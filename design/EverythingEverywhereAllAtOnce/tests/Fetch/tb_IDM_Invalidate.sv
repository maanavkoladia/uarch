import common_pkg::*;
import Fetch_pkg::*;
import IDM_pkg::*;

module tb_IDM_Invalidate();

    // Clock and reset
    logic clk;
    logic rst;

    // DUT inputs
    address_t eip;
    bool flush;
    bool exp_pipeclear;
    bool decode_stall;
    idm_outputs_t idm_meta;

    // DUT output
    idm_invalidate_logic_output_t out_invalidates;

    // Test tracking
    int test_num = 0;
    int passed = 0;
    int failed = 0;

    // DUT instantiation
    IDM_Invalidate_Logic dut (
        .clk(clk),
        .rst(rst),
        .eip(eip),
        .flush(flush),
        .exp_pipeclear(exp_pipeclear),
        .decode_stall(decode_stall),
        .idm_meta(idm_meta),
        .out_invalidates(out_invalidates)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main test sequence
    initial begin
        $display("========================================");
        $display("  IDM_Invalidate_Logic Testbench");
        $display("========================================\n");

        // Initialize
        rst = 1;
        eip = 32'h0;
        flush = 0;
        exp_pipeclear = 0;
        decode_stall = 0;
        init_idm();

        // Reset
        repeat(3) @(posedge clk);
        rst = 0;
        @(posedge clk);
        #1;

        // Run tests
        test_startup_no_invalidation();
        test_normal_sequential_progression();
        test_slot_boundary_invalidation();
        test_regular_branch_invalidation();
        test_xcl_branch_both_valid();
        test_xcl_branch_next_invalid();
        test_simultaneous_sequential_and_branch();
        test_decode_stall_blocks_invalidation();
        test_invalid_slot_no_action();
        test_flush_invalidates_all();
        test_exp_pipeclear_invalidates_all();
        test_flush_restart_behavior();
        test_multiple_slot_transitions();
        test_branch_not_at_eip();
        test_slot_wraparound();
        test_back_to_back_branches();
        test_xcl_sequential_same_cycle();
        test_decode_stall_during_branch();
        test_flush_during_sequential();
        test_branch_then_refill_same_slot();
        test_branch_refill_sequential();
        test_multiple_branches_with_refills();

        // Summary
        @(posedge clk);
        #1;
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

    // Test 1: Startup - prev_eip = eip, no invalidation
    task automatic test_startup_no_invalidation();
        test_num++;
        $display("[TEST %0d] Startup: prev_eip = eip → No Invalidation", test_num);

        @(posedge clk);
        #1;
        eip = 32'h1000;  // Slot 0
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);  // Valid, no branch
        flush = 0;
        exp_pipeclear = 0;
        decode_stall = 0;

        @(posedge clk);
        #1;
        display_debug_info("After startup");
        check_invalidation("Startup should not invalidate anything", 4'b0000);
        $display("");
    endtask

    // Test 2: Normal sequential progression within same slot
    task automatic test_normal_sequential_progression();
        test_num++;
        $display("[TEST %0d] Sequential Progression Within Same Slot", test_num);

        @(posedge clk);
        #1;
        eip = 32'h1000;  // Slot 0, offset 0
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);

        @(posedge clk);
        #1;
        eip = 32'h1004;  // Slot 0, offset 4 (same slot)
        #1
        display_debug_info("After progression in same slot");
        check_invalidation("Same slot progression should not invalidate", 4'b0000);
        $display("");
    endtask

    // Test 3: Slot boundary crossing - sequential invalidation
    task automatic test_slot_boundary_invalidation();
        test_num++;
        $display("[TEST %0d] Slot Boundary Crossing → Invalidate Previous", test_num);

        // Start in slot 0
        @(posedge clk);
        #1
        eip = 32'h100C;  // Slot 0, near end
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);

        // Move to slot 1 - check invalidation combinationally BEFORE next clock
        @(posedge clk);
        #1
        eip = 32'h1010;  // Slot 1, offset 0
        #1;  // Let combinational logic settle
        display_debug_info("During slot boundary cross");
        check_invalidation("Should invalidate slot 0", 4'b0001);
        $display("  Crossed from slot 0 to slot 1");
        $display("");
    endtask

    // Test 4: Regular (non-XCL) branch invalidation
    task automatic test_regular_branch_invalidation();
        test_num++;
        $display("[TEST %0d] Regular Branch Taken → Invalidate Current Slot", test_num);

        @(posedge clk);
        #1;
        eip = 32'h2000;  // Slot 0
        setup_slot(0, 1, 1, 32'h2000, 32'h5000, 0);  // Branch at 0x2000, not XCL
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);

        @(posedge clk);
        #1;
        // EIP reaches branch
        eip = 32'h2000;
        #1;  // Check in same cycle when at branch EIP
        display_debug_info("At branch EIP");
        check_invalidation("Should invalidate slot 0 (branch)", 4'b0001);
        $display("  Branch at EIP=0x%h, target=0x5000", eip);
        $display("");
    endtask

    // Test 5: XCL branch with both slots valid
    task automatic test_xcl_branch_both_valid();
        test_num++;
        $display("[TEST %0d] XCL Branch, Next Slot Valid → Invalidate Both", test_num);

        @(posedge clk);
        #1;
        eip = 32'h300C;  // Slot 0, near boundary
        setup_slot(0, 1, 1, 32'h300C, 32'h7000, 1);  // XCL branch at 0x300C
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);  // Next slot valid

        @(posedge clk);
        #1;
        eip = 32'h300C;  // At branch EIP
        #1;  // Check in same cycle
        display_debug_info("At XCL branch with both valid");
        check_invalidation("Should invalidate slots 0 and 1", 4'b0011);
        $display("  XCL branch spans slot 0 and 1, target=0x7000");
        $display("");
    endtask

    // Test 6: XCL branch with next slot invalid (stall case)
    task automatic test_xcl_branch_next_invalid();
        test_num++;
        $display("[TEST %0d] XCL Branch, Next Slot Invalid → No Invalidation", test_num);

        @(posedge clk);
        #1;
        eip = 32'h400C;  // Slot 0
        setup_slot(0, 1, 1, 32'h400C, 32'h8000, 1);  // XCL branch
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);  // Next slot INVALID

        @(posedge clk);
        #1;
        eip = 32'h400C;  // At branch EIP
        #1;  // Check in same cycle
        display_debug_info("At XCL branch with next invalid");
        check_invalidation("XCL with invalid next slot should not invalidate", 4'b0000);
        $display("  Waiting for next cache line to arrive");
        $display("");
    endtask

    // Test 7: Sequential + Branch invalidation same cycle
    task automatic test_simultaneous_sequential_and_branch();
        test_num++;
        $display("[TEST %0d] Sequential + Branch Same Cycle → Both Invalidate", test_num);

        // Setup: slot 0 valid, slot 1 valid with branch at start
        @(posedge clk);
        #1;
        eip = 32'h500C;  // Slot 0, near end
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 1, 32'h5010, 32'h9000, 0);  // Branch at slot 1 start

        // Move to slot 1 and hit branch immediately
        @(posedge clk);
        #1;
        eip = 32'h5010;  // Slot 1, at branch EIP
        #1;  // Check in same cycle
        display_debug_info("Sequential + Branch same cycle");
        check_invalidation("Should invalidate slot 0 (sequential) and slot 1 (branch)", 4'b0011);
        $display("  Crossed to slot 1 which has branch at entry");
        $display("");
    endtask

    // Test 8: decode_stall blocks all invalidation
    task automatic test_decode_stall_blocks_invalidation();
        test_num++;
        $display("[TEST %0d] Decode Stall → No Invalidation", test_num);

        @(posedge clk);
        #1;
        eip = 32'h6000;  // Slot 0
        setup_slot(0, 1, 1, 32'h6000, 32'hA000, 0);  // Branch at EIP
        decode_stall = 1;  // Stall active

        @(posedge clk);
        #1;
        eip = 32'h6000;
        #1;  // Check immediately when decode_stall is active
        display_debug_info("During decode stall");
        check_invalidation("Decode stall should block all invalidation", 4'b0000);

        // Clear stall
        decode_stall = 0;
        @(posedge clk);
        #1;
        $display("");
    endtask

    // Test 9: Invalid slot → no action
    task automatic test_invalid_slot_no_action();
        test_num++;
        $display("[TEST %0d] Invalid Current Slot → No Invalidation", test_num);

        @(posedge clk);
        #1;
        eip = 32'h7000;  // Slot 0
        setup_slot(0, 0, 1, 32'h7000, 32'hB000, 0);  // INVALID slot with branch

        @(posedge clk);
        #1;
        eip = 32'h7000;
        #1;  // Check immediately
        display_debug_info("Invalid slot test");
        check_invalidation("Invalid slot should not trigger invalidation", 4'b0000);
        $display("");
    endtask

    // Test 10: Flush invalidates everything
    task automatic test_flush_invalidates_all();
        test_num++;
        $display("[TEST %0d] Flush → Invalidate All Slots", test_num);

        @(posedge clk);
        #1;
        eip = 32'h8000;
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(2, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 1, 0, 32'h0, 32'h0, 0);
        flush = 1;

        @(posedge clk);
        #1;
        display_debug_info("During flush");
        check_invalidation("Flush should invalidate all slots", 4'b1111);

        flush = 0;
        @(posedge clk);
        $display("");
    endtask

    // Test 11: exp_pipeclear invalidates everything
    task automatic test_exp_pipeclear_invalidates_all();
        test_num++;
        $display("[TEST %0d] Exception Pipe Clear → Invalidate All", test_num);

        @(posedge clk);
        #1;
        eip = 32'h9000;
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);
        exp_pipeclear = 1;

        @(posedge clk);
        #1;
        display_debug_info("During exp_pipeclear");
        check_invalidation("exp_pipeclear should invalidate all slots", 4'b1111);

        exp_pipeclear = 0;
        @(posedge clk);
        #1;
        $display("");
    endtask

    // Test 12: After flush restart - prev_eip interaction
    task automatic test_flush_restart_behavior();
        test_num++;
        $display("[TEST %0d] Flush Restart: prev_eip Behavior", test_num);

        // Normal operation in slot 1
        @(posedge clk);
        #1;
        eip = 32'h1010;  // Slot 1
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);
        flush = 0;

        // Flush occurs
        @(posedge clk);
        #1;
        flush = 1;
        eip = 32'h2000;  // Restore to slot 0

        @(posedge clk);
        #1;
        check_invalidation("Flush invalidates all", 4'b1111);

        // First cycle after flush
        flush = 0;
        @(posedge clk);
        #1;
        eip = 32'h2000;  // Stay at restore address

        @(posedge clk);
        #1;
        display_debug_info("First cycle after flush");
        check_invalidation("First cycle after flush: prev_eip updated, no slot change", 4'b0000);
        $display("  prev_eip should now equal eip (0x2000)");

        // Continue execution
        @(posedge clk);
        #1;
        eip = 32'h2010;  // Move to slot 1
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);
        #1;  // Check in same cycle
        display_debug_info("After flush restart progression");
        check_invalidation("Should invalidate slot 0 after restart", 4'b0001);
        $display("  Normal sequential invalidation resumes");
        $display("");
    endtask

    // Test 13: Multiple slot transitions
    task automatic test_multiple_slot_transitions();
        test_num++;
        $display("[TEST %0d] Multiple Consecutive Slot Transitions", test_num);

        // Slot 0 → 1 → 2 → 3
        @(posedge clk);
        #1;
        eip = 32'h100C;  // Slot 0
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(2, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 1, 0, 32'h0, 32'h0, 0);

        @(posedge clk);
        #1;
        eip = 32'h1010;  // Slot 1
        #1;
        display_debug_info("Transition 0→1");
        check_invalidation("Invalidate slot 0", 4'b0001);

        @(posedge clk);
        #1;
        eip = 32'h1020;  // Slot 2
        #1;
        display_debug_info("Transition 1→2");
        check_invalidation("Invalidate slot 1", 4'b0010);

        @(posedge clk);
        #1;
        eip = 32'h1030;  // Slot 3
        #1;
        display_debug_info("Transition 2→3");
        check_invalidation("Invalidate slot 2", 4'b0100);

        $display("  Sequential march through all slots");
        $display("");
    endtask

    // Test 14: Branch valid but EIP not at branch yet
    task automatic test_branch_not_at_eip();
        test_num++;
        $display("[TEST %0d] Branch Exists But EIP Not At Branch → No Branch Invalidation", test_num);

        @(posedge clk);
        #1;
        eip = 32'h3000;  // Slot 0, offset 0
        setup_slot(0, 1, 1, 32'h3008, 32'hC000, 0);  // Branch at 0x3008

        @(posedge clk);
        #1;
        eip = 32'h3004;  // Still before branch
        #1;  // Check immediately
        display_debug_info("Before branch EIP");
        check_invalidation("Branch exists but not at br_eip yet", 4'b0000);
        $display("  EIP=0x%h, branch at 0x3008", eip);
        $display("");
    endtask

    // Test 15: Slot wraparound (slot 3 → slot 0)
    task automatic test_slot_wraparound();
        test_num++;
        $display("[TEST %0d] Slot Wraparound: Slot 3 → Slot 0", test_num);

        @(posedge clk);
        #1;
        eip = 32'h103C;  // Slot 3, near end
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(2, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 1, 0, 32'h0, 32'h0, 0);

        @(posedge clk);
        #1;
        eip = 32'h1040;  // Wraps to slot 0
        #1;  // Check in same cycle
        display_debug_info("Slot wraparound 3→0");
        check_invalidation("Should invalidate slot 3", 4'b1000);
        $display("  Wrapped from slot 3 back to slot 0");
        $display("");
    endtask

    // Test 16: Back-to-back branches
    task automatic test_back_to_back_branches();
        test_num++;
        $display("[TEST %0d] Back-to-Back Branches in Different Slots", test_num);

        // Cycle 0: Both slots 0 and 1 have branches, at slot 0 branch
        @(posedge clk);
        #1;
        eip = 32'h4000;  // Slot 0, at branch
        setup_slot(0, 1, 1, 32'h4000, 32'h5010, 0);  // Branch to slot 1
        setup_slot(1, 1, 1, 32'h5010, 32'h6000, 0);  // Branch at slot 1 entry
        setup_slot(2, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C0: First branch at slot 0");
        check_invalidation("C0: Branch should invalidate slot 0", 4'b0001);

        // Cycle 1: Hardware has invalidated slot 0, refilled it, now at slot 1 branch
        @(posedge clk);
        #1;
        eip = 32'h5010;  // At slot 1, at branch
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);  // Refilled with new data, no branch
        setup_slot(1, 1, 1, 32'h5010, 32'h6000, 0);  // Still has branch from C0
        setup_slot(2, 1, 0, 32'h0, 32'h0, 0);  // Filled with branch target data
        setup_slot(3, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C1: Second branch at slot 1");
        check_invalidation("C1: Should invalidate slot 1 only (no sequential)", 4'b0010);
        $display("  Two branches in succession - prev_eip tracks branch target correctly");
        $display("");
    endtask

    // Test 17: XCL + Sequential same cycle (complex case)
    task automatic test_xcl_sequential_same_cycle();
        test_num++;
        $display("[TEST %0d] XCL Branch + Sequential Transition Same Cycle", test_num);

        // Slot 0 -> Slot 1 transition where slot 1 has XCL branch at entry
        @(posedge clk);
        #1;
        eip = 32'h700C;  // Slot 0, end
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 1, 32'h7010, 32'h9000, 1);  // XCL at slot 1 start
        setup_slot(2, 1, 0, 32'h0, 32'h0, 0);  // Next slot valid

        @(posedge clk);
        #1;
        eip = 32'h7010;  // Move to slot 1, hit XCL branch
        #1;  // Check in same cycle
        display_debug_info("XCL + Sequential same cycle");
        check_invalidation("Should invalidate 0 (seq), 1 (XCL current), 2 (XCL next)", 4'b0111);
        $display("  Complex case: all three invalidation sources active");
        $display("");
    endtask

    // Test 18: Decode stall during branch
    task automatic test_decode_stall_during_branch();
        test_num++;
        $display("[TEST %0d] Decode Stall While At Branch EIP", test_num);

        @(posedge clk);
        #1;
        eip = 32'h8000;  // Slot 0
        setup_slot(0, 1, 1, 32'h8000, 32'hD000, 0);
        decode_stall = 0;

        // Hit branch but stall
        @(posedge clk);
        #1;
        eip = 32'h8000;
        decode_stall = 1;

        @(posedge clk);
        #1;
        display_debug_info("Decode stall at branch");
        check_invalidation("Decode stall prevents branch invalidation", 4'b0000);

        // Release stall
        @(posedge clk);
        #1;
        decode_stall = 0;
        #1;  // Check in same cycle as stall releases
        display_debug_info("After stall release");
        check_invalidation("After stall release, branch invalidates", 4'b0001);
        $display("");
    endtask

    // Test 19: Flush during sequential transition
    task automatic test_flush_during_sequential();
        test_num++;
        $display("[TEST %0d] Flush During Slot Transition", test_num);

        @(posedge clk);
        #1;
        eip = 32'h900C;  // Slot 0
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(2, 1, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 1, 0, 32'h0, 32'h0, 0);
        flush = 0;

        // Start transition but flush intervenes
        @(posedge clk);
        #1;
        eip = 32'h9010;  // Would go to slot 1
        flush = 1;  // But flush happens

        @(posedge clk);
        #1;
        display_debug_info("Flush during transition");
        check_invalidation("Flush overrides sequential logic", 4'b1111);

        flush = 0;
        @(posedge clk);
        $display("");
    endtask




    // Test 20: Branch then refill same slot - should NOT invalidate refilled slot
    task automatic test_branch_then_refill_same_slot();
        test_num++;
        $display("[TEST %0d] Branch From Slot 0 to Slot 0 (different line) → No False Invalidation", test_num);

        // Cycle 0: Setup slot 0 with branch to different slot 0 address
        @(posedge clk);
        #1;
        eip = 32'h1008;  // Slot 0 (0x1000-0x100F range)
        setup_slot(0, 1, 1, 32'h1008, 32'h2000, 0);  // Branch to 0x2000 (also slot 0, 0x2000-0x200F range)
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);

        $display("  Initial: slot[0]=valid with branch to 0x2000 (also slot 0)");

        // Cycle 1: At branch - should invalidate slot 0
        @(posedge clk);
        #1;
        eip = 32'h1008;  // At branch EIP
        // Keep same slot setup
        setup_slot(0, 1, 1, 32'h1008, 32'h2000, 0);
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C1: At branch");
        check_invalidation("C1: Branch should invalidate slot 0", 4'b0001);

        // Cycle 2: After branch - hardware refilled slot 0, now at target (SAME slot number)
        @(posedge clk);
        #1;
        eip = 32'h2000;  // Target is also slot 0 (different cache line)
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);  // Slot 0 refilled with 0x2000 range, no branch
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);
        // At this point:
        // - prev_eip in DUT = 0x1008 (slot 0)
        // - eip = 0x2000 (slot 0)
        // - Both map to slot 0!
        // - slot_in_use_changed = (0 != 0) = false
        // - Should NOT invalidate anything
        #1;
        display_debug_info("C2: After branch to same slot");
        $display("  prev_eip=0x%h (slot 0), eip=0x%h (slot 0)", dut.prev_eip, eip);
        $display("  Both addresses map to slot 0, no slot change");
        check_invalidation("C2: Same slot number, should NOT invalidate", 4'b0000);

        $display("  This case should work correctly (staying in same slot)");
        $display("");
    endtask

    // Test 21: Branch, refill, then sequential progression - EXPOSES THE BUG
    task automatic test_branch_refill_sequential();
        test_num++;
        $display("[TEST %0d] Branch With Refill → Tests prev_eip Tracking", test_num);

        // Cycle 0: Setup - slot 0 with branch, slot 1 invalid initially
        @(posedge clk);
        #1;
        eip = 32'h1008;  // Before branch
        setup_slot(0, 1, 1, 32'h1009, 32'h2010, 0);  // Branch at 0x1009 to 0x2010 (slot 1)
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);  // Slot 1 initially invalid
        setup_slot(2, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C0: Before branch");
        $display("  Initial: slot[0]=valid(branch at 0x1009→0x2010), slot[1]=invalid");

        // Cycle 1: At branch EIP
        @(posedge clk);
        #1;
        eip = 32'h1009;  // At branch EIP
        // Keep same slot setup - nothing changed yet
        setup_slot(0, 1, 1, 32'h1009, 32'h2010, 0);
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(2, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C1: At branch EIP");
        check_invalidation("C1: Branch should invalidate slot 0", 4'b0001);

        // Cycle 2: Hardware invalidated slot 0 and refilled it, now at target

        @(posedge clk);
        #1;
        eip = 32'h2010;  // At branch target (slot 1)
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);  // Refilled with 0x2000 line, no branch
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);  // Filled with 0x2010 line, no branch
        setup_slot(2, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C2: After branch and refill");
        $display("  Hardware refilled both slots. prev_eip should be 0x2010 (branch target)");
        check_invalidation("C2: Should NOT invalidate - prev_eip should track branch target", 4'b0000);
        $display("");
    endtask

    // Test 22: Multiple branches with refills
    task automatic test_multiple_branches_with_refills();
        test_num++;
        $display("[TEST %0d] Multiple Branches With Refills", test_num);

        // Setup cycle: Initialize prev_eip to something in slot 3 to avoid false sequential invalidation
        @(posedge clk);
        #1;
        eip = 32'h3030;  // Slot 3
        setup_slot(0, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(2, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 1, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C-1: Setup prev_eip");

        // Cycle 0: At branch in slot 0 → slot 1
        @(posedge clk);
        #1;
        eip = 32'h3000;  // Slot 0, at branch
        setup_slot(0, 1, 1, 32'h3000, 32'h4010, 0);  // Branch to slot 1
        setup_slot(1, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(2, 0, 0, 32'h0, 32'h0, 0);
        setup_slot(3, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C0: First branch 0→1");
        check_invalidation("C0: Sequential (3→0) + Branch → invalidate slots 0 and 3", 4'b1001);

        // Cycle 1: Jumped to slot 1, which ALSO has a branch!
        @(posedge clk);
        #1;
        eip = 32'h4010;  // Slot 1, AT another branch
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);  // Refilled, no branch
        setup_slot(1, 1, 1, 32'h4010, 32'h5020, 0);  // Filled with branch to slot 2
        setup_slot(2, 0, 0, 32'h0, 32'h0, 0);  // Not filled yet
        setup_slot(3, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C1: At second branch 1→2");
        check_invalidation("C1: Should invalidate slot 1 (branch, no sequential)", 4'b0010);

        // Cycle 2: Jumped to slot 2, no branch there
        @(posedge clk);
        #1;
        eip = 32'h5020;  // Slot 2
        setup_slot(0, 1, 0, 32'h0, 32'h0, 0);  // Still refilled
        setup_slot(1, 1, 0, 32'h0, 32'h0, 0);  // Refilled after invalidation
        setup_slot(2, 0, 0, 32'h0, 32'h0, 0);  // Filled with target data
        setup_slot(3, 0, 0, 32'h0, 32'h0, 0);
        #1;
        display_debug_info("C2: After second branch");
        check_invalidation("C2: Should NOT invalidate - prev_eip tracked branch", 4'b0000);

        $display("  Two back-to-back branches: prev_eip_next fix prevents false sequential invalidation");
        $display("");
    endtask

    // ========================================
    // Helper Functions
    // ========================================

    // Initialize IDM to empty state
    function automatic void init_idm();
        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            idm_meta.idm_slots[i].valid = 0;
            idm_meta.idm_slots[i].br_valid = 0;
            idm_meta.idm_slots[i].br_eip = 32'h0;
            idm_meta.idm_slots[i].br_btb_target = 32'h0;
            idm_meta.idm_slots[i].br_xcl = 0;
        end
    endfunction

    // Setup a specific slot
    function automatic void setup_slot(
        int slot_num,
        bit valid,
        bit br_valid,
        address_t br_eip,
        address_t br_target,
        bit br_xcl
    );
        idm_meta.idm_slots[slot_num].valid = valid;
        idm_meta.idm_slots[slot_num].br_valid = br_valid;
        idm_meta.idm_slots[slot_num].br_eip = br_eip;
        idm_meta.idm_slots[slot_num].br_btb_target = br_target;
        idm_meta.idm_slots[slot_num].br_xcl = br_xcl;
    endfunction

    // Check specific invalidation pattern
    function automatic void check_invalidation(string name, logic [3:0] expected);
        logic [3:0] actual = {
            out_invalidates.invalidate[3],
            out_invalidates.invalidate[2],
            out_invalidates.invalidate[1],
            out_invalidates.invalidate[0]
        };

        if (actual === expected) begin
            $display("  ✓ PASS: %s", name);
            $display("    Invalidation: [3:0] = 4'b%04b", actual);
            passed++;
        end else begin
            $display("  ✗ FAIL: %s", name);
            $display("    Expected: 4'b%04b", expected);
            $display("    Got:      4'b%04b", actual);
            failed++;
        end
    endfunction

    // Display debug information including prev_eip
    function automatic void display_debug_info(string label = "");
        logic [$clog2(NUM_IDM_SLOTS)-1:0] eip_slot, prev_eip_slot;
        address_t prev_eip_val;

        prev_eip_val = dut.prev_eip;

        eip_slot = eip[$clog2(NUM_IDM_SLOTS)+$clog2(CACHE_LINES_SIZE_B)-1
                      :$clog2(CACHE_LINES_SIZE_B)];
        prev_eip_slot = prev_eip_val[$clog2(NUM_IDM_SLOTS)+$clog2(CACHE_LINES_SIZE_B)-1
                                     :$clog2(CACHE_LINES_SIZE_B)];

        if (label != "")
            $display("  [DEBUG %s]", label);
        else
            $display("  [DEBUG]");

        $display("    Current EIP:  0x%08h (slot %0d)", eip, eip_slot);
        $display("    Previous EIP: 0x%08h (slot %0d)", prev_eip_val, prev_eip_slot);
        $display("    prev_eip_next: 0x%08h", dut.prev_eip_next);
        $display("    Slot Changed: %0b (prev=%0d, curr=%0d)",
                 (eip_slot != prev_eip_slot), prev_eip_slot, eip_slot);


        // Show decision signals
        $display("    will_leave_for_br: %0b", dut.will_leave_for_br);
        if (idm_meta.idm_slots[eip_slot].valid) begin
            if (idm_meta.idm_slots[eip_slot].br_valid) begin
                bool at_branch = (idm_meta.idm_slots[eip_slot].br_eip == eip);
                $display("    Branch Valid: %0b, at br_eip=%0b (br_eip=0x%h, target=0x%h, XCL=%0b)",
                         idm_meta.idm_slots[eip_slot].br_valid,
                         at_branch,
                         idm_meta.idm_slots[eip_slot].br_eip,
                         idm_meta.idm_slots[eip_slot].br_btb_target,
                         idm_meta.idm_slots[eip_slot].br_xcl);
            end else begin
                $display("    Branch Valid: 0");
            end
        end else begin
            $display("    Current Slot Invalid");
        end

        $display("    Control: flush=%0b, decode_stall=%0b, exp_pipeclear=%0b",
                 flush, decode_stall, exp_pipeclear);

        // Display slot valid status for all slots
        $display("    Slot Valid: [0]=%0b [1]=%0b [2]=%0b [3]=%0b",
                 idm_meta.idm_slots[0].valid,
                 idm_meta.idm_slots[1].valid,
                 idm_meta.idm_slots[2].valid,
                 idm_meta.idm_slots[3].valid);
    endfunction

    // Timeout watchdog
    initial begin
        #100000;
        $display("\n✗ TIMEOUT: Test run exceeded time limit");
        $finish;
    end

endmodule
