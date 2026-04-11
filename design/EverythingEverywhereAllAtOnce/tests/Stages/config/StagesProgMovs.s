.org 0x1000
    .code

    .global _start
_start:

    # ----------------------------------------
    # B2: MOV DL, imm8
    # opcode B2
    # ----------------------------------------
    movb $0x7F, %dl

    # ----------------------------------------
    # 89: MOV r/m32, r32
    # EBX -> ECX
    # opcode 89
    # ----------------------------------------
    movl %ebx, %ecx

    # ----------------------------------------
    # 8C: MOV r/m16, Sreg
    # Move DS into AX
    # opcode 8C
    # ----------------------------------------
    movw %ds, %ax

    # ----------------------------------------
    # 8E: MOV Sreg, r/m16
    # Move AX into ES
    # opcode 8E
    # ----------------------------------------
    movw %ax, %es

    # ----------------------------------------
    # 89 with memory operand
    # [EDI + EDX*2 + disp]
    # ----------------------------------------
    movl %eax, 0x5678(%edi,%edx,2)

    # ----------------------------------------
    # E9: JMP rel32
    # Jump forward to label target
    # ----------------------------------------
    jmp target

    # some filler instructions (won’t execute)
    movl %eax, %eax
    movl %ebx, %ebx

target:
    addl %edi, %ebx

    hlt


.org 0x5670
    .data
val_1:  .long  0x11111111
val_2:  .long  0x22222222
val_a:  .long  0xAABBCCDD
val_b:  .long  0xBEEFDEAD