.org 0x1000
.code
.global _start

_start:

    movl $0x11111111, %eax
    movl $0x22222222, %ebx
    movl $0x33333333, %ecx
    movl $0x44444444, %edx
    nop
    nop
    nop
    jmp target
    addl %eax, %ecx
    addl %ebx, %edx

target:
    addl %eax, %edx
    addl %ebx, %ecx
    hlt


.org 0x2000
.data
memval:
    .long 0xAAAAAAAA
