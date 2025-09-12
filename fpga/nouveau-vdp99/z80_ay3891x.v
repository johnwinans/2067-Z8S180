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

// The purpose of this module is to connect the CPU clock domain to the ay38910 PSG
// clock domain. 
// XXX This is much the same as for the vdp99.  This overlap should be factored out.

`timescale 1ns/1ns
`default_nettype none

module z80_ay3891x #(
    parameter CLK_FREQ = 25000000
    ) (
    input wire          reset,
    input wire          phi,            // the z80 PHI clock
    input wire          clk,          	// the PSG clock

    input wire          a0,       		// address valid during cpu_rd/wr_tick
    input wire [7:0]    wdata,        	// valid during cpu_wr
    output wire [7:0]   rdata,       	// must be valid during cpu_rd

    input wire          cpu_wr,         // async CPU signal
    input wire          cpu_rd,         // async CPU signal
    
	output wire [2:0]	aout
    );

    localparam SYN_LEN = 3;             // too long for worst case write timing
    //localparam SYN_LEN = 2;           // not safe from metastability

    reg [SYN_LEN-1:0]   ay_wr_sync;
    always @(posedge clk)
        ay_wr_sync <= {cpu_wr, ay_wr_sync[SYN_LEN-1:1]};

    reg [SYN_LEN-1:0]   ay_rd_sync;
    always @(posedge clk)
        ay_rd_sync <= {cpu_rd, ay_rd_sync[SYN_LEN-1:1]};

    wire    ay_wr_tick = ay_wr_sync[1:0] == 2'b10;        // clk domain
    wire    ay_rd_tick = ay_rd_sync[1:0] == 2'b10;        // clk domain

    // stretch the CPU address and data bus values for worst-case write timing.
    // note that the edge used here is a gated clock to latch one clk period before ay_wr_tick falls
    reg [7:0]   ay_wdata;
    always @(posedge ay_wr_tick)
        ay_wdata <= wdata;

    // stretch the data bus values when reading
    // note that the cpu asserts RD sooner than WR on IORQ cycles 
    wire [7:0] ay_rdata;
    reg [7:0] cpu_dout_reg;

    //always @(posedge clk)
    always @(negedge clk)         // negedge buys us another 20ns setup on dout (will cut max clk freq in half)
        if ( ay_rd_tick )
            cpu_dout_reg <= ay_rdata;

    ay3891x #(
        .CLK_FREQ(CLK_FREQ),
        ) ay (
        .reset(reset),
        .clk(clk),
        .a0(a0),
        .wr_tick(ay_wr_tick),
        .wdata(ay_wdata),
        .rd_tick(ay_rd_tick),
        .rdata(ay_rdata),
        .aout(aout)
        );

    assign rdata = cpu_dout_reg;

endmodule
