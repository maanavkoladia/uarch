.org 0x1000
.code
.global _start

# =================================================
# Segment selector assumptions
# =================================================
# Assumes a flat-like setup where both selectors map
# to the same linear base (so offsets are portable).
# Adjust CS_MAIN / CS_ALT to match your GDT.
# =================================================
.equ CS_MAIN, 0x08
.equ CS_ALT,  0x10

_start:

    # =================================================
    # TEST 0: Known state
    # =================================================
    movl $0, %eax
    movl $0, %ebx
    movl $0, %ecx
    movl $0, %edx
    movl $0, %ebp
    movl $0x200, %esp


    # =================================================
    # TEST 1: Far CALL ptr16:32 (9A cp)
    # =================================================
    # Stack delta on entry to callee (32-bit operand):
    #   [ESP+4] = saved CS (16-bit selector, zero-padded to 32)
    #   [ESP+0] = return EIP
    # =================================================
    movl $0x11111111, %eax
    movl %esp, %ebp            # snapshot ESP for later check

    lcall $CS_MAIN, $T1_func

    # If LCALL works, control returns here manually
T1_return:
    # EXPECT after far return:
    #   EAX = 0xAAAAAAAA (set in callee)
    #   EBX = saved CS   (popped in callee)
    #   ECX = address of T1_return (popped in callee)
    #   ESP = EBP (fully unwound)

    jmp T2_start


T1_func:
    # ---------------------------------
    # Inside far callee
    # ---------------------------------
    # popl %ecx        # return EIP
    # popl %ebx        # return CS (low 16 bits = selector)
    # pushl %ebx       # restore for LRET
    # pushl %ecx       # restore for LRET
    # EXPECT: ECX = T1_return, (EBX & 0xFFFF) = CS_MAIN

    movl $0xAAAAAAAA, %eax
    lret                        # far return: pop EIP, then CS


    # =================================================
    # TEST 2: Far CALL fall-through must NOT execute
    # =================================================
T2_start:

    movl $0x22222222, %ecx

    lcall $CS_MAIN, $T2_func

    movl $0xDEADBEEF, %ecx      # SHOULD NOT EXECUTE

T2_after:
    # EXPECT:
    #   ECX = 0xBBBBBBBB

    jmp T3_start


T2_func:
    movl $0xBBBBBBBB, %ecx
    lret                        # must land at T2_after, not fall-through


    # =================================================
    # TEST 3: Back-to-back / nested far CALLs
    # =================================================
    # Verifies stack correctness with CS+EIP pairs:
    # each LCALL pushes 8 bytes, each LRET pops 8.
    # =================================================
T3_start:

    movl $0x33333333, %eax
    movl %esp, %ebp             # snapshot ESP before nested chain

    lcall $CS_MAIN, $T3_func1

T3_after:
    # EXPECT:
    #   EAX = 0xCCCCCCCC
    #   ESP = EBP (fully unwound, no leaked CS/EIP frames)

    jmp T4_start


T3_func1:
    # Stack: [ ret_EIP_1 | ret_CS_1 ]

    lcall $CS_MAIN, $T3_func2   # nested far call

    # SHOULD NOT REACH a bad path if nested LRET is correct
return_loc:
    # Must land here after inner LRET; then LRET below
    # unwinds to T3_after.
    lret


T3_func2:
    # Stack: [ ret_EIP_2=return_loc | ret_CS_2 |
    #         ret_EIP_1             | ret_CS_1 ]

    movl $0xCCCCCCCC, %eax
    lret                        # must land at return_loc


    # =================================================
    # TEST 4: Indirect far CALL m16:32 (FF /3)
    # =================================================
    # Memory operand layout:
    #   offset (4 bytes) then segment (2 bytes)
    # =================================================
T4_start:

    movl $0x44444444, %eax
    movl %esp, %ebp

    lcall *T4_far_ptr           # indirect far call through memory

    movl $0xDEADBEEF, %eax      # SHOULD NOT EXECUTE

T4_after:
    # EXPECT:
    #   EAX = 0xDDDDDDDD
    #   ESP = EBP

    jmp T5_start


T4_far_ptr:
    .long T4_func               # 32-bit offset
    .word CS_MAIN               # 16-bit selector


T4_func:
    movl $0xDDDDDDDD, %eax
    lret


    # =================================================
    # TEST 5: Far RET imm16 (CA iw) — callee cleans args
    # =================================================
    # Caller pushes N bytes of args. Callee does LRET $N,
    # which pops EIP, pops CS, then adds N to ESP.
    # =================================================
T5_start:

    movl $0x55555555, %ecx
    movl %esp, %ebp             # snapshot ESP (pre-push)

    pushl $0x22222222           # arg2
    pushl $0x11111111           # arg1

    lcall $CS_MAIN, $T5_func

T5_after:
    # EXPECT:
    #   ECX = 0xEEEEEEEE
    #   ESP = EBP   (args were reclaimed by LRET $8,
    #                NOT by the caller)

    jmp T6_start


T5_func:
    # Stack on entry:
    #   [ESP+0]  = ret EIP
    #   [ESP+4]  = ret CS
    #   [ESP+8]  = arg1  (0x11111111)
    #   [ESP+12] = arg2  (0x22222222)

    # movl 8(%esp),  %eax       # sanity: should be 0x11111111
    # movl 12(%esp), %ebx       # sanity: should be 0x22222222

    movl $0xEEEEEEEE, %ecx
    lret $8                     # pop EIP, pop CS, ESP += 8


    # =================================================
    # TEST 6: Inter-segment far CALL (actual CS change)
    # =================================================
    # Requires CS_ALT to be a valid, executable selector
    # whose base matches CS_MAIN's so the offset resolves.
    # =================================================
T6_start:

    movl $0x66666666, %edx
    movw %cs, %bx               # record CS before call (low 16 bits of EBX)

    lcall $CS_ALT, $T6_func_alt

T6_after:
    # EXPECT:
    #   EDX = 0xFFFFFFFF
    #   (CS low 16) == CS_MAIN  (restored by LRET popping saved CS)

    jmp T7_start


T6_func_alt:
    # Inside the alternate segment.
    # A conforming emulator must have loaded CS = CS_ALT here.
    # movw %cs, %ax             # EXPECT: AX == CS_ALT

    movl $0xFFFFFFFF, %edx
    lret                        # pops EIP then CS, restoring CS_MAIN


    # =================================================
    # TEST 7: Operand-size override on far CALL (66 9A)
    # =================================================
    # 16-bit operand form pushes 16-bit CS and 16-bit IP.
    # Use `data16 lcall` (or `lcallw`) if your assembler
    # supports it; otherwise hand-encode: .byte 0x66,0x9A,...
    # =================================================
T7_start:

    movl $0x77777777, %eax
    movl %esp, %ebp

    # Pick one your assembler accepts:
    # data16 lcall $CS_MAIN, $T7_func
    lcallw $CS_MAIN, $T7_func

    movl $0xDEADBEEF, %eax      # SHOULD NOT EXECUTE

T7_after:
    # EXPECT (depending on emulator's 16-bit far-call behavior):
    #   EAX = 0x77777777_low16-cleared | 0x7777 merged per impl,
    #         then overwritten to 0x99999999 inside callee
    #   Specifically: EAX = 0x99999999
    #   ESP = EBP

    jmp done


T7_func:
    # With the 0x66 prefix, only IP (low 16 of EIP) was pushed,
    # and CS was pushed as 16 bits. A matching `lretw` is required.
    movl $0x99999999, %eax
    lretw                       # 16-bit far return


    # =================================================
    # FINAL STATE
    # =================================================
done:
    # EXPECT FINAL:
    #   EAX = 0x99999999        (TEST 7)
    #   EBX = (low 16) = CS_MAIN saved in TEST 6 path,
    #         upper bits possibly clobbered by TEST 1 pop sequence
    #         if those lines are uncommented
    #   ECX = 0xEEEEEEEE        (TEST 5)
    #   EDX = 0xFFFFFFFF        (TEST 6)
    #   ESP = 0x200             (fully restored)
    #   CS  = CS_MAIN

    hlt