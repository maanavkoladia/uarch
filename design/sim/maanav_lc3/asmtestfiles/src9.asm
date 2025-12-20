 ;program to multiply two unsingned bytes

            .ORIG x3000

            LEA R2 In1Loc; ex 2
            LDW R2 R2 #0
            LDB R2 R2 #0
            BRz ZEROCASE


            LEA R0 In2Loc ;ex: 5
            LDW R0 R0 #0
            LDB R0 R0 #0
            BRz ZEROCASE


            AND R4 R4 #0 ; clear R4


LOOP        ADD R4 R4 R0 ; add
            ADD R2 R2 #-1; repeat


            BRnz STORE
            BR LOOP



STORE       LEA R3 OutLoc
            LDW R3 R3 #0
            STB R4 R3 #0 ;storing result ask luke: STW or STB

            LEA R3 Mask
            LDW R3 R3 #0 ; get mask
            AND R4 R4 R3 ; clears 0-7 leaves 8-15 unchanged
            BRz NOOVERFLOW
            BR OVERFLOW


OVERFLOW    AND R1 R1 #0
            ADD R1 R1 #1
            LEA R3 OFLoc
            LDW R3 R3 #0
            STB R1 R3 #0
            BR DONE

NOOVERFLOW  AND R1 R1 #0 ;set r1 to 0
            LEA R3 OFLoc
            LDW R3 R3 #0
            STB R1 R3 #0 ;store 0 to OFLoc
            BR DONE

ZEROCASE    AND R1 R1 #0
            LEA R3 OutLoc
            LDW R3 R3 #0
            STB R1 R3 #0 ;storing result
            BR NOOVERFLOW
DONE        HALT

Mask    .fill xFF00
In1Loc  .fill x3100
In2Loc  .fill x3101
OutLoc  .fill x3102
OFLoc .fill x3103

.END
