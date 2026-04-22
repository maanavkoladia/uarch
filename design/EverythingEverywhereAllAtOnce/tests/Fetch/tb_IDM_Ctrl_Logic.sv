import common_pkg::*;
import Fetch_pkg::*;
import IDM_pkg::*;
import core_common_pkg::*;
import interconnect_pkg::icache_2_core_t;

module tb_IDM_Ctrl_Logic();

    // DUT inputs
    address_t spc;
    idm_outputs_t idm_i;
    idm_invalidate_logic_output_t invalidate_logic_outs_i;
    btb_output_t btb_out_i;
    predictor_output_t pred_out_i;
    icache_2_core_t icache_out_i;
    spc_sel_logic_output_t spc_sel_logic_out_i;
    byte_t data_in[CACHE_LINES_SIZE_B];

    // DUT output
    idm_ctrl_logic_output_t out;

    // Test tracking
    int test_num = 0;
    int passed = 0;
    int failed = 0;

    // DUT instantiation
    IDM_Ctrl_Logic dut (
        .spc(spc),
        .idm_i(idm_i),
        .invalidate_logic_outs_i(invalidate_logic_outs_i),
        .btb_out_i(btb_out_i),
        .pred_out_i(pred_out_i),
        .icache_out_i(icache_out_i),
        .spc_sel_logic_out_i(spc_sel_logic_out_i),
        .data_in(data_in),
        .out(out)
    );

    // Main test sequence
    initial begin
        $display("========================================");
        $display("  IDM_Ctrl_Logic Testbench");
        $display("========================================\n");

        // Initialize
        init_inputs();

        // Run tests
        test_cache_miss_no_writes();
        test_cache_hit_invalid_slot();
        test_cache_hit_valid_slot_no_invalidation();
        test_cache_hit_invalidated_slot();
        test_slot_number_calculation();
        test_btb_hit_pred_taken();
        test_btb_hit_pred_not_taken();
        test_btb_miss_pred_taken();
        test_btb_hit_with_flush();
        test_xcl_branch_metadata();
        test_multiple_slots_invalidated();
        test_slot_protection();
        test_all_slots_invalid_cache_hit();
        test_data_loading();
        test_sequential_slot_fills();

        // Summary
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

    // Test 1: Cache miss - no writes to any slot
    task automatic test_cache_miss_no_writes();
        test_num++;
        $display("[TEST %0d] Cache Miss → No Writes", test_num);

        init_inputs();
        spc = 32'h1000;  // Slot 0
        icache_out_i.hit = 0;  // MISS
        invalidate_logic_outs_i.invalidate[0] = 1;  // Slot being invalidated

        #1;  // Combinational settle
        display_outputs();

        // Should NOT write valid=1 to any slot
        if (out.idm_input.req[0].valid == 0 &&
            out.push_success == 0 &&
            out.idm_input.req[0].ld_meta_data == 1) begin
            $display("  ✓ PASS: Cache miss prevents valid write");
            $display("    req[0].valid=%0b, push_success=%0b, ld_meta_data=%0b",
                     out.idm_input.req[0].valid, out.push_success, out.idm_input.req[0].ld_meta_data);
            passed++;
        end else begin
            $display("  ✗ FAIL: Cache miss but writes occurred");
            $display("    req[0].valid=%0b (expected 0), push_success=%0b (expected 0)",
                     out.idm_input.req[0].valid, out.push_success);
            failed++;
        end
        $display("");
    endtask

    // Test 2: Cache hit + invalid slot → should write
    task automatic test_cache_hit_invalid_slot();
        test_num++;
        $display("[TEST %0d] Cache Hit + Invalid Slot → Write to Slot", test_num);

        init_inputs();
        spc = 32'h2010;  // Slot 1
        icache_out_i.hit = 1;  // HIT
        idm_i.idm_slots[1].valid = 0;  // Slot invalid
        invalidate_logic_outs_i.invalidate[1] = 0;  // Not being invalidated

        // Setup test data
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            data_in[i] = 8'hAA + i;
        end

        #1;
        display_outputs();

        if (out.idm_input.req[1].valid == 1 &&
            out.idm_input.req[1].ld_meta_data == 1 &&
            out.idm_input.req[1].ld_data == 1 &&
            out.push_success == 1) begin
            $display("  ✓ PASS: Cache hit + invalid slot writes correctly");
            $display("    Slot 1: valid=%0b, ld_meta_data=%0b, ld_data=%0b, push_success=%0b",
                     out.idm_input.req[1].valid, out.idm_input.req[1].ld_meta_data,
                     out.idm_input.req[1].ld_data, out.push_success);
            passed++;
        end else begin
            $display("  ✗ FAIL: Should write to invalid slot on cache hit");
            $display("    Slot 1: valid=%0b, ld_meta_data=%0b, ld_data=%0b, push_success=%0b",
                     out.idm_input.req[1].valid, out.idm_input.req[1].ld_meta_data,
                     out.idm_input.req[1].ld_data, out.push_success);
            failed++;
        end
        $display("");
    endtask

    // Test 3: Cache hit + valid slot + no invalidation → should NOT write
    task automatic test_cache_hit_valid_slot_no_invalidation();
        test_num++;
        $display("[TEST %0d] Cache Hit + Valid Slot + No Invalidation → No Write", test_num);

        init_inputs();
        spc = 32'h3020;  // Slot 2
        icache_out_i.hit = 1;  // HIT
        idm_i.idm_slots[2].valid = 1;  // Slot VALID
        invalidate_logic_outs_i.invalidate[2] = 0;  // NOT being invalidated

        #1;
        display_outputs();

        if (out.idm_input.req[2].valid == 0 &&
            out.idm_input.req[2].ld_meta_data == 0 &&
            out.push_success == 0) begin
            $display("  ✓ PASS: Valid slot protected from overwrite");
            $display("    Slot 2: valid=%0b, ld_meta_data=%0b, push_success=%0b",
                     out.idm_input.req[2].valid, out.idm_input.req[2].ld_meta_data, out.push_success);
            passed++;
        end else begin
            $display("  ✗ FAIL: Valid slot should not be overwritten");
            $display("    Slot 2: valid=%0b, ld_meta_data=%0b, push_success=%0b",
                     out.idm_input.req[2].valid, out.idm_input.req[2].ld_meta_data, out.push_success);
            failed++;
        end
        $display("");
    endtask

    // Test 4: Cache hit + valid slot + being invalidated → should write
    task automatic test_cache_hit_invalidated_slot();
        test_num++;
        $display("[TEST %0d] Cache Hit + Valid Slot Being Invalidated → Write", test_num);

        init_inputs();
        spc = 32'h4000;  // Slot 0
        icache_out_i.hit = 1;  // HIT
        idm_i.idm_slots[0].valid = 1;  // Slot currently valid
        invalidate_logic_outs_i.invalidate[0] = 1;  // Being invalidated

        #1;
        display_outputs();

        if (out.idm_input.req[0].valid == 1 &&
            out.idm_input.req[0].ld_meta_data == 1 &&
            out.idm_input.req[0].ld_data == 1 &&
            out.push_success == 1) begin
            $display("  ✓ PASS: Invalidated slot can be overwritten");
            $display("    Slot 0: valid=%0b, ld_meta_data=%0b, ld_data=%0b, push_success=%0b",
                     out.idm_input.req[0].valid, out.idm_input.req[0].ld_meta_data,
                     out.idm_input.req[0].ld_data, out.push_success);
            passed++;
        end else begin
            $display("  ✗ FAIL: Invalidated slot should allow write");
            $display("    Slot 0: valid=%0b, ld_meta_data=%0b, push_success=%0b",
                     out.idm_input.req[0].valid, out.idm_input.req[0].ld_meta_data, out.push_success);
            failed++;
        end
        $display("");
    endtask

    // Test 5: Slot number calculation
    task automatic test_slot_number_calculation();
        int errors;
        test_num++;
        $display("[TEST %0d] Slot Number Calculation from SPC", test_num);

        init_inputs();
        icache_out_i.hit = 1;
        errors = 0;

        // Test each slot
        for (int slot = 0; slot < NUM_IDM_SLOTS; slot++) begin
            init_inputs();
            icache_out_i.hit = 1;
            spc = 32'h1000 + (slot << 4);  // Each slot is 16 bytes
            idm_i.idm_slots[slot].valid = 0;  // Make it writable

            #1;
            display_outputs();

            if (out.idm_input.req[slot].valid != 1) begin
                $display("  ✗ Slot %0d: SPC=0x%h should map to slot %0d, but req[%0d].valid=%0b",
                         slot, spc, slot, slot, out.idm_input.req[slot].valid);
                errors++;
            end
        end

        if (errors == 0) begin
            $display("  ✓ PASS: All slot calculations correct");
            passed++;
        end else begin
            $display("  ✗ FAIL: %0d slot calculation errors", errors);
            failed++;
        end
        $display("");
    endtask

    // Test 6: BTB hit + prediction taken → branch metadata
    task automatic test_btb_hit_pred_taken();
        test_num++;
        $display("[TEST %0d] BTB Hit + Pred Taken → Branch Metadata Loaded", test_num);

        init_inputs();
        spc = 32'h5000;  // Slot 0
        icache_out_i.hit = 1;
        idm_i.idm_slots[0].valid = 0;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'h5008;
        btb_out_i.br_target = 32'h7000;
        btb_out_i.XCL = 0;
        pred_out_i.taken = 1;
        spc_sel_logic_out_i.flush_reg = 0;

        #1;
        display_outputs();

        if (out.idm_input.req[0].br_valid == 1 &&
            out.idm_input.req[0].br_eip == 32'h5008 &&
            out.idm_input.req[0].br_target == 32'h7000 &&
            out.idm_input.req[0].br_xcl == 0) begin
            $display("  ✓ PASS: Branch metadata loaded correctly");
            $display("    br_valid=%0b, br_eip=0x%h, br_target=0x%h, br_xcl=%0b",
                     out.idm_input.req[0].br_valid, out.idm_input.req[0].br_eip,
                     out.idm_input.req[0].br_target, out.idm_input.req[0].br_xcl);
            passed++;
        end else begin
            $display("  ✗ FAIL: Branch metadata not loaded correctly");
            $display("    br_valid=%0b, br_eip=0x%h, br_target=0x%h",
                     out.idm_input.req[0].br_valid, out.idm_input.req[0].br_eip,
                     out.idm_input.req[0].br_target);
            failed++;
        end
        $display("");
    endtask

    // Test 7: BTB hit + prediction NOT taken → no branch metadata
    task automatic test_btb_hit_pred_not_taken();
        test_num++;
        $display("[TEST %0d] BTB Hit + Pred Not Taken → No Branch Metadata", test_num);

        init_inputs();
        spc = 32'h6010;  // Slot 1
        icache_out_i.hit = 1;
        idm_i.idm_slots[1].valid = 0;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'h6018;
        btb_out_i.br_target = 32'h8000;
        pred_out_i.taken = 0;  // NOT taken

        #1;
        display_outputs();

        if (out.idm_input.req[1].br_valid == 0) begin
            $display("  ✓ PASS: No branch metadata when prediction not taken");
            $display("    br_valid=%0b", out.idm_input.req[1].br_valid);
            passed++;
        end else begin
            $display("  ✗ FAIL: Branch metadata should not be set");
            $display("    br_valid=%0b (expected 0)", out.idm_input.req[1].br_valid);
            failed++;
        end
        $display("");
    endtask

    // Test 8: BTB miss + prediction taken → no branch metadata
    task automatic test_btb_miss_pred_taken();
        test_num++;
        $display("[TEST %0d] BTB Miss + Pred Taken → No Branch Metadata", test_num);

        init_inputs();
        spc = 32'h7020;  // Slot 2
        icache_out_i.hit = 1;
        idm_i.idm_slots[2].valid = 0;
        btb_out_i.hit = 0;  // BTB MISS
        pred_out_i.taken = 1;

        #1;
        display_outputs();

        if (out.idm_input.req[2].br_valid == 0) begin
            $display("  ✓ PASS: No branch metadata when BTB misses");
            $display("    br_valid=%0b", out.idm_input.req[2].br_valid);
            passed++;
        end else begin
            $display("  ✗ FAIL: Branch metadata should not be set on BTB miss");
            $display("    br_valid=%0b (expected 0)", out.idm_input.req[2].br_valid);
            failed++;
        end
        $display("");
    endtask

    // Test 9: BTB hit + pred taken + flush → no branch metadata
    task automatic test_btb_hit_with_flush();
        test_num++;
        $display("[TEST %0d] BTB Hit + Pred Taken + Flush → No Branch Metadata", test_num);

        init_inputs();
        spc = 32'h8030;  // Slot 3
        icache_out_i.hit = 1;
        idm_i.idm_slots[3].valid = 0;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'h8038;
        btb_out_i.br_target = 32'h9000;
        pred_out_i.taken = 1;
        spc_sel_logic_out_i.flush_reg = 1;  // FLUSH active

        #1;
        display_outputs();

        if (out.idm_input.req[3].br_valid == 0) begin
            $display("  ✓ PASS: Flush prevents branch metadata");
            $display("    br_valid=%0b", out.idm_input.req[3].br_valid);
            passed++;
        end else begin
            $display("  ✗ FAIL: Flush should prevent branch metadata");
            $display("    br_valid=%0b (expected 0)", out.idm_input.req[3].br_valid);
            failed++;
        end
        $display("");
    endtask

    // Test 10: XCL branch metadata
    task automatic test_xcl_branch_metadata();
        test_num++;
        $display("[TEST %0d] XCL Branch Metadata", test_num);

        init_inputs();
        spc = 32'hA00C;  // Slot 0
        icache_out_i.hit = 1;
        idm_i.idm_slots[0].valid = 0;
        btb_out_i.hit = 1;
        btb_out_i.br_eip = 32'hA00E;
        btb_out_i.br_target = 32'hB000;
        btb_out_i.XCL = 1;  // XCL branch
        pred_out_i.taken = 1;

        #1;
        display_outputs();

        if (out.idm_input.req[0].br_valid == 1 &&
            out.idm_input.req[0].br_xcl == 1) begin
            $display("  ✓ PASS: XCL branch metadata set correctly");
            $display("    br_valid=%0b, br_xcl=%0b", out.idm_input.req[0].br_valid, out.idm_input.req[0].br_xcl);
            passed++;
        end else begin
            $display("  ✗ FAIL: XCL branch metadata incorrect");
            $display("    br_valid=%0b, br_xcl=%0b", out.idm_input.req[0].br_valid, out.idm_input.req[0].br_xcl);
            failed++;
        end
        $display("");
    endtask

    // Test 11: Multiple slots invalidated
    task automatic test_multiple_slots_invalidated();
        test_num++;
        $display("[TEST %0d] Multiple Slots Invalidated", test_num);

        init_inputs();
        spc = 32'hC010;  // Slot 1
        icache_out_i.hit = 1;

        // Invalidate slots 0, 1, 2
        invalidate_logic_outs_i.invalidate[0] = 1;
        invalidate_logic_outs_i.invalidate[1] = 1;
        invalidate_logic_outs_i.invalidate[2] = 1;
        invalidate_logic_outs_i.invalidate[3] = 0;

        // All valid
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            idm_i.idm_slots[i].valid = 1;
        end

        #1;
        display_outputs();

        // Only slot 1 (target slot) should get valid=1 write
        // Slots 0, 2 should get ld_meta_data=1 but valid=0
        if (out.idm_input.req[0].ld_meta_data == 1 && out.idm_input.req[0].valid == 0 &&
            out.idm_input.req[1].ld_meta_data == 1 && out.idm_input.req[1].valid == 1 &&
            out.idm_input.req[2].ld_meta_data == 1 && out.idm_input.req[2].valid == 0 &&
            out.idm_input.req[3].ld_meta_data == 0 && out.idm_input.req[3].valid == 0 &&
            out.push_success == 1) begin
            $display("  ✓ PASS: Multiple invalidations handled correctly");
            $display("    Slot 0: ld_meta_data=%0b, valid=%0b", out.idm_input.req[0].ld_meta_data, out.idm_input.req[0].valid);
            $display("    Slot 1: ld_meta_data=%0b, valid=%0b (target)", out.idm_input.req[1].ld_meta_data, out.idm_input.req[1].valid);
            $display("    Slot 2: ld_meta_data=%0b, valid=%0b", out.idm_input.req[2].ld_meta_data, out.idm_input.req[2].valid);
            $display("    Slot 3: ld_meta_data=%0b, valid=%0b", out.idm_input.req[3].ld_meta_data, out.idm_input.req[3].valid);
            passed++;
        end else begin
            $display("  ✗ FAIL: Multiple invalidations not handled correctly");
            $display("    Slot 0: ld_meta_data=%0b, valid=%0b", out.idm_input.req[0].ld_meta_data, out.idm_input.req[0].valid);
            $display("    Slot 1: ld_meta_data=%0b, valid=%0b", out.idm_input.req[1].ld_meta_data, out.idm_input.req[1].valid);
            $display("    Slot 2: ld_meta_data=%0b, valid=%0b", out.idm_input.req[2].ld_meta_data, out.idm_input.req[2].valid);
            $display("    Slot 3: ld_meta_data=%0b, valid=%0b", out.idm_input.req[3].ld_meta_data, out.idm_input.req[3].valid);
            failed++;
        end
        $display("");
    endtask

    // Test 12: Slot protection - verify other slots not touched
    task automatic test_slot_protection();
        test_num++;
        $display("[TEST %0d] Slot Protection - Other Valid Slots Untouched", test_num);

        init_inputs();
        spc = 32'hD010;  // Slot 1
        icache_out_i.hit = 1;

        // Slot 1 invalid (target), others valid and not invalidated
        idm_i.idm_slots[0].valid = 1;
        idm_i.idm_slots[1].valid = 0;  // Target
        idm_i.idm_slots[2].valid = 1;
        idm_i.idm_slots[3].valid = 1;
        invalidate_logic_outs_i.invalidate = '{default: '0};

        #1;
        display_outputs();

        if (out.idm_input.req[0].ld_meta_data == 0 && out.idm_input.req[0].valid == 0 &&
            out.idm_input.req[1].ld_meta_data == 1 && out.idm_input.req[1].valid == 1 &&
            out.idm_input.req[2].ld_meta_data == 0 && out.idm_input.req[2].valid == 0 &&
            out.idm_input.req[3].ld_meta_data == 0 && out.idm_input.req[3].valid == 0) begin
            $display("  ✓ PASS: Other valid slots protected");
            $display("    Only slot 1 (target) modified");
            passed++;
        end else begin
            $display("  ✗ FAIL: Other slots incorrectly modified");
            for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
                $display("    Slot %0d: ld_meta_data=%0b, valid=%0b", i, out.idm_input.req[i].ld_meta_data, out.idm_input.req[i].valid);
            end
            failed++;
        end
        $display("");
    endtask

    // Test 13: All slots invalid + cache hit
    task automatic test_all_slots_invalid_cache_hit();
        test_num++;
        $display("[TEST %0d] All Slots Invalid + Cache Hit → Write Target Slot", test_num);

        init_inputs();
        spc = 32'hE020;  // Slot 2
        icache_out_i.hit = 1;

        // All slots invalid
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            idm_i.idm_slots[i].valid = 0;
        end

        #1;
        display_outputs();

        // All slots should have ld_meta_data=1, but only slot 2 should have valid=1
        if (out.idm_input.req[0].ld_meta_data == 1 && out.idm_input.req[0].valid == 0 &&
            out.idm_input.req[1].ld_meta_data == 1 && out.idm_input.req[1].valid == 0 &&
            out.idm_input.req[2].ld_meta_data == 1 && out.idm_input.req[2].valid == 1 &&
            out.idm_input.req[3].ld_meta_data == 1 && out.idm_input.req[3].valid == 0 &&
            out.push_success == 1) begin
            $display("  ✓ PASS: All invalid slots set ld_meta_data, only target gets valid");
            passed++;
        end else begin
            $display("  ✗ FAIL: Incorrect handling of all invalid slots");
            for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
                $display("    Slot %0d: ld_meta_data=%0b, valid=%0b", i, out.idm_input.req[i].ld_meta_data, out.idm_input.req[i].valid);
            end
            failed++;
        end
        $display("");
    endtask

    // Test 14: Data loading verification
    task automatic test_data_loading();
        int i, data_errors;
        test_num++;
        $display("[TEST %0d] Data Loading Verification", test_num);

        init_inputs();
        spc = 32'hF000;  // Slot 0
        icache_out_i.hit = 1;
        idm_i.idm_slots[0].valid = 0;

        // Fill data_in with test pattern
        for (i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            data_in[i] = 8'h10 + i;
        end

        #1;
        display_outputs();

        data_errors = 0;
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            if (out.idm_input.req[0].data[i] != data_in[i]) begin
                data_errors++;
            end
        end

        if (data_errors == 0 && out.idm_input.req[0].ld_data == 1) begin
            $display("  ✓ PASS: Data loaded correctly");
            $display("    All %0d bytes match, ld_data=%0b", CACHE_LINES_SIZE_B, out.idm_input.req[0].ld_data);
            passed++;
        end else begin
            $display("  ✗ FAIL: Data loading errors");
            $display("    %0d byte mismatches, ld_data=%0b", data_errors, out.idm_input.req[0].ld_data);
            failed++;
        end
        $display("");
    endtask

    // Test 15: Sequential slot fills
    task automatic test_sequential_slot_fills();
        int errors, slot, i;
        test_num++;
        $display("[TEST %0d] Sequential Slot Fills", test_num);

        errors = 0;

        for (slot = 0; slot < NUM_IDM_SLOTS; slot++) begin
            init_inputs();
            spc = 32'h10000 + (slot << 4);  // Different line for each slot
            icache_out_i.hit = 1;
            idm_i.idm_slots[slot].valid = 0;

            // Fill different data for each slot
            for (i = 0; i < CACHE_LINES_SIZE_B; i++) begin
                data_in[i] = 8'hA0 + slot * 16 + i;
            end

            #1;
            display_outputs();

            if (out.idm_input.req[slot].valid != 1 ||
                out.idm_input.req[slot].ld_data != 1 ||
                out.push_success != 1) begin
                $display("  ✗ Slot %0d fill failed: valid=%0b, ld_data=%0b, push_success=%0b",
                         slot, out.idm_input.req[slot].valid, out.idm_input.req[slot].ld_data, out.push_success);
                errors++;
            end
        end

        if (errors == 0) begin
            $display("  ✓ PASS: All slots can be filled sequentially");
            passed++;
        end else begin
            $display("  ✗ FAIL: %0d slot fill errors", errors);
            failed++;
        end
        $display("");
    endtask

    // ========================================
    // Helper Functions
    // ========================================

    function automatic void display_outputs();
        int i;
        $display("  ----------------------------------------");
        $display("  Output Details:");
        $display("  ----------------------------------------");
        for (i = 0; i < NUM_IDM_SLOTS; i++) begin
            $display("  Slot %0d:", i);
            $display("    valid        = %0b", out.idm_input.req[i].valid);
            $display("    ld_meta_data = %0b", out.idm_input.req[i].ld_meta_data);
            $display("    ld_data      = %0b", out.idm_input.req[i].ld_data);
            $display("    br_valid     = %0b", out.idm_input.req[i].br_valid);
            $display("    br_eip       = 0x%h", out.idm_input.req[i].br_eip);
            $display("    br_target    = 0x%h", out.idm_input.req[i].br_target);
            $display("    br_xcl       = %0b", out.idm_input.req[i].br_xcl);
        end
        $display("  push_success = %0b", out.push_success);
        $display("  ----------------------------------------");
    endfunction

    function automatic void init_inputs();
        spc = 32'h0;
        icache_out_i = '{default: '0};
        btb_out_i = '{default: '0};
        pred_out_i = '{default: '0};
        spc_sel_logic_out_i = '{default: '0};
        invalidate_logic_outs_i = '{default: '0};

        // Initialize IDM to all invalid
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            idm_i.idm_slots[i].valid = 0;
            idm_i.idm_slots[i].br_valid = 0;
            idm_i.idm_slots[i].br_eip = 32'h0;
            idm_i.idm_slots[i].br_btb_target = 32'h0;
            idm_i.idm_slots[i].br_xcl = 0;
        end

        // Initialize data_in
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            data_in[i] = 8'h0;
        end
    endfunction

endmodule
