module alu_input_sel(

    input p_address_t ld_addr_0, //not $ aligned
    input byte_t res_buf[CACHE_LINES_SIZE_B *2],
    input uint64_t imm64,
    input uint64_t sr_data,
    input uint64_t dr_data,
    input uint32_t segment,
    input uint32_t NEIP,
    input source_selector_e alu_inputA_sel,
    input source_selector_e alu_inputB_sel,
    input source_selector_e br_input_sel,
    input logic[1:0] data_size,


    //seems weird but I think it will be easier than to mask out everything properly. Best to do it all just here
    //This right now is basically just for Return from interrupt. As of right now we are not making that a rom even tho we probably could 
    output uintCL_t srA_128;
    output uintCL_t srB_128;

    output uint64_t srA_64;
    output uint64_t srB_64;

    output uint32_t srA_32;
    output uint32_t srB_32;

    output uint16_t srA_16;
    output uint16_t srB_16;

    output uint8_t srA_8;
    output uint8_t srB_8;

    output uint32_t br_sel;

);

    uintCL_t res_buf_out;  // 128 bits

    logic[$clog2(CACHE_LINES_SIZE_B)-1: 0] res_buf_offset; 
    assign res_buf_offset = ld_addr_0[$clog2(CACHE_LINES_SIZE_B)-1: 0];

    always_comb begin
        for (int i = 0; i < 16; i++) begin  // Read 16 bytes (128 bits)
            res_buf_out[i*8 +: 8] = res_buf[res_buf_offset + i];
        end
    end

    //logic to determine srA
    always_comb begin
        unique case (alu_inputA_sel)
            SR_REGISTER:  srA_128 = {64'd0, sr_data};
            DR_REGISTER:  srA_128 = {64'd0, dr_data};
            IMM64        :  srA_128 = {64'd0, imm64};
            BUFFER     :  srA_128 = res_buf_out;
            SEGMENT    :  srA_128 = {96'd0, segment};
            NEIP       :  srA_128 = {96'd0, NEIP};
            SEXT8      :  srA_128 = {64'd0, 64'(signed'(imm64[7:0]))};
            NOP        :  srA_128 = '0;
            SEGMENT_NEIP: srA_128 = {64'd0, 12'd0, NEIP, segment};
            default    :  srA_128 = '0;
        endcase
    end

    //logic for srB
    always_comb begin
        unique case (alu_inputB_sel)
            SR_REGISTER:  srB_128 = {64'd0, sr_data};
            DR_REGISTER:  srB_128 = {64'd0, dr_data};
            IMM64        :  srB_128 = {64'd0, imm64};
            BUFFER     :  srB_128 = res_buf_out;
            NEIP       :  srB_128 = {96'd0, NEIP};
            SEGMENT    :  srB_128 = {96'd0, segment};
            SEXT8      :  srB_128 = {64'd0, 64'(signed'(imm64[7:0]))};
            NOP        :  srB_128 = '0;
            SEGMENT_NEIP: srB_128 = {64'd0, NEIP, segment};
            default    :  srB_128 = '0;
        endcase
    end


    //logic for BR 
    always_comb begin
        unique case (br_input_sel)
            SR_REGISTER: br_sel = sr_data[31:0];
            DR_REGISTER: br_sel = dr_data[31:0];
            IMM32        : br_sel = imm64[31:0];
            ZEXT_IMM16   : br_sel = {16'd0, imm64[16:0]};
            ZEXT_IMM8    : br_sel = {24'd0, imm64[7:0]};

            //stack grows toward lower mem addresses. EIP always pushed last so its at lowest address always bottom 32 bits 
            BUF32     : br_sel = res_buf_out[31:0]; 
            ZEX_BUF16 : br_sel = {16'd0, res_buf_out[15:0]};
        endcase
    end

    //outputs - mask down from 128-bit
    assign srA_64 = srA_128[63:0];
    assign srA_32 = srA_128[31:0];
    assign srA_16 = srA_128[15:0];
    assign srA_8  = srA_128[7:0];

    assign srB_64 = srB_128[63:0];
    assign srB_32 = srB_128[31:0];
    assign srB_16 = srB_128[15:0];
    assign srB_8  = srB_128[7:0];



endmodule