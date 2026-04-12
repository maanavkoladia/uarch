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


.org 10D0
.data
val_a_10: .long 0x01020304
val_b_10: .long 0x02030405
val_c_10: .long 0x03040506
val_d_10: .long 0x04050607

.org 20D0
.data
val_a_20: .long 0x11121314
val_b_20: .long 0x12131415
val_c_20: .long 0x13141516
val_d_20: .long 0x14151617

.org 30D0
.data
val_a_30: .long 0x21222324
val_b_30: .long 0x22232425
val_c_30: .long 0x23242526
val_d_30: .long 0x24252627

.org 40D0
.data
val_a_40: .long 0x31323334
val_b_40: .long 0x32333435
val_c_40: .long 0x33343536
val_d_40: .long 0x34353637

.org 50D0
.data
val_a_50: .long 0x41424344
val_b_50: .long 0x42434445
val_c_50: .long 0x43444546
val_d_50: .long 0x44454647

.org 60D0
.data
val_a_60: .long 0x51525354
val_b_60: .long 0x52535455
val_c_60: .long 0x53545556
val_d_60: .long 0x54555657