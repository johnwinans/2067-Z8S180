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

// Process a 2-write data transfer from the CPU to the config regs.
// Process a read of the VDP status reg.
// Note that reading the status reg will reset the write transfer state!
module reg_ifce(
    input   wire        clk,
    input   wire        reset,      // active high

    input   wire        wm0_tick,   // mode0 write
    input   wire        rm0_tick,   // mode0 read
    input   wire [7:0]  din,        // stable during wm0_tick
    output  wire [7:0]  dout,       // make stable during rm0_tick
    output  wire [7:0]  r0,
    output  wire [7:0]  r1,
    output  wire [7:0]  r2,
    output  wire [7:0]  r3,
    output  wire [7:0]  r4,
    output  wire [7:0]  r5,
    output  wire [7:0]  r6,
    output  wire [7:0]  r7
    );

    reg [7:0]   vdp_regs[0:7];
    reg [7:0]   vdp_regs_next;
    reg         update_vdp_reg_tick;    // true if save din into vdp_regs[w0_reg[2:0]]

    reg [7:0]   w0_reg, w0_next;
    reg [7:0]   w1_reg, w1_next;

    reg         state_reg, state_next;  // 0 = write to w0_reg next, else w1_reg

	always @(posedge clk) begin
        if ( reset ) begin
            w0_reg <= 0;
            w1_reg <= 0;
            state_reg <= 0;
        end else begin
            w0_reg <= w0_next;
            w1_reg <= w1_next;
            state_reg <= state_next;
        end

        if ( update_vdp_reg_tick )
            vdp_regs[din[2:0]] <= w0_reg;
	end

    // When w0_tick, update the w0/1 registers & toggle the next reg state
    always @(*) begin
        w0_next = wm0_tick && state_reg==0 ? din : w0_reg;
        w1_next = wm0_tick && state_reg==1 ? din : w1_reg;
        state_next = wm0_tick ? ~state_reg : state_reg;     // toggle when written

        // special reset the w0/1 reg state when read the status register
        if ( rm0_tick )
            state_next = 0;

        update_vdp_reg_tick = wm0_tick & state_reg & din[7];
    end

    assign r0 = vdp_regs[0];
    assign r1 = vdp_regs[1];
    assign r2 = vdp_regs[2];
    assign r3 = vdp_regs[3];
    assign r4 = vdp_regs[4];
    assign r5 = vdp_regs[5];
    assign r6 = vdp_regs[6];
    assign r7 = vdp_regs[7];

endmodule
