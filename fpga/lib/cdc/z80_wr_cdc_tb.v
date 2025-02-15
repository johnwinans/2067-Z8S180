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

    // The Z8S180 interface signals of interest.
    // Initialize here before any initial or always blocks start.
    reg reset       = 0;
    reg iorq        = 0;
    reg wr          = 0;
    reg [7:0] din1  = 'hz;
    reg [7:0] ain1  = 'hz;

    reg phi         = 0;    // the PHI clock 18.432MHZ
    reg pxclk       = 0;    // the pixel clock 25MHZ

    reg t1_marker   = 0;    // used to make obvious which are T1 phi clocks



    wire wr_tick1;
    wire wr_tick2;
    wire [7:0] dout2;
    wire [7:0] aout2;

    // generate a write tick in the PHI domain
    iorq_wr_fsm wr_fsm (
        .reset(reset), 
        .phi(phi), 
        .iorq(iorq), 
        .wr(wr), 
        .wr_tick(wr_tick1) 
    );

    // generate a write tick in the VDP domain
    z80_wr_cdc wr_cdc (
        .reset(reset),
        .clk1(phi),
        .clk2(pxclk),
        .wr_tick1(wr_tick1),
        .din1(din1),
        .ain1(ain1),
        .wr_tick2(wr_tick2),
        .dout2(dout2),
        .aout2(aout2)
    );

    localparam phi_period   = (1.0/18432000)*1000000000;    // phi is running at about 18.432MHZ
    localparam pxclk_period = (1.0/25000000)*1000000000;    // pxclk is running at 25MHZ

    // generate free-running clocks
    always #(phi_period/2) phi <= ~phi;
    always #(pxclk_period/2) pxclk <= ~pxclk;

    initial begin
        $dumpfile("z80_wr_cdc_tb.vcd");
        $dumpvars;

        reset <= 1;
        #(phi_period*4);        // XXX probably not the best way to do this!      XXX
        reset <= 0;
        #(phi_period*2);


        // A realistic moderately timed 4-T Z8S180 IO write transaction

        // This allows us to wait until the next phi rising edge (simulation only)
        @(posedge phi);         // T1 rising
        t1_marker <= 1;
        t1_marker <= #(phi_period) 0;

        ain1 <= #12 8'h81;      // address valid after T1 rising and >5ns before IORQ

        @(negedge phi);         // T1 falling
        din1 <= #5 8'h23;       // data <25ns after T1 falling and >10ns before WR active
        iorq <= #15 1;          // iorq = <25ns after T1 falling 
                                // rd = <25ns after T1 falling 
        @(posedge phi);         // T2 rising
        wr <= #12 1;            // <25ns after T2 rising

        @(posedge phi);         // Tw rising
        @(posedge phi);         // T3 rising
        @(negedge phi);         // T3 falling

        iorq <= #11 0;          // iorq <25ns after T3 falling
        wr <= #12 0;            // wr <25ns after T3 falling
                                // rd <25ns after T3 falling

        @(negedge wr)           // be careful that wr does not happen after posedge phi here!!!
        ain1 <= #6 'hz;         // >5ns after iorq & wr trailing
        din1 <= #12 'hz;        // >10ns after wr trailing

        @(posedge phi);         // wait for T1 rising of next bus cycle (opcode fetch)
        t1_marker <= 1;
        t1_marker <= #(phi_period) 0;
        @(posedge phi);         // T2 opcode fetch
        @(posedge phi);         // T3 opcode fetch

        // skip the operand fetch as if this were an OUT (nn),A instruction
        @(posedge phi);         // wait for T1 rising of next bus cycle (operand fetch)
        t1_marker <= 1;
        t1_marker <= #(phi_period) 0;
        @(posedge phi);         // T2 operand fetch
        @(posedge phi);         // T3 operand fetch




        // A worst case timed 4-T Z8S180 IO write transaction

        @(posedge phi);         // T1 IO cycle starts
        t1_marker <= 1;
        t1_marker <= #(phi_period) 0;

        @(negedge phi);         // T1 falling

        ain1 <= #20 8'h81;      // address valid >5ns before IORQ
        din1 <= #25 8'h23;      // data <25ns after T1 falling and >10ns before WR active

        // rd = <25ns after T1 falling 
        iorq <= #25 1;          // iorq = <25ns after T1 falling

        @(posedge phi);         // T2 rising
        wr <= #25 1;            // wr <25ns after T2 raising

        @(posedge phi);         // Tw rising
        @(posedge phi);         // T3 rising
        @(negedge phi);         // T3 falling

        iorq <= #1 0;           // iorq <25ns after T3 falling
        wr <= #1 0;             // wr <25ns after T3 falling
                                // rd <25ns after T3 falling

        @(negedge wr)           // be careful that wr does not happen after posedge phi here!!!
        ain1 <= #6 'hz;         // >5ns after iorq & wr trailing
        din1 <= #12 'hz;        // >10ns after wr trailing




        // skip the next opcode fetch bus cycle
        @(posedge phi);         // wait for T1 rising of next bus cycle
        t1_marker <= 1;
        t1_marker <= #(phi_period) 0;
        @(posedge phi);         // T2 opcode fetch
        @(posedge phi);         // T3 opcode fetch


/*
        // Lets understand WHEN the RHS is evaluated  
        @(posedge phi);         // the next T1 rising edge
        t1_marker <= 1;
        //t1_marker <= #(phi_period*0.75) 0;
        t1_marker <= #(phi_period*0.75) phi;     // what gets assigned here???   XXX
*/

        // waste some time and end it
        #(phi_period*3);
        $finish;
    end
 
endmodule
