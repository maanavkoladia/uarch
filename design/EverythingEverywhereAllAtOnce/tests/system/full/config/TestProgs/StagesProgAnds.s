.org 0x1000
    .code

    .global _start
_start:

    mov $dataA, %eax
    mov (%eax), %ebx
    andl $0xFFFF, %ebx 

    hlt


    .org 0x5670
    .data
dataA: .long  0x11111111
  .long  0x22222222
  .long  0xAABBCCDD
  .long  0xBEEFDEAD