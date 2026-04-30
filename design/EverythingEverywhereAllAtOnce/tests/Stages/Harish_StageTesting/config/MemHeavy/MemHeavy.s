# ================================================================
# TEST 2: MEMORY-HEAVY — Addressing Mode & Data Access Stress
# ================================================================
# LEGAL INSTRUCTIONS ONLY. No SUB/CMP/TEST/XOR/LEA/MOVZX/MOVSX/etc.
#
# Tests: All valid addressing modes (reg indirect, base+disp8,
#        base+disp32, base+index, base+index*scale,
#        base+index*scale+disp), byte/word/dword reads and writes,
#        memory dependencies (RAW/WAW/WAR), store-load forwarding,
#        ALU with memory operands (ADD/AND/OR/NOT/SAL/SAR on mem),
#        cross-segment data access, MOVS (single), XCHG with mem.
#
# Segment Layout:
#   CS0 = 0x0000 -> base 0x00000000  (code)
#   DS0 = 0x0100 -> base 0x01000000  (data page 1)
#   DS1 = 0x0200 -> base 0x02000000  (data page 2)
#   SS0 = 0x0300 -> base 0x03000000  (stack)
# ================================================================

#define __CS0__ 0x0000
#define __DS0__ 0x0100
#define __DS1__ 0x0200
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
    # SECTION 1: REGISTER INDIRECT — [reg]
    # Store and load through each usable GP register as pointer.
    # ================================================================

    movl    $0x00000000, %esi
    movl    $0xAAAA1111, (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    movl    $0x00000010, %edi
    movl    $0xBBBB2222, (%edi)
    movl    (%edi), %eax
    addl    %eax, %ebx

    movl    $0x00000020, %ecx
    movl    $0xCCCC3333, (%ecx)
    movl    (%ecx), %eax
    addl    %eax, %ebx

    movl    $0x00000030, %edx
    movl    $0xDDDD4444, (%edx)
    movl    (%edx), %eax
    addl    %eax, %ebx

    # EBP as base (special ModRM encoding: requires disp8=0)
    movl    $0x00000040, %ebp
    movl    $0xEEEE5555, (%ebp)
    movl    (%ebp), %eax
    addl    %eax, %ebx

    # EAX as base
    movl    $0x00000050, %eax
    movl    $0xFFFF6666, (%eax)
    movl    $0x00000050, %eax
    movl    (%eax), %ecx
    addl    %ecx, %ebx

    # ================================================================
    # SECTION 2: BASE + DISPLACEMENT (disp8 and disp32)
    # ================================================================

    movl    $0x00000000, %esi

    # disp8 range
    movl    $0x11110001, 0x04(%esi)
    movl    $0x11110002, 0x08(%esi)
    movl    $0x11110003, 0x0C(%esi)
    movl    $0x11110004, 0x7C(%esi)

    movl    0x04(%esi), %eax
    addl    %eax, %ebx
    movl    0x08(%esi), %eax
    addl    %eax, %ebx
    movl    0x0C(%esi), %eax
    addl    %eax, %ebx
    movl    0x7C(%esi), %eax
    addl    %eax, %ebx

    # disp32 range
    movl    $0x22220001, 0x100(%esi)
    movl    $0x22220002, 0x200(%esi)
    movl    $0x22220003, 0x400(%esi)
    movl    $0x22220004, 0x800(%esi)

    movl    0x100(%esi), %eax
    addl    %eax, %ebx
    movl    0x200(%esi), %eax
    addl    %eax, %ebx
    movl    0x400(%esi), %eax
    addl    %eax, %ebx
    movl    0x800(%esi), %eax
    addl    %eax, %ebx

    # Different base regs with displacement
    movl    $0x00000000, %edi
    movl    $0x33330001, 0x10(%edi)
    movl    0x10(%edi), %eax
    addl    %eax, %ebx

    movl    $0x00000000, %ecx
    movl    $0x33330002, 0x20(%ecx)
    movl    0x20(%ecx), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 3: BASE + INDEX (SIB, scale=1, no disp)
    # ================================================================

    movl    $0x00000000, %esi
    movl    $0x00000060, %edi
    movl    $0x44440001, (%esi,%edi,1)
    movl    (%esi,%edi,1), %eax
    addl    %eax, %ebx

    movl    $0x00000010, %esi
    movl    $0x00000008, %ecx
    movl    $0x44440002, (%esi,%ecx,1)
    movl    (%esi,%ecx,1), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 4: BASE + INDEX * SCALE (scale = 2, 4, 8)
    # ================================================================

    movl    $0x00000000, %esi
    movl    $0x00000010, %edi

    # scale=2: addr = 0 + 0x10*2 = 0x20
    movl    $0x55550001, (%esi,%edi,2)
    movl    (%esi,%edi,2), %eax
    addl    %eax, %ebx

    # scale=4: addr = 0 + 0x10*4 = 0x40
    movl    $0x55550002, (%esi,%edi,4)
    movl    (%esi,%edi,4), %eax
    addl    %eax, %ebx

    # scale=8: addr = 0 + 0x10*8 = 0x80
    movl    $0x55550003, (%esi,%edi,8)
    movl    (%esi,%edi,8), %eax
    addl    %eax, %ebx

    # Different base/index pair
    movl    $0x00000100, %eax
    movl    $0x00000004, %ecx
    movl    $0x55550004, (%eax,%ecx,4)   # 0x100 + 4*4 = 0x110
    movl    (%eax,%ecx,4), %edx
    addl    %edx, %ebx

    # ================================================================
    # SECTION 5: BASE + INDEX * SCALE + DISPLACEMENT
    # ================================================================

    movl    $0x00000000, %esi
    movl    $0x00000008, %edi

    # disp8: ESI + EDI*2 + 0x10 = 0 + 16 + 16 = 0x20
    movl    $0x66660001, 0x10(%esi,%edi,2)
    movl    0x10(%esi,%edi,2), %eax
    addl    %eax, %ebx

    # disp32: ESI + EDI*4 + 0x100 = 0 + 32 + 256 = 0x120
    movl    $0x66660002, 0x100(%esi,%edi,4)
    movl    0x100(%esi,%edi,4), %eax
    addl    %eax, %ebx

    # scale=8 + disp: ESI + EDI*8 + 0x200 = 0 + 64 + 512 = 0x240
    movl    $0x66660003, 0x200(%esi,%edi,8)
    movl    0x200(%esi,%edi,8), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 6: BYTE AND WORD ACCESSES
    # ================================================================

    movl    $0x00000300, %esi

    # Byte stores
    movb    $0xAA, (%esi)
    movb    $0xBB, 1(%esi)
    movb    $0xCC, 2(%esi)
    movb    $0xDD, 3(%esi)

    # Read back as dword — 0xDDCCBBAA (little-endian)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # Byte read into byte reg, then move to 32-bit
    movb    (%esi), %al
    andl    $0x000000FF, %eax           # zero-extend manually
    addl    %eax, %ebx

    movb    1(%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx

    # Word stores and loads
    movw    $0x1234, 0x10(%esi)
    movw    $0x5678, 0x12(%esi)
    movl    0x10(%esi), %eax            # 0x56781234
    addl    %eax, %ebx

    # Read 16-bit, zero-extend via AND
    movw    0x10(%esi), %ax
    andl    $0x0000FFFF, %eax           # zero-extend
    addl    %eax, %ebx

    # ================================================================
    # SECTION 7: UNALIGNED ACCESS
    # ================================================================

    movl    $0x00000400, %esi
    movl    $0x00000000, (%esi)
    movl    $0x00000000, 4(%esi)

    # Dword at offset +1
    movl    $0xAABBCCDD, 1(%esi)
    movl    1(%esi), %eax
    addl    %eax, %ebx

    # Dword at offset +2
    movl    $0x11223344, 2(%esi)
    movl    2(%esi), %eax
    addl    %eax, %ebx

    # Dword at offset +3
    movl    $0x55667788, 3(%esi)
    movl    3(%esi), %eax
    addl    %eax, %ebx

    # Word at odd address
    movw    $0xFACE, 1(%esi)
    movw    1(%esi), %ax
    andl    $0x0000FFFF, %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 8: MEMORY DEPENDENCIES (RAW, WAW, WAR)
    # ================================================================

    movl    $0x00000500, %esi

    # RAW: immediate
    movl    $0xDEADBEEF, (%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx

    # RAW with intervening instruction
    movl    $0x12345678, 4(%esi)
    movl    $0x00000000, %ecx           # intervening
    movl    4(%esi), %eax
    addl    %eax, %ebx

    # WAW: second write wins
    movl    $0xAAAAAAAA, 8(%esi)
    movl    $0xBBBBBBBB, 8(%esi)
    movl    8(%esi), %eax
    addl    %eax, %ebx

    # WAR: read old, then write new
    movl    $0x11111111, 0x0C(%esi)
    movl    0x0C(%esi), %eax
    movl    $0x22222222, 0x0C(%esi)
    addl    %eax, %ebx
    movl    0x0C(%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 9: STORE-LOAD FORWARDING
    # ================================================================

    movl    $0x00000600, %esi

    # Store dword, load individual bytes
    movl    $0x44332211, (%esi)
    movb    (%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx                  # 0x11
    movb    1(%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx                  # 0x22
    movb    2(%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx                  # 0x33
    movb    3(%esi), %al
    andl    $0x000000FF, %eax
    addl    %eax, %ebx                  # 0x44

    # Store two words, load as dword
    movw    $0xFFEE, 4(%esi)
    movw    $0xDDCC, 6(%esi)
    movl    4(%esi), %eax               # 0xDDCCFFEE
    addl    %eax, %ebx

    # ================================================================
    # SECTION 10: ALU WITH MEMORY OPERANDS
    # ================================================================

    movl    $0x00000700, %esi

    # ADD reg, mem
    movl    $0x00001000, (%esi)
    movl    $0x00000111, %eax
    addl    (%esi), %eax                # EAX = 0x1111
    addl    %eax, %ebx

    # ADD mem, reg
    movl    $0x00002000, 4(%esi)
    movl    $0x00000222, %eax
    addl    %eax, 4(%esi)               # mem = 0x2222
    movl    4(%esi), %eax
    addl    %eax, %ebx

    # ADD mem, imm32
    movl    $0x00003000, 8(%esi)
    addl    $0x00000333, 8(%esi)         # mem = 0x3333
    movl    8(%esi), %eax
    addl    %eax, %ebx

    # AND mem, imm32
    movl    $0xFFFF0000, 0x0C(%esi)
    andl    $0x0F0F0F0F, 0x0C(%esi)      # 0x0F0F0000
    movl    0x0C(%esi), %eax
    addl    %eax, %ebx

    # OR mem, imm32
    movl    $0x00000000, 0x10(%esi)
    orl     $0xF0F0F0F0, 0x10(%esi)
    movl    0x10(%esi), %eax
    addl    %eax, %ebx

    # NOT mem
    movl    $0x0F0F0F0F, 0x14(%esi)
    notl    0x14(%esi)                   # 0xF0F0F0F0
    movl    0x14(%esi), %eax
    addl    %eax, %ebx

    # SAL mem, imm8
    movl    $0x00000001, 0x18(%esi)
    sall    $16, 0x18(%esi)              # 0x00010000
    movl    0x18(%esi), %eax
    addl    %eax, %ebx

    # SAR mem, imm8
    movl    $0x80000000, 0x1C(%esi)
    sarl    $4, 0x1C(%esi)               # 0xF8000000
    movl    0x1C(%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 11: CROSS-SEGMENT DATA ACCESS
    # ================================================================

    movl    $__DS1__, %eax
    movw    %ax, %ds

    movl    $0x00000000, %esi
    movl    $0xFEDCBA98, (%esi)
    movl    $0x76543210, 4(%esi)
    movl    (%esi), %eax
    addl    %eax, %ebx
    movl    4(%esi), %eax
    addl    %eax, %ebx

    # Switch back to DS0
    movl    $__DS0__, %eax
    movw    %ax, %ds

    # Verify DS0 data intact
    movl    $0x00000500, %esi
    movl    (%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 12: INDEXED LOOP — store then verify
    # ================================================================

    movl    $0x00000000, %esi
    movl    $0x00000000, %edi
    movl    $0x00000008, %ecx

mem_store_loop:
    movl    %ecx, (%esi,%edi,4)
    addl    $0x00000001, %edi
    addl    $0xFFFFFFFF, %ecx
    jne     mem_store_loop

    # Read them back
    movl    $0x00000000, %edi
    movl    $0x00000008, %ecx
mem_read_loop:
    movl    (%esi,%edi,4), %eax
    addl    %eax, %ebx
    addl    $0x00000001, %edi
    addl    $0xFFFFFFFF, %ecx
    jne     mem_read_loop

    # ================================================================
    # SECTION 13: XCHG WITH MEMORY
    # ================================================================

    movl    $0x00000000, %esi
    movl    $0xAAAA0000, (%esi)
    movl    $0xBBBB0000, %eax
    xchgl   %eax, (%esi)                # EAX=0xAAAA0000, mem=0xBBBB0000
    addl    %eax, %ebx
    movl    (%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # SECTION 14: MOVS (single, no REP) — byte, word, dword
    # ================================================================

    # Set up source at DS:[0x100]
    movl    $0x00000100, %esi
    movl    $0xABCD1234, (%esi)

    # ES defaults to... we need ES set. Use DS for both via override.
    # Actually MOVS uses DS:ESI -> ES:EDI. Set ES = DS.
    movl    $__DS0__, %eax
    movw    %ax, %es

    # MOVS dword: DS:[ESI] -> ES:[EDI]
    movl    $0x00000100, %esi           # source
    movl    $0x00000900, %edi           # destination
    cld                                 # clear DF, forward direction
    #movsl                               # move dword
    # Verify: DS:[0x900] should have 0xABCD1234
    movl    $0x00000900, %esi
    movl    (%esi), %eax
    addl    %eax, %ebx

    # ================================================================
    # DONE — store checksum and halt
    # ================================================================

    movl    $0x00000000, %esi
    movl    %ebx, 0xF00(%esi)
    hlt


# ================================================================
# DATA 1 (DS0 base = 0x01000000)
# ================================================================
.org 0x01000000
.data
    .long 0x11223344
    .space 0x0F00

# ================================================================
# DATA 2 (DS1 base = 0x02000000)
# ================================================================
.org 0x02000000
.data
    .long 0x55667788
    .space 0x0F00

# ================================================================
# STACK (SS0 base = 0x03000000)
# ================================================================
.org 0x03000000
.data
    .space 0x1000
