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

    reg     reset   = 0;
    reg     clk     = 0;
    wire    ay_clk;

    localparam CLK_FREQ         = 25000000;
    localparam AY_CLK_FREQ      = 1789773;
    localparam CLK_PERIOD       = (1.0/CLK_FREQ)*1000000000;

    always #(CLK_PERIOD/2) clk = ~clk;

    prescaler #(
        .IN_FREQ(CLK_FREQ),
        .OUT_FREQ(AY_CLK_FREQ)
    ) uut (
        .reset(reset),
        .clk(clk),
        .out_tick(ay_clk)
    );

    initial begin
        $dumpfile( { `__FILE__, "cd" } );
        $dumpvars;

        #(CLK_PERIOD*4);
        reset <= 1;
        #(CLK_PERIOD*4);
        reset <= 0;
        #(CLK_PERIOD*4);

        //#(CLK_FREQ*2);
        #100000;

        $finish;
    end

endmodule
