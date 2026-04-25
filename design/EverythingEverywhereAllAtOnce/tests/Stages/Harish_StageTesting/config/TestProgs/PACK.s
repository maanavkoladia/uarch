.org 0x1000
.code
.global _start

# ================================================================
# PACK.s — Comprehensive MMX SIMD edge-case coverage
#
# Each instruction is tested with multiple subtests loaded inline
# into the scratch area (+0x60/+0x68) immediately before use.
#
# EDX holds a unique hex marker after every subtest so the waveform
# shows exactly which case ran last.
#
# Marker scheme:
#   PACKSSWB  subtests: 0x1A00_000n
#   PACKSSDW  subtests: 0x2B00_000n
#   PADDW     subtests: 0x3C00_000n
#   PADDD     subtests: 0x4D00_000n
#   PAVGB     subtests: 0x5E00_000n
#   PAVGW     subtests: 0x6F00_000n
#   Scalar (MOV/ADD/ADC/AND/AAA): 0xn000_0000 (unchanged from original)
# ================================================================

_start:
    movl    $0x00002000, %esi       # ESI = data_page base

    # ============================================================
    # PACKSSWB  (0F 63)
    # Pack 4 signed words from mm1 and 4 from mm0 into 8 signed
    # bytes using SIGNED saturation: clamp to [−128, +127] / [0x80,0x7F]
    #
    # Result layout (little-endian qword in scratch):
    #   byte[0] = mm0.word[0] sat   byte[4] = mm1.word[0] sat
    #   byte[1] = mm0.word[1] sat   byte[5] = mm1.word[1] sat
    #   byte[2] = mm0.word[2] sat   byte[6] = mm1.word[2] sat
    #   byte[3] = mm0.word[3] sat   byte[7] = mm1.word[3] sat
    # ============================================================

    # ── PACKSSWB sub-T1: all values in-range (no saturation) ───
    # mm0 words: [0x0000, 0x0001, 0x007E, 0x007F]  → bytes 0x00,0x01,0x7E,0x7F
    # mm1 words: [0xFF80, 0xFF81, 0xFFFE, 0xFFFF]  → bytes 0x80,0x81,0xFE,0xFF
    # EXPECT lo=0x7E_01_00 ...  full: 0xFF_FE_81_80 | 0x7F_7E_01_00
    movl    $0x00010000, 0x00(%esi)  # mm0[31:0]  words [0]=0x0000 [1]=0x0001
    movl    $0x007F007E, 0x04(%esi)  # mm0[63:32] words [2]=0x007E [3]=0x007F
    movl    $0xFF81FF80, 0x08(%esi)  # mm1[31:0]  words [0]=0xFF80 [1]=0xFF81
    movl    $0xFFFFFFFE, 0x0C(%esi)  # mm1[63:32] words [2]=0xFFFE [3]=0xFFFF
    movq    0x00(%esi), %mm0
    movq    0x08(%esi), %mm1
    packsswb %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x7F7E0100
    movl    0x64(%esi), %ebx        # expect 0xFFFEFF81   (wait — 0x80→0x80 in signed, 0xFF81→0x81, 0xFFFE→0xFE, 0xFFFF→0xFF)
    movl    $0x1A000001, %edx       # marker PACKSSWB sub-T1

    # ── PACKSSWB sub-T2: positive overflow → clamp to 0x7F ─────
    # mm0 words: [0x0080, 0x00FF, 0x0100, 0x7FFF] → all > 127 → all 0x7F
    # mm1 words: [0x0000, 0x0000, 0x0000, 0x0000] → all 0x00
    # EXPECT lo=0x7F_7F_7F_7F  hi=0x00_00_00_00
    movl    $0x00FF0080, 0x00(%esi)
    movl    $0x7FFF0100, 0x04(%esi)
    movl    $0x00000000, 0x08(%esi)
    movl    $0x00000000, 0x0C(%esi)
    movq    0x00(%esi), %mm0
    movq    0x08(%esi), %mm1
    packsswb %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x7F7F7F7F
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x1A000002, %edx       # marker PACKSSWB sub-T2

    # ── PACKSSWB sub-T3: negative overflow → clamp to 0x80 ─────
    # mm0 words: [0xFF7F, 0xFF00, 0x8001, 0x8000] → all < −128 → all 0x80
    # mm1 words: [0x0000, 0x0000, 0x0000, 0x0000] → all 0x00
    # EXPECT lo=0x80_80_80_80  hi=0x00_00_00_00
    movl    $0xFF00FF7F, 0x00(%esi)
    movl    $0x80008001, 0x04(%esi)
    movl    $0x00000000, 0x08(%esi)
    movl    $0x00000000, 0x0C(%esi)
    movq    0x00(%esi), %mm0
    movq    0x08(%esi), %mm1
    packsswb %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80808080
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x1A000003, %edx       # marker PACKSSWB sub-T3

    # ── PACKSSWB sub-T4: exact boundary values ──────────────────
    # mm0 words: [0x007F, 0xFF80, 0x0000, 0x0000] → 0x7F, 0x80, 0x00, 0x00
    # mm1 words: [0x007F, 0xFF80, 0x0000, 0x0000] → 0x7F, 0x80, 0x00, 0x00
    # EXPECT lo=0x00_00_80_7F  hi=0x00_00_80_7F
    movl    $0xFF80007F, 0x00(%esi)
    movl    $0x00000000, 0x04(%esi)
    movl    $0xFF80007F, 0x08(%esi)
    movl    $0x00000000, 0x0C(%esi)
    movq    0x00(%esi), %mm0
    movq    0x08(%esi), %mm1
    packsswb %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x0000807F
    movl    0x64(%esi), %ebx        # expect 0x0000807F
    movl    $0x1A000004, %edx       # marker PACKSSWB sub-T4

    # ── PACKSSWB sub-T5: mixed mm0 pos-overflow, mm1 neg-overflow
    # mm0 words: [0x0100, 0x7FFF, 0xFF7F, 0x8000] → 0x7F,0x7F,0x80,0x80
    # mm1 words: [0x0080, 0x7FFE, 0xFF81, 0x8001] → 0x7F,0x7F,0x80,0x80
    # EXPECT lo=0x80_80_7F_7F  hi=0x80_80_7F_7F
    movl    $0x7FFF0100, 0x00(%esi)
    movl    $0x80008000, 0x04(%esi)   # 0x8000→clamp 0x80; 0xFF7F→clamp 0x80
    movl    $0x7FFE0080, 0x08(%esi)
    movl    $0x8001FF81, 0x0C(%esi)
    movq    0x00(%esi), %mm0
    movq    0x08(%esi), %mm1
    packsswb %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80807F7F
    movl    0x64(%esi), %ebx        # expect 0x80807F7F
    movl    $0x1A000005, %edx       # marker PACKSSWB sub-T5

    # ============================================================
    # PACKSSDW  (0F 6B)
    # Pack 2 signed dwords from mm1 and 2 from mm0 into 4 signed
    # words using SIGNED saturation: clamp to [−32768, +32767] / [0x8000,0x7FFF]
    #
    # Result layout:
    #   word[0]=mm0.dword[0] sat   word[2]=mm1.dword[0] sat
    #   word[1]=mm0.dword[1] sat   word[3]=mm1.dword[1] sat
    # ============================================================

    # ── PACKSSDW sub-T1: all values in-range (no saturation) ───
    # mm0 dwords: [0x00001234, 0xFFFF8000] → 0x1234, 0x8000 (exact boundaries)
    # mm1 dwords: [0x00007FFF, 0xFFFF0001] → 0x7FFF, 0x0001 (wait — need signed range)
    # Note: 0xFFFF8000 = −32768 (just fits), 0xFFFF0001 = −65535 (overflows → 0x8000)
    # Corrected mm1: [0x00007FFF, 0xFFFF8001] → 0x7FFF, 0x8001? 0xFFFF8001=−32767 → fits
    # EXPECT lo=0x8000_1234  hi=0x8001_7FFF
    movl    $0x00001234, 0x10(%esi)
    movl    $0xFFFF8000, 0x14(%esi)
    movl    $0x00007FFF, 0x18(%esi)
    movl    $0xFFFF8001, 0x1C(%esi)
    movq    0x10(%esi), %mm0
    movq    0x18(%esi), %mm1
    packssdw %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80001234
    movl    0x64(%esi), %ebx        # expect 0x80017FFF
    movl    $0x2B000001, %edx       # marker PACKSSDW sub-T1

    # ── PACKSSDW sub-T2: positive overflow → clamp to 0x7FFF ───
    # mm0 dwords: [0x00008000, 0x00010000] → both > 32767 → 0x7FFF, 0x7FFF
    # mm1 dwords: [0x7FFFFFFF, 0x00100000] → both → 0x7FFF, 0x7FFF
    # EXPECT lo=0x7FFF_7FFF  hi=0x7FFF_7FFF
    movl    $0x00008000, 0x10(%esi)
    movl    $0x00010000, 0x14(%esi)
    movl    $0x7FFFFFFF, 0x18(%esi)
    movl    $0x00100000, 0x1C(%esi)
    movq    0x10(%esi), %mm0
    movq    0x18(%esi), %mm1
    packssdw %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x7FFF7FFF
    movl    0x64(%esi), %ebx        # expect 0x7FFF7FFF
    movl    $0x2B000002, %edx       # marker PACKSSDW sub-T2

    # ── PACKSSDW sub-T3: negative overflow → clamp to 0x8000 ───
    # mm0 dwords: [0xFFFF7FFF, 0x80000000] → both < −32768 → 0x8000, 0x8000
    # mm1 dwords: [0xFFFE0000, 0x80000001] → both → 0x8000, 0x8000
    # EXPECT lo=0x8000_8000  hi=0x8000_8000
    movl    $0xFFFF7FFF, 0x10(%esi)
    movl    $0x80000000, 0x14(%esi)
    movl    $0xFFFE0000, 0x18(%esi)
    movl    $0x80000001, 0x1C(%esi)
    movq    0x10(%esi), %mm0
    movq    0x18(%esi), %mm1
    packssdw %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80008000
    movl    0x64(%esi), %ebx        # expect 0x80008000
    movl    $0x2B000003, %edx       # marker PACKSSDW sub-T3

    # ── PACKSSDW sub-T4: exact boundary dwords ──────────────────
    # mm0 dwords: [0x00007FFF, 0xFFFF8000] → exact max/min, no saturation
    # mm1 dwords: [0x00000000, 0xFFFFFFFF] → 0x0000, 0xFFFF
    # EXPECT lo=0x8000_7FFF  hi=0xFFFF_0000
    movl    $0x00007FFF, 0x10(%esi)
    movl    $0xFFFF8000, 0x14(%esi)
    movl    $0x00000000, 0x18(%esi)
    movl    $0xFFFFFFFF, 0x1C(%esi)
    movq    0x10(%esi), %mm0
    movq    0x18(%esi), %mm1
    packssdw %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80007FFF
    movl    0x64(%esi), %ebx        # expect 0xFFFF0000
    movl    $0x2B000004, %edx       # marker PACKSSDW sub-T4

    # ── PACKSSDW sub-T5: mixed overflow (one pos, one neg per reg)
    # mm0 dwords: [0x7FFFFFFF, 0x80000000] → 0x7FFF, 0x8000
    # mm1 dwords: [0x00010000, 0xFFFF0000] → 0x7FFF, 0x8000
    # EXPECT lo=0x8000_7FFF  hi=0x8000_7FFF
    movl    $0x7FFFFFFF, 0x10(%esi)
    movl    $0x80000000, 0x14(%esi)
    movl    $0x00010000, 0x18(%esi)
    movl    $0xFFFF0000, 0x1C(%esi)
    movq    0x10(%esi), %mm0
    movq    0x18(%esi), %mm1
    packssdw %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80007FFF
    movl    0x64(%esi), %ebx        # expect 0x80007FFF
    movl    $0x2B000005, %edx       # marker PACKSSDW sub-T5

    # ============================================================
    # PADDW  (0F FD)
    # Add 4 packed 16-bit integers; result wraps (no saturation)
    # ============================================================

    # ── PADDW sub-T1: normal add ─────────────────────────────────
    # mm0 words: [0x0001, 0x0010, 0x0100, 0x1000]
    # mm1 words: [0x0001, 0x0010, 0x0100, 0x1000]
    # result:    [0x0002, 0x0020, 0x0200, 0x2000]
    # EXPECT lo=0x00200002  hi=0x20000200
    movl    $0x00100001, 0x20(%esi)
    movl    $0x10000100, 0x24(%esi)
    movl    $0x00100001, 0x28(%esi)
    movl    $0x10000100, 0x2C(%esi)
    movq    0x20(%esi), %mm0
    movq    0x28(%esi), %mm1
    paddw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00200002
    movl    0x64(%esi), %ebx        # expect 0x20000200
    movl    $0x3C000001, %edx       # marker PADDW sub-T1

    # ── PADDW sub-T2: wrap-around (0xFFFF + 1 = 0x0000) ─────────
    # mm0 words: [0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF]
    # mm1 words: [0x0001, 0x0001, 0x0001, 0x0001]
    # result:    [0x0000, 0x0000, 0x0000, 0x0000]
    # EXPECT lo=0x00000000  hi=0x00000000
    movl    $0xFFFFFFFF, 0x20(%esi)
    movl    $0xFFFFFFFF, 0x24(%esi)
    movl    $0x00010001, 0x28(%esi)
    movl    $0x00010001, 0x2C(%esi)
    movq    0x20(%esi), %mm0
    movq    0x28(%esi), %mm1
    paddw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00000000
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x3C000002, %edx       # marker PADDW sub-T2

    # ── PADDW sub-T3: signed wrap (0x7FFF + 1 = 0x8000) ─────────
    # mm0 words: [0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF]
    # mm1 words: [0x0001, 0x0001, 0x0001, 0x0001]
    # result:    [0x8000, 0x8000, 0x8000, 0x8000]
    # EXPECT lo=0x80008000  hi=0x80008000
    movl    $0x7FFF7FFF, 0x20(%esi)
    movl    $0x7FFF7FFF, 0x24(%esi)
    movl    $0x00010001, 0x28(%esi)
    movl    $0x00010001, 0x2C(%esi)
    movq    0x20(%esi), %mm0
    movq    0x28(%esi), %mm1
    paddw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80008000
    movl    0x64(%esi), %ebx        # expect 0x80008000
    movl    $0x3C000003, %edx       # marker PADDW sub-T3

    # ── PADDW sub-T4: add zero (identity) ────────────────────────
    # mm0 words: [0xDEAD, 0xBEEF, 0xCAFE, 0xBABE]
    # mm1 words: [0x0000, 0x0000, 0x0000, 0x0000]
    # result unchanged
    # EXPECT lo=0xBEEFDEAD  hi=0xBABECAFE
    movl    $0xBEEFDEAD, 0x20(%esi)
    movl    $0xBABECAFE, 0x24(%esi)
    movl    $0x00000000, 0x28(%esi)
    movl    $0x00000000, 0x2C(%esi)
    movq    0x20(%esi), %mm0
    movq    0x28(%esi), %mm1
    paddw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0xBEEFDEAD
    movl    0x64(%esi), %ebx        # expect 0xBABECAFE
    movl    $0x3C000004, %edx       # marker PADDW sub-T4

    # ── PADDW sub-T5: 0x8000 + 0x8000 = 0x0000 (neg wrap) ───────
    # mm0 words: [0x8000, 0x8000, 0x8000, 0x8000]
    # mm1 words: [0x8000, 0x8000, 0x8000, 0x8000]
    # result:    [0x0000, 0x0000, 0x0000, 0x0000]
    # EXPECT lo=0x00000000  hi=0x00000000
    movl    $0x80008000, 0x20(%esi)
    movl    $0x80008000, 0x24(%esi)
    movl    $0x80008000, 0x28(%esi)
    movl    $0x80008000, 0x2C(%esi)
    movq    0x20(%esi), %mm0
    movq    0x28(%esi), %mm1
    paddw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00000000
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x3C000005, %edx       # marker PADDW sub-T5

    # ============================================================
    # PADDD  (0F FE)
    # Add 2 packed 32-bit integers; result wraps (no saturation)
    # ============================================================

    # ── PADDD sub-T1: normal add ──────────────────────────────────
    # mm0 dwords: [0x00001234, 0x00ABCDEF]
    # mm1 dwords: [0x0000EDCC, 0xFF543211]
    # result:     [0x00010000, 0x00000000]
    # EXPECT lo=0x00010000  hi=0x00000000
    movl    $0x00001234, 0x30(%esi)
    movl    $0x00ABCDEF, 0x34(%esi)
    movl    $0x0000EDCC, 0x38(%esi)
    movl    $0xFF543211, 0x3C(%esi)
    movq    0x30(%esi), %mm0
    movq    0x38(%esi), %mm1
    paddd   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00010000
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x4D000001, %edx       # marker PADDD sub-T1

    # ── PADDD sub-T2: wrap-around (0xFFFFFFFF + 1 = 0) ───────────
    # mm0 dwords: [0xFFFFFFFF, 0xFFFFFFFF]
    # mm1 dwords: [0x00000001, 0x00000001]
    # result:     [0x00000000, 0x00000000]
    # EXPECT lo=0x00000000  hi=0x00000000
    movl    $0xFFFFFFFF, 0x30(%esi)
    movl    $0xFFFFFFFF, 0x34(%esi)
    movl    $0x00000001, 0x38(%esi)
    movl    $0x00000001, 0x3C(%esi)
    movq    0x30(%esi), %mm0
    movq    0x38(%esi), %mm1
    paddd   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00000000
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x4D000002, %edx       # marker PADDD sub-T2

    # ── PADDD sub-T3: signed wrap (0x7FFFFFFF + 1 = 0x80000000) ─
    # mm0 dwords: [0x7FFFFFFF, 0x7FFFFFFF]
    # mm1 dwords: [0x00000001, 0x00000001]
    # result:     [0x80000000, 0x80000000]
    # EXPECT lo=0x80000000  hi=0x80000000
    movl    $0x7FFFFFFF, 0x30(%esi)
    movl    $0x7FFFFFFF, 0x34(%esi)
    movl    $0x00000001, 0x38(%esi)
    movl    $0x00000001, 0x3C(%esi)
    movq    0x30(%esi), %mm0
    movq    0x38(%esi), %mm1
    paddd   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80000000
    movl    0x64(%esi), %ebx        # expect 0x80000000
    movl    $0x4D000003, %edx       # marker PADDD sub-T3

    # ── PADDD sub-T4: add zero (identity) ────────────────────────
    # mm0 dwords: [0xDEADBEEF, 0xCAFEBABE]
    # mm1 dwords: [0x00000000, 0x00000000]
    # EXPECT lo=0xDEADBEEF  hi=0xCAFEBABE
    movl    $0xDEADBEEF, 0x30(%esi)
    movl    $0xCAFEBABE, 0x34(%esi)
    movl    $0x00000000, 0x38(%esi)
    movl    $0x00000000, 0x3C(%esi)
    movq    0x30(%esi), %mm0
    movq    0x38(%esi), %mm1
    paddd   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0xDEADBEEF
    movl    0x64(%esi), %ebx        # expect 0xCAFEBABE
    movl    $0x4D000004, %edx       # marker PADDD sub-T4

    # ── PADDD sub-T5: 0x80000000 + 0x80000000 = 0x00000000 ───────
    # mm0 dwords: [0x80000000, 0x80000000]
    # mm1 dwords: [0x80000000, 0x80000000]
    # result:     [0x00000000, 0x00000000]
    # EXPECT lo=0x00000000  hi=0x00000000
    movl    $0x80000000, 0x30(%esi)
    movl    $0x80000000, 0x34(%esi)
    movl    $0x80000000, 0x38(%esi)
    movl    $0x80000000, 0x3C(%esi)
    movq    0x30(%esi), %mm0
    movq    0x38(%esi), %mm1
    paddd   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00000000
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x4D000005, %edx       # marker PADDD sub-T5

    # ============================================================
    # PAVGB  (0F E0)
    # Average 8 packed unsigned bytes: result = (a + b + 1) >> 1
    # Rounds UP on .5 (i.e., odd+odd → round up)
    # ============================================================

    # ── PAVGB sub-T1: basic average, exact (even sum) ────────────
    # mm0 bytes: [0x00, 0x02, 0x04, 0x10,  0x20, 0x40, 0x80, 0xFE]
    # mm1 bytes: [0x00, 0x02, 0x04, 0x10,  0x20, 0x40, 0x80, 0xFE]
    # result:    [0x00, 0x02, 0x04, 0x10,  0x20, 0x40, 0x80, 0xFE]
    # EXPECT lo=0x10040200  hi=0xFE804020
    movl    $0x10040200, 0x40(%esi)
    movl    $0xFE804020, 0x44(%esi)
    movl    $0x10040200, 0x48(%esi)
    movl    $0xFE804020, 0x4C(%esi)
    movq    0x40(%esi), %mm0
    movq    0x48(%esi), %mm1
    pavgb   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x10040200
    movl    0x64(%esi), %ebx        # expect 0xFE804020
    movl    $0x5E000001, %edx       # marker PAVGB sub-T1

    # ── PAVGB sub-T2: round-up at 0.5 (odd+odd sums) ─────────────
    # PAVGB rounds: (a+b+1)>>1, so odd+odd → sum is even+1 → round up
    # mm0 bytes: [0x01, 0x03, 0xFF, 0x01,  0x01, 0x01, 0x01, 0x01]
    # mm1 bytes: [0x00, 0x00, 0x00, 0xFE,  0x02, 0x04, 0xFE, 0xFF]
    # avgs:      ceil((1+0+1)/2)=1, ceil((3+0+1)/2)=2,
    #            ceil((255+0+1)/2)=128, ceil((1+254+1)/2)=128,
    #            ceil((1+2+1)/2)=2,  ceil((1+4+1)/2)=3,
    #            ceil((1+254+1)/2)=128, ceil((1+255+1)/2)=129
    # EXPECT lo=0x80_02_02_01  hi=0x81_80_03_02
    movl    $0x01FF0301, 0x40(%esi)
    movl    $0x01010101, 0x44(%esi)
    movl    $0xFE0000FF, 0x48(%esi)  # note: byte order [3]=0xFE,[2]=0x00,[1]=0x00,[0]=0xFF? No—little endian
    # Rewrite carefully in little-endian byte order:
    # mm0 lo dword bytes: [0]=0x01,[1]=0x03,[2]=0xFF,[3]=0x01 → 0x01_FF_03_01
    # mm0 hi dword bytes: [4]=0x01,[5]=0x01,[6]=0x01,[7]=0x01 → 0x01_01_01_01
    # mm1 lo dword bytes: [0]=0x00,[1]=0x00,[2]=0x00,[3]=0xFE → 0xFE_00_00_00
    # mm1 hi dword bytes: [4]=0x02,[5]=0x04,[6]=0xFE,[7]=0xFF → 0xFF_FE_04_02
    movl    $0x01FF0301, 0x40(%esi)
    movl    $0x01010101, 0x44(%esi)
    movl    $0xFE000000, 0x48(%esi)
    movl    $0xFFFE0402, 0x4C(%esi)
    movq    0x40(%esi), %mm0
    movq    0x48(%esi), %mm1
    pavgb   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80800201
    movl    0x64(%esi), %ebx        # expect 0x81800302
    movl    $0x5E000002, %edx       # marker PAVGB sub-T2

    # ── PAVGB sub-T3: all 0xFF avg 0xFF ──────────────────────────
    # avg(0xFF,0xFF) = (255+255+1)/2 = 255  (no overflow in unsigned 9-bit)
    # EXPECT lo=0xFFFFFFFF  hi=0xFFFFFFFF
    movl    $0xFFFFFFFF, 0x40(%esi)
    movl    $0xFFFFFFFF, 0x44(%esi)
    movl    $0xFFFFFFFF, 0x48(%esi)
    movl    $0xFFFFFFFF, 0x4C(%esi)
    movq    0x40(%esi), %mm0
    movq    0x48(%esi), %mm1
    pavgb   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0xFFFFFFFF
    movl    0x64(%esi), %ebx        # expect 0xFFFFFFFF
    movl    $0x5E000003, %edx       # marker PAVGB sub-T3

    # ── PAVGB sub-T4: avg(0x00, 0x00) = 0x00 ────────────────────
    # EXPECT lo=0x00000000  hi=0x00000000
    movl    $0x00000000, 0x40(%esi)
    movl    $0x00000000, 0x44(%esi)
    movl    $0x00000000, 0x48(%esi)
    movl    $0x00000000, 0x4C(%esi)
    movq    0x40(%esi), %mm0
    movq    0x48(%esi), %mm1
    pavgb   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00000000
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x5E000004, %edx       # marker PAVGB sub-T4

    # ── PAVGB sub-T5: avg(0xFE, 0x01) = ceil(255/2)=128=0x80 ────
    # and avg(0x01,0x00)=1  avg(0xFF,0x01)=ceil(257/2)=0x81
    # mm0 bytes: all 0xFE  mm1 bytes: all 0x01
    # avg: all ceil((0xFE+0x01+1)/2) = ceil(256/2) = 128 = 0x80
    # EXPECT lo=0x80808080  hi=0x80808080
    movl    $0xFEFEFEFE, 0x40(%esi)
    movl    $0xFEFEFEFE, 0x44(%esi)
    movl    $0x01010101, 0x48(%esi)
    movl    $0x01010101, 0x4C(%esi)
    movq    0x40(%esi), %mm0
    movq    0x48(%esi), %mm1
    pavgb   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80808080
    movl    0x64(%esi), %ebx        # expect 0x80808080
    movl    $0x5E000005, %edx       # marker PAVGB sub-T5

    # ============================================================
    # PAVGW  (0F E3)
    # Average 4 packed unsigned words: result = (a + b + 1) >> 1
    # Rounds UP on .5
    # ============================================================

    # ── PAVGW sub-T1: basic average, exact (even sum) ─────────────
    # mm0 words: [0x0000, 0x0100, 0x8000, 0xFFFE]
    # mm1 words: [0x0000, 0x0100, 0x8000, 0xFFFE]
    # result:    [0x0000, 0x0100, 0x8000, 0xFFFE]
    # EXPECT lo=0x01000000  hi=0xFFFE8000
    movl    $0x01000000, 0x50(%esi)
    movl    $0xFFFE8000, 0x54(%esi)
    movl    $0x01000000, 0x58(%esi)
    movl    $0xFFFE8000, 0x5C(%esi)
    movq    0x50(%esi), %mm0
    movq    0x58(%esi), %mm1
    pavgw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x01000000
    movl    0x64(%esi), %ebx        # expect 0xFFFE8000
    movl    $0x6F000001, %edx       # marker PAVGW sub-T1

    # ── PAVGW sub-T2: round-up at 0.5 (odd+odd sums) ─────────────
    # avg(0x0001, 0x0000) = ceil(2/2)=1,  avg(0x0003, 0x0000)=2
    # avg(0xFFFF, 0x0000) = ceil(0x10000/2)=0x8000
    # avg(0x0001, 0xFFFE) = ceil(0x10000/2)=0x8000
    # EXPECT lo=0x00020001  hi=0x80008000
    movl    $0x00030001, 0x50(%esi)
    movl    $0x0001FFFF, 0x54(%esi)
    movl    $0x00000000, 0x58(%esi)
    movl    $0xFFFE0000, 0x5C(%esi)
    movq    0x50(%esi), %mm0
    movq    0x58(%esi), %mm1
    pavgw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00020001
    movl    0x64(%esi), %ebx        # expect 0x80008000
    movl    $0x6F000002, %edx       # marker PAVGW sub-T2

    # ── PAVGW sub-T3: all 0xFFFF avg 0xFFFF ──────────────────────
    # avg(0xFFFF,0xFFFF) = (65535+65535+1)/2 = 65535 = 0xFFFF
    # EXPECT lo=0xFFFFFFFF  hi=0xFFFFFFFF
    movl    $0xFFFFFFFF, 0x50(%esi)
    movl    $0xFFFFFFFF, 0x54(%esi)
    movl    $0xFFFFFFFF, 0x58(%esi)
    movl    $0xFFFFFFFF, 0x5C(%esi)
    movq    0x50(%esi), %mm0
    movq    0x58(%esi), %mm1
    pavgw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0xFFFFFFFF
    movl    0x64(%esi), %ebx        # expect 0xFFFFFFFF
    movl    $0x6F000003, %edx       # marker PAVGW sub-T3

    # ── PAVGW sub-T4: avg(0x0000, 0x0000) = 0 ────────────────────
    # EXPECT lo=0x00000000  hi=0x00000000
    movl    $0x00000000, 0x50(%esi)
    movl    $0x00000000, 0x54(%esi)
    movl    $0x00000000, 0x58(%esi)
    movl    $0x00000000, 0x5C(%esi)
    movq    0x50(%esi), %mm0
    movq    0x58(%esi), %mm1
    pavgw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x00000000
    movl    0x64(%esi), %ebx        # expect 0x00000000
    movl    $0x6F000004, %edx       # marker PAVGW sub-T4

    # ── PAVGW sub-T5: avg(0xFFFE, 0x0001) = ceil(0xFFFF/2)=0x8000
    # (0xFFFE+0x0001+1)/2 = 0x10000/2 = 0x8000 — all four words
    # EXPECT lo=0x80008000  hi=0x80008000
    movl    $0xFFFEFFFE, 0x50(%esi)
    movl    $0xFFFEFFFE, 0x54(%esi)
    movl    $0x00010001, 0x58(%esi)
    movl    $0x00010001, 0x5C(%esi)
    movq    0x50(%esi), %mm0
    movq    0x58(%esi), %mm1
    pavgw   %mm1, %mm0
    movq    %mm0, 0x60(%esi)
    movl    0x60(%esi), %eax        # expect 0x80008000
    movl    0x64(%esi), %ebx        # expect 0x80008000
    movl    $0x6F000005, %edx       # marker PAVGW sub-T5

    # ============================================================
    # Scalar MOV / ADD / ADC / AND / AAA tests (unchanged from original)
    # ============================================================

    # ── T-MOV1: MOV r32, imm32  (B8+rd) ────────────────────────
    movl    $0xDEADC0DE, %eax
    movl    $0xCAFEBABE, %ebx
    movl    $0x12345678, %ecx
    movl    $0x88888888, %edx       # sentinel marker

    # ── T-MOV2: MOV r/m32<->r32 store+reload ────────────────────
    movl    $0xFACEFACE, %eax
    movl    %eax, 0x70(%esi)        # MOV r/m32, r32
    movl    $0x00000000, %eax
    movl    0x70(%esi), %eax        # MOV r32, r/m32
    movl    %eax, %ecx
    movl    $0x99999999, %edx

    # ── T-MOV3: MOV byte and word forms ─────────────────────────
    movl    $0x000000AB, %eax
    movb    %al, 0x68(%esi)         # MOV r/m8, r8
    movl    $0x00000000, %eax
    movb    0x68(%esi), %al         # MOV r8, r/m8
    movl    $0x00005C5C, %ebx
    movw    %bx, 0x6C(%esi)         # MOV r/m16, r16
    movl    $0x00000000, %ebx
    movw    0x6C(%esi), %bx         # MOV r16, r/m16
    movl    $0xAAAAAAAA, %edx

    # ── T-ADD: ADD all forms ─────────────────────────────────────
    movl    $0x00001000, %eax
    addl    $0x00002000, %eax       # ADD EAX,imm32 → 0x3000
    movl    $0x00000010, %ebx
    addl    $0x00001234, %ebx       # ADD r/m32,imm32 → 0x1244
    movl    $0x00000005, %ecx
    movl    $0x00000003, %edx
    addl    %edx, %ecx              # ADD r/m32,r32 → 0x8
    movl    $0xBBBBBBBB, %edx

    # ── T-ADC: ADC all forms ─────────────────────────────────────
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax       # CF=1
    movl    $0x00000000, %eax
    adcl    $0x00001000, %ebx       # ADC r/m32,imm32
    movl    $0xFFFFFFFF, %ebx
    addl    $0x00000001, %ebx       # CF=1
    movl    $0x00000000, %ebx
    adcl    $0x01, %ebx             # ADC r/m32,imm8
    movl    $0xFFFFFFFF, %ecx
    addl    $0x00000001, %ecx       # CF=1
    movl    $0x00000000, %ecx
    movl    $0x0000ABCD, %edx
    adcl    %edx, %ecx              # ADC r/m32,r32
    movl    $0xCCCCCCCC, %edx

    # ── T-AND: AND all forms ─────────────────────────────────────
    movl    $0xFFFF00FF, %eax
    andl    $0x0F0F0F0F, %eax       # → 0x0F0F000F
    movl    $0xABCDEF12, %ebx
    andl    $0xFFFF0000, %ebx       # → 0xABCD0000
    movl    $0x000000FF, %ecx
    andl    $0x0F, %ecx             # → 0x0F
    movl    $0xDEADBEEF, %eax
    movl    $0x0000FFFF, %edx
    andl    %edx, %eax              # → 0x0000BEEF
    movl    $0xDDDDDDDD, %edx

    # ── T-AAA: ASCII adjust ───────────────────────────────────────
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
    # +0x00 – +0x5F : 96 bytes used as inline input staging area
    #   (written by movl instructions in _start before each subtest)
    .fill 96, 1, 0x00

    # ── result scratch ─────────────────────────────── +0x60
    .long 0x00000000
    .long 0x00000000

    # ── byte scratch ───────────────────────────────── +0x68
    .long 0x00000000

    # ── word scratch ───────────────────────────────── +0x6C
    .long 0x00000000

    # ── dword scratch ──────────────────────────────── +0x70
    .long 0xFACEFACE

