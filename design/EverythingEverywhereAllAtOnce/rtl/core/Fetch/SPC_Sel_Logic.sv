module SPC_Sel_Logic (
    input wire clk,
    input wire rst,

    input bool flush,
    input bool pd_stall,

    input btb_output_t btb_outputs,
    input predictor_output_t pred_out,
    input q_ctrl_logic_output_t q_ctrl_logic_out,

    output spc_sel_logic_output_t outputs

);

    address_t saved_br_eip, saved_br_eip_next;
    bool XCL_stall, XCL_stall_next;

    bool br_taken, push_success, btb_xcl;

    assign br_taken = btb_outputs.hit && pred_out.taken;
    assign push_success = q_ctrl_logic_out.push_success;
    assign btb_xcl = btb_outputs.XCL;

    always_comb begin
        outputs.sel = SPC;
        if (flush) outputs.sel = BR_RESTORE;
        else if (push_success) begin
            if ((br_taken && !btb_xcl) || (br_taken && XCL_stall)) outputs.sel = BTB_TARGET;
            else outputs.sel = SPC_P16;

        end

    end

    //proabaly buggy 
    always_comb begin
        XCL_stall_next = 0;
        if (br_taken && btb_xcl && push_success) begin
            XCL_stall_next = 1;
            saved_br_eip_next = btb_outputs.br_eip;
        end
        if (XCL_stall && push_success) XCL_stall_next = 0;
        if (flush) XCL_stall_next = 1;
    end


    always_ff @(posedge clk) begin
        if (rst) XCL_stall <= 0;
        else begin
            XCL_stall <= XCL_stall_next;
            saved_br_eip <= saved_br_eip_next;
        end
    end

endmodule
