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

module ay_adc (
    input wire          reset,
    input wire          clk,
    input wire [3:0]    amp,            // the desired signal amplitude
    input wire          in,             // the input signal
    output wire         out             // the PWM modulated output signal
    );

    reg [9:0]   log_amp;
    wire        pwm_out;

    pwm #(
            .MAX_PERIOD(1000)
        ) dac (
            .reset(reset),
            .clk(clk),
            .period(log_amp),
            .out(pwm_out)
        );

    // a RMS voltage look-up table
    always @(*) begin
        case (amp)
            4'h0:   log_amp = 0;
            4'h1:   log_amp = 6;
            4'h2:   log_amp = 9;
            4'h3:   log_amp = 14;
            4'h4:   log_amp = 21;
            4'h5:   log_amp = 30;
            4'h6:   log_amp = 43;
            4'h7:   log_amp = 62;
            4'h8:   log_amp = 88;
            4'h9:   log_amp = 125;
            4'ha:   log_amp = 152;
            4'hb:   log_amp = 250;
            4'hc:   log_amp = 303;
            4'hd:   log_amp = 500;
            4'he:   log_amp = 707;
            4'hf:   log_amp = 1000;
        endcase
    end

    assign out = pwm_out & in;      // the in signal will gate the pwm output

endmodule
