package common_pkg;

    //`define true (1'b1)
    //`define false (1'b0)


    localparam int CACHE_LINES_SIZE_B = 16;
    localparam int CACHE_LINES_SIZE_Bits = CACHE_LINES_SIZE_B * 8;
    localparam int ADDRESS_BITS = 32;
    localparam int PAGE_SIZE = 4096;
    localparam int PHY_MEM_SIZE = 1 << 15;

    localparam int DATA_BUS_WIDTH_BITS = 32;
    localparam int ADDRESS_BUS_WIDTH_BITS = 32;

    typedef logic [7:0] byte_t;
    typedef logic [ADDRESS_BITS - 1 : 0] address_t;
    typedef logic bool;

    typedef logic [$clog2(PHY_MEM_SIZE) - 1 : 0] p_address_t;
    typedef address_t v_address_t;
    typedef address_t l_address_t;

    typedef logic [7:0] uint8_t;
    typedef logic [15:0] uint16_t;
    typedef logic [31:0] uint32_t;
    typedef logic [63:0] uint64_t;
    typedef logic [127:0] uintCL_t;

    localparam int NUM_WB_ST_QS = 4;
    localparam int ST_Q_DEPTH = 4;  //needs to be a power of two
    localparam int NUM_IDM_SLOTS = 4;

    localparam int NUM_SBS = 22;


endpackage
