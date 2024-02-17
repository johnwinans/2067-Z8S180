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
    output wire [7:0]   d,

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

    assign reset_n = s1_n;

    assign d = rd_n == 0 ? { 8'b0 } : { 8'bz };

    reg [15:0]     ctr;
    always @(posedge hwclk) begin
        ctr <= ctr + 1;
    end

    assign extal = ctr[15];
    assign led = ~a[15:8];

    assign busreq_n = 1'bz;
    assign dreq1_n = 1'bz;
    assign int_n = 3'bz;
    assign nmi_n = 1'bz;
    assign wait_n = 1'bz;

    wire [8:0]  rom_data;

    memory boot_rom (
                .addr(a[3:0]),
                .data(rom_data)
                );

endmodule