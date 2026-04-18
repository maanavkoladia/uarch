.org 0x1000
.code
.global _start

_start:

# ============================================================
# BASE SETUP
# ============================================================

    mov $data_page, %esi    # canonical base pointer

# preload general regs with non-trivial values
    mov $0xFFFFFFFF, %eax
    mov $0xAAAAAAAA, %ebx
    mov $0x12345678, %ecx
    mov $0x0F0F0F0F, %edx

# ============================================================
# IMM -> REG
# ============================================================

    and $0xF0, %al
    and $0x0FF0, %ax
    andl $0x00FF00FF, %eax

# ============================================================
# IMM -> MEM (SAFE)
# ============================================================

    mov %esi, %edi
    andb $0x0F, (%edi)

    mov %esi, %edi
    add $4, %edi
    andw $0x00FF, (%edi)

    mov %esi, %edi
    add $8, %edi
    andl $0x0000FFFF, (%edi)

# ============================================================
# REG -> REG
# ============================================================

    and %ebx, %eax
    and %ecx, %ebx
    and %edx, %ecx

# ============================================================
# REG -> MEM (SAFE)
# ============================================================

    mov %esi, %edi
    and %eax, (%edi)

    mov %esi, %edi
    add $4, %edi
    and %ebx, (%edi)

    mov %esi, %edi
    add $8, %edi
    and %ecx, (%edi)

# ============================================================
# MEM -> REG (SAFE)
# ============================================================

    mov %esi, %edi
    and (%edi), %eax

    mov %esi, %edi
    add $4, %edi
    and (%edi), %ecx

    mov %esi, %edi
    add $8, %edi
    and (%edi), %edx

# ============================================================
# BYTE OPS (AL / AH / MEM8)
# ============================================================

    mov %esi, %edi
    and (%edi), %al

    mov %esi, %edi
    add $1, %edi
    and (%edi), %ah

    mov %esi, %edi
    and %al, (%edi)

    mov %esi, %edi
    add $1, %edi
    and %ah, (%edi)

# reg ↔ reg (8-bit)
    and %bl, %al
    and %bh, %ah
    and %al, %bl
    and %ah, %bh

# ============================================================
# WORD OPS (16-bit)
# ============================================================

    and %bx, %ax
    and %cx, %dx

    mov %esi, %edi
    and %ax, (%edi)

    mov %esi, %edi
    and (%edi), %dx

# ============================================================
# DWORD OPS (32-bit)
# ============================================================

    and %eax, %ebx
    and %ecx, %edx

    mov %esi, %edi
    and %eax, (%edi)

    mov %esi, %edi
    and (%edi), %edx

# ============================================================
# SAFE "AGU-LIKE" VARIATION (NO FAULT POSSIBLE)
# ============================================================

    mov %esi, %edi
    add $0x10, %edi
    and (%edi), %al

    mov %esi, %edi
    add $0x20, %edi
    and %al, (%edi)

# ============================================================
# EDGE CASES (AH / AL CROSS)
# ============================================================

    and %ah, %al
    and %al, %ah

    mov %esi, %edi
    and %ah, (%edi)

    mov %esi, %edi
    and (%edi), %al

# ============================================================
# DONE
# ============================================================

    hlt


# ============================================================
# DATA (ONE PAGE ONLY: 0x2000–0x2FFF)
# ============================================================

.org 0x2000
.data

data_page:
    .long 0x11111111
    .long 0x22222222
    .long 0x33333333
    .long 0x44444444
    .long 0x55555555
    .long 0x66666666
    .long 0x77777777
    .long 0x88888888

    .long 0xAAAAAAAA
    .long 0xBBBBBBBB
    .long 0xCCCCCCCC
    .long 0xDDDDDDDD