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

    reg reset;
    reg phi;
    reg pxclk;

    reg iorq;
    reg rd;
    reg wr;
    reg [15:0] a;
    reg [7:0] d;

    
    wire [7:0]   cpu_dout;
    wire [3:0]   color;
    wire hsync;
    wire vsync;
    wire irq;

    z80_vdp99 uut (
        .reset(reset),
        .phi(phi),
        .pxclk(pxclk),
        .cpu_mode(a[0]),
        .cpu_din(d),
        .cpu_dout(cpu_dout),
        .cpu_wr_tick(ioreq_wr_vdp_tick),
        .cpu_rd_tick(ioreq_rd_vdp_tick),
        .color(color),
        .hsync(hsync),
        .vsync(vsync),
        .irq(irq)
    );

    localparam phi_period = (1.0/18432000)*1000000000; // clk1 is running at about 18.432MHZ
    localparam pxclk_period = (1.0/25000000)*1000000000; // clk2 is running at 25MHZ

    always #(phi_period) phi = ~phi;
    always #(pxclk_period) pxclk = ~pxclk;


    // generate the ticks & such same as is done in top.v

    wire    iorq_rd_tick;
    iorq_rd_fsm rd_fsm (.reset(reset), .phi(phi), .iorq(iorq), .rd(rd), .rd_tick(iorq_rd_tick) );

    wire    iorq_wr_tick;
    iorq_wr_fsm wr_fsm (.reset(reset), .phi(phi), .iorq(iorq), .wr(wr), .wr_tick(iorq_wr_tick) );

    wire iorq_rd = iorq && rd;
    wire iorq_wr = iorq && wr;

    wire ioreq_rd_vdp = iorq_rd && (a[7:1] == 7'b1000000);  // true for ports 80 and 81
    wire ioreq_wr_vdp = iorq_wr && (a[7:1] == 7'b1000000);  // true for ports 80 and 81
    wire ioreq_wr_vdp_tick  = iorq_wr_tick && (a[7:1] == 7'b1000000);
    wire ioreq_rd_vdp_tick  = iorq_rd_tick && (a[7:1] == 7'b1000000);


    initial begin
        $dumpfile("z80_vdp99_tb.vcd");
        $dumpvars;

        reset = 1;
        phi = 0;
        pxclk = 0;

        a = 0;
        d = 0;
        iorq = 0;
        wr = 0;
        rd = 0;

        #(phi_period*4);
        reset <= 0;
        #(phi_period*4);;

        // This allows us to wait until the next clk1 rising edge (simulation only)
        @(posedge phi);        // this as T1 of an IORQ write cycle

        // A realistic 4-T Z8S180 IO write transaction
        #5;
        a <= 8'h81;          // address valid by 5ns after T1 rising edge

        @(negedge phi);
        #15;                    // data valid max 25ns after T1 falling and 10ns before T2 rising
        d <= 8'h23;          // some data value to write to the IO port

        // iorq = 25ns after T1 falling worst case
        // rd = 25ns after T1 falling worst case
        #5; // meh
        iorq <= 1;

        @(posedge phi);        // wait for T2 rising edge
        #22;                    // 25ns worst case
        wr <= 1;

        @(posedge phi);        // Wait for Tw rising
        @(posedge phi);        // Wait for T3 rising
        @(negedge phi);        // Wait for T3 falling
        #20;                    // 25ns worst case
        wr <= 0;
        iorq <= 0;
        
        @(posedge phi);        // wait for T1 rising of next bus cycle
        d = 'hz;
        a = 'hz;

        
        // skip the opcode fetch bus cycle
        @(posedge phi);        // T2
        @(posedge phi);        // T3

        // skip the operand fetch as if this were an OUT (nn),A instruction
        @(posedge phi);        // T1
        @(posedge phi);        // T2
        @(posedge phi);        // T3

        // The IORQ WR cycle
        #5;
        a <= 8'h81;          // address valid by 5ns after T1 rising edge

        @(negedge phi);
        #15;                    // data valid max 25ns after T1 falling and 10ns before T2 rising
        d <= 8'h82;          // write to VDP register 2

        // iorq = 25ns after T1 falling worst case
        // rd = 25ns after T1 falling worst case
        #5; // meh
        iorq <= 1;

        @(posedge phi);        // wait for T2 rising edge
        #22;                    // 25ns worst case
        wr <= 1;

        @(posedge phi);        // Wait for Tw rising
        @(posedge phi);        // Wait for T3 rising
        @(negedge phi);        // Wait for T3 falling
        #20;                    // 25ns worst case
        wr <= 0;
        iorq <= 0;
        
        @(posedge phi);        // wait for T1 rising of next bus cycle
        d = 'hz;
        a = 'hz;

        #(phi_period*100);
        $finish;
    end
 
endmodule
