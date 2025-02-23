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

// a color palette for mapping the TI99 colors to a 6-bit RGB dac

module color_palette (
    input wire [3:0]    color,
    output reg [1:0]   red,         // these are reg because I am lazy
    output reg [1:0]   grn,
    output reg [1:0]   blu
    );

    always @(*) begin
        case(color)
        4'h0: begin     // black
            red = 0;
            grn = 0;
            blu = 0;
        end
        4'h1: begin     // black
            red = 0;
            grn = 0;
            blu = 0;
        end
        4'h2: begin     // mid grn
            red = 0;
            grn = 2;
            blu = 0;
        end
        4'h3: begin     // lt grn
            red = 0;
            grn = 3;
            blu = 0;
        end
        4'h4: begin     // drk blu
            red = 0;
            grn = 0;
            blu = 1;
        end
        4'h5: begin     // lt blu
            red = 0;
            grn = 0;
            blu = 3;
        end
        4'h6: begin     // drk red
            red = 1;
            grn = 0;
            blu = 0;
        end
        4'h7: begin     // cyan
            red = 0;
            grn = 3;
            blu = 3;
        end
        4'h8: begin     // med red
            red = 2;
            grn = 0;
            blu = 0;
        end
        4'h9: begin     // lt red
            red = 3;
            grn = 0;
            blu = 0;
        end
        4'ha: begin     // drk yel
            red = 1;
            grn = 1;
            blu = 0;
        end
        4'hb: begin     // lt yel
            red = 3;
            grn = 3;
            blu = 0;
        end
        4'hc: begin     // drk grn
            red = 0;
            grn = 1;
            blu = 0;
        end
        4'hd: begin     // magenta
            red = 3;
            grn = 0;
            blu = 3;
        end
        4'he: begin     // gry
            red = 1;
            grn = 1;
            blu = 1;
        end
        4'hf: begin     // wht
            red = 3;
            grn = 3;
            blu = 3;
        end
        endcase
    end

endmodule

