Simulate a small ROM that has a program in it that jumps
to itself in a loop.

There are three variations:

```
JMP .				; endless loop
```


```
LD A,0
OUT (0x36),A		; shut off automatic refresh feature
JMP .				; endless loop
```

```
LD A,0
OUT (0x36),A		; shut off automatic refresh feature
OUT (0x32),A		; shut off the wait-state generator
JMP .				; endless loop
```


WARNING: This only works because the value being written to the output port
is zero!  See the following from the Z80 CPU User Manual:

OUT (n),a

The operand n is placed on the bottom half (A0 through A7) of the address bus to select
the I/O device at one of 256 possible ports. The contents of the Accumulator (Register A)
also appear on the top half (A8 through A15) of the address bus at this time. Then the 
byte contained in the Accumulator is placed on the data bus and written to the selected 
peripheral device.


The *corret* way to write to the I/O ports in the S180 is to use the out0 instruction!
