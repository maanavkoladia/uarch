package DTE_FSM_gen_pkg;

    localparam int DTE_MEM_2_ICACHE_FSM_NUM_STATES = 7;

    typedef enum logic [$clog2(
DTE_MEM_2_ICACHE_FSM_NUM_STATES
)-1:0] {
        DTE_MEM_2_ICACHE_IDLE    = 0,
        DTE_MEM_2_ICACHE_LD0     = 1,
        DTE_MEM_2_ICACHE_LD1     = 2,
        DTE_MEM_2_ICACHE_LD2     = 3,
        DTE_MEM_2_ICACHE_LD3     = 4,
        DTE_MEM_2_ICACHE_MEM_REQ = 5,
        DTE_MEM_2_ICACHE_ERROR   = 6
    } DTE_MEM_2_ICache_FSM_State_e;


    // ============================================================
    // DTE_MEM_2_DCache_FSM
    // ============================================================
    localparam int DTE_MEM_2_DCACHE_FSM_NUM_STATES = 7;

    typedef enum logic [$clog2(
DTE_MEM_2_DCACHE_FSM_NUM_STATES
)-1:0] {
        DTE_MEM_2_DCACHE_IDLE    = 0,
        DTE_MEM_2_DCACHE_LD0     = 1,
        DTE_MEM_2_DCACHE_LD1     = 2,
        DTE_MEM_2_DCACHE_LD2     = 3,
        DTE_MEM_2_DCACHE_LD3     = 4,
        DTE_MEM_2_DCACHE_MEM_REQ = 5,
        DTE_MEM_2_DCACHE_ERROR   = 6
    } DTE_MEM_2_DCache_FSM_State_e;


    // ============================================================
    // DTE_DCache_2_MEM_FSM
    // ============================================================
    localparam int DTE_DCACHE_2_MEM_FSM_NUM_STATES = 6;

    typedef enum logic [$clog2(
DTE_DCACHE_2_MEM_FSM_NUM_STATES
)-1:0] {
        DTE_DCACHE_2_MEM_IDLE   = 0,
        DTE_DCACHE_2_MEM_WR0    = 1,
        DTE_DCACHE_2_MEM_WR1    = 2,
        DTE_DCACHE_2_MEM_WR2    = 3,
        DTE_DCACHE_2_MEM_WR_REQ = 4,
        DTE_DCACHE_2_MEM_ERROR  = 5
    } DTE_DCache_2_MEM_FSM_State_e;


    // ============================================================
    // DTE_DDR5_2_Core_FSM
    // ============================================================
    localparam int DTE_DDR5_2_CORE_FSM_NUM_STATES = 4;

    typedef enum logic [$clog2(
DTE_DDR5_2_CORE_FSM_NUM_STATES
)-1:0] {
        DTE_DDR5_2_CORE_IDLE    = 0,
        DTE_DDR5_2_CORE_DELAY   = 1,
        DTE_DDR5_2_CORE_LD_DDR5 = 2,
        DTE_DDR5_2_CORE_ERROR   = 3
    } DTE_DDR5_2_Core_FSM_State_e;


    // ============================================================
    // DTE_Core_2_DDR5_FSM
    // ============================================================
    localparam int DTE_CORE_2_DDR5_FSM_NUM_STATES = 4;

    typedef enum logic [$clog2(
DTE_CORE_2_DDR5_FSM_NUM_STATES
)-1:0] {
        DTE_CORE_2_DDR5_IDLE    = 0,
        DTE_CORE_2_DDR5_DELAY   = 1,
        DTE_CORE_2_DDR5_ST_DDR5 = 2,
        DTE_CORE_2_DDR5_ERROR   = 3
    } DTE_Core_2_DDR5_FSM_State_e;


    // ============================================================
    // DTE_Core_2_DMA_FSM
    // ============================================================
    localparam int DTE_CORE_2_DMA_FSM_NUM_STATES = 4;

    typedef enum logic [$clog2(
DTE_CORE_2_DMA_FSM_NUM_STATES
)-1:0] {
        DTE_CORE_2_DMA_IDLE   = 0,
        DTE_CORE_2_DMA_DELAY  = 1,
        DTE_CORE_2_DMA_ST_DMA = 2,
        DTE_CORE_2_DMA_ERROR  = 3
    } DTE_Core_2_DMA_FSM_State_e;


    // ============================================================
    // DTE_DMA_2_MEM_FSM
    // ============================================================
    localparam int DTE_DMA_2_MEM_FSM_NUM_STATES = 6;

    typedef enum logic [$clog2(
DTE_DMA_2_MEM_FSM_NUM_STATES
)-1:0] {
        DTE_DMA_2_MEM_IDLE   = 0,
        DTE_DMA_2_MEM_ST0    = 1,
        DTE_DMA_2_MEM_ST1    = 2,
        DTE_DMA_2_MEM_ST2    = 3,
        DTE_DMA_2_MEM_ST_REQ = 4,
        DTE_DMA_2_MEM_ERROR  = 5
    } DTE_DMA_2_MEM_FSM_State_e;


endpackage
