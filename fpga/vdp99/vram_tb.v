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

    reg clk             = 0;        // pixel clock
    reg reset           = 0;
    reg wr_tick         = 0;
    reg rd_tick         = 0;
    reg mode            = 0;
    reg [7:0] din       = 'hz;
    reg [VRAM_ADDR_WIDTH-1:0] dma_addr = 'hx;
    reg dma_tick        = 0;

    wire [7:0] dout;

    vram #( .VRAM_SIZE(VRAM_SIZE) ) uut (
        .reset(reset),
        .clk(clk),
        .rd_tick(rd_tick),
        .wr_tick(wr_tick),
        .mode(mode),
        .din(din),
        .dout(dout),
        .dma_addr(dma_addr),
        .dma_rd_tick(dma_tick)
    );

    initial begin
        $dumpfile("vram_tb.vcd");
        $dumpvars;
    end
    
    localparam clk_period = (1.0/25000000)*1000000000; // clk is running at 25MHZ
    always #(clk_period/2) clk = ~clk;

    integer i;
    integer j;

    initial begin

        #(clk_period*4);
        reset <= 1;
        #(clk_period*4);
        reset <= 0;
        #(clk_period*4);

        @(posedge clk);
        mode <= 1;          // mode 1 = address
        din <= 8'h00;       // address LSB
        wr_tick <= 1;

        @(posedge clk);
        mode <= 0;
        din <= 'hz;
        wr_tick <= 0;

        @(posedge clk);
        mode <= 1;          // mode 1 = address
        din <= 8'h40;       // address MSB (write mode)
        wr_tick <= 1;

        @(posedge clk);
        mode <= 0;
        din <= 'hz;
        wr_tick <= 0;


        // fill the VRAM with some data
        // note that while filling the first time, the read data is 'hx
        for ( i=0; i<'h2000; i=i+1 ) begin
            @(posedge clk);
            mode <= 0;      // mode 0 = data
            din <= i&'h0ff;
            wr_tick <= 1;

            @(posedge clk);
            mode <= 0;
            din <= 'hz;
            wr_tick <= 0;

            @(posedge clk);
        end

        // read it back
        mode <= 1;          // mode 1 = address
        din <= 8'h00;       // address LSB
        wr_tick <= 1;

        @(posedge clk);
        mode <= 1;          // mode 1 = address
        din <= 8'h10;       // address MSB (read mode)  -- read out of phase for fun
        wr_tick <= 1;

        @(posedge clk);
        mode <= 0;          // mode 0 = data
        din <= 'hz;         // address MSB (read mode)
        wr_tick <= 0;

        for ( i=0; i<'h2000; i=i+1 ) begin
//$display( "%8t vram[%4x]:%x", $time, i+'h20f, uut.vram[i+'h20f] );
            @(posedge clk);
            mode <= 0;      // mode 0 = data
            rd_tick <= 1;

            @(posedge clk);
            mode <= 0;
            rd_tick <= 0;

            if ( dout != (i&'h0ff) )
                $display( "memory readback failed: %8t vram[%4x]:%x", $time, i, uut.vram[i] );

            @(posedge clk);
        end

        @(posedge clk);
        mode <= 0;
        din <= 'hz;
        wr_tick <= 0;
        rd_tick <= 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);




        // make sure that reading the status register will reset the register fsm
        
        // start setting up a new VRAM address
        mode <= 1;          // mode 1 = address
        din <= 8'h99;       // address LSB 
        wr_tick <= 1;
        rd_tick <= 0;

        @(posedge clk);
        // now abort the vram address setup by reading the status register
        mode <= 1;
        wr_tick <= 0;
        rd_tick <= 1;

        @(posedge clk);
        rd_tick <= 0;
        wr_tick <= 0;

        @(posedge clk);
        // now restart the vram address setting
        mode <= 1;          // mode 1 = address
        din <= 8'h11;       // address LSB 
        wr_tick <= 1;

        @(posedge clk);
        mode <= 1;          // mode 1 = address
        din <= 8'h33;       // address MSB (read mode)
        wr_tick <= 1;

        @(posedge clk);
        rd_tick <= 0;
        wr_tick <= 0;
        mode <= 0;
        din <= 'hz;
        
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        mode <= 0;
        rd_tick <= 1;       // read 1 vram byte

        @(posedge clk);
        mode <= 0;
        rd_tick <= 0;

        @(posedge clk);
        mode <= 0;
        rd_tick <= 1;       // read a second vram byte

        @(posedge clk);
        mode <= 0;
        rd_tick <= 0;




        // DMA access tests
        @(posedge clk);
        mode <= 0;
        rd_tick <= 0;
        wr_tick <= 0;


        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        dma_addr <= 'h1100;
        dma_tick <= 1;

        @(posedge clk);
        dma_addr <= 'h1101;
        dma_tick <= 1;
        @(posedge clk);
        dma_addr <= 'h1102;
        dma_tick <= 1;

//        @(posedge clk);
//        dma_addr <= 0;
//        dma_tick <= 0;


        @(posedge clk);
        dma_addr <= 'hx;
        dma_tick <= 0;
        mode <= 0;
        rd_tick <= 1;       // read vram using the CPU interface
        @(posedge clk);
        mode <= 0;
        rd_tick <= 1;       // and another...
        @(posedge clk);
        mode <= 0;
        rd_tick <= 0;
        dma_addr <= 'h1103;
        dma_tick <= 1;




        @(posedge clk);
        mode <= 0;
        rd_tick <= 0;
        wr_tick <= 0;
        dma_tick <= 0;
        dma_addr <= 'hx;
        din <= 'hz;

        #(clk_period*20);
        $finish;
    end

endmodule
