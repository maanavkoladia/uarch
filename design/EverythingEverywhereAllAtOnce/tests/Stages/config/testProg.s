.org 0x1000
    .text

    .global _start
_start:

    # 1) ADD AX, 0xABCD
    addw $0xDEAD, %ax

    # 2) ADD ECX, EBX
    addl %ebx, %ecx

    # 3) ADD [EDX*2 + EDI + 0x12345678], ESI
    addl %eax, 0x00005678(%edi,%edx,2)

    # 3) ADD ESI, [EDX*2 + EDI + 0x12345678]
    addl 0x00005678(%edi,%edx,2), %esi

    # 4) ADD EBX, EDI
    addl %edi, %ebx

    hlt


    .org 0x2000
    .data
val_1:  .long  0x11111111
val_2:  .long  0x22222222
val_a:  .long  0xAABBCCDD
val_b:  .long  0xBEEFDEAD
