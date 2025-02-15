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
// Note that the rd_tick is used to reset the write transfer state.
module vdp_reg_ifce(
    input   wire        clk,
    input   wire        reset,      // active high

    input   wire        wr_tick,    // mode1 write
    input   wire        rd_tick,    // mode1 read
    input   wire [7:0]  din,        // stable during wr_tick
    output  wire [7:0]  r0,
    output  wire [7:0]  r1,
    output  wire [7:0]  r2,
    output  wire [7:0]  r3,
    output  wire [7:0]  r4,
    output  wire [7:0]  r5,
    output  wire [7:0]  r6,
    output  wire [7:0]  r7
    );

    reg [7:0]   vdp_regs[0:7];          // an array makes register addressing easier
    reg         update_vdp_reg_tick;    // true if save w0_reg into vdp_regs[din[2:0]]

    reg [7:0]   w0_reg, w0_next;
    reg         state_reg, state_next;  // 0 = write to w0_reg next, else write to reg

    always @(posedge clk) begin
        if ( reset ) begin
            w0_reg <= 0;
            state_reg <= 0;
        end else begin
            w0_reg <= w0_next;
            state_reg <= state_next;
        end

        if ( update_vdp_reg_tick )
            vdp_regs[din[2:0]] <= w0_reg;
    end

    // Note that we discard write operations that don't match the VDP reg sig in din[7:6]
    always @(*) begin
        w0_next = wr_tick && state_reg==0 ? din : w0_reg;
        state_next = wr_tick ? ~state_reg : state_reg;     // toggle state on each write

        // special reset the w0/1 reg state when read the status register
        if ( rd_tick )
            state_next = 0;

        update_vdp_reg_tick = wr_tick & state_reg & din[7:6]==2'b10;
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
