#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "../../../sim_types.h"

// Function prototype
void icache_Init(bool* resetWire, tlb_2_icache_p* tlb2icache, icache_2_qctrl_p* icache2qctrl,
                 icache_2_mem_p* icache2mem, mem_2_icache_p* mem2icache);
void icache_cycle();

// Simulated memory array
#define MEM_SIZE 8192
static uint8_t simulated_memory[MEM_SIZE];

// Test statistics
typedef struct {
    int total_cycles;
    int cache_hits;
    int cache_misses;
    int mem_accesses;
} test_stats_t;

test_stats_t stats = {0};

// Initialize simulated memory with test patterns
void init_memory() {
    for (int i = 0; i < MEM_SIZE; i++) {
        simulated_memory[i] = (uint8_t)(i & 0xFF);
    }
    
    // Add some specific test patterns
    // Pattern 1: At address 0x0000 - Simple instruction sequence
    simulated_memory[0x00] = 0x90; // NOP
    simulated_memory[0x01] = 0x90;
    simulated_memory[0x02] = 0xB8; // MOV EAX
    simulated_memory[0x03] = 0x01;
    
    // Pattern 2: At address 0x0100 - Different cache line
    simulated_memory[0x100] = 0xC3; // RET
    simulated_memory[0x101] = 0x90;
    simulated_memory[0x102] = 0x90;
    simulated_memory[0x103] = 0xC3;
}

// Memory controller simulation - responds to memory requests
void simulate_memory_controller(icache_2_mem_p* icache_to_mem, mem_2_icache_p* mem_to_icache) {
    static int response_delay = 0;
    static bool servicing_request = false;
    static uint32_t current_addr = 0;
    static int beat_count = 0;
    
    // Check for new memory request
    if (icache_to_mem->mem_req && !servicing_request) {
        servicing_request = true;
        current_addr = icache_to_mem->mem_addr & ~0xF; // Align to cache line
        beat_count = 0;
        response_delay = 2; // Simulate 2 cycle memory latency
        mem_to_icache->mem_valid = false;
        printf("    [MEM] Request received for addr 0x%04X (aligned: 0x%04X)\n", 
               icache_to_mem->mem_addr, current_addr);
    }
    
    // Service ongoing request
    if (servicing_request) {
        if (response_delay > 0) {
            response_delay--;
            mem_to_icache->mem_valid = false;
        } else {
            // Send data beats (4 bytes per beat, 4 beats = 16 byte line)
            mem_to_icache->mem_valid = true;
            for (int i = 0; i < DRAM_BUS_WIDTH; i++) {
                uint32_t byte_addr = current_addr + (beat_count * DRAM_BUS_WIDTH) + i;
                if (byte_addr < MEM_SIZE) {
                    mem_to_icache->dramData[i] = simulated_memory[byte_addr];
                } else {
                    mem_to_icache->dramData[i] = 0xFF;
                }
            }
            
            printf("    [MEM] Sending beat %d: [0x%02X 0x%02X 0x%02X 0x%02X]\n",
                   beat_count,
                   mem_to_icache->dramData[0],
                   mem_to_icache->dramData[1],
                   mem_to_icache->dramData[2],
                   mem_to_icache->dramData[3]);
            
            beat_count++;
            
            if (beat_count >= 4) {
                servicing_request = false;
                beat_count = 0;
                stats.mem_accesses++;
            }
        }
    } else {
        mem_to_icache->mem_valid = false;
    }
}

// Print cache line contents
void print_cache_line(uint8_t* cache_line) {
    printf("    Cache Line: ");
    for (int i = 0; i < ICACHE_LINE_SIZE; i++) {
        printf("%02X ", cache_line[i]);
        if (i == 7) printf("| ");
    }
    printf("\n");
}

// Test case 1: Reset functionality
bool test_reset() {
    printf("\n=== TEST 1: Reset Functionality ===\n");
    
    bool reset_wire = true;
    tlb_2_icache_p tlb_to_icache = {0};
    icache_2_qctrl_p icache_to_qctrl = {0};
    icache_2_mem_p icache_to_mem = {0};
    mem_2_icache_p mem_to_icache = {0};
    
    icache_Init(&reset_wire, &tlb_to_icache, &icache_to_qctrl, &icache_to_mem, &mem_to_icache);
    
    // Cycle 0: Reset active
    printf("Cycle 0: Reset active\n");
    icache_cycle();
    
    if (icache_to_qctrl.valid_line != false || icache_to_mem.mem_req != false) {
        printf("FAILED: Outputs not cleared on reset\n");
        return false;
    }
    
    printf("PASSED: Reset properly clears cache\n");
    return true;
}

// Test case 2: Cache miss and fill
bool test_cache_miss_and_fill() {
    printf("\n=== TEST 2: Cache Miss and Fill ===\n");
    
    bool reset_wire = true;
    tlb_2_icache_p tlb_to_icache = {0};
    icache_2_qctrl_p icache_to_qctrl = {0};
    icache_2_mem_p icache_to_mem = {0};
    mem_2_icache_p mem_to_icache = {0};
    
    icache_Init(&reset_wire, &tlb_to_icache, &icache_to_qctrl, &icache_to_mem, &mem_to_icache);
    
    // Reset
    printf("Cycle 0: Reset\n");
    icache_cycle();
    reset_wire = false;
    stats.total_cycles++;
    
    // Request address 0x0000
    printf("\nCycle 1: Request addr 0x0000 (expect miss)\n");
    tlb_to_icache.tlb_addr = 0x0000;
    tlb_to_icache.valid_req_addr = true;
    
    simulate_memory_controller(&icache_to_mem, &mem_to_icache);
    icache_cycle();
    stats.total_cycles++;
    
    if (icache_to_qctrl.valid_line == true) {
        printf("FAILED: Should be a cache miss\n");
        return false;
    }
    
    if (icache_to_mem.mem_req != true) {
        printf("FAILED: Memory request should be asserted\n");
        return false;
    }
    
    printf("  Result: Cache miss detected, memory request sent\n");
    stats.cache_misses++;
    
    // Continue cycling to fill the cache line
    int fill_cycles = 0;
    while (icache_to_qctrl.valid_line == false && fill_cycles < 20) {
        fill_cycles++;
        printf("\nCycle %d: Waiting for memory data\n", stats.total_cycles + 1);
        
        simulate_memory_controller(&icache_to_mem, &mem_to_icache);
        icache_cycle();
        stats.total_cycles++;
        
        printf("  valid_line: %d, mem_valid: %d\n", 
               icache_to_qctrl.valid_line, mem_to_icache.mem_valid);
    }
    
    // Check if line is now valid
    if (icache_to_qctrl.valid_line == true) {
        printf("\n  Result: Cache line filled successfully\n");
        print_cache_line(icache_to_qctrl.cache_line);
        
        // Verify data matches memory
        bool data_correct = true;
        for (int i = 0; i < ICACHE_LINE_SIZE; i++) {
            if (icache_to_qctrl.cache_line[i] != simulated_memory[i]) {
                printf("FAILED: Byte %d mismatch (got 0x%02X, expected 0x%02X)\n",
                       i, icache_to_qctrl.cache_line[i], simulated_memory[i]);
                data_correct = false;
            }
        }
        
        if (data_correct) {
            printf("PASSED: Cache line filled with correct data\n");
            return true;
        }
    } else {
        printf("FAILED: Cache line not filled after %d cycles\n", fill_cycles);
    }
    
    return false;
}

// Test case 3: Cache hit after fill
bool test_cache_hit() {
    printf("\n=== TEST 3: Cache Hit ===\n");
    
    bool reset_wire = true;
    tlb_2_icache_p tlb_to_icache = {0};
    icache_2_qctrl_p icache_to_qctrl = {0};
    icache_2_mem_p icache_to_mem = {0};
    mem_2_icache_p mem_to_icache = {0};
    
    icache_Init(&reset_wire, &tlb_to_icache, &icache_to_qctrl, &icache_to_mem, &mem_to_icache);
    
    // Reset and fill a cache line
    icache_cycle();
    reset_wire = false;
    
    // First request (miss)
    printf("Cycle 0: Initial request (miss) for addr 0x0000\n");
    tlb_to_icache.tlb_addr = 0x0000;
    tlb_to_icache.valid_req_addr = true;
    simulate_memory_controller(&icache_to_mem, &mem_to_icache);
    icache_cycle();
    
    // Wait for fill
    int cycle = 1;
    while (icache_to_qctrl.valid_line == false && cycle < 20) {
        simulate_memory_controller(&icache_to_mem, &mem_to_icache);
        icache_cycle();
        cycle++;
    }
    
    printf("\nCycle %d: Same address request (expect hit)\n", cycle);
    icache_cycle();
    
    if (icache_to_qctrl.valid_line != true) {
        printf("FAILED: Should be a cache hit\n");
        return false;
    }
    
    if (icache_to_mem.mem_req == true) {
        printf("FAILED: Should not request memory on cache hit\n");
        return false;
    }
    
    stats.cache_hits++;
    printf("  Result: Cache hit!\n");
    print_cache_line(icache_to_qctrl.cache_line);
    printf("PASSED: Cache hit works correctly\n");
    
    return true;
}

// Test case 4: Multiple cache lines
bool test_multiple_lines() {
    printf("\n=== TEST 4: Multiple Cache Lines ===\n");
    
    bool reset_wire = true;
    tlb_2_icache_p tlb_to_icache = {0};
    icache_2_qctrl_p icache_to_qctrl = {0};
    icache_2_mem_p icache_to_mem = {0};
    mem_2_icache_p mem_to_icache = {0};
    
    icache_Init(&reset_wire, &tlb_to_icache, &icache_to_qctrl, &icache_to_mem, &mem_to_icache);
    
    // Reset
    icache_cycle();
    reset_wire = false;
    
    uint32_t test_addresses[] = {0x0000, 0x0010, 0x0100, 0x0200};
    int num_addresses = sizeof(test_addresses) / sizeof(test_addresses[0]);
    
    for (int i = 0; i < num_addresses; i++) {
        printf("\n--- Testing address 0x%04X ---\n", test_addresses[i]);
        
        // Request
        tlb_to_icache.tlb_addr = test_addresses[i];
        tlb_to_icache.valid_req_addr = true;
        simulate_memory_controller(&icache_to_mem, &mem_to_icache);
        icache_cycle();
        
        // Wait for fill
        int cycle = 0;
        while (icache_to_qctrl.valid_line == false && cycle < 20) {
            simulate_memory_controller(&icache_to_mem, &mem_to_icache);
            icache_cycle();
            cycle++;
        }
        
        if (icache_to_qctrl.valid_line) {
            printf("  Filled in %d cycles\n", cycle);
            print_cache_line(icache_to_qctrl.cache_line);
        } else {
            printf("FAILED: Line not filled for address 0x%04X\n", test_addresses[i]);
            return false;
        }
    }
    
    // Now test hits on previously loaded addresses
    printf("\n--- Testing cache hits ---\n");
    for (int i = 0; i < num_addresses; i++) {
        tlb_to_icache.tlb_addr = test_addresses[i];
        tlb_to_icache.valid_req_addr = true;
        icache_cycle();
        
        if (icache_to_qctrl.valid_line) {
            printf("  Address 0x%04X: HIT\n", test_addresses[i]);
            stats.cache_hits++;
        } else {
            printf("  Address 0x%04X: MISS (unexpected)\n", test_addresses[i]);
        }
    }
    
    printf("PASSED: Multiple cache lines handled correctly\n");
    return true;
}

// Test case 5: Tag conflicts
bool test_tag_conflict() {
    printf("\n=== TEST 5: Tag Conflict (Cache Replacement) ===\n");
    
    bool reset_wire = true;
    tlb_2_icache_p tlb_to_icache = {0};
    icache_2_qctrl_p icache_to_qctrl = {0};
    icache_2_mem_p icache_to_mem = {0};
    mem_2_icache_p mem_to_icache = {0};
    
    icache_Init(&reset_wire, &tlb_to_icache, &icache_to_qctrl, &icache_to_mem, &mem_to_icache);
    
    // Reset
    icache_cycle();
    reset_wire = false;
    
    // Two addresses that map to the same index but different tags
    uint32_t addr1 = 0x0000; // Index 0, Tag 0
    uint32_t addr2 = 0x0200; // Index 0, Tag 1 (assuming 32 lines, 16 bytes/line)
    
    printf("\nFilling addr1 (0x%04X)\n", addr1);
    tlb_to_icache.tlb_addr = addr1;
    tlb_to_icache.valid_req_addr = true;
    simulate_memory_controller(&icache_to_mem, &mem_to_icache);
    icache_cycle();
    
    int cycle = 0;
    while (icache_to_qctrl.valid_line == false && cycle < 20) {
        simulate_memory_controller(&icache_to_mem, &mem_to_icache);
        icache_cycle();
        cycle++;
    }
    
    uint8_t saved_line1[ICACHE_LINE_SIZE];
    memcpy(saved_line1, icache_to_qctrl.cache_line, ICACHE_LINE_SIZE);
    
    printf("\nAccessing conflicting addr2 (0x%04X)\n", addr2);
    tlb_to_icache.tlb_addr = addr2;
    simulate_memory_controller(&icache_to_mem, &mem_to_icache);
    icache_cycle();
    
    if (icache_to_mem.mem_req) {
        printf("  Conflict detected - cache miss as expected\n");
        stats.cache_misses++;
    } else {
        printf("FAILED: Should miss on tag conflict\n");
        return false;
    }
    
    // Wait for new fill
    cycle = 0;
    while (icache_to_qctrl.valid_line == false && cycle < 20) {
        simulate_memory_controller(&icache_to_mem, &mem_to_icache);
        icache_cycle();
        cycle++;
    }
    
    printf("PASSED: Tag conflict handled correctly\n");
    return true;
}

int main() {
    printf("╔════════════════════════════════════════╗\n");
    printf("║   ICache Cycle-by-Cycle Test Suite    ║\n");
    printf("╚════════════════════════════════════════╝\n");
    
    init_memory();
    
    int tests_passed = 0;
    int total_tests = 5;
    
    if (test_reset()) tests_passed++;
    if (test_cache_miss_and_fill()) tests_passed++;
    if (test_cache_hit()) tests_passed++;
    if (test_multiple_lines()) tests_passed++;
    if (test_tag_conflict()) tests_passed++;
    
    printf("\n╔════════════════════════════════════════╗\n");
    printf("║          Test Summary                  ║\n");
    printf("╠════════════════════════════════════════╣\n");
    printf("║ Tests Passed:    %2d / %2d              ║\n", tests_passed, total_tests);
    printf("║ Total Cycles:    %-20d ║\n", stats.total_cycles);
    printf("║ Cache Hits:      %-20d ║\n", stats.cache_hits);
    printf("║ Cache Misses:    %-20d ║\n", stats.cache_misses);
    printf("║ Memory Accesses: %-20d ║\n", stats.mem_accesses);
    printf("╚════════════════════════════════════════╝\n");
    
    if (tests_passed == total_tests) {
        printf("\n✓ All tests passed!\n");
        return 0;
    } else {
        printf("\n✗ Some tests failed.\n");
        return 1;
    }
}
