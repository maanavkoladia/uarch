`ifndef TB_UTILS_EXE_PATH
`define TB_UTILS_EXE_PATH


//`ifndef EXE_UNIT_PATH
//    `error "WB_UNIT_PATH not defined"
//`endif



// --- EXE LATCHES ---
`ifdef EXE_UNIT_PATH
`define PRINT_EXE_LATCHES \
    task automatic print_exe_latches(); \
        $fdisplay(`LOG_FD, "[EXE LATCHES]"); \
        begin \
            automatic exe_latches_t L = `EXE_UNIT_PATH.exe_latches; \
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
`ifdef EXE_UNIT_PATH
`define PRINT_EXE_OUTPUTS \
    task automatic print_exe_outputs(); \
        $fdisplay(`LOG_FD, "[EXE OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  wb_we=%0b  ST_OP=%0b  ST_XCL=%0b  clr_ZF_sb=%0b  ZF=%0b", \
                  `EXE_UNIT_PATH.exe_outputs.valid, `EXE_UNIT_PATH.exe_outputs.wb_stage_latch_we, \
                  `EXE_UNIT_PATH.exe_outputs.ST_OP, `EXE_UNIT_PATH.exe_outputs.ST_XCL, \
                  `EXE_UNIT_PATH.exe_outputs.clr_ZF_sb, `EXE_UNIT_PATH.exe_outputs.ZF); \
        begin \
            automatic exe_br_resolution_outputs_t B = `EXE_UNIT_PATH.exe_outputs.br_res_out; \
            $fdisplay(`LOG_FD, "  BR_RES: valid=%0b  flush=%0b  farFlush=%0b  mispredict=%0b  taken=%0b", \
                      B.valid, B.flush, B.farFlush, B.miss_prediction, B.taken); \
            if (B.valid) \
                $fdisplay(`LOG_FD, "    eip=0x%08h  neip=0x%08h  tgt=0x%08h  xcl=%0b  ucond=%0b  clr_exp=%0b", \
                          B.br_eip, B.neip, B.br_target, B.br_XCL, B.br_ucond, B.clr_exp_mode); \
        end \
    endtask
`endif



`endif
