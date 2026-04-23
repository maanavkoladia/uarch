.org 0x1000
    .code

    .global _start
_start:
    movl $0, %eax
    movl $0, %ebx
    movl $0, %ecx
    movl $0, %edx
    movl $0x5670, %esi
    movl $0x2000, %edi
    movl $0, %ebp

    movsl
    movl (%edi), %eax
    movsl
    movl (%edi), %eax
    movsl
    movl (%edi), %eax
    movsl
    movl (%edi), %eax

    hlt


.org 0x5670
    .data
val_1:  .long  0x11111111
val_2:  .long  0x22222222
val_a:  .long  0xAABBCCDD
val_b:  .long  0xBEEFDEAD