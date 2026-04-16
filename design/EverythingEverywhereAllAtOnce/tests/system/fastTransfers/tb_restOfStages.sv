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
    logic wb_rst;
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

    assign core_2_icache = '{default: '0};


    // ================= DUT INSTANTIATION =================
    WB wb_stage(
        .clk(clk),
        .rst(wb_rst),
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


task automatic print_info(input string test_name); begin
    $fdisplay(`LOG_FD, "test name: %s", test_name);
    print_cycle_header();
    print_wb_info();
    $fdisplay(`LOG_FD, "\n\n\n");
end
endtask

task automatic drive_wb_latches(
    input logic valid,
    input logic ST_OP,
    input logic WB_DR,
    input logic WB_SR,
    input logic ST_XCL,
    input logic [14:0] ST_PADDR_0,
    input logic [14:0] ST_PADDR_1,
    input logic [15:0] ST_BIT_VEC_0,
    input logic [15:0] ST_BIT_VEC_1,
    input logic MIO,
    input logic [31:0] EIP,
    input byte_t res_buf[CACHE_LINES_SIZE_B*2],
    input reg_ids_e sr_id,
    input logic [63:0] sr_data,
    input logic [63:0] dr_data,
    input reg_ids_e dr_id,
    input string test_name
);
begin
   // wb_rst = 0;
    
    wb_rst = 1;
    wb_latches.valid = valid;

    wb_latches.cs = '{
        ST_OP: ST_OP,
        WB_DR: WB_DR,
        WB_SR: WB_SR
    };

    wb_latches.ST_XCL      = ST_XCL;
    wb_latches.ST_PADDR_0  = ST_PADDR_0;
    wb_latches.ST_PADDR_1  = ST_PADDR_1;
    wb_latches.ST_BIT_VEC_0 = ST_BIT_VEC_0;
    wb_latches.ST_BIT_VEC_1 = ST_BIT_VEC_1; // fixed duplicate bug
    wb_latches.MIO         = MIO;
    wb_latches.EIP         = EIP;
    wb_latches.res_buf     = res_buf ;

    wb_latches.sr_id   = sr_id;
    wb_latches.sr_data = sr_data;
    wb_latches.dr_data = dr_data;
    wb_latches.dr_id   = dr_id;
    #3
    print_info(test_name);
end
endtask

    assign core_2_dcache.stq_info_mio = wb_outs.mio_head;
    assign core_2_dcache.stq_heads = wb_outs.stq_heads;


    // ===================== TEST SEQUENCE =====================
    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        rst = 0;
        wb_rst =0;
        wb_latches = '{default: '0};
        core_2_dcache.ld_addr_0_V = 0;
        core_2_dcache.ld_addr_1_V = 0;
        core_2_dcache.ld_addr_0 = 0;
        core_2_dcache.ld_addr_1 = 0;
        core_2_dcache.ld_addr_MIO_V = 0;
        core_2_dcache.ld_addr_MIO = 0;
        //for d$ arb logic,
        for(int i = 0; i < NUM_DCACHE_PORTS; i++)begin
            core_2_dcache.memStage_CLR_REQ[i] = 0;
        end
        core_2_dcache.memStage_CLR_REQ_MIO = 0;

        DelayClks(10);
        rst = 1;
        DelayClks(10);
        @(posedge clk)
        //bits 4-5 is bank
        //bits 6 to 9 is index
        //0 to 3 is offset
        //10 to 14 is tag


        drive_wb_latches(
            1,  // valid
            1,  // ST_OP
            0,  // WB_DR
            1,  // WB_SR
            0,  // ST_XCL
            15'h2000, //ST_PADDR_0
            15'h1010, //ST_PADDR_1
            16'h0ff0, //ST_BIT_VEC1
            16'hff00, //ST_BIT_VEC1
            0,  // MIO
            32'h0000,
            {
                8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h08,
                8'h09,8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F,8'h10,
                8'h11,8'h12,8'h13,8'h14,8'h15,8'h16,8'h17,8'h18,
                8'h19,8'h1A,8'h1B,8'h1C,8'h1D,8'h1E,8'h1F,8'h20
            },
            EAX, //DR_ID
            64'hFFFFFFFF, //DR_DATA
            64'hDDDDDDDD, //SR_DATA
            ECX, //SRID
            "getting Q to stall 0"
        );

        drive_wb_latches(
            1,  // valid
            1,  // ST_OP
            0,  // WB_DR
            1,  // WB_SR
            0,  // ST_XCL
            15'h3000, //ST_PADDR_0
            15'h1010, //ST_PADDR_1
            16'h0ff0, //ST_BIT_VEC1
            16'hff00, //ST_BIT_VEC1
            0,  // MIO
            32'h0000,
            {
                8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h08,
                8'h09,8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F,8'h10,
                8'h11,8'h12,8'h13,8'h14,8'h15,8'h16,8'h17,8'h18,
                8'h19,8'h1A,8'h1B,8'h1C,8'h1D,8'h1E,8'h1F,8'h20
            },
            EAX, //DR_ID
            64'hFFFFFFFF, //DR_DATA
            64'hDDDDDDDD, //SR_DATA
            ECX, //SRID
            "getting Q to stall 1"
        );

        drive_wb_latches(
            1,  // valid
            1,  // ST_OP
            0,  // WB_DR
            1,  // WB_SR
            0,  // ST_XCL
            15'h4000, //ST_PADDR_0
            15'h1010, //ST_PADDR_1
            16'h0ff0, //ST_BIT_VEC1
            16'hff00, //ST_BIT_VEC1
            0,  // MIO
            32'h0000,
            {
                8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h08,
                8'h09,8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F,8'h10,
                8'h11,8'h12,8'h13,8'h14,8'h15,8'h16,8'h17,8'h18,
                8'h19,8'h1A,8'h1B,8'h1C,8'h1D,8'h1E,8'h1F,8'h20
            },
            EAX, //DR_ID
            64'hFFFFFFFF, //DR_DATA
            64'hDDDDDDDD, //SR_DATA
            ECX, //SRID
            "getting Q to stall 2"
        );
        drive_wb_latches(
            1,  // valid
            1,  // ST_OP
            0,  // WB_DR
            1,  // WB_SR
            0,  // ST_XCL
            15'h5000, //ST_PADDR_0
            15'h1010, //ST_PADDR_1
            16'h0ff0, //ST_BIT_VEC1
            16'hff00, //ST_BIT_VEC1
            0,  // MIO
            32'h0000,
            {
                8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h08,
                8'h09,8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F,8'h10,
                8'h11,8'h12,8'h13,8'h14,8'h15,8'h16,8'h17,8'h18,
                8'h19,8'h1A,8'h1B,8'h1C,8'h1D,8'h1E,8'h1F,8'h20
            },
            EAX, //DR_ID
            64'hFFFFFFFF, //DR_DATA
            64'hDDDDDDDD, //SR_DATA
            ECX, //SRID
            "getting Q to stall 3"
        );

        drive_wb_latches(
            1,  // valid
            1,  // ST_OP
            0,  // WB_DR
            1,  // WB_SR
            0,  // ST_XCL
            15'h6000, //ST_PADDR_0
            15'h1010, //ST_PADDR_1
            16'h0ff0, //ST_BIT_VEC1
            16'hff00, //ST_BIT_VEC1
            0,  // MIO
            32'h0000,
            {
                8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h08,
                8'h09,8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F,8'h10,
                8'h11,8'h12,8'h13,8'h14,8'h15,8'h16,8'h17,8'h18,
                8'h19,8'h1A,8'h1B,8'h1C,8'h1D,8'h1E,8'h1F,8'h20
            },
            EAX, //DR_ID
            64'hFFFFFFFF, //DR_DATA
            64'hDDDDDDDD, //SR_DATA
            ECX, //SRID
            "should stall next cycle?"
        );


        drive_wb_latches(
            1,  // valid
            1,  // ST_OP
            0,  // WB_DR
            1,  // WB_SR
            1,  // ST_XCL
            15'h7000, //ST_PADDR_0
            15'h1010, //ST_PADDR_1
            16'h0ff0, //ST_BIT_VEC1
            16'hff00, //ST_BIT_VEC1
            0,  // MIO
            32'h0000,
            {
                8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h08,
                8'h09,8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F,8'h10,
                8'h11,8'h12,8'h13,8'h14,8'h15,8'h16,8'h17,8'h18,
                8'h19,8'h1A,8'h1B,8'h1C,8'h1D,8'h1E,8'h1F,8'h20
            },
            EAX, //DR_ID
            64'hFFFFFFFF, //DR_DATA
            64'hDDDDDDDD, //SR_DATA
            ECX, //SRID
            "should stall now"
        );


        //@(posedge clk)
        DelayClks(200);
        $finish;
    end
endmodule


