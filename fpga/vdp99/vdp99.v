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

module vdp99 (
    input   wire        pxclk,      // 25MHZ
    input   wire        reset,      // active high

    input   wire        wr0_tick,
    input   wire        wr1_tick,
    input   wire        rd0_tick,
    input   wire        rd1_tick,
    input   wire [7:0]  din,
    outpu   wire [7:0]  dout,

    output  wire        vga_red,
    output  wire        vga_grn,
    output  wire        vga_blu,
    output  wire        vga_hsync,
    output  wire        vga_vsync
    );

    assign vga_red = 0;
    assign vga_grn = 0;
    assign vga_blu = 0;
    assign vga_hsync = 0;
    assign vga_vsync = 0;

	always @(posedge pxclk) begin
	end

endmodule
