0x0:  b8 00 00 00 00          //mov    eax,0x0
0x5:  bb 00 00 00 00          //mov    ebx,0x0
0xa:  b9 00 00 00 00          //mov    ecx,0x0
0xf:  ba 00 00 00 00          //mov    edx,0x0
0x14: 05 00 b0 00 00          //add    eax,0xb000
0x19: 05 00 0a 00 00          //add    eax,0xa00
0x1e: 05 b0 00 00 00          //add    eax,0xb0
0x23: 83 c0 0e                //add    eax,0xe
0x26: 83 e3 00                //and    ebx,0x0
0x29: 83 d3 05                //adc    ebx,0x5
0x2c: b9 ff ff ff ff          //mov    ecx,0xffffffff
0x31: 83 c1 01                //add    ecx,0x1
0x34: 83 d3 02                //adc    ebx,0x2
0x37: 83 e1 00                //and    ecx,0x0
0x3a: 83 db 01                //sbb    ebx,0x1
0x3d: b9 ff ff ff ff          //mov    ecx,0xffffffff
0x42: 83 c1 01                //add    ecx,0x1
0x45: 83 db 02                //sbb    ebx,0x2
0x48: d1 e3                   //shl    ebx,1
0x4a: d1 fb                   //sar    ebx,1
0x4c: f7 d3                   //not    ebx
0x4e: f7 d3                   //not    ebx
0x50: 83 cb 10                //or     ebx,0x10
0x53: 83 e3 0f                //and    ebx,0xf
0x56: 89 c2                   //mov    edx,eax
0x58: b8 00 00 00 00          //mov    eax,0x0
0x5d: 05 00 c0 00 00          //add    eax,0xc000
0x62: 05 00 0a 00 00          //add    eax,0xa00
0x67: 05 f0 00 00 00          //add    eax,0xf0
0x6c: 83 c0 0e                //add    eax,0xe
0x6f: c1 e0 08                //shl    eax,0x8
0x72: c1 e0 08                //shl    eax,0x8
0x75: 09 d0                   //or     eax,edx
0x77: 93                      //xchg   ebx,eax
0x78: 83 c0 0c                //add    eax,0xc
0x7b: 0f bc c8                //bsf    ecx,eax
0x7e: 01 c8                   //add    eax,ecx
0x80: 93                      //xchg   ebx,eax
0x81: ba 11 11 11 11          //mov    edx,0x11111111
0x86: 81 c2 22 22 22 22       //add    edx,0x22222222
0x8c: 81 ca 44 44 44 44       //or     edx,0x44444444
0x92: 81 e2 77 77 77 77       //and    edx,0x77777777
0x98: 89 d1                   //mov    ecx,edx
0x9a: f7 d1                   //not    ecx
0x9c: 09 ca                   //or     edx,ecx
0x9e: 83 e2 00                //and    edx,0x0
0xa1: 89 c1                   //mov    ecx,eax
0xa3: 0f b1 d9                //cmpxchg ecx,ebx
0xa6: b9 ef be ad de          //mov    ecx,0xdeadbeef
0xab: 0f b1 d9                //cmpxchg ecx,ebx
0xae: b8 be ba fe ca          //mov    eax,0xcafebabe
0xb3: b9 00 00 00 00          //mov    ecx,0x0
0xb8: 83 c1 0a                //add    ecx,0xa
0xbb: 83 c1 0a                //add    ecx,0xa
0xbe: 83 c1 0a                //add    ecx,0xa
0xc1: 83 c1 0a                //add    ecx,0xa
0xc4: 83 c1 0a                //add    ecx,0xa
0xc7: 83 c1 0a                //add    ecx,0xa
0xca: 83 c1 0a                //add    ecx,0xa
0xcd: 83 c1 0a                //add    ecx,0xa
0xd0: 83 c1 0a                //add    ecx,0xa
0xd3: 83 c1 0a                //add    ecx,0xa
0xd6: ba 64 00 00 00          //mov    edx,0x64
0xdb: 83 e2 00                //and    edx,0x0
0xde: 83 d9 0a                //sbb    ecx,0xa
0xe1: 83 d9 0a                //sbb    ecx,0xa
0xe4: 83 d9 0a                //sbb    ecx,0xa
0xe7: 83 d9 0a                //sbb    ecx,0xa
0xea: 83 d9 0a                //sbb    ecx,0xa
0xed: 83 d9 0a                //sbb    ecx,0xa
0xf0: 83 d9 0a                //sbb    ecx,0xa
0xf3: 83 d9 0a                //sbb    ecx,0xa
0xf6: 83 d9 0a                //sbb    ecx,0xa
0xf9: 83 d9 0a                //sbb    ecx,0xa
0xfc: 89 ca                   //mov    edx,ecx
0xfe: f7 d2                   //not    edx
0x100:    f7 d2                   //not    edx
0x102:    83 e2 ff                //and    edx,0xffffffff
0x105:    83 ca 00                //or     edx,0x0
0x108:    ba 00 00 00 40          //mov    edx,0x40000000
0x10d:    d1 e2                   //shl    edx,1
0x10f:    d1 fa                   //sar    edx,1
0x111:    bb 00 00 00 00          //mov    ebx,0x0
0x116:    83 c3 01                //add    ebx,0x1
0x119:    83 c3 02                //add    ebx,0x2
0x11c:    83 c3 03                //add    ebx,0x3
0x11f:    83 c3 04                //add    ebx,0x4
0x122:    83 c3 05                //add    ebx,0x5
0x125:    83 c3 06                //add    ebx,0x6
0x128:    83 c3 07                //add    ebx,0x7
0x12b:    83 c3 08                //add    ebx,0x8
0x12e:    83 c3 09                //add    ebx,0x9
0x131:    83 c3 0a                //add    ebx,0xa
0x134:    b9 ff ff ff ff          //mov    ecx,0xffffffff
0x139:    21 d9                   //and    ecx,ebx
0x13b:    81 c9 0f 0f 0f 0f       //or     ecx,0xf0f0f0f
0x141:    81 e1 f0 f0 f0 f0       //and    ecx,0xf0f0f0f0
0x147:    f7 d1                   //not    ecx
0x149:    89 ca                   //mov    edx,ecx
0x14b:    87 da                   //xchg   edx,ebx
0x14d:    bb 00 00 00 00          //mov    ebx,0x0
0x152:    b9 00 00 00 00          //mov    ecx,0x0
0x157:    ba 00 00 00 00          //mov    edx,0x0
0x15c:    83 c3 00                //add    ebx,0x0
0x15f:    83 c1 00                //add    ecx,0x0
0x162:    83 c2 00                //add    edx,0x0
0x165:    83 e3 00                //and    ebx,0x0
0x168:    83 e1 00                //and    ecx,0x0
0x16b:    83 e2 00                //and    edx,0x0
0x16e:    f4                      //hlt

//Expected Result: EAX = CAFEBABE


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
