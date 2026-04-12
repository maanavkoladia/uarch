import common_pkg::*;
import ICache_common_pkg::*;
import interconnect_pkg::*;

module ICache (
    input wire clk,
    input wire rst,

    //
    input  core_2_icache_t inFromCore_i,
    output icache_2_core_t out2Core_o,

    //input from dte drive bus tristate, and memvalid for fsm control
    input dte_2_icache_t inFromDte_i,
    output icache_2_scheduler_t out2Sch_o,

    //okay mankey
    inout [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus
);

    typedef struct {
        bool LD_IC_SWAP_BUF;
        bool RD_I_VC_SWAP_BUF;
        bool busy;
        bool MakeReq;
        bool Fill0EN;
        bool Fill1EN;
        bool Fill2EN;
        bool Fill3EN;
    } fsm_outputs_t;

    icache_controller_fsm_states_e controller_fsmState;
    logic [$clog2( NUM_ICACHE_CONTROLLER_STATES) - 1 : 0] controller_fsmState_bits;
    assign controller_fsmState = controller_fsmState_bits;
    fsm_outputs_t fsmOuts;

    ICache_swap_buf_t icache_swapbuf, i_vcache_swapBuf;

    byte_t icache_dataLines[CACHE_LINES_SIZE_B];
    logic [ICACHE_TAG_WIDTH - 1 : 0] icache_tag;
    logic icache_tag_V;

    logic icache_hit, icache_miss;

    logic i_vcache_hit, i_vcache_miss, i_vcache_swapBuf_V_Clr;
    byte_t i_vcache_dataLines[CACHE_LINES_SIZE_B];


    //note that this is latched, so it is one cycle behind actual fetch spc,
    //that is just used when we are changing that state of the icache data.
    //this is because spc can change due to flushes etc while icache is
    //swapping or filling a line from mem
    //i think that i can mux this line w that wires that i coming
    //in and pass them into the submodules to ensure that they use
    //latched address instead of wires from fetch

    p_address_t saved_pAddr;
    v_address_t saved_vAddr;

    v_address_t curr_v_addr_to_use;

    bool useSaved_v_Addr;

    ICache_Controller_Logic icache_contrller_fsm (
        .clk(clk),
        .rst(rst),
        .IC_miss_i(icache_miss),
        .I_VC_Miss_i(i_vcache_miss),
        .mem_valid_i(inFromDte_i.Mem_Valid),
        .en_i(inFromCore_i.icache_en),
        .S_0(controller_fsmState_bits[0]),  // current-state bit 0 (LSB)
        .S_1(controller_fsmState_bits[1]),  // current-state bit 1 (1)
        .S_2(controller_fsmState_bits[2]),  // current-state bit 2 (MSB)
        .LD_IC_SWAP_BUF_o(fsmOuts.LD_IC_SWAP_BUF),
        .RD_I_VC_SWAP_BUF_o(fsmOuts.RD_I_VC_SWAP_BUF),
        .busy_o(fsmOuts.busy),
        .MakeReq_o(fsmOuts.MakeReq),
        .Fill0EN_o(fsmOuts.Fill0EN),
        .Fill1EN_o(fsmOuts.Fill1EN),
        .Fill2EN_o(fsmOuts.Fill2EN),
        .Fill3EN_o(fsmOuts.Fill3EN)
    );

    //create the tagstore

    ICache_TagStore icache_TagStore_unit (
        .clk(clk),
        .rst(rst),
        .en(inFromCore_i.icache_en),  //active high
        .v_addr_i(curr_v_addr_to_use),
        .ld_From_I_VC_Swap(fsmOuts.RD_I_VC_SWAP_BUF),
        .LD_IC_SWAP_BUF(fsmOuts.LD_IC_SWAP_BUF),
        .fill3_i(fsmOuts.Fill3EN),
        .busy(fsmOuts.busy),
        .I_VC_SwapBuf_i(i_vcache_swapBuf),
        .currTag_o(icache_tag),
        .currLine_V(icache_tag_V)
    );

    //create the data store
    ICache_DataStore icache_dataStore_unit (
        .rst(rst),
        .clk(clk),
        .en(inFromCore_i.icache_en),  //active high
        .v_addr_i(curr_v_addr_to_use),
        .LD_IC_SWAP_BUF(fsmOuts.LD_IC_SWAP_BUF),
        .fill0_i(fsmOuts.Fill0EN),
        .fill1_i(fsmOuts.Fill1EN),
        .fill2_i(fsmOuts.Fill2EN),
        .fill3_i(fsmOuts.Fill3EN),
        .busy(fsmOuts.busy),
        .ld_From_I_VC_Swap(fsmOuts.RD_I_VC_SWAP_BUF),
        .I_VC_SwapBuf_i(i_vcache_swapBuf),
        .dataBus(dataBus),
        .currLine_o(icache_dataLines)
    );

    //create teh I_Victrim cache
    I_VCache i_vcache_unit (
        .clk(clk),
        .rst(rst),  //active low
        .busy_i(fsmOuts.busy),
        .en_i(inFromCore_i.icache_en),  //i think we can ust use the icache en signal, might be a src of problems later
        .v_addr_i(curr_v_addr_to_use),
        .IC_SwapBuf_i(icache_swapbuf),
        .I_VC_SwapBuf_o(i_vcache_swapBuf),
        .hit_o(i_vcache_hit),
        .miss_o(i_vcache_miss),
        .IC_SwapBuf_V_clr_o(i_vcache_swapBuf_V_Clr),
        .dataLineOut_o(i_vcache_dataLines)
    );

    //do the swapbuf latch logic
    always_ff @(posedge clk) begin
        if (!rst) icache_swapbuf <= '{default: '0};
        else if (fsmOuts.LD_IC_SWAP_BUF) begin
            icache_swapbuf.valid <= 1;
            icache_swapbuf.lineAddr <= {
                icache_tag, inFromCore_i.v_addr_i[ICACHE_INDEX_UB : ICACHE_INDEX_LB], 4'b0000
            };
            icache_swapbuf.line <= icache_dataLines;
        end else if (i_vcache_swapBuf_V_Clr) begin
            icache_swapbuf.valid <= 0;
        end
    end

    //INTERNAL SIGNALS

    assign icache_hit =
        inFromCore_i.icache_en
        && (!fsmOuts.busy)
        && (icache_tag_V
        && (icache_tag == inFromCore_i.v_addr_i[ICACHE_TAG_UB : ICACHE_TAG_LB]));

    assign icache_miss =
        inFromCore_i.icache_en
        && (!fsmOuts.busy)
        && (!icache_tag_V
        || (icache_tag != inFromCore_i.v_addr_i[ICACHE_TAG_UB : ICACHE_TAG_LB]));

    assign useSaved_v_Addr = fsmOuts.busy;
    assign curr_v_addr_to_use = useSaved_v_Addr ? saved_vAddr : inFromCore_i.v_addr_i;

    always_ff @(posedge clk) begin
        if (!rst) begin
            saved_vAddr <= 0;
            saved_pAddr <= 0;
        end else if (!fsmOuts.busy) begin
            saved_pAddr <= inFromCore_i.p_addr;
            saved_vAddr <= inFromCore_i.v_addr_i;
        end
    end


    //MODULE OUTPUT SIGNALS
    assign out2Core_o.hit = icache_hit || i_vcache_hit;//en is already included in the gen of the icache hit signal
    assign out2Core_o.instruction_line = i_vcache_hit ? i_vcache_dataLines : icache_dataLines;

    //need schduler req gen logic, idle means no req
    //im gonna go ahead and say that even if icache is disableed
    //is shoudl still be making its current req becase
    //once it gets back to idle, it cant go on to make more
    //reqs and it is disabled also stopping it might brick other
    //parts of the system
    always_comb begin
        out2Sch_o.req = NO_REQ;
        if (fsmOuts.MakeReq) begin
            out2Sch_o.req = ICACHE_LOW_PRI_REQ;
            if (inFromCore_i.num_valid_IDM_slots < 2) out2Sch_o.req = ICACHE_HIGH_PRI;
        end
    end

    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] addrBus_drv;
    assign addrBus_drv = saved_pAddr;
    assign addrBus = inFromDte_i.driveAddrBus ? addrBus_drv : 'z;

endmodule



