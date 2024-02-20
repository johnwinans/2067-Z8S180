An example of booting the CPU and running code that is in one of the 
RAM4k Blocks in the FPGA.

The code in the RAM block is assembled into binary and then loaded into
an FPGA block RAM by making it part of the initialization logic for an
array of bytes.

On a PI or Ubuntu system, install the Z80 assembler I used like this:

```
sudo apt install z80asm
```

This test includes adding a register inside the FPGA that latches any
value written to memory address 0xffff and displays it on the LEDs.

This is useful when combined with the LDIR test program running from
the FPGA memory block that padds the memory.

The only way the proper pattern can be seen on the LEDs is if every 
memory byte from 0x0200 through 0xfffe can be written and then read 
back properly... good enough for this simple test!
