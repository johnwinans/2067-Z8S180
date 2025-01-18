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

`default_nettype none

module video (
    input   wire        pxclk,      // 25MHZ
    input   wire        reset,      // active high
    output  wire        vga_red,
    output  wire        vga_grn,
    output  wire        vga_blu,
    output  wire        vga_hsync,
    output  wire        vga_vsync
    );

    wire vs_vid;
    wire vs_bdr;
    wire vs_hsync, vdp_hsync;
    wire vs_vsync, vdp_vsync;
    wire [$clog2(800)-1:0] vs_col;    // big enough to hold the counter value
    wire [$clog2(525)-1:0] vs_row;     // big enough to hold the counter value

    localparam HLB  = 64;      // horizontal left border here to use below
    localparam VTB  = 48;      // vertical top border here to use below

    vgasync #( .HLB(HLB), .VTB(VTB) ) vga (
        .clk(pxclk),
        .reset(reset),
        .hsync(vs_hsync),
        .vsync(vs_vsync),
        .col(vs_col),
        .row(vs_row),
        .vid_active(vs_vid),
        .bdr_active(vs_bdr)
    );

    wire [9:0]  name_raddr;
    wire [10:0] pattern_raddr;
    wire [4:0]  color_raddr;

    reg [7:0]  name_rdata;
    reg [7:0]  pattern_rdata;
    reg [7:0]  color_rdata;

	reg [7:0] name_mem [0:767];
	reg [7:0] pattern_mem [0:2047];
	reg [7:0] color_mem [0:31];

	initial begin
        // readmemh include path?  Anybody??
		$readmemh("../vdp/rom_name.hex", name_mem);
		//$readmemh("../vdp/rom_pattern.hex", pattern_mem);
		$readmemh("../vdp/rom_binnacle.hex", pattern_mem);     // https://damieng.com/typography/zx-origins/binnacle/
		$readmemh("../vdp/rom_color.hex", color_mem);
	end

	always @(posedge pxclk) begin
		name_rdata      <= name_mem[name_raddr];
		pattern_rdata   <= pattern_mem[pattern_raddr];
		color_rdata     <= color_mem[color_raddr];
	end

    vdp_table_test vdp (
        .pxclk(pxclk),
        .reset(reset),
        .hsync_in(vs_hsync),
        .vsync_in(vs_vsync),
        .col_in(vs_col-HLB),           // may not be most efficient way to do this :-/
        .row_in(vs_row-VTB),
        .active_in(vs_vid),
        .border_in(vs_bdr),
        .hsync_out(vdp_hsync),
        .vsync_out(vdp_vsync),
        .red(vga_red),
        .grn(vga_grn),
        .blu(vga_blu),
        .name_raddr(name_raddr),
        .name_rdata(name_rdata),
        .pattern_raddr(pattern_raddr),
        .pattern_rdata(pattern_rdata),
        .color_raddr(color_raddr),
        .color_rdata(color_rdata),
    );

    assign vga_hsync = ~vdp_hsync;      // Polarity of horizontal sync pulse is negative.
    assign vga_vsync = ~vdp_vsync;      // Polarity of vertical sync pulse is negative.

endmodule
