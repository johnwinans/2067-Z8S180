TOP=..
include $(TOP)/Make.rules

all::

reg_ifce_tb.vvp: reg_ifce_tb.v reg_ifce.v
	iverilog -o $@ $^

reg_ifce: reg_ifce_tb.vcd
	gtkwave $^
