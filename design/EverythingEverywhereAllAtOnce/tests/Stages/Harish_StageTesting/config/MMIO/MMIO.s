#define __CS__ 0x0000
#define __DS__ 0x2000
#define __ES__ 0xE000
#define __SS__ 0xF000

#define MMIO_BASE              0xE0000000

#define DDR5_POWER_GATING      (0x40)
#define DDR5_READ_TEMPERATURE  (0x50)

#define NOP_DELAYS (50)

.org 0x00000000
.code
.global _start

_start:

    # सेट DS
    movl    $__DS__, %eax
    movw    %ax, %ds

    # सेट ES (MMIO segment)
    movl    $__ES__, %eax
    movw    %ax, %es
    movl    $__SS__, %eax
    movw    %ax, %ss
    movl $0x00FE0, %esp 
    
    # -------------------------------
    # DDR5: disable power gating (write 0)
    # -------------------------------
    movl    $0, %eax
    movl    $DDR5_POWER_GATING, %esi
    # movl    %eax, %es:(%esi)
    
    call fakeDelay

    # -------------------------------
    # DDR5: read temperature
    # -------------------------------
    # movl    %es:(DDR5_READ_TEMPERATURE), %ebx

    hlt


# ================================
# Fake delay loop
# ================================
fakeDelay:
    movl    $NOP_DELAYS, %ecx

delay_loop:
    nop
    addl    $-1, %ecx
    jne     delay_loop

    ret
    

.org 0x20000000
.data
data_page:
    .space 0xB00


.org 0xF0000000
.data
stack_page:
    .long 0x55667788

#    .space 0x1000
