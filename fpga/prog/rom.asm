; This is loaded into what the CPU will see in address range 00000-001ff.

; The cheezy assembler I am using does not support the 180's OUT0 instruction.
; BUT... if (and ONLY if) I am outputting a zero value, the result is the same.

        org 0

        ; The processor will run faster if it does not have to generate
        ; DRAM refresh and wait states that are enabled after reset.

        ld      a,0
        //out0     (0x36),a        ; RCR = 0 = disables the refresh controller
        db      0xdd,0x39,036   ; hand-made OUT0 instruction
        //out0     (0x32),a        ; DCNTL = 0 = zero wait states
        db      0xdd,0x39,0x32  ; hand-made OUT0 instruction

loop:   
        jp      loop

        end
