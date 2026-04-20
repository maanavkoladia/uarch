.org 0x1000
.code
.global _start

_start:

    # =================================================
    # TEST 0: Known state
    # =================================================
    movl $0, %eax
    movl $0, %ebx
    movl $0, %ecx
    movl $0, %edx
    movl $0x200, %esp


    # =================================================
    # TEST 1: CALL + RET (basic)
    # =================================================
    movl $0x11111111, %eax

    call T1_func

T1_after:
    # EXPECT: EAX = 0xAAAAAAAA

    jmp T2_start

    movl $0xDEADBEEF, %eax   # SHOULD NOT EXECUTE (dead code after jmp)


T1_func:
    movl $0xAAAAAAAA, %eax
    ret


    # =================================================
    # TEST 2: CALL + RET (correct return point)
    # =================================================
T2_start:

    movl $0x22222222, %ebx

    call T2_func

T2_after:
    # EXPECT: EBX = 0xBBBBBBBB

    jmp T3_start

    movl $0xDEADBEEF, %ebx   # SHOULD NOT EXECUTE (dead code after jmp)


T2_func:
    movl $0xBBBBBBBB, %ebx
    ret


    # =================================================
    # TEST 3: Nested CALL + RET
    # =================================================
T3_start:

    movl $0x33333333, %ecx

    call T3_func1

T3_after:
    # EXPECT: ECX = 0xCCCCCCCC

    jmp T4_start

    movl $0xDEADBEEF, %ecx   # SHOULD NOT EXECUTE (dead code after jmp)


T3_func1:
    call T3_func2
    # T3_func2's ret returns HERE (back into T3_func1), then we ret to T3_after
    ret


T3_func2:
    movl $0xCCCCCCCC, %ecx
    ret


    # =================================================
    # TEST 4: Sequential CALLs
    # =================================================
T4_start:

    movl $0x44444444, %edx

    call T4_func1
    call T4_func2

T4_after:
    # EXPECT: EDX = 0xEEEEEEEE

    jmp T5_start

    movl $0xDEADBEEF, %edx   # SHOULD NOT EXECUTE (dead code after jmp)


T4_func1:
    movl $0xAAAAAAAA, %edx
    ret


T4_func2:
    movl $0xEEEEEEEE, %edx
    ret


    # =================================================
    # TEST 5: Deep nesting (3 levels)
    # =================================================
T5_start:

    movl $0x55555555, %eax

    call T5_func1

T5_after:
    # EXPECT: EAX = 0xDDDDDDDD

    jmp done

    movl $0xDEADBEEF, %eax   # SHOULD NOT EXECUTE (dead code after jmp)


T5_func1:
    call T5_func2
    ret


T5_func2:
    call T5_func3
    ret


T5_func3:
    movl $0xDDDDDDDD, %eax
    ret


    # =================================================
    # FINAL VERIFICATION
    # =================================================
done:
    # EXPECTED FINAL STATE:
    #   EAX = 0xDDDDDDDD
    #   EBX = 0xBBBBBBBB
    #   ECX = 0xCCCCCCCC
    #   EDX = 0xEEEEEEEE

    hlt
