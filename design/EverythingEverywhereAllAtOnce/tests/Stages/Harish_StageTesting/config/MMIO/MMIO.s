#define __CS__ (0x0000)
#define __DS__ (0x0200)
#define __SS__ (0xF000) 
#define __ES__ (0xE000)
#define __FS__ (0x0600)

#define IDTR (0x04000000)
#define MMIO_BASE (0xE0000000)

#define DMA_WRITE_SRC_ADDRESS (0x00)
#define DMA_WRITE_DEST_ADDRESS (0x10)
#define DMA_WRITE_NUM_BYTES_ADDRESS (0x20)
#define DMA_WRITE_START_TRANSFER_ADDRESS (0x30)
#define DDR5_POWER_GATING (0x40)
#define DDR5_READ_TEMPERATURE (0x50)

#define DMA_TRANSFER_DISK_ADDR (0x00)
#define DMA_TRANSFER_PMEM_TRANSFER_DISK_ADDR (0x7000)
#define DMA_TRANSFER_NUM_BYTES (64)

#define NOP_DELAYS (50)

#define NUM_NONSENSE_RWS (50)

.org 0x00000000 //mapped
.code
.global _start

_start:
seg_init:
    # सेट DS
    movl    $__DS__, %eax
    movw    %ax, %ds

    # सेट ES (MMIO segment)
    movl    $__ES__, %eax
    movw    %ax, %es
    movl    $__SS__, %eax
    movw    %ax, %ss
    movl    $__FS__, %eax
    movw    %ax, %fs
    movl $0x00FFF, %esp 

 main:   
    # -------------------------------
    # DDR5: disable power gating (write 0)
    # -------------------------------
    call ddr5_routine
    
    //ebx should have a 0xbb8 and ecx have a 0
    call dma_routine

    //interrupt will come in in a bit, 
    //do i bunch of nonsense mem loads from data page using sib, interrupt shoudl come in between
    //write this 
    call nonsense_mem_ops

    mov $0xa0a0a0a0, %eax

    hlt
//ddr5 routine
ddr5_routine:
    
    //turn off the default high pwoer gate
    movl    $DDR5_POWER_GATING, %esi
    movl    $0, %es:(%esi)
    
    call fakeDelay

    # # -------------------------------
    # # DDR5: read temperature
    # # -------------------------------
    movl $DDR5_READ_TEMPERATURE, %esi
    movl %es:(%esi), %ebx
    movl $0xA0A0A0A0, %ebx
    
    //pweor gate the ddr5 again
    movl    $DDR5_POWER_GATING, %esi
    movl    $1, %es:(%esi)
    call fakeDelay
    movl $0x11111111, %edx
    movl $DDR5_READ_TEMPERATURE, %esi
    movl %es:(%esi), %ecx

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

    movl $0x11223344, %ecx
    ret

interruptRoutine:
    //mov something from the frame the data was written to edx
    movl $0x10, %eax
    movl %fs:(%eax), %edx
    movl $0x12345678, %ebp
    iret
    hlt


nonsense_mem_ops:
    # ---------------------------------------
    # Cacheline stress test (byte accesses)
    # 32 cachelines, 16B stride
    # repeated NUM_NONSENSE_RWS times
    # ---------------------------------------

    movl $NUM_NONSENSE_RWS, %ecx
    movl $0, %esi
nonsense_loop:
    mov (%esi), %ebx
    nop
    nop
    nop
        nop
    nop
    nop
        nop
    nop
    nop
        nop
    nop
    nop
        nop
    nop
    nop
        nop
    nop
    nop
        nop
    nop
    nop
    nop
    nop
    nop
        nop
    nop
    nop
        nop
    nop
    nop
        nop
    nop
    nop
        nop
    nop
    nop

    addl $-1, %ecx
    jne nonsense_loop
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



//data segement
.org 0x02000000 //mapped
.data
data_page:
    .space 0xB00

//stack segment
.org 0xF0000000 //mapped
.data

//ES, this is the mmio segment
.org 0xE0000000
.data

//FS
.org 0x06000000 //mapped, dma will write here
.data

.org 0x04000000
.data
.space 7*8   // skip 56 bytes
// entry 7
.word interruptRoutine //offset_low, pc of the interruptRoutine
.word 0x0000 //selector
.byte 0x0
.byte 0x0 //type_attr
.word 0x0000 //offset_high
//8 entry bytes


