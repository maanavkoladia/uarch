`ifndef TB_UTILS_EXE_PATH
`define TB_UTILS_EXE_PATH


task automatic print_exe_latches();
`ifdef EXE_PURE_STRUCTURAL
    integer i;
    begin
    $fdisplay(`LOG_FD, "[EXE LATCHES]");

`ifdef EXE_UNIT_PATH
    $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h",
              `EXE_UNIT_PATH.latches_valid,
              `EXE_UNIT_PATH.latches_EIP,
              `EXE_UNIT_PATH.latches_NEIP);

    $fdisplay(`LOG_FD, "  dr_id=%0d(0x%016h)  sr_id=%0d(0x%016h)",
              `EXE_UNIT_PATH.latches_dr_id,
              `EXE_UNIT_PATH.latches_dr_data,
              `EXE_UNIT_PATH.latches_sr_id,
              `EXE_UNIT_PATH.latches_sr_data);

    $fdisplay(`LOG_FD, "  CS: OP_TYPE=0x%02h  ST=%0b  data_size_vec=0x%01h",
              `EXE_UNIT_PATH.latches_cs_OP_TYPE,
              `EXE_UNIT_PATH.latches_cs_ST_OP,
              `EXE_UNIT_PATH.latches_data_size_vec);

    $fdisplay(`LOG_FD, "  inputA_sel=0x%02h  inputB_sel=0x%02h  br_tgt_sel=0x%02h",
              `EXE_UNIT_PATH.latches_cs_alu_inputA_sel,
              `EXE_UNIT_PATH.latches_cs_alu_inputB_sel,
              `EXE_UNIT_PATH.latches_cs_branch_target_sel);

    $fdisplay(`LOG_FD,
        "  br_info: v=%0b  eip=0x%08h  xcl=%0b  pred_taken=%0b  spec_tgt=0x%08h",
        `EXE_UNIT_PATH.latches_br_info_valid,
        `EXE_UNIT_PATH.latches_br_info_br_eip,
        `EXE_UNIT_PATH.latches_br_info_br_xcl,
        `EXE_UNIT_PATH.latches_br_info_br_pred_taken,
        `EXE_UNIT_PATH.latches_br_info_speculative_target);

    $fdisplay(`LOG_FD,
        "  ST: xcl=%0b  paddr0=0x%04h  paddr1=0x%04h  MIO=%0b",
        `EXE_UNIT_PATH.latches_ST_XCL,
        `EXE_UNIT_PATH.latches_ST_PADDR_0,
        `EXE_UNIT_PATH.latches_ST_PADDR_1,
        `EXE_UNIT_PATH.latches_MIO);

    $fdisplay(`LOG_FD,
        "  imm64=0x%016h  ld_addy=0x%04h",
        `EXE_UNIT_PATH.latches_imm64,
        `EXE_UNIT_PATH.latches_ld_addy);

    $fdisplay(`LOG_FD,
        "  WB_CS: ST=%0b DR=%0b SR=%0b",
        `EXE_UNIT_PATH.latches_wb_cs_ST_OP,
        `EXE_UNIT_PATH.latches_wb_cs_WB_DR,
        `EXE_UNIT_PATH.latches_wb_cs_WB_SR);

    $fdisplay(`LOG_FD,
        "  FLAGS: AF=%0b CF=%0b DF=%0b OF=%0b PF=%0b SF=%0b ZF=%0b",
        `EXE_UNIT_PATH.af_flag_o,
        `EXE_UNIT_PATH.cf_flag_o,
        `EXE_UNIT_PATH.df_flag_o,
        `EXE_UNIT_PATH.of_flag_o,
        `EXE_UNIT_PATH.pf_flag_o,
        `EXE_UNIT_PATH.sf_flag_o,
        `EXE_UNIT_PATH.zf_flag_o);

    // LD BUFFER (32 bytes, two lines of 16)
    $fwrite(`LOG_FD, "LD_BUF: ");
    for (i = 0; i < 16; i = i + 1) begin
        $fwrite(`LOG_FD, "%02x", `EXE_UNIT_PATH.latches_ld_buf[i*8 +: 8]);
        if (i != 15) $fwrite(`LOG_FD, "_");
    end

    $fwrite(`LOG_FD, "\n         ");

    for (i = 16; i < 32; i = i + 1) begin
        $fwrite(`LOG_FD, "%02x", `EXE_UNIT_PATH.latches_ld_buf[i*8 +: 8]);
        if (i != 31) $fwrite(`LOG_FD, "_");
    end

    $fdisplay(`LOG_FD, "");
`endif
    end
`else
    // SV struct path (EXE_structural.sv / EXE.sv)
    $fdisplay(`LOG_FD, "[EXE LATCHES]");
`ifdef EXE_UNIT_PATH
    begin
        automatic exe_latches_t L = `EXE_UNIT_PATH.latches_i;
        automatic string sel_a, sel_b, sel_br;
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
`endif
endtask


// --- EXE OUTPUTS ---
task automatic print_exe_outputs();
`ifdef EXE_PURE_STRUCTURAL
    begin
    $fdisplay(`LOG_FD, "[EXE OUTS]");

`ifdef EXE_UNIT_PATH
    $fdisplay(`LOG_FD,
        "  valid=%0b  wb_we=%0b  ST_OP=%0b  ST_XCL=%0b  clr_ZF_sb=%0b  ZF=%0b",
        `EXE_UNIT_PATH.outs_valid,
        `EXE_UNIT_PATH.outs_wb_stage_latch_we,
        `EXE_UNIT_PATH.outs_ST_OP,
        `EXE_UNIT_PATH.outs_ST_XCL,
        `EXE_UNIT_PATH.outs_clr_ZF_sb,
        `EXE_UNIT_PATH.outs_ZF);

    $fdisplay(`LOG_FD,
        "  BR_RES: valid=%0b  flush=%0b  farFlush=%0b  mispredict=%0b  taken=%0b",
        `EXE_UNIT_PATH.outs_br_res_valid,
        `EXE_UNIT_PATH.outs_br_res_flush,
        `EXE_UNIT_PATH.outs_br_res_farFlush,
        `EXE_UNIT_PATH.outs_br_res_miss_prediction,
        `EXE_UNIT_PATH.outs_br_res_taken);

    if (`EXE_UNIT_PATH.outs_br_res_valid) begin
        $fdisplay(`LOG_FD,
            "    eip=0x%08h  neip=0x%08h  tgt=0x%08h  xcl=%0b  ucond=%0b  clr_exp=%0b",
            `EXE_UNIT_PATH.outs_br_res_br_eip,
            `EXE_UNIT_PATH.outs_br_res_neip,
            `EXE_UNIT_PATH.outs_br_res_br_target,
            `EXE_UNIT_PATH.outs_br_res_br_XCL,
            `EXE_UNIT_PATH.outs_br_res_br_ucond,
            `EXE_UNIT_PATH.outs_br_res_clr_exp_mode);
    end
`endif
    end
`else
    // SV struct path
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
`endif
endtask


// --- WB NEXT LATCHES (what will be written this cycle) ---
task automatic print_wb_next_latches();
`ifdef EXE_PURE_STRUCTURAL
    integer i;
    begin
    $fdisplay(`LOG_FD, "[WB NEXT LATCHES]");
`ifdef EXE_UNIT_PATH
    $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h",
              `EXE_UNIT_PATH.wb_latches_next_valid,
              `EXE_UNIT_PATH.wb_latches_next_EIP);

    $fdisplay(`LOG_FD, "  dr_id=%0d(0x%016h)  sr_id=%0d(0x%016h)",
              `EXE_UNIT_PATH.wb_latches_next_dr_id,
              `EXE_UNIT_PATH.wb_latches_next_dr_data,
              `EXE_UNIT_PATH.wb_latches_next_sr_id,
              `EXE_UNIT_PATH.wb_latches_next_sr_data);

    $fdisplay(`LOG_FD, "  WB_CS: ST=%0b WB_DR=%0b WB_SR=%0b",
              `EXE_UNIT_PATH.wb_latches_next_cs_ST_OP,
              `EXE_UNIT_PATH.wb_latches_next_cs_WB_DR,
              `EXE_UNIT_PATH.wb_latches_next_cs_WB_SR);

    $fdisplay(`LOG_FD,
        "  ST: xcl=%0b  paddr0=0x%04h  bitvec0=0x%04h  paddr1=0x%04h  bitvec1=0x%04h  MIO=%0b",
        `EXE_UNIT_PATH.wb_latches_next_ST_XCL,
        `EXE_UNIT_PATH.wb_latches_next_ST_PADDR_0,
        `EXE_UNIT_PATH.wb_latches_next_ST_BIT_VEC_0,
        `EXE_UNIT_PATH.wb_latches_next_ST_PADDR_1,
        `EXE_UNIT_PATH.wb_latches_next_ST_BIT_VEC_1,
        `EXE_UNIT_PATH.wb_latches_next_MIO);

    $fwrite(`LOG_FD, "RES_BUF: ");
    for (i = 0; i < 16; i = i + 1) begin
        $fwrite(`LOG_FD, "%02x", `EXE_UNIT_PATH.wb_latches_next_res_buf[i*8 +: 8]);
        if (i != 15) $fwrite(`LOG_FD, "_");
    end
    $fwrite(`LOG_FD, "\n         ");
    for (i = 16; i < 32; i = i + 1) begin
        $fwrite(`LOG_FD, "%02x", `EXE_UNIT_PATH.wb_latches_next_res_buf[i*8 +: 8]);
        if (i != 31) $fwrite(`LOG_FD, "_");
    end
    $fdisplay(`LOG_FD, "");
`endif
    end
`else
    // SV struct path
    $fdisplay(`LOG_FD, "[WB NEXT LATCHES]");
`ifdef EXE_UNIT_PATH
    begin
        automatic wb_latches_t L = `EXE_UNIT_PATH.wb_latches_next_o;

        $fdisplay(`LOG_FD, "  valid=%0b  EIP=0x%08h", L.valid, L.EIP);

        $fdisplay(`LOG_FD, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
                  tb_debug_pkg::get_reg_name(L.dr_id), L.dr_data,
                  tb_debug_pkg::get_reg_name(L.sr_id), L.sr_data);

        $fdisplay(`LOG_FD, "  WB_CS: ST=%0b WB_DR=%0b WB_SR=%0b",
                  L.cs.ST_OP, L.cs.WB_DR, L.cs.WB_SR);

        $fdisplay(`LOG_FD,
            "  ST: xcl=%0b  paddr0=0x%04h  bitvec0=0x%04h  paddr1=0x%04h  bitvec1=0x%04h  MIO=%0b",
            L.ST_XCL, L.ST_PADDR_0, L.ST_BIT_VEC_0, L.ST_PADDR_1, L.ST_BIT_VEC_1, L.MIO);

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
`endif
endtask


//--- Optional wrapper (same pattern as WB) ---
task automatic print_exe_info();
    begin
    #(`CLK_PERIOD-1);
    print_exe_latches();
    print_exe_outputs();
    print_wb_next_latches();
    end
endtask


// --- FLAGS TO SEPARATE DUMP FILE ---
// Pass the EIP and the saved flags_reg captured when exeforwards fired.
task automatic dump_flags(input reg [31:0] eip, input reg [31:0] flags);
    begin
    $fdisplay(`FLAGDUMP_FD, "[FLAG DUMP] EIP=0x%08h", eip);
    $fdisplay(`FLAGDUMP_FD, "  CF=%0b  PF=%0b  AF=%0b  ZF=%0b  SF=%0b  DF=%0b  OF=%0b",
              flags[`CF_IDX],
              flags[`PF_IDX],
              flags[`AF_IDX],
              flags[`ZF_IDX],
              flags[`SF_IDX],
              flags[`DF_IDX],
              flags[`OF_IDX]);
    end
endtask


// --- STORE DUMP TO SEPARATE FILE ---
// Called at posedge when exeforwards && wb_latches_next_cs_ST_OP.
// Reads live WB-next latches: paddr (15-bit), bit vector, and res_buf.
// PORT0 maps to the first 16 bytes of res_buf; PORT1 to the last 16.
// Only bytes whose bit in the vector is set are printed.
task automatic dump_store(input reg [31:0] eip);
    integer i;
    reg [14:0] paddr0, paddr1;
    reg [15:0] bvec0,  bvec1;
    begin
`ifdef EXE_UNIT_PATH
`ifdef EXE_PURE_STRUCTURAL
    paddr0 = `EXE_UNIT_PATH.wb_latches_next_ST_PADDR_0;
    paddr1 = `EXE_UNIT_PATH.wb_latches_next_ST_PADDR_1;
    bvec0  = `EXE_UNIT_PATH.wb_latches_next_ST_BIT_VEC_0;
    bvec1  = `EXE_UNIT_PATH.wb_latches_next_ST_BIT_VEC_1;

    $fdisplay(`STOREDUMP_FD, "[STORE DUMP] EIP=0x%08h  xcl=%0b  MIO=%0b",
              eip,
              `EXE_UNIT_PATH.wb_latches_next_ST_XCL,
              `EXE_UNIT_PATH.wb_latches_next_MIO);

    // --- Port 0 (res_buf bytes 0-15) ---
    if (|bvec0) begin
        $fdisplay(`STOREDUMP_FD, "  PORT0: paddr=0x%04h  bvec=0x%04h", paddr0, bvec0);
        $fwrite(`STOREDUMP_FD, "  DATA:");
        for (i = 0; i < 16; i = i + 1) begin
            if (bvec0[i])
                $fwrite(`STOREDUMP_FD, "  [0x%04h]=0x%02h",
                        ({1'b0, paddr0[14:4], 4'b0} + i),
                        `EXE_UNIT_PATH.wb_latches_next_res_buf[i*8 +: 8]);
        end
        $fdisplay(`STOREDUMP_FD, "");
    end

    // --- Port 1 (res_buf bytes 16-31) ---
    if (|bvec1) begin
        $fdisplay(`STOREDUMP_FD, "  PORT1: paddr=0x%04h  bvec=0x%04h", paddr1, bvec1);
        $fwrite(`STOREDUMP_FD, "  DATA:");
        for (i = 0; i < 16; i = i + 1) begin
            if (bvec1[i])
                $fwrite(`STOREDUMP_FD, "  [0x%04h]=0x%02h",
                        ({1'b0, paddr1[14:4], 4'b0} + i),
                        `EXE_UNIT_PATH.wb_latches_next_res_buf[(16+i)*8 +: 8]);
        end
        $fdisplay(`STOREDUMP_FD, "");
    end
`else
    // SV struct path
    begin
        automatic wb_latches_t L = `EXE_UNIT_PATH.wb_latches_next_o;
        paddr0 = L.ST_PADDR_0;
        paddr1 = L.ST_PADDR_1;
        bvec0  = L.ST_BIT_VEC_0;
        bvec1  = L.ST_BIT_VEC_1;

        $fdisplay(`STOREDUMP_FD, "[STORE DUMP] EIP=0x%08h  xcl=%0b  MIO=%0b",
                  eip, L.ST_XCL, L.MIO);

        // --- Port 0 (res_buf bytes 0-15) ---
        if (|bvec0) begin
            $fdisplay(`STOREDUMP_FD, "  PORT0: paddr=0x%04h  bvec=0x%04h", paddr0, bvec0);
            $fwrite(`STOREDUMP_FD, "  DATA:");
            for (int j = 0; j < 16; j++) begin
                if (bvec0[j])
                    $fwrite(`STOREDUMP_FD, "  [0x%04h]=0x%02h",
                            ({1'b0, paddr0[14:4], 4'b0} + j),
                            L.res_buf[j]);
            end
            $fdisplay(`STOREDUMP_FD, "");
        end

        // --- Port 1 (res_buf bytes 16-31) ---
        if (|bvec1) begin
            $fdisplay(`STOREDUMP_FD, "  PORT1: paddr=0x%04h  bvec=0x%04h", paddr1, bvec1);
            $fwrite(`STOREDUMP_FD, "  DATA:");
            for (int j = 0; j < 16; j++) begin
                if (bvec1[j])
                    $fwrite(`STOREDUMP_FD, "  [0x%04h]=0x%02h",
                            ({1'b0, paddr1[14:4], 4'b0} + j),
                            L.res_buf[16+j]);
            end
            $fdisplay(`STOREDUMP_FD, "");
        end
    end
`endif
`endif
    end
endtask


`endif
