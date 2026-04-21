.org 0x1000
.code
.global _start

_start:

    movl $0x11111111, %eax
    movl $0x22222222, %ebxdc
    movl $0x33333333, %ecx
    movl $0x44444444, %edx

    movl $0x2000, %edi        # use EDI as pointer

    xchgl %ebx, %eax          # eax <-> ebx

    xchgl %ecx, (%edi)        # ecx <-> [edi]

    xchgw %dx, (%edi)         # dx <-> lower 16 bits of [edi]

    xchgb %al, (%edi)         # al <-> lowest byte of [edi]

    xchgw %bx, %ax            # ax <-> bx

    hlt


.org 0x2000
.data
memval:
    .long 0xAAAAAAAA