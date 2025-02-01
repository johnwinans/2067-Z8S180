TOP=..
include $(TOP)/Make.rules

all::

vdp_reg_ifce_tb.vvp: vdp_reg_ifce_tb.v vdp_reg_ifce.v
	iverilog -o $@ $^

vdp_reg_ifce: vdp_reg_ifce_tb.vcd
	gtkwave $^
