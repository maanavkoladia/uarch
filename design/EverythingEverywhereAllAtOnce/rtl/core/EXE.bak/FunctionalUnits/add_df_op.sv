module add_df_op(
    input  uint64_t srA,
    input  uint64_t srB,
    input  [3:0] data_size,
    input  bool curr_df_flag,
    output uint64_t dr_o,
    output uint64_t sr_o
);

    logic [2:0] size;

    always_comb begin
        size = 0;
        case (data_size)
            4'b0010, 4'b0001: size = 3'd1;
            4'b0011:          size = 3'd2;
            4'b0111:          size = 3'd4;
        endcase
    end

    assign dr_o = curr_df_flag ? srA - size : srA + size;
    assign sr_o = curr_df_flag ? srB - size : srB + size;

endmodule