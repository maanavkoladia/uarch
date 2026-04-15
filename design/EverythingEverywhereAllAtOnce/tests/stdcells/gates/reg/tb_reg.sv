`timescale 1ns/1ps

module tb_reg();

    initial begin
        $vcdpluson;
        $vcdplusmemon;
    end
    
    // Test signals
    logic clk;
    logic rst;
    logic we;
    logic [7:0] d_8bit;
    wire [7:0] q_8bit;
    
    logic [63:0] d_64bit;
    wire [63:0] q_64bit;
    
    logic [127:0] d_128bit;
    wire [127:0] q_128bit, q_rst_128bit;


    // Test tracking
    int test_num;
    int pass_count;
    int fail_count;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate DUTs
    MPS_reg_rst_we$ #(.WIDTH(8)) u_reg8 (
        .clk(clk),
        .rst(rst),
        .we(we),
        .d(d_8bit),
        .q(q_8bit)
    );

    MPS_reg_rst_we$ #(.WIDTH(64)) u_reg64 (
        .clk(clk),
        .rst(rst),
        .we(we),
        .d(d_64bit),
        .q(q_64bit)
    );

    // MPS_reg_rst_we$ #(.WIDTH(128)) u_reg128 (
    //     .clk(clk),
    //     .rst(rst),
    //     .we(we),
    //     .d(d_128bit),
    //     .q(q_128bit)
    // );

    `REG_RST_WE(u_reg128, 128, clk, rst, we , d_128bit, q_128bit);


    `REG_RST( u_reg_rst, 128, clk, rst, d_128bit , q_rst_128bit);

    // Helper task to check register value
    task check_reg_8bit(input logic [7:0] expected, input string test_name);
        #1; // Wait for output to settle
        if (q_8bit === expected) begin
            $display("[PASS] Test %0d: %s - Got: 0x%h, Expected: 0x%h", 
                     test_num, test_name, q_8bit, expected);
            pass_count++;
        end else begin
            $display("[FAIL] Test %0d: %s - Got: 0x%h, Expected: 0x%h", 
                     test_num, test_name, q_8bit, expected);
            fail_count++;
        end
        test_num++;
    endtask

    task check_reg_64bit(input logic [63:0] expected, input string test_name);
        #1;
        if (q_64bit === expected) begin
            $display("[PASS] Test %0d: %s - Got: 0x%h, Expected: 0x%h", 
                     test_num, test_name, q_64bit, expected);
            pass_count++;
        end else begin
            $display("[FAIL] Test %0d: %s - Got: 0x%h, Expected: 0x%h", 
                     test_num, test_name, q_64bit, expected);
            fail_count++;
        end
        test_num++;
    endtask

    task check_reg_128bit(input logic [127:0] expected, input string test_name);
        #1;
        if (q_128bit === expected) begin
            $display("[PASS] Test %0d: %s - Got: 0x%h, Expected: 0x%h", 
                     test_num, test_name, q_128bit, expected);
            pass_count++;
        end else begin
            $display("[FAIL] Test %0d: %s - Got: 0x%h, Expected: 0x%h", 
                     test_num, test_name, q_128bit, expected);
            fail_count++;
        end
        test_num++;
    endtask

    // Main test sequence
    initial begin
        // Initialize
        test_num = 1;
        pass_count = 0;
        fail_count = 0;
        
        rst = 0;  // Assert reset (active low)
        we = 0;
        d_8bit = 8'h00;
        d_64bit = 64'h0;
        d_128bit = 128'h0;
        
        $display("\n========================================");
        $display("Register (MPS_reg_rst_we$) Testbench");
        $display("========================================\n");

        // Wait a few cycles
        repeat(3) @(posedge clk);

        $display("--- Test 1: Reset Behavior (Active Low) ---");
        // rst=0 should clear register to 0
        rst = 0;
        we = 0;
        d_8bit = 8'hAA;
        @(posedge clk);
        check_reg_8bit(8'h00, "8-bit reg under reset should be 0");
        check_reg_64bit(64'h0, "64-bit reg under reset should be 0");
        check_reg_128bit(128'h0, "128-bit reg under reset should be 0");

        $display("\n--- Test 2: Release Reset, No Write (we=0) ---");
        rst = 1;  // Release reset
        we = 0;   // Write disabled
        d_8bit = 8'h55;
        d_64bit = 64'hDEADBEEFCAFEBABE;
        d_128bit = 128'hFEEDFACEDEADBEEFCAFEBABE12345678;
        @(posedge clk);
        check_reg_8bit(8'h00, "8-bit reg should hold 0 (we=0)");
        check_reg_64bit(64'h0, "64-bit reg should hold 0 (we=0)");
        check_reg_128bit(128'h0, "128-bit reg should hold 0 (we=0)");

        $display("\n--- Test 3: Write Enable (we=1) ---");
        rst = 1;
        we = 1;
        d_8bit = 8'hAB;
        d_64bit = 64'h123456789ABCDEF0;
        d_128bit = 128'hA5A5A5A5B4B4B4B4C3C3C3C3D2D2D2D2;
        @(posedge clk);
        check_reg_8bit(8'hAB, "8-bit reg should capture 0xAB");
        check_reg_64bit(64'h123456789ABCDEF0, "64-bit reg should capture data");
        check_reg_128bit(128'hA5A5A5A5B4B4B4B4C3C3C3C3D2D2D2D2, "128-bit reg should capture data");

        $display("\n--- Test 4: Hold Value (we=0) ---");
        rst = 1;
        we = 0;  // Disable write
        d_8bit = 8'hFF;  // Try to write different value
        d_64bit = 64'hFFFFFFFFFFFFFFFF;
        d_128bit = 128'h0;
        @(posedge clk);
        check_reg_8bit(8'hAB, "8-bit reg should hold 0xAB (we=0)");
        check_reg_64bit(64'h123456789ABCDEF0, "64-bit reg should hold previous value");
        check_reg_128bit(128'hA5A5A5A5B4B4B4B4C3C3C3C3D2D2D2D2, "128-bit reg should hold previous value");

        $display("\n--- Test 5: Multiple Writes ---");
        rst = 1;
        we = 1;
        for (int i = 0; i < 5; i++) begin
            d_8bit = 8'h10 + i;
            d_64bit = 64'h1000 + i;
            d_128bit = 128'h10000 + i;
            @(posedge clk);
            check_reg_8bit(8'h10 + i, $sformatf("8-bit write iteration %0d", i));
            check_reg_64bit(64'h1000 + i, $sformatf("64-bit write iteration %0d", i));
            check_reg_128bit(128'h10000 + i, $sformatf("128-bit write iteration %0d", i));
        end

        $display("\n--- Test 6: Toggle Write Enable ---");
        rst = 1;
        d_8bit = 8'hCC;
        d_64bit = 64'hCCCCCCCCCCCCCCCC;
        
        we = 1;
        @(posedge clk);
        check_reg_8bit(8'hCC, "8-bit write 0xCC with we=1");
        
        we = 0;
        d_8bit = 8'h99;
        @(posedge clk);
        check_reg_8bit(8'hCC, "8-bit should hold 0xCC with we=0");
        
        we = 1;
        @(posedge clk);
        check_reg_8bit(8'h99, "8-bit write 0x99 with we=1");

        $display("\n--- Test 7: Reset Priority (rst overrides we) ---");
        rst = 1;
        we = 1;
        d_8bit = 8'h77;
        @(posedge clk);
        check_reg_8bit(8'h77, "8-bit write 0x77");
        
        rst = 0;  // Assert reset
        we = 1;   // we=1 but reset should take priority
        d_8bit = 8'hEE;
        @(posedge clk);
        check_reg_8bit(8'h00, "8-bit should be 0 (reset priority)");

        $display("\n--- Test 8: All Bits Pattern Test ---");
        rst = 1;
        we = 1;
        
        // Test all 1s
        d_8bit = 8'hFF;
        d_64bit = 64'hFFFFFFFFFFFFFFFF;
        d_128bit = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        @(posedge clk);
        check_reg_8bit(8'hFF, "8-bit all 1s");
        check_reg_64bit(64'hFFFFFFFFFFFFFFFF, "64-bit all 1s");
        check_reg_128bit(128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, "128-bit all 1s");
        
        // Test all 0s
        d_8bit = 8'h00;
        d_64bit = 64'h0;
        d_128bit = 128'h0;
        @(posedge clk);
        check_reg_8bit(8'h00, "8-bit all 0s");
        check_reg_64bit(64'h0, "64-bit all 0s");
        check_reg_128bit(128'h0, "128-bit all 0s");
        
        // Test alternating pattern
        d_8bit = 8'hA5;
        d_64bit = 64'hA5A5A5A5A5A5A5A5;
        d_128bit = 128'h5A5A5A5A5A5A5A5AA5A5A5A5A5A5A5A5;
        @(posedge clk);
        check_reg_8bit(8'hA5, "8-bit alternating pattern");
        check_reg_64bit(64'hA5A5A5A5A5A5A5A5, "64-bit alternating pattern");
        check_reg_128bit(128'h5A5A5A5A5A5A5A5AA5A5A5A5A5A5A5A5, "128-bit alternating pattern");

        $display("\n--- Test 9: Rapid we Toggling ---");
        rst = 1;
        d_8bit = 8'h42;
        
        we = 1;
        @(posedge clk);
        we = 0;
        @(posedge clk);
        we = 1;
        @(posedge clk);
        we = 0;
        @(posedge clk);
        
        check_reg_8bit(8'h42, "8-bit after rapid we toggling");

        $display("\n--- Test 10: Edge Case - Width Boundaries ---");
        // Test exactly 64-bit boundary
        rst = 1;
        we = 1;
        d_64bit = 64'h0123456789ABCDEF;
        @(posedge clk);
        check_reg_64bit(64'h0123456789ABCDEF, "64-bit boundary test");
        
        // Test 128-bit (uses 2 reg64e$ instances)
        d_128bit = 128'hFEDCBA9876543210123456789ABCDEF0;
        @(posedge clk);
        check_reg_128bit(128'hFEDCBA9876543210123456789ABCDEF0, "128-bit (2x64) boundary test");

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
            $display("LIKELY BUG: reg64e$ write-enable mux creates combinational loop");
            $display("When we=0, D = Q creates feedback path that may not hold correctly");
        end
        
        $finish;
    end

    // Timeout watchdog
    initial begin
        #50000;
        $display("\n[ERROR] Testbench timeout!");
        $finish;
    end

    // Monitor for debugging
    initial begin
        $display("\nTime\tclk\trst\twe\td_8bit\tq_8bit");
        $display("----\t---\t---\t--\t------\t------");
        $monitor("%0t\t%b\t%b\t%b\t0x%h\t0x%h", 
                 $time, clk, rst, we, d_8bit, q_8bit);
    end

endmodule
