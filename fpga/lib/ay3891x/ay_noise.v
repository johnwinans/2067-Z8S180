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

module ay_noise (
    input wire          reset,
    input wire          clk,
    input wire          ay_clk,         // synchronized-ish locked to clk
    input wire [4:0]    period,
    output wire         out
    );

//add a prescaler in here

    // use a CDMA2000 CRC feeding back on itself
    reg [8:0]   noise_ctr_reg, noise_ctr_next;
    reg         crc_enable_reg, crc_enable_next;
    wire [15:0] crc_out;
    assign      out = crc_out[15];

    crc #(.BITS(16), .POLY(16'hC867), .INIT(16'hFFFF), .REF_OUT(0), .XOR_OUT(16'h0)) crc_cdma2000 (.clk(clk), .rst(reset), .data(noise_ctr_reg[0]), .enable(crc_enable_reg), .crc_out(crc_out));

    always @(posedge clk) begin
        if (reset) begin
            noise_ctr_reg <= 0;
            crc_enable_reg <= 0;
        end else begin
            noise_ctr_reg <= noise_ctr_next;
            crc_enable_reg <= crc_enable_next;
        end
    end

    always @(*) begin
        if ( noise_ctr_reg == 0 ) begin
            noise_ctr_next = { period , 4'b0000 };      // 16 for noise prescaler
            crc_enable_next <= 1;
        end else begin
            noise_ctr_next = noise_ctr_reg - 1;
            crc_enable_next = 0;
        end
    end

endmodule
