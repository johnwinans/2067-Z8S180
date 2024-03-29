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


        ; Padd RAM so we can see if the decode logic is working
        ; Each time we make a pass, we rotate A to the right so we are setting
        ; one bit at a time in the RAM.

        ld      a,3             ; 3H = 0000_0011B

loop:   
        ld      hl,0x0200       ; copy entire address range of 0200-ffff over itself.
        ld      (hl),a          ; store A ito the first byte
        ld      de,0x0201       ; copy it into the next one
        ld      bc,0xfdff       ; and repeat the copy through the end of the RAM
        ldir

        rrca                    ; rotate A to the right (with wrap around)

        jp      loop            ; ...then go back and do it again

        end
