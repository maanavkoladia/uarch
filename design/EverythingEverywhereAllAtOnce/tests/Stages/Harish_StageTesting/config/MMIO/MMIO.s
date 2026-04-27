#define __CS__ 0x0000
#define __DS__ 0x2000
#define __ES__ 0xE000

#define MMIO_BASE              0xE0000000

#define DDR5_POWER_GATING      (MMIO_BASE + 0x40)
#define DDR5_READ_TEMPERATURE  (MMIO_BASE + 0x50)

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
        
    # -------------------------------
    # DDR5: disable power gating (write 0)
    # -------------------------------
    movl    $0, %eax
    movl    %eax, %es:(DDR5_POWER_GATING)
    
    call fakeDelay

    # -------------------------------
    # DDR5: read temperature
    # -------------------------------
    movl    %es:(DDR5_READ_TEMPERATURE), %ebx

    hlt


# ================================
# Fake delay loop
# ================================
fakeDelay:
    movl    $NOP_DELAYS, %ecx

delay_loop:
    nop
    loop    delay_loop   # decrements ECX and loops if not zero

    ret
    

.org 0x20000000
.data
data_page:
    .space 0xB00
