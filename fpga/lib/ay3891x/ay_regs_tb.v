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

module tb ();

    reg         reset   = 0;
    reg         clk     = 0;
    reg         a0      = 0;
    reg         wr_tick = 0;
    reg [7:0]   wdata   = 0;
    reg         rd_tick = 0;
    wire [7:0]  rdata;
    wire [7:0]  r0;
    wire [7:0]  r1;
    wire [7:0]  r2;
    wire [7:0]  r3;
    wire [7:0]  r4;
    wire [7:0]  r5;
    wire [7:0]  r6;
    wire [7:0]  r7;
    wire [7:0]  r8;
    wire [7:0]  r9;
    wire [7:0]  r10;
    wire [7:0]  r11;
    wire [7:0]  r12;
    wire [7:0]  r13;

    localparam CLK_FREQ         = 25000000;
    localparam CLK_PERIOD       = (1.0/CLK_FREQ)*1000000000;

    always #(CLK_PERIOD/2) clk = ~clk;

    ay_regs uut (
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

    initial begin
        $dumpfile( { `__FILE__, "cd" } );
        $dumpvars;

        #(CLK_PERIOD*4);
        reset = 1;
        #(CLK_PERIOD*4);
        reset = 0;
        #(CLK_PERIOD*4);

        @(posedge clk);
        write_register( 0, 8'h21 );     // A
        write_register( 1, 8'h0f );
        write_register( 8, 8'h0f );     // max amp, no envelope
        write_register( 7, 8'h07 );     // enable all tones

        #1000;

        @(posedge clk);
        write_register( 2, 8'h22 );     // B
        write_register( 3, 8'h02 );
        write_register( 9, 8'h0f );     // max amp, no envelope

        #1000;

        @(posedge clk);
        write_register( 4, 8'h33 );     // C
        write_register( 5, 8'h03 );
        write_register( 10, 8'h0f );     // max amp, no envelope

        #1000;
        @(posedge clk);
        write_register( 6, 8'h10 );     // noise period
        write_register( 11, 8'he1 );    // envelope LSB
        write_register( 12, 8'he2 );    // envelope MSB
        write_register( 13, 8'h02 );    // envelope shape/cycle

        #1000;

        $finish;
    end


    task write_register(input [3:0] reg_addr, input [7:0] reg_data);
    begin
        a0 <= 1'b0;
        wdata <= reg_addr;
        wr_tick <= 1'b1;
        @(posedge clk);
        wdata <= reg_data;
        wr_tick <= 1;
        a0 <= 1'b1;
        @(posedge clk);
        wr_tick <= 0;
        wdata <= 'hx;
    end
    endtask


endmodule
