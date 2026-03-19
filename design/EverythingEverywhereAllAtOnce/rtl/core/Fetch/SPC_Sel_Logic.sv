import Fetch_pkg::*;
import common_pkg::*;
module SPC_Sel_Logic (
    input wire clk,
    input wire rst,

    input bool flush,

    //probably not needed
    input bool decode_stall,

    input btb_output_t btb_outputs,
    input predictor_output_t pred_out,
    input idm_ctrl_logic_output_t idm_ctrl_logic_out,

    output spc_sel_logic_output_t outputs

);
    bool XCL_stall, XCL_stall_next;

    address_t BR_target_reg;
    bool flush_reg;

    bool br_info_we, br_taken, push_success, btb_xcl;

    assign br_taken = btb_outputs.hit && pred_out.taken;
    assign push_success = idm_ctrl_logic_out.push_success;
    assign btb_xcl = btb_outputs.XCL;
    assign br_info_we = (!XCL_stall) || (XCL_stall && push_success);
    assign outputs.br_target_sel = XCL_stall;
    assign outputs.br_target = XCL_stall ? BR_target_reg : btb_outputs.br_target;
    assign outputs.flush_reg = flush_reg;
    //SPC sel
    always_comb begin
        outputs.sel = SPC;
        if (flush) outputs.sel = BR_RESTORE;
        else begin
            if (push_success) begin
                if (flush_reg) outputs.sel = SPC_P16;
                else begin
                    if ((br_taken && !btb_xcl) || XCL_stall) outputs.sel = BTB_TARGET;
                    else outputs.sel = SPC_P16;
                end
            end
        end
    end

    //XCL_next
    always_comb begin
        XCL_stall_next = XCL_stall;
        if (flush || flush_reg) begin
            XCL_stall_next = 0;
        end
        else begin
            if (~XCL_stall && br_taken && btb_xcl && push_success) begin
                XCL_stall_next = 1;
            end
            else if (XCL_stall && push_success) XCL_stall_next = 0;
        end
    end


    //XCL update
    always_ff @(posedge clk) begin
        if (rst) XCL_stall <= 0;
        else begin
            XCL_stall <= XCL_stall_next;
        end
    end

    //br_target_reg update
    always_ff@(posedge clk) begin
        if(br_info_we)begin
            BR_target_reg  <= btb_outputs.br_target;
        end
    end

    //flush reg JK
    always_ff@(posedge clk)begin
        if(rst)flush_reg <= 0;
        else begin
            if(flush) flush_reg <=1;
            else if(flush_reg && push_success) flush_reg <= 0;
        end
    end

endmodule



        /*
                Control rationale (from original issue to current implementation)

                Original problem:
                - BTB outputs are live and can change every cycle as SPC moves.
                - For an XCL branch, branch resolution is effectively split across cycles:
                    we first step to SPC+16, then later redirect to branch target.
                - If we only remember old SPC and keep reading live BTB outputs, the target can
                    get overwritten by the next line's BTB data before redirect is applied.

                Original attempt:
                - Save old SPC and rely on current BTB outputs.
                - This fails when BTB output context changes before redirect is consumed.

                Current solution:
                1) Save branch target in BR_target_reg when allowed by br_info_we.
                2) Use XCL_stall to indicate "servicing delayed XCL redirect".
                3) While XCL_stall=1, target select uses saved target path (outputs.br_target_sel=1).
                4) Add flush_reg as a one-shot mask after flush/restore:
                     after BR_RESTORE is accepted, force one SPC+16 before allowing prediction-based
                     BTB target redirects again.

                SPC action rules:
                - BR_RESTORE: whenever flush=1 (highest priority).
                - Hold SPC: default when no push_success and no flush.
                - SPC_P16: on push_success when flush_reg=1, or when no redirect condition matches.
                - BTB_TARGET: on push_success when either
                        a) predicted taken non-XCL branch, or
                        b) currently servicing XCL_stall.

                Why this avoids off-by-one issues:
                - XCL_stall_next holds state by default, then only toggles on explicit events.
                - Enter XCL_stall only on accepted XCL-taken line (push_success).
                - Exit XCL_stall on accepted follow-up line (push_success), exactly when redirect
                    should be applied from saved target.
                - flush_reg is set-dominant on flush and cleared only after a successful push,
                    giving deterministic one-cycle prediction masking after restore.
        */
