#!/usr/bin/env python3
"""
compare.py  —  Diff Python functional sim trace against RTL pipeline_debug.log

Usage:
    # 1. Generate the sim trace:
    python3 sim.py --asm tests/Stages/Harish_StageTesting/config/AAA_ADC.s \
                   --tlb ... --core-regs ... --trace-file sim_trace.log

    # 2. Run compare:
    python3 compare.py --sim sim_trace.log \
                       --rtl tests/Stages/Harish_StageTesting/pipeline_debug.log

    # Optional: write report to file instead of stdout
    python3 compare.py --sim sim_trace.log --rtl pipeline_debug.log --out report.txt

How it works:
    * Sim trace (from --trace-file):  one line per committed instruction, keyed by EIP.
    * RTL log (pipeline_debug.log):
        - [EXE LATCHES] valid=1 EIP=0x...  FLAGS: AF=? CF=? ...
          → captures per-EIP flag state (EXE output is where flags are computed)
        - [WB NEXT LATCHES] valid=1 EIP=0x...  dr=REG(val)  WB_CS: WB_DR=?
          → captures per-EIP register writeback
    * Both are merged by EIP and compared side-by-side.
"""

import re
import sys
import argparse
from collections import OrderedDict

# ---------------------------------------------------------------------------
# Normalized record dataclass (plain dict)
# ---------------------------------------------------------------------------
# {
#   'eip':      int,
#   'mnemonic': str,         # 'RTL' for hardware side
#   'writes':   dict,        # { 'EAX': 0x..., 'EBX': 0x..., ... }
#   'flags':    dict,        # { 'CF': 0, 'ZF': 1, ... }
# }

FLAG_NAMES = ["CF", "ZF", "SF", "OF", "PF", "AF"]


# ---------------------------------------------------------------------------
# Sim trace parser
# ---------------------------------------------------------------------------
def parse_sim_trace(path):
    """Parse a sim_trace.log produced by sim.py --trace-file.
    Returns OrderedDict { eip (int) -> record }.
    If the same EIP appears twice (e.g. a loop), they are stored in order
    under a list — but for simple linear tests EIPs are unique.
    """
    records = OrderedDict()
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            # Format: 0x00001000  movl         EAX=0x00000000,...  CF=0 ZF=0 SF=0 OF=0 PF=1 AF=0
            m = re.match(
                r'^(0x[0-9a-fA-F]+)\s+'          # EIP
                r'(\S+)\s+'                        # mnemonic
                r'(\S+)\s+'                        # writes (comma-sep or 'none')
                r'(CF=\d.*)',                      # flags
                line
            )
            if not m:
                continue
            eip      = int(m.group(1), 16)
            mnemonic = m.group(2)
            writes   = _parse_writes(m.group(3))
            flags    = _parse_flags(m.group(4))

            rec = {'eip': eip, 'mnemonic': mnemonic, 'writes': writes, 'flags': flags}
            # Use list to handle repeated EIPs (loops)
            records.setdefault(eip, []).append(rec)

    # Flatten: if each EIP appears only once, simplify to single record list
    flat = []
    for recs in records.values():
        flat.extend(recs)
    return flat


def _parse_writes(s):
    """Parse 'EAX=0x00000001,EBX=0x00000002' → {'EAX': 1, 'EBX': 2}."""
    result = {}
    if s == 'none':
        return result
    for token in s.split(','):
        token = token.strip()
        if '=' not in token:
            continue
        reg, val = token.split('=', 1)
        try:
            result[reg.upper().strip()] = int(val, 16)
        except ValueError:
            pass
    return result


def _parse_flags(s):
    """Parse 'CF=0 ZF=1 SF=0 OF=0 PF=1 AF=0' → {'CF':0, 'ZF':1, ...}."""
    result = {}
    for token in s.split():
        if '=' in token:
            k, v = token.split('=', 1)
            try:
                result[k.upper()] = int(v)
            except ValueError:
                pass
    return result


# ---------------------------------------------------------------------------
# RTL log parser
# ---------------------------------------------------------------------------
def parse_rtl_log(path):
    """Parse pipeline_debug.log from the RTL testbench.

    Extracts per-EIP data from two sections:
      [EXE LATCHES]     → EIP + FLAGS (flags are computed here)
      [WB NEXT LATCHES] → EIP + register writes

    Both are keyed by EIP and merged.
    Returns list of records in EIP-commit order (order of first WB commit).
    """

    # We track: exe_data[eip] = flags_dict
    #           wb_data[eip]  = writes_dict  (first commit wins)
    #           wb_order       = list of EIPs in order of first WB commit
    exe_data = {}   # eip -> flags
    wb_data  = {}   # eip -> writes dict
    wb_order = []   # EIPs in WB commit order

    IN_NONE = 0
    IN_EXE  = 1
    IN_WB   = 2

    state     = IN_NONE
    cur_valid = False
    cur_eip   = None
    cur_flags = {}
    cur_writes = {}
    cur_wb_dr  = False
    cur_wb_sr  = False
    cur_dr_reg = None
    cur_dr_val = None
    cur_sr_reg = None
    cur_sr_val = None

    def _flush_exe():
        nonlocal cur_valid, cur_eip, cur_flags
        if cur_valid and cur_eip is not None and cur_flags:
            # Keep the LAST valid entry (most recent execution, not a stale bubble)
            exe_data[cur_eip] = dict(cur_flags)
        cur_valid = False
        cur_eip   = None
        cur_flags = {}

    def _flush_wb():
        nonlocal cur_valid, cur_eip, cur_wb_dr, cur_wb_sr
        nonlocal cur_dr_reg, cur_dr_val, cur_sr_reg, cur_sr_val
        if cur_valid and cur_eip is not None:
            writes = {}
            if cur_wb_dr and cur_dr_reg and cur_dr_reg not in ('---', 'ERR', '???', 'ETR'):
                writes[cur_dr_reg.upper().strip()] = cur_dr_val
            if cur_wb_sr and cur_sr_reg and cur_sr_reg not in ('---', 'ERR', '???', 'ETR'):
                writes[cur_sr_reg.upper().strip()] = cur_sr_val
            if cur_eip not in wb_data:
                wb_data[cur_eip] = writes
                wb_order.append(cur_eip)
        cur_valid  = False
        cur_eip    = None
        cur_wb_dr  = False
        cur_wb_sr  = False
        cur_dr_reg = None
        cur_dr_val = None
        cur_sr_reg = None
        cur_sr_val = None

    with open(path) as f:
        for raw_line in f:
            line = raw_line.strip()

            # Section transitions
            if line.startswith('[EXE LATCHES]'):
                if state == IN_EXE:
                    _flush_exe()
                elif state == IN_WB:
                    _flush_wb()
                state = IN_EXE
                cur_valid = False
                cur_eip   = None
                cur_flags = {}
                continue

            if line.startswith('[WB NEXT LATCHES]'):
                if state == IN_EXE:
                    _flush_exe()
                elif state == IN_WB:
                    _flush_wb()
                state     = IN_WB
                cur_valid = False
                cur_eip   = None
                cur_wb_dr = False
                cur_wb_sr = False
                cur_dr_reg = cur_dr_val = cur_sr_reg = cur_sr_val = None
                continue

            # Any other section header ends current section
            if line.startswith('[') and line.endswith(']'):
                if state == IN_EXE:
                    _flush_exe()
                elif state == IN_WB:
                    _flush_wb()
                state = IN_NONE
                continue

            # Cycle header resets nothing (data continues in same block)
            if re.match(r'^=+ CYCLE', line):
                # New cycle — flush any open section
                if state == IN_EXE:
                    _flush_exe()
                elif state == IN_WB:
                    _flush_wb()
                state = IN_NONE
                continue

            # --- Parse fields within active section ---
            if state == IN_EXE:
                # valid and EIP: "  valid=1  EIP=0x00001000  ..."
                m = re.search(r'valid=(\d)\s+EIP=0x([0-9a-fA-F]+)', line)
                if m:
                    cur_valid = (m.group(1) == '1')
                    cur_eip   = int(m.group(2), 16)

                # FLAGS: "  FLAGS: AF=0 CF=1 DF=0 OF=0 PF=1 SF=0 ZF=0"
                m = re.search(
                    r'FLAGS:\s+AF=(\d)\s+CF=(\d)\s+DF=(\d)\s+OF=(\d)\s+PF=(\d)\s+SF=(\d)\s+ZF=(\d)',
                    line
                )
                if m:
                    cur_flags = {
                        'AF': int(m.group(1)),
                        'CF': int(m.group(2)),
                        'OF': int(m.group(4)),
                        'PF': int(m.group(5)),
                        'SF': int(m.group(6)),
                        'ZF': int(m.group(7)),
                    }

            elif state == IN_WB:
                # valid and EIP
                m = re.search(r'valid=(\d)\s+EIP=0x([0-9a-fA-F]+)', line)
                if m:
                    cur_valid = (m.group(1) == '1')
                    cur_eip   = int(m.group(2), 16)

                # dr=EAX(0x0000000000000000)  sr=---(0x0000000000000000)
                # Register names can be EAX/EBX/..., ---, CS (with trailing space), etc.
                m = re.search(
                    r'dr=([^\s(]+)\s*\(\s*0x([0-9a-fA-F]+)\s*\)\s+sr=([^\s(]+)\s*\(\s*0x([0-9a-fA-F]+)\s*\)',
                    line
                )
                if m:
                    cur_dr_reg = m.group(1).strip()
                    cur_dr_val = int(m.group(2), 16) & 0xFFFFFFFF
                    cur_sr_reg = m.group(3).strip()
                    cur_sr_val = int(m.group(4), 16) & 0xFFFFFFFF

                # WB_CS: ST=0 WB_DR=1 WB_SR=0
                m = re.search(r'WB_DR=(\d).*WB_SR=(\d)', line)
                if m:
                    cur_wb_dr = (m.group(1) == '1')
                    cur_wb_sr = (m.group(2) == '1')

    # Flush last section
    if state == IN_EXE:
        _flush_exe()
    elif state == IN_WB:
        _flush_wb()

    # Build final record list in WB commit order
    records = []
    for eip in wb_order:
        writes = wb_data.get(eip, {})
        flags  = exe_data.get(eip, {})
        records.append({
            'eip':      eip,
            'mnemonic': 'RTL',
            'writes':   writes,
            'flags':    flags,
        })

    return records


# ---------------------------------------------------------------------------
# Comparison logic
# ---------------------------------------------------------------------------
def compare(sim_records, rtl_records, out=sys.stdout):
    """Align sim and RTL records by position (instruction sequence) and diff.

    The RTL pipeline always writes-back DR/SR through the register file, even
    for stores or when the value hasn't changed.  The sim only records *real*
    changes.  To avoid false positives we track register state and suppress
    RTL-only writes that are no-ops (value == current known state).
    """

    n_sim = len(sim_records)
    n_rtl = len(rtl_records)
    n     = max(n_sim, n_rtl)

    total = 0
    passed = 0
    failed = 0
    only_sim = 0
    only_rtl = 0
    noop_suppressed = 0            # no-op RTL write-backs suppressed

    # Track known register state (from agreed / SIM writes) so we can detect
    # RTL no-op write-backs.  Keys are uppercase register names, values are
    # the last-known 32-bit integer value.
    reg_state = {}

    def w(line):
        out.write(line + '\n')

    w("=" * 80)
    w("  SIM vs RTL COMPARISON REPORT")
    w("=" * 80)
    w(f"  Sim instructions: {n_sim}")
    w(f"  RTL commits:      {n_rtl}")
    w("")

    for i in range(n):
        sim = sim_records[i] if i < n_sim else None
        rtl = rtl_records[i] if i < n_rtl else None
        total += 1

        if sim is None:
            only_rtl += 1
            w(f"[ONLY_RTL] #{i:04d}  EIP=0x{rtl['eip']:08X}  "
              f"RTL writes={_fmt_writes(rtl['writes'])}  flags={_fmt_flags(rtl['flags'])}")
            # Update reg_state from RTL writes (best info we have)
            reg_state.update(rtl['writes'])
            continue

        if rtl is None:
            only_sim += 1
            w(f"[ONLY_SIM] #{i:04d}  EIP=0x{sim['eip']:08X}  {sim['mnemonic']:<12}  "
              f"SIM writes={_fmt_writes(sim['writes'])}  flags={_fmt_flags(sim['flags'])}")
            # Update reg_state from SIM writes
            reg_state.update(sim['writes'])
            continue

        # Check EIP alignment
        eip_match = sim['eip'] == rtl['eip']
        eip_warn  = "" if eip_match else f"  !! EIP MISMATCH (SIM=0x{sim['eip']:08X} RTL=0x{rtl['eip']:08X})"

        # --- Filter no-op RTL write-backs before diffing ---
        # If RTL writes REG=VAL but SIM doesn't, and we already know
        # REG==VAL from previous instructions, suppress that write.
        rtl_writes_filtered = dict(rtl['writes'])
        noop_regs = []
        for reg, val in list(rtl_writes_filtered.items()):
            if reg not in sim['writes'] and reg_state.get(reg) == val:
                noop_regs.append(reg)
                del rtl_writes_filtered[reg]
        noop_suppressed += len(noop_regs)

        # Compare writes (using filtered RTL writes)
        write_diffs = _diff_writes(sim['writes'], rtl_writes_filtered)
        # Compare flags
        flag_diffs  = _diff_flags(sim['flags'], rtl['flags'])

        all_ok = eip_match and not write_diffs and not flag_diffs

        if all_ok:
            passed += 1
            noop_note = ""
            if noop_regs:
                noop_note = f"  (RTL no-op: {','.join(noop_regs)})"
            w(f"[OK ] #{i:04d}  0x{sim['eip']:08X}  {sim['mnemonic']:<12}  "
              f"writes={_fmt_writes(sim['writes'])}  flags={_fmt_flags(sim['flags'])}{noop_note}")
        else:
            failed += 1
            w(f"[ERR] #{i:04d}  0x{sim['eip']:08X}  {sim['mnemonic']:<12}{eip_warn}")
            w(f"       SIM  writes={_fmt_writes(sim['writes'])}  flags={_fmt_flags(sim['flags'])}")
            w(f"       RTL  writes={_fmt_writes(rtl_writes_filtered)}  flags={_fmt_flags(rtl['flags'])}")
            if write_diffs:
                for d in write_diffs:
                    w(f"       *** WRITE DIFF: {d}")
            if flag_diffs:
                for d in flag_diffs:
                    w(f"       *** FLAG  DIFF: {d}")

        # Update reg_state: SIM writes are authoritative; also adopt
        # RTL writes that SIM agrees with (both wrote same reg+val).
        reg_state.update(sim['writes'])
        for reg, val in rtl['writes'].items():
            if reg in sim['writes'] and sim['writes'][reg] == val:
                reg_state[reg] = val

    w("")
    w("=" * 80)
    w(f"  SUMMARY: {passed}/{total} matched  |  {failed} mismatched  "
      f"|  {only_sim} sim-only  |  {only_rtl} rtl-only")
    if noop_suppressed:
        w(f"  ({noop_suppressed} RTL no-op write-backs suppressed)")
    w("=" * 80)

    return failed == 0


def _fmt_writes(w):
    if not w:
        return "none"
    return ",".join(f"{r}=0x{v:08X}" for r, v in sorted(w.items()))


def _fmt_flags(f):
    if not f:
        return "?"
    return " ".join(f"{k}={f.get(k, '?')}" for k in FLAG_NAMES if k in f)


def _diff_writes(sim_w, rtl_w):
    diffs = []
    all_regs = sorted(set(list(sim_w.keys()) + list(rtl_w.keys())))
    for reg in all_regs:
        sv = sim_w.get(reg)
        rv = rtl_w.get(reg)
        if sv is None:
            diffs.append(f"{reg}: SIM=<not written>  RTL=0x{rv:08X}")
        elif rv is None:
            diffs.append(f"{reg}: SIM=0x{sv:08X}  RTL=<not written>")
        elif sv != rv:
            diffs.append(f"{reg}: SIM=0x{sv:08X}  RTL=0x{rv:08X}")
    return diffs


def _diff_flags(sim_f, rtl_f):
    diffs = []
    if not sim_f or not rtl_f:
        return diffs   # can't compare if one side is missing
    for fl in FLAG_NAMES:
        sv = sim_f.get(fl)
        rv = rtl_f.get(fl)
        if sv is None or rv is None:
            continue
        if sv != rv:
            diffs.append(f"{fl}: SIM={sv}  RTL={rv}")
    return diffs


# ---------------------------------------------------------------------------
# Also write normalized trace files (so you can plain `diff` them)
# ---------------------------------------------------------------------------
def write_normalized(records, path):
    """Write records to a normalized trace file (sim and RTL use same format)."""
    with open(path, 'w') as f:
        for r in records:
            writes_str = _fmt_writes(r['writes'])
            flags_str  = _fmt_flags(r['flags'])
            f.write(f"0x{r['eip']:08X}  {r['mnemonic']:<12}  {writes_str:<48}  {flags_str}\n")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def main():
    p = argparse.ArgumentParser(
        description="Compare Python sim trace against RTL pipeline_debug.log"
    )
    p.add_argument("--sim", required=True, metavar="SIM_TRACE",
                   help="Sim trace file from sim.py --trace-file")
    p.add_argument("--rtl", required=True, metavar="RTL_LOG",
                   help="RTL pipeline_debug.log from testbench")
    p.add_argument("--out", metavar="REPORT",
                   help="Write comparison report to file (default: stdout)")
    p.add_argument("--norm-sim", metavar="PATH",
                   help="Write normalized SIM trace (for plain diff)")
    p.add_argument("--norm-rtl", metavar="PATH",
                   help="Write normalized RTL trace (for plain diff)")
    args = p.parse_args()

    print(f"Parsing sim trace: {args.sim}")
    sim_records = parse_sim_trace(args.sim)
    print(f"  → {len(sim_records)} instructions")

    print(f"Parsing RTL log:   {args.rtl}")
    rtl_records = parse_rtl_log(args.rtl)
    print(f"  → {len(rtl_records)} commits")

    if args.norm_sim:
        write_normalized(sim_records, args.norm_sim)
        print(f"Normalized SIM trace → {args.norm_sim}")
    if args.norm_rtl:
        write_normalized(rtl_records, args.norm_rtl)
        print(f"Normalized RTL trace → {args.norm_rtl}")

    if args.out:
        with open(args.out, 'w') as f:
            ok = compare(sim_records, rtl_records, out=f)
        print(f"Report written to {args.out}")
    else:
        ok = compare(sim_records, rtl_records, out=sys.stdout)

    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
