//**************************************************************************
//
//    Copyright (C) 2024  John Winans
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

// There is some talk about initialized sysMEM blocks on the ICE40 taking time 
// after the chip boots before it can be reliably read.  The accepted solution
// is to include a counter to wait as the chip comes out of reset.

module memory #(
    parameter VRAM_SIZE = 4096
    ) (
    input                               rd_clk,
    input wire [$clog2(VRAM_SIZE)-1:0]  addr,
    output reg [7:0]                    data
    );

    reg [7:0] mem [0:VRAM_SIZE-1];

    initial begin
        $readmemh("rom.hex", mem);
    end

    // if this /not/ edge-triggered then Yosys will /not/ infer a sysMEM block
    always @(posedge rd_clk)
        data <= mem[addr];

endmodule
