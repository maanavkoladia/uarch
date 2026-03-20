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
    bool exp_mode_jk;
    bool int_mode_jk;
    bool DMA_int_jk; //corresponds to unterrupt "unit" Need to figure out how to clear int bit
    l_address_t SPC;


    //wires
    bool f_exp;
    v_address_t seg_xlation_out;
    bool seg_xlation_gp_fault; //not used
    byte_t rom_data_out[CACHE_LINES_SIZE_B];
    byte_t idm_ctrl_data_in[CACHE_LINES_SIZE_B];
    l_address_t next_spc;
    l_address_t spc_16;
    l_address_t br_restore_spc;
    l_address_t br_target;

    predictor_input_t predictor_inputs;
    tlb_inputs_t tlb_inputs;

    //logic block outputs
    btb_output_t btb_outs;
    spc_sel_logic_output_t spc_sel_logic_outs;
    predictor_output_t predictor_outs;
    idm_ctrl_logic_output_t idm_ctrl_logic_outs;
    idm_invalidate_logic_output_t idm_invalidate_logic_outs;
    icache_en_logic_output_t icache_en_logic_outs;
    tlb_outputs_t tlb_outs;
    exp_set_logic_output_t exp_set_logic_outs;

    //gate logic





    assign f_exp = tlb_outs.gp_exp & tlb_outs.pageFault & ~exp_mode_jk;


    assign tlb_inputs = '{
        virtual_addr : seg_xlation_out, //seg_Xlation outputs
        write_intention : '0
    };

    assign predictor_inputs = '{
        btfn_target: btb_outs.br_target,
        spc: SPC,
        exe_br_valid: exe_outs_i.br_res_out.valid,
        exe_br_target: exe_outs_i.br_res_out.br_target,
        exe_br_taken: exe_outs_i.br_res_out.taken,
        exe_br_hit: exe_outs_i.br_res_out.taken
    };

    assign idm_ctrl_data_in = (exp_mode_jk ||int_mode_jk) ?
                               icache_info_i.instruction_line : rom_data_out;

    assign br_restore_spc = exe_outs_i.br_res_out.taken
                          ? exe_outs_i.br_res_out.br_target
                          : exe_outs_i.br_res_out.br_eip;

    assign br_target =  spc_sel_logic_outs.br_target_sel ?
                        spc_sel_logic_outs.br_target
                        : btb_outs.br_target;

    always_comb begin
        case(spc_sel_logic_outs.sel)
            SPC: next_spc = SPC;
            SPC_P16: next_spc = spc_16;
            BR_RESTORE: next_spc = br_restore_spc;
            BTB_TARGET: next_spc = br_target;
            default: next_spc = 0;
        endcase
    end

    //DMA JK
    always_ff@(posedge clk or posedge rst) begin
        if(rst)
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
    always_ff@(posedge clk or posedge rst) begin
        if(rst)
            exp_mode_jk <= 0;
        else begin
            case({exp_set_logic_outs.exp_pipe_clear, exe_outs_i.br_res_out.clr_exp_mode})
                2'b00: exp_mode_jk <= exp_mode_jk;
                2'b01: exp_mode_jk <= 0;
                2'b10: exp_mode_jk <= 1;
                2'b11: exp_mode_jk <= ~exp_mode_jk;
                default: exp_mode_jk <= exp_mode_jk;
            endcase
        end
    end

//int JK
    always_ff@(posedge clk or posedge rst) begin
        if(rst)
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
    always_ff@(posedge clk or posedge rst)begin
        if(rst) SPC <= 0;
        else begin
            SPC <= next_spc;
        end
    end

    BTB btb(
        .clk(clk),
        .reset(rst),
        .spc(SPC), //address

        .exe_br_valid(exe_outs_i.br_res_out.valid), //bool
        .exe_br_target(exe_outs_i.br_res_out.br_target), //address_t
        .exe_br_eip(exe_outs_i.br_res_out.br_eip), //address_t
        .exe_br_XCL(exe_outs_i.br_res_out.br_XCL),
        .exe_br_ucond(exe_outs_i.br_res_out.br_ucond), //bool
        .outputs(btb_outs) //BTB_outputs_t
    );

    Predictor predictor(
        .inputs(predictor_inputs),
        .outputs(predictor_outs)
    );

    SPC_Sel_Logic spc_sel_logic(
        .clk(clk),
        .rst(rst),
        .flush(exe_outs_i.br_res_out.flush),

        //probably not needed
        .decode_stall(decode_outs_i.stall),

        .btb_outputs(btb_outs), //btb outs struct
        .pred_out(predictor_outs), //predictor_outputs_t
        .idm_ctrl_logic_out(idm_ctrl_logic_outs), //for push success

        .outputs(spc_sel_logic_outs)
    );


    IDM_Ctrl_Logic idm_ctrl_logic (
        .spc(SPC),
        .idm_i(idm_info_i),
        .invalidate_logic_outs_i(idm_invalidate_logic_outs),
        .btb_out_i(btb_outs),
        .pred_out_i(predictor_outs),
        .icache_out_i(icache_info_i),
        .spc_sel_logic_out_i(spc_sel_logic_outs),
        .data_in(idm_ctrl_data_in),
        .out(idm_ctrl_logic_outs)
    );


    IDM_Invalidate_Logic idm_invalidate_logic(
        .clk(clk),
        .rst(rst),
        .eip(decode_outs_i.eip),
        .flush(exe_outs_i.br_res_out.flush),
        .exp_pipeclear(exp_set_logic_outs.exp_pipe_clear),
        .decode_stall(decode_outs_i.stall),
        .idm_meta(idm_info_i),

        .out_invalidates(idm_invalidate_logic_outs)
    );


    EXP_Set_logic exp_set_logic(
        .invalid_instruction(decode_outs_i.invalid_instruction),
        .rr_valid(rr_outs_i.valid),
        .dc_valid(dc_outs_i.valid),
        .mem_valid(mem_outs_i.valid),
        .exe_valid(exe_outs_i.valid),
        .wb_valid(wb_outs_i.valid),
        .f_exp(f_exp),
        .rr_exp(rr_outs_i.exp_present),
        .int_set(DMA_int_jk),
        .outputs(exp_set_logic_outs)
    );

    EXP_Ctrl_ROMS exp_ctrl_roms(
        .RR_pf(rr_outs_i.exp_pf),
        .RR_exp(rr_outs_i.exp_present),
        .Fetch_pf(tlb_outs.pageFault),
        .DMA_int(DMA_int_jk),
        .exp_mode(exp_mode_jk),
        .rom_data_out(rom_data_out)
    );


    //spc to icache path
    ICache_En_Logic icache_en_logic(
        .exp_mode(exp_mode_jk),
        .cs_sb(rr_outs_i.codeSeg_sb),
        .int_mode(int_mode_jk),

        .out(icache_en_logic_outs)
    );

    TLB tlb(
        .inputs(tlb_inputs),
        .outputs(tlb_outs)
    );

    SegmentTranslation seg_Xlation(
        .clk(clk),
        .rst(rst),
        .l_addr_i(SPC),
        .dataSize_i(1'b0),
        .segID_i(reg_ids_pkg::CS),
        .v_addr_o(seg_xlation_out),
        .gp_fault_o(seg_xlation_gp_fault)
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



