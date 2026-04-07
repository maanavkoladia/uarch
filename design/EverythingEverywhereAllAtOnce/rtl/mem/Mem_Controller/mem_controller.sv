
//module is resposible for managing the various banks, this module should not
//
//
//this module shoudl also control which bank gets the bus via tristates
import common_pkg::*;
import interconnect_pkg::*;
import mem_common_pkg::*;

module mem_controller (
    input wire clk,
    input wire rst,  //active low

    //adress and data bus, shoudl proably just be an input
    inout [PHY_MEM_ADDRESS_SIZE - 1 : 0] address_bus,
    inout [DATA_BUS_WIDTH_BITS - 1 : 0] data_bus,
    //arb stuff
    input dte_2_mem_t DTE_i,

    output mem_2_dte_t ToDTE_o,
    output mem_2_scheduler_t ToScheduler_o,

    //controlling outputs to banks
    output mem_controller_2_mem_bank_t bank_cmds_o[NUM_BANKS],
    /*
        logic [NUM_SRAM_ADDRESS_BITS -1 : 0] ld_address;

        //address from the bank group table
        logic [NUM_SRAM_ADDRESS_BITS -1 : 0] st_address;

        //thse two signals are for the bank_fsm_controller
        bool start_store;
        bool ld_address_change;

        //this comes from the mem Controller, this gives
        //permission to this bank to write to the memBus
        bool driveMemBus;

        //buf where write are stored fora bankgrup
        byte_t writeBuf[CACHE_LINES_SIZE_B];
    */


    input mem_bank_out_t banks_i[NUM_BANKS]
    /*

    typedef struct {
        bool precharged;
        bool clear_writebufV;
    } mem_bank_out_t;
     */

);

    typedef struct {
        bool valid;
        logic [(PHY_MEM_ADDRESS_SIZE) - 1 : 0] address;
        //logic lock;
        logic precharge_Status[NUM_BANKS_PER_CHIP];
    } chip_entry_t;

    typedef struct {
        bool valid;  //reg
        bool writeBuf_Valid;  //reg
        logic [PHY_MEM_ADDRESS_SIZE - 1 : 0] address;  //address this chip is representing, reg, needs to be wired to the banks in the group
        byte_t writeBuf[CACHE_LINES_SIZE_B];  //reg
        bool startStore[NUM_BANKS_PER_BANK_GROUP];  //this should be not a reg
    } bankgroup_table_entry_t;

    typedef struct {
        bool mem_ready;
        bool set_ld_tristate;
        bool start_store;
        bool ld_address_changed;
        bool set_WriteBuf_V;
        bool fill0;
        bool fill1;
        bool fill2;
        bool fill3;
    } mem_controller_fsm_out_t;

    //create the bank table
    bankgroup_table_entry_t bankGroupTable[NUM_BANK_GROUPS];

    //create the chip table
    chip_entry_t chipTable[NUM_OF_BANK_CHIPS];

    //bundlede fsm out
    mem_controller_fsm_out_t fsm_outs;

    logic [$clog2(
MEM_CONTROLLER_FSM_STATES
) - 1 : 0] mem_controller_state_bits;  // packed 5-bit vector

    //writing the structurcal state bits to the sv enum
    mem_controller_fsm_state_t fsm_state;
    assign fsm_state = mem_controller_state_bits;

    //TODO: WRite this
    logic hit_into_fsm;

    //instaiate the mem controller fsm module
    mem_controller_fsm u0_Controller (
        .clk(clk),
        .rst(rst),
        .ld_req_i(DTE_i.ld_req),
        .write_req_i(DTE_i.st_req),
        .hit_i(hit_into_fsm),
        .S_0(mem_controller_state_bits[0]),  // current-state bit 0
        .S_1(mem_controller_state_bits[1]),  // current-state bit 1
        .S_2(mem_controller_state_bits[2]),  // current-state bit 2
        .S_3(mem_controller_state_bits[3]),  // current-state bit 3
        .mem_ready_o(fsm_outs.mem_ready),
        .set_ld_tristate_o(fsm_outs.set_ld_tristate),
        .start_store_o(fsm_outs.start_store),
        .ld_address_changed_o(fsm_outs.ld_address_changed),
        .set_WriteBuf_V_o(fsm_outs.set_WriteBuf_V),
        .fill0_o(fsm_outs.fill0),
        .fill1_o(fsm_outs.fill1),
        .fill2_o(fsm_outs.fill2),
        .fill3_o(fsm_outs.fill3)
    );

    //things that need to be done
    //
    //chip table stuff probably
    //drive the chip table seq, address and valid bit
    //wire the ld address to each bank
    //wire the ld address changed to the correct banks
    //wire the driveMemBus logic based on set_ld_tristate
    //wire the precharge from the banks to each respective chip

    logic [$clog2(NUM_OF_BANK_CHIPS) - 1 : 0] chipNum;  //4 wide
    logic [$clog2(NUM_BANKS_PER_CHIP) - 1 : 0] bankBits_InChip;  //2 wide
    logic [NUM_SRAM_ADDRESS_BITS -1 : 0] rowBitFromChipAddress;  //5 wide

    logic [$clog2(NUM_BANKS) - 1 : 0] bank_num_for_chip;
    assign bank_num_for_chip = {chipNum, bankBits_InChip};

    assign chipNum = address_bus[MEM_CHIP_BITS_UB : MEM_CHIP_BITS_LD];
    assign bankBits_InChip = address_bus[5:4];
    assign rowBitFromChipAddress = address_bus[14:10];

    //seq to drive the chip table
    always_ff @(posedge clk) begin
        if (!rst) begin
            //we can proabaly cheese here and preload a chunk
            for (int i = 0; i < NUM_OF_BANK_CHIPS; i++) begin
                chipTable[i].valid   <= 1;
                chipTable[i].address <= 0;
            end
        end else begin
            //need to latch in the new ld address from the address bus coming
            //in
            if (fsm_outs.ld_address_changed) begin
                `LOG("fsm_outs.ld_address_changed block entered");
                chipTable[chipNum].valid   <= 1;
                chipTable[chipNum].address <= address_bus;
            end
        end
    end

    //send correct load address
    //wire the ld_addr to each bank in each chip
    always_comb begin
        //send load address to each bank
        for (int i = 0; i < NUM_OF_BANK_CHIPS; i++) begin
            for (int j = 0; j < NUM_BANKS_PER_CHIP; j++) begin
                bank_cmds_o[{(i*NUM_BANKS_PER_CHIP)+j}].ld_address = chipTable[i].address[14:10];
            end
        end
    end

    //ld_address_changed logic, by defualt send a 0, then if 
    //ld_address changed for a chip, then send a ld_address changed
    //to the banks of that chip
    always_comb begin
        // default: clear all
        for (int i = 0; i < NUM_BANKS; i++) begin
            bank_cmds_o[i].ld_address_change = 0;
        end

        // set only selected chip's banks
        if (fsm_outs.ld_address_changed) begin
            for (int j = 0; j < NUM_BANKS_PER_CHIP; j++) begin
                bank_cmds_o[(chipNum*NUM_BANKS_PER_CHIP)+j].ld_address_change = 1;
            end
        end
    end

    //comb to contrlol banks in chip: deal with drive mem logic
    //allow a single bank the privladege to drive the main memBus
    always_comb begin
        for (int i = 0; i < NUM_BANKS; i++) bank_cmds_o[i].driveMemBus = 0;
        if (fsm_outs.set_ld_tristate) bank_cmds_o[bank_num_for_chip].driveMemBus = 1;
        //send load address to each bank
    end

    //wire the precharge from the banks to each respective chip, always
    always_comb begin
        for (int i = 0; i < NUM_OF_BANK_CHIPS; i++) begin
            for (int j = 0; j < NUM_BANKS_PER_CHIP; j++) begin
                chipTable[i].precharge_Status[j] = banks_i[i*NUM_BANKS_PER_CHIP+j].precharged;
            end
        end
    end

    //bankGRoup Table stuff proabaly
    //drive the table seq, valid, bit, also if st req comes in need store in
    //buf and set valid bit
    //wire the write_buf/valid to each bank in the group, shared
    //wire the startstore signal to each bank this is uniqie to each bank in
    //the bank group based on somehitng proabaly

    //logic
    logic [$clog2(NUM_BANK_GROUPS) - 1 : 0] bankGroup;
    assign bankGroup = address_bus[MEM_BANKGROUP_BITS_UB : MEM_BANKGROUP_BITS_LD];
    //seq logic to drive the bank table, add new entries
    //needs to be decided based on fillX signal
    always_ff @(posedge clk) begin
        if (!rst) begin
            for (int i = 0; i < NUM_BANK_GROUPS; i++) begin
                bankGroupTable[i].valid <= 0;
                bankGroupTable[i].writeBuf_Valid <= 0;
                bankGroupTable[i].address <= 0;
                for (int j = 0; j < CACHE_LINES_SIZE_B; j++) begin
                    bankGroupTable[i].writeBuf[j] <= 0;
                end
            end
        end else begin
            if (fsm_outs.set_WriteBuf_V) begin
                bankGroupTable[bankGroup].writeBuf_Valid <= 1;
                bankGroupTable[bankGroup].address <= address_bus[14:0];

            end

            if (fsm_outs.fill0) begin
                for (int j = 0; j < 4; j++) begin
                    bankGroupTable[bankGroup].writeBuf[j] <= data_bus[8*j+:8];
                end
            end

            if (fsm_outs.fill1) begin
                for (int j = 0; j < 4; j++) begin
                    bankGroupTable[bankGroup].writeBuf[4+j] <= data_bus[8*j+:8];
                end
            end

            if (fsm_outs.fill2) begin
                for (int j = 0; j < 4; j++) begin
                    bankGroupTable[bankGroup].writeBuf[8+j] <= data_bus[8*j+:8];
                end
            end

            if (fsm_outs.fill3) begin
                for (int j = 0; j < 4; j++) begin
                    bankGroupTable[bankGroup].writeBuf[12+j] <= data_bus[8*j+:8];
                end
            end

            for (int i = 0; i < NUM_BANKS; i++) begin
                if (banks_i[i].clear_writebufV) begin
                    bankGroupTable[i[MEM_BANKGROUP_BITS_UB : MEM_BANKGROUP_BITS_LD ]].writeBuf_Valid <= 0;
                end
            end
        end
    end

    //need to wire the correct 5 bit write address to each bank
    always_comb begin
        for (int i = 0; i < NUM_BANK_GROUPS; i++) begin
            for (int j = 0; j < NUM_BANKS_PER_BANK_GROUP; j++) begin
                bank_cmds_o[(NUM_BANKS_PER_BANK_GROUP*i)+j].st_address = bankGroupTable[i].address[14:10];
            end
        end
    end

    //handle start_store logic
    //if the fsm outputs a start_store, then the correct bank needs to get
    //a start store pulse, this logic is broken i think, this needs to pulse,
    //might not be broken because the fsm will keep it high for one cycle
    always_comb begin
        // 1. Default: clear ALL banks
        for (int i = 0; i < NUM_BANK_GROUPS * NUM_BANKS_PER_BANK_GROUP; i++) begin
            bank_cmds_o[i].start_store = 0;
        end

        // 2. Set the selected bank
        if (fsm_outs.start_store) begin
            int idx;
            idx = {address_bus[9:7], bankGroup};  // make sure this is valid indexing!
            bank_cmds_o[idx].start_store = 1;
        end
    end

    //send the writebufs to each of the banks
    always_comb begin
        for (int i = 0; i < NUM_BANK_GROUPS; i++) begin
            for (int j = 0; j < NUM_BANKS_PER_BANK_GROUP; j++) begin
                for (int k = 0; k < CACHE_LINES_SIZE_B; k++) begin
                    bank_cmds_o[(NUM_BANKS_PER_BANK_GROUP * i) + j].writeBuf[k] = bankGroupTable[i].writeBuf[k];
                end
            end
        end
    end

    //need to send v bits to schuelerOut
    always_comb begin
        for (int i = 0; i < NUM_BANK_GROUPS; i++) begin
            ToScheduler_o.writeBuf_V[i] = bankGroupTable[i].writeBuf_Valid;
        end
    end

    //need to do DTE_out logic
    always_comb begin
        ToDTE_o.mem_Ready = fsm_outs.mem_ready;
    end

    //need to do hit logic
    always_comb begin
        hit_into_fsm = 
            DTE_i.ld_req && 
            chipTable[chipNum].address[14:10] == address_bus[14:10] && 
            chipTable[chipNum].precharge_Status[bankBits_InChip];
    end

endmodule
