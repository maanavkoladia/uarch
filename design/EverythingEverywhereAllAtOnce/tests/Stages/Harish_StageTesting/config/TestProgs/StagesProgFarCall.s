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
    movl $0x50, %esp

    # =================================================
    # TEST 1: CALL rel32 (E8 cd)
    # =================================================
    movl $0x11111111, %eax

    call T1_func

    # If CALL works, control returns here manually
T1_return:
    # EXPECT after return:
    # EBX = return address (popped in callee)
    # EAX = 0xAAAAAAAA (set in callee)

    jmp T2_start


T1_func:
    # ---------------------------------
    # Inside callee
    # ---------------------------------
    # popl %ebx
    # EXPECT: EBX = address of T1_return

    movl $0xAAAAAAAA, %eax
    ret
    # jmp T1_return     # manual "ret"


# =================================================
# TEST 2: CALL rel32 (fall-through must NOT execute)
# =================================================
T2_start:

    movl $0x22222222, %ecx

    call T2_func

    movl $0xDEADBEEF, %ecx   # SHOULD NOT EXECUTE

T2_after:
    # EXPECT:
    # ECX = 0xBBBBBBBB

    jmp T3_start


T2_func:
    # popl %edx
    # EXPECT: EDX = address of T2_after

    movl $0xBBBBBBBB, %ecx

    # jmp T2_after
    ret


# =================================================
# TEST 3: Back-to-back CALLs (stack correctness)
# =================================================
T3_start:

    movl $0x33333333, %eax

    call T3_func1

T3_after:
    # EXPECT:
    # EAX = 0xCCCCCCCC

    jmp T4_start


T3_func1:
    # popl %ebx          # return addr of T3_after

    call T3_func2      # nested call

    # SHOULD NOT REACH HERE if nested call returns correctly
return_loc:
    movl $0xDEADBEEF, %eax
    # jmp T3_after
    ret


T3_func2:
    # popl %ecx          # return addr inside func1

    movl $0xCCCCCCCC, %eax

    # jmp return_loc          # return to func1 continuation
    ret

# =================================================
# TEST 4: CALL rel16 (operand-size override)
# =================================================
# NOTE:
# This depends on your assembler emitting 0x66 prefix.
# If not, you may need to encode manually.

T4_start:

    movl $0x44444444, %edx

    call T4_func

    movl $0xDEADBEEF, %edx   # SHOULD NOT EXECUTE

T4_after:
    # EXPECT:
    # EDX = 0xDDDDDDDD

    jmp done


T4_func:
    popl %eax
    # EXPECT: EAX = address of T4_after (lower 16 bits valid if rel16)

    movl $0xDDDDDDDD, %edx

    jmp T4_after


# =================================================
# FINAL STATE
# =================================================
done:
    # EXPECT FINAL:
    # EAX = (return addr from T4)
    # EBX = (return addr from T1)
    # ECX = (intermediate return addr)
    # EDX = 0xDDDDDDDD

    hlt