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
    assign outputs.EAX_data = ARCH_REGISTERS[EAX[2:0]];
    assign outputs.CS_data = SEG_REG[CS[2:0]];
    assign outputs.Segment0_data = SEG_REG[inputs.Segment0_ID[2:0]];
    assign outputs.Segment1_data = SEG_REG[inputs.Segment1_ID[2:0]];

    always_comb begin
        //MODRM out
        case (inputs.DR_ID[4:3])
            2'b00: begin    //byte
                if(inputs.DR_ID[2] == 0) begin
                    outputs.DR_data = ARCH_REGISTERS[inputs.DR_ID[2:0]] & 64'h0000_000F;
                end
                else begin  //for AH BH etc
                    outputs.DR_data =
                        ARCH_REGISTERS[{1'b0, inputs.DR_ID[1:0]}] & 64'h0000_00F0;
                end
            end
            2'b01: begin    //word
                outputs.DR_data = ARCH_REGISTERS[inputs.DR_ID[2:0]] & 64'h0000_00FF;
            end
            2'b10: begin    //doubleword
                outputs.DR_data = ARCH_REGISTERS[inputs.DR_ID[2:0]] & 64'h0000_FFFF;
            end
            2'b11: begin    //quadword
                outputs.DR_data = MMX_REGISTERS[inputs.DR_ID[2:0]];
            end
        endcase

        //REG out
        case (inputs.SR_ID[4:3])
            2'b00: begin    //byte
                outputs.SR_data = ARCH_REGISTERS[inputs.SR_ID[2:0]] & 64'h0000_000F;
            end
            2'b01: begin    //word
                outputs.SR_data = ARCH_REGISTERS[inputs.SR_ID[2:0]] & 64'h0000_00FF;
            end
            2'b10: begin    //doubleword
                outputs.SR_data = ARCH_REGISTERS[inputs.SR_ID[2:0]] & 64'h0000_FFFF;
            end
            2'b11: begin    //quadword
                outputs.SR_data = MMX_REGISTERS[inputs.SR_ID[2:0]];
            end
        endcase

        //REG out
        case (inputs.SR_ID[4:3])
            2'b00: begin    //byte
                if(inputs.SR_ID[2] == 0) begin
                    outputs.SR_data = ARCH_REGISTERS[inputs.SR_ID[2:0]] & 64'h0000_000F;
                end
                else begin  //for AH BH etc
                    outputs.SR_data = ARCH_REGISTERS[{1'b0, inputs.SR_ID[1:0]}] & 64'h0000_00F0;
                end            end
            2'b01: begin    //word
                outputs.SR_data = ARCH_REGISTERS[inputs.SR_ID[2:0]] & 64'h0000_00FF;
            end
            2'b10: begin    //doubleword
                outputs.SR_data = ARCH_REGISTERS[inputs.SR_ID[2:0]] & 64'h0000_FFFF;
            end
            2'b11: begin    //quadword
                outputs.SR_data = MMX_REGISTERS[inputs.SR_ID[2:0]];
            end
        endcase
    end

    always_ff @(posedge clk ) begin
        if(!rst) begin
            ARCH_REGISTERS <= '{default: '0};
            MMX_REGISTERS <= '{default: '0};
            SEG_REG <= '{default: '0};
        end
        else begin
            if (inputs.WB_DR0_we) begin
                if(inputs.WB_DR0_ID[5]) begin
                    SEG_REG[inputs.WB_DR0_ID[2:0]] <= inputs.WB_DR0_data;
                end
                else begin
                    case(inputs.WB_DR0_ID[4:3])
                        2'b00: begin
                            if(inputs.WB_DR0_ID[2] == 0) begin
                                ARCH_REGISTERS[inputs.WB_DR0_ID[2:0]]
                                    <= {ARCH_REGISTERS[inputs.WB_DR0_ID[2:0]][31:8], inputs.WB_DR0_data[7:0]};
                            end
                            else begin
                                ARCH_REGISTERS[{1'b0, inputs.WB_DR0_ID[1:0]}]
                                    <= {ARCH_REGISTERS[inputs.WB_DR0_ID[2:0]][31:16], inputs.WB_DR0_data[7:0],
                                        ARCH_REGISTERS[inputs.WB_DR0_ID[2:0]][7:0]};
                            end
                        end
                        2'b01: begin
                            ARCH_REGISTERS[inputs.WB_DR0_ID[2:0]]
                                <= {ARCH_REGISTERS[inputs.WB_DR0_ID[2:0]][31:16], inputs.WB_DR0_data[15:0]};
                        end
                        2'b10: begin
                            ARCH_REGISTERS[inputs.WB_DR0_ID[2:0]] <= inputs.WB_DR0_data[31:0];
                        end
                        2'b11: begin
                            MMX_REGISTERS[inputs.WB_DR0_ID[2:0]] <= inputs.WB_DR0_data;
                        end
                    endcase
                end
            end

            if (inputs.WB_DR1_we) begin
                if(inputs.WB_DR1_ID[5]) begin
                    SEG_REG[inputs.WB_DR1_ID[2:0]] <= inputs.WB_DR1_data;
                end
                else begin
                    case(inputs.WB_DR1_ID[4:3])
                        2'b00: begin
                            if(inputs.WB_DR1_ID[2] == 0) begin
                                ARCH_REGISTERS[inputs.WB_DR1_ID[2:0]]
                                    <= {ARCH_REGISTERS[inputs.WB_DR1_ID[2:0]][31:8], inputs.WB_DR1_data[7:0]};
                            end
                            else begin
                                ARCH_REGISTERS[{1'b0, inputs.WB_DR1_ID[1:0]}]
                                    <= {ARCH_REGISTERS[inputs.WB_DR1_ID[2:0]][31:16], inputs.WB_DR1_data[7:0],
                                        ARCH_REGISTERS[inputs.WB_DR1_ID[2:0]][7:0]};
                            end
                        end
                        2'b01: begin
                            ARCH_REGISTERS[inputs.WB_DR1_ID[2:0]]
                                <= {ARCH_REGISTERS[inputs.WB_DR1_ID[2:0]][31:16], inputs.WB_DR1_data[15:0]};
                        end
                        2'b10: begin
                            ARCH_REGISTERS[inputs.WB_DR1_ID[2:0]] <= inputs.WB_DR1_data[31:0];
                        end
                        2'b11: begin
                            MMX_REGISTERS[inputs.WB_DR1_ID[2:0]] <= inputs.WB_DR1_data;
                        end
                    endcase
                end
            end
        end
    end

endmodule
