; Program: Countdown from 10 to 0
        .ORIG x3000           ; Program starting address
        LEA R0, TEN       ; Load the address of TEN into R0
        LDW R1, R0, #0    ; Load the value at TEN (10) into R1
START   ADD R1, R1, #-1   ; Decrement R1 by 1
        BRZ DONE          ; If R1 is zero, branch to DONE
        BR START          ; Otherwise, loop back to START

DONE    TRAP x25          ; Halt the program

TEN     .FILL #10       ; Constant value 10 (hexadecimal)

        .END              ; End of program
