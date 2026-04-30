# ================================================================
# TEST 5: MIXED EDGE-CASE — Subtle Bug Hunter
# ================================================================
# LEGAL INSTRUCTIONS ONLY.
#
# Targets hard-to-find bugs:
#   - ADC/SBB carry chain correctness
#   - Flag interactions between consecutive instructions
#   - Partial register writes (AL/AH vs EAX) using MOV byte
#   - CMPXCHG flag side effects
#   - SAL/SAR flag behavior (CF from shifted-out bit, OF on 1-bit)
#   - CMOVC flag dependency timing
#   - Store-load forwarding correctness
#   - AND/OR/ADD flag differences (AND/OR clear CF; ADD may set it)
#   - AAA edge cases
#   - NOT not affecting flags
#   - Boundary values (0, 0xFFFFFFFF, 0x80000000)
#   - XCHG self = identity
#   - Manual memory copy via MOV (no REP MOVS)
#
# Segment Layout:
#   CS0 = 0x0000 -> base 0x00000000  (code, 2 pages)
#   CS1 = 0x0200 -> base 0x02000000  (far call target)
#   DS0 = 0x0300 -> base 0x03000000  (data)
#   SS0 = 0x0400 -> base 0x04000000  (stack)
# ================================================================

#define __CS0__ 0x0000
#define __CS1__ 0x0200
#define __DS0__ 0x0300
#define __SS0__ 0x0400

.org 0x00000000
.code
.global _start

_start:

segment_init:
    movl    $__DS0__, %eax
    movw    %ax, %ds
    movl    $__SS0__, %eax
    movw    %ax, %ss
    movl    $0x0FFF, %esp
    movl    $0x00000000, %ebx

    # ================================================================
    # SECTION 1: ADC/SBB CARRY CHAIN
    # ================================================================
    # ADC and SBB propagate CF. A chain of ADC/SBB operations must
    # correctly carry flags through. Bugs here indicate wrong CF
    # capture or propagation.

    # Step 1: Generate CF=1 via ADD overflow
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # EAX=0, CF=1, ZF=1

    # Step 2: ADC with CF=1
    movl    $0x000000FF, %ecx
    adcl    $0x00000000, %ecx           # ECX = 0xFF + 0 + 1 = 0x100
    addl    %ecx, %ebx                  # expected: 0x100

    # Step 3: ADC picks up CF from previous ADC (CF=0 from 0x100)
    movl    $0x00000001, %edx
    adcl    $0x00000000, %edx           # EDX = 1 + 0 + 0 = 1
    addl    %edx, %ebx                  # expected: 1

    # Step 4: Force CF=1 again, then SBB
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1
    movl    $0x00000100, %ecx
    sbbl    $0x00000000, %ecx           # ECX = 0x100 - 0 - 1 = 0xFF
    addl    %ecx, %ebx                  # expected: 0xFF

    # Step 5: Chain SBB -> ADC
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1
    movl    $0x00000010, %ecx
    sbbl    $0x00000001, %ecx           # ECX = 0x10 - 1 - 1 = 0x0E, CF=0
    adcl    $0x00000000, %ecx           # ECX = 0x0E + 0 + 0 = 0x0E
    addl    %ecx, %ebx

    # ================================================================
    # SECTION 2: AND CLEARS CF, OR CLEARS CF
    # ================================================================
    # AND and OR always clear CF and OF. If they don't, CMOVC/ADC
    # will produce wrong results.

    # Set CF=1
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1

    # AND should clear CF
    movl    $0x000000FF, %eax
    andl    $0x000000FF, %eax           # CF=0 now
    movl    $0x00000000, %edx
    movl    $0xBADCF001, %ecx
    cmovcl  %ecx, %edx                  # CF=0 -> EDX stays 0
    addl    %edx, %ebx                  # should add 0

    # Set CF=1 again
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1

    # OR should clear CF
    movl    $0x00000000, %eax
    orl     $0x000000FF, %eax           # CF=0
    movl    $0x00000000, %edx
    cmovcl  %ecx, %edx                  # CF=0 -> EDX stays 0
    addl    %edx, %ebx                  # should add 0

    # ================================================================
    # SECTION 3: NOT DOES NOT AFFECT FLAGS
    # ================================================================
    # NOT is supposed to leave all flags unchanged. If it clears or
    # sets flags, subsequent conditional ops will be wrong.

    # Set flags: CF=1 via ADD overflow
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1, ZF=1

    # NOT should NOT change CF or ZF
    movl    $0x0F0F0F0F, %ecx
    notl    %ecx                        # ECX = 0xF0F0F0F0, flags unchanged

    # CF should still be 1
    movl    $0x00000000, %edx
    movl    $0x00000001, %eax
    cmovcl  %eax, %edx                  # CF=1 -> EDX = 1
    addl    %edx, %ebx                  # expected: 1

    # ZF should still be 1 from the ADD (NOT didn't change it)
    # JNE tests ZF=0, so JNE should NOT take
    jne     not_flag_fail
    addl    $0x00000002, %ebx           # PASS: ZF still 1
    jmp     not_flag_done
not_flag_fail:
    addl    $0xBAD30001, %ebx
not_flag_done:

    # ================================================================
    # SECTION 4: PARTIAL REGISTER WRITES (MOV byte)
    # ================================================================
    # Writing AL/AH must preserve the other half of AX and upper EAX.

    movl    $0xAABBCCDD, %eax
    movb    $0x11, %al                  # EAX should be 0xAABBCC11

    # Verify via CMPXCHG: if EAX == mem, ZF=1
    movl    $0x00000000, %esi
    movl    $0xAABBCC11, (%esi)         # expected value
    movl    $0xAAAAAAAA, %ecx           # dummy replacement
    cmpxchgl %ecx, (%esi)              # if EAX==mem: ZF=1, mem=0xAAAAAAAA
    jne     partial_al_fail             # ZF=0 means mismatch -> FAIL
    addl    $0x00000010, %ebx
    jmp     partial_al_done
partial_al_fail:
    addl    $0xBAD40001, %ebx
partial_al_done:

    # Test AH write
    movl    $0xAABBCCDD, %eax
    movb    $0x22, %ah                  # EAX should be 0xAABB22DD
    movl    $0xAABB22DD, (%esi)
    movl    $0xBBBBBBBB, %ecx
    cmpxchgl %ecx, (%esi)
    jne     partial_ah_fail
    addl    $0x00000020, %ebx
    jmp     partial_ah_done
partial_ah_fail:
    addl    $0xBAD40002, %ebx
partial_ah_done:

    # Test 16-bit write preserves upper 16 of EAX
    movl    $0x11223344, %eax
    movw    $0xFFFF, %ax                # EAX should be 0x1122FFFF
    movl    $0x1122FFFF, (%esi)
    movl    $0xCCCCCCCC, %ecx
    cmpxchgl %ecx, (%esi)
    jne     partial_ax_fail
    addl    $0x00000030, %ebx
    jmp     partial_ax_done
partial_ax_fail:
    addl    $0xBAD40003, %ebx
partial_ax_done:

    # Test partial on other registers
    movl    $0xDEADBEEF, %ecx
    movb    $0x00, %cl                  # ECX should be 0xDEADBE00
    movl    $0xDEADBE00, (%esi)
    movl    %ecx, %eax
    movl    $0xDDDDDDDD, %ecx
    cmpxchgl %ecx, (%esi)
    jne     partial_cl_fail
    addl    $0x00000040, %ebx
    jmp     partial_cl_done
partial_cl_fail:
    addl    $0xBAD40004, %ebx
partial_cl_done:

    # ================================================================
    # SECTION 5: SAL/SAR FLAG BEHAVIOR
    # ================================================================
    # SAL sets CF to the last bit shifted out.
    # SAR sets CF to the last bit shifted out.
    # SAL by 1 sets OF if top two bits differ.

    # SAL: shift 0x80000000 left by 1 -> CF = bit 31 = 1
    movl    $0x80000000, %eax
    sall    $1, %eax                    # EAX = 0, CF=1
    movl    $0x00000000, %edx
    movl    $0x00000001, %ecx
    cmovcl  %ecx, %edx                  # CF=1 -> EDX = 1
    addl    %edx, %ebx                  # expected: 1

    # SAL: shift 0x00000001 left by 1 -> CF = bit 31 = 0 (was 0)
    movl    $0x00000001, %eax
    sall    $1, %eax                    # EAX = 2, CF=0
    movl    $0x00000000, %edx
    cmovcl  %ecx, %edx                  # CF=0 -> EDX stays 0
    addl    %edx, %ebx                  # expected: 0
    addl    %eax, %ebx                  # EAX=2

    # SAR: shift 0x00000001 right by 1 -> CF = bit 0 = 1
    movl    $0x00000001, %eax
    sarl    $1, %eax                    # EAX = 0, CF=1
    movl    $0x00000000, %edx
    cmovcl  %ecx, %edx                  # CF=1 -> EDX = 1
    addl    %edx, %ebx

    # SAR: shift 0x80000000 right by 1 -> CF = bit 0 = 0
    movl    $0x80000000, %eax
    sarl    $1, %eax                    # EAX = 0xC0000000, CF=0
    addl    %eax, %ebx

    # ================================================================
    # SECTION 6: CMPXCHG FLAG + BRANCH INTERACTION
    # ================================================================
    # CMPXCHG sets ZF. JNE must correctly read ZF from CMPXCHG,
    # not from some stale flag state.

    movl    $0x00000000, %esi
    movl    $0xAAAAAAAA, (%esi)

    # Match case: ZF=1 -> JNE should NOT take
    movl    $0xAAAAAAAA, %eax
    movl    $0xBBBBBBBB, %ecx
    cmpxchgl %ecx, (%esi)
    jne     cmpx_zf_fail_1
    addl    $0x00001000, %ebx           # PASS
    jmp     cmpx_zf_test_2
cmpx_zf_fail_1:
    addl    $0xBAD60001, %ebx
cmpx_zf_test_2:

    # Non-match case: ZF=0 -> JNE should take
    movl    $0x00000000, %eax           # EAX != mem (0xBBBBBBBB)
    movl    $0xCCCCCCCC, %ecx
    cmpxchgl %ecx, (%esi)
    jne     cmpx_zf_ok_2                # should take
    addl    $0xBAD60002, %ebx
    jmp     cmpx_zf_done
cmpx_zf_ok_2:
    addl    $0x00002000, %ebx
cmpx_zf_done:

    # ================================================================
    # SECTION 7: BOUNDARY VALUES
    # ================================================================

    # ADD 0x7FFFFFFF + 1 -> 0x80000000 (no CF, but OF=1)
    movl    $0x7FFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=0 (no unsigned overflow)
    # Verify CF=0
    movl    $0x00000000, %edx
    movl    $0xBAD70001, %ecx
    cmovcl  %ecx, %edx                  # CF=0 -> EDX stays 0
    addl    %edx, %ebx                  # should add 0
    addl    %eax, %ebx                  # add 0x80000000

    # ADD 0xFFFFFFFF + 1 -> 0, CF=1, ZF=1
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax
    # Verify CF=1
    movl    $0x00000000, %edx
    movl    $0x00000001, %ecx
    cmovcl  %ecx, %edx
    addl    %edx, %ebx                  # expected: 1
    # Verify ZF=1 (JNE should not take)
    jne     boundary_zf_fail
    addl    $0x00000002, %ebx
    jmp     boundary_done
boundary_zf_fail:
    addl    $0xBAD70002, %ebx
boundary_done:

    # AND reg with self: result unchanged, CF=0, ZF depends on value
    movl    $0xDEADBEEF, %eax
    andl    %eax, %eax                  # CF=0, ZF=0 (nonzero)
    jnbe    and_self_ok                 # CF=0 AND ZF=0 -> JNBE taken
    addl    $0xBAD70003, %ebx
    jmp     and_self_done
and_self_ok:
    addl    %eax, %ebx
and_self_done:

    # ================================================================
    # SECTION 8: XCHG SELF = NO-OP
    # ================================================================

    movl    $0x12345678, %eax
    xchgl   %eax, %eax                  # should be identity
    # Verify via CMPXCHG
    movl    $0x00000000, %esi
    movl    $0x12345678, (%esi)
    movl    $0xAAAAAAAA, %ecx
    cmpxchgl %ecx, (%esi)
    jne     xchg_self_fail
    addl    $0x00000100, %ebx
    jmp     xchg_self_done
xchg_self_fail:
    addl    $0xBAD80001, %ebx
xchg_self_done:

    # ================================================================
    # SECTION 9: CHAINED FLAG DEPENDENCIES
    # ================================================================
    # ADD -> ADC -> SBB -> ADD -> ADC chain.
    # Each instruction's CF feeds the next.

    movl    $0xFFFFFFF0, %eax
    addl    $0x00000020, %eax           # EAX=0x10, CF=1
    movl    $0x00000000, %ecx
    adcl    $0x00000000, %ecx           # ECX = 0 + 0 + 1 = 1, CF=0
    sbbl    $0x00000000, %ecx           # ECX = 1 - 0 - 0 = 1, CF=0
    addl    $0xFFFFFFFF, %ecx           # ECX = 0, CF=1
    adcl    $0x000000FF, %ecx           # ECX = 0 + 0xFF + 1 = 0x100
    addl    %ecx, %ebx                  # expected: 0x100

    # ================================================================
    # SECTION 10: STORE-LOAD FORWARDING + BRANCH
    # ================================================================

    movl    $0x00000000, %esi
    movl    $0x00000042, (%esi)
    movl    (%esi), %eax
    # Verify EAX = 0x42 via CMPXCHG
    movl    $0x00000042, (%esi)         # set expected
    movl    $0xAAAAAAAA, %ecx
    cmpxchgl %ecx, (%esi)              # EAX should be 0x42 -> match
    jne     stfwd_fail
    addl    $0x00000200, %ebx
    jmp     stfwd_done
stfwd_fail:
    addl    $0xBADA0001, %ebx
stfwd_done:

    # Byte store, dword load
    movl    $0x00000000, 4(%esi)
    movb    $0xFF, 4(%esi)
    movl    4(%esi), %eax               # should be 0x000000FF
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 11: AAA EDGE CASES
    # ================================================================
    # AAA adjusts AL for unpacked BCD after addition.
    # If AL lower nibble > 9 or AF=1, it adds 6 to AL and 1 to AH.

    # Case: 9 + 8 = 0x11 -> AAA should give AL=7, AH+=1
    movl    $0x00000009, %eax
    addl    $0x00000008, %eax           # AL=0x11
    aaa
    addl    %eax, %ebx

    # Case: 5 + 3 = 8 -> no adjustment needed (low nibble <= 9)
    movl    $0x00000005, %eax
    addl    $0x00000003, %eax           # AL=0x08
    aaa
    addl    %eax, %ebx

    # ================================================================
    # SECTION 12: FAR CALL WITH FLAG PRESERVATION
    # ================================================================
    # Set known flags, far call to CS1 which preserves them via
    # careful register save/restore, then verify flags on return.

    # Set CF=1 via ADD overflow
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1, ZF=1
    lcall   $__CS1__, $0
    # CS1 saves EBX, does work, restores EBX, doesn't touch flags
    # Actually we can't guarantee flag preservation without PUSHF.
    # Instead, CS1 just sets known flags before LRET.
    # After lret, CF=0 (AND inside CS1 cleared it), ZF=0
    addl    %eax, %ebx                  # EAX from CS1

    # ================================================================
    # SECTION 13: MANUAL MEMORY COPY (no REP MOVS)
    # ================================================================

    movl    $0x00000100, %esi
    movl    $0xAAAA0001, (%esi)
    movl    $0xBBBB0002, 4(%esi)
    movl    $0xCCCC0003, 8(%esi)
    movl    $0xDDDD0004, 12(%esi)

    movl    $0x00000100, %esi
    movl    $0x00000200, %edi
    movl    $0x00000004, %ecx
manual_copy:
    movl    (%esi), %eax
    movl    %eax, (%edi)
    addl    $0x00000004, %esi
    addl    $0x00000004, %edi
    addl    $0xFFFFFFFF, %ecx
    jne     manual_copy

    # Verify destination
    movl    $0x00000200, %esi
    movl    (%esi), %eax
    addl    %eax, %ebx
    movl    4(%esi), %eax
    addl    %eax, %ebx
    movl    8(%esi), %eax
    addl    %eax, %ebx
    movl    12(%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 14: BSF ON COMPUTED VALUES
    # ================================================================
    # Build a value via OR, then BSF it to find lowest set bit.

    movl    $0x00000000, %eax
    orl     $0x00000100, %eax           # bit 8
    bsfl    %eax, %ecx                  # ECX = 8
    addl    %ecx, %ebx

    movl    $0x00000000, %eax
    orl     $0x80000000, %eax           # bit 31
    orl     $0x00001000, %eax           # bit 12 (lowest)
    bsfl    %eax, %ecx                  # ECX = 12
    addl    %ecx, %ebx

    # ================================================================
    # DONE
    # ================================================================

    movl    $0x00000000, %esi
    movl    %ebx, 0xF00(%esi)
    movl    $0xDEAD5555, 0xF04(%esi)
    hlt


# ================================================================
# CS1 — FAR CALL TARGET (base = 0x02000000)
# Sets EAX to a known value, clears CF via AND, returns.
# ================================================================
.org 0x02000000
.code

_cs1_flag_test:
    # We can't use PUSHF/POPF. Just do some safe work.
    movl    $0x000000FF, %eax
    andl    $0xFFFFFFFF, %eax           # CF=0, EAX=0xFF
    lret


# ================================================================
# DATA (DS0 base = 0x03000000)
# ================================================================
.org 0x03000000
.data
    .long 0x11223344
    .space 0x0F00

# ================================================================
# STACK (SS0 base = 0x04000000)
# ================================================================
.org 0x04000000
.data
    .space 0x1000
