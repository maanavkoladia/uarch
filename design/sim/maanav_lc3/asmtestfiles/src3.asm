.ORIG x3000
    LEA R1 NUM1          ; Load the first number into R1
    LEA R2 NUM2          ; Load the second number into R2
    LEA R3 RESULT

    LDB R1 R1 #0
    LDB R2 R2 #0

    ADD R2 R1 R2         ; Add R1 and R2, store the result in R3
    STW R2 R3 #0        ; Store the result in memory
    HALT

NUM1    .FILL x0005     ; First number 5
NUM2    .FILL x0003     ; Second number 3
RESULT  .FILL x0000     ; Placeholder for result
.END
