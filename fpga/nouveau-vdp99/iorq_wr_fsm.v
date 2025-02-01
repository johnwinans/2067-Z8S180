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
// for a write cycle: latch value on second phi falling edge after iorq becomes true:
// fsm counting falling phi when wr is true and enable when count = 1

module iorq_wr_fsm (
    input wire          phi,            // the CPU phi clock
    input wire          reset,
    input wire          iorq,           // positive logic iorq
    input wire          wr,             // positive logic wr
    output wire         wr_tick         // true during window to capture first phi falling edge
    );
 
    reg [1:0]   state_reg, state_next;

    always @(negedge phi) begin
        if ( reset )
            state_reg <= 0;
        else
            state_reg <= state_next;
    end

    always @(*) begin
        state_next = 0;

        case ( state_reg )
        0:
            if ( iorq && wr )
                state_next = 1;
        1:
            if ( iorq && wr )
                state_next = 2;
        2:
            if ( iorq && wr )
                state_next = 2;
        endcase
    end

    assign wr_tick = ( state_reg==1 );

endmodule
