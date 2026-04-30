# ================================================================
# TEST 1: BRANCH-HEAVY — Control Flow Stress Test
# ================================================================
# LEGAL INSTRUCTIONS ONLY. No SUB/CMP/TEST/XOR/INC/DEC/LEA/etc.
#
# Tests: JNE taken/not-taken, JNBE taken/not-taken, JMP near/short,
#        CALL/RET near, RET imm16, CALL indirect r/m32, JMP indirect,
#        LCALL/LRET far, LJMP far, nested far calls, branch chains,
#        conditional loops, multi-segment control flow.
#
# Segment Layout:
#   CS0 = 0x0000 -> base 0x00000000  (primary code)
#   CS1 = 0x0200 -> base 0x02000000  (far call target 1)
#   CS2 = 0x0300 -> base 0x03000000  (far call target 2)
#   CS3 = 0x0400 -> base 0x04000000  (final ljmp target)
#   DS0 = 0x0500 -> base 0x05000000  (data page)
#   SS0 = 0x0600 -> base 0x06000000  (stack page)
# ================================================================

#define __CS0__ 0x0000
#define __CS1__ 0x0200
#define __CS2__ 0x0300
#define __CS3__ 0x0400
#define __DS0__ 0x0500
#define __SS0__ 0x0600

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
    movl    $0x00000000, %ebx           # running checksum

    # ================================================================
    # SECTION 1: JNE — TAKEN (ZF=0)
    # ADD nonzero to zero -> nonzero result -> ZF=0
    # ================================================================

    movl    $0x00000001, %eax
    addl    $0x00000000, %eax           # EAX=1, ZF=0
    jne     jne_taken_1
    addl    $0xBAD00001, %ebx
jne_taken_1:
    addl    $0x00000001, %ebx

    # ================================================================
    # SECTION 2: JNE — NOT TAKEN (ZF=1)
    # ADD (-1) to 1 -> result=0 -> ZF=1
    # ================================================================

    movl    $0x00000001, %eax
    addl    $0xFFFFFFFF, %eax           # 1+(-1)=0, ZF=1
    jne     jne_fail_1
    addl    $0x00000002, %ebx
    jmp     jne_nt_done
jne_fail_1:
    addl    $0xBAD00002, %ebx
jne_nt_done:

    # ================================================================
    # SECTION 3: JNBE — TAKEN (CF=0 AND ZF=0)
    # AND with nonzero result clears CF and sets ZF=0
    # ================================================================

    movl    $0x000000FF, %eax
    andl    $0x000000FF, %eax           # CF=0, ZF=0
    jnbe    jnbe_taken_1
    addl    $0xBAD00003, %ebx
jnbe_taken_1:
    addl    $0x00000003, %ebx

    # ================================================================
    # SECTION 4: JNBE — NOT TAKEN due to ZF=1
    # AND with 0 -> result=0 -> ZF=1
    # ================================================================

    movl    $0x000000FF, %eax
    andl    $0x00000000, %eax           # ZF=1, CF=0
    jnbe    jnbe_fail_1
    addl    $0x00000004, %ebx
    jmp     jnbe_nt_done
jnbe_fail_1:
    addl    $0xBAD00004, %ebx
jnbe_nt_done:

    # ================================================================
    # SECTION 5: JNBE — NOT TAKEN due to CF=1
    # ADD causing carry: CF=1
    # ================================================================

    movl    $0xFFFFFFFF, %eax
    addl    $0x00000002, %eax           # result=1, CF=1, ZF=0
    jnbe    jnbe_fail_2
    addl    $0x00000005, %ebx
    jmp     jnbe_cf_done
jnbe_fail_2:
    addl    $0xBAD00005, %ebx
jnbe_cf_done:

    # ================================================================
    # SECTION 6: JNE LOOP — countdown 16 times
    # ================================================================

    movl    $0x00000010, %ecx
loop_1:
    addl    $0x00000010, %ebx
    addl    $0xFFFFFFFF, %ecx           # ECX--
    jne     loop_1

    # ================================================================
    # SECTION 7: NESTED LOOPS (outer=4, inner=3)
    # ================================================================

    movl    $0x00000004, %edi
outer_loop:
    movl    $0x00000003, %ecx
inner_loop:
    addl    $0x00000001, %ebx
    addl    $0xFFFFFFFF, %ecx
    jne     inner_loop
    addl    $0xFFFFFFFF, %edi
    jne     outer_loop

    # ================================================================
    # SECTION 8: FORWARD JMP CHAIN (8 hops)
    # ================================================================

    jmp     chain_1
chain_1:
    addl    $0x00000010, %ebx
    jmp     chain_2
chain_2:
    addl    $0x00000010, %ebx
    jmp     chain_3
chain_3:
    addl    $0x00000010, %ebx
    jmp     chain_4
chain_4:
    addl    $0x00000010, %ebx
    jmp     chain_5
chain_5:
    addl    $0x00000010, %ebx
    jmp     chain_6
chain_6:
    addl    $0x00000010, %ebx
    jmp     chain_7
chain_7:
    addl    $0x00000010, %ebx
    jmp     chain_8
chain_8:
    addl    $0x00000010, %ebx

    # ================================================================
    # SECTION 9: BACKWARD BRANCH LOOP
    # ================================================================

    movl    $0x00000004, %ecx
back_loop:
    addl    $0x00000100, %ebx
    addl    $0xFFFFFFFF, %ecx
    jne     back_loop

    # ================================================================
    # SECTION 10: NEAR CALL / RET
    # ================================================================

    movl    $0x00000100, %eax
    call    near_func_1
    addl    %eax, %ebx
    jmp     near_call_2

near_func_1:
    addl    $0x00000100, %eax           # EAX = 0x200
    ret

near_call_2:
    movl    $0x00000000, %eax
    call    near_func_2
    addl    %eax, %ebx
    jmp     near_done

near_func_2:
    movl    $0x00000055, %eax
    ret

near_done:

    # ================================================================
    # SECTION 11: NESTED NEAR CALLS (3 levels)
    # ================================================================

    movl    $0x00000000, %eax
    call    nest_1
    addl    %eax, %ebx
    jmp     nested_done

nest_1:
    addl    $0x00000001, %eax
    call    nest_2
    addl    $0x00000010, %eax
    ret

nest_2:
    addl    $0x00000100, %eax
    ret

nested_done:

    # ================================================================
    # SECTION 12: CALL WITH STACK ARGS
    # ================================================================

    pushl   $0x0000000A
    pushl   $0x00000014
    call    add_two_args
    addl    $0x00000008, %esp           # clean 2 args
    addl    %eax, %ebx
    jmp     section_13

add_two_args:

    pushl %esi
    pushl %edi

    # save FS
    movw %fs, %ax
    pushl %eax

    # switch FS = SS
    movw %ss, %ax
    movw %ax, %fs

    # base pointer to stack frame
    movl %esp, %esi

    # -----------------------------------------
    # load arg1 (ESP + 8)
    # -----------------------------------------
    movl %esi, %edi
    addl $8, %edi
    movl %fs:(%edi), %eax

    # -----------------------------------------
    # load arg2 (ESP + 12)
    # -----------------------------------------
    movl %esi, %edi
    addl $12, %edi
    add %fs:(%edi), %eax


    # restore FS
    popl %ebx
    movw %bx, %fs

    popl %edi
    popl %esi

    ret

section_13:

    # ================================================================
    # SECTION 13: RET imm16 — callee cleans stack
    # ================================================================

    pushl   $0x00000003
    pushl   $0x00000007
    call    add_ret_clean
    addl    %eax, %ebx
    jmp     section_14

add_ret_clean:

    movw %fs, %ax
    pushl %eax

    movl %esp, %esi

    movl 8(%esi), %eax
    addl 12(%esi), %eax

    popl %eax
    movw %ax, %fs

    ret $8

section_14:

    # ================================================================
    # SECTION 14: CALL r/m32 — indirect near call through memory
    # ================================================================

    movl    $0x00000000, %esi
    movl    $indirect_target, (%esi)
    call    *(%esi)
    addl    %eax, %ebx
    jmp     section_15

indirect_target:
    movl    $0x000000AA, %eax
    ret

section_15:

    # ================================================================
    # SECTION 15: JMP r/m32 — indirect jump through memory
    # ================================================================

    movl    $jmp_ind_target, 4(%esi)
    jmp     *4(%esi)
    addl    $0xBAD000F0, %ebx
jmp_ind_target:
    addl    $0x000000BB, %ebx

    # ================================================================
    # SECTION 16: FAR CALL to CS1 and LRET
    # ================================================================

    movl    $0xAAAA0000, %eax
    lcall   $__CS1__, $0
    addl    %eax, %ebx

    # ================================================================
    # SECTION 17: NESTED FAR CALL CS0->CS2->CS1->CS2->CS0
    # ================================================================

    movl    $0xBBBB0000, %eax
    lcall   $__CS2__, $0
    addl    %eax, %ebx

    # ================================================================
    # SECTION 18: BRANCH + STACK INTEGRITY
    # ================================================================

    pushl   $0xDEAD0001
    pushl   $0xDEAD0002
    pushl   $0xDEAD0003

    movl    $0x00000001, %eax
    addl    $0x00000000, %eax           # ZF=0
    jne     branch_over_stack
    addl    $0xBAD00018, %ebx
branch_over_stack:
    popl    %eax
    addl    %eax, %ebx
    popl    %eax
    addl    %eax, %ebx
    popl    %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 19: CALL then JNBE based on return value
    # Tests branch decision after call return.
    # ================================================================

    call    returns_nonzero
    # EAX = 0x42, AND clears CF, result nonzero -> ZF=0
    andl    $0xFFFFFFFF, %eax           # CF=0, ZF=0 (EAX=0x42)
    jnbe    call_ret_branch_ok
    addl    $0xBAD00019, %ebx
    jmp     call_ret_done
call_ret_branch_ok:
    addl    %eax, %ebx
call_ret_done:
    jmp     section_20

returns_nonzero:
    movl    $0x00000042, %eax
    ret

section_20:

    # ================================================================
    # SECTION 20: LJMP to CS3 — final halt
    # ================================================================

    movl    $0x00000000, %esi
    movl    %ebx, (%esi)
    ljmp    $__CS3__, $0


# ================================================================
# CS1 — base 0x02000000
# ================================================================
.org 0x02000000
.code

_cs1_entry:
    addl    $0x0000CCCC, %eax
    movl    $0x00000003, %ecx
cs1_loop:
    addl    $0x00000001, %eax
    addl    $0xFFFFFFFF, %ecx
    jne     cs1_loop
    lret


# ================================================================
# CS2 — base 0x03000000 — nested far call to CS1
# ================================================================
.org 0x03000000
.code

_cs2_entry:
    addl    $0x0000DDDD, %eax
    lcall   $__CS1__, $0
    addl    $0x0000EEEE, %eax
    lret


# ================================================================
# CS3 — base 0x04000000 — halt
# ================================================================
.org 0x04000000
.code

_cs3_entry:
    movl    $__DS0__, %eax
    movw    %ax, %ds
    movl    $0x00000000, %esi
    movl    %ebx, (%esi)
    movl    $0x12345678, 4(%esi)
    hlt


# ================================================================
# DATA (DS0 base = 0x05000000)
# ================================================================
.org 0x05000000
.data
    .long 0x00000000
    .space 0x0100


# ================================================================
# STACK (SS0 base = 0x06000000)
# ================================================================
.org 0x06000000
.data
    .space 0x1000
