TOP=..
include $(TOP)/Make.rules

all::

vdp_reg_ifce_tb.vvp: vdp_reg_ifce_tb.v vdp_reg_ifce.v
	iverilog -o $@ $^

vdp_reg_ifce: vdp_reg_ifce_tb.vcd
	gtkwave $^


vdp_irq_tb.vvp: vdp_irq.v vdp_irq_tb.v
	iverilog -o $@ $^

vdp_irq: vdp_irq_tb.vcd
	gtkwave $^

vdp99_tb.vvp: vdp99.v vdp99_tb.v vdp_reg_ifce.v vdp_irq.v vgasync.v
	iverilog -o $@ $^

vdp99: vdp99_tb.vcd
	gtkwave $^

