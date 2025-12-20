.ORIG 0x1200    

;//////// CONTEXT SAVE ////////
    ADD R6 R6 #-2    
    STW R0 R6 #0     

    ADD R6 R6 #-2    
    STW R1 R6 #0     

    ADD R6 R6 #-2    
    STW R2 R6 #0     

    ADD R6 R6 #-2    
    STW R3 R6 #0     

    ADD R6 R6 #-2    
    STW R4 R6 #0     

    ADD R6 R6 #-2    
    STW R5 R6 #0     

    ADD R6 R6 #-2    
    STW R7 R6 #0     

;//////// SETUP ////////
    LEA R0 PTADDR     
    LDW R0 R0 #0       ; R0 = start of page table

    LEA R1 PTSIZE      
    LDW R1 R1 #0       ; R1 = number of entries (assumed negative: -128)

    LEA R3 CLEARREF    
    LDW R3 R3 #0       ; R3 = mask to clear ref bit

    AND R2 R2 #0       ; R2 = counter = 0

;//////// LOOP ////////
LOOP LDW R4 R0 #0       ; R4 = current PTE
     AND R4 R4 R3       ; clear ref bit
     STW R4 R0 #0       ; write updated PTE back

     ADD R0 R0 #2       ; move to next PTE (word aligned)
     ADD R2 R2 #1       ; increment counter

     ; Check if we've hit 128 entries
     ADD R5 R2 R1       ; R5 = R2 + (-128)
     BRn LOOP           ; if R2 < 128, keep looping

;//////// CONTEXT RESTORE ////////
    LDW R7 R6 #0       
    ADD R6 R6 #2       

    LDW R5 R6 #0       
    ADD R6 R6 #2       

    LDW R4 R6 #0       
    ADD R6 R6 #2       

    LDW R3 R6 #0       
    ADD R6 R6 #2       

    LDW R2 R6 #0       
    ADD R6 R6 #2       

    LDW R1 R6 #0       
    ADD R6 R6 #2       

    LDW R0 R6 #0       
    ADD R6 R6 #2       

    RTI

;//////// DATA SECTION ////////
PTADDR   .FILL 0x1000
PTSIZE   .FILL #-128         ; Negative to use BRn loop logic
CLEARREF .FILL 0xFFFE        ; Mask to clear ref bit
.END
