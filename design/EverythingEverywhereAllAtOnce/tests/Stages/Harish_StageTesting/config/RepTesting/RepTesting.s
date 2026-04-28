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
    cld

    /* =====================================================
       SETUP: Write known pattern into DS memory.
       DS:0   = 0xAABBCCDD
       DS:4   = 0x11223344
       DS:8   = 0x55667788
       DS:12  = 0x99AABBCC
       DS:16  = 0xDDEEFF00
       DS:20  = 0xCAFEBABE
       DS:24  = 0xDEADBEEF
       DS:28  = 0x12345678
       All ES memory starts at 0x00000000
    ===================================================== */
    movl    $0xAABBCCDD, %ds:0
    movl    $0x11223344, %ds:4
    movl    $0x55667788, %ds:8
    movl    $0x99AABBCC, %ds:12
    movl    $0xDDEEFF00, %ds:16
    movl    $0xCAFEBABE, %ds:20
    movl    $0xDEADBEEF, %ds:24
    movl    $0x12345678, %ds:28

    /* =====================================================
       TEST 1: rep movsl — copy DS:0..12 → ES:0..12
       SENTINEL before: EAX = 0x00000001
       Expected after:
         ES:0  = 0xAABBCCDD
         ES:4  = 0x11223344
         ES:8  = 0x55667788
         ES:12 = 0x99AABBCC
         ESI   = 16  (advanced by 4 dwords)
         EDI   = 16
         ECX   = 0
    ===================================================== */
    movl    $0x00000001, %eax       /* SENTINEL T1 */
    movl    $0,  %esi
    movl    $0,  %edi
    movl    $4,  %ecx
    rep movsl
    /* CHECKPOINT: ECX=0, ESI=16, EDI=16 */
    movl    $0x00000001, %eax       /* MARKER: T1 done */

    /* =====================================================
       TEST 2: rep movsl — copy DS:16..28 → ES:16..28
       SENTINEL before: EAX = 0x00000002
       Expected after:
         ES:16 = 0xDDEEFF00
         ES:20 = 0xCAFEBABE
         ES:24 = 0xDEADBEEF
         ES:28 = 0x12345678
         ESI   = 32
         EDI   = 32
         ECX   = 0
    ===================================================== */
    movl    $0x00000002, %eax       /* SENTINEL T2 */
    movl    $16, %esi
    movl    $16, %edi
    movl    $4,  %ecx
    rep movsl
    /* CHECKPOINT: ECX=0, ESI=32, EDI=32 */
    movl    $0x00000002, %eax       /* MARKER: T2 done */

    /* =====================================================
       TEST 3: rep movsl — copy DS:0..28 → ES:64..92
       (8 dwords, non-overlapping destination region)
       SENTINEL before: EAX = 0x00000003
       Expected after:
         ES:64 = 0xAABBCCDD
         ES:68 = 0x11223344
         ES:72 = 0x55667788
         ES:76 = 0x99AABBCC
         ES:80 = 0xDDEEFF00
         ES:84 = 0xCAFEBABE
         ES:88 = 0xDEADBEEF
         ES:92 = 0x12345678
         ESI   = 32
         EDI   = 96
         ECX   = 0
    ===================================================== */
    movl    $0x00000003, %eax       /* SENTINEL T3 */
    movl    $0,  %esi
    movl    $64, %edi
    movl    $8,  %ecx
    rep movsl
    /* CHECKPOINT: ECX=0, ESI=32, EDI=96 */
    movl    $0x00000003, %eax       /* MARKER: T3 done */

    /* =====================================================
       TEST 4: rep movsl with STD — reverse copy
       Copy ES:64..76 (4 dwords) backwards → ES:128..116
       ESI starts at last dword of source block = 64+(4-1)*4 = 76
       EDI starts at last dword of dest block  = 128+(4-1)*4 = 140
       After STD each step decrements by 4.
       SENTINEL before: EAX = 0x00000004
       Expected after:
         ES:128 = 0xAABBCCDD  (= ES:64)
         ES:132 = 0x11223344  (= ES:68)
         ES:136 = 0x55667788  (= ES:72)
         ES:140 = 0x99AABBCC  (= ES:76)
         ESI    = 60  (76 - 4*4 + 4 overshoot corrected: 76-16=60)
         EDI    = 124 (140 - 16 = 124)
         ECX    = 0
       Note: after rep, ESI/EDI point 4 bytes BEFORE first element.
    ===================================================== */
    movl    $0x00000004, %eax       /* SENTINEL T4 */
    std
    movl    $76,  %esi
    movl    $140, %edi
    movl    $4,   %ecx
    rep movsl
    cld
    /* CHECKPOINT: ECX=0, ESI=60, EDI=124 */
    movl    $0x00000004, %eax       /* MARKER: T4 done */

    /* =====================================================
       TEST 5: repe cmpsl — full match
       Compare DS:0..12 vs ES:0..12 (both set identically by T1)
       SENTINEL before: EAX = 0x00000005
       Expected after:
         ZF    = 1   (all matched)
         ECX   = 0   (exhausted)
         ESI   = 16
         EDI   = 16
    ===================================================== */
    movl    $0x00000005, %eax       /* SENTINEL T5 */
    movl    $0, %esi
    movl    $0, %edi
    movl    $4, %ecx
    repe cmpsl
    /* CHECKPOINT: ZF=1, ECX=0, ESI=16, EDI=16 */
    movl    $0x00000005, %eax       /* MARKER: T5 done */

    /* =====================================================
       TEST 6: repe cmpsl — match across larger block
       Compare DS:0..28 vs ES:64..92 (copied in T3, should match)
       SENTINEL before: EAX = 0x00000006
       Expected after:
         ZF    = 1
         ECX   = 0
         ESI   = 32
         EDI   = 96
    ===================================================== */
    movl    $0x00000006, %eax       /* SENTINEL T6 */
    movl    $0,  %esi
    movl    $64, %edi
    movl    $8,  %ecx
    repe cmpsl
    /* CHECKPOINT: ZF=1, ECX=0, ESI=32, EDI=96 */
    movl    $0x00000006, %eax       /* MARKER: T6 done */

    /* =====================================================
       TEST 7: repe cmpsl — mismatch at dword 1 (ES:4)
       Corrupt ES:4 so it differs from DS:4.
       DS:4 = 0x11223344, ES:4 = 0xFFFFFFFF → mismatch at index 1
       SENTINEL before: EAX = 0x00000007
       Expected after:
         ZF    = 0   (mismatch)
         ECX   = 6   (8 - 1 consumed before mismatch - 1 on mismatch = 6)
         ESI   = 8   (advanced past DS:0 and DS:4)
         EDI   = 8   (advanced past ES:0 and ES:4)
    ===================================================== */
    movl    $0xFFFFFFFF, %es:4      /* inject mismatch at ES:4 */
    movl    $0x00000007, %eax       /* SENTINEL T7 */
    movl    $0, %esi
    movl    $0, %edi
    movl    $8, %ecx
    repe cmpsl
    /* CHECKPOINT: ZF=0, ECX=6, ESI=8, EDI=8 */
    movl    $0x00000007, %eax       /* MARKER: T7 done */

    /* =====================================================
       TEST 8: repe cmpsl — mismatch at dword 3 (ES:24 vs DS:8)
       Restore ES:4, corrupt ES:24.
       Comparing DS:0..16 (4 dwords) vs ES:20..32
       DS:0=0xAABBCCDD, ES:20=0xCAFEBABE → mismatch at index 0
       Use a region pair that demonstrates ECX=N-1 on first-dword mismatch.
       Comparing DS:8..20 (3 dwords) vs ES:8..20
         DS:8  = 0x55667788   ES:8  = 0x55667788  → match
         DS:12 = 0x99AABBCC   ES:12 = 0x99AABBCC  → match
         DS:16 = 0xDDEEFF00   ES:16 = 0xFFFFFFFF  → mismatch (was corrupted by T7 restore area; set explicitly)
       SENTINEL before: EAX = 0x00000008
       Expected after:
         ZF    = 0
         ECX   = 0   (3 dwords, stopped after consuming all 3: 2 match + stop on 3rd)
         ESI   = 20
         EDI   = 20
    ===================================================== */
    movl    $0x11223344, %es:4      /* restore ES:4 */
    movl    $0xFFFFFFFF, %es:16     /* inject mismatch at ES:16 */
    movl    $0x00000008, %eax       /* SENTINEL T8 */
    movl    $8,  %esi
    movl    $8,  %edi
    movl    $3,  %ecx
    repe cmpsl
    /* CHECKPOINT: ZF=0, ECX=0, ESI=20, EDI=20 */
    movl    $0x00000008, %eax       /* MARKER: T8 done */

    /* =====================================================
       FINAL SANITY: load ES:0 → EAX
       EAX should read 0xAABBCCDD
    ===================================================== */
    movl    $0xFFFFDEAD, %eax       /* pre-load canary */
    movl    $0, %edi
    movl    %es:(%edi), %eax
    /* CHECKPOINT: EAX = 0xAABBCCDD */
    hlt