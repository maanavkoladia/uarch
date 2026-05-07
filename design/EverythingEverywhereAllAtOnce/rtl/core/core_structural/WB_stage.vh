`define WB_STAGE \
    WB write_back_unit ( \
        .clk(clk), \
        .rst(rst), \
        .wb_latches_valid                  (wb_latches_valid), \
        .wb_latches_cs_ST_OP               (wb_latches_cs_ST_OP), \
        .wb_latches_cs_WB_DR               (wb_latches_cs_WB_DR), \
        .wb_latches_cs_WB_SR               (wb_latches_cs_WB_SR), \
        .wb_latches_cs_WB_EAX              (wb_latches_cs_WB_EAX), \
        .wb_latches_ST_XCL                 (wb_latches_ST_XCL), \
        .wb_latches_ST_PADDR_0             (wb_latches_ST_PADDR_0), \
        .wb_latches_ST_BIT_VEC_0           (wb_latches_ST_BIT_VEC_0), \
        .wb_latches_ST_PADDR_1             (wb_latches_ST_PADDR_1), \
        .wb_latches_ST_BIT_VEC_1           (wb_latches_ST_BIT_VEC_1), \
        .wb_latches_MIO                    (wb_latches_MIO), \
        .wb_latches_EIP                    (wb_latches_EIP), \
        .wb_latches_res_buf                (wb_latches_res_buf), \
        .wb_latches_sr_id                  (wb_latches_sr_id), \
        .wb_latches_sr_data                (wb_latches_sr_data), \
        .wb_latches_dr_id                  (wb_latches_dr_id), \
        .wb_latches_dr_data                (wb_latches_dr_data), \
        .wb_latches_EAX                    (wb_latches_EAX), \
        .write_success_0                   (dcache2Core_writeSuccess_0_o), \
        .write_success_1                   (dcache2Core_writeSuccess_1_o), \
        .write_success_2                   (dcache2Core_writeSuccess_2_o), \
        .write_success_3                   (dcache2Core_writeSuccess_3_o), \
        .write_success_mio                 (dcache2Core_writeSuccess_MIO_o), \
        .outputs_valid                     (wb_outputs_valid), \
        .outputs_wb_stall                  (wb_outputs_wb_stall), \
        .outputs_ST_OP                     (wb_outputs_ST_OP), \
        .outputs_ST_XCL                    (wb_outputs_ST_XCL), \
        .outputs_ST_PADDR_0                (wb_outputs_ST_PADDR_0), \
        .outputs_ST_PADDR_1                (wb_outputs_ST_PADDR_1), \
        .outputs_stq_head_0_full           (wb_outputs_stq_heads_0_full), \
        .outputs_stq_head_0_empty          (wb_outputs_stq_heads_0_empty), \
        .outputs_stq_head_0_address        (wb_outputs_stq_heads_0_address), \
        .outputs_stq_head_0_bit_vec        (wb_outputs_stq_heads_0_bit_vec), \
        .outputs_stq_head_0_data           (wb_outputs_stq_heads_0_data), \
        .outputs_stq_head_1_full           (wb_outputs_stq_heads_1_full), \
        .outputs_stq_head_1_empty          (wb_outputs_stq_heads_1_empty), \
        .outputs_stq_head_1_address        (wb_outputs_stq_heads_1_address), \
        .outputs_stq_head_1_bit_vec        (wb_outputs_stq_heads_1_bit_vec), \
        .outputs_stq_head_1_data           (wb_outputs_stq_heads_1_data), \
        .outputs_stq_head_2_full           (wb_outputs_stq_heads_2_full), \
        .outputs_stq_head_2_empty          (wb_outputs_stq_heads_2_empty), \
        .outputs_stq_head_2_address        (wb_outputs_stq_heads_2_address), \
        .outputs_stq_head_2_bit_vec        (wb_outputs_stq_heads_2_bit_vec), \
        .outputs_stq_head_2_data           (wb_outputs_stq_heads_2_data), \
        .outputs_stq_head_3_full           (wb_outputs_stq_heads_3_full), \
        .outputs_stq_head_3_empty          (wb_outputs_stq_heads_3_empty), \
        .outputs_stq_head_3_address        (wb_outputs_stq_heads_3_address), \
        .outputs_stq_head_3_bit_vec        (wb_outputs_stq_heads_3_bit_vec), \
        .outputs_stq_head_3_data           (wb_outputs_stq_heads_3_data), \
        .outputs_mio_head_full             (wb_outputs_mio_head_full), \
        .outputs_mio_head_empty            (wb_outputs_mio_head_empty), \
        .outputs_mio_head_address          (wb_outputs_mio_head_address), \
        .outputs_mio_head_bit_vec          (wb_outputs_mio_head_bit_vec), \
        .outputs_mio_head_data             (wb_outputs_mio_head_data), \
        .outputs_dep_check_entry_0_valid   (wb_outputs_dep_check_entry_0_valid), \
        .outputs_dep_check_entry_0_address (wb_outputs_dep_check_entry_0_address), \
        .outputs_dep_check_entry_1_valid   (wb_outputs_dep_check_entry_1_valid), \
        .outputs_dep_check_entry_1_address (wb_outputs_dep_check_entry_1_address), \
        .outputs_dep_check_entry_2_valid   (wb_outputs_dep_check_entry_2_valid), \
        .outputs_dep_check_entry_2_address (wb_outputs_dep_check_entry_2_address), \
        .outputs_dep_check_entry_3_valid   (wb_outputs_dep_check_entry_3_valid), \
        .outputs_dep_check_entry_3_address (wb_outputs_dep_check_entry_3_address), \
        .outputs_dep_check_entry_4_valid   (wb_outputs_dep_check_entry_4_valid), \
        .outputs_dep_check_entry_4_address (wb_outputs_dep_check_entry_4_address), \
        .outputs_dep_check_entry_5_valid   (wb_outputs_dep_check_entry_5_valid), \
        .outputs_dep_check_entry_5_address (wb_outputs_dep_check_entry_5_address), \
        .outputs_dep_check_entry_6_valid   (wb_outputs_dep_check_entry_6_valid), \
        .outputs_dep_check_entry_6_address (wb_outputs_dep_check_entry_6_address), \
        .outputs_dep_check_entry_7_valid   (wb_outputs_dep_check_entry_7_valid), \
        .outputs_dep_check_entry_7_address (wb_outputs_dep_check_entry_7_address), \
        .outputs_dep_check_entry_8_valid   (wb_outputs_dep_check_entry_8_valid), \
        .outputs_dep_check_entry_8_address (wb_outputs_dep_check_entry_8_address), \
        .outputs_dep_check_entry_9_valid   (wb_outputs_dep_check_entry_9_valid), \
        .outputs_dep_check_entry_9_address (wb_outputs_dep_check_entry_9_address), \
        .outputs_dep_check_entry_10_valid  (wb_outputs_dep_check_entry_10_valid), \
        .outputs_dep_check_entry_10_address(wb_outputs_dep_check_entry_10_address), \
        .outputs_dep_check_entry_11_valid  (wb_outputs_dep_check_entry_11_valid), \
        .outputs_dep_check_entry_11_address(wb_outputs_dep_check_entry_11_address), \
        .outputs_dep_check_entry_12_valid  (wb_outputs_dep_check_entry_12_valid), \
        .outputs_dep_check_entry_12_address(wb_outputs_dep_check_entry_12_address), \
        .outputs_dep_check_entry_13_valid  (wb_outputs_dep_check_entry_13_valid), \
        .outputs_dep_check_entry_13_address(wb_outputs_dep_check_entry_13_address), \
        .outputs_dep_check_entry_14_valid  (wb_outputs_dep_check_entry_14_valid), \
        .outputs_dep_check_entry_14_address(wb_outputs_dep_check_entry_14_address), \
        .outputs_dep_check_entry_15_valid  (wb_outputs_dep_check_entry_15_valid), \
        .outputs_dep_check_entry_15_address(wb_outputs_dep_check_entry_15_address) \
    );
