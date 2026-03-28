module Decode (
    input wire clk,
    input wire rst,

    //for decoding instructions coming in from fetch
    input idm_outputs_t idm_outs_i,

    //for pipeclear when exp is about to be served and ROM loaded into IDM
    input fetch_outputs_t fetch_outs_i,

    //exc/sb and ZF/sb and valid , and needed for stage latch valid signal
    input rr_outputs_t rr_outs_i,

    //only used for valid logic
    input dc_outputs_t dc_outs_i,

    //only used for valid logic
    input mem_outputs_t mem_outs_i,

    //these are for valid bit shit and exe br res for eip changes and flushing
    input exe_outputs_t exe_outs_i,

    //only used for valid logic
    input wb_outputs_t wb_outs_i,

    //these are the next rr latches harish
    output rr_latches_t rr_latches_next,

    //actual stage bundled outputs
    output decode_outputs_t outs_o

);

    //prefix stuff(ppu s),
    //invalid instruciton logic (i think we dciessed that this needs a bit to redcue critaoth back into exp logic in fetch),
    //modrm LUT,
    //opcode LUT (CS stuff)
    //instuciton len adding
    //sib logic
    //displacment logic
    //immedatite logic
    //segment id gen ()
    //all regs use internal reg_Id_t in the core pkgs
    //
    //rep controller (takes ecx, set/clr zf_sb, zf flag, ecx sb, CS_signal for
    //rep(sthild not be apassed forward is internal to decode)
    //
    //needs to send a gp to rr (eip, preveip, prev instruciton len logic to
    //gen a gp and send it forward to rr to tell it that its corrent
    //isntrucitoni s invlaid and it needs to throw a gp, ie gp not thrown here,
    //it is intdicated to rr that it needs to throw one)
    //
    //br logic so taken info comes from idm not taken still needs to populate
    //the br info because exe needs it for br resolution
    //
    //loigc needed for reading from the idm slots, ie invalid stuff, etc
    //need to have logic for if branch is xcl to send to excecute for btb updates
    //can't just use btb output since if miss then don't have that info



    //modrm LUT,
    //opcode LUT (CS stuff)
    //segment id gen ()
    //all regs use internal reg_Id_t in the core pkgs

    //needs to send a gp to rr (eip, preveip, prev instruciton len logic to
    //gen a gp and send it forward to rr to tell it that its corrent
    //isntrucitoni s invlaid and it needs to throw a gp, ie gp not thrown here,
    //it is intdicated to rr that it needs to throw one)
    //
    //br logic so taken info comes from idm not taken still needs to populate
    //the br info because exe needs it for br resolution
    //
    //loigc needed for reading from the idm slots, ie invalid stuff, etc
    //need to have logic for if branch is xcl to send to excecute for btb updates
    //can't just use btb output since if miss then don't have that info

    //rep controller (takes ecx, set/clr zf_sb, zf flag, ecx sb, CS_signal for
    //rep(sthild not be apassed forward is internal to decode)



    uint32_t neip;
    logic [3:0] instruction_length; //might need for valid logic to determine if full inst is valid
    logic [7:0] sib_byte;
    logic [31:0] disp;
    logic [63:0] imm64;
    logic [9:0] total_pf_vector;
    logic invalid_inst;

    logic [31:0] EIP;

    predecode length_finding(
        .clk(clk), .rst(rst),
        .queue({idm_outs_i.idm_slots[0].data,
                idm_outs_i.idm_slots[1].data,
                idm_outs_i.idm_slots[2].data,
                idm_outs_i.idm_slots[3].data}),
        .queue_valid({idm_outs_i.idm_slots[0].valid,
                        idm_outs_i.idm_slots[1].valid,
                        idm_outs_i.idm_slots[2].valid,
                        idm_outs_i.idm_slots[3].valid}),
        .EIP(EIP),
        .NEIP(neip),
        .inst_length(intruction_length),
        .sib_byte(sib_byte),
        .disp(disp),
        .imm64(imm64),
        .total_pf_vector(total_pf_vector),
        .invalid_inst(invalid_inst)
    );

    initial begin
        EIP <= 32'b0;
    end

    always @(posedge clk) begin
        if(!rst) EIP <= 32'b0;
        else begin
            if (exe_outs_i.br_res_out.flush) EIP <= exe_outs_i.br_res_out.br_target;
            else begin
                if (idm_outs_i.idm_slots[EIP[4:3]].valid && idm_outs_i.idm_slots[EIP[4:3]].br_valid
                    && idm_outs_i.idm_slots[EIP[4:3]].br_eip == EIP) begin
                        EIP <= idm_outs_i.idm_slots[EIP[4:3]].br_btb_target;
                end
                else if (idm_outs_i.idm_slots[EIP[4:3]].valid &&
                        idm_outs_i.idm_slots[neip[4:3]].valid && !invalid_inst) begin
                            EIP <= neip;
                end
                else EIP <= EIP;
            end
        end
    end
endmodule
