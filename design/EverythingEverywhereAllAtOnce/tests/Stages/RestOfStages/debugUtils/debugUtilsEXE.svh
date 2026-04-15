`ifndef TB_UTILS_EXE_PATH
`define TB_UTILS_EXE_PATH

//====================================================
// Always-available debug tasks (no macro-generated tasks)
//====================================================


// --- EXE LATCHES ---
task automatic print_exe_latches();
    $fdisplay(`LOG_FD, "[EXE LATCHES]");

`ifdef EXE_UNIT_PATH
    begin
        automatic exe_latches_t L = `EXE_UNIT_PATH.latches_i;

        $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h",
                  L.valid, L.EIP, L.NEIP);

        $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
                  tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data,
                  tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data);

        $fdisplay(`LOG_FD, "  CS: OP=%s  ST=%0b   data_size_vec=0x%01h",
                  tb_debug_pkg::get_op_name(L.cs.OP_TYPE),
                  L.cs.ST_OP, L.data_size_vec);

        $fdisplay(`LOG_FD, "  inputA_sel=%0d  inputB_sel=%0d  br_tgt_sel=%0d",
                  L.cs.alu_inputA_sel,
                  L.cs.alu_inputB_sel,
                  L.cs.branch_target_sel);

        $fdisplay(`LOG_FD,
            "  br_info: v=%0b  eip=0x%08h  xcl=%0b  pred_taken=%0b  spec_tgt=0x%08h",
            L.br_info.valid, L.br_info.br_eip, L.br_info.br_xcl,
            L.br_info.br_pred_taken, L.br_info.speculative_target);

        $fdisplay(`LOG_FD,
            "  ST: xcl=%0b  paddr0=0x%04h  paddr1=0x%04h  MIO=%0b",
            L.ST_XCL, L.ST_PADDR_0, L.ST_PADDR_1, L.MIO);

        $fdisplay(`LOG_FD,
            "  imm64=0x%016h  ld_addy=0x%04h",
            L.imm64, L.ld_addy);

        $fdisplay(`LOG_FD,
            "  WB_CS: ST=%0b DR=%0b SR=%0b",
            L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR);

        // LD BUFFER (same formatting as WB RES_BUF)
        $fwrite(`LOG_FD, "LD_BUF: ");
        for (int i = 0; i < 16; i++) begin
            $fwrite(`LOG_FD, "%02x", L.ld_buf[i]);
            if (i != 15) $fwrite(`LOG_FD, "_");
        end

        $fwrite(`LOG_FD, "\n         ");

        for (int i = 16; i < 32; i++) begin
            $fwrite(`LOG_FD, "%02x", L.ld_buf[i]);
            if (i != 31) $fwrite(`LOG_FD, "_");
        end

        $fdisplay(`LOG_FD, "");
    end
`endif

endtask


// --- EXE OUTPUTS ---
task automatic print_exe_outputs();
    $fdisplay(`LOG_FD, "[EXE OUTS]");

`ifdef EXE_UNIT_PATH
    $fdisplay(`LOG_FD,
        "  valid=%0b  wb_we=%0b  ST_OP=%0b  ST_XCL=%0b  clr_ZF_sb=%0b  ZF=%0b",
        `EXE_UNIT_PATH.outs_o.valid,
        `EXE_UNIT_PATH.outs_o.wb_stage_latch_we,
        `EXE_UNIT_PATH.outs_o.ST_OP,
        `EXE_UNIT_PATH.outs_o.ST_XCL,
        `EXE_UNIT_PATH.outs_o.clr_ZF_sb,
        `EXE_UNIT_PATH.outs_o.ZF
    );

    begin
        automatic exe_br_resolution_outputs_t B =
            `EXE_UNIT_PATH.outs_o.br_res_out;

        $fdisplay(`LOG_FD,
            "  BR_RES: valid=%0b  flush=%0b  farFlush=%0b  mispredict=%0b  taken=%0b",
            B.valid, B.flush, B.farFlush, B.miss_prediction, B.taken);

        if (B.valid) begin
            $fdisplay(`LOG_FD,
                "    eip=0x%08h  neip=0x%08h  tgt=0x%08h  xcl=%0b  ucond=%0b  clr_exp=%0b",
                B.br_eip, B.neip, B.br_target,
                B.br_XCL, B.br_ucond, B.clr_exp_mode);
        end
    end
`endif

endtask


// --- WB NEXT LATCHES (what will be written this cycle) ---
task automatic print_wb_next_latches();
    $fdisplay(`LOG_FD, "[WB NEXT LATCHES]");

`ifdef EXE_UNIT_PATH
    begin
        automatic wb_latches_t L = `EXE_UNIT_PATH.wb_latches_next_o;

        $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h",
                  L.valid, L.EIP);

        $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
                  tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data,
                  tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data);

        $fdisplay(`LOG_FD, "  WB_CS: ST=%0b WB_DR=%0b WB_SR=%0b",
                  L.cs.ST_OP, L.cs.WB_DR, L.cs.WB_SR);

        $fdisplay(`LOG_FD,
            "  ST: xcl=%0b  paddr0=0x%04h  bitvec0=0x%04h  paddr1=0x%04h  bitvec1=0x%04h  MIO=%0b",
            L.ST_XCL, L.ST_PADDR_0, L.ST_BIT_VEC_0, L.ST_PADDR_1, L.ST_BIT_VEC_1, L.MIO);

        // RES BUFFER (32 bytes formatted in two lines of 16 bytes each)
        $fwrite(`LOG_FD, "RES_BUF: ");
        for (int i = 0; i < 16; i++) begin
            $fwrite(`LOG_FD, "%02x", L.res_buf[i]);
            if (i != 15) $fwrite(`LOG_FD, "_");
        end

        $fwrite(`LOG_FD, "\n         ");

        for (int i = 16; i < 32; i++) begin
            $fwrite(`LOG_FD, "%02x", L.res_buf[i]);
            if (i != 31) $fwrite(`LOG_FD, "_");
        end

        $fdisplay(`LOG_FD, "");
    end
`endif

endtask
// --- Optional wrapper (same pattern as WB) ---
task automatic print_exe_info();
    #(`CLK_PERIOD-1);
    print_exe_latches();
    print_exe_outputs();
    print_wb_next_latches();
endtask


`endif