.org 0x1000
.code
.global _start

_start:
    movl $data_page, %esi      # ESI = base of writable data page (0x2000)

    # ============================================================
    # SAL / SHL — Shift Arithmetic Left  (SHL and SAL share opcodes)
    # ============================================================

    # ─────────────────────────────────────────────────────────────
    # SAL r/m8, 1  (D0 /4) — shift count = 1, implicit encoding
    # ─────────────────────────────────────────────────────────────

    # T1: AL = 0x01, shift 1 → AL = 0x02, CF=0, SF=0, ZF=0, OF=0, PF=0
    movl $0x00000001, %eax
    salb $1, %al               # AL = 0x02

    # T2: AL = 0x80 → MSB shifts out: AL = 0x00, CF=1, ZF=1, SF=0, OF=1, PF=1
    movl $0x00000080, %eax
    salb $1, %al               # AL = 0x00, CF=1, ZF=1, OF=1, PF=1
    jne  T2_nonzero            # ZF=1 → NOT taken
    movl $0x11111111, %edx     # SHOULD EXECUTE — confirms ZF=1
    jmp  T2_end
T2_nonzero:
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T2_end:
    # EXPECT: EDX = 0x11111111

    # T3: AL = 0x40 → sign changes: AL = 0x80, CF=0, SF=1, ZF=0, OF=1
    movl $0x00000040, %eax
    salb $1, %al               # AL = 0x80, CF=0, SF=1, OF=1

    # T4: AH = 0x04, shift 1 → AH = 0x08, CF=0, SF=0, ZF=0, OF=0
    movl $0x00000400, %eax     # EAX[15:8] = AH = 0x04
    salb $1, %ah               # AH = 0x08

    # T5: AH = 0x80 → MSB of AH shifts out: AH = 0x00, CF=1, ZF=1, OF=1, PF=1
    movl $0x00008000, %eax     # AH = 0x80
    salb $1, %ah               # AH = 0x00, CF=1, ZF=1, OF=1, PF=1

    # T6: Memory byte = 0x40, shift 1 → mem[0] = 0x80, CF=0, SF=1, ZF=0, OF=1
    movb $0x40, (%esi)
    salb $1, (%esi)            # mem[0] = 0x80, CF=0, SF=1, OF=1

    # ─────────────────────────────────────────────────────────────
    # SAL r/m8, CL  (D2 /4)
    # ─────────────────────────────────────────────────────────────

    # T7: AL = 0x01, CL = 2 → AL = 0x04, CF=0, SF=0, ZF=0
    movl $0x00000001, %eax
    movb $2, %cl
    salb %cl, %al              # AL = 0x04

    # T8: AH = 0x20, CL = 1 → AH = 0x40, CF=0, SF=0, ZF=0
    movl $0x00002000, %eax     # AH = 0x20
    movb $1, %cl
    salb %cl, %ah              # AH = 0x40

    # T9: Memory byte = 0x10, CL = 3 → mem[0] = 0x80, CF=0, SF=1, ZF=0
    movb $0x10, (%esi)
    movb $3, %cl
    salb %cl, (%esi)           # mem[0] = 0x80, CF=0, SF=1

    # ─────────────────────────────────────────────────────────────
    # SAL r/m8, imm8  (C0 /4 ib) — count > 1 uses this encoding
    # ─────────────────────────────────────────────────────────────

    # T10: AL = 0x01, shift 4 → AL = 0x10, CF=0, SF=0, ZF=0
    movl $0x00000001, %eax
    salb $4, %al               # AL = 0x10

    # T11: AH = 0x20, shift 2 → AH = 0x80, CF=0, SF=1, ZF=0
    movl $0x00002000, %eax     # AH = 0x20
    salb $2, %ah               # AH = 0x80, CF=0, SF=1

    # T12: AH = 0x18, shift 4 → AH = 0x80, CF=1, SF=1
    #   CF = bit(8-4)=bit4 of 0x18 = 1  (0x18 = 0001_1000b, bit4=1)
    movl $0x00001800, %eax     # AH = 0x18
    salb $4, %ah               # AH = 0x80, CF=1, SF=1, ZF=0

    # ─────────────────────────────────────────────────────────────
    # SAL r/m16, 1  (D1 /4 with 66h prefix)
    # ─────────────────────────────────────────────────────────────

    # T13: AX = 0x0100, shift 1 → AX = 0x0200, CF=0, SF=0, ZF=0, OF=0
    movl $0x00000100, %eax
    salw $1, %ax               # AX = 0x0200

    # T14: AX = 0x8000 → MSB shifts out: AX = 0x0000, CF=1, ZF=1, OF=1, PF=1
    movl $0x00008000, %eax
    salw $1, %ax               # AX = 0x0000, CF=1, ZF=1, OF=1, PF=1

    # T15: AX = 0x4000 → sign changes: AX = 0x8000, CF=0, SF=1, ZF=0, OF=1
    movl $0x00004000, %eax
    salw $1, %ax               # AX = 0x8000, CF=0, SF=1, OF=1

    # T16: Memory word = 0x4000, shift 1 → mem[4] = 0x8000, CF=0, SF=1, OF=1
    movw $0x4000, 4(%esi)
    salw $1, 4(%esi)           # mem[4] = 0x8000, CF=0, SF=1, OF=1

    # ─────────────────────────────────────────────────────────────
    # SAL r/m16, CL  (D3 /4 with 66h prefix)
    # ─────────────────────────────────────────────────────────────

    # T17: AX = 0x0001, CL = 4 → AX = 0x0010, CF=0, SF=0, ZF=0
    movl $0x00000001, %eax
    movb $4, %cl
    salw %cl, %ax              # AX = 0x0010

    # ─────────────────────────────────────────────────────────────
    # SAL r/m16, imm8  (C1 /4 ib with 66h prefix)
    # ─────────────────────────────────────────────────────────────

    # T18: AX = 0x0001, shift 8 → AX = 0x0100, CF=0, SF=0, ZF=0
    movl $0x00000001, %eax
    salw $8, %ax               # AX = 0x0100

    # T19: AX = 0x1000, shift 4 → AX = 0x0000, CF=1, ZF=1, PF=1
    #   CF = bit(16-4)=bit12 of 0x1000 = 1  (0x1000 = bit12 set)
    movl $0x00001000, %eax
    salw $4, %ax               # AX = 0x0000, CF=1, ZF=1, PF=1
    jne  T19_nonzero           # ZF=1 → NOT taken
    movl $0x22222222, %edx     # SHOULD EXECUTE
    jmp  T19_end
T19_nonzero:
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T19_end:
    # EXPECT: EDX = 0x22222222

    # ─────────────────────────────────────────────────────────────
    # SAL r/m32, 1  (D1 /4)
    # ─────────────────────────────────────────────────────────────

    # T20: EAX = 0x00000001, shift 1 → EAX = 0x00000002, CF=0, SF=0, ZF=0, OF=0
    movl $0x00000001, %eax
    sall $1, %eax              # EAX = 0x00000002

    # T21: EAX = 0x80000000 → CF=1, ZF=1, SF=0, OF=1, PF=1
    movl $0x80000000, %eax
    sall $1, %eax              # EAX = 0x00000000, CF=1, ZF=1, OF=1, PF=1
    jne  T21_nonzero           # ZF=1 → NOT taken
    movl $0x33333333, %edx     # SHOULD EXECUTE
    jmp  T21_end
T21_nonzero:
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T21_end:
    # EXPECT: EDX = 0x33333333

    # T22: EAX = 0x40000000 → sign changes: EAX = 0x80000000, CF=0, SF=1, ZF=0, OF=1
    movl $0x40000000, %eax
    sall $1, %eax              # EAX = 0x80000000, CF=0, SF=1, OF=1

    # ─────────────────────────────────────────────────────────────
    # SAL r/m32, CL  (D3 /4)
    # ─────────────────────────────────────────────────────────────

    # T23: EAX = 0x00000001, CL = 3 → EAX = 0x00000008, CF=0, SF=0, ZF=0
    movl $0x00000001, %eax
    movb $3, %cl
    sall %cl, %eax             # EAX = 0x00000008

    # T24: Memory dword = 0x40000000, CL = 2 → mem[8] = 0x00000000, CF=1, ZF=1
    #   CF = bit(32-2)=bit30 of 0x40000000 = 1  (0x40000000 = bit30 set)
    movl $0x40000000, 8(%esi)
    movb $2, %cl
    sall %cl, 8(%esi)          # mem[8] = 0x00000000, CF=1, ZF=1, PF=1

    # ─────────────────────────────────────────────────────────────
    # SAL r/m32, imm8  (C1 /4 ib)
    # ─────────────────────────────────────────────────────────────

    # T25: EAX = 0x00000001, shift 16 → EAX = 0x00010000, CF=0, SF=0, ZF=0
    movl $0x00000001, %eax
    sall $16, %eax             # EAX = 0x00010000

    # T26: Memory dword = 0x00001234, shift 1 → mem[12] = 0x00002468, CF=0, SF=0, ZF=0
    movl $0x00001234, 12(%esi)
    sall $1, 12(%esi)          # mem[12] = 0x00002468

    # T27: JNBE verify — EAX = 0x00000002, shift 1 → EAX = 0x00000004, CF=0, ZF=0: JNBE taken
    movl $0x00000002, %eax
    sall $1, %eax              # EAX = 0x00000004, CF=0, ZF=0, SF=0
    movl $0x44444444, %edx     # sentinel
    jnbe T27_end               # CF=0 AND ZF=0 → TAKEN → skip deadbeef
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T27_end:
    # EXPECT: EDX = 0x44444444

    # ============================================================
    # SAR — Shift Arithmetic Right  (sign bit propagated into MSB)
    # ============================================================

    # ─────────────────────────────────────────────────────────────
    # SAR r/m8, 1  (D0 /7)
    # ─────────────────────────────────────────────────────────────

    # T28: AL = 0x04 (positive) → AL = 0x02, CF=0, SF=0, ZF=0, OF=0
    movl $0x00000004, %eax
    sarb $1, %al               # AL = 0x02

    # T29: AL = 0x80 (negative) → sign replicated: AL = 0xC0, CF=0, SF=1, ZF=0, OF=0
    movl $0x00000080, %eax
    sarb $1, %al               # AL = 0xC0, CF=0, SF=1

    # T30: AL = 0x03 → CF=1 (bit0 was 1): AL = 0x01, CF=1, SF=0, ZF=0
    movl $0x00000003, %eax
    sarb $1, %al               # AL = 0x01, CF=1

    # T31: AL = 0x01 → ZF=1: AL = 0x00, CF=1, ZF=1, SF=0, OF=0
    movl $0x00000001, %eax
    sarb $1, %al               # AL = 0x00, CF=1, ZF=1
    jne  T31_nonzero           # ZF=1 → NOT taken
    movl $0x55555555, %edx     # SHOULD EXECUTE
    jmp  T31_end
T31_nonzero:
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T31_end:
    # EXPECT: EDX = 0x55555555

    # T32: AH = 0x10 (positive) → AH = 0x08, CF=0, SF=0, ZF=0
    movl $0x00001000, %eax     # AH = 0x10
    sarb $1, %ah               # AH = 0x08

    # T33: AH = 0x81 (negative, bit0=1) → AH = 0xC0, CF=1, SF=1, ZF=0
    movl $0x00008100, %eax     # AH = 0x81
    sarb $1, %ah               # AH = 0xC0, CF=1, SF=1

    # T34: Memory byte = 0xFE (negative) → mem[0] = 0xFF, CF=0, SF=1, ZF=0
    movb $0xFE, (%esi)
    sarb $1, (%esi)            # mem[0] = 0xFF, CF=0, SF=1

    # ─────────────────────────────────────────────────────────────
    # SAR r/m8, CL  (D2 /7)
    # ─────────────────────────────────────────────────────────────

    # T35: AL = 0x80 (negative), CL = 2 → AL = 0xE0, CF=0, SF=1, ZF=0
    movl $0x00000080, %eax
    movb $2, %cl
    sarb %cl, %al              # AL = 0xE0, CF=0, SF=1

    # T36: AH = 0x80 (negative), CL = 2 → AH = 0xE0, CF=0, SF=1, ZF=0
    movl $0x00008000, %eax     # AH = 0x80
    movb $2, %cl
    sarb %cl, %ah              # AH = 0xE0, CF=0, SF=1

    # ─────────────────────────────────────────────────────────────
    # SAR r/m8, imm8  (C0 /7 ib)
    # ─────────────────────────────────────────────────────────────

    # T37: AL = 0x80 (negative), shift 4 → AL = 0xF8, CF=0, SF=1, ZF=0
    movl $0x00000080, %eax
    sarb $4, %al               # AL = 0xF8, CF=0, SF=1

    # T38: AH = 0x40 (positive), shift 3 → AH = 0x08, CF=0, SF=0, ZF=0
    movl $0x00004000, %eax     # AH = 0x40
    sarb $3, %ah               # AH = 0x08, CF=0, SF=0

    # T39: AH = 0x01, shift 1 → AH = 0x00, CF=1, ZF=1, SF=0, OF=0
    movl $0x00000100, %eax     # AH = 0x01
    sarb $1, %ah               # AH = 0x00, CF=1, ZF=1
    jne  T39_nonzero           # ZF=1 → NOT taken
    movl $0x66666666, %edx     # SHOULD EXECUTE
    jmp  T39_end
T39_nonzero:
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T39_end:
    # EXPECT: EDX = 0x66666666

    # ─────────────────────────────────────────────────────────────
    # SAR r/m16, 1  (D1 /7 with 66h prefix)
    # ─────────────────────────────────────────────────────────────

    # T40: AX = 0x0100 (positive) → AX = 0x0080, CF=0, SF=0, ZF=0, OF=0
    movl $0x00000100, %eax
    sarw $1, %ax               # AX = 0x0080

    # T41: AX = 0x8000 (negative) → AX = 0xC000, CF=0, SF=1, ZF=0, OF=0
    movl $0x00008000, %eax
    sarw $1, %ax               # AX = 0xC000, CF=0, SF=1

    # T42: AX = 0x0001 → ZF=1: AX = 0x0000, CF=1, ZF=1, SF=0
    movl $0x00000001, %eax
    sarw $1, %ax               # AX = 0x0000, CF=1, ZF=1
    jne  T42_nonzero           # ZF=1 → NOT taken
    movl $0x77777777, %edx     # SHOULD EXECUTE
    jmp  T42_end
T42_nonzero:
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T42_end:
    # EXPECT: EDX = 0x77777777

    # ─────────────────────────────────────────────────────────────
    # SAR r/m16, CL  (D3 /7 with 66h prefix)
    # ─────────────────────────────────────────────────────────────

    # T43: AX = 0x8000 (negative), CL = 4 → AX = 0xF800, CF=0, SF=1, ZF=0
    movl $0x00008000, %eax
    movb $4, %cl
    sarw %cl, %ax              # AX = 0xF800, CF=0, SF=1

    # ─────────────────────────────────────────────────────────────
    # SAR r/m16, imm8  (C1 /7 ib with 66h prefix)
    # ─────────────────────────────────────────────────────────────

    # T44: AX = 0x8000 (negative), shift 8 → AX = 0xFF80, CF=0, SF=1, ZF=0
    movl $0x00008000, %eax
    sarw $8, %ax               # AX = 0xFF80, CF=0, SF=1

    # T45: Memory word = 0x8080 (negative), shift 1 → mem[4] = 0xC040, CF=0, SF=1, ZF=0
    movw $0x8080, 4(%esi)
    sarw $1, 4(%esi)           # mem[4] = 0xC040, CF=0, SF=1

    # ─────────────────────────────────────────────────────────────
    # SAR r/m32, 1  (D1 /7)
    # ─────────────────────────────────────────────────────────────

    # T46: EAX = 0x00010000 (positive) → EAX = 0x00008000, CF=0, SF=0, ZF=0
    movl $0x00010000, %eax
    sarl $1, %eax              # EAX = 0x00008000

    # T47: EAX = 0x80000000 (negative) → EAX = 0xC0000000, CF=0, SF=1, ZF=0, OF=0
    movl $0x80000000, %eax
    sarl $1, %eax              # EAX = 0xC0000000, CF=0, SF=1

    # T48: EAX = 0x00000001 → ZF=1: EAX = 0x00000000, CF=1, ZF=1, SF=0
    movl $0x00000001, %eax
    sarl $1, %eax              # EAX = 0x00000000, CF=1, ZF=1
    jne  T48_nonzero           # ZF=1 → NOT taken
    movl $0x88888888, %edx     # SHOULD EXECUTE
    jmp  T48_end
T48_nonzero:
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T48_end:
    # EXPECT: EDX = 0x88888888

    # T49: Memory dword = 0x80000001 (negative, bit0=1), shift 1
    #      → mem[8] = 0xC0000000, CF=1, SF=1, ZF=0
    movl $0x80000001, 8(%esi)
    sarl $1, 8(%esi)           # mem[8] = 0xC0000000, CF=1, SF=1

    # ─────────────────────────────────────────────────────────────
    # SAR r/m32, CL  (D3 /7)
    # ─────────────────────────────────────────────────────────────

    # T50: EAX = 0x80000000 (negative), CL = 4 → EAX = 0xF8000000, CF=0, SF=1, ZF=0
    movl $0x80000000, %eax
    movb $4, %cl
    sarl %cl, %eax             # EAX = 0xF8000000, CF=0, SF=1

    # ─────────────────────────────────────────────────────────────
    # SAR r/m32, imm8  (C1 /7 ib)
    # ─────────────────────────────────────────────────────────────

    # T51: EAX = 0x80000000 (negative), shift 16 → EAX = 0xFFFF8000, CF=0, SF=1, ZF=0
    movl $0x80000000, %eax
    sarl $16, %eax             # EAX = 0xFFFF8000, CF=0, SF=1

    # T52: Memory dword = 0x12345678 (positive), shift 8
    #      CF = bit7 of 0x12345678 = bit7 of 0x78 = 0  (0x78 = 0111_1000b)
    #      → mem[12] = 0x00123456, CF=0, SF=0, ZF=0
    movl $0x12345678, 12(%esi)
    sarl $8, 12(%esi)          # mem[12] = 0x00123456, CF=0, SF=0

    # ─────────────────────────────────────────────────────────────
    # Final JNBE verify: SAR EAX → CF=0, ZF=0 → JNBE taken
    # ─────────────────────────────────────────────────────────────
    movl $0x00000004, %eax
    sarl $1, %eax              # EAX = 0x00000002, CF=0, ZF=0, SF=0
    movl $0x99999999, %edx     # sentinel
    jnbe T_final_end           # CF=0 AND ZF=0 → TAKEN → skip deadbeef
    movl $0xDEADBEEF, %edx     # SHOULD NOT EXECUTE
T_final_end:
    # EXPECT: EDX = 0x99999999

    hlt

# ============================================================
# DATA — writable scratch area (page 0x2000, mapped in TLB)
# ============================================================

.org 0x2000
.data

data_page:
    .long 0x00000000    # offset  0  byte scratch  (T6 SAL/T9 SAL/T34 SAR mem8)
    .long 0x00000000    # offset  4  word scratch  (T16 SAL/T45 SAR mem16)
    .long 0x00000000    # offset  8  dword scratch (T24 SAL CL / T49 SAR)
    .long 0x00000000    # offset 12  dword scratch (T26 SAL imm8 / T52 SAR imm8)
