.org 0x1000
    .code

    .global _start
_start:

    addw $0xDEAD, %ax
    addl %ebx, %ecx

    # 3) ADD [EDX*2 + EDI + 0x12345678], EAX x1006
    addl %eax, 0x00005678(%edi,%edx,2)
    addl 0x00005678(%edi,%edx,2), %esi

    addl %edi, %ebx

    hlt


    .org 0x5670
    .data
val_1:  .long  0x11111111
val_2:  .long  0x22222222
val_a:  .long  0xAABBCCDD
val_b:  .long  0xBEEFDEAD