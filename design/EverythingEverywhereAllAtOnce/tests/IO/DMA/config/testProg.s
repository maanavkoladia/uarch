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
blk0_a: .long 0x00000000
blk0_b: .long 0x00000000
blk0_c: .long 0x00000000
blk0_d: .long 0x00000000

        .org x2400
        .data
blk1_a: .long 0x11111111
blk1_b: .long 0x11111111
blk1_c: .long 0x11111111
blk1_d: .long 0x11111111

        .org x2800
        .data
blk2_a: .long 0x22222222
blk2_b: .long 0x22222222
blk2_c: .long 0x22222222
blk2_d: .long 0x22222222

        .org x2C00
        .data
blk3_a: .long 0x33333333
blk3_b: .long 0x33333333
blk3_c: .long 0x33333333
blk3_d: .long 0x33333333

        .org x3000
        .data
blk4_a: .long 0x44444444
blk4_b: .long 0x44444444
blk4_c: .long 0x44444444
blk4_d: .long 0x44444444

        .org x3400
        .data
blk5_a: .long 0x55555555
blk5_b: .long 0x55555555
blk5_c: .long 0x55555555
blk5_d: .long 0x55555555

        .org x3800
        .data
blk6_a: .long 0x66666666
blk6_b: .long 0x66666666
blk6_c: .long 0x66666666
blk6_d: .long 0x66666666

        .org x3C00
        .data
blk7_a: .long 0x77777777
blk7_b: .long 0x77777777
blk7_c: .long 0x77777777
blk7_d: .long 0x77777777

        .org x4000
        .data
blk8_a: .long 0x88888888
blk8_b: .long 0x88888888
blk8_c: .long 0x88888888
blk8_d: .long 0x88888888

        .org x4400
        .data
blk9_a: .long 0x99999999
blk9_b: .long 0x99999999
blk9_c: .long 0x99999999
blk9_d: .long 0x99999999

        .org x4800
        .data
blk10_a: .long 0xAAAAAAAA
blk10_b: .long 0xAAAAAAAA
blk10_c: .long 0xAAAAAAAA
blk10_d: .long 0xAAAAAAAA

        .org x4C00
        .data
blk11_a: .long 0xBBBBBBBB
blk11_b: .long 0xBBBBBBBB
blk11_c: .long 0xBBBBBBBB
blk11_d: .long 0xBBBBBBBB

        .org x5000
        .data
blk12_a: .long 0xCCCCCCCC
blk12_b: .long 0xCCCCCCCC
blk12_c: .long 0xCCCCCCCC
blk12_d: .long 0xCCCCCCCC

        .org x5400
        .data
blk13_a: .long 0xDDDDDDDD
blk13_b: .long 0xDDDDDDDD
blk13_c: .long 0xDDDDDDDD
blk13_d: .long 0xDDDDDDDD

        .org x5800
        .data
blk14_a: .long 0xEEEEEEEE
blk14_b: .long 0xEEEEEEEE
blk14_c: .long 0xEEEEEEEE
blk14_d: .long 0xEEEEEEEE

        .org x5C00
        .data
blk15_a: .long 0xFFFFFFFF
blk15_b: .long 0xFFFFFFFF
blk15_c: .long 0xFFFFFFFF
blk15_d: .long 0xFFFFFFFF
