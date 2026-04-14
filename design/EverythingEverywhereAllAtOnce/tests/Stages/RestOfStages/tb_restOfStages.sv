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


module tb_restOfStages ();

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
    wire [ADDRESS_BUS_WIDTH_BITS -1 : 0] address_bus;
    wire [DATA_BUS_WIDTH_BITS - 1 : 0] data_bus;

    // ================= SIGNALS =================
    wb_latches_t wb_latches;
    wb_outputs_t wb_outs;
    core_2_icache_t core_2_icache;
    core_2_dcache_t core_2_dcache;
    icache_2_core_t icache_2_core;
    dcache_2_core_t dcache_2_core;
    dma_controller_2_core_t dma_2_core;

    // ================= DUT INSTANTIATION =================
    WB wb_stage(
        .clk(clk),
        .rst(rst),
        .wb_latches(wb_latches),
        .write_success(dcache_2_core.writeSuccess),
        .write_success_mio(dcache_2_core.writeSuccess_MIO),
        .outputs(wb_outs)
    );

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


/*
    typedef struct {
        bool ST_OP;
        bool WB_DR;
        bool WB_SR;
    } wb_cs_t;

    typedef struct {
        bool valid;
        wb_cs_t cs;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline algned
        uint16_t ST_BIT_VEC_0;  //where to write
        p_address_t ST_PADDR_1;  //cacheline algned
        uint16_t ST_BIT_VEC_1;  //where to write
        bool MIO;

        uint32_t EIP; //used for tagging insts, for edebugging

        byte_t res_buf[CACHE_LINES_SIZE_B*2];  //32 byte buf

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

    } wb_latches_t;

*/

    // ===================== TEST SEQUENCE =====================
    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        rst = 0;
        wb_latches <= '{default: '0};
        DelayClks(20);
        @(posedge clk)
        rst = 1;
        DelayClks(20);
        print_cycle_header();
        print_wb_info();

        //@(posedge clk)
        //DelayClks();
        $finish;
    end
endmodule


