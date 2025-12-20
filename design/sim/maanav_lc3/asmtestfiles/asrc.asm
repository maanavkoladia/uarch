.ORIG x3000

BR skipedata
eData1 .FILL xa245;
eData2 .FILL x1
baddVerif .FILL #32767
passKeyLSB .FILL x3200
pskylsbext .FILL x1111
passKey2FW .FILL x0000; should contain x9686  (x300c = 12300)
skipedata nop

;Loading garbage into registers
LEA R0, eData1 ;r0 has address
LDW R0, R0, #0 ; r0 has 0xa245
AND R1, R1, #0 ; r1 has 0
LEA R2, data1  ; has address
LDW R3, R2, #0 ; r3 has 0xa138
AND R4, R4, #0 ; r4 has 0
NOT R4, R4     ; r4 has xffff
LDW R5, R2, #3 ; r5 has 0x7654
LDW R7, R2, #4 ; r7 has a 1

;start of testing
LEA R0, addData ; r0 has address
LDW R0, R0, #0 ; r0 has a 3
add R1, R0, #0  ; r1 has a 3
brp afp1
HALT ; FAILED
afp1 NOT R0, R0 ; r0 has a 0xfffc, -4
add R0, R0, #1 ; r0 has a 0xfffd, -3
brn afp2 ;
HALT ; FAILED
afp2 add R1, R0, R1 ;r1 has a 0
brnp aff3
JSR aff4
aff3 HALT ; FAILED

aff4 LEA R5, adDataB ;r5 has address
LDW R5, R5, #0 ;r5 has #32752, 0x7ff0
add R5, R5, #15 ; r5 has 0x7fff
brnz baddf1 ;
JSR baddp1
baddf1 HALT ; FAILED

baddp1 LEA R0, baddVerif ; r0 has address
LDB R6, R0, #1 ; r6 has a 0x007f
LSHF R6, R6, #8 ; r6 should be 0x7f00
LDB R7, R0, #0 ; r7 has a 0x00ff
LSHF R7, R7, #8 ; r7 has a 0xff00
RSHFL R7, R7, #8 ; r7 has a 0x00ff
ADD R6, R6, R7 ;R6 should be equal to R5 = x7fff (IC=33)
NOT R6, R6 ; r6 is 0x8000
ADD R6, R6, #3 ; r6 has 0x8003
AND r6, r6, #-3 ; r6 has 0x8001
XOR R6, R6, #1 ; r6 has 0x8000
ADD R6, R6, #1 ; R6 should have -R5 = x8001 (IC=38)
ADD R0, R6, R5 ; r0 has a 0
AND R1, R1, #0 ; r1 cleared again
ADD R1, R1, #1 ; r1 has a 1
LSHF R1, R1, #15 ; r1 has a 0x8000
BRn shfp43p
HALT; FAILED
shfp43p RSHFA R1, R1, #15 ; r1 has a 0xffff
RSHFL R1, R1, #1 ; R1 = x7fff (IC=45)
ADD R0, R0, R1 ; r0 has a 0x7fff
ADD R0, R0, R6 ; r0 has a 0
BRnp cumf78 ;
brnzp cump78
cumf78 HALT; FAILED
cump78 RSHFA R1, R1, #14 ; R1 should be 1
ADD R7, R1, #-1 ; r7 is a 0
BRz rshfa987p
HALT; FAILED
rshfa987p NOP; TEST HAS PASSED
LEA R0, passKeyMSB ; r0 has address
LDB R1, R0, #0 ; r1 has a x17
LSHF R1, R1, #8 ; r1 has a x1700
LEA R0, pskylsbext ; r0 has address
LDB R0, R0, #-1 ; r0 has 0x0032
ADD R1, R1, R0 ; R1 should have x1732 (IC=59)
LEA R7, passKeyF ; r7 has address
STW R1, R7, #0 ; store r1 at [r7]
LDW R0, R7, #0 ; r0 is 0x1732
LDW R2, R7, #0 ; r0 is 0x1732
LDW R3, R7, #0 ; r0 is 0x1732
LDW R4, R7, #0 ; r0 is 0x1732
LDW R5, R7, #0 ; r0 is 0x1732
LDW R6, R7, #0 ; TEST PASSED (IC=67) ;All but R7 should have x1732 and passKeyF should have x1732
;//Cycle count 770?
;//TRAP x25; TEST OVER (IC= 68) PHASE 1 HAS PASSED!

;PHASE 2
;TESTING JMP Routines
AND R5, R5, #0 ;counter for jumps, r5 has 0
AND R7, R7, #0 ; r7 has 0
ADD R7, R7, #-1 ; r7 has -1
XOR R7, R7, #2 ; 0xfffd
AND R7, R7, #7 ;R7 should have 5
LEA R4, jmprotOk ; r4 has address
LEA R0, jmprot1 ; r0 has address
JMP R0
jmprotOk nop;R5 should be 1
;JSRR test
AND R7, R7, #0
ADD R7, R7, #12
jsr jmsrot1;
AND R7, R7, #0 ; R5 should be 2
ADD R7, R7, #13
LEA R4, jmsrot1
jsrr r4 ; R5 should be 3
LEA R7, jmpr7f1
ADD R7, R7, #2
jsrr r7 ; R5 should be 4 IC = 105
;R5 value check
add R5, R5, #-4
brz jumpspass
HALT ; FAILED

jumpspass nop ; JMP Routines have passed!! IC = 108
;TRAP x25 ; JMP PASSED IC = 109
; Generating 2nd pass token 9686
AND R6, R6, #0
XOR R6, R6, xd
LSHF R6, R6, #13 ; IC = 111
RSHFL R4, R6, #13 ; R4 should have 5
ADD R4, R4, #1; R4 should have 6
RSHFA R5, R6, #2; R5, 11101....
RSHFA R5, R5, #11; R5 = 11101
AND R5, R5, xF;
XOR R5, R5, #4; R5 = 9 IC=117
LSHF R6, R4, #8
ADD R6, R6, R4
LSHF R5, R5, #12

ADD R6, R6, R5; R6 = x9606 IC = 121
AND R4, R4, #0 ; clear r4
ADD R4, R4, #-16 ; r4 gets -16
LSHF R4, R4, #3 ; r4 gets a -32
LSHF R4, R4, #8 ; 
RSHFL R4, R4, #8
ADD R6, R6, R4; R6 = x9686 // IC= 127 
LEA R0, passKey2FB
STB R6, R0, #0
RSHFL R4, R6, #8
LEA R0, passKeyF
STB R4, R0, #3 ; now passKey2FB should contain x9686
LEA R0, skipedata
STW R6, R0, #-1;  ;now passKey2FW should contain x9686
LEA R5, passKey2FW
LDW R5, R5, #0 ; R5 should have x9686
LEA R4, endlbl;
LDB R0, R4, #-1 ; should have x96;
LSHF R0, R0, #8
LDB R4, R4, #-2 ; should have xff86
LSHF R4, R4, #8
RSHFL R4, R4, #8
ADD R4, R4, R0 ; R4 should hvae x9686 // IC = 143
; Setting R0 to 460A
RSHFA R0, R5, #0 ; copying x9686 to R0
AND R7, R7, #0
ADD R7, R7, xD
LSHF R7, R7, #12
XOR R0, R0, R7 ; R0 = x4686
LEA R7, endlbl
LDW R7, R7, #0
ADD R0, R0, R7
HALT ;TEST OVER PASSED // IC = 152

; PASS RESULTS:
;R0 should contain         x460A
;R1, R2, R3 should contain x1732
;R4, R5, R6 shuld contain  x9686
; M(x300c = 12300) should contain x9686
; M(x3150 = 12624) should contian x1732
; M(x3152 = 12626) should contain x9686
; IC = 152

jmprot1 ADD R7, R7, #-5
BRnp jmpr7f1
NOP
NOP
ADD R5, R5, #1
ADD R7, R7, R4
RET
jmpr7f1 HALT; FAILED

jmsrot1 ADD R5, R5, #1
nop
nop
RET
HALT; FAILED

;initally have garbage values
data1 .FILL xa138
data2 .FILL x1
data3 .FILL x1
data4 .FILL x7654
data5 .FILL x0001

addData .FILL x3
adDataB .FILL #32752
passKeyMSB .FILL x17
passKeyF .FILL xFFFF ; should be replaced with correct pass key x1732 (R7 + 16)
passKey2FB .FILL x0000; should be replaced with passk key x9686
endLbl .FILL #-124;
.END
