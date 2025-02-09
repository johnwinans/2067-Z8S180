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

// at this point, this exists only to compile vdp99 with iverilog
module tb();

    reg clk;        // pixel clock
    reg reset;
    reg wr_tick;
    reg rd_tick;
    reg mode;
    reg [7:0] din;

    wire [7:0] dout;
    wire [3:0] color;
    wire hsync;
    wire vsync;
    wire irq;

    vdp99 uut (
        .pxclk(clk),
        .reset(reset),
        .wr_tick(wr_tick),
        .rd_tick(rd_tick),
        .mode(mode),
        .din(din),
        .irq(irq),
        .dout(dout),
        .color(color),
        .hsync(hsync),
        .vsync(vsync)
    );

    initial begin
        $dumpfile("vdp99_tb.vcd");
        $dumpvars;
    end
    
    always #1 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        wr_tick = 0;
        rd_tick = 0;
        mode = 0;
        din = 0;
        #5;

        reset <= 0;
        #4;

        #20;
        $finish;
    end

endmodule
