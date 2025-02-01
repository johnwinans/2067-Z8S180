
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
    reg irq_tick;
    reg rd_tick;

    vdp_irq uut (
        .clk(clk),
        .reset(reset),
        .irq_tick(irq_tick),
        .rd_tick(rd_tick)
    );

    initial begin
        $dumpfile("vdp_irq_tb.vcd");
        $dumpvars;
    end
    
    always #1 clk = ~clk;

    initial begin
        clk = 0;
        irq_tick = 0;
        rd_tick = 0;
        reset = 1;
        #5;

        reset <= 0;
        #4;

        // read while no IRQ present
        rd_tick <= 1;
        #2;
        rd_tick <= 0;
        #2;

        rd_tick <= 1;
        #6;
        rd_tick <= 0;
        #2;

        // assert the IRQ
        irq_tick <= 1;
        #2;
        irq_tick <= 0;
        // lease it asserted a while...
        #4;

        // assert IRQ again (the reader missed one)
        irq_tick <= 1;
        #2;
        irq_tick <= 0;
        #4;

        // read should see IRQ high & reset it
        rd_tick <= 1;
        #2;
        rd_tick <= 0;
        #2;

        // another read should see no IRQ
        rd_tick <= 1;
        #2;
        rd_tick <= 0;
        #2;

        rd_tick <= 1;
        irq_tick <= 1;
        #2;
        rd_tick <= 0;
        irq_tick <= 0;
        #2;

        rd_tick <= 1;
        #2;
        rd_tick <= 0;
        #2;

        irq_tick <= 1;
        #2;
        rd_tick <= 1;
        irq_tick <= 0;
        #2;
        rd_tick <= 0;
        #2;

        #2;

        rd_tick <= 1;
        irq_tick <= 1;
        #2;
        rd_tick <= 0;
        irq_tick <= 0;
        #2;

        rd_tick <= 1;
        irq_tick <= 1;
        #2;
        rd_tick <= 0;
        irq_tick <= 0;
        #2;

        // what if we read and assert IRQs on every clock cycle?
        rd_tick <= 1;
        irq_tick <= 1;
        #6;
        irq_tick <= 0;
        #2;
        rd_tick <= 0;
        #4;

        // and if go back & forth repeatedly?
        irq_tick <= 1;
        #2;
        irq_tick <= 0;
        rd_tick <= 1;
        #2;
        rd_tick <= 0;
        irq_tick <= 1;
        #2;
        irq_tick <= 0;
        rd_tick <= 1;
        #2;
        rd_tick <= 0;
        #2;
        rd_tick <= 1;
        #2;
        rd_tick <= 0;

        #20;
        $finish;
    end

endmodule
