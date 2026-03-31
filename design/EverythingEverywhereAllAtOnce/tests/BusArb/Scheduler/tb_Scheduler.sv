import interconnect_pkg::*;
import common_pkg::*;
/*

typedef struct {req_2_sch_t req;} icache_2_scheduler_t;

typedef struct {
    req_2_sch_t req[NUM_DCACHE_PORTS];
    p_address_t evictionBufAddr[NUM_DCACHE_PORTS];

    req_2_sch_t req_mio;
} dcache_2_scheduler_t;

typedef struct {bool writeBuf_V[numWriteBufsInMem];} mem_2_scheduler_t;

typedef struct {
    req_2_sch_t dma_req;
    p_address_t writeBuf_Address;
} dma_controller_2_scheduler_t;

*/

module tb_Scheduler ();

    localparam int Clk_PERIOD = 10;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    // ================= CLOCK / RESET =================
    `CLK_INIT(Clk_PERIOD);
    logic rst;

    icache_2_scheduler_t icache_2_sched;
    dcache_2_scheduler_t dcache_2_sched;
    mem_2_scheduler_t mem_2_sched;
    dma_controller_2_scheduler_t dma_2_sched;
    req_2_sch_t bestPick_req;
    logic [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_i;


    task automatic DelayClks(input int cycles);
        #(Clk_PERIOD * cycles);
    endtask

    Scheduler uut0_scheduler (
        .clk(clk),
        .rst(rst),  //active low
        .iCache_2_Sch_i(icache_2_sched),
        .dCache_2_Sch_i(dcache_2_sched),
        .mem_2_Sch_i(mem_2_sched),
        .dma_2_sch_i(dma_2_sched),
        .bestPick_o(bestPick_req),
        .bestPick_bk_id_o(bestPick_bk_i)
    );

    Scheduler_Golden uut1_scheduler_golden (
        .clk(clk),
        .rst(rst),  //active low
        .iCache_2_Sch_i(icache_2_sched),
        .dCache_2_Sch_i(dcache_2_sched),
        .mem_2_Sch_i(mem_2_sched),
        .dma_2_sch_i(dma_2_sched),
        .bestPick_o(bestPick_req),
        .bestPick_bk_id_o(bestPick_bk_i)
    );

    initial begin
        `LOG("Starting mem System TB");
        rst = 0;  //active low
        icache_2_sched.req = NO_REQ;  //for lds from mem
        for (int i = 0; i < NUM_DCACHE_PORTS; i++) begin
            dcache_2_sched.req = NO_REQ;
            dcache_2_sched.evictionBufAddr = NO_REQ;
        end  //for ld and store to mem and io
        mem_2_sched = '{default: '0};  //write buf status
        dma_2_sched.dma_req = NO_REQ;
        dma_2_sched.dma_req = 0;

        DelayClks(5);
        rst = 1;

        // sceduler
        DelayClks(20);

        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(30);
        $finish;
        `LOG("Finishing mem System TB");
    end

endmodule
