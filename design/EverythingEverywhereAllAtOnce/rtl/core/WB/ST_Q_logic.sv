import core_common_pkg::*;
import WriteBack_pkg::*;
import common_pkg::*;
import core_stage_latches_pkg::*;


module ST_Q_logic(
    input bool wb_valid,
    input p_address_t st_paddr_0,
    input p_address_t st_paddr_1,
    input byte_t res_buf[CACHE_LINES_SIZE_B * 2],
    input uint16_t bit_vect_0,
    input uint16_t bit_vect_1,
    input bool ST_OP,
    input bool ST_XCL,
    input bool MIO, 
    input bool write_success[NUM_WB_ST_QS],
    input bool non_forwarding,

    output st_q_inputs_t stq_info[NUM_WB_ST_QS]
);



  //STQ stuff
            //1:0
    logic [$clog2(ST_Q_DEPTH)-1: 0] low_bank_num;
    logic [$clog2(ST_Q_DEPTH)-1: 0] high_bank_num;

    byte_t st_data_low_bank[CACHE_LINES_SIZE_B];
    byte_t st_data_high_bank[CACHE_LINES_SIZE_B];

    always_comb begin
        for(int i = 0 ; i < CACHE_LINES_SIZE_B; i++)begin
            st_data_low_bank[i] = res_buf[i];
            st_data_high_bank[i] = res_buf[i+CACHE_LINES_SIZE_B];
        end
    end

                                        //5:4
    assign low_bank_num = st_paddr_0[$clog2(ST_Q_DEPTH)-1 + $clog2(CACHE_LINES_SIZE_B):
                                      $clog2(CACHE_LINES_SIZE_B)];

    assign high_bank_num = st_paddr_1[$clog2(ST_Q_DEPTH)-1 + $clog2(CACHE_LINES_SIZE_B):
                                      $clog2(CACHE_LINES_SIZE_B)];


    st_q_entry_t entry0;
    st_q_entry_t entry1;

    assign entry0 = '{
                valid : (ST_OP & ~MIO & wb_valid),
                address : st_paddr_0,
                bit_vec: bit_vect_0,
                data : st_data_low_bank,
                non_forwarding : non_forwarding
            };

    assign  entry1 = '{
                valid: (ST_OP & ST_XCL & ~MIO & wb_valid),
                address: st_paddr_1,
                bit_vec: bit_vect_1,
                data: st_data_high_bank,
                non_forwarding : non_forwarding

            };

    always_comb begin
        // Initialize all queues
        for(int i = 0; i < NUM_WB_ST_QS; i++)begin
            stq_info[i] = '{default : '0};
            stq_info[i].pop = write_success[i];  // Always propagate pop signals
        end

        // Push entry0 to its bank
        if (entry0.valid) begin
            stq_info[low_bank_num].push = 1'b1;
            stq_info[low_bank_num].data = entry0;
        end

        if (entry1.valid) begin
            stq_info[high_bank_num].push = 1'b1;
            stq_info[high_bank_num].data = entry1;
        end
    end


    //Claude
    // Immediate assertion: Check for bank collision on XCL stores
    // If both entries are valid and map to same bank, you'll lose entry0
    always_comb begin
        if (entry0.valid && entry1.valid && (low_bank_num == high_bank_num) & ST_XCL) begin
            $error("STQ_Logic: Bank collision - XCL store with both entries mapping to same bank %0d", 
                   low_bank_num);
        end
    end

endmodule