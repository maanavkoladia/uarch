.ORIG x3000

; Initialize values
LEA R1 NUM1           ;Load NUM1 into R1
LEA R2 NUM2           ;Load NUM2 into R2
LDW R1 R1 #3
LDW R2 R2 #10
AND R3 R3 #0         ; Clear R3

; Perform arithmetic
ADD R3 R1 R2         ; Add R1 and R2, store in R3
AND R4 R1 #15        ; AND R1 with 15, store in R4
NOT R5 R2            ; NOT operation on R2, store in R5
XOR R6 R1 R2         ; XOR R1 and R2, store in R6

; Branching operations
BRz BRANCHZERO      ; Branch if zero
BRn BRANCHNEGA  ; Branch if negative
BRp BRANCHPOS  ; Branch if positive
BRnp SKIPBRANCH     ; Branch if negative or positive
BRnz SKIPBRANCH     ; Branch if negative or zero
BRzp SKIPBRANCH     ; Branch if zero or positive
BRnzp UNCOND  ; UNCOND branch

BRANCHZERO ADD R3 R3 #-1        ; Decrement R3
BRnzp SKIPBRANCH    ; Continue

BRANCHNEGA  ADD R3 R3 #1          ;Increment R3
BRnzp SKIPBRANCH     ;Continue

BRANCHPOS ADD R3 R3 #2         ;Add 2 to R3
BRnzp SKIPBRANCH     ;Continue

UNCOND NOP                  ; No operation

SKIPBRANCH LSHF R7 R1 #2        ; Left shift R1 by 2, store in R7
RSHFL R7 R1 #1       ; Logical right shift R1 by 1, store in R7
RSHFA R7 R1 #1       ; Arithmetic right shift R1 by 1, store in R7

; Memory operations
LEA R1 VALUEADDR     ;Load address of VALUEADDR into R1
LDB R2 R1 #0         ; Load byte from address in R1 to R2
STB R2 R1 #1         ; Store byte from R2 into address in R1 + 1
STW R3 R6 x10       ; Store word from R3 into RESULT

; Subroutine call
JSR SUBROUTINE       ; Jump to subroutine
HALT

; Subroutine
SUBROUTINE ADD R7 R7 #1         ; Increment R7
RET                  ; Return from subroutine

; Indirect subroutine call
LEA R4 FUNCADDR      ;Load subroutine address
JSRR R4              ; Jump to subroutine via R4

; Interrupt handling (simulated)
RTI                  ; Return from interrupt

; Output character
TRAP x21             ; Output character stored in R0

; Data storage
NUM1 .FILL x3335     ; First number (5)
NUM2 .FILL x3333     ; Second number (3)
VALUEADDR .FILL x3100 ; Address for value storage
RESULT .FILL x3000   ; Placeholder for result
FUNCADDR .FILL x3014 ; Address of subroutine
.END
