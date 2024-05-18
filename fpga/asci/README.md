
An example of booting the CPU and running code that is in multiple
RAM4k Blocks in the FPGA.

The code in the RAM block is assembled into binary and then loaded into
an FPGA block RAM by making it part of the initialization logic for an
array of bytes.

On a PI or Ubuntu system, install the Z80 assembler I used like this:

```
sudo apt install z80asm
```

This is an example on how to initialize and use the ASCI.
