.org 0x1000
.code
.global _start

_start:
    movl $data_page, %esi      # ESI = base of writable data page (0x2000)

    # ============================================================
    # BSF r32,r/m32  (0F BC)  — Bit Scan Forward, 32-bit
    # ============================================================

    # T1: lowest set bit = bit 0 → ECX = 0, ZF=0
    movl $0x00000001, %eax
    bsfl %eax, %ecx            # ECX = 0,  ZF = 0

    # T2: lowest set bit = bit 2 → ECX = 2, ZF=0
    movl $0x00000004, %eax
    bsfl %eax, %ecx            # ECX = 2,  ZF = 0

    # T3: lowest set bit = bit 12 → ECX = 12, ZF=0
    movl $0x00001000, %eax
    bsfl %eax, %ecx            # ECX = 12, ZF = 0

    # T4: multiple set bits, lowest = bit 4 → ECX = 4, ZF=0
    movl $0xFFFFFFF0, %eax
    bsfl %eax, %ecx            # ECX = 4,  ZF = 0

    # T5: only bit 31 set → ECX = 31, ZF=0
    movl $0x80000000, %eax
    bsfl %eax, %ecx            # ECX = 31, ZF = 0

    # T6: source = 0 → ZF=1, dest undefined
    #     JNE is NOT taken (ZF=1), so we fall through to the sentinel
    movl $0x00000000, %eax
    bsfl %eax, %ecx            # ZF = 1  (src == 0)
    jne  T6_nonzero            # ZF=1 → NOT taken
    movl $0xAAAAAAAA, %edx     # SHOULD EXECUTE — confirms ZF=1
    jmp  T6_end
T6_nonzero:
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T6_end:
    # EXPECT: EDX = 0xAAAAAAAA
    # T7: source from memory (0x100 → bit 8) → ECX = 8, ZF=0
    movl $0x00000100, %eax
    movl %eax, (%esi)          # mem[data_page+0] = 0x00000100
    bsfl (%esi), %ecx          # ECX = 8,  ZF = 0

    # ============================================================
    # BSF r16,r/m16  (66h prefix + 0F BC)
    # ============================================================

    # T8: 16-bit scan, bit 0 → BX = 0, ZF=0
    movw $0x0001, %ax
    bsfw %ax, %bx              # BX = 0,  ZF = 0

    # T9: 16-bit scan, bit 8 → BX = 8, ZF=0
    movw $0x0100, %ax
    bsfw %ax, %bx              # BX = 8,  ZF = 0

    # T10: 16-bit scan, bit 15 → BX = 15, ZF=0
    movw $0x8000, %ax
    bsfw %ax, %bx              # BX = 15, ZF = 0

    # T11: 16-bit scan from memory (0x0080 → bit 7) → BX = 7, ZF=0
    movw $0x0080, %ax
    movw %ax, 4(%esi)          # mem[data_page+4] = 0x0080 (low 16 bits)
    bsfw 4(%esi), %bx          # BX = 7,  ZF = 0

    # ============================================================
    # SBB r/m32,imm32  (81 /3)
    #   Immediates > 127 cannot be encoded as imm8 → forces 81 encoding.
    # AT&T:  sbbl $imm32, r/m32
    # ============================================================

    # T12: CF=0: EBX = 0x1000 - 0x100 - 0 = 0xF00
    movl $0x00001000, %ebx
    andl %ebx, %ebx            # clear CF (AND always clears CF/OF)
    sbbl $0x00000100, %ebx     # EBX = 0xF00, CF=0, ZF=0, SF=0, OF=0

    # T13: CF=1: EBX = 0x1000 - 0x100 - 1 = 0xEFF
    movl $0xFFFFFFFF, %eax
    addl $0x00000001, %eax     # CF = 1
    movl $0x00001000, %ebx
    sbbl $0x00000100, %ebx     # EBX = 0xEFF, CF=0

    # T14: borrow out: 0x10 - 0x100 wraps → EBX = 0xFFFFFF10, CF=1, SF=1
    movl $0x00000010, %ebx
    andl %ebx, %ebx            # clear CF
    sbbl $0x00000100, %ebx     # EBX = 0xFFFFFF10, CF=1, SF=1, OF=0

    # T15: signed overflow: 0x7FFFFFFF - 0x80000001 = 0xFFFFFFFE, OF=1, CF=1, SF=1
    #   Signed: MAX_INT - MIN_INT+1 overflows into negative territory
    movl $0x7FFFFFFF, %ebx
    andl %ebx, %ebx            # clear CF
    sbbl $0x80000001, %ebx     # EBX = 0xFFFFFFFE, OF=1, CF=1, SF=1

    # T16: result = 0 → ZF=1: 0x100 - 0x100 - 0 = 0
    movl $0x00000100, %ebx
    andl %ebx, %ebx            # clear CF
    sbbl $0x00000100, %ebx     # EBX = 0, ZF=1, CF=0

    # ============================================================
    # SBB r/m32,imm8  (83 /3)
    #   Immediates in [-128, 127] are sign-extended from 8 bits.
    # AT&T:  sbbl $imm8, r/m32
    # ============================================================

    # T17: CF=0: EAX = 0x1000 - 5 - 0 = 0xFFB
    movl $0x00001000, %eax
    andl %eax, %eax            # clear CF
    sbbl $5, %eax              # EAX = 0xFFB, CF=0

    # T18: CF=1: EAX = 0x1000 - 5 - 1 = 0xFFA
    movl $0xFFFFFFFF, %ecx
    addl $0x00000001, %ecx     # CF = 1
    movl $0x00001000, %eax
    sbbl $5, %eax              # EAX = 0xFFA, CF=0

    # T19: negative imm8 ($-1 sign-extended → 0xFFFFFFFF), CF=0
    #   EAX = 0x10 - 0xFFFFFFFF - 0 = 0x11 with borrow (CF=1)
    movl $0x00000010, %eax
    andl %eax, %eax            # clear CF
    sbbl $-1, %eax             # EAX = 0x11, CF=1

    # T20: large imm8 = 127: EAX = 0x100 - 0x7F - 0 = 0x81
    movl $0x00000100, %eax
    andl %eax, %eax            # clear CF
    sbbl $127, %eax            # EAX = 0x81, CF=0

    # ============================================================
    # SBB r/m32,r32  (19 /r)
    #   dst=r/m32, src=r32  — AT&T: sbbl %r32src, r/m32dst
    # ============================================================

    # T21: CF=0: ECX = 0x50 - 0x20 - 0 = 0x30
    movl $0x00000050, %ecx
    movl $0x00000020, %edx
    andl %ecx, %ecx            # clear CF
    sbbl %edx, %ecx            # ECX = 0x30, CF=0

    # T22: CF=1: ECX = 0x50 - 0x20 - 1 = 0x2F
    movl $0xFFFFFFFF, %eax
    addl $0x00000001, %eax     # CF = 1
    movl $0x00000050, %ecx
    movl $0x00000020, %edx
    sbbl %edx, %ecx            # ECX = 0x2F, CF=0

    # T23: borrow: ECX = 0 - 1 - 0 = 0xFFFFFFFF, CF=1, SF=1
    movl $0x00000000, %ecx
    movl $0x00000001, %edx
    andl %ecx, %ecx            # clear CF
    sbbl %edx, %ecx            # ECX = 0xFFFFFFFF, CF=1, SF=1

    # T24: destination in memory: mem[8] = 0x200 - 0x10 - 0 = 0x1F0
    movl $0x00000200, %eax
    movl %eax, 8(%esi)         # mem[data_page+8] = 0x200
    movl $0x00000010, %ebx
    andl %eax, %eax            # clear CF
    sbbl %ebx, 8(%esi)         # mem[data_page+8] = 0x1F0, CF=0

    # ============================================================
    # SBB r32,r/m32  (1B /r)
    #   dst=r32, src=r/m32  — AT&T: sbbl r/m32src, %r32dst
    # ============================================================

    # T25: reg-reg CF=0: EBX = 0x100 - 0x10 - 0 = 0xF0
    movl $0x00000100, %ebx
    movl $0x00000010, %ecx
    andl %ebx, %ebx            # clear CF
    sbbl %ecx, %ebx            # EBX = 0xF0, CF=0

    # T26: reg-reg CF=1: EBX = 0x100 - 0x10 - 1 = 0xEF
    movl $0xFFFFFFFF, %eax
    addl $0x00000001, %eax     # CF = 1
    movl $0x00000100, %ebx
    movl $0x00000010, %ecx
    sbbl %ecx, %ebx            # EBX = 0xEF, CF=0

    # T27: source from memory, CF=0: EBX = 0x200 - mem[12] - 0 = 0x1B0
    movl $0x00000050, %eax
    movl %eax, 12(%esi)        # mem[data_page+12] = 0x50
    movl $0x00000200, %ebx
    andl %ebx, %ebx            # clear CF
    sbbl 12(%esi), %ebx        # EBX = 0x1B0, CF=0

    # T28: source from memory, CF=1: EBX = 0x200 - mem[12] - 1 = 0x1AF
    movl $0xFFFFFFFF, %eax
    addl $0x00000001, %eax     # CF = 1
    movl $0x00000050, %eax
    movl %eax, 12(%esi)        # mem[data_page+12] = 0x50
    movl $0x00000200, %ebx
    sbbl 12(%esi), %ebx        # EBX = 0x1AF, CF=0

    # ============================================================
    # VERIFY: use JNBE to branch on CF=0, ZF=0 (taken expected)
    #   After T28: CF=0, ZF=0  →  JNBE taken  →  EAX = 0x12345678
    # ============================================================
    movl $0x12345678, %eax     # sentinel
    jnbe T_jnbe_end            # CF=0 and ZF=0 → TAKEN → skip deadbeef
    movl $0xDEADBEEF, %eax     # SHOULD NOT EXECUTE
T_jnbe_end:
    # EXPECT: EAX = 0x12345678

    hlt

# ============================================================
# DATA — writable scratch area (page 0x2000, mapped in TLB)
# ============================================================

.org 0x2000
.data

data_page:
    .long 0x00000000    # offset  0  T7  (BSF r32 from mem)
    .long 0x00000000    # offset  4  T11 (BSF r16 from mem)
    .long 0x00000000    # offset  8  T24 (SBB 19/r mem dst)
    .long 0x00000000    # offset 12  T27/T28 (SBB 1B/r mem src)
