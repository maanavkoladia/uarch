#define __CS0__ 0x0000
#define __DS0__ 0x2004
#define __CS1__ 0x0100
#define __DS1__ 0x1234
#define __SP0__ 0xFFFF

.org 0x00000000
.code
.global _start

_start:

    /* ------------------------------------------------
       set data segment
       ------------------------------------------------ */
    movl    $__DS0__, %eax
    movw    %ax, %ds
    movl    $__SP0__, %eax
    movw    %ax, %ss

    /* ------------------------------------------------
       initialize stack pointer (stack grows downward)
       ------------------------------------------------ */
    movl    $0x0FFF, %esp
    /* ------------------------------------------------
       push some values onto stack
       (these will remain intact across far call/retf
       if CS1 code does not destroy them)
       ------------------------------------------------ */

    pushl   %eax
    pushl   $0x11111111
    pushl   $0x22222222
    pushl   $0x33333333
    /* optional marker */
    pushl   $0xDEADBEEF
    /* ------------------------------------------------

       far call into CS1:0x10000
       pushes CS0:EIP automatically
       ------------------------------------------------ */
    lcall   $__CS1__, $0
    /* ------------------------------------------------
       returned from CS1 via lret

       check stack still valid
       ------------------------------------------------ */
    popl    %ebx
    popl    %ecx
    popl    %edx
    popl    %esi

    hlt

/* ================================================================
   DATA SECTION - mapped at 0x2000
   ================================================================ */
.org 0x20040000

.data
data_page:
    .long 0x11223344
    .space 0xC00

/* ================================================================

   SECOND CODE SECTION - mapped at 0x10000 (CS1)
   ================================================================ */
.org 0x01000000
.code
_second_entry:
    /* ------------------------------------------------

       switch data segment
       ------------------------------------------------ */
    movl    $__DS1__, %eax
    movw    %ax, %ds
    /* ------------------------------------------------
       memory operations

       ------------------------------------------------ */
    movl    $0, %ecx
    addl    (%ecx), %eax /*2004 + 3344*/
    movl    %eax, %ebx
    movl    %ebx, %ecx

    /* ------------------------------------------------
       stack inspection - should see 0xDEADBEEF
       ------------------------------------------------ */

   /* movl    (%esp), %edx */
      movl %esp, %eax
      movl %ss:(%eax), %edx

    /* ------------------------------------------------
       return to caller (restores CS0:EIP)

       ------------------------------------------------ */
    lret


.org 0x12340000
.data
data_page_2:

    .long 0x55667788
    .space 0xC00

/* ================================================================
   STACK SECTION
   ESP initialized to 0xFFFFF, stack grows downward

   ================================================================ */
.org 0xFFFF0000
.data
stack_page:
    .space 0xC00
