GTK_ARGS=-A --rcvar 'fontname_signals Monospace 13' --rcvar 'fontname_waves Monospace 12'

VSRC=\
	crc.v

all: crc8

crc8_tb.vvp: $(VSRC) crc8_tb.v
	iverilog -o $@ $^

crc8_tb.vcd: crc8_tb.vvp
	vvp $^

crc8: crc8_tb.vcd
	gtkwave $(GTK_ARGS) crc8_tb.vcd

crc16_tb.vvp: $(VSRC) crc16_tb.v
	iverilog -o $@ $^

crc16_tb.vcd: crc16_tb.vvp
	vvp $^

crc16: crc16_tb.vcd
	gtkwave $(GTK_ARGS) crc16_tb.vcd

clean:
	rm -f *.vvp *.vcd
