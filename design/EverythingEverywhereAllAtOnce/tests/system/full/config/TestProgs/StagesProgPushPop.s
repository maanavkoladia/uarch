.org 0x1000
.code
.global _start

_start:

    # ---------------------------------
    # Initialize stack (no LEA)
    # ---------------------------------
    movl $0x3000, %esp

    # ---------------------------------
    # Initialize segment registers
    # ---------------------------------
    movw $0x0010, %ax
    movw %ax, %ds
    movw %ax, %es
    # movw %ax, %ss

    movw $0x0020, %ax
    movw %ax, %fs
    movw %ax, %gs

    # ---------------------------------
    # TEST 1: PUSH r32
    # ---------------------------------
    movl $0x11111111, %eax
    movl $0x22222222, %ebx

    pushl %eax
    pushl %ebx

    popl %ecx    # EXPECT: 0x22222222
    popl %edx    # EXPECT: 0x11111111

    # ---------------------------------
    # TEST 2: PUSH imm32
    # ---------------------------------
    pushl $0x12345678

    popl %ecx    # EXPECT: 0x12345678

    # ---------------------------------
    # TEST 3: PUSH imm8 (sign-extended)
    # ---------------------------------
    pushl $0x7F

    popl %ecx    # EXPECT: 0x0000007F

    # pushl $0x80
    .byte 0x6A, 0x80
    popl %ecx    # EXPECT: 0xFFFFFF80

    # ---------------------------------
    # TEST 4: PUSH imm16
    # ---------------------------------
    pushw $0xABCD
    popl %ecx    # EXPECT: lower 16 bits = 0xABCD

    # ---------------------------------
    # TEST 5: PUSH r16
    # ---------------------------------
    movw $0xAAAA, %ax
    pushw %ax

    popl %ecx    # EXPECT: lower 16 bits = 0xAAAA

    # ---------------------------------
    # TEST 6: PUSH segment registers
    # ---------------------------------

    push %ds
    popl %ecx    # EXPECT: 0x00000010

    push %es
    popl %ecx    # EXPECT: 0x00000010

    push %ss
    popl %ecx    # EXPECT: 0x00000010

    push %fs
    popl %ecx    # EXPECT: 0x00000020

    push %gs
    popl %ecx    # EXPECT: 0x00000020

    push %cs
    popl %ecx    # EXPECT: typically 0x00000008 (depends on your setup)

    # ---------------------------------
    # END: hold state for inspection
    # ---------------------------------
    hlt