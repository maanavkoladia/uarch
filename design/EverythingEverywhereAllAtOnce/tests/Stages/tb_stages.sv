import common_pkg::*;
import interconnect_pkg::*;
import DTE_FSM_gen_pkg::*;
import core_common_pkg::*;


module tb_stages();

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


    // ================= CORE OUTPUTS =================
    // fetch_outputs_t fetch_outs_o;
    // idm_outputs_t idm_info_i;
    // decode_outputs_t decode_outs_i;
    // rr_outputs_t rr_outs_i;
    // dc_outputs_t dc_outs_i;
    // exe_outputs_t exe_outs_i;
    // mem_outputs_t mem_outs_i;
    // wb_outputs_t wb_outs_i;

    core_2_icache_t core_2_icache;
    core_2_dcache_t core_2_dcache;

    // ================= CORE LATCHES =================
    rr_latches_t rr_latches, rr_latches_next;
    dc_latches_t dc_latches, dc_latches_next;
    exe_latches_t exe_latches, exe_latches_next;
    mem_latches_t mem_latches, mem_latches_next;
    wb_latches_t wb_latches, wb_latches_next;

    // ================= ICACHE OUTPUTS =================
    icache_2_core_t icache_2_core;
    icache_2_scheduler_t icache_2_sch;

    // ================= DCACHE OUTPUTS =================
    dcache_2_core_t dcache_2_core;
    dcache_2_scheduler_t dcache_2_sch;

    // ================= MEMORY OUTPUTS =================
    mem_2_dte_t mem_2_dte;
    mem_2_scheduler_t mem_2_sch;

    // ================= DTE (BUS ARBITRATION) OUTPUTS =================
    dte_2_icache_t dte_2_icache;
    dte_2_dcache_t dte_2_dcache;
    dte_2_mem_t dte_2_mem;
    dte_2_dma_controller_t dte_2_dma;
    dte_2_ddr5_t dte_2_ddr5;

    // ================= DMA OUTPUTS =================
    dma_controller_2_scheduler_t dma_2_sch;
    dma_controller_2_core_t dma_2_core;

    assign dma_2_core = '{default: '0};

   BusArbitration uut4_busArb (
        .clk(clk),
        .rst(rst),
        .iCache_2_Sch_i(icache_2_sch),
        .dCache_2_Sch_i(dcache_2_sch),
        .mem_2_Sch_i(mem_2_sch),
        .mem_2_dte_i(mem_2_dte),
        .dma_2_sch_i(dma_2_sch),
        .dte_2_mem_o(dte_2_mem),        
        .dte_out_2_icache_o(dte_2_icache),
        .dte_out_2_dcache_o(dte_2_dcache),
        .dte_2_dma_o(),
        .dte_2_ddr5_o()
    );
    
    mem_TOP uut_mem (
        .clk(clk),
        .rst(rst),
        .address_bus(address_bus),
        .data_bus(data_bus),
        .inFromDte(dte_2_mem),
        .out2Dte(mem_2_dte),
        .out2Sch(mem_2_sch)
    );

    DCache_TOP uut_dcache (
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core_2_dcache),
        .out2Core_o(dcache_2_core),
        .inFromDTE_i(dte_2_dcache),
        .out2Sch_o(dcache_2_sch),
        .dataBus(data_bus),
        .address_bus(address_bus)
    );

    ICache uut_icache(
        .clk(clk),
        .rst(rst),
        .inFromCore_i(core_2_icache),
        .out2Core_o(icache_2_core),
        .inFromDte_i(dte_2_icache),
        .out2Sch_o(icache_2_sch),
        .dataBus(data_bus),
        .addrBus(address_bus)
    );

    EveryThing_TOP uut_core(
        .clk(clk),
        .rst(rst),
        .ICacheIn_i(icache_2_core),
        .inFromDMA_i(dma_2_core),   
        .DCacheIn_i(dcache_2_core),
        .out2DCache_o(core_2_dcache),
        .out2ICache_o(core_2_icache)
    );
   

    icache_loader icacheLoader();
    dcache_loader dcache_loader_unit();
    tb_memGen_InitRitual memLoader();

  

    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        rst = 0; 

        DelayClks(20);
        @(posedge clk)
        @(posedge clk)
        force uut_core.fetch_unit.SPC = 32'h1000;
        force uut_core.decode_unit.EIP = 32'h1000;
        set_limit_regs();
        @(posedge clk)
        rst = 1;
        release uut_core.fetch_unit.SPC;
        release uut_core.decode_unit.EIP;
        @(posedge clk)
        @(posedge clk)         


   

      
        /////////////////////////////////////////////////////////////////////////////////////
        //Extra completion time
        /////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////
        DelayClks(100);
        $finish;
        `LOG("Finishing mem System TB");
    end



    // task automatic display_state();
    //     #1;  // Allow combinational logic to settle
        
    //     $display("  ╔══════════════════════════════════════════════════════════════════════════════╗");
    //     $display("  ║                          FETCH MODULE STATE                                  ║");
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ Mode Flags:                                                                  ║");
    //     $display("  ║   exp_mode_jk=%0b  int_mode_jk=%0b  DMA_int_jk=%0b                                 ║",
    //               uut_core.fetch_unit.exp_mode_jk, uut_core.fetch_unit.int_mode_jk, uut_core.fetch_unit.DMA_int_jk);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ SPC & Selection:                                                             ║");
    //     $display("  ║   SPC=0x%08h  next_spc=0x%08h  spc_16=0x%08h                     ║", 
    //               uut_core.fetch_unit.SPC, uut_core.fetch_unit.next_spc, uut_core.fetch_unit.spc_16);
    //     $display("  ║   sel=%s  br_target_sel=%0b  flush_reg=%0b                                 ║",
    //               get_spc_sel_name(uut_core.fetch_unit.spc_sel_logic_outs.sel), 
    //               uut_core.fetch_unit.spc_sel_logic_outs.br_target_sel, uut_core.fetch_unit.spc_sel_logic_outs.flush_reg);
    //     $display("  ║   br_target=0x%08h  br_restore_spc=0x%08h                            ║",
    //               uut_core.fetch_unit.spc_sel_logic_outs.br_target, uut_core.fetch_unit.br_restore_spc);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ TLB:                                                                         ║");
    //     $display("  ║   v_addr=0x%08h  p_addr=0x%08h  valid=%0b                              ║",
    //               uut_core.fetch_unit.seg_xlation_out, uut_core.fetch_unit.tlb_outs.physical_addr, uut_core.fetch_unit.tlb_outs.physical_addr_valid);
    //     $display("  ║   gp_exp=%0b  pageFault=%0b  f_exp=%0b                                             ║",
    //               uut_core.fetch_unit.tlb_outs.gp_exp, uut_core.fetch_unit.tlb_outs.pageFault, uut_core.fetch_unit.f_exp);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ ICache Enable Logic:                                                         ║");
    //     $display("  ║   en_icache=%0b  (exp_mode=%0b  int_mode=%0b  cs_sb=%0b)                             ║",
    //               uut_core.fetch_unit.en_icache, uut_core.fetch_unit.exp_mode_jk, uut_core.fetch_unit.int_mode_jk, rr_outs_i.codeSeg_sb);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ Exception Logic:                                                             ║");
    //     $display("  ║   exp_pipe_clear=%0b  int_pipe_clear=%0b                                         ║",
    //               uut_core.fetch_unit.exp_set_logic_outs.exp_pipe_clear, uut_core.fetch_unit.exp_set_logic_outs.int_pipe_clear);
    //     $display("  ║   invalid_instruction=%0b  rr_exp=%0b  rr_exp_pf=%0b                               ║",
    //               decode_outs_i.invalid_instruction, rr_outs_i.exp_present, rr_outs_i.exp_pf);
    //     $display("  ║   rom_sel=0x%02h  rom_idx=%0b                                                  ║",
    //               uut_core.fetch_unit.exp_ctrl_roms.rom_sel, uut_core.fetch_unit.exp_ctrl_roms.rom_idx);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║                              PIPELINE STATE                                  ║");
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ DECODE Stage:                                                                ║");
    //     $display("  ║   valid=%0b  invalid_instr=%0b                                                   ║",
    //               decode_outs_i.valid, decode_outs_i.invalid_instruction);
    //     if (decode_outs_i.valid) begin
    //         $display("  ║   eip=0x%08h                                                             ║",
    //                   decode_outs_i.eip);
    //     end
    //     $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
    //     $display("  ║ RR Stage:                                                                    ║");
    //     $display("  ║   valid=%0b  exp_present=%0b  exp_pf=%0b codeSeg_sb=%0b                              ║",
    //               rr_outs_i.valid, rr_outs_i.exp_present, rr_outs_i.exp_pf, rr_outs_i.codeSeg_sb);
    //     if (rr_outs_i.valid) begin
    //         $display("  ║   codeSeg_sb=%0b                                                               ║",
    //                   rr_outs_i.codeSeg_sb);
    //     end
    //     $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
    //     $display("  ║ DC Stage:                                                                    ║");
    //     $display("  ║   valid=%0b                                                                    ║",
    //               dc_outs_i.valid);
    //     $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
    //     $display("  ║ EXE Stage:                                                                   ║");
    //     $display("  ║   valid=%0b  br_valid=%0b  br_flush=%0b  br_taken=%0b                                ║",
    //               exe_outs_i.valid, exe_outs_i.br_res_out.valid, 
    //               exe_outs_i.br_res_out.flush, exe_outs_i.br_res_out.taken);
    //     if (exe_outs_i.br_res_out.valid) begin
    //         $display("  ║   br_eip=0x%08h  br_target=0x%08h                                     ║",
    //                   exe_outs_i.br_res_out.br_eip, exe_outs_i.br_res_out.br_target);
    //     end
    //     $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
    //     $display("  ║ MEM Stage:                                                                   ║");
    //     $display("  ║   valid=%0b                                                                    ║",
    //               mem_outs_i.valid);
    //     $display("  ╠──────────────────────────────────────────────────────────────────────────────╣");
    //     $display("  ║ WB Stage:                                                                    ║");
    //     $display("  ║   valid=%0b                                                                    ║",
    //               wb_outs_i.valid);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ BTB Output:                                                                  ║");
    //     $display("  ║   hit=%0b  br_eip=0x%08h  br_target=0x%08h                             ║",
    //               uut_core.fetch_unit.btb_outs.hit, uut_core.fetch_unit.btb_outs.br_eip, uut_core.fetch_unit.btb_outs.br_target);
    //     $display("  ║   XCL=%0b  br_ucond=%0b                                                          ║",
    //               uut_core.fetch_unit.btb_outs.XCL, uut_core.fetch_unit.btb_outs.br_ucond);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ Predictor:                                                                   ║");
    //     $display("  ║   taken=%0b                                                                    ║",
    //               uut_core.fetch_unit.predictor_outs.taken);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ Invalidate Logic:                                                            ║");
    //     $display("  ║   eip=0x%08h  prev_eip=0x%08h                                        ║",
    //               decode_outs_i.eip, uut_core.fetch_unit.idm_invalidate_logic.prev_eip);
    //     $display("  ║   invalidate: [3]=%0b [2]=%0b [1]=%0b [0]=%0b  no_writes=%0b                           ║",
    //               uut_core.fetch_unit.idm_invalidate_logic_outs.invalidate[3], uut_core.fetch_unit.idm_invalidate_logic_outs.invalidate[2],
    //               uut_core.fetch_unit.idm_invalidate_logic_outs.invalidate[1], uut_core.fetch_unit.idm_invalidate_logic_outs.invalidate[0],
    //               uut_core.fetch_unit.idm_invalidate_logic_outs.no_writes);
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ IDM Control Logic:                                                           ║");
    //     $display("  ║   push_success=%0b                                                             ║",
    //               uut_core.fetch_unit.idm_ctrl_logic_outs.push_success);
    //     $display("  ║   IDM Requests (per slot):                                                   ║");
    //     for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
    //         $display("  ║     [%0d] valid=%0b ld_meta_data=%0b ld_data=%0b br_valid=%0b br_xcl=%0b                 ║",
    //                   i, uut_core.fetch_unit.idm_ctrl_logic_outs.idm_input.req[i].valid,
    //                   uut_core.fetch_unit.idm_ctrl_logic_outs.idm_input.req[i].ld_meta_data,
    //                   uut_core.fetch_unit.idm_ctrl_logic_outs.idm_input.req[i].ld_data,
    //                   uut_core.fetch_unit.idm_ctrl_logic_outs.idm_input.req[i].br_valid,
    //                   uut_core.fetch_unit.idm_ctrl_logic_outs.idm_input.req[i].br_xcl);
    //     end
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ IDM State (from idm_info_i):                                                 ║");
    //     for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
    //         if (idm_info_i.idm_slots[i].valid) begin
    //             $display("  ║   Slot %0d: valid=%0b  br_valid=%0b  br_xcl=%0b                                   ║",
    //                       i, idm_info_i.idm_slots[i].valid, idm_info_i.idm_slots[i].br_valid,
    //                       idm_info_i.idm_slots[i].br_xcl);
    //             if (idm_info_i.idm_slots[i].br_valid) begin
    //                 $display("  ║           br_eip=0x%08h  br_target=0x%08h                         ║",
    //                           idm_info_i.idm_slots[i].br_eip, idm_info_i.idm_slots[i].br_btb_target);
    //             end
    //         end else begin
    //             $display("  ║   Slot %0d: valid=%0b                                                            ║",
    //                       i, idm_info_i.idm_slots[i].valid);
    //         end
    //     end
    //     $display("  ╠══════════════════════════════════════════════════════════════════════════════╣");
    //     $display("  ║ Branch Resolution (from EXE):                                                ║");
    //     $display("  ║   valid=%0b  flush=%0b  taken=%0b  clr_exp_mode=%0b                                  ║",
    //               uut_core.exe_outs_i.br_res_out.valid, exe_outs_i.br_res_out.flush,
    //               exe_outs_i.br_res_out.taken, exe_outs_i.br_res_out.clr_exp_mode);
    //     if (exe_outs_i.br_res_out.valid) begin
    //         $display("  ║   br_eip=0x%08h  br_target=0x%08h                                         ║",
    //                   exe_outs_i.br_res_out.br_eip, exe_outs_i.br_res_out.br_target);
    //     end
    //     $display("  ╚══════════════════════════════════════════════════════════════════════════════╝");
    //     $display("");
    // endtask

    // // Helper to convert SPC_SEL enum to string
    // function automatic string get_spc_sel_name(spc_sel_logic_output_options_e sel);
    //     case (sel)
    //         Fetch_pkg::SPC: return "SPC     ";
    //         Fetch_pkg::SPC_P16: return "SPC_P16 ";
    //         Fetch_pkg::BR_RESTORE: return "BR_RST  ";
    //         Fetch_pkg::BTB_TARGET: return "BTB_TGT ";
    //         default: return "UNKNOWN ";
    //     endcase
    // endfunction

    //task to set limit regs
    task automatic set_limit_regs();
            uut_core.rr_unit.SEGMENT_LIMITS[CS_LIMIT_ID] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[DS_LIMIT_ID] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[SS_LIMIT_ID] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[ES_LIMIT_ID] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[FS_LIMIT_ID] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[GS_LIMIT_ID] = 32'hFFFF_FFFF;
    endtask

endmodule



