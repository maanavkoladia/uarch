.org 0x1000
.code
.global _start

_start:

# ============================================================
# BASE SETUP (SAFE ADDRESS SPACE + DIRTY REG STATE)
# ============================================================

    mov $data_page, %esi

    and $0x0FFF, %esi
    and $0x0F, %ebx
    and $0x0F, %ecx
    and $0x0F, %edx

    mov $0xFFFF0000, %eax
    mov $0xAAAAFFFF, %ebx
    mov $0x12340000, %ecx
    mov $0x0000FFFF, %edx

# ============================================================
# IMM -> REG (AND / OR MIX)
# ============================================================

    or  $0x11, %al
    and $0xFE, %al

    or  $0x22, %ah
    and $0xFD, %ah

    or  $0x33, %bl
    and $0xEE, %bl

    or  $0x44, %bh
    and $0xDD, %bh

# ============================================================
# REG -> REG LOGIC
# ============================================================

    or  %ebx, %eax
    and %ecx, %eax

    or  %edx, %ebx
    and %eax, %ebx

    or  %eax, %ecx
    and %ebx, %ecx

# ============================================================
# MEMORY (32-bit SAFE RMW)
# ============================================================

    mov %esi, %edi

    or  %eax, (%edi)
    and %ebx, (%edi)

    add $4, %edi
    or  %ecx, (%edi)
    and %edx, (%edi)

    add $4, %edi
    or  %eax, (%edi)
    and %ecx, (%edi)

# ============================================================
# MEMORY (16-bit SAFE)
# ============================================================

    mov %esi, %edi
    add $8, %edi

    or  %ax, (%edi)
    and %bx, (%edi)

# ============================================================
# BYTE MEMORY (AL / AH)
# ============================================================

    mov %esi, %edi

    or  (%edi), %al
    and (%edi), %al

    add $1, %edi

    or  (%edi), %ah
    and (%edi), %ah

    mov %esi, %edi

    or  %al, (%edi)
    and %ah, (%edi)

# ============================================================
# CROSS BYTE LOGIC
# ============================================================

    or  %al, %ah
    and %ah, %al

    or  %bl, %bh
    and %bh, %bl

# ============================================================
# FULL REGISTER MERGE VALIDATION
# ============================================================

    mov $0x12345678, %eax
    or  $0x000000FF, %al
    and $0xFFFFFF00, %eax

    mov $0x12345678, %eax
    or  $0x0000FF00, %ax
    and $0xFFFF00FF, %eax

# ============================================================
# NOT TESTS (EXPLICIT WIDTHS)
# ============================================================

    notl %eax
    notl %ebx
    notl %ecx
    notl %edx

    notw %ax
    notw %bx
    notw %cx
    notw %dx

    notb %al
    notb %ah
    notb %bl
    notb %bh

# ============================================================
# MEMORY NOT (SAFE RMW)
# ============================================================

    mov %esi, %edi
    notl (%edi)

    add $4, %edi
    notl (%edi)

    add $4, %edi
    notl (%edi)

# byte-level NOT
    mov %esi, %edi
    notb (%edi)

    add $1, %edi
    notb (%edi)

# ============================================================
# INDEXED ADDRESSING (SAFE + BOUNDED)
# ============================================================

    mov %esi, %edi

    and $0x0F, %ebx
    or  (%edi,%ebx,1), %eax
    and (%edi,%ebx,1), %eax

    and $0x0F, %ecx
    or  %eax, (%edi,%ecx,1)
    and %eax, (%edi,%ecx,1)

# ============================================================
# FINAL EDGE STRESS
# ============================================================

    or  $0xFF, %al
    and $0x00, %al
    notb %al

    orl $0xFFFFFFFF, %eax
    andl $0x00000000, %eax
    notl %eax

# ============================================================
# DONE
# ============================================================

    hlt

# ============================================================
# DATA (UNCHANGED SAFE REGION)
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