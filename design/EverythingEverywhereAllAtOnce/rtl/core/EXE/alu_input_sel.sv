module alu_input_sel(

    input p_address_t ld_addr_0, //not $ aligned
    input byte_t res_buf[CACHE_LINES_SIZE_B *2],
    input uint64_t imm64,
    input uint64_t sr_data,
    input uint64_t dr_data,
    input uint32_t EAX,
    input uint32_t NEIP,
    input uin32_t EIP,
    input source_selector_e alu_inputA_sel,
    input source_selector_e alu_inputB_sel,
    
    input source_selector_e br_input_sel,


    //
    output uint64_t srA_64;
    output uint64_t srB_64;

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
            SR_REGISTER:    srA_64 = sr_data;
            DR_REGISTER:    srA_64 = dr_data;
            IMM64:          srA_64 = imm64;
            BUFFER:         srA_64 = res_buf_out[63:0];
            SEGMENT:        srA_64 = {32'd0, segment};
            NEIP:           srA_64 = {32'd0, NEIP};
            EIP:            srA_64 = {32'b0, EIP};
            SEXT8:          srA_64 = {32'd0, 32'(signed'(imm64[7:0]))};
            NOP:            srA_64 = 0;
            SEGMENT_NEIP:   srA_64 = {NEIP, segment}; 
            SEGMENT_EIP:    srA_64 = {EIP, segment}; //not sure when this needs to be used
            EAX:            srA    = {32'd0, EAX}; //cmpxchg
            CMPXCHG:        srA_64 = {sr_data, dr_data}; 
            default:        $fatal
        endcase
    end

    //logic for srB
    always_comb begin
        unique case (alu_inputB_sel)
            SR_REGISTER:    srAB_64 = sr_data;
            DR_REGISTER:    srAB_64 = dr_data;
            IMM64:          srAB_64 = imm64;
            BUFFER:         srAB_64 = res_buf_out[63:0];
            NEIP:           srAB_64 = {32'd0, NEIP};
            EIP:            srAB_64 = {32'b0, EIP};
            SEXT8:          srAB_64 = {32'd0, 32'(signed'(imm64[7:0]))};
            NOP:            srAB_64 = 0;
            SEGMENT_NEIP:   srAB_64 = {NEIP, segment}; 
            SEGMENT_EIP:    srAB_64 = {EIP, segment}; //not sure when this needs to be used
            EAX:            srAB    = {32'd0, EAX}; //send forward EAX
            CMPXCHG:        srAB_64 = {sr_data, dr_data}; //rm32 r32 on cmpxchg 
            default:        $fatal
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
            ZEXT_BUF16 : br_sel = {16'd0, res_buf_out[15:0]};
        endcase
    end




endmodule