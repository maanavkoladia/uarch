import common_pkg::*;
import DCache_common_pkg::*;

module DCache_Bank_DataStore (
    input p_address_t p_addr_i,

    input bool oe,
    input bool we,

    input bool ld_From_V_Swap_i,
    input bool fill0_i,
    input bool fill1_i,
    input bool fill2_i,
    input bool fill3_i,
    input bool write2_Dwap_i,
    input bool bankControllerBusy_i,


    input byte_t   st_q_data  [CACHE_LINES_SIZE_B],
    input uint16_t st_data_vec,

    input byte_t VCache_SwapBuf_Line_i[CACHE_LINES_SIZE_B],
    input wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus_i,

    input bool tagStore_hit_i,

    output byte_t lineOut_o[CACHE_LINES_SIZE_B]
);
    localparam int NUM_CELL_IN_DATA_STORE = CACHE_LINES_SIZE_B;

    //not an array on purpose, the datastore should not be bytes addressable
    //this shoudl just be the index bits from the the block req
    //Case 1: ld_req is in Block_Req
    //Case 2: miss, fsm is fetching, addr should still be latched into
    //case 3: swap data coming in from V$, means we missed here, but hit in V$,
    //use reg addr
    //address can come from bus or block req, fuck, or v$ swapbuf, dont think
    //this is true anymore, i think the only place the address can come from
    //is block req, so i am removing addr bus for now,
    //so address should be in req, this is wrong 
    //because address can change in arb, so need to use the addr in vswap_buf,
    //wrong 
    logic [DCACHE_BANK_INDEX_WIDTH - 1 : 0] ADDRESS_2_DataStore;

    //can be driven by req with vec and we logic , or fsm fill signals, or all high for a swap
    //active low
    logic WR_2_DataStore[NUM_CELL_IN_DATA_STORE];

    //din can come from bus, for a ld_req or wr_req and a miss, or from block_req we req st_q req, or v$ swapBuf
    //exact control will be dictacted by oe and we
    byte_t DIN_2_DataStore[NUM_CELL_IN_DATA_STORE];

    //
    //active low, intentioanlly made it 1 bit, and not a vecotr,
    //there is not bytes addressable ld
    //Case 1: output to ld_mem if the controller is not busy,
    //so only when idle
    //case 2: write to D$ swapBuf
    //
    logic OE_2_DataStore;


    //DOUT can go to D$ swap buf or up to ld_mem (so D$ output)
    byte_t DOUT_DataStore[NUM_CELL_IN_DATA_STORE];

    p_addr_dcache_fields_t p_addr_fields = '{
        tag    : p_addr_i[DCACHE_BANK_TAG_UB : DCACHE_BANK_TAG_LB],
        index  : p_addr_i[DCACHE_BANK_INDEX_UB : DCACHE_BANK_INDEX_LB],
        bank   : p_addr_i[DCACHE_BANK_BANK_UB : DCACHE_BANK_BANK_LB],
        offset : p_addr_i[DCACHE_BANK_OFFSET_UB : DCACHE_BANK_OFFSET_LB]
    };

    generate
        for (
            genvar i = 0; i < NUM_CELL_IN_DATA_STORE; i++
        ) begin : g_dcache_bank_data_store_ram_cells
            ram8b8w$ dcache_bank_data_store_ramCell (
                .A(ADDRESS_2_DataStore),
                .WR(WR_2_DataStore[i]),
                .DIN(DIN_2_DataStore[i]),
                .OE(OE_2_DataStore),
                .DOUT(DOUT_DataStore[i])
            );
        end
    endgenerate

    //ADDRESS_2_DataStore logic
    always_comb begin
        ADDRESS_2_DataStore = p_addr_fields.index;
    end

    //WR_2_DataStore logic
    always_comb begin

        // default safety (important for combinational completeness)
        WR_2_DataStore[i] = '1;

        unique case ({
            ld_From_V_Swap_i, fill0_i, fill1_i, fill2_i, fill3_i
        })

            5'b10000: begin  // ld_v_swap, set all low
                WR_2_DataStore[i] = '0;
            end

            5'b01000: begin  //low only for first four
                for (int i = 0; i < 4; i++) begin
                    WR_2_DataStore[i] = 1'b0;
                end
            end

            5'b00100: begin
                for (int i = 0; i < 4; i++) begin
                    WR_2_DataStore[i+4] = 1'b0;
                end
            end

            5'b00010: begin
                for (int i = 0; i < 4; i++) begin
                    WR_2_DataStore[i+8] = 1'b0;
                end
            end

            5'b00001: begin
                for (int i = 0; i < 4; i++) begin
                    WR_2_DataStore[i+12] = 1'b0;
                end
            end

            5'b00000: begin  // default fill from request, needs to be anded with vec and we and banks is not busy, need to add some kind of hit logic before doing a write
                for (int i = 0; i < NUM_CELL_IN_DATA_STORE; i++) begin
                    WR_2_DataStore[i] = st_data_vec[i]
                    && we
                    && !bankControllerBusy_i
                    && tagStore_hit_i ? 1'b0 : 1'b1;
                end
            end

            default: begin
                $fatal;
            end

        endcase
    end


    //DIN_2_DataStore logic
    always_comb begin

        // default safety (important for combinational completeness)
        DIN_2_DataStore[i] = '1;

        unique case ({
            ld_From_V_Swap_i, fill0_i, fill1_i, fill2_i, fill3_i
        })

            5'b10000: begin  // ld_v_swap
                DIN_2_DataStore = VCache_SwapBuf_Line_i;
            end

            5'b01000: begin
                for (int i = 0; i < 4; i++) begin
                    DIN_2_DataStore[i] = dataBus_i[i*8+:8];
                end
            end

            5'b00100: begin
                for (int i = 0; i < 4; i++) begin
                    DIN_2_DataStore[i+4] = dataBus_i[i*8+:8];
                end
            end

            5'b00010: begin
                for (int i = 0; i < 4; i++) begin
                    DIN_2_DataStore[i+8] = dataBus_i[i*8+:8];
                end
            end

            5'b00001: begin
                for (int i = 0; i < 4; i++) begin
                    DIN_2_DataStore[i+12] = dataBus_i[i*8+:8];
                end
            end

            5'b00000: begin  // default fill from request
                DIN_2_DataStore = st_q_data;
            end

            default: begin
                $fatal;
            end

        endcase
    end

    //OE_2_DataStore logic
    always_comb begin
        OE_2_DataStore = write2_Dwap_i || (oe && !bankControllerBusy_i) ? 1'b0 : 1'b1;
    end

    always_comb begin
        lineOut_o = DOUT_DataStore;
    end

endmodule
