import common_pkg::*;
import Fetch_pkg::*;
import IDM_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::icache_2_core_t;

module tb_SPC_IDM();

    // Clock and reset
    logic clk;
    logic rst;

    // ========================================
    // Testbench Inputs
    // ========================================
    address_t eip;
    bool flush;
    bool decode_stall;
    icache_2_core_t icache_out_i;
    byte_t data_in[CACHE_LINES_SIZE_B];
    
    // Execute branch resolution (for BTB updates and branch restore)
    bool exe_br_valid;
    address_t exe_br_target;
    address_t exe_br_eip;
    bool exe_br_taken;
    bool exe_br_XCL;
    bool exe_br_ucond;

    // ========================================
    // SPC Register and Selection Logic
    // ========================================
    address_t SPC;
    address_t next_spc;
    address_t spc_16;
    address_t br_restore_spc;
    address_t br_target;

    assign spc_16 = SPC + 16;

    assign br_restore_spc = exe_br_taken ? exe_br_target : exe_br_eip;

    assign br_target = spc_sel_logic_out.br_target_sel ?
                       spc_sel_logic_out.br_target :
                       btb_out.br_target;

    always_comb begin
        case(spc_sel_logic_out.sel)
            Fetch_pkg::SPC: next_spc = SPC;
            Fetch_pkg::SPC_P16: next_spc = spc_16;
            Fetch_pkg::BR_RESTORE: next_spc = br_restore_spc;
            Fetch_pkg::BTB_TARGET: next_spc = br_target;
            default: next_spc = 0;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            SPC <= 0;
        else
            SPC <= next_spc;
    end

    // ========================================
    // Module Outputs
    // ========================================
    btb_output_t btb_out;
    predictor_output_t pred_out;
    spc_sel_logic_output_t spc_sel_logic_out;
    idm_ctrl_logic_output_t ctrl_out;
    idm_invalidate_logic_output_t invalidate_out;
    idm_outputs_t idm_state;
    fetch_outputs_t fetch_outs;

    // Predictor inputs
    predictor_input_t pred_in;
    assign pred_in = '{
        btfn_target: btb_out.br_target,
        spc: SPC,
        exe_br_valid: exe_br_valid,
        exe_br_target: exe_br_target,
        exe_br_taken: exe_br_taken,
        exe_br_hit: exe_br_taken
    };

    // ========================================
    // Test tracking
    // ========================================
    int test_num = 0;
    int passed = 0;
    int failed = 0;
    int cycle_count;
    integer log_file;

    // ========================================
    // Module Instantiations
    // ========================================

    // BTB
    BTB btb (
        .clk(clk),
        .reset(rst),
        .spc(SPC),
        .exe_br_valid(exe_br_valid),
        .exe_br_target(exe_br_target),
        .exe_br_eip(exe_br_eip),
        .exe_br_XCL(exe_br_XCL),
        .exe_br_ucond(exe_br_ucond),
        .outputs(btb_out)
    );

    // Predictor
    Predictor predictor (
        .inputs(pred_in),
        .outputs(pred_out)
    );

    // SPC Selection Logic
    SPC_Sel_Logic spc_sel_logic (
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .decode_stall(decode_stall),
        .btb_outputs(btb_out),
        .pred_out(pred_out),
        .idm_ctrl_logic_out(ctrl_out),
        .outputs(spc_sel_logic_out)
    );

    // IDM Invalidate Logic
    IDM_Invalidate_Logic invalidate_logic (
        .clk(clk),
        .rst(rst),
        .eip(eip),
        .flush(flush),
        .exp_pipeclear(1'b0),  // Not testing exceptions
        .decode_stall(decode_stall),
        .idm_meta(idm_state),
        .out_invalidates(invalidate_out)
    );

    // IDM Control Logic
    IDM_Ctrl_Logic ctrl_logic (
        .rst(rst),
        .exp_pipe_clear(1'b0),  // Not testing exceptions
        .spc(SPC),
        .idm_i(idm_state),
        .invalidate_logic_outs_i(invalidate_out),
        .btb_out_i(btb_out),
        .pred_out_i(pred_out),
        .icache_out_i(icache_out_i),
        .spc_sel_logic_out_i(spc_sel_logic_out),
        .data_in(data_in),
        .out(ctrl_out)
    );

    // IDM Storage
    IDM idm (
        .clk(clk),
        .rst(rst),
        .fetch_outs_i(fetch_outs),
        .idm_outs_o(idm_state)
    );

    // Connect fetch outputs to IDM
    assign fetch_outs.idm_reqs = ctrl_out.idm_input;
    assign fetch_outs.exp_pipe_clear = 1'b0;
    assign fetch_outs.fetch_2_icache = '{default: '0};

    // ========================================
    // Clock generation
    // ========================================
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

    // ========================================
    // Main test sequence
    // ========================================
    initial begin
        // Open log file
        log_file = $fopen("tb_SPC_IDM.log", "w");
        if (log_file == 0) begin
            $display("ERROR: Could not open log file!");
            $finish;
        end

        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "  SPC-IDM Integration Testbench");
        $fdisplay(log_file, "========================================\n");

        // Initialize
        rst = 1;
        init_inputs();

        // Reset
        repeat(3) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Run tests
        test_sequential_fill_with_spc();
        test_btb_hit_and_branch_taken();
        test_xcl_branch_with_spc();
        test_branch_misprediction_flush();
        test_wraparound_with_branches();

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
        $display("\nLog file written to: tb_SPC_IDM.log");
        $finish;
    end

    // ========================================
    // Test Cases
    // ========================================

    // Test 1: Sequential fill with SPC progression
    task automatic test_sequential_fill_with_spc();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Sequential Fill with SPC Progression", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Let SPC drive sequential fills through slots 0, 1");

        init_inputs();

        // Cycle 0: Set initial SPC value
        force SPC = 32'h00001000;
        @(posedge clk);
        #1;
        release SPC;  // Release immediately so SPC can update normally

        // Cycle 1: Fill slot 0 at SPC=0x1000
        $fdisplay(log_file, "\n--- Cycle %0d: Initial SPC=0x1000, Fill Slot 0 ---", cycle_count);

        // Update inputs
        eip = 32'h00001000;
        icache_out_i.hit = 1;
        setup_cache_data(8'hA0);

        display_state();

        // Cycle 2: SPC should advance to 0x1010, check slot 0 filled
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Verify Slot 0 Filled, SPC advances to 0x1010 ---", cycle_count);

        // Assert slot 0 should be valid
        if (idm_state.idm_slots[0].valid != 1) begin
            $fdisplay(log_file, "FAIL: Slot 0 should be valid");
            failed++;
        end

        // SPC should have advanced to 0x00001010
        if (SPC != 32'h00001010) begin
            $fdisplay(log_file, "FAIL: SPC should be 0x00001010, got 0x%h", SPC);
            failed++;
        end

       // Update inputs - eip progresses within slot 0
        eip = 32'h00001004;
        icache_out_i.hit = 1;
        setup_cache_data(8'hA1);

        display_state();

        // Cycle 3: Check slot 1 filled, SPC at 0x00001020
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Slot 1 Filled, SPC=0x00001020 ---", cycle_count);

        // Assert slot 1 should be valid
        if (idm_state.idm_slots[1].valid != 1) begin
            $fdisplay(log_file, "FAIL: Slot 1 should be valid");
            failed++;
        end
        
        // SPC should be at 0x00001020
        if (SPC != 32'h00001020) begin
            $fdisplay(log_file, "FAIL: SPC should be 0x00001020, got 0x%h", SPC);
            failed++;
        end
        
        display_state();

        // Cycle 4: Move EIP to slot 1, should invalidate slot 0
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: EIP crosses to Slot 1 ---", cycle_count);
        
        // Update inputs - eip crosses to slot 1
        eip = 32'h00001010;
        icache_out_i.hit = 1;
        setup_cache_data(8'hA2);
        
        display_state();

        // Cycle 5: Verify slot 0 invalidated, slot 1 valid
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Verify Slot 0 Invalidated ---", cycle_count);
        
        if (idm_state.idm_slots[0].valid == 0 && idm_state.idm_slots[1].valid == 1) begin
            $fdisplay(log_file, "PASS: Sequential fill with SPC works correctly");
            passed++;
        end else begin
            $fdisplay(log_file, "FAIL: Slot 0 should be invalid, slot 1 valid");
            failed++;
        end
        
        display_state();
        $fdisplay(log_file, "");
    endtask

    // Test 2: BTB hit and branch taken
    task automatic test_btb_hit_and_branch_taken();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] BTB Hit and Branch Taken", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Fill BTB entry, hit it, take branch, SPC jumps to target");

        init_inputs();

        // Reset and set SPC to 0x00002000 first
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;

        // Cycle 1: Train BTB with branch at 0x00002008 -> 0x00005000
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Train BTB (br_eip=0x00002008, target=0x00005000) ---", cycle_count);

        // Update execute inputs to train BTB
        exe_br_valid = 1;
        exe_br_eip = 32'h00002008;
        exe_br_target = 32'h00001000;
        exe_br_XCL = 0;
        exe_br_ucond = 0;
        exe_br_taken = 1;

        display_state();

        // Cycle 2: Clear exe inputs, BTB now trained
        @(posedge clk);
        force SPC = 32'h00002000;
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: SPC=0x00002000, Should Hit BTB ---", cycle_count);

        // Clear exe inputs
        exe_br_valid = 0;

        // Set up cache hit - SPC already at 0x00002000
        eip = 32'h00002000;
        icache_out_i.hit = 1;
        setup_cache_data(8'hB0);

        display_state();
        release SPC;
        // Cycle 3: Check BTB hit, branch metadata loaded

        // BTB should hit
        if (btb_out.hit != 1) begin
            $fdisplay(log_file, "FAIL: BTB should hit on SPC=0x00002000");
            failed++;
        end

        @(posedge clk)
        // Branch metadata should be in slot 0
        #1
        $fdisplay(log_file, "we should now see the x2000 line in the idm with branhc taken");
        if (idm_state.idm_slots[0].br_valid != 1) begin
            $fdisplay(log_file, "FAIL: Slot 0 should be valid nch meta data");
            failed++;
        end

        // SPC should jump to target
        if (SPC != 32'h00001000) begin
            $fdisplay(log_file, "FAIL: SPC should jump to 0x00001000, got 0x%h", SPC);
            failed++;
        end
        
        // Update inputs
        eip = 32'h00002008;  // Reach branch EIP
        icache_out_i.hit = 1;
        setup_cache_data(8'hC0);
        
        display_state();

        // Cycle 4: Verify slot 0 invalidated and refilled with target
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Verify Branch Taken, Slot Refilled ---", cycle_count);
        eip = 32'h00001000;
        if (idm_state.idm_slots[0].valid == 1 && SPC == 32'h00001010) begin
            $fdisplay(log_file, "PASS: BTB hit and branch taken works");
            passed++;
        end else begin
            $fdisplay(log_file, "FAIL: Branch taken behavior incorrect");
            failed++;
        end
        
        display_state();
        $fdisplay(log_file, "");
    endtask









    // Test 3: XCL branch with SPC
    task automatic test_xcl_branch_with_spc();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] XCL Branch with SPC", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Train BTB with XCL branch, hit it, SPC goes to +16 then target");

        init_inputs();

        // Reset
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;

        // Cycle 1: Train BTB and set up for slot 0 fill
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Train BTB (XCL branch at 0x3018->0x2020), Start Fill Slot 0 ---", cycle_count);

        // Train BTB first
        exe_br_valid = 1;
        exe_br_eip = 32'h00003018;
        exe_br_target = 32'h00002020;
        exe_br_XCL = 1;
        exe_br_ucond = 0;
        exe_br_taken = 1;

        eip = 32'h00003000;
        force SPC = 32'h00003000;
        // Drive valid icache inputs
        icache_out_i.hit = 1;
        setup_cache_data(8'hD0);

        display_state();
        
        @(posedge clk);
        release SPC;
        #1;
        if (SPC != 32'h00003010) begin
            $fdisplay(log_file, "FAIL: SPC should be 3010. Got: %0h", SPC);
            failed++;
        end
        

        $fdisplay(log_file, "\n--- Cycle %0d: SPC=0x3010, Slot 0 Valid, BTB Hits ---", cycle_count);
        
        // Clear exe inputs after BTB training
        exe_br_valid = 0;
        
        // At this cycle, verify:
        // - SPC advanced to 0x3010
        // - Slot 0 is now valid (filled in previous cycle)
        // - BTB hits with XCL branch
        
        eip = 32'h00003004;
        icache_out_i.hit = 1;
        setup_cache_data(8'hD1);
        
        display_state();

        // Cycle 3: SPC advances to 0x3020 (XCL +16), slot 1 filled with branch metadata
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: SPC=0x3020 (XCL +16), Slot 1 Has Branch ---", cycle_count);
        if (SPC != 32'h00003020) begin
            $fdisplay(log_file, "FAIL: SPC should be 3020. Got: %0h", SPC);
            failed++;
        end
        eip = 32'h00003018;
        icache_out_i.hit = 1;
        setup_cache_data(8'hD2);
        $fdisplay(log_file, "DEBUG: sel raw value = %0d", spc_sel_logic_out.sel);
        display_state();

        // Cycle 4: EIP at branch, SPC jumps to target 0x2020, XCL_stall clears, invalidations occur
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: EIP at Branch, SPC Jumps to Target 0x2020 ---", cycle_count);
        if (SPC != 32'h00002020) begin
            $fdisplay(log_file, "FAIL: SPC should be 2020. Got: %0h", SPC);
            failed++;
        end
       // Move EIP to target area
        
        icache_out_i.hit = 1;
        setup_cache_data(8'hE0);
        #1
        $fdisplay(log_file, "DEBUG: sel raw value = %0d", spc_sel_logic_out.sel);
        display_state();

        // Cycle 5: SPC=0x2030, slot 3 filled at target
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: SPC=0x2030, Slot 3 Filled at Target ---", cycle_count);
        if (SPC != 32'h00002030) begin
            $fdisplay(log_file, "FAIL: SPC should be 2030. Got: %0h", SPC);
            failed++;
        end
        eip = 32'h00002020;
        
        icache_out_i.hit = 1;
        setup_cache_data(8'hE1);

        display_state();
        
        // Cycle 6: SPC=0x2040, slot 0 filled
        @(posedge clk);
        #1;
        eip = 32'h00002024;
        $fdisplay(log_file, "\n--- Cycle %0d: SPC=0x2040, Slot 0 Filled ---", cycle_count);
        if (SPC != 32'h00002040) begin
            $fdisplay(log_file, "FAIL: SPC should be 2040. Got: %0h", SPC);
            failed++;
        end

        
        display_state();
        
        // Cycle 7: Final verification - SPC=0x2050
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Final State - SPC=0x2050 ---", cycle_count);
        if (SPC != 32'h00002050) begin
            $fdisplay(log_file, "FAIL: SPC should be 2050. Got: %0h", SPC);
            failed++;
        end

        display_state();
        $fdisplay(log_file, "");
    endtask









    // Test 4: Branch misprediction and flush
    task automatic test_branch_misprediction_flush();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Branch Misprediction and Flush", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Take branch, then flush with exe correction");

        init_inputs();
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;
        
        // Cycle 1: Set up initial state at 0x00004000
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Initial State ---", cycle_count);
        
        force SPC = 32'h00004000;
        @(posedge clk);
        #1;
        release SPC;
        
        eip = 32'h00004000;
        icache_out_i.hit = 1;
        setup_cache_data(8'hE0);
        
        display_state();

        // Cycle 2: Fill some slots
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Fill Slots ---", cycle_count);
        
        if (idm_state.idm_slots[0].valid != 1) begin
            $fdisplay(log_file, "FAIL: Slot 0 should be filled");
            failed++;
        end
        
        eip = 32'h00004008;
        icache_out_i.hit = 1;
        setup_cache_data(8'hE1);
        
        display_state();

        // Cycle 3: Apply flush
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Apply Flush ---", cycle_count);
        
        flush = 1;
        exe_br_valid = 1;
        exe_br_taken = 0;  // Mispredicted as taken, actually not taken
        exe_br_eip = 32'h00004008;
        exe_br_target = 32'h00006000;
        
        display_state();

        // Cycle 4: Check all slots invalidated
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Verify All Slots Invalidated ---", cycle_count);
        
        flush = 0;
        exe_br_valid = 0;
        
        // Count valid slots
        begin
            int valid_count = 0;
            for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
                if (idm_state.idm_slots[i].valid) valid_count++;
            end
        
            if (valid_count != 0) begin
                $fdisplay(log_file, "FAIL: All slots should be invalid after flush");
                failed++;
            end
        
            // SPC should be restored to br_eip (fall through)
            if (SPC != 32'h00004008) begin
                $fdisplay(log_file, "FAIL: SPC should restore to 0x00004008, got 0x%h", SPC);
                failed++;
            end
        
            display_state();

            @(posedge clk);
            #1;
        
            if (valid_count == 0 && SPC == 32'h00004008) begin
                $fdisplay(log_file, "PASS: Flush and restore works correctly");
                passed++;
            end else begin
                $fdisplay(log_file, "FAIL: Flush behavior incorrect");
                // Already incremented failed above
            end
        end
        
        display_state();
        $fdisplay(log_file, "");
    endtask

    // Test 5: Wraparound with branches
    task automatic test_wraparound_with_branches();
        test_num++;
        $fdisplay(log_file, "\n[TEST %0d] Wraparound with Branches", test_num);
        $fdisplay(log_file, "========================================");
        $fdisplay(log_file, "Scenario: Fill all slots, wraparound, with branch in slot 2");

        init_inputs();
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;
        
        // Train BTB with branch in what will be slot 2
        exe_br_valid = 1;
        exe_br_eip = 32'h00008028;
        exe_br_target = 32'h0007000;
        exe_br_XCL = 0;
        exe_br_ucond = 0;
        exe_br_taken = 1;
        
        @(posedge clk);
        #1;
        exe_br_valid = 0;
        
        // Start at 0x00008000
        force SPC = 32'h00008000;
        @(posedge clk);
        #1;
        release SPC;
        
        // Fill slots 0, 1, 2 (with branch), 3
        for (int i = 0; i < 4; i++) begin
            @(posedge clk);
            #1;
            $fdisplay(log_file, "\n--- Cycle %0d: Fill Slot %0d ---", cycle_count, i);
            
            eip = 32'h00008000 + (i << 4);
            icache_out_i.hit = 1;
            setup_cache_data(8'hF0 + i);

            display_state();
        end

        // Check that we have branch metadata in slot 2
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Verify Branch in Slot 2 ---", cycle_count);

        if (idm_state.idm_slots[2].br_valid != 1) begin
            $fdisplay(log_file, "FAIL: Slot 2 should have branch metadata");
            failed++;
        end

        display_state();

        // Now wraparound - SPC should be at slot 0 address
        @(posedge clk);
        #1;
        $fdisplay(log_file, "\n--- Cycle %0d: Wraparound to Slot 0 ---", cycle_count);

        // Move EIP to trigger wraparound
        eip = 32'h00008040;
        icache_out_i.hit = 1;
        setup_cache_data(8'hF4);

        display_state();

        @(posedge clk);
        #1;

        if (idm_state.idm_slots[3].valid == 0 && idm_state.idm_slots[0].valid == 1) begin
            $fdisplay(log_file, "PASS: Wraparound with branches works");
            passed++;
        end else begin
            $fdisplay(log_file, "FAIL: Wraparound behavior with branches incorrect");
            failed++;
        end

        display_state();
        $fdisplay(log_file, "");
    endtask

    // ========================================
    // Helper Functions
    // ========================================

    function automatic void init_inputs();
        eip = 32'h00000000;
        flush = 0;
        decode_stall = 0;
        icache_out_i = '{default: '0};
        exe_br_valid = 0;
        exe_br_target = 32'h00000000;
        exe_br_eip = 32'h00000000;
        exe_br_taken = 0;
        exe_br_XCL = 0;
        exe_br_ucond = 0;
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            data_in[i] = 8'h0;
        end
    endfunction

    function automatic void setup_cache_data(byte_t base_val);
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            data_in[i] = base_val + i;
        end
    endfunction

    // Comprehensive state display
    task automatic display_state();
        automatic logic [1:0] curr_slot;
        automatic logic [1:0] eip_slot;
        
        #1;  // Allow combinational logic to settle
        
        curr_slot = SPC[5:4];
        eip_slot = eip[5:4];
        
        $fdisplay(log_file, "  ╔════════════════════════════════════════════════════════════════════════════╗");
        $fdisplay(log_file, "  ║                        SPC-IDM SYSTEM STATE                                ║");
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ SPC & EIP:                                                                 ║");
        $fdisplay(log_file, "  ║   SPC=0x%08h  next_spc=0x%08h  spc_16=0x%08h          ║", SPC, next_spc, spc_16);
        $fdisplay(log_file, "  ║   EIP=0x%08h  prev_eip=0x%08h                              ║", eip, invalidate_logic.prev_eip);
        $fdisplay(log_file, "  ║   Current SPC Slot: %0d    Current EIP Slot: %0d                             ║", curr_slot, eip_slot);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ SPC Selection Logic:                                                       ║");
        $fdisplay(log_file, "  ║   sel=%s  br_target_sel=%0d  br_target=0x%08h          ║", 
                  get_spc_sel_name(spc_sel_logic_out.sel), spc_sel_logic_out.br_target_sel, spc_sel_logic_out.br_target);
        $fdisplay(log_file, "  ║   XCL_stall=%0d  flush_reg=%0d  br_restore_spc=0x%08h              ║", 
                  spc_sel_logic.XCL_stall, spc_sel_logic_out.flush_reg, br_restore_spc);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ BTB Output:                                                                ║");
        $fdisplay(log_file, "  ║   hit=%0d  br_eip=0x%08h  br_target=0x%08h                 ║", 
                  btb_out.hit, btb_out.br_eip, btb_out.br_target);
        $fdisplay(log_file, "  ║   XCL=%0d  br_ucond=%0d                                                     ║", 
                  btb_out.XCL, btb_out.br_ucond);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ Predictor:                                                                 ║");
        $fdisplay(log_file, "  ║   taken=%0d                                                                  ║", pred_out.taken);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ Invalidation Logic:                                                        ║");
        $fdisplay(log_file, "  ║   slot_in_use_changed=%0d  will_leave_for_br=%0d  no_writes=%0d            ║",
                  invalidate_logic.slot_in_use_changed, invalidate_logic.will_leave_for_br, invalidate_out.no_writes);
        $fdisplay(log_file, "  ║   Invalidations: [3]=%0d [2]=%0d [1]=%0d [0]=%0d                           ║",
                  invalidate_out.invalidate[3], invalidate_out.invalidate[2], 
                  invalidate_out.invalidate[1], invalidate_out.invalidate[0]);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ ICache:                                                                    ║");
        $fdisplay(log_file, "  ║   hit=%0d  push_success=%0d                                                ║", 
                  icache_out_i.hit, ctrl_out.push_success);
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ IDM Requests (from Control Logic):                                        ║");
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            $fdisplay(log_file, "  ║   Slot %0d: valid=%0d  ld_meta_data=%0d  ld_data=%0d                           ║",
                      i, ctrl_out.idm_input.req[i].valid, ctrl_out.idm_input.req[i].ld_meta_data, ctrl_out.idm_input.req[i].ld_data);
        end
        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");

        // Display IDM slots
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            $fdisplay(log_file, "  ║ IDM Slot %0d:                                                               ║", i);
            $fdisplay(log_file, "  ║   valid=%0d  br_valid=%0d  br_xcl=%0d                                       ║",
                      idm_state.idm_slots[i].valid, idm_state.idm_slots[i].br_valid, idm_state.idm_slots[i].br_xcl);
            if (idm_state.idm_slots[i].br_valid) begin
                $fdisplay(log_file, "  ║   br_eip=0x%08h  br_target=0x%08h                         ║",
                          idm_state.idm_slots[i].br_eip, idm_state.idm_slots[i].br_btb_target);
            end
            $fdisplay(log_file, "  ║   data[0:3]=0x%02h%02h%02h%02h                                              ║",
                      idm_state.idm_slots[i].data[0], idm_state.idm_slots[i].data[1],
                      idm_state.idm_slots[i].data[2], idm_state.idm_slots[i].data[3]);
        end

        $fdisplay(log_file, "  ╠════════════════════════════════════════════════════════════════════════════╣");
        $fdisplay(log_file, "  ║ BTB Contents:                                                              ║");
        display_btb_contents();
        $fdisplay(log_file, "  ╚════════════════════════════════════════════════════════════════════════════╝");
        $fdisplay(log_file, "");
    endtask

    // Display BTB contents (hierarchical access)
    task automatic display_btb_contents();
        for (int i = 0; i < 8; i++) begin  // BTB has 8 entries
            if (btb.btb_entry_arr[i].valid) begin
                $fdisplay(log_file, "  ║   [%0d] tag=0x%h eip=0x%08h->0x%08h XCL=%0d ucond=%0d  ║",
                          i, btb.btb_entry_arr[i].tag,
                          btb.btb_entry_arr[i].br_eip, btb.btb_entry_arr[i].br_target,
                          btb.btb_entry_arr[i].XCL, btb.btb_entry_arr[i].br_ucond);
            end
        end
    endtask

    // Helper to convert SPC_SEL enum to string
    function automatic string get_spc_sel_name(spc_sel_logic_output_options_e sel);
        case (sel)
            Fetch_pkg::SPC: return "SPC     ";
            Fetch_pkg::SPC_P16: return "SPC_P16 ";
            Fetch_pkg::BR_RESTORE: return "BR_RST  ";
            Fetch_pkg::BTB_TARGET: return "BTB_TGT ";
            default: return "UNKNOWN ";
        endcase
    endfunction

endmodule