.ORIG x3000
LEA R1 NUM1          ; Load the first number into R1
LEA R2 NUM2          ; Load the second number into R2

LDW R1 R1 #0
LDW R2 R2 #0

AND R3 R3 #0         ; Clear R3 (result)

LOOP    BRz DONE             ; If R2 == 0, exit loop
        ADD R3 R3 R1         ; Add R1 to R3
        ADD R2 R2 #-1        ; Decrement R2
BRnzp   LOOP           ; Repeat loop

DONE    LEA R3 RESULT        ; Store the result in memory
        STW R3 R3 #0
HALT

NUM1 .FILL x0004     ; First number (4)
NUM2 .FILL x0003     ; Second number (3)
RESULT .FILL x0000   ; Placeholder for result
.END
