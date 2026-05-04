#define __CS__ 0x0000
#define __DS__ 0x4002
#define __SS__ 0xF000


.org 0x00000000
.code
.global _start

# ================================================================
# AluTest.s
#
# Comprehensive coverage of every ALU functional unit.
# No far jumps, no calls, no exception-related code.
#
# Conventions
# -----------
#   DS = ES = 0x4002  (one 4 KiB data page mapped via VPN 0x40020)
#   SS  = 0xF000      (one 4 KiB stack page mapped via VPN 0xF0000)
#   ESI = 0           (data offsets are (%esi)+disp inside the data page)
#   EBX = running checksum / accumulator (read at end via hlt)
#
# Memory map inside the data page (used as scratch):
#   0x000-0x07F : MOV scratch
#   0x080-0x0FF : ADD scratch
#   0x100-0x17F : ADC scratch
#   0x180-0x1FF : SBB scratch
#   0x200-0x27F : AND scratch
#   0x280-0x2FF : OR  scratch
#   0x300-0x37F : NOT scratch
#   0x380-0x3FF : SAL/SAR scratch
#   0x400-0x47F : BSF / CMOVC / CMPXCHG / XCHG scratch
#   0x480-0x4FF : PUSH / POP scratch
#   0x500-0x5FF : MMX (PACK / PADD / PAVG / MOVQ) staging + result
#   0x600-0x6FF : //MOVS source buffer
#   0x700-0x7FF : //MOVS / //REPE CMPS destination buffer
#
# Every section ends by mixing some result into EBX so a trace
# tool can see the full state evolve.
# ================================================================

_start:

segment_init:
    movl    $__DS__, %eax
    movw    %ax, %ds
    movw    %ax, %es                 # ES = DS  (so //MOVS/CMPS hit the same page)
    movl    $__SS__, %eax
    movw    %ax, %ss

main:
    movl    $0x00FFF, %esp           # stack grows down inside the SS page
    movl    $0x0,     %esi
    movl    $0x0,     %edi
    movl    $0x0,     %ebx           # accumulator

    # ================================================================
    # SECTION 1 : MOV — every form, including all 8-bit register
    # combinations (AL,AH,BL,BH,CL,CH,DL,DH) and r/m forms.
    # ================================================================

    # MOV r32, imm32  (B8+rd)
    movl    $0xDEADBEEF, %eax
    movl    $0x12345678, %ecx
    movl    $0xCAFEBABE, %edx
    movl    $0x0F0F0F0F, %edi

    # MOV r/m32, r32  (89 /r)  — store
    movl    %eax, 0x00(%esi)
    movl    %ecx, 0x04(%esi)
    movl    %edx, 0x08(%esi)
    movl    %edi, 0x0C(%esi)

    # MOV r32, r/m32  (8B /r)  — reload
    movl    0x00(%esi), %eax
    addl    %eax, %ebx
    movl    0x04(%esi), %ecx
    addl    %ecx, %ebx
    movl    0x08(%esi), %edx
    addl    %edx, %ebx
    movl    0x0C(%esi), %edi
    addl    %edi, %ebx

    # MOV r/m32, imm32  (C7 /0)
    movl    $0x11223344, 0x10(%esi)
    movl    $0xAABBCCDD, 0x14(%esi)
    movl    0x10(%esi), %eax
    addl    %eax, %ebx
    movl    0x14(%esi), %eax
    addl    %eax, %ebx

    # MOV r16, imm16  (B8+rw)
    movw    $0x1234, %ax
    movw    $0x5678, %cx
    movw    $0x9ABC, %dx
    movw    $0xDEF0, %di

    # MOV r/m16, r16   (89 /r) — store
    movw    %ax, 0x18(%esi)
    movw    %cx, 0x1A(%esi)
    movw    %dx, 0x1C(%esi)
    movw    %di, 0x1E(%esi)

    # MOV r16, r/m16   (8B /r) — reload
    movw    0x18(%esi), %ax
    movw    0x1A(%esi), %cx
    movw    0x1C(%esi), %dx
    movw    0x1E(%esi), %di
    andl    $0xFFFF, %eax
    addl    %eax, %ebx
    andl    $0xFFFF, %ecx
    addl    %ecx, %ebx

    # MOV r/m16, imm16  (C7 /0)
    movw    $0xBEEF, 0x20(%esi)
    movw    $0xFACE, 0x22(%esi)

    # MOV r8, imm8  (B0+rb)  — every 8-bit register
    movb    $0x12, %al
    movb    $0x34, %ah
    movb    $0x56, %bl
    movb    $0x78, %bh
    movb    $0x9A, %cl
    movb    $0xBC, %ch
    movb    $0xDE, %dl
    movb    $0xF0, %dh

    # MOV r/m8, r8   (88 /r)  — store every 8-bit reg
    movb    %al, 0x30(%esi)
    movb    %ah, 0x31(%esi)
    movb    %bl, 0x32(%esi)
    movb    %bh, 0x33(%esi)
    movb    %cl, 0x34(%esi)
    movb    %ch, 0x35(%esi)
    movb    %dl, 0x36(%esi)
    movb    %dh, 0x37(%esi)

    # MOV r8, r/m8   (8A /r)  — load into AL/AH/CL/CH
    movb    0x30(%esi), %al
    movb    0x31(%esi), %ah
    movb    0x34(%esi), %cl
    movb    0x35(%esi), %ch

    # MOV r/m8, imm8  (C6 /0)
    movb    $0x55, 0x38(%esi)
    movb    $0xAA, 0x39(%esi)
    movb    $0x01, 0x3A(%esi)
    movb    $0xFE, 0x3B(%esi)

    # MOV reg-reg 8-bit — exercise AH/AL crosses
    movb    %al, %ah                 # AH = AL
    movb    %ah, %dl                 # DL = AH
    movb    %dl, %bh                 # BH = DL
    movb    %bh, %cl                 # CL = BH
    movb    %ch, %al                 # AL = CH (read-AH-pair)
    movb    %ah, %bl
    movb    %dh, %ah                 # AH = DH
    movb    %al, %dh                 # DH = AL

    movl    0x30(%esi), %eax
    addl    %eax, %ebx
    movl    0x34(%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 2 : ADD — 8/16/32 with imm/reg/mem and AH/AL combos.
    # ================================================================

    # 32-bit ADD
    movl    $0x10000000, %eax
    addl    $0x20000000, %eax        # ADD EAX, imm32        (05 id)
    addl    %eax, %ebx

    movl    $0x00000010, %ecx
    addl    $0x00000020, %ecx        # ADD r/m32, imm32      (81 /0 id)
    addl    %ecx, %ebx

    movl    $0x00001000, %edx
    addl    $0x10, %edx              # ADD r/m32, imm8 sx    (83 /0 ib)
    addl    %edx, %ebx

    movl    $0x00001000, %edx
    addl    $-1, %edx                # imm8 sign-extended → 0xFFFFFFFF
    addl    %edx, %ebx

    movl    $0x11111111, %eax
    movl    $0x22222222, %ecx
    addl    %ecx, %eax               # ADD r/m32, r32        (01 /r)
    addl    %eax, %ebx

    movl    $0x10000000, %eax
    movl    $0xCAFEBABE, 0x80(%esi)
    addl    0x80(%esi), %eax         # ADD r32, r/m32        (03 /r)
    addl    %eax, %ebx

    movl    $0x00000010, 0x80(%esi)
    movl    $0x00000005, %ecx
    addl    %ecx, 0x80(%esi)         # ADD r/m32, r32 (mem dest)
    movl    0x80(%esi), %eax
    addl    %eax, %ebx

    movl    $0x00000010, 0x84(%esi)
    addl    $0x07, 0x84(%esi)        # ADD r/m32, imm8 (mem dest)
    movl    0x84(%esi), %eax
    addl    %eax, %ebx

    # 16-bit ADD
    movw    $0x1000, %ax
    addw    $0x0234, %ax             # ADD AX, imm16         (05 iw)
    movw    %ax, 0x88(%esi)
    movw    0x88(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x1000, %cx
    addw    $-1, %cx                 # ADD r/m16, imm8 sx    (83 /0 ib)
    movw    %cx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x1234, 0x8A(%esi)
    movw    $0x0001, %ax
    addw    %ax, 0x8A(%esi)          # ADD r/m16, r16 (mem dst)
    movw    0x8A(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    0x8A(%esi), %dx
    addw    %dx, 0x88(%esi)          # ADD r/m16, r16 (mem dst, dx)
    movw    0x88(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # 8-bit ADD — AL/AH against imm8, reg, mem
    movb    $0x10, %al
    addb    $0x05, %al               # ADD AL, imm8          (04 ib)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x40, %ah
    addb    $0x02, %ah               # ADD r/m8, imm8        (80 /0 ib)
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # AH+AL combo  (00 /r with both halves of EAX)
    movb    $0x10, %al
    movb    $0x05, %ah
    addb    %ah, %al                 # AL += AH    (AL=0x15)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # Carry-out  AL=0x80 + AH=0x80 → AH=0x00, CF=1
    movb    $0x80, %al
    movb    $0x80, %ah
    addb    %al, %ah
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # AL+memory
    movb    $0x44, 0x90(%esi)
    movb    $0x11, %al
    addb    0x90(%esi), %al          # ADD r8, r/m8          (02 /r)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # mem+AL
    movb    $0x10, 0x90(%esi)
    movb    $0x05, %al
    addb    %al, 0x90(%esi)          # ADD r/m8, r8 (mem dst, al)
    movb    0x90(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # mem+AH
    movb    $0x20, 0x91(%esi)
    movb    $0x07, %ah
    addb    %ah, 0x91(%esi)          # ADD r/m8, r8 (mem dst, ah)
    movb    0x91(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # AH+mem (load)
    movb    $0x33, 0x92(%esi)
    movb    $0x10, %ah
    addb    0x92(%esi), %ah
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # mem+imm8 (8-bit r/m8, imm8 — generic form)
    movb    $0x10, 0x93(%esi)
    addb    $0x05, 0x93(%esi)
    movb    0x93(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # 8-bit cross-half register adds
    movb    $0x01, %bl
    movb    $0x02, %bh
    addb    %bl, %bh                 # BH += BL
    movb    %bh, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x10, %cl
    movb    $0x20, %dh
    addb    %cl, %dh
    movb    %dh, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 3 : ADC — 32-bit r/m and reg forms only (per ISA list).
    # ================================================================

    # CF=1 producer:  0xFFFFFFFF + 1 = 0  (CF set)
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000001, %eax
    movl    $0x00000000, %edx
    adcl    $0x00000000, %edx        # ADC r/m32, imm32 → 1
    addl    %edx, %ebx

    # ADC r/m32, imm32 with CF=0
    movl    $0x00000001, %eax
    addl    $0x00000001, %eax        # CF=0
    movl    $0x10000000, %edx
    adcl    $0x00000010, %edx        # → 0x10000010
    addl    %edx, %ebx

    # ADC r/m32, imm8 (sign-extended)
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000002, %eax        # CF=1
    movl    $0x00000010, %ecx
    adcl    $-1, %ecx                # +0xFFFFFFFF + CF → 0x00000010
    addl    %ecx, %ebx

    # ADC r/m32, r32  (CF=1)
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000002, %eax
    movl    $0x00000005, %ecx
    movl    $0x00000010, %edx
    adcl    %edx, %ecx               # ECX = 5 + 0x10 + 1 = 0x16
    addl    %ecx, %ebx

    # ADC r32, r/m32 (mem source) — CF=1
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000002, %eax
    movl    $0x00000020, 0x100(%esi)
    movl    $0x00000003, %ecx
    adcl    0x100(%esi), %ecx        # ECX = 3 + 0x20 + 1 = 0x24
    addl    %ecx, %ebx

    # ADC r/m32, imm32 (mem dest) — CF=1
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000002, %eax
    movl    $0x00001000, 0x104(%esi)
    adcl    $0x00000001, 0x104(%esi) # mem = 0x1002
    movl    0x104(%esi), %eax
    addl    %eax, %ebx

    # ADC r/m32, r32 (mem dest) — CF=0
    movl    $0x00000001, %eax
    addl    $0x00000001, %eax        # CF=0
    movl    $0x00002000, 0x108(%esi)
    movl    $0x00000100, %ecx
    adcl    %ecx, 0x108(%esi)        # mem = 0x2100
    movl    0x108(%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 4 : SBB — 32-bit r/m and reg forms only (per ISA list).
    # ================================================================

    # SBB r/m32, imm32, CF=0
    movl    $0x00000001, %eax
    addl    $0x00000001, %eax        # CF=0
    movl    $0x00000010, %eax
    sbbl    $0x00000001, %eax        # 0x10 - 1 - 0 = 0xF
    addl    %eax, %ebx

    # SBB r/m32, imm32, CF=1
    movl    $0xFFFFFFFF, %ecx
    addl    $0x00000002, %ecx        # CF=1
    movl    $0x00000010, %eax
    sbbl    $0x00000001, %eax        # 0x10 - 1 - 1 = 0xE
    addl    %eax, %ebx

    # SBB r/m32, imm8 sx, CF=1
    movl    $0xFFFFFFFF, %ecx
    addl    $0x00000002, %ecx
    movl    $0x00001000, %edx
    sbbl    $0x10, %edx              # 0x1000 - 0x10 - 1 = 0xFEF
    addl    %edx, %ebx

    # SBB r/m32, r32, CF=1
    movl    $0xFFFFFFFF, %ecx
    addl    $0x00000002, %ecx
    movl    $0x00000100, %eax
    movl    $0x00000010, %edx
    sbbl    %edx, %eax               # EAX = 0x100 - 0x10 - 1 = 0xEF
    addl    %eax, %ebx

    # SBB r32, r/m32 (mem source), CF=1
    movl    $0xFFFFFFFF, %ecx
    addl    $0x00000002, %ecx
    movl    $0x00000050, 0x180(%esi)
    movl    $0x00000200, %eax
    sbbl    0x180(%esi), %eax        # 0x200 - 0x50 - 1 = 0x1AF
    addl    %eax, %ebx

    # SBB r/m32, imm32 (mem dest), CF=0
    movl    $0x00000001, %eax
    addl    $0x00000001, %eax        # CF=0
    movl    $0x00001000, 0x184(%esi)
    sbbl    $0x00000001, 0x184(%esi) # 0x1000 - 1 - 0 = 0xFFF
    movl    0x184(%esi), %eax
    addl    %eax, %ebx

    # SBB r/m32, r32 (mem dest), CF=1
    movl    $0xFFFFFFFF, %ecx
    addl    $0x00000002, %ecx
    movl    $0x00005000, 0x188(%esi)
    movl    $0x00000100, %eax
    sbbl    %eax, 0x188(%esi)        # 0x5000 - 0x100 - 1 = 0x4EFF
    movl    0x188(%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 5 : AND — 8/16/32 with all forms; AH/AL combos.
    # ================================================================

    # 32-bit
    movl    $0xFFFF00FF, %eax
    andl    $0x0F0F0F0F, %eax        # AND EAX, imm32        (25 id)
    addl    %eax, %ebx

    movl    $0xABCDEF12, %ecx
    andl    $0xFFFF0000, %ecx        # AND r/m32, imm32      (81 /4 id)
    addl    %ecx, %ebx

    movl    $0xDEADBEEF, %edx
    andl    $0x0F, %edx              # AND r/m32, imm8 sx    (83 /4 ib)
    addl    %edx, %ebx

    movl    $0xDEADBEEF, %eax
    movl    $0x0000FFFF, %edx
    andl    %edx, %eax               # AND r/m32, r32        (21 /r)
    addl    %eax, %ebx

    movl    $0xF0F0F0F0, 0x200(%esi)
    movl    $0x0F0F0F0F, %eax
    andl    0x200(%esi), %eax        # AND r32, r/m32        (23 /r)
    addl    %eax, %ebx

    movl    $0xFFFFFFFF, 0x204(%esi)
    movl    $0x12345678, %eax
    andl    %eax, 0x204(%esi)        # AND r/m32, r32 (mem dst)
    movl    0x204(%esi), %eax
    addl    %eax, %ebx

    movl    $0xFFFFFFFF, 0x208(%esi)
    andl    $0x00FF00FF, 0x208(%esi) # AND r/m32, imm32 (mem)
    movl    0x208(%esi), %eax
    addl    %eax, %ebx

    # 16-bit
    movw    $0xABCD, %ax
    andw    $0x00FF, %ax             # AND AX, imm16         (25 iw)
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x1234, %cx
    andw    $0x0F, %cx               # AND r/m16, imm8 sx    (83 /4 ib)
    movw    %cx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0xFFFF, 0x20C(%esi)
    movw    $0x0F0F, %ax
    andw    %ax, 0x20C(%esi)         # AND r/m16, r16 (mem dst)
    movw    0x20C(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # 8-bit AND with AL/AH/mem combos
    movb    $0xFF, %al
    andb    $0x0F, %al               # AND AL, imm8          (24 ib)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0xFF, %ah
    andb    $0xF0, %ah               # AND r/m8, imm8        (80 /4 ib)
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # AL & AH (AH+AL combo)
    movb    $0xFF, %al
    movb    $0x0F, %ah
    andb    %ah, %al                 # AND r/m8, r8 (al, ah)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0xFF, %ah
    movb    $0xF0, %al
    andb    %al, %ah
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # AL & mem
    movb    $0x0F, 0x210(%esi)
    movb    $0xFF, %al
    andb    0x210(%esi), %al         # AND r8, r/m8          (22 /r)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # mem & AL
    movb    $0xFF, 0x210(%esi)
    movb    $0x33, %al
    andb    %al, 0x210(%esi)         # AND r/m8, r8 (mem, al)
    movb    0x210(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # mem & AH
    movb    $0xFF, 0x211(%esi)
    movb    $0xCC, %ah
    andb    %ah, 0x211(%esi)
    movb    0x211(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # mem & imm8 — generic form
    movb    $0xFF, 0x212(%esi)
    andb    $0x0F, 0x212(%esi)
    movb    0x212(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # cross-half: BH & BL, CH & DL etc.
    movb    $0xF0, %bh
    movb    $0x0F, %bl
    andb    %bl, %bh                 # 0
    movb    %bh, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0xAA, %ch
    movb    $0xCC, %dl
    andb    %ch, %dl                 # 0x88
    movb    %dl, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 6 : OR — 8/16/32 with all forms; AH/AL combos.
    # ================================================================

    # 32-bit
    movl    $0x00FF00FF, %eax
    orl     $0xFF00FF00, %eax        # OR EAX, imm32         (0D id)
    addl    %eax, %ebx

    movl    $0x00000000, %ecx
    orl     $0x12345678, %ecx        # OR r/m32, imm32       (81 /1 id)
    addl    %ecx, %ebx

    movl    $0x10000000, %edx
    orl     $0x0F, %edx              # OR r/m32, imm8 sx     (83 /1 ib)
    addl    %edx, %ebx

    movl    $0x00FF0000, %eax
    movl    $0xFF00FFFF, %ecx
    orl     %ecx, %eax               # OR r/m32, r32         (09 /r)
    addl    %eax, %ebx

    movl    $0x12000000, 0x280(%esi)
    movl    $0x00345678, %eax
    orl     0x280(%esi), %eax        # OR r32, r/m32         (0B /r)
    addl    %eax, %ebx

    movl    $0x00000000, 0x284(%esi)
    movl    $0xCAFEBABE, %eax
    orl     %eax, 0x284(%esi)        # OR r/m32, r32 (mem)
    movl    0x284(%esi), %eax
    addl    %eax, %ebx

    movl    $0x0F0F0F0F, 0x288(%esi)
    orl     $0xF0F0F0F0, 0x288(%esi) # OR r/m32, imm32 (mem)
    movl    0x288(%esi), %eax
    addl    %eax, %ebx

    # 16-bit
    movw    $0x00FF, %ax
    orw     $0xFF00, %ax             # OR AX, imm16          (0D iw)
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x0010, %cx
    orw     $0x0F, %cx               # OR r/m16, imm8 sx     (83 /1 ib)
    movw    %cx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x0F0F, 0x28C(%esi)
    movw    $0xF0F0, %ax
    orw     %ax, 0x28C(%esi)
    movw    0x28C(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # 8-bit OR with AL/AH/mem combos
    movb    $0x00, %al
    orb     $0x55, %al               # OR AL, imm8           (0C ib)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x00, %ah
    orb     $0xAA, %ah               # OR r/m8, imm8         (80 /1 ib)
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # AL | AH
    movb    $0x0F, %al
    movb    $0xF0, %ah
    orb     %ah, %al                 # OR r/m8, r8 (AL,AH)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x05, %ah
    movb    $0x0A, %al
    orb     %al, %ah
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # AL | mem
    movb    $0xF0, 0x290(%esi)
    movb    $0x0F, %al
    orb     0x290(%esi), %al         # OR r8, r/m8           (0A /r)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # mem | AL/AH
    movb    $0x00, 0x290(%esi)
    movb    $0x44, %al
    orb     %al, 0x290(%esi)
    movb    0x290(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x00, 0x291(%esi)
    movb    $0x88, %ah
    orb     %ah, 0x291(%esi)
    movb    0x291(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x10, 0x292(%esi)
    orb     $0x21, 0x292(%esi)       # OR r/m8, imm8 (mem)
    movb    0x292(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # cross-half register OR
    movb    $0x10, %bl
    movb    $0x02, %bh
    orb     %bl, %bh                 # BH = 0x12
    movb    %bh, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 7 : NOT — 8/16/32 reg + mem
    # ================================================================

    movl    $0x0F0F0F0F, %eax
    notl    %eax                     # NOT r/m32             (F7 /2)
    addl    %eax, %ebx

    movl    $0x12345678, 0x300(%esi)
    notl    0x300(%esi)              # NOT r/m32 (mem)
    movl    0x300(%esi), %eax
    addl    %eax, %ebx

    movw    $0x1234, %cx
    notw    %cx                      # NOT r/m16             (F7 /2)
    movw    %cx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0xABCD, 0x304(%esi)
    notw    0x304(%esi)
    movw    0x304(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # NOT 8-bit on each register half
    movb    $0x55, %al
    notb    %al                      # NOT r/m8              (F6 /2)
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0xAA, %ah
    notb    %ah
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0xC3, %bl
    notb    %bl
    movb    %bl, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x00, %dh
    notb    %dh
    movb    %dh, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0xF0, 0x308(%esi)
    notb    0x308(%esi)              # NOT r/m8 (mem)
    movb    0x308(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 8 : AAA — ASCII adjust AL after addition
    # AAA reads AL/AH and AF, writes AL/AH and CF/AF.
    # ================================================================

    movl    $0x00000000, %eax
    movb    $0x09, %al
    addb    $0x09, %al               # AL=0x12, AF=1
    aaa                              # AL=0x08, AH=0x01, CF=AF=1
    movl    %eax, 0x310(%esi)
    movl    0x310(%esi), %eax
    addl    %eax, %ebx

    movl    $0x00000000, %eax
    movb    $0x05, %al
    addb    $0x03, %al               # AL=0x08, AF=0
    aaa                              # AL=0x08, AH=0x00, CF=AF=0 (no adjust)
    movl    %eax, 0x314(%esi)
    movl    0x314(%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 9 : SAL — shift arithmetic left, all sizes & shift sources
    # ================================================================

    # SAL r/m32, 1
    movl    $0x00000001, %eax
    sall    $1, %eax                 # → 2
    addl    %eax, %ebx

    # SAL r/m32, imm8
    movl    $0x00000001, %eax
    sall    $8, %eax                 # → 0x100
    addl    %eax, %ebx

    movl    $0x00000001, %eax
    sall    $16, %eax                # → 0x10000
    addl    %eax, %ebx

    # SAL r/m32, CL
    movl    $0x00000001, %eax
    movb    $4, %cl
    sall    %cl, %eax                # → 0x10
    addl    %eax, %ebx

    movl    $0x00000003, %eax
    movb    $12, %cl
    sall    %cl, %eax                # → 0x3000
    addl    %eax, %ebx

    # SAL r/m32, * (mem)
    movl    $0x00000080, 0x380(%esi)
    sall    $1, 0x380(%esi)
    movl    0x380(%esi), %eax
    addl    %eax, %ebx

    movl    $0x00000001, 0x380(%esi)
    sall    $12, 0x380(%esi)
    movl    0x380(%esi), %eax
    addl    %eax, %ebx

    movl    $0x00000001, 0x380(%esi)
    movb    $20, %cl
    sall    %cl, 0x380(%esi)
    movl    0x380(%esi), %eax
    addl    %eax, %ebx

    # SAL r/m16
    movw    $0x0001, %ax
    salw    $1, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x0001, %ax
    salw    $8, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x0001, %dx
    movb    $4, %cl
    salw    %cl, %dx
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x0040, 0x384(%esi)
    salw    $2, 0x384(%esi)
    movw    0x384(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # SAL r/m8 — exercise AH and AL specifically
    movb    $0x01, %al
    salb    $1, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x01, %ah
    salb    $4, %ah
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x03, %al
    movb    $3, %cl
    salb    %cl, %al                 # AL = 0x18
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x03, %ah
    movb    $4, %cl
    salb    %cl, %ah                 # AH = 0x30  (verifies AH is isolated from AL)
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x40, 0x386(%esi)
    salb    $1, 0x386(%esi)
    movb    0x386(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x02, 0x386(%esi)
    movb    $3, %cl
    salb    %cl, 0x386(%esi)
    movb    0x386(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 10 : SAR — arithmetic right shift, all sizes & shift srcs
    # ================================================================

    # SAR r/m32, 1
    movl    $0x80000000, %eax
    sarl    $1, %eax                 # → 0xC0000000
    addl    %eax, %ebx

    movl    $0x40000000, %eax
    sarl    $1, %eax                 # → 0x20000000
    addl    %eax, %ebx

    # SAR r/m32, imm8
    movl    $0x80000000, %eax
    sarl    $4, %eax                 # → 0xF8000000
    addl    %eax, %ebx

    movl    $0x7F000000, %eax
    sarl    $4, %eax                 # → 0x07F00000
    addl    %eax, %ebx

    # SAR r/m32, CL
    movl    $0xFF000000, %eax
    movb    $8, %cl
    sarl    %cl, %eax                # → 0xFFFF0000
    addl    %eax, %ebx

    movl    $0x7FFFFFFF, %eax
    movb    $1, %cl
    sarl    %cl, %eax                # → 0x3FFFFFFF
    addl    %eax, %ebx

    # SAR r/m32 mem
    movl    $0x80000000, 0x388(%esi)
    sarl    $1, 0x388(%esi)
    movl    0x388(%esi), %eax
    addl    %eax, %ebx

    movl    $0xFF000000, 0x388(%esi)
    movb    $8, %cl
    sarl    %cl, 0x388(%esi)
    movl    0x388(%esi), %eax
    addl    %eax, %ebx

    # SAR r/m16
    movw    $0x8000, %ax
    sarw    $1, %ax                  # → 0xC000
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0xF000, %dx
    movb    $4, %cl
    sarw    %cl, %dx                 # → 0xFF00
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0xFF00, 0x38C(%esi)
    sarw    $4, 0x38C(%esi)
    movw    0x38C(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # SAR r/m8 — AH and AL forms
    movb    $0x80, %al
    sarb    $1, %al                  # → 0xC0
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x80, %ah
    sarb    $4, %ah                  # → 0xF8 (verify AH isolated)
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x40, %al
    movb    $1, %cl
    sarb    %cl, %al                 # → 0x20
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0xF0, %ah
    movb    $2, %cl
    sarb    %cl, %ah                 # → 0xFC
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x80, 0x38E(%esi)
    sarb    $1, 0x38E(%esi)          # → 0xC0
    movb    0x38E(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0xC0, 0x38E(%esi)
    movb    $2, %cl
    sarb    %cl, 0x38E(%esi)         # → 0xF0
    movb    0x38E(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 11 : BSF — bit scan forward, r16 / r32, reg & mem
    # ================================================================

    movl    $0x00000001, %eax
    bsfl    %eax, %ecx               # ECX = 0
    addl    %ecx, %ebx

    movl    $0x00000080, %eax
    bsfl    %eax, %ecx               # 7
    addl    %ecx, %ebx

    movl    $0x00008000, %eax
    bsfl    %eax, %ecx               # 15
    addl    %ecx, %ebx

    movl    $0x80000000, %eax
    bsfl    %eax, %ecx               # 31
    addl    %ecx, %ebx

    movl    $0xFFFF0000, %eax
    bsfl    %eax, %ecx               # 16
    addl    %ecx, %ebx

    # BSF reg ← mem
    movl    $0x00010000, 0x400(%esi)
    bsfl    0x400(%esi), %ecx        # 16
    addl    %ecx, %ebx

    movl    $0x00200000, 0x400(%esi)
    bsfl    0x400(%esi), %ecx        # 21
    addl    %ecx, %ebx

    # 16-bit BSF
    movw    $0x0001, %ax
    bsfw    %ax, %dx                 # 0
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x8000, %ax
    bsfw    %ax, %dx                 # 15
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x0F00, %ax
    bsfw    %ax, %dx                 # 8
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x0040, 0x404(%esi)
    bsfw    0x404(%esi), %dx         # 6
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 12 : CMOVC — conditional move if CF=1
    # ================================================================

    # CF=1 path (move taken)
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000002, %eax        # CF=1
    movl    $0xDEADBEEF, %ecx
    movl    $0x00000000, %edx
    cmovcl  %ecx, %edx               # → EDX = 0xDEADBEEF
    addl    %edx, %ebx

    # CF=0 path (no move)
    movl    $0x00000001, %eax
    addl    $0x00000001, %eax        # CF=0
    movl    $0x12345678, %ecx
    movl    $0xABCDABCD, %edx
    cmovcl  %ecx, %edx               # EDX unchanged
    addl    %edx, %ebx

    # CMOVC from memory, CF=1
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000002, %eax
    movl    $0x11223344, 0x408(%esi)
    movl    $0x00000000, %ecx
    cmovcl  0x408(%esi), %ecx        # → 0x11223344
    addl    %ecx, %ebx

    # CMOVC from memory, CF=0
    movl    $0x00000001, %eax
    addl    $0x00000001, %eax
    movl    $0x99887766, 0x408(%esi)
    movl    $0xFEFEFEFE, %ecx
    cmovcl  0x408(%esi), %ecx        # ECX unchanged
    addl    %ecx, %ebx

    # 16-bit CMOVC
    movl    $0xFFFFFFFF, %eax
    addl    $0x00000002, %eax        # CF=1
    movw    $0xBEEF, %cx
    movw    $0x0000, %dx
    cmovcw  %cx, %dx                 # DX = 0xBEEF
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movl    $0x00000001, %eax
    addl    $0x00000001, %eax        # CF=0
    movw    $0xCAFE, %cx
    movw    $0x1234, %dx
    cmovcw  %cx, %dx                 # DX unchanged
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 13 : CMPXCHG — r/m8, r/m16, r/m32 with reg + mem dst
    # ================================================================

    # 32-bit, EAX matches → write
    movl    $0xCAFECAFE, 0x410(%esi)
    movl    $0xCAFECAFE, %eax
    movl    $0x12345678, %ecx
    cmpxchgl %ecx, 0x410(%esi)       # mem ← ECX
    movl    0x410(%esi), %eax
    addl    %eax, %ebx

    # 32-bit, EAX mismatches → EAX ← mem, mem unchanged
    movl    $0xDEADBEEF, 0x410(%esi)
    movl    $0x00000000, %eax
    movl    $0x99999999, %ecx
    cmpxchgl %ecx, 0x410(%esi)
    addl    %eax, %ebx
    movl    0x410(%esi), %eax
    addl    %eax, %ebx

    # 32-bit, register operand (mem-less form)
    movl    $0xAAAA5555, %edx
    movl    $0xAAAA5555, %eax
    movl    $0x0F0F0F0F, %ecx
    cmpxchgl %ecx, %edx              # EDX ← ECX
    addl    %edx, %ebx

    # 16-bit
    movw    $0xBEEF, 0x414(%esi)
    movw    $0xBEEF, %ax
    movw    $0xC0DE, %cx
    cmpxchgw %cx, 0x414(%esi)        # mem ← CX (match)
    movw    0x414(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    movw    $0x1234, 0x416(%esi)
    movw    $0x0000, %ax             # mismatch → AX ← mem
    movw    $0xFFFF, %cx
    cmpxchgw %cx, 0x416(%esi)
    andl    $0xFFFF, %eax
    addl    %eax, %ebx
    movw    0x416(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # 8-bit — exercise AL match/mismatch with AH source
    movb    $0x55, 0x418(%esi)
    movb    $0x55, %al
    movb    $0xAA, %ah
    cmpxchgb %ah, 0x418(%esi)        # mem ← AH on match
    movb    0x418(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x10, 0x419(%esi)
    movb    $0x00, %al               # mismatch
    movb    $0xCC, %ah
    cmpxchgb %ah, 0x419(%esi)        # AL ← mem
    andl    $0xFF, %eax
    addl    %eax, %ebx
    movb    0x419(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # 8-bit register form
    movb    $0x77, %dl
    movb    $0x77, %al
    movb    $0x33, %ch
    cmpxchgb %ch, %dl                # DL ← CH
    movb    %dl, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 14 : XCHG — every form, including AH/AL combos
    # ================================================================

    # XCHG EAX, r32 (90+rd short form)
    movl    $0x0000DEAD, %eax
    movl    $0x0000BEEF, %edi
    xchgl   %eax, %edi
    addl    %eax, %ebx
    addl    %edi, %ebx

    # XCHG r/m32, r32
    movl    $0xAAAAAAAA, %ecx
    movl    $0x55555555, %edx
    xchgl   %ecx, %edx
    addl    %ecx, %ebx
    addl    %edx, %ebx

    # XCHG r/m32, mem
    movl    $0xCAFEBABE, 0x420(%esi)
    movl    $0xDEADC0DE, %eax
    xchgl   %eax, 0x420(%esi)
    addl    %eax, %ebx
    movl    0x420(%esi), %eax
    addl    %eax, %ebx

    # XCHG AX, r16 (short form)
    movw    $0x1111, %ax
    movw    $0x2222, %cx
    xchgw   %ax, %cx
    andl    $0xFFFF, %eax
    addl    %eax, %ebx
    movw    %cx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # XCHG r/m16, mem
    movw    $0xABCD, 0x424(%esi)
    movw    $0x1234, %dx
    xchgw   %dx, 0x424(%esi)
    movw    %dx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx
    movw    0x424(%esi), %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # XCHG r/m8, r8 — AH/AL combos
    movb    $0xAA, %al
    movb    $0x55, %ah
    xchgb   %al, %ah                 # cross-half
    andl    $0xFF, %eax
    addl    %eax, %ebx
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x11, %bl
    movb    $0x22, %al
    xchgb   %al, %bl
    andl    $0xFF, %eax
    addl    %eax, %ebx
    movb    %bl, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    movb    $0x33, %ch
    movb    $0x44, %dh
    xchgb   %ch, %dh
    movb    %ch, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx
    movb    %dh, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # XCHG r/m8, mem (AL with mem)
    movb    $0x77, 0x428(%esi)
    movb    $0xEE, %al
    xchgb   %al, 0x428(%esi)
    andl    $0xFF, %eax
    addl    %eax, %ebx
    movb    0x428(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # XCHG r/m8, mem (AH with mem)
    movb    $0xC3, 0x429(%esi)
    movb    $0x3C, %ah
    xchgb   %ah, 0x429(%esi)
    movb    %ah, %al
    andl    $0xFF, %eax
    addl    %eax, %ebx
    movb    0x429(%esi), %al
    andl    $0xFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 15 : PUSH / POP — registers, immediates, memory
    # ================================================================

    movl    $0x11111111, %eax
    movl    $0x22222222, %ecx
    movl    $0x33333333, %edx

    pushl   %eax                     # PUSH r32
    pushl   %ecx
    pushl   %edx

    popl    %edx                     # POP r32
    popl    %ecx
    popl    %eax

    addl    %eax, %ebx
    addl    %ecx, %ebx
    addl    %edx, %ebx

    # PUSH imm32 / imm8
    pushl   $0xDEAD0001
    pushl   $0xDEAD0002
    pushl   $0x00000077              # imm8 form (sign-extended)
    popl    %eax
    addl    %eax, %ebx
    popl    %eax
    addl    %eax, %ebx
    popl    %eax
    addl    %eax, %ebx

    # PUSH/POP memory operands
    movl    $0xBEEF1234, 0x480(%esi)
    pushl   0x480(%esi)              # PUSH r/m32 (mem)
    popl    0x484(%esi)              # POP r/m32 (mem)
    movl    0x484(%esi), %eax
    addl    %eax, %ebx

    # 16-bit push / pop r16
    pushw   $0xCAFE
    pushw   $0xBABE
    popw    %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx
    popw    %cx
    movw    %cx, %ax
    andl    $0xFFFF, %eax
    addl    %eax, %ebx

    # round-trip ESP-saved EBX
    pushl   %ebx
    movl    $0xDEADDEAD, %ebx
    popl    %ebx                     # restore EBX

    # ================================================================
    # SECTION 16 : MMX — PACK / PADD / PAVG / MOVQ
    # ================================================================

    # ---- PACKSSWB : in-range words → bytes (no saturation) -------
    # mm0 words: [0x0000, 0x0001, 0x007E, 0x007F]  → 0x00,0x01,0x7E,0x7F
    # mm1 words: [0xFF80, 0xFF81, 0xFFFE, 0xFFFF]  → 0x80,0x81,0xFE,0xFF
    movl    $0x00010000, 0x500(%esi)
    movl    $0x007F007E, 0x504(%esi)
    movl    $0xFF81FF80, 0x508(%esi)
    movl    $0xFFFFFFFE, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    packsswb %mm1, %mm0
    movq    %mm0, 0x520(%esi)
    movl    0x520(%esi), %eax
    addl    %eax, %ebx
    movl    0x524(%esi), %eax
    addl    %eax, %ebx

    # ---- PACKSSWB : positive saturate ----------------------------
    movl    $0x00FF0080, 0x500(%esi)
    movl    $0x7FFF0100, 0x504(%esi)
    movl    $0x00000000, 0x508(%esi)
    movl    $0x00000000, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    packsswb %mm1, %mm0
    movq    %mm0, 0x520(%esi)
    movl    0x520(%esi), %eax
    addl    %eax, %ebx

    # ---- PACKSSDW : in-range dwords → words ----------------------
    movl    $0x00001234, 0x510(%esi)
    movl    $0xFFFF8000, 0x514(%esi)
    movl    $0x00007FFF, 0x518(%esi)
    movl    $0xFFFF8001, 0x51C(%esi)
    movq    0x510(%esi), %mm0
    movq    0x518(%esi), %mm1
    packssdw %mm1, %mm0
    movq    %mm0, 0x528(%esi)
    movl    0x528(%esi), %eax
    addl    %eax, %ebx
    movl    0x52C(%esi), %eax
    addl    %eax, %ebx

    # ---- PACKSSDW : positive saturate ----------------------------
    movl    $0x00008000, 0x510(%esi)
    movl    $0x00010000, 0x514(%esi)
    movl    $0x7FFFFFFF, 0x518(%esi)
    movl    $0x00100000, 0x51C(%esi)
    movq    0x510(%esi), %mm0
    movq    0x518(%esi), %mm1
    packssdw %mm1, %mm0
    movq    %mm0, 0x528(%esi)
    movl    0x528(%esi), %eax
    addl    %eax, %ebx

    # ---- PADDW : lane-wise wrap-around ---------------------------
    movl    $0x00100001, 0x500(%esi)
    movl    $0x10000100, 0x504(%esi)
    movl    $0x00100001, 0x508(%esi)
    movl    $0x10000100, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    paddw   %mm1, %mm0
    movq    %mm0, 0x530(%esi)
    movl    0x530(%esi), %eax
    addl    %eax, %ebx
    movl    0x534(%esi), %eax
    addl    %eax, %ebx

    # ---- PADDW : 0xFFFF + 0x0001 = 0x0000 (wrap) -----------------
    movl    $0xFFFFFFFF, 0x500(%esi)
    movl    $0xFFFFFFFF, 0x504(%esi)
    movl    $0x00010001, 0x508(%esi)
    movl    $0x00010001, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    paddw   %mm1, %mm0
    movq    %mm0, 0x530(%esi)
    movl    0x530(%esi), %eax
    addl    %eax, %ebx

    # ---- PADDD : two-lane 32-bit add -----------------------------
    movl    $0x00001234, 0x500(%esi)
    movl    $0x00ABCDEF, 0x504(%esi)
    movl    $0x0000EDCC, 0x508(%esi)
    movl    $0xFF543211, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    paddd   %mm1, %mm0
    movq    %mm0, 0x538(%esi)
    movl    0x538(%esi), %eax
    addl    %eax, %ebx
    movl    0x53C(%esi), %eax
    addl    %eax, %ebx

    # ---- PADDD : 0xFFFFFFFF + 1 = 0 (wrap) -----------------------
    movl    $0xFFFFFFFF, 0x500(%esi)
    movl    $0xFFFFFFFF, 0x504(%esi)
    movl    $0x00000001, 0x508(%esi)
    movl    $0x00000001, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    paddd   %mm1, %mm0
    movq    %mm0, 0x538(%esi)
    movl    0x538(%esi), %eax
    addl    %eax, %ebx

    # ---- PAVGB : per-byte rounding average -----------------------
    movl    $0x10040200, 0x500(%esi)
    movl    $0xFE804020, 0x504(%esi)
    movl    $0x10040200, 0x508(%esi)
    movl    $0xFE804020, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    pavgb   %mm1, %mm0
    movq    %mm0, 0x540(%esi)
    movl    0x540(%esi), %eax
    addl    %eax, %ebx
    movl    0x544(%esi), %eax
    addl    %eax, %ebx

    # ---- PAVGB : avg(0xFF, 0xFF) = 0xFF (no overflow) ------------
    movl    $0xFFFFFFFF, 0x500(%esi)
    movl    $0xFFFFFFFF, 0x504(%esi)
    movl    $0xFFFFFFFF, 0x508(%esi)
    movl    $0xFFFFFFFF, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    pavgb   %mm1, %mm0
    movq    %mm0, 0x540(%esi)
    movl    0x540(%esi), %eax
    addl    %eax, %ebx

    # ---- PAVGW : per-word rounding average -----------------------
    movl    $0x01000000, 0x500(%esi)
    movl    $0xFFFE8000, 0x504(%esi)
    movl    $0x01000000, 0x508(%esi)
    movl    $0xFFFE8000, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    pavgw   %mm1, %mm0
    movq    %mm0, 0x548(%esi)
    movl    0x548(%esi), %eax
    addl    %eax, %ebx
    movl    0x54C(%esi), %eax
    addl    %eax, %ebx

    # ---- PAVGW : avg(0xFFFF, 0xFFFF) = 0xFFFF -------------------
    movl    $0xFFFFFFFF, 0x500(%esi)
    movl    $0xFFFFFFFF, 0x504(%esi)
    movl    $0xFFFFFFFF, 0x508(%esi)
    movl    $0xFFFFFFFF, 0x50C(%esi)
    movq    0x500(%esi), %mm0
    movq    0x508(%esi), %mm1
    pavgw   %mm1, %mm0
    movq    %mm0, 0x548(%esi)
    movl    0x548(%esi), %eax
    addl    %eax, %ebx

    # MOVQ mm/m64 ↔ mm  identity round-trip
    movl    $0xCAFEBABE, 0x550(%esi)
    movl    $0xDEADBEEF, 0x554(%esi)
    movq    0x550(%esi), %mm0
    movq    %mm0, 0x558(%esi)
    movl    0x558(%esi), %eax
    addl    %eax, %ebx
    movl    0x55C(%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 17 : //MOVS / //REP //MOVS / //REPE CMPS
    # DS:[ESI] → ES:[EDI]  (ES = DS, so both inside the data page)
    # ================================================================

    # Set up source data at 0x600..0x61F (8 dwords)
    movl    $0xAABBCCDD, 0x600(%esi)
    movl    $0x11223344, 0x604(%esi)
    movl    $0x55667788, 0x608(%esi)
    movl    $0x99AABBCC, 0x60C(%esi)
    movl    $0xDDEEFF00, 0x610(%esi)
    movl    $0xCAFEBABE, 0x614(%esi)
    movl    $0xDEADBEEF, 0x618(%esi)
    movl    $0x12345678, 0x61C(%esi)

    cld                              # ensure DF=0 (forward)

    # Single ////MOVSL — copies one dword DS:[ESI] → ES:[EDI]
    movl    $0x600, %esi
    movl    $0x700, %edi
    //movsl
    movl    $0x0, %esi               # restore ESI for further ESI-relative tests
    movl    0x700(%esi), %eax
    addl    %eax, %ebx

    # //REP //MOVSL — copy 8 dwords
    movl    $0x600, %esi
    movl    $0x710, %edi
    movl    $8, %ecx
   // //rep //movsl                        # 32 bytes copied
    movl    $0x0, %esi
    movl    0x710(%esi), %eax
    addl    %eax, %ebx
    movl    0x72C(%esi), %eax        # last dword copied
    addl    %eax, %ebx

    # //REP B — copy 8 bytes
    movl    $0x600, %esi
    movl    $0x740, %edi
    movl    $8, %ecx
    ////rep //movsb
    movl    $0x0, %esi
    movl    0x740(%esi), %eax
    addl    %eax, %ebx

    # //REP //MOVSW — copy 4 words
    movl    $0x600, %esi
    movl    $0x750, %edi
    movl    $4, %ecx
    ////rep //movsw
    movl    $0x0, %esi
    movl    0x750(%esi), %eax
    addl    %eax, %ebx

    # //REP //MOVSL with STD (reverse direction)
    std
    movl    $0x61C, %esi             # last dword of src
    movl    $0x76C, %edi             # last dword of dst
    movl    $4, %ecx
    ////rep //movsl
    cld
    movl    $0x0, %esi
    movl    0x760(%esi), %eax        # should equal source DS:0x610 = 0xDDEEFF00
    addl    %eax, %ebx

    # //REPE CMPSL — full match (src == prior dst)
    movl    $0x600, %esi
    movl    $0x710, %edi
    movl    $8, %ecx
    //repe cmpsl
    movl    $0x0, %esi
    addl    %ecx, %ebx               # ECX should be 0 on full match

    # //REPE CMPSL — mismatch on first dword
    movl    $0xFFFFFFFF, 0x710(%esi) # corrupt first dword of dst
    movl    $0x600, %esi
    movl    $0x710, %edi
    movl    $8, %ecx
    //repe cmpsl
    movl    $0x0, %esi
    addl    %ecx, %ebx               # ECX should be 7 (one compare consumed)

    # ================================================================
    # SECTION 18 : CLD / STD — direction-flag round-trip
    # ================================================================

    cld                              # DF = 0
    movl    $0xCAFEBABE, 0x780(%esi)
    movl    0x780(%esi), %eax
    addl    %eax, %ebx

    std                              # DF = 1 (does not affect plain mov)
    movl    $0xDEADBEEF, 0x784(%esi)
    movl    0x784(%esi), %eax
    addl    %eax, %ebx
    cld                              # restore DF=0

    # ================================================================
    # END
    # ================================================================
    movb    $0, %ah
    movb    %ah, %al
    movw    %ax, %ss
    hlt

# ================================================================
# Data page — VPN 0x40020 → PFN 7
# ================================================================
.org 0x40020000
.data
    .long 0x11223344

# ================================================================
# Stack page — VPN 0xF0000 → PFN 4
# ================================================================
.org 0xF0000000
.data
    .long 0x55667788
