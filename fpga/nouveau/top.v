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

module top (
    input wire          hwclk,
    input wire          s1_n,
    output wire [7:0]   led,

    input wire [19:0]   a,
    inout wire [7:0]    d,          // bidirectional

    input wire          busack_n,
    output wire         busreq_n,

    output wire         ce_n,
    output wire         oe_n,
    output wire         we_n,

    output wire         dreq1_n,

    input wire          e,
    output wire         extal,
    input wire          phi,

    input wire          halt_n,

    output wire [2:0]   int_n,
    output wire         nmi_n,

    input wire          rd_n,
    input wire          wr_n,
    input wire          iorq_n,
    input wire          mreq_n,
    input wire          m1_n,

    output wire         reset_n,
    input wire          rfsh_n,
    input wire          st,
    input wire          tend1_n,
    output wire         wait_n,

    output wire         sd_mosi,
    output wire         sd_clk,
    output wire         sd_ssel_n,

    input wire          sd_miso,
    input wire          sd_det,

    output wire [15:0]  tp          // handy-dandy test-point outputs
 
    );
 
    localparam RAM_START = 20'h1000;

    // note that the test points here are different from the previous test proggies
    assign tp = { we_n, oe_n, ce_n, wr_n, rd_n, mreq_n, m1_n };

    wire [7:0]  rom_data;       // ROM output data bus

    // Instantiate the boot ROM
    //memory rom ( .rd_clk(hwclk), .addr(a[11:0]), .data(rom_data));
    memory rom ( .rd_clk(phi), .addr(a[11:0]), .data(rom_data));

    assign reset_n = s1_n;      // route the reset signal to the CPU

    // When the CPU is reading from the low 4K bytes, send it data 
    // from ROM, else tri-state the bus.
    reg [7:0] dout;
    reg dbus_out;      // 1 if the FPGA is outputting to the data bus
    assign d = dbus_out ? dout : 8'bz;

    reg rom_sel;
    always @(posedge phi)
        if ( ~reset_n )
            rom_sel <= 1;
        else if ( ioreq_rd_fe )
            rom_sel <= 0;

    always @(*) begin
        dbus_out = 0;
        dout = 8'bx;
        if (rom_sel && ~mreq_n && ~rd_n && a < RAM_START) begin
            dout = rom_data;
            dbus_out = 1;
        end else if (ioreq_rd_f0) begin
            dout = {sd_miso,sd_det,6'bx};
            dbus_out = 1;
        end
    end

    // Use a counter to divide the clock speed down
    localparam CLK_BITS = 1;        // set to 1 for 25/2 = 12.5MHZ
    reg [CLK_BITS-1:0]     ctr;
    always @(posedge hwclk) begin
        ctr <= ctr + 1;
    end

    // select an extal clock for the CPU (note this can/will impact the ASCI bit rate)!
    // at the time of this writing:
    //      12.5MHZ = 19531 (close enough to pass for 19200)
    //      25MHZ   = 39062 (close enough to pass for 38400)

    assign extal = ctr[CLK_BITS-1];     // Use the ctr to divide hwclk down
    //assign extal = hwclk;               // Run at the full 25MHZ (might be overclocking the CPU)

    // decoders for the GPIO ports and shadow boot-ROM reset
    wire ioreq_rd_f0;       // gpio input
    wire ioreq_wr_f1;       // gpio output
    wire ioreq_rd_fe;       // flash select disable access port
    assign ioreq_rd_f0 = ((m1_n & ~iorq_n & ~rd_n) && (a[7:0] == 8'hf0)) ? 1'b1 : 1'b0;
    assign ioreq_wr_f1 = ((m1_n & ~iorq_n & ~wr_n) && (a[7:0] == 8'hf1)) ? 1'b1 : 1'b0;
    assign ioreq_rd_fe = ((m1_n & ~iorq_n & ~rd_n) && (a[7:0] == 8'hfe)) ? 1'b1 : 1'b0;

    // The GPIO output latch
    reg [7:0] gpio_out;
    always @(negedge ioreq_wr_f1)
        gpio_out <= d;

    // show some signals from the GPIO ports on the LEDs for reference
    assign led = {~sd_miso,sd_det,3'b111,~gpio_out[2:0]};          // display the current GPIO out port value

    assign sd_mosi = gpio_out[0];   // connect the GPIO output bits to the SD card pins
    assign sd_clk  = gpio_out[1];
    assign sd_ssel_n = gpio_out[2];

    assign busreq_n = 1'b1;     // de-assert /BUSREQ
    assign dreq1_n = 1'b1;      // de-assert /DREQ1
    assign int_n = 3'b111;      // de-assert /INT0 /INT1 /INT2
    assign nmi_n = 1'b1;        // de-assert /NMI
    assign wait_n = 1'b1;       // de-assert /WAIT

    // Enable the static RAM on memory cycles when the data bus is driven by the FPGA
    // The address range that is used to enable the SRAM varies depending on if/when 
    // the shadow ROM is being enabled.
    assign ce_n = ~(~mreq_n && ~dbus_out );
    assign oe_n = mreq_n | rd_n;
    assign we_n = mreq_n | wr_n;

endmodule
