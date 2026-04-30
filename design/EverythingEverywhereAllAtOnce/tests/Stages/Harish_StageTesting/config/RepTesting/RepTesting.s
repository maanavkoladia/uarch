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

    /* set up FS as a third segment for override tests */
    movl    $0x0300, %eax
    movw    %ax, %fs

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
       All ES/FS memory starts zeroed.
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
       ███████╗███████╗ ██████╗████████╗██╗ ██████╗ ███╗
          SECTION 1: MOVSL (32-bit, original tests)
       ███████╗███████╗ ██████╗████████╗██╗ ██████╗ ███╗
    ===================================================== */

    /* ---------------------------------------------------
       T1: rep movsl — copy DS:0..12 → ES:0..12
       Expected after:
         ES:0  = 0xAABBCCDD
         ES:4  = 0x11223344
         ES:8  = 0x55667788
         ES:12 = 0x99AABBCC
         ESI   = 16
         EDI   = 16
         ECX   = 0
    --------------------------------------------------- */
    movl    $0x00000001, %eax
    movl    $0,  %esi
    movl    $0,  %edi
    movl    $4,  %ecx
    rep movsl
    movl    $0x00000001, %eax       /* MARKER: T1 done */

    /* ---------------------------------------------------
       T2: rep movsl — copy DS:16..28 → ES:16..28
       Expected after:
         ES:16 = 0xDDEEFF00
         ES:20 = 0xCAFEBABE
         ES:24 = 0xDEADBEEF
         ES:28 = 0x12345678
         ESI   = 32
         EDI   = 32
         ECX   = 0
    --------------------------------------------------- */
    movl    $0x00000002, %eax
    movl    $16, %esi
    movl    $16, %edi
    movl    $4,  %ecx
    rep movsl
    movl    $0x00000002, %eax       /* MARKER: T2 done */

    /* ---------------------------------------------------
       T3: rep movsl — copy DS:0..28 → ES:64..92
       Expected after:
         ES:64 = 0xAABBCCDD
         ES:92 = 0x12345678
         ESI   = 32
         EDI   = 96
         ECX   = 0
    --------------------------------------------------- */
    movl    $0x00000003, %eax
    movl    $0,  %esi
    movl    $64, %edi
    movl    $8,  %ecx
    rep movsl
    movl    $0x00000003, %eax       /* MARKER: T3 done */

    /* ---------------------------------------------------
       T4: rep movsl STD — reverse copy ES:64..76 → ES:128..140
       ESI = 76 (last dword of source), EDI = 140 (last dword of dest)
       Expected after:
         ES:128 = 0xAABBCCDD
         ES:132 = 0x11223344
         ES:136 = 0x55667788
         ES:140 = 0x99AABBCC
         ESI    = 60
         EDI    = 124
         ECX    = 0
    --------------------------------------------------- */
    movl    $0x00000004, %eax
    std
    movl    $76,  %esi
    movl    $140, %edi
    movl    $4,   %ecx
    rep movsl
    cld
    movl    $0x00000004, %eax       /* MARKER: T4 done */

    /* ---------------------------------------------------
       T5: repe cmpsl — full match DS:0..12 vs ES:0..12
       Expected after:
         ZF  = 1
         ECX = 0
         ESI = 16
         EDI = 16
    --------------------------------------------------- */
    movl    $0x00000005, %eax
    movl    $0, %esi
    movl    $0, %edi
    movl    $4, %ecx
    repe cmpsl
    movl    $0x00000005, %eax       /* MARKER: T5 done */

    /* ---------------------------------------------------
       T6: repe cmpsl — full match DS:0..28 vs ES:64..92
       Expected after:
         ZF  = 1
         ECX = 0
         ESI = 32
         EDI = 96
    --------------------------------------------------- */
    movl    $0x00000006, %eax
    movl    $0,  %esi
    movl    $64, %edi
    movl    $8,  %ecx
    repe cmpsl
    movl    $0x00000006, %eax       /* MARKER: T6 done */

    /* ---------------------------------------------------
       T7: repe cmpsl — mismatch at dword 1 (ES:4 corrupted)
       DS:4 = 0x11223344, ES:4 = 0xFFFFFFFF
       Expected after:
         ZF  = 0
         ECX = 6
         ESI = 8
         EDI = 8
    --------------------------------------------------- */
    movl    $0xFFFFFFFF, %es:4
    movl    $0x00000007, %eax
    movl    $0, %esi
    movl    $0, %edi
    movl    $8, %ecx
    repe cmpsl
    movl    $0x00000007, %eax       /* MARKER: T7 done */

    /* ---------------------------------------------------
       T8: repe cmpsl — mismatch at dword 2 (ES:16 corrupted)
       Restore ES:4. Compare DS:8..20 vs ES:8..20.
         DS:8  = 0x55667788  ES:8  = 0x55667788  match
         DS:12 = 0x99AABBCC  ES:12 = 0x99AABBCC  match
         DS:16 = 0xDDEEFF00  ES:16 = 0xFFFFFFFF  mismatch
       Expected after:
         ZF  = 0
         ECX = 0
         ESI = 20
         EDI = 20
    --------------------------------------------------- */
    movl    $0x11223344, %es:4      /* restore ES:4 */
    movl    $0xFFFFFFFF, %es:16     /* inject mismatch */
    movl    $0x00000008, %eax
    movl    $8,  %esi
    movl    $8,  %edi
    movl    $3,  %ecx
    repe cmpsl
    movl    $0x00000008, %eax       /* MARKER: T8 done */

    /* =====================================================
       ██████╗██╗ ██████╗ ███╗
          SECTION 2: MOVSB (8-bit)
       ██████╗██╗ ██████╗ ███╗

       SETUP: Write known byte pattern into DS:128..135
         DS:128 = 0xAA
         DS:129 = 0xBB
         DS:130 = 0xCC
         DS:131 = 0xDD
         DS:132 = 0x11
         DS:133 = 0x22
         DS:134 = 0x33
         DS:135 = 0x44
       Destination: ES:200..207 (starts zeroed)
    ===================================================== */
    movb    $0xAA, %ds:128
    movb    $0xBB, %ds:129
    movb    $0xCC, %ds:130
    movb    $0xDD, %ds:131
    movb    $0x11, %ds:132
    movb    $0x22, %ds:133
    movb    $0x33, %ds:134
    movb    $0x44, %ds:135

    /* ---------------------------------------------------
       T9: rep movsb — copy 4 bytes DS:128..131 → ES:200..203
       Expected after:
         ES:200 = 0xAA
         ES:201 = 0xBB
         ES:202 = 0xCC
         ES:203 = 0xDD
         ESI    = 132
         EDI    = 204
         ECX    = 0
    --------------------------------------------------- */
    movl    $0x00000009, %eax
    movl    $128, %esi
    movl    $200, %edi
    movl    $4,   %ecx
    rep movsb
    movl    $0x00000009, %eax       /* MARKER: T9 done */

    /* ---------------------------------------------------
       T10: rep movsb — copy 8 bytes DS:128..135 → ES:210..217
       Verifies full 8-byte transfer and ESI/EDI advance by 1 each step.
       Expected after:
         ES:210 = 0xAA
         ES:211 = 0xBB
         ES:212 = 0xCC
         ES:213 = 0xDD
         ES:214 = 0x11
         ES:215 = 0x22
         ES:216 = 0x33
         ES:217 = 0x44
         ESI    = 136
         EDI    = 218
         ECX    = 0
    --------------------------------------------------- */
    movl    $0x0000000A, %eax
    movl    $128, %esi
    movl    $210, %edi
    movl    $8,   %ecx
    rep movsb
    movl    $0x0000000A, %eax       /* MARKER: T10 done */

    /* ---------------------------------------------------
       T11: rep movsb STD — reverse copy DS:131..128 → ES:223..220
       ESI = 131 (last byte of source block)
       EDI = 223 (last byte of dest block)
       Expected after:
         ES:220 = 0xAA
         ES:221 = 0xBB
         ES:222 = 0xCC
         ES:223 = 0xDD
         ESI    = 127
         EDI    = 219
         ECX    = 0
    --------------------------------------------------- */
    movl    $0x0000000B, %eax
    std
    movl    $131, %esi
    movl    $223, %edi
    movl    $4,   %ecx
    rep movsb
    cld
    movl    $0x0000000B, %eax       /* MARKER: T11 done */

    /* ---------------------------------------------------
       T12: repe cmpsb — full match DS:128..131 vs ES:200..203
       (ES:200..203 was filled by T9)
       Expected after:
         ZF  = 1
         ECX = 0
         ESI = 132
         EDI = 204
    --------------------------------------------------- */
    movl    $0x0000000C, %eax
    movl    $128, %esi
    movl    $200, %edi
    movl    $4,   %ecx
    repe cmpsb
    movl    $0x0000000C, %eax       /* MARKER: T12 done */

    /* ---------------------------------------------------
       T13: repe cmpsb — mismatch at byte 2 (ES:202 corrupted)
       ES:202 = 0xFF, DS:130 = 0xCC → mismatch at index 2
       Expected after:
         ZF  = 0
         ECX = 1   (4 - 2 matched - 1 on mismatch = 1)
         ESI = 131
         EDI = 203
    --------------------------------------------------- */
    movb    $0xFF, %es:202
    movl    $0x0000000D, %eax
    movl    $128, %esi
    movl    $200, %edi
    movl    $4,   %ecx
    repe cmpsb
    movl    $0x0000000D, %eax       /* MARKER: T13 done */

    /* =====================================================
       ██╗    ██╗
          SECTION 3: MOVSW (16-bit)
       ██╗    ██╗

       SETUP: Write known word pattern into DS:256..263
         DS:256 = 0xABCD  (word)
         DS:258 = 0x1234
         DS:260 = 0x5678
         DS:262 = 0x9ABC
       Destination: ES:300..307 (starts zeroed)
    ===================================================== */
    movw    $0xABCD, %ds:256
    movw    $0x1234, %ds:258
    movw    $0x5678, %ds:260
    movw    $0x9ABC, %ds:262

    /* ---------------------------------------------------
       T14: rep movsw — copy 4 words DS:256..262 → ES:300..306
       ESI/EDI advance by 2 per iteration.
       Expected after:
         ES:300 = 0xABCD
         ES:302 = 0x1234
         ES:304 = 0x5678
         ES:306 = 0x9ABC
         ESI    = 264
         EDI    = 308
         ECX    = 0
    --------------------------------------------------- */
    movl    $0x0000000E, %eax
    movl    $256, %esi
    movl    $300, %edi
    movl    $4,   %ecx
    rep movsw
    movl    $0x0000000E, %eax       /* MARKER: T14 done */

    /* ---------------------------------------------------
       T15: rep movsw STD — reverse copy DS:262..256 → ES:314..308
       ESI = 262 (last word of source), EDI = 314 (last word of dest)
       Expected after:
         ES:308 = 0xABCD
         ES:310 = 0x1234
         ES:312 = 0x5678
         ES:314 = 0x9ABC
         ESI    = 254
         EDI    = 306
         ECX    = 0
    --------------------------------------------------- */
    movl    $0x0000000F, %eax
    std
    movl    $262, %esi
    movl    $314, %edi
    movl    $4,   %ecx
    rep movsw
    cld
    movl    $0x0000000F, %eax       /* MARKER: T15 done */

    /* ---------------------------------------------------
       T16: repe cmpsw — full match DS:256..262 vs ES:300..306
       Expected after:
         ZF  = 1
         ECX = 0
         ESI = 264
         EDI = 308
    --------------------------------------------------- */
    movl    $0x00000010, %eax
    movl    $256, %esi
    movl    $300, %edi
    movl    $4,   %ecx
    repe cmpsw
    movl    $0x00000010, %eax       /* MARKER: T16 done */

    /* ---------------------------------------------------
       T17: repe cmpsw — mismatch at word 1 (ES:302 corrupted)
       ES:302 = 0xFFFF, DS:258 = 0x1234
       Expected after:
         ZF  = 0
         ECX = 2
         ESI = 260
         EDI = 304
    --------------------------------------------------- */
    movw    $0xFFFF, %es:302
    movl    $0x00000011, %eax
    movl    $256, %esi
    movl    $300, %edi
    movl    $4,   %ecx
    repe cmpsw
    movl    $0x00000011, %eax       /* MARKER: T17 done */

    /* =====================================================
       ███████╗███████╗ ██████╗
          SECTION 4: SEGMENT OVERRIDE
       ███████╗███████╗ ██████╗

       movs normally reads from DS:ESI and writes to ES:EDI.
       The only overridable side is the SOURCE (DS→something else).
       The destination is always ES:EDI — this is hardwired by the ISA
       and cannot be overridden.

       Here we use FS as the source segment instead of DS.
       Write known data directly into FS memory (segment base 0x0300).
       FS:0  = 0xFEDCBA98
       FS:4  = 0x76543210
    ===================================================== */
    movl    $0xFEDCBA98, %fs:0
    movl    $0x76543210, %fs:4

    /* ---------------------------------------------------
       T18: rep movsl with FS source override — FS:0..4 → ES:400..404
       Using fs: prefix on the movsl to override source segment.
       Expected after:
         ES:400 = 0xFEDCBA98
         ES:404 = 0x76543210
         ESI    = 8
         EDI    = 408
         ECX    = 0
    --------------------------------------------------- */
    movl    $0x00000012, %eax
    movl    $0,   %esi
    movl    $400, %edi
    movl    $2,   %ecx
    rep fs movsl                    /* FS:ESI → ES:EDI */
    movl    $0x00000012, %eax       /* MARKER: T18 done */

    /* ---------------------------------------------------
       T19: rep movsb with FS source override — FS:0..3 → ES:410..413
       Byte-granular read from FS, write to ES as normal.
       Expected after:
         ES:410 = 0x98  (low byte of FS:0, little-endian)
         ES:411 = 0xBA
         ES:412 = 0xDC
         ES:413 = 0xFE
         ESI    = 4
         EDI    = 414
         ECX    = 0
    --------------------------------------------------- */
    movl    $0x00000013, %eax
    movl    $0,   %esi
    movl    $410, %edi
    movl    $4,   %ecx
    rep fs movsb                    /* FS:ESI → ES:EDI, byte at a time */
    movl    $0x00000013, %eax       /* MARKER: T19 done */

    /* ---------------------------------------------------
       T20: repe cmpsl with FS source override
       Compare FS:0..4 vs ES:400..404 (copied in T18, should match).
       Expected after:
         ZF  = 1
         ECX = 0
         ESI = 8
         EDI = 408
    --------------------------------------------------- */
    movl    $0x00000014, %eax
    movl    $0,   %esi
    movl    $400, %edi
    movl    $2,   %ecx
    repe fs cmpsl                   /* compare FS:ESI vs ES:EDI */
    movl    $0x00000014, %eax       /* MARKER: T20 done */

    /* ---------------------------------------------------
       T21: repe cmpsl with FS override — mismatch
       Corrupt ES:400 so it differs from FS:0.
       FS:0 = 0xFEDCBA98, ES:400 = 0x00000000
       Expected after:
         ZF  = 0
         ECX = 1   (2 total, stops on first)
         ESI = 4
         EDI = 404
    --------------------------------------------------- */
    movl    $0x00000000, %es:400    /* inject mismatch */
    movl    $0x00000015, %eax
    movl    $0,   %esi
    movl    $400, %edi
    movl    $2,   %ecx
    repe fs cmpsl
    movl    $0x00000015, %eax       /* MARKER: T21 done */

    /* =====================================================
       FINAL SANITY
       EAX should read 0xAABBCCDD from ES:0 (set in T1, untouched)
    ===================================================== */
    movl    $0xFFFFDEAD, %eax       /* canary */
    movl    $0, %edi
    movl    %es:(%edi), %eax
    /* CHECKPOINT: EAX = 0xAABBCCDD */
    hlt