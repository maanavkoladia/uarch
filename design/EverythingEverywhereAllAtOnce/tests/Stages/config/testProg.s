.org 0x1000
    .text

    .global _start
_start:

    # 1) ADD AX, 0xABCD x1000
    addw $0xDEAD, %ax

    # 2) ADD ECX, EBX x1004
    addl %ebx, %ecx

    # 3) ADD [EDX*2 + EDI + 0x12345678], EAX x1006
    addl %eax, 0x00005678(%edi,%edx,2)

    # 4) x100d
    addl 0x00005678(%edi,%edx,2), %esi 

    # 4) ADD EBX, EDI x1014
    addl %edi, %ebx


    .org 0x5670
    .data
val_1:  .long  0x11111111
val_2:  .long  0x22222222
val_a:  .long  0xAABBCCDD
val_b:  .long  0xBEEFDEAD
