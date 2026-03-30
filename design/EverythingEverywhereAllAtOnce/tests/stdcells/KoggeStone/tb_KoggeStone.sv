import common_pkg::*;
import interconnect_pkg::*;
import DTE_FSM_gen_pkg::*;

module tb_DTE ();
    localparam int Clk_PERIOD = 10;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask


    // ================= CLOCK / RESET =================
    `CLK_INIT(Clk_PERIOD);
    logic                                                     rst;
    wire                   [   ADDRESS_BUS_WIDTH_BITS -1 : 0] address_bus;
    wire                   [     DATA_BUS_WIDTH_BITS - 1 : 0] data_bus;
    // ================= ICACHE =================
    dte_2_icache_t                                            dte_2_icache;

    // ================= DCACHE =================
    dte_2_dcache_t                                            dte_2_dcache;

    // ================= MEMORY =================
    mem_2_dte_t                                               mem_2_dte;
    dte_2_mem_t                                               dte_2_mem;

    // ================= DMA =================
    dte_2_dma_controller_t                                    dte_2_dma;

    // ================= DDR5 =================
    dte_2_ddr5_t                                              dte_2_ddr5;

    //sch pick signals
    req_2_sch_t                                               bestPick_req_2_dte;
    logic                  [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_2_dte;


    DTE uut0_DTE (
        .clk(clk),
        .rst(rst),
        .bestPick_i(bestPick_req_2_dte),
        .bestPick_bk_id_i(bestPick_bk_id_2_dte),
        .dte_out_2_icache_o(dte_2_icache),
        .dte_out_2_dcache_o(dte_2_dcache),
        .mem_2_dte_i(mem_2_dte),
        .dte_2_mem_o(dte_2_mem),
        .dte_2_dma_o(dte_2_dma),
        .dte_2_ddr5_o(dte_2_ddr5)
    );

    mem_TOP uut1_mem (
        .clk(clk),
        .rst(rst),
        //adress and data bus
        .address_bus(address_bus),
        .data_bus(data_bus),
        //arb stuff
        .inFromDte(dte_2_mem),
        .out2Dte(mem_2_dte),
        .out2Sch()
    );

    initial begin
        `LOG("Starting mem System TB");
        //drive all signals going into dte to 0, shoudl just be memvalid right?
        //also need to give it a scheudler pick, no_req in this case
        rst = 0;  //active low
        mem_2_dte.mem_Ready = 0;
        bestPick_req_2_dte = NO_REQ;
        bestPick_bk_id_2_dte = 0;
        DelayClks(5);
        rst = 1;
        DelayClks(5);
        @(posedge clk) mem_2_dte.mem_Ready = 0;
        bestPick_req_2_dte   = ICACHE_HIGH_PRI;
        bestPick_bk_id_2_dte = 0;
        @(posedge clk) bestPick_req_2_dte = NO_REQ;
        mem_2_dte.mem_Ready = 1;  //ld0 - MEMREQ
        @(posedge clk)  //ICACHE_LD0
        @(posedge clk)  //ICACHE_LD1
        @(posedge clk)  //ICACHE_LD2
        @(posedge clk)
        @(negedge clk)
        assert (uut0_DTE.dte_mem_2_icache_fsm_state == DTE_MEM_2_ICACHE_IDLE)
        else $error("Assert fail: Icache transation should be complete: should be IDLE \
                     GOT: %d ", uut0_DTE.dte_mem_2_icache_fsm_state);

        mem_2_dte.mem_Ready  = 0;
        bestPick_req_2_dte   = DCACHE_FILL_LD;
        bestPick_bk_id_2_dte = 1;
        @(posedge clk) bestPick_req_2_dte = ICACHE_LOW_PRI_REQ;
        @(posedge clk) @(posedge clk) @(posedge clk) bestPick_req_2_dte = DCACHE_EB_BLOCKING_LD;
        bestPick_bk_id_2_dte = 3;
        mem_2_dte.mem_Ready  = 1;
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(negedge clk)
        assert (uut0_DTE.dte_mem_2_dcache_fsm_state[1] == DTE_MEM_2_DCACHE_IDLE)
        else $error("Assert fail: dcache_2_mem should be IDLE");

        @(posedge clk)
        //should see store req
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)


        // let it idle for a bit, shoudl countinues to rx no_reqs from
        // sceduler
        DelayClks(
            20);
        //now give it a pick ...
        //need to test all the picks and getting new picks while one fsm is
        //running to enure that another dte fsm doesnt startup
        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(30);
        $finish;
        `LOG("Finishing mem System TB");
    end
endmodule
