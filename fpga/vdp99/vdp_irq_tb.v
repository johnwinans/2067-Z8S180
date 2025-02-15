
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

module tb();

    reg clk         = 0;        // pixel clock
    reg reset       = 0;
    reg irq_tick    = 0;
    reg rd_tick     = 0;

    wire irq;

    vdp_irq uut (
        .clk(clk),
        .reset(reset),
        .irq_tick(irq_tick),
        .rd_tick(rd_tick),
        .irq(irq)
    );

    initial begin
        $dumpfile("vdp_irq_tb.vcd");
        $dumpvars;
    end
    
    localparam CLK_PERIOD = 100;

    always #(CLK_PERIOD/2) clk = ~clk;

`define ASSERT(cond) $display("%s:%0d %m time:%6t %0s", `__FILE__, `__LINE__, $time, (cond) ? "passed" : "ASSERTION (cond) FAILED!" );

    initial begin

        #3;
        @(posedge clk);
        reset <= 1;
        @(posedge clk);         // keep it asserted for a few clock cycles
        @(posedge clk);
        @(posedge clk);
        reset <= 0;


        // read while no IRQ present
        @(posedge clk);
        rd_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;

        // rapid-fire (continuous) reading (impossibly fast, but legal)
        @(posedge clk);
        rd_tick <= 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rd_tick <= 0;


        // assert the IRQ
        @(posedge clk);
        irq_tick <= 1;
        @(posedge clk);
        irq_tick <= 0;

        // wait a while to see that IRQ stays asserted
        @(posedge clk);
        @(posedge clk);

        // assert IRQ again (as if the last was not consumed)
        @(posedge clk);
        irq_tick <= 1;
        @(posedge clk);
        irq_tick <= 0;
        @(posedge clk);

        // read should see IRQ high and the reset the IRQ
        @(posedge clk);
        rd_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;

        // another read should see no IRQ
        @(posedge clk);
        rd_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;

        // read and irq tick happen at same time 
        // should read no IRQ and then IRQ go active in following clk period
        @(posedge clk);
        `ASSERT( irq == 0 );
        rd_tick <= 1;
        irq_tick <= 1;
        @(posedge clk);
        `ASSERT( irq == 0 );        // checking irq value after the nonblocking assignment has completed
        rd_tick <= 0;
        irq_tick <= 0;
        @(negedge clk);
        `ASSERT( irq == 1 );        // at this point, the irq will have been asserted

        // read/consume the irq
        @(posedge clk);
        `ASSERT( irq == 1 );
        rd_tick <= 1;
        @(posedge clk);
        `ASSERT( irq == 1 );
        rd_tick <= 0;
        @(negedge clk);
        `ASSERT( irq == 0 );        // at this point, the irq will have been consumed/cleared

        // generate an irq that goes active at same time as it is read 
        @(posedge clk);
        `ASSERT( irq == 0 );
        irq_tick <= 1;
        @(posedge clk);
        rd_tick <= 1;
        irq_tick <= 0;
        `ASSERT( irq == 0 );
        #1;     // sloppy, but will put us at the end of the queue after the current non-blocking assignments complete
        `ASSERT( irq == 1 );
        @(posedge clk);
        rd_tick <= 0;
        `ASSERT( irq == 1 );
        #1;
        `ASSERT( irq == 0 );

        @(posedge clk);
        @(posedge clk);

        rd_tick <= 1;
        irq_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;
        irq_tick <= 0;

        @(posedge clk);
        rd_tick <= 1;
        irq_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;
        irq_tick <= 0;

        // what if we read and assert IRQs on every clock cycle?
        @(posedge clk);
        rd_tick <= 1;
        irq_tick <= 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        irq_tick <= 0;
        @(posedge clk);
        rd_tick <= 0;

        @(posedge clk);

        // and if go back & forth repeatedly?
        @(posedge clk);
        irq_tick <= 1;
        @(posedge clk);
        irq_tick <= 0;
        rd_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;
        irq_tick <= 1;
        @(posedge clk);
        irq_tick <= 0;
        rd_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;
        @(posedge clk);
        rd_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;

        @(posedge clk);
        #(CLK_PERIOD*5);
        $finish;
    end

endmodule
