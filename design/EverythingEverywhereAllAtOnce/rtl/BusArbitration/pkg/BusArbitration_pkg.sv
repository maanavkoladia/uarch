package BusArbitration_pkg;

    localparam int NUM_TRANSACTIONS = 14;

    typedef enum logic [$clog2(
NUM_TRANSACTIONS
)-1:0] {
        NOP          = 4'd0,
        MEM_2_ICACHE = 4'd1,

        MEM_2_DCACHE_BK_0 = 4'd2,
        MEM_2_DCACHE_BK_1 = 4'd3,
        MEM_2_DCACHE_BK_2 = 4'd4,
        MEM_2_DCACHE_BK_3 = 4'd5,

        DCACHE_BK_0_2_MEM = 4'd6,
        DCACHE_BK_1_2_MEM = 4'd7,
        DCACHE_BK_2_2_MEM = 4'd8,
        DCACHE_BK_3_2_MEM = 4'd9,

        DMA_2_MEM = 4'd10,

        MIO_2_DMA  = 4'd11,
        MIO_2_DDR5 = 4'd12,
        DDR5_2_MIO = 4'd13

    } bus_transaction_e;



endpackage
