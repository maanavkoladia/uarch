.ORIG 0x1600

AND R0 R0 #0
AND R1 R1 #0
AND R2 R2 #0
AND R3 R3 #0

ADD R1 R1 #1

HALT
.END

;    .ORIG 0x1600
;
;    
;    ADD R6 R6 #-2 ; dec stack ptr 
;    STW R1 R6 #0 ; save R1
;
;    ADD R6 R6 #-2 ; dec stack ptr 
;    STW R2 R6 #0 ; put R2 on stack
;
;    ADD R6 R6 #-2 ; dec stack ptr 
;    STW R4 R6 #0 ; put R2 on stack
;
;    LEA R0 BADMAR ; get addr of bad addr
;    LDW R0 R0 #0 ; load bad addr
;    
;    AND R4 R4 #0 ; clear R4
;    ADD R4 R4 #8 ; should be a 8 at 0x4168 
;
;    AND R1 R1 #0 ; make z bit high
;
;    STW R4 R0 #0 ; try to store at bad addr, throw unalgined 
;    
;    BRz STOREVAL ; z bit shoudl stil be high after the exception handler
;
;    HALT
;
;
;STOREVAL lea r2 BRGOOD
;        LDW r2 r2 #0
;
;        AND r1 r1 #0
;        ADD r1 r1 #10
;
;        STW  r1 r2 #0
;
;        lea r0 GOODMAR
;        ldw r0 r0 #0
;
;        LDW R4 R6 #0 ; restore R2
;        ADD R6 R6 #2 ; incremnt ssp
;
;        LDW R2 R6 #0 ; restore R2
;        ADD R6 R6 #2 ; incremnt ssp
;
;        LDW R1 R6 #0 ; restore R1
;        ADD R6 R6 #2 ; incremnt ssp
;
;        RTI
;
;BADMAR .FILL 0x4169 ;shoudl put a 4 here
;GOODMAR .FILL 0xC014
;BRGOOD .FILL 0x4164 ;should put a "a" here
;
;   .END


;    .ORIG 0x1600
;    LEA R0 GOODMDR
;    LDW R0 R0 #0
;    RTI
;
;BADMDR .FILL 0xC017
;GOODMDR .FILL 0xC014
;   .END
