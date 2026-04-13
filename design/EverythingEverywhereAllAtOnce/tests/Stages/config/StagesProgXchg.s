.org 0x1000
.code
.global _start

_start:
    # ----------------------------
    # Initialize registers
    # ----------------------------
    movl $0x11111111, %eax
    movl $0x22222222, %ebx
    movl $0x33333333, %ecx
    movl $0x44444444, %edx

    # ----------------------------
    # Initialize memory
    # ----------------------------
    movl $0x2000, %edi        # use EDI as pointer

    # ----------------------------
    # 90+rd : XCHG EAX, r32
    # ----------------------------
    xchgl %ebx, %eax          # eax <-> ebx

    # ----------------------------
    # 87 /r : XCHG r/m32, r32
    # ----------------------------
    xchgl %ecx, (%edi)        # ecx <-> [edi]

    # ----------------------------
    # 87 /r : XCHG r/m16, r16
    # ----------------------------
    xchgw %dx, (%edi)         # dx <-> lower 16 bits of [edi]

    # ----------------------------
    # 86 /r : XCHG r/m8, r8
    # ----------------------------
    xchgb %al, (%edi)         # al <-> lowest byte of [edi]

    # ----------------------------
    # 90+rw : XCHG AX, r16
    # ----------------------------
    xchgw %bx, %ax            # ax <-> bx

    hlt


.org 0x2000
.data
memval:
    .long 0xAAAAAAAA