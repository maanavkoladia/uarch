module predecode(
    input [63:0][7:0] queue,
    input clk, rst,
    output reg [31:0] EIP,
    output [3:0] inst_length
);

    initial begin
        EIP = 32'b0;
    end
    wire [15:0][7:0] IRbyte; //16 different IR bytes
    wire [3:0][3:0] ppu_inst_length;
    wire [4:0][2:0] ppu_imm_size, ppu_msd_size;
    wire [3:0] ppu_needrm;
    wire [1:0] num_pfs;
    wire [9:0] pf_vector0, pf_vector1, pf_vector2, total_pf_vector;
    wire [15:0] eip_bar_top, eip_bar_bottom;
    wire [8:0] carry;
    wire [31:0] sext_inst_length, NEIP;
    wire inst_length_cout;

    assign carry[0] = 1'b0;
    assign sext_inst_length = {28'b0, inst_length};

    selection_logic sel_log1(.queue(queue), .EIP(EIP), .IRbyte(IRbyte));

    ppu pfs0(.opcode_byte(IRbyte[0]), .mod_byte(IRbyte[1]), .total_pf_vector(total_pf_vector), .num_pfs_plusone(3'b001), 
        .inst_length(ppu_inst_length[0]), .msd_size(ppu_msd_size[0]), .imm_size(ppu_imm_size[0]), .needrm(ppu_needrm[0]));
    ppu pfs1(.opcode_byte(IRbyte[1]), .mod_byte(IRbyte[2]), .total_pf_vector(total_pf_vector), .num_pfs_plusone(3'b010), 
        .inst_length(ppu_inst_length[1]), .msd_size(ppu_msd_size[1]), .imm_size(ppu_imm_size[1]), .needrm(ppu_needrm[1]));
    ppu pfs2(.opcode_byte(IRbyte[2]), .mod_byte(IRbyte[3]), .total_pf_vector(total_pf_vector), .num_pfs_plusone(3'b011), 
        .inst_length(ppu_inst_length[2]), .msd_size(ppu_msd_size[2]), .imm_size(ppu_imm_size[2]), .needrm(ppu_needrm[2]));
    ppu pfs3(.opcode_byte(IRbyte[3]), .mod_byte(IRbyte[4]), .total_pf_vector(total_pf_vector), .num_pfs_plusone(3'b100), 
        .inst_length(ppu_inst_length[3]), .msd_size(ppu_msd_size[3]), .imm_size(ppu_imm_size[3]), .needrm(ppu_needrm[3]));

    mux4_4 length_mux(.in0(ppu_inst_length[0]), .in1(ppu_inst_length[1]), .in2(ppu_inst_length[2]), .in3(ppu_inst_length[3]), 
        .sel0(num_pfs[0]), .sel1(num_pfs[1]), .out(inst_length));


    pf_checker checker0(.IRbyte(IRbyte[0]), .pf(pf0), .pf_vector(pf_vector0));
    pf_checker checker1(.IRbyte(IRbyte[1]), .pf(pf1), .pf_vector(pf_vector1));
    pf_checker checker2(.IRbyte(IRbyte[2]), .pf(pf2), .pf_vector(pf_vector2));
    num_pf_gen num_pf_gen0(pf0, pf1 ,pf2, num_pfs);
    pf_vector_gen vec_gen(.pfs(num_pfs), .pf_vector0(pf_vector0), .pf_vector1(pf_vector1), .pf_vector2(pf_vector2), 
        .total_pf_vector(total_pf_vector));

    kogge_stone_adder #(.WIDTH(32)) neip_adder (.a(EIP), .b(sext_inst_length), .cin(1'b0), .sum(NEIP), .cout(inst_length_cout));

    //dff16$ topword(clk, NEIP[31:16], EIP[31:16], eip_bar_top, rst, 1'b1);
    //dff16$ bottomword(clk, NEIP[15:0], EIP[15:0], eip_bar_bottom, rst, 1'b1);
endmodule
