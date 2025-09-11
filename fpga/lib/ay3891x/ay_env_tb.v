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
    reg         shape_tick = 0;
    reg [3:0]   shape = 0;
    reg [15:0]  period = 0;

    wire        ay_clk;
    wire [3:0]  out;

    localparam CLK_FREQ         = 16;  //25000000;
    localparam CLK_PERIOD       = (1.0/CLK_FREQ)*1000000000;
    localparam AY_CLK_FREQ      = 8;   // 1789773;
    localparam AY_CLK_PERIOD    = (1.0/AY_CLK_FREQ)*1000000000;

    always #(CLK_PERIOD/2) clk = ~clk;

    prescaler #(
        .IN_FREQ(CLK_FREQ),
        .OUT_FREQ(AY_CLK_FREQ)
    ) the_prescaler (
        .reset(reset),
        .clk(clk),
        .out_tick(ay_clk)
    );

    ay_env env (
        .reset(reset),
        .clk(clk),
        .env_clk_tick(ay_clk),   // %256 tick clock
        .shape_tick(shape_tick),     // true if shape has changed
        .shape(shape),          // cont, attack, alt, hold
        .period(period),
        .out(out)
    );


    integer i;

    initial begin
        $dumpfile( { `__FILE__, "cd" } );
        $dumpvars;

        #(CLK_PERIOD*4);
        reset <= 1;
        #(CLK_PERIOD*4);
        reset <= 0;
        #(CLK_PERIOD*4);

        write_env( 4'b0000, 10 );
        #(CLK_PERIOD*800);

        write_env( 4'b0100, 10 );
        #(CLK_PERIOD*800);

        for (i=4'b1000; i <= 4'b1111; i=i+1) begin
            write_env( i, 7 );
            #(CLK_PERIOD*1000);
        end

        $finish;
    end

    task write_env(input [3:0] s, input [15:0] p);
    begin
/*
        @(posedge clk);
        reset <= 1;
        @(posedge clk);
        reset <= 0;
        #(CLK_PERIOD*10);    // a visual gap
*/

        @(posedge clk);
        period <= p;
        shape <= s;
        shape_tick <= 1;
        @(posedge clk);
        shape_tick <= 0;
    end
    endtask

endmodule
