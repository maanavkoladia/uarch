#!/usr/bin/env python3
"""
x86-32 Functional Instruction-Level Simulator (segmented memory model).

Usage:
    python3 sim.py --test-dir <dir> --bin <path/to/program.bin> [options]

`<dir>` must contain:
    TLB.conf.json
    CoreRegs.conf.json
    memGen.conf.json     (only used informationally for mem_size_bytes)

`program.bin` is a flat 32 KiB physical image.
"""

import argparse
import json
import os
import sys

from registers import RegisterFile
from flags import Flags
from memory import Memory
from decoder import decode_one
from execute import CPU, CPUException, HaltException


# --------------------------------------------------------------
# Helpers
# --------------------------------------------------------------
def _parse_verilog_literal(s):
    """Parse a Verilog-style literal like \"32'h0001A2B0\" or \"20'hFFFFF\"."""
    s = s.strip()
    if "'h" in s:
        return int(s.split("'h", 1)[1], 16)
    if "'d" in s:
        return int(s.split("'d", 1)[1], 10)
    if "'b" in s:
        return int(s.split("'b", 1)[1], 2)
    return int(s, 0)


def _load_core_regs(regs, core_cfg_path):
    with open(core_cfg_path) as f:
        cfg = json.load(f)

    if cfg.get("EIP", {}).get("load") == "true":
        regs.eip = _parse_verilog_literal(cfg["EIP"]["val"]) & 0xFFFFFFFF

    if cfg.get("SegLimitVals", {}).get("load") == "true":
        sl = cfg["SegLimitVals"]
        for seg in ["CS", "DS", "SS", "ES", "FS", "GS"]:
            if seg in sl and isinstance(sl[seg], list) and sl[seg]:
                regs.seg_limits[seg.lower()] = _parse_verilog_literal(sl[seg][0]) & 0xFFFFF


# --------------------------------------------------------------
# Main loop
# --------------------------------------------------------------
def run_simulation(test_dir, bin_path, verbose=True, max_cycles=100000, dump_cycle=None):
    regs  = RegisterFile()
    flags = Flags()
    mem   = Memory()

    mem.load_from_bin(bin_path)
    mem.load_tlb(os.path.join(test_dir, "TLB.conf.json"))
    _load_core_regs(regs, os.path.join(test_dir, "CoreRegs.conf.json"))

    cpu = CPU(regs, flags, mem)
    trace = []

    if verbose:
        print(f"=== x86-32 Functional Simulator (segmented) ===")
        print(f"  test-dir : {test_dir}")
        print(f"  bin      : {bin_path}")
        print(f"  EIP init : 0x{regs.eip:08X}")
        print(f"  CS init  : 0x{regs.get('cs'):04X}")
        seg_lim_str = "  ".join(f"{s.upper()}=0x{regs.seg_limits[s]:05X}"
                                for s in ["cs", "ds", "ss", "es", "fs", "gs"])
        print(f"  limits   : {seg_lim_str}")
        print()

    while cpu.cycle < max_cycles:
        eip    = regs.eip
        cs_val = regs.get('cs')

        # --- Instruction Fetch ---
        raw_bytes, fetch_err = mem.fetch_bytes(eip, cs_val, regs.seg_limits, count=15)
        if fetch_err and len(raw_bytes) == 0:
            print(f"[cycle {cpu.cycle}] Fetch fault at CS:EIP={cs_val:04X}:{eip:08X}: {fetch_err}")
            break
        if len(raw_bytes) == 0:
            print(f"[cycle {cpu.cycle}] No bytes fetched at CS:EIP={cs_val:04X}:{eip:08X}, halting.")
            break

        linear_fetch = ((cs_val << 16) + eip) & 0xFFFFFFFF

        # --- Decode ---
        inst = decode_one(raw_bytes, linear_fetch)
        if inst is None:
            print(f"[cycle {cpu.cycle}] Decode failed at 0x{linear_fetch:08X} "
                  f"(bytes: {raw_bytes[:8].hex()}), halting.")
            break

        # --- Snapshot before ---
        snap_before = regs.dump()
        snap_before["flags"] = flags.dump()
        snap_before["cycle"] = cpu.cycle
        snap_before["instruction"] = str(inst)
        snap_before["raw"]   = inst.raw
        snap_before["addr"]  = eip  # raw EIP offset within CS (pre-segment-translation)

        # --- Advance EIP past current instruction (handlers may overwrite) ---
        regs.eip = (eip + inst.size) & 0xFFFFFFFF

        # --- Execute ---
        try:
            eip_modified = cpu.execute(inst)
        except HaltException:
            if verbose:
                print(f"[cycle {cpu.cycle:4d}] {cs_val:04X}:{eip:08X}: {inst.raw}")
                print(f"  *** HLT — Processor halted ***")
            snap_after = regs.dump()
            snap_after["flags"] = flags.dump()
            trace.append({"before": snap_before, "after": snap_after})
            cpu.cycle += 1
            cpu.halted = True
            break
        except CPUException as e:
            print(f"\n!!! EXCEPTION at cycle {cpu.cycle}, CS:EIP={cs_val:04X}:{eip:08X} !!!")
            print(f"    Instruction: {inst.raw}")
            print(f"    {e}")
            print(f"    Stopping simulation.")
            break

        # --- Snapshot after ---
        snap_after = regs.dump()
        snap_after["flags"] = flags.dump()
        trace.append({"before": snap_before, "after": snap_after})

        if verbose:
            print(f"[cycle {cpu.cycle:4d}] {cs_val:04X}:{eip:08X}: {inst.raw}")
            _print_changed(snap_before, snap_after)

        if dump_cycle is not None and cpu.cycle == dump_cycle:
            _print_state(regs, flags, cpu.cycle)

        cpu.cycle += 1

    if verbose:
        print(f"\n=== Final State (cycle {cpu.cycle}) ===")
        print(regs.dump_str())
        print(flags.dump_str())

    return trace, {"regs": regs.dump(), "flags": flags.dump(), "cycles": cpu.cycle}


# --------------------------------------------------------------
# Trace / dump writers (unchanged formats)
# --------------------------------------------------------------
def _write_trace(trace, out_path):
    """Write a normalized per-instruction trace for use with compare.py."""
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
    for fl in ["CF", "ZF", "SF", "OF", "PF", "AF"]:
        if bf.get(fl) != af.get(fl):
            print(f"    {fl}: 0x{bf.get(fl, 0):X} -> 0x{af.get(fl, 0):X}")


def _print_state(regs, flags, cycle):
    print(f"\n--- Register dump at cycle {cycle} ---")
    print(regs.dump_str())
    print(flags.dump_str())
    print()


def _write_regdump_log(trace, out_path):
    """Per-instruction regfile dump matching RTL regdump.log format."""
    with open(out_path, 'w') as f:
        for entry in trace:
            eip = entry["before"]["addr"]
            s   = entry["after"]
            f.write(f"[REGFILE DUMP] EIP=0x{eip:08X}\n")
            f.write(f"  EAX=0x{s.get('eax',0):08X}  EBX=0x{s.get('ebx',0):08X}"
                    f"  ECX=0x{s.get('ecx',0):08X}  EDX=0x{s.get('edx',0):08X}\n")
            f.write(f"  ESP=0x{s.get('esp',0):08X}  EBP=0x{s.get('ebp',0):08X}"
                    f"  ESI=0x{s.get('esi',0):08X}  EDI=0x{s.get('edi',0):08X}\n")
            f.write(f"  CS =0x{s.get('cs',0):08X}  DS =0x{s.get('ds',0):08X}"
                    f"  SS =0x{s.get('ss',0):08X}  ES =0x{s.get('es',0):08X}\n")
            f.write(f"  FS =0x{s.get('fs',0):08X}  GS =0x{s.get('gs',0):08X}\n")
            f.write(f"  MM0=0x{s.get('mm0',0):016X}  MM1=0x{s.get('mm1',0):016X}"
                    f"  MM2=0x{s.get('mm2',0):016X}  MM3=0x{s.get('mm3',0):016X}\n")
            f.write(f"  MM4=0x{s.get('mm4',0):016X}  MM5=0x{s.get('mm5',0):016X}"
                    f"  MM6=0x{s.get('mm6',0):016X}  MM7=0x{s.get('mm7',0):016X}\n")


def _write_flagdump_log(trace, out_path):
    """Per-instruction flag dump matching RTL flagdump.log format."""
    with open(out_path, 'w') as f:
        for entry in trace:
            eip = entry["before"]["addr"]
            fl  = entry["after"].get("flags", {})
            df  = (fl.get("eflags", 0) >> 10) & 1
            f.write(f"[FLAG DUMP] EIP=0x{eip:08X}\n")
            f.write(f"  CF={fl.get('CF',0)}  PF={fl.get('PF',0)}  AF={fl.get('AF',0)}"
                    f"  ZF={fl.get('ZF',0)}  SF={fl.get('SF',0)}  DF={df}"
                    f"  OF={fl.get('OF',0)}\n")


# --------------------------------------------------------------
# CLI
# --------------------------------------------------------------
def main():
    p = argparse.ArgumentParser(description="x86-32 Functional Simulator (segmented)")
    p.add_argument("--test-dir", required=True,
                   help="Folder containing TLB.conf.json, CoreRegs.conf.json, memGen.conf.json")
    p.add_argument("--bin", required=True,
                   help="Flat physical-image program.bin (32 KiB)")
    p.add_argument("--quiet", action="store_true", help="Suppress per-instruction output")
    p.add_argument("--max-cycles", type=int, default=100000)
    p.add_argument("--dump-cycle", type=int, help="Dump full state at this cycle")
    p.add_argument("--dump-json", help="Write final state to JSON file")
    p.add_argument("--trace-file", metavar="PATH",
                   help="Write normalized per-instruction trace to PATH (for compare.py)")
    p.add_argument("--regdump-file", metavar="PATH",
                   help="Write per-instruction regfile dump matching RTL regdump.log format")
    p.add_argument("--flagdump-file", metavar="PATH",
                   help="Write per-instruction flag dump matching RTL flagdump.log format")
    args = p.parse_args()

    trace, final = run_simulation(
        test_dir=args.test_dir, bin_path=args.bin,
        verbose=not args.quiet,
        max_cycles=args.max_cycles,
        dump_cycle=args.dump_cycle,
    )

    if args.dump_json:
        out = {"cycles": final["cycles"]}
        out["regs"]  = {k: f"0x{v:08X}" for k, v in final["regs"].items()}
        out["flags"] = {k: (f"0x{v:X}" if isinstance(v, int) else v)
                        for k, v in final["flags"].items()}
        with open(args.dump_json, 'w') as f:
            json.dump(out, f, indent=2)
        print(f"\nFinal state written to {args.dump_json}")

    if args.trace_file:
        _write_trace(trace, args.trace_file)
        print(f"\nSim trace written to {args.trace_file}")

    if args.regdump_file:
        _write_regdump_log(trace, args.regdump_file)
        print(f"Reg dump written to {args.regdump_file}")

    if args.flagdump_file:
        _write_flagdump_log(trace, args.flagdump_file)
        print(f"Flag dump written to {args.flagdump_file}")


if __name__ == "__main__":
    main()
