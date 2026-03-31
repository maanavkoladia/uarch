module cmpxchg_op(
    input  uint64_t lock_i,        // Accumulator (AL/AX/EAX)
    input  uint64_t new_lock_i,    // Source (r32)
    input  uint64_t compare_val_i, // Destination (r/m)
    input  logic [1:0] data_size,  // 00=8b, 01=16b, 10=32b
    output uint64_t lock_result_o, 
    output uint64_t acc_result_o,  
    output bool ZF,
    output bool SF,
    output bool PF,
    output bool CF,
    output bool OF,
    output bool AF
);

    logic [32:0] sub_res;
    logic [31:0] opA, opB;

    always_comb begin
        // Internal operands for flag calculation
        opA = lock_i[31:0];
        opB = compare_val_i[31:0];
        
        // Single subtraction to derive flags (A - B)
        sub_res = {1'b0, opA} - {1'b0, opB};

        // AF is the borrow from bit 3 to bit 4
        AF = (opA[4] ^ opB[4]) ^ sub_res[4];
        // PF is based on the low 8 bits of the subtraction result
        PF = ~^sub_res[7:0];

        case (data_size)
            2'b00: begin // 8-bit
                ZF = (opA[7:0] == opB[7:0]);
                SF = sub_res[7];
                CF = (opA[7:0] < opB[7:0]);
                OF = (opA[7] ^ opB[7]) & (opA[7] ^ sub_res[7]);
                
                if (ZF) begin
                    lock_result_o = {compare_val_i[63:8], new_lock_i[7:0]};
                    acc_result_o  = lock_i;
                end else begin
                    lock_result_o = compare_val_i;
                    acc_result_o  = {lock_i[63:8], compare_val_i[7:0]};
                end
            end

            2'b01: begin // 16-bit
                ZF = (opA[15:0] == opB[15:0]);
                SF = sub_res[15];
                CF = (opA[15:0] < opB[15:0]);
                OF = (opA[15] ^ opB[15]) & (opA[15] ^ sub_res[15]);

                if (ZF) begin
                    lock_result_o = {compare_val_i[63:16], new_lock_i[15:0]};
                    acc_result_o  = lock_i;
                end else begin
                    lock_result_o = compare_val_i;
                    acc_result_o  = {lock_i[63:16], compare_val_i[15:0]};
                end
            end

            default: begin // 32-bit (10)
                ZF = (opA[31:0] == opB[31:0]);
                SF = sub_res[31];
                CF = sub_res[32];
                OF = (opA[31] ^ opB[31]) & (opA[31] ^ sub_res[31]);

                if (ZF) begin
                    lock_result_o = {compare_val_i[63:32], new_lock_i[31:0]};
                    acc_result_o  = lock_i;
                end else begin
                    lock_result_o = compare_val_i;
                    acc_result_o  = {lock_i[63:32], compare_val_i[31:0]};
                end
            end
        endcase
    end
endmodule
