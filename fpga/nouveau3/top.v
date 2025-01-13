//**************************************************************************
//
//    Copyright (C) 2024,2025  John Winans
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
    input wire          hwclk,      // 25MHZ oscillator
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
    assign tp = { iorq_tick, phi, e, iorq_n, we_n, oe_n, ce_n, wr_n, rd_n, mreq_n, m1_n };
    //            90         87   84 82      80    78    75    73    63    61      56

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

    reg rom_sel;                    // true when the boot ROM is accessible
    always @(posedge phi)
        if ( ~reset_n )
            rom_sel <= 1;           // after a hard reset, the boot ROM is enabled...
        else if ( ioreq_rd_fe )     // until there is a read from IO port 0xfe
            rom_sel <= 0;               

    // Determine if the FPGA will drive the data bus and with what
    always @(*) begin
        dbus_out = 0;
        dout = 8'bx;
        if ( mreq_rom ) begin           // CPU is reading the boot ROM
            dout = rom_data;
            dbus_out = 1;
        end else if (ioreq_rd_f0) begin // CPU is reading the boot ROM latch reset
            dout = ioreq_rd_f0_data;
            dbus_out = 1;
        end else if (mreq_bram_rd) begin // CPU is reading from the test memory
            dout = bram_mem_rd_data;
            dbus_out = 1;
        end
    end

    // Consider integrating the output locked into a future automatic power-up reset timer.
    // 18.432MHZ = 57600 (when running at X/2)
    // 18.432MHZ = 115200 (when running at X/1)
    pll_25_18432 pll ( .clock_in(hwclk), .clock_out(extal) ); 

    // addres decoders for the memory, IO ports and shadow boot-ROM reset port
    wire ioreq_rd_f0 = iorq_tick && ~rd_n && (a[7:0] == 8'hf0); // gpio input
    wire ioreq_wr_f1 = iorq_tick && ~wr_n && (a[7:0] == 8'hf1); // gpio output
    wire ioreq_rd_fe = iorq_tick && ~rd_n && (a[7:0] == 8'hfe); // flash select disable access port

    // the VDP is at address 0x80-0x81
    wire ioreq_rd_vdp = iorq_tick && ~rd_n && (a[7:1] == 7'b1000000);
    wire ioreq_wr_vdp = iorq_tick && ~wr_n && (a[7:1] == 7'b1000000); 

    wire ioreq_rd_j3 = iorq_tick && ~rd_n && (a[7:0] == 8'ha8);         // joystick J3 read-only
    wire ioreq_rd_j4 = iorq_tick && ~rd_n && (a[7:0] == 8'ha9);         // joystick J4 read-only

    wire mreq_rom = rom_sel && ~mreq_n && ~rd_n && a < RAM_START;

    // The GPIO output latch
    reg [7:0] gpio_out;
    always @(negedge ioreq_wr_f1)
        gpio_out <= d;

    wire [7:0] ioreq_rd_f0_data = {sd_miso,sd_det,6'bx};  // data value when reading port F0

    // We can use this to synchronize iorq_n to the phi clock to create a one phi period
    // wide enable "tick" signal during an IO read or write operation.
    // Note that including ~rd_n & ~wr_n eliminates an iorq_n during interrupt acknowledge.
    // with IOC=1 this will read on tw & write on t3

    //wire iorq_sync_gate = m1_n && ~iorq_n;       // during INT ACK iorq_n rises after m1_n & false-trigger?
    //wire iorq_sync_gate = ~iorq_n && (~rd_n || ~wr_n);    // can overrun into next t1 after internal IO
    wire iorq_sync_gate = ~iorq_n && (~rd_n || ~wr_n) && (a[7:0] >= 8'h40); // only look at external addr range

    wire iorq_tick;
    iorq_fsm iorq_sync ( 
        .phi(phi), 
        .iorq(iorq_sync_gate),
        .iorq_tick(iorq_tick) 
        );

    //////////////////////////

    // some direct-mapped memory
    wire [10:0]  bram_raddr;
    wire [10:0]  bram_waddr;
    reg [7:0] bram_mem [0:511];

    wire mreq_bram_rd = (~mreq_n && ~rd_n && a[15:0] >= 16'h8000 && a[15:0] < 16'h8200);  // fpga memory test region
    wire mreq_bram_wr = (~mreq_n && ~wr_n && a[15:0] >= 16'h8000 && a[15:0] < 16'h8200);  // fpga memory test region
    reg [7:0] bram_mem_rd_data;

    always @(negedge phi) begin
        if ( mreq_bram_wr )
            bram_mem[a-'h8000] <= d;
        else if ( mreq_bram_rd ) begin
            bram_mem_rd_data <= bram_mem[a-'h8000];
            //bram_mem_rd_data <= a[7:0];      // XXX test hack
        end
    end

    //////////////////////////


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
