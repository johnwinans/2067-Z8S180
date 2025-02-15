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

    reg reset       = 1;
    reg phi         = 0;
    reg pxclk       = 0;

    reg iorq        = 0;
    reg rd          = 0;
    reg wr          = 0;
    reg [15:0] a    = 'hz;
    reg [7:0] d     = 'hz;

    reg t1_marker   = 0;    // used to make obvious which are T1 phi clocks

    
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
        .cpu_wr(iorq && wr && (a[7:1] == 7'b1000000)),
        .cpu_rd(iorq && rd && (a[7:1] == 7'b1000000)),
        .color(color),
        .hsync(hsync),
        .vsync(vsync),
        .irq(irq)
    );

    localparam phi_period = (1.0/18432000)*1000000000; // clk1 is running at about 18.432MHZ
    localparam pxclk_period = (1.0/25000000)*1000000000; // clk2 is running at 25MHZ

    always #(phi_period/2) phi = ~phi;
    always #(pxclk_period/2) pxclk = ~pxclk;

    integer i;      // for loop iterator

    initial begin
        $dumpfile("z80_vdp99_tb.vcd");
        $dumpvars;

        reset <= 1;
        #(phi_period*4);
        reset <= 0;
        #(phi_period*4);;


        // write values into the 8 VDP registers
        for ( i=0; i<8; i=i+1 ) begin
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

            // IO write cycle
            @(posedge phi);         // T1 rising
            t1_marker <= 1;
            t1_marker <= #(phi_period) 0;

            @(negedge phi);         // T1 falling
            a <= #20 8'h81;         // address valid after T1 rising and >5ns before IORQ
            d <= #25 i;             // data <25ns after T1 falling and >10ns before WR active
            iorq <= #25 1;          // iorq = <25ns after T1 falling 
                                    // rd = <25ns after T1 falling 
            @(posedge phi);         // T2 rising
            wr <= #25 1;            // <25ns after T2 rising

            @(posedge phi);         // Tw rising
            @(posedge phi);         // T3 rising
            @(negedge phi);         // T3 falling

            iorq <= #1 0;           // iorq <25ns after T3 falling
            wr <= #1 0;             // wr <25ns after T3 falling
                                    // rd <25ns after T3 falling

            @(negedge wr)           // be careful that wr does not happen after posedge phi here!!!
            a <= #5 'hz;            // >5ns after iorq & wr trailing
            d <= #10 'hz;           // >10ns after wr trailing



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

            // IO write cycle
            @(posedge phi);         // T1 rising
            t1_marker <= 1;
            t1_marker <= #(phi_period) 0;


            @(negedge phi);         // T1 falling
            // write to VDP register i
            a <= #20 8'h81;         // address valid after T1 rising and >5ns before IORQ
            d <= #25 8'h80+i;       // data <25ns after T1 falling and >10ns before WR active
            iorq <= #25 1;          // iorq = <25ns after T1 falling 
                                    // rd = <25ns after T1 falling 
            @(posedge phi);         // T2 rising
            wr <= #25 1;            // <25ns after T2 rising

            @(posedge phi);         // Tw rising
            @(posedge phi);         // T3 rising
            @(negedge phi);         // T3 falling

            iorq <= #1 0;           // iorq <25ns after T3 falling
            wr <= #1 0;             // wr <25ns after T3 falling
                                    // rd <25ns after T3 falling

            @(negedge wr)           // be careful that wr does not happen after posedge phi here!!!
            a <= #5 'hz;            // >5ns after iorq & wr trailing
            d <= #10 'hz;           // >10ns after wr trailing

        end

//#(phi_period*100000);
//$finish;

        // wait until an entire frame has completed
        @(negedge vsync);

        // IRQ should have been asserted 
        // Read from the VDP status register to see the IRQ status flag on data bus & then be reset 

        @(posedge phi);

        @(negedge phi);         // T1 falling
        a <= #20 8'h81;         // address valid after T1 rising and >5ns before IORQ
        iorq <= #25 1;          // iorq = <25ns after T1 falling 
        rd <= #25 1;            // rd = <25ns after T1 falling 

        @(posedge phi);         // T2 rising
        @(posedge phi);         // Tw rising
        @(posedge phi);         // T3 rising
        @(negedge phi);         // T3 falling
        iorq <= #1 0;           // iorq <25ns after T3 falling
        rd <= #1 0;             // rd <25ns after T3 falling

        @(negedge iorq);
        a <= #5 'hz;            //  >5ns after iorq & rd trailing

        @(posedge phi);
 
        // waste some time to make waveform easier to zoom
        #(phi_period*20);
        $finish;
    end
 
endmodule
