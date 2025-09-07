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
