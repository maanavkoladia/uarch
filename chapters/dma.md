# DMA Controller — Design Report

## 1. Overview

The DMA controller is a memory-mapped peripheral that copies a contiguous run of bytes from a backing disk into main memory without involving the core for each transfer beat. The core configures it through four MMIO registers — source disk address, destination physical address, byte count, and a start bit — and then triggers the transfer. The controller streams the data from disk into a write buffer, asks the DTE for memory-write permission one cache line at a time, and raises an interrupt when the whole transfer is complete.

![DMA controller block diagram.](figures/fig_dma.png){#fig:dma width=85%}

## 2. Interesting Features

- **Four MMIO configuration registers** — the core writes source / destination / length / start through the MIO path. The controller decodes those four addresses against the address bus and latches the matching register.
- **In-progress configuration lock** — the four registers can only be written while `!fsmOuts.busy`, so an in-progress transfer can't be reconfigured under itself.
- **Cache-line-at-a-time streaming** — once the disk page is loaded, the controller carves it into 16-byte cache lines and drives them one at a time onto the data bus under DTE permission.
- **Three-buffer datapath** — disk → `disk_ld_Buffer` (page-size, loaded in one shot) → `writeBuf` (16-byte sliding window) → main memory (one line at a time).
- **`commiting` flag** suppresses the controller's `dma_req` to the scheduler while a transfer is mid-bus, so the scheduler doesn't see a duplicate request for a line that's already being committed.
- **Interrupt on completion** — the FSM pulses `intOut` on the final LD_BUF → IDLE arc.

## 3. Subsystem Organization

```
       core MIO writes                          DTE
            │                                    │
            ▼                                    ▼
   ┌──────────────────────────────────────────────────────┐
   │                  DMA_Controller                      │
   │                                                      │
   │  4 MMIO regs: srcAddr  destAddr  numBytes  startWrite│
   │                              │                       │
   │                              ▼                       │
   │                       ┌────────────┐                 │
   │                       │  DMA_FSM   │ (5 states)      │
   │                       │ IDLE       │                 │
   │                       │ WAIT_FOR_LD│                 │
   │                       │ LD_BUF     │                 │
   │                       │ WAIT_FOR_WR│                 │
   │                       │ ERROR      │                 │
   │                       └─────┬──────┘                 │
   │           ┌─────────────────┴───────────────┐        │
   │           ▼                                 ▼        │
   │   ┌──────────────┐                ┌──────────────┐   │
   │   │ DiskWrapper  │ ──────────►    │  writeBuf    │   │
   │   │  PAGE_SIZE B │  page bytes    │  (16 B)      │   │
   │   │  load buffer │  via counter   │  + counter   │   │
   │   └──────────────┘                └──────┬───────┘   │
   │                                          │           │
   └──────────────────────────────────────────┼───────────┘
                                              ▼
                              address bus + 4-beat data bus
                                  (under DTE permission)
                                              │
                                              ▼
                                        main memory
```

## 4. Control Registers

Four core-writeable MMIO registers, decoded against fixed addresses on the MIO path:

| Address      | Register       | Purpose                                              |
|--------------|----------------|------------------------------------------------------|
| `0x00000000` | `srcAddr`      | Byte address into the disk                           |
| `0x00000010` | `destAddr`     | Target physical address in main memory               |
| `0x00000020` | `numBytes`     | Total transfer length                                |
| `0x00000030` | `startWrite`   | Go bit (LSB of the data bus write at this address)   |

The MIO datapath drives `coreValOnBus` from the DTE while the core issues a write to one of these addresses. The controller compares the address bus against the four constants and latches `dataBus` into the matching register, but only while `!fsmOuts.busy`. The `startWrite` bit is the trigger; the FSM clears it via `clr_start_write_bit` when the transfer finishes.

## 5. Data Path

A transfer moves data through three buffers in series:

- **`disk_ld_Buffer`** — a PAGE_SIZE-byte buffer inside `DiskWrapper`, filled in one shot from the model disk after a fixed delay (`DISK_LOAD_DELAY = 75` cycles).
- **`writeBuf`** — a 16-byte buffer inside the controller. One cache line of the disk page, sliced out at offset `counter`. Driven onto the data bus four bytes at a time when the DTE grants `permission2DriveDataBus[i]`.
- **Main memory** — the destination, written one 16-byte line at a time at address `(destAddr + counter)`.

`counter` is the byte offset into the page. It is reset to 0 on `ld_counter` and incremented by `CACHE_LINES_SIZE_B = 16` on `inc_counter`, which moves the slicing window forward one cache line per outbound write.

## 6. FSM Sequencing

Five states:

- **IDLE** — wait for `dma_Regs.startWrite`. On startWrite: assert `req_ld` (tell `DiskWrapper` to begin loading), go to **WAIT_FOR_LD**.
- **WAIT_FOR_LD** — assert `busy_o`. Spin until `DiskWrapper` raises `disk_ld_Buffer_V` (75 cycles after `req_ld` was pulsed). On `ld_buf_data_V`: assert `ld_counter` (reset counter to 0), go to **LD_BUF**.
- **LD_BUF** — if `writeComplete` (counter ≥ numBytes), assert `clr_start_write_bit` and `interrupt`, return to **IDLE**. Otherwise assert `ld_writeBuf` — one cache line is sliced out of `disk_ld_Buffer` at offset `counter` into the controller's `writeBuf`, `writeBuf_V` is set, `writeBuf_addr` becomes `destAddr + counter`; go to **WAIT_FOR_WR**.
- **WAIT_FOR_WR** — assert `req_bus` (signals the scheduler with `DMA_WRITE_REQ` via `out2Sch_o.dma_req`). Wait for the DTE to drain `writeBuf` into memory; the DTE eventually asserts `writeComplete` back, which clears `writeBuf_V`. When `writeBuf_V` drops: assert `inc_counter` (advance counter by one line), go back to **LD_BUF**.
- **ERROR** — synthesised trap state.

The interrupt output `out2Core_o.intOut` pulses on the LD_BUF → IDLE arc that fires when `writeComplete` asserts at end-of-transfer.

## 7. Interface to the Bus / DTE

The controller talks to the DTE through `dte_2_dma_controller_t`:

- **`permission2DriveADDRBus`** — drive `(destAddr + counter)` onto the address bus.
- **`permission2DriveDataBus[0..3]`** — drive a 32-bit slice of `writeBuf` onto the data bus.
- **`commiting`** — latched into a `commiting` flag inside the controller.
- **`writeComplete`** — DTE has finished pushing the line to memory; the controller drops `writeBuf_V` and lets the FSM advance.

Back the other way:

- **`out2Sch_o.dma_req`** = `DMA_WRITE_REQ` when `req_bus` is asserted and `!commiting`; `NO_REQ` otherwise.
- **`out2Sch_o.writeBuf_Address`** = `writeBuf_addr` (= `destAddr + counter`).
- **`out2Core_o.intOut`** = the FSM interrupt pulse on transfer completion.

The `commiting` flag suppresses `dma_req` while the DTE is mid-transaction, so the scheduler does not see `DMA_WRITE_REQ` for a line that is already being committed.

## 8. Bus Driving

```
  addrBus_drv = destAddr + counter
  addrBus = permission2DriveADDRBus ? addrBus_drv : 'z  (with a #5 delay)

  dataBus  = one of permission2DriveDataBus[0..3] selects which 4-byte
             slice of writeBuf is driven (writeBuf[i*4 +: 4]); 'z when no
             permission bit is set
```

## 9. DiskWrapper

A simple model of a backing disk for simulation. Holds `DISK_SIZE = 4 × PAGE_SIZE` bytes. On `ld_write_buf_req` it kicks off a `DISK_LOAD_DELAY = 75`-cycle wait, then copies up to `PAGE_SIZE` bytes starting at `ld_diskAddr` into `disk_ld_Buffer` in one cycle. It asserts `disk_ld_Buffer_V` to tell the DMA FSM the page is ready. Transfers smaller than a page only fill the front of the buffer (number of bytes copied is bounded by `ld_num_bytes mod PAGE_SIZE`).

## 10. Critical Path / Timing

This arc contributes to the overall 11.2 ns clock period but was not the binding stage — the Decode stage set the cycle time.

## 11. Design Considerations and Trade-offs

- **In-progress configuration lock** is gated by `fsmOuts.busy`, so reconfiguring a register while a transfer runs is silently dropped. Clean separation; the cost is the core needs to poll busy or wait for the completion interrupt before writing new values.
- **One outstanding DMA write at a time** through the scheduler — keeps the bus contract simple. A second line is not requested until the previous line's `writeComplete` is observed.
- **`commiting` flag** prevents duplicate `dma_req`s during a committing transaction. Trivial to add, important for not confusing the scheduler.
- **5-state FSM** is the minimum needed to express the disk-load → slice → bus-write loop without forcing the FSM to do two things at once. ERROR state is synthesised for illegal transitions; it never gets entered in correct simulation.
- **`#5` delays on bus drives** keep the model honest about contention windows in simulation; in synthesis they collapse.

## 12. Conclusions

The DMA controller moves a contiguous range of disk bytes into main memory in cache-line chunks, raising an interrupt at the end. It exercises the MMIO write path (four config registers), the scheduler interface (`DMA_WRITE_REQ` with `writeBuf_Address`), the DTE permission protocol (`permission2DriveADDRBus` + 4-way `permission2DriveDataBus`), and the interrupt return path — i.e. it's a useful integration test of the whole MMIO + bus + main-mem stack.

A natural next design would (1) issue multiple outstanding DMA writes so the bus drains while the next line is being prepared, (2) add a source-on-memory DMA mode (memory-to-memory copies, not just disk-to-memory), and (3) add scatter-gather support so a single transfer can span multiple non-contiguous source / destination regions.
