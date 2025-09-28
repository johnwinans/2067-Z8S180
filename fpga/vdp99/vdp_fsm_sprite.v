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
* Sprite implementation FSM.
*
* The SAT is scanned, starting in the right-border of the scan line
* preceeding the line we are preparing to render.  Therefore, the row
* number is one less than the target.
*
* The sprites are only rendered and collisions checked during the active
* portion of the display area.
*
* This FSM will never assert vdp_dma_rd_tick during the active display region.
***************************************************************************/

module vdp_fsm_sprite #(
    parameter HPOS_OFFSET = 0,                      // offset horizontal to right
    parameter VRAM_SIZE = 8*1024,
    parameter VRAM_ADDR_WIDTH = $clog2(VRAM_SIZE)   // annoying this must be here to use in a port
    ) (
    input   wire        reset,                  // active high
    input   wire        pxclk,                  // 25MHZ (VGA clock, not VDP clk)

    input   wire [9:0]  px_col,                 // VGA column number
    input   wire [9:0]  px_row,                 // VGA pixel row number

    // The following config values are stable over time as far as this module is concerned.
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

    // VRAM access
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
    input   wire        sprite_tick_out,

    input   wire        status_reset,           // used to reset the fifth & collision status (for polling)
    output  wire        fifth_flag,             // true if the fifth_sprite value is value
    output  wire [4:0]  fifth_sprite,           // the fifth sprite number on a line
    output  wire        collision,              // two visible sprites have collided

    output  wire [3:0]  color_out               // recall that 0 = transparent
    );

    // These are used to access the VRAM
    reg         vdp_dma_rd_tick_reg, vdp_dma_rd_tick_next;
    reg [VRAM_ADDR_WIDTH-1:0]  vdp_dma_addr_reg, vdp_dma_addr_next;

    // sprite status flags (collisions, 5th on a line,...)
    reg         collision_reg, collision_next;
    reg [4:0]   fifth_sprite_reg, fifth_sprite_next;
    reg         fifth_flag_reg, fifth_flag_next;

    // These signals are used to collect the config values for a given sprite before
    // writing them into a sprite object.
    // Note to future self: It might use less LUTs to implement the latches here
    // as opposed to inside the sprite modules.
    reg [8:0]   hpos_reg, hpos_next;
    reg [15:0]  pattern_reg, pattern_next;
    reg [3:0]   fg_color_reg, fg_color_next;
    reg [3:0]   sprite_load_tick_reg, sprite_load_tick_next;
    reg         sprite_reset_reg, sprite_reset_next;

    wire [3:0]  sprite_color_out[3:0];              // note: one for each sprite object

    // the sprite controllers
    genvar i;
    generate
        for (i=0; i<4; i=i+1) begin : inst
            sprite s (
                .reset(reset | sprite_reset_reg),
                .pxclk(pxclk),
                .vdp_col0_tick(col_last_out),
                .mag(vdp_smag),                     // Note this comes from VDP config reg 1
                .hpos(hpos_reg),                    // SAT
                .pattern(pattern_reg),              // SAT
                .fg_color(fg_color_reg),            // SAT
                .load_tick(sprite_load_tick_reg[i]),
                .color_out(sprite_color_out[i])
            );
        end
    endgenerate


    localparam SAT_VERT_SENTINEL = 'hd0;            // VDP vertical position representing the end of the SAT
    reg [6:0] sat_off_reg, sat_off_next;            // used to scan the SAT
    reg [2:0] sprite_ctr_reg, sprite_ctr_next;      // counts the 4 visible sprites: 0..4
    reg [7:0] sprite_row_reg, sprite_row_next;      // relative row number of a given sprite
    reg [7:0] sprite_name_reg, sprite_name_next;    // name from the current SAT entry

    reg [9:0] sprite_state_reg, sprite_state_next;  // the one-hot state bits
    localparam SPRITE_IDLE  = 0;
    localparam SPRITE_VERT  = 1;
    localparam SPRITE_DELTA = 2;
    localparam SPRITE_HWAIT = 3;
    localparam SPRITE_HORIZ = 4;
    localparam SPRITE_NAME  = 5;
    localparam SPRITE_COLOR = 6;
    localparam SPRITE_PTRN1 = 7;
    localparam SPRITE_PTRN2 = 8;

    always @(posedge pxclk) begin
        if ( reset ) begin
            vdp_dma_rd_tick_reg <= 0;
            vdp_dma_addr_reg <= 0;
            sat_off_reg <= 0;
            sprite_ctr_reg <= 0;
            sprite_row_reg <= 0;
            sprite_state_reg <= 1'b1<<SPRITE_IDLE;
            sprite_name_reg <= 0;
            hpos_reg <= 0;
            pattern_reg <= 0;
            fg_color_reg <= 0;
            sprite_load_tick_reg <= 0;
            sprite_reset_reg <= 0;
            collision_reg <= 0;
            fifth_sprite_reg <= 0;
            fifth_flag_reg <= 0;
        end else begin
            vdp_dma_rd_tick_reg <= vdp_dma_rd_tick_next;
            vdp_dma_addr_reg <= vdp_dma_addr_next;
            sat_off_reg <= sat_off_next;
            sprite_ctr_reg <= sprite_ctr_next;
            sprite_row_reg <= sprite_row_next;
            sprite_state_reg <= sprite_state_next;
            sprite_name_reg <= sprite_name_next;
            hpos_reg <= hpos_next;
            pattern_reg <= pattern_next;
            fg_color_reg <= fg_color_next;
            sprite_load_tick_reg <= sprite_load_tick_next;
            sprite_reset_reg <= sprite_reset_next;
            collision_reg <= collision_next;
            fifth_sprite_reg <= fifth_sprite_next;
            fifth_flag_reg <= fifth_flag_next;
        end
    end

    // FSM temp sprite variables
    localparam VVID_BEGIN = 48;                                 // first vga active video line (even)
    wire [7:0] vdp_row      = (px_row + 1 - VVID_BEGIN) >>> 1;  // truncate to 8 to make comparisons easier
    wire [7:0] sprite_delta = vdp_row - (vram_dout+1);          // which line of a sprite we are rendering
    reg  [5:0] sprite_size;

    always @(*) begin
`ifdef SIMULATION
        // Sprite-fetching must never happen when vid_active is true.
        if (vid_active && sprite_state_reg != 1'b1<<SPRITE_IDLE) begin
            $display("%d: vid_active and sprite_state_reg != DONE at same time?", $time);
            $finish;
        end
`endif
        // determine the displayed size of the sprite
        case (1)
        (vdp_ssiz & vdp_smag):  sprite_size = 32;
        (vdp_ssiz ^ vdp_smag):  sprite_size = 16;
        default:                sprite_size = 8;
        endcase

        vdp_dma_rd_tick_next = 0;       // default to zero makes the ticks 1 vga pxclk wide (be careful of the phase!)
        vdp_dma_addr_next = 'hx;

        hpos_next = hpos_reg;
        pattern_next = pattern_reg;
        fg_color_next = fg_color_reg;
        sprite_load_tick_next = 0;
        sprite_reset_next = 0;

        collision_next = collision_reg;
        fifth_sprite_next = fifth_sprite_reg;
        fifth_flag_next = fifth_flag_reg;

        sprite_row_next = sprite_row_reg;
        sat_off_next = sat_off_reg;
        sprite_ctr_next = sprite_ctr_reg;
        sprite_name_next = sprite_name_reg;
        sprite_state_next = 0;      // by default, there is no state (becomes SPRITE_IDLE by default case below)

        // When the status register is read, reset the sprite status bits
        if ( status_reset ) begin
            collision_next = 0;
            fifth_sprite_next = 0;
            fifth_flag_next = 0;
        end

        // collision detector runs all the time watching if multiple sprites are rendering a color at the same time
        if ( vid_active_out && collision_reg == 0 ) begin
            case ({ sprite_color_out[0]!=0, sprite_color_out[1]!=0, sprite_color_out[2]!=0, sprite_color_out[3]!=0 })
            4'b0000:    collision_next = 0;
            4'b0001:    collision_next = 0;
            4'b0010:    collision_next = 0;
            4'b0100:    collision_next = 0;
            4'b1000:    collision_next = 0;
            default:    collision_next = 1;      // more than 1 must be opaque
            endcase
        end

        (* parallel_case *)
        case (1)

        sprite_state_reg[SPRITE_IDLE]: begin            // waiting for sprite_tick
            if (sprite_tick_out) begin
                // Reset the sprite fetch logic for the next VGA pixel row.
                sprite_state_next[SPRITE_VERT] = 1;
                sprite_ctr_next = 0;                    // scanning for the first (0th) of 4 visible sprites
                sat_off_next = 0;                       // point to first SAT entry
                vdp_dma_addr_next = {vdp_sprite_att_base, sat_off_next};
                vdp_dma_rd_tick_next = 1;
                sprite_reset_next = 1;                  // reset (and blank) all the sprites in case they are not used
            end else begin
                sprite_state_next[SPRITE_IDLE] = 1;
            end
        end

        sprite_state_reg[SPRITE_VERT]: begin            // reading SAT entry vert pos
            sprite_state_next[SPRITE_DELTA] = 1;        // wait for the VRAM to finish
        end

        sprite_state_reg[SPRITE_DELTA]: begin           // vram_dout = VDP row number
            if (vram_dout == SAT_VERT_SENTINEL) begin
                sprite_state_next[SPRITE_IDLE] = 1;
            end else begin
                if (sprite_delta < sprite_size) begin   // if in range...
`ifdef SIMULATION
$display("px_row:%d vert:%d vdp_row:%3d delta:%2d sprite:%d", px_row, vram_dout, vdp_row, sprite_delta, sprite_ctr_reg);
`endif
                    if (sprite_ctr_reg == 4) begin
`ifdef SIMULATION
$display("5th sprite sat_off_reg:%x", sat_off_reg);
`endif
                        // This is the 5th sprite
                        if ( ~fifth_flag_reg ) begin
                            // if not already reporting one...
                            fifth_sprite_next = sat_off_reg[6:2];   // the 5th sprite index
                            fifth_flag_next = 1;
                        end
                        sprite_state_next[SPRITE_IDLE] = 1;
                    end else begin
`ifdef SIMULATION
$display("sprite:%d sat_off_reg:%x", sprite_ctr_reg, sat_off_reg);
`endif
                        // save the delta for configuring the sprite
                        sprite_row_next = vdp_smag ? sprite_delta/2 : sprite_delta; // the pattern row
                        sat_off_next = sat_off_reg+1;           // sprite horizontal pos address
                        vdp_dma_addr_next = {vdp_sprite_att_base, sat_off_next};
                        vdp_dma_rd_tick_next = 1;
                        sprite_state_next[SPRITE_HWAIT] = 1;
                    end
                end else begin
                    // sprite is not in vertical range, skip it
                    sat_off_next = sat_off_reg+4;               // advance to the NEXT sprite address
                    if ( sat_off_next == 0 ) begin
                        sprite_state_next[SPRITE_IDLE] = 1;     // wrap around, we're done
                    end else begin
                        vdp_dma_addr_next = {vdp_sprite_att_base, sat_off_next};
                        vdp_dma_rd_tick_next = 1;
                        sprite_state_next[SPRITE_VERT] = 1;
                    end
                end
            end
        end

        sprite_state_reg[SPRITE_HWAIT]: begin
            sprite_state_next[SPRITE_HORIZ] = 1;
            // waiting for horiz value, prepare for sprite name
            sat_off_next = sat_off_reg+1;           // advance to sprite name address
            vdp_dma_addr_next = {vdp_sprite_att_base, sat_off_next};
            vdp_dma_rd_tick_next = 1;
`ifdef SIMULATION
$display("sprite:%d sat_off_reg:%x HWAIT vram:%d", sprite_ctr_reg, sat_off_reg, vram_dout);
`endif
        end

        sprite_state_reg[SPRITE_HORIZ]: begin       // got horiz, prep to read color, advance to read name
            sprite_state_next[SPRITE_NAME] = 1;
            sat_off_next = sat_off_reg+1;           // advance to next SAT ec,color address
            vdp_dma_addr_next = {vdp_sprite_att_base, sat_off_next};
            vdp_dma_rd_tick_next = 1;
`ifdef SIMULATION
$display("sprite:%d sat_off_reg:%x HORIZ hpos:%d", sprite_ctr_reg, sat_off_reg, vram_dout);
`endif
            hpos_next = vram_dout;
        end

        sprite_state_reg[SPRITE_NAME]: begin        // got name, prep to read pattern (left), advance to color
            sprite_state_next[SPRITE_COLOR] = 1;
            sprite_name_next = vram_dout;
            sat_off_next = sat_off_reg+1;           // advance to the next SAT sprite entry
            // prepare for pattern1 (the left half)
            if ( vdp_ssiz )
                // 16x16 sprites only have a %4 'name' as implied by page 3-4 of
                // the TMS9918A/TMS9928A/TMS9929A VDP Data Manual (MP010A) (c) 1982.
                // Note the diagram in VDP Programmer's Guide (SPPU004) (c) 1984 is garbage.
                vdp_dma_addr_next = {vdp_sprite_pat_base, sprite_name_next[7:2], 1'b0, sprite_row_reg[3:0]};  // 16x16 left
            else
                vdp_dma_addr_next = {vdp_sprite_pat_base, sprite_name_next, sprite_row_reg[2:0]};    // 8x8
            vdp_dma_rd_tick_next = 1;
`ifdef SIMULATION
$display("sprite:%d sat_off_reg:%x NAME  name:%x", sprite_ctr_reg, sat_off_reg, sprite_name_next);
`endif
        end

        sprite_state_reg[SPRITE_COLOR]: begin       // got color, prep to read pattern right if got one, advance to pat
            sprite_state_next[SPRITE_PTRN1] = 1;
            // prepare for pattern2 (the right half, if present)
            vdp_dma_addr_next = {vdp_sprite_pat_base, sprite_name_next[7:2], 1'b1, sprite_row_reg[3:0]};  // 16x16 right
            vdp_dma_rd_tick_next = vdp_ssiz;            // if we are 16x16 then read the other half, else not & waste cycle
            fg_color_next = vram_dout[3:0];
            // vram_dout[7] is the early-clock flag, shift the hpos to the left
            //hpos_next = (vram_dout[7] ? hpos_reg - 32 : hpos_reg) + HPOS_OFFSET;  // logical but complex
            hpos_next = hpos_reg + ( vram_dout[7] ? 0 : HPOS_OFFSET );              // simpler
`ifdef SIMULATION
$display("sprite:%d sat_off_reg:%x COLOR color:%x ec:%b", sprite_ctr_reg, sat_off_reg, fg_color_next, vram_dout[7]);
`endif
        end

        sprite_state_reg[SPRITE_PTRN1]: begin       // got left side pattern from VRAM, advance to pat right side
            sprite_state_next[SPRITE_PTRN2] = 1;
            pattern_next[15:8] = vram_dout;         // sprite pattern left half
`ifdef SIMULATION
$display("sprite:%d sat_off_reg:%x PTRN1 pattern_next:%x", sprite_ctr_reg, sat_off_reg, pattern_next);
`endif
        end

        sprite_state_reg[SPRITE_PTRN2]: begin       // got pattern right (or nothing), prep for next SAT entry
            // NOTE: Consuming a time slot for this is superfluous when vdp_ssiz == 0, but simplifies the code.

            if ( sat_off_reg == 0 ) begin
                // wrapped around, SAT scan done
                sprite_state_next[SPRITE_IDLE] = 1;
            end else begin
                // prepare for next SAT entry DELTA
                sprite_state_next[SPRITE_VERT] = 1;
                vdp_dma_addr_next = {vdp_sprite_att_base, sat_off_reg};
                vdp_dma_rd_tick_next = 1;
            end

            pattern_next[7:0] = vdp_ssiz ? vram_dout : 0;   // ingest right half if present, else transparent
`ifdef SIMULATION
$display("sprite:%d sat_off_reg:%x PTRN2 vram:%x  pattern:%x <-------------------", sprite_ctr_reg, sat_off_reg, vram_dout, pattern_next);
`endif
            sprite_load_tick_next[sprite_ctr_reg] = 1;      // save the sprite config
            sprite_ctr_next = sprite_ctr_reg + 1;           // advance to configure the next sprite
        end

        default: begin
            // should never get here, reset the FSM
            sprite_state_next = 0;
            sprite_state_next[SPRITE_IDLE] = 1;
`ifdef SIMULATION
$display("sprite FSM is stuck");
$finish;
`endif
        end
        endcase

    end

    assign vdp_dma_addr = vdp_dma_addr_reg;
    assign vdp_dma_rd_tick = vdp_dma_rd_tick_reg;

    // A prio encoder to decide which sprite will appear.
    assign color_out =  sprite_color_out[0] != 0 ? sprite_color_out[0] :
                        sprite_color_out[1] != 0 ? sprite_color_out[1] :
                        sprite_color_out[2] != 0 ? sprite_color_out[2] :
                        sprite_color_out[3];

    assign collision = collision_reg;
    assign fifth_sprite = fifth_sprite_reg;
    assign fifth_flag = fifth_flag_reg;

endmodule
