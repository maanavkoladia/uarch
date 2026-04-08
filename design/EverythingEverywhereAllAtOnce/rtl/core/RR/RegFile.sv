import RegisterRead_pkg::*;
import reg_ids_pkg::*;

module RegFile (
    input clk, rst,
    input reg_ids_e DR_ID,
    input reg_ids_e SR_ID,
    input reg_ids_e SIB_IDX_ID,
    input reg_ids_e SIB_BASE_ID,
    input uint64_t WB_DR0_data,
    input uint64_t WB_DR1_data,
    input reg_ids_e WB_DR0_ID,
    input reg_ids_e WB_DR1_ID,
    input bool WB_DR0_we,
    input bool WB_DR1_we,
    input reg_ids_e Segment0_ID,
    input reg_ids_e Segment1_ID,
    output regfile_output_t outputs
);

    uint64_t REGISTERS[NUM_REGS];

    always_ff @(posedge clk) begin
        if(!rst) REGISTERS <= '{default: '0};
        else begin
            if (WB_DR0_we) REGISTERS[WB_DR0_ID] <= WB_DR0_data;
            if (WB_DR1_we) REGISTERS[WB_DR1_ID] <= WB_DR1_data;
        end
    end

    assign #1.5 outputs.SIB_IDX_data = REGISTERS[SIB_IDX_ID][31:0];
    assign #1.5 outputs.SIB_BASE_data = REGISTERS[SIB_BASE_ID][31:0];
    assign #1.5 outputs.ECX_data = REGISTERS[ECX][31:0];
    assign #1.5 outputs.EAX_data = REGISTERS[EAX][31:0];
    assign #1.5 outputs.CS_data = REGISTERS[CS][31:0];
    assign #1.5 outputs.Segment0_data = REGISTERS[Segment0_ID][31:0];
    assign #1.5 outputs.Segment1_data = REGISTERS[Segment1_ID][31:0];
    assign #1.5 outputs.DR_data = REGISTERS[DR_ID];  //dr
    assign #1.5 outputs.SR_data = REGISTERS[SR_ID];  //sr

endmodule
