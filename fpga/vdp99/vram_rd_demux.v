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

/*
* Capture din when rd_tick is true on /following/ clk.
***************************************************************************/
module vram_rd_demux (
    input wire                          reset,
    input wire                          clk,
    input wire                          rd_tick,        // true when reading
    input wire [7:0]                    din,
    output wire [7:0]                   dout
    );

    reg [7:0] dout_reg, dout_next;
    reg state_reg, state_next;

    always @(posedge clk) begin
        if (reset) begin
            dout_reg <= 0;
            state_reg <= 0;
        end else begin
            dout_reg <= dout_next;
            state_reg <= state_next;
        end
    end
    always @(*) begin
        dout_next = dout_reg;
        state_next = rd_tick;
        if (state_reg)
            dout_next = din;
    end

    assign dout = dout_reg;

endmodule
