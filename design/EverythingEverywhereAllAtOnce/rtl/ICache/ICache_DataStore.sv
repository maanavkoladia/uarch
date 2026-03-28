import common_pkg::*;
import ICache_common_pkg::*;

module ICache_DataStore (

    input wire rst,
    input wire en,  //active high
    input v_address_t v_addr_i,  //can be the spc one, or the latched one, top module will decide
    input p_address_t p_addr_i,  //can be the spc one, or the latched one, top module will decide

    //output the line evition line to write to IC_SWAP_BUF
    input bool LD_IC_SWAP_BUF,

    input bool fill0_i,
    input bool fill1_i,
    input bool fill2_i,
    input bool fill3_i,

    input bool busy,

    //rd in ld_From_I_VC_Swap
    input bool ld_From_I_VC_Swap,
    input ICache_swap_buf_t I_VC_SwapBuf_i,

    input wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    output byte_t currLine_o[CACHE_LINES_SIZE_B]

);

    localparam int LAYERS_OF_CELLS = 2;
    localparam int NUM_CELLS = CACHE_LINES_SIZE_B;

    logic [ICACHE_INDEX_WIDTH - 1 : 0] v_addr_i_index;
    assign v_addr_i_index = v_addr_i[ICACHE_INDEX_UB : ICACHE_INDEX_LB];

    // Use virtual address for indexing into tag store (VIPT)
    // Lower bits select the RAM cell address, MSB selects which of the 2 RAM cells
    logic [ICACHE_INDEX_WIDTH - 1 - 1 : 0] ADDRESS_2_DataStore;
    assign ADDRESS_2_DataStore = v_addr_i_index[ICACHE_INDEX_WIDTH-1-1 : 0];
    logic dataLineOutSel;
    assign dataLineOutSel = v_addr_i_index[ICACHE_INDEX_WIDTH-1];

    //comes from p_addr upper index bit

    //index with upper idx bit from p_addr and use if fill0
    //cases to write is
    //reading from swap buf,
    //or from bus, in which case the
    //address comes from p_addr
    logic WR_2_DataStore[LAYERS_OF_CELLS][NUM_CELLS];

    always_comb begin
        WR_2_DataStore = '{default: '1};  //active low
        for (int j = 0; j < LAYERS_OF_CELLS; j++) begin
            if (dataLineOutSel == j) begin
                unique case ({
                    ld_From_I_VC_Swap, fill0_i, fill1_i, fill2_i, fill3_i
                })
                    5'b10000: WR_2_DataStore[dataLineOutSel] = '{default: '0};
                    5'b01000: for (int i = 0; i < 4; i++) WR_2_DataStore[dataLineOutSel][i] = 0;
                    5'b00100: for (int i = 0; i < 4; i++) WR_2_DataStore[dataLineOutSel][i+4] = 0;
                    5'b00010: for (int i = 0; i < 4; i++) WR_2_DataStore[dataLineOutSel][i+8] = 0;
                    5'b00001: for (int i = 0; i < 4; i++) WR_2_DataStore[dataLineOutSel][i+12] = 0;
                    5'b00000: WR_2_DataStore[dataLineOutSel] = '{default: '1};
                    default:  if (rst) $fatal;
                endcase
            end
        end
    end

    // Tag input: always use physical address tag (VIPT)
    // Swap buffer only provides data, not the tag - tag comes from current p_addr_i
    byte_t DIN_2_DataStore[CACHE_LINES_SIZE_B];

    always_comb begin
        if (ld_From_I_VC_Swap) begin
            DIN_2_DataStore = I_VC_SwapBuf_i.line;
        end else begin
            DIN_2_DataStore[0] = dataBus[7:0];
            DIN_2_DataStore[1] = dataBus[15:8];
            DIN_2_DataStore[2] = dataBus[23:16];
            DIN_2_DataStore[3] = dataBus[31:24];
        end
    end

    logic OE_2_DataStore;
    assign OE_2_DataStore = !busy || LD_IC_SWAP_BUF;

    byte_t DOUT_2_DataStore[LAYERS_OF_CELLS][CACHE_LINES_SIZE_B];

    generate
        for (genvar i = 0; i < LAYERS_OF_CELLS; i++) begin : g_mem_layer
            for (genvar j = 0; j < NUM_CELLS; j++) begin : g_memCells
                ram8b8w$ dataStore_memCell (
                    .A(ADDRESS_2_DataStore),
                    .WR(WR_2_DataStore[i][j]),
                    .DIN(DIN_2_DataStore[j]),
                    .OE(OE_2_DataStore),
                    .DOUT(DOUT_2_DataStore[i][j])
                );
            end
        end
    endgenerate

    assign currLine_o = DOUT_2_DataStore[dataLineOutSel];

endmodule
