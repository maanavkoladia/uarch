
/*

CS BASE: 0

DS BASE: 0x0A000000

FS BASE: 0x0B000000

*/

.org 0x0000
.code
.global _start

    movl    $0xa00, %edx                  //EDX = 0x00000A00
    .byte 0x66
    movw    %dx, %ds                      // DS = 0x0A00, DS_base = 0x0A000000
    addw    $0x100, %dx                   // DX = 0x0B00 CF=0, OF=0, AF=0, PF=1, ZF=0, SF=0
    .byte 0x66
    movw    %dx, %fs                      // FS = 0x0B00, FS_base = 0x0B000000
    movl    $0x08090a0b, %eax             // EAX = 0x08090A0B
    movl    $0xfd, %ebx                   // EBX = 0x000000FD
    movl    $0x03040506, -1(%ebx)         // M[VA=0x0A000000 + 0xFD - 0x1 (0x0A0000FC)] = 0x03040506 
    movl    %eax, 0x3(%ebx)               // M[VA=0x0A000000 + 0xFD + 0x3 (0x0A000100)] = 0x08090A0B
    sarl    (%ebx)                        // M[VA=0x0A000000 + 0xFD (0x0A0000FD)] = 0x05818202
                                          // CF=1, OF=0, AF=0/1(undefined), PF=0, ZF=0, SF=0 
    movb    %ah, 0x2(%ebx)                // M[VA=0x0A000000 + 0xFD + 0x2 (0x0A0000FF)] = 0A
    movl    %eax, 0x800(%ebx)             // M[VA=0x0A000000 + 0xFD + 0x800 (0x0A0008FD)] = 0x08090A0B
    movl    %edx, %fs:(%ebx)              // M[VA=0x0B000000 + 0xFD (0x0B0000FD)] = 0x00000b00
    addl    (%ebx), %eax                  // EAX += M[VA=0x0A000000 + 0xFD (0x0A0000FD)]
                                          // EAX = 0x08090a0b + 0x050a8202 = 0x0d138c0d					
                                          // CF=0, OF=0, AF=0, PF=0, ZF=0, SF=0
    hlt                                   // halt
