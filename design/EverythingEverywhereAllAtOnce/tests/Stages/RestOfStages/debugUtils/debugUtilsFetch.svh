`ifndef TB_UTILS_FETCH_PATH
`define TB_UTILS_FETCH_PATH


//`ifndef FETCH_UNIT_PATH
//    `error "WB_UNIT_PATH not defined"
//`endif

// --- FETCH ---
`ifdef FETCH_UNIT_PATH
`define PRINT_FETCH \
    task automatic print_fetch(); \
        $fdisplay(`LOG_FD, "[FETCH]"); \
        $fdisplay(`LOG_FD, "  SPC       = 0x%08h   next_spc = 0x%08h   spc+16 = 0x%08h", \
                  `FETCH_UNIT_PATH.fetch_unit.SPC, `FETCH_UNIT_PATH.fetch_unit.next_spc, \
                  `FETCH_UNIT_PATH.fetch_unit.spc_16); \
        $fdisplay(`LOG_FD, "  spc_sel   = %s   br_tgt_sel=%0b   flush_reg=%0b", \
                  tb_debug_pkg::get_spc_sel_name(`FETCH_UNIT_PATH.fetch_unit.spc_sel_logic_outs.sel), \
                  `FETCH_UNIT_PATH.fetch_unit.spc_sel_logic_outs.br_target_sel, \
                  `FETCH_UNIT_PATH.fetch_unit.spc_sel_logic_outs.flush_reg); \
        $fdisplay(`LOG_FD, "  exp_mode  = %0b   int_mode=%0b   DMA_int=%0b   en_icache=%0b", \
                  `FETCH_UNIT_PATH.fetch_unit.exp_mode_jk, `FETCH_UNIT_PATH.fetch_unit.int_mode_jk, \
                  `FETCH_UNIT_PATH.fetch_unit.DMA_int_jk, `FETCH_UNIT_PATH.fetch_unit.en_icache); \
        $fdisplay(`LOG_FD, "  TLB: v_addr=0x%08h  p_addr=0x%08h  valid=%0b  gp=%0b  pf=%0b  f_exp=%0b", \
                  `FETCH_UNIT_PATH.fetch_unit.seg_xlation_out, `FETCH_UNIT_PATH.fetch_unit.tlb_outs.physical_addr, \
                  `FETCH_UNIT_PATH.fetch_unit.tlb_outs.physical_addr_valid, `FETCH_UNIT_PATH.fetch_unit.tlb_outs.gp_exp, \
                  `FETCH_UNIT_PATH.fetch_unit.tlb_outs.pageFault, `FETCH_UNIT_PATH.fetch_unit.f_exp); \
        $fdisplay(`LOG_FD, "  BTB: hit=%0b  eip=0x%08h  tgt=0x%08h  XCL=%0b  ucond=%0b", \
                  `FETCH_UNIT_PATH.fetch_unit.btb_outs.hit, `FETCH_UNIT_PATH.fetch_unit.btb_outs.br_eip, \
                  `FETCH_UNIT_PATH.fetch_unit.btb_outs.br_target, `FETCH_UNIT_PATH.fetch_unit.btb_outs.XCL, \
                  `FETCH_UNIT_PATH.fetch_unit.btb_outs.br_ucond); \
        $fdisplay(`LOG_FD, "  Predictor: taken=%0b", `FETCH_UNIT_PATH.fetch_unit.predictor_outs.taken); \
        $fdisplay(`LOG_FD, "  ICache: hit=%0b  icache_en=%0b", icache_2_core.hit, \
                  `FETCH_UNIT_PATH.fetch_outputs.fetch_2_icache.icache_en); \
    endtask
`endif

// --- IDM ---
`ifdef FETCH_UNIT_PATH
`define PRINT_IDM \
    task automatic print_idm(); \
        $fdisplay(`LOG_FD, "[IDM]  valid_slots=%0d", `FETCH_UNIT_PATH.idm_outputs.valid_slots); \
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin \
            if (`FETCH_UNIT_PATH.idm_outputs.idm_slots[i].valid) begin \
                $fwrite(`LOG_FD, "  slot[%0d] V=1  br_v=%0b  br_xcl=%0b", i, \
                        `FETCH_UNIT_PATH.idm_outputs.idm_slots[i].br_valid, \
                        `FETCH_UNIT_PATH.idm_outputs.idm_slots[i].br_xcl); \
                if (`FETCH_UNIT_PATH.idm_outputs.idm_slots[i].br_valid) \
                    $fwrite(`LOG_FD, "  br_eip=0x%08h  br_tgt=0x%08h", \
                            `FETCH_UNIT_PATH.idm_outputs.idm_slots[i].br_eip, \
                            `FETCH_UNIT_PATH.idm_outputs.idm_slots[i].br_btb_target); \
                $fdisplay(`LOG_FD, ""); \
            end else begin \
                $fdisplay(`LOG_FD, "  slot[%0d] V=0", i); \
            end \
        end \
        $fdisplay(`LOG_FD, "  IDM Ctrl: push_success=%0b", \
                  `FETCH_UNIT_PATH.fetch_unit.idm_ctrl_logic_outs.push_success); \
        $fwrite(`LOG_FD, "  Invalidate:"); \
        for (int i = 0; i < NUM_IDM_SLOTS; i++) \
            $fwrite(`LOG_FD, " [%0d]=%0b", i, `FETCH_UNIT_PATH.fetch_unit.idm_invalidate_logic_outs.invalidate[i]); \
        $fdisplay(`LOG_FD, "  no_writes=%0b", \
                  `FETCH_UNIT_PATH.fetch_unit.idm_invalidate_logic_outs.no_writes); \
    endtask
`endif




`endif
