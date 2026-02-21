# ICache Test Suite

This directory contains comprehensive cycle-by-cycle tests for the instruction cache (ICache) implementation.

## Overview

The test suite simulates the ICache behavior including:
- Cache initialization and reset
- Cache miss handling
- Memory fill operations (4-beat DRAM transfers)
- Cache hit scenarios
- Multiple cache line management
- Tag conflict and replacement

## Test Cases

1. **Reset Functionality** - Verifies that reset properly clears the cache
2. **Cache Miss and Fill** - Tests the complete cache miss flow and memory fill process
3. **Cache Hit** - Validates that subsequent accesses to filled lines hit in the cache
4. **Multiple Cache Lines** - Tests loading and accessing multiple different cache lines
5. **Tag Conflict** - Verifies replacement behavior when addresses map to same index

## Building and Running

### Build only:
```bash
make
```

### Build and run tests:
```bash
make run
```

### Clean build artifacts:
```bash
make clean
```

## Test Output

The test provides detailed cycle-by-cycle output showing:
- Request addresses and cache hit/miss status
- Memory controller operations and data beats
- Cache line contents after fills
- Summary statistics (total cycles, hits, misses, memory accesses)

## ICache Specifications

- **Cache Size**: 32 lines × 16 bytes = 512 bytes
- **Line Size**: 16 bytes
- **Organization**: Direct-mapped
- **DRAM Bus Width**: 4 bytes per beat
- **Fill Latency**: 4 beats (+ 2 cycle memory access latency)

## Address Format

```
[  TAG (23 bits)  |  INDEX (5 bits)  |  OFFSET (4 bits)  ]
  Bits 31-9          Bits 8-4            Bits 3-0
```

- **Offset**: Selects byte within cache line
- **Index**: Selects cache line (0-31)
- **Tag**: Identifies which memory block is cached

## Example Output

```
=== TEST 2: Cache Miss and Fill ===
Cycle 0: Reset
Cycle 1: Request addr 0x0000 (expect miss)
  Result: Cache miss detected, memory request sent
  
Cycle 2: Filling cache line (beat 1)
    [MEM] Request received for addr 0x0000 (aligned: 0x0000)
    [MEM] Sending beat 0: [0x00 0x01 0x02 0x03]
  
  Result: Cache line filled successfully
    Cache Line: 00 01 02 03 04 05 06 07 | 08 09 0A 0B 0C 0D 0E 0F
PASSED: Cache line filled with correct data
```

## Dependencies

- icache.c - The ICache implementation
- sim_types.h - Type definitions
- sim_common.h - Common definitions (ICACHE_LINE_SIZE, DRAM_BUS_WIDTH)
