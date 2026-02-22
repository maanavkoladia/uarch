package common_pkg;

    //`define true (1'b1)
    //`define false (1'b0)

    localparam int CACHE_LINES_SIZE = 16;
    localparam int ADDRESS_BITS = 32;
    localparam int PAGE_SIZE = 4096;

    typedef logic [7:0] byte_t;
    typedef logic [ADDRESS_BITS] address_t;
    typedef logic bool;

endpackage
