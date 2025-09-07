TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

LIB_UTILS=..
include $(LIB_UTILS)/Make.include

FILES= \
	$(LIB_UTILS_FILES)

all:: 

ay_noise_tb.vvp: $(FILES) ay_noise_tb.v
	$(VERILOG_SIM) -s tb -o $@ $^

ay_noise: ay_noise_tb.vcd
	gtkwave $^

ay_regs_tb.vvp: $(FILES) ay_regs_tb.v
	$(VERILOG_SIM) -s tb -o $@ $^

ay_regs: ay_regs_tb.vcd
	gtkwave $^

ay3891x_tb.vvp: $(FILES) ay3891x_tb.v
	$(VERILOG_SIM) -s tb -o $@ $^

ay3891x: ay3891x_tb.vcd
	gtkwave $^
