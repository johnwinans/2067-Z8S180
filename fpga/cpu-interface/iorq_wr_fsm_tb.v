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

`timescale 1ns/1ps  // time units & precision 

module tb ();

    reg     phi = 1;
    reg     reset;
    reg     iorq = 0;           // positive logic
    reg     wr = 0;             // positive logic
    wire    wr_tick;            // positive logic

    iorq_wr_fsm uut (.phi(phi), .iorq(iorq), .wr(wr), .wr_tick(wr_tick), .reset(reset) );

    always #25 phi = ~phi;

    reg t1 = 0;     // use for refernce when viewing waveform

    initial begin
        $dumpfile("iorq_wr_fsm_tb.vcd");
        $dumpvars;
        
        reset = 1;
        #50;
        reset = 0;

        #(6*25);         // skip a machine cycle

        // An external t1-t2-tw-t3 IO WR cycle
        // IOC=1 (default)
       
        // earliest case IORQ edge is 1ns after t1 falling
        t1=1;
        #25;
        #1;
        iorq = 1;
        #24;
        t1=0;

        #25;
        #1;
        wr = 1;     // earliest case is 1ns after t2 raising
        #24;

        #50;        // tw
        #50;        // t3
        iorq = 0;   // latest case is iorq=false on t1 rising
        wr = 0;

        t1=1;       // skip to make waveform easier to see
        #(2*25);
        t1=0;
        #(4*25);


        t1=1;
        #25;
        #25;
        iorq = 1;
        t1=0;

        #25;        // t2
        #1;
        wr = 1;     // latest case is with t2 falling (miss the edge)
        #24;

        #50;        // tw
        #25;        // t3
        #1;
        iorq = 0;   // earliest caseiorq=false 1ns after t3 falling 
        wr = 0;
        #24;


        t1=1;       // skip to make waveform easier to see
        #(2*25);
        t1=0;
        #(4*25);



        t1=1;
        #25;
        #25;
        iorq = 1;
        t1=0;

        #15;        // t2
        wr = 1;     // medium case is before t2 falling
        #10;
        #25;

        #50;        // tw
        #50;        // tw (extra)
        #50;        // tw (extra)

        #25;        // t3
        #15;
        iorq = 0;   // meduim case iorq=false 15ns after t3 falling 
        wr = 0;     // meduim case wr=false 15ns after t3 falling
        #10;


        t1=1;       // skip to make waveform easier to see
        #(2*25);
        t1=0;
        #(4*25);


        $finish;
    end

endmodule
