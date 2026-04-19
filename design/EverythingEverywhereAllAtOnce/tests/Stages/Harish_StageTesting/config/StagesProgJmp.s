.org 0x1000
.code
.global _start

_start:

    # =================================================
    # TEST 0: Known starting point
    # =================================================
    movl $0, %eax
    movl $0, %ebx
    movl $0, %ecx
    movl $0, %edx

    # =================================================
    # TEST 1: JMP rel8 (EB) — always taken
    # =================================================
    movl $0x11111111, %eax

    jmp T1_target

    movl $0xDEADBEEF, %eax    # SHOULD NOT EXECUTE

T1_target:
    # EXPECT: EAX = 0x11111111


    # =================================================
    # TEST 2: JMP rel32 (E9)
    # =================================================
    movl $0x22222222, %ebx

    jmp T2_target

    movl $0xDEADBEEF, %ebx    # SHOULD NOT EXECUTE

T2_target:
    # EXPECT: EBX = 0x22222222


    # =================================================
    # TEST 3: JNE rel8 (taken case)
    # ZF = 0 → jump SHOULD be taken
    # =================================================
    movl $1, %ecx
    andl $1, %ecx     # result = 1 → ZF = 0

    movl $0x33333333, %ecx
    nop

    jne T3_taken

    movl $0xDEADBEEF, %ecx    # SHOULD NOT EXECUTE

T3_taken:
    # EXPECT: ECX = 0x33333333


    # =================================================
    # TEST 4: JNE rel8 (NOT taken case)
    # ZF = 1 → jump should NOT be taken
    # =================================================
    movl $0, %edx
    andl %edx, %edx   # result = 0 → ZF = 1

    movl $0x44444444, %edx

    jne T4_taken

    # fall-through path
    movl $0xAAAAAAAA, %edx   # SHOULD EXECUTE

    jmp T4_end

T4_taken:
    movl $0xDEADBEEF, %edx   # SHOULD NOT EXECUTE

T4_end:
    # EXPECT: EDX = 0xAAAAAAAA


    # =================================================
    # TEST 5: JNBE rel8 (taken case)
    # CF=0 and ZF=0 → jump SHOULD be taken
    # =================================================
    movl $1, %eax
    addl $1, %eax     # no carry, result != 0 → CF=0, ZF=0

    movl $0x55555555, %eax

    jnbe T5_taken

    movl $0xDEADBEEF, %eax   # SHOULD NOT EXECUTE

T5_taken:
    # EXPECT: EAX = 0x55555555


    # =================================================
    # TEST 6: JNBE rel8 (NOT taken: ZF=1)
    # =================================================
    movl $0, %ebx
    andl %ebx, %ebx   # ZF = 1

    movl $0x66666666, %ebx

    jnbe T6_taken

    movl $0xBBBBBBBB, %ebx   # SHOULD EXECUTE

    jmp T6_end

T6_taken:
    movl $0xDEADBEEF, %ebx   # SHOULD NOT EXECUTE

T6_end:
    # EXPECT: EBX = 0xBBBBBBBB


    # =================================================
    # TEST 7: JNBE rel8 (NOT taken: CF=1)
    # =================================================
    movl $0xFFFFFFFF, %ecx
    addl $1, %ecx     # overflow → CF=1, ZF=1

    movl $0x77777777, %ecx

    jnbe T7_taken

    movl $0xCCCCCCCC, %ecx   # SHOULD EXECUTE

    jmp T7_end

T7_taken:
    movl $0xDEADBEEF, %ecx   # SHOULD NOT EXECUTE

T7_end:
    # EXPECT: ECX = 0xCCCCCCCC


    # =================================================
    # TEST 8: JNE rel32 (0F 85 cd)
    # =================================================
    movl $1, %edx
    andl $1, %edx     # ZF=0

    movl $0x88888888, %edx

    jne T8_taken

    movl $0xDEADBEEF, %edx   # SHOULD NOT EXECUTE

T8_taken:
    # EXPECT: EDX = 0x88888888


    # =================================================
    # TEST 9: JNBE rel32 (0F 87 cd)
    # =================================================
    movl $1, %eax
    addl $1, %eax     # CF=0, ZF=0

    movl $0x99999999, %eax

    jnbe T9_taken

    movl $0xDEADBEEF, %eax   # SHOULD NOT EXECUTE

T9_taken:
    # EXPECT: EAX = 0x99999999


    # =================================================
    # FINAL STATE (easy inspection)
    # =================================================
    # EAX = 0x99999999
    # EBX = 0xBBBBBBBB
    # ECX = 0xCCCCCCCC
    # EDX = 0x88888888

    hlt