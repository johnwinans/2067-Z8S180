TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

LIB_UTILS=..
include $(LIB_UTILS)/Make.include

FILES= \
	$(LIB_UTILS_FILES)

all:: pwm

pwm_tb.vvp: $(FILES) pwm_tb.v
	$(VERILOG_SIM) -s tb -o $@ $^

pwm: pwm_tb.vcd
	gtkwave $^
