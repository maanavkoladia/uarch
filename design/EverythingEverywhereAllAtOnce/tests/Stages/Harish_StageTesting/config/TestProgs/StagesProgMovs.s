.org 0x1000
    .code

    .global _start
_start:
    movl $0, %eax
    movl $0, %ebx
    movl $0, %ecx
    movl $0, %edx
    movl $0, %esi
    movl $0, %edi
    movl $0, %ebp

    # ================================================================
    # MOVSB TESTS  (opcode A4)
    # Move byte DS:[ESI] -> ES:[EDI]; ESI and EDI updated by ±1
    # EBX holds the pre-MOVS destination address for read-back.
    # EDX holds a unique marker so the waveform shows which test ran.
    # ================================================================

    # T1: forward (DF=0), normal byte 0x42
    cld
    movl $src_byte_norm, %esi
    movl $0x3000, %edi
    movl %edi, %ebx
    movsb
    movb (%ebx), %al
    movl $0xB0B0B0B0, %edx          # marker T1

    # T2: forward, zero byte 0x00 (zero edge case)
    movl $src_byte_00, %esi
    movl $0x3001, %edi
    movl %edi, %ebx
    movsb
    movb (%ebx), %al
    movl $0xB1B1B1B1, %edx          # marker T2

    # T3: forward, all-ones 0xFF
    movl $src_byte_ff, %esi
    movl $0x3002, %edi
    movl %edi, %ebx
    movsb
    movb (%ebx), %al
    movl $0xB2B2B2B2, %edx          # marker T3

    # T4: forward, signed-max 0x7F
    movl $src_byte_7f, %esi
    movl $0x3003, %edi
    movl %edi, %ebx
    movsb
    movb (%ebx), %al
    movl $0xB3B3B3B3, %edx          # marker T4

    # T5: forward, sign-boundary 0x80
    movl $src_byte_80, %esi
    movl $0x3004, %edi
    movl %edi, %ebx
    movsb
    movb (%ebx), %al
    movl $0xB4B4B4B4, %edx          # marker T5

    # T6: backward (DF=1), all-ones 0xFF
    std
    movl $src_byte_ff, %esi
    movl $0x3008, %edi
    movl %edi, %ebx
    movsb                            # writes 0xFF to [0x3008]; ESI--, EDI--
    cld
    movb (%ebx), %al
    movl $0xB5B5B5B5, %edx          # marker T6

    # T7-T9: three consecutive MOVSBs — verifies ESI/EDI auto-advance
    # src_bytes layout: [0x42, 0x00, 0xFF, 0x7F, 0x80, 0xA5, ...]
    movl $src_bytes, %esi
    movl $0x3010, %edi
    movl %edi, %ebx
    movsb                            # copies 0x42 to [0x3010]
    movb (%ebx), %al
    movl $0xB6B6B6B6, %edx          # marker T7

    movl %edi, %ebx
    movsb                            # copies 0x00 to [0x3011]
    movb (%ebx), %al
    movl $0xB7B7B7B7, %edx          # marker T8

    movl %edi, %ebx
    movsb                            # copies 0xFF to [0x3012]
    movb (%ebx), %al
    movl $0xB8B8B8B8, %edx          # marker T9

    # ================================================================
    # MOVSW TESTS  (opcode 66 A5)
    # Move word DS:[ESI] -> ES:[EDI]; ESI and EDI updated by ±2
    # ================================================================

    # T10: forward, normal word 0x1234
    movl $src_word_norm, %esi
    movl $0x3020, %edi
    movl %edi, %ebx
    movsw
    movw (%ebx), %ax
    movl $0xC0C0C0C0, %edx          # marker T10

    # T11: forward, zero word 0x0000
    movl $src_word_00, %esi
    movl $0x3022, %edi
    movl %edi, %ebx
    movsw
    movw (%ebx), %ax
    movl $0xC1C1C1C1, %edx          # marker T11

    # T12: forward, all-ones 0xFFFF
    movl $src_word_ff, %esi
    movl $0x3024, %edi
    movl %edi, %ebx
    movsw
    movw (%ebx), %ax
    movl $0xC2C2C2C2, %edx          # marker T12

    # T13: forward, signed-max 0x7FFF
    movl $src_word_7f, %esi
    movl $0x3026, %edi
    movl %edi, %ebx
    movsw
    movw (%ebx), %ax
    movl $0xC3C3C3C3, %edx          # marker T13

    # T14: forward, sign-boundary 0x8000
    movl $src_word_80, %esi
    movl $0x3028, %edi
    movl %edi, %ebx
    movsw
    movw (%ebx), %ax
    movl $0xC4C4C4C4, %edx          # marker T14

    # T15: backward (DF=1), all-ones 0xFFFF
    std
    movl $src_word_ff, %esi
    movl $0x3030, %edi
    movl %edi, %ebx
    movsw                            # writes 0xFFFF to [0x3030]; ESI-=2, EDI-=2
    cld
    movw (%ebx), %ax
    movl $0xC5C5C5C5, %edx          # marker T15

    # T16-T18: three consecutive MOVSWs — verifies ESI/EDI auto-advance by 2
    # src_words layout: [0x1234, 0x0000, 0xFFFF, 0x7FFF, 0x8000]
    movl $src_words, %esi
    movl $0x3040, %edi
    movl %edi, %ebx
    movsw                            # copies 0x1234 to [0x3040]
    movw (%ebx), %ax
    movl $0xC6C6C6C6, %edx          # marker T16

    movl %edi, %ebx
    movsw                            # copies 0x0000 to [0x3042]
    movw (%ebx), %ax
    movl $0xC7C7C7C7, %edx          # marker T17

    movl %edi, %ebx
    movsw                            # copies 0xFFFF to [0x3044]
    movw (%ebx), %ax
    movl $0xC8C8C8C8, %edx          # marker T18

    # ================================================================
    # MOVSL TESTS  (opcode A5)
    # Move dword DS:[ESI] -> ES:[EDI]; ESI and EDI updated by ±4
    # ================================================================

    # T19: forward, normal dword 0x12345678
    movl $src_dword_norm, %esi
    movl $0x3060, %edi
    movl %edi, %ebx
    movsl
    movl (%ebx), %eax
    movl $0xD0D0D0D0, %edx          # marker T19

    # T20: forward, zero 0x00000000
    movl $src_dword_00, %esi
    movl $0x3064, %edi
    movl %edi, %ebx
    movsl
    movl (%ebx), %eax
    movl $0xD1D1D1D1, %edx          # marker T20

    # T21: forward, all-ones 0xFFFFFFFF
    movl $src_dword_ff, %esi
    movl $0x3068, %edi
    movl %edi, %ebx
    movsl
    movl (%ebx), %eax
    movl $0xD2D2D2D2, %edx          # marker T21

    # T22: forward, signed-max 0x7FFFFFFF
    movl $src_dword_7f, %esi
    movl $0x306C, %edi
    movl %edi, %ebx
    movsl
    movl (%ebx), %eax
    movl $0xD3D3D3D3, %edx          # marker T22

    # T23: forward, sign-boundary 0x80000000
    movl $src_dword_80, %esi
    movl $0x3070, %edi
    movl %edi, %ebx
    movsl
    movl (%ebx), %eax
    movl $0xD4D4D4D4, %edx          # marker T23

    # T24: backward (DF=1), recognizable pattern 0xDEADBEEF
    std
    movl $src_dword_dead, %esi
    movl $0x3080, %edi
    movl %edi, %ebx
    movsl                            # writes 0xDEADBEEF to [0x3080]; ESI-=4, EDI-=4
    cld
    movl (%ebx), %eax
    movl $0xD5D5D5D5, %edx          # marker T24

    # T25-T27: three consecutive MOVSLs — verifies ESI/EDI auto-advance by 4
    # src_dwords layout: [0x12345678, 0x00000000, 0xFFFFFFFF, ...]
    movl $src_dwords, %esi
    movl $0x3090, %edi
    movl %edi, %ebx
    movsl                            # copies 0x12345678 to [0x3090]
    movl (%ebx), %eax
    movl $0xD6D6D6D6, %edx          # marker T25

    movl %edi, %ebx
    movsl                            # copies 0x00000000 to [0x3094]
    movl (%ebx), %eax
    movl $0xD7D7D7D7, %edx          # marker T26

    movl %edi, %ebx
    movsl                            # copies 0xFFFFFFFF to [0x3098]
    movl (%ebx), %eax
    movl $0xD8D8D8D8, %edx          # marker T27

    hlt


    # ================================================================
    # Source data — page 5 (VPN 0x00005 -> present, r_w=1 in TLB)
    # ================================================================

.org 0x5000
    .data

    # ---- byte sources (0x5000 – 0x5005) ----
src_bytes:
src_byte_norm:  .byte 0x42          # normal value
src_byte_00:    .byte 0x00          # zero
src_byte_ff:    .byte 0xFF          # all-ones
src_byte_7f:    .byte 0x7F          # signed max  (+127)
src_byte_80:    .byte 0x80          # sign boundary (−128 / 0x80)
src_byte_a5:    .byte 0xA5          # alternating bits
                .byte 0x00          # padding
                .byte 0x00          # padding (align to 2)

    # ---- word sources (0x5008 – 0x5011) ----
src_words:
src_word_norm:  .word 0x1234        # normal value
src_word_00:    .word 0x0000        # zero
src_word_ff:    .word 0xFFFF        # all-ones
src_word_7f:    .word 0x7FFF        # signed max  (+32767)
src_word_80:    .word 0x8000        # sign boundary (−32768 / 0x8000)
                .word 0x0000        # padding (align to 4)

    # ---- dword sources (0x5014 – 0x502B) ----
src_dwords:
src_dword_norm: .long 0x12345678    # normal value
src_dword_00:   .long 0x00000000    # zero
src_dword_ff:   .long 0xFFFFFFFF    # all-ones
src_dword_7f:   .long 0x7FFFFFFF    # signed max  (+2147483647)
src_dword_80:   .long 0x80000000    # sign boundary (−2147483648 / 0x80000000)
src_dword_dead: .long 0xDEADBEEF    # recognizable pattern