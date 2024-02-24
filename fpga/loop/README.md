Simulate a small ROM that has a program in it that jumps
to itself in a loop.

There are three variations:

```
JMP .               ; endless loop
```

```
LD A,0
OUT0 (0x36),A       ; shut off automatic refresh feature
JMP .               ; endless loop
```

```
LD A,0
OUT0 (0x36),A       ; shut off automatic refresh feature
OUT0 (0x32),A       ; shut off the wait-state generator
JMP .               ; endless loop
```


Note that this uses the Z8S180 instruction `OUT0` because the regular Z80 `OUT` instruction.
See the following from the Z80 CPU User Manual:

OUT (n),A

The operand n is placed on the bottom half (A0 through A7) of the address bus to select
the I/O device at one of 256 possible ports. The contents of the Accumulator (Register A)
also appear on the top half (A8 through A15) of the address bus at this time. Then the 
byte contained in the Accumulator is placed on the data bus and written to the selected 
peripheral device.

The manual for the Z8S180 states that when writing to the I/O ports that are internal 
to the SOC, you must make sure that A8-A15 are zero!

The *corret* way to write to the I/O ports in the S180 SOC is to use the `OUT0` instruction!


Side note:  Since I am writing the value 0x00 to the output port, it just so happens
that the `OUT` instruction would, in fact, work OK in this specific case.  But ONLY
because I am outputting a zero to the port!
