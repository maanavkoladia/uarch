module RegSB (
    input wire clk, rst,
    input regsb_inputs_t inputs,
    output bool dep_stall
);

    regsb_entry_t ARCH_SCOREBOARD[8];
    regsb_entry_t MMX_SCOREBOARD[8];
    regsb_entry_t SEG_SCOREBOARD[8]; //lowkey don't want to use reg ids, nvm might have to
    //nv, maybe not since just use segnment0/1 id since if needed here we will wait. 
    //write back will send clear signal in dr0_id, must be able to clear segreg through that



    always_ff @(posedge clk) begin
        //setting scoreboards
        //nned to check and block only if ids match, otherwise should still go through
        //just wanna check compilation rn have to fix this later
        if(inputs.cs_reg_wr && !inputs.wb_dr0_we && !inputs.wb_dr1_we) begin
            unique case(inputs.reg_id[4:3])
                2'b00, 2'b01, 2'b10: begin
                    ARCH_SCOREBOARD[inputs.reg_id[2:0]].counter <=
                        ARCH_SCOREBOARD[inputs.reg_id[2:0]].counter + 1;
                end
                2'b11: begin
                    MMX_SCOREBOARD[inputs.reg_id[2:0]].counter <=
                        MMX_SCOREBOARD[inputs.reg_id[2:0]].counter+1;
                end
            endcase
        end

        if(inputs.cs_modrm_reg_wr && !inputs.wb_dr0_we && !inputs.wb_dr1_we) begin
            unique case(inputs.modrm_id[4:3])
                2'b00, 2'b01, 2'b10: begin
                    ARCH_SCOREBOARD[inputs.modrm_id[2:0]].counter <=
                        ARCH_SCOREBOARD[inputs.modrm_id[2:0]].counter + 1;
                end
                2'b11: begin
                    MMX_SCOREBOARD[inputs.modrm_id[2:0]].counter <=
                        MMX_SCOREBOARD[inputs.modrm_id[2:0]].counter+1;
                end
            endcase
        end

        //for clearning, will def need to consolidate multiple driver issue
        if(inputs.wb_dr0_we && !inputs.cs_modrm_reg_wr && !inputs.cs_reg_wr) begin
            unique case(inputs.wb_dr0_id[4:3])
                2'b00, 2'b01, 2'b10: begin
                    ARCH_SCOREBOARD[inputs.wb_dr0_id[2:0]].counter <=
                        ARCH_SCOREBOARD[inputs.wb_dr0_id[2:0]].counter - 1;
                end
                2'b11: begin
                    MMX_SCOREBOARD[inputs.wb_dr0_id[2:0]].counter <=
                        MMX_SCOREBOARD[inputs.wb_dr0_id[2:0]].counter-1;
                end
            endcase
        end

        if(inputs.wb_dr1_we && !inputs.cs_modrm_reg_wr && !inputs.cs_reg_wr) begin
            unique case(inputs.wb_dr1_id[4:3])
                2'b00, 2'b01, 2'b10: begin
                    ARCH_SCOREBOARD[inputs.wb_dr1_id[2:0]].counter <=
                        ARCH_SCOREBOARD[inputs.wb_dr1_id[2:0]].counter - 1;
                end
                2'b11: begin
                    MMX_SCOREBOARD[inputs.wb_dr1_id[2:0]].counter <=
                        MMX_SCOREBOARD[inputs.wb_dr1_id[2:0]].counter-1;
                end
            endcase
        end
    end

    always_comb begin
        if(inputs.cs_reg_rd) begin
            unique case(inputs.reg_id[4:3])
                2'b00, 2'b01, 2'b10: begin
                    if(ARCH_SCOREBOARD[inputs.reg_id[2:0]].counter != 0) begin
                        dep_stall = 1'b1;
                    end
                    else begin
                        dep_stall = 1'b0;
                    end
                end
                2'b11: begin
                    if(MMX_SCOREBOARD[inputs.reg_id[2:0]].counter != 0) begin
                        dep_stall = 1'b1;
                    end
                    else begin
                        dep_stall = 1'b0;
                    end
                end
            endcase
        end

        if(inputs.cs_modrm_rd) begin
            unique case(inputs.modrm_id[4:3])
                2'b00, 2'b01, 2'b10: begin
                    if(ARCH_SCOREBOARD[inputs.modrm_id[2:0]].counter != 0) begin
                        dep_stall = 1'b1;
                    end
                    else begin
                        dep_stall = 1'b0;
                    end
                end
                2'b11: begin
                    if(MMX_SCOREBOARD[inputs.modrm_id[2:0]].counter != 0) begin
                        dep_stall = 1'b1;
                    end
                    else begin
                        dep_stall = 1'b0;
                    end
                end
            endcase
        end

        if(inputs.cs_sib_size) begin
            unique case(inputs.sib_base_id[4:3])
                2'b00, 2'b01, 2'b10: begin
                    if(ARCH_SCOREBOARD[inputs.sib_base_id[2:0]].counter != 0) begin
                        dep_stall = 1'b1;
                    end
                    else begin
                        dep_stall = 1'b0;
                    end
                end
                2'b11: begin
                    if(MMX_SCOREBOARD[inputs.sib_base_id[2:0]].counter != 0) begin
                        dep_stall = 1'b1;
                    end
                    else begin
                        dep_stall = 1'b0;
                    end
                end
            endcase
        end

        if(inputs.cs_sib_size) begin
            unique case(inputs.sib_idx_id[4:3])
                2'b00, 2'b01, 2'b10: begin
                    if(ARCH_SCOREBOARD[inputs.sib_idx_id[2:0]].counter != 0) begin
                        dep_stall = 1'b1;
                    end
                    else begin
                        dep_stall = 1'b0;
                    end
                end
                2'b11: begin
                    if(MMX_SCOREBOARD[inputs.sib_idx_id[2:0]].counter != 0) begin
                        dep_stall = 1'b1;
                    end
                    else begin
                        dep_stall = 1'b0;
                    end
                end
            endcase
        end
    end
endmodule
