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

`timescale 1ns/1ns
`default_nettype none

module ay_env (
    input wire          reset,
    input wire          clk,
    input wire          env_clk_tick,   // %256 tick clock
    input wire          shape_tick,     // true if shape has changed
    input wire [3:0]    shape,          // cont, attack, alt, hold
    input wire [15:0]   period,
    output wire [3:0]   out
    );

    reg [15:0]  period_ctr_reg, period_ctr_next;    // counts from 0..65535
    reg [3:0]   amp_reg, amp_next;
    reg [3:0]   out_reg, out_next;
    reg         flip_reg, flip_next;                // true = count down, else up
    reg         run_reg, run_next;

    always @( posedge clk ) begin
        if (reset) begin
            period_ctr_reg <= 0;
            flip_reg <= 0;
            amp_reg <= 0;
            out_reg <= 0;
            run_reg <= 1;
        end else begin
            period_ctr_reg <= period_ctr_next;
            flip_reg <= flip_next;
            amp_reg <= amp_next;
            out_reg <= out_next;
            run_reg <= run_next;
        end
    end

    wire cont = shape[3];
    wire attack = shape[2];
    wire alt = shape[1];
    wire hold = shape[0];

    // Generate a linear 4-bit amplitude value.
    always @(*) begin
        period_ctr_next = period_ctr_reg;
        amp_next = amp_reg;
        flip_next = flip_reg;
        run_next = run_reg;
        out_next = out_reg;

        if ( shape_tick ) begin
            amp_next = 0;                   // restart the amplitude ramp
            flip_next = ~attack;
            run_next = 1;
            period_ctr_next = 0;
        end else if ( env_clk_tick ) begin
            if ( period_ctr_reg+1 == period ) begin
                period_ctr_next = 0;
                if ( amp_reg == 15 ) begin
                    if ( !cont ) begin
                        flip_next = 1;
                        run_next = 0;
                    end else begin
                        run_next = ~hold;
                        if ( alt )
                            flip_next = ~flip_reg;
                        if ( !hold )
                            amp_next = 0;
                    end
                end else begin
                    amp_next = amp_reg+1;
                end
            end else begin
                if ( run_reg )
                    period_ctr_next = period_ctr_reg+1;
            end
            out_next = flip_reg ? ~amp_reg : amp_reg;
        end
    end

    assign out = out_reg;

endmodule
