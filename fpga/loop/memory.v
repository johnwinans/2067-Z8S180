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

module boot_loop (
    input wire [8:0]    addr,
    output reg [7:0]   data
    );

    always @(*)
        case (addr)
        9'h00:  data = 8'hc3;       // JMP 0x0000
        9'h01:  data = 8'h00;
        9'h02:  data = 8'h00;
        default:
            data = 0;
        endcase
endmodule

module boot_noref (
    input wire [8:0]    addr,
    output reg [7:0]   data
    );

    always @(*)
        case (addr)
        9'h00:  data = 8'h3e;       // LD A,0
        9'h01:  data = 8'h00;       // XXX this /should/ be done with an OUT0
        9'h02:  data = 8'hd3;       // OUT (0x36),A (shut off refresh)
        9'h03:  data = 8'h36;
        9'h04:  data = 8'hc3;       // JMP 0x0004
        9'h05:  data = 8'h04;
        9'h06:  data = 8'h00;
        default:
            data = 0;
        endcase
endmodule

module boot_noref_nowait (
    input wire [8:0]    addr,
    output reg [7:0]   data
    );

    always @(*)
        case (addr)
        9'h00:  data = 8'h3e;       // LD A,0
        9'h01:  data = 8'h00;
        9'h02:  data = 8'hd3;       // OUT (0x36),A (shut off refresh)
        9'h03:  data = 8'h36;
        9'h04:  data = 8'hd3;       // OUT (0x32),A (shut off wait-state generator)
        9'h05:  data = 8'h32;
        9'h06:  data = 8'hc3;       // JMP 0x0006
        9'h07:  data = 8'h06;
        9'h08:  data = 8'h00;
        default:
            data = 0;
        endcase
endmodule
