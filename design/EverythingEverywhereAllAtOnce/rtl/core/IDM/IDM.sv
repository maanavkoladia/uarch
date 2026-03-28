import common_pkg::*;
import core_common_pkg::fetch_outputs_t;
import core_common_pkg::fetch_idm_ctrl_2_idm_t;
import core_common_pkg::idm_slot_req_t;
import core_stage_latches_pkg::idm_outputs_t;
import IDM_pkg::*;

module IDM (
    input wire clk,
    input wire rst,

    //used for slot reqs, and exp_pipe_clear signal
    input  fetch_outputs_t fetch_outs_i,
    //basically feeds the state of the idm to fetch and decode
    output idm_outputs_t   idm_outs_o
);

    idm_t idm;

    always@(posedge clk)begin
        if(rst | fetch_outs_i.exp_pipe_clear)begin
            for(int i = 0; i < NUM_IDM_SLOTS; i++)begin
                idm.slots[i].valid     <= 0;
                idm.slots[i].br_valid  <= 0;
                idm.slots[i].br_eip    <= '0;
                idm.slots[i].br_target <= '0;
                idm.slots[i].br_xcl    <= 0;
                idm.slots[i].data      <= '{default: '0};
            end
        end
        else begin
            for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
                idm_slot_req_t curReq;
                curReq = fetch_outs_i.idm_reqs.req[i];
                if (curReq.ld_meta_data) begin
                    idm.slots[i].valid <= curReq.valid;
                    idm.slots[i].br_valid <= curReq.br_valid;
                    idm.slots[i].br_eip <= curReq.br_eip;
                    idm.slots[i].br_target <= curReq.br_target;
                    idm.slots[i].br_xcl <= curReq.br_xcl;
                end
                if (curReq.ld_data) begin
                    for (int j = 0; j < CACHE_LINES_SIZE_B; j++) begin
                        idm.slots[i].data[j] <= curReq.data[j];
                    end
                end
            end
        end
    end


    always_comb begin
        idm_outs_o.valid_slots = 0;
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            idm_outs_o.valid_slots += idm.slots[i].valid;
            idm_outs_o.idm_slots[i].valid         = idm.slots[i].valid;
            idm_outs_o.idm_slots[i].br_valid      = idm.slots[i].br_valid;
            idm_outs_o.idm_slots[i].br_eip        = idm.slots[i].br_eip;
            idm_outs_o.idm_slots[i].br_btb_target = idm.slots[i].br_target;
            idm_outs_o.idm_slots[i].br_xcl        = idm.slots[i].br_xcl;
            idm_outs_o.idm_slots[i].data          = idm.slots[i].data;
        end
    end

/*

    typedef struct {
        bool valid;
        bool br_valid;
        address_t br_eip;
        address_t br_target;
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE_B];

        // you may add internal-only metadata here later
        // e.g. age bits, debug tags, etc.
    } slot_t;

    typedef struct {slot_t slots[NUM_IDM_SLOTS];} idm_t;

    typedef struct {
        bool valid;
        //the br was predecited taken in fetch
        bool br_valid;
        l_address_t br_eip;
        l_address_t br_btb_target;  //this is the btbs predicted target, 
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE_B];
    } idm_slot_info_t;

    typedef struct {idm_slot_info_t idm_slots[NUM_IDM_SLOTS];} idm_outputs_t;


        typedef struct {
        core_2_icache_t fetch_2_icache;
        fetch_idm_ctrl_2_idm_t idm_reqs;
        bool exp_pipe_clear;
    } fetch_outputs_t;



    typedef struct {
        bool ld_meta_data;
        //this is for the cachelines, if not laoding dont want to create a mux or
        //load in X's
        bool ld_data;

        bool valid;

        bool br_valid;
        address_t br_eip;
        address_t br_target;
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE_B];
    } idm_slot_req_t;

    typedef struct {idm_slot_req_t req[NUM_IDM_SLOTS];} fetch_idm_ctrl_2_idm_t;

*/


    
endmodule
