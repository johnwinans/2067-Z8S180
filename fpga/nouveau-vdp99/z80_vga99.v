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

// The purpose of this module is to connect use a latch to sync the video
// pipeline on the way out of the FPGA to the video DAC.

`timescale 1ns/1ns
`default_nettype none

module z80_vga99 #(
    parameter VRAM_SIZE = 8*1024
    ) (
    input wire          reset,
    input wire          phi,            // the z80 PHI clock
    input wire          pxclk,          // the pixel clock

    input wire          cpu_mode,       // address valid during cpu_rd/wr_tick
    input wire [7:0]    cpu_din,        // valid during cpu_wr
    output wire [7:0]   cpu_dout,       // must be valid during cpu_rd

    input wire          cpu_wr,         // async CPU signal
    input wire          cpu_rd,         // async CPU signal

    output wire [1:0]   red,
    output wire [1:0]   grn,
    output wire [1:0]   blu,
    output wire         hsync,
    output wire         vsync,
    output wire         irq
    );

    wire [3:0]  vdp_color;
    wire [1:0]  vga_red;
    wire [1:0]  vga_grn;
    wire [1:0]  vga_blu;
    wire        vdp_hsync;
    wire        vdp_vsync;

    reg [1:0]   vga_red_reg;
    reg [1:0]   vga_grn_reg;
    reg [1:0]   vga_blu_reg;
    reg         hsync_reg;
    reg         vsync_reg;

    z80_vdp99 #( .VRAM_SIZE(VRAM_SIZE) ) vdp (
        .reset(reset),
        .phi(phi),
        .pxclk(pxclk),
        .cpu_mode(cpu_mode),
        .cpu_din(cpu_din),
        .cpu_dout(cpu_dout),
        .irq(irq),
        .cpu_wr(cpu_wr),
        .cpu_rd(cpu_rd),
        .color(vdp_color),
        .hsync(vdp_hsync),
        .vsync(vdp_vsync)
    );

    // Remap the 4-bit VDP color codes to 6-bit RGB
    color_palette palette (
        .color(vdp_color),
        .red(vga_red),
        .grn(vga_grn),
        .blu(vga_blu)
    );

    // Implement a latch to sync the VGA signals by adding a 1PX delay 
    // to allow the color pipeline to settle.
    always @(posedge pxclk) begin
        vga_red_reg <= vga_red;
        vga_grn_reg <= vga_grn;
        vga_blu_reg <= vga_blu;
        hsync_reg <= vdp_hsync;
        vsync_reg <= vdp_vsync;
    end

    assign hsync = ~hsync_reg;
    assign vsync = ~vsync_reg;
    assign red = vga_red_reg;
    assign grn = vga_grn_reg;
    assign blu = vga_blu_reg;

endmodule
