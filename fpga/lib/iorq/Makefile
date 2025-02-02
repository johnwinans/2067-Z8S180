TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

all:: 

iorq_rd_fsm_tb.vvp: iorq_rd_fsm.v iorq_rd_fsm_tb.v
	iverilog -o $@ $^

iorqr: iorq_rd_fsm_tb.vcd
	gtkwave $^

iorq_wr_fsm_tb.vvp: iorq_wr_fsm.v iorq_wr_fsm_tb.v
	iverilog -o $@ $^

iorqw: iorq_wr_fsm_tb.vcd
	gtkwave $^
