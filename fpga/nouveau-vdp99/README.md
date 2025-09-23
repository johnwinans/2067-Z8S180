# A Z80 Nouveau with a TI99 style VDP

Note that the IO interface of the VDP is running in the
pixel clock domain and the CPU is running in the PHI clock
domain.

[Related video discussion on YouTube.](https://youtu.be/vwotP50WOko)

The following program can be used to set the VDP regs with values
for a suitable test pattern for commit: e3811cc2d82fea9283de4cb5aa280cf6de1f5f84 
```
  0100  LD   B,08
  0102  LD   C,80
  0104  LD   D,80
  0106  LD   A,C
  0107  OUT  81,A
  0109  LD   A,D
  010A  OUT  81,A
  010C  INC  C
  010D  INC  D
  010E  DJNZ F6
  0110  NOP  
  0111  RET  
```

# Memory Map

Note that the Z8S180 has its own internal IO devices mapped to addresses 00-3F.

```
80	VDP VRAM
81	VDP registers

A8	Joystick J3
A9	Joystick J4

B0	AY-3-8910
B1	AY-3-8910

F0	GPIO input
F1	GPIO output

FE	Boot flash select disable
```
