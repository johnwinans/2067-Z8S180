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
* Due to limited resources on the ICE40HX, the VRAM size may be limited to 8K.
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
* Note: dma_rd_tick takes precedence over rd_tick.  It is assumed that
*       coordinating these signals is a task for a higher level. 
***************************************************************************/

`timescale 1ns/1ns
`default_nettype none

module vram #(
    parameter VRAM_SIZE = 8192
    ) (
    input wire                          reset,
    input wire                          clk,            // VDP clock (25MHZ)
    input wire                          rd_tick,        // CPU read in VDP clock domain 
    input wire                          wr_tick,        // CPU write in VDP clock domain 
    input wire                          mode,           // 1=addr setup, 0=data xfer
    input wire [$clog2(VRAM_SIZE)-1:0]  dma_addr,       // used to indicate a direct memory access read
    input wire                          dma_rd_tick,    // true when want to read from address dma_addr
    input wire [7:0]                    din,            // data from CPU or FSM
    output wire [7:0]                   dout            // data from the VRAM
    );

    reg [$clog2(VRAM_SIZE)-1:0] addr_reg, addr_next;    // vram address counter for read/write xfers
    reg [7:0]                   addr_tmp_reg, addr_tmp_next;
    reg                         addr_state_reg, addr_state_next;
    reg [7:0]                   dout_reg;

    reg [7:0]                   vram[0:VRAM_SIZE-1];    // this is the actual VRAM memory

    assign dout = dout_reg;

    always @(posedge clk) begin
        if (reset) begin
            addr_reg <= 0;
//            addr_reg <= 'hxx;     // test hack (as seen on YouTube)
            addr_tmp_reg <= 0;
            addr_state_reg <= 0;
        end else begin
            addr_reg <= addr_next;
            addr_tmp_reg <= addr_tmp_next;
            addr_state_reg <= addr_state_next;
        end
    end

    always @(posedge clk) begin
        dout_reg <= vram[dma_rd_tick ? dma_addr : addr_reg];
        if ( wr_tick & mode==0 )
            vram[addr_reg] <= din;      // only write when requested
    end

    // If we reset the addr_state_reg when reading the status register, bad things could happen.
    // But if we don't then it could be impossible to correct a phase error.  :-/
    always @(*) begin
        addr_state_next = addr_state_reg;
        addr_next = addr_reg;
        addr_tmp_next = addr_tmp_reg;

        if ((wr_tick || rd_tick) && mode==0) begin
            addr_next = addr_reg+1;
        end

        if ( rd_tick && mode==1 ) begin
            addr_state_next = 0;        // reset the address reg state when read the status register
        end else begin
            case (addr_state_reg)
            0:  // we are waiting to receive a mode 1 write with the Setup Address LSB
                begin
                    if (wr_tick && mode==1) begin
                        addr_tmp_next = din;
                        addr_state_next = 1;
                    end
                end
            1:  // we are waiting to receive a mode 1 write with the Setup Address MSB
                begin
                    if (wr_tick && mode==1) begin
                        addr_state_next = 0;
                        if ( din[7] == 0 )
                            addr_next = { din[5:0], addr_tmp_reg };     // MSB will be truncated
                    end
                end
            endcase
        end
    end

endmodule
