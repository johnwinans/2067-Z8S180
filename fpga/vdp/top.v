`default_nettype none

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

module top (
    input   wire        hwclk,
    input   wire        s1_n,
    input   wire        s2_n,
    output  wire [1:0]  vga_red,
    output  wire [1:0]  vga_grn,
    output  wire [1:0]  vga_blu,
    output  wire        vga_hsync,
    output  wire        vga_vsync,
    output  wire [7:0]  led
    );

    wire vid_red;
    wire vid_grn;
    wire vid_blu;
    assign vga_red = { vid_red, vid_red };
    assign vga_grn = { vid_grn, vid_grn };
    assign vga_blu = { vid_blu, vid_blu };

    video vdp ( 
        .pxclk(hwclk),
        .reset(~s1_n),      // active high
        .vga_red(vid_red),
        .vga_grn(vid_grn),
        .vga_blu(vid_blu),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync)
        );

    assign led = ~0;                // turn off the LEDs

endmodule
