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

module ay_mux (
    input wire          reset,
    input wire          clk,
    input wire          tone,
    input wire          noise,
    input wire          enable_noise,
    input wire          enable_tone,
    output wire         out
    );

    reg out_reg, out_next;

    // Note: this will phase-shift the output by 1 clk
    always @(posedge clk) begin
        if (reset) begin
            out_reg <= 0;
        end else begin
            out_reg <= out_next;
        end
    end

    always @(*) begin
        case ( { enable_noise, enable_tone } )
        2'b00:  out_next = tone & noise;
        2'b01:  out_next = noise;
        2'b10:  out_next = tone;
        2'b11:  out_next = 1;               // when disabled, output a 1
        endcase
    end

    assign out = out_reg;

endmodule
