package DTE_FSM_gen_pkg;

    localparam int DTE_MEM_2_ICACHE_FSM_NUM_STATES = 6;

    typedef enum logic [$clog2(
DTE_MEM_2_ICACHE_FSM_NUM_STATES
)-1:0] {
        IDLE    = 0,
        LD0     = 1,
        LD1     = 2,
        LD2     = 3,
        MEM_REQ = 4,
        ERROR   = 5
    } DTE_MEM_2_ICache_FSM_State_e;


    // ============================================================
    // DTE_MEM_2_DCache_FSM
    // ============================================================
    localparam int DTE_MEM_2_DCACHE_FSM_NUM_STATES = 6;

    typedef enum logic [$clog2(
DTE_MEM_2_DCACHE_FSM_NUM_STATES
)-1:0] {
        IDLE    = 0,
        LD0     = 1,
        LD1     = 2,
        LD2     = 3,
        MEM_REQ = 4,
        ERROR   = 5
    } DTE_MEM_2_DCache_FSM_State_e;


    // ============================================================
    // DTE_DCache_2_MEM_FSM
    // ============================================================
    localparam int DTE_DCACHE_2_MEM_FSM_NUM_STATES = 6;

    typedef enum logic [$clog2(
DTE_DCACHE_2_MEM_FSM_NUM_STATES
)-1:0] {
        IDLE   = 0,
        WR0    = 1,
        WR1    = 2,
        WR2    = 3,
        WR_REQ = 4,
        ERROR  = 5
    } DTE_DCache_2_MEM_FSM_State_e;


    // ============================================================
    // DTE_DDR5_2_Core_FSM
    // ============================================================
    localparam int DTE_DDR5_2_CORE_FSM_NUM_STATES = 3;

    typedef enum logic [$clog2(
DTE_DDR5_2_CORE_FSM_NUM_STATES
)-1:0] {
        IDLE    = 0,
        LD_DDR5 = 1,
        ERROR   = 2
    } DTE_DDR5_2_Core_FSM_State_e;


    // ============================================================
    // DTE_Core_2_DDR5_FSM
    // ============================================================
    localparam int DTE_CORE_2_DDR5_FSM_NUM_STATES = 3;

    typedef enum logic [$clog2(
DTE_CORE_2_DDR5_FSM_NUM_STATES
)-1:0] {
        IDLE    = 0,
        ST_DDR5 = 1,
        ERROR   = 2
    } DTE_Core_2_DDR5_FSM_State_e;


    // ============================================================
    // DTE_Core_2_DMA_FSM
    // ============================================================
    localparam int DTE_CORE_2_DMA_FSM_NUM_STATES = 3;

    typedef enum logic [$clog2(
DTE_CORE_2_DMA_FSM_NUM_STATES
)-1:0] {
        IDLE   = 0,
        ST_DMA = 1,
        ERROR  = 2
    } DTE_Core_2_DMA_FSM_State_e;


    // ============================================================
    // DTE_DMA_2_MEM_FSM
    // ============================================================
    localparam int DTE_DMA_2_MEM_FSM_NUM_STATES = 6;

    typedef enum logic [$clog2(
DTE_DMA_2_MEM_FSM_NUM_STATES
)-1:0] {
        IDLE   = 0,
        ST0    = 1,
        ST1    = 2,
        ST2    = 3,
        ST_REQ = 4,
        ERROR  = 5
    } DTE_DMA_2_MEM_FSM_State_e;


endpackage
