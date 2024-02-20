//**************************************************************************
//
//    Copyright (C) 2024  John Winans
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

module top (
    input wire          hwclk,      // 25MHZ oscillator on the 2057 FPGA board
    input wire          s1_n,       // press-button on the 2057 FPGA board
    output wire [7:0]   led,        // LEDs on the 2057 FPGA board

    input wire [19:0]   a,          // Z8S180 address bus
    inout wire [7:0]    d,          // Z8S180 data bus is bidirectional  <-------------

    input wire          busack_n,   // Z8S180 /BUSACK
    output wire         busreq_n,   // Z8S180 /BUSREQ

    output wire         ce_n,       // SRAM /CE
    output wire         oe_n,       // SRAM /OE
    output wire         we_n,       // SRAM /WE

    output wire         dreq1_n,    // Z8S180 /DREQ1

    input wire          e,          // Z8S180 E
    output wire         extal,      // Z8S180 EXTAL (main clock from FPGA to CPU)
    input wire          phi,        // Z8S180 reference clock output

    input wire          halt_n,     // Z8S180 /HALT status pin

    output wire [2:0]   int_n,      // Z8S180 INT0, 1, 2
    output wire         nmi_n,      // Z8S180 NMI

    input wire          rd_n,       // Z8S180 /RD
    input wire          wr_n,       // Z8S180 /WR
    input wire          iorq_n,     // Z8S180 /IORQ
    input wire          mreq_n,     // Z8S180 /MREQ
    input wire          m1_n,       // Z8S180 /M1

    output wire         reset_n,    // Z8S180 /RESET
    input wire          rfsh_n,     // Z8S180 /RFSH
    input wire          st,         // Z8S180 /ST
    input wire          tend1_n,    // Z8S180 /TEND1
    output wire         wait_n,     // Z8S180 /WAIT

    output wire [15:0]  tp          // handy-dandy test-points on the 2057 FPGA board
    );
 
    assign tp = { st, rfsh_n, wr_n, rd_n, iorq_n, mreq_n, m1_n, phi, extal };

    assign reset_n = s1_n;

    // ONLY when the CPU is reading shall we drive the data bus
    assign d = ( rd_n == 0 ? { 8'b0 } : { 8{1'bz} } );

    // extal = 25000000/16777216 = 1.5hz (approx)
    //localparam CLK_BITS = 24;
    localparam CLK_BITS = 22;
    //localparam CLK_BITS = 1;

    // Use a counter to divide the clock speed down to human speed.
    reg [CLK_BITS-1:0]     ctr;
    always @(posedge hwclk) begin
        ctr <= ctr + 1;
    end

    assign extal = ctr[CLK_BITS-1]; // slow clock for the CPU

    //assign led = ~a[15:8];          // recall that the LEDs light when low
    assign led = ~a[7:0];           // recall that the LEDs light when low

    // de-assert everything
    assign busreq_n = 1'b1;         // do not request the bus
    assign dreq1_n = 1'b1;          // do not request a DMA operation
    assign int_n = 3'b111;          // do not request any IRQs
    assign nmi_n = 1'b1;            // do not request an NMI
    assign wait_n = 1'b1;           // do not request any wait states
    assign ce_n = 1'b1;             // do not enable the SRAM
    assign oe_n = 1'b1;             // do not pass go
    assign we_n = 1'b1;             // do not collect $200

endmodule
