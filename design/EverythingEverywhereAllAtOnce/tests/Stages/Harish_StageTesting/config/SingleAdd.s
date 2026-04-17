.org 0x1000
.code
.global _start

_start:

    add  $0x1234, %eax
    
    add %al, %ah
    hlt


.org 0x2000
.data
memval:
    .long 0xAAAAAAAA