#define __CS0__ 0x0000
#define __DS0__ 0x0500
#define __ES0__ 0x0400

.org 0x00000000
.code
.global _start
_start:
    movl    $__DS0__, %eax
    movw    %ax, %ds
    movl    $__ES0__, %eax
    movw    %ax, %es

    movl    $0x0300, %eax
    movw    %ax, %fs

   movl    $0x0600, %eax
    movw    %ax, %ss
    movl    $0x0FFF, %esp


    cld

    /* =====================================================
       SETUP
    ===================================================== */
    movl    $0xAABBCCDD, %ds:0
    movl    $0x11223344, %ds:4
    movl    $0x55667788, %ds:8
    movl    $0x99AABBCC, %ds:12
    movl    $0xDDEEFF00, %ds:16
    movl    $0xCAFEBABE, %ds:20
    movl    $0xDEADBEEF, %ds:24
    movl    $0x12345678, %ds:28

    movb    $0xAA, %ds:128
    movb    $0xBB, %ds:129
    movb    $0xCC, %ds:130
    movb    $0xDD, %ds:131
    movb    $0x11, %ds:132
    movb    $0x22, %ds:133
    movb    $0x33, %ds:134
    movb    $0x44, %ds:135

    movw    $0xABCD, %ds:256
    movw    $0x1234, %ds:258
    movw    $0x5678, %ds:260
    movw    $0x9ABC, %ds:262

    movl    $0xFEDCBA98, %fs:0
    movl    $0x76543210, %fs:4

    jmp     _tests

    /* =====================================================
       SUBROUTINE: check
       In:  EAX = actual value
            EBX = expected value
            EDX = address to jump to on failure
       Clobbers: EAX, EBX
       Preserves: EBP (sentinel), ECX, EDX, ESI, EDI
    ===================================================== */
check:
    not     %ebx
    add     $1,   %ebx
    add     %ebx, %eax
    jne     _check_fail
    ret
_check_fail:
    jmp     *%edx

    /* =====================================================
       SUBROUTINE: check_zero
       In:  EAX = value that must be zero
            EDX = address to jump to on failure
       Clobbers: EAX
       Preserves: EBP (sentinel), EBX, ECX, EDX, ESI, EDI
    ===================================================== */
check_zero:
    add     $0,   %eax
    jne     _check_zero_fail
    ret
_check_zero_fail:
    jmp     *%edx

    /* =====================================================
       TESTS
       Convention:
         EBP = sentinel for current test (set once, never touched by check)
         EDX = fail label for current test (set once per test)
         EAX = actual value  (set before each call)
         EBX = expected value (set before each call)
    ===================================================== */
_tests:

    /* ---------------------------------------------------
       T1: rep movsl — DS:0..12 → ES:0..12
       Check: ES:0  = 0xAABBCCDD
              ES:4  = 0x11223344
              ES:8  = 0x55667788
              ES:12 = 0x99AABBCC
              ESI=16,  EDI=16,  ECX=0
    --------------------------------------------------- */
    movl    $0x00000001, %ebp
    movl    $fail_t1,    %edx
    movl    $0,  %esi
    movl    $0,  %edi
    movl    $4,  %ecx
    rep movsl

    andl    $0,          %ebx
    movl    %es:(%ebx),  %eax        /* ES:0 */
    movl    $0xAABBCCDD, %ebx
    call    check

    movl    $4,          %ebx
    movl    %es:(%ebx),  %eax        /* ES:4 */
    movl    $0x11223344, %ebx
    call    check

    movl    $8,          %ebx
    movl    %es:(%ebx),  %eax        /* ES:8 */
    movl    $0x55667788, %ebx
    call    check

    movl    $12,         %ebx
    movl    %es:(%ebx),  %eax        /* ES:12 */
    movl    $0x99AABBCC, %ebx
    call    check

    movl    %esi,        %eax
    movl    $16,         %ebx
    call    check

    movl    %edi,        %eax
    movl    $16,         %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t2
fail_t1:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T2: rep movsl — DS:16..28 → ES:16..28
       Check: ES:16 = 0xDDEEFF00
              ES:20 = 0xCAFEBABE
              ES:24 = 0xDEADBEEF
              ES:28 = 0x12345678
              ESI=32,  EDI=32,  ECX=0
    --------------------------------------------------- */
_t2:
    movl    $0x00000002, %ebp
    movl    $fail_t2,    %edx
    movl    $16, %esi
    movl    $16, %edi
    movl    $4,  %ecx
    rep movsl

    movl    $16,         %ebx
    movl    %es:(%ebx),  %eax        /* ES:16 */
    movl    $0xDDEEFF00, %ebx
    call    check

    movl    $20,         %ebx
    movl    %es:(%ebx),  %eax        /* ES:20 */
    movl    $0xCAFEBABE, %ebx
    call    check

    movl    $24,         %ebx
    movl    %es:(%ebx),  %eax        /* ES:24 */
    movl    $0xDEADBEEF, %ebx
    call    check

    movl    $28,         %ebx
    movl    %es:(%ebx),  %eax        /* ES:28 */
    movl    $0x12345678, %ebx
    call    check

    movl    %esi,        %eax
    movl    $32,         %ebx
    call    check

    movl    %edi,        %eax
    movl    $32,         %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t3
fail_t2:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T3: rep movsl — DS:0..28 → ES:64..92
       Check: ES:64 = 0xAABBCCDD
              ES:92 = 0x12345678
              ESI=32,  EDI=96,  ECX=0
    --------------------------------------------------- */
_t3:
    movl    $0x00000003, %ebp
    movl    $fail_t3,    %edx
    movl    $0,  %esi
    movl    $64, %edi
    movl    $8,  %ecx
    rep movsl

    movl    $64,         %ebx
    movl    %es:(%ebx),  %eax        /* ES:64 */
    movl    $0xAABBCCDD, %ebx
    call    check

    movl    $92,         %ebx
    movl    %es:(%ebx),  %eax        /* ES:92 */
    movl    $0x12345678, %ebx
    call    check

    movl    %esi,        %eax
    movl    $32,         %ebx
    call    check

    movl    %edi,        %eax
    movl    $96,         %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t4
fail_t3:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T4: rep movsl STD — DS:28..16 (reverse) → ES:128..140
       Source DS:28=0x12345678, DS:24=0xDEADBEEF,
              DS:20=0xCAFEBABE, DS:16=0xDDEEFF00
       With STD, ESI=28, EDI=140, ECX=4:
         iter0: DS:28 → ES:140, ESI=24, EDI=136
         iter1: DS:24 → ES:136, ESI=20, EDI=132
         iter2: DS:20 → ES:132, ESI=16, EDI=128
         iter3: DS:16 → ES:128, ESI=12, EDI=124
       Check: ES:128 = 0xDDEEFF00
              ES:132 = 0xCAFEBABE
              ES:136 = 0xDEADBEEF
              ES:140 = 0x12345678
              ESI=12,  EDI=124,  ECX=0
    --------------------------------------------------- */
_t4:
    movl    $0x00000004, %ebp
    movl    $fail_t4,    %edx
    std
    movl    $28,  %esi
    movl    $140, %edi
    movl    $4,   %ecx
    rep movsl
    cld

    movl    $128,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:128 = DS:16 = 0xDDEEFF00 */
    movl    $0xDDEEFF00, %ebx
    call    check

    movl    $132,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:132 = DS:20 = 0xCAFEBABE */
    movl    $0xCAFEBABE, %ebx
    call    check

    movl    $136,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:136 = DS:24 = 0xDEADBEEF */
    movl    $0xDEADBEEF, %ebx
    call    check

    movl    $140,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:140 = DS:28 = 0x12345678 */
    movl    $0x12345678, %ebx
    call    check

    movl    %esi,        %eax
    movl    $12,         %ebx
    call    check

    movl    %edi,        %eax
    movl    $124,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t5
fail_t4:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T5: repe cmpsl — full match DS:0..12 vs ES:0..12
       Check: ZF=1,  ECX=0,  ESI=16,  EDI=16
    --------------------------------------------------- */
_t5:
    movl    $0x00000005, %ebp
    movl    $fail_t5,    %edx
    movl    $0, %esi
    movl    $0, %edi
    movl    $4, %ecx
    repe cmpsl

    jne     fail_t5

    movl    %ecx,        %eax
    call    check_zero

    movl    %esi,        %eax
    movl    $16,         %ebx
    call    check

    movl    %edi,        %eax
    movl    $16,         %ebx
    call    check

    movl    %ebp,        %eax
    jmp     _t6
fail_t5:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T6: repe cmpsl — full match DS:0..28 vs ES:64..92
       Check: ZF=1,  ECX=0,  ESI=32,  EDI=96
    --------------------------------------------------- */
_t6:
    movl    $0x00000006, %ebp
    movl    $fail_t6,    %edx
    movl    $0,  %esi
    movl    $64, %edi
    movl    $8,  %ecx
    repe cmpsl

    jne     fail_t6

    movl    %ecx,        %eax
    call    check_zero

    movl    %esi,        %eax
    movl    $32,         %ebx
    call    check

    movl    %edi,        %eax
    movl    $96,         %ebx
    call    check

    movl    %ebp,        %eax
    jmp     _t7
fail_t6:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T7: repe cmpsl — mismatch at dword 1 (ES:4 = 0xFFFFFFFF)
       Check: ZF=0,  ECX=6,  ESI=8,  EDI=8
    --------------------------------------------------- */
_t7:
    movl    $0x00000007, %ebp
    movl    $fail_t7,    %edx
    movl    $4,          %ebx
    movl    $0xFFFFFFFF, %es:(%ebx)  /* ES:4 = 0xFFFFFFFF */
    movl    $0, %esi
    movl    $0, %edi
    movl    $8, %ecx
    repe cmpsl

    jne     _t7_zf_ok
    jmp     fail_t7
_t7_zf_ok:
    movl    %ecx,        %eax
    movl    $6,          %ebx
    call    check

    movl    %esi,        %eax
    movl    $8,          %ebx
    call    check

    movl    %edi,        %eax
    movl    $8,          %ebx
    call    check

    movl    %ebp,        %eax
    jmp     _t8
fail_t7:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T8: repe cmpsl — mismatch at dword 2 (ES:16 = 0xFFFFFFFF)
       Restore ES:4. Compare DS:8..20 vs ES:8..20.
       Check: ZF=0,  ECX=0,  ESI=20,  EDI=20
    --------------------------------------------------- */
_t8:
    movl    $0x00000008, %ebp
    movl    $fail_t8,    %edx
    movl    $4,          %ebx
    movl    $0x11223344, %es:(%ebx)  /* restore ES:4 */
    movl    $16,         %ebx
    movl    $0xFFFFFFFF, %es:(%ebx)  /* ES:16 = 0xFFFFFFFF */
    movl    $8,  %esi
    movl    $8,  %edi
    movl    $3,  %ecx
    repe cmpsl

    jne     _t8_zf_ok
    jmp     fail_t8
_t8_zf_ok:
    movl    %ecx,        %eax
    call    check_zero

    movl    %esi,        %eax
    movl    $20,         %ebx
    call    check

    movl    %edi,        %eax
    movl    $20,         %ebx
    call    check

    movl    %ebp,        %eax
    jmp     _t9
fail_t8:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* =====================================================
          SECTION 2: REP MOVSB
    ===================================================== */

    /* ---------------------------------------------------
       T9: rep movsb — DS:128..131 → ES:200..203
       Check: ES:200..203 = 0xDDCCBBAA
              ESI=132,  EDI=204,  ECX=0
    --------------------------------------------------- */
_t9:
    movl    $0x00000009, %ebp
    movl    $fail_t9,    %edx
    movl    $128, %esi
    movl    $200, %edi
    movl    $4,   %ecx
    rep movsb

    movl    $200,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:200 */
    movl    $0xDDCCBBAA, %ebx
    call    check

    movl    %esi,        %eax
    movl    $132,        %ebx
    call    check

    movl    %edi,        %eax
    movl    $204,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t10
fail_t9:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T10: rep movsb — DS:128..135 → ES:210..217
       Check: ES:210..213 = 0xDDCCBBAA
              ES:214..217 = 0x44332211
              ESI=136,  EDI=218,  ECX=0
    --------------------------------------------------- */
_t10:
    movl    $0x0000000A, %ebp
    movl    $fail_t10,   %edx
    movl    $128, %esi
    movl    $210, %edi
    movl    $8,   %ecx
    rep movsb

    movl    $210,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:210 */
    movl    $0xDDCCBBAA, %ebx
    call    check

    movl    $214,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:214 */
    movl    $0x44332211, %ebx
    call    check

    movl    %esi,        %eax
    movl    $136,        %ebx
    call    check

    movl    %edi,        %eax
    movl    $218,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t11
fail_t10:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T11: rep movsb STD — reverse DS:131..128 → ES:223..220
       ESI=131, EDI=223
       Check: ES:220..223 = 0xDDCCBBAA
              ESI=127,  EDI=219,  ECX=0
    --------------------------------------------------- */
_t11:
    movl    $0x0000000B, %ebp
    movl    $fail_t11,   %edx
    std
    movl    $131, %esi
    movl    $223, %edi
    movl    $4,   %ecx
    rep movsb
    cld

    movl    $220,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:220 */
    movl    $0xDDCCBBAA, %ebx
    call    check

    movl    %esi,        %eax
    movl    $127,        %ebx
    call    check

    movl    %edi,        %eax
    movl    $219,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t12
fail_t11:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* =====================================================
          SECTION 3: REP MOVSW
    ===================================================== */

    /* ---------------------------------------------------
       T12: rep movsw — DS:256..262 → ES:300..306
       Check: ES:300..303 = 0x1234ABCD
              ES:304..307 = 0x9ABC5678
              ESI=264,  EDI=308,  ECX=0
    --------------------------------------------------- */
_t12:
    movl    $0x0000000C, %ebp
    movl    $fail_t12,   %edx
    movl    $256, %esi
    movl    $300, %edi
    movl    $4,   %ecx
    rep movsw

    movl    $300,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:300 */
    movl    $0x1234ABCD, %ebx
    call    check

    movl    $304,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:304 */
    movl    $0x9ABC5678, %ebx
    call    check

    movl    %esi,        %eax
    movl    $264,        %ebx
    call    check

    movl    %edi,        %eax
    movl    $308,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t13
fail_t12:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T13: rep movsw STD — reverse DS:262..256 → ES:314..308
       ESI=262, EDI=314
       Check: ES:308..311 = 0x1234ABCD
              ES:312..315 = 0x9ABC5678
              ESI=254,  EDI=306,  ECX=0
    --------------------------------------------------- */
_t13:
    movl    $0x0000000D, %ebp
    movl    $fail_t13,   %edx
    std
    movl    $262, %esi
    movl    $314, %edi
    movl    $4,   %ecx
    rep movsw
    cld

    movl    $308,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:308 */
    movl    $0x1234ABCD, %ebx
    call    check

    movl    $312,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:312 */
    movl    $0x9ABC5678, %ebx
    call    check

    movl    %esi,        %eax
    movl    $254,        %ebx
    call    check

    movl    %edi,        %eax
    movl    $306,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t14
fail_t13:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* =====================================================
          SECTION 4: SEGMENT OVERRIDE (FS source)
    ===================================================== */

    /* ---------------------------------------------------
       T14: rep movsl FS override — FS:0..4 → ES:400..404
       Check: ES:400 = 0xFEDCBA98
              ES:404 = 0x76543210
              ESI=8,  EDI=408,  ECX=0
    --------------------------------------------------- */
_t14:
    movl    $0x0000000E, %ebp
    movl    $fail_t14,   %edx
    movl    $0,   %esi
    movl    $400, %edi
    movl    $2,   %ecx
    rep fs movsl

    movl    $400,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:400 */
    movl    $0xFEDCBA98, %ebx
    call    check

    movl    $404,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:404 */
    movl    $0x76543210, %ebx
    call    check

    movl    %esi,        %eax
    movl    $8,          %ebx
    call    check

    movl    %edi,        %eax
    movl    $408,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t15
fail_t14:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T15: rep movsb FS override — FS:0..3 → ES:410..413
       Check: ES:410..413 = 0xFEDCBA98
              ESI=4,  EDI=414,  ECX=0
    --------------------------------------------------- */
_t15:
    movl    $0x0000000F, %ebp
    movl    $fail_t15,   %edx
    movl    $0,   %esi
    movl    $410, %edi
    movl    $4,   %ecx
    rep fs movsb

    movl    $410,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:410 */
    movl    $0xFEDCBA98, %ebx
    call    check

    movl    %esi,        %eax
    movl    $4,          %ebx
    call    check

    movl    %edi,        %eax
    movl    $414,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t16
fail_t15:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T16: rep movsw FS override — FS:0..2 → ES:420..422
       Check: ES:420..423 = 0xFEDCBA98
              ESI=4,  EDI=424,  ECX=0
    --------------------------------------------------- */
_t16:
    movl    $0x00000010, %ebp
    movl    $fail_t16,   %edx
    movl    $0,   %esi
    movl    $420, %edi
    movl    $2,   %ecx
    rep fs movsw

    movl    $420,        %ebx
    movl    %es:(%ebx),  %eax        /* ES:420 */
    movl    $0xFEDCBA98, %ebx
    call    check

    movl    %esi,        %eax
    movl    $4,          %ebx
    call    check

    movl    %edi,        %eax
    movl    $424,        %ebx
    call    check

    movl    %ecx,        %eax
    call    check_zero

    movl    %ebp,        %eax
    jmp     _t17
fail_t16:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt

    /* ---------------------------------------------------
       T17: repe cmpsl FS override — full match FS:0..4 vs ES:400..404
       Check: ZF=1,  ECX=0,  ESI=8,  EDI=408
    --------------------------------------------------- */
_t17:
    movl    $0x00000011, %ebp
    movl    $fail_t17,   %edx
    movl    $0,   %esi
    movl    $400, %edi
    movl    $2,   %ecx
    repe fs cmpsl
 
    jne     fail_t17
 
    movl    %ecx,        %eax
    call    check_zero
 
    movl    %esi,        %eax
    movl    $8,          %ebx
    call    check
 
    movl    %edi,        %eax
    movl    $408,        %ebx
    call    check
 
    movl    %ebp,        %eax
    jmp     _t18
fail_t17:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt
 
    /* ---------------------------------------------------
       T18: repe cmpsl FS override — mismatch at dword 0
       ES:400 = 0x00000000, FS:0 = 0xFEDCBA98
       Check: ZF=0,  ECX=1,  ESI=4,  EDI=404
    --------------------------------------------------- */
_t18:
    movl    $0x00000012, %ebp
    movl    $fail_t18,   %edx
    movl    $400,        %ebx
    movl    $0x00000000, %es:(%ebx)  /* ES:400 = 0 */
    movl    $0,   %esi
    movl    $400, %edi
    movl    $2,   %ecx
    repe fs cmpsl
 
    jne     _t18_zf_ok
    jmp     fail_t18
_t18_zf_ok:
    movl    %ecx,        %eax
    movl    $1,          %ebx
    call    check
 
    movl    %esi,        %eax
    movl    $4,          %ebx
    call    check
 
    movl    %edi,        %eax
    movl    $404,        %ebx
    call    check
 
    movl    %ebp,        %eax
    jmp     _done
fail_t18:
    movl    $0xDEADDEAD, %eax
    movl    %ebp,        %ebx
    hlt
 
    /* =====================================================
       ALL TESTS PASSED
    ===================================================== */
_done:
    movl    $0xCAFED00D, %eax
    movl    $0x00000000, %ebx
    hlt