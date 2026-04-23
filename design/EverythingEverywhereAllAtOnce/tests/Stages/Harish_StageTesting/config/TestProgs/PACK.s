.org 0x1000
.code
.global _start

# ================================================================
# PACK.s — MMX SIMD + scalar MOV/ADD/ADC/AND/AAA coverage
#
# Memory layout at data_page (0x2000):
#   +0x00  T1 PACKSSWB  mm0 input
#   +0x08  T1 PACKSSWB  mm1 input
#   +0x10  T2 PACKSSDW  mm0 input
#   +0x18  T2 PACKSSDW  mm1 input
#   +0x20  T3 PADDW     mm0 input
#   +0x28  T3 PADDW     mm1 input
#   +0x30  T4 PADDD     mm0 input
#   +0x38  T4 PADDD     mm1 input
#   +0x40  T5 PAVGB     mm0 input
#   +0x48  T5 PAVGB     mm1 input
#   +0x50  T6 PAVGW     mm0 input
#   +0x58  T6 PAVGW     mm1 input
#   +0x60  MOVQ scratch / result (8 bytes)
#   +0x68  byte scratch for MOV r/m8 tests
#   +0x6C  word scratch for MOV r/m16 tests
#   +0x70  dword scratch for MOV r/m32 tests
# ================================================================

_start:
    movl    $0x00002000, %esi       # ESI = data_page base

    # ============================================================
    # T1: PACKSSWB  (0F 63)
    # mm0 words: [0x0001, 0x007F, 0x0100, 0x8000]
    #   sat bytes: [0x01, 0x7F, 0x7F, 0x80]
    # mm1 words: [0x0000, 0x007E, 0x7FFF, 0x8001]
    #   sat bytes: [0x00, 0x7E, 0x7F, 0x80]
    # EXPECT mm0 = 0x807F7E00_807F7F01
    # ============================================================
    movq    0x00(%esi), %mm0
    movq    0x08(%esi), %mm1
    packsswb %mm1, %mm0
    movq    %mm0, 0x60(%esi)

    movl    0x60(%esi), %eax        # lower: 0x807F7F01
    movl    0x64(%esi), %ebx        # upper: 0x807F7E00
    movl    $0x11111111, %edx

    # ============================================================
    # T2: PACKSSDW  (0F 6B)
    # mm0 dwords: [0x00007FFF, 0x00010000]
    #   sat words: [0x7FFF, 0x7FFF]
    # mm1 dwords: [0x80000000, 0xFFFF8000]
    #   sat words: [0x8000, 0x8000]
    # EXPECT mm0 = 0x80008000_7FFF7FFF
    # ============================================================
    movq    0x10(%esi), %mm0
    movq    0x18(%esi), %mm1
    packssdw %mm1, %mm0
    movq    %mm0, 0x60(%esi)

    movl    0x60(%esi), %eax        # lower: 0x7FFF7FFF
    movl    0x64(%esi), %ebx        # upper: 0x80008000
    movl    $0x22222222, %edx

    # ============================================================
    # T3: PADDW  (0F FD)
    # mm0 words: [0x0001, 0x7FFF, 0xFFFF, 0x1000]
    # mm1 words: [0x0001, 0x0001, 0x0001, 0x1000]
    # result:    [0x0002, 0x8000, 0x0000, 0x2000]
    # EXPECT mm0 = 0x20000000_80000002
    # ============================================================
    movq    0x20(%esi), %mm0
    movq    0x28(%esi), %mm1
    paddw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)

    movl    0x60(%esi), %eax        # lower: 0x80000002
    movl    0x64(%esi), %ebx        # upper: 0x20000000
    movl    $0x33333333, %edx

    # ============================================================
    # T4: PADDD  (0F FE)
    # mm0 dwords: [0x00001234, 0xFFFFFFFE]
    # mm1 dwords: [0x0000EDCC, 0x00000003]
    # result:     [0x00010000, 0x00000001]
    # EXPECT mm0 = 0x00000001_00010000
    # ============================================================
    movq    0x30(%esi), %mm0
    movq    0x38(%esi), %mm1
    paddd   %mm1, %mm0
    movq    %mm0, 0x60(%esi)

    movl    0x60(%esi), %eax        # lower: 0x00010000
    movl    0x64(%esi), %ebx        # upper: 0x00000001
    movl    $0x44444444, %edx

    # ============================================================
    # T5: PAVGB  (0F E0)
    # mm0 bytes: [0x01,0x04,0xFF,0x00, 0x10,0x20,0x80,0xFE]
    # mm1 bytes: [0x01,0x04,0x01,0x00, 0x10,0x20,0x80,0x02]
    # result:    [0x01,0x04,0x80,0x00, 0x10,0x20,0x80,0x80]
    # EXPECT mm0 = 0x80802010_00800401
    # ============================================================
    movq    0x40(%esi), %mm0
    movq    0x48(%esi), %mm1
    pavgb   %mm1, %mm0
    movq    %mm0, 0x60(%esi)

    movl    0x60(%esi), %eax        # lower: 0x00800401
    movl    0x64(%esi), %ebx        # upper: 0x80802010
    movl    $0x55555555, %edx

    # ============================================================
    # T6: PAVGW  (0F E3)
    # mm0 words: [0x0001, 0xFFFF, 0x0100, 0x8000]
    # mm1 words: [0x0003, 0x0001, 0x0100, 0x8000]
    # result:    [0x0002, 0x8000, 0x0100, 0x8000]
    # EXPECT mm0 = 0x80000100_80000002
    # ============================================================
    movq    0x50(%esi), %mm0
    movq    0x58(%esi), %mm1
    pavgw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)

    movl    0x60(%esi), %eax        # lower: 0x80000002
    movl    0x64(%esi), %ebx        # upper: 0x80000100
    movl    $0x66666666, %edx

    # ============================================================
    # T7: MOVQ mm<->mm and mm<->mem  (0F 6F / 0F 7F)
    # Copy mm0 result from T6 into mm2 via mm reg, then store/reload
    # ============================================================
    movq    %mm0, %mm2              # mm2 = mm0 (reg→reg)
    movq    %mm2, 0x60(%esi)        # store mm2 to mem (0F 7F)
    movq    0x60(%esi), %mm3        # reload into mm3  (0F 6F)
    movq    %mm3, 0x60(%esi)        # store again to verify round-trip

    movl    0x60(%esi), %eax        # should still be 0x80000002
    movl    0x64(%esi), %ebx        # should still be 0x80000100
    movl    $0x77777777, %edx

    # ============================================================
    # T8: MOV — immediate to register (B8+rd)
    # MOV r32, imm32
    # ============================================================
    movl    $0xDEADC0DE, %eax
    movl    $0xCAFEBABE, %ebx
    movl    $0x12345678, %ecx
    movl    $0xABCD1234, %edx
    movl    $0x88888888, %edx       # sentinel overwrite

    # ============================================================
    # T9: MOV — reg/mem variants
    # MOV r/m32, r32  (89 /r)   MOV r32, r/m32  (8B /r)
    # ============================================================
    movl    $0xFACEFACE, %eax
    movl    %eax, 0x70(%esi)        # store: MOV r/m32, r32
    movl    $0x00000000, %eax       # clear
    movl    0x70(%esi), %eax        # reload: MOV r32, r/m32
    movl    %eax, %ecx              # MOV r32, r32 (89/8B r/r form)
    movl    $0x99999999, %edx

    # ============================================================
    # T10: MOV — byte and word forms  (88/8A, 89w/8Bw)
    # ============================================================
    movl    $0x000000AB, %eax
    movb    %al, 0x68(%esi)         # MOV r/m8, r8
    movl    $0x00000000, %eax
    movb    0x68(%esi), %al         # MOV r8, r/m8
                                    # EAX low byte should be 0xAB
    movl    $0x00005C5C, %ebx
    movw    %bx, 0x6C(%esi)         # MOV r/m16, r16
    movl    $0x00000000, %ebx
    movw    0x6C(%esi), %bx         # MOV r16, r/m16
                                    # EBX low word should be 0x5C5C
    movl    $0xAAAAAAAA, %edx

    # ============================================================
    # T11: ADD — all immediate and register forms
    # ADD EAX, imm32  (05 id)
    # ADD r/m32, imm32 (81 /0 id)
    # ADD r/m32, imm8  (83 /0 ib)
    # ADD r/m32, r32   (01 /r)
    # ADD r32, r/m32   (03 /r)
    # ============================================================
    movl    $0x00001000, %eax
    addl    $0x00002000, %eax       # ADD EAX,imm32 → EAX=0x3000
    movl    $0x00000010, %ebx
    addl    $0x00001234, %ebx       # ADD r/m32,imm32 → EBX=0x1244
    addl    $0x01, %ecx             # ADD r/m32,imm8 (sign-ext)
    movl    $0x00000005, %ecx
    movl    $0x00000003, %edx
    addl    %edx, %ecx              # ADD r/m32,r32 → ECX=0x8
    movl    $0x00000100, %esi
    addl    0x70(%esi), %esi        # ADD r32,r/m32  (ESI += mem[0x2070])
    movl    $0x00002000, %esi       # restore ESI
    movl    $0xBBBBBBBB, %edx

    # ============================================================
    # T12: ADC — add with carry
    # ADC r/m32, imm32  (81 /2)
    # ADC r/m32, imm8   (83 /2)
    # ADC r/m32, r32    (11 /r)
    # ADC r32, r/m32    (13 /r)
    # ============================================================
    # First set CF=1 via add of two large numbers
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax       # EAX=0, CF=1
    movl    $0x00000000, %eax
    adcl    $0x00001000, %eax       # ADC EAX,imm32 → EAX=0x1001 (0+0x1000+CF=1)
    movl    $0xFFFFFFFF, %ebx
    addl    $0x00000001, %ebx       # EBX=0, CF=1
    movl    $0x00000000, %ebx
    adcl    $0x01, %ebx             # ADC r/m32,imm8 → EBX=0x2 (0+1+CF=1)
    movl    $0xFFFFFFFF, %ecx
    addl    $0x00000001, %ecx       # ECX=0, CF=1
    movl    $0x00000000, %ecx
    movl    $0x0000ABCD, %edx
    adcl    %edx, %ecx              # ADC r/m32,r32 → ECX=0xABCE (0+0xABCD+CF=1)
    movl    $0x00000000, %edx
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax       # CF=1
    movl    $0x00000000, %eax
    adcl    0x70(%esi), %eax        # ADC r32,r/m32 → EAX=mem+CF
    movl    $0xCCCCCCCC, %edx

    # ============================================================
    # T13: AND — all immediate and register forms
    # AND EAX,imm32  (25 id)
    # AND r/m32,imm32 (81 /4)
    # AND r/m32,imm8  (83 /4)
    # AND r/m32,r32   (21 /r)
    # AND r32,r/m32   (23 /r)
    # ============================================================
    movl    $0xFFFF00FF, %eax
    andl    $0x0F0F0F0F, %eax       # AND EAX,imm32 → EAX=0x0F0F000F
    movl    $0xABCDEF12, %ebx
    andl    $0xFFFF0000, %ebx       # AND r/m32,imm32 → EBX=0xABCD0000
    movl    $0x000000FF, %ecx
    andl    $0x0F, %ecx             # AND r/m32,imm8 → ECX=0x0F
    movl    $0xDEADBEEF, %eax
    movl    $0x0000FFFF, %edx
    andl    %edx, %eax              # AND r/m32,r32 → EAX=0x0000BEEF
    movl    $0xAAAAAAAA, %eax
    andl    0x70(%esi), %eax        # AND r32,r/m32
    movl    $0xDDDDDDDD, %edx

    # ============================================================
    # T14: AAA  (37)
    # ASCII adjust after addition
    # Setup: AL=0x09 + AL=0x09 = 0x12 (AH=0, AL=0x12, AF=1)
    # AAA: nibble >9 so AL=(AL+6)&0x0F=0x08, AH++, CF=AF=1
    # Then: AL=0x08+0x09=0x11, AAA: >9 → AL=0x07, AH++, CF=1
    # ============================================================
    movl    $0x00000000, %eax
    movb    $0x09, %al
    addb    $0x09, %al              # AL=0x12, AF=1
    aaa                             # AL→0x08, AH→0x01, CF=AF=1
    movl    $0xEEEEEEEE, %edx

    hlt

# ================================================================
.org 0x2000
.data

data_page:

    # ── T1 PACKSSWB inputs ─────────────────────────── +0x00
    .long 0x007F0001               # mm0 bits[31:0]:  word1=0x007F, word0=0x0001
    .long 0x80000100               # mm0 bits[63:32]: word3=0x8000, word2=0x0100
    .long 0x007E0000               # mm1 bits[31:0]:  word1=0x007E, word0=0x0000
    .long 0x80017FFF               # mm1 bits[63:32]: word3=0x8001, word2=0x7FFF

    # ── T2 PACKSSDW inputs ─────────────────────────── +0x10
    .long 0x00007FFF               # mm0 dword0
    .long 0x00010000               # mm0 dword1
    .long 0x80000000               # mm1 dword0
    .long 0xFFFF8000               # mm1 dword1

    # ── T3 PADDW inputs ────────────────────────────── +0x20
    .long 0x7FFF0001               # mm0 words [1]=0x7FFF, [0]=0x0001
    .long 0x1000FFFF               # mm0 words [3]=0x1000, [2]=0xFFFF
    .long 0x00010001               # mm1 words [1]=0x0001, [0]=0x0001
    .long 0x10000001               # mm1 words [3]=0x1000, [2]=0x0001

    # ── T4 PADDD inputs ────────────────────────────── +0x30
    .long 0x00001234               # mm0 dword0
    .long 0xFFFFFFFE               # mm0 dword1
    .long 0x0000EDCC               # mm1 dword0
    .long 0x00000003               # mm1 dword1

    # ── T5 PAVGB inputs ────────────────────────────── +0x40
    .long 0x00FF0401               # mm0 bytes [3]=0x00, [2]=0xFF, [1]=0x04, [0]=0x01
    .long 0xFE802010               # mm0 bytes [7]=0xFE, [6]=0x80, [5]=0x20, [4]=0x10
    .long 0x00010401               # mm1 bytes [3]=0x00, [2]=0x01, [1]=0x04, [0]=0x01
    .long 0x02802010               # mm1 bytes [7]=0x02, [6]=0x80, [5]=0x20, [4]=0x10

    # ── T6 PAVGW inputs ────────────────────────────── +0x50
    .long 0xFFFF0001               # mm0 words [1]=0xFFFF, [0]=0x0001
    .long 0x80000100               # mm0 words [3]=0x8000, [2]=0x0100
    .long 0x00010003               # mm1 words [1]=0x0001, [0]=0x0003
    .long 0x80000100               # mm1 words [3]=0x8000, [2]=0x0100

    # ── result scratch ─────────────────────────────── +0x60
    .long 0x00000000
    .long 0x00000000

    # ── byte scratch ───────────────────────────────── +0x68
    .long 0x00000000

    # ── word scratch ───────────────────────────────── +0x6C
    .long 0x00000000

    # ── dword scratch ──────────────────────────────── +0x70
    .long 0xFACEFACE


# ================================================================
# Verification strategy (no CMP/XOR/SUB available):
#   1. Ensure CF=0: movl $1,%ecx; sall $1,%ecx (bit31 of 1 is 0)
#   2. Load 32-bit result chunk into EAX from scratch area (+0x60)
#   3. sbbl $expected, %eax  → if equal: EAX=0, ZF=1, CF=0
#   4. jne  fail_Tn          → DEADBEEF sentinel
#   Repeat for upper dword (CF=0 because lower matched exactly).
#
# Memory layout at data_page (0x2000):
#   +0x00  T1 PACKSSWB  mm0 input (8 bytes)
#   +0x08  T1 PACKSSWB  mm1 input (8 bytes)
#   +0x10  T2 PACKSSDW  mm0 input (8 bytes)
#   +0x18  T2 PACKSSDW  mm1 input (8 bytes)
#   +0x20  T3 PADDW     mm0 input (8 bytes)
#   +0x28  T3 PADDW     mm1 input (8 bytes)
#   +0x30  T4 PADDD     mm0 input (8 bytes)
#   +0x38  T4 PADDD     mm1 input (8 bytes)
#   +0x40  T5 PAVGB     mm0 input (8 bytes)
#   +0x48  T5 PAVGB     mm1 input (8 bytes)
#   +0x50  T6 PAVGW     mm0 input (8 bytes)
#   +0x58  T6 PAVGW     mm1 input (8 bytes)
#   +0x60  result scratch (8 bytes)
# ================================================================

