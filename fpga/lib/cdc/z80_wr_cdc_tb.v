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

`timescale 1ns/10ps
`default_nettype none

module tb ();

    // the Z8S180 interface signals of interest
    reg reset;
    reg iorq;
    reg wr;
    reg [7:0] din1;
    reg [7:0] ain1;

    reg clk1;           // the PHI clock 18.432MHZ
    reg clk2;           // the pixel clock 25MHZ

    wire wr_tick1;
    wire wr_tick2;
    wire [7:0] dout2;
    wire [7:0] aout2;

    // generate a write tick in the PHI domain
    iorq_wr_fsm wr_fsm (
        .reset(reset), 
        .phi(clk1), 
        .iorq(iorq), 
        .wr(wr), 
        .wr_tick(wr_tick1) 
    );

    // generate a write tick in the VDP domain
    z80_wr_cdc wr_cdc (
        .reset(reset),
        .clk1(clk1),
        .clk2(clk2),
        .wr_tick1(wr_tick1),
        .din1(din1),
        .ain1(ain1),
        .wr_tick2(wr_tick2),
        .dout2(dout2),
        .aout2(aout2)
    );

    localparam clk1_period = (1.0/18432000)*1000000000; // clk1 is running at about 18.432MHZ
    localparam clk2_period = (1.0/25000000)*1000000000; // clk2 is running at 25MHZ

    always #(clk1_period) clk1 = ~clk1;
    always #(clk2_period) clk2 = ~clk2;

    initial begin
        $dumpfile("z80_wr_cdc_tb.vcd");
        $dumpvars;

        reset = 1;
        clk1 = 0;
        clk2 = 0;
        iorq = 0;
        wr = 0;
        din1 = 'hz;
        ain1 = 'hz;

        #(clk1_period*2);
        reset <= 0;
        #(clk1_period*2);;

        // This allows us to wait until the next clk1 rising edge (simulation only)
        @(posedge clk1);        // this as T1 of an IORQ write cycle

        // A realistic 4-T Z8S180 IO write transaction
        #5;
        ain1 <= 8'h81;          // address valid by 5ns after T1 rising edge

        @(negedge clk1);
        #15;                    // data valid max 25ns after T1 falling and 10ns before T2 rising
        din1 <= 8'h23;          // some data value to write to the IO port

        // iorq = 25ns after T1 falling worst case
        // rd = 25ns after T1 falling worst case
        #5; // meh
        iorq <= 1;

        @(posedge clk1);        // wait for T2 rising edge
        #22;                    // 25ns worst case
        wr <= 1;

        @(posedge clk1);        // Wait for Tw rising
        @(posedge clk1);        // Wait for T3 rising
        @(negedge clk1);        // Wait for T3 falling
        #20;                    // 25ns worst case
        wr <= 0;
        iorq <= 0;
        
        @(posedge clk1);        // wait for T1 rising of next bus cycle
        din1 = 'hz;
        ain1 = 'hz;

        
        // skip the opcode fetch bus cycle
        @(posedge clk1);        // T2
        @(posedge clk1);        // T3

        // skip the operand fetch as if this were an OUT (nn),A instruction
        @(posedge clk1);        // T1
        @(posedge clk1);        // T2
        @(posedge clk1);        // T3

        // The IORQ WR cycle
        #5;
        ain1 <= 8'h81;          // address valid by 5ns after T1 rising edge

        @(negedge clk1);
        #15;                    // data valid max 25ns after T1 falling and 10ns before T2 rising
        din1 <= 8'h82;          // write to VDP register 2

        // iorq = 25ns after T1 falling worst case
        // rd = 25ns after T1 falling worst case
        #5; // meh
        iorq <= 1;

        @(posedge clk1);        // wait for T2 rising edge
        #22;                    // 25ns worst case
        wr <= 1;

        @(posedge clk1);        // Wait for Tw rising
        @(posedge clk1);        // Wait for T3 rising
        @(negedge clk1);        // Wait for T3 falling
        #20;                    // 25ns worst case
        wr <= 0;
        iorq <= 0;
        
        @(posedge clk1);        // wait for T1 rising of next bus cycle
        din1 = 'hz;
        ain1 = 'hz;


        #(clk1_period*10);;
        $finish;
    end
 
endmodule
