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

`timescale 10ns/1ns

module tb();

    reg clk;        // pixel clock
    reg reset;
    reg wm0_tick;
    reg rm0_tick;
    reg [7:0] din;

    reg_ifce uut (
        .clk(clk),
        .reset(reset),
        .wm0_tick(wm0_tick),
        .rm0_tick(rm0_tick),
        .din(din)
    );

    initial begin
        $dumpfile("reg_ifce_tb.vcd");
        $dumpvars;
    end
    
    always #1 clk = ~clk;

    initial begin
        clk = 0;
        wm0_tick = 0;
        rm0_tick = 0;
        din = 'hz;
        reset = 1;
        #5;

        reset <= 0;
        #4;

        //#0.3;           // exaggerate the tick changes after the rising edges

        // reg0 = 0xee
        din <= 'hee;
        wm0_tick <= 1;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #2;
        din <= 'h80;     // write into reg 0
        wm0_tick <= 1;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #2;

        // reg3 = 0x33
        din <= 'h33;
        wm0_tick <= 1;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #2;
        din <= 'h83;     // write into reg 3
        wm0_tick <= 1;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #2;

        // rapid-fire writes
        din <= 'h44;
        wm0_tick <= 1;
        #2;
        din <= 'h84;
        #2;
        din <= 'h55;
        #2;
        din <= 'h85;
        #2;
        din <= 'h66;
        #2;
        din <= 'h86;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #4;

        // test rm0 reset the 2-state write register toggler
        din <= 'h22;
        wm0_tick <= 1;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #2;

        rm0_tick <= 1;
        #2;
        rm0_tick <= 0;
        din <= 'hz;
        #2;

        // make sure it still works (we didn't get it stuck)
        din <= 'h11;
        wm0_tick <= 1;
        #2;
        din <= 'h81;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #2;

        // make sure we can CHANGE a value that has already been written
        din <= 'hf6;
        wm0_tick <= 1;
        #2;
        din <= 'h86;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #2;

        // make sure that rm0 is OK when not done in state 1
        rm0_tick <= 1;
        #2;
        rm0_tick <= 0;
        din <= 'hz;
        #2;

        // a long wait between successive wm0 writes
        din <= 'h77;
        wm0_tick <= 1;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #6;
        wm0_tick <= 1;
        din <= 'h87;
        #2;
        wm0_tick <= 0;
        din <= 'hz;
        #2;


        #20;
        $finish;
    end

endmodule
