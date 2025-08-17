//**************************************************************************
//
//    Copyright (C) 2025  John Winans
//
//    This library is free software; you can redistribute it and/or
//    modify it under the terms of the GNU Lesser General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
//    USA
//
//**************************************************************************

`timescale 1ns/1ns
`default_nettype none

/**
* Control the video pipeline of the VDP.
***************************************************************************/

module vdp_fsm_gfx #(
    parameter VRAM_SIZE = 8*1024,
    parameter VRAM_ADDR_WIDTH = $clog2(VRAM_SIZE)   // annoying this must be here to use in a port
    ) (
    input   wire        reset,      // active high
    input   wire        pxclk,      // 25MHZ

    input   wire [9:0]  px_col,
    input   wire [9:0]  px_row,

    input   wire [2:0]  vdp_mode,
    input   wire        vdp_blank,
    input   wire        vdp_smag,
    input   wire        vdp_ssiz,
    input   wire [3:0]  vdp_name_base,
    input   wire [7:0]  vdp_color_base,
    input   wire [2:0]  vdp_pattern_base,
    input   wire [6:0]  vdp_sprite_att_base,
    input   wire [2:0]  vdp_sprite_pat_base,
    input   wire [3:0]  vdp_fg_color,           // text foreground
    input   wire [3:0]  vdp_bg_color,           // text and border background

    // VRAM access signals
    output  wire [VRAM_ADDR_WIDTH-1:0] vdp_dma_addr,  // VRAM DMA access address
    output  wire        vdp_dma_rd_tick,        // read vdp_dma_addr
    input   wire [7:0]  vram_dout,              // data from the VRAM

    // signals from the VGA timing generator
    input   wire        hsync,
    input   wire        vsync,
    input   wire        vid_active,
    input   wire        vid_active0,            // 1 px_clk early view of vid_active
    input   wire        sprite_tick,
    input   wire        bdr_active,
    input   wire        last_pixel,
    input   wire        col_last,
    input   wire        row_last,

    // pipeline-delayed signals
    input   wire        hsync_out,
    input   wire        vsync_out,
    input   wire        vid_active_out,
    input   wire        bdr_active_out,
    input   wire        last_pixel_out,
    input   wire        col_last_out,
    input   wire        row_last_out,

    output  wire [3:0]  color_out
    );

    integer i;

    // use a ring counter to generate an 8-clock cycle for mode1 and mode2 graphics.
    // name, cpu, color, pattern, x, cpu, x, x

    reg [7:0]   ring_ctr_reg, ring_ctr_next;

    reg [7:0]   name_reg, name_next;
    reg [7:0]   color_reg, color_next;
    reg [3:0]   color_out_reg, color_out_next;
    reg [7:0]   pattern_reg, pattern_next;
    reg         pixel_reg, pixel_next;          // used to delay the pixel by 1 clock

    reg         vdp_dma_rd_tick_reg, vdp_dma_rd_tick_next;
    reg [VRAM_ADDR_WIDTH-1:0]  vdp_dma_addr_reg, vdp_dma_addr_next;
    reg [9:0]   tile_ctr_reg, tile_ctr_next;
    reg [9:0]   tile_ctr_row_reg, tile_ctr_row_next;

    always @(posedge pxclk) begin
        if ( reset ) begin
            ring_ctr_reg <= 1;
            name_reg <= 0;
            color_reg <= 0;
            color_out_reg <= 0;
            pattern_reg <= 0;
            vdp_dma_rd_tick_reg <= 0;
            vdp_dma_addr_reg <= 0;
            tile_ctr_reg <= 0;
            tile_ctr_row_reg <= 0;
            pixel_reg <= 0;
        end else begin
            ring_ctr_reg <= ring_ctr_next;
            name_reg <= name_next;
            color_reg <= color_next;
            color_out_reg <= color_out_next;
            pattern_reg <= pattern_next;
            vdp_dma_rd_tick_reg <= vdp_dma_rd_tick_next;
            vdp_dma_addr_reg <= vdp_dma_addr_next;
            tile_ctr_reg <= tile_ctr_next;
            tile_ctr_row_reg <= tile_ctr_row_next;
            pixel_reg <= pixel_next;
        end
    end

    always @(*) begin

        vdp_dma_rd_tick_next = 0;       // default to zero makes the ticks 1 vga pxclk wide (be careful of the phase!)
        vdp_dma_addr_next = 'hx;

        tile_ctr_next = tile_ctr_reg;
        name_next = name_reg;
        pattern_next = pattern_reg;
        color_next = color_reg;
        pixel_next = pixel_reg;
        ring_ctr_next = ring_ctr_reg;
        tile_ctr_row_next = tile_ctr_row_reg;
        color_out_next = color_out_reg;

        if (vsync) begin
            tile_ctr_next = 0;          // reset on every vsync
            tile_ctr_row_next = 0;      // reset on every vsync
        end else begin
            // NOTE: col_last_out will never happen when vid_active is true (no conflict with phase 6)
            if ( col_last_out ) begin                   // just after the input row counter advances
                if (px_row[3:0]!='b0000)                // XXX will only work if top border is %8 rows high
                    tile_ctr_next = tile_ctr_row_reg;   // reload the tile_counter for the current row
                else
                    tile_ctr_row_next = tile_ctr_reg;   // save current tile counter for this and the next 7 rows
            end
        end

        // only on every other clock cycle to divide the pxclock by 2
        // XXX This will fail by 1/2 VDP pixel if the border does not end when px_col is odd
        if ( px_col[0] ) begin

            if ( col_last )
                // XXX this is sloppy because it depends on the col_last tick occurring on an odd pixel column
                ring_ctr_next = 1;                      // this is needed to keep text mode in phase
            else
                ring_ctr_next = { ring_ctr_reg[6:0], ring_ctr_reg[7] }; // rotate left

            pattern_next = { pattern_reg[6:0], 1'b0 };                  // shift left on each VDP pixel
            pixel_next = pattern_reg[7];

            color_out_next = pixel_reg ? color_reg[7:4] : color_reg[3:0];
            if ( color_out_next == 0 )
                color_out_next = vdp_bg_color;      // transparent, show bgcolor from vdp reg 7

            if (vid_active) begin
                (* parallel_case, full_case *)
                case (1)
                ring_ctr_reg[0]: begin      // prep DMA addr to fetch a tile name from pattern table
                    vdp_dma_addr_next = { vdp_name_base, tile_ctr_reg };
                    vdp_dma_rd_tick_next = 1;
                end
                ring_ctr_reg[1]: begin      // capture the tile name from the pattern table
                    name_next = vram_dout;
                    // The CPU can use this slot
                end
                ring_ctr_reg[2]: begin      // prep DMA addr to fetch a tile pattern
                    vdp_dma_rd_tick_next = 1;
                    case ( vdp_mode )
                    3'b000:     // graphics mode 1
                        // name*8 + character row number ( use 3:1 because we are doubling the rows )
                        vdp_dma_addr_next = { vdp_pattern_base, name_reg, px_row[3:1] };
                    3'b001:     // graphics mode 2
                        // tile_ctr_reg % 256 gives us the screen partition
                        vdp_dma_addr_next = { vdp_pattern_base[2], tile_ctr_reg[9:8], name_reg, px_row[3:1] };
                    //3'b010:     // multicolor mode
                    3'b100:     // text mode
                        // name*8 + character row number ( use 3:1 because we are doubling the rows )
                        vdp_dma_addr_next = { vdp_pattern_base, name_reg, px_row[3:1] };
                    default:
                        vdp_dma_rd_tick_next = 0;
                    endcase
                end
                ring_ctr_reg[3]: begin      // capture tile pattern & prep DMA addr to fetch color
                    pattern_next = vram_dout;
                    vdp_dma_rd_tick_next = 1;
                    case ( vdp_mode )
                    3'b000:     // graphics mode 1
                        vdp_dma_addr_next = { vdp_color_base, 1'b0, name_reg[7:3] };
                    3'b001:     // graphics mode 2
                        vdp_dma_addr_next = { vdp_color_base[7], tile_ctr_reg[9:8], name_reg, px_row[3:1] };
                    //3'b010:     // multicolor mode
                    //3'b100:     // text mode
                    default: begin
                        // multicolor & text have no color table
                        vdp_dma_rd_tick_next = 0;
                    end
                    endcase
                end
                ring_ctr_reg[4]: begin      // capture color
                    case ( vdp_mode )
                    3'b100:        // text mode
                        color_next = { vdp_fg_color, vdp_bg_color };
                    //3'b010:     // multicolor mode (get color from pattern table & render differently)
                    //3'b000:     // graphics mode 1
                    //3'b001:     // graphics mode 2
                    default:
                        color_next = vram_dout;
                    endcase
                end
                ring_ctr_reg[5]: begin      // if in text mode, advance to next tile early
                    // The CPU can use this slot
                    if ( vdp_mode == 3'b100 ) begin
                        // text mode
                        ring_ctr_next = 1;                  // jam-sync to 1 for text mode (6-bit wide tiles)
                        tile_ctr_next = tile_ctr_reg + 1;   // move on to next tile early
                    end
                end
                ring_ctr_reg[6]: begin      // idle slot
                    // The CPU can use this slot
                end
                ring_ctr_reg[7]: begin      // advance to next tile
                    // The CPU can use this slot
                    tile_ctr_next = tile_ctr_reg + 1;
                end
                endcase
            end
        end

    end

    assign vdp_dma_addr = vdp_dma_addr_reg;
    assign vdp_dma_rd_tick = vdp_dma_rd_tick_reg;
    assign color_out = color_out_reg;

endmodule
