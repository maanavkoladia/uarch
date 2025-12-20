.ORIG x3000
LEA R1 NUM1          ; Load the first number into R1
LEA R2 NUM2          ; Load the second number into R2

LDW R1 R1 #0
LDW R2 R2 #0

NOT R3 R2            ; Take NOT of R2
ADD R3 R3 #1         ; Compute -R2
ADD R3 R1 R3         ; Subtract R2 from R1
BRn NUM2GREATER     ; If R3 < 0, branch to NUM2_GREATER
LEA R7 RESULT
LDW R7 R7 #0
STW R1 R7 #0        ; Store R1 (NUM1) in RESULT
HALT

NUM2GREATER STW R2 R7 #0       ; Store R2 (NUM2) in RESULT
HALT

NUM1 .FILL x0007     ; First number (7)
NUM2 .FILL x0009     ; Second number (9)
RESULT .FILL x0000   ; Placeholder for result
.END
