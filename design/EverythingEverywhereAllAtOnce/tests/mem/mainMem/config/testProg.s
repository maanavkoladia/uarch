.org x1000
    .code

    .global _start
_start:
    # load data address into eax
    movl  $0x2000, %eax

    # load first word from data section
    movl  (%eax), %ebx

    # add second word
    addl  4(%eax), %ebx

    # store result back
    movl  %ebx, 8(%eax)

    # infinite loop (halt equivalent)
loop:
    jmp   loop


    .org x2000
    .data

val_a:  .long  0xDEADBEEF
val_b:  .long  0x0000CAFE
