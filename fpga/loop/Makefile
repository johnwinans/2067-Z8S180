TOP=..

include $(TOP)/Make.rules

.PHONY: prog

FILES= \
	top.v \
	memory.v

all:: top.bin

top.json: $(FILES)
	$(COMPILE.v) -p "$(SYNTH) -top top -json $@" $(COMPILE_OPT) $^

timing: top.asc
	icetime -tmd $(DEVICE) $^

counter_tb.vvp: counter_tb.v counter.v
	iverilog -o $@ $^

plot: counter_tb.vcd
	gtkwave $^

prog: top.bin
	$(FLASH_PROG) $^

# extra dependancies
top.asc: $(PINMAP)

