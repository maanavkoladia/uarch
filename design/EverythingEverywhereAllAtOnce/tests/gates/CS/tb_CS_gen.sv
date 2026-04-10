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
    logic [9 : 0] CS_input;

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
        .REP_o(),
        .MODRM_NEEDED_o(),
        .RM_IS_DR_o(),
        .REG_IS_DR_o(),
        .HARD_CODED_DR_o(),
        .HARD_CODED_DR_ID_4_o(),
        .HARD_CODED_DR_ID_3_o(),
        .HARD_CODED_DR_ID_2_o(),
        .HARD_CODED_DR_ID_1_o(),
        .HARD_CODED_DR_ID_0_o(),
        .HARD_CODED_SR_o(),
        .HARD_CODED_SR_ID_4_o(),
        .HARD_CODED_SR_ID_3_o(),
        .HARD_CODED_SR_ID_2_o(),
        .HARD_CODED_SR_ID_1_o(),
        .HARD_CODED_SR_ID_0_o(),
        .OP_IN_MODRM_o(),
        .DATA_SIZE_2_o(),
        .DATA_SIZE_1_o(),
        .DATA_SIZE_0_o(),
        .HARDCODED_DR_RD_o(),
        .HARDCODED_SR_RD_o(),
        .ST_SEL_o(),
        .alu_inputA_sel_4_o(),
        .alu_inputA_sel_3_o(),
        .alu_inputA_sel_2_o(),
        .alu_inputA_sel_1_o(),
        .alu_inputA_sel_0_o(),
        .alu_inputB_sel_4_o(),
        .alu_inputB_sel_3_o(),
        .alu_inputB_sel_2_o(),
        .alu_inputB_sel_1_o(),
        .alu_inputB_sel_0_o(),
        .branch_target_sel_4_o(),
        .branch_target_sel_3_o(),
        .branch_target_sel_2_o(),
        .branch_target_sel_1_o(),
        .branch_target_sel_0_o(),
        .OP_TYPE_4_o(),
        .OP_TYPE_3_o(),
        .OP_TYPE_2_o(),
        .OP_TYPE_1_o(),
        .OP_TYPE_0_o(),
        .br_uncond_o(),
        .relative_branch_o(),
        .special_dr_o(),
        .is_far_o(),
        .second_flag_needed_o()
    );


    initial begin
        `LOG("Starting ROM tb");
        CS_input = 0;


        DelayClks(20);
        @(posedge clk);
        CS_input = 10;
        DelayClks(20);
        CS_input = 2;
        DelayClks(30);
        `LOG("Done with ROM tb");
        $finish;
    end
    // Test signals

endmodule
