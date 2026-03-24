module ppu (
    input [7:0] opcode_byte, mod_byte, 
    input [9:0] total_pf_vector,
    input [2:0] num_pfs_plusone,
    output [3:0] inst_length,
    output[2:0] msd_size, imm_size,
    output needrm
);

    wire [2:0] imm_size_fake, msd_size_fake;

    wire [4:0] extended_instru_len;
    assign inst_length = extended_instru_len[3:0];

    op_size opcode_size(opcode_byte, needrm, imm_size_fake);

    modrm_size mod_size(mod_byte, msd_size_fake);

    mux2_3 immmux(.in0(imm_size_fake), .in1(3'b010), .sel(total_pf_vector[5]), .out(imm_size));
    mux2_3 msdmux(.in0(3'b000), .in1(msd_size_fake), .sel(needrm), .out(msd_size));

    triple_adder adder0 (.in0(msd_size), .in1(imm_size), .in2(num_pfs_plusone), .result(extended_instru_len));

    
endmodule
