// ===========================================================================
// tb_debug_tasks.svh - Reusable Debug Task Macros for Stage Testbenches
// ===========================================================================
// This file provides debug printing task macros that can work across different
// testbenches with different DUT instance names.
//
// USAGE:
// Before including this file, define the DUT instance names and log file descriptor:
//
//   `define CORE_DUT_PATH  uut_core
//   `define DCACHE_DUT_PATH uut_dcache
//   `define ICACHE_DUT_PATH uut_icache
//   `define LOG_FD log_fd            // File descriptor for logging
//   `define CYCLE_COUNT cycle_count  // Cycle counter variable
//
//   `include "tb_debug_tasks.svh"
//
// Then instantiate the task macros (note: NO parentheses):
//   `PRINT_FETCH
//   `PRINT_IDM
//   `PRINT_ALL_STAGES
//
// If a DUT is not present in your testbench, you can skip defining that macro.
// Tasks that need that macro will not be callable.
// ===========================================================================

// ===================== PRINT TASKS =====================

// --- HEADER ---
`define PRINT_CYCLE_HEADER \
    task automatic print_cycle_header(); \
        $fdisplay(`LOG_FD, ""); \
        $fdisplay(`LOG_FD, "==================== CYCLE %0d  (t=%0t) ====================", `CYCLE_COUNT, $time); \
    endtask

// --- FETCH ---
`ifdef CORE_DUT_PATH
`define PRINT_FETCH \
    task automatic print_fetch(); \
        $fdisplay(`LOG_FD, "[FETCH]"); \
        $fdisplay(`LOG_FD, "  SPC       = 0x%08h   next_spc = 0x%08h   spc+16 = 0x%08h", \
                  `CORE_DUT_PATH.fetch_unit.SPC, `CORE_DUT_PATH.fetch_unit.next_spc, \
                  `CORE_DUT_PATH.fetch_unit.spc_16); \
        $fdisplay(`LOG_FD, "  spc_sel   = %s   br_tgt_sel=%0b   flush_reg=%0b", \
                  tb_debug_pkg::get_spc_sel_name(`CORE_DUT_PATH.fetch_unit.spc_sel_logic_outs.sel), \
                  `CORE_DUT_PATH.fetch_unit.spc_sel_logic_outs.br_target_sel, \
                  `CORE_DUT_PATH.fetch_unit.spc_sel_logic_outs.flush_reg); \
        $fdisplay(`LOG_FD, "  exp_mode  = %0b   int_mode=%0b   DMA_int=%0b   en_icache=%0b", \
                  `CORE_DUT_PATH.fetch_unit.exp_mode_jk, `CORE_DUT_PATH.fetch_unit.int_mode_jk, \
                  `CORE_DUT_PATH.fetch_unit.DMA_int_jk, `CORE_DUT_PATH.fetch_unit.en_icache); \
        $fdisplay(`LOG_FD, "  TLB: v_addr=0x%08h  p_addr=0x%08h  valid=%0b  gp=%0b  pf=%0b  f_exp=%0b", \
                  `CORE_DUT_PATH.fetch_unit.seg_xlation_out, `CORE_DUT_PATH.fetch_unit.tlb_outs.physical_addr, \
                  `CORE_DUT_PATH.fetch_unit.tlb_outs.physical_addr_valid, `CORE_DUT_PATH.fetch_unit.tlb_outs.gp_exp, \
                  `CORE_DUT_PATH.fetch_unit.tlb_outs.pageFault, `CORE_DUT_PATH.fetch_unit.f_exp); \
        $fdisplay(`LOG_FD, "  BTB: hit=%0b  eip=0x%08h  tgt=0x%08h  XCL=%0b  ucond=%0b", \
                  `CORE_DUT_PATH.fetch_unit.btb_outs.hit, `CORE_DUT_PATH.fetch_unit.btb_outs.br_eip, \
                  `CORE_DUT_PATH.fetch_unit.btb_outs.br_target, `CORE_DUT_PATH.fetch_unit.btb_outs.XCL, \
                  `CORE_DUT_PATH.fetch_unit.btb_outs.br_ucond); \
        $fdisplay(`LOG_FD, "  Predictor: taken=%0b", `CORE_DUT_PATH.fetch_unit.predictor_outs.taken); \
        $fdisplay(`LOG_FD, "  ICache: hit=%0b  icache_en=%0b", icache_2_core.hit, \
                  `CORE_DUT_PATH.fetch_outputs.fetch_2_icache.icache_en); \
    endtask
`endif

// --- IDM ---
`ifdef CORE_DUT_PATH
`define PRINT_IDM \
    task automatic print_idm(); \
        $fdisplay(`LOG_FD, "[IDM]  valid_slots=%0d", `CORE_DUT_PATH.idm_outputs.valid_slots); \
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin \
            if (`CORE_DUT_PATH.idm_outputs.idm_slots[i].valid) begin \
                $fwrite(`LOG_FD, "  slot[%0d] V=1  br_v=%0b  br_xcl=%0b", i, \
                        `CORE_DUT_PATH.idm_outputs.idm_slots[i].br_valid, \
                        `CORE_DUT_PATH.idm_outputs.idm_slots[i].br_xcl); \
                if (`CORE_DUT_PATH.idm_outputs.idm_slots[i].br_valid) \
                    $fwrite(`LOG_FD, "  br_eip=0x%08h  br_tgt=0x%08h", \
                            `CORE_DUT_PATH.idm_outputs.idm_slots[i].br_eip, \
                            `CORE_DUT_PATH.idm_outputs.idm_slots[i].br_btb_target); \
                $fdisplay(`LOG_FD, ""); \
            end else begin \
                $fdisplay(`LOG_FD, "  slot[%0d] V=0", i); \
            end \
        end \
        $fdisplay(`LOG_FD, "  IDM Ctrl: push_success=%0b", \
                  `CORE_DUT_PATH.fetch_unit.idm_ctrl_logic_outs.push_success); \
        $fwrite(`LOG_FD, "  Invalidate:"); \
        for (int i = 0; i < NUM_IDM_SLOTS; i++) \
            $fwrite(`LOG_FD, " [%0d]=%0b", i, `CORE_DUT_PATH.fetch_unit.idm_invalidate_logic_outs.invalidate[i]); \
        $fdisplay(`LOG_FD, "  no_writes=%0b", \
                  `CORE_DUT_PATH.fetch_unit.idm_invalidate_logic_outs.no_writes); \
    endtask
`endif

// --- DECODE ---
`ifdef CORE_DUT_PATH
`define PRINT_DECODE \
    task automatic print_decode(); \
        $fdisplay(`LOG_FD, "[DECODE]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  eip=0x%08h  invalid_instr=%0b  decode_gp=%0b  rr_latch_we=%0b", \
                  `CORE_DUT_PATH.decode_outputs.valid, `CORE_DUT_PATH.decode_outputs.eip, \
                  `CORE_DUT_PATH.decode_outputs.invalid_instruction, `CORE_DUT_PATH.decode_outputs.decode_gp, \
                  `CORE_DUT_PATH.decode_outputs.rr_stage_latch_we); \
    endtask
`endif

// --- RR LATCHES ---
`ifdef CORE_DUT_PATH
`define PRINT_RR_LATCHES \
    task automatic print_rr_latches(); \
        $fdisplay(`LOG_FD, "[RR LATCHES]  useRep=%0b", `CORE_DUT_PATH.rr_latches.useRep); \
        begin \
            automatic rr_latches_general_t L = `CORE_DUT_PATH.rr_latches.useRep ? \
                `CORE_DUT_PATH.rr_latches.rep_latches : `CORE_DUT_PATH.rr_latches.normal_latches; \
            $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h", L.valid, L.EIP, L.NEIP); \
            $fdisplay(`LOG_FD, "  dr=%s  sr=%s  dr_rd=%0b  sr_rd=%0b  dr_wr=%0b  sr_wr=%0b  datasize=%0d", \
                      tb_debug_pkg::get_reg_name(L.cs.dr_id), tb_debug_pkg::get_reg_name(L.cs.sr_id), \
                      L.cs.dr_rd, L.cs.sr_rd, L.cs.dr_wr, L.cs.sr_wr, L.cs.datasize); \
            $fdisplay(`LOG_FD, "  LD_OP=%0b  ST_OP=%0b  MODRM=%0b  RM_IS_DR=%0b", \
                      L.cs.LD_OP, L.cs.ST_OP, L.cs.MODRM_NEEDED, L.cs.RM_IS_DR); \
            $fdisplay(`LOG_FD, "  EXE_CS: OP=%s  br_ucond=%0b  rel_br=%0b  special=%0b  far=%0b", \
                      tb_debug_pkg::get_op_name(L.exe_cs.OP_TYPE), L.exe_cs.br_ucond, \
                      L.exe_cs.relative_branch, L.exe_cs.special_br, L.exe_cs.is_far); \
            $fdisplay(`LOG_FD, "  br_info: v=%0b  eip=0x%08h  xcl=%0b  pred_taken=%0b  spec_tgt=0x%08h", \
                      L.br_info.valid, L.br_info.br_eip, L.br_info.br_xcl, \
                      L.br_info.br_pred_taken, L.br_info.speculative_target); \
            if (L.sib_needed) \
                $fdisplay(`LOG_FD, "  SIB: idx=%s  base=%s  scale=%0d", \
                          tb_debug_pkg::get_reg_name(L.sib_idx_id), \
                          tb_debug_pkg::get_reg_name(L.sib_base_id), L.sib_scale); \
            if (L.disp_needed) \
                $fdisplay(`LOG_FD, "  DISP: size=%s  val=0x%08h", \
                          L.disp_size ? "32" : "8", L.displacement); \
            $fdisplay(`LOG_FD, "  WB_CS: ST_OP=%0b  WB_DR=%0b  WB_SR=%0b", \
                      L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR); \
        end \
    endtask
`endif

// --- RR OUTPUTS ---
`ifdef CORE_DUT_PATH
`define PRINT_RR_OUTPUTS \
    task automatic print_rr_outputs(); \
        $fdisplay(`LOG_FD, "[RR OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  stall=%0b ecx_sb=%0b  cs_sb=%0b  dc_we=%0b", \
                  `CORE_DUT_PATH.rr_outputs.valid, `CORE_DUT_PATH.rr_outputs.stall, \
                  `CORE_DUT_PATH.rr_outputs.ecx_sb, `CORE_DUT_PATH.rr_outputs.codeSeg_sb, \
                  `CORE_DUT_PATH.rr_outputs.dc_stage_latch_we); \
    endtask
`endif

// --- DC LATCHES ---
`ifdef CORE_DUT_PATH
`define PRINT_DC_LATCHES \
    task automatic print_dc_latches(); \
        $fdisplay(`LOG_FD, "[DC LATCHES]"); \
        begin \
            automatic dc_latches_t L = `CORE_DUT_PATH.dc_latches; \
            $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h", L.valid, L.EIP, L.NEIP); \
            $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)", \
                      tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data, \
                      tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data); \
            $fdisplay(`LOG_FD, "  CS: LD=%0b  ST=%0b  upper8=%0b  dsize=%0d", \
                      L.cs.LD_OP, L.cs.ST_OP, L.cs.upper8, L.cs.datasize); \
            $fdisplay(`LOG_FD, "  LD: vaddr=0x%08h  next_vaddr=0x%08h  limit=0x%08h", \
                      L.ld_vaddy, L.next_ld_vaddy, L.seg0_limit_w_datasize); \
            $fdisplay(`LOG_FD, "  ST: vaddr=0x%08h  next_vaddr=0x%08h  limit=0x%08h", \
                      L.st_vaddy, L.next_st_vaddy, L.seg1_limit_w_datasize); \
            $fdisplay(`LOG_FD, "  br_info: v=%0b  eip=0x%08h  pred_taken=%0b", \
                      L.br_info.valid, L.br_info.br_eip, L.br_info.br_pred_taken); \
            $fdisplay(`LOG_FD, "  EXE_CS: OP=%s  WB_CS: ST=%0b DR=%0b SR=%0b", \
                      tb_debug_pkg::get_op_name(L.exe_cs.OP_TYPE), \
                      L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR); \
            $fdisplay(`LOG_FD, "  imm64=0x%016h", L.imm64); \
            $fdisplay(`LOG_FD, "  rr_gp=%0b", L.rr_gp); \
        end \
    endtask
`endif

// --- DC OUTPUTS ---
`ifdef CORE_DUT_PATH
`define PRINT_DC_OUTPUTS \
    task automatic print_dc_outputs(); \
        $fdisplay(`LOG_FD, "[DC OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  stall=%0b  mem_we=%0b", \
                  `CORE_DUT_PATH.dc_outputs.valid, `CORE_DUT_PATH.dc_outputs.stall, \
                  `CORE_DUT_PATH.dc_outputs.exp_present, `CORE_DUT_PATH.dc_outputs.exp_pf, \
                  `CORE_DUT_PATH.dc_outputs.mem_stage_latch_we); \
        $fdisplay(`LOG_FD, "  ld0: V=%0b addr=0x%04h   ld1: V=%0b addr=0x%04h   mio: V=%0b addr=0x%04h", \
                  `CORE_DUT_PATH.dc_outputs.ld_addr_0_V, `CORE_DUT_PATH.dc_outputs.ld_addr_0, \
                  `CORE_DUT_PATH.dc_outputs.ld_addr_1_V, `CORE_DUT_PATH.dc_outputs.ld_addr_1, \
                  `CORE_DUT_PATH.dc_outputs.ld_addr_MIO_V, `CORE_DUT_PATH.dc_outputs.ld_addr_MIO); \
    endtask
`endif

// --- MEM LATCHES ---
`ifdef CORE_DUT_PATH
`define PRINT_MEM_LATCHES \
    task automatic print_mem_latches(); \
        $fdisplay(`LOG_FD, "[MEM LATCHES]"); \
        begin \
            automatic mem_latches_t L = `CORE_DUT_PATH.mem_latches; \
            $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h", L.valid, L.EIP, L.NEIP); \
            $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)", \
                      tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data, \
                      tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data); \
            $fdisplay(`LOG_FD, "  CS: LD=%0b  ST=%0b   data_size_vec=0x%01h", \
                      L.cs.LD_OP, L.cs.ST_OP, L.data_size_vec); \
            $fdisplay(`LOG_FD, "  LD: xcl=%0b  paddr0=0x%04h  paddr1=0x%04h  swap=%0b", \
                      L.LD_XCL, L.LD_PADDR_0, L.LD_PADDR_1, L.swapLines); \
            $fdisplay(`LOG_FD, "  ST: xcl=%0b  paddr0=0x%04h  paddr1=0x%04h  MIO=%0b", \
                      L.ST_XCL, L.ST_PADDR_0, L.ST_PADDR_1, L.MIO); \
            $fdisplay(`LOG_FD, "  EXE_CS: OP=%s  WB_CS: ST=%0b DR=%0b SR=%0b", \
                      tb_debug_pkg::get_op_name(L.exe_cs.OP_TYPE), \
                      L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR); \
            $fdisplay(`LOG_FD, "  br_info: v=%0b  eip=0x%08h  pred_taken=%0b", \
                      L.br_info.valid, L.br_info.br_eip, L.br_info.br_pred_taken); \
        end \
    endtask
`endif

// --- MEM OUTPUTS ---
`ifdef CORE_DUT_PATH
`define PRINT_MEM_OUTPUTS \
    task automatic print_mem_outputs(); \
        $fdisplay(`LOG_FD, "[MEM OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  stall=%0b  exe_we=%0b  ST_OP=%0b  ST_XCL=%0b", \
                  `CORE_DUT_PATH.mem_outputs.valid, `CORE_DUT_PATH.mem_outputs.stall, \
                  `CORE_DUT_PATH.mem_outputs.exe_stage_latch_we, `CORE_DUT_PATH.mem_outputs.ST_OP, \
                  `CORE_DUT_PATH.mem_outputs.ST_XCL); \
        $fdisplay(`LOG_FD, "  ST_PADDR_0=0x%04h  ST_PADDR_1=0x%04h", \
                  `CORE_DUT_PATH.mem_outputs.ST_PADDR_0, `CORE_DUT_PATH.mem_outputs.ST_PADDR_1); \
        $fdisplay(`LOG_FD, "  DCache: hit0=%0b  hit1=%0b  hit2=%0b  hit3=%0b  hitMIO=%0b", \
                  dcache_2_core.hit[0], dcache_2_core.hit[1], dcache_2_core.hit[2], \
                  dcache_2_core.hit[3], dcache_2_core.hit_MIO); \
    endtask
`endif

// --- EXE LATCHES ---
`ifdef CORE_DUT_PATH
`define PRINT_EXE_LATCHES \
    task automatic print_exe_latches(); \
        $fdisplay(`LOG_FD, "[EXE LATCHES]"); \
        begin \
            automatic exe_latches_t L = `CORE_DUT_PATH.exe_latches; \
            $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h", L.valid, L.EIP, L.NEIP); \
            $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)", \
                      tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data, \
                      tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data); \
            $fdisplay(`LOG_FD, "  CS: OP=%s  ST=%0b   data_size_vec=0x%01h", \
                      tb_debug_pkg::get_op_name(L.cs.OP_TYPE), L.cs.ST_OP, L.data_size_vec); \
            $fdisplay(`LOG_FD, "  inputA_sel=%0d  inputB_sel=%0d  br_tgt_sel=%0d", \
                      L.cs.alu_inputA_sel, L.cs.alu_inputB_sel, L.cs.branch_target_sel); \
            $fdisplay(`LOG_FD, "  br_info: v=%0b  eip=0x%08h  xcl=%0b  pred_taken=%0b  spec_tgt=0x%08h", \
                      L.br_info.valid, L.br_info.br_eip, L.br_info.br_xcl, \
                      L.br_info.br_pred_taken, L.br_info.speculative_target); \
            $fdisplay(`LOG_FD, "  ST: xcl=%0b  paddr0=0x%04h  paddr1=0x%04h  MIO=%0b", \
                      L.ST_XCL, L.ST_PADDR_0, L.ST_PADDR_1, L.MIO); \
            $fdisplay(`LOG_FD, "  imm64=0x%016h  ld_addy=0x%04h", L.imm64, L.ld_addy); \
            $fdisplay(`LOG_FD, "  WB_CS: ST=%0b DR=%0b SR=%0b", \
                      L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR); \
            $fwrite(`LOG_FD, "LD_BUF: "); \
            for (int i = 0; i < 16; i++) begin \
                $fwrite(`LOG_FD, "%02x", L.ld_buf[i]); \
                if (i != 15) $fwrite(`LOG_FD, "_"); \
            end \
            $fwrite(`LOG_FD, "\n"); \
            $fwrite(`LOG_FD, "         "); \
            for (int i = 16; i < 32; i++) begin \
                $fwrite(`LOG_FD, "%02x", L.ld_buf[i]); \
                if (i != 31) $fwrite(`LOG_FD, "_"); \
            end \
            $fdisplay(`LOG_FD, ""); \
        end \
    endtask
`endif

// --- EXE OUTPUTS ---
`ifdef CORE_DUT_PATH
`define PRINT_EXE_OUTPUTS \
    task automatic print_exe_outputs(); \
        $fdisplay(`LOG_FD, "[EXE OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  wb_we=%0b  ST_OP=%0b  ST_XCL=%0b  clr_ZF_sb=%0b  ZF=%0b", \
                  `CORE_DUT_PATH.exe_outputs.valid, `CORE_DUT_PATH.exe_outputs.wb_stage_latch_we, \
                  `CORE_DUT_PATH.exe_outputs.ST_OP, `CORE_DUT_PATH.exe_outputs.ST_XCL, \
                  `CORE_DUT_PATH.exe_outputs.clr_ZF_sb, `CORE_DUT_PATH.exe_outputs.ZF); \
        begin \
            automatic exe_br_resolution_outputs_t B = `CORE_DUT_PATH.exe_outputs.br_res_out; \
            $fdisplay(`LOG_FD, "  BR_RES: valid=%0b  flush=%0b  farFlush=%0b  mispredict=%0b  taken=%0b", \
                      B.valid, B.flush, B.farFlush, B.miss_prediction, B.taken); \
            if (B.valid) \
                $fdisplay(`LOG_FD, "    eip=0x%08h  neip=0x%08h  tgt=0x%08h  xcl=%0b  ucond=%0b  clr_exp=%0b", \
                          B.br_eip, B.neip, B.br_target, B.br_XCL, B.br_ucond, B.clr_exp_mode); \
        end \
    endtask
`endif

// --- WB LATCHES ---
`ifdef CORE_DUT_PATH
`define PRINT_WB_LATCHES \
    task automatic print_wb_latches(); \
        $fdisplay(`LOG_FD, "[WB LATCHES]"); \
        begin \
            automatic wb_latches_t L = `CORE_DUT_PATH.wb_latches; \
            $fdisplay(`LOG_FD, "  valid=%0b  CS: ST=%0b  WB_DR=%0b  WB_SR=%0b", \
                      L.valid, L.cs.ST_OP, L.cs.WB_DR, L.cs.WB_SR); \
            $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)", \
                      tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data, \
                      tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data); \
            $fdisplay(`LOG_FD, "  ST: xcl=%0b  paddr0=0x%04h  bv0=0x%04h  paddr1=0x%04h  bv1=0x%04h  MIO=%0b", \
                      L.ST_XCL, L.ST_PADDR_0, L.ST_BIT_VEC_0, L.ST_PADDR_1, L.ST_BIT_VEC_1, L.MIO); \
            $fwrite(`LOG_FD, "RES_BUF: "); \
            for (int i = 0; i < 16; i++) begin \
                $fwrite(`LOG_FD, "%02x", L.res_buf[i]); \
                if (i != 15) $fwrite(`LOG_FD, "_"); \
            end \
            $fwrite(`LOG_FD, "\n"); \
            $fwrite(`LOG_FD, "         "); \
            for (int i = 16; i < 32; i++) begin \
                $fwrite(`LOG_FD, "%02x", L.res_buf[i]); \
                if (i != 31) $fwrite(`LOG_FD, "_"); \
            end \
            $fdisplay(`LOG_FD, ""); \
        end \
    endtask
`endif

// --- WB OUTPUTS ---
`ifdef CORE_DUT_PATH
`define PRINT_WB_OUTPUTS \
    task automatic print_wb_outputs(); \
        $fdisplay(`LOG_FD, "[WB OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  wb_stall=%0b", \
                  `CORE_DUT_PATH.wb_outputs.valid, `CORE_DUT_PATH.wb_outputs.wb_stall); \
        $fdisplay(`LOG_FD, "  DR0: we=%0b  id=%s  data=0x%016h", \
                  `CORE_DUT_PATH.wb_outputs.DR_0_we, \
                  tb_debug_pkg::get_reg_name(`CORE_DUT_PATH.wb_outputs.DR_0_id), \
                  `CORE_DUT_PATH.wb_outputs.DR_0_data); \
        $fdisplay(`LOG_FD, "  DR1: we=%0b  id=%s  data=0x%016h", \
                  `CORE_DUT_PATH.wb_outputs.DR_1_we, \
                  tb_debug_pkg::get_reg_name(`CORE_DUT_PATH.wb_outputs.DR_1_id), \
                  `CORE_DUT_PATH.wb_outputs.DR_1_data); \
    endtask
`endif

// --- STALLS & FLUSHES ---
`ifdef CORE_DUT_PATH
`define PRINT_STALLS \
    task automatic print_stalls(); \
        $fdisplay(`LOG_FD, "[STALLS & FLUSHES]"); \
        $fdisplay(`LOG_FD, "  RR_stall=%0b  DC_stall=%0b  MEM_stall=%0b  WB_stall=%0b", \
                  `CORE_DUT_PATH.rr_outputs.stall, `CORE_DUT_PATH.dc_outputs.stall, \
                  `CORE_DUT_PATH.mem_outputs.stall, `CORE_DUT_PATH.wb_outputs.wb_stall); \
        $fdisplay(`LOG_FD, "  flush=%0b  farFlush=%0b  exp_pipe_clear=%0b  int_pipe_clear=%0b", \
                  `CORE_DUT_PATH.exe_outputs.br_res_out.flush, \
                  `CORE_DUT_PATH.exe_outputs.br_res_out.farFlush, \
                  `CORE_DUT_PATH.fetch_unit.exp_set_logic_outs.exp_pipe_clear, \
                  `CORE_DUT_PATH.fetch_unit.exp_set_logic_outs.int_pipe_clear); \
        $fdisplay(`LOG_FD, "  RR_exp=%0b  RR_exp_pf=%0b  decode_invalid=%0b  decode_gp=%0b", \
                  `CORE_DUT_PATH.dc_outputs.exp_present, `CORE_DUT_PATH.dc_outputs.exp_pf, \
                  `CORE_DUT_PATH.decode_outputs.invalid_instruction, \
                  `CORE_DUT_PATH.decode_outputs.decode_gp); \
    endtask
`endif

// --- REGISTER FILE ---
`ifdef CORE_DUT_PATH
`define PRINT_REGFILE \
    task automatic print_regfile(); \
        $fdisplay(`LOG_FD, "[REGISTER FILE]"); \
        $fwrite(`LOG_FD, "  "); \
        for (int i = 0; i < NUM_REGS; i++) begin \
            $fwrite(`LOG_FD, "%s=0x%08h  ", tb_debug_pkg::get_reg_name(reg_ids_e'(i)), \
                    `CORE_DUT_PATH.rr_unit.RegisterFile_unit.REGISTERS[i][31:0]); \
            if ((i % 6) == 5) begin \
                $fdisplay(`LOG_FD, ""); \
                $fwrite(`LOG_FD, "  "); \
            end \
        end \
        $fdisplay(`LOG_FD, ""); \
    endtask
`endif

// --- SCOREBOARD ---
`ifdef CORE_DUT_PATH
`define PRINT_SCOREBOARD \
    task automatic print_scoreboard(); \
        $fdisplay(`LOG_FD, "[SCOREBOARD]"); \
        $fwrite(`LOG_FD, "  "); \
        for (int i = 0; i < NUM_REGS; i++) begin \
            if (`CORE_DUT_PATH.rr_unit.reg_sb_unit.SCORE_BOARD[i].counter != 0) \
                $fwrite(`LOG_FD, "%s=%0d  ", tb_debug_pkg::get_reg_name(reg_ids_e'(i)), \
                        `CORE_DUT_PATH.rr_unit.reg_sb_unit.SCORE_BOARD[i].counter); \
        end \
        $fdisplay(`LOG_FD, ""); \
        $fdisplay(`LOG_FD, "  dep_stall=%0b  ecx_sb=%0b  cs_sb=%0b", \
                  `CORE_DUT_PATH.rr_unit.reg_sb_unit.dep_stall, \
                  `CORE_DUT_PATH.rr_unit.reg_sb_unit.ecx_sb, \
                  `CORE_DUT_PATH.rr_unit.reg_sb_unit.codeSeg_sb); \
    endtask
`endif

// --- STORE QUEUES ---
`ifdef CORE_DUT_PATH
`define PRINT_ONE_STQ \
    task automatic print_one_stq(int idx, st_q_outputs_t outs); \
        $fdisplay(`LOG_FD, "  STQ[%0d]: full=%0b  empty=%0b  push_fail=%0b", \
                  idx, outs.full, outs.empty, outs.push_fail); \
        if (!outs.empty) begin \
            $fdisplay(`LOG_FD, "    HEAD: addr=0x%04h  bv=0x%04h", \
                      outs.head_address, outs.bit_vec); \
        end \
        for (int e = 0; e < ST_Q_DEPTH; e++) begin \
            if (outs.valid[e]) \
                $fdisplay(`LOG_FD, "    [%0d] V=1 addr=0x%04h", e, outs.address[e]); \
        end \
    endtask

`define PRINT_STORE_QUEUES \
    task automatic print_store_queues(); \
        $fdisplay(`LOG_FD, "[STORE QUEUES]"); \
        print_one_stq(0, `CORE_DUT_PATH.write_back_unit.stq_outputs[0]); \
        print_one_stq(1, `CORE_DUT_PATH.write_back_unit.stq_outputs[1]); \
        print_one_stq(2, `CORE_DUT_PATH.write_back_unit.stq_outputs[2]); \
        print_one_stq(3, `CORE_DUT_PATH.write_back_unit.stq_outputs[3]); \
    endtask
`endif

// --- MIO QUEUE ---
`ifdef CORE_DUT_PATH
`define PRINT_MIO_QUEUE \
    task automatic print_mio_queue(); \
        $fdisplay(`LOG_FD, "[MIO QUEUE]"); \
        $fdisplay(`LOG_FD, "  full=%0b  empty=%0b", \
                  `CORE_DUT_PATH.write_back_unit.mio_q_inst.full, \
                  `CORE_DUT_PATH.write_back_unit.mio_q_inst.empty); \
        if (!`CORE_DUT_PATH.write_back_unit.mio_q_inst.empty) begin \
            $fdisplay(`LOG_FD, "  entry: v=%0b  addr=0x%04h  data[0:3]=%02h %02h %02h %02h", \
                      `CORE_DUT_PATH.write_back_unit.mio_q_inst.mio_q.valid, \
                      `CORE_DUT_PATH.write_back_unit.mio_q_inst.mio_q.address, \
                      `CORE_DUT_PATH.write_back_unit.mio_q_inst.mio_q.data[0], \
                      `CORE_DUT_PATH.write_back_unit.mio_q_inst.mio_q.data[1], \
                      `CORE_DUT_PATH.write_back_unit.mio_q_inst.mio_q.data[2], \
                      `CORE_DUT_PATH.write_back_unit.mio_q_inst.mio_q.data[3]); \
        end \
    endtask
`endif

// --- DCACHE ARBITRATION ---
`ifdef CORE_DUT_PATH
`ifdef DCACHE_DUT_PATH
`define PRINT_DCACHE_ARB \
    task automatic print_dcache_arb(); \
        $fdisplay(`LOG_FD, "[DCACHE ARB]"); \
        $fdisplay(`LOG_FD, "  req_served_0=%0b  req_served_1=%0b  req_served_mio=%0b", \
                  dcache_2_core.reqServed_0, dcache_2_core.reqServed_1, \
                  dcache_2_core.reqServed_MIO); \
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin \
            $fdisplay(`LOG_FD, "  blk[%0d]: oe=%0b  we=%0b  addr=0x%04h  hit=%0b  ws=%0b  sch_req=%0d", i, \
                      `DCACHE_DUT_PATH.req_2_blocks[i].oe, `DCACHE_DUT_PATH.req_2_blocks[i].we, \
                      `DCACHE_DUT_PATH.req_2_blocks[i].p_addr, `DCACHE_DUT_PATH.hitVec[i], \
                      dcache_2_core.writeSuccess[i], `DCACHE_DUT_PATH.out2Sch_o.req[i]); \
        end \
    endtask
`endif
`endif

// ===================== MASTER PRINT =====================
`ifdef CORE_DUT_PATH
`define PRINT_ALL_STAGES \
    task automatic print_all(); \
        #1; \
        print_cycle_header(); \
        print_fetch(); \
        print_idm(); \
        print_decode(); \
        print_rr_latches(); \
        print_rr_outputs(); \
        print_dc_latches(); \
        print_dc_outputs(); \
        print_mem_latches(); \
        print_mem_outputs(); \
        print_exe_latches(); \
        print_exe_outputs(); \
        print_wb_latches(); \
        print_wb_outputs(); \
        $fdisplay(`LOG_FD, ""); \
        print_stalls(); \
        print_regfile(); \
        print_scoreboard(); \
        $fdisplay(`LOG_FD, ""); \
        print_store_queues(); \
        print_mio_queue(); \
    endtask
`endif
