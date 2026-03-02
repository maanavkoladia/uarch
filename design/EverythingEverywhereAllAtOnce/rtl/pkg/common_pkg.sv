package common_pkg;

    //`define true (1'b1)
    //`define false (1'b0)

    localparam int CACHE_LINES_SIZE_B = 16;
    localparam int CACHE_LINES_SIZE_Bits = CACHE_LINES_SIZE_B * 8;
    localparam int ADDRESS_BITS = 32;
    localparam int PAGE_SIZE = 4096;

    localparam int DATA_BUS_WIDTH_BITS = 32;
    localparam int ADDRESS_BUS_WIDTH_BITS = 32;

    typedef logic [7:0] byte_t;
    typedef logic [ADDRESS_BITS -1 : 0] address_t;
    typedef logic bool;



endpackage
