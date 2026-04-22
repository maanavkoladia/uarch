#!/usr/bin/env python3
"""
x86-32 Functional Instruction-Level Simulator

Usage:
    python3 sim.py --asm path/to/program.s [--tlb path/to/TLB.conf.json] [--core-regs path/to/CoreRegs.conf.json]
    python3 sim.py --config sim_config.json

Assembles the .s file using GNU as/ld, disassembles with objdump to get
real instruction addresses and sizes, then executes instruction-by-instruction.
"""

import argparse
import json
import sys
import os

from registers import RegisterFile
from flags import Flags
from memory import Memory
from parser import assemble_and_disassemble, parse_objdump, parse_data_from_source
from execute import CPU, CPUException, HaltException


def load_config(config_path):
    with open(config_path) as f:
        return json.load(f)


def setup_from_args(asm_path, tlb_path=None, core_regs_path=None):
    """Set up simulator from CLI args."""
    regs = RegisterFile()
    flags = Flags()
    mem = Memory()

    if tlb_path:
        mem.tlb.load_from_config(tlb_path)

    if core_regs_path:
        with open(core_regs_path) as f:
            cfg = json.load(f)
        if "SegLimitVals" in cfg:
            sl = cfg["SegLimitVals"]
            for seg_name in ["CS", "DS", "SS", "ES", "FS", "GS"]:
                if seg_name in sl:
                    val_str = sl[seg_name][0]  # e.g. "20'hFFFFF"
                    val = int(val_str.split("'h")[1], 16)
                    regs.seg_limits[seg_name.lower()] = val

    return regs, flags, mem


def run_simulation(regs, flags, mem, asm_path, verbose=True, max_cycles=100000, dump_cycle=None):
    """Run the simulation. Returns (trace, final_state)."""

    # Phase 1: Assemble and disassemble
    print("Assembling...") if verbose else None
    objdump_text, objdump_raw, data_bytes, text_org, data_org = assemble_and_disassemble(asm_path)

    # Phase 2: Parse instructions from objdump
    instructions = parse_objdump(objdump_text, objdump_raw)

    # Override text_org with actual first instruction address
    if instructions:
        text_org = instructions[0].addr

    # Build address -> instruction index map
    addr_to_idx = {}
    for i, inst in enumerate(instructions):
        addr_to_idx[inst.addr] = i

    # Phase 3: Load data into memory
    # Auto-map data pages in TLB so they're accessible
    for vaddr, data in data_bytes.items():
        mem.tlb.add_identity_mapping(vaddr, len(data))
        paddr, err = mem.tlb.translate(vaddr)
        if err:
            print("WARNING: Could not map data at 0x{:08X}: {}".format(vaddr, err))
            paddr = vaddr & (mem.SIZE - 1)
        mem.load_bytes_physical(paddr, data)

    # Set initial EIP
    regs.eip = text_org

    cpu = CPU(regs, flags, mem)
    trace = []
    pc = 0  # instruction index

    if verbose:
        print(f"=== x86-32 Functional Simulator ===")
        print(f"Code origin: 0x{regs.eip:08X}")
        print(f"Instructions: {len(instructions)}")
        print(f"Data sections loaded: {len(data_bytes)}")
        if instructions:
            print(f"First instruction: {instructions[0]}")
            print(f"Last instruction:  {instructions[-1]}")
        print()

    while cpu.cycle < max_cycles:
        if pc < 0 or pc >= len(instructions):
            if verbose:
                print(f"[cycle {cpu.cycle}] EIP 0x{regs.eip:08X} - out of instruction range, halting.")
            break

        inst = instructions[pc]
        regs.eip = inst.addr

        # Snapshot before execution
        snap_before = regs.dump()
        snap_before["flags"] = flags.dump()
        snap_before["cycle"] = cpu.cycle
        snap_before["instruction"] = str(inst)
        snap_before["raw"] = inst.raw
        snap_before["addr"] = inst.addr

        # Advance EIP past current instruction (for relative jumps)
        next_eip = inst.addr + inst.size
        regs.eip = next_eip

        try:
            eip_modified = cpu.execute(inst)
        except HaltException:
            if verbose:
                print(f"[cycle {cpu.cycle:4d}] 0x{inst.addr:08X}: {inst.raw}")
                print(f"  *** HLT - Processor halted ***")
            snap_after = regs.dump()
            snap_after["flags"] = flags.dump()
            trace.append({"before": snap_before, "after": snap_after})
            cpu.cycle += 1
            cpu.halted = True
            break
        except CPUException as e:
            print(f"\n!!! EXCEPTION at cycle {cpu.cycle}, addr 0x{inst.addr:08X} !!!")
            print(f"    Instruction: {inst.raw}")
            print(f"    {e}")
            print(f"    Stopping simulation.")
            break

        snap_after = regs.dump()
        snap_after["flags"] = flags.dump()
        trace.append({"before": snap_before, "after": snap_after})

        if verbose:
            print(f"[cycle {cpu.cycle:4d}] 0x{inst.addr:08X}: {inst.raw}")
            _print_changed(snap_before, snap_after)

        if dump_cycle is not None and cpu.cycle == dump_cycle:
            _print_state(regs, flags, cpu.cycle)

        # Advance PC
        if eip_modified:
            # EIP was set by the instruction (jump)
            target = regs.eip
            if target in addr_to_idx:
                pc = addr_to_idx[target]
            else:
                if verbose:
                    print(f"  WARNING: Jump target 0x{target:08X} not found in instruction map")
                break
        else:
            pc += 1
            regs.eip = next_eip

        cpu.cycle += 1

    if verbose:
        print(f"\n=== Final State (cycle {cpu.cycle}) ===")
        print(regs.dump_str())
        print(flags.dump_str())

    return trace, {"regs": regs.dump(), "flags": flags.dump(), "cycles": cpu.cycle}


def _write_trace(trace, out_path):
    """Write a normalized per-instruction trace for use with compare.py.

    Format (one line per committed instruction):
        EIP       MNEMONIC     WRITES                  FLAGS
        0x1000    movl         EAX=0x00001000          CF=0 ZF=0 SF=0 OF=0 PF=1 AF=0
    """
    GPR   = ["eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi"]
    SEG   = ["cs", "ds", "ss", "es", "fs", "gs"]
    MMX   = [f"mm{i}" for i in range(8)]
    FLAGS = ["CF", "ZF", "SF", "OF", "PF", "AF"]

    with open(out_path, 'w') as f:
        f.write("# SIM TRACE — generated by sim.py\n")
        f.write("# Format: EIP  MNEMONIC  WRITES  CF=? ZF=? SF=? OF=? PF=? AF=?\n")
        f.write("#\n")
        for entry in trace:
            before = entry["before"]
            after  = entry["after"]
            eip    = before["addr"]
            raw    = before.get("raw", "")
            mnemonic = raw.split(None, 1)[0] if raw else "unk"

            # Collect changed registers (normalized to uppercase, 8 hex digits for GPR/SEG)
            writes = []
            for reg in GPR:
                bv, av = before.get(reg, 0), after.get(reg, 0)
                if bv != av:
                    writes.append(f"{reg.upper()}=0x{av:08X}")
            for reg in SEG:
                bv, av = before.get(reg, 0), after.get(reg, 0)
                if bv != av:
                    writes.append(f"{reg.upper()}=0x{av:04X}")
            for reg in MMX:
                bv, av = before.get(reg, 0), after.get(reg, 0)
                if bv != av:
                    writes.append(f"{reg.upper()}=0x{av:016X}")

            writes_str = ",".join(writes) if writes else "none"

            af = after.get("flags", {})
            flags_str = " ".join(f"{fl}={af.get(fl, 0)}" for fl in FLAGS)

            f.write(f"0x{eip:08X}  {mnemonic:<12}  {writes_str:<48}  {flags_str}\n")


def _print_changed(before, after):
    for k in ["eax", "ebx", "ecx", "edx", "esp", "ebp", "esi", "edi"]:
        if before.get(k) != after.get(k):
            print(f"    {k}: 0x{before[k]:08X} -> 0x{after[k]:08X}")
    for k in ["cs", "ds", "ss", "es", "fs", "gs"]:
        if before.get(k) != after.get(k):
            print(f"    {k}: 0x{before.get(k, 0):04X} -> 0x{after.get(k, 0):04X}")
    for i in range(8):
        k = f"mm{i}"
        if before.get(k) != after.get(k):
            print(f"    {k}: 0x{before.get(k, 0):016X} -> 0x{after.get(k, 0):016X}")
    bf = before.get("flags", {})
    af = after.get("flags", {})
    for f in ["CF", "ZF", "SF", "OF", "PF", "AF"]:
        if bf.get(f) != af.get(f):
            print(f"    {f}: 0x{bf.get(f, 0):X} -> 0x{af.get(f, 0):X}")


def _print_state(regs, flags, cycle):
    print(f"\n--- Register dump at cycle {cycle} ---")
    print(regs.dump_str())
    print(flags.dump_str())
    print()


def main():
    p = argparse.ArgumentParser(description="x86-32 Functional Simulator")
    p.add_argument("--asm", required=True, help="Path to .s assembly file")
    p.add_argument("--tlb", help="Path to TLB.conf.json")
    p.add_argument("--core-regs", help="Path to CoreRegs.conf.json")
    p.add_argument("--config", help="Path to sim config JSON (overrides other args)")
    p.add_argument("--quiet", action="store_true", help="Suppress per-instruction output")
    p.add_argument("--max-cycles", type=int, default=100000)
    p.add_argument("--dump-cycle", type=int, help="Dump full state at this cycle")
    p.add_argument("--dump-json", help="Write final state to JSON file")
    p.add_argument("--trace-file", metavar="PATH",
                   help="Write normalized per-instruction trace to PATH (for compare.py)")
    args = p.parse_args()

    if args.config:
        cfg = load_config(args.config)
        regs, flags, mem = setup_from_args(
            cfg.get("asm_file", args.asm),
            cfg.get("tlb_config", args.tlb),
            cfg.get("core_regs_config", args.core_regs)
        )
        asm_path = cfg.get("asm_file", args.asm)
    else:
        regs, flags, mem = setup_from_args(args.asm, args.tlb, args.core_regs)
        asm_path = args.asm

    trace, final = run_simulation(regs, flags, mem, asm_path,
                                   verbose=not args.quiet,
                                   max_cycles=args.max_cycles,
                                   dump_cycle=args.dump_cycle)

    if args.dump_json:
        out = {"cycles": final["cycles"]}
        out["regs"] = {k: "0x{:08X}".format(v) for k, v in final["regs"].items()}
        out["flags"] = {k: "0x{:X}".format(v) if isinstance(v, int) else v
                        for k, v in final["flags"].items()}
        with open(args.dump_json, 'w') as f:
            json.dump(out, f, indent=2)
        print(f"\nFinal state written to {args.dump_json}")

    if args.trace_file:
        _write_trace(trace, args.trace_file)
        print(f"\nSim trace written to {args.trace_file}")


if __name__ == "__main__":
    main()
