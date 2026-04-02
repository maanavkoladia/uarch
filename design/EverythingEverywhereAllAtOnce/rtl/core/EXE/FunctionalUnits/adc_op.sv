import common_pkg::*;

module adc_op (
    input  uint64_t srA,
    input  uint64_t srB,
    input  logic    CF_in,       
    input  logic [3:0] data_size, // 0001=AL, 0010=AH, 0011=AX, 0111=EAX
    
    output uint64_t dr_o,
    output uint64_t res_buf_o,
    output logic CF, PF, AF, ZF, SF, OF
);

    logic [31:0] opA, opB;
    logic [32:0] sum;
    logic [4:0]  msb_ptr; // Pointer to the relevant sign bit (7, 15, or 31)
    uint64_t result;

    always_comb begin
        // 1. Structural Operand Selection
        case (data_size)
            4'b0001: begin opA = {24'd0, srA[7:0]};  opB = {24'd0, srB[7:0]};  msb_ptr = 5'd7;  end
            4'b0010: begin opA = {24'd0, srA[15:8]}; opB = {24'd0, srB[15:8]}; msb_ptr = 5'd7;  end
            4'b0011: begin opA = {16'd0, srA[15:0]}; opB = {16'd0, srB[15:0]}; msb_ptr = 5'd15; end
            default: begin opA = srA[31:0];          opB = srB[31:0];          msb_ptr = 5'd31; end
        endcase

        // 2. Single 32-bit Addition (with carry-in)
        sum = opA + opB + {32'd0, CF_in};

        // 3. Result Merging
        result = srA; // Default to original for preservation
        if (data_size == 4'b0010) 
            result[15:8] = sum[7:0]; // AH Case
        else if (data_size == 4'b0111)
            result = {32'd0, sum[31:0]}; // EAX Zero-extension
        else if (data_size == 4'b0011)
            result[15:0] = sum[15:0]; // AX Case
        else
            result[7:0]  = sum[7:0];  // AL Case

        assign dr_o = result;
        assign res_buf_o = result;
        // 4. Flag Logic based on msb_ptr
        CF = sum[msb_ptr + 1];
        SF = sum[msb_ptr];
        ZF = (data_size == 4'b0001 || data_size == 4'b0010) ? (sum[7:0]  == 8'h0) :
             (data_size == 4'b0011)                         ? (sum[15:0] == 16'h0) :
                                                              (sum[31:0] == 32'h0);
        
        PF = ~^sum[7:0]; // Always low 8 bits of the result segment
        AF = (opA[3:0] + opB[3:0] + {3'd0, CF_in}) > 4'hF;
        OF = (opA[msb_ptr] == opB[msb_ptr]) && (opA[msb_ptr] != sum[msb_ptr]);
    end

endmodule
