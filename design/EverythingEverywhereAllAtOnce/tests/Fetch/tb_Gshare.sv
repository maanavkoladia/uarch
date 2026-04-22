import common_pkg::*;
import Fetch_pkg::*;
import Predictor_pkg::*;

module tb_Gshare();

    logic clk;
    logic rst;
    predictor_input_t inputs;
    predictor_output_t outputs;

    // Test tracking
    int test_num;
    int pass_count;
    int fail_count;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // DUT instantiation
    GShare dut (
        .clk(clk),
        .rst(rst),
        .inputs(inputs),
        .outputs(outputs)
    );

    // Helper task to check prediction
    task check_prediction(input logic expected, input string test_name);
        if (outputs.taken === expected) begin
            $display("[PASS] Test %0d: %s - Predicted: %b, Expected: %b", 
                     test_num, test_name, outputs.taken, expected);
            pass_count++;
        end else begin
            $display("[FAIL] Test %0d: %s - Predicted: %b, Expected: %b", 
                     test_num, test_name, outputs.taken, expected);
            fail_count++;
        end
        test_num++;
    endtask

    // Helper task to train the predictor
    task train_branch(input logic [31:0] pc, input logic taken, input logic mispred, input string msg = "");
        inputs.exe_br_valid = 1'b1;
        inputs.exe_br_eip = pc;
        inputs.exe_br_taken = taken;
        inputs.misprediction = mispred;
        $display("[TRAIN]");
        $display("BHR (Real):        0x%h (0b%b)", dut.bhr_real, dut.bhr_real);
        $display("pht_index_update:  0x%h (0b%b)", dut.pht_index_update, dut.pht_index_update);
        $display(" PC: 0x%h, Taken: %b" , pc, taken);
        @(posedge clk)
        inputs.exe_br_valid = 1'b0;
        #1
        print_pht_state("State after training");
    endtask

    // Helper task to make a prediction
    task predict_branch(input logic [31:0] pc, input logic btb_hit = 1'b1);
        inputs.spc = pc;
        inputs.btb_hit = btb_hit;
        #1; // Allow combinational logic to settle
        $display("---pred branch----");
        $display("spc: 0x%h", pc);
        $display("BHR (Speculative): 0x%h (0b%b)", dut.bhr_spec, dut.bhr_spec);
        $display("pht_index_spec:    0x%h (0b%b)", dut.pht_index_spec, dut.pht_index_spec);
        $display("prediction: %b", outputs.taken);
        $display("-----------------");
        @(posedge clk)
        inputs.btb_hit = 0;
    endtask

    // Helper task to print PHT and BHR state
    task print_pht_state(input string label = "");
        int non_zero_count;
        non_zero_count = 0;
        $display("\n======== PHT and BHR State%s ========", label != "" ? {" - ", label} : "");
        $display("BHR (Speculative): 0x%h (0b%b)", dut.bhr_spec, dut.bhr_spec);
        $display("BHR (Real):        0x%h (0b%b)", dut.bhr_real, dut.bhr_real);
        $display("\nPattern History Table (PHT) - 256 entries:");
        $display("Index | Sat Counter | State           | Prediction");
        $display("------|-------------|-----------------|------------");
        
        for (int i = 0; i < 8; i++) begin
            logic [1:0] count;
            string state_str;
            
            count = dut.pht_contents_debug[i];
            
            // Only print non-zero entries (or show first 16 for overview)
            if (i < 8) begin
                case(count)
                    2'b00: state_str = "Strongly NT";
                    2'b01: state_str = "Weakly NT  ";
                    2'b10: state_str = "Weakly T   ";
                    2'b11: state_str = "Strongly T ";
                endcase
                
                $display("0x%02h  |     %b      | %s | %s", 
                         i, count, state_str, count[1] ? "Taken    " : "Not-Taken");
                
                if (count != 2'b00) non_zero_count++;
            end
        end
        
        
        $display("==========================================\n");
    endtask

    // Main test sequence
    initial begin
        // Initialize
        logic [31:0] pattern_pc;
        logic [31:0] pc_a, pc_b;
        logic [31:0] mis_pc;
        logic [31:0] btb_pc;
        logic [31:0] seq_pc;

        test_num = 1;
        pass_count = 0;
        fail_count = 0;
        
        inputs = '{default: '0};
        rst = 0;
        
        $display("\n========================================");
        $display("GShare Branch Predictor Testbench");
        $display("========================================\n");

        // Reset sequence
        repeat(3) @(posedge clk);
        rst = 1;
        @(posedge clk);
        
        print_pht_state("After Reset");
        
        $display("--- Test 1: Initial State (Cold Start) ---");
    
        predict_branch(32'h0000_0010);
        check_prediction(1'b0, "Cold start - should predict not-taken");
        @(posedge clk);

        $display("\n--- Test 2: Training Single Branch (Taken) ---");

        train_branch(32'h00001010, 1'b1, 1, ""); 
        @(posedge clk)

        predict_branch(32'h00001010); 
        check_prediction(1'b0, "predict not taken");
        
        @(posedge clk)
        train_branch(32'h00001010, 1'b1, 0);
        predict_branch(32'h00001010);
        check_prediction(1'b1, "After 2 taken - should predict taken");
        print_pht_state("After Training Test 2");
        @(posedge clk);
        predict_branch(32'h00001020);
        @(posedge clk)
        predict_branch(32'h00001030);
        @(posedge clk)
        predict_branch(32'h00001040);
        @(posedge clk)
        predict_branch(32'h00001010);
        train_branch(32'h00001010, 1'b0, 1);



        // $display("\n--- Test 3: Training Single Branch (Not-Taken) ---");
        // // Train different PC to not-taken (it's already weakly not-taken, so one more makes it strong)
        // predict_branch(32'h00002000);
        // train_branch(32'h00002000, 1'b0, "Training not-taken");
        // predict_branch(32'h00002000);
        // check_prediction(1'b0, "After training not-taken - should predict not-taken");
        // @(posedge clk);

        // $display("\n--- Test 4: Saturating Counter Behavior ---");
        // // Test that counter saturates (doesn't overflow)
        // predict_branch(32'h00003000);
        // train_branch(32'h00003000, 1'b1, "Training 1");
        // train_branch(32'h00003000, 1'b1, "Training 2");
        // train_branch(32'h00003000, 1'b1, "Training 3 (should saturate)");
        // train_branch(32'h00003000, 1'b1, "Training 4 (already saturated)");
        // predict_branch(32'h00003000);
        // check_prediction(1'b1, "After saturation - should still predict taken");
        
        // // Now train not-taken once - should go from strongly taken to weakly taken
        // train_branch(32'h00003000, 1'b0, "One not-taken - strongly taken -> weakly taken");
        // predict_branch(32'h00003000);
        // check_prediction(1'b1, "After one not-taken - should still predict taken");
        // print_pht_state("After Saturation Test 4");
        // @(posedge clk);

        // $display("\n--- Test 5: Pattern Detection ---");
        // // Train a pattern: PC alternates behavior based on history
        // pattern_pc = 32'h00004000;
        
        // $display("  Training pattern: T, T, T, T (same PC, building history)");
        // train_branch(pattern_pc, 1'b1);
        // train_branch(pattern_pc, 1'b1);
        // train_branch(pattern_pc, 1'b1);
        // train_branch(pattern_pc, 1'b1);
        
        // predict_branch(pattern_pc);
        // check_prediction(1'b1, "Pattern recognition - 4 takens should predict taken");
        // @(posedge clk);

        // $display("\n--- Test 6: GShare XOR Behavior ---");
        // // Test that different PCs with same lower bits get different predictions
        // // due to XOR with BHR
        // pc_a = 32'h00005010; // Cache-aligned, bits [11:4] = 0x01
        // pc_b = 32'h00006010; // Same index bits but different upper bits
        
        // $display("  Testing GShare XOR property with different PCs");
        // // Reset to clear BHR
        // rst = 0;
        // @(posedge clk);
        // rst = 1;
        // @(posedge clk);
        
        // // Train pc_a to be taken
        // train_branch(pc_a, 1'b1, "Train PC_A taken (1st)");
        // train_branch(pc_a, 1'b1, "Train PC_A taken (2nd)");
        
        // // pc_b should still predict not-taken because GHR is different now
        // predict_branch(pc_b);
        // $display("  [INFO] PC_A and PC_B have same lower bits but different predictions due to GShare XOR");
        // check_prediction(1'b0, "PC_B prediction with different history context");
        // print_pht_state("After GShare XOR Test 6");
        // @(posedge clk);

        // $display("\n--- Test 7: Misprediction Recovery ---");
        // // Test speculative vs real BHR handling
        // mis_pc = 32'h00007000;
        
        // rst = 0;
        // @(posedge clk);
        // rst = 1;
        // @(posedge clk);
        
        // $display("  Training branch to be taken");
        // train_branch(mis_pc, 1'b1);
        // train_branch(mis_pc, 1'b1);
        
        // $display("  Simulating misprediction recovery");
        // inputs.misprediction = 1'b1;
        // inputs.exe_br_valid = 1'b1;
        // inputs.exe_br_taken = 1'b0; // Actually not taken
        // inputs.exe_br_eip = mis_pc;
        // @(posedge clk);
        // inputs.misprediction = 1'b0;
        // inputs.exe_br_valid = 1'b0;
        
        // predict_branch(mis_pc);
        // $display("  [INFO] After misprediction, BHR should be corrected");
        // // Prediction may vary based on corrected history
        // $display("  [INFO] Prediction: %b (depends on corrected BHR state)", outputs.taken);
        // test_num++; // Count this as a test but don't check specific value
        // @(posedge clk);

        // $display("\n--- Test 8: BTB Miss Handling ---");
        // // When BTB misses, speculative BHR shouldn't update
        // btb_pc = 32'h00008000;
        
        // predict_branch(btb_pc, 1'b0); // BTB miss
        // $display("  [INFO] BTB miss - speculative BHR should NOT update");
        // $display("  [INFO] This test verifies BHR doesn't update on BTB miss");
        // test_num++; // Informational test
        // @(posedge clk);

        // $display("\n--- Test 9: Multiple Branches with History ---");
        // // Train a sequence and verify predictions
        // seq_pc = 32'h00009000;
        
        // rst = 0;
        // @(posedge clk);
        // rst = 1;
        // @(posedge clk);
        
        // $display("  Building branch history with sequence");
        // train_branch(seq_pc, 1'b1, "Build history 1");
        // train_branch(seq_pc + 32'h10, 1'b0, "Build history 2");
        // train_branch(seq_pc, 1'b1, "Build history 3");
        // train_branch(seq_pc + 32'h10, 1'b1, "Build history 4");
        
        // // Now the BHR has a specific pattern
        // predict_branch(seq_pc);
        // $display("  [INFO] Prediction after building history: %b", outputs.taken);
        // $display("  [INFO] GShare correlates PC with global history");
        // test_num++;
        // @(posedge clk);

        // $display("\n--- Test 10: Stress Test - Rapid Training ---");
        // rst = 0;
        // @(posedge clk);
        // rst = 1;
        // @(posedge clk);
        
        // $display("  Rapid training of 16 branches");
        // for (int i = 0; i < 16; i++) begin
        //     train_branch(32'h0000A000 + (i << 4), i[0], $sformatf("Branch %0d", i));
        // end
        // $display("  [PASS] Stress test completed without errors");
        // pass_count++;
        // test_num++;

        // print_pht_state("Final State - After All Tests");

        // Summary
        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Total Tests: %0d", test_num - 1);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("\n*** ALL TESTS PASSED ***\n");
        end else begin
            $display("\n*** SOME TESTS FAILED ***\n");
        end
        
        $finish;
    end

    // Timeout watchdog
    initial begin
        #100000;
        $display("\n[ERROR] Testbench timeout!");
        $finish;
    end

endmodule