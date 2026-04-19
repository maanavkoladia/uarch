import common_pkg::*;
import control_store_pkg::*;

module alu_input_sel(

    input p_address_t ld_addr_0, //not $ aligned
    input byte_t res_buf[CACHE_LINES_SIZE_B *2],
    input uint64_t imm64,
    input uint64_t sr_data,
    input uint64_t dr_data,
    input uint32_t EAX,
    input uint32_t NEIP,
    input uint32_t EIP,
    input uint32_t flags,
    input source_selector_e alu_inputA_sel,
    input source_selector_e alu_inputB_sel,
    input bool shift_sr_down,
    input bool shift_sr_up,
    
    input source_selector_e br_input_sel,

    output uint64_t srA_64,
    output uint64_t srB_64,
    output uint32_t br_sel
);

    uintCL_t res_buf_out;  // 128 bits
    uint64_t srB;

    logic[$clog2(CACHE_LINES_SIZE_B)-1: 0] res_buf_offset;
    assign res_buf_offset = ld_addr_0[$clog2(CACHE_LINES_SIZE_B)-1: 0];

    always_comb begin
        for (int i = 0; i < 16; i++) begin  // Read 16 bytes (128 bits)
            res_buf_out[i*8 +: 8] = res_buf[res_buf_offset + i];
        end
    end

    //logic to determine srA
    always_comb begin
        case (alu_inputA_sel)
            control_store_pkg::SR_REGISTER:    srA_64 = sr_data;
            control_store_pkg::DR_REGISTER:    srA_64 = dr_data;
            control_store_pkg::IMM64:          srA_64 = imm64;
            control_store_pkg::BUFFER:         srA_64 = res_buf_out[63:0];
            control_store_pkg::NEIP:           srA_64 = {32'd0, NEIP[31:0]};
            control_store_pkg::EIP:            srA_64 = {32'b0, EIP};
            control_store_pkg::SEXT8:          srA_64 = {32'd0, 32'(signed'(imm64[7:0]))};
            control_store_pkg::NO_EXE:         srA_64 = 0;
            control_store_pkg::SEGMENT_NEIP:   srA_64 = {dr_data, NEIP}; 
            control_store_pkg::SEGMENT_EIP:    srA_64 = {dr_data, EIP}; //not sure when this needs to be used
            control_store_pkg::EAX_REG:        srA_64 = {32'd0, EAX}; //cmpxchg
            control_store_pkg::CMPXCHG_SEL:    srA_64 = {sr_data, dr_data}; 
            control_store_pkg::IRETD_SEL:      srA_64 = res_buf_out[96:32];
            control_store_pkg::FLAGS:          srA_64 = {32'd0, flags};
            default:        srA_64 = '0;
        endcase
    end

    //logic for srB
    always_comb begin
        case (alu_inputB_sel)
            control_store_pkg::SR_REGISTER:    srB = sr_data;
            control_store_pkg::DR_REGISTER:    srB = dr_data;
            control_store_pkg::IMM64:          srB = imm64;
            control_store_pkg::BUFFER:         srB = res_buf_out[63:0];
            control_store_pkg::NEIP:           srB = {32'd0, NEIP};
            control_store_pkg::EIP:            srB = {32'b0, EIP};
            control_store_pkg::SEXT8:          srB = {32'd0, 32'(signed'(imm64[7:0]))};
            control_store_pkg::NO_EXE:         srB = 0;
            control_store_pkg::SEGMENT_NEIP:   srB = {NEIP, dr_data}; 
            control_store_pkg::SEGMENT_EIP:    srB = {EIP, dr_data}; //not sure when this needs to be used
            control_store_pkg::EAX_REG:        srB  = {32'd0, EAX}; //send forward EAX
            control_store_pkg::CMPXCHG_SEL:    srB = {sr_data, EAX}; //rm32 r32 on cmpxchg 
            control_store_pkg::IRETD_SEL:      srB = res_buf_out[95:32];
            control_store_pkg::FLAGS:          srB = {32'd0, flags};
            default:        srB = '0;
        endcase
    end



    //ex: add mem ah means
    //means the isntruction has rh in the source register and mem in the dr
    //this means we need to shift down ah.

    //add ah mem means that we are putting mem into ah. this means we need to shift UP mem
    always_comb begin
        srB_64 = srB;
        if(shift_sr_down) srB_64 = {8'd0, srB[63:8]};
        if(shift_sr_up) srB_64 = {srB[56:0], 8'd0};
    end

    //logic for BR  //relative offsets calculated in mem
    always_comb begin
        case (br_input_sel)
            control_store_pkg::SR_REGISTER:   br_sel = sr_data[31:0];
            control_store_pkg::DR_REGISTER:   br_sel = dr_data[31:0];
            control_store_pkg::BUF32      :   br_sel = res_buf_out[31:0];
            control_store_pkg::ZEXT_BUF16 :   br_sel = {16'd0, res_buf_out[15:0]};
            default    :   br_sel = '0;
        endcase
    end




endmodule