TOP=..

include $(TOP)/Make.2057.rules

# use a locally defined pinmap so the SD card pins don't generate warnings in the other test apps
PINMAP		= ./pinmap-2057.pcf

include $(TOP)/Make.rules

.PHONY: all clean burn world timings

FILES= \
	top.v \
	memory.v \
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
#	cat $< | sed -e "s/@@DATE@@/$(DATE)/g" -e "s/@@GIT_VERSION@@/$(GIT_VERSION)/g" | z80asm - -o $@ --list=$(basename $@).lst --label=$(basename $@).sym $(ASM_FLAGS)
#

rom.bin:
	cp ../../../2063-Z80-cpm/boot/firmware.bin rom.bin

%.hex: %.bin
	hexdump -v -e '/1 "%02x\n"' < $< > $@

clean::
	rm -f *.lst *.bin *.hex *.sym pll_25_18432.v


pll_25_18432.v:
	icepll -i 25 -o 18.432 -m -n pll_25_18432 > $@
