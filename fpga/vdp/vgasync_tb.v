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

`timescale 100ns/1ps

module tb();

    reg clk;        // pixel clock
    reg reset;

    vgasync
    #(
        // artifically small screen to make easy to see waveforms
        .HVID(5),
        .HRB(2),
        .HFP(2),
        .HS(3),
        .HBP(4),
        .HLB(2),
        .VVID(3),
        .VBB(2),
        .VFP(4),
        .VS(2),
        .VBP(3),
        .VTB(2)
    ) uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $dumpfile("vgasync_tb.vcd");
        $dumpvars;
        clk = 0;
    end
    
    always #1 clk = ~clk;

    initial begin
        reset = 1;
        #4;
        reset = 0;
        #100000;
        $finish;
    end

endmodule
