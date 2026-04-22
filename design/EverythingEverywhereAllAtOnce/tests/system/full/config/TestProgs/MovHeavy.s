.org 0x1000
.code
.global _start

_start:
    movl $0x2000, %esi
    movl $0x00000000, %ebx

    # ================= DCACHE TESTS =================

    movl $0xA0A0A0A0, (%esi)
    movl $0xB1B1B1B1, 0x200(%esi)
    movl $0xC2C2C2C2, 0x400(%esi)
    movl $0xD3D3D3D3, 0x600(%esi)
    movl $0xE4E4E4E4, 0x800(%esi)

    movl (%esi), %eax
    addl %eax, %ebx
    movl 0x200(%esi), %eax
    addl %eax, %ebx
    movl 0x400(%esi), %eax
    addl %eax, %ebx
    movl 0x600(%esi), %eax
    addl %eax, %ebx
    movl 0x800(%esi), %eax
    addl %eax, %ebx

    movl $0xF5F5F5F5, 0xA00(%esi)
    movl 0xA00(%esi), %eax
    addl %eax, %ebx

    movl $0xFFFFFFFF, (%esi)
    andl $0x0F0F0F0F, (%esi)
    movl $0xFFFFFFFF, 0x200(%esi)
    andl $0xF0F0F0F0, 0x200(%esi)
    movl $0xFFFFFFFF, 0x400(%esi)
    andl $0x00FF00FF, 0x400(%esi)

    movl (%esi), %eax
    andl 0x200(%esi), %eax
    andl 0x400(%esi), %eax
    addl %eax, %ebx

    movl $0x00000001, (%esi)
    movl $0x00000002, 0x200(%esi)
    movl $0x00000004, 0x400(%esi)
    movl $0x00000008, 0x600(%esi)
    movl $0x00000010, 0x800(%esi)

    movl $0, %eax
    addl (%esi), %eax
    addl 0x200(%esi), %eax
    addl 0x400(%esi), %eax
    addl 0x600(%esi), %eax
    addl 0x800(%esi), %eax
    addl %eax, %ebx

    movl $0x10000001, (%esi)
    movl $0x20000002, 0x200(%esi)
    movl $12, %ecx

dc_thrash_loop:
    movl (%esi), %eax
    addl 0x200(%esi), %eax
    movl %eax, (%esi)
    movl %eax, 0x200(%esi)
    addl $-1, %ecx
    jne dc_thrash_loop

    addl %eax, %ebx

    movl $0xBA000000, (%esi)
    movl $0xBB000000, 0x10(%esi)
    movl $0xBC000000, 0x20(%esi)
    movl $0xBD000000, 0x30(%esi)

    movl (%esi), %eax
    addl 0x10(%esi), %eax
    addl 0x20(%esi), %eax
    addl 0x30(%esi), %eax
    addl %eax, %ebx

    movl $0x10000000, (%esi)
    movl $0x20000000, 0x40(%esi)
    movl $0x30000000, 0x80(%esi)
    movl $0x40000000, 0xC0(%esi)
    movl $0x50000000, 0x100(%esi)
    movl $0x60000000, 0x140(%esi)
    movl $0x70000000, 0x180(%esi)
    movl $0x80000000, 0x1C0(%esi)

    movl (%esi), %eax
    addl 0x40(%esi), %eax
    addl 0x80(%esi), %eax
    addl 0xC0(%esi), %eax
    addl 0x100(%esi), %eax
    addl 0x140(%esi), %eax
    addl 0x180(%esi), %eax
    addl 0x1C0(%esi), %eax
    addl %eax, %ebx

    movl $0x01000000, 0x10(%esi)
    movl $0x02000000, 0x50(%esi)
    movl $0x03000000, 0x90(%esi)
    movl $0x04000000, 0xD0(%esi)
    movl $0x05000000, 0x110(%esi)
    movl $0x06000000, 0x150(%esi)
    movl $0x07000000, 0x190(%esi)
    movl $0x08000000, 0x1D0(%esi)

    movl 0x10(%esi), %eax
    addl 0x50(%esi), %eax
    addl 0x90(%esi), %eax
    addl 0xD0(%esi), %eax
    addl 0x110(%esi), %eax
    addl 0x150(%esi), %eax
    addl 0x190(%esi), %eax
    addl 0x1D0(%esi), %eax
    addl %eax, %ebx

    jmp ic_fill_1

# ================= ICACHE =================

ic_fill_1:
    movl $0x16161616, (%esi)
    movl $0x16161616, 0x200(%esi)
    addl (%esi), %ebx
    andl $0xFFFFFF00, 0x400(%esi)
    movl 0x400(%esi), %eax
    addl %eax, %ebx
    jmp ic_fill_2

ic_fill_2:
    movl $0x17171717, 0x10(%esi)
    movl $0x17171717, 0x210(%esi)
    addl 0x10(%esi), %ebx
    addl 0x210(%esi), %ebx
    andl $0x0FFFFFFF, (%esi)
    jmp ic_fill_3

ic_fill_3:
    movl $0x18181818, 0x40(%esi)
    movl $0x18181818, 0x240(%esi)
    addl 0x40(%esi), %ebx
    movl 0x240(%esi), %eax
    andl %eax, %ebx
    movl $0x18181818, 0x20(%esi)
    addl 0x20(%esi), %ebx
    jmp ic_fill_4

ic_fill_4:
    movl $0x12121212, 0x200(%esi)
    movl 0x200(%esi), %ebx
    movl $0x14141414, 0x400(%esi)
    movl 0x400(%esi), %eax
    movl $0x18181818, 0x800(%esi)
    movl 0x800(%esi), %eax
    addl %eax, %ebx
    jmp ic_fill_5

ic_fill_5:
    movl $0x1A1A1A1A, (%esi)
    movl (%esi), %ebx
    movl $0x16161616, 0x600(%esi)
    movl 0x600(%esi), %ebx
    movl 0x200(%esi), %eax
    hlt
    andl $0xF0F0F0F0, 0x200(%esi)
    movl $16, %ecx
    jmp ic_thrash_a

ic_thrash_a:
    movl $0xBBBBBBBB, (%esi)
    addl (%esi), %ebx
    movl $0xBBBBBBBB, 0x40(%esi)
    andl $0xBBBBBBBB, 0x80(%esi)
    addl $-1, %ecx
    jne ic_thrash_b
    jmp ic_done

ic_thrash_b:
    movl $0xCCCCCCCC, 0x200(%esi)
    addl 0x200(%esi), %ebx
    movl $0xCCCCCCCC, 0x240(%esi)
    andl $0xCCCCCCCC, 0x280(%esi)
    addl $-1, %ecx
    jne ic_thrash_a

ic_done:
    hlt

.org 0x2000
.data

data_page:
    .space 0xB00
