//module is resposible for managing the various banks, this module should not
//
//
//this module shoudl also control which bank gets the bus via tristates

module mem_controller (
    input wire clk,
    input wire rst,

    //adress and data bus, shoudl proably just be an input
    inout logic [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus,
    inout logic [DATA_BUS_WIDTH_BITS - 1 : 0] data_bus,
    //arb stuff
    input dte_2_mem_t DTE_i,

    output mem_2_dte_t ToDTE_o,
    output mem_2_scheduler_t ToScheduler_o,

    //controlling outputs to banks
    output mem_controller_2_mem_bank_t bank_cmds_o[NUM_BANKS],

    input mem_bank_out_t banks_i[NUM_BANKS]

);
    import common_pkg::*;
    import system_bus_ifs_pkg::*;
    import mem_common_pkg::*;

    typedef struct {
        bool valid;
        logic [ADDRESS_BITS -1 : 0] address;
        logic lock;
        logic precharge_Status[NUM_BANKS_PER_CHIP];
    } chip_entry_t;

    typedef struct {
        bool valid;  //reg
        bool writeBuf_Valid;  //reg
        logic [ADDRESS_BITS - 1 : 0] address;  //address this chip is representing, reg, needs to be wired to the banks in the group
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

    //logic
    logic [$clog2(NUM_BANK_GROUPS) - 1 : 0] bankGroupNum_FromAddress;
    logic [$clog2(NUM_OF_BANK_CHIPS) - 1 : 0] chipNum_FromAddress;
    logic [$clog2(NUM_BANKS) - 1 : 0] bank_FromAddress;

    assign bankGroupNum_FromAddress = address[6:4];
    assign chipNum_FromAddress = address[9:6];
    assign bankInGroup_FromAddress = address[9:7];

    //TODO: WRite this
    logic hit_into_fsm;
    //assign hit_into_fsm = chipTable[chipTable].address{[14:12],[5:4]} == ;

    //instaiate the mem controller fsm module
    mem_controller_fsm u0_Controller (
        .clk(clk),
        .rst(rst),
        .ld_req_i(DTE_i.ld_req),
        .write_req_i(DTE_i.st_req),
        .hit_i(hit_into_fsm),
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


    //seq to drive the chip table
    always_ff @(posedge clk) begin
        if (rst) begin
            //we can proabaly cheese here and preload a chunk
            for (int i = 0; i < NUM_OF_BANK_CHIPS; i++) chipTable[i].valid <= 0;
        end else begin
            //need to signal each bank that the ld_address has changed
            //need to latch in the new ld address from the address bus coming
            //in
            if (ld_address_changed) begin
                chipTable[chipNum_FromAddress].valid   <= 1;
                chipTable[chipNum_FromAddress].address <= address;

            end
            //changed, and signal the correct bank to drive the mem bus
        end
    end

    //send correct load address
    always_comb begin
        //send load address to each bank
        for (int i = 0; i < NUM_OF_BANK_CHIPS; i++) begin
            chip_entry_t currEntry = chipTable[i];
            for (int j = 0; j < NUM_BANKS_PER_CHIP; i++) begin
                bank_cmds_o[  /*no idea*/].ld_address = currEntry.address;
            end
        end
    end

    //ld_address_changed logic
    always_comb begin
        for (int i = 0; i < NUM_BANKS; i++) bank_cmds_o[i].ld_address_change = 0;
        if (ld_address_changed) begin
            for (int i = 0; i < NUM_BANKS_PER_CHIP; i++) begin
                bank_cmds_o[{chipNum_FromAddress, address[5:4]}].ld_address_change = 1;
            end
        end
    end

    //comb to contrlol banks in chip: deal with drive mem logic
    always_comb begin
        for (int i = 0; i < NUM_BANKS; i++) bank_cmds_o[i].driveMemBus = 0;

        if (set_ld_tristate) bank_cmds_o[bank_FromAddress].driveMemBus = 1;
        //send load address to each bank
    end

    //wire the precharge from the banks to each respective chip
    always_comb begin
        //DO This
    end

    //bankGRoup Table stuff proabaly
    //drive the table seq, valid, bit, also if st req comes in need store in
    //buf and set valid bit
    //wire the write_buf/valid to each bank in the group, shared
    //wire the startstore signal to each bank this is uniqie to each bank in
    //the bank group based on somehitng proabaly

    //seq logic to drive the bank table, add new entries
    //needs to be decided based on fillX signal
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < NUM_BANKS; i++) begin
                bankGroupTable[i].valid <= 0;
            end
        end else begin

        end
    end

    //need to wire the correct 5 bit write address to each bank
    always_comb begin
        for (int i = 0; i < NUM_BANK_GROUPS; i++) begin
            for (int j = 0; j < NUM_BANKS; j++) begin
                bank_cmds_o[(NUM_BANKS*i)+j].st_address = bankGroupTable[i].address[14:10];
            end
        end
    end

    //handle start_store logic
    always_comb begin
        //clear all of them to clear them
        for (int i = 0; i < NUM_BANK_GROUPS; i++) begin
            bankGroupTable[i].start_store = '0;
        end

        //now assert the correct ones
        for (int i = 0; i < NUM_BANK_GROUPS; i++) begin
            bankgroup_table_entry_t currEntry = bankGroupTable[i];
            if (fsm_outs.start_store) begin  //need to assert the start_store signle for the correct bank
                bank_cmds_o[bank_FromAddress].start_store = 1;
            end
        end
    end

endmodule


