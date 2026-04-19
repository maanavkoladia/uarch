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


    # =================================================
    # TEST 1: CALL rel32 — basic control flow
    # =================================================
    movl $0x11111111, %eax

    call T1_func

T1_return:
    # EXPECT:
    # EAX = 0xAAAAAAAA

    jmp T2_start


T1_func:
    movl $0xAAAAAAAA, %eax
    jmp T1_return     # manual return


    # =================================================
    # TEST 2: CALL must skip fall-through
    # =================================================
T2_start:

    movl $0x22222222, %ebx

    call T2_func

    movl $0xDEADBEEF, %ebx   # SHOULD NOT EXECUTE

T2_after:
    # EXPECT:
    # EBX = 0xBBBBBBBB

    jmp T3_start


T2_func:
    movl $0xBBBBBBBB, %ebx
    jmp T2_after


    # =================================================
    # TEST 3: Back-to-back CALLs
    # =================================================
T3_start:

    movl $0x33333333, %ecx

    call T3_func1

T3_after:
    # EXPECT:
    # ECX = 0xCCCCCCCC

    jmp T4_start


T3_func1:
    movl $0x12345678, %edx   # intermediate write

    call T3_func2

    # SHOULD NOT EXECUTE if flow is correct
    movl $0xDEADBEEF, %ecx
    jmp T3_after


T3_func2:
    movl $0xCCCCCCCC, %ecx
    jmp T3_after


    # =================================================
    # TEST 4: CALL chaining (stack stress indirectly)
    # =================================================
T4_start:

    movl $0x44444444, %eax

    call T4_func1

T4_after:
    # EXPECT:
    # EAX = 0xDDDDDDDD

    jmp T5_start


T4_func1:
    movl $0xAAAA0000, %eax

    call T4_func2

    # SHOULD NOT EXECUTE
    movl $0xDEADBEEF, %eax
    jmp T4_after


T4_func2:
    movl $0xDDDDDDDD, %eax
    jmp T4_after


    # =================================================
    # TEST 5: CALL rel32 again (final sanity)
    # =================================================
T5_start:

    movl $0x55555555, %edx

    call T5_func

    movl $0xDEADBEEF, %edx   # SHOULD NOT EXECUTE

T5_after:
    # EXPECT:
    # EDX = 0xEEEEEEEE

    jmp done


T5_func:
    movl $0xEEEEEEEE, %edx
    jmp T5_after


    # =================================================
    # FINAL STATE
    # =================================================
done:
    # EXPECT FINAL:
    # EAX = 0xDDDDDDDD
    # EBX = 0xBBBBBBBB
    # ECX = 0xCCCCCCCC
    # EDX = 0xEEEEEEEE

    hlt