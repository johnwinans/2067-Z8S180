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

// A quick hack at making a basic sound generator.
// This implements an AY-3-891x style register interface.
// Only the tone and noise generators are implemented. 

module ay3891x #(
    parameter CLK_FREQ = 25000000       // freq of clk
    ) (
    input wire          reset,
    input wire          clk,
    input wire          a0,             // 0=addr latch, 1=data transfer 
    input wire          wr_tick,        // a write tick in the clk domain
    input wire [7:0]    wdata,          // data must be stable during wr_tick
    input wire          rd_tick,        // a write tick in the clk2 domain when dout is valid
    output wire [7:0]   rdata,          // data will be valid during the period following rd_tick
    output wire [2:0]   aout            // analog(ish) out channels
    );

    localparam AY_CLK_FREQ = 1789773;

    wire        ay_clk;                 // 1.789773 MHZ clock
    wire [7:0]  r0;                     // fine tune A
    wire [7:0]  r1;                     // course tune A
    wire [7:0]  r2;                     // fine B
    wire [7:0]  r3;                     // course B
    wire [7:0]  r4;                     // fine C
    wire [7:0]  r5;                     // course C
    wire [7:0]  r6;                     // noise period
    wire [7:0]  r7;                     // enablage
    wire [7:0]  r8;                     // A amplitude
    wire [7:0]  r9;                     // B amplitude
    wire [7:0]  r10;                    // C amplitude
    wire [7:0]  r11;                    // Envelope fine
    wire [7:0]  r12;                    // Envelope course
    wire [7:0]  r13;                    // Envelope shape

    wire        noise_out;              // noise bit stream

    prescaler #(
        .IN_FREQ(CLK_FREQ),
        .OUT_FREQ(AY_CLK_FREQ)
    ) ay_prescaler (
        .reset(reset),
        .clk(clk),
        .out(ay_clk)
    );

    ay_regs regs (
        .reset(reset),
        .clk(clk),
        .a0(a0),
        .wr_tick(wr_tick),
        .wdata(wdata),
        .rd_tick(rd_tick),
        .rdata(rdata),
        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .r4(r4),
        .r5(r5),
        .r6(r6),
        .r7(r7),
        .r8(r8),
        .r9(r9),
        .r10(r10),
        .r11(r11),
        .r12(r12),
        .r13(r13)
    );

    ay_noise noise (
        .reset(reset),
        .clk(clk),
        .ay_clk(ay_clk),
        .period(r6[4:0]),
        .out(noise_out)
    );

    // XXX tone generators
    // XXX envelope generator
    // XXX mux / summing circuit


endmodule
