//************************************************************************
//
// A parameterizable CRC generator
//
// Copyright (C) 2023 John Winans
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// See: https://github.com/johnwinans/crc8
//
//************************************************************************

`timescale 1ns/1ns
`default_nettype none


/**
* @note Since this is a bit-serial implementation, there is no option at 
* this level to reflect the input bits.  (Input reflection normally 
* represents the natural order of the data arrival.)
*
* @note This implementation uses the "Direct Method." This provides the CRC
* value immediately after the last message bit has been received. (This
* is in contrast to the "Zero-Augmented Method" where trailing zeros are
* clocked into the generater after the end of the message.)
*
***************************************************************************/
module crc 
#(
    // default settings for crc8_wcdma
    parameter   BITS    = 8,            ///< How many bits wide is the CRC
    parameter   POLY    = 8'h9B,        ///< The CRC polynomial
    parameter   INIT    = 8'h00,        ///< the initial value of the CRC
    parameter   XOR_OUT = 8'h00,        ///< XOR the result
    parameter   REF_OUT = 1             ///< reverse the bit order of the CRC
)
(
    input wire clk,                     ///< accept a new bit on rising edge
    input wire rst,                     ///< sync reset when true and clk rising edge
    input wire data,                    ///< message data bits
    input wire enable,                  ///< accept data when high & clk rising
    output wire [BITS-1:0] crc_out      ///< the running value of calculated crc
);

    reg [BITS-1:0] crc_reg;
    wire xdi = crc_reg[BITS-1]^data;
    wire [BITS-1:0] crc_ref;

    always @(posedge clk) begin
        if (rst) begin
            crc_reg <= INIT;
        end else if (enable) begin
            crc_reg <= {crc_reg[BITS-2:0], 1'b0} ^ (xdi ? POLY : 0);
        end
    end

    // reflect the CRC value... or not
    // this will be optimized into wire connections
    genvar j;
    generate for(j=0; j<BITS; j=j+1) 
        assign crc_ref[j] = (REF_OUT ? crc_reg[BITS-1-j] : crc_reg[j]);
    endgenerate

    // XOR the (possibly reflected) result
    // this will get optimized into inverters or nothing because XOR_OUT is a constant
    assign crc_out = crc_ref ^ XOR_OUT;

endmodule

