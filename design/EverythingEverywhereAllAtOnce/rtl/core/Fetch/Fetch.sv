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

    input wire ddr5_int,

    output fetch_outputs_t outs_o

);
    /*

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

if xcl, load a temp register with br.location with valid bit set. SPC will get SPC + 16

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


endmodule
