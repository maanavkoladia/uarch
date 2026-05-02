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


module tb_stages ();

    //localparam int Clk_PERIOD = 8;
    `include "debugUtils/tb_utils_defs.svh"
    `DEBUG_UTILS_INIT
    logic    rst;

    uint32_t idm_empty_cycle_counts;
    uint32_t flush_count;
    uint32_t vcache_hits;
    uint32_t icache_hits;
    always_ff @(posedge clk) begin
        if(!rst) begin
            idm_empty_cycle_counts <= 0;
            flush_count <= 0;
            vcache_hits <= 0;
            icache_hits <= 0;
        end
        else begin
            if (`FETCH_UNIT_PATH.outs_o.fetch_2_icache.num_valid_IDM_slots == 0) idm_empty_cycle_counts++;
            if (`EXE_UNIT_PATH.branch_resolution_o.flush == 1) flush_count++;
            if (uut_AllAtOnce.mem_sys_unit.icache_unit.i_vcache_hit == 1) vcache_hits++;
            if (uut_AllAtOnce.mem_sys_unit.icache_unit.icache_hit == 1) icache_hits++;
        end
    end

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end

    logic instruction_commit;
    logic exeforwards;
    logic program_halted;

    logic needToDumpRegFile, needToDumpFlags;

    //same logic as
    logic [31:0] saved_reg_dump_EIP;
    logic [31:0] saved_flag_dump_EIP;
    logic haltcommited;
    logic [31:0] savedFlags;

    assign program_halted = `DECODE_UNIT_PATH.HALT_REG;

    always_comb begin
        instruction_commit = !`EXE_UNIT_PATH.stall_flop && `EXE_UNIT_PATH.outs_o.valid;
        exeforwards = `EXE_UNIT_PATH.wb_stage_we_valid_unit_o && `EXE_UNIT_PATH.wb_stage_next_vaild_o;
    end

    always_ff @(posedge clk) begin
        if(!rst) begin
            haltcommited <= 0;
        end

        if (instruction_commit) begin
            needToDumpRegFile  <= 1;
            saved_reg_dump_EIP <= `EXE_UNIT_PATH.latches_i.EIP;
        end else needToDumpRegFile <= 0;
        if (exeforwards) begin
            needToDumpFlags <= 1;
            saved_flag_dump_EIP <= `EXE_UNIT_PATH.latches_i.EIP;
            savedFlags[CF_IDX] <= `EXE_UNIT_PATH.cf_flag_o;
            savedFlags[PF_IDX] <= `EXE_UNIT_PATH.pf_flag_o;
            savedFlags[AF_IDX] <= `EXE_UNIT_PATH.af_flag_o;
            savedFlags[ZF_IDX] <= `EXE_UNIT_PATH.zf_flag_o;
            savedFlags[SF_IDX] <= `EXE_UNIT_PATH.sf_flag_o;
            savedFlags[DF_IDX] <= `EXE_UNIT_PATH.df_flag_o;
            savedFlags[OF_IDX] <= `EXE_UNIT_PATH.of_flag_o;
        end else needToDumpFlags <= 0;

        if (needToDumpRegFile) dump_regs(saved_reg_dump_EIP);
        if (needToDumpFlags) dump_flags(saved_flag_dump_EIP, savedFlags);
        // if(program_halted && !haltcommited) begin
        //     dump_regs(`DECODE_UNIT_PATH.EIP);
        //     dump_flags(`DECODE_UNIT_PATH.EIP, savedFlags);
        //     haltcommited <= 1;
        // end
    end


    // task automatic DelayClks(input int cycles);
    //     #(Clk_PERIOD * cycles);
    // endtask


    // // ================= CLOCK / RESET =================
    //`CLK_INIT(Clk_PERIOD);
    // wire                   [   ADDRESS_BUS_WIDTH_BITS -1 : 0] address_bus;
    // wire                   [     DATA_BUS_WIDTH_BITS - 1 : 0] data_bus;

    uint32_t finish_time;
    always_ff @(posedge clk) begin
        if (!rst) finish_time <= 0;
        else if (!program_halted) finish_time++;
    end


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
    diskLoader disk_loader_unit ();


    always_ff @(posedge clk) begin
        print_info(" ");
    end

    // // Emit [WB ACTUAL COMMIT] every cycle WB has a valid instruction, and
    // // [REGFILE DUMP] whenever a register write actually occurs.
    // // #1 advances past the NBA region so REGISTERS[] reflects this posedge.
    // always @(posedge clk) begin
    //     #1;
    //     if (`WB_UNIT_PATH.outputs.valid) begin
    //         print_wb_actual_commit();
    //         if (`WB_UNIT_PATH.outputs.DR_0_we || `WB_UNIT_PATH.outputs.DR_1_we)
    //             print_regfile_dump();
    //     end
    // end

    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        // core_2_dcache = '{default: '0};
        // for (int i = 0; i < NUM_DCACHE_PORTS; i++) core_2_dcache.stq_heads[i].empty = 1;
        // core_2_dcache.stq_info_mio.empty = 1;
        //set_limit_regs();
        rst = 0;

        DelayClks(20);
        @(posedge clk) @(posedge clk) force uut_AllAtOnce.core_unit.fetch_unit.SPC = 32'h0000;
        force uut_AllAtOnce.core_unit.decode_unit.EIP = 32'h0000;
        @(posedge clk) rst = 1;
        release uut_AllAtOnce.core_unit.fetch_unit.SPC;
        release uut_AllAtOnce.core_unit.decode_unit.EIP;
        @(posedge clk)
        @(posedge clk)


        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(50000);
        //print_all();
        $display("program completion cycle count: %0d", finish_time);
        $display("flush count: %0d", flush_count);
        $display("idm empty count: %0d", idm_empty_cycle_counts);
        $display("num vcache hits: %0d", vcache_hits);
        $display("num icache hits: %0d", icache_hits);
        $display("Reg Dump File Path: %s", `RTL_REGDUMP_FILE_NAME);
        $display("Flag Dump File Path: %s", `RTL_FLAGDUMP_FILE_NAME);
        $finish;
        `LOG("Finishing mem System TB");




        // ===================== END DEBUG LOGGER =====================
    end


endmodule



