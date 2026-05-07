#define __CS__ 0x0000
#define __DS__ 0x0600
#define __ES__ 0x0300
#define __SS__ 0xF000


.org 0x00000000
.code
.global _start

_start:

segment_init:
    movl    $__DS__, %eax
    movw    %ax, %ds
    movl    $__ES__, %eax
    movw    %ax, %es
    movl    $__SS__, %eax
    movw    %ax, %ss

main:
    nop
    nop
    nop
    movl $10, %ecx
    rep movsl
    movl $50, %eax

    hlt

# ================================================================
# DATA SECTION — mapped at 0x2000
# ================================================================

.org 0x40020000
.data
    .long 0x11223344
#data_page:
#    .space 0xC00

# ================================================================
# STACK SECTION — mapped at 0x4000
# ESP initialised to 0x5000 so the stack grows downward into this page
# ================================================================

.org 0xF0000000
.data
    .long 0x55667788
#stack_page:
#    .space 0x1000
