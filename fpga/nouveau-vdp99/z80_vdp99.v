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


// The purpose of this module is to connect the CPU clock domain to the VDP clock domain.

`default_nettype none

module z80_vdp99 #(
    parameter VRAM_SIZE = 8*1024
    ) (
    input wire          reset,
    input wire          phi,            // the z80 PHI clock
    input wire          pxclk,          // the pixel clock

    input wire          cpu_mode,       // address valid during cpu_rd/wr_tick
    input wire [7:0]    cpu_din,        // valid during cpu_wr
    output wire [7:0]   cpu_dout,       // must be valid during cpu_rd

    input wire          cpu_wr,         // async CPU signal
    input wire          cpu_rd,         // async CPU signal
    
    output wire [3:0]   color,
    output wire         hsync,
    output wire         vsync,
    output wire         irq             // Note: The IRQ is an async signal in the CPU domain
    );

    localparam SYN_LEN = 3;             // too long for worst case write timing
    //localparam SYN_LEN = 2;           // not safe from metastability

    // As long as pxclk is fast enough, we can just sync the CPU rd & wr signals 
    // and use the A and D busses without synchronizing them.
    reg [SYN_LEN-1:0]   vdp_wr_sync;
    always @(posedge pxclk)
        vdp_wr_sync <= {cpu_wr, vdp_wr_sync[SYN_LEN-1:1]};

    reg [SYN_LEN-1:0]   vdp_rd_sync;
    always @(posedge pxclk)
        vdp_rd_sync <= {cpu_rd, vdp_rd_sync[SYN_LEN-1:1]};

    wire    vdp_wr_tick = vdp_wr_sync[1:0] == 2'b10;        // pxclk domain
    wire    vdp_rd_tick = vdp_rd_sync[1:0] == 2'b10;        // pxclk domain
    wire    vdp_mode_tick = vdp_wr_tick|vdp_rd_tick;

    // stretch the CPU address and data bus values for worst-case write timing.
    // note that the edge used here is a gated clock to latch one pxclk period before vdp_wr_tick falls
    reg [7:0]   vdp_din;
    always @(posedge vdp_wr_tick)
        vdp_din <= cpu_din;

    reg         vdp_mode;
    always @(posedge vdp_mode_tick)
        vdp_mode <= cpu_mode;

    // stretch the data bus values when reading
    // note that the cpu asserts RD sooner than WR on IORQ cycles 
    wire [7:0] vdp_dout;
    reg [7:0] cpu_dout_reg;
    //always @(posedge pxclk)
    always @(negedge pxclk)         // buy us another 25ns setup on dout
        if ( vdp_rd_tick )
            cpu_dout_reg <= vdp_dout;

    assign cpu_dout = cpu_dout_reg;

    // Connect the pxclk synchronized CPU bus to the VDP
    vdp99 #( .VRAM_SIZE(VRAM_SIZE) ) vdp (
        .reset(reset),
        .pxclk(pxclk),
        .wr_tick(vdp_wr_tick),
        .rd_tick(vdp_rd_tick),
        .mode(vdp_mode),
        .din(vdp_din),
        .dout(vdp_dout),
        .irq(irq),
        .color(color),
        .hsync(hsync),
        .vsync(vsync)
    );

 
endmodule
