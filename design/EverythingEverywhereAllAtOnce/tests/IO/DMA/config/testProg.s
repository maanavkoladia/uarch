.org x1000
    .code

    .global _start
_start:

    # 1) ADD AX, 0xDEAD
    addw $0xDEAD, %ax

    # 2) ADD ECX, EAX
    addl %eax, %ecx

    # load data address into eax
    #movl  $0x2000, %eax

    ## load first word from data section
    #movl  (%eax), %ebx

    ## add second word
    #addl  4(%eax), %ebx

    ## store result back
    #movl  %ebx, 8(%eax)

    # infinite loop (halt equivalent)
#loop:
    #jmp   loop


        .org x2000
        .data
val_a: .long 0x11223344
val_b: .long 0x11223344
val_c: .long 0x11223344
val_d: .long 0x11223344

