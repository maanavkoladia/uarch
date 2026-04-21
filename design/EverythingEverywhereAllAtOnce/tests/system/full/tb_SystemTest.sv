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

`define CLK_PERIOD 100


module tb_SystemTest ();

    //localparam int Clk_PERIOD = 8;
    `include "debugUtils/tb_utils_defs.svh"

    `DEBUG_UTILS_INIT

    logic rst;

    AllAtOnce_TOP uut_AllAtOnce (
        .clk(clk),
        .rst(rst)
    );

    task automatic print_info(input string test_name);
        begin
            $fdisplay(`LOG_FD, "test name: %s", test_name);
            print_cycle_header();
            print_exe_info();
            $fdisplay(`LOG_FD, "\n\n\n");
        end
    endtask

    icache_loader icacheLoader ();
    dcache_loader dcache_loader_unit ();
    tb_memGen_InitRitual memLoader ();
    tlb_loader tlb_loader_unit ();
    coreRegLoader core_reg_loader_unit ();

    // ===================== DEBUG LOGGER =====================


    always_ff @(posedge clk) begin
        print_info(" ");
    end

    initial begin
        `LOG("TB Starting");
        $display("%m");
        // core_2_dcache = '{default: '0};
        // for (int i = 0; i < NUM_DCACHE_PORTS; i++) core_2_dcache.stq_heads[i].empty = 1;
        // core_2_dcache.stq_info_mio.empty = 1;
        //set_limit_regs();
        rst = 0;

        DelayClks(20);
        @(posedge clk) @(posedge clk) force uut_AllAtOnce.core_unit.fetch_unit.SPC = 32'h1000;
        force uut_AllAtOnce.core_unit.decode_unit.EIP = 32'h1000;
        @(posedge clk) rst = 1;
        release uut_AllAtOnce.core_unit.fetch_unit.SPC;
        release uut_AllAtOnce.core_unit.decode_unit.EIP;
        @(posedge clk)
        @(posedge clk)


        DelayClks(500);
        //print_all();
        $finish;
        `LOG("TB Done");
    end
endmodule



