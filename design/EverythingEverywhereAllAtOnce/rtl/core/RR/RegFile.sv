import RegisterRead_pkg::*;
import reg_ids_pkg::*;

module RegFile (
    input clk, rst,
    input regfile_input_t inputs,
    output regfile_output_t outputs
);

    uint32_t ARCH_REGISTERS [8];
    uint64_t MMX_REGISTERS [8];
    uint32_t SEG_REG [8];

    assign outputs.SIB_IDX_data = ARCH_REGISTERS[inputs.SIB_IDX_ID[2:0]];
    assign outputs.SIB_BASE_data = ARCH_REGISTERS[inputs.SIB_BASE_ID[2:0]];
    assign outputs.ECX_data = ARCH_REGISTERS[ECX[2:0]];
    assign outputs.CS_data = SEG_REG[CS[2:0]];
    assign outputs.Segment0_data = SEG_REG[inputs.Segment0_ID[2:0]];
    assign outputs.Segment1_data = SEG_REG[inputs.Segment1_ID[2:0]];

    always_comb begin
        //MODRM out
        unique case (inputs.MODRM_ID[4:3])
            2'b00: begin    //byte
                if(inputs.MODRM_ID[2] == 0) begin
                    outputs.MODRM_data = ARCH_REGISTERS[inputs.MODRM_ID[2:0]] & 64'h0000_000F;
                end
                else begin  //for AH BH etc
                    outputs.MODRM_data =
                        ARCH_REGISTERS[{1'b0, inputs.MODRM_ID[1:0]}] & 64'h0000_00F0;
                end
            end
            2'b01: begin    //word
                outputs.MODRM_data = ARCH_REGISTERS[inputs.MODRM_ID[2:0]] & 64'h0000_00FF;
            end
            2'b10: begin    //doubleword
                outputs.MODRM_data = ARCH_REGISTERS[inputs.MODRM_ID[2:0]] & 64'h0000_FFFF;
            end
            2'b11: begin    //quadword
                outputs.MODRM_data = MMX_REGISTERS[inputs.MODRM_ID[2:0]];
            end
        endcase

        //REG out
        unique case (inputs.REG_ID[4:3])
            2'b00: begin    //byte
                outputs.REG_data = ARCH_REGISTERS[inputs.REG_ID[2:0]] & 64'h0000_000F;
            end
            2'b01: begin    //word
                outputs.REG_data = ARCH_REGISTERS[inputs.REG_ID[2:0]] & 64'h0000_00FF;
            end
            2'b10: begin    //doubleword
                outputs.REG_data = ARCH_REGISTERS[inputs.REG_ID[2:0]] & 64'h0000_FFFF;
            end
            2'b11: begin    //quadword
                outputs.REG_data = MMX_REGISTERS[inputs.REG_ID[2:0]];
            end
        endcase

        //REG out
        unique case (inputs.REG_ID[4:3])
            2'b00: begin    //byte
                if(inputs.REG_ID[2] == 0) begin
                    outputs.REG_data = ARCH_REGISTERS[inputs.REG_ID[2:0]] & 64'h0000_000F;
                end
                else begin  //for AH BH etc
                    outputs.REG_data = ARCH_REGISTERS[{1'b0, inputs.REG_ID[1:0]}] & 64'h0000_00F0;
                end            end
            2'b01: begin    //word
                outputs.REG_data = ARCH_REGISTERS[inputs.REG_ID[2:0]] & 64'h0000_00FF;
            end
            2'b10: begin    //doubleword
                outputs.REG_data = ARCH_REGISTERS[inputs.REG_ID[2:0]] & 64'h0000_FFFF;
            end
            2'b11: begin    //quadword
                outputs.REG_data = MMX_REGISTERS[inputs.REG_ID[2:0]];
            end
        endcase
    end

    always_ff @(posedge clk ) begin
        if (inputs.DR0_we) begin
            if(inputs.DR0_ID[5]) begin
                SEG_REG[inputs.DR0_ID[2:0]] <= inputs.DR0_data;
            end
            else begin
                unique case(inputs.DR0_ID[4:3])
                    2'b00: begin
                        if(inputs.DR0_ID[2] == 0) begin
                            ARCH_REGISTERS[inputs.DR0_ID[2:0]]
                                <= {ARCH_REGISTERS[inputs.DR0_ID[2:0]][31:8], inputs.DR0_data[7:0]};
                        end
                        else begin
                            ARCH_REGISTERS[{1'b0, inputs.DR0_ID[1:0]}]
                                <= {ARCH_REGISTERS[inputs.DR0_ID[2:0]][31:16], inputs.DR0_data[7:0],
                                    ARCH_REGISTERS[inputs.DR0_ID[2:0]][7:0]};
                        end
                    end
                    2'b01: begin
                        ARCH_REGISTERS[inputs.DR0_ID[2:0]]
                            <= {ARCH_REGISTERS[inputs.DR0_ID[2:0]][31:16], inputs.DR0_data[15:0]};
                    end
                    2'b10: begin
                        ARCH_REGISTERS[inputs.DR0_ID[2:0]] <= inputs.DR0_data[31:0];
                    end
                    2'b11: begin
                        MMX_REGISTERS[inputs.DR0_ID[2:0]] <= inputs.DR0_data;
                    end
                endcase
            end
        end
        else begin

        end

        if (inputs.DR1_we) begin
            if(inputs.DR1_ID[5]) begin
                SEG_REG[inputs.DR1_ID[2:0]] <= inputs.DR1_data;
            end
            else begin
                unique case(inputs.DR1_ID[4:3])
                    2'b00: begin
                        if(inputs.DR1_ID[2] == 0) begin
                            ARCH_REGISTERS[inputs.DR1_ID[2:0]]
                                <= {ARCH_REGISTERS[inputs.DR1_ID[2:0]][31:8], inputs.DR1_data[7:0]};
                        end
                        else begin
                            ARCH_REGISTERS[{1'b0, inputs.DR1_ID[1:0]}]
                                <= {ARCH_REGISTERS[inputs.DR1_ID[2:0]][31:16], inputs.DR1_data[7:0],
                                    ARCH_REGISTERS[inputs.DR1_ID[2:0]][7:0]};
                        end
                    end
                    2'b01: begin
                        ARCH_REGISTERS[inputs.DR1_ID[2:0]]
                            <= {ARCH_REGISTERS[inputs.DR1_ID[2:0]][31:16], inputs.DR1_data[15:0]};
                    end
                    2'b10: begin
                        ARCH_REGISTERS[inputs.DR1_ID[2:0]] <= inputs.DR1_data[31:0];
                    end
                    2'b11: begin
                        MMX_REGISTERS[inputs.DR1_ID[2:0]] <= inputs.DR1_data;
                    end
                endcase
            end
        end
        else begin

        end
    end

endmodule
