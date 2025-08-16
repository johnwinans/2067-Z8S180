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

/**
* Implement one TI99-style sprite.
*
* pattern will have 16 bits loaded.  When rendering 8 bits, the LSB will be zero.
* When early is 1 the hpos value starts from 32px to the left of the acvive region.
* 1 VDP pixel = 2 pxclk periods.
* Note that mag can double the size to 32x32 max.
***************************************************************************/
module tb ();
 
    reg         reset = 0;
    reg         pxclk = 0;
    reg         col_last_tick = 0;
    reg         mag = 0;
    reg         early = 0;
    reg [8:0]   hpos = 0;
    reg [15:0]  pattern = 0;
    reg [3:0]   fg_color = 0;
    reg         load_tick = 0;

    sprite uut
    (
        .reset(reset),
        .pxclk(pxclk),
        .col_last_tick(col_last_tick),
        .mag(mag),
        .early(early),
        .hpos(hpos),
        .pattern(pattern),
        .fg_color(fg_color),
        .load_tick(load_tick)
    );

    initial begin
        $dumpfile("sprite_tb.vcd");
        $dumpvars;
    end

    localparam clk_period = (1.0/25000000)*1000000000; // clk is running at 25MHZ
    always #(clk_period/2) pxclk = ~pxclk;

`define ASSERT(cond) if ( !(cond) ) $display("%s:%0d %m time:%3t ASSERTION (cond) FAILED!", `__FILE__, `__LINE__, $time );

    initial begin
        #(clk_period*4);
        reset <= 1;
        #(clk_period*4);
        @(posedge pxclk);
        reset <= 0;

        #(clk_period*4);

        @(posedge pxclk);
        mag <= 0;
        early <= 0;
        hpos <= 1;
        pattern <= 16'b1011001010101001;
        fg_color <= 9;

        @(posedge pxclk);
        load_tick <= 1;

        @(posedge pxclk);
        load_tick <= 0;


        @(posedge pxclk);
        @(posedge pxclk);
        @(posedge pxclk);
        @(posedge pxclk);

        // trigger the FSM to start counting and shifting out the sprite pattern
        col_last_tick <= 1;

        @(posedge pxclk);
        col_last_tick <= 0;

        @(posedge pxclk);

        #(clk_period*500);
        $finish;
    end

endmodule
