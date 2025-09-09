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

    wire [2:0]  aout;

    localparam CLK_FREQ         = 25000000;
    localparam CLK_PERIOD       = (1.0/CLK_FREQ)*1000000000;

    always #(CLK_PERIOD/2) clk = ~clk;

    ay3891x uut (
        .reset(reset),
        .clk(clk),
        .a0(a0),
        .wr_tick(wr_tick),
        .wdata(wdata),
        .rd_tick(rd_tick),
        .rdata(rdata),
        .aout(aout)
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
        write_register( 0, 8'h11 );     // A
        write_register( 1, 8'h00 );
        write_register( 8, 8'h0e );     // amp, no envelope
        //write_register( 7, 8'hf0 );     // enable all tones & noise on A
        write_register( 7, 8'hf8 );     // enable all tones & no noise

        #10000;

        @(posedge clk);
        write_register( 2, 8'h22 );     // B
        write_register( 3, 8'h00 );
        write_register( 9, 8'h0d );     // amp, no envelope

        #10000;

        @(posedge clk);
        write_register( 4, 8'h33 );     // C
        write_register( 5, 8'h00 );
        write_register( 10, 8'h0c );     // amp, no envelope

        #10000;
        @(posedge clk);
        write_register( 6, 8'h03 );     // noise period
        write_register( 11, 8'he1 );    // envelope LSB
        write_register( 12, 8'he2 );    // envelope MSB
        write_register( 13, 8'h02 );    // envelope shape/cycle

        //#100000000;
        #(25000000*4);

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
