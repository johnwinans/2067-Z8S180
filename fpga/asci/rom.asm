; This is loaded into what the CPU will see in address range 00000-001ff.

; The cheezy assembler I am using does not support the 180's OUT0 instruction.

        org 0

        ; The processor will run faster if it does not have to generate
        ; DRAM refresh and wait states that are enabled after reset.

        ld      a,0
        ;out     (0x36),a        ; RCR = 0 = disables the refresh controller
        db      0xed,0x39,0x36
        ;out     (0x32),a        ; DCNTL = 0 = zero wait states
        db      0xed,0x39,0x32

        ld      sp,0xff00

CNTLA0: equ     0x00
CNTLB0: equ     0x02
RDR0:   equ     0x08
ASEXT0: equ     0x12
STAT0:  equ     0x04
TDR0:   equ     0x06

        ; stolen from https://groups.google.com/g/retro-comp/c/N574sGiwmaI?pli=1
        ; 25000000/2/2/10/16/2 = 19531

        ; set the ERF ion CNTLA to clear the RX overrun fiasco bit!!!

        ;LD      A,01100100B    ;rcv enable, xmit enable, no parity
        LD      A,01100101B    ;rcv enable, xmit enable, no parity
        ;OUT0    (CNTLA0),A     ;0C0H, set cntla
        db      0xed,0x39,CNTLA0
       
        LD      A,00000001B    ;div 10, div 16, div 2 25000000/2/2/10/16/2 = 19531
        ;OUT0    (CNTLB0),A     ;0C2H, set cntlb
        db      0xed,0x39,CNTLB0

        LD      A,01100110B    ;no cts, no dcd, no break detect
        ;OUT0    (ASEXT0),A     ;0D2H, set ASCI0 EXTENSION CONTROL (Z8S180 only)
        db      0xed,0x39,ASEXT0
        XOR     A
        ;OUT0    (STAT0),A      ;0C4H, ASCI Status Reg Ch 0
        db      0xed,0x39,STAT0

LOOP:
        CALL    CIN
        CALL    COUT
        CALL    COUT
        CALL    COUT
        JP      LOOP
        
COUT:
        PUSH  AF
CHKEMPTY:
        ;IN0     A,(STAT0)      ;C4H,read status
        db      11101101B,00111000B,STAT0
        AND     2
        JR      Z,CHKEMPTY
        POP     AF
        ;OUT0    (TDR0),A       ;C6H
        db      0xed,0x39,TDR0
        RET

CIN:
CINEMPTY:
        ;IN0     A,(STAT0)      ;C4H,read status
        db      11101101B,00111000B,STAT0
        AND     10000000B
        JR      Z,CINEMPTY
        ;IN0     A,(RDR0)      ;C4H,read status
        db      11101101B,00111000B,RDR0
        ret

        end
