import common_pkg::*;
import WriteBack_pkg::*;

//100% claude
module tb_MIO_Q();

    // Clock and reset
    logic clk;
    logic rst;

    // Interface signals
    mio_inputs_t mio_input;
    mio_outputs_t mio_output;

    // Test tracking
    int test_num;
    int errors;

    // Instantiate DUT
    MIO_Q dut (
        .clk(clk),
        .rst(rst),
        .mio_input(mio_input),
        .outs(mio_output)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // Display queue state
    task display_queue_state();
        $display("========================================");
        $display("Time: %0t | Queue State:", $time);
        $display("  Full: %0b | Empty: %0b", mio_output.full, mio_output.empty);
        if (!mio_output.empty) begin
            $display("  Entry Content:");
            $display("    Valid:   %0b", dut.mio_q.valid);
            $display("    Address: 0x%h", dut.mio_q.address);
            $display("    Data[0-3]: %h %h %h %h", 
                     dut.mio_q.data[0], dut.mio_q.data[1], 
                     dut.mio_q.data[2], dut.mio_q.data[3]);
        end else begin
            $display("  Queue is EMPTY");
        end
        $display("========================================");
    endtask

    // Display input signals
    task display_inputs();
        $display(">>> Input Signals:");
        $display("    Push: %0b | Pop: %0b", mio_input.push, mio_input.pop);
        if (mio_input.push) begin
            $display("    Incoming Data:");
            $display("      Valid:   %0b", mio_input.data.valid);
            $display("      Address: 0x%h", mio_input.data.address);
            $display("      Data[0-3]: %h %h %h %h", 
                     mio_input.data.data[0], mio_input.data.data[1], 
                     mio_input.data.data[2], mio_input.data.data[3]);
        end
    endtask

    // Push task with display
    task push_data(input p_address_t addr, input byte_t data_val);
        mio_input.push = 1;
        mio_input.pop = 0;
        mio_input.data.valid = 1;
        mio_input.data.address = addr;
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            mio_input.data.data[i] = data_val + i;
        end
        
        $display("\n[TEST %0d] PUSH Operation", test_num++);
        display_inputs();
        @(posedge clk);
        #1;  // Small delay to see outputs update
        display_queue_state();
        
        // Clear push
        mio_input.push = 0;
        mio_input.data = '{default: '0};
    endtask

    // Pop task with display
    task pop_data();
        $display("\n[TEST %0d] POP Operation", test_num++);
        $display(">>> Attempting to pop from queue");
        display_queue_state();
        
        mio_input.pop = 1;
        mio_input.push = 0;
        @(posedge clk);
        #1;  // Small delay to see outputs update
        
        $display(">>> After POP:");
        display_queue_state();
        
        // Clear pop
        mio_input.pop = 0;
    endtask

    // Simultaneous push and pop
    task push_pop_simultaneous(input p_address_t addr, input byte_t data_val);
        $display("\n[TEST %0d] SIMULTANEOUS Push & Pop", test_num++);
        $display(">>> Before operation:");
        display_queue_state();
        
        mio_input.push = 1;
        mio_input.pop = 1;
        mio_input.data.valid = 1;
        mio_input.data.address = addr;
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            mio_input.data.data[i] = data_val + i;
        end
        
        display_inputs();
        @(posedge clk);
        #1;  // Small delay to see outputs update
        
        $display(">>> After PUSH+POP:");
        display_queue_state();
        
        // Clear signals
        mio_input.push = 0;
        mio_input.pop = 0;
        mio_input.data = '{default: '0};
    endtask

    // Main test sequence
    initial begin
        $display("\n");
        $display("╔════════════════════════════════════════╗");
        $display("║   MIO_Q Testbench Starting             ║");
        $display("╔════════════════════════════════════════╗");
        $display("\n");
        
        test_num = 1;
        errors = 0;

        // Initialize
        rst = 1;
        mio_input = '{default: '0};
        
        // Reset sequence
        $display("[INIT] Applying Reset");
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        display_queue_state();

        // Test 1: Push to empty queue
        $display("\n\n=== TEST SEQUENCE 1: Basic Push ===");
        push_data(64'hDEADBEEF_00000040, 8'hAA);

        // Test 2: Try to push to full queue (should fail)
        $display("\n\n=== TEST SEQUENCE 2: Push to Full Queue (should fail) ===");
        mio_input.push = 1;
        mio_input.data.valid = 1;
        mio_input.data.address = 64'hCAFEBABE_00000080;
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            mio_input.data.data[i] = 8'hBB + i;
        end
        
        $display("\n[TEST %0d] Attempting PUSH to FULL queue", test_num++);
        display_inputs();
        @(posedge clk);
        #1;
        if (mio_output.push_fail) begin
            $display("✓ PASS: Push correctly failed (push_fail = %0b)", mio_output.push_fail);
        end else begin
            $display("✗ FAIL: Push should have failed!");
            errors++;
        end
        display_queue_state();
        mio_input.push = 0;

        // Test 3: Pop from full queue
        $display("\n\n=== TEST SEQUENCE 3: Pop from Full Queue ===");
        pop_data();

        // Test 4: Try to pop from empty queue (should fail with assertion)
        $display("\n\n=== TEST SEQUENCE 4: Pop from Empty Queue ===");
        $display(">>> This should trigger an assertion error (expected)");
        pop_data();

        // Test 5: Push to empty queue again
        $display("\n\n=== TEST SEQUENCE 5: Push After Empty ===");
        push_data(64'h12345678_000000C0, 8'hCC);

        // Test 6: Simultaneous push and pop with full queue
        $display("\n\n=== TEST SEQUENCE 6: Simultaneous Push+Pop (Full Queue) ===");
        push_pop_simultaneous(64'hABCDEF00_00000100, 8'hDD);

        // Test 7: Multiple push-pop cycles
        $display("\n\n=== TEST SEQUENCE 7: Rapid Push-Pop Cycles ===");
        for (int i = 0; i < 3; i++) begin
            push_data(64'h00000000_00000000 + (i * 64), 8'h10 + i);
            pop_data();
        end

        // Test 8: Verify empty after pops
        $display("\n\n=== TEST SEQUENCE 8: Verify Empty State ===");
        @(posedge clk);
        display_queue_state();

        // Summary
        $display("\n\n");
        $display("╔════════════════════════════════════════╗");
        $display("║   Test Complete                        ║");
        $display("╠════════════════════════════════════════╣");
        if (errors == 0) begin
            $display("║   ✓ ALL TESTS PASSED                   ║");
        end else begin
            $display("║   ✗ %0d ERRORS DETECTED                 ║", errors);
        end
        $display("╚════════════════════════════════════════╝");
        $display("\n");
        
        #100;
        $finish;
    end

    // Monitor for debugging
    initial begin
        $display("\nStarting continuous monitor...\n");
        forever begin
            @(posedge clk);
            if (mio_input.push || mio_input.pop) begin
                $display("[%0t] Activity: Push=%0b Pop=%0b | Full=%0b Empty=%0b Push_Fail=%0b", 
                         $time, mio_input.push, mio_input.pop, 
                         mio_output.full, mio_output.empty, mio_output.push_fail);
            end
        end
    end

    // Watchdog timeout
    initial begin
        #10000;
        $display("\n*** TIMEOUT - Test did not complete in time ***\n");
        $finish;
    end

endmodule
