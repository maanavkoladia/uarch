.ORIG x3000               ; Start of the program
    LEA r0 data 
    ldw r0 r0 #0
    lea r1 loc
    ldw r1 r1 #0
    stb r0 r1 #1
    stb r0 r1 #2
    halt
data .FILL 0x0077
loc .FILL 0x3150
.end
