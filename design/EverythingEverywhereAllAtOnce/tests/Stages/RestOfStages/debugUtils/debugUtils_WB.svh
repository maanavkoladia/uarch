`ifndef TB_UTILS_WB_PATH
`define TB_UTILS_WB_PATH


//`ifndef WB_UNIT_PATH
//    `error "WB_UNIT_PATH not defined"
//`endif

// --- WB LATCHES ---
`ifdef WB_UNIT_PATH
`define PRINT_WB_LATCHES \
    task automatic print_wb_latches(); \
        $fdisplay(`LOG_FD, "[WB LATCHES]"); \
        begin \
            automatic wb_latches_t L = `WB_UNIT_PATH.wb_latches; \
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

`ifdef WB_UNIT_PATH
`define PRINT_WB_OUTPUTS \
    task automatic print_wb_outputs(); \
        $fdisplay(`LOG_FD, "[WB OUTS]"); \
        $fdisplay(`LOG_FD, "  valid=%0b  wb_stall=%0b", \
                  `WB_UNIT_PATH.wb_outputs.valid, `WB_UNIT_PATH.wb_outputs.wb_stall); \
        $fdisplay(`LOG_FD, "  DR0: we=%0b  id=%s  data=0x%016h", \
                  `WB_UNIT_PATH.wb_outputs.DR_0_we, \
                  tb_debug_pkg::get_reg_name(`WB_UNIT_PATH.wb_outputs.DR_0_id), \
                  `WB_UNIT_PATH.wb_outputs.DR_0_data); \
        $fdisplay(`LOG_FD, "  DR1: we=%0b  id=%s  data=0x%016h", \
                  `WB_UNIT_PATH.wb_outputs.DR_1_we, \
                  tb_debug_pkg::get_reg_name(`WB_UNIT_PATH.wb_outputs.DR_1_id), \
                  `WB_UNIT_PATH.wb_outputs.DR_1_data); \
    endtask
`endif

`ifdef WB_UNIT_PATH
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
        print_one_stq(0, `WB_UNIT_PATH.write_back_unit.stq_outputs[0]); \
        print_one_stq(1, `WB_UNIT_PATH.write_back_unit.stq_outputs[1]); \
        print_one_stq(2, `WB_UNIT_PATH.write_back_unit.stq_outputs[2]); \
        print_one_stq(3, `WB_UNIT_PATH.write_back_unit.stq_outputs[3]); \
    endtask
`endif

`ifdef WB_UNIT_PATH
`define PRINT_MIO_QUEUE \
    task automatic print_mio_queue(); \
        $fdisplay(`LOG_FD, "[MIO QUEUE]"); \
        $fdisplay(`LOG_FD, "  full=%0b  empty=%0b", \
                  `WB_UNIT_PATH.write_back_unit.mio_q_inst.full, \
                  `WB_UNIT_PATH.write_back_unit.mio_q_inst.empty); \
        if (!`WB_UNIT_PATH.write_back_unit.mio_q_inst.empty) begin \
            $fdisplay(`LOG_FD, "  entry: v=%0b  addr=0x%04h  data[0:3]=%02h %02h %02h %02h", \
                      `WB_UNIT_PATH.write_back_unit.mio_q_inst.mio_q.valid, \
                      `WB_UNIT_PATH.write_back_unit.mio_q_inst.mio_q.address, \
                      `WB_UNIT_PATH.write_back_unit.mio_q_inst.mio_q.data[0], \
                      `WB_UNIT_PATH.write_back_unit.mio_q_inst.mio_q.data[1], \
                      `WB_UNIT_PATH.write_back_unit.mio_q_inst.mio_q.data[2], \
                      `WB_UNIT_PATH.write_back_unit.mio_q_inst.mio_q.data[3]); \
        end \
    endtask
`endif

`PRINT_WB_LATCHES
`PRINT_WB_OUTPUTS
`PRINT_STORE_QUEUES

`PRINT_MIO_QUEUEtask automatic print_wb_info();
    print_wb_latches();
    print_wb_outputs();
    print_store_queues();
    print_mio_queue();
endtask

`endif
