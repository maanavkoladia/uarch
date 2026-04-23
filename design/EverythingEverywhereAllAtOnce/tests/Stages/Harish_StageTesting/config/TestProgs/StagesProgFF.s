.org 0x1000
.code
.global _start

# ============================================================
# FF-opcode test suite  (x86-32, AT&T syntax)
# ------------------------------------------------------------
# FF is a "group" opcode; the /reg field of the ModR/M byte
# selects the operation:
#
#   FF /2  =  CALL r/m32   (near, absolute indirect)
#   FF /4  =  JMP  r/m32   (near, absolute indirect)
#   FF /6  =  PUSH r/m32   (push 32-bit memory/register)
#
# Each test leaves a unique fingerprint in a dedicated
# register so the final state reveals which tests passed.
#
#   EAX = 0xAAAAAAAA   TEST 1  jmp  *%reg     FF /4 (reg)
#   EBX = 0xBBBBBBBB   TEST 2  jmp  *mem      FF /4 (mem)
#   ECX = 0xCCCCCCCC   TEST 3  call *%reg     FF /2 (reg)
#   EDX = 0xEEEEEEEE   TEST 4  call *mem      FF /2 (mem)
#   ESI = 0x5A5A5A5A   TEST 5  pushl mem      FF /6 (mem abs)
#   EDI = 0x6D6D6D6D   TEST 6  pushl (%reg)   FF /6 (mem reg)
# ============================================================

_start:

    # =================================================
    # TEST 0: Known state
    # =================================================
    movl $0, %eax
    movl $0, %ebx
    movl $0, %ecx
    movl $0, %edx
    movl $0, %esi
    movl $0, %edi
    movl $0, %ebp
    movl $0x200, %esp


    # =================================================
    # TEST 1: JMP indirect through REGISTER   (FF /4)
    #   jmp *%ebp   ->   FF E5
    # =================================================
    movl $0x11111111, %eax
    movl $T1_target, %ebp
    jmp  *%ebp              # ebp = 0x1039

    movl $0xDEADBEEF, %eax       # SHOULD NOT EXECUTE

T1_target:                      # 0x1039
    movl $0xAAAAAAAA, %eax
    # EXPECT: EAX = 0xAAAAAAAA
    jmp T2_start


    # =================================================
    # TEST 2: JMP indirect through MEMORY      (FF /4)
    #   jmp *T2_ptr   ->   FF 25 [disp32]
    # =================================================
T2_start:
    movl $0x22222222, %ebx
    jmp  *T2_ptr                # t2_ptr = 1050

    movl $0xDEADBEEF, %ebx       # SHOULD NOT EXECUTE

T2_target:                  # 0x1050
    movl $0xBBBBBBBB, %ebx
    # EXPECT: EBX = 0xBBBBBBBB
    jmp T3_start


    # =================================================
    # TEST 3: CALL indirect through REGISTER  (FF /2)
    #   call *%ebp   ->   FF D5
    # =================================================
T3_start:
    movl $0x33333333, %ecx
    movl $T3_func, %ebp
    call *%ebp

T3_after:
    # EXPECT: ECX = 0xCCCCCCCC
    jmp T4_start

    movl $0xDEADBEEF, %ecx       # SHOULD NOT EXECUTE

T3_func:
    movl $0xCCCCCCCC, %ecx
    ret


    # =================================================
    # TEST 4: CALL indirect through MEMORY    (FF /2)
    #   call *T4_ptr   ->   FF 15 [disp32]
    # =================================================
T4_start:
    movl $0x44444444, %edx
    call *T4_ptr

T4_after:
    # EXPECT: EDX = 0xEEEEEEEE
    jmp T5_start

    movl $0xDEADBEEF, %edx       # SHOULD NOT EXECUTE

T4_func:
    movl $0xEEEEEEEE, %edx
    ret


    # =================================================
    # TEST 5: PUSH absolute memory            (FF /6)
    #   pushl T5_value   ->   FF 35 [disp32]
    #   Verified by popping into ESI.
    # =================================================
T5_start:
    movl $0x55555555, %esi
    pushl T5_value               # FF /6   (mem-abs form)
    popl  %esi

    # EXPECT: ESI = 0x5A5A5A5A
    jmp T6_start


    # =================================================
    # TEST 6: PUSH via register indirect      (FF /6)
    #   pushl (%ebp)   ->   FF 75 00
    #   Verified by popping into EDI.
    # =================================================
T6_start:
    movl $0x66666666, %edi
    movl $T6_value, %ebp
    pushl (%ebp)                 # FF /6   (mem-via-reg form)
    popl  %edi

    # EXPECT: EDI = 0x6D6D6D6D


    # =================================================
    # FINAL VERIFICATION
    # =================================================
done:
    # EXPECTED FINAL STATE:
    #   EAX = 0xAAAAAAAA
    #   EBX = 0xBBBBBBBB
    #   ECX = 0xCCCCCCCC
    #   EDX = 0xEEEEEEEE
    #   ESI = 0x5A5A5A5A
    #   EDI = 0x6D6D6D6D
    hlt


    # =================================================
    # DATA (placed after hlt so it is never executed)
    # =================================================
T2_ptr:
    .long T2_target

T4_ptr:
    .long T4_func

T5_value:
    .long 0x5A5A5A5A

T6_value:
    .long 0x6D6D6D6D