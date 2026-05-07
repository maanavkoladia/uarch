# Writeback (WB) — How It Works & How It Was Ported to Structural

This document is a reference for the writeback subsystem: what it does, how
its submodules fit together, and the conventions used to port it from
SystemVerilog to pure 2005-style structural Verilog. Future ports
(predictor, BTB, register-file writeback, etc.) should follow the same
playbook.

---

## 1. What writeback does

WB is the stage that *commits* in-flight stores to the memory hierarchy. By
the time an instruction reaches WB, EXE has already produced the store data
and physical addresses; WB's only job is to:

1. Latch the store(s) into the right *bank* of the store queue (or into the
   MIO queue, for non-cacheable I/O stores) so the dcache can drain them.
2. Track when the dcache has accepted (popped) each entry.
3. Stall the upstream pipeline if a queue refuses a push it cannot accept
   (`wb_stall`).
4. Forward queue head data to the dcache port and forward all in-flight
   store addresses to dependency-check logic in decode.

The compute work is trivial — WB is mostly a fan-out/store-buffer, not an
ALU stage.

### Inputs / outputs at the WB top
```
input  wb_latches_t  wb_latches              // EXE output
input  bool          write_success[4]        // dcache pop ack per bank
input  bool          write_success_mio       // dcache pop ack for MIO_Q
output wb_outputs_t  outputs                 // -> DC, decode, MEM
```

`wb_outputs_t` carries:
- `valid`, `wb_stall`             — pipeline control
- `stq_heads[4]`                  — head entry of each bank to dcache
- `mio_head`                      — head of the MIO queue to dcache
- `dep_check.entries[16]`         — flattened view of every in-flight STQ
                                    entry (4 banks * 4 deep) for decode
- `ST_OP, ST_XCL, ST_PADDR_0/1`   — pass-through to MEM stage

---

## 2. Submodule layout

Five files, all in `rtl/core/WB/structural/`:

```
                wb_latches  write_success[4]   write_success_mio
                    |              |                  |
                    v              v                  v
                +-----------------+  +----------------+
                |   ST_Q_logic    |  | ST_Q_MIO_logic |
                | (combinational) |  | (combinational)|
                +--------+--------+  +-------+--------+
                         |                   |
       per-bank push     |                   | mio push
       data + pop wires  v                   v
                  +-----+-----+         +---------+
                  |  ST_Q x4  |         |  MIO_Q  |
                  |  (FIFO 4) |         | (1-entry)|
                  +-----+-----+         +----+----+
                        |                    |
                  per-bank flat outputs      flat outputs
                        |                    |
                        v                    v
                +-----------------------------+
                |          WB.sv              |
                |  pack -> stq_outputs structs|
                |  pack -> mio_q_output struct|
                |  build stq_heads, dc_dep    |
                |  build wb_outputs, stall    |
                +-----------------------------+
```

### Per-submodule role

| File             | Kind          | What it does                                                     |
|------------------|---------------|------------------------------------------------------------------|
| ST_Q_logic.sv    | Combinational | Decodes wb_latches into per-bank push commands and data.         |
| ST_Q_MIO_logic.sv| Combinational | Same, but the MIO path (single queue, no bank-routing).          |
| ST_Q.sv          | Sequential    | One bank: a 4-deep FIFO of `st_q_entry_t`.                       |
| MIO_Q.sv         | Sequential    | A single-entry "queue" (replaces on push, invalidates on pop).   |
| WB.sv            | Top wrapper   | Wires the four above + assembles the output struct.              |

### Stores are mutually exclusive across the two paths
For a given valid WB op, only ONE of these can be true:
- `~MIO`: store goes through ST_Q_logic into one (or two, if `ST_XCL`) of
  the four cacheable banks.
- `MIO`:  store goes through ST_Q_MIO_logic into the MIO_Q.

`ST_Q_logic` gates entries with `~MIO`; `ST_Q_MIO_logic` gates with `MIO`.

---

## 3. Data structure shapes (for unrolling structs)

The struct types live in `rtl/core/WB/pkg/WriteBack_pkg.sv` and the common
packages. Field widths assume the project constants
`CACHE_LINES_SIZE_B=16`, `ST_Q_DEPTH=4`, `NUM_WB_ST_QS=4`,
`p_address_t = 15 b` (`PHY_MEM_SIZE = 1<<15`), `uint16_t = 16 b`,
`byte_t = 8 b`.

### `st_q_entry_t` (a queue slot)
```
valid     : 1
address   : 15
bit_vec   : 16
data[16]  : 16 * 8 = 128
                     -- total 160 b
```

### `st_q_inputs_t` (control to one ST_Q)
```
data : st_q_entry_t   -- (160)
push : 1
pop  : 1
```

### `st_q_outputs_t` (one ST_Q's status)
```
full          : 1
empty         : 1
valid[4]      : 4 * 1
address[4]    : 4 * 15
head_address  : 15
bit_vec       : 16
data[16]      : 128
push_fail     : 1
```

### `mio_entry_t`
```
valid    : 1   -- (legacy stored, but never read; can be dropped)
address  : 15
data[16] : 128
```

### `mio_inputs_t`
```
data : mio_entry_t
push : 1
pop  : 1
```

### `st_q_2_dcache_t` (one head -> dcache)
```
full     : 1
empty    : 1
address  : 15
bit_vec  : 16
data[16] : 128
```

### `st_q_2_dep_check_outputs_t`
```
entries[16] : { valid : 1, address : 15 }   -- 4 banks * 4 deep
```

---

## 4. Port-flattening convention (the unrolling rule)

When a structural module replaces a SV one, every struct field becomes its
own port, named after the struct path:

```
struct_t   sig_name
    .field_a
    .field_b
    .nested.field_c
```
becomes
```
sig_name_field_a
sig_name_field_b
sig_name_nested_field_c
```

For *arrays of structs* of fixed length N (e.g. `stq_info[4]`), unroll
**per-element** — one full set of field-ports per array index — rather than
packing into a single wide bus per field. This is more lines but each port
self-documents its bank/index:

```
stq_info_0_push,  stq_info_0_pop,  stq_info_0_data_address, ...
stq_info_1_push,  stq_info_1_pop,  stq_info_1_data_address, ...
```

For *arrays of bytes that are intrinsically a contiguous wide bus* (e.g.
`byte_t data[16]`, `byte_t res_buf[32]`), pack into a single flat
`[N*8-1:0]` wire. These aren't structs — they're just data buses that
happen to have been declared as byte arrays in SV.

WB.sv is responsible for the pack/unpack between SV byte arrays and the
flat buses, via tiny `generate ... for` blocks.

---

## 5. Gate / cell idioms used (cell library: `lib/STDCells/STDCell_Macros.vh`)

You only get to use what's in `STDCell_Macros.vh`. Inventory is roughly:
- Gates: `INV_N`, `AND_2..12`, `OR_2..12`, `NAND_2..4`, `NOR_2..4`
- Muxes: `MUX_2`, `MUX_3`, `MUX_4`, `MUX_8`, `MUX_16`, `MUX_32`, `MUX_64`
- Compare: `CMP_N` (equality, parameterizable width)
- Arithmetic: `ADD_N` (Kogge-Stone, with `cin` -> use as increment)
- Decoder: `DECODER_N` (binary -> one-hot, INPUTS = address bits)
- Register: `REG_RST_WE` (active-low reset, active-high WE),
            `REG_RST` (same but WE tied to 1)
- Misc: `BUFFER_DELAY`, `TRISTATE_L`, `BUS_TRISTATE`, `ROM_32W_64b`

If you need a cell that doesn't exist (e.g. XOR), STOP and ask the user.
Don't write your own primitives.

### Common patterns the WB port uses

#### Negation / not-equal
There's no XOR macro. `a != b` becomes:
```
CMP_N(eq, w, a, b)
INV_N(neq, eq)
```

#### Increment by 1
No INC cell. Use `ADD_N` with `cin = 1` and the second operand zero:
```
ADD_N(u_inc, W, sum_w, cout_w, x_w, {W{1'b0}}, 1'b1)
```

#### "If not push, hold" register (write-enable mux semantics)
Rely on `REG_RST_WE`'s WE behavior — when WE=0 the register holds. So the
SV pattern
```
if (cond) reg <= new_value;
```
becomes
```
REG_RST_WE(u_reg, W, clk, rst, cond, new_value, reg_q)
```

For "if A: write x, else if B: write 0, else hold":
```
WE  = A | B
DIN = A ? x : 0          -- becomes MUX_2(0, x, A)
REG_RST_WE(u_reg, W, clk, rst, WE, DIN, reg_q)
```
Both ST_Q's per-slot `valid` bit and MIO_Q's logic use this exact pattern.

#### FIFO full/empty (extra-bit method)
4-deep FIFO needs 2-bit indices, but uses 3-bit pointers (an extra wrap
bit on top) to distinguish full from empty when head_ptr == tail_ptr:
```
empty = (head[2:0] == tail[2:0])                    -> CMP_N(width=3)
eq_low = (head[1:0] == tail[1:0])                   -> CMP_N(width=2)
neq_msb = ~(head[2] == tail[2])                     -> CMP_N(width=1) + INV_N
full  = neq_msb & eq_low                            -> AND_2
```

#### One-hot WE generation
For per-slot writes in a FIFO:
```
DECODER_N(width=2, in=tail_ptr, out=tail_dec[3:0])  -- one-hot
push_to_i = AND_2(valid_push, tail_dec[i])          -- per slot
```
Same pattern with `head_ptr` for pop-side decoding.

#### Head-selected output mux
```
MUX_4(width=W, out=head_data,
      q_0_data, q_1_data, q_2_data, q_3_data,
      head_ptr)
```

#### Dropping SV-only constructs
- `$error` / `assert property` blocks — strip out (no runtime in
  pure-structural). Keep the comment so the design intent isn't lost.
- `'{default : '0}` initializers — replaced by the active-low reset on
  `MPS_reg_rst_we$`.

---

## 6. The "keep the WB top SV-style" trick

When porting a single submodule, you don't have to rewrite the whole
parent. WB.sv keeps:
- Its `import ...::*` lines
- Its `wb_latches_t`, `wb_outputs_t` struct ports
- Its `always_comb` blocks that build `stq_heads`, `dc_dep`, `outputs`
- Its `always_ff` for `stall_flop`

What changes is *only*:
1. New flat wires for every flat port on every submodule.
2. Submodule instantiations rewritten to those flat wires.
3. A small **pack** `always_comb` per submodule output: rebuilds the
   struct that downstream code already consumes (`stq_outputs[i]`,
   `mio_q_output`).
4. A small **flatten** `generate for` for `wb_latches.res_buf` (byte
   array -> 256-bit bus).

This means downstream WB code is untouched — much easier to diff and
review than rewriting the whole top-level.

When the WB top itself is later ported, those pack/flatten blocks
disappear and the struct ports become flat ports too.

---

## 7. Subtle behaviors worth knowing (all preserved by the port)

- **ST_Q_logic bank-collision priority**: if entry0 and entry1 target the
  same bank (a design error flagged by the legacy `$error`), entry1 wins.
  The port preserves this priority via nested `MUX_2`s; the legacy
  assertion is dropped.
- **MIO push-replaces-on-full**: if push arrives while full and pop
  doesn't, `push_fail` asserts and the entry is *not* overwritten — the
  upstream stalls. If pop *does* arrive same cycle, push succeeds and
  overwrites the popped entry.
- **`stall_flop` is registered in WB.sv but `wb_stall` output is
  combinational** (`stall_flop_next`). The flop is only used by the
  scoreboard / register-WB path that runs separately.
- **`mio_q.valid` is dead state** — it's set in legacy SV but never read
  (the output struct `st_q_2_dcache_t` has no `valid` field). The
  structural port omits the register entirely; behavior is identical.
- **Reset is active LOW**: legacy code uses `if(!rst)`; the
  `MPS_reg_rst_we$` cell uses `CLR(rst)` with active-low semantics.
  Don't invert.

---

## 8. Verification checklist (per future port)

When adding a structural copy of a module:
1. Compile the structural folder with the project's existing testbench.
2. Run regression that exercises the module — for WB, that's any test
   that issues stores. Confirm bit-identical results to the SV path.
3. Spot-check the four cycles of: idle, push only, pop only, push+pop,
   push-while-full. These cover all state-change classes for both ST_Q
   and MIO_Q.
4. Check `wb_stall` propagation: any of the five push_fail signals
   (`stq_out_<i>_push_fail` x 4 + `mio_push_fail`) should pop the OR-tree
   in WB.sv's `stall_flop_next`.
