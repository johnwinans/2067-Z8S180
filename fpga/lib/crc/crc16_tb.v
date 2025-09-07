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

`timescale 1ns/1ps

/**
* A test bench for multiple standard 8-bit CRCs.
*
* see: https://crccalc.com
***************************************************************************/
module ttop ();

    reg clk         = 0;        ///< free running clock
    reg rst         = 1;        ///< reset (active high)
    reg data        = 0;        ///< input bit-stream
    reg data_ref    = 0;        ///< reflected input bit-stream
    reg enable      = 0;        ///< advance the CRC calc on the next clk
    reg ready       = 0;        ///< true when the CRC value is valid

    // The following can appear misleading!  Note that we are reversing the order of the bits
    // little endian = [n:0]
    // big endian = [0:n]

    localparam MSG_LEN = 9*8;
    reg [MSG_LEN-1:0] check_data = "123456789";      

    reg [7:0] ctr       = 0;      // a bit counter 
    reg [7:0] ix        = 0;      // the next bit to send index 
    reg [7:0] ix_ref    = 0;      // the next bit to send index in reflected order

    localparam RST_PERIOD = 4;

    // 16-bit reflected tests (bitwise little-endian data arrival)
    wire [15:0] crc_cdma2000_out;       
    crc #(.BITS(16), .POLY(16'hC867), .INIT(16'hFFFF), .REF_OUT(0), .XOR_OUT(16'h0)) crc_cdma2000 (.clk(clk), .rst(rst), .data(data), .enable(enable), .crc_out(crc_cdma2000_out));

    wire [15:0] crc_arc_out;       
    crc #(.BITS(16), .POLY(16'h8005), .INIT(16'h0000), .REF_OUT(1), .XOR_OUT(16'h0)) crc_arc (.clk(clk), .rst(rst), .data(data_ref), .enable(enable), .crc_out(crc_arc_out));

    initial
    begin
        $dumpfile("crc16_tb.vcd");
        $dumpvars;          // dump everything in the ttop module

        #4;
        @(posedge clk);
        rst <= 0;
    end

    always #1 clk = ~clk;

    // this will clear the ctr when reset is true
    always @(negedge clk) begin
        if (rst) begin
            ctr <= ~0;          // start at all-ones so first tick becomes zero
        end else begin
            ctr <= ctr+1;
        end
        $strobe( "%t: rst:%x enable:%d ready:%d data:%x ref:%x ix:%3d %3d", $time, rst, enable, ready, data, data_ref, ix, ix_ref );
    end

    always @(*) begin
        enable      = ctr < MSG_LEN;                        // enable CRC generator until we run out of bits

        ix          = enable ? (MSG_LEN-1)-ctr : 'hx;       // bitwise big-endian order
        ix_ref      = enable ? 8*(ix/8)+7-(ix%8) : 'hx;     // bitwise little-endian order

        data        = check_data[ix];                       // send MSb first for each byte
        data_ref    = check_data[ix_ref];                   // send LSb first for each byte
        ready       = (ctr == MSG_LEN);                     // ready on clk follwing the last transmitted bit
    end

    initial
    begin
        @(posedge ready);   // wait till we are ready
        #8;                 // add some margin to the end of the waveform

        $display("cdma2000: %h %b", crc_cdma2000_out, crc_cdma2000_out==16'h4C06);
        $display("     arc: %h %b", crc_arc_out, crc_arc_out==16'hBB3D);

        $finish;
    end

endmodule
