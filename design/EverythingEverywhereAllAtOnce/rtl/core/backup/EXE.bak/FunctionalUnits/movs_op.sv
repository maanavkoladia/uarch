module movs_op(
    input uint64_t srA, //sr, dr
    input uint64_t srB, //buffer
    input [3:0] data_size,
    input curr_df_flag,
    output uint64_t res_buf_o,
    output uint64_t dr_o,
    output uint64_t sr_o
);

    logic [2:0] size;
    always_comb begin
        size = 0;
        case(data_size)
            4'b0010, 4'b0001: size = 3'd1;
            4'b0011: size = 3'd2;
            4'b0111: size = 3'd4;
        endcase
    end

    assign res_buf_o = srB;
    assign dr_o = curr_df_flag ? srA[31:0]-size : srA[31:0]+size;
    assign sr_o = curr_df_flag ? srA[63:32]-size : srA[63:32]+size;

endmodule