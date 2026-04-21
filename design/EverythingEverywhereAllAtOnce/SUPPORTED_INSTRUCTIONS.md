# Supported Instructions — EE 382N Project RTL

**Reference this file before writing any test bench.**  
Only use instructions marked ✅ (currently supported & tested). Do **not** use instructions marked ❌ (not in project scope) or 🔲 (in project spec, not yet tested/integrated).

---

## Arithmetic

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| 37 | AAA | ASCII adjust AL after addition | ✅ |
| 04 ib | ADD AL,imm8 | Add imm8 to AL | ✅ |
| 05 iw | ADD AX,imm16 | Add imm16 to AX | ✅ |
| 05 id | ADD EAX,imm32 | Add imm32 to EAX | ✅ |
| 80 /0 ib | ADD r/m8,imm8 | Add imm8 to r/m8 | ✅ |
| 81 /0 iw | ADD r/m16,imm16 | Add imm16 to r/m16 | ✅ |
| 81 /0 id | ADD r/m32,imm32 | Add imm32 to r/m32 | ✅ |
| 83 /0 ib | ADD r/m16,imm8 | Add sign-extended imm8 to r/m16 | ✅ |
| 83 /0 ib | ADD r/m32,imm8 | Add sign-extended imm8 to r/m32 | ✅ |
| 00 /r | ADD r/m8,r8 | Add r8 to r/m8 | ✅ |
| 01 /r | ADD r/m16,r16 | Add r16 to r/m16 | ✅ |
| 01 /r | ADD r/m32,r32 | Add r32 to r/m32 | ✅ |
| 02 /r | ADD r8,r/m8 | Add r/m8 to r8 | ✅ |
| 03 /r | ADD r16,r/m16 | Add r/m16 to r16 | ✅ |
| 03 /r | ADD r32,r/m32 | Add r/m32 to r32 | ✅ |
| 81 /2 id | ADC r/m32,imm32 | Add with CF imm32 to r/m32 | ✅ |
| 83 /2 ib | ADC r/m32,imm8 | Add with CF sign-extended imm8 to r/m32 | ✅ |
| 11 /r | ADC r/m32,r32 | Add with CF r32 to r/m32 | ✅ |
| 13 /r | ADC r32,r/m32 | Add with CF r/m32 to r32 | ✅ |
| 81 /3 id | SBB r/m32,imm32 | Subtract with borrow imm32 from r/m32 | ✅ |
| 83 /3 ib | SBB r/m32,imm8 | Subtract with borrow sign-extended imm8 from r/m32 | ✅ |
| 19 /r | SBB r/m32,r32 | Subtract with borrow r32 from r/m32 | ✅ |
| 1B /r | SBB r32,r/m32 | Subtract with borrow r/m32 from r32 | ✅ |

---

## Logical

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| 24 ib | AND AL,imm8 | AL AND imm8 | ✅ |
| 25 iw | AND AX,imm16 | AX AND imm16 | ✅ |
| 25 id | AND EAX,imm32 | EAX AND imm32 | ✅ |
| 80 /4 ib | AND r/m8,imm8 | r/m8 AND imm8 | ✅ |
| 81 /4 iw | AND r/m16,imm16 | r/m16 AND imm16 | ✅ |
| 81 /4 id | AND r/m32,imm32 | r/m32 AND imm32 | ✅ |
| 83 /4 ib | AND r/m16,imm8 | r/m16 AND sign-extended imm8 | ✅ |
| 83 /4 ib | AND r/m32,imm8 | r/m32 AND sign-extended imm8 | ✅ |
| 20 /r | AND r/m8,r8 | r/m8 AND r8 | ✅ |
| 21 /r | AND r/m16,r16 | r/m16 AND r16 | ✅ |
| 21 /r | AND r/m32,r32 | r/m32 AND r32 | ✅ |
| 22 /r | AND r8,r/m8 | r8 AND r/m8 | ✅ |
| 23 /r | AND r16,r/m16 | r16 AND r/m16 | ✅ |
| 23 /r | AND r32,r/m32 | r32 AND r/m32 | ✅ |
| 0C ib | OR AL,imm8 | AL OR imm8 | ✅ |
| 0D iw | OR AX,imm16 | AX OR imm16 | ✅ |
| 0D id | OR EAX,imm32 | EAX OR imm32 | ✅ |
| 80 /1 ib | OR r/m8,imm8 | r/m8 OR imm8 | ✅ |
| 81 /1 iw | OR r/m16,imm16 | r/m16 OR imm16 | ✅ |
| 81 /1 id | OR r/m32,imm32 | r/m32 OR imm32 | ✅ |
| 83 /1 ib | OR r/m16,imm8 | r/m16 OR sign-extended imm8 | ✅ |
| 83 /1 ib | OR r/m32,imm8 | r/m32 OR sign-extended imm8 | ✅ |
| 08 /r | OR r/m8,r8 | r/m8 OR r8 | ✅ |
| 09 /r | OR r/m16,r16 | r/m16 OR r16 | ✅ |
| 09 /r | OR r/m32,r32 | r/m32 OR r32 | ✅ |
| 0A /r | OR r8,r/m8 | r8 OR r/m8 | ✅ |
| 0B /r | OR r16,r/m16 | r16 OR r/m16 | ✅ |
| 0B /r | OR r32,r/m32 | r32 OR r/m32 | ✅ |
| F6 /2 | NOT r/m8 | Reverse each bit of r/m8 | ✅ |
| F7 /2 | NOT r/m16 | Reverse each bit of r/m16 | ✅ |
| F7 /2 | NOT r/m32 | Reverse each bit of r/m32 | ✅ |

---

## Shift

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| D0 /4 | SAL r/m8,1 | Multiply r/m8 by 2, once | ✅ |
| D2 /4 | SAL r/m8,CL | Multiply r/m8 by 2, CL times | ✅ |
| C0 /4 ib | SAL r/m8,imm8 | Multiply r/m8 by 2, imm8 times | ✅ |
| D1 /4 | SAL r/m16,1 | Multiply r/m16 by 2, once | ✅ |
| D3 /4 | SAL r/m16,CL | Multiply r/m16 by 2, CL times | ✅ |
| C1 /4 ib | SAL r/m16,imm8 | Multiply r/m16 by 2, imm8 times | ✅ |
| D1 /4 | SAL r/m32,1 | Multiply r/m32 by 2, once | ✅ |
| D3 /4 | SAL r/m32,CL | Multiply r/m32 by 2, CL times | ✅ |
| C1 /4 ib | SAL r/m32,imm8 | Multiply r/m32 by 2, imm8 times | ✅ |
| D0 /7 | SAR r/m8,1 | Signed divide r/m8 by 2, once | ✅ |
| D2 /7 | SAR r/m8,CL | Signed divide r/m8 by 2, CL times | ✅ |
| C0 /7 ib | SAR r/m8,imm8 | Signed divide r/m8 by 2, imm8 times | ✅ |
| D1 /7 | SAR r/m16,1 | Signed divide r/m16 by 2, once | ✅ |
| D3 /7 | SAR r/m16,CL | Signed divide r/m16 by 2, CL times | ✅ |
| C1 /7 ib | SAR r/m16,imm8 | Signed divide r/m16 by 2, imm8 times | ✅ |
| D1 /7 | SAR r/m32,1 | Signed divide r/m32 by 2, once | ✅ |
| D3 /7 | SAR r/m32,CL | Signed divide r/m32 by 2, CL times | ✅ |
| C1 /7 ib | SAR r/m32,imm8 | Signed divide r/m32 by 2, imm8 times | ✅ |

> Note: SHL is an alias for SAL — same opcode, same behavior.

---

## Bit Manipulation

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| 0F BC | BSF r16,r/m16 | Bit scan forward on r/m16 | ✅ |
| 0F BC | BSF r32,r/m32 | Bit scan forward on r/m32 | ✅ |

---

## Data Movement

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| 88 /r | MOV r/m8,r8 | Move r8 to r/m8 | ✅ |
| 89 /r | MOV r/m16,r16 | Move r16 to r/m16 | ✅ |
| 89 /r | MOV r/m32,r32 | Move r32 to r/m32 | ✅ |
| 8A /r | MOV r8,r/m8 | Move r/m8 to r8 | ✅ |
| 8B /r | MOV r16,r/m16 | Move r/m16 to r16 | ✅ |
| 8B /r | MOV r32,r/m32 | Move r/m32 to r32 | ✅ |
| 8C /r | MOV r/m16,Sreg | Move segment register to r/m16 | ✅ |
| 8E /r | MOV Sreg,r/m16 | Move r/m16 to segment register | ✅ |
| B0+rb | MOV r8,imm8 | Move imm8 to r8 | ✅ |
| B8+rw | MOV r16,imm16 | Move imm16 to r16 | ✅ |
| B8+rd | MOV r32,imm32 | Move imm32 to r32 | ✅ |
| C6 /0 | MOV r/m8,imm8 | Move imm8 to r/m8 | ✅ |
| C7 /0 | MOV r/m16,imm16 | Move imm16 to r/m16 | ✅ |
| C7 /0 | MOV r/m32,imm32 | Move imm32 to r/m32 | ✅ |
| 0F 6F /r | MOVQ mm,mm/m64 | Move quadword from mm/m64 to mm | 🔲 not yet |
| 0F 7F /r | MOVQ mm/m64,mm | Move quadword from mm to mm/m64 | 🔲 not yet |
| A4 | MOVS m8,m8 | Move byte DS:[(E)SI] to ES:[(E)DI] | 🔲 not yet |
| A5 | MOVS m16,m16 | Move word DS:[(E)SI] to ES:[(E)DI] | 🔲 not yet |
| A5 | MOVS m32,m32 | Move dword DS:[(E)SI] to ES:[(E)DI] | 🔲 not yet |
| F3 A4 | REP MOVS m8,m8 | Move ECX bytes from DS:ESI to ES:EDI | 🔲 not yet |
| F3 A5 | REP MOVS m16,m16 | Move ECX words from DS:ESI to ES:EDI | 🔲 not yet |
| F3 A5 | REP MOVS m32,m32 | Move ECX dwords from DS:ESI to ES:EDI | 🔲 not yet |
| F3 A7 | REPE CMPS m32,m32 | Find nonmatching dwords in ES:EDI and DS:ESI | 🔲 not yet |
| 90+rw | XCHG AX,r16 | Exchange r16 with AX | ✅ |
| 90+rd | XCHG EAX,r32 | Exchange r32 with EAX | ✅ |
| 86 /r | XCHG r/m8,r8 | Exchange r8 with r/m8 | ✅ |
| 87 /r | XCHG r/m16,r16 | Exchange r16 with r/m16 | ✅ |
| 87 /r | XCHG r/m32,r32 | Exchange r32 with r/m32 | ✅ |
| 0F 42 /r | CMOVC r16,r/m16 | Move if carry (CF=1) | ✅ |
| 0F 42 /r | CMOVC r32,r/m32 | Move if carry (CF=1) | ✅ |
| 0F B0 /r | CMPXCHG r/m8,r8 | Compare AL with r/m8; if equal ZF=1,r/m8=r8; else ZF=0,AL=r/m8 | ✅ |
| 0F B1 /r | CMPXCHG r/m16,r16 | Compare AX with r/m16 | ✅ |
| 0F B1 /r | CMPXCHG r/m32,r32 | Compare EAX with r/m32 | ✅ |

---

## Stack

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| FF /6 | PUSH r/m16 | Push r/m16 | ✅ |
| FF /6 | PUSH r/m32 | Push r/m32 | ✅ |
| 50+rw | PUSH r16 | Push r16 | ✅ |
| 50+rd | PUSH r32 | Push r32 | ✅ |
| 6A | PUSH imm8 | Push sign-extended imm8 | ✅ |
| 68 | PUSH imm16 | Push imm16 | ✅ |
| 68 | PUSH imm32 | Push imm32 | ✅ |
| 0E | PUSH CS | Push CS | ✅ |
| 16 | PUSH SS | Push SS | ✅ |
| 1E | PUSH DS | Push DS | ✅ |
| 06 | PUSH ES | Push ES | ✅ |
| 0F A0 | PUSH FS | Push FS | ✅ |
| 0F A8 | PUSH GS | Push GS | ✅ |
| 8F /0 | POP r/m16 | Pop top of stack into r/m16 | ✅ |
| 8F /0 | POP r/m32 | Pop top of stack into r/m32 | ✅ |
| 58+rw | POP r16 | Pop top of stack into r16 | ✅ |
| 58+rd | POP r32 | Pop top of stack into r32 | ✅ |
| 1F | POP DS | Pop into DS | ✅ |
| 07 | POP ES | Pop into ES | ✅ |
| 17 | POP SS | Pop into SS | ✅ |
| 0F A1 | POP FS | Pop into FS | ✅ |
| 0F A9 | POP GS | Pop into GS | ✅ |

---

## Control Flow

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| EB cb | JMP rel8 | Jump short, relative | ✅ |
| E9 cw | JMP rel16 | Jump near, relative | ✅ |
| E9 cd | JMP rel32 | Jump near, relative | ✅ |
| FF /4 | JMP r/m16 | Jump near, absolute indirect | ✅ |
| FF /4 | JMP r/m32 | Jump near, absolute indirect | ✅ |
| EA cd | JMP ptr16:16 | Jump far, absolute | ✅ |
| EA cp | JMP ptr16:32 | Jump far, absolute | ✅ |
| 77 cb | JNBE rel8 | Jump short if above (CF=0 and ZF=0) — also written JA | ✅ |
| 0F 87 cw | JNBE rel16 | Jump near if above (CF=0 and ZF=0) | ✅ |
| 0F 87 cd | JNBE rel32 | Jump near if above (CF=0 and ZF=0) | ✅ |
| 75 cb | JNE rel8 | Jump short if not equal (ZF=0) — also written JNZ | ✅ |
| 0F 85 cw | JNE rel16 | Jump near if not equal (ZF=0) | ✅ |
| 0F 85 cd | JNE rel32 | Jump near if not equal (ZF=0) | ✅ |
| E8 cw | CALL rel16 | Call near, relative | 🔲 not yet |
| E8 cd | CALL rel32 | Call near, relative | 🔲 not yet |
| FF /2 | CALL r/m16 | Call near, absolute indirect | 🔲 not yet |
| FF /2 | CALL r/m32 | Call near, absolute indirect | 🔲 not yet |
| 9A cp | CALL ptr16:32 | Call far, absolute | 🔲 not yet |
| C3 | RET | Near return | 🔲 not yet |
| CB | RET | Far return | 🔲 not yet |
| C2 iw | RET imm16 | Near return, pop imm16 bytes | 🔲 not yet |
| CA iw | RET imm16 | Far return, pop imm16 bytes | 🔲 not yet |
| CF | IRETD | Interrupt return (32-bit) | 🔲 not yet |

> **NOT in project scope** (❌ do not use): JBE (76), JE/JZ (74), JB/JC (72), JL (7C), JG (7F), LOOP, etc.

---

## MMX / SIMD

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| 0F 63 /r | PACKSSWB mm1,mm/m64 | Pack 4 signed words → 8 signed bytes (sat.) | 🔲 not yet |
| 0F 6B /r | PACKSSDW mm1,mm/m64 | Pack 2 signed dwords → 4 signed words (sat.) | 🔲 not yet |
| 0F FD /r | PADDW mm,mm/m64 | Add packed word integers | 🔲 not yet |
| 0F FE /r | PADDD mm,mm/m64 | Add packed dword integers | 🔲 not yet |
| 0F E0 /r | PAVGB mm1,mm2/m64 | Average packed unsigned bytes (round) | 🔲 not yet |
| 0F E3 /r | PAVGW mm1,mm2/m64 | Average packed unsigned words (round) | 🔲 not yet |

---

## Miscellaneous

| Opcode | Mnemonic | Description | Status |
|--------|----------|-------------|--------|
| F4 | HLT | Halt | ✅ |
| FC | CLD | Clear DF flag | ✅ |
| FD | STD | Set DF flag | ✅ |

---

## Quick Summary — Currently Supported ✅

AAA · ADC · ADD · AND · BSF · CLD · CMOVC · CMPXCHG · HLT · JMP · JNBE (JA) · JNE (JNZ) · MOV (register/immediate/memory — **not** MOVS/MOVQ) · NOT · OR · POP · PUSH · SAL/SHL · SAR · SBB · STD · XCHG

## Jumps — Only These Are Supported

| AT&T mnemonic | Condition | Opcode |
|---------------|-----------|--------|
| `jmp` | always | EB / E9 / FF /4 / EA |
| `jnbe` / `ja` | CF=0 **and** ZF=0 | 77 / 0F 87 |
| `jne` / `jnz` | ZF=0 | 75 / 0F 85 |

**❌ Do not use**: `jbe`, `je`, `jz`, `jb`, `jc`, `jl`, `jg`, `jle`, `jge`, `jnl`, `jnle`, or any conditional jump not in the table above.
