.org 0x1000
    .text

    .global _start
_start:

    # 1) ADD AX, 0xABCD
    addw $0xDEAD, %ax

    # 2) ADD ECX, EBX
    addl %ebx, %ecx

    # 3) ADD [EDX*2 + EDI + 0x12345678], ESI
    addl %esi, 0x00005678(%edi,%edx,2)

    # 4) ADD EBX, EDI
    addl %edi, %ebx


    .org 0x5670
    .data

val_a:  .long  0xAABBCCDD
val_b:  .long  0xBEEFDEAD
