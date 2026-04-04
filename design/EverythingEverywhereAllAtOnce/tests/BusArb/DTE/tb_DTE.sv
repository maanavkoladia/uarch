

import common_pkg::*;
import interconnect_pkg::*;
import DTE_FSM_gen_pkg::*;
import core_common_pkg::*;

//import print_icache_pkg::*;
   
    // LOWER (layer 0)
    `define ICACHE_PRINT_LINE_LOWER(ROW) \
        $display("Lower Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
            ROW, \
            /*u_icache.icache_TagStore_unit.validStore[ROW]*/ \
            tb_DTE.uut1_icache.icache_TagStore_unit.tag_store_ramCell_Lower.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[0].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[1].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[2].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[3].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[4].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[5].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[6].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[7].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[8].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[9].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[10].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[11].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[12].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[13].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[14].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[0].g_memCells[15].dataStore_memCell.mem[ROW] \
        );

    // UPPER (layer 1)
    `define ICACHE_PRINT_LINE_UPPER(ROW) \
        $display("Upper Idx: %0d, Tag: %02h | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", \
            ROW, \
            tb_DTE.uut1_icache.icache_TagStore_unit.tag_store_ramCell_Upper.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[0].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[1].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[2].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[3].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[4].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[5].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[6].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[7].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[8].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[9].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[10].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[11].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[12].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[13].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[14].dataStore_memCell.mem[ROW], \
            tb_DTE.uut1_icache.icache_dataStore_unit.g_mem_layer[1].g_memCells[15].dataStore_memCell.mem[ROW] \
        );


    task automatic display_icache_contents();

        $display("==== ICache Contents ====");
        $display("Valid Bits:");
        for(int i = 0; i < 16; i++ ) $display("IDX: %2d, V: %0d", i, tb_DTE.uut1_icache.icache_TagStore_unit.validStore[i]);
        $display("==========================================================");
            

        // Lower (0–7)
        `ICACHE_PRINT_LINE_LOWER(0)
        `ICACHE_PRINT_LINE_LOWER(1)
        `ICACHE_PRINT_LINE_LOWER(2)
        `ICACHE_PRINT_LINE_LOWER(3)
        `ICACHE_PRINT_LINE_LOWER(4)
        `ICACHE_PRINT_LINE_LOWER(5)
        `ICACHE_PRINT_LINE_LOWER(6)
        `ICACHE_PRINT_LINE_LOWER(7)

        // Upper (0–7)
        `ICACHE_PRINT_LINE_UPPER(0)
        `ICACHE_PRINT_LINE_UPPER(1)
        `ICACHE_PRINT_LINE_UPPER(2)
        `ICACHE_PRINT_LINE_UPPER(3)
        `ICACHE_PRINT_LINE_UPPER(4)
        `ICACHE_PRINT_LINE_UPPER(5)
        `ICACHE_PRINT_LINE_UPPER(6)
        `ICACHE_PRINT_LINE_UPPER(7)

    endtask


module tb_DTE ();
    localparam int Clk_PERIOD = 20;

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
    logic [31:0] addres_bus_drv;
    logic [31:0] data_bus_drv;

    //================== CORE ==================
    icache_2_core_t icache_2_core;
    core_2_icache_t core_2_icache;
    icache_2_scheduler_t icache_2_scheduler;
    icache_2_core_t icache_info_i;
    idm_outputs_t idm_info_i;
    decode_outputs_t decode_outs_i;
    rr_outputs_t rr_outs_i;
    dc_outputs_t dc_outs_i;
    mem_outputs_t mem_outs_i;
    exe_outputs_t exe_outs_i;
    wb_outputs_t wb_outs_i;
    wire dma_int;
    fetch_outputs_t fetch_outs_o;

    rr_latches_t rr_latches, rr_latches_next;
    dc_latches_t dc_latches, dc_latches_next;
    mem_latches_t mem_latches, mem_latches_next;
    exe_latches_t exe_latches, exe_latches_next;
    wb_latches_t wb_latches, wb_latches_next;

    // ================= ICACHE =================
    dte_2_icache_t dte_2_icache;

    // ================= DCACHE =================
    dte_2_dcache_t dte_2_dcache;

    // ================= MEMORY =================
    mem_2_dte_t mem_2_dte;
    dte_2_mem_t dte_2_mem;

    // ================= DMA =================
    dte_2_dma_controller_t dte_2_dma;

    // ================= DDR5 =================
    dte_2_ddr5_t dte_2_ddr5;
    mem_2_scheduler_t mem_2_sch;

    //sch pick signals
    req_2_sch_t bestPick_req_2_dte;
    logic [$clog2(NUM_DCACHE_PORTS) - 1 : 0] bestPick_bk_id_2_dte;

    dcache_2_core_t DCacheIn_i;
    assign DCacheIn_i = '{default: 0};

    wire RR_we;


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
        .out2Sch(mem_2_sch)
    );

    ICache uut1_icache(
      .clk(clk),
      .rst(rst),
      .inFromCore_i(fetch_outs_o.fetch_2_icache),
      .out2Core_o(icache_2_core),
// from dte drive bus tristate, and memvalid for fsm control
      .inFromDte_i(dte_2_icache),
      .out2Sch_o(icache_2_scheduler),
//okay mankey
     .dataBus(data_bus),
     .addrBus(address_bus)
    );

    Fetch fetch_uut(
        .clk(clk),
        .rst(rst),
        .icache_info_i(icache_2_core),
        .idm_info_i(idm_info_i),
        .decode_outs_i(decode_outs_i),
        .rr_outs_i(rr_outs_i),
        .dc_outs_i(dc_outs_i),
        .mem_outs_i(mem_outs_i),
        .exe_outs_i(exe_outs_i),
        .wb_outs_i(wb_outs_i),
        .dma_int('0),
        .outs_o(fetch_outs_o)
    );

    IDM idm_uut1(
        .clk(clk),
        .rst(rst),
        .fetch_outs_i(fetch_outs_o),
        .idm_outs_o(idm_info_i)
    );

    Decode decode_uut(
        .clk(clk),
        .rst(rst),
        .cs_limit(32'hFFFF_FFFF),    //fill have to feed in real cs_limit at some point
        .idm_outs_i(idm_info_i),
        .fetch_outs_i(fetch_outs_o),
        .rr_outs_i(rr_outs_i),
        .dc_outs_i(dc_outs_i),
        .mem_outs_i(mem_outs_i),
        .exe_outs_i(exe_outs_i),
        .wb_outs_i(wb_outs_i),
        .rr_latches_next(rr_latches_next),
        .outs_o(decode_outs_i),
        .latch_we_o(RR_we)
    );

    RR_Latches rr_latches_unit (
        .clk(clk),
        .rst(rst),
        .write_enable_i(RR_we),
        .nextLatches_i(rr_latches_next),
        .latches_o(rr_latches)
    );

    RR rr_uut(
        .clk(clk),
        .rst(rst),
        .latches_i(rr_latches),
        .fetch_outs_i(fetch_outs_o),
        .decode_outs_i(decode_outs_i),
        .dc_outs_i(dc_outs_i),
        .mem_outs_i(mem_outs_i),
        .exe_outs_i(exe_outs_i),
        .wb_outs_i(wb_outs_i),
        .dc_latches_next(dc_latches_next),
        .outs_o(rr_outs_i)
    );

    // DC_Latches dc_latches_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .nextLatches_i(dc_latches_next),
    //     .latches_o(dc_latches)
    // );

    // DC dc_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .latches_i(dc_latches),
    //     .mem_outs_i(mem_outs_i),
    //     .exe_outs_i(exe_outs_i),
    //     .wb_outs_i(wb_outs_i),
    //     .mem_latches_next_o(mem_latches_next),
    //     .req_rejected_mio(DCacheIn_i.req_rejected_mio),
    //     .req_rejected_0(DCacheIn_i.req_rejected_0),
    //     .req_rejected_1(DCacheIn_i.req_rejected_1),
    //     .dc_outs_o(dc_outs_i)
    // );

    // MEM_Latches mem_latches_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .nextLatches_i(mem_latches_next),
    //     .latches_o(mem_latches)
    // );

    // MEM mem_unit (
    //     .clk(clk),
    //     .rst(rst),

    //     .latches_i (mem_latches),
    //     .exe_outs_i(exe_outs_i),
    //     .wb_outs_i (wb_outs_i),

    //     .hit_line_0(DCacheIn_i.hit_line_0),  //this onyl goes high if valid
    //     .line_0(DCacheIn_i.line_0),
    //     .hit_line_1(DCacheIn_i.hit_line_1),
    //     .line_1(DCacheIn_i.line_1),
    //     .exe_latches_next_o(exe_latches_next),
    //     .hit_line_MMIO(DCacheIn_i.hit_line_MIO),
    //     .line_MMIO(DCacheIn_i.line_MIO),
    //     .outs_o(mem_outs_i)
    // );

    // EXE_Latches exe_latches_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .nextLatches_i(exe_latches_next),
    //     .latches_o(exe_latches)
    // );

    // EXE execute_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .latches_i(exe_latches),
    //     .wb_outs_i(wb_outs_i),
    //     .wb_latches_next_o(wb_latches_next),
    //     .outs_o(exe_outs_i)
    // );

    // WB_Latches wb_latches_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .nextLatches_i(wb_latches_next),
    //     .latches_o(wb_latches)
    // );

    // WB write_back_unit (
    //     .clk(clk),
    //     .rst(rst),
    //     .wb_latches(wb_latches),
    //     .write_success(DCacheIn_i.writeSuccess),
    //     .write_success_mio(DCacheIn_i.writeSuccess_MIO),
    //     .outputs(wb_outs_i)
    // );

    Scheduler uut0_scheduler (
        .clk(clk),
        .rst(rst),  //active low
        .iCache_2_Sch_i(icache_2_scheduler),
        .dCache_2_Sch_i('{default : '0}),
        .mem_2_Sch_i(mem_2_sch),
        .dma_2_sch_i('{default : '0}),
        .bestPick_o(bestPick_req_2_dte),
        .bestPick_bk_id_o(bestPick_bk_id_2_dte)
    );

    // assign decode_outs_i = '{
    //     valid: 0,
    //     stall:  0,
    //     eip: 32'h1000,
    //     invalid_instruction:  0,
    //     decode_gp: 0
    // };

    
    //code segment is at 0
    //assign rr_outs_i = '{default: '0};
    //decode worked fine when I had this above line uncommented
    //need to check how the rr_outs_i is being set or initialized
    assign dc_outs_i = '{default: '0};
    assign mem_outs_i = '{default: '0};
    assign exe_outs_i = '{default: '0};
    assign wb_outs_i = '{default: '0};




    icache_loader icacheLoader();
    tb_memGen_InitRitual memLoader();



    assign data_bus = data_bus_drv;
    assign data_bus_drv = 'z;
    assign address_bus = dte_2_icache.driveAddrBus ? 32'h1000 : 'z;
  

    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        //drive all signals going into dte to 0, shoudl just be memvalid right?
        //also need to give it a scheudler pick, no_req in this case
        rst = 0;  //active low


        //bestPick_req_2_dte = NO_REQ;
        DelayClks(20);
        @(posedge clk)
        //bestPick_req_2_dte   = ICACHE_HIGH_PRI;
        @(posedge clk)
        force fetch_uut.SPC = 32'h1000;
        @(posedge clk)
        rst = 1;
        release fetch_uut.SPC;
        @(posedge clk)
        display_state();

        
        

        

        @(posedge clk) 
        //bestPick_req_2_dte   = ICACHE_HIGH_PRI;
        //bestPick_bk_id_2_dte = 0;
        //@(posedge clk) bestPick_req_2_dte = NO_REQ;
  
        
        @(posedge clk)  //ICACHE_LD0
        @(posedge clk)  //ICACHE_LD1
        @(posedge clk)  //ICACHE_LD2
        @(posedge clk)
        @(negedge clk)
        assert (uut0_DTE.dte_mem_2_icache_fsm_state == DTE_MEM_2_ICACHE_IDLE)
        else $error("Assert fail: Icache transation should be complete: should be IDLE \
                     GOT: %d ", uut0_DTE.dte_mem_2_icache_fsm_state);

   
        // bestPick_req_2_dte   = DCACHE_FILL_LD;
        // bestPick_bk_id_2_dte = 1;
        // @(posedge clk) bestPick_req_2_dte = ICACHE_LOW_PRI_REQ;
        // @(posedge clk) @(posedge clk) @(posedge clk) bestPick_req_2_dte = DCACHE_EB_BLOCKING_LD;
        // bestPick_bk_id_2_dte = 3;

        DelayClks(9);
        @(posedge clk)
        force decode_uut.EIP = 32'h1000;
        @(posedge clk)
        release decode_uut.EIP;

        // @(posedge clk)
        // @(posedge clk)
        // @(negedge clk)
        // assert (uut0_DTE.dte_mem_2_dcache_fsm_state[1] == DTE_MEM_2_DCACHE_IDLE)
        // else $error("Assert fail: dcache_2_mem should be IDLE");

        // @(posedge clk)
        // //should see store req
        // @(posedge clk)
        // @(posedge clk)
        // @(posedge clk)


        // let it idle for a bit, shoudl countinues to rx no_reqs from
        // sceduler
        DelayClks(20);
        display_icache_contents();
        display_state();
        //now give it a pick ...
        //need to test all the picks and getting new picks while one fsm is
        //running to enure that another dte fsm doesnt startup
        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(100);
        $finish;
        `LOG("Finishing mem System TB");
    end



    task automatic display_state();
        #1;  // Allow combinational logic to settle
        
        $display("  ╔══════════════════════════════════════════════════════════════════════════════╗");
        $display("  ║                          FETCH MODULE STATE                                  ║");
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ Mode Flags:                                                                  ║");
        $display("  ║   exp_mode_jk=%0b  int_mode_jk=%0b  DMA_int_jk=%0b                                 ║",
                  fetch_uut.exp_mode_jk, fetch_uut.int_mode_jk, fetch_uut.DMA_int_jk);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ SPC & Selection:                                                             ║");
        $display("  ║   SPC=0x%08h  next_spc=0x%08h  spc_16=0x%08h                     ║", 
                  fetch_uut.SPC, fetch_uut.next_spc, fetch_uut.spc_16);
        $display("  ║   sel=%s  br_target_sel=%0b  flush_reg=%0b                                 ║",
                  get_spc_sel_name(fetch_uut.spc_sel_logic_outs.sel), 
                  fetch_uut.spc_sel_logic_outs.br_target_sel, fetch_uut.spc_sel_logic_outs.flush_reg);
        $display("  ║   br_target=0x%08h  br_restore_spc=0x%08h                            ║",
                  fetch_uut.spc_sel_logic_outs.br_target, fetch_uut.br_restore_spc);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ TLB:                                                                         ║");
        $display("  ║   v_addr=0x%08h  p_addr=0x%08h  valid=%0b                              ║",
                  fetch_uut.seg_xlation_out, fetch_uut.tlb_outs.physical_addr, fetch_uut.tlb_outs.physical_addr_valid);
        $display("  ║   gp_exp=%0b  pageFault=%0b  f_exp=%0b                                             ║",
                  fetch_uut.tlb_outs.gp_exp, fetch_uut.tlb_outs.pageFault, fetch_uut.f_exp);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ ICache Enable Logic:                                                         ║");
        $display("  ║   en_icache=%0b  (exp_mode=%0b  int_mode=%0b  cs_sb=%0b)                             ║",
                  fetch_uut.en_icache, fetch_uut.exp_mode_jk, fetch_uut.int_mode_jk, rr_outs_i.codeSeg_sb);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ Exception Logic:                                                             ║");
        $display("  ║   exp_pipe_clear=%0b  int_pipe_clear=%0b                                         ║",
                  fetch_uut.exp_set_logic_outs.exp_pipe_clear, fetch_uut.exp_set_logic_outs.int_pipe_clear);
        $display("  ║   invalid_instruction=%0b  rr_exp=%0b  rr_exp_pf=%0b                               ║",
                  decode_outs_i.invalid_instruction, rr_outs_i.exp_present, rr_outs_i.exp_pf);
        $display("  ║   rom_sel=0x%02h  rom_idx=%0b                                                  ║",
                  fetch_uut.exp_ctrl_roms.rom_sel, fetch_uut.exp_ctrl_roms.rom_idx);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║                              PIPELINE STATE                                  ║");
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ DECODE Stage:                                                                ║");
        $display("  ║   valid=%0b  invalid_instr=%0b                                                   ║",
                  decode_outs_i.valid, decode_outs_i.invalid_instruction);
        if (decode_outs_i.valid) begin
            $display("  ║   eip=0x%08h                                                             ║",
                      decode_outs_i.eip);
        end
        $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
        $display("  ║ RR Stage:                                                                    ║");
        $display("  ║   valid=%0b  exp_present=%0b  exp_pf=%0b codeSeg_sb=%0b                              ║",
                  rr_outs_i.valid, rr_outs_i.exp_present, rr_outs_i.exp_pf, rr_outs_i.codeSeg_sb);
        if (rr_outs_i.valid) begin
            $display("  ║   codeSeg_sb=%0b                                                               ║",
                      rr_outs_i.codeSeg_sb);
        end
        $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
        $display("  ║ DC Stage:                                                                    ║");
        $display("  ║   valid=%0b                                                                    ║",
                  dc_outs_i.valid);
        $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
        $display("  ║ EXE Stage:                                                                   ║");
        $display("  ║   valid=%0b  br_valid=%0b  br_flush=%0b  br_taken=%0b                                ║",
                  exe_outs_i.valid, exe_outs_i.br_res_out.valid, 
                  exe_outs_i.br_res_out.flush, exe_outs_i.br_res_out.taken);
        if (exe_outs_i.br_res_out.valid) begin
            $display("  ║   br_eip=0x%08h  br_target=0x%08h                                     ║",
                      exe_outs_i.br_res_out.br_eip, exe_outs_i.br_res_out.br_target);
        end
        $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
        $display("  ║ MEM Stage:                                                                   ║");
        $display("  ║   valid=%0b                                                                    ║",
                  mem_outs_i.valid);
        $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
        $display("  ║ WB Stage:                                                                    ║");
        $display("  ║   valid=%0b                                                                    ║",
                  wb_outs_i.valid);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ BTB Output:                                                                  ║");
        $display("  ║   hit=%0b  br_eip=0x%08h  br_target=0x%08h                             ║",
                  fetch_uut.btb_outs.hit, fetch_uut.btb_outs.br_eip, fetch_uut.btb_outs.br_target);
        $display("  ║   XCL=%0b  br_ucond=%0b                                                          ║",
                  fetch_uut.btb_outs.XCL, fetch_uut.btb_outs.br_ucond);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ Predictor:                                                                   ║");
        $display("  ║   taken=%0b                                                                    ║",
                  fetch_uut.predictor_outs.taken);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ Invalidate Logic:                                                            ║");
        $display("  ║   eip=0x%08h  prev_eip=0x%08h                                        ║",
                  decode_outs_i.eip, fetch_uut.idm_invalidate_logic.prev_eip);
        $display("  ║   invalidate: [3]=%0b [2]=%0b [1]=%0b [0]=%0b  no_writes=%0b                           ║",
                  fetch_uut.idm_invalidate_logic_outs.invalidate[3], fetch_uut.idm_invalidate_logic_outs.invalidate[2],
                  fetch_uut.idm_invalidate_logic_outs.invalidate[1], fetch_uut.idm_invalidate_logic_outs.invalidate[0],
                  fetch_uut.idm_invalidate_logic_outs.no_writes);
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ IDM Control Logic:                                                           ║");
        $display("  ║   push_success=%0b                                                             ║",
                  fetch_uut.idm_ctrl_logic_outs.push_success);
        $display("  ║   IDM Requests (per slot):                                                   ║");
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            $display("  ║     [%0d] valid=%0b ld_meta_data=%0b ld_data=%0b br_valid=%0b br_xcl=%0b                 ║",
                      i, fetch_uut.idm_ctrl_logic_outs.idm_input.req[i].valid,
                      fetch_uut.idm_ctrl_logic_outs.idm_input.req[i].ld_meta_data,
                      fetch_uut.idm_ctrl_logic_outs.idm_input.req[i].ld_data,
                      fetch_uut.idm_ctrl_logic_outs.idm_input.req[i].br_valid,
                      fetch_uut.idm_ctrl_logic_outs.idm_input.req[i].br_xcl);
        end
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ IDM State (from idm_info_i):                                                 ║");
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            if (idm_info_i.idm_slots[i].valid) begin
                $display("  ║   Slot %0d: valid=%0b  br_valid=%0b  br_xcl=%0b                                   ║",
                          i, idm_info_i.idm_slots[i].valid, idm_info_i.idm_slots[i].br_valid,
                          idm_info_i.idm_slots[i].br_xcl);
                if (idm_info_i.idm_slots[i].br_valid) begin
                    $display("  ║           br_eip=0x%08h  br_target=0x%08h                         ║",
                              idm_info_i.idm_slots[i].br_eip, idm_info_i.idm_slots[i].br_btb_target);
                end
            end else begin
                $display("  ║   Slot %0d: valid=%0b                                                            ║",
                          i, idm_info_i.idm_slots[i].valid);
            end
        end
        $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
        $display("  ║ Branch Resolution (from EXE):                                                ║");
        $display("  ║   valid=%0b  flush=%0b  taken=%0b  clr_exp_mode=%0b                                  ║",
                  exe_outs_i.br_res_out.valid, exe_outs_i.br_res_out.flush,
                  exe_outs_i.br_res_out.taken, exe_outs_i.br_res_out.clr_exp_mode);
        if (exe_outs_i.br_res_out.valid) begin
            $display("  ║   br_eip=0x%08h  br_target=0x%08h                                         ║",
                      exe_outs_i.br_res_out.br_eip, exe_outs_i.br_res_out.br_target);
        end
        $display("  ╚══════════════════════════════════════════════════════════════════════════════╝");
        $display("");
    endtask

    // Helper to convert SPC_SEL enum to string
    function automatic string get_spc_sel_name(spc_sel_logic_output_options_e sel);
        case (sel)
            Fetch_pkg::SPC: return "SPC     ";
            Fetch_pkg::SPC_P16: return "SPC_P16 ";
            Fetch_pkg::BR_RESTORE: return "BR_RST  ";
            Fetch_pkg::BTB_TARGET: return "BTB_TGT ";
            default: return "UNKNOWN ";
        endcase
    endfunction

endmodule
