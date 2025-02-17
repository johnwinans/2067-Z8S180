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

module tb();

    localparam  VRAM_SIZE = 8192;
    localparam  VRAM_ADDR_WIDTH = $clog2(VRAM_SIZE);

    reg reset                       = 0;
    reg clk                         = 0;    // pixel clock
    reg [2:0] vdp_mode              = 1;
    reg [9:0] px_row                = 0;
    reg vdp_blank                   = 0;
    reg vdp_smag                    = 0;
    reg vdp_ssiz                    = 0;
    reg [2:0] vdp_pattern_base      = 'h00; // VRAM address 0x0000 - 0x07ff
    reg [3:0] vdp_name_base         = 'h02; // VRAM address 0x0800 - 0x0bff
    reg [7:0] vdp_color_base        = 'h30; // VRAM address 0x0c00 - 0x0c20
    reg [6:0] vdp_sprite_att_base   = 0;
    reg [2:0] vdp_sprite_pat_base   = 0;
    reg [3:0] vdp_fg_color          = 1;
    reg [3:0] vdp_bg_color          = 2;
    reg [7:0] vram_dout             = 'hx;

    wire [VRAM_ADDR_WIDTH-1:0] vdp_dma_addr;
    wire vdp_dma_rd_tick;
    wire [3:0] color;

    reg hsync                       = 0;
    reg vsync                       = 0;
    reg vid_active                  = 1;        // XXX 
    reg bdr_active                  = 0;
    reg last_pixel                  = 0;
    reg col_last                    = 0;
    reg row_last                    = 0;

    wire hsync_out;
    wire vsync_out;
    wire vid_active_out;
    wire bdr_active_out;
    wire last_pixel_out;
    wire col_last_out;
    wire row_last_out;

    vdp_fsm #( .VRAM_SIZE(VRAM_SIZE) ) uut
    (
        .reset(reset),
        .pxclk(clk),
//.px_col,
        .px_row(px_row),
        .vdp_mode(vdp_mode),
        .vdp_blank(vdp_blank),
        .vdp_smag(vdp_smag),
        .vdp_ssiz(vdp_ssiz),
        .vdp_name_base(vdp_name_base),
        .vdp_color_base(vdp_color_base),
        .vdp_pattern_base(vdp_pattern_base),
        .vdp_sprite_att_base(vdp_sprite_att_base),
        .vdp_sprite_pat_base(vdp_sprite_pat_base),
        .vdp_fg_color(vdp_fg_color),
        .vdp_bg_color(vdp_bg_color),
        .vdp_dma_addr(vdp_dma_addr),
        .vdp_dma_rd_tick(vdp_dma_rd_tick),
        .vram_dout(vram_dout),
        .hsync(hsync),
        .vsync(vsync),
        .vid_active(vid_active),
        .bdr_active(bdr_active),
        .last_pixel(last_pixel),
        .col_last(col_last),
        .row_last(row_last),
        .hsync_out(hsync_out),
        .vsync_out(vsync_out),
        .vid_active_out(vid_active_out),
        .bdr_active_out(bdr_active_out),
        .last_pixel_out(last_pixel_out),
        .col_last_out(col_last_out),
        .row_last_out(row_last_out),
        .color_out(color)
    );


`define ASSERT(cond) if ( !(cond) ) $display("%s:%0d %m time:%3t ASSERTION (cond) FAILED!", `__FILE__, `__LINE__, $time );


    initial begin
        $dumpfile("vdp_fsm_tb.vcd");
        $dumpvars;
    end
    
    localparam clk_period = (1.0/25000000)*1000000000; // clk is running at 25MHZ
    always #(clk_period/2) clk = ~clk;

    integer i;
    integer j;

    initial begin

`ASSERT( 0 === 1 );  // XXX this is stale and no longer works
$finish;

        #(clk_period*4);
        @(posedge clk);
        reset <= 1;
        #(clk_period*4);
        @(posedge clk);
        reset <= 0;

        // wait until we know we are ready to start a new tile cycle (this will skip tile #1)
        while ( uut.ring_ctr_reg !== 'h80 ) 
            @(posedge clk); 

        while ( uut.ring_ctr_reg !== 'h01 )
            @(posedge clk);

        vram_dout <= 'h81;          // the value from the name table for tile #2

        @(posedge clk); // uut.ring_ctr_reg 0x02
        
       `ASSERT( uut.ring_ctr_reg === 'h02 );
       `ASSERT( vdp_dma_addr === 'h0801 );
       `ASSERT( vdp_dma_rd_tick === 1 );

        vram_dout <= 'hz;


        @(posedge clk); // uut.ring_ctr_reg 0x04

        // CPU cycle
        `ASSERT( uut.ring_ctr_reg === 'h04 );
        `ASSERT( vdp_dma_rd_tick === 0 );
        `ASSERT( uut.name_reg === 'h81 );

        vram_dout <= 'h85;                  // pattern value


        @(posedge clk); // uut.ring_ctr_reg 0x08


        `ASSERT( uut.ring_ctr_reg === 'h08 );
        vram_dout <= 'h34;                  // the value from the color table


        @(posedge clk); // uut.ring_ctr_reg 0x10
        `ASSERT( uut.ring_ctr_reg === 'h10 );

        vram_dout <= 'hz;


        @(posedge clk); // uut.ring_ctr_reg 0x20
        `ASSERT( uut.ring_ctr_reg === 'h20 );
        @(posedge clk); // uut.ring_ctr_reg 0x40
        `ASSERT( uut.ring_ctr_reg === 'h40 );
        @(posedge clk); // uut.ring_ctr_reg 0x80
        `ASSERT( uut.ring_ctr_reg === 'h80 );






        @(posedge clk); // uut.ring_ctr_reg 0x80
        `ASSERT( uut.ring_ctr_reg === 'h1 );

        vram_dout <= 'h18;          // the value from the name table for tile #3

        @(posedge clk); // uut.ring_ctr_reg 0x02
        
       `ASSERT( uut.ring_ctr_reg === 'h02 );
       `ASSERT( vdp_dma_addr === 'h0802 );
       `ASSERT( vdp_dma_rd_tick === 1 );

        vram_dout <= 'hz;


        @(posedge clk); // uut.ring_ctr_reg 0x04

        // CPU cycle
        `ASSERT( uut.ring_ctr_reg === 'h04 );
        `ASSERT( vdp_dma_rd_tick === 0 );
        `ASSERT( uut.name_reg === 'h18 );

        vram_dout <= 'haa;                  // pattern value

        @(posedge clk); // uut.ring_ctr_reg 0x08


        `ASSERT( uut.ring_ctr_reg === 'h08 );
        vram_dout <= 'hf0;                  // the value from the color table


        @(posedge clk); // uut.ring_ctr_reg 0x10
        `ASSERT( uut.ring_ctr_reg === 'h10 );

        vram_dout <= 'hz;


        @(posedge clk); // uut.ring_ctr_reg 0x20
        `ASSERT( uut.ring_ctr_reg === 'h20 );
        @(posedge clk); // uut.ring_ctr_reg 0x40
        `ASSERT( uut.ring_ctr_reg === 'h40 );
        @(posedge clk); // uut.ring_ctr_reg 0x80
        `ASSERT( uut.ring_ctr_reg === 'h80 );





        while ( uut.ring_ctr_reg != 'h01 )
            @(posedge clk);

        #(clk_period*40);
        $finish;
    end

endmodule
