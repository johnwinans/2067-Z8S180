TOP=..


include $(TOP)/Make.rules
#FREQ		= 110	# test for fun

.PHONY: all clean burn world timings

FILES= \
	top.v \
	memory.v \
	iorq_rd_fsm.v \
	iorq_wr_fsm.v \
	$(VDP_LIBV)/video.v \
	$(VDP_LIBV)/vdp_table_test.v \
	$(VDP_LIBV)/vgasync.v \
	pll_25_18432.v

all:: top.bin

top.json: $(FILES) rom.hex
	$(COMPILE.v) -p "synth_ice40 -top top -json $@" $(FILES)

timing: top.asc
	icetime -tmd $(DEVICE) $^

prog: top.bin
	$(FLASH_PROG) $^

# extra dependancies
top.asc: $(PINMAP)

#
#DATE := $(shell date --rfc-3339=seconds)
#GIT_VERSION := $(shell git describe --long --dirty; git show -s --format='%ci')
#%.bin: %.asm
#	cat $< | sed -e "s/@@DATE@@/$(DATE)/g" -e "s/@@GIT_VERSION@@/$(GIT_VERSION)/g" | $(CROSS_AS) - -o $@ --list=$(basename $@).lst --label=$(basename $@).sym $(CROSS_AS_FLAGS)
#

rom.bin:
	cp ../../../2063-Z80-cpm/boot/firmware.bin rom.bin

%.hex: %.bin
	hexdump -v -e '/1 "%02x\n"' < $< > $@

clean::
	rm -f *.lst *.bin *.hex *.sym pll_25_18432.v


pll_25_18432.v:
	icepll -i 25 -o 18.432 -m -n pll_25_18432 > $@



iorq_rd_fsm_tb.vvp : iorq_rd_fsm_tb.v iorq_rd_fsm.v
	iverilog -o $@ $^

iorqr: iorq_rd_fsm_tb.vcd
	gtkwave $^

iorq_wr_fsm_tb.vvp : iorq_wr_fsm_tb.v iorq_wr_fsm.v
	iverilog -o $@ $^

iorqw: iorq_wr_fsm_tb.vcd
	gtkwave $^
