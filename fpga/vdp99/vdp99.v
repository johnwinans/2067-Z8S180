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

module vdp99 (
    input   wire        pxclk,      // 25MHZ
    input   wire        reset,      // active high

    input   wire        wr0_tick,
    input   wire        wr1_tick,
    input   wire        rd0_tick,
    input   wire        rd1_tick,
    input   wire [7:0]  din,
    output  wire [7:0]  dout,
    output  wire        irq,

    output  wire [3:0]  color,      // 4-bit color output
    output  wire        hsync,
    output  wire        vsync
    );

    wire [7:0]  regs[0:7];      // the 8 control regs

`ifdef NOT_YET
    // extract register bits into things with useful names
    wire [2:0]  vdp_mode            = { regs[0][1], regs[1][3], regs[1][4] };
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
`endif

    vdp_reg_ifce icfe (
        .clk(pxclk),
        .reset(reset),
        .wr_tick(wr1_tick),
        .rd_tick(rd1_tick),
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

    vdp_irq virq (
        .clk(pxclk),
        .reset(reset),
        //.irq_tick(irq_tick),
        .irq_tick(1'b0),           // XXX hack for now
        .rd_tick(rd1_tick),
        .irq(irq)
    );


`ifdef NOT_YET

`else

    wire [9:0] col;
    wire [9:0] row;
    wire vid_active;

    // XXX color-bar test stub
    vgasync v (
        .reset(reset),
        .clk(pxclk),
        .hsync(hsync),
        .vsync(vsync),
        .col(col),
        .row(row),
        .vid_active(vid_active)
    );

    // XXX use every control register so that the compiler can not optimize them away
    assign color = vid_active ? regs[col[6:4]][3:0] : 0;
`endif

endmodule
