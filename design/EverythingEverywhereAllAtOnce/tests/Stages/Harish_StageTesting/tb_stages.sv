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

    logic instruction_commit;
    
    logic needToDumpRegFile, needToDumpFlags;

    logic exeforwards;
    //same logic as 
    logic savedEIP, savedFlags;

    always_comb begin
        instruction_commit = !`WB_UNIT_PATH.outputs.stall && `WB_UNIT_PATH.outputs.valid;
        exeforwards = `EXE_UNIT_PATH.wb_stage_we_valid_unit_o && `EXE_UNIT_PATH.wb_stage_next_vaild_o;
    end

    always_ff @(posedge clk) begin
        if(instruction_commit) begin
            needToDumpRegFile <= 1;
            savedEIP <= `WB_UNIT_PATH.wb_latches.EIP;
        end else needToDumpRegFile <= 0;
        if(exeforwards)  begin
            needToDumpFlags <= 1;
            savedEIP = `EXE_UNIT_PATH.latches_i.EIP;
        end else needToDumpFlags <= 0;

        if(needToDumpRegFile) //do the regfile print here, and print the eip
        if(needToDumpFlags)//print the flags and eip for that set of flags
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


endmodule



