`timescale 1ns / 1ps

module tb_CS_gen ();

    localparam int Clk_PERIOD = 10;

    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    `CLK_INIT(Clk_PERIOD);

    logic [9:0] CS_input;
    logic [63:0] out;

    // DUT
    gen uut0 (
        .in_9_i(CS_input[9]),
        .in_8_i(CS_input[8]),
        .in_7_i(CS_input[7]),
        .in_6_i(CS_input[6]),
        .in_5_i(CS_input[5]),
        .in_4_i(CS_input[4]),
        .in_3_i(CS_input[3]),
        .in_2_i(CS_input[2]),
        .in_1_i(CS_input[1]),
        .in_0_i(CS_input[0]),

        // MSB → LSB packing
        .REP_o(out[63]),
        .MODRM_NEEDED_o(out[62]),
        .RM_IS_DR_o(out[61]),
        .REG_IS_DR_o(out[60]),
        .HARD_CODED_DR_o(out[59]),

        .HARD_CODED_DR_ID_4_o(out[58]),
        .HARD_CODED_DR_ID_3_o(out[57]),
        .HARD_CODED_DR_ID_2_o(out[56]),
        .HARD_CODED_DR_ID_1_o(out[55]),
        .HARD_CODED_DR_ID_0_o(out[54]),

        .HARD_CODED_SR_o(out[53]),
        .HARD_CODED_SR_ID_4_o(out[52]),
        .HARD_CODED_SR_ID_3_o(out[51]),
        .HARD_CODED_SR_ID_2_o(out[50]),
        .HARD_CODED_SR_ID_1_o(out[49]),
        .HARD_CODED_SR_ID_0_o(out[48]),

        .OP_IN_MODRM_o(out[47]),

        .DATA_SIZE_2_o(out[46]),
        .DATA_SIZE_1_o(out[45]),
        .DATA_SIZE_0_o(out[44]),

        .HARDCODED_DR_RD_o(out[43]),
        .HARDCODED_SR_RD_o(out[42]),
        .ST_SEL_o(out[41]),

        .alu_inputA_sel_4_o(out[40]),
        .alu_inputA_sel_3_o(out[39]),
        .alu_inputA_sel_2_o(out[38]),
        .alu_inputA_sel_1_o(out[37]),
        .alu_inputA_sel_0_o(out[36]),

        .alu_inputB_sel_4_o(out[35]),
        .alu_inputB_sel_3_o(out[34]),
        .alu_inputB_sel_2_o(out[33]),
        .alu_inputB_sel_1_o(out[32]),
        .alu_inputB_sel_0_o(out[31]),

        .branch_target_sel_4_o(out[30]),
        .branch_target_sel_3_o(out[29]),
        .branch_target_sel_2_o(out[28]),
        .branch_target_sel_1_o(out[27]),
        .branch_target_sel_0_o(out[26]),

        .OP_TYPE_4_o(out[25]),
        .OP_TYPE_3_o(out[24]),
        .OP_TYPE_2_o(out[23]),
        .OP_TYPE_1_o(out[22]),
        .OP_TYPE_0_o(out[21]),

        .br_uncond_o(out[20]),
        .relative_branch_o(out[19]),
        .special_dr_o(out[18]),
        .is_far_o(out[17]),
        .second_flag_needed_o(out[16])
    );

    // ---- Print helper ----
    task automatic print_state();
        $display("%0d,%064b", CS_input, out);
    endtask

    // ---- Test sequence ----
    initial begin
        `LOG("Starting ROM tb");

        CS_input = 0;
        @(posedge clk);
        print_state();

        CS_input = 10;
        @(posedge clk);
        print_state();

        CS_input = 2;
        @(posedge clk);
        print_state();

        DelayClks(10);

        `LOG("Done with ROM tb");
        $finish;
    end

endmodule
