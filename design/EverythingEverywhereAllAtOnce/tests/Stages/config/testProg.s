.org 0x1000
    .text

    .global _start
_start:

    # 1) ADD AX, 0xDEAD
    addw $0xDEAD, %ax

    # 2) ADD ECX, EBX
    addl %ebx, %ecx

    # 3) ADD [EDX*2 + EDI + 0x12345678], ESI
    addl %esi, 0x12345678(%edi,%edx,2)

    # 4) ADD EBX, EDI
    addl %edi, %ebx


    .org 0x2000
    .data

val_a:  .long  0xDEADBEEF
val_b:  .long  0x0000CAFE
