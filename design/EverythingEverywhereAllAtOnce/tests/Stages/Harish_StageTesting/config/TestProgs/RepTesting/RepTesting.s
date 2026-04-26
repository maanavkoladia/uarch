.org 0x00000000
    .code

    .global _start
_start:
    movl $0, %eax
    movl $0, %ebx
    movl $0, %ecx
    movl $0, %edx
    movl $5000, %esi
    movl $4000, %edi
    movl $0, %esp
    movl $0, %ebp
    
    xchg %edi, %esi
    
    hlt

.org 0x00050000
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
