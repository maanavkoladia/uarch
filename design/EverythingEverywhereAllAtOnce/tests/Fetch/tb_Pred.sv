import common_pkg::*;
import Fetch_pkg::*;
import Predictor_pkg::*;

module tb_Pred();

    // Clock and reset
    logic clk;
    logic reset;

    // BTB signals
    address_t    btb_spc;
    bool         btb_exe_br_valid;
    address_t    btb_exe_br_target;
    address_t    btb_exe_br_eip;
    bool         btb_exe_br_XCL;
    bool         btb_exe_br_ucond;
    btb_output_t btb_outputs;

    // Predictor signals
    predictor_input_t  pred_inputs;
    predictor_output_t pred_outputs;

    // Test tracking
    int test_num = 0;
    int passed = 0;
    int failed = 0;

    // DUT instantiation
    BTB btb_inst (
        .clk(clk),
        .reset(reset),
        .spc(btb_spc),
        .exe_br_valid(btb_exe_br_valid),
        .exe_br_target(btb_exe_br_target),
        .exe_br_eip(btb_exe_br_eip),
        .exe_br_XCL(btb_exe_br_XCL),
        .exe_br_ucond(btb_exe_br_ucond),
        .outputs(btb_outputs)
    );

    Predictor pred_inst (
        .inputs(pred_inputs),
        .outputs(pred_outputs)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period, 100MHz
    end

    // Main test sequence
    initial begin
        $display("========================================");
        $display("  BTB + Predictor Testbench Starting");
        $display("========================================\n");

        // Initialize
        reset = 1;
        btb_spc = 0;
        btb_exe_br_valid = 0;
        btb_exe_br_target = 0;
        btb_exe_br_eip = 0;
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 0;
        pred_inputs = '{default: '0};

        // Reset
        repeat(3) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // Run tests
        test_btb_miss();
        test_btb_training();
        test_btb_hit();
        test_btb_collision();
        test_btb_xcl_flag();
        test_btb_ucond_flag();
        test_predictor_backward_branch();
        test_predictor_forward_branch();
        test_integration();
        test_integration_ucond();
        test_simultaneous_read_write();
        test_btb_replacement();
        test_fill_btb();
        test_simultaneous_read_write();
        test_btb_replacement();
        test_fill_btb();

        // Summary
        @(posedge clk);
        $display("\n========================================");
        $display("  Final BTB State");
        $display("========================================");
        display_btb();
        
        $display("========================================");
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

    // Test 1: BTB miss on initial lookup
    task automatic test_btb_miss();
        test_num++;
        $display("[TEST %0d] BTB Miss on Initial Lookup", test_num);
        
        @(posedge clk);
        btb_spc = 32'h1000;
        btb_exe_br_valid = 0;
        @(posedge clk);
        
        check_bit("BTB Hit should be 0", btb_outputs.hit, 1'b0);
        display_btb();
        $display("");
    endtask

    // Test 2: BTB training (write entry)
    task automatic test_btb_training();
        test_num++;
        $display("[TEST %0d] BTB Training", test_num);
        
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'h1000;      // Branch at 0x1000
        btb_exe_br_target = 32'h2000;   // Target is 0x2000
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 0;           // Conditional branch

        @(posedge clk);
        btb_exe_br_valid = 0;
        
        $display("  Trained: EIP=0x%h -> Target=0x%h", 32'h1000, 32'h2000);
        display_btb();
        $display("");
    endtask

    // Test 3: BTB hit on trained entry
    task automatic test_btb_hit();
        test_num++;
        $display("[TEST %0d] BTB Hit on Trained Entry", test_num);
        
        @(posedge clk);
        btb_spc = 32'h1000;  // Lookup the trained address
        
        @(posedge clk);
        check_bit("BTB Hit should be 1", btb_outputs.hit, 1'b1);
        check("BTB Target should match", btb_outputs.br_target, 32'h2000);
        check("BTB EIP should match", btb_outputs.br_eip, 32'h1000);
        check_bit("BTB XCL should be 0", btb_outputs.XCL, 1'b0);
        check_bit("BTB ucond should be 0", btb_outputs.br_ucond, 1'b0);
        display_btb();
        $display("");
    endtask

    // Test 4: BTB index collision (same index, different tag)
    task automatic test_btb_collision();
        address_t collision_addr;
        
        test_num++;
        $display("[TEST %0d] BTB Index Collision", test_num);
        
        // Train first entry
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'h1000;
        btb_exe_br_target = 32'h2000;
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 0;
        @(posedge clk);
        btb_exe_br_valid = 0;
        
        $display("  After training EIP=0x%h:", 32'h1000);
        display_btb();
        
        // Calculate address with same index but different tag
        // This is simplified - in real test you'd calculate based on BTB structure
        collision_addr = 32'h1000 + (1 << 16); // Different upper bits
        
        // Lookup collision address (should miss)
        @(posedge clk);
        btb_spc = collision_addr;
        @(posedge clk);
        
        check_bit("Collision lookup should miss", btb_outputs.hit, 1'b0);
        $display("  Collision addr 0x%h misses (different tag)", collision_addr);
        display_btb();
        $display("");
    endtask

    // Test 5: BTB XCL flag handling
    task automatic test_btb_xcl_flag();
        test_num++;
        $display("[TEST %0d] BTB XCL Flag", test_num);
        
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'h3000;
        btb_exe_br_target = 32'h4000;
        btb_exe_br_XCL = 1;  // Cross-cache-line branch
        btb_exe_br_ucond = 0;
        @(posedge clk);
        btb_exe_br_valid = 0;
        
        // Lookup
        @(posedge clk);
        btb_spc = 32'h3000;
        @(posedge clk);
        display_btb();
        
        check_bit("XCL flag should be set", btb_outputs.XCL, 1'b1);
        $display("");
    endtask

    // Test 6: BTB unconditional branch flag handling
    task automatic test_btb_ucond_flag();
        test_num++;
        $display("[TEST %0d] BTB Unconditional Branch Flag", test_num);

        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'h8000;
        btb_exe_br_target = 32'h9000;
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 1;  // Unconditional branch (JMP/CALL)
        @(posedge clk);
        btb_exe_br_valid = 0;

        // Lookup
        @(posedge clk);
        btb_spc = 32'h8000;
        @(posedge clk);
        display_btb();
        check_bit("Ucond flag should be set", btb_outputs.br_ucond, 1'b1);
        $display("  Unconditional branch: EIP=0x%h -> Target=0x%h", 32'h8000, 32'h9000);
        $display("");
    endtask

    // Test 7: Predictor backward branch (target < spc)
    task automatic test_predictor_backward_branch();
        test_num++;
        $display("[TEST %0d] Predictor - Backward Branch (Taken)", test_num);
        
        @(posedge clk);
        pred_inputs.btfn_target = 32'h1000;  // Target
        pred_inputs.spc = 32'h2000;          // Current PC (target < spc)
        
        @(posedge clk);
        display_btb();
        check_bit("Backward branch should predict taken", pred_outputs.taken, 1'b1);
        $display("  Target=0x%h < SPC=0x%h => Taken=%b", 32'h1000, 32'h2000, pred_outputs.taken);
        $display("");
    endtask

    // Test 8: Predictor forward branch (target >= spc)
    task automatic test_predictor_forward_branch();
        test_num++;
        $display("[TEST %0d] Predictor - Forward Branch (Not Taken)", test_num);
        
        @(posedge clk);
        pred_inputs.btfn_target = 32'h3000;  // Target
        pred_inputs.spc = 32'h2000;          // Current PC (target >= spc)
        
        @(posedge clk);
        display_btb();
        check_bit("Forward branch should predict not taken", pred_outputs.taken, 1'b0);
        $display("  Target=0x%h >= SPC=0x%h => Taken=%b", 32'h3000, 32'h2000, pred_outputs.taken);
        $display("");
    endtask

    // Test 9: Integration test (BTB + Predictor)
    task automatic test_integration();
        test_num++;
        $display("[TEST %0d] Integration - BTB + Predictor", test_num);
        
        // Train a backward branch
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'h5000;
        btb_exe_br_target = 32'h4000;  // Backward branch (loop)
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 0;          // Conditional
        @(posedge clk);
        btb_exe_br_valid = 0;
        
        // Lookup and predict
        @(posedge clk);
        btb_spc = 32'h5000;
        pred_inputs.spc = 32'h5000;
        
        @(posedge clk);
        // Connect BTB output to predictor input
        pred_inputs.btfn_target = btb_outputs.br_target;
        
        @(posedge clk);
        check_bit("BTB should hit", btb_outputs.hit, 1'b1);
        check_bit("Predictor should predict taken (backward)", pred_outputs.taken, 1'b1);
        $display("  SPC=0x%h: BTB hit, Target=0x%h, Predicted=%s", 
                 32'h5000, btb_outputs.br_target, pred_outputs.taken ? "TAKEN" : "NOT TAKEN");
        
        // Train a forward branch
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'h6000;
        btb_exe_br_target = 32'h7000;  // Forward branch
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 0;          // Conditional
        @(posedge clk);
        btb_exe_br_valid = 0;
        
        // Lookup and predict
        @(posedge clk);
        btb_spc = 32'h6000;
        pred_inputs.spc = 32'h6000;
        
        @(posedge clk);
        pred_inputs.btfn_target = btb_outputs.br_target;
        
        @(posedge clk);
        check_bit("BTB should hit", btb_outputs.hit, 1'b1);
        check_bit("Predictor should predict not taken (forward)", pred_outputs.taken, 1'b0);
        $display("  SPC=0x%h: BTB hit, Target=0x%h, Predicted=%s", 
                 32'h6000, btb_outputs.br_target, pred_outputs.taken ? "TAKEN" : "NOT TAKEN");
        
        $display("\n  Final BTB state after integration test:");
        display_btb();
        $display("");
    endtask

    // Test 10: Integration test with unconditional branch
    task automatic test_integration_ucond();
        test_num++;
        $display("[TEST %0d] Integration - Unconditional Branch", test_num);

        // Train an unconditional forward jump (JMP)
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'hA000;
        btb_exe_br_target = 32'hB000;  // Forward unconditional
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 1;          // Unconditional (JMP/CALL)
        @(posedge clk);
        btb_exe_br_valid = 0;

        // Lookup
        @(posedge clk);
        btb_spc = 32'hA000;
        pred_inputs.spc = 32'hA000;

        @(posedge clk);
        pred_inputs.btfn_target = btb_outputs.br_target;

        @(posedge clk);
        check_bit("BTB should hit", btb_outputs.hit, 1'b1);
        check_bit("BTB ucond should be 1", btb_outputs.br_ucond, 1'b1);
        // Note: For unconditional branches, predictor output doesn't matter
        // The branch should always be taken regardless of BTFN prediction
        $display("  SPC=0x%h: BTB hit, Target=0x%h, Ucond=%b",
                 32'hA000, btb_outputs.br_target, btb_outputs.br_ucond);
        $display("  Note: Unconditional branches should always be taken");
        display_btb();

        $display("");
    endtask

    // Test 11: Simultaneous read and write to same BTB entry
    task automatic test_simultaneous_read_write();
        test_num++;
        $display("[TEST %0d] Simultaneous Read and Write to Same Entry", test_num);

        // Train an entry first
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'hC000;
        btb_exe_br_target = 32'hD000;
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 0;
        @(posedge clk);
        btb_exe_br_valid = 0;

        $display("  Initial training: EIP=0x%h -> Target=0x%h", 32'hC000, 32'hD000);
        display_btb();

        // Now read from same address while writing new data to it
        @(posedge clk);
        btb_spc = 32'hC000;              // Read from this address
        btb_exe_br_valid = 1;            // Write to this address
        btb_exe_br_eip = 32'hC000;       // Same address
        btb_exe_br_target = 32'hE000;    // New target
        btb_exe_br_XCL = 1;              // New XCL flag
        btb_exe_br_ucond = 0;

        @(posedge clk);
        $display("  Read outputs during write:");
        $display("    Hit=%b, Target=0x%h (should show OLD or NEW data)", 
                 btb_outputs.hit, btb_outputs.br_target);
        
        btb_exe_br_valid = 0;
        
        // Verify the write took effect
        @(posedge clk);
        btb_spc = 32'hC000;
        @(posedge clk);
        
        check_bit("Entry should still hit", btb_outputs.hit, 1'b1);
        check("Updated target should be 0xE000", btb_outputs.br_target, 32'hE000);
        check_bit("Updated XCL should be 1", btb_outputs.XCL, 1'b1);
        
        $display("  After simultaneous read/write:");
        display_btb();
        $display("");
    endtask

    // Test 12: BTB entry replacement
    task automatic test_btb_replacement();
        test_num++;
        $display("[TEST %0d] BTB Entry Replacement", test_num);

        // Train first branch at a specific index
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'h1100;       // Index 0
        btb_exe_br_target = 32'h2100;
        btb_exe_br_XCL = 0;
        btb_exe_br_ucond = 0;
        @(posedge clk);
        btb_exe_br_valid = 0;

        $display("  First entry: EIP=0x%h -> Target=0x%h", 32'h1100, 32'h2100);
        display_btb();

        // Replace with different branch at same index (different tag)
        @(posedge clk);
        btb_exe_br_valid = 1;
        btb_exe_br_eip = 32'h1100 + (1 << 20);  // Same index, different tag
        btb_exe_br_target = 32'h3100;
        btb_exe_br_XCL = 1;
        btb_exe_br_ucond = 1;
        @(posedge clk);
        btb_exe_br_valid = 0;

        $display("  Replacement entry: EIP=0x%h -> Target=0x%h", 
                 32'h1100 + (1 << 20), 32'h3100);
        display_btb();

        // Verify old entry is gone, new entry exists
        @(posedge clk);
        btb_spc = 32'h1100;  // Old address
        @(posedge clk);
        check_bit("Old entry should miss", btb_outputs.hit, 1'b0);

        @(posedge clk);
        btb_spc = 32'h1100 + (1 << 20);  // New address
        @(posedge clk);
        check_bit("New entry should hit", btb_outputs.hit, 1'b1);
        check("New target should match", btb_outputs.br_target, 32'h3100);
        check_bit("New XCL should be 1", btb_outputs.XCL, 1'b1);
        check_bit("New ucond should be 1", btb_outputs.br_ucond, 1'b1);

        $display("");
    endtask

    // Test 13: Fill BTB with multiple entries
    task automatic test_fill_btb();
        test_num++;
        $display("[TEST %0d] Fill BTB with Multiple Entries", test_num);

        // Reset to start fresh
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        $display("  After reset:");
        display_btb();

        // Fill BTB with 8 different entries (assuming 8-entry BTB)
        for (int i = 0; i < 8; i++) begin
            @(posedge clk);
            btb_exe_br_valid = 1;
            btb_exe_br_eip = 32'h10000 + (i << 4);  // Different addresses, each to different index
            btb_exe_br_target = 32'h20000 + (i << 10);
            btb_exe_br_XCL = (i % 2 == 1);  // Alternate XCL flag
            btb_exe_br_ucond = (i % 3 == 0);  // Every 3rd is unconditional
            @(posedge clk);
            btb_exe_br_valid = 0;
            $display("  Added entry %0d: EIP=0x%h -> Target=0x%h", 
                     i, 32'h10000 + (i << 4), 32'h20000 + (i << 10));
        end

        @(posedge clk);
        $display("  BTB after filling:");
        display_btb();

        // Verify all entries hit
        for (int i = 0; i < 8; i++) begin
            @(posedge clk);
            btb_spc = 32'h10000 + (i << 4);
            @(posedge clk);
            $display("  Lookup %0d (0x%h): Hit=%b", i, btb_spc, btb_outputs.hit);
        end

        $display("");
    endtask

    // ========================================
    // Helper Functions
    // ========================================

    // Display BTB contents
    task automatic display_btb();
        int btb_size;
        btb_size = $size(btb_inst.btb_entry_arr);
        
        $display("  ----------------------------------------");
        $display("  BTB Contents (%0d entries):", btb_size);
        $display("  ----------------------------------------");
        $display("  Idx | V | Tag      | Target   | EIP      | XCL | Ucond");
        $display("  ----|---|----------|----------|----------|-----|------");
        
        for (int i = 0; i < btb_size; i++) begin
            if (btb_inst.btb_entry_arr[i].valid) begin
                $display("  %3d | %b | %8h | %8h | %8h |  %b  |  %b",
                    i,
                    btb_inst.btb_entry_arr[i].valid,
                    btb_inst.btb_entry_arr[i].tag,
                    btb_inst.btb_entry_arr[i].br_target,
                    btb_inst.btb_entry_arr[i].br_eip,
                    btb_inst.btb_entry_arr[i].XCL,
                    btb_inst.btb_entry_arr[i].br_ucond
                );
            end else begin
                $display("  %3d | %b | -------- | -------- | -------- | --- | -----",
                    i,
                    btb_inst.btb_entry_arr[i].valid
                );
            end
        end
        $display("  ----------------------------------------\n");
    endtask

    // Check function for verification
    function automatic void check(
        string name,
        logic [ADDRESS_BITS-1:0] actual,
        logic [ADDRESS_BITS-1:0] expected
    );
        if (actual === expected) begin
            $display("  [PASS] %s: 0x%h", name, actual);
            passed++;
        end else begin
            $display("  [FAIL] %s: Expected 0x%h, Got 0x%h", name, expected, actual);
            failed++;
        end
    endfunction

    // Single bit check function
    function automatic void check_bit(string name, logic actual, logic expected);
        if (actual === expected) begin
            $display("  [PASS] %s: %b", name, actual);
            passed++;
        end else begin
            $display("  [FAIL] %s: Expected %b, Got %b", name, expected, actual);
            failed++;
        end
    endfunction

    // Timeout watchdog
    initial begin
        #10000; // 10us timeout
        $display("\n[ERROR] Testbench timeout!");
        $finish;
    end

endmodule
