.org x1000
    .code

    .global _start
_start:

    # 1) ADD AX, 0xDEAD
    addw $0xDEAD, %ax

    # 2) ADD ECX, EAX
    addl %eax, %ecx

# infinite loop (halt)
loop:
    jmp loop