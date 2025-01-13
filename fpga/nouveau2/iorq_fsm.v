`timescale 1ns/1ps

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
//      the S180 configured to operate in IOC=1 mode.
//      When operating in IOC=1 mode, a read operation will take place during 
//      Tw and a write will take place during T3.
module iorq_fsm (
    input wire          phi,            // the CPU phi clock
    input wire          iorq,           // assume is (~iorq_n && (~rd_n || !wr_n))
    output wire         iorq_tick       // true for one phi period during CPU t3 cycle
    );
 
    reg [1:0]   sync;                   // this is used as a 2-bit shift register

    always @(posedge phi) begin
        sync <= {sync[0], iorq};        // shift iorq through the shift register
    end

    // include iorq here so that if it starts late then it will end early
    assign iorq_tick = (sync == 2'b01) && iorq;   // true only during inital shift into the reg 

endmodule
