import common_pkg::*;
import interconnect_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import Fetch_pkg::*;

module Fetch (
    input wire clk,
    input wire rst,

    //en addr
    input icache_2_core_t icache_info_i,

    input idm_outputs_t idm_info_i,
    //invalid instruction for exp logic, also eip for prev eip invalidate
    //logic
    input decode_outputs_t decode_outs_i,

    //valid and exp logic
    input rr_outputs_t rr_outs_i,

    //valid and exp logic
    input dc_outputs_t dc_outs_i,

    //valid and exp logic
    input mem_outputs_t mem_outs_i,

    //valid, br.valid, br.target, br.eip, br.xcl, br.hit, br.taken, br.flush
    input exe_outputs_t exe_outs_i,

    //valid and exp logic
    input wb_outputs_t wb_outs_i,

    input wire dma_int,

    output fetch_outputs_t outs_o

);



    //internal reg to Fetch
    logic [1:0] exp_mode_jk;
    bool int_mode_jk;
    bool DMA_int_jk; //corresponds to unterrupt "unit" Need to figure out how to clear int bit
    l_address_t SPC;


    //wires
    bool f_exp;
    v_address_t seg_xlation_out;
    byte_t rom_data_out[CACHE_LINES_SIZE_B];
    byte_t idm_ctrl_data_in[CACHE_LINES_SIZE_B];
    l_address_t next_spc;
    l_address_t spc_16;
    l_address_t br_restore_spc;
    l_address_t br_target;
    l_address_t spc_2_IDM_CTRL;

    tlb_inputs_t tlb_inputs;

    //logic block outputs
    btb_output_t btb_outs;
    spc_sel_logic_output_t spc_sel_logic_outs;
    predictor_output_t predictor_outs;
    idm_ctrl_logic_output_t idm_ctrl_logic_outs;
    idm_invalidate_logic_output_t idm_invalidate_logic_outs;
    bool en_icache;
    tlb_outputs_t tlb_outs;
    exp_set_logic_output_t exp_set_logic_outs;

    // ----------------------------------------------------------------
    // Adapter wires bridging the SV structs in this file to the flat
    // ports of the structural Verilog 2005 sub-modules.
    // ----------------------------------------------------------------

    // Per-IDM-slot fields of idm_info_i.idm_slots[*] (consumed by the
    // structural IDM_Ctrl_Logic and IDM_Invalidate_Logic).
    wire        idm_slot_valid_w          [0:NUM_IDM_SLOTS-1];
    wire        idm_slot_br_valid_w       [0:NUM_IDM_SLOTS-1];
    wire [31:0] idm_slot_br_eip_w         [0:NUM_IDM_SLOTS-1];
    wire [31:0] idm_slot_br_btb_target_w  [0:NUM_IDM_SLOTS-1];
    wire        idm_slot_br_xcl_w         [0:NUM_IDM_SLOTS-1];

    // Flat outputs of IDM_Ctrl_Logic, repacked into idm_ctrl_logic_outs.
    wire        idmc_ld_meta_data_w [0:NUM_IDM_SLOTS-1];
    wire        idmc_ld_data_w      [0:NUM_IDM_SLOTS-1];
    wire        idmc_valid_w        [0:NUM_IDM_SLOTS-1];
    wire        idmc_br_valid_w     [0:NUM_IDM_SLOTS-1];
    wire [31:0] idmc_br_eip_w       [0:NUM_IDM_SLOTS-1];
    wire [31:0] idmc_br_target_w    [0:NUM_IDM_SLOTS-1];
    wire        idmc_br_xcl_w       [0:NUM_IDM_SLOTS-1];
    wire [7:0]  idmc_data_w         [0:NUM_IDM_SLOTS-1] [0:CACHE_LINES_SIZE_B-1];
    wire        idmc_push_success_w;

    // SPC sel output as a plain 2-bit wire (cast back to the enum field).
    wire [1:0]  spc_sel_w;

    // Unpack the IDM slot meta into the flat helper arrays
    genvar gs;
    generate
        for (gs = 0; gs < NUM_IDM_SLOTS; gs = gs + 1) begin : g_idm_slot_unpack
            assign idm_slot_valid_w[gs]         = idm_info_i.idm_slots[gs].valid;
            assign idm_slot_br_valid_w[gs]      = idm_info_i.idm_slots[gs].br_valid;
            assign idm_slot_br_eip_w[gs]        = idm_info_i.idm_slots[gs].br_eip;
            assign idm_slot_br_btb_target_w[gs] = idm_info_i.idm_slots[gs].br_btb_target;
            assign idm_slot_br_xcl_w[gs]        = idm_info_i.idm_slots[gs].br_xcl;
        end
    endgenerate

    // Repack IDM_Ctrl_Logic flat outputs back into the SV struct fields
    genvar gs2, gk;
    generate
        for (gs2 = 0; gs2 < NUM_IDM_SLOTS; gs2 = gs2 + 1) begin : g_idmc_repack
            assign idm_ctrl_logic_outs.idm_input.req[gs2].ld_meta_data = idmc_ld_meta_data_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].ld_data      = idmc_ld_data_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].valid        = idmc_valid_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].br_valid     = idmc_br_valid_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].br_eip       = idmc_br_eip_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].br_target    = idmc_br_target_w[gs2];
            assign idm_ctrl_logic_outs.idm_input.req[gs2].br_xcl       = idmc_br_xcl_w[gs2];

            for (gk = 0; gk < CACHE_LINES_SIZE_B; gk = gk + 1) begin : g_idmc_data_repack
                assign idm_ctrl_logic_outs.idm_input.req[gs2].data[gk] = idmc_data_w[gs2][gk];
            end
        end
    endgenerate
    assign idm_ctrl_logic_outs.push_success = idmc_push_success_w;

    // Cast the 2-bit SPC sel output into the enum field
    assign spc_sel_logic_outs.sel = spc_sel_logic_output_options_e'(spc_sel_w);

    //gate logic

    always_comb begin
        outs_o.idm_reqs = idm_ctrl_logic_outs.idm_input;
        outs_o.exp_pipe_clear = exp_set_logic_outs.exp_pipe_clear | exp_set_logic_outs.int_pipe_clear;
        outs_o.fetch_2_icache.icache_en =  en_icache;
        outs_o.fetch_2_icache.p_addr = tlb_outs.physical_addr;
        outs_o.fetch_2_icache.v_addr_i = seg_xlation_out;
        outs_o.fetch_2_icache.num_valid_IDM_slots = idm_info_i.valid_slots;
        outs_o.exp_present = f_exp;
        outs_o.exp_pf = tlb_outs.pageFault;
        outs_o.exp_mode_jk = exp_mode_jk;
        outs_o.int_mode_jk = int_mode_jk;
    end

    assign f_exp = (tlb_outs.gp_exp | tlb_outs.pageFault) & ~exp_mode_jk;


    assign tlb_inputs = '{
        virtual_addr : seg_xlation_out, //seg_Xlation outputs
        write_intention : '0
    };

    assign idm_ctrl_data_in = (exp_mode_jk ||int_mode_jk) ?
                               rom_data_out :icache_info_i.instruction_line;

    assign br_restore_spc = exe_outs_i.br_res_out.taken
                          ? exe_outs_i.br_res_out.br_target
                          : exe_outs_i.br_res_out.neip;

    assign br_target =  spc_sel_logic_outs.br_target_sel ?
                        spc_sel_logic_outs.br_target
                        : btb_outs.br_target;

    assign spc_2_IDM_CTRL = (exp_mode_jk ||int_mode_jk) ? //this might be a stupid way of doing this but I force the slot number address on an exception to 0
                            32'h00000000 : SPC;   //This wont work if we are doing this routine an interrupt comes in during the exception transition...which it shouldnt?

    assign spc_16 = SPC+16;

    always_comb begin
        case(spc_sel_logic_outs.sel)
            Fetch_pkg::SPC: next_spc = SPC;
            Fetch_pkg::SPC_P16: next_spc = spc_16;
            Fetch_pkg::BR_RESTORE: next_spc = {br_restore_spc[31:4], 4'b0};
            Fetch_pkg::BTB_TARGET: next_spc = {br_target[31:4], 4'b0};
            default: next_spc = 0;
        endcase
    end


    
    //DMA JK
    always_ff@(posedge clk) begin
        if(!rst)
            DMA_int_jk <= 0;
        else begin
            case({dma_int, exe_outs_i.br_res_out.clr_exp_mode})
                2'b00: DMA_int_jk <= DMA_int_jk;
                2'b01: DMA_int_jk <= 0;
                2'b10: DMA_int_jk <= 1;
                2'b11: DMA_int_jk <= ~DMA_int_jk;
                default: DMA_int_jk <= DMA_int_jk;
            endcase
        end
    end

    
// exp_mode JK
    always_ff@(posedge clk) begin
        if(!rst)
            exp_mode_jk <= 0;
        else begin
            if(exe_outs_i.br_res_out.flush && exe_outs_i.br_res_out.valid) exp_mode_jk <= 0;
            else begin

                //writing this bc its like the jk logic writen out 
                case({exp_set_logic_outs.exp_pipe_clear, exe_outs_i.br_res_out.clr_exp_mode})
                    2'b00: exp_mode_jk[0] <= exp_mode_jk[0];
                    2'b01: exp_mode_jk[0] <= 0;
                    2'b10: exp_mode_jk[0] <= 1;
                    2'b11: exp_mode_jk[0] <= ~exp_mode_jk[0];
                    default: exp_mode_jk[0] <= exp_mode_jk[0];
                endcase

                case({exp_set_logic_outs.dc_exp_set, exe_outs_i.br_res_out.clr_exp_mode})
                    2'b00: exp_mode_jk[1] <= exp_mode_jk[1];
                    2'b01: exp_mode_jk[1] <= 0;
                    2'b10: exp_mode_jk[1] <= 1;
                    2'b11: exp_mode_jk[1] <= ~exp_mode_jk[1];
                    default: exp_mode_jk[1] <= exp_mode_jk[1];
                endcase

            end
        end
    end

//int JK
    always_ff@(posedge clk) begin
        if(!rst)
            int_mode_jk <= 0;
        else begin
            case({exp_set_logic_outs.int_pipe_clear, exe_outs_i.br_res_out.clr_exp_mode})
                2'b00: int_mode_jk <= int_mode_jk;
                2'b01: int_mode_jk <= 0;
                2'b10: int_mode_jk <= 1;
                2'b11: int_mode_jk <= ~int_mode_jk;
                default: int_mode_jk <= int_mode_jk;
            endcase
        end
    end

    //SPC flop
    always_ff@(posedge clk)begin
        if(!rst) SPC <= 0;
        else begin
            SPC <= next_spc;
        end
    end

    // BTB Training Note:
    // Special branches in exception/interrupt handlers (indicated by CS)
    // do not send training signals (exe_br_valid controlled by execute stage)
    // This prevents exception handler branches from polluting user BTB entries
    BTB btb(
        .clk(clk),
        .rst(rst),
        .spc(SPC), //address

        .exe_br_valid(exe_outs_i.br_res_out.valid), //bool
        .exe_br_target(exe_outs_i.br_res_out.br_target), //address_t
        .exe_br_eip(exe_outs_i.br_res_out.br_eip), //address_t
        .exe_br_XCL(exe_outs_i.br_res_out.br_XCL),
        .exe_br_ucond(exe_outs_i.br_res_out.br_ucond), //bool

        // outputs (struct fields driven individually — module is structural V2005)
        .hit       (btb_outs.hit),
        .br_target (btb_outs.br_target),
        .br_eip    (btb_outs.br_eip),
        .XCL       (btb_outs.XCL),
        .br_ucond  (btb_outs.br_ucond)
    );

    Predictor predictor(
        .clk          (clk),
        .rst          (rst),

        // flat predictor inputs (struct unrolled — only the fields GShare uses)
        .spc          (SPC),
        .btb_hit      (btb_outs.hit),
        .exe_br_valid (exe_outs_i.br_res_out.valid),
        .exe_br_taken (exe_outs_i.br_res_out.taken),
        .exe_br_eip   (exe_outs_i.br_res_out.br_eip),
        .misprediction(exe_outs_i.br_res_out.miss_prediction),

        // flat predictor output
        .taken        (predictor_outs.taken)
    );

    SPC_Sel_Logic spc_sel_logic(
        .clk          (clk),
        .rst          (rst),                                  // active-low directly (was !rst)
        .spc          (SPC),
        .flush        (exe_outs_i.br_res_out.flush),
        .decode_stall (decode_outs_i.stall),                  // unused on the structural side, kept for parity

        // btb_output_t fields
        .btb_hit       (btb_outs.hit),
        .btb_br_target (btb_outs.br_target),
        .btb_br_eip    (btb_outs.br_eip),
        .btb_XCL       (btb_outs.XCL),
        .btb_br_ucond  (btb_outs.br_ucond),

        // predictor_output_t
        .pred_taken            (predictor_outs.taken),

        // push_success from IDM_Ctrl_Logic (only field consumed)
        .idm_ctrl_push_success (idm_ctrl_logic_outs.push_success),

        // spc_sel_logic_output_t fields driven individually
        .sel           (spc_sel_w),                           // cast to enum above
        .br_target_sel (spc_sel_logic_outs.br_target_sel),
        .br_target     (spc_sel_logic_outs.br_target),
        .flush_reg     (spc_sel_logic_outs.flush_reg)
    );


    IDM_Ctrl_Logic idm_ctrl_logic (
        .exp_mode (exp_mode_jk[0]),
        .int_mode (int_mode_jk),
        .spc      (spc_2_IDM_CTRL),

        // idm_outputs_t — only per-slot valid bits used
        .idm_slot_valid (idm_slot_valid_w),

        // idm_invalidate_logic_output_t fields
        .invalidate (idm_invalidate_logic_outs.invalidate),
        .no_writes  (idm_invalidate_logic_outs.no_writes),

        // btb_output_t (br_ucond unused)
        .btb_hit       (btb_outs.hit),
        .btb_br_target (btb_outs.br_target),
        .btb_br_eip    (btb_outs.br_eip),
        .btb_XCL       (btb_outs.XCL),

        // predictor_output_t
        .pred_taken    (predictor_outs.taken),

        // icache_2_core_t — only hit consumed
        .icache_hit    (icache_info_i.hit),

        // spc_sel_logic_output_t — only flush_reg consumed
        .spc_sel_flush_reg (spc_sel_logic_outs.flush_reg),

        // Cacheline data into IDM (selected outside between rom/icache by idm_ctrl_data_in)
        .data_in (idm_ctrl_data_in),

        // idm_ctrl_logic_output_t — flat per-slot outputs (repacked into the struct above)
        .idm_req_ld_meta_data (idmc_ld_meta_data_w),
        .idm_req_ld_data      (idmc_ld_data_w),
        .idm_req_valid        (idmc_valid_w),
        .idm_req_br_valid     (idmc_br_valid_w),
        .idm_req_br_eip       (idmc_br_eip_w),
        .idm_req_br_target    (idmc_br_target_w),
        .idm_req_br_xcl       (idmc_br_xcl_w),
        .idm_req_data         (idmc_data_w),
        .push_success         (idmc_push_success_w)
    );


    IDM_Invalidate_Logic idm_invalidate_logic(
        .clk            (clk),
        .rst            (rst),                                // active-low directly (was !rst)
        .eip            (decode_outs_i.eip),
        .flush          (exe_outs_i.br_res_out.flush),
        .exp_pipeclear  (exp_set_logic_outs.exp_pipe_clear),
        .int_pipe_clear (exp_set_logic_outs.int_pipe_clear),
        .decode_stall   (decode_outs_i.stall),                // unused on the structural side, kept for parity

        // idm_outputs_t — only per-slot fields consumed (cacheline data NOT used here)
        .idm_slot_valid          (idm_slot_valid_w),
        .idm_slot_br_valid       (idm_slot_br_valid_w),
        .idm_slot_br_eip         (idm_slot_br_eip_w),
        .idm_slot_br_btb_target  (idm_slot_br_btb_target_w),
        .idm_slot_br_xcl         (idm_slot_br_xcl_w),

        .decode_forward (decode_outs_i.decode_forward),

        // idm_invalidate_logic_output_t fields driven individually
        .invalidate     (idm_invalidate_logic_outs.invalidate),
        .no_writes      (idm_invalidate_logic_outs.no_writes)
    );


    EXP_Set_logic exp_set_logic(
        .invalid_instruction(decode_outs_i.invalid_instruction),
        .rr_valid(rr_outs_i.valid),
        .dc_valid(dc_outs_i.valid),
        .mem_valid(mem_outs_i.valid),
        .exe_valid(exe_outs_i.valid),
        .wb_valid(wb_outs_i.valid),
        .f_exp(f_exp),
        .dc_exp(dc_outs_i.exp_present),
        .int_set(DMA_int_jk),
        .exp_mode_jk(exp_mode_jk[0]),
        .int_mode_jk(int_mode_jk),

        // exp_set_logic_output_t fields driven individually (structural V2005 module)
        .exp_pipe_clear(exp_set_logic_outs.exp_pipe_clear),
        .dc_exp_set    (exp_set_logic_outs.dc_exp_set),
        .int_pipe_clear(exp_set_logic_outs.int_pipe_clear)
    );

    EXP_Ctrl_ROMS exp_ctrl_roms(
        .clk           (clk),
        .rst           (rst),                                     // newly added on the structural port
        .exp_pipe_clear(exp_set_logic_outs.exp_pipe_clear),
        .int_pipe_clear(exp_set_logic_outs.int_pipe_clear),
        .DC_pf         (dc_outs_i.exp_pf),
        .DC_exp        (dc_outs_i.exp_present),
        .Fetch_pf      (tlb_outs.pageFault),
        .DMA_int       (DMA_int_jk),
        .exp_mode      (exp_mode_jk[0]),
        .rom_data_out  (rom_data_out)
    );


    //spc to icache path
    ICache_En_Logic icache_en_logic(
        .rst(rst),
        .exp_mode(exp_mode_jk[0]),
        .cs_sb(rr_outs_i.codeSeg_sb),
        .int_mode(int_mode_jk),
        .DMA_int(DMA_int_jk),
        .f_exp(f_exp),
        .out(en_icache)
    );

    TLB tlb(
        .inputs(tlb_inputs),
        .outputs(tlb_outs)
    );

    SegmentTranslation seg_Xlation(
        .l_addr_i(SPC),
        .segValue(rr_outs_i.codeSeg_data),
        .segLimit(rr_outs_i.codeSeg_limit),
        .v_addr_o(seg_xlation_out),
        .gp_fault_o()
    );


    endmodule




    /*

    I am going to try to keep all the registers inside of this module and as structural like as possible

    modules in this file:a
    SPC_SEL_LOGIC
    BTB
    Predictor
    iCache_en_logic
    TLB
    Seg_Xlation
    Qcntrl
    InvalidLogic
    EXP_CTRL_ROMS


if(v_bk0 & v_bk1) {
    SPC <= SPC
}

if(~slot0.v && ~spe[4] && icache_v) slot0.ld = 1;
if(~slot1.v && spe[4] && icache_v) slot1.ld = 1;

if(current cache line has branch) pend_br = 1;

invalidate_entry1 = headptr[4] && ~(headptr + inst_length)[4];
invalidate_entry0 = ~headptr[4] && (headptr + inst_length)[4];



question:
invalid bank slot in Q but don't want to load?





/////////////////////////////////
xcl branch problem for SPC fetching (figure 1)
problems:
xbr -> E (regular intrsduction)
xbr -> br
xbr -> xbr

btb outputs xcl, next line, target, br.location

if xcl, load a temp register with br.location with XCL valid bit set. SPC will get SPC + 16

since valid is set, mux will pick br.location instead of SPC to feed into BTB.
This will keep the BTB predicting the same cache line while the SPC moves on to SPC + 16
while valid is set, SPC logic will ignore BTB predictions since you don't want to load SPC with BTB prediction target,
you want to keep SPC the same (SPC + 16 from previous SPC update) so that you finish fetching the next cache line
in which the xcl branch finishes before moving onto the target cache line.

cache will produce hit signal for the next line which will clear the valid bit of the br.location register,
same cycle, SPC will get target from BTB.

this also fixes xbr to xbr situation since valid bit would clear same cycle as SPC update.
This means that there is one cycle of invalidity for the temp register where the updated SPC value is being fed to the BTB
Next cycle the temp register will be loaded with the br.location and valid bit will be set. xcl status would be reupdated.



other problems:
how to invalidate both xcl slots


invalidate slot + xcl when EIP = br.location.
if br.location = EIP, and its not xcl, only invalidate the current slot since slot + xcl = slot + 0 = slot
if xcl then slot + 1 and slot must be invalidated together.



*/



