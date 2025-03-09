TOP=../..

-include  $(TOP)/Make.local
include $(TOP)/Make.rules

LIB_UTILS=..
include $(LIB_UTILS)/Make.include

FILES= \
	$(LIB_UTILS_FILES)

all:: 

z80_wr_cdc_tb.vvp: z80_wr_cdc_tb.v $(FILES)
	$(VERILOG_SIM) -s tb -o $@ $^

plot: z80_wr_cdc_tb.vcd
	gtkwave $^
