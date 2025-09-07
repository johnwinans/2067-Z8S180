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

module ay_tone (
    input wire          reset,
    input wire          clk,
    input wire          ay_clk,         // synchronized-ish locked to clk
    input wire [11:0]   period,
    output wire         out
    );

    reg [11:0]  tone_ctr_reg, tone_ctr_next;
    reg         out_reg, out_next;

    always @(posedge clk) begin
        if (reset) begin
            tone_ctr_reg <= 0;
            out_reg <= 0;
        end else begin
            tone_ctr_reg <= tone_ctr_next;
            out_reg <= out_next;
        end
    end

    always @(*) begin
        if ( tone_ctr_reg == 0 ) begin
            tone_ctr_next = period/2;
            out_next = ~out_reg;
        end else begin
            tone_ctr_next = tone_ctr_reg - 1;
            out_next = out_reg;
        end
    end

    assign out = out_reg;

endmodule
