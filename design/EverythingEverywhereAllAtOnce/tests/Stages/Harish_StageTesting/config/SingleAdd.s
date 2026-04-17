.org 0x1000
.code
.global _start

_start:

    # --- imm to accumulator ---
    add $0x1, %al
    add $0x7F, %al
    add $0x12, %al
    add $0x34, %al

    add $0x1234, %ax
    add $0x00FF, %ax
    add $0xABCD, %ax
    add $0x0101, %ax
    # 1018
    add $0x12345678, %eax
    add $0x1, %eax
    add $0x7FFFFFFF, %eax
    add $0x80000000, %eax

    # --- imm8 sign-extended to 32 ---
    add $0x7F, %eax
    add $0x80, %eax
    add $0x01, %ebx
    add $0xFF, %ebx
    nop
    nop
    nop
    nop
    nop
    nop
    add $0x7F, %ecx
    add $0x80, %ecx
    add $0x01, %edx
    add $0xFF, %edx

    hlt

    # --- 32-bit reg to reg (dest += src) ---
    add %eax, %ebx
    add %ebx, %eax
    add %ecx, %eax
    add %edx, %eax
    add %eax, %ecx
    add %ebx, %ecx
    add %ecx, %ebx
    add %edx, %ebx
    add %eax, %edx
    add %ebx, %edx
    add %ecx, %edx
    add %edx, %ecx

# --- reverse encoding form (r32 += r/m32) ---
add %ebx, %eax
add %eax, %ebx
add %eax, %ecx
add %eax, %edx
add %ecx, %eax
add %ecx, %ebx
add %ebx, %ecx
add %ebx, %edx
add %edx, %eax
add %edx, %ebx
add %edx, %ecx
add %ecx, %edx

    # --- 16-bit reg to reg ---
    add %ax, %bx
    add %bx, %ax
    add %cx, %ax
    add %dx, %ax
    add %ax, %cx
    add %bx, %cx
    add %cx, %bx
    add %dx, %bx
    add %ax, %dx
    add %bx, %dx
    add %cx, %dx
    add %dx, %cx

    # --- reverse 16-bit ---
    add %bx, %ax
    add %ax, %bx
    add %ax, %cx
    add %ax, %dx
    add %cx, %ax
    add %cx, %bx
    add %bx, %cx
    add %bx, %dx
    add %dx, %ax
    add %dx, %bx
    add %dx, %cx
    add %cx, %dx

    # --- 8-bit low regs ---
    add %al, %bl
    add %bl, %al
    add %cl, %al
    add %dl, %al
    add %al, %cl
    add %bl, %cl
    add %cl, %bl
    add %dl, %bl
    add %al, %dl
    add %bl, %dl
    add %cl, %dl
    add %dl, %cl

    # --- 8-bit high regs ---
    add %ah, %bh
    add %bh, %ah
    add %ch, %ah
    add %dh, %ah
    add %ah, %ch
    add %bh, %ch
    add %ch, %bh
    add %dh, %bh
    add %ah, %dh
    add %bh, %dh
    add %ch, %dh
    add %dh, %ch

    # --- mixed high/low (valid but tricky cases) ---
    add %al, %ah
    add %ah, %al
    add %bl, %bh
    add %bh, %bl
    add %cl, %ch
    add %ch, %cl
    add %dl, %dh
    add %dh, %dl

    # --- extra coverage to reach 100 ---
    add %eax, %eax
    add %ebx, %ebx
    add %ecx, %ecx
    add %edx, %edx

    add %ax, %ax
    add %bx, %bx
    add %cx, %cx
    add %dx, %dx

    add %al, %al
    add %bl, %bl
    add %cl, %cl
    add %dl, %dl
    hlt


.org 0x2000
.data
memval:
    .long 0xAAAAAAAA