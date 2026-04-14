`ifndef TB_UTILS_RR_PATH
`define TB_UTILS_RR_PATH


`ifndef RR_UNIT_PATH
    `error "WB_UNIT_PATH not defined"
`endif


// --- RR LATCHES ---
`ifdef RR_UNIT_PATH
`define PRINT_RR_LATCHES \
    task automatic print_rr_latches(); \
        $fdisplay(`LOG_FD, "[RR LATCHES]  useRep=%0b", `RR_UNIT_PATH.rr_latches.useRep); \
        begin \
            automatic rr_latches_general_t L = `RR_UNIT_PATH.rr_latches.useRep ? \
                `RR_UNIT_PATH.rr_latches.rep_latches : `RR_UNIT_PATH.rr_latches.normal_latches; \
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
`ifdef RR_UNIT_PATH
`define PRINT_RR_OUTPUTS \
    task automatic print_rr_outputs(); \
        $fdisplay(`LOG_FD, "[RR OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  stall=%0b ecx_sb=%0b  cs_sb=%0b  dc_we=%0b", \
                  `RR_UNIT_PATH.rr_outputs.valid, `RR_UNIT_PATH.rr_outputs.stall, \
                  `RR_UNIT_PATH.rr_outputs.ecx_sb, `RR_UNIT_PATH.rr_outputs.codeSeg_sb, \
                  `RR_UNIT_PATH.rr_outputs.dc_stage_latch_we); \
    endtask
`endif


// --- REGISTER FILE ---
`ifdef RR_UNIT_PATH
`define PRINT_REGFILE \
    task automatic print_regfile(); \
        $fdisplay(`LOG_FD, "[REGISTER FILE]"); \
        $fwrite(`LOG_FD, "  "); \
        for (int i = 0; i < NUM_REGS; i++) begin \
            $fwrite(`LOG_FD, "%s=0x%08h  ", tb_debug_pkg::get_reg_name(reg_ids_e'(i)), \
                    `RR_UNIT_PATH.rr_unit.RegisterFile_unit.REGISTERS[i][31:0]); \
            if ((i % 6) == 5) begin \
                $fdisplay(`LOG_FD, ""); \
                $fwrite(`LOG_FD, "  "); \
            end \
        end \
        $fdisplay(`LOG_FD, ""); \
    endtask
`endif

// --- SCOREBOARD ---
`ifdef RR_UNIT_PATH
`define PRINT_SCOREBOARD \
    task automatic print_scoreboard(); \
        $fdisplay(`LOG_FD, "[SCOREBOARD]"); \
        $fwrite(`LOG_FD, "  "); \
        for (int i = 0; i < NUM_REGS; i++) begin \
            if (`RR_UNIT_PATH.rr_unit.reg_sb_unit.SCORE_BOARD[i].counter != 0) \
                $fwrite(`LOG_FD, "%s=%0d  ", tb_debug_pkg::get_reg_name(reg_ids_e'(i)), \
                        `RR_UNIT_PATH.rr_unit.reg_sb_unit.SCORE_BOARD[i].counter); \
        end \
        $fdisplay(`LOG_FD, ""); \
        $fdisplay(`LOG_FD, "  dep_stall=%0b  ecx_sb=%0b  cs_sb=%0b", \
                  `RR_UNIT_PATH.rr_unit.reg_sb_unit.dep_stall, \
                  `RR_UNIT_PATH.rr_unit.reg_sb_unit.ecx_sb, \
                  `RR_UNIT_PATH.rr_unit.reg_sb_unit.codeSeg_sb); \
    endtask
`endif




`endif

