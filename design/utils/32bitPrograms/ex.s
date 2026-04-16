.section .data
memval:
    .long 0x33333333
    .long 0x44444444
    .long 0x55555555
    .long 0x66666666

.section .text
.global _start

_start:
    xor %eax, %eax
    xor %ebx, %ebx
    xor %ecx, %ecx
    xor %edx, %edx
    xor %esi, %esi
    xor %edi, %edi
    xor %ebp, %ebp
    cld
    clc
    xor %eax, %eax

main:
    movl $0x11111111, %eax
    movl $0x22222222, %ebx

    movl $memval, %esi      # load address of data
    movl (%esi), %ecx       # ecx = 0x33333333
    addl $4, %esi           # move to next value

    jmp target

    addl %eax, %ecx         # skipped
    addl %ebx, %edx         # skipped

target:
    addl %eax, %ecx         # ecx += 0x11111111
    addl (%esi), %ecx       # ecx += 0x44444444
    xchgl %ebx, %eax

termination:
    jmp termination

    # exit cleanly instead of hlt
    #movl $1, %eax           # sys_exit
    #xorl %ebx, %ebx
    #int $0x80

#org 0x1000
#.code
#.global _start
#
#_start:
#
#    movl $0x11111111, %eax
#    movl $0x22222222, %ebx
#    movl $0x2000, %esi
#    movl (%esi), %ecx        # ecx now shuld have 0x66660000
#    addl $0x4, %esi
#
#    jmp target
#    addl %eax, %ecx
#    addl %ebx, %edx         # should not see x2222 in edx
#
#target:
#    addl %eax, %ecx         # x44444444 in ecx
#    addl (%esi), %ecx       # x88888888 in ecx
#    xchgl %ebx, %eax
#
#    hlt
#
#
#.org 0x2000
#.data
#memval:
#    .long 0x33333333
#    .long 0x44444444
#    .long 0x55555555
#    .long 0x66666666
