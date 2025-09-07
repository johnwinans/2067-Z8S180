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

    localparam MSG_LEN = 9*8;
    reg [MSG_LEN-1:0] check_data = "123456789";

    reg [7:0] ctr       = 0;      // a bit counter 
    reg [7:0] ix        = 0;      // the next bit to send index 
    reg [7:0] ix_ref    = 0;      // the next bit to send index in reflected order

    localparam RST_PERIOD = 4;


    // 8-bit reflected tests (bitwise little-endian data arrival)
    wire [7:0] crc_wcdma_out;       
    crc #(.POLY(8'h9B), .INIT(8'h00)) crc_wcdma (.clk(clk), .rst(rst), .data(data_ref), .enable(enable), .crc_out(crc_wcdma_out));
    wire [7:0] crc_rohc_out;
    crc #(.POLY(8'h07), .INIT(8'hff)) crc_rohc (.clk(clk), .rst(rst), .data(data_ref), .enable(enable), .crc_out(crc_rohc_out));
    wire [7:0] crc_maxim_out;
    crc #(.POLY(8'h31), .INIT(8'h00)) crc_maxim (.clk(clk), .rst(rst), .data(data_ref), .enable(enable), .crc_out(crc_maxim_out));
    wire [7:0] crc_ebu_out;
    crc #(.POLY(8'h1D), .INIT(8'hff)) crc_ebu (.clk(clk), .rst(rst), .data(data_ref), .enable(enable), .crc_out(crc_ebu_out));
    wire [7:0] crc_darc_out;
    crc #(.POLY(8'h39), .INIT(8'h00)) crc_darc (.clk(clk), .rst(rst), .data(data_ref), .enable(enable), .crc_out(crc_darc_out));

    // 8-bit un-reflected tests (bitwise big-endian data arrival)
    wire [7:0] crc_8_out;
    crc #(.POLY(8'h07), .INIT(8'h00), .REF_OUT(0)) crc_8 (.clk(clk), .rst(rst), .data(data), .enable(enable), .crc_out(crc_8_out));
    wire [7:0] crc_cdma2000_out;
    crc #(.POLY(8'h9b), .INIT(8'hff), .REF_OUT(0)) crc_cdma2000 (.clk(clk), .rst(rst), .data(data), .enable(enable), .crc_out(crc_cdma2000_out));
    wire [7:0] crc_dvb52_out;
    crc #(.POLY(8'hd5), .INIT(8'h00), .REF_OUT(0)) crc_dvb52 (.clk(clk), .rst(rst), .data(data), .enable(enable), .crc_out(crc_dvb52_out));
    wire [7:0] crc_code_out;
    crc #(.POLY(8'h1d), .INIT(8'hfd), .REF_OUT(0)) crc_code (.clk(clk), .rst(rst), .data(data), .enable(enable), .crc_out(crc_code_out));
    wire [7:0] crc_itu_out;
    crc #(.POLY(8'h07), .INIT(8'h00), .REF_OUT(0), .XOR_OUT(8'h55)) crc_itu (.clk(clk), .rst(rst), .data(data), .enable(enable), .crc_out(crc_itu_out));

    initial
    begin
        $dumpfile("crc8_tb.vcd");
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

    // The following can appear misleading!  Note that data_ref is a reflected (reversed) bit ordering
    // little endian = [n:0]
    // big endian = [0:n]

    always @(*) begin
        enable      = ctr < MSG_LEN;                        // enable CRC generator until we run out of bits

        ix          = enable ? (MSG_LEN-1)-ctr : 'hx;       // bitwise big-endian order
        ix_ref      = enable ? 8*(ix/8)+7-(ix%8) : 'hx;     // bitwise little-endian order

        data        = check_data[ix];                       // send MSb first for each byte
        data_ref    = check_data[ix_ref];                   // send LSb first for each byte
        ready       = (ctr == MSG_LEN);                     // ready on clk following the last transmitted bit
    end

    initial
    begin
        @(posedge ready);   // wait till we are ready
        #8;                 // add some margin to the end of the waveform

        $display("    crc8: %h %b", crc_8_out, crc_8_out==8'hf4);
        $display("cdma2000: %h %b", crc_cdma2000_out, crc_cdma2000_out==8'hda);
        $display("    darc: %h %b", crc_darc_out, crc_darc_out==8'h15);
        $display("   dvb62: %h %b", crc_dvb52_out, crc_dvb52_out==8'hbc);
        $display("     ebu: %h %b", crc_ebu_out, crc_ebu_out==8'h97);
        $display("   icode: %h %b", crc_code_out, crc_code_out==8'h7e);
        $display("     itu: %h %b", crc_itu_out, crc_itu_out==8'ha1);
        $display("   maxim: %h %b", crc_maxim_out, crc_maxim_out==8'ha1);
        $display("    rohc: %h %b", crc_rohc_out, crc_rohc_out==8'hd0);
        $display("   wcdma: %h %b", crc_wcdma_out, crc_wcdma_out==8'h25);

        $finish;
    end

endmodule
