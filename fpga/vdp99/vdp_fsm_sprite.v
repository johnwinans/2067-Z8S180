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
* Sprite implementation FSM
***************************************************************************/

module vdp_fsm_sprite #(
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

    reg         vdp_dma_rd_tick_reg, vdp_dma_rd_tick_next;
    reg [VRAM_ADDR_WIDTH-1:0]  vdp_dma_addr_reg, vdp_dma_addr_next;

    reg [7:0]   color_reg, color_next;
    reg [3:0]   color_out_reg, color_out_next;

    localparam SAT_VERT_SENTINEL = 'hd0;    // VDP vertical position representing the end of the SAT
    reg [VRAM_ADDR_WIDTH-1:0] sat_ptr_reg, sat_ptr_next;
    reg [2:0] sprite_ctr_reg, sprite_ctr_next;
    reg [7:0] sprite_row_reg, sprite_row_next;
    reg [7:0] sprite_name_reg, sprite_name_next;

    reg [9:0] sprite_state_reg, sprite_state_next;
    localparam SPRITE_VERT  = 0;
    localparam SPRITE_DELTA = 1;
    localparam SPRITE_HWAIT = 2;
    localparam SPRITE_HORIZ = 3;
    localparam SPRITE_NAME  = 4;
    localparam SPRITE_COLOR = 5;
    localparam SPRITE_WAIT  = 6;
    localparam SPRITE_PTRN1 = 7;
    localparam SPRITE_PTRN2 = 8;
    localparam SPRITE_DONE  = 9;

    always @(posedge pxclk) begin
        if ( reset ) begin
            color_reg <= 0;
            color_out_reg <= 0;
            vdp_dma_rd_tick_reg <= 0;
            vdp_dma_addr_reg <= 0;
            sat_ptr_reg <= 0;
            sprite_ctr_reg <= 0;
            sprite_row_reg <= 0;
            sprite_state_reg <= 0;
            sprite_name_reg <= 0;
        end else begin
            color_reg <= color_next;
            color_out_reg <= color_out_next;
            vdp_dma_rd_tick_reg <= vdp_dma_rd_tick_next;
            vdp_dma_addr_reg <= vdp_dma_addr_next;
            sat_ptr_reg <= sat_ptr_next;
            sprite_ctr_reg <= sprite_ctr_next;
            sprite_row_reg <= sprite_row_next;
            sprite_state_reg <= sprite_state_next;
            sprite_name_reg <= sprite_name_next;
        end
    end

    // fsm temp sprite variables
    localparam VVID_BEGIN = 48;                                         // first vga active video line
    wire [7:0] vdp_row      = (px_row + 1 - VVID_BEGIN) >>> 1;          // truncate to 8 to make comparisons easier
    wire [7:0] sprite_delta = vdp_row - (vram_dout+1);                  // which line of a sprite we are rendering

    always @(*) begin
`ifdef SIMULATION
        // Sprite-fetching must never happen when vid_active is true.
        if (vid_active && sprite_state_reg != 1<<SPRITE_DONE) begin
            $display("%d: vid_active and sprite_state_reg != DONE at same time?", $time);
            $finish;
        end
`endif

        vdp_dma_rd_tick_next = 0;       // default to zero makes the ticks 1 vga pxclk wide (be careful of the phase!)
        vdp_dma_addr_next = 'hx;
        color_out_next = color_out_reg;

        sprite_row_next = sprite_row_reg;
        sat_ptr_next = sat_ptr_reg;
        sprite_ctr_next = sprite_ctr_reg;
        sprite_name_next = sprite_name_reg;
        sprite_state_next = 0;      // by default, there is no state (becomes DONE by default case below)

        if (sprite_tick) begin
            // Reset the sprite fetch logic for the next VGA pixel row.
            // This is forced any time sprite_tick is true to make debugging easier.
            // Should be moved into the DONE state.
            sprite_state_next[SPRITE_VERT] = 1;
            sprite_ctr_next = 0;
            sat_ptr_next = {vdp_sprite_att_base, 7'b0000000};
            vdp_dma_addr_next = sat_ptr_next;
            vdp_dma_rd_tick_next = 1;

        end else begin

            (* parallel_case *)
            case (1)
            sprite_state_reg[SPRITE_VERT]: begin
                if (sat_ptr_reg[6:2] == 31) begin           // this address is the end of the SAT
                    sprite_state_next[SPRITE_DONE] = 1;
                end else begin
                    sprite_state_next[SPRITE_DELTA] = 1;
                end
            end

            sprite_state_reg[SPRITE_DELTA]: begin       // vram_dout = VDP row number
                if (vram_dout == SAT_VERT_SENTINEL) begin
                    sprite_state_next[SPRITE_DONE] = 1;
                end else begin
                    if (sprite_delta < 8) begin     // if in range...
    $display("px_row:%d vert:%d vdp_row:%3d delta:%2d sprite:%d", px_row, vram_dout, vdp_row, sprite_delta, sprite_ctr_reg);
                        if (sprite_ctr_reg == 4) begin
                            // this is the 5th sprite
                            // XXX the5thsprite_number = sat_ptr_next[6:2];
                            sprite_state_next[SPRITE_DONE] = 1;
                        end else begin
                            sprite_row_next = sprite_delta;        // save the delta for configuring the sprite
                            sat_ptr_next = sat_ptr_reg+1;           // sprite name address
                            vdp_dma_addr_next = sat_ptr_next;
                            vdp_dma_rd_tick_next = 1;
                            sprite_state_next[SPRITE_HWAIT] = 1;
                        end
                    end else begin
                        // sprite is not in vertical range
                        sat_ptr_next = sat_ptr_reg+4;               // advance to the NEXT sprite address
                        vdp_dma_addr_next = sat_ptr_next;
                        vdp_dma_rd_tick_next = 1;
                        sprite_state_next[SPRITE_VERT] = 1;
                    end
                end
            end

            sprite_state_reg[SPRITE_HWAIT]: begin
                sprite_state_next[SPRITE_HORIZ] = 1;
                // waiting for horiz value, prepare for sprite name
                sat_ptr_next = sat_ptr_reg+1;           // advance to sprite name address
                vdp_dma_addr_next = sat_ptr_next;
                vdp_dma_rd_tick_next = 1;
            end

            sprite_state_reg[SPRITE_HORIZ]: begin
                sprite_state_next[SPRITE_NAME] = 1;
                sat_ptr_next = sat_ptr_reg+1;           // advance to sprite color address
                vdp_dma_addr_next = sat_ptr_next;
                vdp_dma_rd_tick_next = 1;
            end

            sprite_state_reg[SPRITE_NAME]: begin
                sprite_state_next[SPRITE_COLOR] = 1;
                sprite_name_next = vram_dout;
                sat_ptr_next = sat_ptr_reg+1;           // advance to the next sprite address
                // prepare for pattern1
                vdp_dma_addr_next = {vdp_sprite_pat_base, sprite_name_next, sprite_row_reg[2:0]};    // row = 0..15
                vdp_dma_rd_tick_next = 1;
            end

            sprite_state_reg[SPRITE_COLOR]: begin
                sprite_state_next[SPRITE_PTRN1] = 1;
                // prepare for pattern2
                vdp_dma_addr_next = vdp_dma_addr_reg + 16;  // address of the right-half of a wide sprite pattern
                vdp_dma_rd_tick_next = 1;
            end

            sprite_state_reg[SPRITE_PTRN1]: begin
                sprite_state_next[SPRITE_PTRN2] = 1;
            end

            sprite_state_reg[SPRITE_PTRN2]: begin
                sprite_state_next[SPRITE_VERT] = 1;
                sprite_ctr_next = sprite_ctr_reg + 1;       // advance to configure the next sprite
                // prepare for DELTA
                vdp_dma_addr_next = sat_ptr_next;
                vdp_dma_rd_tick_next = 1;
            end

            sprite_state_reg[SPRITE_DONE]:
                // seize sprite fetching FSM until next sprite_tick
                sprite_state_next[SPRITE_DONE] = 1;

            default: begin
                // should never get here, reset the FSM
                sprite_state_next = 0;
                sprite_state_next[SPRITE_DONE] = 1;
            end
            endcase
        end

    end

    assign vdp_dma_addr = vdp_dma_addr_reg;
    assign vdp_dma_rd_tick = vdp_dma_rd_tick_reg;

    assign color_out = color_out_reg;

endmodule
