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
    add $0x7F, %ecx
    add $0x80, %ecx
    add $0x01, %edx
    add $0xFF, %edx


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


    # --- base setup (intentionally misaligned) ---
    mov $dataA, %eax
    add $0xF, %eax          # near line boundary

    mov $dataB, %ebx
    add $0x3, %ebx

    mov $dataC, %ecx
    add $0xD, %ecx

    mov $dataD, %edx
    add $0x7, %edx

        
    # =========================
    # INIT BASE POINTERS (CRITICAL)
    # =========================

    mov $dataA, %eax
    mov (%eax), %eax     # eax = safe ptr in page

    mov $dataB, %ebx
    mov (%ebx), %ebx

    mov $dataC, %ecx
    mov (%ecx), %ecx

    mov $dataD, %edx
    mov (%edx), %edx


    # =========================
    # 32-bit memory ops
    # =========================

    add (%eax), %ebx
    add 0xF(%eax), %ecx
    add 0xD(%eax), %edx
    add 0x3(%eax), %eax

    add (%ebx), %eax
    add 0xE(%ebx), %ecx
    add 0x5(%ebx), %edx
    add 0x1(%ebx), %ebx

    add (%ecx), %eax
    add 0xB(%ecx), %ebx
    add 0x7(%ecx), %edx
    add 0xF(%ecx), %ecx

    add (%edx), %eax
    add 0xD(%edx), %ebx
    add 0x9(%edx), %ecx
    add 0x2(%edx), %edx


    
    mov $dataA, %eax
    mov (%eax), %eax

    mov $dataB, %ebx
    mov (%ebx), %ebx


    # =========================
    # mem writeback
    # =========================

    add %eax, (%eax)
    add %ebx, 0xF(%eax)
    add %ecx, 0xD(%eax)
    add %edx, 0x3(%eax)


    # =========================
    # 16-bit ops
    # =========================

    add (%eax), %bx
    add 0xF(%eax), %cx
    add 0xD(%eax), %dx
    add 0x3(%eax), %ax

    add %ax, (%ebx)
    add %bx, 0xE(%ebx)
    add %cx, 0x5(%ebx)
    add %dx, 0x1(%ebx)


    # =========================
    # 8-bit low regs
    # =========================

    add (%eax), %bl
    add 0xF(%eax), %cl
    add 0xD(%eax), %dl
    add 0x3(%eax), %al

    add %al, (%ecx)
    add %bl, 0xB(%ecx)
    add %cl, 0x7(%ecx)
    add %dl, 0xF(%ecx)


    # =========================
    # 8-bit high regs
    # =========================

    add (%ebx), %bh
    add 0xE(%ebx), %ch
    add 0x5(%ebx), %dh
    add 0x1(%ebx), %ah

    add %ah, (%edx)
    add %bh, 0xD(%edx)
    add %ch, 0x9(%edx)
    add %dh, 0x2(%edx)


    # =========================
    # AGU STRESS (CONTROLLED)
    # =========================

    mov $dataA, %eax
    mov (%eax), %eax

    mov $dataB, %ebx
    mov (%ebx), %ebx

    add (%eax,%ebx,1), %ecx
    add 0xF(%eax,%ebx,1), %edx

    add %eax, (%eax,%ebx,1)
    add %ebx, 0xF(%eax,%ebx,1)


    # =========================
    # CROSS-LINE (SAFE)
    # =========================

    add 0xF(%eax), %ebx
    add 0xF(%eax), %bx
    add 0xF(%eax), %bl
    add 0xF(%eax), %bh

    add %ebx, 0xF(%eax)
    add %bx, 0xF(%eax)
    add %bl, 0xF(%eax)
    add %bh, 0xF(%eax)


    # =========================
    # FINAL REGION
    # =========================

    mov $dataE, %eax
    mov (%eax), %eax     # CRITICAL FIX (was missing before!)
    add $0xD, %eax

    add (%eax), %ebx
    add 0xF(%eax), %ecx
    add %edx, (%eax)
    add %eax, 0x3(%eax)

    hlt
        # =========================
        # DATA REGIONS (scattered)
        # =========================

    .org 0x2000
    .data

    dataA:
        .long 0x00002040
        .long 0x00002080
        .long 0x000020C0

    dataB:
        .long 0x00002100
        .long 0x00002140
        .long 0x00002180

    dataC:
        .long 0x00002200
        .long 0x00002240
        .long 0x00002280

    dataD:
        .long 0x00002300
        .long 0x00002340
        .long 0x00002380

    dataE:
        .long 0x00002400
        .long 0x00002440
        .long 0x00002480

    memval:
        .long 0x00002500