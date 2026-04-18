    .org 0x1000
    .code
    .global _start

    _start:

    # ============================================================
    # BASE POINTER SETUP (IMMUTABLE)
    # ============================================================

        mov $data_page, %eax      # base pointer (DO NOT TOUCH)
        mov %eax, %ebx
        mov %eax, %ecx
        mov %eax, %edx

    # ============================================================
    # OR TESTS
    # ============================================================

    # --- imm to reg ---
        or $0x12, %al
        or $0x1234, %ax
        or $0x12345678, %edi

    # --- mem to reg (SAFE via scratch) ---
        mov (%eax), %esi
        or %esi, %edi

        mov 0x2(%eax), %si
        or %si, %di

        mov 0x4(%eax), %esi
        or %esi, %edi

    # --- reg to mem ---
        or %al, (%eax)
        or %ax, 0x2(%eax)
        or %edi, 0x4(%eax)

    # --- reg/reg ---
        or %bl, %al
        or %bx, %ax
        or %ebx, %edi

    # --- mem to reg (more coverage) ---
        mov (%ecx), %esi
        or %esi, %ebx

    # --- AH / AL mixing ---
        or %ah, %al
        or %al, %ah

        mov (%edx), %esi
        or %ah, %bl

        or %ah, (%edx)
        or 0x1(%edx), %ah
        or %ah, 0x1(%edx)

    # ============================================================
    # AND TESTS
    # ============================================================

    # --- imm to reg ---
        and $0xF0, %al
        and $0x0FF0, %ax
        and $0x00FF00FF, %edi

    # --- mem to reg ---
        mov (%eax), %esi
        and %esi, %edi

        mov 0x2(%eax), %si
        and %si, %di

        mov 0x4(%eax), %esi
        and %esi, %edi

    # --- reg to mem ---
        and %al, (%eax)
        and %ax, 0x2(%eax)
        and %edi, 0x4(%eax)

    # --- reg/reg ---
        and %cl, %al
        and %cx, %ax
        and %ecx, %edi

    # --- AH / AL mixing ---
        and %ah, %al
        and %al, %ah

        mov (%edx), %esi
        and %ah, %bl

        and %ah, (%edx)
        and 0x1(%edx), %ah
        and %ah, 0x1(%edx)

    # ============================================================
    # NOT TESTS
    # ============================================================

        not %al
        not %ah
        not %ax
        notl %edi

        notl (%eax)
        notl 0x2(%eax)
        notl 0x4(%eax)

    # ============================================================
    # SAFE AGU TEST (bounded inside page)
    # ============================================================

    # Build safe address: base + small offset
        mov %eax, %esi
        add $0x10, %esi        # still within page
        or (%esi), %al

        mov %eax, %esi
        add $0x20, %esi
        and (%esi), %ah

        mov %eax, %esi
        add $0x30, %esi
        or %al, (%esi)

    # ============================================================
    # CROSS BYTE STRESS
    # ============================================================

        or %ah, %bl
        or %bh, %al
        and %ah, %bl
        and %bh, %al

        mov (%eax), %esi
        or %bh, %bl
        and %ch, %bl

        or %bh, (%eax)
        and %ch, (%eax)

    # ============================================================
    # SAFE WRITEBACK
    # ============================================================

        or %edi, (%eax)
        and %edi, 0x4(%eax)

        or %ax, 0x2(%eax)
        and %al, 0x1(%eax)

    # ============================================================
    # END
    # ============================================================

        hlt


    # ============================================================
    # SINGLE PAGE DATA (ALL WITHIN ONE PAGE)
    # ============================================================

    .org 0x2000
    .data

    data_page:
        .long 0x11111111
        .long 0x22222222
        .long 0x33333333
        .long 0x44444444
        .long 0x55555555
        .long 0x66666666
        .long 0x77777777
        .long 0x88888888

        .long 0xAAAAAAAA
        .long 0xBBBBBBBB
        .long 0xCCCCCCCC
        .long 0xDDDDDDDD