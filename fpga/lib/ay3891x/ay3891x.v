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

// A quick hack at making a basic sound generator.
// This implements an AY-3-891x style register interface.
// Only the tone and noise generators are implemented. 

module ay3891x #(
    parameter CLK_FREQ = 25000000       // freq of clk
    ) (
    input wire          reset,
    input wire          clk,
    input wire          a0,             // 0=addr latch, 1=data transfer 
    input wire          wr_tick,        // a write tick in the clk domain
    input wire [7:0]    wdata,          // data must be stable during wr_tick
    input wire          rd_tick,        // a write tick in the clk2 domain when dout is valid
    output wire [7:0]   rdata,          // data will be valid during the period following rd_tick
    output wire [2:0]   aout            // analog(ish) out channels
    );

    localparam AY_CLK_FREQ = 1789773;

    wire        clk16;                  // 1.789773/16 MHZ clock
    wire        clk256;                 // 1.789773/256 MHZ clock
    wire        shape_tick;             // true after the envelop shape r13 has been written
    wire [7:0]  r0;                     // fine tune A
    wire [7:0]  r1;                     // course tune A
    wire [7:0]  r2;                     // fine B
    wire [7:0]  r3;                     // course B
    wire [7:0]  r4;                     // fine C
    wire [7:0]  r5;                     // course C
    wire [7:0]  r6;                     // noise period
    wire [7:0]  r7;                     // enablage
    wire [7:0]  r8;                     // A amplitude
    wire [7:0]  r9;                     // B amplitude
    wire [7:0]  r10;                    // C amplitude
    wire [7:0]  r11;                    // Envelope fine
    wire [7:0]  r12;                    // Envelope course
    wire [7:0]  r13;                    // Envelope shape

    wire        noise_out;              // noise bit stream
    wire        tonea_out;
    wire        toneb_out;
    wire        tonec_out;

    wire        muxa_out;
    wire        muxb_out;
    wire        muxc_out;

    wire        adca_out;
    wire        adcb_out;
    wire        adcc_out;

    prescaler #(
        .IN_FREQ(CLK_FREQ*16),
        .OUT_FREQ(AY_CLK_FREQ)
    ) ay_prescaler16 (
        .reset(reset),
        .clk(clk),
        .out_tick(clk16)
    );
    prescaler #(
        .IN_FREQ(CLK_FREQ*256),
        .OUT_FREQ(AY_CLK_FREQ)
    ) ay_prescaler256 (
        .reset(reset),
        .clk(clk),
        .out_tick(clk256)
    );

    ay_regs regs (
        .reset(reset),
        .clk(clk),
        .a0(a0),
        .wr_tick(wr_tick),
        .wdata(wdata),
        .rd_tick(rd_tick),
        .rdata(rdata),
        .shape_tick(shape_tick),
        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .r4(r4),
        .r5(r5),
        .r6(r6),
        .r7(r7),
        .r8(r8),
        .r9(r9),
        .r10(r10),
        .r11(r11),
        .r12(r12),
        .r13(r13)
    );

    ay_noise noise (
        .reset(reset),
        .clk(clk),
        .ay_clk(clk16),
        .period(r6[4:0]),
        .out(noise_out)
    );

    ay_tone tonea (
        .reset(reset),
        .clk(clk),
        .ay_clk(clk16),
        .period( { r1[3:0], r0 } ),
        .out(tonea_out)
    );
    ay_tone toneb (
        .reset(reset),
        .clk(clk),
        .ay_clk(clk16),
        .period( { r3[3:0], r2 } ),
        .out(toneb_out)
    );
    ay_tone tonec (
        .reset(reset),
        .clk(clk),
        .ay_clk(clk16),
        .period( { r5[3:0], r4 } ),
        .out(tonec_out)
    );

    ay_mux muxa (
        .reset(reset),
        .clk(clk),
        .tone(tonea_out),
        .noise(noise_out),
        .enable_tone(r7[0]),
        .enable_noise(r7[3]),
        .out(muxa_out)
    );
    ay_mux muxb (
        .reset(reset),
        .clk(clk),
        .tone(toneb_out),
        .noise(noise_out),
        .enable_tone(r7[1]),
        .enable_noise(r7[4]),
        .out(muxb_out)
    );
    ay_mux muxc (
        .reset(reset),
        .clk(clk),
        .tone(tonec_out),
        .noise(noise_out),
        .enable_tone(r7[2]),
        .enable_noise(r7[5]),
        .out(muxc_out)
    );


    // envelope generator
    wire [3:0] env_amp;
    ay_env env (
        .reset(reset),
        .clk(clk),
        .env_clk_tick(clk256),           // %256 tick clock
        .shape_tick(shape_tick),
        .shape(r13[3:0]),
        .period( { r11, r12 } ),
        .out(env_amp)
    );


    // amplitude controlers
    ay_adc adca (
        .reset(reset|~muxa_out),        // reset when wave is low so not cause pulse-crawl
        .clk(clk),
        .amp(r8[4] ? env_amp : r8[3:0]),
        .in(muxa_out),
        .out(adca_out)
    );
    ay_adc adcb (
        .reset(reset|~muxb_out),
        .clk(clk),
        .amp(r9[4] ? env_amp : r9[3:0]),
        .in(muxb_out),
        .out(adcb_out)
    );
    ay_adc adcc (
        .reset(reset|~muxc_out),
        .clk(clk),
        .amp(r10[4] ? env_amp : r10[3:0]),
        .in(muxc_out),
        .out(adcc_out)
    );

    assign aout = { adcc_out, adcb_out, adca_out };

endmodule
