import common_pkg::*;
import ICache_common_pkg::*;


module ICache_TagStore (
    input wire clk,
    input wire rst,

    input wire en,  //active high
    input v_address_t v_addr_i,  //can be the spc one, or the latched one, top module will decide
    input bool ld_From_I_VC_Swap,
    input bool LD_IC_SWAP_BUF,
    input bool fill3_i,
    input bool busy,
    input ICache_swap_buf_t I_VC_SwapBuf_i,

    output [ICACHE_TAG_WIDTH - 1:0] currTag_o,
    output bool currLine_V
);

    localparam int NUM_LAYERS = 2;
    localparam int NUM_CELLS = 3;

    wire clk_45_phase;
    assign #CLK_PHASE_DELAY clk_45_phase = clk;

    // VIPT: Virtual address for INDEX, Physical address for TAG
    v_addr_icache_fields_t v_addr_i_fields;
    assign v_addr_i_fields = '{
            tag : v_addr_i[ICACHE_TAG_UB : ICACHE_TAG_LB],
            index : v_addr_i[ICACHE_INDEX_UB : ICACHE_INDEX_LB],
            offset : v_addr_i[ICACHE_OFFSET_UB : ICACHE_OFFSET_LB]
        };

    bool validStore[NUM_ICACHE_LINES];

    // Use virtual address for indexing into tag store (VIPT)
    // Lower bits select the RAM cell address, MSB selects which of the 2 RAM cells
    logic [ICACHE_INDEX_WIDTH - 1 - 1 : 0] ADDRESS_2_TagStore;
    assign ADDRESS_2_TagStore = v_addr_i_fields.index[ICACHE_INDEX_WIDTH-1-1 : 0];

    logic tagCellOutSel;
    assign tagCellOutSel = v_addr_i_fields.index[ICACHE_INDEX_WIDTH-1];


    //cases to write is
    //reading from swap buf,
    //or from bus, in which case the
    logic WR_2_TagStore_clk[NUM_LAYERS];
    //logic WR_2_TagStore_Delay[NUM_CELLS];
    logic WR_2_TagStore_actual[NUM_LAYERS];


    assign WR_2_TagStore_clk[0] = !rst ? 1 : (!tagCellOutSel && (fill3_i || ld_From_I_VC_Swap) && en ? 0 : 1);
    assign WR_2_TagStore_clk[1] = !rst ? 1 : (tagCellOutSel && (fill3_i || ld_From_I_VC_Swap) && en ? 0 : 1);

    //assign #2 WR_2_TagStore_Delay[0] = !rst ? 1 : WR_2_TagStore_clk[0];
    //assign #2 WR_2_TagStore_Delay[1] = !rst ? 1 : WR_2_TagStore_clk[1];

    assign WR_2_TagStore_actual[0] = (clk_45_phase) && (WR_2_TagStore_clk[0] == 0) ? 0 : 1;
    assign WR_2_TagStore_actual[1] = (clk_45_phase) && (WR_2_TagStore_clk[1] == 0) ? 0 : 1;



    // Tag input: always use physical address tag (VIPT)
    logic [ICACHE_TAG_WIDTH -1 : 0] DIN_2_TagStore;
    assign DIN_2_TagStore = v_addr_i_fields.tag;

    logic OE_2_TagStore;
    assign OE_2_TagStore = (!busy || LD_IC_SWAP_BUF) && rst && en ? 0 : 1;

    logic [ICACHE_TAG_WIDTH - 1 : 0] DOUT_2_TagStore;
    logic [ICACHE_TAG_WIDTH - 1 : 0] DOUT_2_TagStore_net[NUM_LAYERS];
    assign DOUT_2_TagStore = DOUT_2_TagStore_net[tagCellOutSel];

    // Output assignments
    assign currTag_o = DOUT_2_TagStore;
    assign currLine_V = validStore[v_addr_i_fields.index];

    generate
        for (genvar i = 0; i < NUM_LAYERS; i++) begin : g_tagStore_Layers
            for (genvar j = 0; j < NUM_CELLS; j++) begin : g_tagStore_Cells
                ram8b8w$ tagStoreCell (
                    .A(ADDRESS_2_TagStore),
                    .WR(WR_2_TagStore_actual[i]),
                    .DIN(DIN_2_TagStore[j*8+:8]),
                    .OE(OE_2_TagStore),
                    .DOUT(DOUT_2_TagStore_net[i][j*8+:8])
                );
            end
        end
    endgenerate

    // Valid bit storage - reset when rst is active high
    always_ff @(posedge clk) begin
        if (!rst) validStore <= '{default: '0};
        else if (fill3_i || ld_From_I_VC_Swap) validStore[v_addr_i_fields.index] <= 1;
    end

endmodule

