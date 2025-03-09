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

`default_nettype none

module vdp_fsm #(
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
    output  wire        hsync_out,
    output  wire        vsync_out,
    output  wire        vid_active_out,
    output  wire        bdr_active_out,
    output  wire        last_pixel_out,
    output  wire        col_last_out,
    output  wire        row_last_out,
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

    localparam  PIPE_LEN = 6*2; // double due to clock doubling
    reg [PIPE_LEN-1:0]  hsync_pipe_reg, hsync_pipe_next;
    reg [PIPE_LEN-1:0]  vsync_pipe_reg, vsync_pipe_next;
    reg [PIPE_LEN-1:0]  vid_active_pipe_reg, vid_active_pipe_next;
    reg [PIPE_LEN-1:0]  bdr_active_pipe_reg, bdr_active_pipe_next;
    reg [PIPE_LEN-1:0]  last_pixel_pipe_reg, last_pixel_pipe_next;
    reg [PIPE_LEN-1:0]  col_last_pipe_reg, col_last_pipe_next;
    reg [PIPE_LEN-1:0]  row_last_pipe_reg, row_last_pipe_next;


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
            hsync_pipe_reg <= 0;
            vsync_pipe_reg <= 0;
            vid_active_pipe_reg <= 0;
            bdr_active_pipe_reg <= 0;
            last_pixel_pipe_reg <= 0;
            col_last_pipe_reg <= 0;
            row_last_pipe_reg <= 0;
            sat_ptr_reg <= 0;
            sprite_ctr_reg <= 0;
            sprite_row_reg <= 0;
            sprite_state_reg <= 0;
            sprite_name_reg <= 0;
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
            hsync_pipe_reg <= hsync_pipe_next;
            vsync_pipe_reg <= vsync_pipe_next;
            vid_active_pipe_reg <= vid_active_pipe_next;
            bdr_active_pipe_reg <= bdr_active_pipe_next;
            last_pixel_pipe_reg <= last_pixel_pipe_next;
            col_last_pipe_reg <= col_last_pipe_next;
            row_last_pipe_reg <= row_last_pipe_next;
            sat_ptr_reg <= sat_ptr_next;
            sprite_ctr_reg <= sprite_ctr_next;
            sprite_row_reg <= sprite_row_next;
            sprite_state_reg <= sprite_state_next;
            sprite_name_reg <= sprite_name_next;
        end
    end

    // pipeline delay for VGA signals
    always @(*) begin
        hsync_pipe_next = { hsync, hsync_pipe_reg[PIPE_LEN-1:1] };
        vsync_pipe_next = { vsync, vsync_pipe_reg[PIPE_LEN-1:1] };
        vid_active_pipe_next = { vid_active, vid_active_pipe_reg[PIPE_LEN-1:1] };
        bdr_active_pipe_next = { bdr_active, bdr_active_pipe_reg[PIPE_LEN-1:1] };
        last_pixel_pipe_next = { last_pixel, last_pixel_pipe_reg[PIPE_LEN-1:1] };
        col_last_pipe_next = { col_last, col_last_pipe_reg[PIPE_LEN-1:1] };
        row_last_pipe_next = { row_last, row_last_pipe_reg[PIPE_LEN-1:1] };
    end


    // fsm temp sprite variables
    localparam VVID_BEGIN = 48;                                         // first vga active video line
    wire [7:0] vdp_row      = (px_row + 1 - VVID_BEGIN) >>> 1;          // truncate to 8 to make comparisons easier
    wire [7:0] sprite_delta = vdp_row - (vram_dout+1);                  // which line of a sprite we are rendering

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
                ring_ctr_reg[0]: begin
                    vdp_dma_addr_next = { vdp_name_base, tile_ctr_reg };
                    vdp_dma_rd_tick_next = 1;
                end
                ring_ctr_reg[1]: begin
                    name_next = vram_dout;
                    // The CPU can use this slot
                end
                ring_ctr_reg[2]: begin
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
                ring_ctr_reg[3]: begin
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
                ring_ctr_reg[4]: begin
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
                ring_ctr_reg[5]: begin
                    // The CPU can use this slot
                    if ( vdp_mode == 3'b100 ) begin
                        // text mode
                        ring_ctr_next = 1;                  // jam-sync to 1 for text mode (6-bit wide tiles)
                        tile_ctr_next = tile_ctr_reg + 1;   // move on to next tile early
                    end
                end
                ring_ctr_reg[6]: begin
                    // The CPU can use this slot
                end
                ring_ctr_reg[7]: begin
                    // The CPU can use this slot
                    tile_ctr_next = tile_ctr_reg + 1;
                end
                endcase
            end
        end


        // This is design is wonky because it could conflict with the above logic
        // by changing vdp_dma_addr_next and vdp_dma_rd_tick_next values if there
        // is an implementation error.

        // Consider forcing the sprite state to DONE when vid_active is true?

`ifdef SIMULATION
        // Sprite-fetching must never happen when vid_active is true.
        if (vid_active && sprite_state_reg != 1<<SPRITE_DONE) begin
            $display("%d: vid_active and sprite_state_reg != DONE at same time?", $time);
            $finish;
        end
`endif

        sprite_row_next = sprite_row_reg;
        sat_ptr_next = sat_ptr_reg;
        sprite_ctr_next = sprite_ctr_reg;
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
    assign hsync_out = hsync_pipe_reg[0];
    assign vsync_out = vsync_pipe_reg[0];
    assign vid_active_out = vid_active_pipe_reg[0];
    assign bdr_active_out = bdr_active_pipe_reg[0];
    assign last_pixel_out = last_pixel_pipe_reg[0];
    assign col_last_out = col_last_pipe_reg[0];
    assign row_last_out = row_last_pipe_reg[0];

endmodule
