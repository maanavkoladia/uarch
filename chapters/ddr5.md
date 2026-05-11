# DDR5 ("Dynamic Degree Reader") — Design Report

## 1. Overview

The module named `ddr5` in this design has nothing to do with DRAM. The acronym is a joke: it stands for **Dynamic Degree Reader** — a temperature sensor with a software-controlled power-gate switch, exposed to the core through two MMIO registers. From the core's perspective, the DDR5 block is a tiny MMIO peripheral that can be read for a temperature value and written to power-gate the sensor on or off.

When the sensor is power-gated **off**, the temperature register reads 0. When **on**, it reads the constant `TEMP_VAL = 3000`, which in this model represents the "current temperature."

![DDR5 (temperature sensor) block diagram.](figures/fig_ddr5.png){#fig:ddr5 width=85%}

## 2. Interesting Features

- **Pure MMIO peripheral** — no logic of its own beyond two registers. The DTE handles all bus arbitration, so the DDR5 block does not decode the address bus itself; it just responds to two control pulses (`newPowerGateValueFromCore`, `driveDataBus`).
- **Two control / status registers** at fixed MMIO addresses:
  - `0x00000040` — power-gate write (1 = gated off, 0 = ungated on).
  - `0x00000050` — temperature read.
- **Implicit power-gating semantics** — the temperature register reloads every cycle based on the `powerGate` flop: gated → 0, ungated → `TEMP_VAL`. No separate path to "compute" the temperature.

## 3. Subsystem Organization

```
       core (MIO load / store)
                │
                ▼
        MIO path + DTE
                │
                ├─── newPowerGateValueFromCore ──► powerGate flop
                │                                          │
                │                                          ▼
                ├─── driveDataBus ─────────────────► tempValue register
                │                                          │
                ▼                                          ▼
            address bus                           data bus (tristate)
```

The DTE has already decided that the current bus phase belongs to this block by the time `driveDataBus` or `newPowerGateValueFromCore` is asserted, so the DDR5 module does not need to compare against the address bus itself.

## 4. Internal State

Two registers:

- **`powerGate`** — 1-bit flop. Reset value is `1` (sensor starts gated off). Updated when the DTE asserts `newPowerGateValueFromCore`; the new value is taken from `dataBus[0]`.
- **`tempValue`** — 32-bit register. Reloaded every cycle:
  - If `!rst` OR `powerGate` → 0
  - Else → `TEMP_VAL = 3000`

So while the sensor is gated off the register reads 0; while ungated, it holds the constant temperature.

## 5. Interface to the Bus / DTE

The DTE drives two control bits in `dte_2_ddr5_t`:

- **`newPowerGateValueFromCore`** — pulse during a core MIO write to `0x00000040`. The module latches `dataBus[0]` into `powerGate`.
- **`driveDataBus`** — pulse during a core MIO read of `0x00000050`. The module drives `tempValue` onto the 32-bit data bus.

Bus driving (with a `#5` delay):

```
  dataBus = driveDataBus ? tempValue : 'z
  addrBus = (never driven by this block)
```

## 6. Operation

**Read temperature**: the core issues an MIO load to `0x00000050`. The MIO / DTE path arbitrates it through `DTE_DDR5_2_Core_FSM`, which pulses `driveDataBus` for one cycle. DDR5 drives `tempValue` onto the data bus during that cycle; the core captures it through the MIO_Block path back into the pipeline.

**Write power-gate**: the core issues an MIO store to `0x00000040` with the new gate value in bit 0 of the data. `DTE_Core_2_DDR5_FSM` pulses `newPowerGateValueFromCore`; DDR5 latches `dataBus[0]` into `powerGate` on the next rising edge. On the cycle after, `tempValue` updates to match (0 if gated off, `TEMP_VAL` if on).

## 7. Critical Path / Timing

This arc contributes to the overall 11.2 ns clock period but was not the binding stage — the Decode stage set the cycle time.

## 8. Design Considerations and Trade-offs

- **No address decode in the block itself** — the DTE has already decided the bus phase belongs to this block by the time the control pulses fire. Keeps the block tiny.
- **Constant temperature in this model** — the design intentionally returns a fixed `TEMP_VAL` rather than a real sensor reading. The interface is the part being designed; a real sensor can be dropped in later without changing the bus contract.
- **Reset-to-gated** — `powerGate` resets to 1, so the temperature register reads 0 until software explicitly enables the sensor.

## 9. Conclusions

DDR5 is a deliberately small MMIO peripheral that exercises the MMIO path end-to-end: address decode in the DTE, single-pulse control / data handshakes back to the block, tristate bus driving under DTE permission. Its main value to the design is as a *concrete consumer* of the MMIO arbitration, write, and read sequences — not as a sophisticated component in its own right.

A natural next iteration would (1) replace the constant temperature with a real sensor model or a software-loadable value, (2) add a status register tracking how long the sensor has been ungated, and (3) consider an interrupt line so the core can be told when the sensor crosses a programmable threshold.
