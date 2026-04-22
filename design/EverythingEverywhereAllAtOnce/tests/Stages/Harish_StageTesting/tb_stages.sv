import common_pkg::*;
import interconnect_pkg::*;
import DTE_FSM_gen_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import control_store_pkg::*;
import reg_ids_pkg::*;
import Fetch_pkg::*;
import DCache_common_pkg::*;
import WriteBack_pkg::*;

`define CLK_PERIOD 8


module tb_stages();

    //localparam int Clk_PERIOD = 8;
    `include "debugUtils/tb_utils_defs.svh"
   `DEBUG_UTILS_INIT

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    // task automatic DelayClks(input int cycles);
    //     #(Clk_PERIOD * cycles);
    // endtask


    // // ================= CLOCK / RESET =================
    //`CLK_INIT(Clk_PERIOD);
    logic                                                     rst;
    // wire                   [   ADDRESS_BUS_WIDTH_BITS -1 : 0] address_bus;
    // wire                   [     DATA_BUS_WIDTH_BITS - 1 : 0] data_bus;


 
    AllAtOnce_TOP uut_AllAtOnce(
        .clk(clk),
        .rst(rst)
    );
   
    task automatic print_info(input string test_name); begin
        $fdisplay(`LOG_FD, "test name: %s", test_name);
        print_cycle_header();
        print_exe_info();
        $fdisplay(`LOG_FD, "\n\n\n");
    end
    endtask

       


    icache_loader icacheLoader();
    dcache_loader dcache_loader_unit();
    tb_memGen_InitRitual memLoader();
    tlb_loader tlb_loader_unit();
    coreRegLoader core_reg_loader_unit();

    // ===================== DEBUG LOGGER =====================
    int log_fd;
    int cycle_count;

    initial begin
        log_fd = $fopen("pipeline_debug.log", "w");
        if (log_fd == 0) begin
            $display("ERROR: Could not open log file");
            $finish;
        end
        print_info("");
        cycle_count = 0;
    end

    final begin
        if (log_fd != 0) $fclose(log_fd);
    end

    // Cycle counter
    always @(posedge clk) begin
        if (rst) cycle_count <= cycle_count + 1;
    end

    always_ff @(posedge clk) begin
        print_info(" ");
    end

    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        // core_2_dcache = '{default: '0};
        // for (int i = 0; i < NUM_DCACHE_PORTS; i++) core_2_dcache.stq_heads[i].empty = 1;
        // core_2_dcache.stq_info_mio.empty = 1;
        //set_limit_regs();
        rst = 0; 

        DelayClks(20);
        @(posedge clk)
        @(posedge clk)
        force uut_AllAtOnce.core_unit.fetch_unit.SPC = 32'h1000;
        force uut_AllAtOnce.core_unit.decode_unit.EIP = 32'h1000;
        @(posedge clk)
        rst = 1;
        release uut_AllAtOnce.core_unit.fetch_unit.SPC;
        release uut_AllAtOnce.core_unit.decode_unit.EIP;
        @(posedge clk)
        @(posedge clk)


        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(2000);
        //print_all();
        $finish;
        `LOG("Finishing mem System TB");


    // ===================== END DEBUG LOGGER =====================
    end


   // ================= CORE OUTPUTS =================
    // fetch_outputs_t fetch_outs_o;
    // idm_outputs_t idm_info_i;
    // decode_outputs_t decode_outs_i;
    // rr_outputs_t rr_outs_i;
    // dc_outputs_t dc_outs_i;
    // exe_outputs_t exe_outs_i;
    // mem_outputs_t mem_outs_i;
    // wb_outputs_t wb_outs_i;

    // core_2_icache_t core_2_icache;
    // core_2_dcache_t core_2_dcache;

    // // ================= ICACHE OUTPUTS =================
    // icache_2_core_t icache_2_core;
    // icache_2_scheduler_t icache_2_sch;

    // // ================= DCACHE OUTPUTS =================
    // dcache_2_core_t dcache_2_core;
    // dcache_2_scheduler_t dcache_2_sch;

    // // ================= MEMORY OUTPUTS =================
    // mem_2_dte_t mem_2_dte;
    // mem_2_scheduler_t mem_2_sch;

    // // ================= DTE (BUS ARBITRATION) OUTPUTS =================
    // dte_2_icache_t dte_2_icache;
    // dte_2_dcache_t dte_2_dcache;
    // dte_2_mem_t dte_2_mem;
    // dte_2_dma_controller_t dte_2_dma;
    // dte_2_ddr5_t dte_2_ddr5;

    // // ================= DMA OUTPUTS =================
    // //dma_controller_2_scheduler_t dma_2_sch;
    // dma_controller_2_core_t dma_2_core;

    // Everywhere_TOP uut_offcore(
    //     .clk(clk),
    //     .rst(rst),
    //     .core2icache_i(core_2_icache),
    //     .icache2core_o(icache_2_core),
    //     .core2dcache_i(core_2_dcache),
    //     .dcache2core_o(dcache_2_core),
    //     .dma2core_o(dma_2_core)
    // );

    // EveryThing_TOP uut_core(
    //     .clk(clk),
    //     .rst(rst),
    //     .ICacheIn_i(icache_2_core),
    //     .inFromDMA_i(dma_2_core),   
    //     .DCacheIn_i(dcache_2_core),
    //     .out2DCache_o(core_2_dcache),
    //     .out2ICache_o(core_2_icache)
    // );


endmodule



