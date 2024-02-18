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
    input wire          hwclk,
    input wire          s1_n,
    output wire [7:0]   led,

    input wire [19:0]   a,
    inout wire [7:0]    d,          // bidirectional

    input wire          busack_n,
    output wire         busreq_n,

    output wire         ce_n,
    output wire         oe_n,
    output wire         we_n,

    output wire         dreq1_n,

    input wire          e,
    output wire         extal,
    input wire          phi,

    input wire          halt_n,

    output wire [2:0]   int_n,
    output wire         nmi_n,

    input wire          rd_n,
    input wire          wr_n,
    input wire          iorq_n,
    input wire          mreq_n,
    input wire          m1_n,

    output wire         reset_n,
    input wire          rfsh_n,
    input wire          st,
    input wire          tend1_n,
    output wire         wait_n,

    input wire          hwclk,

    output wire [7:0]   led,

    input wire          s1_n,
    input wire          s2_n

    );

    wire [7:0]  rom_data;       // ROM output data bus

    // Instantiate the boot ROM
    //boot_loop boot_rom ( .addr(a[8:0]), .data(rom_data));
    //boot_noref boot_rom ( .addr(a[8:0]), .data(rom_data));
    boot_noref_nowait boot_rom ( .addr(a[8:0]), .data(rom_data));

    assign reset_n = s1_n;      // route the reset signal to the CPU

    // When the CPU is reading, send it data from our ROM
    assign d = (~mreq_n & ~rd_n) ? rom_data : 8'bz;

    // extal = 25000000/2 = 12.5mhz
    localparam CLK_BITS = 1;
    reg [CLK_BITS-1:0]     ctr;
    always @(posedge hwclk) begin
        ctr <= ctr + 1;
    end

    assign extal = ctr[CLK_BITS-1];

    assign led = ~a[7:0];           // LEDs are active-low

    // de-assert everything
    assign busreq_n = 1'b1;         // do not request the bus
    assign dreq1_n = 1'b1;          // do not request a DMA operation
    assign int_n = 3'b111;          // do not request any IRQs
    assign nmi_n = 1'b1;            // do not request an NMI
    assign wait_n = 1'b1;           // do not request any wait states
    assign ce_n = 1'b1;             // do not enable the SRAM
    assign oe_n = 1'b1;             // do not pass go,
    assign we_n = 1'b1;             // do not collect $200

endmodule
