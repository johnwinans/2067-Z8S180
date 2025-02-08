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

// This uses a pulse-stretcher and a transparent latch to pass a tick
// signal from the phi (clk1) domain to the clk2 domain.

// Want:
// For a write cycle: latch the tick1 and din1 values on the second phi 
// falling edge after iorq becomes true.  Then generate tick2 in the clk2
// domain using a pulse stretcher.

module z80_wr_cdc #(
    parameter ADDR_WIDTH = 8
    ) (
    input wire                  reset,
    input wire                  clk1,           // normally, the CPU phi clock
    input wire                  clk2,           // the clock in the target domain
    input wire                  wr_tick1,       // a write tick in clk1 domain
    input wire [7:0]            din1,           // the data bus from the CPU valid during wr
    input wire [ADDR_WIDTH-1:0] ain1,           // the address bus from the CPU valid during wr
    output wire                 wr_tick2,       // a write tick in the clk2 domain when dout is valid
    output wire [7:0]           dout2,          // the latched data bus valid during wr_tick2
    output wire [ADDR_WIDTH-1:0] aout2          // the latched address bus valid during wr_tick2
    );
 
    reg [ADDR_WIDTH-1:0] aout_reg = 'hx;           // initial value for simulation
    reg [7:0] dout_reg = 'hx;           // initial value for simulation

`ifndef SHOULD_NOT_NEED_THIS
    // wr_tick1 ALWAYS raises with falling edge T2.  CPU A and D busses are stable by then
    always @(posedge wr_tick1) begin
        aout_reg <= ain1;
        dout_reg <= din1;
    end
`else
    // D (transparent) latches used to ensure that the setup and hold times on 
    // dout and aout are long enough for wr_tick2.
    // nextpnr does not like this
    // get around it's loop failure with:
    //      NEXTPNR_OPT+=--ignore-loops 
    always @(*) begin
        if ( wr_tick1 ) begin
            aout_reg <= ain1;
            dout_reg <= din1;
        end
    end
`endif

    // stretcher used to cross the clock domain
    sync_stretch #(
        .STRETCH_BITS(1),
        .SYNC_LEN(2)
    ) ss (
        .reset(reset),
        .clk1(clk1),
        .clk2(clk2),
        .in(wr_tick1),
        .out(wr_tick2)
    );

    assign dout2 = dout_reg;
    assign aout2 = aout_reg;

endmodule
