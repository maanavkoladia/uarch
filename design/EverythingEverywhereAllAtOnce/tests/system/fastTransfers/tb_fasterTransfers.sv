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

`define CLK_PERIOD (8)


module tb_fasterTransfers ();

    //localparam int Clk_PERIOD = 8;
    `include "debugUtils/tb_utils_defs.svh"

    //task automatic DelayClks(input int cycles);
    //    #(Clk_PERIOD * cycles);
    //endtask

    `DEBUG_UTILS_INIT;

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end


    // ================= CLOCK / RESET =================
    logic rst;

    // ================= SIGNALS =================
    core_2_icache_t core_2_icache;
    core_2_dcache_t core_2_dcache;
    icache_2_core_t icache_2_core;
    dcache_2_core_t dcache_2_core;
    dma_controller_2_core_t dma_2_core;

    assign core_2_icache = '{default: '0};


    // ================= DUT INSTANTIATION =================
    Everywhere_TOP u_everywhere_top (
        .clk(clk),
        .rst(rst),
        .core2icache_i(core_2_icache),
        .icache2core_o(icache_2_core),
        .core2dcache_i(core_2_dcache),
        .dcache2core_o(dcache_2_core),
        .dma2core_o(dma_2_core)
    );

    icache_loader icacheLoader ();
    dcache_loader dcache_loader_unit ();
    tb_memGen_InitRitual memLoader ();


   // wb_rst = 0;
    
    // ===================== TEST SEQUENCE =====================
    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        rst = 0;
        core_2_dcache = '{default: '0};
        for(int i = 0; i < NUM_DCACHE_PORTS; i++) core_2_dcache.stq_heads[i].empty = 1;
        core_2_dcache.stq_info_mio.empty = 1;
        core_2_icache = '{default: '0};
        //for d$ arb logic,

        DelayClks(10);
        rst = 1;
        DelayClks(10);

        DelayClks(50);
        $finish;
    end
endmodule


