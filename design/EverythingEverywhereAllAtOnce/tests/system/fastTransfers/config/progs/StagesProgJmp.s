.org 0x1000
    .code

    # ----------------------------------------
    # B2: MOV BL, imm8
    # opcode B2
    # ----------------------------------------
    movl $0x5670, %esp

    # 0x1005
    movl $0x1234, (%esp)

    # 0x100C
    movl (%esp), %ecx

    # ----------------------------------------
    # E9: JMP rel32
    # Jump forward to label target
    # ----------------------------------------
    # 0x100F
    jmp target

target2:
    hlt

.org 0x0000
    .code

target:
    pop %eax
    jmp target2

.org 0x5670
    .data
val_1:  .long  0x11111111
val_2:  .long  0x22222222
val_a:  .long  0xAABBCCDD
val_b:  .long  0xBEEFDEAD