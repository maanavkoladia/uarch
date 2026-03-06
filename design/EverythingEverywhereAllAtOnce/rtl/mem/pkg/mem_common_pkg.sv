package mem_common_pkg;

    import common_pkg::*;


    localparam int NUM_BANKS = 64;

    localparam int NUM_BANK_GROUPS = 8;
    localparam int NUM_BANKS_PER_BANK_GROUP = NUM_BANKS / NUM_BANK_GROUPS;

    localparam int NUM_OF_BANK_CHIPS = 16;
    localparam int NUM_BANKS_PER_CHIP = NUM_BANKS / NUM_OF_BANK_CHIPS;

    localparam int NUM_SRAM_ADDRESS_WORD = 32;
    localparam int NUM_SRAM_ADDRESS_BITS = $clog2(NUM_SRAM_ADDRESS_WORD);

    localparam int MEM_SIZE = 1 << 15;
    localparam int PHY_MEM_ADDRESS_SIZE = $clog2(MEM_SIZE);


    //need to figure out later
    //bank outputs
    typedef struct {
        bool precharged;
        bool clear_writebufV;
    } mem_bank_out_t;

    typedef struct {
        //address from the chip entry
        logic [NUM_SRAM_ADDRESS_BITS -1 : 0] ld_address;

        //address from the bank group table
        logic [NUM_SRAM_ADDRESS_BITS -1 : 0] st_address;

        //thse two signals are for the bank_fsm_controller
        bool start_store;
        bool ld_address_change;

        //this comes from the mem Controller, this gives
        //permission to this bank to write to the memBus
        bool driveMemBus;

        //buf where write are stored fora bankgroup
        byte_t writeBuf[CACHE_LINES_SIZE_B];

    } mem_controller_2_mem_bank_t;


endpackage


