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
    output  wire        sprite_tick_out,
    output  wire [3:0]  color_out,

    input   wire        sprite_status_reset,           // used to reset the fifth & collision status (for polling)
    output  wire        sprite_fifth_flag,             // true if the fifth_sprite value is value
    output  wire [4:0]  sprite_fifth_sprite,           // the fifth sprite number on a line
    output  wire        sprite_collision               // two visible sprites have collided
    );

    wire [3:0]                  color_out_gfx;
    wire [VRAM_ADDR_WIDTH-1:0]  vdp_dma_addr_gfx;
    wire                        vdp_dma_rd_tick_gfx;

    wire [3:0]                  color_out_sprite;
    wire [VRAM_ADDR_WIDTH-1:0]  vdp_dma_addr_sprite;
    wire                        vdp_dma_rd_tick_sprite;

    // VDP FSM for the tiled active display area
    vdp_fsm_gfx #(
            .VRAM_SIZE(VRAM_SIZE)
        ) gfx (
            .reset(reset),
            .pxclk(pxclk),
            .px_col(px_col),
            .px_row(px_row),
            .vdp_mode(vdp_mode),
            .vdp_blank(vdp_blank),
            .vdp_smag(vdp_smag),
            .vdp_ssiz(vdp_ssiz),
            .vdp_name_base(vdp_name_base),
            .vdp_color_base(vdp_color_base),
            .vdp_pattern_base(vdp_pattern_base),
            .vdp_sprite_att_base(vdp_sprite_att_base),
            .vdp_sprite_pat_base(vdp_sprite_pat_base),
            .vdp_fg_color(vdp_fg_color),
            .vdp_bg_color(vdp_bg_color),
            .hsync(hsync),
            .vsync(vsync),
            .vid_active(vid_active),
            .vid_active0(vid_active0),
            .sprite_tick(sprite_tick),
            .bdr_active(bdr_active),
            .last_pixel(last_pixel),
            .col_last(col_last),
            .row_last(row_last),
            .hsync_out(hsync_out),
            .vsync_out(vsync_out),
            .vid_active_out(vid_active_out),
            .bdr_active_out(bdr_active_out),
            .last_pixel_out(last_pixel_out),
            .col_last_out(col_last_out),
            .row_last_out(row_last_out),
            .sprite_tick_out(sprite_tick_out),

            .vram_dout(vram_dout),

            .vdp_dma_addr(vdp_dma_addr_gfx),
            .vdp_dma_rd_tick(vdp_dma_rd_tick_gfx),
            .color_out(color_out_gfx)
        );

    // VDP FSM for the sprites
    vdp_fsm_sprite #(
            .HPOS_OFFSET(32),      // 32 = left border width
            .VRAM_SIZE(VRAM_SIZE)
        ) sprite (
            .reset(reset),
            .pxclk(pxclk),
            .px_col(px_col),
            .px_row(px_row),
            .vdp_mode(vdp_mode),
            .vdp_blank(vdp_blank),
            .vdp_smag(vdp_smag),
            .vdp_ssiz(vdp_ssiz),
            .vdp_name_base(vdp_name_base),
            .vdp_color_base(vdp_color_base),
            .vdp_pattern_base(vdp_pattern_base),
            .vdp_sprite_att_base(vdp_sprite_att_base),
            .vdp_sprite_pat_base(vdp_sprite_pat_base),
            .vdp_fg_color(vdp_fg_color),
            .vdp_bg_color(vdp_bg_color),
            .hsync(hsync),
            .vsync(vsync),
            .vid_active(vid_active),
            .vid_active0(vid_active0),
            .sprite_tick(sprite_tick),
            .bdr_active(bdr_active),
            .last_pixel(last_pixel),
            .col_last(col_last),
            .row_last(row_last),
            .hsync_out(hsync_out),
            .vsync_out(vsync_out),
            .vid_active_out(vid_active_out),
            .bdr_active_out(bdr_active_out),
            .last_pixel_out(last_pixel_out),
            .col_last_out(col_last_out),
            .row_last_out(row_last_out),
            .sprite_tick_out(sprite_tick_out),

            .vram_dout(vram_dout),

            .vdp_dma_addr(vdp_dma_addr_sprite),
            .vdp_dma_rd_tick(vdp_dma_rd_tick_sprite),
            .color_out(color_out_sprite),

            .status_reset(sprite_status_reset),
            .fifth_flag(sprite_fifth_flag),
            .fifth_sprite(sprite_fifth_sprite),
            .collision(sprite_collision)

        );


    // Pipeline delay synchronizers needed to give the FSMs time to react to the vga signals

    localparam  PIPE_LEN = 6*2; // double due to clock doubling
    reg [PIPE_LEN-1:0]  hsync_pipe_reg, hsync_pipe_next;
    reg [PIPE_LEN-1:0]  vsync_pipe_reg, vsync_pipe_next;
    reg [PIPE_LEN-1:0]  vid_active_pipe_reg, vid_active_pipe_next;
    reg [PIPE_LEN-1:0]  bdr_active_pipe_reg, bdr_active_pipe_next;
    reg [PIPE_LEN-1:0]  last_pixel_pipe_reg, last_pixel_pipe_next;
    reg [PIPE_LEN-1:0]  col_last_pipe_reg, col_last_pipe_next;
    reg [PIPE_LEN-1:0]  row_last_pipe_reg, row_last_pipe_next;
    reg [PIPE_LEN-1:0]  sprite_tick_pipe_reg, sprite_tick_pipe_next;

    // pipeline delay for VGA signals
    always @(*) begin
        hsync_pipe_next = { hsync, hsync_pipe_reg[PIPE_LEN-1:1] };
        vsync_pipe_next = { vsync, vsync_pipe_reg[PIPE_LEN-1:1] };
        vid_active_pipe_next = { vid_active, vid_active_pipe_reg[PIPE_LEN-1:1] };
        bdr_active_pipe_next = { bdr_active, bdr_active_pipe_reg[PIPE_LEN-1:1] };
        last_pixel_pipe_next = { last_pixel, last_pixel_pipe_reg[PIPE_LEN-1:1] };
        col_last_pipe_next = { col_last, col_last_pipe_reg[PIPE_LEN-1:1] };
        row_last_pipe_next = { row_last, row_last_pipe_reg[PIPE_LEN-1:1] };
        sprite_tick_pipe_next = { sprite_tick, sprite_tick_pipe_reg[PIPE_LEN-1:1] };
    end

    always @(posedge pxclk) begin
        if ( reset ) begin
            hsync_pipe_reg <= 0;
            vsync_pipe_reg <= 0;
            vid_active_pipe_reg <= 0;
            bdr_active_pipe_reg <= 0;
            last_pixel_pipe_reg <= 0;
            col_last_pipe_reg <= 0;
            row_last_pipe_reg <= 0;
            sprite_tick_pipe_reg <= 0;
        end else begin
            hsync_pipe_reg <= hsync_pipe_next;
            vsync_pipe_reg <= vsync_pipe_next;
            vid_active_pipe_reg <= vid_active_pipe_next;
            bdr_active_pipe_reg <= bdr_active_pipe_next;
            last_pixel_pipe_reg <= last_pixel_pipe_next;
            col_last_pipe_reg <= col_last_pipe_next;
            row_last_pipe_reg <= row_last_pipe_next;
            sprite_tick_pipe_reg <= sprite_tick_pipe_next;
        end
    end

    assign hsync_out = hsync_pipe_reg[0];
    assign vsync_out = vsync_pipe_reg[0];
    assign vid_active_out = vid_active_pipe_reg[0];
    assign bdr_active_out = bdr_active_pipe_reg[0];
    assign last_pixel_out = last_pixel_pipe_reg[0];
    assign col_last_out = col_last_pipe_reg[0];
    assign row_last_out = row_last_pipe_reg[0];
    assign sprite_tick_out = sprite_tick_pipe_reg[0];


    // MUX the VRAM access signals from the gfx & sprite FSMs
    // Note that the sprite FSM does NOT access the VRAM when vid_active is high

`ifdef SIMULATION
    always @(*)
        if ( vdp_dma_rd_tick_gfx && vdp_dma_rd_tick_sprite ) begin
            $display("%d: vdp_dma_rd_tick_gfx and vdp_dma_rd_tick_sprite are both active at the same time!", $time);
            $finish;
        end
`endif

    assign vdp_dma_rd_tick = vdp_dma_rd_tick_gfx | vdp_dma_rd_tick_sprite;
    assign vdp_dma_addr = vdp_dma_rd_tick_gfx ? vdp_dma_addr_gfx : vdp_dma_addr_sprite;

    // if a sprite color is zero, then it is transparent
    assign color_out = color_out_sprite == 0 ? color_out_gfx : color_out_sprite;

endmodule
