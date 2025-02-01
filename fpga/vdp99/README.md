# A TI99-ish VDP

# Video Modes:
## M1
## M2
## M3
## text

# Writable control regs (2-byte config mode1):
```
CR0: 0 0 0 0 0 M3 0
CR1: x BLK IE M1 M2 0 SSIZ SMAG
CR2: 0 0 0 0 n n n n                    nn.nn00 0000.0000 = name base address
CR3: n n n n n n n n                    nn.nnnn nn00.0000 = color base address
CR4: 0 0 0 0 0 n n n                    nn.n000 0000.0000 = pattern base
CR5: 0 n n n n n n n                    nn.nnnn n000.0000 = sprite attribute base
CR6: 0 0 0 0 0 n n n                    nn.n000 0000.0000 = sprite pattern base
CR7: a a a a b b b b                    aaaa = text foreground, bbbb = text background & border
```

# Readable Status Register (just read the mode1 port):
```
ST:  F 5TH C S S S S S
    F = frame ended since last read
    5TH = five or more sprites on one line
    C = Coincidence/coln if two visible sprite px overlap
    SSSSS = lowest priority sprite on the horizontal line when 5TH is set
```
