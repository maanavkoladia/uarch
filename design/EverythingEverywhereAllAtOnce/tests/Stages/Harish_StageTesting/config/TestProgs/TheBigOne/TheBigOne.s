#define __CS__
#define __DS__
#define __SS__


.org 0x00000
.code
.global _start

_start:

segment_init:
    movl    $__DS__, %eax
    movw    %ax, %ds
    movl    $__SS__, %eax
    movw    %ax, %ss

main:
    movl $0x5000, %esp              # Stack grows down from 0x5000 into stack_page
    movl $0x2000, %esi              # ESI = base of data page
    movl $0x00000000, %ebx          # EBX = running accumulator / checksum

    # ================================================================
    # SECTION 1: BASIC STORE / LOAD — WIDE STRIDE
    # Test dcache across large address spans.
    # ================================================================

    movl $0xA0A0A0A0, (%esi)
    movl $0xB1B1B1B1, 0x200(%esi)
    movl $0xC2C2C2C2, 0x400(%esi)
    movl $0xD3D3D3D3, 0x600(%esi)
    movl $0xE4E4E4E4, 0x800(%esi)
    movl $0xF5F5F5F5, 0xA00(%esi)
    movl $0x12345678, 0x100(%esi)
    movl $0x87654321, 0x300(%esi)

    movl (%esi),       %eax
    addl %eax,         %ebx
    movl 0x200(%esi),  %eax
    addl %eax,         %ebx
    movl 0x400(%esi),  %eax
    addl %eax,         %ebx
    movl 0x600(%esi),  %eax
    addl %eax,         %ebx
    movl 0x800(%esi),  %eax
    addl %eax,         %ebx
    movl 0xA00(%esi),  %eax
    addl %eax,         %ebx
    movl 0x100(%esi),  %eax
    addl %eax,         %ebx
    movl 0x300(%esi),  %eax
    addl %eax,         %ebx

    # ================================================================
    # SECTION 2: TIGHT-STRIDE STORES — SAME CACHE LINE REGION
    # Test byte-adjacent and 16-byte-stride accesses.
    # ================================================================

    movl $0xBA000000, (%esi)
    movl $0xBB000000, 0x10(%esi)
    movl $0xBC000000, 0x20(%esi)
    movl $0xBD000000, 0x30(%esi)
    movl $0xBE000000, 0x40(%esi)
    movl $0xBF000000, 0x50(%esi)
    movl $0xCA000000, 0x60(%esi)
    movl $0xCB000000, 0x70(%esi)

    movl (%esi),      %eax
    addl 0x10(%esi),  %eax
    addl 0x20(%esi),  %eax
    addl 0x30(%esi),  %eax
    addl 0x40(%esi),  %eax
    addl 0x50(%esi),  %eax
    addl 0x60(%esi),  %eax
    addl 0x70(%esi),  %eax
    addl %eax,        %ebx

    # ================================================================
    # SECTION 3: AND / OR / NOT ON MEMORY AND REGISTERS
    # ================================================================

    # AND memory, imm
    movl $0xFFFFFFFF, (%esi)
    andl $0x0F0F0F0F, (%esi)        # mem = 0x0F0F0F0F
    movl (%esi),      %eax
    addl %eax,        %ebx

    movl $0xFFFFFFFF, 0x200(%esi)
    andl $0xF0F0F0F0, 0x200(%esi)   # mem = 0xF0F0F0F0
    movl 0x200(%esi), %eax
    addl %eax,        %ebx

    movl $0xFFFFFFFF, 0x400(%esi)
    andl $0x00FF00FF, 0x400(%esi)   # mem = 0x00FF00FF
    movl 0x400(%esi), %eax
    addl %eax,        %ebx

    # OR memory, imm
    movl $0x00000000, 0x600(%esi)
    orl  $0xDEADBEEF, 0x600(%esi)   # mem = 0xDEADBEEF
    movl 0x600(%esi), %eax
    addl %eax,        %ebx

    movl $0x0F0F0F0F, 0x800(%esi)
    orl  $0xF0F0F0F0, 0x800(%esi)   # mem = 0xFFFFFFFF
    movl 0x800(%esi), %eax
    addl %eax,        %ebx

    # AND/OR register operands
    movl $0xFFFF0000, %eax
    movl $0x0000FFFF, %ecx
    andl %ecx,        %eax          # EAX = 0x00000000
    addl %eax,        %ebx

    movl $0xFFFF0000, %eax
    orl  %ecx,        %eax          # EAX = 0xFFFFFFFF
    addl %eax,        %ebx

    movl $0xAAAAAAAA, %eax
    movl $0x55555555, %ecx
    andl %ecx,        %eax          # EAX = 0x00000000
    addl %eax,        %ebx

    movl $0xAAAAAAAA, %eax
    orl  %ecx,        %eax          # EAX = 0xFFFFFFFF
    addl %eax,        %ebx

    # AND reg, mem
    movl $0x0F0F0F0F, (%esi)
    movl $0xF0F0F0F0, %eax
    andl (%esi),      %eax          # EAX = 0x00000000
    addl %eax,        %ebx

    # OR reg, mem
    movl $0x0F0F0F0F, (%esi)
    movl $0xF0F0F0F0, %eax
    orl  (%esi),      %eax          # EAX = 0xFFFFFFFF
    addl %eax,        %ebx

    # AND mem, reg
    movl $0xFFFFFFFF, 0x90(%esi)
    movl $0x12345678, %eax
    andl %eax,        0x90(%esi)    # mem = 0x12345678
    movl 0x90(%esi),  %eax
    addl %eax,        %ebx

    # OR mem, reg
    movl $0x00000000, 0x90(%esi)
    movl $0xABCDEF01, %eax
    orl  %eax,        0x90(%esi)    # mem = 0xABCDEF01
    movl 0x90(%esi),  %eax
    addl %eax,        %ebx

    # NOT on registers
    movl $0x0F0F0F0F, %eax
    notl %eax                        # EAX = 0xF0F0F0F0
    addl %eax,        %ebx

    movl $0x00000000, %eax
    notl %eax                        # EAX = 0xFFFFFFFF
    addl %eax,        %ebx

    movl $0xFFFFFFFF, %eax
    notl %eax                        # EAX = 0x00000000
    addl %eax,        %ebx

    # NOT on memory
    movl $0x0F0F0F0F, 0xA0(%esi)
    notl 0xA0(%esi)                  # mem = 0xF0F0F0F0
    movl 0xA0(%esi),  %eax
    addl %eax,        %ebx

    movl $0xDEADBEEF, 0xA0(%esi)
    notl 0xA0(%esi)                  # mem = 0x21524110
    movl 0xA0(%esi),  %eax
    addl %eax,        %ebx

    # ================================================================
    # SECTION 4: SAL / SAR — REGISTER AND MEMORY, ALL THREE FORMS
    # ================================================================

    # SAL reg, 1
    movl $0x00000001, %eax
    sall $1,          %eax           # EAX = 0x00000002
    addl %eax,        %ebx

    # SAL reg, imm8
    movl $0x00000001, %eax
    sall $8,          %eax           # EAX = 0x00000100
    addl %eax,        %ebx

    movl $0x00000001, %eax
    sall $16,         %eax           # EAX = 0x00010000
    addl %eax,        %ebx

    # SAL reg, CL
    movl $0x00000001, %eax
    movl $4,          %ecx
    sall %cl,         %eax           # EAX = 0x00000010
    addl %eax,        %ebx

    movl $0x00000003, %eax
    movl $12,         %ecx
    sall %cl,         %eax           # EAX = 0x00003000
    addl %eax,        %ebx

    # SAR reg, 1 (arithmetic: sign extends)
    movl $0x80000000, %eax
    sarl $1,          %eax           # EAX = 0xC0000000
    addl %eax,        %ebx

    movl $0x40000000, %eax
    sarl $1,          %eax           # EAX = 0x20000000
    addl %eax,        %ebx

    # SAR reg, imm8
    movl $0x80000000, %eax
    sarl $4,          %eax           # EAX = 0xF8000000
    addl %eax,        %ebx

    movl $0x7F000000, %eax
    sarl $4,          %eax           # EAX = 0x07F00000
    addl %eax,        %ebx

    # SAR reg, CL
    movl $0xFF000000, %eax
    movl $8,          %ecx
    sarl %cl,         %eax           # EAX = 0xFFFF0000
    addl %eax,        %ebx

    movl $0x7FFFFFFF, %eax
    movl $1,          %ecx
    sarl %cl,         %eax           # EAX = 0x3FFFFFFF
    addl %eax,        %ebx

    # SAL mem, 1
    movl $0x00000080, 0xB0(%esi)
    sall $1,          0xB0(%esi)     # mem = 0x00000100
    movl 0xB0(%esi),  %eax
    addl %eax,        %ebx

    # SAL mem, imm8
    movl $0x00000001, 0xB0(%esi)
    sall $12,         0xB0(%esi)     # mem = 0x00001000
    movl 0xB0(%esi),  %eax
    addl %eax,        %ebx

    # SAL mem, CL
    movl $0x00000001, 0xB0(%esi)
    movl $20,         %ecx
    sall %cl,         0xB0(%esi)     # mem = 0x00100000
    movl 0xB0(%esi),  %eax
    addl %eax,        %ebx

    # SAR mem, 1
    movl $0x80000000, 0xB0(%esi)
    sarl $1,          0xB0(%esi)     # mem = 0xC0000000
    movl 0xB0(%esi),  %eax
    addl %eax,        %ebx

    # SAR mem, imm8
    movl $0xFF000000, 0xB0(%esi)
    sarl $8,          0xB0(%esi)     # mem = 0xFFFF0000
    movl 0xB0(%esi),  %eax
    addl %eax,        %ebx

    # SAR mem, CL
    movl $0xF0000000, 0xB0(%esi)
    movl $4,          %ecx
    sarl %cl,         0xB0(%esi)     # mem = 0xFF000000
    movl 0xB0(%esi),  %eax
    addl %eax,        %ebx

    # ================================================================
    # SECTION 5: ADC — ADD WITH CARRY, ALL FORMS
    # ================================================================

    # Produce CF=1 via overflow, then ADC reg, imm
    movl $0xFFFFFFFF, %eax
    addl $0x00000001, %eax           # EAX=0, CF=1
    movl $0x00000000, %edx
    adcl $0x00000000, %edx           # EDX = 0 + CF = 1
    addl %edx,        %ebx

    # ADC reg, imm with CF=0
    movl $0x00000001, %eax
    addl $0x00000001, %eax           # CF=0
    movl $0x10000000, %edx
    adcl $0x00000001, %edx           # EDX = 0x10000001
    addl %edx,        %ebx

    # ADC reg, reg with CF=1
    movl $0xFFFFFFFF, %eax
    addl $0x00000002, %eax           # CF=1
    movl $0x00000005, %ecx
    adcl %ecx,        %eax           # EAX = 1 + 5 + 1 = 7
    addl %eax,        %ebx

    # ADC reg, mem with CF=1
    movl $0xFFFFFFFF, %eax
    addl $0x00000002, %eax           # CF=1
    movl $0x00000010, 0xC0(%esi)
    adcl 0xC0(%esi),  %eax           # EAX = 1 + 16 + 1 = 18
    addl %eax,        %ebx

    # ADC mem, imm with CF=1
    movl $0xFFFFFFFF, %eax
    addl $0x00000002, %eax           # CF=1
    movl $0x00001000, 0xC0(%esi)
    adcl $0x00000001, 0xC0(%esi)     # mem = 0x1000 + 1 + 1 = 0x1002
    movl 0xC0(%esi),  %eax
    addl %eax,        %ebx

    # ADC mem, reg with CF=0
    movl $0x00000001, %eax
    addl $0x00000001, %eax           # CF=0
    movl $0x00002000, 0xC0(%esi)
    movl $0x00000100, %ecx
    adcl %ecx,        0xC0(%esi)     # mem = 0x2000 + 0x100 + 0 = 0x2100
    movl 0xC0(%esi),  %eax
    addl %eax,        %ebx

    # ================================================================
    # SECTION 6: SBB — SUBTRACT WITH BORROW, ALL FORMS
    # ================================================================

    # SBB reg, imm with CF=0
    movl $0x00000001, %eax
    addl $0x00000001, %eax           # CF=0
    movl $0x00000010, %eax
    sbbl $0x00000001, %eax           # EAX = 0x10 - 1 - 0 = 0xF
    addl %eax,        %ebx

    # SBB reg, imm with CF=1
    movl $0xFFFFFFFF, %ecx
    addl $0x00000002, %ecx           # CF=1
    movl $0x00000010, %eax
    sbbl $0x00000001, %eax           # EAX = 0x10 - 1 - 1 = 0xE
    addl %eax,        %ebx

    # SBB reg, reg with CF=1
    movl $0xFFFFFFFF, %ecx
    addl $0x00000002, %ecx           # CF=1
    movl $0x00000100, %eax
    movl $0x00000010, %edx
    sbbl %edx,        %eax           # EAX = 0x100 - 0x10 - 1 = 0xEF
    addl %eax,        %ebx

    # SBB reg, mem with CF=1
    movl $0xFFFFFFFF, %ecx
    addl $0x00000002, %ecx           # CF=1
    movl $0x00000050, 0xD0(%esi)
    movl $0x00000200, %eax
    sbbl 0xD0(%esi),  %eax           # EAX = 0x200 - 0x50 - 1 = 0x1AF
    addl %eax,        %ebx

    # SBB mem, imm with CF=0
    movl $0x00000001, %eax
    addl $0x00000001, %eax           # CF=0
    movl $0x00001000, 0xD0(%esi)
    sbbl $0x00000001, 0xD0(%esi)     # mem = 0x1000 - 1 - 0 = 0xFFF
    movl 0xD0(%esi),  %eax
    addl %eax,        %ebx

    # SBB mem, reg with CF=1
    movl $0xFFFFFFFF, %ecx
    addl $0x00000002, %ecx           # CF=1
    movl $0x00005000, 0xD0(%esi)
    movl $0x00000100, %eax
    sbbl %eax,        0xD0(%esi)     # mem = 0x5000 - 0x100 - 1 = 0x4EFF
    movl 0xD0(%esi),  %eax
    addl %eax,        %ebx

    # ================================================================
    # SECTION 7: XCHG — ALL FORMS
    # ================================================================

    movl $0xAAAAAAAA, %eax
    movl $0x55555555, %ecx
    xchgl %eax,       %ecx          # EAX=0x55555555, ECX=0xAAAAAAAA
    addl %eax,        %ebx
    addl %ecx,        %ebx

    movl $0x11111111, %eax
    movl $0x22222222, %edx
    xchgl %eax,       %edx          # EAX=0x22222222, EDX=0x11111111
    addl %eax,        %ebx
    addl %edx,        %ebx

    # XCHG reg, mem
    movl $0xCAFEBABE, 0xE0(%esi)
    movl $0xDEADC0DE, %eax
    xchgl %eax,       0xE0(%esi)    # EAX=0xCAFEBABE, mem=0xDEADC0DE
    addl %eax,        %ebx
    addl 0xE0(%esi),  %ebx

    movl $0x00000001, 0xE0(%esi)
    movl $0xFFFFFFFF, %ecx
    xchgl %ecx,       0xE0(%esi)    # ECX=0x00000001, mem=0xFFFFFFFF
    addl %ecx,        %ebx
    addl 0xE0(%esi),  %ebx

    # XCHG EAX, r32 short form (90+rd)
    movl $0x0000DEAD, %eax
    movl $0x0000BEEF, %edi
    xchgl %eax,       %edi          # EAX=0x0000BEEF, EDI=0x0000DEAD
    addl %eax,        %ebx
    addl %edi,        %ebx

    # ================================================================
    # SECTION 8: BSF — BIT SCAN FORWARD, REGISTER AND MEMORY
    # ================================================================

    movl $0x00000001, %eax
    bsfl %eax,        %ecx          # ECX = 0
    addl %ecx,        %ebx

    movl $0x00000002, %eax
    bsfl %eax,        %ecx          # ECX = 1
    addl %ecx,        %ebx

    movl $0x00000080, %eax
    bsfl %eax,        %ecx          # ECX = 7
    addl %ecx,        %ebx

    movl $0x00008000, %eax
    bsfl %eax,        %ecx          # ECX = 15
    addl %ecx,        %ebx

    movl $0x80000000, %eax
    bsfl %eax,        %ecx          # ECX = 31
    addl %ecx,        %ebx

    movl $0xFFFF0000, %eax
    bsfl %eax,        %ecx          # ECX = 16
    addl %ecx,        %ebx

    movl $0x00100000, %eax
    bsfl %eax,        %ecx          # ECX = 20
    addl %ecx,        %ebx

    # BSF from memory
    movl $0x00010000, 0xF0(%esi)
    bsfl 0xF0(%esi),  %ecx          # ECX = 16
    addl %ecx,        %ebx

    movl $0x00000100, 0xF0(%esi)
    bsfl 0xF0(%esi),  %ecx          # ECX = 8
    addl %ecx,        %ebx

    movl $0x00200000, 0xF0(%esi)
    bsfl 0xF0(%esi),  %ecx          # ECX = 21
    addl %ecx,        %ebx

    # ================================================================
    # SECTION 9: CMOVC — CONDITIONAL MOVE IF CARRY (CF=1)
    # ================================================================

    # CF=1: move should happen
    movl $0xFFFFFFFF, %eax
    addl $0x00000002, %eax           # CF=1
    movl $0xDEADBEEF, %ecx
    movl $0x00000000, %edx
    cmovcl %ecx,      %edx           # EDX = 0xDEADBEEF
    addl %edx,        %ebx

    # CF=0: move should NOT happen
    movl $0x00000001, %eax
    addl $0x00000001, %eax           # CF=0
    movl $0x12345678, %ecx
    movl $0xABCDABCD, %edx
    cmovcl %ecx,      %edx           # EDX stays 0xABCDABCD
    addl %edx,        %ebx

    # CMOVC from memory, CF=1
    movl $0xFFFFFFFF, %eax
    addl $0x00000002, %eax           # CF=1
    movl $0x11223344, 0xF0(%esi)
    movl $0x00000000, %ecx
    cmovcl 0xF0(%esi), %ecx          # ECX = 0x11223344
    addl %ecx,        %ebx

    # CMOVC from memory, CF=0
    movl $0x00000001, %eax
    addl $0x00000001, %eax           # CF=0
    movl $0x99887766, 0xF0(%esi)
    movl $0xFEFEFEFE, %ecx
    cmovcl 0xF0(%esi), %ecx          # ECX stays 0xFEFEFEFE
    addl %ecx,        %ebx

    # ================================================================
    # SECTION 10: CMPXCHG — REGISTER AND MEMORY
    # ================================================================

    # Case 1: EAX matches memory — write occurs
    movl $0xCAFECAFE, 0x500(%esi)
    movl $0xCAFECAFE, %eax
    movl $0x12345678, %ecx
    cmpxchgl %ecx,    0x500(%esi)    # mem = 0x12345678, ZF=1
    movl 0x500(%esi), %eax
    addl %eax,        %ebx

    # Case 2: EAX does NOT match memory — write does not occur, EAX=mem
    movl $0xDEADBEEF, 0x500(%esi)
    movl $0x00000000, %eax
    movl $0x99999999, %ecx
    cmpxchgl %ecx,    0x500(%esi)    # ZF=0, EAX=0xDEADBEEF, mem unchanged
    addl %eax,        %ebx
    addl 0x500(%esi), %ebx

    # Case 3: register operand — EAX matches
    movl $0xAAAA5555, %edx
    movl $0xAAAA5555, %eax
    movl $0x0F0F0F0F, %ecx
    cmpxchgl %ecx,    %edx           # EDX = 0x0F0F0F0F, ZF=1
    addl %edx,        %ebx

    # Case 4: register operand — EAX does not match
    movl $0x12121212, %edx
    movl $0xFFFFFFFF, %eax
    movl $0xABCDABCD, %ecx
    cmpxchgl %ecx,    %edx           # EDX unchanged, EAX = 0x12121212
    addl %edx,        %ebx
    addl %eax,        %ebx

    # ================================================================
    # SECTION 11: PUSH / POP — REGISTERS, IMMEDIATES, MEMORY
    # ================================================================

    movl $0x11111111, %eax
    movl $0x22222222, %ecx
    movl $0x33333333, %edx

    pushl %eax                       # push 0x11111111
    pushl %ecx                       # push 0x22222222
    pushl %edx                       # push 0x33333333

    popl  %edx                       # EDX = 0x33333333
    popl  %ecx                       # ECX = 0x22222222
    popl  %eax                       # EAX = 0x11111111

    addl %eax,        %ebx
    addl %ecx,        %ebx
    addl %edx,        %ebx

    # PUSH immediate
    pushl $0xDEAD0001
    pushl $0xDEAD0002
    popl  %eax                       # EAX = 0xDEAD0002
    popl  %ecx                       # ECX = 0xDEAD0001
    addl %eax,        %ebx
    addl %ecx,        %ebx

    # PUSH/POP memory operands
    movl $0xBEEF1234, 0x540(%esi)
    pushl 0x540(%esi)                # push 0xBEEF1234
    popl  0x560(%esi)                # pop into different mem location
    movl 0x560(%esi), %eax
    addl %eax,        %ebx

    # Save EBX on stack, corrupt it, restore
    pushl %ebx
    movl $0xDEADDEAD, %ebx
    popl  %ebx

    # ================================================================
    # SECTION 12: CLD / STD — DIRECTION FLAG
    # ================================================================

    movl $0x00ABCDEF, 0x520(%esi)
    cld                              # DF = 0
    movl 0x520(%esi), %eax
    addl %eax,        %ebx

    std                              # DF = 1
    movl 0x520(%esi), %eax           # Normal load unaffected by DF
    addl %eax,        %ebx

    cld                              # DF = 0 (restore)
    movl $0xFEDCBA00, 0x520(%esi)
    movl 0x520(%esi), %eax
    addl %eax,        %ebx

    # ================================================================
    # SECTION 13: CALL / RET — NEAR SUBROUTINES
    # ================================================================

    call  sub_add_constant           # EAX = 0xABCD0000
    addl  %eax,       %ebx

    call  sub_shift_and              # EAX = computed value
    addl  %eax,       %ebx

    call  sub_mem_ops                # side-effects into 0x580(%esi)
    movl  0x580(%esi),%eax
    addl  %eax,       %ebx

    call  sub_logic_chain            # EAX = computed value
    addl  %eax,       %ebx

    jmp   after_subs

# ---------------------------------------------------------------
# Subroutine: sub_add_constant
#   Returns EAX = 0xABCD0000
# ---------------------------------------------------------------
sub_add_constant:
    movl $0xABCC0000, %eax
    addl $0x00010000, %eax           # EAX = 0xABCD0000
    ret

# ---------------------------------------------------------------
# Subroutine: sub_shift_and
#   Returns EAX computed via SAL, SAR, AND, NOT
# ---------------------------------------------------------------
sub_shift_and:
    movl $0xF0F0F0F0, %eax
    sarl $4,          %eax           # EAX = 0xFF0F0F0F
    andl $0x0FFFFFFF, %eax           # EAX = 0x0F0F0F0F
    notl %eax                        # EAX = 0xF0F0F0F0
    ret

# ---------------------------------------------------------------
# Subroutine: sub_mem_ops
#   Builds a value in 0x580(%esi) via OR chains and NOT
# ---------------------------------------------------------------
sub_mem_ops:
    movl $0x00000000, 0x580(%esi)
    orl  $0x12000000, 0x580(%esi)
    orl  $0x00340000, 0x580(%esi)
    orl  $0x00005600, 0x580(%esi)
    orl  $0x00000078, 0x580(%esi)   # mem = 0x12345678
    notl 0x580(%esi)                 # mem = 0xEDCBA987
    andl $0xFFFF0000, 0x580(%esi)   # mem = 0xEDCB0000
    ret

# ---------------------------------------------------------------
# Subroutine: sub_logic_chain
#   Returns EAX via a chain of register logic ops
# ---------------------------------------------------------------
sub_logic_chain:
    movl $0x0F0F0F0F, %eax
    movl $0xF0F0F0F0, %ecx
    andl %ecx,        %eax           # EAX = 0x00000000
    notl %eax                        # EAX = 0xFFFFFFFF
    movl $0x55555555, %ecx
    andl %ecx,        %eax           # EAX = 0x55555555
    sall $1,          %eax           # EAX = 0xAAAAAAAA
    orl  $0x00000001, %eax           # EAX = 0xAAAAAAAB
    ret

after_subs:

    # ================================================================
    # SECTION 14: CALL / RET WITH STACK-PASSED ARGUMENTS
    # ================================================================

    pushl $0x00000064               # arg2 = 100
    pushl $0x00000036               # arg1 = 54
    movl $0xAABBCCDD, %ebp
    call  sub_add_args              # EAX = 54 + 100 = 154
    addl  $8,         %esp          # cdecl caller cleanup
    addl  %eax,       %ebx

    pushl $0xAAAA0000
    pushl $0x5555FFFF
    call  sub_and_args              # EAX = arg1 AND arg2
    addl  $8,         %esp
    addl  %eax,       %ebx

    pushl $0x00FF00FF
    pushl $0xFF00FF00
    call  sub_or_args               # EAX = arg1 OR arg2 = 0xFFFFFFFF
    addl  $8,         %esp
    addl  %eax,       %ebx

    jmp   after_arg_subs

sub_add_args:
    # [ESP] = return addr, [ESP+4] = arg1, [ESP+8] = arg2
    push %ebp
    mov %esp, %ebp
    movl 0x4(%ebp),   %eax
    addl 0x8(%ebp),   %eax
    pop %ebp
    ret

sub_and_args:
    push %ebp
    mov %esp, %ebp
    movl 0x4(%ebp),   %eax
    andl 0x8(%ebp),   %eax
    pop %ebp
    ret

sub_or_args:
    push %ebp
    mov %esp, %ebp
    movl 0x4(%ebp),   %eax
    orl  0x8(%ebp),   %eax
    pop %ebp
    ret

after_arg_subs:

    # ================================================================
    # SECTION 15: NESTED CALLS
    # ================================================================

    call  sub_outer
    addl  %eax,       %ebx

    jmp   after_nested

sub_inner_shift:
    movl $0x00BABE00, %eax
    sall $4,          %eax          # EAX = 0x0BABE000
    andl $0x0FFFFFFF, %eax          # EAX = 0x0BABE000
    ret

sub_outer:
    pushl %ebx                       # save accumulator
    call  sub_inner_shift            # EAX = 0x0BABE000
    movl %eax,        %ecx
    notl %ecx                        # ECX = NOT result
    andl $0xFFFF0000, %ecx
    orl  %ecx,        %eax           # mix in high half of NOT
    popl  %ebx                       # restore accumulator
    ret

after_nested:

    # ================================================================
    # SECTION 16: MULTI-REGISTER PUSH/POP SPILL
    # ================================================================

    movl $0xAAAA1111, %eax
    movl $0xBBBB2222, %ecx
    movl $0xCCCC3333, %edx
    movl $0xDDDD4444, %edi

    pushl %eax
    pushl %ecx
    pushl %edx
    pushl %edi

    movl $0x00000001, %eax
    movl $0x00000002, %ecx
    movl $0x00000004, %edx
    movl $0x00000008, %edi

    addl %eax,        %ebx
    addl %ecx,        %ebx
    addl %edx,        %ebx
    addl %edi,        %ebx

    popl  %edi
    popl  %edx
    popl  %ecx
    popl  %eax

    addl %eax,        %ebx
    addl %ecx,        %ebx
    addl %edx,        %ebx
    addl %edi,        %ebx

    # ================================================================
    # SECTION 17: STACK DEPTH STRESS — PUSH 8, POP 8 IN LIFO ORDER
    # ================================================================

    pushl $0x01000000
    pushl $0x02000000
    pushl $0x03000000
    pushl $0x04000000
    pushl $0x05000000
    pushl $0x06000000
    pushl $0x07000000
    pushl $0x08000000

    popl  %eax
    addl  %eax,       %ebx          # 0x08000000
    popl  %eax
    addl  %eax,       %ebx          # 0x07000000
    popl  %eax
    addl  %eax,       %ebx          # 0x06000000
    popl  %eax
    addl  %eax,       %ebx          # 0x05000000
    popl  %eax
    addl  %eax,       %ebx          # 0x04000000
    popl  %eax
    addl  %eax,       %ebx          # 0x03000000
    popl  %eax
    addl  %eax,       %ebx          # 0x02000000
    popl  %eax
    addl  %eax,       %ebx          # 0x01000000

    # ================================================================
    # SECTION 18: DCACHE THRASH LOOP — WIDE STRIDE, MANY REGISTERS
    # ================================================================

    movl $0x10000001, (%esi)
    movl $0x20000002, 0x200(%esi)
    movl $0x00000010, %ecx          # loop count = 16

dc_thrash_loop:
    movl (%esi),       %eax
    addl 0x200(%esi),  %eax
    movl %eax,        (%esi)
    movl %eax,        0x200(%esi)
    addl $-1,         %ecx
    jne  dc_thrash_loop

    addl %eax,        %ebx

    # Second thrash: AND/OR/NOT interleaved each iteration
    movl $0xF0F0F0F0, 0x5A0(%esi)
    movl $0x0F0F0F0F, 0x5C0(%esi)
    movl $0x00000010, %ecx

dc_thrash2_loop:
    movl 0x5A0(%esi),  %eax
    andl 0x5C0(%esi),  %eax
    notl %eax
    orl  0x5A0(%esi),  %eax
    movl %eax,        0x5A0(%esi)
    addl $-1,         %ecx
    jne  dc_thrash2_loop

    addl %eax,        %ebx

    # ================================================================
    # SECTION 19: JNBE — JUMP IF NOT BELOW OR EQUAL (CF=0 AND ZF=0)
    # ================================================================

    movl $0x00000000, %edx

    # ZF=0, CF=0 -> branch taken
    movl $0x00000001, %eax
    addl $0x00000001, %eax           # EAX=2, CF=0, ZF=0
    jnbe jnbe_taken_1
    addl $0xDEAD0000, %edx           # should NOT execute
jnbe_taken_1:
    addl $0x00000001, %edx           # EDX=1

    # ZF=1 -> branch NOT taken
    movl $0x00000000, %eax
    addl $0x00000000, %eax           # ZF=1
    jnbe jnbe_taken_2
    addl $0x00000010, %edx           # executes, EDX=0x11
    jmp  jnbe_done_2
jnbe_taken_2:
    addl $0xDEAD0000, %edx
jnbe_done_2:

    # CF=1 -> branch NOT taken
    movl $0xFFFFFFFF, %eax
    addl $0x00000002, %eax           # CF=1
    jnbe jnbe_taken_3
    addl $0x00000100, %edx           # executes, EDX=0x111
    jmp  jnbe_done_3
jnbe_taken_3:
    addl $0xDEAD0000, %edx
jnbe_done_3:

    addl %edx,        %ebx           # EDX = 0x111

    # ================================================================
    # SECTION 20: SAL/SAR AND ADC/SBB INTERLEAVED WITH STACK
    # ================================================================

    # Compute a value, push it, shift it, push that, then ADC
    movl $0x00010000, %eax
    pushl %eax                       # push 0x00010000
    sall $4,          %eax           # EAX = 0x00100000
    pushl %eax                       # push 0x00100000

    popl  %ecx                       # ECX = 0x00100000
    popl  %edx                       # EDX = 0x00010000

    movl $0x00000001, %eax
    addl $0x00000001, %eax           # CF=0
    adcl %edx,        %ecx           # ECX = 0x00110000 + 0 = 0x00110000
    addl %ecx,        %ebx

    # SBB from a pushed value
    movl $0x00FF0000, %eax
    pushl %eax
    movl $0xFFFFFFFF, %ecx
    addl $0x00000002, %ecx           # CF=1
    popl  %edx                       # EDX = 0x00FF0000
    sbbl $0x00010000, %edx           # EDX = 0xFF0000 - 0x10000 - 1 = 0xEEFFFF
    addl %edx,        %ebx

    # ================================================================
    # SECTION 21: XCHG AND BSF WITH STACK INTERMEDIARY
    # ================================================================

    movl $0x00100000, %eax
    pushl %eax
    movl $0xFFFFFFFF, %eax
    popl  %ecx                       # ECX = 0x00100000
    xchgl %eax,       %ecx           # EAX=0x00100000, ECX=0xFFFFFFFF
    bsfl  %eax,       %edx           # EDX = 20
    addl  %edx,       %ebx
    bsfl  %ecx,       %edx           # EDX = 0
    addl  %edx,       %ebx

    movl $0x00ABCD00, 0x5E0(%esi)
    pushl 0x5E0(%esi)                # push mem value
    movl  $0x00DCBA00, %eax
    xchgl %eax,       0x5E0(%esi)    # EAX=0x00ABCD00, mem=0x00DCBA00
    addl  %eax,       %ebx
    popl  %ecx                       # ECX = original 0x00ABCD00
    addl  %ecx,       %ebx

    # ================================================================
    # SECTION 22: CMPXCHG IN A COUNTED LOOP
    # ================================================================

    movl $0x00000003, %edi           # loop count

cmpxchg_loop:
    movl $0xFEEDFACE, 0x5A0(%esi)   # reset mem each iteration
    movl $0xFEEDFACE, %eax           # expected = current
    movl $0xC0DE1234, %ecx
    cmpxchgl %ecx,    0x5A0(%esi)    # should succeed every time
    movl 0x5A0(%esi), %eax
    addl %eax,        %ebx
    addl $-1,         %edi
    jne  cmpxchg_loop

    # ================================================================
    # SECTION 23: BSF ON OR-CHAIN RESULTS
    # ================================================================

    movl $0x00000000, %eax
    orl  $0x00000010, %eax           # bit 4 set
    orl  $0x00001000, %eax           # bit 12 set
    bsfl %eax,        %ecx           # ECX = 4 (lowest set bit)
    addl %ecx,        %ebx

    movl $0xFFFFF800, %eax           # lowest set bit = bit 11
    bsfl %eax,        %ecx           # ECX = 11
    addl %ecx,        %ebx

    # ================================================================
    # SECTION 24: FINAL CMOVC INTEGRATION PASS
    # ================================================================

    # CF=1 -> move happens
    movl $0xFFFFFFFF, %eax
    addl $0x00000001, %eax           # CF=1
    movl $0x0000CAFE, %edx
    movl $0x0000DEAD, %ecx
    cmovcl %ecx,      %edx           # EDX = 0x0000DEAD
    addl %edx,        %ebx

    # CF=0 -> move does not happen
    movl $0x00000001, %eax
    addl $0x00000001, %eax           # CF=0
    movl $0xABCD0000, %edx
    movl $0x00001234, %ecx
    cmovcl %ecx,      %edx           # EDX stays 0xABCD0000
    addl %edx,        %ebx

    # Alternate: CMOVC from memory with CF=1
    movl $0xFFFFFFFF, %eax
    addl $0x00000002, %eax           # CF=1
    movl $0x0AAAAAAA, 0x5F0(%esi)
    movl $0x00000000, %ecx
    cmovcl 0x5F0(%esi), %ecx         # ECX = 0x0AAAAAAA
    addl %ecx,        %ebx

    # ================================================================
    # SECTION 25: SBB COUNTDOWN LOOP
    # ================================================================

    movl $0x08000000, %eax
    movl $0x01000000, %edx
    movl $0x00000008, %ecx

sbb_loop:
    # Ensure CF=0 before each SBB: dummy add of 0 sets CF=0
    addl $0x00000000, %eax
    sbbl %edx,        %eax           # EAX -= EDX - 0
    addl %eax,        %ebx
    addl $-1,         %ecx
    jne  sbb_loop

    # ================================================================
    # SECTION 26: COMBINED ICACHE JMP CHAIN
    # ================================================================

    jmp ic_fill_1

ic_fill_1:
    movl $0x16161616, (%esi)
    movl $0x16161616, 0x200(%esi)
    addl (%esi),      %ebx
    andl $0xFFFFFF00, 0x400(%esi)
    movl 0x400(%esi), %eax
    addl %eax,        %ebx
    jmp  ic_fill_2

ic_fill_2:
    movl $0x17171717, 0x10(%esi)
    movl $0x17171717, 0x210(%esi)
    addl 0x10(%esi),  %ebx
    addl 0x210(%esi), %ebx
    andl $0x0FFFFFFF, (%esi)
    jmp  ic_fill_3

ic_fill_3:
    movl $0x18181818, 0x40(%esi)
    movl $0x18181818, 0x240(%esi)
    addl 0x40(%esi),  %ebx
    movl 0x240(%esi), %eax
    andl %eax,        %ebx
    movl $0x18181818, 0x20(%esi)
    addl 0x20(%esi),  %ebx
    jmp  ic_fill_4

ic_fill_4:
    movl $0x19191919, 0x200(%esi)
    addl 0x200(%esi), %ebx
    movl $0x17171717, 0x400(%esi)
    andl $0x1F1F1F1F, 0x800(%esi)
    movl 0x800(%esi), %eax
    addl %eax,        %ebx
    jmp  ic_fill_5

ic_fill_5:
    movl $0x1A1A1A1A, (%esi)
    addl (%esi),      %ebx
    movl $0x1A1A1A1A, 0x600(%esi)
    addl 0x600(%esi), %ebx
    andl $0xF0F0F0F0, 0x200(%esi)
    movl $0x00000010, %ecx
    jmp  ic_thrash_a

ic_thrash_a:
    movl $0xBBBBBBBB, (%esi)
    addl (%esi),      %ebx
    movl $0xBBBBBBBB, 0x40(%esi)
    andl $0xBBBBBBBB, 0x80(%esi)
    addl $-1,         %ecx
    jne  ic_thrash_b
    jmp  ic_done

ic_thrash_b:
    movl $0xCCCCCCCC, 0x200(%esi)
    addl 0x200(%esi), %ebx
    movl $0xCCCCCCCC, 0x240(%esi)
    andl $0xCCCCCCCC, 0x280(%esi)
    addl $-1,         %ecx
    jne  ic_thrash_a

ic_done:
    hlt

# ================================================================
# DATA SECTION — mapped at 0x2000
# ================================================================

.org 0x02000
.data

data_page:
    .space 0xC00

# ================================================================
# STACK SECTION — mapped at 0x4000
# ESP initialised to 0x5000 so the stack grows downward into this page
# ================================================================

.org 0x04000
.data

stack_page:
    .space 0x1000
