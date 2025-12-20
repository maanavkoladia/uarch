.ORIG 0x1400

AND R0 R0 #0
AND R1 R1 #0
AND R2 R2 #0
AND R3 R3 #0

ADD R2 R2 #1

HALT

.END



;.ORIG 0x1400
;
;;//////// CONTEXT SAVE ////////
;    ADD R6 R6 #-2    
;    STW R0 R6 #0     
;
;    ADD R6 R6 #-2    
;    STW R1 R6 #0     
;
;    ADD R6 R6 #-2    
;    STW R2 R6 #0     
;    
;    LEA R0 PTBR
;    LDW R0 R0 #0
;
;    LEA R1 PAGENUM
;    LDW R1 R1 #0
;
;    LSHF R1 R1 #1 ; account for 16bit works
;
;    ADD R0 R0 R1 ; get addr of pte
;
;    LDW R2 R2 #0 ; get PTE
;
;    ADD R2 R2 #4 ; set valid bit[2] high
;
;    STW R2 R0 #0
;
;;//////// CONTEXT RESTORE ////////
;    LDW R2 R6 #0       
;    ADD R6 R6 #2       
;
;    LDW R1 R6 #0       
;    ADD R6 R6 #2       
;
;    LDW R0 R6 #0       
;    ADD R6 R6 #2       
;
;RTI
;
;PTBR .FILL 0x1000
;PAGENUM .FILL #32
;.END
