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


/**
* Implement one TI99-style sprite.
*
* pattern will have 16 bits loaded.  When rendering 8 bits, the LSB will be zero.
* When early is 1 the hpos value starts from 32px to the left of the acvive region.
* 1 VDP pixel = 2 pxclk periods.
* Note that mag can double the size to 32x32 max.
***************************************************************************/
module sprite 
    (
    input   wire        reset,          // active high
    input   wire        pxclk,          // 25MHZ VGA clock (2X the VDP clock)

    input   wire        col_last_tick,  // when true, the next col will represent hpos_reg zero
    input   wire        mag,            // true when magnified mode (2X size VDP pixels)
    input   wire        early,          // 1=shift left 32 VDP pixel units
    input   wire [8:0]  hpos,           // 0=left edge, 0xff=off right edge (in VDP pixel units)
    input   wire [15:0] pattern,        // pattern of the current row to render
    input   wire [3:0]  fg_color,       // foreground color (stable between load_ticks)
    input   wire        load_tick,      // true when time to load the pattern, hpos, & color

    output  wire [3:0]  color_out       // set to either fg_color or zero
    );

    reg         active_reg, active_next;        // sprite rendering is active
    reg [1:0]   pxvdp_reg, pxvdp_next;          // counts at pxclk rate
    reg         mag_reg, mag_next;              // false = 1:1, true = 2:1 (magnify VDP pixels)
    reg [8:0]   hpos_reg, hpos_next;            // 0 = 32 VDP px to left of border
    reg [15:0]  pattern_reg, pattern_next;      // 16-bit row value that will shift out at hpos_reg
    reg [5:0]   color_reg, color_next;

    always @(posedge pxclk) begin
        if (reset) begin
            active_reg <= 0;
            pxvdp_reg <= 0;
            mag_reg <= 0;
            hpos_reg <= 0;
            pattern_reg <= 0;
            color_reg <= 0;
        end else begin
            active_reg <= active_next;
            pxvdp_reg <= pxvdp_next;
            mag_reg <= mag_next;
            hpos_reg <= hpos_next;
            pattern_reg <= pattern_next;
            color_reg <= color_next;
        end
    end

    always @(*) begin
        active_next = active_reg;
        mag_next = mag_reg;
        hpos_next = hpos_reg;
        pattern_next = pattern_reg;
        color_next = color_reg;

        pxvdp_next = pxvdp_reg+1;

        if (load_tick) begin
            active_next = 0;
            mag_next = mag;
            hpos_next = early ? hpos : hpos+32;     // move it to the right if NOT starting early
            pattern_next = pattern;
            color_next = fg_color;
        end

        if (col_last_tick) begin
            active_next = 1;                // start counting/rendering the sprite
            pxvdp_next = 0;                 // jam sync the phase so start at zero
        end 
            if (active_reg && pxvdp_reg[0]) begin
                // skip hpos_reg pixels and then start showing the pattern bits
                if (hpos_reg != 0) begin
                    hpos_next = hpos_reg-1;
                end else begin
                    // mag_reg doubles the size of the pixels, shift 1/2 as often
                    if ((mag_reg && pxvdp_reg==2'b11) || (~mag_reg && pxvdp_reg[0])) begin
                        pattern_next = { pattern_reg[14:0], 1'b0 };     // shift left one bit
                    end
                end
            end
    end

    // sprite is showing when active_reg & the pattern_reg MSb is 1
    assign color_out = (active_reg && hpos_reg==0 && pattern_reg[15]) ? color_reg : 0;

endmodule
