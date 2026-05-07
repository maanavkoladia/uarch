`define WB_OUTPUTS \
    wire        wb_outputs_valid; \
    wire        wb_outputs_wb_stall; \
    wire        wb_outputs_ST_OP; \
    wire        wb_outputs_ST_XCL; \
    wire [14:0] wb_outputs_ST_PADDR_0; \
    wire [14:0] wb_outputs_ST_PADDR_1; \
    wire        wb_outputs_stq_heads_0_full,    wb_outputs_stq_heads_0_empty; \
    wire [14:0] wb_outputs_stq_heads_0_address; \
    wire [15:0] wb_outputs_stq_heads_0_bit_vec; \
    wire [127:0] wb_outputs_stq_heads_0_data; \
    wire        wb_outputs_stq_heads_1_full,    wb_outputs_stq_heads_1_empty; \
    wire [14:0] wb_outputs_stq_heads_1_address; \
    wire [15:0] wb_outputs_stq_heads_1_bit_vec; \
    wire [127:0] wb_outputs_stq_heads_1_data; \
    wire        wb_outputs_stq_heads_2_full,    wb_outputs_stq_heads_2_empty; \
    wire [14:0] wb_outputs_stq_heads_2_address; \
    wire [15:0] wb_outputs_stq_heads_2_bit_vec; \
    wire [127:0] wb_outputs_stq_heads_2_data; \
    wire        wb_outputs_stq_heads_3_full,    wb_outputs_stq_heads_3_empty; \
    wire [14:0] wb_outputs_stq_heads_3_address; \
    wire [15:0] wb_outputs_stq_heads_3_bit_vec; \
    wire [127:0] wb_outputs_stq_heads_3_data; \
    wire        wb_outputs_mio_head_full, wb_outputs_mio_head_empty; \
    wire [14:0] wb_outputs_mio_head_address; \
    wire [15:0] wb_outputs_mio_head_bit_vec; \
    wire [127:0] wb_outputs_mio_head_data; \
    wire        wb_outputs_dep_check_entry_0_valid; \
    wire [14:0] wb_outputs_dep_check_entry_0_address; \
    wire        wb_outputs_dep_check_entry_1_valid; \
    wire [14:0] wb_outputs_dep_check_entry_1_address; \
    wire        wb_outputs_dep_check_entry_2_valid; \
    wire [14:0] wb_outputs_dep_check_entry_2_address; \
    wire        wb_outputs_dep_check_entry_3_valid; \
    wire [14:0] wb_outputs_dep_check_entry_3_address; \
    wire        wb_outputs_dep_check_entry_4_valid; \
    wire [14:0] wb_outputs_dep_check_entry_4_address; \
    wire        wb_outputs_dep_check_entry_5_valid; \
    wire [14:0] wb_outputs_dep_check_entry_5_address; \
    wire        wb_outputs_dep_check_entry_6_valid; \
    wire [14:0] wb_outputs_dep_check_entry_6_address; \
    wire        wb_outputs_dep_check_entry_7_valid; \
    wire [14:0] wb_outputs_dep_check_entry_7_address; \
    wire        wb_outputs_dep_check_entry_8_valid; \
    wire [14:0] wb_outputs_dep_check_entry_8_address; \
    wire        wb_outputs_dep_check_entry_9_valid; \
    wire [14:0] wb_outputs_dep_check_entry_9_address; \
    wire        wb_outputs_dep_check_entry_10_valid; \
    wire [14:0] wb_outputs_dep_check_entry_10_address; \
    wire        wb_outputs_dep_check_entry_11_valid; \
    wire [14:0] wb_outputs_dep_check_entry_11_address; \
    wire        wb_outputs_dep_check_entry_12_valid; \
    wire [14:0] wb_outputs_dep_check_entry_12_address; \
    wire        wb_outputs_dep_check_entry_13_valid; \
    wire [14:0] wb_outputs_dep_check_entry_13_address; \
    wire        wb_outputs_dep_check_entry_14_valid; \
    wire [14:0] wb_outputs_dep_check_entry_14_address; \
    wire        wb_outputs_dep_check_entry_15_valid; \
    wire [14:0] wb_outputs_dep_check_entry_15_address;
