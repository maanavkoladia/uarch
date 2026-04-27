#define __CS0__ 0x0000
#define __DS0__ 0x0500
#define __ES0__ 0x0400

.org 0x00000000
.code
.global _start

_start:

    /* ------------------------------------------------
       set data segment
       ------------------------------------------------ */
    movl    $__DS0__, %eax
    movw    %ax, %ds
    movl    $__ES0__, %eax
    movw    %ax, %es

    movl $0, %edi
    movl $0, %esi

    movl $4, %ecx

    rep movsl

    movl $0xDEADB00F, %ebx
    movl $0xCAFE1234, %edx
    addl $-16, %edi
    movl %es:(%edi), %eax

    hlt

/* ================================================================
   DATA SECTION - mapped at 0x0500
   ================================================================ */
.org 0x05000000
.data
    .long 0xDEF0DEF0
    .long 0x9ABC9ABC
    .long 0x56785678
    .long 0x12341234
    .long 0xDEF0DEF0
    .long 0x9ABC9ABC
    .long 0x56785678
    .long 0x12341234
    .long 0xDEF0DEF0
    .long 0x9ABC9ABC
    .long 0x56785678
    .long 0x12341234
    .long 0xDEF0DEF0
    .long 0x9ABC9ABC
    .long 0x56785678
    .long 0x12341234





/* ================================================================
   E SECTION - mapped at 0x0400
   ================================================================ */
.org 0x04000000
.data
    .long 0x11223344
    .long 0x55667788
    .long 0x99AABBCC
    .long 0xDDEEFF00
    .long 0x11223344
    .long 0x55667788
    .long 0x99AABBCC
    .long 0xDDEEFF00
    .long 0x11223344
    .long 0x55667788
    .long 0x99AABBCC
    .long 0xDDEEFF00
    .long 0x11223344
    .long 0x55667788
    .long 0x99AABBCC
    .long 0xDDEEFF00
