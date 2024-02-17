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

// A simple ROM with an endless loop in it.

module boot_rom (
    input wire [3:0]    addr,
    output wire [7:0]   data
    );

    always @(*)
        case (addr)
        9'h00:  data = 8'h00;       // NOP 
        9'h01:  data = 8'h00;       // NOP
        9'h02:  data = 8'h00;       // NOP
        9'h03:  data = 8'h00;       // NOP
        9'h04:  data = 8'hc3;       // JMP
        9'h05:  data = 8'h00;       // (LSB target address) 0
        9'h06:  data = 8'h00;       // (MSB target address) 0
        default:
                data = 0;
        endcase

endmodule
