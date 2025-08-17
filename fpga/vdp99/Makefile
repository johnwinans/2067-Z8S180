TOP=..
include $(TOP)/Make.rules

all::

vdp_reg_ifce_tb.vvp: vdp_reg_ifce_tb.v vdp_reg_ifce.v
	$(VERILOG_SIM) -s tb -o $@ $^

vdp_reg_ifce: vdp_reg_ifce_tb.vcd
	gtkwave $^


vdp_irq_tb.vvp: vdp_irq_tb.v vdp_irq.v 
	$(VERILOG_SIM) -s tb -o $@ $^

vdp_irq: vdp_irq_tb.vcd
	gtkwave $^

vdp99_tb.vvp: vdp99_tb.v vdp99.v vram_rd_demux.v vdp_reg_ifce.v vdp_irq.v vgasync.v vram.v vdp_fsm.v vdp_fsm_gfx.v
	$(VERILOG_SIM) -s tb -o $@ $^

vdp99: vdp99_tb.vcd
	gtkwave $^


vgasync_tb.vvp: vgasync_tb.v vgasync.v
	$(VERILOG_SIM) -s tb -o $@ $^

vgasync: vgasync_tb.vcd
	gtkwave $^


vram_tb.vvp: vram_tb.v vram.v
	$(VERILOG_SIM) -s tb -o $@ $^

vram: vram_tb.vcd
	gtkwave $^


vdp_fsm_tb.vvp: vdp_fsm_tb.v vdp_fsm.v vdp_fsm_gfx.v
	$(VERILOG_SIM) -s tb -o $@ $^

vdp_fsm: vdp_fsm_tb.vcd
	gtkwave $^



sprite_tb.vvp: sprite_tb.v sprite.v
	$(VERILOG_SIM) -s tb -o $@ $^

sprite: sprite_tb.vcd
	gtkwave $^

