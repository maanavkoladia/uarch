#define __CS__ 0x0000
#define __DS__ 0x4002
#define __SS__ 0xF000


.org 0x00000000
.code
.global _start

_start:

    addb $1, %al
    addl %eax, %eax
    addl %eax, %eax
    hlt

