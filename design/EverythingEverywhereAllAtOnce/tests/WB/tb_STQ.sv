import common_pkg::*;
import WriteBack_pkg::*;

module tb_STQ();

    // Clock and reset
    logic clk;
    logic rst;

    // Interface signals
    st_q_inputs_t wb_in;
    st_q_outputs_t outputs;

    // Test tracking
    int test_num;
    int errors;

    // Instantiate DUT
    ST_Q dut (
        .clk(clk),
        .rst(rst),
        .wb_in(wb_in),
        .outputs(outputs)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // Display full queue contents
    task display_queue_state();
        $display("========================================");
        $display("Time: %0t | Queue State:", $time);
        $display("  Full: %0b | Empty: %0b | Valid Entries: %0d/%0d", 
                 outputs.full, outputs.empty, dut.validEntries, ST_Q_DEPTH);
        $display("  Head Index: %0d | Tail Index: %0d", dut.head, dut.tail);
        $display("  ST_Override: %0b | Push_Fail: %0b", outputs.st_override, outputs.push_fail);
        
        if (!outputs.empty) begin
            $display("  HEAD Entry (output):");
            $display("    Address: 0x%h", outputs.head_address);
            $display("    Bit_Vec: 0x%h", outputs.bit_vec);
            $display("    Data[0-3]: %h %h %h %h", 
                     outputs.data[0], outputs.data[1], outputs.data[2], outputs.data[3]);
        end
        
        $display("\n  All Queue Entries:");
        for (int i = 0; i < ST_Q_DEPTH; i++) begin
            string marker = "";
            if (i == dut.head && !outputs.empty) marker = " <- HEAD";
            if (i == dut.tail) marker = {marker, " <- TAIL"};
            
            if (dut.q[i].valid) begin
                $display("    [%0d] VALID%s", i, marker);
                $display("        Address: 0x%h", dut.q[i].address);
                $display("        Bit_Vec: 0x%h", dut.q[i].bit_vec);
                $display("        Data[0-3]: %h %h %h %h", 
                         dut.q[i].data[0], dut.q[i].data[1], 
                         dut.q[i].data[2], dut.q[i].data[3]);
            end else begin
                $display("    [%0d] EMPTY%s", i, marker);
            end
        end
        $display("========================================");
    endtask

    // Display input signals
    task display_inputs();
        $display(">>> Input Signals:");
        $display("    Push: %0b | Pop: %0b", wb_in.push, wb_in.pop);
        if (wb_in.push) begin
            $display("    Incoming Data:");
            $display("      Valid:   %0b", wb_in.data.valid);
            $display("      Address: 0x%h", wb_in.data.address);
            $display("      Bit_Vec: 0x%h", wb_in.data.bit_vec);
            $display("      Data[0-3]: %h %h %h %h", 
                     wb_in.data.data[0], wb_in.data.data[1], 
                     wb_in.data.data[2], wb_in.data.data[3]);
        end
    endtask

    // Push task with display
    task push_data(input p_address_t addr, input uint16_t bit_vec, input byte_t data_val);
        wb_in.push = 1;
        wb_in.pop = 0;
        wb_in.data.valid = 1;
        wb_in.data.address = addr;
        wb_in.data.bit_vec = bit_vec;
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            wb_in.data.data[i] = data_val + i;
        end
        
        $display("\n[TEST %0d] PUSH Operation", test_num++);
        display_inputs();
        @(posedge clk);
        #1;  // Small delay to see outputs update
        display_queue_state();
        
        // Clear push
        wb_in.push = 0;
        wb_in.data = '{default: '0};
    endtask

    // Pop task with display
    task pop_data();
        $display("\n[TEST %0d] POP Operation", test_num++);
        $display(">>> Attempting to pop from queue");
        $display(">>> Queue state before POP:");
        display_queue_state();
        
        wb_in.pop = 1;
        wb_in.push = 0;
        @(posedge clk);
        #1;  // Small delay to see outputs update
        
        $display(">>> After POP:");
        display_queue_state();
        
        // Clear pop
        wb_in.pop = 0;
    endtask

    // Simultaneous push and pop
    task push_pop_simultaneous(input p_address_t addr, input uint16_t bit_vec, input byte_t data_val);
        $display("\n[TEST %0d] SIMULTANEOUS Push & Pop", test_num++);
        $display(">>> Before operation:");
        display_queue_state();
        
        wb_in.push = 1;
        wb_in.pop = 1;
        wb_in.data.valid = 1;
        wb_in.data.address = addr;
        wb_in.data.bit_vec = bit_vec;
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            wb_in.data.data[i] = data_val + i;
        end
        
        display_inputs();
        @(posedge clk);
        #1;  // Small delay to see outputs update
        
        $display(">>> After PUSH+POP:");
        display_queue_state();
        
        // Clear signals
        wb_in.push = 0;
        wb_in.pop = 0;
        wb_in.data = '{default: '0};
    endtask

    // Main test sequence
    initial begin
        $display("\n");
        $display("╔════════════════════════════════════════╗");
        $display("║   ST_Q Testbench Starting              ║");
        $display("║   Queue Depth: %0d                      ║", ST_Q_DEPTH);
        $display("╚════════════════════════════════════════╝");
        $display("\n");
        
        test_num = 1;
        errors = 0;

        // Initialize
        rst = 1;
        wb_in = '{default: '0};
        
        // Reset sequence
        $display("[INIT] Applying Reset");
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        display_queue_state();

        // Test 1: Basic push to empty queue
        $display("\n\n=== TEST SEQUENCE 1: Single Push to Empty Queue ===");
        push_data(64'hDEADBEEF_00000040, 16'hFFFF, 8'hAA);

        // Test 2: Multiple pushes
        $display("\n\n=== TEST SEQUENCE 2: Fill Queue with Multiple Pushes ===");
        for (int i = 1; i < ST_Q_DEPTH; i++) begin
            push_data(64'h10000000 + (i * 64), 16'h00FF << i, 8'h10 + i);
        end

        // Test 3: Try to push to full queue
        $display("\n\n=== TEST SEQUENCE 3: Push to Full Queue (should fail) ===");
        wb_in.push = 1;
        wb_in.data.valid = 1;
        wb_in.data.address = 64'hCAFEBABE_00000080;
        wb_in.data.bit_vec = 16'hDEAD;
        for (int i = 0; i < CACHE_LINES_SIZE_B; i++) begin
            wb_in.data.data[i] = 8'hBB + i;
        end
        
        $display("\n[TEST %0d] Attempting PUSH to FULL queue", test_num++);
        display_inputs();
        @(posedge clk);
        #1;
        if (outputs.push_fail) begin
            $display("✓ PASS: Push correctly failed (push_fail = %0b)", outputs.push_fail);
        end else begin
            $display("✗ FAIL: Push should have failed!");
            errors++;
        end
        display_queue_state();
        wb_in.push = 0;

        // Test 4: Pop from full queue
        $display("\n\n=== TEST SEQUENCE 4: Pop from Full Queue ===");
        pop_data();

        // Test 5: Verify st_override flag
        $display("\n\n=== TEST SEQUENCE 5: Check ST_Override Flag ===");
        $display("ST_Override should be 1 (queue was full): %0b", outputs.st_override);
        if (outputs.st_override) begin
            $display("✓ PASS: ST_Override correctly set");
        end else begin
            $display("✗ FAIL: ST_Override should be set");
            errors++;
        end

        // Test 6: Another pop
        $display("\n\n=== TEST SEQUENCE 6: Pop Again ===");
        pop_data();

        // Test 7: Simultaneous push and pop
        $display("\n\n=== TEST SEQUENCE 7: Simultaneous Push+Pop ===");
        push_pop_simultaneous(64'hABCDEF00_00000100, 16'h1234, 8'hDD);

        // Test 8: Drain the queue
        $display("\n\n=== TEST SEQUENCE 8: Drain Entire Queue ===");
        for (int i = 0; i < ST_Q_DEPTH; i++) begin
            if (!outputs.empty) begin
                pop_data();
            end else begin
                $display("Queue is empty at iteration %0d", i);
                break;
            end
        end

        // Test 9: Verify empty and st_override cleared
        $display("\n\n=== TEST SEQUENCE 9: Verify Empty State ===");
        @(posedge clk);
        #1;
        display_queue_state();
        if (outputs.empty && !outputs.st_override) begin
            $display("✓ PASS: Queue empty and ST_Override cleared");
        end else begin
            $display("✗ FAIL: Queue state incorrect (empty=%0b, st_override=%0b)", 
                     outputs.empty, outputs.st_override);
            errors++;
        end

        // Test 10: Rapid push-pop cycles
        $display("\n\n=== TEST SEQUENCE 10: Rapid Push-Pop Cycles ===");
        for (int i = 0; i < 5; i++) begin
            push_data(64'h00000000_00000000 + (i * 64), 16'h0001 << i, 8'h20 + i);
            pop_data();
        end

        // Test 11: Fill and drain with simultaneous operations
        $display("\n\n=== TEST SEQUENCE 11: Fill with Simultaneous Ops ===");
        // Fill partway
        for (int i = 0; i < ST_Q_DEPTH/2; i++) begin
            push_data(64'h50000000 + (i * 64), 16'hF0F0, 8'h30 + i);
        end
        
        // Do simultaneous operations
        for (int i = 0; i < 3; i++) begin
            push_pop_simultaneous(64'h60000000 + (i * 64), 16'hAAAA, 8'h40 + i);
        end

        // Test 12: Final state check
        $display("\n\n=== TEST SEQUENCE 12: Final State Check ===");
        @(posedge clk);
        #1;
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
            if (wb_in.push || wb_in.pop) begin
                $display("[%0t] Activity: Push=%0b Pop=%0b | Full=%0b Empty=%0b Entries=%0d Push_Fail=%0b", 
                         $time, wb_in.push, wb_in.pop, 
                         outputs.full, outputs.empty, dut.validEntries, outputs.push_fail);
            end
        end
    end

    // Watchdog timeout
    initial begin
        #50000;
        $display("\n*** TIMEOUT - Test did not complete in time ***\n");
        $finish;
    end

endmodule