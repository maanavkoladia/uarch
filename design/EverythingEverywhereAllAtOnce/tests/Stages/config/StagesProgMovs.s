.org 0x1000
    .code

    .global _start
_start:

    # ----------------------------------------
    # B2: MOV BL, imm8
    # opcode B2
    # ----------------------------------------
    movb $0x7F, %bl

    # ----------------------------------------
    # 89: MOV r/m32, r32
    # EBX -> ECX
    # opcode 89
    # 0x1002
    # ----------------------------------------
    movl %ebx, %ecx

    # ----------------------------------------
    # 8E: MOV Sreg, r/m16
    # Move AX into ES
    # opcode 8E
    # 0x1004
    # ----------------------------------------
    movw %cx, %es

    # ----------------------------------------
    # 8C: MOV r/m16, Sreg
    # Move DS into AX
    # opcode 8C
    # 0x1006
    # ----------------------------------------
    movw %es, %ax

    # ----------------------------------------
    # 89 with memory operand
    # [EDI + EDX*2 + disp]
    # 0x1009
    # ----------------------------------------
    movw %ax, 0x5678(%edi,%edx,2)


    # 0x1011
    movl 0x5678(%edi,%edx,2), %edx

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