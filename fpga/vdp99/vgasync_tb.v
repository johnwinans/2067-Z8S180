`timescale 1ns/1ns

module tb();

    reg clk         = 0;        // pixel clock
    reg reset       = 0;
    reg text_mode   = 0;

    vgasync
    #(
        // artifically small screen to make easy to see waveforms
        .HVID(5),
        .HRB(2),
        .HFP(2),
        .HS(3),
        .HBP(4),
        .HLB(2),
        .VVID(3),
        .VBB(2),
        .VFP(4),
        .VS(2),
        .VBP(3),
        .VTB(2)
    ) uut (
        .clk(clk),
        .reset(reset),
        .text_mode(text_mode)
    );

`define ASSERT(cond) if ( !(cond) ) $display("%s:%0d %m time:%3t ASSERTION (cond) FAILED!", `__FILE__, `__LINE__, $time );

    localparam clk_period = (1.0/25000000)*1000000000; // clk is running at 25MHZ
    always #(clk_period/2) clk = ~clk;

    initial begin
        $dumpfile("vgasync_tb.vcd");
        $dumpvars;
    
        #(clk_period*4);
        @(posedge clk);
        reset <= 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        reset <= 0;

        @(posedge clk);


        #100000;
        $finish;
    end

endmodule
