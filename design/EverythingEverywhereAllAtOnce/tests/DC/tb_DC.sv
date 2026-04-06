import common_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::*;

module tb_DC();

    // Clock and reset
    logic clk;
    logic rst;
    
    // DUT inputs
    dc_latches_t latches_i;
    mem_outputs_t mem_outs_i;
    exe_outputs_t exe_outs_i;
    wb_outputs_t wb_outs_i;
    bool req_rejected_mio;
    bool req_rejected_0;
    bool req_rejected_1;
    
    // DUT outputs
    mem_latches_t mem_latches_next_o;
    dc_outputs_t dc_outs_o;
    
    // Test tracking
    int test_num;
    int errors;
    
    // Instantiate DUT
    DC dut (
        .clk(clk),
        .rst(rst),
        .latches_i(latches_i),
        .mem_outs_i(mem_outs_i),
        .exe_outs_i(exe_outs_i),
        .wb_outs_i(wb_outs_i),
        .req_rejected_mio(req_rejected_mio),
        .req_rejected_0(req_rejected_0),
        .req_rejected_1(req_rejected_1),
        .mem_latches_next_o(mem_latches_next_o),
        .dc_outs_o(dc_outs_o)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Helper task to display DC state
    task display_dc_state(string msg = "");
        $display("========================================");
        if (msg != "") $display("%s", msg);
        $display("Time: %0t", $time);
        $display("  DC Stage:");
        $display("    valid=%b, LD_OP=%b, ST_OP=%b, MIO=%b, LD_XCL=%b", 
                 latches_i.valid, latches_i.cs.LD_OP, latches_i.cs.ST_OP, 
                 latches_i.MIO, latches_i.LD_XCL);
        $display("    LD_PADDR_0=0x%h, LD_PADDR_1=0x%h", 
                 latches_i.LD_PADDR_0, latches_i.LD_PADDR_1);
        $display("    ST_PADDR_0=0x%h, ST_PADDR_1=0x%h", 
                 latches_i.ST_PADDR_0, latches_i.ST_PADDR_1);
        $display("  Outputs:");
        $display("    stall=%b, ld_addr_0_V=%b, ld_addr_1_V=%b, ld_addr_MIO_V=%b",
                 dc_outs_o.stall, dc_outs_o.ld_addr_0_V, 
                 dc_outs_o.ld_addr_1_V, dc_outs_o.ld_addr_MIO_V);
        $display("    ld_addr_0=0x%h, ld_addr_1=0x%h", 
                 dc_outs_o.ld_addr_0, dc_outs_o.ld_addr_1);
        $display("  Internals:");
        $display("    dep_stall=%b, arb_stall=%b", dut.dep_stall, dut.arb_stall);
        $display("    in_flight_stall=%b, stq_stall=%b", 
                 dut.in_flight_stall, dut.stq_stall);
        $display("========================================\n");
    endtask
    
    // Initialize all inputs
    task init_inputs();
        latches_i = '{default: '0};
        mem_outs_i = '{default: '0};
        exe_outs_i = '{default: '0};
        wb_outs_i = '{default: '0};
        req_rejected_mio = 0;
        req_rejected_0 = 0;
        req_rejected_1 = 0;
    endtask
    
    // Setup DC with a load operation
    task setup_dc_load(p_address_t addr0, p_address_t addr1 = 0, bool xcl = 0, bool mio = 0);
        latches_i.valid = 1;
        latches_i.cs.LD_OP = 1;
        latches_i.cs.ST_OP = 0;
        latches_i.LD_PADDR_0 = addr0;
        latches_i.LD_PADDR_1 = addr1;
        latches_i.LD_XCL = xcl;
        latches_i.MIO = mio;
    endtask
    
    // Setup in-flight store in MEM stage
    task setup_mem_store(p_address_t addr0, p_address_t addr1 = 0, bool xcl = 0);
        mem_outs_i.valid = 1;
        mem_outs_i.ST_OP = 1;
        mem_outs_i.ST_PADDR_0 = addr0;
        mem_outs_i.ST_PADDR_1 = addr1;
        mem_outs_i.ST_XCL = xcl;
    endtask
    
    // Setup in-flight store in EXE stage
    task setup_exe_store(p_address_t addr0, p_address_t addr1 = 0, bool xcl = 0);
        exe_outs_i.valid = 1;
        exe_outs_i.ST_OP = 1;
        exe_outs_i.ST_PADDR_0 = addr0;
        exe_outs_i.ST_PADDR_1 = addr1;
        exe_outs_i.ST_XCL = xcl;
    endtask
    
    // Setup in-flight store in WB stage
    task setup_wb_store(p_address_t addr0, p_address_t addr1 = 0, bool xcl = 0);
        wb_outs_i.valid = 1;
        wb_outs_i.ST_OP = 1;
        wb_outs_i.ST_PADDR_0 = addr0;
        wb_outs_i.ST_PADDR_1 = addr1;
        wb_outs_i.ST_XCL = xcl;
    endtask
    
    // Check if result matches expectation
    task check_result(bool exp_stall, bool exp_ld0_v, bool exp_ld1_v, bool exp_mio_v);
        @(negedge clk);
        #1;
        
        if (dc_outs_o.stall != exp_stall) begin
            $display("✗ FAIL: Expected stall=%b, got %b", exp_stall, dc_outs_o.stall);
            errors++;
        end
        if (dc_outs_o.ld_addr_0_V != exp_ld0_v) begin
            $display("✗ FAIL: Expected ld_addr_0_V=%b, got %b", exp_ld0_v, dc_outs_o.ld_addr_0_V);
            errors++;
        end
        if (dc_outs_o.ld_addr_1_V != exp_ld1_v) begin
            $display("✗ FAIL: Expected ld_addr_1_V=%b, got %b", exp_ld1_v, dc_outs_o.ld_addr_1_V);
            errors++;
        end
        if (dc_outs_o.ld_addr_MIO_V != exp_mio_v) begin
            $display("✗ FAIL: Expected ld_addr_MIO_V=%b, got %b", exp_mio_v, dc_outs_o.ld_addr_MIO_V);
            errors++;
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("\n╔════════════════════════════════════════╗");
        $display("║   DC Stage Testbench Starting          ║");
        $display("╚════════════════════════════════════════╝\n");
        
        test_num = 1;
        errors = 0;
        
        // Initialize
        init_inputs();
        rst = 1;
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        
        // ========================================
        // TEST 1: Simple load with no dependencies
        // ========================================
        $display("\n[TEST %0d] Simple load, no dependencies", test_num++);
        init_inputs();
        setup_dc_load(32'h1000);
        @(posedge clk);
        display_dc_state("After simple load");
        check_result(.exp_stall(0), .exp_ld0_v(1), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 2: Cross-cacheline load
        // ========================================
        $display("\n[TEST %0d] Cross-cacheline load", test_num++);
        init_inputs();
        setup_dc_load(32'h100C, 32'h1010, .xcl(1));
        @(posedge clk);
        display_dc_state("After XCL load");
        check_result(.exp_stall(0), .exp_ld0_v(1), .exp_ld1_v(1), .exp_mio_v(0));
        
        // ========================================
        // TEST 3: Load with MEM stage store dependency
        // ========================================
        $display("\n[TEST %0d] Load with MEM store dependency (same addr)", test_num++);
        init_inputs();
        setup_dc_load(32'h2000);
        setup_mem_store(32'h2000);
        @(posedge clk);
        display_dc_state("Load depends on MEM store");
        check_result(.exp_stall(1), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 4: Load with EXE stage store dependency
        // ========================================
        $display("\n[TEST %0d] Load with EXE store dependency", test_num++);
        init_inputs();
        setup_dc_load(32'h3000);
        setup_exe_store(32'h3000);
        @(posedge clk);
        display_dc_state("Load depends on EXE store");
        check_result(.exp_stall(1), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 5: Load with WB stage store dependency
        // ========================================
        $display("\n[TEST %0d] Load with WB store dependency", test_num++);
        init_inputs();
        setup_dc_load(32'h4000);
        setup_wb_store(32'h4000);
        @(posedge clk);
        display_dc_state("Load depends on WB store");
        check_result(.exp_stall(1), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 6: XCL load with dependency on second address
        // ========================================
        $display("\n[TEST %0d] XCL load with dep on ld_addr_1", test_num++);
        init_inputs();
        setup_dc_load(32'h500C, 32'h5010, .xcl(1));
        setup_mem_store(32'h5010);  // Matches ld_addr_1
        @(posedge clk);
        display_dc_state("XCL load depends on store at addr1");
        check_result(.exp_stall(1), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 7: Load with XCL store dependency
        // ========================================
        $display("\n[TEST %0d] Load vs XCL store (matches st_addr_1)", test_num++);
        init_inputs();
        setup_dc_load(32'h6010);
        setup_mem_store(32'h600C, 32'h6010, .xcl(1));  // Store XCL, addr1 matches
        @(posedge clk);
        display_dc_state("Load matches XCL store addr1");
        check_result(.exp_stall(1), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 8: Load with no dependency (different address)
        // ========================================
        $display("\n[TEST %0d] Load with store, different addresses", test_num++);
        init_inputs();
        setup_dc_load(32'h7000);
        setup_mem_store(32'h8000);
        @(posedge clk);
        display_dc_state("No dependency - different addresses");
        check_result(.exp_stall(0), .exp_ld0_v(1), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 9: Cache arbiter rejects load request
        // ========================================
        $display("\n[TEST %0d] Cache arbiter rejects load_0", test_num++);
        init_inputs();
        setup_dc_load(32'h9000);
        req_rejected_0 = 1;
        @(posedge clk);
        display_dc_state("Arbiter rejects load_0");
        check_result(.exp_stall(1), .exp_ld0_v(1), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 10: Cache arbiter rejects XCL second request
        // ========================================
        $display("\n[TEST %0d] Cache arbiter rejects XCL load_1", test_num++);
        init_inputs();
        setup_dc_load(32'hA00C, 32'hA010, .xcl(1));
        req_rejected_1 = 1;
        @(posedge clk);
        display_dc_state("Arbiter rejects XCL load_1");
        check_result(.exp_stall(1), .exp_ld0_v(1), .exp_ld1_v(1), .exp_mio_v(0));
        
        // ========================================
        // TEST 11: MIO load request
        // ========================================
        $display("\n[TEST %0d] MIO load request", test_num++);
        init_inputs();
        setup_dc_load(32'hB000, .mio(1));
        @(posedge clk);
        display_dc_state("MIO load");
        check_result(.exp_stall(0), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(1));
        
        // ========================================
        // TEST 12: MIO load with dependency
        // ========================================
        $display("\n[TEST %0d] MIO load with store dependency", test_num++);
        init_inputs();
        setup_dc_load(32'hC000, .mio(1));
        setup_mem_store(32'hC000);
        @(posedge clk);
        display_dc_state("MIO load with dependency");
        check_result(.exp_stall(1), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 13: MIO arbiter rejection
        // ========================================
        $display("\n[TEST %0d] MIO arbiter rejection", test_num++);
        init_inputs();
        setup_dc_load(32'hD000, .mio(1));
        req_rejected_mio = 1;
        @(posedge clk);
        display_dc_state("MIO arbiter rejection");
        check_result(.exp_stall(1), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(1));
        
        // ========================================
        // TEST 14: Invalid DC stage (valid=0)
        // ========================================
        $display("\n[TEST %0d] Invalid DC stage", test_num++);
        init_inputs();
        latches_i.valid = 0;
        latches_i.cs.LD_OP = 1;
        latches_i.LD_PADDR_0 = 32'hE000;
        @(posedge clk);
        display_dc_state("Invalid stage");
        check_result(.exp_stall(0), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(0));
        
        // ========================================
        // TEST 15: Multiple in-flight stores, one matches
        // ========================================
        $display("\n[TEST %0d] Multiple in-flight stores", test_num++);
        init_inputs();
        setup_dc_load(32'hF000);
        setup_mem_store(32'h1000);  // No match
        setup_exe_store(32'hF000);  // Match!
        setup_wb_store(32'h2000);   // No match
        @(posedge clk);
        display_dc_state("Multiple stores, one matches");
        check_result(.exp_stall(1), .exp_ld0_v(0), .exp_ld1_v(0), .exp_mio_v(0));
        
        // Summary
        $display("\n╔════════════════════════════════════════╗");
        $display("║   Test Complete                        ║");
        $display("╠════════════════════════════════════════╣");
        if (errors == 0) begin
            $display("║   ✓ ALL TESTS PASSED                   ║");
        end else begin
            $display("║   ✗ %0d ERRORS DETECTED                 ║", errors);
        end
        $display("╚════════════════════════════════════════╝\n");
        
        #100;
        $finish;
    end
    
    // VPD dump
    initial begin
        $vcdplusfile("tb_DC.vpd");
        $vcdpluson;
    end
    
    // Watchdog
    initial begin
        #100000;
        $display("\n*** TIMEOUT ***\n");
        $finish;
    end

endmodule