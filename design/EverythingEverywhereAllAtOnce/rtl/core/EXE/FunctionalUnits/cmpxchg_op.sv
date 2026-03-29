module cmpxchg_op(
    input  uint64_t lock_i,        // Current lock value (e.g., AL/AX/EAX)
    input  uint64_t new_lock_i,    // New value to store if compare matches (r32)
    input  uint64_t compare_val_i, // Value to compare against (r/m operand)
    input  logic [1:0] data_size,     // 00=8b, 01=16b, 10=32b
    output uint64_t lock_result_o, // Final value for memory/register write
    output uint64_t acc_result_o,  // New accumulator value
    output uint64_t cmp_result_o,  // New r/m value
    output bool zf_o
);

    //when we wire this up we will just wire src_val = alu_input_sel.srA[63:31]
    //gemini finished off the sizing and then commented everyting

    // Intermediate match signals for easy structural mapping
    logic match8, match16, match32;
    
    assign match8  = (lock_i[7:0]   == compare_val_i[7:0]);
    assign match16 = (lock_i[15:8]  == compare_val_i[15:8])  && match8;
    assign match32 = (lock_i[31:16] == compare_val_i[31:16]) && match16;

    always_comb begin
        // Default assignments to prevent latches
        zf_o          = 1'b0;
        acc_result_o  = lock_i;
        cmp_result_o  = compare_val_i;
        lock_result_o = compare_val_i;

        case (data_size)
            2'b00: begin // 8-bit
                zf_o = match8;
                if (match8) begin
                    cmp_result_o[7:0] = new_lock_i[7:0];
                    acc_result_o      = lock_i; // Accumulator stays same
                end else begin
                    acc_result_o[7:0] = compare_val_i[7:0]; // Load dest into accumulator
                    cmp_result_o      = compare_val_i;
                end
            end

            2'b01: begin // 16-bit
                zf_o = match16;
                if (match16) begin
                    cmp_result_o[15:0] = new_lock_i[15:0];
                    acc_result_o       = lock_i;
                end else begin
                    acc_result_o[15:0] = compare_val_i[15:0];
                    cmp_result_o       = compare_val_i;
                end
            end

            2'b10: begin // 32-bit
                zf_o = match32;
                if (match32) begin
                    cmp_result_o[31:0] = new_lock_i[31:0];
                    acc_result_o       = lock_i;
                end else begin
                    acc_result_o[31:0] = compare_val_i[31:0];
                    cmp_result_o       = compare_val_i;
                end
            end
            
            default: ; 
        endcase
        
        // lock_result_o is the final value destined for the "destination" (compare_val_i's location)
        lock_result_o = cmp_result_o;
    end

endmodule
