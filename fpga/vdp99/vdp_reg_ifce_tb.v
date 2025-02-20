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

    reg clk         = 0;        // pixel clock
    reg reset       = 0;
    reg wr_tick     = 0;
    reg rd_tick     = 0;
    reg [7:0] din   = 'hx;

    vdp_reg_ifce uut (
        .clk(clk),
        .reset(reset),
        .wr_tick(wr_tick),
        .rd_tick(rd_tick),
        .din(din)
    );

`define ASSERT(cond) if ( !(cond) ) $display("%s:%0d %m time:%3t ASSERTION (cond) FAILED!", `__FILE__, `__LINE__, $time );

    initial begin
        $dumpfile("vdp_reg_ifce_tb.vcd");
        $dumpvars;
    end
    
    localparam clk_period = (1.0/25000000)*1000000000; // clk is running at 25MHZ
    always #(clk_period/2) clk = ~clk;

    initial begin
        #(clk_period*4);

        @(posedge clk);
        reset <= 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        reset <= 0;


        @(posedge clk);

        `ASSERT( uut.r0 === 0 );
        `ASSERT( uut.r1 === 0 );
        `ASSERT( uut.r2 === 0 );
        `ASSERT( uut.r3 === 0 );
        `ASSERT( uut.r4 === 0 );
        `ASSERT( uut.r5 === 0 );
        `ASSERT( uut.r6 === 0 );
        `ASSERT( uut.r7 === 0 );

        @(posedge clk);
        @(posedge clk);

        // reg0 = 0xee
        @(posedge clk);
        din <= 'hee;
        wr_tick <= 1;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.w0_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.r0 === 0 );

        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 1 );
        `ASSERT( uut.w0_reg === 'hee );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.r0 === 0 );

        @(posedge clk);
        din <= 'h80;     // write into reg 0
        wr_tick <= 1;
        @(negedge clk);
        `ASSERT( uut.state_reg === 1 );
        `ASSERT( uut.w0_reg === 'hee );
        `ASSERT( uut.update_vdp_reg_tick === 1 );
        `ASSERT( uut.r0 === 0 );

        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.w0_reg === 'hee );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.r0 === 'hee );



        // reg3 = 0x33
        @(posedge clk);
        din <= 'h33;
        wr_tick <= 1;
        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;

        @(posedge clk);
        din <= 'h83;     // write into reg 3
        wr_tick <= 1;
        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'h33 );
        `ASSERT( uut.r0 === 'hee);
        `ASSERT( uut.r1 === 'h00);
        `ASSERT( uut.r2 === 'h00);
        `ASSERT( uut.r3 === 'h33);
        `ASSERT( uut.r4 === 'h00);
        `ASSERT( uut.r5 === 'h00);
        `ASSERT( uut.r6 === 'h00);
        `ASSERT( uut.r7 === 'h00);


        // rapid-fire writes
        @(posedge clk);
        din <= 'h44;
        wr_tick <= 1;
        @(posedge clk);
        din <= 'h84;
        @(posedge clk);
        @(negedge clk);
        `ASSERT( uut.r4 === 'h44 );

        din <= 'h55;
        @(posedge clk);
        din <= 'h85;
        @(posedge clk);
        @(negedge clk);
        `ASSERT( uut.r5 === 'h55 );
        din <= 'h66;
        @(posedge clk);
        din <= 'h86;
        @(posedge clk);
        @(negedge clk);
        `ASSERT( uut.r6 === 'h66 );
        wr_tick <= 0;
        din <= 'hz;


        @(posedge clk);
        @(posedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'h66 );
        `ASSERT( uut.r0 === 'hee);
        `ASSERT( uut.r1 === 'h00);
        `ASSERT( uut.r2 === 'h00);
        `ASSERT( uut.r3 === 'h33);
        `ASSERT( uut.r4 === 'h44);
        `ASSERT( uut.r5 === 'h55);
        `ASSERT( uut.r6 === 'h66);
        `ASSERT( uut.r7 === 'h00);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        // test rm0 reset the 2-state write register toggler
        @(posedge clk);
        din <= 'h22;
        wr_tick <= 1;
        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 1 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'h22 );
        `ASSERT( uut.r1 === 'h00);


        @(posedge clk);
        rd_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'h22 );
        `ASSERT( uut.r1 === 'h00);


        // make sure it still works (we didn't get it stuck)
        @(posedge clk);
        din <= 'h11;
        wr_tick <= 1;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'h22 );
        `ASSERT( uut.r1 === 'h00);

        @(posedge clk);
        din <= 'h81;
        @(negedge clk);
        `ASSERT( uut.state_reg === 1 );
        `ASSERT( uut.update_vdp_reg_tick === 1 );
        `ASSERT( uut.w0_reg === 'h11 );
        `ASSERT( uut.r1 === 'h00);

        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'h11 );
        `ASSERT( uut.r1 === 'h11);


        // make sure we can CHANGE a value that has already been written
        @(posedge clk);
        din <= 'hf6;
        wr_tick <= 1;
        @(posedge clk);
        din <= 'h86;
        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'hf6 );
        `ASSERT( uut.r6 === 'hf6);

        // make sure that rm0 is OK when not done in state 1
        @(posedge clk);
        rd_tick <= 1;
        @(posedge clk);
        rd_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'hf6 );
        `ASSERT( uut.r6 === 'hf6);

        // a long wait between successive wm0 writes
        @(posedge clk);
        din <= 'h77;
        wr_tick <= 1;
        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 1 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'h77 );
        `ASSERT( uut.r7 === 'h00);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        wr_tick <= 1;
        din <= 'h87;
        @(negedge clk);
        `ASSERT( uut.state_reg === 1 );
        `ASSERT( uut.update_vdp_reg_tick === 1 );
        `ASSERT( uut.w0_reg === 'h77 );
        `ASSERT( uut.r7 === 'h00);

        @(posedge clk);
        wr_tick <= 0;
        din <= 'hz;
        @(negedge clk);
        `ASSERT( uut.state_reg === 0 );
        `ASSERT( uut.update_vdp_reg_tick === 0 );
        `ASSERT( uut.w0_reg === 'h77 );
        `ASSERT( uut.r7 === 'h77);

        @(posedge clk);

        #(clk_period*10);
        $finish;
    end

endmodule
