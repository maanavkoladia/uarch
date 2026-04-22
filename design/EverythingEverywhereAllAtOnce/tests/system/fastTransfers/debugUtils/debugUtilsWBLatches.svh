`ifndef TB_UTILS_WB_PATH
`define TB_UTILS_WB_PATH

//====================================================
// Always-available debug tasks (no macro-generated tasks)
//====================================================


// --- WB LATCHES ---
task automatic print_wb_latches();
    $fdisplay(`LOG_FD, "[WB LATCHES]");

`ifdef WB_UNIT_PATH
    begin
        automatic wb_latches_t L = `WB_UNIT_PATH.latches_i;

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


// --- WB NEXT LATCHES (what will be written this cycle) ---
task automatic print_wb_next_latches();
    $fdisplay(`LOG_FD, "[WB NEXT LATCHES]");

`ifdef WB_UNIT_PATH
    begin
        automatic wb_latches_t L = `WB_UNIT_PATH.nextLatches_i;

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


// --- WB OUTPUTS ---
task automatic print_wb_outputs();
    $fdisplay(`LOG_FD, "[WB OUTS]");

`ifdef WB_UNIT_PATH
    $fdisplay(`LOG_FD,
        "  (Add WB output signals here as needed)"
    );
    // Add specific WB output signals when they are defined in the WB stage module
`endif

endtask


// --- Optional wrapper ---
task automatic print_wb_info();
    #(`CLK_PERIOD-1);
    print_wb_latches();
    print_wb_next_latches();
    print_wb_outputs();
endtask


`endif
