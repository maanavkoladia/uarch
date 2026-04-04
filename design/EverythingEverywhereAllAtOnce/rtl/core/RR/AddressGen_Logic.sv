module AddressGen_Logic (
    input uint32_t register_data,
    input uint32_t SIB_IDX_data,
    input uint32_t SIB_BASE_data,
    input uint8_t SIB_SCALE_val,
    input bool sib_needed,
    input bool disp_needed,
    input bool dispsize,
    input uint32_t displacement,

    output l_address_t AddrGen_out
);

    uint32_t adder_input1, adder_input2;
    bool cout;

    always_comb begin
        case({sib_needed, disp_needed})
            2'b00: begin
                adder_input2 = register_data;
            end
            2'b01: begin
                adder_input2 = 32'b0;
            end
            2'b10: begin
                adder_input2 = (SIB_IDX_data << SIB_SCALE_val) + SIB_BASE_data;
            end
            2'b11: begin
                adder_input2 = (SIB_IDX_data << SIB_SCALE_val) + SIB_BASE_data;
            end
        endcase

        case({disp_needed, dispsize})
            2'b00: begin
                adder_input1 = 32'b0;
            end
            2'b01: begin
                adder_input1 = 32'b0;
            end
            2'b10: begin
                adder_input1 = {24'b0, displacement[7:0]};
            end
            2'b11: begin
                adder_input1 = displacement;
            end
        endcase
    end

    kogge_stone_adder #(.WIDTH(32)) AddressGen_adder (.a(adder_input1),
        .b(adder_input2), .cin(1'b0), .sum(AddrGen_out), .cout(cout));

endmodule
