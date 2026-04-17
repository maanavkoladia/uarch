.org 0x1000
.code
.global _start

_start:
    # ----------------------------
    # Initialize registers
    # ----------------------------
    movl $0x11111111, %eax      # EAX (also used by CMPXCHG)
    movl $0x22222222, %ebx
    movl $0x50, %esp
    movl $0x33333333, %ecx
    movl $0x44444444, %edx
    movl $0x55555555, %esi
    movl $0x66666666, %edi

    pushl %eax
    popl %ebx

    hlt