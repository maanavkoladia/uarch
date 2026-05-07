#!/usr/bin/env python3
"""
merge_dumps.py  --  merge regdump, flagdump, and storedump into one log
                    matched by instruction-commit order.

Usage:
    python3 merge_dumps.py --reg REG --flags FLAGS --store STORE --out OUT

Matching strategy
-----------------
regdump and flagdump both fire on every 'exeforwards' event so they are
always the same length and match positionally (entry[0] with entry[0], etc.).

storedump is a strict subset: it only fires when the instruction also has
ST_OP set.  We match stores to their instruction by keeping a per-EIP FIFO
queue so that repeated EIPs (loops) are handled correctly -- stores for a
given EIP are consumed in the same order they were written to the file.
"""

import argparse
import re
from collections import defaultdict, deque


def parse_dump(path, header_re):
    """Return ordered list of (eip_int, [lines]) from a dump file.

    header_re must match the first line of each entry and capture the hex
    EIP value in group 1.  Returns [] if the file is missing.
    """
    entries = []
    current_eip = None
    current_lines = []
    try:
        with open(path) as f:
            raw = f.readlines()
    except FileNotFoundError:
        return []

    for line in raw:
        line = line.rstrip('\n')
        m = re.match(header_re, line)
        if m:
            if current_eip is not None:
                entries.append((current_eip, current_lines))
            current_eip = int(m.group(1), 16)
            current_lines = [line]
        elif current_eip is not None:
            current_lines.append(line)

    if current_eip is not None:
        entries.append((current_eip, current_lines))

    return entries


def main():
    ap = argparse.ArgumentParser(
        description='Merge regdump / flagdump / storedump into one file.')
    ap.add_argument('--reg',   required=True, help='RTL regdump log')
    ap.add_argument('--flags', required=True, help='RTL flagdump log')
    ap.add_argument('--store', required=True, help='RTL storedump log')
    ap.add_argument('--out',   required=True, help='Output merged log')
    args = ap.parse_args()

    REG_HDR   = r'^\[REGFILE DUMP\]\s+EIP=0x([0-9a-fA-F]+)'
    FLAG_HDR  = r'^\[FLAG DUMP\]\s+EIP=0x([0-9a-fA-F]+)'
    STORE_HDR = r'^\[STORE DUMP\]\s+EIP=0x([0-9a-fA-F]+)'

    reg_entries   = parse_dump(args.reg,   REG_HDR)
    flag_entries  = parse_dump(args.flags, FLAG_HDR)
    store_entries = parse_dump(args.store, STORE_HDR)

    # Per-EIP FIFO of store entries -- consumed in commit order.
    store_q = defaultdict(deque)
    for eip, lines in store_entries:
        store_q[eip].append(lines)

    # reg and flag should be the same length; pad the shorter one if not.
    max_len = max(len(reg_entries), len(flag_entries))
    reg_pad  = reg_entries  + [(None, [])] * (max_len - len(reg_entries))
    flag_pad = flag_entries + [(None, [])] * (max_len - len(flag_entries))

    with open(args.out, 'w') as out:
        for idx, ((r_eip, r_lines), (f_eip, f_lines)) in \
                enumerate(zip(reg_pad, flag_pad)):

            eip = r_eip if r_eip is not None else f_eip
            eip_str = f'0x{eip:08x}' if eip is not None else '0x????????'

            out.write('=' * 64 + '\n')
            out.write(f'COMMIT #{idx}   EIP = {eip_str}\n')
            out.write('=' * 64 + '\n')

            # ---- registers ----
            for line in r_lines:
                out.write(line + '\n')

            # ---- flags ----
            for line in f_lines:
                out.write(line + '\n')

            # ---- store (only present for ST_OP instructions) ----
            if eip is not None and store_q[eip]:
                s_lines = store_q[eip].popleft()
                for line in s_lines:
                    out.write(line + '\n')

            out.write('\n')

    # Warn about any unmatched store entries.
    leftover = sum(len(q) for q in store_q.values())
    if leftover:
        print(f'WARNING: {leftover} store entries could not be matched '
              f'(no corresponding regdump entry for that EIP).')

    print(f'Merged {max_len} commit(s) -> {args.out}')


if __name__ == '__main__':
    main()
