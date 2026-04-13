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


module tb_stages();

    localparam int Clk_PERIOD = 8;

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
    assign dma_2_sch = '{default: '0};
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
    
    // mem_TOP uut_mem (
    //     .clk(clk),
    //     .rst(rst),
    //     .address_bus(address_bus),
    //     .data_bus(data_bus),
    //     .inFromDte(dte_2_mem),
    //     .out2Dte(mem_2_dte),
    //     .out2Sch(mem_2_sch)
    // );

    mem_TOP uut_mem (
        .clk(clk),
        .rst(rst),
        .address_bus(address_bus),
        .data_bus(data_bus),
        .inFromDte_ld_req(dte_2_mem.ld_req),
        .inFromDte_st_req(dte_2_mem.st_req),
        .inFromDte_permission2DriveBus(dte_2_mem.permission2DriveBus),
        .out2Dte_mem_Ready(mem_2_dte.mem_Ready),
        .out2Sch_writeBuf_V(mem_2_sch.writeBuf_V)
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

    // ===================== DEBUG LOGGER =====================
    int log_fd;
    int cycle_count;

    initial begin
        log_fd = $fopen("pipeline_debug.log", "w");
        if (log_fd == 0) begin
            $display("ERROR: Could not open log file");
            $finish;
        end
        cycle_count = 0;
    end

    final begin
        if (log_fd != 0) $fclose(log_fd);
    end

    // Cycle counter
    always @(posedge clk) begin
        if (rst) cycle_count <= cycle_count + 1;
    end

    // ===================== REG NAME HELPER =====================
    function automatic string get_reg_name(reg_ids_e id);
        case (id)
            CS:  return "CS ";  DS:  return "DS ";  SS:  return "SS ";
            ES:  return "ES ";  FS:  return "FS ";  GS:  return "GS ";
            EAX: return "EAX";  EBX: return "EBX";  ECX: return "ECX";
            EDX: return "EDX";  ESI: return "ESI";  EDI: return "EDI";
            ESP: return "ESP";  EBP: return "EBP";
            MM0: return "MM0";  MM1: return "MM1";  MM2: return "MM2";
            MM3: return "MM3";  MM4: return "MM4";  MM5: return "MM5";
            MM6: return "MM6";  MM7: return "MM7";
            ETR: return "ETR";  ERROR_REG: return "ERR";  NO_REG: return "---";
            default: return "???";
        endcase
    endfunction

    function automatic string get_op_name(exe_cs_operation_type_e op);
        case (op)
            ADD: return "ADD";   ADC: return "ADC";   AND: return "AND";
            OR:  return "OR ";   NOT: return "NOT";   SAL: return "SAL";
            SAR: return "SAR";   SBB: return "SBB";   BSF: return "BSF";
            CMP: return "CMP";   MOV: return "MOV";   PUSH: return "PSH";
            POP: return "POP";   CALL: return "CAL";  RET: return "RET";
            XCHG: return "XCH";  CMPXCHG: return "CXG";  IRETD: return "IRT";
            default: return "???";
        endcase
    endfunction

    // ===================== HELPER FUNCTIONS =====================
    function automatic string get_spc_sel_name(spc_sel_logic_output_options_e sel);
        case (sel)
            Fetch_pkg::SPC: return "SPC     ";
            Fetch_pkg::SPC_P16: return "SPC_P16 ";
            Fetch_pkg::BR_RESTORE: return "BR_RST  ";
            Fetch_pkg::BTB_TARGET: return "BTB_TGT ";
            default: return "UNKNOWN ";
        endcase
    endfunction

    // ===================== PRINT TASKS =====================

    // --- HEADER ---
    task automatic print_cycle_header();
        $fdisplay(log_fd, "");
        $fdisplay(log_fd, "==================== CYCLE %0d  (t=%0t) ====================", cycle_count, $time);
    endtask

    // --- FETCH ---
    task automatic print_fetch();
        $fdisplay(log_fd, "[FETCH]");
        $fdisplay(log_fd, "  SPC       = 0x%08h   next_spc = 0x%08h   spc+16 = 0x%08h",
            uut_core.fetch_unit.SPC, uut_core.fetch_unit.next_spc, uut_core.fetch_unit.spc_16);
        $fdisplay(log_fd, "  spc_sel   = %s   br_tgt_sel=%0b   flush_reg=%0b",
            get_spc_sel_name(uut_core.fetch_unit.spc_sel_logic_outs.sel),
            uut_core.fetch_unit.spc_sel_logic_outs.br_target_sel,
            uut_core.fetch_unit.spc_sel_logic_outs.flush_reg);
        $fdisplay(log_fd, "  exp_mode  = %0b   int_mode=%0b   DMA_int=%0b   en_icache=%0b",
            uut_core.fetch_unit.exp_mode_jk, uut_core.fetch_unit.int_mode_jk,
            uut_core.fetch_unit.DMA_int_jk, uut_core.fetch_unit.en_icache);
        $fdisplay(log_fd, "  TLB: v_addr=0x%08h  p_addr=0x%08h  valid=%0b  gp=%0b  pf=%0b  f_exp=%0b",
            uut_core.fetch_unit.seg_xlation_out,
            uut_core.fetch_unit.tlb_outs.physical_addr,
            uut_core.fetch_unit.tlb_outs.physical_addr_valid,
            uut_core.fetch_unit.tlb_outs.gp_exp,
            uut_core.fetch_unit.tlb_outs.pageFault,
            uut_core.fetch_unit.f_exp);
        $fdisplay(log_fd, "  BTB: hit=%0b  eip=0x%08h  tgt=0x%08h  XCL=%0b  ucond=%0b",
            uut_core.fetch_unit.btb_outs.hit,
            uut_core.fetch_unit.btb_outs.br_eip,
            uut_core.fetch_unit.btb_outs.br_target,
            uut_core.fetch_unit.btb_outs.XCL,
            uut_core.fetch_unit.btb_outs.br_ucond);
        $fdisplay(log_fd, "  Predictor: taken=%0b", uut_core.fetch_unit.predictor_outs.taken);
        $fdisplay(log_fd, "  ICache: hit=%0b  icache_en=%0b",
            icache_2_core.hit, uut_core.fetch_outputs.fetch_2_icache.icache_en);
    endtask

    // --- IDM ---
    task automatic print_idm();
        $fdisplay(log_fd, "[IDM]  valid_slots=%0d", uut_core.idm_outputs.valid_slots);
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            if (uut_core.idm_outputs.idm_slots[i].valid) begin
                $fwrite(log_fd, "  slot[%0d] V=1  br_v=%0b  br_xcl=%0b",
                    i,
                    uut_core.idm_outputs.idm_slots[i].br_valid,
                    uut_core.idm_outputs.idm_slots[i].br_xcl);
                if (uut_core.idm_outputs.idm_slots[i].br_valid)
                    $fwrite(log_fd, "  br_eip=0x%08h  br_tgt=0x%08h",
                        uut_core.idm_outputs.idm_slots[i].br_eip,
                        uut_core.idm_outputs.idm_slots[i].br_btb_target);
                $fdisplay(log_fd, "");
            end else begin
                $fdisplay(log_fd, "  slot[%0d] V=0", i);
            end
        end
        $fdisplay(log_fd, "  IDM Ctrl: push_success=%0b",
            uut_core.fetch_unit.idm_ctrl_logic_outs.push_success);
        $fwrite(log_fd, "  Invalidate:");
        for (int i = 0; i < NUM_IDM_SLOTS; i++)
            $fwrite(log_fd, " [%0d]=%0b", i, uut_core.fetch_unit.idm_invalidate_logic_outs.invalidate[i]);
        $fdisplay(log_fd, "  no_writes=%0b", uut_core.fetch_unit.idm_invalidate_logic_outs.no_writes);
    endtask

    // --- DECODE (outputs) ---
    task automatic print_decode();
        $fdisplay(log_fd, "[DECODE]");
        $fdisplay(log_fd, "  valid=%0b  eip=0x%08h  invalid_instr=%0b  decode_gp=%0b  rr_latch_we=%0b",
            uut_core.decode_outputs.valid,
            uut_core.decode_outputs.eip,
            uut_core.decode_outputs.invalid_instruction,
            uut_core.decode_outputs.decode_gp,
            uut_core.decode_outputs.rr_stage_latch_we);
    endtask

    // --- RR LATCHES ---
    task automatic print_rr_latches();
        $fdisplay(log_fd, "[RR LATCHES]  useRep=%0b", uut_core.rr_latches.useRep);
        begin
            automatic rr_latches_general_t L = uut_core.rr_latches.useRep ?
                uut_core.rr_latches.rep_latches : uut_core.rr_latches.normal_latches;
            $fdisplay(log_fd, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h", L.valid, L.EIP, L.NEIP);
            $fdisplay(log_fd, "  dr=%s  sr=%s  dr_rd=%0b  sr_rd=%0b  dr_wr=%0b  sr_wr=%0b  datasize=%0d",
                get_reg_name(L.cs.dr_id), get_reg_name(L.cs.sr_id),
                L.cs.dr_rd, L.cs.sr_rd, L.cs.dr_wr, L.cs.sr_wr, L.cs.datasize);
            $fdisplay(log_fd, "  LD_OP=%0b  ST_OP=%0b  MODRM=%0b  RM_IS_DR=%0b",
                L.cs.LD_OP, L.cs.ST_OP, L.cs.MODRM_NEEDED, L.cs.RM_IS_DR);
            $fdisplay(log_fd, "  EXE_CS: OP=%s  br_ucond=%0b  rel_br=%0b  special=%0b  far=%0b",
                get_op_name(L.exe_cs.OP_TYPE), L.exe_cs.br_ucond,
                L.exe_cs.relative_branch, L.exe_cs.special_br, L.exe_cs.is_far);
            $fdisplay(log_fd, "  br_info: v=%0b  eip=0x%08h  xcl=%0b  pred_taken=%0b  spec_tgt=0x%08h",
                L.br_info.valid, L.br_info.br_eip, L.br_info.br_xcl,
                L.br_info.br_pred_taken, L.br_info.speculative_target);
            if (L.sib_needed)
                $fdisplay(log_fd, "  SIB: idx=%s  base=%s  scale=%0d",
                    get_reg_name(L.sib_idx_id), get_reg_name(L.sib_base_id), L.sib_scale);
            if (L.disp_needed)
                $fdisplay(log_fd, "  DISP: size=%s  val=0x%08h",
                    L.disp_size ? "32" : "8", L.displacement);
            $fdisplay(log_fd, "  WB_CS: ST_OP=%0b  WB_DR=%0b  WB_SR=%0b",
                L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR);
        end
    endtask

    // --- RR OUTPUTS ---
    task automatic print_rr_outputs();
        $fdisplay(log_fd, "[RR OUTS]");
        $fdisplay(log_fd, "  valid=%0b  stall=%0b ecx_sb=%0b  cs_sb=%0b  dc_we=%0b",
            uut_core.rr_outputs.valid, uut_core.rr_outputs.stall,
            uut_core.rr_outputs.ecx_sb, uut_core.rr_outputs.codeSeg_sb,
            uut_core.rr_outputs.dc_stage_latch_we);
    endtask

// --- DC LATCHES ---
task automatic print_dc_latches();
    $fdisplay(log_fd, "[DC LATCHES]");
    begin
        automatic dc_latches_t L = uut_core.dc_latches;
        $fdisplay(log_fd, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h",
            L.valid, L.EIP, L.NEIP);
        $fdisplay(log_fd, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
            get_reg_name(L.dr_id), L.dr_data,
            get_reg_name(L.sr_id), L.sr_data);
        $fdisplay(log_fd, "  CS: LD=%0b  ST=%0b  upper8=%0b  dsize=%0d",
            L.cs.LD_OP, L.cs.ST_OP, L.cs.upper8, L.cs.datasize);
        $fdisplay(log_fd, "  LD: vaddr=0x%08h  next_vaddr=0x%08h  limit=0x%08h",
            L.ld_vaddy, L.next_ld_vaddy, L.seg0_limit_w_datasize);
        $fdisplay(log_fd, "  ST: vaddr=0x%08h  next_vaddr=0x%08h  limit=0x%08h",
            L.st_vaddy, L.next_st_vaddy, L.seg1_limit_w_datasize);
        $fdisplay(log_fd, "  br_info: v=%0b  eip=0x%08h  pred_taken=%0b",
            L.br_info.valid, L.br_info.br_eip, L.br_info.br_pred_taken);
        $fdisplay(log_fd, "  EXE_CS: OP=%s  WB_CS: ST=%0b DR=%0b SR=%0b",
            get_op_name(L.exe_cs.OP_TYPE),
            L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR);
        $fdisplay(log_fd, "  imm64=0x%016h", L.imm64);
        $fdisplay(log_fd, "  rr_gp=%0b", L.rr_gp);
    end
endtask

    // --- DC OUTPUTS ---
    task automatic print_dc_outputs();
        $fdisplay(log_fd, "[DC OUTS]");
        $fdisplay(log_fd, "  valid=%0b  stall=%0b  mem_we=%0b",
            uut_core.dc_outputs.valid, uut_core.dc_outputs.stall,
            uut_core.dc_outputs.exp_present, uut_core.dc_outputs.exp_pf,
            uut_core.dc_outputs.mem_stage_latch_we);
        $fdisplay(log_fd, "  ld0: V=%0b addr=0x%04h   ld1: V=%0b addr=0x%04h   mio: V=%0b addr=0x%04h",
            uut_core.dc_outputs.ld_addr_0_V, uut_core.dc_outputs.ld_addr_0,
            uut_core.dc_outputs.ld_addr_1_V, uut_core.dc_outputs.ld_addr_1,
            uut_core.dc_outputs.ld_addr_MIO_V, uut_core.dc_outputs.ld_addr_MIO);
    endtask

    // --- MEM LATCHES ---
    task automatic print_mem_latches();
        $fdisplay(log_fd, "[MEM LATCHES]");
        begin
            automatic mem_latches_t L = uut_core.mem_latches;
            $fdisplay(log_fd, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h", L.valid, L.EIP, L.NEIP);
            $fdisplay(log_fd, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
                get_reg_name(L.dr_id), L.dr_data, get_reg_name(L.sr_id), L.sr_data);
            $fdisplay(log_fd, "  CS: LD=%0b  ST=%0b   data_size_vec=0x%01h",
                L.cs.LD_OP, L.cs.ST_OP, L.data_size_vec);
            $fdisplay(log_fd, "  LD: xcl=%0b  paddr0=0x%04h  paddr1=0x%04h  swap=%0b",
                L.LD_XCL, L.LD_PADDR_0, L.LD_PADDR_1, L.swapLines);
            $fdisplay(log_fd, "  ST: xcl=%0b  paddr0=0x%04h  paddr1=0x%04h  MIO=%0b",
                L.ST_XCL, L.ST_PADDR_0, L.ST_PADDR_1, L.MIO);
            $fdisplay(log_fd, "  EXE_CS: OP=%s  WB_CS: ST=%0b DR=%0b SR=%0b",
                get_op_name(L.exe_cs.OP_TYPE), L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR);
            $fdisplay(log_fd, "  br_info: v=%0b  eip=0x%08h  pred_taken=%0b",
                L.br_info.valid, L.br_info.br_eip, L.br_info.br_pred_taken);
        end
    endtask

    // --- MEM OUTPUTS ---
    task automatic print_mem_outputs();
        $fdisplay(log_fd, "[MEM OUTS]");
        $fdisplay(log_fd, "  valid=%0b  stall=%0b  exe_we=%0b  ST_OP=%0b  ST_XCL=%0b",
            uut_core.mem_outputs.valid, uut_core.mem_outputs.stall,
            uut_core.mem_outputs.exe_stage_latch_we,
            uut_core.mem_outputs.ST_OP, uut_core.mem_outputs.ST_XCL);
        $fdisplay(log_fd, "  ST_PADDR_0=0x%04h  ST_PADDR_1=0x%04h",
            uut_core.mem_outputs.ST_PADDR_0, uut_core.mem_outputs.ST_PADDR_1);
        $fdisplay(log_fd, "  DCache: hit0=%0b  hit1=%0b  hit2=%0b  hit3=%0b  hitMIO=%0b",
            dcache_2_core.hit[0], dcache_2_core.hit[1], dcache_2_core.hit[2], 
            dcache_2_core.hit[3], dcache_2_core.hit_MIO);
    endtask

    // --- EXE LATCHES ---
    task automatic print_exe_latches();
        $fdisplay(log_fd, "[EXE LATCHES]");
        begin
            automatic exe_latches_t L = uut_core.exe_latches;
            $fdisplay(log_fd, "  valid=%0b  EIP=0x%08h  NEIP=0x%08h", L.valid, L.EIP, L.NEIP);
            $fdisplay(log_fd, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
                get_reg_name(L.dr_id), L.dr_data, get_reg_name(L.sr_id), L.sr_data);
            $fdisplay(log_fd, "  CS: OP=%s  ST=%0b   data_size_vec=0x%01h",
                get_op_name(L.cs.OP_TYPE), L.cs.ST_OP, L.data_size_vec);
            $fdisplay(log_fd, "  inputA_sel=%0d  inputB_sel=%0d  br_tgt_sel=%0d",
                L.cs.alu_inputA_sel, L.cs.alu_inputB_sel, L.cs.branch_target_sel);
            $fdisplay(log_fd, "  br_info: v=%0b  eip=0x%08h  xcl=%0b  pred_taken=%0b  spec_tgt=0x%08h",
                L.br_info.valid, L.br_info.br_eip, L.br_info.br_xcl,
                L.br_info.br_pred_taken, L.br_info.speculative_target);
            $fdisplay(log_fd, "  ST: xcl=%0b  paddr0=0x%04h  paddr1=0x%04h  MIO=%0b",
                L.ST_XCL, L.ST_PADDR_0, L.ST_PADDR_1, L.MIO);
            $fdisplay(log_fd, "  imm64=0x%016h  ld_addy=0x%04h",
                L.imm64, L.ld_addy);
            $fdisplay(log_fd, "  WB_CS: ST=%0b DR=%0b SR=%0b",
                L.wb_cs.ST_OP, L.wb_cs.WB_DR, L.wb_cs.WB_SR);
            // First line (bytes 0–15)
            $fwrite(log_fd, "LD_BUF: ");
            for (int i = 0; i < 16; i++) begin
                $fwrite(log_fd, "%02x", L.ld_buf[i]);
                if (i != 15) $fwrite(log_fd, "_");
            end
            $fwrite(log_fd, "\n");

            // Second line (bytes 16–31)
            $fwrite(log_fd, "         "); // indent to align
            for (int i = 16; i < 32; i++) begin
                $fwrite(log_fd, "%02x", L.ld_buf[i]);
                if (i != 31) $fwrite(log_fd, "_");
            end
            $fdisplay(log_fd, "");
        end
    endtask

    // --- EXE OUTPUTS + BRANCH RESOLUTION ---
    task automatic print_exe_outputs();
        $fdisplay(log_fd, "[EXE OUTS]");
        $fdisplay(log_fd, "  valid=%0b  wb_we=%0b  ST_OP=%0b  ST_XCL=%0b  clr_ZF_sb=%0b  ZF=%0b",
            uut_core.exe_outputs.valid, uut_core.exe_outputs.wb_stage_latch_we,
            uut_core.exe_outputs.ST_OP, uut_core.exe_outputs.ST_XCL,
            uut_core.exe_outputs.clr_ZF_sb, uut_core.exe_outputs.ZF);
        begin
            automatic exe_br_resolution_outputs_t B = uut_core.exe_outputs.br_res_out;
            $fdisplay(log_fd, "  BR_RES: valid=%0b  flush=%0b  farFlush=%0b  mispredict=%0b  taken=%0b",
                B.valid, B.flush, B.farFlush, B.miss_prediction, B.taken);
            if (B.valid)
                $fdisplay(log_fd, "    eip=0x%08h  neip=0x%08h  tgt=0x%08h  xcl=%0b  ucond=%0b  clr_exp=%0b",
                    B.br_eip, B.neip, B.br_target, B.br_XCL, B.br_ucond, B.clr_exp_mode);
        end
    endtask

    // --- WB LATCHES ---
    task automatic print_wb_latches();
        $fdisplay(log_fd, "[WB LATCHES]");
        begin
            automatic wb_latches_t L = uut_core.wb_latches;
            $fdisplay(log_fd, "  valid=%0b  CS: ST=%0b  WB_DR=%0b  WB_SR=%0b",
                L.valid, L.cs.ST_OP, L.cs.WB_DR, L.cs.WB_SR);
            $fdisplay(log_fd, "  dr=%s(0x%016h)  sr=%s(0x%016h)",
                get_reg_name(L.dr_id), L.dr_data, get_reg_name(L.sr_id), L.sr_data);
            $fdisplay(log_fd, "  ST: xcl=%0b  paddr0=0x%04h  bv0=0x%04h  paddr1=0x%04h  bv1=0x%04h  MIO=%0b",
                L.ST_XCL, L.ST_PADDR_0, L.ST_BIT_VEC_0,
                L.ST_PADDR_1, L.ST_BIT_VEC_1, L.MIO);
            // First line (bytes 0–15)
            $fwrite(log_fd, "RES_BUF: ");
            for (int i = 0; i < 16; i++) begin
                $fwrite(log_fd, "%02x", L.res_buf[i]);
                if (i != 15) $fwrite(log_fd, "_");
            end
            $fwrite(log_fd, "\n");

            // Second line (bytes 16–31)
            $fwrite(log_fd, "         "); // indent to align
            for (int i = 16; i < 32; i++) begin
                $fwrite(log_fd, "%02x", L.res_buf[i]);
                if (i != 31) $fwrite(log_fd, "_");
            end
            $fdisplay(log_fd, "");
        end
    endtask

    // --- WB OUTPUTS ---
    task automatic print_wb_outputs();
        $fdisplay(log_fd, "[WB OUTS]");
        $fdisplay(log_fd, "  valid=%0b  wb_stall=%0b",
            uut_core.wb_outputs.valid, uut_core.wb_outputs.wb_stall);
        $fdisplay(log_fd, "  DR0: we=%0b  id=%s  data=0x%016h",
            uut_core.wb_outputs.DR_0_we,
            get_reg_name(uut_core.wb_outputs.DR_0_id),
            uut_core.wb_outputs.DR_0_data);
        $fdisplay(log_fd, "  DR1: we=%0b  id=%s  data=0x%016h",
            uut_core.wb_outputs.DR_1_we,
            get_reg_name(uut_core.wb_outputs.DR_1_id),
            uut_core.wb_outputs.DR_1_data);
    endtask

    // --- STALLS & FLUSHES ---
    task automatic print_stalls();
        $fdisplay(log_fd, "[STALLS & FLUSHES]");
        $fdisplay(log_fd, "  RR_stall=%0b  DC_stall=%0b  MEM_stall=%0b  WB_stall=%0b",
            uut_core.rr_outputs.stall,
            uut_core.dc_outputs.stall,
            uut_core.mem_outputs.stall,
            uut_core.wb_outputs.wb_stall);
        $fdisplay(log_fd, "  flush=%0b  farFlush=%0b  exp_pipe_clear=%0b  int_pipe_clear=%0b",
            uut_core.exe_outputs.br_res_out.flush,
            uut_core.exe_outputs.br_res_out.farFlush,
            uut_core.fetch_unit.exp_set_logic_outs.exp_pipe_clear,
            uut_core.fetch_unit.exp_set_logic_outs.int_pipe_clear);
        $fdisplay(log_fd, "  RR_exp=%0b  RR_exp_pf=%0b  decode_invalid=%0b  decode_gp=%0b",
            uut_core.dc_outputs.exp_present,
            uut_core.dc_outputs.exp_pf,
            uut_core.decode_outputs.invalid_instruction,
            uut_core.decode_outputs.decode_gp);
    endtask

    // --- REGISTER FILE ---
    task automatic print_regfile();
        $fdisplay(log_fd, "[REGISTER FILE]");
        $fwrite(log_fd, "  ");
        for (int i = 0; i < NUM_REGS; i++) begin
            $fwrite(log_fd, "%s=0x%08h  ",
                get_reg_name(reg_ids_e'(i)),
                uut_core.rr_unit.RegisterFile_unit.REGISTERS[i][31:0]);
            if ((i % 6) == 5) begin
                $fdisplay(log_fd, "");
                $fwrite(log_fd, "  ");
            end
        end
        $fdisplay(log_fd, "");
    endtask

    // --- SCOREBOARD ---
    task automatic print_scoreboard();
        $fdisplay(log_fd, "[SCOREBOARD]");
        $fwrite(log_fd, "  ");
        for (int i = 0; i < NUM_REGS; i++) begin
            if (uut_core.rr_unit.reg_sb_unit.SCORE_BOARD[i].counter != 0)
                $fwrite(log_fd, "%s=%0d  ",
                    get_reg_name(reg_ids_e'(i)),
                    uut_core.rr_unit.reg_sb_unit.SCORE_BOARD[i].counter);
        end
        $fdisplay(log_fd, "");
        $fdisplay(log_fd, "  dep_stall=%0b  ecx_sb=%0b  cs_sb=%0b",
            uut_core.rr_unit.reg_sb_unit.dep_stall,
            uut_core.rr_unit.reg_sb_unit.ecx_sb,
            uut_core.rr_unit.reg_sb_unit.codeSeg_sb);
    endtask

    // --- STORE QUEUES ---
    task automatic print_one_stq(int idx, st_q_outputs_t outs);
        $fdisplay(log_fd, "  STQ[%0d]: full=%0b  empty=%0b  push_fail=%0b",
            idx, outs.full, outs.empty, outs.push_fail);
        if (!outs.empty) begin
            $fdisplay(log_fd, "    HEAD: addr=0x%04h  bv=0x%04h",
                outs.head_address, outs.bit_vec);
        end
        for (int e = 0; e < ST_Q_DEPTH; e++) begin
            if (outs.valid[e])
                $fdisplay(log_fd, "    [%0d] V=1 addr=0x%04h", e, outs.address[e]);
        end
    endtask

    task automatic print_store_queues();
        $fdisplay(log_fd, "[STORE QUEUES]");
        print_one_stq(0, uut_core.write_back_unit.stq_outputs[0]);
        print_one_stq(1, uut_core.write_back_unit.stq_outputs[1]);
        print_one_stq(2, uut_core.write_back_unit.stq_outputs[2]);
        print_one_stq(3, uut_core.write_back_unit.stq_outputs[3]);
    endtask

    // --- MIO QUEUE ---
    task automatic print_mio_queue();
        $fdisplay(log_fd, "[MIO QUEUE]");
        $fdisplay(log_fd, "  full=%0b  empty=%0b",
            uut_core.write_back_unit.mio_q_inst.full,
            uut_core.write_back_unit.mio_q_inst.empty);
        if (!uut_core.write_back_unit.mio_q_inst.empty) begin
            $fdisplay(log_fd, "  entry: v=%0b  addr=0x%04h  data[0:3]=%02h %02h %02h %02h",
                uut_core.write_back_unit.mio_q_inst.mio_q.valid,
                uut_core.write_back_unit.mio_q_inst.mio_q.address,
                uut_core.write_back_unit.mio_q_inst.mio_q.data[0],
                uut_core.write_back_unit.mio_q_inst.mio_q.data[1],
                uut_core.write_back_unit.mio_q_inst.mio_q.data[2],
                uut_core.write_back_unit.mio_q_inst.mio_q.data[3]);
        end
    endtask

    // --- DCACHE ARBITRATION ---
    task automatic print_dcache_arb();
        $fdisplay(log_fd, "[DCACHE ARB]");
        $fdisplay(log_fd, "  req_served_0=%0b  req_served_1=%0b  req_served_mio=%0b",
            dcache_2_core.reqServed_0,
            dcache_2_core.reqServed_1,
            dcache_2_core.reqServed_MIO);
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            $fdisplay(log_fd, "  blk[%0d]: oe=%0b  we=%0b  addr=0x%04h  hit=%0b  ws=%0b  sch_req=%0d",
                i,
                uut_dcache.req_2_blocks[i].oe,
                uut_dcache.req_2_blocks[i].we,
                uut_dcache.req_2_blocks[i].p_addr,
                uut_dcache.hitVec[i],
                dcache_2_core.writeSuccess[i],
                uut_dcache.out2Sch_o.req[i]);
        end
    endtask

    // ===================== MASTER PRINT =====================
    task automatic print_all();
        #1; // let combinational logic settle
        print_cycle_header();
        print_fetch();
        print_idm();
        print_decode();
        print_rr_latches();
        print_rr_outputs();
        print_dc_latches();
        print_dc_outputs();
        print_mem_latches();
        print_mem_outputs();
        print_exe_latches();
        print_exe_outputs();
        print_wb_latches();
        print_wb_outputs();
        $fdisplay(log_fd, "");
        print_stalls();
        print_regfile();
        print_scoreboard();
        $fdisplay(log_fd, "");
        print_store_queues();
        print_mio_queue();
        print_dcache_arb();
    endtask

    // ===================== AUTO-PRINT EVERY CYCLE =====================
    always @(posedge clk) begin
        if (rst) print_all();
    end

    // ===================== END DEBUG LOGGER =====================

    initial begin
        `LOG("Starting mem System TB");
        $display("%m");
        set_limit_regs();
        rst = 0; 

        DelayClks(20);
        @(posedge clk)
        @(posedge clk)
        force uut_core.fetch_unit.SPC = 32'h1000;
        force uut_core.decode_unit.EIP = 32'h1000;
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
        DelayClks(300);
        print_all();
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
            uut_core.rr_unit.SEGMENT_LIMITS[CS_LIMIT_ID].limit[0] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[CS_LIMIT_ID].limit[1] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[CS_LIMIT_ID].limit[2] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[CS_LIMIT_ID].limit[3] = 32'hFFFF_FFFF;

            uut_core.rr_unit.SEGMENT_LIMITS[DS_LIMIT_ID].limit[0] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[DS_LIMIT_ID].limit[1] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[DS_LIMIT_ID].limit[2] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[DS_LIMIT_ID].limit[3] = 32'hFFFF_FFFF;

            uut_core.rr_unit.SEGMENT_LIMITS[SS_LIMIT_ID].limit[0] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[SS_LIMIT_ID].limit[1] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[SS_LIMIT_ID].limit[2] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[SS_LIMIT_ID].limit[3] = 32'hFFFF_FFFF;

            uut_core.rr_unit.SEGMENT_LIMITS[ES_LIMIT_ID].limit[0] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[ES_LIMIT_ID].limit[1] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[ES_LIMIT_ID].limit[2] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[ES_LIMIT_ID].limit[3] = 32'hFFFF_FFFF;

            uut_core.rr_unit.SEGMENT_LIMITS[FS_LIMIT_ID].limit[0] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[FS_LIMIT_ID].limit[1] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[FS_LIMIT_ID].limit[2] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[FS_LIMIT_ID].limit[3] = 32'hFFFF_FFFF;

            uut_core.rr_unit.SEGMENT_LIMITS[GS_LIMIT_ID].limit[0] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[GS_LIMIT_ID].limit[1] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[GS_LIMIT_ID].limit[2] = 32'hFFFF_FFFF;
            uut_core.rr_unit.SEGMENT_LIMITS[GS_LIMIT_ID].limit[3] = 32'hFFFF_FFFF;
    endtask

endmodule



