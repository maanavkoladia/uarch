.org 0x1000
.code
.global _start

_start:

    movl $0x11111111, %eax
    movl $0x22222222, %ebx
    movl $0x2000, %esi
    movl (%esi), %ecx        # ecx now shuld have 0x66660000
    addl $0x4, %esi

    jmp target
    addl %eax, %ecx
    addl %ebx, %edx         # should not see x2222 in edx

target:
    addl %eax, %ecx         # x44444444 in ecx
    addl (%esi), %ecx       # x88888888 in ecx
    xchgl %ebx, %eax

    hlt


.org 0x2000
.data
memval:
    .long 0x33333333
    .long 0x44444444
    .long 0x55555555
    .long 0x66666666