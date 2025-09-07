TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

LIB_UTILS=..
include $(LIB_UTILS)/Make.include

FILES= \
	$(LIB_UTILS_FILES)

all:: prescaler

prescaler_tb.vvp: $(FILES) prescaler_tb.v
	$(VERILOG_SIM) -s tb -o $@ $^

prescaler: prescaler_tb.vcd
	gtkwave $^
