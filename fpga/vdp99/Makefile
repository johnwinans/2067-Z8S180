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

vdp99_tb.vvp: vdp99.v vdp99_tb.v vdp_reg_ifce.v vdp_irq.v vgasync.v vram.v
	iverilog -o $@ $^

vdp99: vdp99_tb.vcd
	gtkwave $^


vgasync_tb.vvp: vgasync_tb.v vgasync.v
	iverilog -o $@ $^

vgasync: vgasync_tb.vcd
	gtkwave $^


vram_tb.vvp: vram_tb.v vram.v
	iverilog -o $@ $^

vram: vram_tb.vcd
	gtkwave $^


vdp_fsm_tb.vvp: vdp_fsm_tb.v vdp_fsm.v
	iverilog -o $@ $^

vdp_fsm: vdp_fsm_tb.vcd
	gtkwave $^
