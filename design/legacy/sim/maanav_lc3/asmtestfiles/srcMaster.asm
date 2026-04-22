;program to implement 5x^2 + 8x - 9 + 10y^3 = z  x is at 04160 y is at 0x4162   store z at 0x4164, should see a 0x1374, 
;x is a word , y is a btye, z is word
;follow rules, return on R0, inputs in r0, r1, r2, r3
; VM : mdump 0x2d60 0x2d68
            .ORIG X3000               ; Start of the program
            LEA R0 ADDYX             ; Load the address of X into R0 ;0x3000
            LDW R0 R0 #0             ;0x3002
            LDW R0 R0 #0             ; x in r0 ; 0x3004

            and r3 r3 #0
            add r3 r0 r3

            jsr CREATE8              ; r0 should have a 8
            ;lshf r0 r0 #0
            and r1 r1 #0
            add r1 r3 r1

            ;AND R1 R1 #0
            ;ADD R1 R1 #8            ; 8 in R1

            JSR MULTI
            ;lshf r0 r0 #0
            AND R4 R4 #0
            ADD R4 R4 R0            ; add 8* 23 to sum, 184

            LEA R0 ADDYX             ; Load the address of X into R0
            LDW R0 R0 #0
            LDW R0 R0 #0             ; x in r0

            AND R1 R1 #0
            ADD R1 R1 #2


            JSR POWER               ; compute x^2

            ;LSHF R0 R0 #0

            AND R1 R1 #0
            ADD R1 R1 #5

            JSR MULTI               ;COMPUTE 5 * r0(X^2)
            ;LSHF R1 R1 #0

            ADD R4 R4 R0            ; add 5(23)^2 to sum, 1829
            ;LSHF R1 R1 #0


            JSR CREATENEG9
            ADD R4 R4 R0           ; add -9 to sum, 2820
            ;LSHF R1 R1 #0

            LEA R0 ADDYX
            LDW R0 R0 #0
            LDB R0 R0 #2 ; load y into r0

            and r1 r1 #0 ; clear r1
            add r1 r1 #3 ; put a 3 into r1

            JSR power ; from brnzp to JSR

            ;LSHF R0 R0 #0

            and r1 r1 #0;
            add r1 r1 #10; put a 10 into r1



            lea r2 multi


            jsrr r2 ; mulit hopefully
            ;LSHF R1 R1 #0

            add r4 r4 r0; add sum into r0

            lea r0 ADDYZ 
            LDW R0 R0 #0
            STW R4 R0 #0

            LEA R1 LSBMASK
            LDW R1 R1 #0
            
            AND R2 R4 R1 ; pull out lsb should be 0x0074
            STB R2 R0 #2

            RSHFL R2 R4 #8 ; put msbs into r2
            STB R2 R0 #3

            HALT




; POWER SUBROUTINE - CALCULATES BASE^EXPONENT, r0 base b1 exp
POWER       lea r5 ADDYLRPWR
            ldw r5 r5 #0
            stw r7 r5 #0             ; store link reg


            ADD R1 R1 #0            ; Check if the exponent is zero
            BRZ POWERISZERO         ; Branch if exponent is zero
            BRN POWERISNEG          ; Branch if exponent is negative


            AND R5 R5 #0            ; Clear R2 (base holder)
            ADD R5 R5 R0            ; Move base into R2

            AND R3 R3 #0            ; Clear R3 (exponent holder)
            ADD R3 R3 R1            ; Move exponent into R3

            AND R0 R0 #0            ; Clear R0 (result holder)
            ADD R0 R0 x1            ; Initialize result to 1


POWERLOOP   ADD R3 R3 #0            ; Check if exponent is zero
            BRZ PWRLOOPDONE         ; Exit loop if exponent is zero
            AND R1 R1 #0            ; Clear R1 (intermediate holder)
            ADD R1 R1 R5            ; Load base into R1


            jsr MULTI                ; Multiply current result by base
            ;LSHF R0 R0 #0
            ADD R3 R3 #-1           ; Decrement exponent
            BR POWERLOOP            ; Repeat the loop

POWERISZERO AND R0 R0 #0            ; Clear R0
            ADD R0 R0 #1            ; Result is 1 for 0 exponent
            BR PWRLOOPDONE          ; Exit

POWERISNEG  AND R0 R0 #0            ; Clear R0
            ADD R0 R0 #-1           ; Indicate error with -1
            BR PWRLOOPDONE          ; Exit

PWRLOOPDONE lea r1 ADDYLRPWR
            ldw r1 r1 #0
            ldw r7 r1 #0            ; load lr from mem
            jmp R7                 ; Return to caller

; MULTIPLY SUBROUTINE - MULTIPLIES TWO VALUES (R0 * R1)
MULTI       AND R2 R2 #0


MULTILOOP   ADD R2 R2 R0            ; Add R0 to itself
            ADD R1 R1 #-1           ; Decrement multiplier (R1)
            BRP MULTILOOP               ; Repeat until R1 reaches zero
PRODUCT     AND R0 R0 #0
            ADD R0 R0 R2

            RET                     ; Return to caller


CREATE8     LEA R0 LOC8              ;do testing to get an 8 from me
            LDW R0 R0 #0             ; r0 should have 159
            RSHFL R0 R0 #6
            LSHF R0 R0 #2            ; should have an eight now
            RET


 CREATENEG9 LEA R0 LOCNEG9
            and r1 r1 #0
            add r1 r1 r0
            LDW R0 R0 #0            ; addy
            LSHF R0 R0 #4           ; -64
            RSHFA R0 R0 #3          ; -8
            ldw r1 r1 #1            ; shoudl ahve -1 in r1
            rshfl  r1 r1 #15        ; shoudl now have a 1 in r1
            lshf r1 r1 #3           ; shoud lhave a 8 in r1
            add r0 r0 r1
            add r0 r0 #1            ; should ahve a -9 in r0

            not r0 r0
            add r0 r0 #1

            xor r0 r0 #-1
            add r0 r0 #1

            RET




; MEMORY LOCATIONS
ADDYX       .FILL x4160             ; Address of X
ADDYY       .FILL x4162             ; Address of Y
ADDYZ       .FILL x4164             ; Address to store Z
ADDYLRPWR   .fill x416a            ; address to store lr during power
;ADDYLRPWR   .fill x5000            ; address to store lr during power

LOC8        .fill #159
LOCNEG9     .fill #-9
NEG1LOC     .fill xFFFF            ; max neg
LSBMASK      .fill 0x00FF
            .END                    ; End of the program

