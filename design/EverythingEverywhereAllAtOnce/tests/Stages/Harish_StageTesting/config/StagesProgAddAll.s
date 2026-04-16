.org 0x1000
.code
.global _start

_start:
    # # ========= MOD = 00 =========
    # # ============================
    # # r/m = 000 → [EAX]
    # # ============================
    # addl %eax, (%eax)
    # addl %ecx, (%eax)
    # addl %edx, (%eax)
    # addl %ebx, (%eax)
    # addl %esp, (%eax)
    # addl %ebp, (%eax)
    # addl %esi, (%eax)
    # addl %edi, (%eax)

    # # ============================
    # # r/m = 001 → [ECX]
    # # ============================
    # addl %eax, (%ecx)
    # addl %ecx, (%ecx)
    # addl %edx, (%ecx)
    # addl %ebx, (%ecx)
    # addl %esp, (%ecx)
    # addl %ebp, (%ecx)
    # addl %esi, (%ecx)
    # addl %edi, (%ecx)

    # # ============================
    # # r/m = 010 → [EDX]
    # # ============================
    # addl %eax, (%edx)
    # addl %ecx, (%edx)
    # addl %edx, (%edx)
    # addl %ebx, (%edx)
    # addl %esp, (%edx)
    # addl %ebp, (%edx)
    # addl %esi, (%edx)
    # addl %edi, (%edx)

    # # ============================
    # # r/m = 011 → [EBX]
    # # ============================
    # addl %eax, (%ebx)
    # addl %ecx, (%ebx)
    # addl %edx, (%ebx)
    # addl %ebx, (%ebx)
    # addl %esp, (%ebx)
    # addl %ebp, (%ebx)
    # addl %esi, (%ebx)
    # addl %edi, (%ebx)

    # # ============================
    # # r/m = 100 → SIB (8 variants)
    # # ============================
    # addl %eax, (%eax,%ecx,1)
    # addl %ecx, (%ebx,%edx,2)
    # addl %edx, (%ecx,%esi,4)
    # addl %ebx, (%edx,%edi,8)
    # addl %esp, (%esi,%eax,2)
    # addl %ebp, (%edi,%ebx,4)
    # addl %esi, (%eax,%edx,8)
    # addl %edi, (%ecx,%eax,1)

    # # ============================
    # # r/m = 101 → [disp32]
    # # ============================
    # addl %eax, 0x12345678
    # addl %ecx, 0x12345678
    # addl %edx, 0x12345678
    # addl %ebx, 0x12345678
    # addl %esp, 0x12345678
    # addl %ebp, 0x12345678
    # addl %esi, 0x12345678
    # addl %edi, 0x12345678

    # # ============================
    # # r/m = 110 → [ESI]
    # # ============================
    # addl %eax, (%esi)
    # addl %ecx, (%esi)
    # addl %edx, (%esi)
    # addl %ebx, (%esi)
    # addl %esp, (%esi)
    # addl %ebp, (%esi)
    # addl %esi, (%esi)
    # addl %edi, (%esi)

    # # ============================
    # # r/m = 111 → [EDI]
    # # ============================
    # addl %eax, (%edi)
    # addl %ecx, (%edi)
    # addl %edx, (%edi)
    # addl %ebx, (%edi)
    # addl %esp, (%edi)
    # addl %ebp, (%edi)
    # addl %esi, (%edi)
    # addl %edi, (%edi)







    # # ========= MOD = 01 =========
    # # ============================
    # # r/m = 000 → [EAX + disp8]
    # # ============================
    # addl %eax, 0x7F(%eax)
    # addl %ecx, 0x7F(%eax)
    # addl %edx, 0x7F(%eax)
    # addl %ebx, 0x7F(%eax)
    # addl %esp, 0x7F(%eax)
    # addl %ebp, 0x7F(%eax)
    # addl %esi, 0x7F(%eax)
    # addl %edi, 0x7F(%eax)

    # # ============================
    # # r/m = 001 → [ECX + disp8]
    # # ============================
    # addl %eax, 0x7F(%ecx)
    # addl %ecx, 0x7F(%ecx)
    # addl %edx, 0x7F(%ecx)
    # addl %ebx, 0x7F(%ecx)
    # addl %esp, 0x7F(%ecx)
    # addl %ebp, 0x7F(%ecx)
    # addl %esi, 0x7F(%ecx)
    # addl %edi, 0x7F(%ecx)

    # # ============================
    # # r/m = 010 → [EDX + disp8]
    # # ============================
    # addl %eax, 0x7F(%edx)
    # addl %ecx, 0x7F(%edx)
    # addl %edx, 0x7F(%edx)
    # addl %ebx, 0x7F(%edx)
    # addl %esp, 0x7F(%edx)
    # addl %ebp, 0x7F(%edx)
    # addl %esi, 0x7F(%edx)
    # addl %edi, 0x7F(%edx)

    # # ============================
    # # r/m = 011 → [EBX + disp8]
    # # ============================
    # addl %eax, 0x7F(%ebx)
    # addl %ecx, 0x7F(%ebx)
    # addl %edx, 0x7F(%ebx)
    # addl %ebx, 0x7F(%ebx)
    # addl %esp, 0x7F(%ebx)
    # addl %ebp, 0x7F(%ebx)
    # addl %esi, 0x7F(%ebx)
    # addl %edi, 0x7F(%ebx)

    # # ============================
    # # r/m = 100 → SIB (disp8)
    # # ============================
    # addl %eax, 0x7F(%eax,%ecx,1)
    # addl %ecx, 0x7F(%ebx,%edx,2)
    # addl %edx, 0x7F(%ecx,%esi,4)
    # addl %ebx, 0x7F(%edx,%edi,8)
    # addl %esp, 0x7F(%esi,%eax,2)
    # addl %ebp, 0x7F(%edi,%ebx,4)
    # addl %esi, 0x7F(%eax,%edx,8)
    # addl %edi, 0x7F(%ecx,%eax,1)

    # # ============================
    # # r/m = 101 → [EBP + disp8]
    # # (NOTE: no longer disp32 special case!)
    # # ============================
    # addl %eax, 0x7F(%ebp)
    # addl %ecx, 0x7F(%ebp)
    # addl %edx, 0x7F(%ebp)
    # addl %ebx, 0x7F(%ebp)
    # addl %esp, 0x7F(%ebp)
    # addl %ebp, 0x7F(%ebp)
    # addl %esi, 0x7F(%ebp)
    # addl %edi, 0x7F(%ebp)

    # # ============================
    # # r/m = 110 → [ESI + disp8]
    # # ============================
    # addl %eax, 0x7F(%esi)
    # addl %ecx, 0x7F(%esi)
    # addl %edx, 0x7F(%esi)
    # addl %ebx, 0x7F(%esi)
    # addl %esp, 0x7F(%esi)
    # addl %ebp, 0x7F(%esi)
    # addl %esi, 0x7F(%esi)
    # addl %edi, 0x7F(%esi)

    # # ============================
    # # r/m = 111 → [EDI + disp8]
    # # ============================
    # addl %eax, 0x7F(%edi)
    # addl %ecx, 0x7F(%edi)
    # addl %edx, 0x7F(%edi)
    # addl %ebx, 0x7F(%edi)
    # addl %esp, 0x7F(%edi)
    # addl %ebp, 0x7F(%edi)
    # addl %esi, 0x7F(%edi)
    # addl %edi, 0x7F(%edi)







    # # ========= MOD = 10 =========
    # # ============================
    # # r/m = 000 → [EAX + disp32]
    # # ============================
    # addl %eax, 0x12345678(%eax)
    # addl %ecx, 0x12345678(%eax)
    # addl %edx, 0x12345678(%eax)
    # addl %ebx, 0x12345678(%eax)
    # addl %esp, 0x12345678(%eax)
    # addl %ebp, 0x12345678(%eax)
    # addl %esi, 0x12345678(%eax)
    # addl %edi, 0x12345678(%eax)

    # # ============================
    # # r/m = 001 → [ECX + disp32]
    # # ============================
    # addl %eax, 0x12345678(%ecx)
    # addl %ecx, 0x12345678(%ecx)
    # addl %edx, 0x12345678(%ecx)
    # addl %ebx, 0x12345678(%ecx)
    # addl %esp, 0x12345678(%ecx)
    # addl %ebp, 0x12345678(%ecx)
    # addl %esi, 0x12345678(%ecx)
    # addl %edi, 0x12345678(%ecx)

    # # ============================
    # # r/m = 010 → [EDX + disp32]
    # # ============================
    # addl %eax, 0x12345678(%edx)
    # addl %ecx, 0x12345678(%edx)
    # addl %edx, 0x12345678(%edx)
    # addl %ebx, 0x12345678(%edx)
    # addl %esp, 0x12345678(%edx)
    # addl %ebp, 0x12345678(%edx)
    # addl %esi, 0x12345678(%edx)
    # addl %edi, 0x12345678(%edx)

    # # ============================
    # # r/m = 011 → [EBX + disp32]
    # # ============================
    # addl %eax, 0x12345678(%ebx)
    # addl %ecx, 0x12345678(%ebx)
    # addl %edx, 0x12345678(%ebx)
    # addl %ebx, 0x12345678(%ebx)
    # addl %esp, 0x12345678(%ebx)
    # addl %ebp, 0x12345678(%ebx)
    # addl %esi, 0x12345678(%ebx)
    # addl %edi, 0x12345678(%ebx)

    # # ============================
    # # r/m = 100 → SIB (disp32)
    # # ============================
    # addl %eax, 0x12345678(%eax,%ecx,1)
    # addl %ecx, 0x12345678(%ebx,%edx,2)
    # addl %edx, 0x12345678(%ecx,%esi,4)
    # addl %ebx, 0x12345678(%edx,%edi,8)
    # addl %esp, 0x12345678(%esi,%eax,2)
    # addl %ebp, 0x12345678(%edi,%ebx,4)
    # addl %esi, 0x12345678(%eax,%edx,8)
    # addl %edi, 0x12345678(%ecx,%eax,1)

    # # ============================
    # # r/m = 101 → [EBP + disp32]
    # # ============================
    # addl %eax, 0x12345678(%ebp)
    # addl %ecx, 0x12345678(%ebp)
    # addl %edx, 0x12345678(%ebp)
    # addl %ebx, 0x12345678(%ebp)
    # addl %esp, 0x12345678(%ebp)
    # addl %ebp, 0x12345678(%ebp)
    # addl %esi, 0x12345678(%ebp)
    # addl %edi, 0x12345678(%ebp)

    # # ============================
    # # r/m = 110 → [ESI + disp32]
    # # ============================
    # addl %eax, 0x12345678(%esi)
    # addl %ecx, 0x12345678(%esi)
    # addl %edx, 0x12345678(%esi)
    # addl %ebx, 0x12345678(%esi)
    # addl %esp, 0x12345678(%esi)
    # addl %ebp, 0x12345678(%esi)
    # addl %esi, 0x12345678(%esi)
    # addl %edi, 0x12345678(%esi)

    # # ============================
    # # r/m = 111 → [EDI + disp32]
    # # ============================
    # addl %eax, 0x12345678(%edi)
    # addl %ecx, 0x12345678(%edi)
    # addl %edx, 0x12345678(%edi)
    # addl %ebx, 0x12345678(%edi)
    # addl %esp, 0x12345678(%edi)
    # addl %ebp, 0x12345678(%edi)
    # addl %esi, 0x12345678(%edi)
    # addl %edi, 0x12345678(%edi)







    # # ========= MOD = 11 =========
    # # ============================
    # # r/m = EAX
    # # ============================
    # addl %eax, %eax
    # addl %ecx, %eax
    # addl %edx, %eax
    # addl %ebx, %eax
    # addl %esp, %eax
    # addl %ebp, %eax
    # addl %esi, %eax
    # addl %edi, %eax

    # # ============================
    # # r/m = ECX
    # # ============================
    # addl %eax, %ecx
    # addl %ecx, %ecx
    # addl %edx, %ecx
    # addl %ebx, %ecx
    # addl %esp, %ecx
    # addl %ebp, %ecx
    # addl %esi, %ecx
    # addl %edi, %ecx

    # # ============================
    # # r/m = EDX
    # # ============================
    # addl %eax, %edx
    # addl %ecx, %edx
    # addl %edx, %edx
    # addl %ebx, %edx
    # addl %esp, %edx
    # addl %ebp, %edx
    # addl %esi, %edx
    # addl %edi, %edx

    # # ============================
    # # r/m = EBX
    # # ============================
    # addl %eax, %ebx
    # addl %ecx, %ebx
    # addl %edx, %ebx
    # addl %ebx, %ebx
    # addl %esp, %ebx
    # addl %ebp, %ebx
    # addl %esi, %ebx
    # addl %edi, %ebx

    # # ============================
    # # r/m = ESP
    # # ============================
    # addl %eax, %esp
    # addl %ecx, %esp
    # addl %edx, %esp
    # addl %ebx, %esp
    # addl %esp, %esp
    # addl %ebp, %esp
    # addl %esi, %esp
    # addl %edi, %esp

    # # ============================
    # # r/m = EBP
    # # ============================
    # addl %eax, %ebp
    # addl %ecx, %ebp
    # addl %edx, %ebp
    # addl %ebx, %ebp
    # addl %esp, %ebp
    # addl %ebp, %ebp
    # addl %esi, %ebp
    # addl %edi, %ebp

    # # ============================
    # # r/m = ESI
    # # ============================
    # addl %eax, %esi
    # addl %ecx, %esi
    # addl %edx, %esi
    # addl %ebx, %esi
    # addl %esp, %esi
    # addl %ebp, %esi
    # addl %esi, %esi
    # addl %edi, %esi

    # # ============================
    # # r/m = EDI
    # # ============================
    # addl %eax, %edi
    # addl %ecx, %edi
    # addl %edx, %edi
    # addl %ebx, %edi
    # addl %esp, %edi
    # addl %ebp, %edi
    # addl %esi, %edi
    # addl %edi, %edi




































    # # ========= MOD = 00 =========
    # # ============================
    # # r/m = 000 → [EAX]
    # # ============================
    # addw %ax, (%eax)
    # addw %cx, (%eax)
    # addw %dx, (%eax)
    # addw %bx, (%eax)
    # addw %sp, (%eax)
    # addw %bp, (%eax)
    # addw %si, (%eax)
    # addw %di, (%eax)

    # # ============================
    # # r/m = 001 → [ECX]
    # # ============================
    # addw %ax, (%ecx)
    # addw %cx, (%ecx)
    # addw %dx, (%ecx)
    # addw %bx, (%ecx)
    # addw %sp, (%ecx)
    # addw %bp, (%ecx)
    # addw %si, (%ecx)
    # addw %di, (%ecx)

    # # ============================
    # # r/m = 010 → [EDX]
    # # ============================
    # addw %ax, (%edx)
    # addw %cx, (%edx)
    # addw %dx, (%edx)
    # addw %bx, (%edx)
    # addw %sp, (%edx)
    # addw %bp, (%edx)
    # addw %si, (%edx)
    # addw %di, (%edx)

    # # ============================
    # # r/m = 011 → [EBX]
    # # ============================
    # addw %ax, (%ebx)
    # addw %cx, (%ebx)
    # addw %dx, (%ebx)
    # addw %bx, (%ebx)
    # addw %sp, (%ebx)
    # addw %bp, (%ebx)
    # addw %si, (%ebx)
    # addw %di, (%ebx)

    # # ============================
    # # r/m = 100 → SIB
    # # ============================
    # addw %ax, (%eax,%ecx,1)
    # addw %cx, (%ebx,%edx,2)
    # addw %dx, (%ecx,%esi,4)
    # addw %bx, (%edx,%edi,8)
    # addw %sp, (%esi,%eax,2)
    # addw %bp, (%edi,%ebx,4)
    # addw %si, (%eax,%edx,8)
    # addw %di, (%ecx,%eax,1)

    # # ============================
    # # r/m = 101 → [disp32]
    # # ============================
    # addw %ax, 0x12345678
    # addw %cx, 0x12345678
    # addw %dx, 0x12345678
    # addw %bx, 0x12345678
    # addw %sp, 0x12345678
    # addw %bp, 0x12345678
    # addw %si, 0x12345678
    # addw %di, 0x12345678

    # # ============================
    # # r/m = 110 → [ESI]
    # # ============================
    # addw %ax, (%esi)
    # addw %cx, (%esi)
    # addw %dx, (%esi)
    # addw %bx, (%esi)
    # addw %sp, (%esi)
    # addw %bp, (%esi)
    # addw %si, (%esi)
    # addw %di, (%esi)

    # # ============================
    # # r/m = 111 → [EDI]
    # # ============================
    # addw %ax, (%edi)
    # addw %cx, (%edi)
    # addw %dx, (%edi)
    # addw %bx, (%edi)
    # addw %sp, (%edi)
    # addw %bp, (%edi)
    # addw %si, (%edi)
    # addw %di, (%edi)



































    # ========= MOD = 00 =========
    # ============================
    # r/m = 000 → [EAX]
    # ============================
    addb %al, (%eax)
    addb %cl, (%eax)
    addb %dl, (%eax)
    addb %bl, (%eax)
    addb %ah, (%eax)
    addb %ch, (%eax)
    addb %dh, (%eax)
    addb %bh, (%eax)

    # ============================
    # r/m = 001 → [ECX]
    # ============================
    addb %al, (%ecx)
    addb %cl, (%ecx)
    addb %dl, (%ecx)
    addb %bl, (%ecx)
    addb %ah, (%ecx)
    addb %ch, (%ecx)
    addb %dh, (%ecx)
    addb %bh, (%ecx)

    # ============================
    # r/m = 010 → [EDX]
    # ============================
    addb %al, (%edx)
    addb %cl, (%edx)
    addb %dl, (%edx)
    addb %bl, (%edx)
    addb %ah, (%edx)
    addb %ch, (%edx)
    addb %dh, (%edx)
    addb %bh, (%edx)

    # ============================
    # r/m = 011 → [EBX]
    # ============================
    addb %al, (%ebx)
    addb %cl, (%ebx)
    addb %dl, (%ebx)
    addb %bl, (%ebx)
    addb %ah, (%ebx)
    addb %ch, (%ebx)
    addb %dh, (%ebx)
    addb %bh, (%ebx)

    # ============================
    # r/m = 100 → SIB
    # ============================
    addb %al, (%eax,%ecx,1)
    addb %cl, (%ebx,%edx,2)
    addb %dl, (%ecx,%esi,4)
    addb %bl, (%edx,%edi,8)
    addb %ah, (%esi,%eax,2)
    addb %ch, (%edi,%ebx,4)
    addb %dh, (%eax,%edx,8)
    addb %bh, (%ecx,%eax,1)

    # ============================
    # r/m = 101 → [disp32]
    # ============================
    addb %al, 0x12345678
    addb %cl, 0x12345678
    addb %dl, 0x12345678
    addb %bl, 0x12345678
    addb %ah, 0x12345678
    addb %ch, 0x12345678
    addb %dh, 0x12345678
    addb %bh, 0x12345678

    # ============================
    # r/m = 110 → [ESI]
    # ============================
    addb %al, (%esi)
    addb %cl, (%esi)
    addb %dl, (%esi)
    addb %bl, (%esi)
    addb %ah, (%esi)
    addb %ch, (%esi)
    addb %dh, (%esi)
    addb %bh, (%esi)

    # ============================
    # r/m = 111 → [EDI]
    # ============================
    addb %al, (%edi)
    addb %cl, (%edi)
    addb %dl, (%edi)
    addb %bl, (%edi)
    addb %ah, (%edi)
    addb %ch, (%edi)
    addb %dh, (%edi)
    addb %bh, (%edi)


    # halt
    hlt