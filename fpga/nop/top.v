module top (
    input wire          hwclk,
    input wire          s1_n,
    output wire [7:0]   led,

    input wire [19:0]   a,
    inout wire [7:0]   	d,

    input wire          busack_n,
    inout wire         	busreq_n,

    output wire         ce_n,
    output wire         oe_n,
    output wire         we_n,

    inout wire         	dreq1_n,

    input wire          e,
    output wire         extal,
    input wire          phi,

    input wire          halt_n,

    inout wire [2:0]    int_n,
    inout wire          nmi_n,

    input wire          rd_n,
    input wire          wr_n,
    input wire          iorq_n,
    input wire          mreq_n,
    input wire          m1_n,

    output wire         reset_n,
    input wire          rfsh_n,
    input wire          st,
    input wire          tend1_n,
    inout wire         	wait_n,

    input wire          hwclk,

    output wire [7:0]   led,

    input wire          s1_n,
    input wire          s2_n

    );

    assign reset_n = s1_n;

    assign d = rd_n == 0 ? { 8'b0 } : { 8{1'bz} };

    reg [15:0]     ctr;
    always @(posedge hwclk) begin
        ctr <= ctr + 1;
    end

    assign extal = ctr[15];
    assign led = ~a[15:8];

    assign busreq_n = 1'b1;		// 1'bz;
    assign dreq1_n = 1'b1;		// 1'bz;
    assign int_n = 3'b111;		// 3'bz;
    assign nmi_n = 1'b1;		// 1'bz;
    assign wait_n = 1'bz;

endmodule
