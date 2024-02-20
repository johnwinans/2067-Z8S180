; This is loaded into what the CPU will see in address range 00000-001ff.

; The cheezy assembler I am using does not support the 180's OUT0 instruction.
; BUT... if (and ONLY if) I am outputting a zero value, the result is the same.

        org 0

        ; The processor will run faster if it does not have to generate
        ; DRAM refresh and wait states that are enabled after reset.

        ld      a,0
        out     (0x36),a        ; RCR = 0 = disables the refresh controller
        out     (0x32),a        ; DCNTL = 0 = zero wait states


        ; Padd RAM so we can see if the decode logic is working
        ; Each time we make a pass, we rotate A to the right so we are setting
        ; one bit at a time in the RAM.

        ld      a,1

loop:   
        ld      hl,0x0200       ; copy entire address range of 0000-ffff over itself.
        ld      (hl),a          ; zero the first byte
        ld      de,0x0201       ; copy into the next one
        ld      bc,0x0000
        ldir

        rrca                    ; rotate A to the right (with wrap around)

        jp      loop            ; ...then go back and do it again

        end
