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

module vdp99 #(
    parameter   VRAM_SIZE = 8*1024 // 12*1024 // 8*1024
    ) (
    input   wire        pxclk,      // 25MHZ
    input   wire        reset,      // active high

    input   wire        wr_tick,    // in pxclk domain
    input   wire        rd_tick,    // in pxclk domain
    input   wire        mode,       // valid during wr_tick and rd_tick
    input   wire [7:0]  din,        // valid during wr_tick and rd_tick
    output  wire [7:0]  dout,       // valid during wr_tick and rd_tick
    output  wire        irq,

    output  wire [3:0]  color,      // 4-bit color output
    output  wire        hsync,
    output  wire        vsync
    );

    localparam VRAM_ADDR_WIDTH = $clog2(VRAM_SIZE);

    wire [7:0]  regs[0:7];      // the 8 control regs

    // extract register bits into things with useful names
    wire [2:0]  vdp_mode            = { regs[1][4], regs[1][3], regs[0][1] };
    wire        vdp_ie              = regs[1][5];
    wire        vdp_blank           = regs[1][6];
    wire        vdp_smag            = regs[1][0];
    wire        vdp_ssiz            = regs[1][1];
    wire [3:0]  vdp_name_base       = regs[2][3:0];
    wire [7:0]  vdp_color_base      = regs[3];
    wire [2:0]  vdp_pattern_base    = regs[4][2:0];
    wire [6:0]  vdp_sprite_att_base = regs[5][6:0];
    wire [2:0]  vdp_sprite_pat_base = regs[6][2:0];
    wire [3:0]  vdp_fg_color        = regs[7][7:4];
    wire [3:0]  vdp_bg_color        = regs[7][3:0];

    vdp_reg_ifce icfe (
        .clk(pxclk),
        .reset(reset),
        .wr_tick(wr_tick && mode==1),
        .rd_tick(rd_tick && mode==1),
        .din(din),
        .r0(regs[0]),
        .r1(regs[1]),
        .r2(regs[2]),
        .r3(regs[3]),
        .r4(regs[4]),
        .r5(regs[5]),
        .r6(regs[6]),
        .r7(regs[7])
    );

    wire irq_status;
    wire irq_tick = last_pixel;

    vdp_irq virq (
        .clk(pxclk),
        .reset(reset),
        .irq_tick(irq_tick),
        .rd_tick(rd_tick && mode==1),
        .irq(irq_status)
    );

    // XXX the CPU's rd_tick probably has to be buffered to fit into the FSM timing

    wire [VRAM_ADDR_WIDTH-1:0] dma_addr;
    wire dma_rd_tick;

    wire [7:0]  vram_dout;
    vram #( .VRAM_SIZE(VRAM_SIZE) ) mem
    (
        .reset(reset),
        .clk(pxclk),
        .dma_addr(dma_addr),
        .dma_rd_tick(dma_rd_tick),
        .rd_tick(rd_tick),              // shouldn't use the CPU rd_tick, prefer a FSM sync'd signal here
        .wr_tick(wr_tick),
        .mode(mode),
        .din(din),
        .dout(vram_dout)
    );

    wire [9:0] col;
    wire [9:0] row;
    wire vid_active;
    wire vid_active0;
    wire col_last;
    wire row_last;
    wire last_pixel;
    wire bdr_active;
    wire hsync_in;
    wire vsync_in;

    vgasync v (
        .reset(reset),
        .clk(pxclk),
        .text_mode(vdp_mode==3'b100),
        .hsync(hsync_in),
        .vsync(vsync_in),
        .col(col),
        .row(row),
        .vid_active(vid_active),
        .vid_active0(vid_active0),
        .col_last(col_last),
        .row_last(row_last),
        .bdr_active(bdr_active),
        .end_of_frame(last_pixel)
    );

    wire hsync_out;
    wire vsync_out;
    wire vid_active_out;
    wire bdr_active_out;
    wire last_pixel_out;
    wire col_last_out;
    wire row_last_out;
    wire [3:0]  color_out;

    vdp_fsm #( .VRAM_SIZE(VRAM_SIZE) ) fsm 
    (
        .reset(reset),
        .pxclk(pxclk),
        .px_col(col),
        .px_row(row),
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

        .vdp_dma_addr(dma_addr),
        .vdp_dma_rd_tick(dma_rd_tick),
        .vram_dout(vram_dout),

        .hsync(hsync_in),
        .vsync(vsync_in),
        .vid_active(vid_active),
        .vid_active0(vid_active0),
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
        .color_out(color_out)
    );

    reg [3:0] color_reg;
    always @(*) begin

        color_reg = 0;      // by default, color=black

        // vdp_blank is an oxymoronic name...  Thanks for that and your bass-ackwards bit numbering TI!
        if ( vdp_blank ) begin
            (* parallel_case *)
            case ( 1 )
            bdr_active_out: color_reg = vdp_bg_color;
            vid_active_out: color_reg = color_out;
            endcase
        end
    end

    assign color = color_reg;
    assign hsync = hsync_out;
    assign vsync = vsync_out;

    assign irq = vdp_ie ? irq_status : 0;
    wire [7:0]  vdp_status = { irq_status, 7'b0 };

    // XXX fix this so don't send vram_dout from the last fsm DMA access! 
    assign dout = rd_tick ? (mode==0 ? vram_dout : vdp_status ) : 'hx;

endmodule
