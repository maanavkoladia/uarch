`ifndef TB_UTILS_DC_PATH
`define TB_UTILS_DC_PATH


//`ifndef DC_UNIT_PATH
//    `error "WB_UNIT_PATH not defined"
//`endif

// --- DC LATCHES ---
`ifdef DC_UNIT_PATH
`define PRINT_DC_LATCHES \
    task automatic print_dc_latches(); \
        $fdisplay(`LOG_FD, "[DC LATCHES]"); \
        begin \
            automatic dc_latches_t L = `DC_UNIT_PATH.latches_i; \
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
`ifdef DC_UNIT_PATH
`define PRINT_DC_OUTPUTS \
    task automatic print_dc_outputs(); \
        $fdisplay(`LOG_FD, "[DC OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  stall=%0b  mem_we=%0b", \
                  `DC_UNIT_PATH.dc_outputs.valid, `DC_UNIT_PATH.dc_outputs.stall, \
                  `DC_UNIT_PATH.dc_outputs.exp_present, `DC_UNIT_PATH.dc_outputs.exp_pf, \
                  `DC_UNIT_PATH.dc_outputs.mem_stage_latch_we); \
        $fdisplay(`LOG_FD, "  ld0: V=%0b addr=0x%04h   ld1: V=%0b addr=0x%04h   mio: V=%0b addr=0x%04h", \
                  `DC_UNIT_PATH.dc_outputs.ld_addr_0_V, `DC_UNIT_PATH.dc_outputs.ld_addr_0, \
                  `DC_UNIT_PATH.dc_outputs.ld_addr_1_V, `DC_UNIT_PATH.dc_outputs.ld_addr_1, \
                  `DC_UNIT_PATH.dc_outputs.ld_addr_MIO_V, `DC_UNIT_PATH.dc_outputs.ld_addr_MIO); \
    endtask
`endif
// --- STALLS & FLUSHES ---
`ifdef DC_UNIT_PATH
`define PRINT_STALLS \
    task automatic print_stalls(); \
        $fdisplay(`LOG_FD, "[STALLS & FLUSHES]"); \
        $fdisplay(`LOG_FD, "  RR_stall=%0b  DC_stall=%0b  MEM_stall=%0b  WB_stall=%0b", \
                  `DC_UNIT_PATH.rr_outputs.stall, `DC_UNIT_PATH.dc_outputs.stall, \
                  `DC_UNIT_PATH.mem_outputs.stall, `DC_UNIT_PATH.wb_outputs.wb_stall); \
        $fdisplay(`LOG_FD, "  flush=%0b  farFlush=%0b  exp_pipe_clear=%0b  int_pipe_clear=%0b", \
                  `DC_UNIT_PATH.exe_outputs.br_res_out.flush, \
                  `DC_UNIT_PATH.exe_outputs.br_res_out.farFlush, \
                  `DC_UNIT_PATH.fetch_unit.exp_set_logic_outs.exp_pipe_clear, \
                  `DC_UNIT_PATH.fetch_unit.exp_set_logic_outs.int_pipe_clear); \
        $fdisplay(`LOG_FD, "  RR_exp=%0b  RR_exp_pf=%0b  decode_invalid=%0b  decode_gp=%0b", \
                  `DC_UNIT_PATH.dc_outputs.exp_present, `DC_UNIT_PATH.dc_outputs.exp_pf, \
                  `DC_UNIT_PATH.decode_outputs.invalid_instruction, \
                  `DC_UNIT_PATH.decode_outputs.decode_gp); \
    endtask
`endif

`endif
