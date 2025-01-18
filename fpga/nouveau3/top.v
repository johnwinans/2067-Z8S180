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
    assign tp = { iorq_wr_tick, iorq_rd_tick, phi, e, iorq_n, we_n, oe_n, ce_n, wr_n, rd_n, mreq_n, m1_n };
    //            93            90            87   84 82      80    78    75    73    63    61      56

    wire [7:0]  rom_data;           // ROM output data bus
    memory rom ( .rd_clk(phi), .addr(a[11:0]), .data(rom_data));        // a boot ROM

    assign reset_n = s1_n;          // route the reset signal to the CPU (should debounce this)

    // When the CPU is reading from the FPGA drive the bus, else tri-state it.
    reg [7:0] dout;                 // what to write to data bus when requested
    reg dbus_out;                   // 1 if the FPGA shoudl drive the data bus
    assign d = dbus_out ? dout : 8'bz;  // a tri-state driver

    reg rom_sel;                    // true when the boot ROM is enabled
    always @(posedge phi)
        if ( ~reset_n )
            rom_sel <= 1;           // after a hard reset, the boot ROM is enabled...
        else if ( ioreq_rd_fe )     // until there is a read from IO port 0xfe
            rom_sel <= 0;

    // Determine if the FPGA will drive the data bus and with what
    always @(*) begin
/*
        // A priority encoder (the compiler doesn't know only 1 cond is true)
        dbus_out = 1;
        dout = 8'bx;
        if ( mreq_rom )
            dout = rom_data;            // CPU is reading the boot ROM
        else if (ioreq_rd_f0)
            dout = ioreq_rd_f0_data;    // CPU is reading the gpio input
        else
            dbus_out = 0;
*/
        dbus_out = 1;
        dout = 8'bx;

        (* parallel_case *)     // no more than one case can match (one-hot)
        case (1)
        mreq_rom:       dout = rom_data;            // CPU reading boot ROM memory
        ioreq_rd_f0:    dout = ioreq_rd_f0_data;    // CPU reading gpio input
        default:        dbus_out = 0;
        endcase
    end

    // Consider integrating the output locked into a future automatic power-up reset timer.
    // 18.432MHZ = 57600 (when running at X/2)
    // 18.432MHZ = 115200 (when running at X/1)
    pll_25_18432 pll ( .clock_in(hwclk), .clock_out(extal) );


    // for read cycle: latch value on first phi falling edge after iorq becomes true:
    // fsm counting falling phi when rd is true & enable when count = 0 && iorq is true
    wire    iorq_rd_tick;
    iorq_rd_fsm rd_fsm (.reset(~s1_n), .phi(phi), .iorq(~iorq_n), .rd(~rd_n), .rd_tick(iorq_rd_tick) );

    // for a write cycle: latch value on second phi falling edge after iorq becomes true:
    // fsm counting falling phi when wr is true and enable when count = 1
    wire    iorq_wr_tick;
    iorq_wr_fsm wr_fsm (.reset(~s1_n), .phi(phi), .iorq(~iorq_n), .wr(~wr_n), .wr_tick(iorq_wr_tick) );


    // qualified asynchronous bus enable signals
    wire iorq_rd = ~iorq_n && ~rd_n;
    wire iorq_wr = ~iorq_n && ~wr_n;
    wire mem_rd = ~mreq_n && ~rd_n;
    wire mem_wr = ~mreq_n && ~wr_n;

    // IO addres decoders (two variations):
    //  signal       = CPU asynchronous IO cycle
    //  signal_tick  = FPGA ff clock enable synchronized to phi

    // gpio input
    wire ioreq_rd_f0 = iorq_rd && (a[7:0] == 8'hf0);                // gpio input
    wire ioreq_rd_f0_tick = iorq_rd_tick && (a[7:0] == 8'hf0);

    wire ioreq_wr_f1 = iorq_wr && (a[7:0] == 8'hf1);                // gpio output
    wire ioreq_wr_f1_tick  = iorq_wr_tick && (a[7:0] == 8'hf1);

    wire ioreq_rd_fe = iorq_rd && (a[7:0] == 8'hfe);                // flash select disable access port
    wire ioreq_rd_fe_tick = iorq_rd_tick && (a[7:0] == 8'hfe);

    // The VDP regs are at address 0x80-0x81 (note LSB is not decoded)
    wire ioreq_rd_vdp = iorq_rd && (a[7:1] == 7'b1000000);
    wire ioreq_wr_vdp = iorq_wr && (a[7:1] == 7'b1000000);
    wire ioreq_rd_vdp_tick = iorq_rd_tick && (a[7:1] == 7'b1000000);
    wire ioreq_wr_vdp_tick = iorq_wr_tick && (a[7:1] == 7'b1000000);

    wire ioreq_rd_j3 = iorq_rd && (a[7:0] == 8'ha8);
    wire ioreq_rd_j3_tick = iorq_rd_tick && (a[7:0] == 8'ha8);         // joystick J3

    wire ioreq_rd_j4 = iorq_rd && (a[7:0] == 8'ha9);
    wire ioreq_rd_j4_tick = iorq_rd_tick && (a[7:0] == 8'ha9);         // joystick J4

    // ROM memory address decoder (address bus is 20 bits wide)
    // All following are suitable for our needs but can have very different number of LUTs!
    // a good example of optimizing for space/time
    //wire mreq_rom = rom_sel && mem_rd && a < RAM_START;       // if accessing low RAM during boot
    //wire mreq_rom = rom_sel && mem_rd && a[15:12] == 0;       // top 4 MSBs of bottom 4K are zero
    wire mreq_rom = rom_sel && mem_rd && a[19:12] == 0;         // all top MSBs of bottom 4K are zero

    // The GPIO output latch
    reg [7:0] gpio_out;
    always @(negedge phi) begin
        if ( ioreq_wr_f1_tick )
            gpio_out <= d;
    end

    // It is not really necessary to latch this because the SD signals will be stable during a read:
    reg [7:0] ioreq_rd_f0_data;     //  = {sd_miso,sd_det,6'bx};  // data value when reading port F0
    always @(negedge phi) begin
        if ( ioreq_rd_f0_tick )
            ioreq_rd_f0_data <= {sd_miso,sd_det,6'bx};
    end

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

    // show some signals from the GPIO ports on the LEDs for reference
    assign led = {~sd_miso,sd_det,3'b111,~gpio_out[2:0]};

endmodule