# ================================================================
# TEST 4: INSTRUCTION DECODING STRESS TEST
# ================================================================
# LEGAL INSTRUCTIONS ONLY. Tests every opcode form on the ISA list.
#
# Focus: Wide opcode coverage, all ModRM fields, valid SIB combos,
#        operand size prefixes (16/32), byte operations, varying
#        instruction lengths, immediate sizes (imm8, imm16, imm32),
#        group opcodes, short-form EAX/AL encodings.
#
# Segment Layout:
#   CS0 = 0x0000 -> base 0x00000000  (code, 2 pages)
#   DS0 = 0x0200 -> base 0x02000000  (data)
#   SS0 = 0x0300 -> base 0x03000000  (stack)
# ================================================================

#define __CS0__ 0x0000
#define __DS0__ 0x0200
#define __SS0__ 0x0300

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
    movl    $0x00000000, %ebx

    # ================================================================
    # SECTION 1: MOV — ALL OPCODE FORMS
    # ================================================================

    # B8+rd: MOV r32, imm32 (5-byte)
    movl    $0xAAAA0001, %eax
    movl    $0xBBBB0002, %ecx
    movl    $0xCCCC0003, %edx
    movl    $0xDDDD0004, %esi
    movl    $0xEEEE0005, %edi
    movl    $0xFFFF0006, %ebp
    addl    %eax, %ebx
    addl    %ecx, %ebx
    addl    %edx, %ebx
    addl    %esi, %ebx
    addl    %edi, %ebx
    addl    %ebp, %ebx

    # 89: MOV r/m32, r32 (reg-to-reg, various ModRM)
    movl    %eax, %ecx
    movl    %ecx, %edx
    movl    %edx, %esi
    movl    %esi, %edi
    movl    %edi, %ebp
    addl    %ebp, %ebx

    # 8B: MOV r32, r/m32
    movl    $0x00000000, %esi
    movl    $0x12340001, (%esi)
    movl    (%esi), %eax                # 8B with ModRM mem
    addl    %eax, %ebx

    # C7 /0: MOV r/m32, imm32 (store imm to mem)
    movl    $0x12340002, 4(%esi)
    movl    $0x12340003, 0x100(%esi)
    movl    4(%esi), %eax
    addl    %eax, %ebx
    movl    0x100(%esi), %eax
    addl    %eax, %ebx

    # 89: MOV r/m32, r32 (store reg to mem)
    movl    $0xABCDEF01, %eax
    movl    %eax, 8(%esi)
    movl    8(%esi), %ecx
    addl    %ecx, %ebx

    # B0+rb: MOV r8, imm8
    movb    $0xAA, %al
    movb    $0xBB, %ah
    movb    $0xCC, %cl
    movb    $0xDD, %ch
    movb    $0xEE, %dl
    movb    $0xFF, %dh
    movb    $0x11, %bl
    movb    $0x22, %bh

    # 88: MOV r/m8, r8 (byte store)
    movl    $0x00000200, %edi
    movb    %al, (%edi)
    movb    %cl, 1(%edi)

    # 8A: MOV r8, r/m8 (byte load)
    movb    (%edi), %dl
    movb    1(%edi), %dh

    # B8+rw: MOV r16, imm16
    movw    $0x1234, %ax
    movw    $0x5678, %cx

    # 89: MOV r/m16, r16 (16-bit store)
    movw    %ax, 0x10(%edi)
    movw    0x10(%edi), %dx             # 8B: 16-bit load
    movl    %edx, %eax
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # C6 /0: MOV r/m8, imm8
    movb    $0x42, 2(%edi)
    movb    2(%edi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # C7 /0: MOV r/m16, imm16
    movw    $0xABCD, 4(%edi)
    movw    4(%edi), %ax
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # 8C: MOV r/m16, Sreg
    movw    %ds, %ax
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # 8E: MOV Sreg, r/m16 (already tested in init)

    # ================================================================
    # SECTION 2: ADD — ALL OPCODE FORMS
    # ================================================================

    # 05: ADD EAX, imm32 (short form, 5-byte)
    movl    $0x00001000, %eax
    addl    $0x00000100, %eax
    addl    %eax, %ebx

    # 04: ADD AL, imm8
    movl    $0x00000000, %eax
    addb    $0x42, %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # 81 /0: ADD r/m32, imm32
    movl    $0x00000000, %esi
    movl    $0x00001000, (%esi)
    addl    $0x00000234, (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # 83 /0: ADD r/m32, imm8 (sign-extended)
    movl    $0x00002000, %ecx
    addl    $0x10, %ecx                 # imm8
    addl    %ecx, %ebx

    # 01: ADD r/m32, r32
    movl    $0x00000100, %eax
    movl    $0x00000200, %ecx
    addl    %ecx, %eax                  # EAX = 0x300
    addl    %eax, %ebx

    # 03: ADD r32, r/m32
    movl    $0x00000400, (%esi)
    movl    $0x00000100, %eax
    addl    (%esi), %eax                # EAX = 0x500
    addl    %eax, %ebx

    # 00: ADD r/m8, r8
    movb    $0x10, (%esi)
    movb    $0x20, %al
    addb    %al, (%esi)
    movb    (%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # 02: ADD r8, r/m8
    movb    $0x05, (%esi)
    movb    $0x03, %al
    addb    (%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # 05 with 0x66 prefix: ADD AX, imm16
    movw    $0x0100, %ax
    addw    $0x0200, %ax
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # 01 with 0x66: ADD r/m16, r16
    movw    $0x1000, (%esi)
    movw    $0x2000, %ax
    addw    %ax, (%esi)
    movw    (%esi), %ax
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # 80 /0: ADD r/m8, imm8
    movb    $0x10, (%esi)
    addb    $0x05, (%esi)
    movb    (%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 3: AND — ALL OPCODE FORMS
    # ================================================================

    # 25: AND EAX, imm32
    movl    $0xFFFF0000, %eax
    andl    $0x0F0F0F0F, %eax
    addl    %eax, %ebx

    # 24: AND AL, imm8
    movl    $0x000000FF, %eax
    andb    $0x0F, %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # 81 /4: AND r/m32, imm32
    movl    $0x00000000, %esi
    movl    $0xFFFF0000, (%esi)
    andl    $0xFF00FF00, (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # 83 /4: AND r/m32, imm8 (sign-extended)
    movl    $0xFFFFFFFF, %ecx
    andl    $0x7F, %ecx                 # 0x7F sign-ext = 0x7F -> ECX = 0x7F
    addl    %ecx, %ebx

    # 21: AND r/m32, r32
    movl    $0xFF00FF00, %eax
    movl    $0x0F0F0F0F, %ecx
    andl    %ecx, %eax
    addl    %eax, %ebx

    # 23: AND r32, r/m32
    movl    $0xFF00FF00, (%esi)
    movl    $0x0F0F0F0F, %eax
    andl    (%esi), %eax
    addl    %eax, %ebx

    # 20: AND r/m8, r8
    movb    $0xFF, (%esi)
    movb    $0x0F, %al
    andb    %al, (%esi)
    movb    (%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # 22: AND r8, r/m8
    movb    $0xF0, (%esi)
    movb    $0xFF, %al
    andb    (%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 4: OR — ALL OPCODE FORMS
    # ================================================================

    # 0D: OR EAX, imm32
    movl    $0x00000000, %eax
    orl     $0xF0F0F0F0, %eax
    addl    %eax, %ebx

    # 0C: OR AL, imm8
    movl    $0x00000000, %eax
    orb     $0xAA, %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # 81 /1: OR r/m32, imm32
    movl    $0x00000000, %esi
    movl    $0x00FF0000, (%esi)
    orl     $0x000000FF, (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # 09: OR r/m32, r32
    movl    $0x00000000, (%esi)
    movl    $0xFF000000, %eax
    orl     %eax, (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # 0B: OR r32, r/m32
    movl    $0x0000FF00, (%esi)
    movl    $0x00000000, %eax
    orl     (%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 5: NOT — ALL FORMS
    # ================================================================

    # F7 /2: NOT r/m32
    movl    $0x0F0F0F0F, %eax
    notl    %eax
    addl    %eax, %ebx

    # F7 /2: NOT mem32
    movl    $0x00000000, %esi
    movl    $0xFF00FF00, (%esi)
    notl    (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # F6 /2: NOT r/m8
    movb    $0x0F, %al
    notb    %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # F7 /2: NOT r/m16
    movw    $0x00FF, %ax
    notw    %ax
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 6: ADC / SBB — r/m32 FORMS
    # ================================================================

    # Set CF=1 via ADD overflow
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1

    # 11: ADC r/m32, r32
    movl    $0x000000FF, %ecx
    movl    $0x00000000, %edx
    adcl    %ecx, %edx                  # EDX = 0xFF + CF(1) = 0x100
    addl    %edx, %ebx

    # Clear CF: AND always clears CF
    movl    $0x00000001, %eax
    andl    $0xFFFFFFFF, %eax           # CF=0

    # 13: ADC r32, r/m32
    movl    $0x00000000, %esi
    movl    $0x00000010, (%esi)
    movl    $0x00000020, %eax
    adcl    (%esi), %eax                # EAX = 0x20 + 0x10 + 0 = 0x30
    addl    %eax, %ebx

    # 81 /2: ADC r/m32, imm32
    movl    $0x00000100, (%esi)
    adcl    $0x00000050, (%esi)          # mem = 0x150
    movl    (%esi), %eax
    addl    %eax, %ebx

    # 83 /2: ADC r/m32, imm8
    movl    $0x00000200, %ecx
    adcl    $0x10, %ecx
    addl    %ecx, %ebx

    # Set CF=1 again for SBB
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1

    # 19: SBB r/m32, r32
    movl    $0x00000100, %ecx
    movl    $0x00000010, %edx
    sbbl    %edx, %ecx                  # ECX = 0x100 - 0x10 - 1 = 0xEF
    addl    %ecx, %ebx

    # 1B: SBB r32, r/m32
    movl    $0x00000050, (%esi)
    movl    $0x00000100, %eax
    # CF is whatever SBB left it. Clear it first.
    andl    $0xFFFFFFFF, %eax           # CF=0
    sbbl    (%esi), %eax                # EAX = 0x100 - 0x50 - 0 = 0xB0
    addl    %eax, %ebx

    # 81 /3: SBB r/m32, imm32
    movl    $0x00001000, (%esi)
    andl    $0xFFFFFFFF, %eax           # CF=0
    sbbl    $0x00000100, (%esi)          # mem = 0xF00
    movl    (%esi), %eax
    addl    %eax, %ebx

    # 83 /3: SBB r/m32, imm8
    movl    $0x00000080, %ecx
    andl    $0xFFFFFFFF, %eax           # CF=0
    sbbl    $0x10, %ecx                  # ECX = 0x80 - 0x10 = 0x70
    addl    %ecx, %ebx

    # ================================================================
    # SECTION 7: SAL / SAR — ALL FORMS
    # ================================================================

    # D1 /4: SAL r/m32, 1
    movl    $0x00000001, %eax
    sall    $1, %eax                    # EAX = 2
    addl    %eax, %ebx

    # C1 /4: SAL r/m32, imm8
    movl    $0x00000001, %eax
    sall    $8, %eax                    # EAX = 0x100
    addl    %eax, %ebx

    # D3 /4: SAL r/m32, CL
    movl    $0x00000001, %eax
    movl    $0x00000004, %ecx
    sall    %cl, %eax                   # EAX = 0x10
    addl    %eax, %ebx

    # SAL on memory
    movl    $0x00000000, %esi
    movl    $0x00000001, (%esi)
    sall    $16, (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # D1 /7: SAR r/m32, 1
    movl    $0x80000000, %eax
    sarl    $1, %eax                    # 0xC0000000
    addl    %eax, %ebx

    # C1 /7: SAR r/m32, imm8
    movl    $0x80000000, %eax
    sarl    $4, %eax                    # 0xF8000000
    addl    %eax, %ebx

    # D3 /7: SAR r/m32, CL
    movl    $0xFF000000, %eax
    movl    $0x00000008, %ecx
    sarl    %cl, %eax                   # 0xFFFF0000
    addl    %eax, %ebx

    # SAR on memory
    movl    $0x80000000, (%esi)
    sarl    $8, (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # SAL/SAR on 8-bit: D0, D2, C0
    movb    $0x01, %al
    salb    $1, %al                     # AL = 0x02
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    movb    $0x80, %al
    sarb    $1, %al                     # AL = 0xC0
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    movb    $0x01, %al
    movb    $0x03, %cl
    salb    %cl, %al                    # AL = 0x08
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # SAL/SAR on 16-bit
    movw    $0x0001, %ax
    salw    $8, %ax                     # AX = 0x0100
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 8: XCHG — ALL FORMS
    # ================================================================

    # 90+rd: XCHG EAX, r32
    movl    $0x11110000, %eax
    movl    $0x22220000, %ecx
    xchgl   %eax, %ecx
    addl    %eax, %ebx
    addl    %ecx, %ebx

    # 87: XCHG r/m32, r32 (reg-reg)
    movl    $0x33330000, %edx
    movl    $0x44440000, %esi
    xchgl   %edx, %esi
    addl    %edx, %ebx
    addl    %esi, %ebx

    # 87: XCHG r/m32, r32 (mem)
    movl    $0x00000000, %esi
    movl    $0x55550000, (%esi)
    movl    $0x66660000, %eax
    xchgl   %eax, (%esi)
    addl    %eax, %ebx
    movl    (%esi), %eax
    addl    %eax, %ebx

    # 86: XCHG r/m8, r8
    movb    $0xAA, (%esi)
    movb    $0xBB, %al
    xchgb   %al, (%esi)
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # NOP = XCHG EAX, EAX (opcode 0x90)
    xchgl   %eax, %eax
    xchgl   %eax, %eax
    xchgl   %eax, %eax

    # ================================================================
    # SECTION 9: BSF
    # ================================================================

    # 0F BC: BSF r32, r/m32
    movl    $0x00000010, %eax
    bsfl    %eax, %ecx                  # ECX = 4
    addl    %ecx, %ebx

    movl    $0x80000000, %eax
    bsfl    %eax, %ecx                  # ECX = 31
    addl    %ecx, %ebx

    # BSF from memory
    movl    $0x00000000, %esi
    movl    $0x00000100, (%esi)
    bsfl    (%esi), %ecx                # ECX = 8
    addl    %ecx, %ebx

    # BSF r16, r/m16
    movw    $0x0080, %ax
    bsfw    %ax, %cx                    # CX = 7
    andl    $0x0000FFFF, %ecx
    addl    %ecx, %ebx

    # ================================================================
    # SECTION 10: CMPXCHG — ALL FORMS
    # ================================================================

    # 0F B1: CMPXCHG r/m32, r32
    # Case 1: EAX matches mem -> store ECX to mem, ZF=1
    movl    $0x00000000, %esi
    movl    $0x12345678, (%esi)
    movl    $0x12345678, %eax
    movl    $0xAAAAAAAA, %ecx
    cmpxchgl %ecx, (%esi)              # match: mem = 0xAAAAAAAA, ZF=1
    jne     cmpx_fail_1                 # should NOT take (ZF=1)
    movl    (%esi), %eax
    addl    %eax, %ebx
    jmp     cmpx_2
cmpx_fail_1:
    addl    $0xBAD0000A, %ebx
cmpx_2:

    # Case 2: EAX doesn't match -> EAX = mem, ZF=0
    movl    $0x00000000, %eax
    movl    $0xBBBBBBBB, %ecx
    cmpxchgl %ecx, (%esi)              # no match: EAX = 0xAAAAAAAA
    jne     cmpx_nomatch_ok             # should take (ZF=0)
    addl    $0xBAD0000B, %ebx
    jmp     cmpx_done
cmpx_nomatch_ok:
    addl    %eax, %ebx
cmpx_done:

    # 0F B0: CMPXCHG r/m8, r8
    movb    $0x42, (%esi)
    movb    $0x42, %al
    movb    $0xFF, %cl
    cmpxchgb %cl, (%esi)               # match: mem = 0xFF
    movb    (%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 11: CMOVC — CF=1 conditional move
    # ================================================================

    # Set CF=1 via ADD overflow
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1
    movl    $0xCCCCCCCC, %ecx
    movl    $0x00000000, %edx
    cmovcl  %ecx, %edx                  # CF=1 -> EDX = 0xCCCCCCCC
    addl    %edx, %ebx

    # CF=0: CMOVC should NOT move
    andl    $0xFFFFFFFF, %eax           # CF=0
    movl    $0xDDDDDDDD, %ecx
    movl    $0x00000000, %edx
    cmovcl  %ecx, %edx                  # CF=0 -> EDX stays 0
    addl    %edx, %ebx                  # adds 0

    # CMOVC from memory
    movl    $0xEEEE0000, (%esi)
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax           # CF=1
    movl    $0x00000000, %edx
    cmovcl  (%esi), %edx                # EDX = 0xEEEE0000
    addl    %edx, %ebx

    # ================================================================
    # SECTION 12: CLD / STD
    # ================================================================

    cld
    std
    cld

    # ================================================================
    # SECTION 13: AAA (ASCII Adjust After Addition)
    # ================================================================

    movl    $0x00000009, %eax           # AL=9
    addl    $0x00000008, %eax           # AL=0x11 (unpacked BCD: 9+8=17)
    aaa                                 # AL adjusted, AH incremented
    addl    %eax, %ebx

    # ================================================================
    # SECTION 14: MIXED INSTRUCTION LENGTHS
    # Back-to-back short and long instructions to stress decoder.
    # ================================================================

    xchgl   %eax, %eax                  # 1 byte (NOP)
    movl    $0xDEADBEEF, %eax           # 5 bytes
    xchgl   %eax, %eax                  # 1 byte
    addl    $0x01, %ecx                 # 3 bytes (imm8)
    movl    $0x12345678, 0x300(%esi)     # long: opcode+ModRM+disp32+imm32
    xchgl   %eax, %eax                  # 1 byte
    movl    $0x00000000, %eax           # 5 bytes
    addl    $0xCAFEBABE, %eax           # 5 bytes
    addl    %eax, %ebx
    xchgl   %eax, %eax
    xchgl   %eax, %eax
    xchgl   %eax, %eax

    # ================================================================
    # DONE
    # ================================================================

    movl    $0x00000000, %esi
    movl    %ebx, 0xF00(%esi)
    hlt


# ================================================================
# DATA (DS0 base = 0x02000000)
# ================================================================
.org 0x02000000
.data
    .long 0x11223344
    .space 0x0F00

# ================================================================
# STACK (SS0 base = 0x03000000)
# ================================================================
.org 0x03000000
.data
    .space 0x1000
