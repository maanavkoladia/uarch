# ================================================================
# TEST 3: STACK-HEAVY — Stack Behavior Stress Test
# ================================================================
# LEGAL INSTRUCTIONS ONLY.
#
# Tests: Push/pop reg, imm, mem, segment regs. Deep call nesting
#        (6 levels), ESP tracking, stack-based memory access via
#        ESP offsets, call with stack args, RET imm16 cleanup,
#        far call stack frame, rapid push/pop stress, 16-bit
#        push/pop, interleaved stack + arithmetic.
#
# Segment Layout:
#   CS0 = 0x0000 -> base 0x00000000  (code, 2 pages)
#   CS1 = 0x0200 -> base 0x02000000  (far call target)
#   DS0 = 0x0300 -> base 0x03000000  (data)
#   SS0 = 0x0400 -> base 0x04000000  (stack, 2 pages)
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
    movl    $0x00001FFF, %esp
    movl    $0x00000000, %ebx

    # ================================================================
    # SECTION 1: BASIC PUSH/POP — REGISTERS
    # ================================================================

    movl    $0x11111111, %eax
    movl    $0x22222222, %ecx
    movl    $0x33333333, %edx
    movl    $0x44444444, %esi
    movl    $0x55555555, %edi
    movl    $0x66666666, %ebp

    pushl   %eax
    pushl   %ecx
    pushl   %edx
    pushl   %esi
    pushl   %edi
    pushl   %ebp

    # Capture ESP after 6 pushes
    movl    %esp, %eax
    addl    %eax, %ebx

    popl    %ebp
    popl    %edi
    popl    %esi
    popl    %edx
    popl    %ecx
    popl    %eax

    # Verify values survived
    addl    %eax, %ebx
    addl    %ecx, %ebx
    addl    %edx, %ebx
    addl    %esi, %ebx
    addl    %edi, %ebx
    addl    %ebp, %ebx

    # ================================================================
    # SECTION 2: PUSH IMMEDIATE VALUES
    # ================================================================

    pushl   $0xAAAAAAAA
    pushl   $0xBBBBBBBB
    pushl   $0xCCCCCCCC
    pushl   $0xDDDDDDDD

    popl    %eax
    addl    %eax, %ebx
    popl    %eax
    addl    %eax, %ebx
    popl    %eax
    addl    %eax, %ebx
    popl    %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 3: PUSH/POP MEMORY OPERANDS
    # ================================================================

    movl    $0x00000000, %esi
    movl    $0xFEEDFACE, (%esi)
    movl    $0xCAFEBABE, 4(%esi)

    pushl   (%esi)
    pushl   4(%esi)

    popl    %eax
    addl    %eax, %ebx
    popl    %eax
    addl    %eax, %ebx

    # Pop into memory
    pushl   $0x12345678
    movl    $0x00000010, %edi
    popl    (%edi)
    movl    (%edi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 4: PUSH/POP SEGMENT REGISTERS
    # ================================================================

    pushl   %ds
    pushl   %ss
    pushl   %es

    popl    %eax                        # ES value
    addl    %eax, %ebx
    popl    %eax                        # SS value
    addl    %eax, %ebx
    popl    %eax                        # DS value
    addl    %eax, %ebx

    # ================================================================
    # SECTION 5: DEEP NEAR CALL NESTING (6 levels)
    # ================================================================

    movl    $0x00000000, %eax
    call    stack_nest_1
    addl    %eax, %ebx
    jmp     section_6

stack_nest_1:
    pushl   $0xAA000001
    addl    $0x000001, %eax
    call    stack_nest_2
    popl    %edx
    addl    %edx, %ebx
    ret

stack_nest_2:
    pushl   $0xBB000002
    addl    $0x000010, %eax
    call    stack_nest_3
    popl    %edx
    addl    %edx, %ebx
    ret

stack_nest_3:
    pushl   $0xCC000003
    addl    $0x000100, %eax
    call    stack_nest_4
    popl    %edx
    addl    %edx, %ebx
    ret

stack_nest_4:
    pushl   $0xDD000004
    addl    $0x001000, %eax
    call    stack_nest_5
    popl    %edx
    addl    %edx, %ebx
    ret

stack_nest_5:
    pushl   $0xEE000005
    addl    $0x010000, %eax
    call    stack_nest_6
    popl    %edx
    addl    %edx, %ebx
    ret

stack_nest_6:
    pushl   $0xFF000006
    addl    $0x100000, %eax
    popl    %edx
    addl    %edx, %ebx
    ret

section_6:

    # ================================================================
    # SECTION 6: CALL WITH STACK ARGS + RET imm16
    # ================================================================

    # add_three(0x100, 0x200, 0x300) using RET $12 for cleanup
    pushl   $0x00000300
    pushl   $0x00000200
    pushl   $0x00000100
    call    add_three_clean
    # RET $12 already cleaned args
    addl    %eax, %ebx
    jmp     section_7

add_three_clean:
    movl    4(%esp), %eax
    addl    8(%esp), %eax
    addl    12(%esp), %eax
    ret     $12

section_7:

    # ================================================================
    # SECTION 7: INTERLEAVED PUSH/POP WITH ARITHMETIC
    # ================================================================

    movl    $0x00000000, %eax
    pushl   $0x00000001
    addl    $0x00000010, %eax
    pushl   %eax
    addl    $0x00000100, %eax
    pushl   %eax
    addl    $0x00001000, %eax

    popl    %ecx
    popl    %edx
    popl    %esi

    addl    %eax, %ebx                  # 0x1110
    addl    %ecx, %ebx                  # 0x110
    addl    %edx, %ebx                  # 0x10
    addl    %esi, %ebx                  # 0x1

    # ================================================================
    # SECTION 8: STACK AS SCRATCH (ESP-relative reads without pop)
    # ================================================================

    pushl   $0x10000000
    pushl   $0x20000000
    pushl   $0x30000000
    pushl   $0x40000000

    movl    0(%esp), %eax               # 0x40000000
    addl    %eax, %ebx
    movl    4(%esp), %eax               # 0x30000000
    addl    %eax, %ebx
    movl    8(%esp), %eax               # 0x20000000
    addl    %eax, %ebx
    movl    12(%esp), %eax              # 0x10000000
    addl    %eax, %ebx

    addl    $0x00000010, %esp           # clean 4 dwords

    # ================================================================
    # SECTION 9: FAR CALL STACK FRAME
    # lcall pushes CS:EIP. Verify stack integrity across it.
    # ================================================================

    movl    %esp, %edi                  # save ESP
    pushl   $0xBEEF0000                 # marker
    lcall   $__CS1__, $0
    popl    %eax                        # should be 0xBEEF0000
    addl    %eax, %ebx

    # Verify ESP is restored: EDI should equal ESP now
    # We can't CMP, so: compute EDI + (-ESP) via add/sbb trick
    # Simpler: just add both and use result
    addl    %edi, %ebx
    addl    %esp, %ebx

    # ================================================================
    # SECTION 10: RAPID PUSH/POP STRESS (16 iterations)
    # ================================================================

    movl    $0x00000010, %ecx
push_pop_stress:
    pushl   %ecx
    pushl   %ebx
    popl    %ebx
    popl    %eax
    addl    %eax, %ebx
    addl    $0xFFFFFFFF, %ecx
    jne     push_pop_stress

    # ================================================================
    # SECTION 11: 16-BIT PUSH/POP
    # ================================================================

    movl    $0xAABBCCDD, %eax
    pushw   %ax                         # push 0xCCDD (2 bytes)
    movl    $0x00000000, %eax
    popw    %ax                         # AX = 0xCCDD
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    pushw   $0x1234
    popw    %cx
    movl    %ecx, %eax
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 12: PUSH imm8 (sign-extended to 32 bits)
    # ================================================================

    pushl   $0x7F                       # 0x0000007F
    popl    %eax
    addl    %eax, %ebx

    pushl   $-1                         # 0xFFFFFFFF (sign-extended from 0xFF)
    popl    %eax
    addl    %eax, %ebx

    # ================================================================
    # DONE
    # ================================================================

    movl    $0x00000000, %esi
    movl    %ebx, 0x100(%esi)
    hlt


# ================================================================
# CS1 — FAR CALL TARGET (base = 0x02000000)
# ================================================================
.org 0x02000000
.code

_cs1_stack_test:
    pushl   $0xFACE0001
    pushl   $0xFACE0002
    movl    0(%esp), %eax
    addl    4(%esp), %eax
    addl    %eax, %ebx
    popl    %edx
    popl    %edx

    # Near call inside far call
    call    cs1_helper
    addl    %eax, %ebx
    lret

cs1_helper:
    movl    $0x000000FF, %eax
    ret


# ================================================================
# DATA (DS0 base = 0x03000000)
# ================================================================
.org 0x03000000
.data
    .long 0x11223344
    .space 0x0F00

# ================================================================
# STACK page 0 (SS0 base = 0x04000000)
# ================================================================
.org 0x04000000
.data
    .space 0x1000

# STACK page 1
.org 0x04001000
.data
    .space 0x1000
