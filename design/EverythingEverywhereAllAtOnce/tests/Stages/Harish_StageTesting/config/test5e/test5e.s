0x0:  66 b8 00 02             //mov    ax,0x200
0x4:  8e d8                   //mov    ds,eax
0x6:  66 b8 00 0b             //mov    ax,0xb00
0xa:  8e c0                   //mov    es,eax
0xc:  b9 50 00 00 00          //mov    ecx,0x50
0x11: be 0e 00 00 00          //mov    esi,0xe
0x16: bf 0e 00 00 00          //mov    edi,0xe
0x1b: fc                      //cld
0x1c: f3 a5                   //rep    movs DWORD PTR es:[edi],DWORD PTR ds:[esi]
0x1e: fd                      //std
0x1f: b9 50 00 00 00          //mov    ecx,0x50
0x24: 83 c6 fc                //add    esi,0xfffffffc
0x27: 83 c7 fc                //add    edi,0xfffffffc
0x2a: f3 a7                   //repz cmps DWORD PTR ds:[esi],DWORD PTR es:[edi]
0x2c: 75 16                   //jne    44 <a>
0x2e: b9 50 00 00 00          //mov    ecx,0x50
0x33: be 0e 00 00 00          //mov    esi,0xe
0x38: bf 0e 00 00 00          //mov    edi,0xe
0x3d: 83 46 21 01             //add    DWORD PTR [esi+0x21],0x1
0x41: fc                      //cld
0x42: f3 a7                   //repz cmps DWORD PTR ds:[esi],DWORD PTR es:[edi]
0x44: f4                      //a: hlt

0x200E: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
0x201E: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F
0x202E: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F
0x203E: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F
0x204E: 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F
0x205E: 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F
0x206E: 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F
0x207E: 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 7E 7F
0x208E: 80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F
0x209E: 90 91 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F
0x20AE: A0 A1 A2 A3 A4 A5 A6 A7 A8 A9 AA AB AC AD AE AF
0x20BE: B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA BB BC BD BE BF
0x20CE: C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 CA CB CC CD CE CF
0x20DE: D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 DA DB DC DD DE DF
0x20EE: E0 E1 E2 E3 E4 E5 E6 E7 E8 E9 EA EB EC ED EE EF
0x20FE: F0 F1 F2 F3 F4 F5 F6 F7 F8 F9 FA FB FC FD FE FF
0x210E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x211E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x212E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x213E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x214E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x215E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x216E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x217E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x218E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x219E: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x21AE: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x21BE: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x21CE: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x21DE: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x21EE: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF
0x21FE: DE AD BE EF DE AD BE EF DE AD BE EF DE AD BE EF

//Final expected results
//ESI/EDI = 0x32
//ECX = 0x47
//ZF = 0

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