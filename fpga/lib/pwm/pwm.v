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

module pwm #(
    parameter MAX_PERIOD    = 1024,
    parameter CTR_BITS      = $clog2(MAX_PERIOD)
    ) (
    input wire                  reset,
    input wire                  clk,
    input wire [CTR_BITS-1:0]   period,
    output wire                 out
    );

    reg [CTR_BITS-1:0] ctr_reg, ctr_next;
    reg out_reg, out_next;

    assign out = out_reg;

    always @(posedge clk) begin
        if ( reset ) begin
            ctr_reg <= 0;
            out_reg <= 0;
        end else begin
            ctr_reg <= ctr_next;
            out_reg <= out_next;
        end
    end

    always @(*) begin
        if ( ctr_reg == 0 ) begin
            out_next = 0;                       // This will limit the max high period to MAX_PERIOD-1
            ctr_next = MAX_PERIOD-1;
        end else if ( ctr_reg <= period ) begin
            out_next = 1;
            ctr_next = ctr_reg -1;
        end else begin
            out_next = out_reg;
            ctr_next = ctr_reg -1;
        end
    end

endmodule
