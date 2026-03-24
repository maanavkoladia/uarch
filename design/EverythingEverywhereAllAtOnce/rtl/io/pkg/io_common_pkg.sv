package io_common_pkg;

    import common_pkg::*;
    localparam uint32_t TEMP_VAL = 3000;

    localparam uint32_t DMA_WRITE_SRC_ADDRESS = 32'h00000000;
    localparam uint32_t DMA_WRITE_DEST_ADDRESS = 32'h00000010;
    localparam uint32_t DMA_WRITE_NUM_BYTES_ADDRESS = 32'h00000020;
    localparam uint32_t DMA_WRITE_START_TRANSFER_ADDRESS = 32'h00000030;
    localparam uint32_t DDR5_WRITE_POWERGATE_VAL_ADDRESS = 32'h00000040;
    localparam uint32_t DDR5_WRITE_LD_TEMP_VAL_ADDRESS = 32'h00000050;

endpackage
