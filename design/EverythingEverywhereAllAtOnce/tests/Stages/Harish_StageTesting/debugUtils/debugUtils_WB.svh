`ifndef TB_UTILS_WB_PATH
`define TB_UTILS_WB_PATH


////====================================================
//// Always-available debug tasks (no macro-generated tasks)
////====================================================
//
//// --- WB LATCHES ---
//task automatic print_wb_latches();
//    $fdisplay(`LOG_FD, "[WB LATCHES]");
//
//`ifdef WB_UNIT_PATH
//    begin
//        automatic wb_latches_t L = `WB_UNIT_PATH.wb_latches;
//
//        $fdisplay(`LOG_FD, "  valid=%0b  ST_OP=%0b  WB_DR=%0b  WB_SR=%0b",
//                  L.valid, L.cs.ST_OP, L.cs.WB_DR, L.cs.WB_SR);
//
//        $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
//                  tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data,
//                  tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data);
//
//        $fdisplay(`LOG_FD, "  ST: xcl=%0b  paddr0=0x%04h  v0=0x%04h  paddr1=0x%04h  v1=0x%04h  MIO=%0b",
//                  L.ST_XCL, L.ST_PADDR_0, L.ST_BIT_VEC_0,
//                  L.ST_PADDR_1, L.ST_BIT_VEC_1, L.MIO);
//
//        $fwrite(`LOG_FD, "RES_BUF: ");
//        for (int i = 0; i < 16; i++) begin
//            $fwrite(`LOG_FD, "%02x", L.res_buf[i]);
//            if (i != 15) $fwrite(`LOG_FD, "_");
//        end
//        $fwrite(`LOG_FD, "\n         ");
//
//        for (int i = 16; i < 32; i++) begin
//            $fwrite(`LOG_FD, "%02x", L.res_buf[i]);
//            if (i != 31) $fwrite(`LOG_FD, "_");
//        end
//        $fdisplay(`LOG_FD, "");
//    end
//`endif
//
//endtask
//
//
//// --- WB OUTPUTS ---
//task automatic print_wb_outputs();
//    $fdisplay(`LOG_FD, "[WB OUTS]");
//`ifdef WB_UNIT_PATH
//    $fdisplay(`LOG_FD, "  valid=%0b  wb_stall=%0b",
//              `WB_UNIT_PATH.outputs.valid,
//              `WB_UNIT_PATH.outputs.wb_stall);
//
//    // $fdisplay(`LOG_FD, "  DR0: we=%0b  id=%s  data=0x%016h",
//    //           `WB_UNIT_PATH.outputs.DR_0_we,
//    //           tb_debug_pkg::get_reg_name(`WB_UNIT_PATH.outputs.DR_0_id),
//    //           `WB_UNIT_PATH.outputs.DR_0_data);
//
//    // $fdisplay(`LOG_FD, "  DR1: we=%0b  id=%s  data=0x%016h",
//    //           `WB_UNIT_PATH.outputs.DR_1_we,
//    //           tb_debug_pkg::get_reg_name(`WB_UNIT_PATH.outputs.DR_1_id),
//    //           `WB_UNIT_PATH.outputs.DR_1_data);
//`endif
//
//endtask
//
//
//// --- STORE QUEUES ---
//task automatic print_one_stq(int idx, st_q_outputs_t outs);
//    $fdisplay(`LOG_FD, "  STQ[%0d]: full=%0b  empty=%0b  push_fail=%0b",
//              idx, outs.full_q, outs.empty_q, outs.push_fail);
//
//    if (!outs.empty_q) begin
//        $fdisplay(`LOG_FD, "    HEAD: addr=0x%04h  bv=0x%04h",
//                  outs.head_address, outs.bit_vec);
//    end
//
//    for (int e = 0; e < ST_Q_DEPTH; e++) begin
//        if (outs.valid[e])
//            $fdisplay(`LOG_FD, "    [%0d] V=1 addr=0x%04h",
//                      e, outs.address[e]);
//    end
//endtask
//
//
//task automatic print_store_queues();
//    $fdisplay(`LOG_FD, "[STORE QUEUES]");
//
//`ifdef WB_UNIT_PATH
//    print_one_stq(0, `WB_UNIT_PATH.stq_outputs[0]);
//    print_one_stq(1, `WB_UNIT_PATH.stq_outputs[1]);
//    print_one_stq(2, `WB_UNIT_PATH.stq_outputs[2]);
//    print_one_stq(3, `WB_UNIT_PATH.stq_outputs[3]);
//`endif
//
//endtask
//
//
//// --- MIO QUEUE ---
//task automatic print_mio_queue();
//    $fdisplay(`LOG_FD, "[MIO QUEUE]");
//`ifdef WB_UNIT_PATH
//    $fdisplay(`LOG_FD, "  full=%0b  empty=%0b",
//              `WB_UNIT_PATH.mio_q_inst.full_q,
//              `WB_UNIT_PATH.mio_q_inst.empty_q);
//
//    if (!`WB_UNIT_PATH.mio_q_inst.empty_q) begin
//        $fdisplay(`LOG_FD,
//            "  entry: v=%0b  addr=0x%04h  data[0:3]=%02h %02h %02h %02h",
//            `WB_UNIT_PATH.mio_q_inst.mio_q.valid,
//            `WB_UNIT_PATH.mio_q_inst.mio_q.address,
//            `WB_UNIT_PATH.mio_q_inst.mio_q.data[0],
//            `WB_UNIT_PATH.mio_q_inst.mio_q.data[1],
//            `WB_UNIT_PATH.mio_q_inst.mio_q.data[2],
//            `WB_UNIT_PATH.mio_q_inst.mio_q.data[3]
//        );
//    end
//`endif
//
//endtask
//
//
//////====================================================
////// Unified call macro (always safe)
//////====================================================
////`define CREATE_WB_TASKS \
////    print_wb_latches(); \
////    print_wb_outputs(); \
////    print_store_queues(); \
////    print_mio_queue();
//
//
//// Optional wrapper
//task automatic print_wb_info();
//    #(`CLK_PERIOD-1);
//    print_wb_latches();
//    print_wb_outputs();
//    print_store_queues();
//    print_mio_queue();
//endtask
//
//
//// --- WB ACTUAL COMMIT ---
//// Same format as [WB NEXT LATCHES] so compare.py regexes work unchanged.
//// Sources data from actual WB stage outputs (accounts for stalls).
//// Called at posedge+#1 so REGISTERS[] has already settled.
//task automatic print_wb_actual_commit();
//    $fdisplay(`LOG_FD, "[WB ACTUAL COMMIT]");
//`ifdef WB_UNIT_PATH
//    $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h",
//              `WB_UNIT_PATH.outputs.valid,
//              `WB_UNIT_PATH.wb_latches.EIP);
//
//    // $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
//    //           tb_debug_pkg::get_reg_name(`WB_UNIT_PATH.outputs.DR_0_id),
//    //           `WB_UNIT_PATH.outputs.DR_0_data,
//    //           tb_debug_pkg::get_reg_name(`WB_UNIT_PATH.outputs.DR_1_id),
//    //           `WB_UNIT_PATH.outputs.DR_1_data);
//
//    $fdisplay(`LOG_FD, "  WB_CS: ST=%0b",
//              `WB_UNIT_PATH.outputs.ST_OP
//              /*`WB_UNIT_PATH.outputs.DR_0_we,
//              `WB_UNIT_PATH.outputs.DR_1_we*/);
//`endif
//endtask
//

//`define REGFILE_OUTPUT_STRUCTURAL

// --- REGFILE DUMP ---
// Full snapshot of GPRs and segment registers.
// Call after posedge+#1 so flip-flop writes from that posedge are visible.
task automatic print_regfile_dump();
    begin
    $fdisplay(`LOG_FD, "[REGFILE DUMP]");
`ifdef REGFILE_PATH
`ifdef REGFILE_OUTPUT_STRUCTURAL

    $fdisplay(`LOG_FD, "  EAX=0x%08h  EBX=0x%08h  ECX=0x%08h  EDX=0x%08h",
              `REGFILE_PATH.REG_EAX_o[31:0],
              `REGFILE_PATH.REG_EBX_o[31:0],
              `REGFILE_PATH.REG_ECX_o[31:0],
              `REGFILE_PATH.REG_EDX_o[31:0]);
    $fdisplay(`LOG_FD, "  ESP=0x%08h  EBP=0x%08h  ESI=0x%08h  EDI=0x%08h",
              `REGFILE_PATH.REG_ESP_o[31:0],
              `REGFILE_PATH.REG_EBP_o[31:0],
              `REGFILE_PATH.REG_ESI_o[31:0],
              `REGFILE_PATH.REG_EDI_o[31:0]);
    $fdisplay(`LOG_FD, "  CS =0x%08h  DS =0x%08h  SS =0x%08h  ES =0x%08h",
              `REGFILE_PATH.REG_CS_o[31:0],
              `REGFILE_PATH.REG_DS_o[31:0],
              `REGFILE_PATH.REG_SS_o[31:0],
              `REGFILE_PATH.REG_ES_o[31:0]);
    $fdisplay(`LOG_FD, "  FS =0x%08h  GS =0x%08h",
              `REGFILE_PATH.REG_FS_o[31:0],
              `REGFILE_PATH.REG_GS_o[31:0]);
    $fdisplay(`LOG_FD, "  MM0=0x%016h  MM1=0x%016h  MM2=0x%016h  MM3=0x%016h",
              `REGFILE_PATH.REG_MM0_o,
              `REGFILE_PATH.REG_MM1_o,
              `REGFILE_PATH.REG_MM2_o,
              `REGFILE_PATH.REG_MM3_o);
    $fdisplay(`LOG_FD, "  MM4=0x%016h  MM5=0x%016h  MM6=0x%016h  MM7=0x%016h",
              `REGFILE_PATH.REG_MM4_o,
              `REGFILE_PATH.REG_MM5_o,
              `REGFILE_PATH.REG_MM6_o,
              `REGFILE_PATH.REG_MM7_o);
`else

    $fdisplay(`LOG_FD, "  EAX=0x%08h  EBX=0x%08h  ECX=0x%08h  EDX=0x%08h",
              `REGFILE_PATH.REGISTERS[EAX][31:0],
              `REGFILE_PATH.REGISTERS[EBX][31:0],
              `REGFILE_PATH.REGISTERS[ECX][31:0],
              `REGFILE_PATH.REGISTERS[EDX][31:0]);
    $fdisplay(`LOG_FD, "  ESP=0x%08h  EBP=0x%08h  ESI=0x%08h  EDI=0x%08h",
              `REGFILE_PATH.REGISTERS[ESP][31:0],
              `REGFILE_PATH.REGISTERS[EBP][31:0],
              `REGFILE_PATH.REGISTERS[ESI][31:0],
              `REGFILE_PATH.REGISTERS[EDI][31:0]);
    $fdisplay(`LOG_FD, "  CS =0x%08h  DS =0x%08h  SS =0x%08h  ES =0x%08h",
              `REGFILE_PATH.REGISTERS[CS][31:0],
              `REGFILE_PATH.REGISTERS[DS][31:0],
              `REGFILE_PATH.REGISTERS[SS][31:0],
              `REGFILE_PATH.REGISTERS[ES][31:0]);
    $fdisplay(`LOG_FD, "  FS =0x%08h  GS =0x%08h",
              `REGFILE_PATH.REGISTERS[FS][31:0],
              `REGFILE_PATH.REGISTERS[GS][31:0]);
    $fdisplay(`LOG_FD, "  MM0=0x%016h  MM1=0x%016h  MM2=0x%016h  MM3=0x%016h",
              `REGFILE_PATH.REGISTERS[MM0],
              `REGFILE_PATH.REGISTERS[MM1],
              `REGFILE_PATH.REGISTERS[MM2],
              `REGFILE_PATH.REGISTERS[MM3]);
    $fdisplay(`LOG_FD, "  MM4=0x%016h  MM5=0x%016h  MM6=0x%016h  MM7=0x%016h",
              `REGFILE_PATH.REGISTERS[MM4],
              `REGFILE_PATH.REGISTERS[MM5],
              `REGFILE_PATH.REGISTERS[MM6],
              `REGFILE_PATH.REGISTERS[MM7]);
`endif

`endif
    end
endtask


// --- REGFILE DUMP TO SEPARATE FILE ---
// Writes a full GPR + segment snapshot to regdump.log.
// Pass the EIP of the committing instruction as the label.
task automatic dump_regs(input reg [31:0] eip);
    begin
    $fdisplay(`REGDUMP_FD, "[REGFILE DUMP] EIP=0x%08h", eip);
`ifdef REGFILE_PATH
`ifdef REGFILE_OUTPUT_STRUCTURAL
    $fdisplay(`REGDUMP_FD, "  EAX=0x%08h  EBX=0x%08h  ECX=0x%08h  EDX=0x%08h",
              `REGFILE_PATH.REG_EAX_o[31:0],
              `REGFILE_PATH.REG_EBX_o[31:0],
              `REGFILE_PATH.REG_ECX_o[31:0],
              `REGFILE_PATH.REG_EDX_o[31:0]);
    $fdisplay(`REGDUMP_FD, "  ESP=0x%08h  EBP=0x%08h  ESI=0x%08h  EDI=0x%08h",
              `REGFILE_PATH.REG_ESP_o[31:0],
              `REGFILE_PATH.REG_EBP_o[31:0],
              `REGFILE_PATH.REG_ESI_o[31:0],
              `REGFILE_PATH.REG_EDI_o[31:0]);
    $fdisplay(`REGDUMP_FD, "  CS =0x%08h  DS =0x%08h  SS =0x%08h  ES =0x%08h",
              `REGFILE_PATH.REG_CS_o[31:0],
              `REGFILE_PATH.REG_DS_o[31:0],
              `REGFILE_PATH.REG_SS_o[31:0],
              `REGFILE_PATH.REG_ES_o[31:0]);
    $fdisplay(`REGDUMP_FD, "  FS =0x%08h  GS =0x%08h",
              `REGFILE_PATH.REG_FS_o[31:0],
              `REGFILE_PATH.REG_GS_o[31:0]);
    $fdisplay(`REGDUMP_FD, "  MM0=0x%016h  MM1=0x%016h  MM2=0x%016h  MM3=0x%016h",
              `REGFILE_PATH.REG_MM0_o,
              `REGFILE_PATH.REG_MM1_o,
              `REGFILE_PATH.REG_MM2_o,
              `REGFILE_PATH.REG_MM3_o);
    $fdisplay(`REGDUMP_FD, "  MM4=0x%016h  MM5=0x%016h  MM6=0x%016h  MM7=0x%016h",
              `REGFILE_PATH.REG_MM4_o,
              `REGFILE_PATH.REG_MM5_o,
              `REGFILE_PATH.REG_MM6_o,
              `REGFILE_PATH.REG_MM7_o);
`else
    $fdisplay(`REGDUMP_FD, "  EAX=0x%08h  EBX=0x%08h  ECX=0x%08h  EDX=0x%08h",
              `REGFILE_PATH.REGISTERS[EAX][31:0],
              `REGFILE_PATH.REGISTERS[EBX][31:0],
              `REGFILE_PATH.REGISTERS[ECX][31:0],
              `REGFILE_PATH.REGISTERS[EDX][31:0]);
    $fdisplay(`REGDUMP_FD, "  ESP=0x%08h  EBP=0x%08h  ESI=0x%08h  EDI=0x%08h",
              `REGFILE_PATH.REGISTERS[ESP][31:0],
              `REGFILE_PATH.REGISTERS[EBP][31:0],
              `REGFILE_PATH.REGISTERS[ESI][31:0],
              `REGFILE_PATH.REGISTERS[EDI][31:0]);
    $fdisplay(`REGDUMP_FD, "  CS =0x%08h  DS =0x%08h  SS =0x%08h  ES =0x%08h",
              `REGFILE_PATH.REGISTERS[CS][31:0],
              `REGFILE_PATH.REGISTERS[DS][31:0],
              `REGFILE_PATH.REGISTERS[SS][31:0],
              `REGFILE_PATH.REGISTERS[ES][31:0]);
    $fdisplay(`REGDUMP_FD, "  FS =0x%08h  GS =0x%08h",
              `REGFILE_PATH.REGISTERS[FS][31:0],
              `REGFILE_PATH.REGISTERS[GS][31:0]);
    $fdisplay(`REGDUMP_FD, "  MM0=0x%016h  MM1=0x%016h  MM2=0x%016h  MM3=0x%016h",
              `REGFILE_PATH.REGISTERS[MM0],
              `REGFILE_PATH.REGISTERS[MM1],
              `REGFILE_PATH.REGISTERS[MM2],
              `REGFILE_PATH.REGISTERS[MM3]);
    $fdisplay(`REGDUMP_FD, "  MM4=0x%016h  MM5=0x%016h  MM6=0x%016h  MM7=0x%016h",
              `REGFILE_PATH.REGISTERS[MM4],
              `REGFILE_PATH.REGISTERS[MM5],
              `REGFILE_PATH.REGISTERS[MM6],
              `REGFILE_PATH.REGISTERS[MM7]);
`endif

`endif
    end
endtask


`endif
