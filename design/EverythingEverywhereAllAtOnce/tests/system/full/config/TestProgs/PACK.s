.org 0x1000
.code
.global _start

# ================================================================
# Verification strategy (no CMP/XOR/SUB available):
#   1. Ensure CF=0: movl $1,%ecx# sall $1,%ecx (bit31 of 1 is 0)
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

_start:
    movl $data_page, %esi      # ESI = base of writable data page (0x2000)
    movl $data_dest, %edi
    movsb    # byte  (m8 → m8)
    movl (%edi), %eax

    addl $0x1, %edi
    addl $0x1, %esi
    movsw    # word  (m16 → m16)
    mov (%edi), %ebx
    addl $0xd, %edi
    addl $0xd, %esi  
    movsl    # doubleword (m32 → m32)
    movl (%edi), %ecx

    # ============================================================
    # T1: PACKSSWB  (0F 63)
    # Pack 4 signed words from dst + 4 signed words from src
    # into 8 signed bytes in dst, using signed saturation [-128,127]
    # ============================================================
    #
    # mm0 (dst) words:  [ 0x0001,  0x007F,  0x0100,  0x8000 ]
    #   sat → bytes:    [   0x01,    0x7F,    0x7F,    0x80  ]  (bytes 0-3)
    # mm1 (src) words:  [ 0x0000,  0x007E,  0x7FFF,  0x8001 ]
    #   sat → bytes:    [   0x00,    0x7E,    0x7F,    0x80  ]  (bytes 4-7)
    # EXPECT mm0 = 0x807F7E00_807F7F01
    #        lower=0x807F7F01  upper=0x807F7E00

#     movq    (%esi),    %mm0        # load mm0 (dst): words [1, 0x7F, 0x100, 0x8000]
#     movq    8(%esi),   %mm1        # load mm1 (src): words [0, 0x7E, 0x7FFF, 0x8001]
#     packsswb %mm1, %mm0            # dst bytes 0-3 from mm0 words, 4-7 from mm1P words
#     movq    %mm0, 0x60(%esi)       # store result

#     movl    $0x00000001, %ecx
#     sall    $1, %ecx               # CF=0 (bit31 of 1 is 0)
#     movl    0x60(%esi), %eax
#     sbbl    $0x807F7F01, %eax      # lower dword: expect 0x807F7F01
#     jne     T1_fail
#     movl    0x64(%esi), %eax       # CF=0 carried forward (exact match above)
#     sbbl    $0x807F7E00, %eax      # upper dword: expect 0x807F7E00
#     jne     T1_fail
#     movl    $0x11111111, %edx      # PASS
#     jmp     T1_end
# T1_fail:
#     movl    $0xDEADBEEF, %edx      # FAIL
# T1_end:
#     # EXPECT: EDX = 0x11111111

#     # ============================================================
#     # T2: PACKSSDW  (0F 6B)
#     # Pack 2 signed dwords from dst + 2 signed dwords from src
#     # into 4 signed words in dst, using signed saturation [-32768,32767]
#     # ============================================================
#     #
#     # mm0 (dst) dwords: [ 0x00007FFF,  0x00010000 ]
#     #   sat → words:    [    0x7FFF,      0x7FFF  ]  (words 0-1# +65536 saturates to 32767)
#     # mm1 (src) dwords: [ 0x80000000,  0xFFFF8000 ]
#     #   sat → words:    [    0x8000,      0x8000  ]  (words 2-3# -32768 exactly at min)
#     # EXPECT mm0 = 0x80008000_7FFF7FFF
#     #        lower=0x7FFF7FFF  upper=0x80008000

#     movq    0x10(%esi), %mm0
#     movq    0x18(%esi), %mm1
#     packssdw %mm1, %mm0
#     movq    %mm0, 0x60(%esi)

#     movl    $0x00000001, %ecx
#     sall    $1, %ecx               # CF=0
#     movl    0x60(%esi), %eax
#     sbbl    $0x7FFF7FFF, %eax      # lower: expect 0x7FFF7FFF
#     jne     T2_fail
#     movl    0x64(%esi), %eax
#     sbbl    $0x80008000, %eax      # upper: expect 0x80008000
#     jne     T2_fail
#     movl    $0x22222222, %edx      # PASS
#     jmp     T2_end
# T2_fail:
#     movl    $0xDEADBEEF, %edx
# T2_end:
#     # EXPECT: EDX = 0x22222222

#     # ============================================================
#     # T3: PADDW  (0F FD)
#     # Add 4 packed unsigned words, modular (no saturation)
#     # ============================================================
#     #
#     # mm0 words: [ 0x0001, 0x7FFF, 0xFFFF, 0x1000 ]
#     # mm1 words: [ 0x0001, 0x0001, 0x0001, 0x1000 ]
#     # result:    [ 0x0002, 0x8000, 0x0000, 0x2000 ]  (0xFFFF+1 wraps to 0)
#     # EXPECT mm0 = 0x20000000_80000002
#     #        lower=0x80000002  upper=0x20000000

#     movq    0x20(%esi), %mm0
#     movq    0x28(%esi), %mm1
#     paddw   %mm1, %mm0
#     movq    %mm0, 0x60(%esi)

#     movl    $0x00000001, %ecx
#     sall    $1, %ecx               # CF=0
#     movl    0x60(%esi), %eax
#     sbbl    $0x80000002, %eax      # lower: expect 0x80000002
#     jne     T3_fail
#     movl    0x64(%esi), %eax
#     sbbl    $0x20000000, %eax      # upper: expect 0x20000000
#     jne     T3_fail
#     movl    $0x33333333, %edx      # PASS
#     jmp     T3_end
# T3_fail:
#     movl    $0xDEADBEEF, %edx
# T3_end:
#     # EXPECT: EDX = 0x33333333

#     # ============================================================
#     # T4: PADDD  (0F FE)
#     # Add 2 packed unsigned dwords, modular (no saturation)
#     # ============================================================
#     #
#     # mm0 dwords: [ 0x00001234, 0xFFFFFFFE ]
#     # mm1 dwords: [ 0x0000EDCC, 0x00000003 ]
#     # result:     [ 0x00010000, 0x00000001 ]  (0xFFFFFFFE+3 wraps)
#     # EXPECT mm0 = 0x00000001_00010000
#     #        lower=0x00010000  upper=0x00000001

#     movq    0x30(%esi), %mm0
#     movq    0x38(%esi), %mm1
#     paddd   %mm1, %mm0
#     movq    %mm0, 0x60(%esi)

#     movl    $0x00000001, %ecx
#     sall    $1, %ecx               # CF=0
#     movl    0x60(%esi), %eax
#     sbbl    $0x00010000, %eax      # lower: expect 0x00010000
#     jne     T4_fail
#     movl    0x64(%esi), %eax
#     sbbl    $0x00000001, %eax      # upper: expect 0x00000001
#     jne     T4_fail
#     movl    $0x44444444, %edx      # PASS
#     jmp     T4_end
# T4_fail:
#     movl    $0xDEADBEEF, %edx
# T4_end:
#     # EXPECT: EDX = 0x44444444

#     # ============================================================
#     # T5: PAVGB  (0F E0)
#     # Average 8 packed unsigned bytes with rounding: (a+b+1)>>1
#     # ============================================================
#     #
#     # mm0 bytes: [ 0x01, 0x04, 0xFF, 0x00, 0x10, 0x20, 0x80, 0xFE ]
#     # mm1 bytes: [ 0x01, 0x04, 0x01, 0x00, 0x10, 0x20, 0x80, 0x02 ]
#     # result:    [ 0x01, 0x04, 0x80, 0x00, 0x10, 0x20, 0x80, 0x80 ]
#     #   byte2: (0xFF+0x01+1)>>1=128  byte7: (0xFE+0x02+1)>>1=128
#     # EXPECT mm0 = 0x80802010_00800401
#     #        lower=0x00800401  upper=0x80802010

#     movq    0x40(%esi), %mm0
#     movq    0x48(%esi), %mm1
#     pavgb   %mm1, %mm0
#     movq    %mm0, 0x60(%esi)

#     movl    $0x00000001, %ecx
#     sall    $1, %ecx               # CF=0
#     movl    0x60(%esi), %eax
#     sbbl    $0x00800401, %eax      # lower: expect 0x00800401
#     jne     T5_fail
#     movl    0x64(%esi), %eax
#     sbbl    $0x80802010, %eax      # upper: expect 0x80802010
#     jne     T5_fail
#     movl    $0x55555555, %edx      # PASS
#     jmp     T5_end
# T5_fail:
#     movl    $0xDEADBEEF, %edx
# T5_end:
#     # EXPECT: EDX = 0x55555555

#     # ============================================================
#     # T6: PAVGW  (0F E3)
#     # Average 4 packed unsigned words with rounding: (a+b+1)>>1
#     # ============================================================
#     #
#     # mm0 words: [ 0x0001, 0xFFFF, 0x0100, 0x8000 ]
#     # mm1 words: [ 0x0003, 0x0001, 0x0100, 0x8000 ]
#     # result:    [ 0x0002, 0x8000, 0x0100, 0x8000 ]
#     #   word1: (0xFFFF+0x0001+1)>>1=32768  word3: (0x8000+0x8000+1)>>1=32768
#     # EXPECT mm0 = 0x80000100_80000002
#     #        lower=0x80000002  upper=0x80000100

#     movq    0x50(%esi), %mm0
#     movq    0x58(%esi), %mm1
#     pavgw   %mm1, %mm0
#     movq    %mm0, 0x60(%esi)

#     movl    $0x00000001, %ecx
#     sall    $1, %ecx               # CF=0
#     movl    0x60(%esi), %eax
#     sbbl    $0x80000002, %eax      # lower: expect 0x80000002
#     jne     T6_fail
#     movl    0x64(%esi), %eax
#     sbbl    $0x80000100, %eax      # upper: expect 0x80000100
#     jne     T6_fail
#     movl    $0x66666666, %edx      # PASS
#     jmp     T6_end
# T6_fail:
#     movl    $0xDEADBEEF, %edx
# T6_end:
#     # EXPECT: EDX = 0x66666666

    hlt

# ================================================================
.org 0x2000
.data

data_page:

    # ── T1 PACKSSWB inputs ─────────────────────────── +0x00
    # mm0: words [0x0001, 0x007F, 0x0100, 0x8000]
    .long 0x007F0001               # bits 0-31:  word1<<16 | word0
    .long 0x80000100               # bits 32-63: word3<<16 | word2
    # mm1: words [0x0000, 0x007E, 0x7FFF, 0x8001]
    .long 0x007E0000
    .long 0x80017FFF

    # ── T2 PACKSSDW inputs ─────────────────────────── +0x10
    # mm0: dwords [0x00007FFF, 0x00010000]
    .long 0x00007FFF
    .long 0x00010000
    # mm1: dwords [0x80000000, 0xFFFF8000]
    .long 0x80000000
    .long 0xFFFF8000

    # ── T3 PADDW inputs ────────────────────────────── +0x20
    # mm0: words [0x0001, 0x7FFF, 0xFFFF, 0x1000]
    .long 0x7FFF0001
    .long 0x1000FFFF
    # mm1: words [0x0001, 0x0001, 0x0001, 0x1000]
    .long 0x00010001
    .long 0x10000001

    # ── T4 PADDD inputs ────────────────────────────── +0x30
    # mm0: dwords [0x00001234, 0xFFFFFFFE]
    .long 0x00001234
    .long 0xFFFFFFFE
    # mm1: dwords [0x0000EDCC, 0x00000003]
    .long 0x0000EDCC
    .long 0x00000003

    # ── T5 PAVGB inputs ────────────────────────────── +0x40
    # mm0: bytes [0x01, 0x04, 0xFF, 0x00, 0x10, 0x20, 0x80, 0xFE]
    .long 0x00FF0401               # bytes 0-3
    .long 0xFE802010               # bytes 4-7
    # mm1: bytes [0x01, 0x04, 0x01, 0x00, 0x10, 0x20, 0x80, 0x02]
    .long 0x00010401
    .long 0x02802010

    # ── T6 PAVGW inputs ────────────────────────────── +0x50
    # mm0: words [0x0001, 0xFFFF, 0x0100, 0x8000]
    .long 0xFFFF0001
    .long 0x80000100
    # mm1: words [0x0003, 0x0001, 0x0100, 0x8000]
    .long 0x00010003
    .long 0x80000100

    # ── result scratch ─────────────────────────────── +0x60
    .long 0x00000000
    .long 0x00000000


.org 0x4000
.data

data_dest:
    .long 0xFFFFFFFF
    .long 0xFFFFFFFF

    .long 0xFFFFFFFF

    .long 0xFFFFFFFF

    .long 0xFFFFFFFF

    .long 0xFFFFFFFF

    .long 0xFFFFFFFF

    .long 0xFFFFFFFF

    .long 0xFFFFFFFF

