TOP=..

LIB_VDP99=$(TOP)/vdp99
LIB_UTILS=$(TOP)/lib

include $(TOP)/Make.rules
#FREQ		= 110	# test for fun

.PHONY: prog

#NEXTPNR_OPT+=--ignore-loops 

include $(LIB_VDP99)/Make.include
include $(LIB_UTILS)/Make.include

TBFILES= \
	memory.v \
	$(LIB_VDP99_FILES) \
	$(LIB_UTILS_FILES) \
	z80_vdp99.v

FILES=\
	top.v \
	$(TBFILES) \
	pll_25_18432.v

all:: top.bin

top.json: $(FILES) rom.hex
	$(COMPILE.v) -p "$(SYNTH) -top top -json $@" $(FILES) $(COMPILE_OPT)

timing: top.asc
	icetime -tmd $(DEVICE) $^

prog: top.bin
	$(FLASH_PROG) $^

# extra dependancies
top.asc: $(PINMAP)

rom.bin:
	cp ../../../2063-Z80-cpm/boot/firmware.bin rom.bin

%.hex: %.bin
	hexdump -v -e '/1 "%02x\n"' < $< > $@

clean::
	rm -f *.lst *.bin *.sym pll_25_18432.v


pll_25_18432.v:
	icepll -i 25 -o 18.432 -m -n pll_25_18432 > $@


z80_vdp99_tb.vvp: $(TBFILES) z80_vdp99_tb.v
	iverilog -o $@ $^

z80_vdp99_tb: z80_vdp99_tb.vcd
	gtkwave $^

