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
    reg [3:0]   amp     = 0;
    reg         in      = 0;
    wire        out;

    localparam CLK_FREQ         = 25000000;
    localparam CLK_PERIOD       = (1.0/CLK_FREQ)*1000000000;

    always #(CLK_PERIOD/2) clk = ~clk;

    ay_adc adc (
        .reset(reset),
        .clk(clk),
        .amp(amp),
        .in(in),
        .out(out)
    );

    initial begin
        $dumpfile( { `__FILE__, "cd" } );
        $dumpvars;

        #(CLK_PERIOD*4);
        reset <= 1;
        #(CLK_PERIOD*4);
        reset <= 0;
        #(CLK_PERIOD*4);

        amp <= 14;
        in <= 1;
        @(posedge out);

        amp <= 13;
        @(posedge out);

        @(posedge out);
        @(negedge out);

        @(posedge out);
        #100;
        in <= 0;
        #100;
        in <= 1;
        
        @(negedge out);


        #100;
        $finish;
    end

endmodule
