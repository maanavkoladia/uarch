0x0:   bb 00 00 00 00          //mov    ebx,0x0
0x5:   66 b8 00 02             //mov    ax,0x0200
0x9:   8e d8                   //mov    ds,eax
0xb:   66 b8 00 04             //mov    ax,0x0400
0xf:   8e e8                   //mov    gs,eax
0x11:  66 b8 00 0b             //mov    ax,0x0b00
0x15:  8e c0                   //mov    es,eax
0x17:  66 b8 00 0c             //mov    ax,0x0c00
0x1b:  8e e0                   //mov    fs,eax
0x1d:  66 b8 00 03             //mov    ax,0x0300
0x21:  8e e8                   //mov    gs,eax
0x23:  b8 01 00 00 00          //mov    eax,0x1
0x28:  89 05 0e 00 00 00       //mov    ds:0xe,eax
0x2e:  89 05 8e 00 00 00       //mov    ds:0x8e,eax
0x34:  89 05 0e 01 00 00       //mov    ds:0x10e,eax
0x3a:  89 05 8e 01 00 00       //mov    ds:0x18e,eax
0x40:  89 05 0e 02 00 00       //mov    ds:0x20e,eax
0x46:  89 05 8e 02 00 00       //mov    ds:0x28e,eax
0x4c:  89 05 0e 03 00 00       //mov    ds:0x30e,eax
0x52:  89 05 8e 03 00 00       //mov    ds:0x38e,eax
0x58:  89 05 0e 04 00 00       //mov    ds:0x40e,eax
0x5e:  89 05 8e 04 00 00       //mov    ds:0x48e,eax
0x64:  89 05 0e 05 00 00       //mov    ds:0x50e,eax
0x6a:  89 05 8e 05 00 00       //mov    ds:0x58e,eax
0x70:  89 05 0e 06 00 00       //mov    ds:0x60e,eax
0x76:  89 05 8e 06 00 00       //mov    ds:0x68e,eax
0x7c:  89 05 0e 07 00 00       //mov    ds:0x70e,eax
0x82:  89 05 8e 07 00 00       //mov    ds:0x78e,eax
0x88:  89 05 0e 08 00 00       //mov    ds:0x80e,eax
0x8e:  89 05 8e 08 00 00       //mov    ds:0x88e,eax
0x94:  89 05 0e 09 00 00       //mov    ds:0x90e,eax
0x9a:  89 05 8e 09 00 00       //mov    ds:0x98e,eax
0xa0:  89 05 0e 0a 00 00       //mov    ds:0xa0e,eax
0xa6:  89 05 8e 0a 00 00       //mov    ds:0xa8e,eax
0xac:  89 05 0e 0b 00 00       //mov    ds:0xb0e,eax
0xb2:  89 05 8e 0b 00 00       //mov    ds:0xb8e,eax
0xb8:  89 05 0e 0c 00 00       //mov    ds:0xc0e,eax
0xbe:  89 05 8e 0c 00 00       //mov    ds:0xc8e,eax
0xc4:  89 05 0e 0d 00 00       //mov    ds:0xd0e,eax
0xca:  89 05 8e 0d 00 00       //mov    ds:0xd8e,eax
0xd0:  89 05 0e 0e 00 00       //mov    ds:0xe0e,eax
0xd6:  89 05 8e 0e 00 00       //mov    ds:0xe8e,eax
0xdc:  89 05 0e 0f 00 00       //mov    ds:0xf0e,eax
0xe2:  89 05 8e 0f 00 00       //mov    ds:0xf8e,eax
0xe8:  65 89 05 0e 00 00 00    //mov    gs:0xe,eax
0xef:  65 89 05 8e 00 00 00    //mov    gs:0x8e,eax
0xf6:  65 89 05 0e 01 00 00    //mov    gs:0x10e,eax
0xfd:  65 89 05 8e 01 00 00    //mov    gs:0x18e,eax
0x104: 65 89 05 0e 02 00 00    //mov    gs:0x20e,eax
0x10b: 65 89 05 8e 02 00 00    //mov    gs:0x28e,eax
0x112: 65 89 05 0e 03 00 00    //mov    gs:0x30e,eax
0x119: 65 89 05 8e 03 00 00    //mov    gs:0x38e,eax
0x120: 65 89 05 0e 04 00 00    //mov    gs:0x40e,eax
0x127: 65 89 05 8e 04 00 00    //mov    gs:0x48e,eax
0x12e: 65 89 05 0e 05 00 00    //mov    gs:0x50e,eax
0x135: 65 89 05 8e 05 00 00    //mov    gs:0x58e,eax
0x13c: 65 89 05 0e 06 00 00    //mov    gs:0x60e,eax
0x143: 65 89 05 8e 06 00 00    //mov    gs:0x68e,eax
0x14a: 65 89 05 0e 07 00 00    //mov    gs:0x70e,eax
0x151: 65 89 05 8e 07 00 00    //mov    gs:0x78e,eax
0x158: 65 89 05 0e 08 00 00    //mov    gs:0x80e,eax
0x15f: 65 89 05 8e 08 00 00    //mov    gs:0x88e,eax
0x166: 65 89 05 0e 09 00 00    //mov    gs:0x90e,eax
0x16d: 65 89 05 8e 09 00 00    //mov    gs:0x98e,eax
0x174: 65 89 05 0e 0a 00 00    //mov    gs:0xa0e,eax
0x17b: 65 89 05 8e 0a 00 00    //mov    gs:0xa8e,eax
0x182: 65 89 05 0e 0b 00 00    //mov    gs:0xb0e,eax
0x189: 65 89 05 8e 0b 00 00    //mov    gs:0xb8e,eax
0x190: 65 89 05 0e 0c 00 00    //mov    gs:0xc0e,eax
0x197: 65 89 05 8e 0c 00 00    //mov    gs:0xc8e,eax
0x19e: 65 89 05 0e 0d 00 00    //mov    gs:0xd0e,eax
0x1a5: 65 89 05 8e 0d 00 00    //mov    gs:0xd8e,eax
0x1ac: 65 89 05 0e 0e 00 00    //mov    gs:0xe0e,eax
0x1b3: 65 89 05 8e 0e 00 00    //mov    gs:0xe8e,eax
0x1ba: 65 89 05 0e 0f 00 00    //mov    gs:0xf0e,eax
0x1c1: 65 89 05 8e 0f 00 00    //mov    gs:0xf8e,eax
0x1c8: 26 89 05 0e 00 00 00    //mov    es:0xe,eax
0x1cf: 26 89 05 8e 00 00 00    //mov    es:0x8e,eax
0x1d6: 26 89 05 0e 01 00 00    //mov    es:0x10e,eax
0x1dd: 26 89 05 8e 01 00 00    //mov    es:0x18e,eax
0x1e4: 26 89 05 0e 02 00 00    //mov    es:0x20e,eax
0x1eb: 26 89 05 8e 02 00 00    //mov    es:0x28e,eax
0x1f2: 26 89 05 0e 03 00 00    //mov    es:0x30e,eax
0x1f9: 26 89 05 8e 03 00 00    //mov    es:0x38e,eax
0x200: 26 89 05 0e 04 00 00    //mov    es:0x40e,eax
0x207: 26 89 05 8e 04 00 00    //mov    es:0x48e,eax
0x20e: 26 89 05 0e 05 00 00    //mov    es:0x50e,eax
0x215: 26 89 05 8e 05 00 00    //mov    es:0x58e,eax
0x21c: 26 89 05 0e 06 00 00    //mov    es:0x60e,eax
0x223: 26 89 05 8e 06 00 00    //mov    es:0x68e,eax
0x22a: 26 89 05 0e 07 00 00    //mov    es:0x70e,eax
0x231: 26 89 05 8e 07 00 00    //mov    es:0x78e,eax
0x238: 26 89 05 0e 08 00 00    //mov    es:0x80e,eax
0x23f: 26 89 05 8e 08 00 00    //mov    es:0x88e,eax
0x246: 26 89 05 0e 09 00 00    //mov    es:0x90e,eax
0x24d: 26 89 05 8e 09 00 00    //mov    es:0x98e,eax
0x254: 26 89 05 0e 0a 00 00    //mov    es:0xa0e,eax
0x25b: 26 89 05 8e 0a 00 00    //mov    es:0xa8e,eax
0x262: 26 89 05 0e 0b 00 00    //mov    es:0xb0e,eax
0x269: 26 89 05 8e 0b 00 00    //mov    es:0xb8e,eax
0x270: 26 89 05 0e 0c 00 00    //mov    es:0xc0e,eax
0x277: 26 89 05 8e 0c 00 00    //mov    es:0xc8e,eax
0x27e: 26 89 05 0e 0d 00 00    //mov    es:0xd0e,eax
0x285: 26 89 05 8e 0d 00 00    //mov    es:0xd8e,eax
0x28c: 26 89 05 0e 0e 00 00    //mov    es:0xe0e,eax
0x293: 26 89 05 8e 0e 00 00    //mov    es:0xe8e,eax
0x29a: 26 89 05 0e 0f 00 00    //mov    es:0xf0e,eax
0x2a1: 26 89 05 8e 0f 00 00    //mov    es:0xf8e,eax
0x2a8: 64 89 05 0e 00 00 00    //mov    fs:0xe,eax
0x2af: 64 89 05 8e 00 00 00    //mov    fs:0x8e,eax
0x2b6: 64 89 05 0e 01 00 00    //mov    fs:0x10e,eax
0x2bd: 64 89 05 8e 01 00 00    //mov    fs:0x18e,eax
0x2c4: 64 89 05 0e 02 00 00    //mov    fs:0x20e,eax
0x2cb: 64 89 05 8e 02 00 00    //mov    fs:0x28e,eax
0x2d2: 64 89 05 0e 03 00 00    //mov    fs:0x30e,eax
0x2d9: 64 89 05 8e 03 00 00    //mov    fs:0x38e,eax
0x2e0: 64 89 05 0e 04 00 00    //mov    fs:0x40e,eax
0x2e7: 64 89 05 8e 04 00 00    //mov    fs:0x48e,eax
0x2ee: 64 89 05 0e 05 00 00    //mov    fs:0x50e,eax
0x2f5: 64 89 05 8e 05 00 00    //mov    fs:0x58e,eax
0x2fc: 64 89 05 0e 06 00 00    //mov    fs:0x60e,eax
0x303: 64 89 05 8e 06 00 00    //mov    fs:0x68e,eax
0x30a: 64 89 05 0e 07 00 00    //mov    fs:0x70e,eax
0x311: 64 89 05 8e 07 00 00    //mov    fs:0x78e,eax
0x318: 64 89 05 0e 08 00 00    //mov    fs:0x80e,eax
0x31f: 64 89 05 8e 08 00 00    //mov    fs:0x88e,eax
0x326: 64 89 05 0e 09 00 00    //mov    fs:0x90e,eax
0x32d: 64 89 05 8e 09 00 00    //mov    fs:0x98e,eax
0x334: 64 89 05 0e 0a 00 00    //mov    fs:0xa0e,eax
0x33b: 64 89 05 8e 0a 00 00    //mov    fs:0xa8e,eax
0x342: 64 89 05 0e 0b 00 00    //mov    fs:0xb0e,eax
0x349: 64 89 05 8e 0b 00 00    //mov    fs:0xb8e,eax
0x350: 64 89 05 0e 0c 00 00    //mov    fs:0xc0e,eax
0x357: 64 89 05 8e 0c 00 00    //mov    fs:0xc8e,eax
0x35e: 64 89 05 0e 0d 00 00    //mov    fs:0xd0e,eax
0x365: 64 89 05 8e 0d 00 00    //mov    fs:0xd8e,eax
0x36c: 64 89 05 0e 0e 00 00    //mov    fs:0xe0e,eax
0x373: 64 89 05 8e 0e 00 00    //mov    fs:0xe8e,eax
0x37a: 64 89 05 0e 0f 00 00    //mov    fs:0xf0e,eax
0x381: 64 89 05 8e 0f 00 00    //mov    fs:0xf8e,eax
0x388: 03 1d 0e 00 00 00       //add    ebx,DWORD PTR ds:0xe
0x38e: 03 1d 8e 00 00 00       //add    ebx,DWORD PTR ds:0x8e
0x394: 03 1d 0e 01 00 00       //add    ebx,DWORD PTR ds:0x10e
0x39a: 03 1d 8e 01 00 00       //add    ebx,DWORD PTR ds:0x18e
0x3a0: 03 1d 0e 02 00 00       //add    ebx,DWORD PTR ds:0x20e
0x3a6: 03 1d 8e 02 00 00       //add    ebx,DWORD PTR ds:0x28e
0x3ac: 03 1d 0e 03 00 00       //add    ebx,DWORD PTR ds:0x30e
0x3b2: 03 1d 8e 03 00 00       //add    ebx,DWORD PTR ds:0x38e
0x3b8: 03 1d 0e 04 00 00       //add    ebx,DWORD PTR ds:0x40e
0x3be: 03 1d 8e 04 00 00       //add    ebx,DWORD PTR ds:0x48e
0x3c4: 03 1d 0e 05 00 00       //add    ebx,DWORD PTR ds:0x50e
0x3ca: 03 1d 8e 05 00 00       //add    ebx,DWORD PTR ds:0x58e
0x3d0: 03 1d 0e 06 00 00       //add    ebx,DWORD PTR ds:0x60e
0x3d6: 03 1d 8e 06 00 00       //add    ebx,DWORD PTR ds:0x68e
0x3dc: 03 1d 0e 07 00 00       //add    ebx,DWORD PTR ds:0x70e
0x3e2: 03 1d 8e 07 00 00       //add    ebx,DWORD PTR ds:0x78e
0x3e8: 03 1d 0e 08 00 00       //add    ebx,DWORD PTR ds:0x80e
0x3ee: 03 1d 8e 08 00 00       //add    ebx,DWORD PTR ds:0x88e
0x3f4: 03 1d 0e 09 00 00       //add    ebx,DWORD PTR ds:0x90e
0x3fa: 03 1d 8e 09 00 00       //add    ebx,DWORD PTR ds:0x98e
0x400: 03 1d 0e 0a 00 00       //add    ebx,DWORD PTR ds:0xa0e
0x406: 03 1d 8e 0a 00 00       //add    ebx,DWORD PTR ds:0xa8e
0x40c: 03 1d 0e 0b 00 00       //add    ebx,DWORD PTR ds:0xb0e
0x412: 03 1d 8e 0b 00 00       //add    ebx,DWORD PTR ds:0xb8e
0x418: 03 1d 0e 0c 00 00       //add    ebx,DWORD PTR ds:0xc0e
0x41e: 03 1d 8e 0c 00 00       //add    ebx,DWORD PTR ds:0xc8e
0x424: 03 1d 0e 0d 00 00       //add    ebx,DWORD PTR ds:0xd0e
0x42a: 03 1d 8e 0d 00 00       //add    ebx,DWORD PTR ds:0xd8e
0x430: 03 1d 0e 0e 00 00       //add    ebx,DWORD PTR ds:0xe0e
0x436: 03 1d 8e 0e 00 00       //add    ebx,DWORD PTR ds:0xe8e
0x43c: 03 1d 0e 0f 00 00       //add    ebx,DWORD PTR ds:0xf0e
0x442: 03 1d 8e 0f 00 00       //add    ebx,DWORD PTR ds:0xf8e
0x448: 65 03 1d 0e 00 00 00    //add    ebx,DWORD PTR gs:0xe
0x44f: 65 03 1d 8e 00 00 00    //add    ebx,DWORD PTR gs:0x8e
0x456: 65 03 1d 0e 01 00 00    //add    ebx,DWORD PTR gs:0x10e
0x45d: 65 03 1d 8e 01 00 00    //add    ebx,DWORD PTR gs:0x18e
0x464: 65 03 1d 0e 02 00 00    //add    ebx,DWORD PTR gs:0x20e
0x46b: 65 03 1d 8e 02 00 00    //add    ebx,DWORD PTR gs:0x28e
0x472: 65 03 1d 0e 03 00 00    //add    ebx,DWORD PTR gs:0x30e
0x479: 65 03 1d 8e 03 00 00    //add    ebx,DWORD PTR gs:0x38e
0x480: 65 03 1d 0e 04 00 00    //add    ebx,DWORD PTR gs:0x40e
0x487: 65 03 1d 8e 04 00 00    //add    ebx,DWORD PTR gs:0x48e
0x48e: 65 03 1d 0e 05 00 00    //add    ebx,DWORD PTR gs:0x50e
0x495: 65 03 1d 8e 05 00 00    //add    ebx,DWORD PTR gs:0x58e
0x49c: 65 03 1d 0e 06 00 00    //add    ebx,DWORD PTR gs:0x60e
0x4a3: 65 03 1d 8e 06 00 00    //add    ebx,DWORD PTR gs:0x68e
0x4aa: 65 03 1d 0e 07 00 00    //add    ebx,DWORD PTR gs:0x70e
0x4b1: 65 03 1d 8e 07 00 00    //add    ebx,DWORD PTR gs:0x78e
0x4b8: 65 03 1d 0e 08 00 00    //add    ebx,DWORD PTR gs:0x80e
0x4bf: 65 03 1d 8e 08 00 00    //add    ebx,DWORD PTR gs:0x88e
0x4c6: 65 03 1d 0e 09 00 00    //add    ebx,DWORD PTR gs:0x90e
0x4cd: 65 03 1d 8e 09 00 00    //add    ebx,DWORD PTR gs:0x98e
0x4d4: 65 03 1d 0e 0a 00 00    //add    ebx,DWORD PTR gs:0xa0e
0x4db: 65 03 1d 8e 0a 00 00    //add    ebx,DWORD PTR gs:0xa8e
0x4e2: 65 03 1d 0e 0b 00 00    //add    ebx,DWORD PTR gs:0xb0e
0x4e9: 65 03 1d 8e 0b 00 00    //add    ebx,DWORD PTR gs:0xb8e
0x4f0: 65 03 1d 0e 0c 00 00    //add    ebx,DWORD PTR gs:0xc0e
0x4f7: 65 03 1d 8e 0c 00 00    //add    ebx,DWORD PTR gs:0xc8e
0x4fe: 65 03 1d 0e 0d 00 00    //add    ebx,DWORD PTR gs:0xd0e
0x505: 65 03 1d 8e 0d 00 00    //add    ebx,DWORD PTR gs:0xd8e
0x50c: 65 03 1d 0e 0e 00 00    //add    ebx,DWORD PTR gs:0xe0e
0x513: 65 03 1d 8e 0e 00 00    //add    ebx,DWORD PTR gs:0xe8e
0x51a: 65 03 1d 0e 0f 00 00    //add    ebx,DWORD PTR gs:0xf0e
0x521: 65 03 1d 8e 0f 00 00    //add    ebx,DWORD PTR gs:0xf8e
0x528: 26 03 1d 0e 00 00 00    //add    ebx,DWORD PTR es:0xe
0x52f: 26 03 1d 8e 00 00 00    //add    ebx,DWORD PTR es:0x8e
0x536: 26 03 1d 0e 01 00 00    //add    ebx,DWORD PTR es:0x10e
0x53d: 26 03 1d 8e 01 00 00    //add    ebx,DWORD PTR es:0x18e
0x544: 26 03 1d 0e 02 00 00    //add    ebx,DWORD PTR es:0x20e
0x54b: 26 03 1d 8e 02 00 00    //add    ebx,DWORD PTR es:0x28e
0x552: 26 03 1d 0e 03 00 00    //add    ebx,DWORD PTR es:0x30e
0x559: 26 03 1d 8e 03 00 00    //add    ebx,DWORD PTR es:0x38e
0x560: 26 03 1d 0e 04 00 00    //add    ebx,DWORD PTR es:0x40e
0x567: 26 03 1d 8e 04 00 00    //add    ebx,DWORD PTR es:0x48e
0x56e: 26 03 1d 0e 05 00 00    //add    ebx,DWORD PTR es:0x50e
0x575: 26 03 1d 8e 05 00 00    //add    ebx,DWORD PTR es:0x58e
0x57c: 26 03 1d 0e 06 00 00    //add    ebx,DWORD PTR es:0x60e
0x583: 26 03 1d 8e 06 00 00    //add    ebx,DWORD PTR es:0x68e
0x58a: 26 03 1d 0e 07 00 00    //add    ebx,DWORD PTR es:0x70e
0x591: 26 03 1d 8e 07 00 00    //add    ebx,DWORD PTR es:0x78e
0x598: 26 03 1d 0e 08 00 00    //add    ebx,DWORD PTR es:0x80e
0x59f: 26 03 1d 8e 08 00 00    //add    ebx,DWORD PTR es:0x88e
0x5a6: 26 03 1d 0e 09 00 00    //add    ebx,DWORD PTR es:0x90e
0x5ad: 26 03 1d 8e 09 00 00    //add    ebx,DWORD PTR es:0x98e
0x5b4: 26 03 1d 0e 0a 00 00    //add    ebx,DWORD PTR es:0xa0e
0x5bb: 26 03 1d 8e 0a 00 00    //add    ebx,DWORD PTR es:0xa8e
0x5c2: 26 03 1d 0e 0b 00 00    //add    ebx,DWORD PTR es:0xb0e
0x5c9: 26 03 1d 8e 0b 00 00    //add    ebx,DWORD PTR es:0xb8e
0x5d0: 26 03 1d 0e 0c 00 00    //add    ebx,DWORD PTR es:0xc0e
0x5d7: 26 03 1d 8e 0c 00 00    //add    ebx,DWORD PTR es:0xc8e
0x5de: 26 03 1d 0e 0d 00 00    //add    ebx,DWORD PTR es:0xd0e
0x5e5: 26 03 1d 8e 0d 00 00    //add    ebx,DWORD PTR es:0xd8e
0x5ec: 26 03 1d 0e 0e 00 00    //add    ebx,DWORD PTR es:0xe0e
0x5f3: 26 03 1d 8e 0e 00 00    //add    ebx,DWORD PTR es:0xe8e
0x5fa: 26 03 1d 0e 0f 00 00    //add    ebx,DWORD PTR es:0xf0e
0x601: 26 03 1d 8e 0f 00 00    //add    ebx,DWORD PTR es:0xf8e
0x608: 64 03 1d 0e 00 00 00    //add    ebx,DWORD PTR fs:0xe
0x60f: 64 03 1d 8e 00 00 00    //add    ebx,DWORD PTR fs:0x8e
0x616: 64 03 1d 0e 01 00 00    //add    ebx,DWORD PTR fs:0x10e
0x61d: 64 03 1d 8e 01 00 00    //add    ebx,DWORD PTR fs:0x18e
0x624: 64 03 1d 0e 02 00 00    //add    ebx,DWORD PTR fs:0x20e
0x62b: 64 03 1d 8e 02 00 00    //add    ebx,DWORD PTR fs:0x28e
0x632: 64 03 1d 0e 03 00 00    //add    ebx,DWORD PTR fs:0x30e
0x639: 64 03 1d 8e 03 00 00    //add    ebx,DWORD PTR fs:0x38e
0x640: 64 03 1d 0e 04 00 00    //add    ebx,DWORD PTR fs:0x40e
0x647: 64 03 1d 8e 04 00 00    //add    ebx,DWORD PTR fs:0x48e
0x64e: 64 03 1d 0e 05 00 00    //add    ebx,DWORD PTR fs:0x50e
0x655: 64 03 1d 8e 05 00 00    //add    ebx,DWORD PTR fs:0x58e
0x65c: 64 03 1d 0e 06 00 00    //add    ebx,DWORD PTR fs:0x60e
0x663: 64 03 1d 8e 06 00 00    //add    ebx,DWORD PTR fs:0x68e
0x66a: 64 03 1d 0e 07 00 00    //add    ebx,DWORD PTR fs:0x70e
0x671: 64 03 1d 8e 07 00 00    //add    ebx,DWORD PTR fs:0x78e
0x678: 64 03 1d 0e 08 00 00    //add    ebx,DWORD PTR fs:0x80e
0x67f: 64 03 1d 8e 08 00 00    //add    ebx,DWORD PTR fs:0x88e
0x686: 64 03 1d 0e 09 00 00    //add    ebx,DWORD PTR fs:0x90e
0x68d: 64 03 1d 8e 09 00 00    //add    ebx,DWORD PTR fs:0x98e
0x694: 64 03 1d 0e 0a 00 00    //add    ebx,DWORD PTR fs:0xa0e
0x69b: 64 03 1d 8e 0a 00 00    //add    ebx,DWORD PTR fs:0xa8e
0x6a2: 64 03 1d 0e 0b 00 00    //add    ebx,DWORD PTR fs:0xb0e
0x6a9: 64 03 1d 8e 0b 00 00    //add    ebx,DWORD PTR fs:0xb8e
0x6b0: 64 03 1d 0e 0c 00 00    //add    ebx,DWORD PTR fs:0xc0e
0x6b7: 64 03 1d 8e 0c 00 00    //add    ebx,DWORD PTR fs:0xc8e
0x6be: 64 03 1d 0e 0d 00 00    //add    ebx,DWORD PTR fs:0xd0e
0x6c5: 64 03 1d 8e 0d 00 00    //add    ebx,DWORD PTR fs:0xd8e
0x6cc: 64 03 1d 0e 0e 00 00    //add    ebx,DWORD PTR fs:0xe0e
0x6d3: 64 03 1d 8e 0e 00 00    //add    ebx,DWORD PTR fs:0xe8e
0x6da: 64 03 1d 0e 0f 00 00    //add    ebx,DWORD PTR fs:0xf0e
0x6e1: 64 03 1d 8e 0f 00 00    //add    ebx,DWORD PTR fs:0xf8e
0x6e8: F4                      //hlt

//Expected Value: EBX = 128 or 0x80
//TLB:
//0x00000: 0x00000, 
//0x02000: 0x00002, 
//0x04000: 0x00005,
//0x0B000: 0x00004, 
//0x0C000: 0x00007, 
//0x0A000: 0x00005, 
//0x03000: 0x00003

//LIMITS:
//UC_X86_REG_CS: 0x04FFF,
//UC_X86_REG_DS: 0x0FFFF,
//UC_X86_REG_SS: 0x0FFFF,
//UC_X86_REG_ES: 0x0FFFF,  
//UC_X86_REG_FS: 0x0FFFF,
//UC_X86_REG_GS: 0x0FFFF