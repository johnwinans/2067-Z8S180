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

module vdp_irq(
    input   wire        reset,      // active high
    input   wire        clk,

    input   wire        irq_tick,   // true = assert irq on next clk rising edge
    input   wire        rd_tick,    // true = clear irq on next clk rising
    output  wire        irq         // true = irq
    );

    reg         irq_reg, irq_next;

    always @(posedge clk) begin
        if ( reset ) begin
            irq_reg <= 0;
        end else begin
            irq_reg <= irq_next;
        end
    end

    always @(*) begin
        case ( { irq_tick, rd_tick } )
        'b00: irq_next = irq_reg;
        'b01: irq_next = 0;
        'b10: irq_next = 1;
        'b11: irq_next = 1;         // when irq_tick and rd_tick at same time, leave IRQ on.
        endcase
    end

    assign irq = irq_reg;

endmodule
