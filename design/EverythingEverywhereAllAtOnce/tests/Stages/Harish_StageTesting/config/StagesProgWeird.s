.org 0x1000
.code
.global _start

_start:
    # # ----------------------------
    # # Initialize registers
    # # ----------------------------
    # movl $0x11111111, %eax      # EAX (also used by CMPXCHG)
    # movl $0x22222222, %ebx
    # movl $0x50, %esp
    # movl $0x33333333, %ecx
    # movl $0x44444444, %edx
    # movl $0x55555555, %esi
    # movl $0x66666666, %edi

    # pushl %eax
    # popl %ebx

    # hlt

    # ----------------------------
    # CASE 1: CF = 1 → CMOVC should move
    # ----------------------------
    movl $0xFFFFFFFF, %eax      # large value
    movl $0x1, %ebx

    addl %ebx, %eax             # 0xFFFFFFFF + 1 → 0x00000000, CF = 1

    movl $0x12345678, %ecx      # source
    movl $0x0, %edx             # destination (initially 0)

    cmovcl %ecx, %edx           # EXPECT: EDX = 0x12345678

    # ----------------------------
    # CASE 2: CF = 0 → CMOVC should NOT move
    # ----------------------------
    movl $0x1, %eax
    movl $0x1, %ebx

    addl %ebx, %eax             # 1 + 1 = 2, CF = 0

    movl $0xAAAAAAAA, %ecx      # source
    movl $0x0, %edx             # reset destination

    cmovcl %ecx, %edx           # EXPECT: EDX stays 0

    # ----------------------------
    # CASE 3: CF = 1 again (sanity repeat)
    # ----------------------------
    movl $0xFFFFFFFF, %eax
    movl $0x2, %ebx

    addl %ebx, %eax             # overflow → CF = 1

    movl $0xDEADBEEF, %ecx
    movl $0x0, %edx

    cmovcl %ecx, %edx           # EXPECT: EDX = 0xDEADBEEF

    hlt