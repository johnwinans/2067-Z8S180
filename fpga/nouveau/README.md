
An example of booting the CPU and running code that is in multiple
RAM4k Blocks in the FPGA.

The code in the RAM block is assembled into binary and then loaded into
an FPGA block RAM by making it part of the initialization logic for an
array of bytes.

On a PI or Ubuntu system, install the Z80 assembler I used like this:

```
sudo apt install z80asm
```

This can be used to boot the Z80-Retro! boot/firmware.bin file.

The default Z8S180 internal I/O device address map is 00-3f:

CNTLA0	00
CNTLA1	01
CNTLB0	02
CNTLB1	03
STAT0	04
STAT1	05
TDR0	06
TDR1	07
RDR0	08
RDR1	09
CNTR	0a
TRDR	0b
TMDR0L	0c
TMDR0H	0d
RLDR0L	0e
RLDR0H	0f
TCR		10

ASEXT0	12
ASEXT1	13

TMDR1L	14
TMDR1H	15
RLDR1L	16
RLDR1H	17
FRC		18

ASTC0L	1a
ASTC0H	1b
ASTC1L	1c
ASTC1H	1d
CLKMUL	1e

SAR0L	20
SAR0H	21
SAR0B	22
DAR0L	23
DAR0H	24
DAR0B	25
BCR0L	26
BCR0H	27
MAR1L	28
MAR1H	29
MAR1B	2a
IAR1L	2b
IAR1H	2c
IAR1B	2d
BCR1L	2e
BCR1H	2f

DSTAT	30
DMODE	31
DCNTL	32

IL		33
ITC		34

RCR		36

CBR		38
BBR		39
CBAR	3a
OMCR	3e

ICR		3f




Note that E falls as T1 rises :-(
Consider a one-shot FSM what triggers on posedge phi when E&IORQ&RD/WR 
and allows one edge to pass and then seizes until E goes low again.

This would also work without E on just the IORQ&WR, IORQ&RD. But
in this case it might be better to latch on the second PHI edge in 
case phi T2 sneaks through.
