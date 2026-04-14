`ifndef TB_UTILS_MEM_PATH
`define TB_UTILS_MEM_PATH


`ifndef MEM_UNIT_PATH
    `error "WB_UNIT_PATH not defined"
`endif


// --- MEM LATCHES ---
`ifdef MEM_UNIT_PATH
`define PRINT_MEM_LATCHES \
    task automatic print_mem_latches(); \
        $fdisplay(`LOG_FD, "[MEM LATCHES]"); \
        begin \
            automatic mem_latches_t L = `MEM_UNIT_PATH.mem_latches; \
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
`ifdef MEM_UNIT_PATH
`define PRINT_MEM_OUTPUTS \
    task automatic print_mem_outputs(); \
        $fdisplay(`LOG_FD, "[MEM OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  stall=%0b  exe_we=%0b  ST_OP=%0b  ST_XCL=%0b", \
                  `MEM_UNIT_PATH.mem_outputs.valid, `MEM_UNIT_PATH.mem_outputs.stall, \
                  `MEM_UNIT_PATH.mem_outputs.exe_stage_latch_we, `MEM_UNIT_PATH.mem_outputs.ST_OP, \
                  `MEM_UNIT_PATH.mem_outputs.ST_XCL); \
        $fdisplay(`LOG_FD, "  ST_PADDR_0=0x%04h  ST_PADDR_1=0x%04h", \
                  `MEM_UNIT_PATH.mem_outputs.ST_PADDR_0, `MEM_UNIT_PATH.mem_outputs.ST_PADDR_1); \
        $fdisplay(`LOG_FD, "  DCache: hit0=%0b  hit1=%0b  hit2=%0b  hit3=%0b  hitMIO=%0b", \
                  dcache_2_core.hit[0], dcache_2_core.hit[1], dcache_2_core.hit[2], \
                  dcache_2_core.hit[3], dcache_2_core.hit_MIO); \
    endtask
`endif

`endif
