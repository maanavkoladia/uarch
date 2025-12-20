.ORIG 0x0200

    .FILL 0x0000  ; Vector[0] (Unused or Reserved)
    .FILL 0x1200  ; Vector[1] - Timer Interrupt Handler (at x1200)
    .FILL 0x1400  ; Vector[2] - Page Fault Excpetion Handler (at 0x1400)
    .FILL 0x1A00  ; Vector[3] - Unaligned Access Exception Handler (at x1A00)
    .FILL 0x1600  ; Vector[4] - Protection Exception Handler (at x1600)
    .FILL 0x1C00  ; Vector[5] - Illegal Opcode Exception Handler (at x1C00)

.END
