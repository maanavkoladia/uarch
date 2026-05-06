#define __CS0__ 0x0000
#define __DS0__ 0x0010
#define __DS1__ 0x1234
#define __DS2__ 0x9ADC
#define __SS0__ 0xFFFF

.org 0x00000000
.code
.global _start
_start:
segment_init:
    movl    $__DS0__, %eax
    movw    %ax, %ds
    movl    $__SS0__, %eax
    movw    %ax, %ss
    movl    $0x00000FFC, %esp

main:
    cld

    // ================================================================
    // Loop 1: DS0 — stride 4, 1024 iters
    //   Worst-case ESI before exit-add: 1023*4 = 0x0FFC
    //   Body max byte access:           0x0FFC + 3 = 0x0FFF
    //   After exit-add:                 0x1000  (still in-segment, never accessed)
    // ================================================================
    movl    $__DS0__, %eax
    movw    %ax, %ds

    movl    $0x00000000, %esi
    movl    $0x00000400, %ecx            // 1024 iterations

ds0_loop:
    movl    (%esi), %eax
    movl    %eax, %ebx
    orl     $0xA5A5A5A5, %ebx
    andl    $0xFFFFFFF0, %ebx

    movl    %ebx, (%esi)
    movl    (%esi), %edx

    movl    $0x11111111, %edi
    adcl    %edi, (%esi)
    movl    (%esi), %edi

    movl    $0xDEADBEEF, %eax
    xchgl   %eax, (%esi)

    notl    (%esi)
    movl    (%esi), %ebx

    sarl    $1, (%esi)
    movl    (%esi), %edx

    addl    $4, %esi
    addl    $0xFFFFFFFF, %ecx
    jne     ds0_loop

    // ================================================================
    // Loop 2: DS1 — stride 16, 256 iters
    //   Worst-case ESI before exit-add: 255*16 = 0x0FF0
    //   Body max byte access:           0x0FF0 + 15 = 0x0FFF
    //   After exit-add:                 0x1000  (never accessed)
    //   Headroom to fault boundary (0x2000): 4096 bytes. Generous.
    // ================================================================
    movl    $__DS1__, %eax
    movw    %ax, %ds

    movl    $0x00000000, %esi
    movl    $0x00000100, %ecx            // 256 iterations

ds1_loop:
    movb    (%esi), %al
    movb    $0x5A, %bl
    orb     %bl, (%esi)
    movb    (%esi), %dl

    addb    $0x11, (%esi)
    movb    (%esi), %ah

    notb    (%esi)
    movb    (%esi), %bh

    movw    1(%esi), %ax
    movw    $0xBEEF, %bx
    xchgw   %bx, 1(%esi)
    movw    1(%esi), %dx

    andw    $0xFF00, 1(%esi)
    movw    1(%esi), %ax

    sarw    $3, 1(%esi)
    movw    1(%esi), %bx

    movb    3(%esi), %dl
    movb    $0x77, %dh
    addb    %dh, 3(%esi)
    movb    3(%esi), %al

    movl    5(%esi), %eax
    movl    $0xCAFEBABE, %edi
    movl    %edi, 5(%esi)
    movl    5(%esi), %ebx

    orl     $0x000F000F, 5(%esi)
    movl    5(%esi), %edx

    adcl    $0x01, 5(%esi)
    movl    5(%esi), %eax

    notl    5(%esi)
    movl    5(%esi), %edi

    movw    9(%esi), %ax
    addw    $0x1234, 9(%esi)
    movw    9(%esi), %bx

    sarw    $1, 9(%esi)
    movw    9(%esi), %dx

    movb    $0x01, %al
    addb    %al, 11(%esi)
    movb    11(%esi), %bl

    xchgb   %bl, 12(%esi)
    movb    12(%esi), %dl

    andb    $0x0F, 13(%esi)
    movb    13(%esi), %dl

    movl    12(%esi), %eax
    sall    $4, 12(%esi)
    movl    12(%esi), %ebx

    addl    $16, %esi
    addl    $0xFFFFFFFF, %ecx
    jne     ds1_loop

    // ================================================================
    // Loop 3: DS2 — stride 32, 128 iters
    //   Worst-case ESI before exit-add: 127*32 = 0x0FE0
    //   Body+helper max byte access:    0x0FE0 + 31 = 0x0FFF
    //   After exit-add:                 0x1000  (never accessed)
    // ================================================================
    movl    $__DS2__, %eax
    movw    %ax, %ds

    movl    $0x00000000, %esi
    movl    $0x00000080, %ecx            // 128 iterations

ds2_loop:
    pushl   $0xC0FFEE00
    popl    %ebx

    pushw   $0xBEEF
    popw    %dx

    addl    $0x01010101, (%esi)
    movl    (%esi), %eax

    movw    4(%esi), %ax
    orw     $0xF000, 4(%esi)
    movw    4(%esi), %bx

    movb    6(%esi), %dl
    notb    6(%esi)
    movb    6(%esi), %dl

    movl    7(%esi), %eax
    xchgl   %eax, 7(%esi)
    movl    7(%esi), %ebx

    movl    11(%esi), %eax
    andl    $0xFFFFFFFF, %eax
    jnbe    ds2_nonzero

    movl    $0x00000001, %edx
    movl    %edx, 11(%esi)
    jmp     ds2_after_branch

ds2_nonzero:
    movl    $0xFEEDFACE, %edx
    movl    %edx, 15(%esi)

ds2_after_branch:
    movl    11(%esi), %eax
    movl    15(%esi), %ebx

    movl    16(%esi), %eax
    sall    $1, 16(%esi)
    movl    20(%esi), %ebx
    movl    24(%esi), %edx
    cmovcl  %ebx, %edx
    movl    %edx, 24(%esi)
    movl    24(%esi), %eax

    call    ds2_helper

    addl    $32, %esi
    addl    $0xFFFFFFFF, %ecx
    jne     ds2_loop

    hlt

// ================================================================
// ds2_helper: preserves ESI, ECX, EDI; clobbers EAX/EBX/EDX/flags
// ================================================================
ds2_helper:
    movw    28(%esi), %ax
    addw    $0x0101, 28(%esi)
    movw    28(%esi), %bx

    movb    30(%esi), %al
    xchgb   %al, 31(%esi)
    movb    30(%esi), %dl
    movb    31(%esi), %bl

    andb    $0x00, %al
    jne     ds2_helper_skip
    notb    30(%esi)
    movb    30(%esi), %ah

ds2_helper_skip:
    ret

.org 0x00100000
.data
random_data_0:
    .incbin "config/VeryMemHeavy/random0.bin"

.org 0x12340000
.data
random_data_1:
    .incbin "config/VeryMemHeavy/random1.bin"

.org 0x9ADC0000
.data
random_data_2:
    .incbin "config/VeryMemHeavy/random2.bin"

.org 0xFFFF0000
.data
    .space 0x1000