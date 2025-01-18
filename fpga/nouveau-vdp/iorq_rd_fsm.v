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

// NOTE: This is NOT useful for a general purpose synchronizer because this
//      expects the input signal to meet the FPGA's setup and hold times with
//      the Z8S180 configured to operate in IOC=1 mode.
// Want:
// for read cycle: latch value on first phi falling edge after iorq becomes true:
// fsm counting falling phi when rd is true & enable when count = 0 && iorq is true

// for a write cycle: latch value on second phi falling edge after iorq becomes true:
// fsm counting falling phi when wr is true and enable when count = 1

module iorq_rd_fsm (
    input wire          phi,            // the CPU phi clock
    input wire          reset,
    input wire          iorq,           // positive logic iorq
    input wire          rd,             // positive logic rd
    output wire         rd_tick         // true during window to capture first phi falling edge
    );
 
    reg     state_reg, state_next;

    always @(negedge phi) begin
        if ( reset )
            state_reg <= 0;
        else
            state_reg <= state_next;
    end

    always @(*) begin
        state_next = iorq && rd;
    end

    assign rd_tick = ( state_reg==0 && iorq && rd );

endmodule
