.ORIG 0x1A00

ADD R0 R0 #-1

;mark it ran
LEA R4 FLAG
LDW R4 R4 #0
AND R3 R3 #0
ADD R3 R3 #4
STW R3 R4 #0

RTI

BADADDR .FILL 0x300D
GOODADDR .FILL 0x300C

FLAG .FILL 0x3014
.END

;    .ORIG 0x1A00
;
;    ADD R6 R6 #-2 ; dec stack ptr 
;    STW R1 R6 #0 ; save R1
;
;    ADD R6 R6 #-2 ; dec stack ptr 
;    STW R2 R6 #0 ; put R2 on stack
;
;
;    ADD R0 R0 #-1 ; shoudl make the p bit go high
;    
;    lea r1 PROTHERE
;    ldw r1 r1 #0
;
;    and r2 r2 #0
;    add r2 r2 #6
;
;    stw r2 r1 #0
;
;    LDW R2 R6 #0 ; restore R2
;    ADD R6 R6 #2 ; incremnt ssp
;
;    LDW R1 R6 #0 ; restore R1
;    ADD R6 R6 #2 ; incremnt ssp
;
;    RTI
;
;PROTHERE .FILL 0x4160 ; will put a 6 here
;
;; VM : mdump 0x2d60 0x2d68
;    .END


;    .ORIG 0x1A00
;
;    ;.fill 0xA000 ; illegal opcode
;
;    ADD R4 R4 #-1
;    ADD R5 R5 #7 ; clobber r5
;    RTI
;
;    .END


;.ORIG 0x1A00
;ADD R0 R0 #-1
;RTI
;.END
