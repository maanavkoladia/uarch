#define __CS__ 0x0000
#define __DS__ 0x2000
#define __ES__ 0xE000
#define __SS__ 0xF000
#define __GS__ 0x8000

#define MMIO_BASE              0xE0000000

#define DMA_WRITE_SRC_ADDRESS (0x00)
#define DMA_WRITE_DEST_ADDRESS (0x10)
#define DMA_WRITE_NUM_BYTES_ADDRESS (0x20)
#define DMA_WRITE_START_TRANSFER_ADDRESS (0x30)
#define DDR5_POWER_GATING (0x40)
#define DDR5_READ_TEMPERATURE (0x50)

#define DMA_TRANSFER_DISK_ADDR (0x00)
#define DMA_TRANSFER_PMEM_TRANSFER_DISK_ADDR (0x7000)
#define DMA_TRANSFER_NUM_BYTES (64)

#define NOP_DELAYS (200)

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
    movl    $__GS__, %eax
    movw    %ax, %gs
    movl $0x00FE0, %esp 
    
    # -------------------------------
    # DDR5: disable power gating (write 0)
    # -------------------------------
    call ddr5_routine

    call dma_routine
    
    hlt
//ddr5 routine
ddr5_routine:
    movl    $DDR5_POWER_GATING, %esi
    movl    $0, %es:(%esi)
    
    call fakeDelay

    # -------------------------------
    # DDR5: read temperature
    # -------------------------------
    movl $DDR5_READ_TEMPERATURE, %esi
    movl %es:(%esi), %ebx

    ret


//DMA ROUTINE
dma_routine:
    movl $DMA_WRITE_SRC_ADDRESS, %esi
    movl $DMA_TRANSFER_DISK_ADDR, %es:(%esi)

    movl $DMA_WRITE_DEST_ADDRESS, %esi
    movl $DMA_TRANSFER_PMEM_TRANSFER_DISK_ADDR, %es:(%esi)

    movl $DMA_WRITE_NUM_BYTES_ADDRESS, %esi
    movl $DMA_TRANSFER_NUM_BYTES, %es:(%esi)

    movl $DMA_WRITE_START_TRANSFER_ADDRESS, %esi
    movl $1, %es:(%esi)
    call fakeDelay //give time for interrupt, for showing interleaving mem ops
    movl $0x11223344, %ecx
    ret

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
