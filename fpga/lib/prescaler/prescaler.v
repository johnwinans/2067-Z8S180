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

module prescaler #(
    parameter IN_FREQ   = 25000000,     // freq of clk
    parameter OUT_FREQ  = 12500000      // Target output clk
    ) (
    input wire      reset,
    input wire      clk,
    output wire     out_tick            // single-tick output
    );

    // Generate a clock that is close to the OUT_FREQ
    localparam integer CLK_DIV = ((1.0*IN_FREQ) / OUT_FREQ);
    reg [$clog2(CLK_DIV)-1:0] clk_reg, clk_next;
    reg out_reg, out_next;

    assign out_tick = out_reg;

    always @(posedge clk) begin
        if ( reset ) begin
            clk_reg <= CLK_DIV-1;
            out_reg <= 0;
        end else begin
            clk_reg <= clk_next;
            out_reg <= out_next;
        end
    end

    always @(*) begin
        if ( clk_reg == 0 ) begin
            out_next = 1;
            clk_next = CLK_DIV-1;
        end else begin
            out_next = 0;
            clk_next = clk_reg - 1;
        end
    end

endmodule
