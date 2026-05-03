# DCache_Arbitration — Structural Verilog 2005 Port Plan

## Reference SV
`rtl/DCache/DCache_Arbitration.sv` — treat as ground truth; replicate its semantics exactly.

## Files to Touch
| File | Action |
|---|---|
| `rtl/DCache/structural/DCache_Arbitration.sv` | Replace entire content with structural port |
| `rtl/DCache/structural/DCache_TOP.sv` | Add `` `define USE_STRUCTURAL_ARB `` flag + flat tap wires + `ifdef` switch on instantiation |

---

## Hard Rules
- No `always` blocks of any kind (`always_comb`, `always_ff`, `always`)
- No ternary operators (`?:`)
- No logical or bitwise operators in logic (`&&`, `||`, `!`, `&`, `|`, `~`, `^`)
- `assign` is **only** used for wire-to-wire connection or bit-replication (`{N{x}}`)
- All logic through macro gate instances from `STDCell_Macros.vh`
- Module name stays `DCache_Arbitration` — no `_struct` suffix
- All generate loop variable names follow the `g_*` convention from existing code
- Preserve all generate block names from the SV reference where they exist
- Double-check every signal name against the SV reference before finalising — the last structural port had a variable name swap bug

---

## Struct Sizing Reference

### `block_req_t` field layout (161 bits per block)
| Field | Width | Notes |
|---|---|---|
| `oe` | 1 | active load request |
| `we` | 1 | active store request |
| `p_addr` | 15 | `p_address_t = $clog2(PHY_MEM_SIZE) = 15` |
| `vec` | 16 | byte-write vector (`uint16_t`) |
| `st_q_data` | 128 | store data, 16 bytes flat |

### `core_2_dcache_t` relevant fields
| Field | Width | Notes |
|---|---|---|
| `ld_addr_0_V` | 1 | load-0 valid |
| `ld_addr_0` | 15 | load-0 physical address |
| `ld_addr_1_V` | 1 | load-1 valid |
| `ld_addr_1` | 15 | load-1 physical address |
| `stq_heads[4].full` | 1 each | store queue full flag |
| `stq_heads[4].empty` | 1 each | store queue empty flag |
| `stq_heads[4].address` | 15 each | store queue head address |
| `stq_heads[4].bit_vec` | 16 each | byte-write vector |
| `stq_heads[4].data[16]` | 128 each | store data (16 bytes → 128-bit flat) |
| `memStage_CLR_REQ[4]` | 1 each | mem stage clears outstanding load request |

### Key constants
- `DCACHE_NUM_BLOCKS = 4`, `NUM_WB_ST_QS = 4` — same value, same per-block index
- `LD_REQ_BANK_UB = 5`, `LD_REQ_BANK_LB = 4` — bits `[5:4]` of `p_addr` select the bank (`DCACHE_BANK_BANK_WIDTH = 2`)
- Reset is **active-low** (`rst`)

---

## Registered State

Both groups use `REG_RST` (always-enabled, active-low reset clears to 0).

### Group 1 — `reqs[4]` (one per DCache block)
| Register | Width |
|---|---|
| `reqs_oe_q[4]` | 1 |
| `reqs_we_q[4]` | 1 |
| `reqs_paddr_q[4]` | 15 |
| `reqs_vec_q[4]` | 16 |
| `reqs_data_q[4]` | 128 |

### Group 2 — `st_override[4]`
| Register | Width |
|---|---|
| `st_override_q[4]` | 1 |

---

## Flat Port Interface

### Replace `input core_2_dcache_t core_i` with
```verilog
input wire        core_ld_addr_0_V_i,
input wire [14:0] core_ld_addr_0_i,
input wire        core_ld_addr_1_V_i,
input wire [14:0] core_ld_addr_1_i,
input wire        core_stq_full_i    [NUM_WB_ST_QS],
input wire        core_stq_empty_i   [NUM_WB_ST_QS],
input wire [14:0] core_stq_addr_i    [NUM_WB_ST_QS],
input wire [15:0] core_stq_bitvec_i  [NUM_WB_ST_QS],
input wire [127:0] core_stq_data_i   [NUM_WB_ST_QS],
input wire        core_memClrReq_i   [DCACHE_NUM_BLOCKS],
```

### Replace `output block_req_t reqs_2_blocks_o[DCACHE_NUM_BLOCKS]` with
```verilog
output wire        reqs_oe_o    [DCACHE_NUM_BLOCKS],
output wire        reqs_we_o    [DCACHE_NUM_BLOCKS],
output wire [14:0] reqs_paddr_o [DCACHE_NUM_BLOCKS],
output wire [15:0] reqs_vec_o   [DCACHE_NUM_BLOCKS],
output wire [127:0] reqs_data_o [DCACHE_NUM_BLOCKS],
```

### Keep as-is (already flat)
```verilog
input  wire       block_hit_i     [DCACHE_NUM_BLOCKS],
output wire       reqServed_0_o,
output wire       reqServed_1_o,
output wire       st_override_o   [NUM_WB_ST_QS],
output wire       writeSuccess_o  [NUM_WB_ST_QS],
```

---

## Combinational Logic (dependency order)

### Module-level wire assigns
```
ld_req_0_bankNum = core_ld_addr_0_i[5:4]   // assign — no gate needed
ld_req_1_bankNum = core_ld_addr_1_i[5:4]   // assign — no gate needed
```

### Per-block generate — `generate for (g_i = 0; g_i < 4; g_i++)` named `g_arb_block`

```
// Constant 2-bit wire for bank compare
wire [1:0] g_bank_const;
assign g_bank_const = g_i[1:0];   // genvar is compile-time constant

// (1) Block idleness: NOR(we, oe)
block_idleness[g_i]      = NOR_2(reqs_we_q[g_i], reqs_oe_q[g_i])

// (2) readyForNewReq
clr_and_oe[g_i]          = AND_2(core_memClrReq_i[g_i], reqs_oe_q[g_i])
we_and_hit[g_i]          = AND_2(reqs_we_q[g_i], block_hit_i[g_i])
readyForNewReq[g_i]      = OR_3(clr_and_oe[g_i], we_and_hit[g_i], block_idleness[g_i])

// (3) LD bank match
ld0_bank_match[g_i]      = CMP_N(2, ld_req_0_bankNum, g_bank_const)
ld1_bank_match[g_i]      = CMP_N(2, ld_req_1_bankNum, g_bank_const)

// (4) LD present at this bank
ld0_at_bank[g_i]         = AND_2(core_ld_addr_0_V_i, ld0_bank_match[g_i])
ld1_at_bank[g_i]         = AND_2(core_ld_addr_1_V_i, ld1_bank_match[g_i])
ldReq_2_BankPresent[g_i] = OR_2(ld0_at_bank[g_i], ld1_at_bank[g_i])

// (5) Store select condition
not_stq_empty[g_i]       = INV_N(core_stq_empty_i[g_i])
st_override_sel[g_i]     = AND_2(st_override_q[g_i], not_stq_empty[g_i])
no_ld_present[g_i]       = INV_N(ldReq_2_BankPresent[g_i])
no_ld_sel[g_i]           = AND_2(no_ld_present[g_i], not_stq_empty[g_i])
st_sel[g_i]              = OR_2(st_override_sel[g_i], no_ld_sel[g_i])

// (6) Mutually exclusive valid selects (SV if/else if/else if chain)
not_st_sel[g_i]          = INV_N(st_sel[g_i])
not_ld0_at_bank[g_i]     = INV_N(ld0_at_bank[g_i])
store_valid[g_i]         = AND_2(readyForNewReq[g_i], st_sel[g_i])
ld0_valid[g_i]           = AND_3(readyForNewReq[g_i], not_st_sel[g_i], ld0_at_bank[g_i])
ld1_valid[g_i]           = AND_4(readyForNewReq[g_i], not_st_sel[g_i], not_ld0_at_bank[g_i], ld1_at_bank[g_i])
keep_valid[g_i]          = INV_N(readyForNewReq[g_i])

// (7) Replication enables (assign only — bit replication, no logic)
store_valid_15[g_i]      = {15{store_valid[g_i]}}
ld0_valid_15[g_i]        = {15{ld0_valid[g_i]}}
ld1_valid_15[g_i]        = {15{ld1_valid[g_i]}}
keep_valid_15[g_i]       = {15{keep_valid[g_i]}}
store_valid_16[g_i]      = {16{store_valid[g_i]}}
keep_valid_16[g_i]       = {16{keep_valid[g_i]}}
store_valid_128[g_i]     = {128{store_valid[g_i]}}
keep_valid_128[g_i]      = {128{keep_valid[g_i]}}

// (8) nextReqs.oe
oe_new[g_i]              = OR_2(ld0_valid[g_i], ld1_valid[g_i])
oe_keep_gated[g_i]       = AND_2(keep_valid[g_i], reqs_oe_q[g_i])
nextReqs_oe[g_i]         = OR_2(oe_new[g_i], oe_keep_gated[g_i])

// (9) nextReqs.we
we_keep_gated[g_i]       = AND_2(keep_valid[g_i], reqs_we_q[g_i])
nextReqs_we[g_i]         = OR_2(store_valid[g_i], we_keep_gated[g_i])

// (10) nextReqs.p_addr — 4-way 15-bit gated OR
paddr_st_gated[g_i]      = AND_2(WIDTH=15, core_stq_addr_i[g_i],  store_valid_15[g_i])
paddr_ld0_gated[g_i]     = AND_2(WIDTH=15, core_ld_addr_0_i,      ld0_valid_15[g_i])
paddr_ld1_gated[g_i]     = AND_2(WIDTH=15, core_ld_addr_1_i,      ld1_valid_15[g_i])
paddr_keep_gated[g_i]    = AND_2(WIDTH=15, reqs_paddr_q[g_i],     keep_valid_15[g_i])
nextReqs_paddr[g_i]      = OR_4(WIDTH=15,  paddr_st_gated, paddr_ld0_gated, paddr_ld1_gated, paddr_keep_gated)

// (11) nextReqs.vec — 2-way 16-bit gated OR (ld/idle write 0 — no vec term needed)
vec_st_gated[g_i]        = AND_2(WIDTH=16, core_stq_bitvec_i[g_i], store_valid_16[g_i])
vec_keep_gated[g_i]      = AND_2(WIDTH=16, reqs_vec_q[g_i],        keep_valid_16[g_i])
nextReqs_vec[g_i]        = OR_2(WIDTH=16, vec_st_gated[g_i], vec_keep_gated[g_i])

// (12) nextReqs.st_q_data — 2-way 128-bit gated OR (ld/idle write 0 — no data term needed)
data_st_gated[g_i]       = AND_2(WIDTH=128, core_stq_data_i[g_i], store_valid_128[g_i])
data_keep_gated[g_i]     = AND_2(WIDTH=128, reqs_data_q[g_i],     keep_valid_128[g_i])
nextReqs_data[g_i]       = OR_2(WIDTH=128, data_st_gated[g_i], data_keep_gated[g_i])

// (13) Registers — always capturing (REG_RST = WE tied 1), active-low reset
REG_RST(u_reg_oe,   WIDTH=1,   clk_i, rst, nextReqs_oe[g_i],    reqs_oe_q[g_i])
REG_RST(u_reg_we,   WIDTH=1,   clk_i, rst, nextReqs_we[g_i],    reqs_we_q[g_i])
REG_RST(u_reg_pa,   WIDTH=15,  clk_i, rst, nextReqs_paddr[g_i], reqs_paddr_q[g_i])
REG_RST(u_reg_vec,  WIDTH=16,  clk_i, rst, nextReqs_vec[g_i],   reqs_vec_q[g_i])
REG_RST(u_reg_dat,  WIDTH=128, clk_i, rst, nextReqs_data[g_i],  reqs_data_q[g_i])

// (14) Output assigns
assign reqs_oe_o[g_i]    = reqs_oe_q[g_i]
assign reqs_we_o[g_i]    = reqs_we_q[g_i]
assign reqs_paddr_o[g_i] = reqs_paddr_q[g_i]
assign reqs_vec_o[g_i]   = reqs_vec_q[g_i]
assign reqs_data_o[g_i]  = reqs_data_q[g_i]

// (15) writeSuccess_o — store succeeded this cycle
assign writeSuccess_o[g_i] = store_valid[g_i]
```

### st_override generate — `generate for (g_st = 0; g_st < 4; g_st++)` named `g_st_override`

SV semantics: `if (full) override <= 1; else if (empty) override <= 0; // else keep`
Since `full` and `empty` are mutually exclusive:  `d = full | (~empty & current)`

`not_stq_empty[g_st]` is already computed in `g_arb_block` (same index) — reuse it.

```
keep_ov[g_st]        = AND_2(not_stq_empty[g_st], st_override_q[g_st])
st_override_d[g_st]  = OR_2(core_stq_full_i[g_st], keep_ov[g_st])
REG_RST(u_ov_reg, WIDTH=1, clk_i, rst, st_override_d[g_st], st_override_q[g_st])
assign st_override_o[g_st] = st_override_q[g_st]
```

### reqServed outputs — outside generate, after loops

```
reqServed_0_o = OR_4(ld0_valid[0], ld0_valid[1], ld0_valid[2], ld0_valid[3])
reqServed_1_o = OR_4(ld1_valid[0], ld1_valid[1], ld1_valid[2], ld1_valid[3])
```

---

## DCache_TOP.sv Changes

### 1. Add `USE_STRUCTURAL_ARB` flag alongside existing flags

Mirror the same pattern used in `DCache_Block.sv` — a commented-out `` `define `` at the top of the file enables the structural path, matching the existing `USE_STRUCTURAL_EB` / `USE_STRUCTURAL_BANK` / `USE_STRUCTURAL_VCACHE` flags already in the header comment block.

```verilog
// USE_STRUCTURAL_EB     -> structural/EvictionBuf.sv            (parent: DCache_Block.sv)
// USE_STRUCTURAL_BANK   -> structural/DCache_Bank.sv ...        (parent: DCache_Block.sv)
// USE_STRUCTURAL_VCACHE -> structural/VCache.sv ...             (parent: DCache_Block.sv)
// USE_STRUCTURAL_ARB    -> structural/DCache_Arbitration.sv     (parent: DCache_TOP.sv)
//`define USE_STRUCTURAL_ARB
```

### 2. Add flat tap wires (always present, functionally inert unless ARB active)

```verilog
// ── Flat wires for structural DCache_Arbitration ──────────────────────
wire        s_arb_ld0V, s_arb_ld1V;
wire [14:0] s_arb_ld0,  s_arb_ld1;
wire        s_arb_stq_full   [NUM_WB_ST_QS];
wire        s_arb_stq_empty  [NUM_WB_ST_QS];
wire [14:0] s_arb_stq_addr   [NUM_WB_ST_QS];
wire [15:0] s_arb_stq_vec    [NUM_WB_ST_QS];
wire [127:0] s_arb_stq_data  [NUM_WB_ST_QS];
wire        s_arb_clrReq     [DCACHE_NUM_BLOCKS];
wire        s_arb_reqs_oe    [DCACHE_NUM_BLOCKS];
wire        s_arb_reqs_we    [DCACHE_NUM_BLOCKS];
wire [14:0] s_arb_reqs_paddr [DCACHE_NUM_BLOCKS];
wire [15:0] s_arb_reqs_vec   [DCACHE_NUM_BLOCKS];
wire [127:0] s_arb_reqs_data [DCACHE_NUM_BLOCKS];
```

### 3. Struct → flat taps (always present — inert when ARB flag is off)

```verilog
assign s_arb_ld0V = inFromCore_i.ld_addr_0_V;
assign s_arb_ld0  = inFromCore_i.ld_addr_0;
assign s_arb_ld1V = inFromCore_i.ld_addr_1_V;
assign s_arb_ld1  = inFromCore_i.ld_addr_1;

generate
    for (genvar gs = 0; gs < NUM_WB_ST_QS; gs = gs + 1) begin : g_arb_core_taps
        assign s_arb_stq_full[gs]  = inFromCore_i.stq_heads[gs].full;
        assign s_arb_stq_empty[gs] = inFromCore_i.stq_heads[gs].empty;
        assign s_arb_stq_addr[gs]  = inFromCore_i.stq_heads[gs].address;
        assign s_arb_stq_vec[gs]   = inFromCore_i.stq_heads[gs].bit_vec;
        // byte_t[16] → 128-bit flat (MSB = byte[15])
        assign s_arb_stq_data[gs]  = {
            inFromCore_i.stq_heads[gs].data[15],
            inFromCore_i.stq_heads[gs].data[14],
            inFromCore_i.stq_heads[gs].data[13],
            inFromCore_i.stq_heads[gs].data[12],
            inFromCore_i.stq_heads[gs].data[11],
            inFromCore_i.stq_heads[gs].data[10],
            inFromCore_i.stq_heads[gs].data[9],
            inFromCore_i.stq_heads[gs].data[8],
            inFromCore_i.stq_heads[gs].data[7],
            inFromCore_i.stq_heads[gs].data[6],
            inFromCore_i.stq_heads[gs].data[5],
            inFromCore_i.stq_heads[gs].data[4],
            inFromCore_i.stq_heads[gs].data[3],
            inFromCore_i.stq_heads[gs].data[2],
            inFromCore_i.stq_heads[gs].data[1],
            inFromCore_i.stq_heads[gs].data[0]
        };
        assign s_arb_clrReq[gs]    = inFromCore_i.memStage_CLR_REQ[gs];
    end
endgenerate
```

### 4. Flat → struct repacking (inside `ifdef USE_STRUCTURAL_ARB`)

```verilog
`ifdef USE_STRUCTURAL_ARB
generate
    for (genvar gp = 0; gp < DCACHE_NUM_BLOCKS; gp = gp + 1) begin : g_arb_pack_out
        assign req_2_blocks[gp].oe     = s_arb_reqs_oe[gp];
        assign req_2_blocks[gp].we     = s_arb_reqs_we[gp];
        assign req_2_blocks[gp].p_addr = s_arb_reqs_paddr[gp];
        assign req_2_blocks[gp].vec    = s_arb_reqs_vec[gp];
        // unpack 128-bit flat → byte_t[16] array
        for (genvar gb = 0; gb < CACHE_LINES_SIZE_B; gb = gb + 1) begin : g_arb_data_unpack
            assign req_2_blocks[gp].st_q_data[gb] = s_arb_reqs_data[gp][gb*8 +: 8];
        end
    end
endgenerate
`endif
```

### 5. Replace the `DCache_Arbitration` instantiation with `ifdef` switch

```verilog
`ifdef USE_STRUCTURAL_ARB
    DCache_Arbitration dcache_arbitration (
        .clk_i               (clk),
        .rst                 (rst),
        .core_ld_addr_0_V_i  (s_arb_ld0V),
        .core_ld_addr_0_i    (s_arb_ld0),
        .core_ld_addr_1_V_i  (s_arb_ld1V),
        .core_ld_addr_1_i    (s_arb_ld1),
        .core_stq_full_i     (s_arb_stq_full),
        .core_stq_empty_i    (s_arb_stq_empty),
        .core_stq_addr_i     (s_arb_stq_addr),
        .core_stq_bitvec_i   (s_arb_stq_vec),
        .core_stq_data_i     (s_arb_stq_data),
        .core_memClrReq_i    (s_arb_clrReq),
        .block_hit_i         (hitVec),
        .reqServed_0_o       (arb_req_served_0_out),
        .reqServed_1_o       (arb_req_served_1_out),
        .reqs_oe_o           (s_arb_reqs_oe),
        .reqs_we_o           (s_arb_reqs_we),
        .reqs_paddr_o        (s_arb_reqs_paddr),
        .reqs_vec_o          (s_arb_reqs_vec),
        .reqs_data_o         (s_arb_reqs_data),
        .st_override_o       (arb_st_override_Out),
        .writeSuccess_o      (out2Core_o.writeSuccess)
    );
`else
    DCache_Arbitration dcache_arbitration (
        .clk_i          (clk),
        .rst             (rst),
        .core_i          (inFromCore_i),
        .block_hit_i     (hitVec),
        .reqServed_0_o   (arb_req_served_0_out),
        .reqServed_1_o   (arb_req_served_1_out),
        .reqs_2_blocks_o (req_2_blocks),
        .st_override_o   (arb_st_override_Out),
        .writeSuccess_o  (out2Core_o.writeSuccess)
    );
`endif
```

---

## Macros Required

All needed macros already exist in `STDCell_Macros.vh`. No new macros required.

| Macro | Where used |
|---|---|
| `INV_N` | `not_stq_empty`, `no_ld_present`, `not_st_sel`, `not_ld0_at_bank`, `keep_valid` |
| `AND_2` | All 2-input gate logic + wide-bus gating (WIDTH=15, 16, 128) |
| `AND_3` | `ld0_valid`, `readyForNewReq` |
| `AND_4` | `ld1_valid` |
| `OR_2` | Gate logic + wide-bus OR (WIDTH=15, 16, 128) |
| `OR_3` | `readyForNewReq` |
| `OR_4` | `nextReqs_paddr`, `reqServed_0_o`, `reqServed_1_o` |
| `NOR_2` | `block_idleness` |
| `CMP_N` | 2-bit bank number equality compare |
| `REG_RST` | All registers (always-enabled, active-low reset) |

---

## Critical Pitfalls

1. **No combinational loop** — `readyForNewReq` feeds from `reqs_oe_q`/`reqs_we_q` (registered outputs), NOT from `nextReqs_oe`/`nextReqs_we`. Confirm this in the SV: `readyForNewReq[i]` reads `reqs_2_blocks_o[i]` which is assigned from `reqs` (the registered value).

2. **`NUM_WB_ST_QS == DCACHE_NUM_BLOCKS == 4`** — `stq_heads[i]`, `st_override[i]`, and `reqs[i]` all share the same per-block index `i`. The `not_stq_empty` wire declared in `g_arb_block` is reused by `g_st_override` — both generates share the same index space.

3. **`st_q_data` is `byte_t[16]`** — in the flat interface always `[127:0]`. The repack in `DCache_TOP` requires 16 individual byte assigns into `req_2_blocks[gp].st_q_data[b]` for `b = 0..15`: `assign req_2_blocks[gp].st_q_data[b] = s_arb_reqs_data[gp][b*8 +: 8]`.

4. **`ld1_valid` uses `AND_4`** — requires `and4_N$`. Confirmed present via `AND_4` macro in `STDCell_Macros.vh`.

5. **`g_bank_const` inside generate** — `genvar g_i` is a compile-time integer; `assign g_bank_const = g_i[1:0]` is a legal constant assign in Verilog 2005. Do NOT pass `g_i[1:0]` directly as a module port expression — always put it through the `g_bank_const` wire.

6. **`vec` and `st_q_data` are zero for load/idle cases** — `ld0_valid`/`ld1_valid`/`keep=0` paths have no `vec` or `data` gated term feeding the OR. The OR result is correctly zero for those cases, matching SV `vec: 0, st_q_data: '{default: '0}`.

7. **Double-check every signal name** against the SV `always_comb` block before finalising. The previous structural port had a variable name swap — each gate connection must be verified against what the SV actually reads.

8. **`reqs_2_blocks_o = reqs` in SV** → structural output assigns come directly from the `reqs_*_q` flop outputs, not from `nextReqs_*`. Do not accidentally wire `nextReqs_*` to the outputs.
