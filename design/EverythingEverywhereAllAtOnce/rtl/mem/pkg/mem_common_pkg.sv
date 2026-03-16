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
        logic [NUM_SRAM_ADDRESS_BITS - 1 : 0] ld_address;

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

    //FSM states for Bank controller FSM
    localparam int BANK_CONTROLLER_FSM_LOGIC_STATES = 18;
    typedef enum logic [$clog2(
BANK_CONTROLLER_FSM_LOGIC_STATES
) - 1 : 0] {
        IDLE            = 5'd0,
        LD_ADDR_WAIT_0  = 5'd1,
        LD_WAIT_0       = 5'd2,
        LD_WAIT_1       = 5'd3,
        LD_WAIT_2       = 5'd4,
        LD_WAIT_3       = 5'd5,
        LD_WAIT_4       = 5'd6,
        LD_WAIT_5       = 5'd7,
        ST_ADDR_WAIT_0  = 5'd8,
        ST_ADDR_WAIT_1  = 5'd9,
        ST_ADDR_WAIT_2  = 5'd10,
        ST_ADDR_WAIT_3  = 5'd11,
        ST_WRITE_WAIT_0 = 5'd12,
        ST_WRITE_WAIT_1 = 5'd13,
        ST_WRITE_WAIT_2 = 5'd14,
        ST_WRITE_WAIT_3 = 5'd15,
        ST_WRITE_WAIT_4 = 5'd16,
        ST_WRITE_WAIT_5 = 5'd17
    } bank_fsm_controller_state_t;

    localparam int MEM_CONTROLLER_FSM_STATES = 10;
    typedef enum logic [$clog2(
MEM_CONTROLLER_FSM_STATES
) - 1 : 0] {
        ERROR   = 5'd0,
        IDLE    = 5'd1,
        LD_0    = 5'd2,
        LD_1    = 5'd3,
        LD_2    = 5'd4,
        LD_HIT  = 5'd5,
        LD_MISS = 5'd6,
        W0      = 5'd7,
        W1      = 5'd8,
        W2      = 5'd9

    } mem_controller_fsm_state_t;

endpackage


