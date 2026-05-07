#!/usr/bin/env python3
"""
Parse a Synopsys fanout_check log (e.g. check.log) into a readable report.

Usage:
    python3 parse_check_log.py <input.log> [output.log]

If output.log is omitted, writes to <input>.parsed.

The parser:
  - Drops Synopsys preamble / file-compilation noise.
  - Captures Error/Warning lines from the compile (VER-xxx) separately.
  - Parses the fanout_check section (INFO / WARNING / VIOLATION entries,
    each followed by a `  driver: ...` line).
  - Groups identical violations and warnings, sorts by fanout (desc),
    and prints unique driver paths under each group.
  - Adds a per-module summary so you can see which submodule has the
    most violations.
"""

import re
import sys
from collections import Counter, defaultdict


# ---------- regexes ----------------------------------------------------------

# Compile-time errors/warnings from Presto, e.g.
#   "Error:  /path/file.v:21: ... (VER-943)"
RE_COMPILE_MSG = re.compile(r"^(Error|Warning):\s+(.*)$")

# fanout_check entries — first line of each record.
# Examples:
#   INFO: wire 'clk' (fanout=88) is a clock signal — buffer rule not applied (...)
#   WARNING: 'wb_latches_ST_PADDR_0[14]' (fanout=6: 5 internal + 1 output ports) — driver is external...
#   VIOLATION: wire 'out' (fanout=10) driven by mux2$, expected bufferH16$ or bufferHInv16$
RE_ENTRY = re.compile(
    r"""^(?P<sev>INFO|WARNING|VIOLATION):\s+
        (?:wire\s+)?'(?P<wire>[^']+)'\s+
        \(fanout=(?P<fanout>\d+)(?P<fanout_extra>[^)]*)\)\s*
        (?P<rest>.*)$""",
    re.VERBOSE,
)

RE_DRIVER = re.compile(r"^\s+driver:\s+(?P<path>.*)$")

# Pull "inst(module)" hops out of the driver path so we can attribute
# violations to a parent instance.
# Path looks like: "(WB) -> stq_inst_0(ST_Q) -> u_valid_pop(and2_N$_WIDTH1) -> ..."
RE_INST_HOP = re.compile(r"(\w+)\(([^)]+)\)")

# Final summary line emitted by fanout_check.
RE_SUMMARY = re.compile(
    r"fanout_check:\s+analyzed\s+(\d+)\s+high-fanout nets\s+\S+\s+"
    r"(\d+)\s+violations,\s+(\d+)\s+warnings,\s+(\d+)\s+infos,\s+(\d+)\s+ok"
)


# ---------- data type --------------------------------------------------------

class Entry(object):
    __slots__ = ("severity", "wire", "fanout", "fanout_extra", "rest", "driver")

    def __init__(self, severity, wire, fanout, fanout_extra, rest, driver=""):
        self.severity = severity
        self.wire = wire
        self.fanout = fanout
        self.fanout_extra = fanout_extra
        self.rest = rest
        self.driver = driver

    def group_key(self):
        return (self.severity, self.fanout, self.fanout_extra.strip(), self.rest.strip())


# ---------- parsing ----------------------------------------------------------

def parse(path):
    compile_msgs = []
    entries = []
    summary = None
    top_design = None

    with open(path) as f:
        lines = f.readlines()

    i = 0
    while i < len(lines):
        line = lines[i].rstrip("\n")

        if line.startswith("Current design is '"):
            # take the latest update — the early one (from lib_header) is
            # not the user's top design.
            m = re.search(r"Current design is '([^']+)'", line)
            if m:
                top_design = m.group(1)

        m = RE_COMPILE_MSG.match(line)
        if m:
            sev, body = m.group(1), m.group(2)
            if "Cannot use command line editor" not in body:
                compile_msgs.append("{0}: {1}".format(sev, body))
            i += 1
            continue

        m = RE_ENTRY.match(line)
        if m:
            entry = Entry(
                severity=m.group("sev"),
                wire=m.group("wire"),
                fanout=int(m.group("fanout")),
                fanout_extra=m.group("fanout_extra"),
                rest=m.group("rest"),
            )
            if i + 1 < len(lines):
                dm = RE_DRIVER.match(lines[i + 1].rstrip("\n"))
                if dm:
                    entry.driver = dm.group("path")
                    i += 2
                else:
                    i += 1
            else:
                i += 1
            entries.append(entry)
            continue

        m = RE_SUMMARY.match(line)
        if m:
            summary = line.strip()
            i += 1
            continue

        i += 1

    return {
        "top_design": top_design,
        "compile_msgs": compile_msgs,
        "entries": entries,
        "summary": summary,
    }


# ---------- reporting --------------------------------------------------------

def parent_inst_from_driver(driver):
    """
    Return the second hop of the path ("stq_inst_0(ST_Q)") which is usually
    the most useful "where does this live" attribution. The first hop is the
    top design. Falls back to the whole path if that fails.
    """
    hops = RE_INST_HOP.findall(driver)
    if len(hops) >= 2:
        inst, mod = hops[1]
        return "{0}({1})".format(inst, mod)
    return driver


def fmt_fanout(e):
    if e.fanout_extra.strip():
        return "fanout={0}{1}".format(e.fanout, e.fanout_extra)
    return "fanout={0}".format(e.fanout)


def render(parsed, src_name):
    out = []
    add = out.append
    bar = "=" * 80

    add(bar)
    add("FANOUT CHECK REPORT — {0}".format(src_name))
    add(bar)
    if parsed["top_design"]:
        add("Top design : {0}".format(parsed["top_design"]))
    if parsed["summary"]:
        add("Summary    : {0}".format(parsed["summary"]))
    add("")

    if parsed["compile_msgs"]:
        add(bar)
        add("COMPILE MESSAGES ({0})".format(len(parsed["compile_msgs"])))
        add(bar)
        for m in parsed["compile_msgs"]:
            add(m)
        add("")

    entries = parsed["entries"]
    by_sev = defaultdict(list)
    for e in entries:
        by_sev[e.severity].append(e)

    # ---- INFOS -------------------------------------------------------------
    infos = by_sev.get("INFO", [])
    if infos:
        add(bar)
        add("INFOS ({0})".format(len(infos)))
        add(bar)
        for e in sorted(infos, key=lambda x: -x.fanout):
            add("[{0}]  {1}  {2}".format(fmt_fanout(e), e.wire, e.rest))
            if e.driver:
                add("    driver: {0}".format(e.driver))
        add("")

    # ---- VIOLATIONS --------------------------------------------------------
    viols = by_sev.get("VIOLATION", [])
    if viols:
        add(bar)
        add("VIOLATIONS ({0}) — grouped, highest fanout first".format(len(viols)))
        add(bar)
        groups = defaultdict(list)
        for e in viols:
            groups[e.group_key()].append(e)

        ordered = sorted(
            groups.items(),
            key=lambda kv: (-kv[0][1], -len(kv[1])),
        )
        for key, members in ordered:
            sev, fanout, extra, rest = key
            head = "[fanout={0}{1}]".format(fanout, (" " + extra) if extra else "")
            plural = "s" if len(members) != 1 else ""
            add("{0} {1}  ({2} occurrence{3})".format(head, rest, len(members), plural))
            seen = set()
            for m in members:
                if m.driver and m.driver not in seen:
                    seen.add(m.driver)
                    add("    {0}".format(m.driver))
            add("")

    # ---- WARNINGS ----------------------------------------------------------
    warns = by_sev.get("WARNING", [])
    if warns:
        add(bar)
        add("WARNINGS ({0}) — grouped, highest fanout first".format(len(warns)))
        add(bar)
        groups = defaultdict(list)
        for e in warns:
            # collapse on severity+fanout+message — fold foo[14], foo[13], ...
            groups[(e.severity, e.fanout, e.fanout_extra.strip(), e.rest.strip())].append(e)

        ordered = sorted(
            groups.items(),
            key=lambda kv: (-kv[0][1], -len(kv[1])),
        )
        for key, members in ordered:
            sev, fanout, extra, rest = key
            head = "[fanout={0}{1}]".format(fanout, (" " + extra) if extra else "")
            plural = "s" if len(members) != 1 else ""
            add("{0} {1}  ({2} occurrence{3})".format(head, rest, len(members), plural))
            wires = sorted({m.wire for m in members})
            shown = wires[:12]
            for w in shown:
                add("    {0}".format(w))
            if len(wires) > len(shown):
                add("    ... and {0} more".format(len(wires) - len(shown)))
            add("")

    # ---- module attribution (violations only) ------------------------------
    if viols:
        add(bar)
        add("VIOLATIONS BY PARENT INSTANCE (top 20)")
        add(bar)
        counter = Counter()
        for e in viols:
            counter[parent_inst_from_driver(e.driver)] += 1
        for inst, n in counter.most_common(20):
            add("  {0:5d}  {1}".format(n, inst))
        add("")

    return "\n".join(out) + "\n"


# ---------- main -------------------------------------------------------------

def main(argv):
    if len(argv) < 2:
        sys.stderr.write(__doc__)
        return 2

    src = argv[1]
    try:
        with open(src):
            pass
    except IOError:
        sys.stderr.write("error: input file not found: {0}\n".format(src))
        return 1

    dst = argv[2] if len(argv) > 2 else src + ".parsed"

    parsed = parse(src)
    report = render(parsed, src.split("/")[-1])
    with open(dst, "w") as f:
        f.write(report)

    n_viol = sum(1 for e in parsed["entries"] if e.severity == "VIOLATION")
    print("wrote {0}  ({1} entries, {2} violations)".format(
        dst, len(parsed["entries"]), n_viol))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
