    .ORIG 0x3000
    
    LEA R6 USERSP
    LDW R6 R6 #0

    ; Load starting address
    LEA R0 STARTHERE 

    ;add r0 r0 #1 ; unalinged
    
    LDW R0 R0 #0 

    ; Load number of iterations
    LEA R2 ITERATIONS
    LDW R2 R2 #0 

    AND R3 R3 #0 ; Clear R3 for running sum

LOOP LDB R1 R0 #0 ; Get first number

    ADD R3 R3 R1 ; Add to running sum 
    ADD R0 R0 #1 ; Move to next byte

    ADD R2 R2 #-1 ; Decrement count
    BRNP LOOP       ; Repeat if not zero
    
    ; Store sum at SUMADDR location
    LEA R0 SUMADDR
    LDW R0 R0 #0
    
    ;AND R0 R0 #0  ; unpriledged access
    ;ADD R0 R0 #1 ; unalinged exception
    ;.fill 0xA000    ;illgal opcode
    ;LEA R0 PAGEFAULT
    ;LDW R0 R0 #0
    ;add r4 r4 #2
    
    STW R3 R0 #0 ; Store result (R3) into sum address

    ;AND R3 R3 #0
    JMP R3
    ;add r4 r4 #4
    HALT

; Memory Locations
INTADDR .FILL 0x4000
ITERATIONS .FILL #20
STARTHERE .FILL 0xC000
SUMADDR .FILL 0xC014
USERSP .FILL 0xFE00
PAGEFAULT .FILL 0x5000
.END


; mdump 0x3800 0x3820
