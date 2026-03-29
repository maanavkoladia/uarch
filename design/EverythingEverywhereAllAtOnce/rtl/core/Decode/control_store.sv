module control_store (
    input logic [9:0] total_pf_vector,
    input byte_t opcode,
    input byte_t modrm,
    output bool rep,
    output bool branch,
    output rr_cs_t rr_cs,
    output dc_cs_t dc_cs,
    output mem_cs_t mem_cs,
    output exe_cs_t exe_cs,
    output wb_cs_t wb_cs
);
    wire [63:0] cs_out[2];
    logic [9:0] rom_index = {(total_pf_vector[0] || total_pf_vector[1]), opcode, total_pf_vector[3]};

    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : g_cs_bank

            rom64b32w$ cs0 (.A(rom_index[4:0]), .OE(rom_index[9:5] == i), .DOUT(cs_out[0]));
            rom64b32w$ cs1 (.A(rom_index[4:0]), .OE(rom_index[9:5] == i), .DOUT(cs_out[1]));

            // Initialization per instance
            initial begin
                $readmemb($sformatf("cs_roms/cs%0d_data.txt", i), cs0.mem);
                $readmemb($sformatf("cs_roms/cs%0d_data.txt", i), cs1.mem);
            end

        end
    endgenerate

    assign rep = 1'b1;
    assign branch = 1'b1;           //will have ot implement these
    
    assign rr_cs = '{
        RR_OP       : cs_out[0][0],
        REG_RD      : cs_out[0][1],
        MOD_RM_RD   : cs_out[0][2],
        SIB_NEEDED  : cs_out[0][3],
        DISP_NEEDED : cs_out[0][4],
        WE_REG      : cs_out[0][5],
        WE_MOD_RM   : cs_out[0][6],
        ST_SEL      : cs_out[0][7],
        DR_SEL      : cs_out[0][8],
        LD_OP       : cs_out[0][9],
        ST_OP       : cs_out[0][10],
        datasize    : cs_out[0][11 +: 3]
    };

    assign dc_cs = '{
        DC_OP  : cs_out[0][14],
        LD_OP  : cs_out[0][15],
        ST_OP  : cs_out[0][16],
        MEM_OP : cs_out[0][17]
    };

    assign mem_cs = '{
        MEM_OP : cs_out[0][18],
        ST_OP  : cs_out[0][19],
        LD_OP  : cs_out[0][20]
    };

    assign exe_cs = '{
        EXE_OP              : cs_out[0][21],
        ST_OP               : cs_out[0][22],
        ld_flags            : cs_out[0][23],
        flag_modified_vector: cs_out[0][24 +: 32],
        xchg                : cs_out[0][56],
        DATA_SIZE           : cs_out[0][57 +: 3],
        alu_inputA_sel      : cs_out[0][60 +: 4],

        //start of second rom (horizontal stacking)
        alu_inputB_sel      : cs_out[1][0 +: 4],
        branch_target_sel   : cs_out[1][4 +: 4],
        OP_TYPE             : cs_out[1][8 +: 6],
        cmpxchg             : cs_out[1][14],
        cmovc               : cs_out[1][15],


        clear_df            : cs_out[1][16],
        set_df              : cs_out[1][17],
        br_ucond            : cs_out[1][18],
        relative_branch     : cs_out[1][19],
        special_br          : cs_out[1][20],
        is_far              : cs_out[1][21],
        second_flag_needed  : cs_out[1][22]
    };

    assign wb_cs = '{
        ST_OP : cs_out[1][23],
        WB_DR : cs_out[1][24],
        WB_SR : cs_out[1][25]
    };
endmodule
