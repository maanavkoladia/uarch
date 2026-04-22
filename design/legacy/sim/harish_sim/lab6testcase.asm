.ORIG x3000
ADD R0, R0, #-5
start ADD R0, R0, #4
BRn start
LEA R2, routine
LDW R2, R2, #0
JSR sub
LEA R1, addy
LDW R1, R1, #0
STW R0, R1, #0
HALT
addy .FILL x4000
routine .FILL x3050

sub LEA R5, addr
LDW R5, R5 #0
AND R6, R6, #0
ADD R6, R6, #1
NOT R6, R6
STW R6, R5, #0
RET
addr .FILL x4000
.END