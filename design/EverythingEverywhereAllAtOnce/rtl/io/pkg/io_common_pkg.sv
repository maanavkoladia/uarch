package io_common_pkg;

    import common_pkg::*;
    localparam uint32_t TEMP_VAL = 3000;

    localparam uint32_t DMA_WRITE_SRC_ADDRESS = 32'h00000000;
    localparam uint32_t DMA_WRITE_DEST_ADDRESS = 32'h00000010;
    localparam uint32_t DMA_WRITE_NUM_BYTES_ADDRESS = 32'h00000020;
    localparam uint32_t DMA_WRITE_START_TRANSFER_ADDRESS = 32'h00000030;
    localparam uint32_t DDR5_WRITE_POWERGATE_VAL_ADDRESS = 32'h00000040;
    localparam uint32_t DDR5_WRITE_LD_TEMP_VAL_ADDRESS = 32'h00000050;

    localparam int MIO_DATA_SIZE_B = 4;

    localparam int DISK_SIZE = 8 * PAGE_SIZE;
    localparam int DISK_LOAD_DELAY = 75;

    localparam int DMA_FSM_NUM_STATES = 5;

    typedef enum logic [$clog2(
DMA_FSM_NUM_STATES
) -1 : 0] {
        IDLE        = 0,
        LD_BUF      = 1,
        WAIT_FOR_LD = 2,
        WAIT_FOR_WR = 3,
        ERROR       = 4
    } dma_fsm_states_e;

endpackage
