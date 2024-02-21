; This is loaded into what the CPU will see in address range 00000-001ff.

; NOTE: The cheezy assembler I am using does not support the 180's OUT0 instruction.

        org 0

        ; The processor will run faster if it does not have to generate
        ; DRAM refresh and wait states that are enabled after reset.

        ld      a,0
        ;out0     (0x36),a      ; RCR = 0 = disables the refresh controller
        db      0xed,0x39,0x36  ; hand-made OUT0 instruction
        ;out0     (0x32),a      ; DCNTL = 0 = zero wait states
        db      0xed,0x39,0x32  ; hand-made OUT0 instruction

loop:   
        jp      loop

        end
