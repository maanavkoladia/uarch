.org 0x1000
.code
.global _start

_start:

# ============================================================
# BASE SETUP
# ============================================================

    mov $data_page, %esi        # ESI = base of writable data page

# ============================================================
# AAA — ASCII Adjust AL After Addition  (opcode 37)
#
# Standard BCD pattern: add two unpacked BCD digits into AL,
# then call AAA to fix up the result.
# ============================================================

# ---- Case 1: low nibble of AL > 9 → adjust (CF=AF=1) ----
# 9 + 5 = 0x0E; AL & 0xF = 0xE > 9 → adjust
# AX = 0x000E + 0x106 = 0x0114; AL = 0x14 & 0xF = 0x04; AH = 0x01
# Expected: AL = 0x04, AH = 0x01, CF=1, AF=1

    mov    $0x0000, %ax
    mov    $0x09,   %al
    add    $0x05,   %al         # AL = 0x0E  (low nibble > 9)
    aaa                         # → AL = 0x04, AH = 0x01, CF=1, AF=1

# ---- Case 2: low nibble ≤ 9, AF=0 → no adjust (CF=AF=0) ----
# 2 + 3 = 0x05; nibble = 5 ≤ 9, AF=0 → pass through unchanged
# Expected: AL = 0x05, AH = 0x00, CF=0, AF=0

    mov    $0x0000, %ax
    mov    $0x02,   %al
    add    $0x03,   %al         # AL = 0x05
    aaa                         # → AL = 0x05, AH = 0x00, CF=0, AF=0

# ---- Case 3: nibble overflow sets AF=1, forces adjust ----
# 9 + 9 = 18 = 0x12; nibble: 9+9 = 18 > 15 so AF=1
# Low nibble of AL = 2 (≤ 9), but AF=1 still triggers adjust
# AX = 0x0012 + 0x106 = 0x0118; AL = 0x18 & 0xF = 0x08; AH = 0x01
# Expected: AL = 0x08, AH = 0x01, CF=1, AF=1

    mov    $0x0000, %ax
    mov    $0x09,   %al
    add    $0x09,   %al         # AL = 0x12, AF=1 (nibble carry)
    aaa                         # → AL = 0x08, AH = 0x01, CF=1, AF=1

# ---- Case 4: AH pre-loaded with carry-in from prior digit ----
# AH=1 (prior digit carry), 7 + 6 = 0x0D (low nibble > 9) → adjust
# AX = 0x010D + 0x106 = 0x0213; AL = 0x13 & 0xF = 0x03; AH = 0x02
# Expected: AL = 0x03, AH = 0x02, CF=1, AF=1

    movw   $0x0100, %ax         # AH = 0x01, AL = 0x00
    mov    $0x07,   %al
    add    $0x06,   %al         # AL = 0x0D
    aaa                         # → AL = 0x03, AH = 0x02, CF=1, AF=1

# ============================================================
# ADC — imm32 → REG  (opcode 81 /2)
# Large immediate (> 0x7F) forces the 81 encoding.
# Helper: "and %reg, %reg" clears CF without changing the register.
#         "add $1, %ecx" with ECX=0xFFFFFFFF generates CF=1.
# ============================================================

# CF=0: 0x10000000 + 0x20000001 + 0 = 0x30000001
    mov    $0x10000000, %eax
    and    %eax, %eax           # clear CF (AND always clears CF/OF)
    adcl   $0x20000001, %eax    # EAX = 0x30000001, CF=0

# CF=1: 0x00000001 + 0x20000001 + 1 = 0x20000003
    and    %ecx, %ecx           # clear CF
    mov    $0xFFFFFFFF, %ecx
    add    $0x00000001, %ecx    # ECX = 0, CF=1
    mov    $0x00000001, %eax
    adcl   $0x20000001, %eax    # EAX = 0x20000003

# Carry-out: 0xE0000000 + 0x30000001 + 0 = 0x10000001, CF=1
    mov    $0xE0000000, %eax
    and    %eax, %eax           # clear CF
    adcl   $0x30000001, %eax    # EAX = 0x10000001, CF=1

# ============================================================
# ADC — imm8 → REG  (opcode 83 /2)
# Small immediate (fits in signed 8-bit: −128..127) → 83 encoding.
# Sign-extended to 32 bits before the add.
# ============================================================

# CF=0: 0x00001000 + 5 + 0 = 0x00001005
    mov    $0x00001000, %eax
    and    %eax, %eax           # clear CF
    adcl   $5, %eax             # EAX = 0x1005

# CF=1: 0x00001000 + 5 + 1 = 0x00001006
    and    %ecx, %ecx           # clear CF
    mov    $0xFFFFFFFF, %ecx
    add    $0x00000001, %ecx    # CF=1
    mov    $0x00001000, %eax
    adcl   $5, %eax             # EAX = 0x1006

# Negative imm8 sign-extended ($-1 → 0xFFFFFFFF), CF=0:
# 0x00000010 + 0xFFFFFFFF + 0 = 0x0000000F, CF=1
    mov    $0x00000010, %eax
    and    %eax, %eax           # clear CF
    adcl   $-1, %eax            # EAX = 0x0000000F, CF=1

# ============================================================
# ADC — REG → R/M32  (opcode 11 /r)
# AT&T:  adcl %r32, r/m32  — r32 is source, r/m32 is destination
# ============================================================

# Reg-to-reg, CF=0: EBX = 0x20 + 0x10 + 0 = 0x30
    mov    $0x00000010, %eax
    mov    $0x00000020, %ebx
    and    %ecx, %ecx           # clear CF
    adcl   %eax, %ebx           # EBX = 0x30

# Reg-to-reg, CF=1: EBX = 0x20 + 0x10 + 1 = 0x31
    and    %ecx, %ecx           # clear CF
    mov    $0xFFFFFFFF, %ecx
    add    $0x00000001, %ecx    # CF=1
    mov    $0x00000010, %eax
    mov    $0x00000020, %ebx
    adcl   %eax, %ebx           # EBX = 0x31

# Reg-to-mem, CF=0: mem[data_page] = 0x01 + 0x10 + 0 = 0x11
    mov    $0x00000001, %eax
    mov    %eax, (%esi)         # mem[0] = 0x01
    mov    $0x00000010, %ebx
    and    %ecx, %ecx           # clear CF
    adcl   %ebx, (%esi)         # mem[0] = 0x11

# Reg-to-mem, CF=1: mem[data_page] = 0x01 + 0x10 + 1 = 0x12
    and    %ecx, %ecx           # clear CF
    mov    $0xFFFFFFFF, %ecx
    add    $0x00000001, %ecx    # CF=1
    mov    $0x00000001, %eax
    mov    %eax, (%esi)         # mem[0] = 0x01
    mov    $0x00000010, %ebx
    adcl   %ebx, (%esi)         # mem[0] = 0x12

# ============================================================
# ADC — R/M32 → REG  (opcode 13 /r)
# AT&T:  adcl r/m32, %r32  — r/m32 is source, r32 is destination
# ============================================================

# Mem-to-reg, CF=0: EAX = 0x100 + 5 + 0 = 0x105
    mov    $0x00000005, %ebx
    mov    %ebx, (%esi)         # mem[0] = 5
    mov    $0x00000100, %eax
    and    %eax, %eax           # clear CF
    adcl   (%esi), %eax         # EAX = 0x105

# Mem-to-reg, CF=1: EAX = 0x100 + 5 + 1 = 0x106
    and    %ecx, %ecx           # clear CF
    mov    $0xFFFFFFFF, %ecx
    add    $0x00000001, %ecx    # CF=1
    mov    $0x00000005, %ebx
    mov    %ebx, (%esi)         # mem[0] = 5
    mov    $0x00000100, %eax
    adcl   (%esi), %eax         # EAX = 0x106

# Reg-to-reg via r/m32 encoding, CF=0: EAX = 0x100 + 0x200 + 0 = 0x300
    mov    $0x00000100, %eax
    mov    $0x00000200, %ebx
    and    %eax, %eax           # clear CF
    adcl   %ebx, %eax           # EAX = 0x300

# ============================================================
# DONE
# ============================================================

    hlt

# ============================================================
# DATA — writable scratch area for memory operand tests
# ============================================================

.org 0x2000
.data

data_page:
    .long 0x00000000
    .long 0x00000000
    .long 0x00000000
    .long 0x00000000
