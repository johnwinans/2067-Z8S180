TOP=..

include $(TOP)/Make.rules
#FREQ		= 110	# test for fun

LIB_UTILS=$(TOP)/lib
include $(LIB_UTILS)/Make.include

.PHONY: prog

FILES= \
	top.v \
	memory.v \
	$(LIB_UTILS_FILES) \
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
	rm -f *.lst *.bin *.hex *.sym pll_25_18432.v


pll_25_18432.v:
	icepll -i 25 -o 18.432 -m -n pll_25_18432 > $@

