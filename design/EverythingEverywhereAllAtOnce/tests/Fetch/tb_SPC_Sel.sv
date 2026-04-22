import common_pkg::*;
import Fetch_pkg::*;

module tb_SPC_Sel();

    // Clock and reset
    logic clk;
    logic reset;

    // DUT inputs
    bool flush;
    bool decode_stall;
    btb_output_t btb_outputs;
    predictor_output_t pred_out;
    idm_ctrl_logic_output_t idm_ctrl_logic_out;
    
    // DUT output
    spc_sel_logic_output_t outputs;

    // Test tracking
    int test_num = 0;
    int passed = 0;
    int failed = 0;

    // DUT instantiation
    SPC_Sel_Logic dut (
        .clk(clk),
        .rst(reset),
        .flush(flush),
        .decode_stall(decode_stall),
        .btb_outputs(btb_outputs),
        .pred_out(pred_out),
        .idm_ctrl_logic_out(idm_ctrl_logic_out),
        .outputs(outputs)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main test sequence
    initial begin
        $display("========================================");
        $display("  SPC_Sel_Logic Testbench Starting");
        $display("========================================\n");

        // Initialize
        reset = 1;
        flush = 0;
        decode_stall = 0;
        btb_outputs = '{default: '0};
        pred_out = '{default: '0};
        idm_ctrl_logic_out = '{default: '0};

        // Reset
        repeat(3) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // Run tests
        test_no_push_no_branch();
        test_normal_increment();
        test_non_xcl_branch_taken();
        test_xcl_branch_two_cycle();
        test_flush_overrides_all();
        test_no_push_holds_spc();
        test_btb_miss_increments();
        test_predicted_not_taken();
        test_xcl_stall_recovery();
        test_flush_during_xcl();
        test_back_to_back_branches();
        test_xcl_no_push_stall();

        // Summary
        @(posedge clk);
        $display("\n========================================");
        $display("  Test Summary");
        $display("========================================");
        $display("  Passed: %0d", passed);
        $display("  Failed: %0d", failed);
        $display("  Total:  %0d", passed + failed);
        if (failed == 0)
            $display("  STATUS: ALL TESTS PASSED!");
        else
            $display("  STATUS: SOME TESTS FAILED");
        $display("========================================\n");

        $finish;
    end

    // ========================================
    // Test Cases
    // ========================================

    // Test 1: No push success, no branch → SPC stays same
    task automatic test_no_push_no_branch();
        test_num++;
        $display("[TEST %0d] No Push Success, No Branch → SPC", test_num);
        
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 0;
        pred_out.taken = 0;
        idm_ctrl_logic_out.push_success = 0;
        
        @(posedge clk);
        check_sel("Should select SPC", outputs.sel, SPC);
        $display("");
    endtask

    // Test 2: Normal increment (push success, no branch)
    task automatic test_normal_increment();
        test_num++;
        $display("[TEST %0d] Push Success, No Branch → SPC+16", test_num);
        
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 0;
        pred_out.taken = 0;
        idm_ctrl_logic_out.push_success = 1;
        
        @(posedge clk);
        check_sel("Should select SPC_P16", outputs.sel, SPC_P16);
        
        // Clean up
        idm_ctrl_logic_out.push_success = 0;
        @(posedge clk);
        $display("");
    endtask

    // Test 3: Non-XCL branch taken
    task automatic test_non_xcl_branch_taken();
        test_num++;
        $display("[TEST %0d] BTB Hit, Predicted Taken, Not XCL → BTB_TARGET", test_num);
        
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.br_target = 32'h5000;
        btb_outputs.br_eip = 32'h1000;
        btb_outputs.XCL = 0;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1;
        
        @(posedge clk);
        check_sel("Should select BTB_TARGET", outputs.sel, BTB_TARGET);
        check_br_target_sel("Non-XCL path should use live BTB target", outputs.br_target_sel, 1'b0);
        check_br_target("Non-XCL target should match BTB", outputs.br_target, 32'h5000);
        $display("  Branch: EIP=0x%h → Target=0x%h", 32'h1000, 32'h5000);
        
        // Clean up
        btb_outputs.hit = 0;
        pred_out.taken = 0;
        idm_ctrl_logic_out.push_success = 0;
        @(posedge clk);
        $display("");
    endtask




    // Test 4: XCL branch - two cycle process
    task automatic test_xcl_branch_two_cycle();
        test_num++;
        $display("[TEST %0d] XCL Branch Two-Cycle Handling", test_num);

        // -------------------------------
        // C0 (decision phase, before posedge)
        // Inputs: XCL taken branch accepted.
        // Expected combinational decision for this edge: SPC_P16.
        // -------------------------------
        @(negedge clk);
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.br_target = 32'h7000;
        btb_outputs.br_eip = 32'h2000;
        btb_outputs.XCL = 1;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1;
        #1
        $display("  C0 decision: XCL branch at EIP=0x%h, target=0x%h", 32'h2000, 32'h7000);
        check_internal_xcl("After C0 posedge, XCL_stall should be set", 1'b0);
        check_sel("C0 should choose SPC_P16", outputs.sel, SPC_P16);
        check_br_target_sel("C0 should use live BTB target path", outputs.br_target_sel, 1'b0);

        // -------------------------------
        // C0 posedge (state update)
        // XCL_stall is set here.
        // -------------------------------
        @(posedge clk);
        #1
        check_internal_xcl("After C0 posedge, XCL_stall should be set", 1'b1);
        check_br_target_sel(
            "After C0 posedge, saved target path is selected",
            outputs.br_target_sel,
            1'b1
        );
        check_br_target("Saved target should be 0x7000", outputs.br_target, 32'h7000);

        // -------------------------------
        // C1 (decision phase, before next posedge)
        // Inputs: next cache line accepted, no new branch metadata.
        // Expected combinational decision: BTB_TARGET using saved target.
        // -------------------------------
        @(negedge clk);
        btb_outputs.hit = 0;
        btb_outputs.br_target = 32'h0000;
        btb_outputs.br_eip = 32'h2010;
        btb_outputs.XCL = 0;
        pred_out.taken = 0;
        idm_ctrl_logic_out.push_success = 1;
        #1;
        $display("  C1 decision: next line accepted, redirect using saved target");
        check_sel("C1 should choose BTB_TARGET", outputs.sel, BTB_TARGET);
        check_br_target_sel("C1 should use saved target path", outputs.br_target_sel, 1'b1);
        check_br_target("C1 redirect target should still be 0x7000", outputs.br_target, 32'h7000);

        // -------------------------------
        // C1 posedge (state update)
        // XCL_stall clears here because push_success=1 while stalling.
        // -------------------------------
        @(posedge clk);
        #1;
        check_internal_xcl("After C1 posedge, XCL_stall should be cleared", 1'b0);

        // Clean up (explicitly drive all controls low)
        @(negedge clk);
        flush = 0;
        btb_outputs.hit = 0;
        btb_outputs.br_target = 32'h0000;
        btb_outputs.br_eip = 32'h0000;
        btb_outputs.XCL = 0;
        pred_out.taken = 0;
        idm_ctrl_logic_out.push_success = 0;
        @(posedge clk);
        $display("");
    endtask




    // Test 5: Flush overrides everything
    task automatic test_flush_overrides_all();
        test_num++;
        $display("[TEST %0d] Flush Overrides All Other Signals", test_num);

        @(posedge clk); //We are fetching nonsense
        #1
        flush = 1;  // Flush is active
        btb_outputs.hit = 1;
        btb_outputs.XCL = 1;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1; //meaningless since we are clearing everything
        #1
        check_sel("Flush should override to BR_RESTORE", outputs.sel, BR_RESTORE);
        check_internal_xcl("XCL_stall should be 0", 1'b0);
        check_internal_flush("flush reg should be 0" ,1'b0 );


        @(posedge clk); //We have are fetching BR_EIP unsuccesfully 
        $display("start of C1");
        // Clean up
        #1
        flush = 0;
        btb_outputs.hit = 1; //info corresponds to SPC
        btb_outputs.XCL = 1;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 0; //means we have not pushed BR_EIP (SPC)
        #1
        check_internal_flush("flush reg should be 1", 1'b1 );
        check_br_target_sel("meaningless...since masked by flush but should be 0", outputs.br_target_sel, 1'b0);
        check_sel("Flush Reg should override to SPC", outputs.sel, SPC);
        check_internal_xcl("Because of prev cycle flush XCL_stall is 0 ", 1'b0);

        @(posedge clk); //We have successfull fetched the Restore
        // Clean up
        #1
        $display("start of C2");
        flush = 0;
        btb_outputs.hit = 1; //info corresponds to SPC
        btb_outputs.XCL = 1;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1; //means we pushed BR_EIP need to go to SPC_16
        #1
        check_internal_flush("flush reg should be 1", 1'b1 );
        check_br_target_sel("BR_sel is on pass thru", outputs.br_target_sel, 1'b0);
        check_sel("Flush Reg should override to SPC_P16", outputs.sel, SPC_P16);
        check_internal_xcl("XCL_Stall is still 0.. will be set to 1 next cycle ", 1'b0);


        @(posedge clk); //We have successfully fetched SPC+16
        $display("start of C3");
        #1
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.XCL = 1; //SPC+16 has a XCL branch
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1; //we pushed SPC + 16
        #1
        check_br_target_sel("C1 should use saved target path", outputs.br_target_sel, 1'b0);
        check_sel("since SPC+16 is XCL we need to SPC_P16", outputs.sel, SPC_P16);
        check_internal_flush("flush reg should be 0", 1'b0);
        check_internal_xcl("After XCL_stall should be 1", 1'b0);

        
        @(posedge clk); //SPC+16 has an XCL so we need to fetch SPC+32 which we do which means we cna move onto target
        $display("start of C3");
        #1
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.XCL = 1; //SPC+16 has a XCL branch
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1; //we pushed SPC + 16
        #1
        check_br_target_sel("C1 should use saved target path", outputs.br_target_sel, 1'b1);
        check_sel("since SPC+16 is XCL we need to SPC_P16", outputs.sel, BTB_TARGET );
        check_internal_flush("flush reg should be 0", 1'b0);
        check_internal_xcl("After XCL_stall should be 1", 1'b1);
        $display("");

    endtask

    // Test 6: No push success holds SPC
    task automatic test_no_push_holds_spc();
        test_num++;
        $display("[TEST %0d] No Push Success Holds SPC (Stall)", test_num);
        
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.br_target = 32'h9000;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 0;  // No push
        
        @(posedge clk);
        check_sel("Should stay at SPC", outputs.sel, SPC);
        $display("  IDM full, SPC should not update");
        
        // Clean up
        btb_outputs.hit = 0;
        pred_out.taken = 0;
        @(posedge clk);
        $display("");
    endtask

    // Test 7: BTB miss with push success → increment
    task automatic test_btb_miss_increments();
        test_num++;
        $display("[TEST %0d] BTB Miss with Push Success → SPC+16", test_num);
        
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 0;  // Miss
        pred_out.taken = 1;   // Don't care since miss
        idm_ctrl_logic_out.push_success = 1;
        
        @(posedge clk);
        check_sel("Should select SPC_P16", outputs.sel, SPC_P16);
        $display("  No branch in BTB, normal increment");
        
        // Clean up
        pred_out.taken = 0;
        idm_ctrl_logic_out.push_success = 0;
        @(posedge clk);
        $display("");
    endtask

    // Test 8: BTB hit but predicted not taken
    task automatic test_predicted_not_taken();
        test_num++;
        $display("[TEST %0d] BTB Hit but Predicted Not Taken → SPC+16", test_num);
        
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.br_target = 32'hA000;
        pred_out.taken = 0;  // Not taken
        idm_ctrl_logic_out.push_success = 1;
        
        @(posedge clk);
        check_sel("Should select SPC_P16 (not taken)", outputs.sel, SPC_P16);
        $display("  Branch exists but predicted not taken");
        
        // Clean up
        btb_outputs.hit = 0;
        idm_ctrl_logic_out.push_success = 0;
        @(posedge clk);
        $display("");
    endtask

    // Test 9: XCL stall recovery (entering stall state)
    task automatic test_xcl_stall_recovery();
        test_num++;
        $display("[TEST %0d] XCL Stall State Holds Until Push", test_num);
        
        // Set up XCL stall
        @(posedge clk); //means we pushed on SPC
        #1
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.br_target = 32'hB000;
        btb_outputs.br_eip = 32'h3000;
        btb_outputs.XCL = 1;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1;
        #1
        check_sel("Should stay at SPC during stall", outputs.sel, SPC_P16);

        @(posedge clk); //we have unsuccesfully fetched SPC_16
        $display("  Entering XCL stall state");
        #1
        // Now no push success while in XCL stall
        idm_ctrl_logic_out.push_success = 0;  // Stalled
        #1
        check_sel("Should stay at SPC during stall", outputs.sel, SPC);
        check_internal_xcl("XCL_stall should remain set", 1'b1);

        @(posedge clk);
        #1
        check_sel("Should stay at SPC during stall", outputs.sel, SPC);
        check_internal_xcl("XCL_stall should remain set", 1'b1);
        
        // Recovery: push success
        @(posedge clk);
        #1
        idm_ctrl_logic_out.push_success = 1;
        #1
        $display("  Push success, exiting stall");
        check_sel("Should go to BTB_TARGET", outputs.sel, BTB_TARGET);
        check_br_target("should be selecting saved", outputs.br_target_sel, 1);
        check_internal_xcl("XCL_stall should remain set", 1'b1);
        @(posedge clk);
        #1
        check_internal_xcl("reset back to 0", 1'b0);

        
        // Clean up
        @(posedge clk);
        idm_ctrl_logic_out.push_success = 0;
        @(posedge clk);
        $display("");
    endtask

    // Test 10: Flush during XCL handling
    task automatic test_flush_during_xcl();
        test_num++;
        $display("[TEST %0d] Flush During XCL Handling", test_num);
        
        // Start XCL
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.br_target = 32'hC000;
        btb_outputs.br_eip = 32'h4000;
        btb_outputs.XCL = 1;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1;
        
        @(posedge clk);
        $display("  XCL branch started");
        
        // Flush happens
        @(posedge clk);
        flush = 1;
        #1
        check_sel("Flush should override to BR_RESTORE", outputs.sel, BR_RESTORE);

        @(posedge clk);
        // Clean up
        #1
        flush = 0;
        idm_ctrl_logic_out.push_success = 0;
        #1
        check_sel("No push success should be SPC", outputs.sel, SPC);
        check_internal_xcl("XCL_stall should be cleared by flush", 1'b0);
        check_br_target_sel(
            "Flush path should not force saved target",
            outputs.br_target_sel,
            1'b0
        );
        

        @(posedge clk);
        @(posedge clk);
        $display("");
    endtask

    // Test 11: Back-to-back non-XCL branches
    task automatic test_back_to_back_branches();
        test_num++;
        $display("[TEST %0d] Back-to-Back Non-XCL Branches", test_num);
        
        // First branch
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.br_target = 32'hD000;
        btb_outputs.br_eip = 32'h5000;
        btb_outputs.XCL = 0;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 1;
        
        @(posedge clk);
        check_sel("First branch should go to target", outputs.sel, BTB_TARGET);
        
        // Second branch immediately
        @(posedge clk);
        btb_outputs.br_target = 32'hE000;
        btb_outputs.br_eip = 32'h6000;
        
        @(posedge clk);
        check_sel("Second branch should also go to target", outputs.sel, BTB_TARGET);
        
        // Clean up
        btb_outputs.hit = 0;
        pred_out.taken = 0;
        idm_ctrl_logic_out.push_success = 0;
        @(posedge clk);
        $display("");
    endtask

    // Test 12: XCL branch but no push success (stall immediately)
    task automatic test_xcl_no_push_stall();
        test_num++;
        $display("[TEST %0d] XCL Branch with No Push Success", test_num);
        
        @(posedge clk);
        flush = 0;
        btb_outputs.hit = 1;
        btb_outputs.br_target = 32'hF000;
        btb_outputs.br_eip = 32'h7000;
        btb_outputs.XCL = 1;
        pred_out.taken = 1;
        idm_ctrl_logic_out.push_success = 0;  // Can't push
        
        @(posedge clk);
        check_sel("Should stay at SPC (can't push)", outputs.sel, SPC);
        check_internal_xcl("XCL_stall should NOT be set yet", 1'b0);
        $display("  XCL branch detected but IDM full, waiting...");
        
        // Now allow push
        @(posedge clk); //we pushed on SPC - going to fetch SPC_16. 
        idm_ctrl_logic_out.push_success = 1;
        #1
        check_sel("Now should increment to SPC_P16", outputs.sel, SPC_P16);
        
        @(posedge clk);
        #1
        check_internal_xcl("XCL_stall should NOW be set", 1'b1);
        check_sel("Now should increment to BTB_TARGET", outputs.sel, BTB_TARGET);

        #1
        // Clean up
        btb_outputs.hit = 0;
        btb_outputs.XCL = 0;
        pred_out.taken = 0;
        idm_ctrl_logic_out.push_success = 0;
        #1
        @(posedge clk);
        @(posedge clk);
        $display("");
    endtask

    // ========================================
    // Helper Functions
    // ========================================

    // Check SPC selection
    function automatic void check_sel(
        string name,
        spc_sel_logic_output_options_e actual,
        spc_sel_logic_output_options_e expected
    );
        string actual_str, expected_str;
        
        case(actual)
            SPC: actual_str = "SPC";
            SPC_P16: actual_str = "SPC_P16";
            BR_RESTORE: actual_str = "BR_RESTORE";
            BTB_TARGET: actual_str = "BTB_TARGET";
            default: actual_str = "UNKNOWN";
        endcase
        
        case(expected)
            SPC: expected_str = "SPC";
            SPC_P16: expected_str = "SPC_P16";
            BR_RESTORE: expected_str = "BR_RESTORE";
            BTB_TARGET: expected_str = "BTB_TARGET";
            default: expected_str = "UNKNOWN";
        endcase
        
        if (actual === expected) begin
            $display("  [PASS] %s: %s", name, actual_str);
            passed++;
        end else begin
            $display("  [FAIL] %s: Expected %s, Got %s", name, expected_str, actual_str);
            failed++;
        end
    endfunction

    // Check internal XCL_stall state
    function automatic void check_internal_xcl(string name, logic expected);
        if (dut.XCL_stall === expected) begin
            $display("  [PASS] %s: %b", name, dut.XCL_stall);
            passed++;
        end else begin
            $display("  [FAIL] %s: Expected %b, Got %b", name, expected, dut.XCL_stall);
            failed++;
        end
    endfunction

        // Check internal XCL_stall state
    function automatic void check_internal_flush(string name, logic expected);
        if (dut.flush_reg === expected) begin
            $display("  [PASS] %s: %b", name, dut.flush_reg);
            passed++;
        end else begin
            $display("  [FAIL] %s: Expected %b, Got %b", name, expected, dut.flush_reg);
            failed++;
        end
    endfunction


    // Check target select source
    function automatic void check_br_target_sel(string name, logic actual, logic expected);
        if (actual === expected) begin
            $display("  [PASS] %s: %b", name, actual);
            passed++;
        end else begin
            $display("  [FAIL] %s: Expected %b, Got %b", name, expected, actual);
            failed++;
        end
    endfunction

    // Check branch target value
    function automatic void check_br_target(
        string name,
        logic [31:0] actual,
        logic [31:0] expected
    );
        if (actual === expected) begin
            $display("  [PASS] %s: 0x%h", name, actual);
            passed++;
        end else begin
            $display("  [FAIL] %s: Expected 0x%h, Got 0x%h", name, expected, actual);
            failed++;
        end
    endfunction

    // Timeout watchdog
    initial begin
        #50000; // 50us timeout
        $display("\n[ERROR] Testbench timeout!");
        $finish;
    end

endmodule
