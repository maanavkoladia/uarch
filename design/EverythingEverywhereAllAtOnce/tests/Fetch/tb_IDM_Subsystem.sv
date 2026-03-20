import common_pkg::*;
import Fetch_pkg::*;
import IDM_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::icache_2_core_t;

module tb_IDM_Subsystem();

    // Clock and reset
    logic clk;
    logic rst;

    // Inputs to subsystem
    address_t spc;
    address_t eip;
    bool flush;
    bool exp_pipeclear;
    bool decode_stall;
    btb_output_t btb_out_i;
    predictor_output_t pred_out_i;
    icache_2_core_t icache_out_i;
    spc_sel_logic_output_t spc_sel_logic_out_i;
    byte_t data_in[CACHE_LINES_SIZE_B];

    // IDM outputs
    idm_outputs_t idm_state;

    // Module outputs
    idm_ctrl_logic_output_t ctrl_out;
    idm_invalidate_logic_output_t invalidate_out;

    // Fetch outputs for IDM
    fetch_outputs_t fetch_outs;

    // Test tracking
    int test_num = 0;
    int passed = 0;
    int failed = 0;
    int cycle_count;

    // File logging
    integer log_file;

    // Instantiate IDM_Ctrl_Logic
    IDM_Ctrl_Logic ctrl_logic (
        .spc(spc),
        .idm_i(idm_state),
        .invalidate_logic_outs_i(invalidate_out),
        .btb_out_i(btb_out_i),
        .pred_out_i(pred_out_i),
        .icache_out_i(icache_out_i),
        .spc_sel_logic_out_i(spc_sel_logic_out_i),
        .data_in(data_in),
        .out(ctrl_out)
    );

    // Instantiate IDM_Invalidate_Logic
    IDM_Invalidate_Logic invalidate_logic (
        .clk(clk),
        .rst(rst),
        .eip(eip),
        .flush(flush),
        .exp_pipeclear(exp_pipeclear),
        .decode_stall(decode_stall),
        .idm_meta(idm_state),
        .out_invalidates(invalidate_out)
    );

    // Instantiate IDM (storage)
    IDM idm (
        .clk(clk),
        .rst(rst),
        .fetch_outs_i(fetch_outs),
        .idm_outs_o(idm_state)
    );

    // Connect fetch outputs to IDM
    assign fetch_outs.idm_reqs = ctrl_out.idm_input;
    assign fetch_outs.exp_pipe_clear = exp_pipeclear;
    assign fetch_outs.fetch_2_icache = '{default: '0};  // Not used in this test

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Cycle counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    // Display state on every clock cycle
    /*always @(posedge clk) begin
        if (!rst) begin
            #1;  // Wait for combinational logic to settle
            display_state();
        end
    end*/

    // Main test sequence
    initial begin
        // Open log file
        log_file = $fopen("tb_IDM_Subsystem.log", "w");
        if (log_file == 0) begin
            $display("ERROR: Could not open log file!");
            $finish;
        end

        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "  IDM Subsystem Integration Testbench");
        $fdisplay(log_file, "========================================\n");

        // Initialize
        rst = 1;
        init_inputs();

        // Reset
        repeat(3) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Run tests
        test_sequential_fill_and_progression();
        test_branch_invalidation_and_refill();
        test_xcl_branch_scenario();
        test_slot_protection_during_refill();
        test_multiple_sequential_fills();
        test_branch_then_sequential_invalidation();
        test_all_slots_filled_then_wraparound();
        test_flush_and_restart();

        // Summary
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n========================================");
        $fdisplay(log_file, "  Test Summary");
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "  Passed: %0d", passed);
        $fdisplay(log_file, "  Failed: %0d", failed);
        $fdisplay(log_file, "  Total:  %0d", passed + failed);
        if (failed == 0) begin
            $fdisplay(log_file, "  STATUS: ALL TESTS PASSED!");
        end else begin
            $fdisplay(log_file, "  STATUS: SOME TESTS FAILED");
        end
        $fdisplay(log_file, "========================================\n");

        $fclose(log_file);
        $display("\nLog file written to: tb_IDM_Subsystem.log");
        $finish;
    end

    // ========================================
    // Test Cases
    // ========================================

    // Test 1: Sequential fill and progression
    task automatic test_sequential_fill_and_progression();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Sequential Fill and Progression", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Fill slot 0, progress through it, fill slot 1");

        init_inputs();

        // Cycle 1: Fill slot 0
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Fill Slot 0 (SPC=0x1000) ---", cycle_count);
        spc = 32'h1000;  // Slot 0
        eip = 32'h1000;
        icache_out_i.hit = 1;
        setup_cache_data(8'hA0);
        //display_state();

        // Cycle 2: Check slot 0 is valid, then progress within slot 0
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Progress within Slot 0 (EIP=0x1004) ---", cycle_count);
        assert (idm_state.idm_slots[0].valid == 1) else begin
            $fdisplay(log_file, "FAIL: Slot 0 should be valid after fill");
            failed++;
        end

        eip = 32'h1004;
        //display_state();

        // Cycle 3: Check slot 0 still valid, then cross to slot 1
        @(posedge clk);
        #1;
        //cycle
        $fdisplay(log_file, "\n--- Cycle %0d: Cross to Slot 1 (EIP=0x1010) ---", cycle_count);
        $fdisplay(log_file, "starting cycle %0d: invalid for 0 should be set to 1 and incoming slot 1 should be valid", cycle_count);
        //assert
        assert (idm_state.idm_slots[0].valid == 1) else begin
            $fdisplay(log_file, "FAIL: Slot 0 should remain valid");
            failed++;
        end
        //updating inputs
        spc = 32'h1010;  // Slot 1
        eip = 32'h1010;
        icache_out_i.hit = 1;
        setup_cache_data(8'hB0);

        //display
        //display_state();

        // Cycle 4: Check slot 0 invalid and slot 1 valid
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n -- Cycle %0d: Ending test case. doing asserts", cycle_count);
        begin
            automatic logic assertion_passed = 1;
            assert (idm_state.idm_slots[0].valid == 0 && idm_state.idm_slots[1].valid == 1) else begin
                $fdisplay(log_file, "FAIL: Slot 0 should be invalid, slot 1 should be valid");
                failed++;
                assertion_passed = 0;
            end
            if (assertion_passed) begin
                $fdisplay(log_file, "PASS: Sequential progression and slot management correct");
                passed++;
            end
        end
        display_state();

        $fdisplay(log_file, "");
        
    endtask



    // Test 2: Branch invalidation and refill
    task automatic test_branch_invalidation_and_refill();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Branch Invalidation and Refill", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Fill slot 0 with branch, take branch, refill slot 0 with new data");

        init_inputs();
        @(posedge clk);
        #1;

        // Fill slot 0 with branch
        $fdisplay(log_file, "\n--- Fill Slot 0 with Branch at 0x2008");

        //update inputs 
        spc = 32'h2000;
        eip = 32'h2000;
        icache_out_i.hit = 1;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'h2008;
        btb_out_i.br_target = 32'h5000;
        btb_out_i.XCL = 0;
        pred_out_i.taken = 1;
        setup_cache_data(8'hC0);
        display_state();

        // Progress to branch EIP
        @(posedge clk); //on this cycle we evaulate the branch. SPC should be fetching the next cache line at x5000. 
                        //That has a branch that is xcl but we get a miss
        #1;
        $fdisplay(log_file, "\n--- Progress to Branch EIP (0x2008), Invalidate signal Slot0 should be 1");

        #1;
        if (idm_state.idm_slots[0].br_valid != 1) begin
            $fdisplay(log_file, "FAIL: Branch metadata should be loaded");
            failed++;
        end

        //update inputs
        spc = 32'h5000;
        eip = 32'h2008;
        icache_out_i.hit = 0;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'h5000;
        btb_out_i.br_target = 32'h2000;
        btb_out_i.XCL = 1;
        pred_out_i.taken = 1;
        setup_cache_data(8'hC0);

        display_state();

        // Refill slot 0 with new target data
        @(posedge clk); //we are still stalling at this point slot 0 should be invalid but will be valid on the next cycle when we get a hit 
                        //nothing should be pending on invalidation since we are waiting to grab cache line we need to operate on 
        #1;
        $fdisplay(log_file, "\n--- Refill Slot 0 at Branch Target (0x5000) ---");

        #1;
        if (idm_state.idm_slots[0].valid != 0) begin
            $fdisplay(log_file, "FAIL: Slot 0 should be invalidated at branch");
            failed++;
        end

        //update inputs
       //update inputs
        spc = 32'h5000;
        eip = 32'h5000;
        icache_out_i.hit = 1;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'h5000;
        btb_out_i.br_target = 32'h2030;
        btb_out_i.XCL = 1;
        pred_out_i.taken = 1;
        setup_cache_data(8'hD0);

        display_state();


        @(posedge clk); //fetching next cache line. nothing changes with eip since we are doing a branch_xcl so decode would theoretically see an invalid instruction

        #1;
        $fdisplay(log_file, "\n-- getting next slot cache line for xcl");

        #1;
        if (idm_state.idm_slots[0].valid != 1) begin
            $fdisplay(log_file, "FAIL: Slot 0 should be valid at branch");
            failed++;
        end

        //update inputs
       //update inputs
        spc = 32'h5010;
        eip = 32'h5000;
        icache_out_i.hit = 1;
        btb_out_i.hit = 0;
        btb_out_i.br_eip = 32'h5000;
        btb_out_i.br_target = 32'h2000;
        btb_out_i.XCL = 0;
        pred_out_i.taken = 0;
        setup_cache_data(8'hE0);

        display_state();

        @(posedge clk); //we should see that both slot 0 and 1 are up for pending invalidation

        #1;
        $fdisplay(log_file, "\n-- serving branch");

        #1;
        if (idm_state.idm_slots[0].valid != 1) begin
            $fdisplay(log_file, "FAIL: Slot 0 should be valid at branch");
            failed++;
        end

        //update inputs
       //update inputs
        spc = 32'h2030;
        eip = 32'h5000;
        icache_out_i.hit = 1;
        btb_out_i.hit = 0;
        btb_out_i.br_eip = 32'h0000;
        btb_out_i.br_target = 32'h0000;
        btb_out_i.XCL = 0;
        pred_out_i.taken = 0;
        setup_cache_data(8'h33);

        display_state();


        @(posedge clk)
        #1;
        $fdisplay(log_file, "\n-- on slot 3... slot 0 and 1 should be invalid");

        #1;
        $fdisplay(log_file, "\n---Ending tests and checking final asserts");

        if (idm_state.idm_slots[0].valid != 1 && idm_state.idm_slots[1].valid != 0 &&  idm_state.idm_slots[3].valid != 1)  begin
            $fdisplay(log_file, "FAIL: Slot 0 should be refilled with new data");
            failed++;
        end else begin
            $fdisplay(log_file, "  ✓ PASS: Branch invalidation and refill works correctly");
            passed++;
        end
        $fdisplay(log_file, "");


    endtask

    // Test 3: XCL branch scenario
    task automatic test_xcl_branch_scenario();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] XCL Branch Scenario", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Fill slots 0 & 1, XCL branch at end of slot 0");

        init_inputs();
        @(posedge clk);
        #1;

        // Fill slot 0 with XCL branch
        $fdisplay(log_file, "\n--- Fill Slot 0 with XCL Branch ---");
        spc = 32'h3000;
        eip = 32'h3000;
        icache_out_i.hit = 1;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'h300E;  // Near end of slot 0
        btb_out_i.br_target = 32'h7000;
        btb_out_i.XCL = 1;
        pred_out_i.taken = 1;
        setup_cache_data(8'hE0);
        @(posedge clk);
        #1;

        // Fill slot 1
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Fill Slot 1 (continuation of XCL) ---");
        spc = 32'h3010;
        eip = 32'h3008;
        btb_out_i.hit = 0;
        pred_out_i.taken = 0;
        icache_out_i.hit = 1;
        setup_cache_data(8'hE1);
        @(posedge clk);
        #1;

        // Progress to XCL branch point
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Reach XCL Branch EIP, Should Invalidate Both Slots ---");
        eip = 32'h300E;
        @(posedge clk);
        #1;
        if (idm_state.idm_slots[0].valid != 0 || idm_state.idm_slots[1].valid != 0) begin
            $fdisplay(log_file, "  ✗ FAIL: Both slots should be invalidated for XCL branch");
            failed++;
        end else begin
            $fdisplay(log_file, "  ✓ PASS: XCL branch invalidates both slots correctly");
            passed++;
        end
        $fdisplay(log_file, "");
    endtask

    // Test 4: Slot protection during refill
    task automatic test_slot_protection_during_refill();
        byte_t original_data;
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Slot Protection During Refill", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Try to refill valid slot without invalidation");

        init_inputs();
        @(posedge clk);
        #1;

        // Fill slot 2
        $fdisplay(log_file, "\n--- Fill Slot 2 ---");
        spc = 32'h4020;
        eip = 32'h4020;
        icache_out_i.hit = 1;
        setup_cache_data(8'hF0);
        @(posedge clk);
        #1;
        if (idm_state.idm_slots[2].valid != 1) begin
            $fdisplay(log_file, "  ✗ FAIL: Slot 2 should be filled");
            failed++;
        end

        // Try to refill slot 2 without invalidating
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Try to Refill Slot 2 (should be protected) ---");
        spc = 32'h4020;  // Same slot
        eip = 32'h4024;  // Different EIP but same slot
        icache_out_i.hit = 1;
        setup_cache_data(8'hF1);  // Different data
        original_data = idm_state.idm_slots[2].data[0];
        @(posedge clk);
        #1;
        if (idm_state.idm_slots[2].data[0] != original_data) begin
            $fdisplay(log_file, "  ✗ FAIL: Slot 2 should be protected from overwrite");
            failed++;
        end else begin
            $fdisplay(log_file, "  ✓ PASS: Valid slot protected from overwrite");
            passed++;
        end
        $fdisplay(log_file, "");
    endtask

    // Test 5: Multiple sequential fills
    task automatic test_multiple_sequential_fills();
        int valid_count;
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Multiple Sequential Fills", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Sequentially fill all 4 slots");

        init_inputs();

        for (int slot = 0; slot < NUM_IDM_SLOTS; slot++) begin
            @(posedge clk);
            #1;
            $fdisplay(log_file, "\n--- Cycle %0d: Fill Slot %0d ---", cycle_count, slot);
            spc = 32'h6000 + (slot << 4);
            eip = 32'h6000 + (slot << 4);
            icache_out_i.hit = 1;
            setup_cache_data(8'hA0 + slot);
            @(posedge clk);
            #1;
        end

        // Verify all slots valid
        valid_count = 0;
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            if (idm_state.idm_slots[i].valid) valid_count++;
        end

        if (valid_count == NUM_IDM_SLOTS) begin
            $fdisplay(log_file, "  ✓ PASS: All %0d slots filled successfully", NUM_IDM_SLOTS);
            passed++;
        end else begin
            $fdisplay(log_file, "  ✗ FAIL: Only %0d/%0d slots filled", valid_count, NUM_IDM_SLOTS);
            failed++;
        end
        $fdisplay(log_file, "");
    endtask

    // Test 6: Branch then sequential invalidation
    task automatic test_branch_then_sequential_invalidation();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Branch Then Sequential Invalidation", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Branch to new slot, then sequentially move to next");

        init_inputs();
        @(posedge clk);
        #1;

        // Fill slot 0 with branch
        $fdisplay(log_file, "\n--- Fill Slot 0 with Branch ---");
        spc = 32'h7000;
        eip = 32'h7000;
        icache_out_i.hit = 1;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'h7008;
        btb_out_i.br_target = 32'h8000;
        pred_out_i.taken = 1;
        setup_cache_data(8'h10);
        @(posedge clk);
        #1;

        // Take branch to new address (slot 0 based on bits [5:4])
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Take Branch, Refill Slot 0 ---");
        spc = 32'h8000;
        eip = 32'h8000;
        btb_out_i.hit = 0;
        pred_out_i.taken = 0;
        setup_cache_data(8'h20);
        @(posedge clk);
        #1;

        // Sequential progression to slot 1
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Sequential Move to Slot 1 ---");
        spc = 32'h8010;
        eip = 32'h8010;
        setup_cache_data(8'h21);
        @(posedge clk);
        #1;

        if (idm_state.idm_slots[0].valid == 0 && idm_state.idm_slots[1].valid == 1) begin
            $fdisplay(log_file, "  ✓ PASS: Branch + sequential invalidation works");
            passed++;
        end else begin
            $fdisplay(log_file, "  ✗ FAIL: Invalidation pattern incorrect");
            failed++;
        end
        $fdisplay(log_file, "");
    endtask

    // Test 7: All slots filled then wraparound
    task automatic test_all_slots_filled_then_wraparound();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] All Slots Filled Then Wraparound", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Fill all slots, then wrap from slot 3 to slot 0");

        init_inputs();

        // Fill all 4 slots sequentially
        for (int slot = 0; slot < NUM_IDM_SLOTS; slot++) begin
            @(posedge clk);
            #1;
            spc = 32'h9000 + (slot << 4);
            eip = 32'h9000 + (slot << 4);
            icache_out_i.hit = 1;
            setup_cache_data(8'h30 + slot);
        end

        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- All Slots Filled ---");

        // Wraparound from slot 3 to slot 0
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Wraparound: Slot 3 -> Slot 0 ---");
        spc = 32'h9040;  // Wraps to slot 0
        eip = 32'h9040;
        setup_cache_data(8'h34);
        @(posedge clk);
        #1;

        if (idm_state.idm_slots[3].valid == 0 && idm_state.idm_slots[0].valid == 1) begin
            $fdisplay(log_file, "  ✓ PASS: Wraparound invalidation works");
            passed++;
        end else begin
            $fdisplay(log_file, "  ✗ FAIL: Wraparound behavior incorrect");
            failed++;
        end
        $fdisplay(log_file, "");
    endtask

    // Test 8: Flush and restart
    task automatic test_flush_and_restart();
        int valid_after_flush;
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Flush and Restart", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Fill slots, flush all, restart from new address");

        init_inputs();

        // Fill some slots
        for (int slot = 0; slot < 2; slot++) begin
            @(posedge clk);
            #1;
            spc = 32'hA000 + (slot << 4);
            eip = 32'hA000 + (slot << 4);
            icache_out_i.hit = 1;
            setup_cache_data(8'h40 + slot);
        end

        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Before Flush ---");

        // Flush
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Applying Flush ---");
        flush = 1;
        @(posedge clk);
        #1;

        valid_after_flush = 0;
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            if (idm_state.idm_slots[i].valid) valid_after_flush++;
        end

        if (valid_after_flush != 0) begin
            $fdisplay(log_file, "  ✗ FAIL: All slots should be invalid after flush");
            failed++;
        end else begin
            $fdisplay(log_file, "  ✓ PASS: Flush cleared all slots");
        end

        // Restart from new address
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Restart from New Address ---");
        flush = 0;
        spc = 32'hB000;
        eip = 32'hB000;
        icache_out_i.hit = 1;
        setup_cache_data(8'h50);
        @(posedge clk);
        #1;

        if (idm_state.idm_slots[0].valid == 1) begin
            $fdisplay(log_file, "  ✓ PASS: Restart after flush works");
            passed++;
        end else begin
            $fdisplay(log_file, "  ✗ FAIL: Refill after flush failed");
            failed++;
        end
        $fdisplay(log_file, "");
    endtask

    // ========================================
    // Helper Functions
    // ========================================

    // Helper task to log to file
    task automatic log_msg(string msg);
        $fdisplay(log_file, "%s", msg);
    endtask

    function automatic void init_inputs();
        spc = 32'h0;
        eip = 32'h0;
        flush = 0;
        exp_pipeclear = 0;
        decode_stall = 0;
        btb_out_i = '{default: '0};
        pred_out_i = '{default: '0};
        icache_out_i = '{default: '0};
        spc_sel_logic_out_i = '{default: '0};
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            data_in[i] = 8'h0;
        end
    endfunction

    function automatic void setup_cache_data(byte_t base_val);
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            data_in[i] = base_val + i;
        end
    endfunction

    task automatic display_state();
        #1;  // Allow combinational logic to settle before sampling
        $fdisplay(log_file, "  ╔════════════════════════════════════════════════════════════════╗");
        $fdisplay(log_file, "  ║                    IDM SUBSYSTEM STATE                         ║");
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ Inputs: SPC=0x%h  EIP=0x%h                        ║", spc, eip);
        $fdisplay(log_file, "  ║         ICache Hit=%0b  Flush=%0b  Stall=%0b                          ║",
                 icache_out_i.hit, flush, decode_stall);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ Control Logic Debug:                                           ║");
        $fdisplay(log_file, "  ║   slot_num=%0d (from spc[5:4])                                  ║", ctrl_logic.slot_num);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ Control Requests:                                              ║");
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            $fdisplay(log_file, "  ║   Slot %0d: valid=%0b ld_meta=%0b ld_data=%0b                          ║",
                     i, ctrl_out.idm_input.req[i].valid,
                     ctrl_out.idm_input.req[i].ld_meta_data,
                     ctrl_out.idm_input.req[i].ld_data);
            $fdisplay(log_file, "  ║         (idm_valid=%0b, invalidate=%0b)                         ║",
                     idm_state.idm_slots[i].valid, invalidate_out.invalidate[i]);
        end
        $fdisplay(log_file, "  ║   push_success=%0b                                              ║", ctrl_out.push_success);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ Invalidations: [%0b %0b %0b %0b]                                      ║",
                 invalidate_out.invalidate[0], invalidate_out.invalidate[1],
                 invalidate_out.invalidate[2], invalidate_out.invalidate[3]);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ Invalidate Logic Debug:                                        ║");
        $fdisplay(log_file, "  ║   prev_eip=0x%h  eip=0x%h                          ║",
                 invalidate_logic.prev_eip, eip);
        $fdisplay(log_file, "  ║   prev_slot=%0d  curr_slot=%0d  slot_changed=%0b                     ║",
                 invalidate_logic.prev_eip_slot_num,
                 invalidate_logic.eip_slot_num,
                 invalidate_logic.slot_in_use_changed);
        $fdisplay(log_file, "  ║   will_leave_for_br=%0b                                         ║",
                 invalidate_logic.will_leave_for_br);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ IDM Slot State:                                                ║");
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            $fdisplay(log_file, "  ║ Slot %0d: V=%0b  BR_V=%0b  BR_EIP=0x%h  BR_TGT=0x%h   ║",
                     i,
                     idm_state.idm_slots[i].valid,
                     idm_state.idm_slots[i].br_valid,
                     idm_state.idm_slots[i].br_eip,
                     idm_state.idm_slots[i].br_btb_target);
            $fdisplay(log_file, "  ║         XCL=%0b  Data[0]=0x%h                                   ║",
                     idm_state.idm_slots[i].br_xcl,
                     idm_state.idm_slots[i].data[0]);
        end
        $fdisplay(log_file, "  ╚════════════════════════════════════════════════════════════════╝");
    endtask

    // Timeout watchdog
    initial begin
        #100000;
        $display("\n✗ ERROR: Testbench timeout!");
        $finish;
    end

endmodule
