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

module ay_regs (
    input wire          reset,
    input wire          clk,
    input wire          a0,             // 0=addr latch, 1=data transfer 
    input wire          wr_tick,        // a write tick in the clk domain
    input wire [7:0]    wdata,          // data must be stable during wr_tick
    input wire          rd_tick,        // a write tick in the clk2 domain when dout is valid
    output wire [7:0]   rdata,          // data will be valid during the period following rd_tick

    output  wire [7:0]  r0,
    output  wire [7:0]  r1,
    output  wire [7:0]  r2,
    output  wire [7:0]  r3,
    output  wire [7:0]  r4,
    output  wire [7:0]  r5,
    output  wire [7:0]  r6,
    output  wire [7:0]  r7,
    output  wire [7:0]  r8,
    output  wire [7:0]  r9,
    output  wire [7:0]  r10,
    output  wire [7:0]  r11,
    output  wire [7:0]  r12,
    output  wire [7:0]  r13
    );

    // register interface
    reg [4:0]   addr_reg, addr_next;            // extra bit for the IO ports
    reg [7:0]   rdata_reg;
    reg [7:0]   regs[0:15];                     // implement 16, but we use 14

    integer i;

    always @(posedge clk) begin
        if (reset) begin
            addr_reg <= 0;
            for ( i=0; i<16; i = i+1 )
                regs[i] <= 0;
            regs[7] <= 8'hff;                   // disable all outputs
        end else begin
            addr_reg <= addr_next;
        end
    end

    // register read-write logic
    always @(posedge clk) begin
        rdata_reg <= regs[addr_reg];
        if ( wr_tick & a0 )
            regs[addr_reg] <= wdata;
    end

    always @(*) begin
        addr_next = (~a0 && wr_tick) ? wdata[4:0] : addr_reg;
    end

    assign rdata = rdata_reg;

    assign r0 = regs[0];
    assign r1 = regs[1];
    assign r2 = regs[2];
    assign r3 = regs[3];
    assign r4 = regs[4];
    assign r5 = regs[5];
    assign r6 = regs[6];
    assign r7 = regs[7];
    assign r8 = regs[8];
    assign r9 = regs[9];
    assign r10 = regs[10];
    assign r11 = regs[11];
    assign r12 = regs[12];
    assign r13 = regs[13];

endmodule
