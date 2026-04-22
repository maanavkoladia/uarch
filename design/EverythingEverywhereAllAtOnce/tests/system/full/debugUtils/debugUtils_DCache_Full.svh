`ifndef DEBUG_UTILS_DCACHE_FULL_SVH
`define DEBUG_UTILS_DCACHE_FULL_SVH

// ============================================================
// DCache Full-Contents Dump Utility
//
// Writes to a SEPARATE log file (dcache_dump.log) so it does
// not interfere with run.log / compare.py.
//
// Usage (run-time, no recompile):
//   ./SystemTest +DCACHE_DUMP_START=50 +DCACHE_DUMP_END=100
//
// Usage (compile-time via Makefile):
//   make DCACHE_DUMP_START=50 DCACHE_DUMP_END=100
//   make run
//
// Omit both args => no dump output (zero overhead).
// ============================================================

// --- Default fallbacks (overridden by Makefile defines) ----
`ifndef DCACHE_LOG_FILE_NAME
    `define DCACHE_LOG_FILE_NAME "dcache_dump.log"
`endif
`ifndef DCACHE_DUMP_START_DEFAULT
    `define DCACHE_DUMP_START_DEFAULT -1
`endif
`ifndef DCACHE_DUMP_END_DEFAULT
    `define DCACHE_DUMP_END_DEFAULT -1
`endif

// --- Separate file descriptor & cycle-range state ----------
integer dcache_logfd;
int     dcache_dump_start = `DCACHE_DUMP_START_DEFAULT;
int     dcache_dump_end   = `DCACHE_DUMP_END_DEFAULT;

initial begin
    dcache_logfd = $fopen(`DCACHE_LOG_FILE_NAME, "w");
    if (dcache_logfd == 0)
        $display("ERROR: cannot open dcache dump log: %s", `DCACHE_LOG_FILE_NAME);
    if (!$value$plusargs("DCACHE_DUMP_START=%d", dcache_dump_start))
        dcache_dump_start = `DCACHE_DUMP_START_DEFAULT;
    if (!$value$plusargs("DCACHE_DUMP_END=%d", dcache_dump_end))
        dcache_dump_end = `DCACHE_DUMP_END_DEFAULT;
end

// ============================================================
// Hierarchical path macros
// B, W, J must always be LITERAL integers at the call site
// (generate-block indices cannot be variables in SV).
// S (set index) and way-as-mem-address index are variables and
// index into reg arrays — that IS allowed.
// ============================================================

`define DCACHE_TOP_PATH  uut_AllAtOnce.mem_sys_unit.dcache_unit
`define DCACHE_BLK(B)    `DCACHE_TOP_PATH.g_dcache_block[B].block

// DCache bank helpers
`define DC_TAG_META(B, S) \
    `DCACHE_BLK(B).dcache_bank_unit.DCache_Bank_TagStore_unit.tagMetaStore[S]
`define DC_TAG_RAM(B) \
    `DCACHE_BLK(B).dcache_bank_unit.DCache_Bank_TagStore_unit.tag_store_ramCell.mem
`define DC_DATA(B, J) \
    `DCACHE_BLK(B).dcache_bank_unit.DCache_Bank_DataStore_unit.g_dcache_bank_data_store_ram_cells[J].dcache_bank_data_store_ramCell.mem

// VCache helpers
`define VC_TAG_META(B, W) \
    `DCACHE_BLK(B).vcache_unit.vcache_tag_store_unit.tagMetaStore[W]
// Each way has 2 RAM cells (address always 0); cell 0 = tag[7:0], cell 1 bit[0] = tag[8]
`define VC_TAG_LO(B, W) \
    `DCACHE_BLK(B).vcache_unit.vcache_tag_store_unit.g_tagStore_Entry[W].g_tagStoreCell[0].tagStoreCell.mem[0]
`define VC_TAG_HI(B, W) \
    `DCACHE_BLK(B).vcache_unit.vcache_tag_store_unit.g_tagStore_Entry[W].g_tagStoreCell[1].tagStoreCell.mem[0]
// VCache data: byte J, way W is mem[W]
`define VC_DATA(B, J) \
    `DCACHE_BLK(B).vcache_unit.vcache_datastore_unit.g_vcache_data_store_ram_cells[J].v_cache_data_store_ramCell.mem

// Eviction buffer
`define EB(B) `DCACHE_BLK(B).evictionBuf_unit.eb

// ============================================================
// Per-bank task generators
//
// MAKE_DUMP_DCACHE_BLOCK(B) — generates dump_dcache_block_B()
// MAKE_DUMP_VCACHE_BLOCK(B) — generates dump_vcache_block_B()
// MAKE_DUMP_EB_BLOCK(B)     — generates dump_eb_block_B()
// ============================================================

`define MAKE_DUMP_DCACHE_BLOCK(B) \
task automatic dump_dcache_block_``B(); \
    logic [DCACHE_BANK_TAG_WIDTH-1:0] tag; \
    logic vbit, dbit; \
    p_address_t addr; \
    $fdisplay(dcache_logfd, "[Bank %0d  DCache]", B); \
    for (int s = 0; s < DCACHE_BANK_NUM_LINES; s++) begin \
        vbit = `DC_TAG_META(B, s).valid; \
        dbit = `DC_TAG_META(B, s).dirty; \
        tag  = `DC_TAG_RAM(B)[s][DCACHE_BANK_TAG_WIDTH-1:0]; \
        addr = (32'(tag) << DCACHE_BANK_TAG_LB) \
             | (32'(s)   << DCACHE_BANK_INDEX_LB) \
             | (32'(B)   << DCACHE_BANK_BANK_LB); \
        if (vbit) \
            $fdisplay(dcache_logfd, \
                "  Set %0d: V=1 D=%0b  Tag=0x%02h  Addr=0x%08h  %02h %02h %02h %02h %02h %02h %02h %02h | %02h %02h %02h %02h %02h %02h %02h %02h", \
                s, dbit, tag, addr, \
                `DC_DATA(B,  0)[s], `DC_DATA(B,  1)[s], `DC_DATA(B,  2)[s], `DC_DATA(B,  3)[s], \
                `DC_DATA(B,  4)[s], `DC_DATA(B,  5)[s], `DC_DATA(B,  6)[s], `DC_DATA(B,  7)[s], \
                `DC_DATA(B,  8)[s], `DC_DATA(B,  9)[s], `DC_DATA(B, 10)[s], `DC_DATA(B, 11)[s], \
                `DC_DATA(B, 12)[s], `DC_DATA(B, 13)[s], `DC_DATA(B, 14)[s], `DC_DATA(B, 15)[s]); \
        else \
            $fdisplay(dcache_logfd, "  Set %0d: V=0 ---", s); \
    end \
endtask

// Helper: emit one VCache way line — W must be a literal
`define DUMP_VC_WAY(B, W) \
    begin \
        automatic logic [V_CACHE_TAG_WIDTH-1:0] vtag; \
        automatic logic vvc, dvc; \
        automatic p_address_t vaddr; \
        vtag[7:0] = `VC_TAG_LO(B, W); \
        vtag[8]   = `VC_TAG_HI(B, W)[0]; \
        vvc  = `VC_TAG_META(B, W).valid; \
        dvc  = `VC_TAG_META(B, W).dirty; \
        vaddr = (32'(vtag) << V_CACHE_TAG_LB) | (32'(B) << V_CACHE_BANK_LB); \
        if (vvc) \
            $fdisplay(dcache_logfd, \
                "  Way %0d: V=1 D=%0b  Tag=0x%03h  Addr=0x%08h  %02h %02h %02h %02h %02h %02h %02h %02h | %02h %02h %02h %02h %02h %02h %02h %02h", \
                W, dvc, vtag, vaddr, \
                `VC_DATA(B,  0)[W], `VC_DATA(B,  1)[W], `VC_DATA(B,  2)[W], `VC_DATA(B,  3)[W], \
                `VC_DATA(B,  4)[W], `VC_DATA(B,  5)[W], `VC_DATA(B,  6)[W], `VC_DATA(B,  7)[W], \
                `VC_DATA(B,  8)[W], `VC_DATA(B,  9)[W], `VC_DATA(B, 10)[W], `VC_DATA(B, 11)[W], \
                `VC_DATA(B, 12)[W], `VC_DATA(B, 13)[W], `VC_DATA(B, 14)[W], `VC_DATA(B, 15)[W]); \
        else \
            $fdisplay(dcache_logfd, "  Way %0d: V=0 ---", W); \
    end

`define MAKE_DUMP_VCACHE_BLOCK(B) \
task automatic dump_vcache_block_``B(); \
    $fdisplay(dcache_logfd, "[Bank %0d  VCache]", B); \
    `DUMP_VC_WAY(B, 0) \
    `DUMP_VC_WAY(B, 1) \
    `DUMP_VC_WAY(B, 2) \
    `DUMP_VC_WAY(B, 3) \
endtask

`define MAKE_DUMP_EB_BLOCK(B) \
task automatic dump_eb_block_``B(); \
    $fdisplay(dcache_logfd, "[Bank %0d  EvicBuf]", B); \
    if (`EB(B).valid) \
        $fdisplay(dcache_logfd, \
            "  EB: V=1 Commit=%0b  Addr=0x%08h  %02h %02h %02h %02h %02h %02h %02h %02h | %02h %02h %02h %02h %02h %02h %02h %02h", \
            `EB(B).commiting, `EB(B).address, \
            `EB(B).dataLine[0],  `EB(B).dataLine[1],  `EB(B).dataLine[2],  `EB(B).dataLine[3], \
            `EB(B).dataLine[4],  `EB(B).dataLine[5],  `EB(B).dataLine[6],  `EB(B).dataLine[7], \
            `EB(B).dataLine[8],  `EB(B).dataLine[9],  `EB(B).dataLine[10], `EB(B).dataLine[11], \
            `EB(B).dataLine[12], `EB(B).dataLine[13], `EB(B).dataLine[14], `EB(B).dataLine[15]); \
    else \
        $fdisplay(dcache_logfd, "  EB: EMPTY"); \
endtask

// ============================================================
// Generate the 12 tasks (4 banks × 3 types)
// ============================================================

`MAKE_DUMP_DCACHE_BLOCK(0)
`MAKE_DUMP_DCACHE_BLOCK(1)
`MAKE_DUMP_DCACHE_BLOCK(2)
`MAKE_DUMP_DCACHE_BLOCK(3)

`MAKE_DUMP_VCACHE_BLOCK(0)
`MAKE_DUMP_VCACHE_BLOCK(1)
`MAKE_DUMP_VCACHE_BLOCK(2)
`MAKE_DUMP_VCACHE_BLOCK(3)

`MAKE_DUMP_EB_BLOCK(0)
`MAKE_DUMP_EB_BLOCK(1)
`MAKE_DUMP_EB_BLOCK(2)
`MAKE_DUMP_EB_BLOCK(3)

// ============================================================
// Master dump task
// ============================================================

task automatic dump_full_dcache();
    $fdisplay(dcache_logfd, "");
    $fdisplay(dcache_logfd, "===== DCACHE DUMP (cycle %0d, t=%0t) =====", cycle_count, $time);
    dump_dcache_block_0(); dump_vcache_block_0(); dump_eb_block_0();
    dump_dcache_block_1(); dump_vcache_block_1(); dump_eb_block_1();
    dump_dcache_block_2(); dump_vcache_block_2(); dump_eb_block_2();
    dump_dcache_block_3(); dump_vcache_block_3(); dump_eb_block_3();
endtask

// ============================================================
// Cycle-range trigger
//
// clk and cycle_count are declared by DEBUG_UTILS_INIT which
// expands AFTER this file is included, so the always_ff block
// cannot live here at include time.  Instead, expand the macro
// DCACHE_DUMP_INIT in tb_SystemTest.sv after DEBUG_UTILS_INIT.
// ============================================================

`define DCACHE_DUMP_INIT \
    always_ff @(posedge clk) begin \
        if (dcache_dump_start >= 0 && \
            cycle_count >= dcache_dump_start && \
            (dcache_dump_end < 0 || cycle_count <= dcache_dump_end)) \
            dump_full_dcache(); \
    end

`endif // DEBUG_UTILS_DCACHE_FULL_SVH
