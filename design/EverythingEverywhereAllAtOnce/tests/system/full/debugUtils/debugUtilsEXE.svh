`ifndef TB_UTILS_EXE_PATH
`define TB_UTILS_EXE_PATH

//====================================================
// Always-available debug tasks (no macro-generated tasks)
//
// EXE_PURE_STRUCTURAL toggle:
//   * defined  -> EXE has flat Verilog-2005 ports (EXE_structural.v).
//                 Field reads come from individual flat ports
//                 (`EXE_UNIT_PATH.outs_valid, .latches_cs_OP_TYPE, ...).
//                 Where the legacy code wanted a struct (`exe_latches_t L`),
//                 we declare L as an automatic local and fill it field-
//                 by-field so the rest of the formatting code is unchanged.
//   * undefined -> Legacy SV mode. EXE has struct ports
//                  (EXE_structural.sv / EXE.sv) and the testbench reads
//                  `EXE_UNIT_PATH.latches_i / .outs_o / .wb_latches_next_o
//                  directly.
// Define `EXE_PURE_STRUCTURAL in debugUtils/tb_utils_defs.svh to pick the
// flat-port branch.
//====================================================


// --- EXE LATCHES ---
task automatic print_exe_latches();
    $fdisplay(`LOG_FD, "[EXE LATCHES]");

`ifdef EXE_UNIT_PATH
    begin
        automatic exe_latches_t L;
        automatic string sel_a, sel_b, sel_br;

`ifdef EXE_PURE_STRUCTURAL
        // Rebuild L from flat ports.
        L.valid               = `EXE_UNIT_PATH.latches_valid;
        L.cs.ST_OP            = `EXE_UNIT_PATH.latches_cs_ST_OP;
        L.cs.OP_TYPE          = exe_cs_operation_type_e'(`EXE_UNIT_PATH.latches_cs_OP_TYPE);
        L.cs.alu_inputA_sel   = source_selector_e'(`EXE_UNIT_PATH.latches_cs_alu_inputA_sel);
        L.cs.alu_inputB_sel   = source_selector_e'(`EXE_UNIT_PATH.latches_cs_alu_inputB_sel);
        L.cs.branch_target_sel= source_selector_e'(`EXE_UNIT_PATH.latches_cs_branch_target_sel);
        L.cs.shift_by_one     = `EXE_UNIT_PATH.latches_cs_shift_by_one;
        L.cs.br_ucond         = `EXE_UNIT_PATH.latches_cs_br_ucond;
        L.cs.relative_branch  = `EXE_UNIT_PATH.latches_cs_relative_branch;
        L.cs.special_br       = `EXE_UNIT_PATH.latches_cs_special_br;
        L.cs.is_far           = `EXE_UNIT_PATH.latches_cs_is_far;
        L.cs.is_call          = `EXE_UNIT_PATH.latches_cs_is_call;
        L.cs.second_flag_needed = `EXE_UNIT_PATH.latches_cs_second_flag_needed;
        L.cs.rep_no_zf_update = `EXE_UNIT_PATH.latches_cs_rep_no_zf_update;
        L.wb_cs.ST_OP         = `EXE_UNIT_PATH.latches_wb_cs_ST_OP;
        L.wb_cs.WB_DR         = `EXE_UNIT_PATH.latches_wb_cs_WB_DR;
        L.wb_cs.WB_SR         = `EXE_UNIT_PATH.latches_wb_cs_WB_SR;
        L.wb_cs.WB_EAX        = `EXE_UNIT_PATH.latches_wb_cs_WB_EAX;
        L.data_size_vec       = `EXE_UNIT_PATH.latches_data_size_vec;
        L.sr_data_size_vec    = `EXE_UNIT_PATH.latches_sr_data_size_vec;
        L.shift_sr_up         = `EXE_UNIT_PATH.latches_shift_sr_up;
        L.shift_sr_down       = `EXE_UNIT_PATH.latches_shift_sr_down;
        L.ST_XCL              = `EXE_UNIT_PATH.latches_ST_XCL;
        L.ST_PADDR_0          = `EXE_UNIT_PATH.latches_ST_PADDR_0;
        L.ST_PADDR_1          = `EXE_UNIT_PATH.latches_ST_PADDR_1;
        L.MIO                 = `EXE_UNIT_PATH.latches_MIO;
        L.br_info.valid       = `EXE_UNIT_PATH.latches_br_info_valid;
        L.br_info.br_eip      = `EXE_UNIT_PATH.latches_br_info_br_eip;
        L.br_info.br_xcl      = `EXE_UNIT_PATH.latches_br_info_br_xcl;
        L.br_info.br_pred_taken      = `EXE_UNIT_PATH.latches_br_info_br_pred_taken;
        L.br_info.speculative_target = `EXE_UNIT_PATH.latches_br_info_speculative_target;
        L.br_rel_target       = `EXE_UNIT_PATH.latches_br_rel_target;
        L.NEIP                = `EXE_UNIT_PATH.latches_NEIP;
        L.EIP                 = `EXE_UNIT_PATH.latches_EIP;
        L.EAX                 = `EXE_UNIT_PATH.latches_EAX;
        L.imm64               = `EXE_UNIT_PATH.latches_imm64;
        for (int i = 0; i < 32; i++)
            L.ld_buf[i] = `EXE_UNIT_PATH.latches_ld_buf[i*8 +: 8];
        L.sr_id               = reg_ids_e'(`EXE_UNIT_PATH.latches_sr_id);
        L.sr_data             = `EXE_UNIT_PATH.latches_sr_data;
        L.dr_id               = reg_ids_e'(`EXE_UNIT_PATH.latches_dr_id);
        L.dr_data             = `EXE_UNIT_PATH.latches_dr_data;
        L.ld_addy             = `EXE_UNIT_PATH.latches_ld_addy;
`else
        L = `EXE_UNIT_PATH.latches_i;
`endif

        sel_a  = tb_debug_pkg::get_source_selector_name(L.cs.alu_inputA_sel);
        sel_b  = tb_debug_pkg::get_source_selector_name(L.cs.alu_inputB_sel);
        sel_br = tb_debug_pkg::get_source_selector_name(L.cs.branch_target_sel);

        $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h",
                  L.valid, L.EIP, L.NEIP);

        $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
                  tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data,
                  tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data);

        $fdisplay(`LOG_FD, "  CS: OP=%s  ST=%0b   data_size_vec=0x%01h",
                  tb_debug_pkg::get_op_name(L.cs.OP_TYPE),
                  L.cs.ST_OP, L.data_size_vec);

        $fdisplay(`LOG_FD, "  inputA_sel=%s  inputB_sel=%s  br_tgt_sel=%s",
                    sel_a, sel_b, sel_br);

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

        $fdisplay(`LOG_FD,
            "  FLAGS: AF=%0b CF=%0b DF=%0b OF=%0b PF=%0b SF=%0b ZF=%0b",
            `EXE_UNIT_PATH.af_flag_o,
            `EXE_UNIT_PATH.cf_flag_o,
            `EXE_UNIT_PATH.df_flag_o,
            `EXE_UNIT_PATH.of_flag_o,
            `EXE_UNIT_PATH.pf_flag_o,
            `EXE_UNIT_PATH.sf_flag_o,
            `EXE_UNIT_PATH.zf_flag_o
        );

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
`ifdef EXE_PURE_STRUCTURAL
    $fdisplay(`LOG_FD,
        "  valid=%0b  wb_we=%0b  ST_OP=%0b  ST_XCL=%0b  clr_ZF_sb=%0b  ZF=%0b",
        `EXE_UNIT_PATH.outs_valid,
        `EXE_UNIT_PATH.outs_wb_stage_latch_we,
        `EXE_UNIT_PATH.outs_ST_OP,
        `EXE_UNIT_PATH.outs_ST_XCL,
        `EXE_UNIT_PATH.outs_clr_ZF_sb,
        `EXE_UNIT_PATH.outs_ZF
    );

    begin
        automatic exe_br_resolution_outputs_t B;
        B.valid           = `EXE_UNIT_PATH.outs_br_res_valid;
        B.flush           = `EXE_UNIT_PATH.outs_br_res_flush;
        B.farFlush        = `EXE_UNIT_PATH.outs_br_res_farFlush;
        B.callFlush       = `EXE_UNIT_PATH.outs_br_res_callFlush;
        B.miss_prediction = `EXE_UNIT_PATH.outs_br_res_miss_prediction;
        B.br_eip          = `EXE_UNIT_PATH.outs_br_res_br_eip;
        B.neip            = `EXE_UNIT_PATH.outs_br_res_neip;
        B.br_target       = `EXE_UNIT_PATH.outs_br_res_br_target;
        B.taken           = `EXE_UNIT_PATH.outs_br_res_taken;
        B.br_XCL          = `EXE_UNIT_PATH.outs_br_res_br_XCL;
        B.clr_exp_mode    = `EXE_UNIT_PATH.outs_br_res_clr_exp_mode;
        B.br_ucond        = `EXE_UNIT_PATH.outs_br_res_br_ucond;

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
`else
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
`endif

endtask


// --- WB NEXT LATCHES (what will be written this cycle) ---
task automatic print_wb_next_latches();
    $fdisplay(`LOG_FD, "[WB NEXT LATCHES]");

`ifdef EXE_UNIT_PATH
    begin
        automatic wb_latches_t L;

`ifdef EXE_PURE_STRUCTURAL
        L.valid          = `EXE_UNIT_PATH.wb_latches_next_valid;
        L.cs.ST_OP       = `EXE_UNIT_PATH.wb_latches_next_cs_ST_OP;
        L.cs.WB_DR       = `EXE_UNIT_PATH.wb_latches_next_cs_WB_DR;
        L.cs.WB_SR       = `EXE_UNIT_PATH.wb_latches_next_cs_WB_SR;
        L.cs.WB_EAX      = `EXE_UNIT_PATH.wb_latches_next_cs_WB_EAX;
        L.ST_XCL         = `EXE_UNIT_PATH.wb_latches_next_ST_XCL;
        L.ST_PADDR_0     = `EXE_UNIT_PATH.wb_latches_next_ST_PADDR_0;
        L.ST_BIT_VEC_0   = `EXE_UNIT_PATH.wb_latches_next_ST_BIT_VEC_0;
        L.ST_PADDR_1     = `EXE_UNIT_PATH.wb_latches_next_ST_PADDR_1;
        L.ST_BIT_VEC_1   = `EXE_UNIT_PATH.wb_latches_next_ST_BIT_VEC_1;
        L.MIO            = `EXE_UNIT_PATH.wb_latches_next_MIO;
        L.EIP            = `EXE_UNIT_PATH.wb_latches_next_EIP;
        for (int i = 0; i < 32; i++)
            L.res_buf[i] = `EXE_UNIT_PATH.wb_latches_next_res_buf[i*8 +: 8];
        L.sr_id          = reg_ids_e'(`EXE_UNIT_PATH.wb_latches_next_sr_id);
        L.sr_data        = `EXE_UNIT_PATH.wb_latches_next_sr_data;
        L.dr_id          = reg_ids_e'(`EXE_UNIT_PATH.wb_latches_next_dr_id);
        L.dr_data        = `EXE_UNIT_PATH.wb_latches_next_dr_data;
        L.EAX            = `EXE_UNIT_PATH.wb_latches_next_EAX;
`else
        L = `EXE_UNIT_PATH.wb_latches_next_o;
`endif

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
