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

/*
* Due to limited resources on the ICE40HX, the VRAM size is limited to 8K.
*
* To write into the VRAM:
* 1) write address LSB with mode=1 
* 2) write address MSB as 0b01xxxxxx with mode=1
* 3) write N data bytes with mode=0
*
* To read from VRAM:
* 1) write address LSB with mode=1
* 2) write address MSB as 0x00xxxxxx with mode=1
* 3) read N data bytes with mode=0
*
***************************************************************************/


`default_nettype none

module vram #(
    parameter VRAM_SIZE = 8192
    ) (
    input wire          reset,
    input wire          clk,
    input wire          rd_tick,
    input wire          wr_tick,
    input wire          mode,           // 1=addr setup, 0=data xfer
    input wire [7:0]    din,
    output wire [7:0]   dout
    );

    reg [$clog2(VRAM_SIZE)-1:0] addr_reg, addr_next;    // vram address counter for read/write xfers
    reg                         addr_state_reg, addr_state_next;
    reg [7:0]                   dout_reg;

    reg [7:0]                   vram[0:VRAM_SIZE-1];

    assign dout = dout_reg;

    always @(posedge clk) begin
        if (reset) begin
            addr_reg <= 0;
            addr_state_reg <= 0;
        end else begin
            addr_reg <= addr_next;
            addr_state_reg <= addr_state_next;
        end
    end

    always @(posedge clk) begin
        dout_reg <= vram[addr_reg];
        if ( wr_tick & mode==0 )
            vram[addr_reg] <= din;      // only write when requested
    end

    always @(*) begin
        addr_state_next = addr_state_reg;
        addr_next = addr_reg;
        addr_state_next = addr_state_reg;

        if ((wr_tick || rd_tick) && mode==0) begin
            addr_next = addr_reg+1;
        end

        case (addr_state_reg)
        0:
            begin
                if (wr_tick && mode==1) begin
                    addr_next = { addr_reg[$clog2(VRAM_SIZE)-1:8], din };
                    addr_state_next = 1;
                end
            end
        1:
            begin
                if (wr_tick && mode==1) begin
                    addr_next = { din, addr_reg[7:0] }; // the MSBs will be truncated
                    addr_state_next = 0;
                end
            end
        endcase
    end

endmodule
