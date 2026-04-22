"""
sv2rtl.py  <input.sv>  <output.sv>

Converts a restricted behavioural SystemVerilog file to structural SV
using parametrized primitive cells.

─────────────────────────────────────────────────────────────────
Input grammar restrictions (tool will die if violated):
  • Only 'logic' signal type (no structs, no arrays)
  • One register driven per always_ff block
  • All always_ff bodies use begin/end (no bare single-line if)
  • No for/while loops
  • No bit shifts (<<, >>)
  • No inline ternary (?:) inside always_ff
  • No submodule instantiation
  • No generate blocks
  • Combinational logic via 'assign' only (no always_comb)
  • Parameters allowed, resolved at elaboration
─────────────────────────────────────────────────────────────────

Primitive port conventions assumed:
  inv_N$   (.a(in),          .y(out))
  and_N$   (.a(a), .b(b),   .y(out))
  or_N$    (.a(a), .b(b),   .y(out))
  xor_N$   (.a(a), .b(b),   .y(out))
  add_N$   (.a(a), .b(b),   .s(sum),  .cout(carry))
  sub_N$   (.a(a), .b(b),   .d(diff), .bout(borrow))
  eq_N$    (.a(a), .b(b),   .eq(out))
  cmp_N$   (.a(a), .b(b),   .lt(lt),  .gt(gt), .lte(lte), .gte(gte))
  mux_N$   (.sel(s),.a(a),  .b(b),    .y(out))
  reg_N$   (.clk(c),.rst(r),.d(d),    .q(out))

  N is always the bit-width of the data operands.
  1-bit signals use N=1.

─────────────────────────────────────────────────────────────────
Pipeline:
  Stage 1 : Lex                      -> <stem>_tokens.txt
  Stage 2 : Parse                    -> <stem>_ast.txt
  Stage 3 : Elaborate                -> <stem>_symbols.txt
  Stage 4 : Assign lowering          -> <stem>_netlist_comb.txt
  Stage 5 : FF flattening            -> <stem>_ff_chains.txt
  Stage 6 : FF lowering              -> <stem>_netlist_ff.txt
  Stage 7 : Netlist emit             -> <output.sv>
"""

import sys, os, re
from dataclasses import dataclass, field
from typing      import Any, Optional

BANNER = "=" * 72

def log(msg=""): print(msg)
def die(msg):
    print(f"\nFATAL: {msg}", file=sys.stderr)
    sys.exit(1)
def stage(n, title):
    log(); log(f"{'─'*72}"); log(f"  Stage {n}: {title}"); log(f"{'─'*72}")

# ─────────────────────────────────────────────────────────────────────────────
# 0.  CLI
# ─────────────────────────────────────────────────────────────────────────────
if len(sys.argv) != 3:
    die("Usage: python3 sv2rtl.py <input.sv> <output.sv>")

sv_in  = sys.argv[1]
sv_out = sys.argv[2]
if not os.path.isfile(sv_in):
    die(f"Input file not found: {sv_in}")

base = os.path.splitext(sv_in)[0]
stem = os.path.splitext(os.path.basename(sv_in))[0]

p_tokens   = base + "_tokens.txt"
p_ast      = base + "_ast.txt"
p_symbols  = base + "_symbols.txt"
p_comb     = base + "_netlist_comb.txt"
p_ff_chains= base + "_ff_chains.txt"
p_ff_net   = base + "_netlist_ff.txt"

log(BANNER)
log(f"  sv2rtl pipeline -- {stem}")
log(BANNER)
log(f"  Input  : {sv_in}")
log(f"  Output : {sv_out}")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 1: Lex
# ─────────────────────────────────────────────────────────────────────────────
stage(1, "Lex")

with open(sv_in) as f:
    src = f.read()

# Strip line comments and block comments
src_clean = re.sub(r'//[^\n]*', '', src)
src_clean = re.sub(r'/\*.*?\*/', '', src_clean, flags=re.DOTALL)

TOKEN_SPEC = [
    ('NUMBER',   r"\d+'[bBoOdDhH][0-9a-fA-F_xXzZ]+|\d+"),
    ('ID',       r'[A-Za-z_][A-Za-z0-9_$]*'),
    ('OP2',      r'==|!=|<=|>=|&&|\|\||<<|>>|~\^|\^~|~&|~\|'),
    ('OP1',      r'[+\-*/&|^~!<>@()[\]{};:,#=.]'),
    ('SKIP',     r'[ \t\n\r]+'),
]
tok_re = re.compile('|'.join(f'(?P<{n}>{p})' for n, p in TOKEN_SPEC))

tokens = []
for m in tok_re.finditer(src_clean):
    kind = m.lastgroup
    val  = m.group()
    if kind == 'SKIP':
        continue
    tokens.append((kind, val))

# Write token file
with open(p_tokens, 'w') as f:
    f.write(f"# Tokens for {stem}\n")
    for i, (k, v) in enumerate(tokens):
        f.write(f"  {i:>5}  {k:<10}  {v}\n")

log(f"  {len(tokens)} tokens  ->  {p_tokens}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2: Parse
# ─────────────────────────────────────────────────────────────────────────────
stage(2, "Parse")

# ── AST node dataclasses ─────────────────────────────────────────────────────

@dataclass
class PortDecl:
    name: str; direction: str; width: Any  # width = (hi_expr, lo_expr) or None

@dataclass
class ParamDecl:
    name: str; value: Any

@dataclass
class LogicDecl:
    name: str; width: Any  # (hi_expr, lo_expr) or None -> 1 bit

@dataclass
class AssignStmt:
    lhs: str; rhs: Any  # continuous assign

@dataclass
class AlwaysFF:
    clk: str; body: Any  # body = IfChain

@dataclass
class IfChain:
    """Represents if / else-if / else inside always_ff.
    arms = list of (condition_expr, [stmts])
    else_body = [stmts] or None
    """
    arms: list
    else_body: Any

@dataclass
class NBAssign:
    lhs: str; rhs: Any  # non-blocking

@dataclass
class BinOp:
    op: str; left: Any; right: Any

@dataclass
class UnaryOp:
    op: str; operand: Any

@dataclass
class Identifier:
    name: str

@dataclass
class Number:
    raw: str; width: int; value: int

@dataclass
class PartSelect:
    name: str; hi: Any; lo: Any

@dataclass
class Module:
    name: str
    params: list
    ports:  list
    decls:  list   # LogicDecl
    assigns: list  # AssignStmt
    always_ffs: list  # AlwaysFF

# ── Parser ───────────────────────────────────────────────────────────────────

class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.pos    = 0

    def peek(self, offset=0):
        i = self.pos + offset
        return self.tokens[i] if i < len(self.tokens) else ('EOF', '')

    def consume(self, expected_val=None, expected_kind=None):
        kind, val = self.peek()
        if expected_val and val != expected_val:
            die(f"Parse: expected '{expected_val}' got '{val}' "
                f"(token {self.pos}, context: {self.tokens[max(0,self.pos-3):self.pos+3]})")
        if expected_kind and kind != expected_kind:
            die(f"Parse: expected kind '{expected_kind}' got '{kind}' (val='{val}')")
        self.pos += 1
        return val

    def at(self, val):
        return self.peek()[1] == val

    def at_kind(self, kind):
        return self.peek()[0] == kind

    # ── Number parsing ───────────────────────────────────────────────────────
    def parse_number(self, raw):
        raw = raw.replace('_', '')
        m = re.match(r"(\d+)'([bBoOdDhH])([0-9a-fA-F]+)", raw)
        if m:
            w   = int(m.group(1))
            fmt = m.group(2).lower()
            val_str = m.group(3)
            base_map = {'b':2,'o':8,'d':10,'h':16}
            return Number(raw, w, int(val_str, base_map[fmt]))
        # unsized integer
        return Number(raw, 32, int(raw))

    # ── Expression parsing (recursive descent, Pratt-style) ──────────────────
    PREC = {
        '||':1, '&&':2,
        '|':3, '^':4, '~^':4, '^~':4,
        '&':5,
        '==':6, '!=':6,
        '<':7, '>':7, '<=':7, '>=':7,
        '+':8, '-':8,
        '*':9, '/':9, '%':9,
    }

    def parse_expr(self, min_prec=0):
        left = self.parse_unary()
        while True:
            _, op = self.peek()
            if op not in self.PREC or self.PREC[op] <= min_prec:
                break
            prec = self.PREC[op]
            self.consume(op)
            right = self.parse_expr(prec)
            left  = BinOp(op, left, right)
        return left

    def parse_unary(self):
        _, val = self.peek()
        if val in ('~', '!', '-', '&', '|', '^', '~&', '~|', '~^'):
            self.consume(val)
            operand = self.parse_unary()
            return UnaryOp(val, operand)
        return self.parse_primary()

    def parse_primary(self):
        kind, val = self.peek()

        # parenthesised expression
        if val == '(':
            self.consume('(')
            e = self.parse_expr()
            self.consume(')')
            return e

        # number literal
        if kind == 'NUMBER':
            self.consume()
            return self.parse_number(val)

        # identifier — may be followed by [hi:lo] or [idx]
        if kind == 'ID':
            self.consume()
            name = val
            if self.at('['):
                self.consume('[')
                idx_or_hi = self.parse_expr()
                if self.at(':'):
                    self.consume(':')
                    lo = self.parse_expr()
                    self.consume(']')
                    return PartSelect(name, idx_or_hi, lo)
                self.consume(']')
                # single bit select — treat as PartSelect(n, i, i)
                return PartSelect(name, idx_or_hi, idx_or_hi)
            return Identifier(name)

        die(f"Parse: unexpected token in expression: kind={kind} val='{val}' "
            f"at pos {self.pos}")

    # ── Width expression (inside []) ─────────────────────────────────────────
    def parse_width_expr(self):
        """Returns (hi_expr, lo_expr) or None."""
        if not self.at('['):
            return None
        self.consume('[')
        hi = self.parse_expr()
        self.consume(':')
        lo = self.parse_expr()
        self.consume(']')
        return (hi, lo)

    # ── Statement parsers ────────────────────────────────────────────────────
    def parse_nb_assign(self):
        kind, name = self.peek()
        if kind != 'ID':
            die(f"Parse: expected LHS identifier, got '{name}'")
        self.consume()
        self.consume('<=')
        rhs = self.parse_expr()
        self.consume(';')
        return NBAssign(name, rhs)

    def parse_if_chain(self):
        """Parse if / else-if / else chain. Returns IfChain."""
        arms      = []
        else_body = None

        self.consume('if')
        self.consume('(')
        cond = self.parse_expr()
        self.consume(')')
        self.consume('begin')
        stmts = []
        while not self.at('end'):
            stmts.append(self.parse_nb_assign())
        self.consume('end')
        arms.append((cond, stmts))

        while self.at('else'):
            self.consume('else')
            if self.at('if'):
                self.consume('if')
                self.consume('(')
                cond2 = self.parse_expr()
                self.consume(')')
                self.consume('begin')
                stmts2 = []
                while not self.at('end'):
                    stmts2.append(self.parse_nb_assign())
                self.consume('end')
                arms.append((cond2, stmts2))
            else:
                # bare else
                self.consume('begin')
                stmts_e = []
                while not self.at('end'):
                    stmts_e.append(self.parse_nb_assign())
                self.consume('end')
                else_body = stmts_e
                break

        return IfChain(arms, else_body)

    # ── Top-level module parse ───────────────────────────────────────────────
    def parse_module(self):
        self.consume('module')
        name = self.consume(expected_kind='ID')
        params = []

        # optional parameter list
        if self.at('#'):
            self.consume('#')
            self.consume('(')
            while not self.at(')'):
                self.consume('parameter')
                pname = self.consume(expected_kind='ID')
                self.consume('=')
                pval  = self.parse_expr()
                params.append(ParamDecl(pname, pval))
                if self.at(','):
                    self.consume(',')
            self.consume(')')

        # port list
        self.consume('(')
        ports = []
        while not self.at(')'):
            _, kw = self.peek()
            if kw in ('input', 'output', 'inout'):
                direction = self.consume()
                if direction == 'inout':
                    die("'inout' ports are not supported.")
                # consume 'logic' keyword if present
                if self.peek()[1] == 'logic':
                    self.consume('logic')
                width = self.parse_width_expr()
                pname = self.consume(expected_kind='ID')
                ports.append(PortDecl(pname, direction, width))
            if self.at(','):
                self.consume(',')
        self.consume(')')
        self.consume(';')

        # module body
        decls      = []
        assigns    = []
        always_ffs = []

        while not self.at('endmodule'):
            _, kw = self.peek()

            if kw == 'logic':
                self.consume('logic')
                width = self.parse_width_expr()
                dname = self.consume(expected_kind='ID')
                self.consume(';')
                decls.append(LogicDecl(dname, width))

            elif kw == 'assign':
                self.consume('assign')
                lhs = self.consume(expected_kind='ID')
                self.consume('=')
                rhs = self.parse_expr()
                self.consume(';')
                assigns.append(AssignStmt(lhs, rhs))

            elif kw == 'always_ff':
                self.consume('always_ff')
                self.consume('@')
                self.consume('(')
                self.consume('posedge')
                clk_name = self.consume(expected_kind='ID')
                self.consume(')')
                self.consume('begin')
                body = self.parse_if_chain()
                self.consume('end')
                always_ffs.append(AlwaysFF(clk_name, body))

            elif kw == 'always_latch':
                die("'always_latch' is not supported — latches cannot be inferred.")

            elif kw == 'always_comb':
                die("'always_comb' is not supported — use 'assign' for combinational logic.")

            elif kw in ('parameter', 'localparam'):
                self.consume()
                pname = self.consume(expected_kind='ID')
                self.consume('=')
                pval  = self.parse_expr()
                self.consume(';')
                params.append(ParamDecl(pname, pval))

            else:
                die(f"Parse: unexpected keyword '{kw}' in module body "
                    f"at token {self.pos}")

        self.consume('endmodule')
        return Module(name, params, ports, decls, assigns, always_ffs)

parser = Parser(tokens)
mod    = parser.parse_module()

# ── Write AST dump ───────────────────────────────────────────────────────────
def ast_str(node, indent=0):
    pad = "  " * indent
    if isinstance(node, Module):
        lines = [f"{pad}Module({node.name})"]
        for p in node.params:   lines.append(ast_str(p, indent+1))
        for p in node.ports:    lines.append(ast_str(p, indent+1))
        for d in node.decls:    lines.append(ast_str(d, indent+1))
        for a in node.assigns:  lines.append(ast_str(a, indent+1))
        for ff in node.always_ffs: lines.append(ast_str(ff, indent+1))
        return '\n'.join(lines)
    if isinstance(node, PortDecl):
        return f"{pad}Port({node.direction} {node.name} width={node.width})"
    if isinstance(node, ParamDecl):
        return f"{pad}Param({node.name} = {ast_str(node.value)})"
    if isinstance(node, LogicDecl):
        return f"{pad}Logic({node.name} width={node.width})"
    if isinstance(node, AssignStmt):
        return f"{pad}Assign({node.lhs} = {ast_str(node.rhs)})"
    if isinstance(node, AlwaysFF):
        return f"{pad}AlwaysFF(clk={node.clk})\n{ast_str(node.body, indent+1)}"
    if isinstance(node, IfChain):
        lines = [f"{pad}IfChain"]
        for cond, stmts in node.arms:
            lines.append(f"{pad}  arm cond={ast_str(cond)}")
            for s in stmts: lines.append(ast_str(s, indent+2))
        if node.else_body:
            lines.append(f"{pad}  else")
            for s in node.else_body: lines.append(ast_str(s, indent+2))
        return '\n'.join(lines)
    if isinstance(node, NBAssign):
        return f"{pad}NB({node.lhs} <= {ast_str(node.rhs)})"
    if isinstance(node, BinOp):
        return f"BinOp({node.op}, {ast_str(node.left)}, {ast_str(node.right)})"
    if isinstance(node, UnaryOp):
        return f"UnaryOp({node.op}, {ast_str(node.operand)})"
    if isinstance(node, Identifier):
        return f"Id({node.name})"
    if isinstance(node, Number):
        return f"Num({node.raw}={node.value})"
    if isinstance(node, PartSelect):
        return f"PartSel({node.name}[{ast_str(node.hi)}:{ast_str(node.lo)}])"
    return repr(node)

with open(p_ast, 'w') as f:
    f.write(f"# AST for {stem}\n\n")
    f.write(ast_str(mod))
    f.write('\n')

log(f"  Module   : {mod.name}")
log(f"  Params   : {[p.name for p in mod.params]}")
log(f"  Ports    : {[p.name for p in mod.ports]}")
log(f"  Decls    : {[d.name for d in mod.decls]}")
log(f"  Assigns  : {len(mod.assigns)}")
log(f"  AlwaysFF : {len(mod.always_ffs)}")
log(f"  AST written -> {p_ast}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 3: Elaborate — build symbol table, resolve widths
# ─────────────────────────────────────────────────────────────────────────────
stage(3, "Elaborate")

# Symbol table: name -> dict
symbols = {}

def eval_const(expr, syms):
    """Evaluate a constant expression (params + integer arithmetic) to int."""
    if isinstance(expr, Number):
        return expr.value
    if isinstance(expr, Identifier):
        if expr.name in syms and syms[expr.name].get('const') is not None:
            return syms[expr.name]['const']
        die(f"Elaborate: cannot resolve '{expr.name}' as a constant.")
    if isinstance(expr, BinOp):
        L = eval_const(expr.left,  syms)
        R = eval_const(expr.right, syms)
        op = expr.op
        ops = {'+':lambda a,b:a+b, '-':lambda a,b:a-b,
               '*':lambda a,b:a*b, '/':lambda a,b:a//b,
               '%':lambda a,b:a%b}
        if op in ops: return ops[op](L, R)
        die(f"Elaborate: unsupported const op '{op}'")
    if isinstance(expr, UnaryOp):
        V = eval_const(expr.operand, syms)
        if expr.op == '-': return -V
        die(f"Elaborate: unsupported const unary '{expr.op}'")
    die(f"Elaborate: cannot evaluate as constant: {expr}")

def resolve_width(width_spec, syms):
    """Convert (hi_expr, lo_expr) or None to integer bit-count."""
    if width_spec is None:
        return 1
    hi = eval_const(width_spec[0], syms)
    lo = eval_const(width_spec[1], syms)
    return hi - lo + 1

# Parameters first (they may be needed to resolve port/decl widths)
for p in mod.params:
    v = eval_const(p.value, symbols)
    symbols[p.name] = {'kind':'param', 'width':32, 'const':v, 'direction':None}
    log(f"  param {p.name} = {v}")

# Ports
for p in mod.ports:
    w = resolve_width(p.width, symbols)
    symbols[p.name] = {'kind':'port', 'width':w, 'direction':p.direction, 'const':None}
    log(f"  port  {p.direction:<7} {p.name:<25} [{w-1}:0]")

# Logic decls
for d in mod.decls:
    w = resolve_width(d.width, symbols)
    symbols[d.name] = {'kind':'logic', 'width':w, 'direction':None, 'const':None}
    log(f"  logic          {d.name:<25} [{w-1}:0]")

def is_unsized_literal(expr):
    """True if expr is a bare integer literal with no explicit width (e.g. 0, 1, 255)."""
    return isinstance(expr, Number) and re.match(r'^\d+$', expr.raw) is not None

def infer_width(expr, syms):
    """Infer the bit-width of an expression.
    Unsized literals return 0 as a sentinel; the BinOp case then uses max()
    so the typed operand on the other side determines the real width.
    """
    if isinstance(expr, Number):
        return 0 if is_unsized_literal(expr) else expr.width
    if isinstance(expr, Identifier):
        if expr.name not in syms:
            die(f"Elaborate: unknown signal '{expr.name}'")
        return syms[expr.name]['width']
    if isinstance(expr, PartSelect):
        if expr.name not in syms:
            die(f"Elaborate: unknown signal '{expr.name}' in part-select")
        hi = eval_const(expr.hi, syms)
        lo = eval_const(expr.lo, syms)
        return hi - lo + 1
    if isinstance(expr, UnaryOp):
        op = expr.op
        if op in ('&','|','^','~&','~|','~^','!'): return 1
        return infer_width(expr.operand, syms)
    if isinstance(expr, BinOp):
        op = expr.op
        if op in ('==','!=','<','>','<=','>=','&&','||'): return 1
        lw = infer_width(expr.left,  syms)
        rw = infer_width(expr.right, syms)
        return max(lw, rw)
    die(f"Elaborate: cannot infer width for {expr}")

with open(p_symbols, 'w') as f:
    f.write(f"# Symbol table for {stem}\n\n")
    f.write(f"  {'name':<25} {'kind':<8} {'direction':<10} {'width'}\n")
    f.write("  " + "-"*55 + "\n")
    for name, info in symbols.items():
        f.write(f"  {name:<25} {info['kind']:<8} {str(info['direction']):<10} {info['width']}\n")

log(f"\n  {len(symbols)} symbols resolved  ->  {p_symbols}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 4: Assign lowering — combinational expressions -> netlist primitives
# ─────────────────────────────────────────────────────────────────────────────
stage(4, "Assign lowering (combinational)")

# Netlist: list of dicts
# {'kind':'inst',   'prim':str, 'inst':str, 'ports':{portname:wirename}}
# {'kind':'assign', 'dst':str,  'src':str}   (wire alias / rewire)
netlist   = []
wire_widths = {}  # wire_name -> int width

inst_counter = [0]

def fresh(prefix):
    inst_counter[0] += 1
    return f"_{prefix}_{inst_counter[0]-1}"

def add_wire(name, width):
    wire_widths[name] = width

def emit_inst(prim, ports, width=None):
    """Create a primitive instance, return the output wire name."""
    iname = fresh(prim.replace('$','').replace('_',''))
    netlist.append({'kind':'inst', 'prim':prim, 'inst':iname, 'ports':ports})
    return iname

def lower_expr(expr, ctx_width=None):
    """
    Recursively lower an expression to netlist primitives.
    Returns the name of the wire carrying the result.

    ctx_width: the bit-width expected by the surrounding context (used to
               resolve unsized integer literals to the right width).
    """
    # ── Identifier ───────────────────────────────────────────────────────────
    if isinstance(expr, Identifier):
        return expr.name

    # ── Number (constant) ────────────────────────────────────────────────────
    if isinstance(expr, Number):
        # Unsized literals (bare integers like 0, 1) inherit context width.
        # Explicitly-sized literals (4'b1010, 8'hFF) keep their own width.
        w = ctx_width if (is_unsized_literal(expr) and ctx_width is not None) else expr.width
        cname = fresh("const")
        add_wire(cname, w)
        netlist.append({'kind':'const', 'dst':cname, 'value':expr.value,
                        'width':w, 'raw':expr.raw})
        return cname

    # ── Part select ──────────────────────────────────────────────────────────
    if isinstance(expr, PartSelect):
        hi = eval_const(expr.hi, symbols)
        lo = eval_const(expr.lo, symbols)
        w  = hi - lo + 1
        src_w = symbols[expr.name]['width']
        # Trivial: full width — just return the signal name
        if hi == src_w - 1 and lo == 0:
            return expr.name
        # Partial: emit a slice-assign wire
        wname = fresh("slice")
        add_wire(wname, w)
        netlist.append({'kind':'slice', 'dst':wname, 'src':expr.name,
                        'hi':hi, 'lo':lo, 'width':w})
        return wname

    # ── Unary ────────────────────────────────────────────────────────────────
    if isinstance(expr, UnaryOp):
        op  = expr.op
        aw  = lower_expr(expr.operand, ctx_width)
        w   = infer_width(expr.operand, symbols)

        if op == '~':
            out = fresh("inv")
            add_wire(out, w)
            emit_inst(f"inv_{w}$", {'a':aw, 'y':out})
            return out

        if op == '!':
            # OR-reduce then invert
            if w == 1:
                out = fresh("inv")
                add_wire(out, 1)
                emit_inst("inv_1$", {'a':aw, 'y':out})
                return out
            red = fresh("orred")
            add_wire(red, 1)
            emit_inst(f"or_{w}$", {'a':aw, 'b':aw, 'y':red})  # placeholder; see note
            # Actually: reduction — use or_N$ with both ports same? No.
            # Use a dedicated reduction: emit as a comment-flagged assign for now.
            # For a true OR-reduction we need an OR tree.
            netlist.pop()  # remove placeholder
            netlist.append({'kind':'reduction', 'op':'|', 'dst':red, 'src':aw, 'width':w})
            inv_out = fresh("inv")
            add_wire(inv_out, 1)
            emit_inst("inv_1$", {'a':red, 'y':inv_out})
            return inv_out

        if op in ('&','|','^','~&','~|','~^'):
            base_op = op.lstrip('~')
            red = fresh(f"{base_op}red")
            add_wire(red, 1)
            netlist.append({'kind':'reduction', 'op':base_op, 'dst':red, 'src':aw, 'width':w})
            if op.startswith('~'):
                inv_out = fresh("inv")
                add_wire(inv_out, 1)
                emit_inst("inv_1$", {'a':red, 'y':inv_out})
                return inv_out
            return red

        if op == '-':
            # unary minus: 0 - a
            zero = fresh("const")
            add_wire(zero, w)
            netlist.append({'kind':'const', 'dst':zero, 'value':0, 'width':w, 'raw':f"{w}'d0"})
            bout = fresh("bout")
            out  = fresh("sub")
            add_wire(bout, 1); add_wire(out, w)
            emit_inst(f"sub_{w}$", {'a':zero, 'b':aw, 'd':out, 'bout':bout})
            return out

        die(f"Lower: unsupported unary op '{op}'")

    # ── Binary ───────────────────────────────────────────────────────────────
    if isinstance(expr, BinOp):
        op = expr.op
        if op in ('<<', '>>'):
            die("Bit shifts are not supported (per grammar restrictions).")
        if op in ('*', '/', '%'):
            die(f"Operator '{op}' is not supported (out of scope).")

        lw      = infer_width(expr.left,  symbols)
        rw      = infer_width(expr.right, symbols)
        # Resolve unified width before lowering so unsized literals on
        # either side inherit the correct context width.
        w       = max(lw, rw)
        lw_expr = lower_expr(expr.left,  w)
        rw_expr = lower_expr(expr.right, w)

        # ── Arithmetic ───────────────────────────────────────────────────────
        if op == '+':
            cout = fresh("cout"); out = fresh("add")
            add_wire(cout, 1); add_wire(out, w)
            emit_inst(f"add_{w}$", {'a':lw_expr, 'b':rw_expr, 's':out, 'cout':cout})
            return out

        if op == '-':
            bout = fresh("bout"); out = fresh("sub")
            add_wire(bout, 1); add_wire(out, w)
            emit_inst(f"sub_{w}$", {'a':lw_expr, 'b':rw_expr, 'd':out, 'bout':bout})
            return out

        # ── Bitwise ──────────────────────────────────────────────────────────
        if op == '&':
            out = fresh("and"); add_wire(out, w)
            emit_inst(f"and_{w}$", {'a':lw_expr, 'b':rw_expr, 'y':out}); return out
        if op == '|':
            out = fresh("or");  add_wire(out, w)
            emit_inst(f"or_{w}$",  {'a':lw_expr, 'b':rw_expr, 'y':out}); return out
        if op == '^':
            out = fresh("xor"); add_wire(out, w)
            emit_inst(f"xor_{w}$", {'a':lw_expr, 'b':rw_expr, 'y':out}); return out
        if op in ('^~', '~^'):
            xout = fresh("xor"); add_wire(xout, w)
            emit_inst(f"xor_{w}$", {'a':lw_expr, 'b':rw_expr, 'y':xout})
            out = fresh("inv"); add_wire(out, w)
            emit_inst(f"inv_{w}$", {'a':xout, 'y':out}); return out

        # ── Equality ─────────────────────────────────────────────────────────
        if op == '==':
            out = fresh("eq"); add_wire(out, 1)
            emit_inst(f"eq_{w}$", {'a':lw_expr, 'b':rw_expr, 'eq':out}); return out
        if op == '!=':
            eq  = fresh("eq");  add_wire(eq,  1)
            emit_inst(f"eq_{w}$", {'a':lw_expr, 'b':rw_expr, 'eq':eq})
            out = fresh("inv"); add_wire(out, 1)
            emit_inst("inv_1$", {'a':eq, 'y':out}); return out

        # ── Comparison ───────────────────────────────────────────────────────
        if op in ('<', '>', '<=', '>='):
            lt = fresh("lt"); gt = fresh("gt")
            lte= fresh("lte");gte= fresh("gte")
            for wn in (lt,gt,lte,gte): add_wire(wn, 1)
            emit_inst(f"cmp_{w}$", {'a':lw_expr, 'b':rw_expr,
                                    'lt':lt, 'gt':gt, 'lte':lte, 'gte':gte})
            return {'<':lt, '>':gt, '<=':lte, '>=':gte}[op]

        # ── Logical AND / OR ─────────────────────────────────────────────────
        if op == '&&':
            # reduce each side to 1 bit then AND
            def or_reduce(wire, width):
                if width == 1: return wire
                r = fresh("orred"); add_wire(r,1)
                netlist.append({'kind':'reduction','op':'|','dst':r,'src':wire,'width':width})
                return r
            la = or_reduce(lw_expr, lw); ra = or_reduce(rw_expr, rw)
            out = fresh("and"); add_wire(out,1)
            emit_inst("and_1$", {'a':la,'b':ra,'y':out}); return out

        if op == '||':
            def or_reduce2(wire, width):
                if width == 1: return wire
                r = fresh("orred"); add_wire(r,1)
                netlist.append({'kind':'reduction','op':'|','dst':r,'src':wire,'width':width})
                return r
            la = or_reduce2(lw_expr, lw); ra = or_reduce2(rw_expr, rw)
            out = fresh("or"); add_wire(out,1)
            emit_inst("or_1$", {'a':la,'b':ra,'y':out}); return out

        die(f"Lower: unsupported binary op '{op}'")

    die(f"Lower: unhandled expression type {type(expr)}")

# Lower all continuous assigns
comb_results = {}  # lhs_name -> result_wire
for a in mod.assigns:
    log(f"  Lowering assign: {a.lhs}")
    result_wire = lower_expr(a.rhs)
    comb_results[a.lhs] = result_wire
    # If result wire != lhs name, emit a wire alias
    if result_wire != a.lhs:
        netlist.append({'kind':'assign', 'dst':a.lhs, 'src':result_wire})

# Add signal widths for port/logic signals to wire_widths
for name, info in symbols.items():
    if name not in wire_widths:
        wire_widths[name] = info['width']

# Write comb netlist debug
with open(p_comb, 'w') as f:
    f.write(f"# Combinational netlist for {stem}\n\n")
    for entry in netlist:
        f.write(f"  {entry}\n")

log(f"  {len(netlist)} netlist entries  ->  {p_comb}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 5: FF flattening — always_ff if-chains -> priority mux chains
# ─────────────────────────────────────────────────────────────────────────────
stage(5, "FF if-chain flattening")

@dataclass
class MuxChain:
    """
    Priority-encoded mux chain for one register's next-state logic.

    arms  = [(cond_wire, rhs_expr), ...]   # highest priority first
    default_rhs = expr | None              # else branch (hold if None)
    target = signal name of the register
    clk    = clock signal name
    """
    target:      str
    clk:         str
    arms:        list
    default_rhs: Any

ff_chains = []

for ff in mod.always_ffs:
    chain = ff.body   # IfChain

    # Find the register being driven (all NBAssign LHS in this block)
    targets = set()
    def collect_targets(stmts):
        for s in stmts:
            if isinstance(s, NBAssign):
                targets.add(s.lhs)
    for _, stmts in chain.arms:
        collect_targets(stmts)
    if chain.else_body:
        collect_targets(chain.else_body)

    if len(targets) != 1:
        die(f"FF block clocked by '{ff.clk}' drives {len(targets)} signals "
            f"({sorted(targets)}). Restriction: exactly one register per always_ff.")

    target = list(targets)[0]
    log(f"  FF block: clk={ff.clk}  target={target}")

    # Build (cond_expr, rhs_expr) arm list
    # Arms come in priority order (first arm = highest priority)
    arms_out = []
    for cond_expr, stmts in chain.arms:
        # Find the assignment to target in this arm (if present)
        rhs = None
        for s in stmts:
            if s.lhs == target:
                rhs = s.rhs
        # If this arm doesn't assign target, it's an implicit hold
        if rhs is None:
            rhs = Identifier(target)  # hold: next = current
        arms_out.append((cond_expr, rhs))

    # Else branch
    default_rhs = None
    if chain.else_body:
        for s in chain.else_body:
            if s.lhs == target:
                default_rhs = s.rhs
        if default_rhs is None:
            default_rhs = Identifier(target)  # hold
    # No else = implicit hold (next = current if no condition fires)
    if default_rhs is None:
        default_rhs = Identifier(target)

    ff_chains.append(MuxChain(target, ff.clk, arms_out, default_rhs))

with open(p_ff_chains, 'w') as f:
    f.write(f"# FF mux chains for {stem}\n\n")
    for mc in ff_chains:
        f.write(f"  target={mc.target}  clk={mc.clk}\n")
        for i, (cond, rhs) in enumerate(mc.arms):
            f.write(f"    arm[{i}]: cond={ast_str(cond)}  rhs={ast_str(rhs)}\n")
        f.write(f"    default:      rhs={ast_str(mc.default_rhs)}\n\n")

log(f"  {len(ff_chains)} FF chain(s)  ->  {p_ff_chains}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 6: FF lowering — mux chains + reg instantiation -> netlist
# ─────────────────────────────────────────────────────────────────────────────
stage(6, "FF lowering")

ff_netlist = []   # entries appended here, merged into netlist at emit

def lower_ff_chain(mc: MuxChain):
    """
    Build the priority mux tree for one register and instantiate reg_N$.

    Priority encoding:
      Start from the DEFAULT (lowest priority) and wrap with mux layers,
      highest-priority arm last (outermost mux).

      mux(cond_N, rhs_N,
        mux(cond_N-1, rhs_N-1,
          ...
            mux(cond_0, rhs_0, default_rhs)
          ...))

    The outermost mux output is the D input of the register.
    """
    w = symbols[mc.target]['width']

    # Lower default RHS — pass register width so bare literals get correct size
    cur_wire = lower_expr(mc.default_rhs, ctx_width=w)

    # Build mux chain from lowest priority to highest
    # (reverse the arm list so we wrap outermost = highest priority)
    for cond_expr, rhs_expr in reversed(mc.arms):
        cond_wire = lower_expr(cond_expr, ctx_width=1)   # conditions are 1-bit
        rhs_wire  = lower_expr(rhs_expr,  ctx_width=w)   # RHS inherits reg width
        mux_out   = fresh("mux")
        add_wire(mux_out, w)
        emit_inst(f"mux_{w}$", {
            'sel': cond_wire,
            'a':   rhs_wire,    # selected when sel=1
            'b':   cur_wire,    # selected when sel=0
            'y':   mux_out
        })
        cur_wire = mux_out

    # cur_wire is now the D input to the register
    next_wire = cur_wire

    # Instantiate reg_N$
    iname = f"ff_{mc.target}"
    emit_inst(f"reg_{w}$", {
        'clk': mc.clk,
        'rst': '1\'b1',        # no async reset port (sync reset via mux)
        'd':   next_wire,
        'q':   mc.target
    })
    log(f"  reg_{w}$  {iname}  d={next_wire}  q={mc.target}")

for mc in ff_chains:
    lower_ff_chain(mc)

with open(p_ff_net, 'w') as f:
    f.write(f"# Full netlist (comb + FF) for {stem}\n\n")
    for entry in netlist:
        f.write(f"  {entry}\n")

log(f"  FF netlist written  ->  {p_ff_net}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Stage 7: Structural SV emit
# ─────────────────────────────────────────────────────────────────────────────
stage(7, "Structural SystemVerilog emit")

def sv_const(value, width):
    """Format a constant as a Verilog literal."""
    return f"{width}'h{value:0{max(1,(width+3)//4)}X}"

def prim_width(prim):
    """Extract N from 'op_N$'."""
    m = re.match(r'[a-z]+_(\d+)\$', prim)
    return int(m.group(1)) if m else None

with open(sv_out, 'w') as f:

    # ── Header ────────────────────────────────────────────────────────────────
    f.write(f"// {'='*70}\n")
    f.write(f"// Structural SV : {mod.name}\n")
    f.write(f"// Tool          : sv2rtl.py  (auto-generated)\n")
    f.write(f"// Source        : {sv_in}\n")
    f.write(f"// {'='*70}\n\n")

    # ── Module declaration ────────────────────────────────────────────────────
    if mod.params:
        f.write(f"module {mod.name} #(\n")
        for i, p in enumerate(mod.params):
            comma = ',' if i < len(mod.params)-1 else ''
            v = symbols[p.name]['const']
            f.write(f"    parameter {p.name} = {v}{comma}\n")
        f.write(") (\n")
    else:
        f.write(f"module {mod.name} (\n")

    port_lines = []
    for i, p in enumerate(mod.ports):
        w    = symbols[p.name]['width']
        wstr = f"[{w-1}:0] " if w > 1 else "       "
        comma = ',' if i < len(mod.ports)-1 else ''
        port_lines.append(f"    {p.direction:<7} wire {wstr}{p.name}{comma}")
    f.write('\n'.join(port_lines))
    f.write('\n);\n\n')

    # ── Internal wire declarations ────────────────────────────────────────────
    # Collect all internal wires: anything in wire_widths that is not a port
    port_names  = {p.name for p in mod.ports}
    logic_names = {d.name for d in mod.decls}
    internal_wires = {
        name: width
        for name, width in wire_widths.items()
        if name not in port_names
    }

    if internal_wires:
        f.write("// Internal wires\n")
        for name in sorted(internal_wires):
            w    = internal_wires[name]
            wstr = f"[{w-1}:0] " if w > 1 else "       "
            f.write(f"wire {wstr}{name};\n")
        f.write('\n')

    # Logic signals declared in source (registers, intermediate signals)
    # These are driven by reg_N$ .q outputs — declared as wire since the
    # reg primitive drives them.
    if logic_names:
        f.write("// Logic signals (driven by reg primitives or assign)\n")
        for name in sorted(logic_names):
            w    = symbols[name]['width']
            wstr = f"[{w-1}:0] " if w > 1 else "       "
            if name not in internal_wires and name not in port_names:
                f.write(f"wire {wstr}{name};\n")
        f.write('\n')

    # ── Emit netlist entries ──────────────────────────────────────────────────
    f.write("// ── Combinational primitives & FF logic ─────────────────────────────\n\n")

    for entry in netlist:
        kind = entry['kind']

        # Constant tie
        if kind == 'const':
            w   = entry['width']
            val = entry['value']
            f.write(f"assign {entry['dst']} = {sv_const(val, w)};  "
                    f"// {entry['raw']}\n")

        # Slice (part-select)
        elif kind == 'slice':
            f.write(f"assign {entry['dst']} = "
                    f"{entry['src']}[{entry['hi']}:{entry['lo']}];\n")

        # Reduction (OR/AND/XOR tree)
        elif kind == 'reduction':
            op_map = {'|':'|', '&':'&', '^':'^'}
            op_str = op_map[entry['op']]
            f.write(f"assign {entry['dst']} = {op_str}{entry['src']};  "
                    f"// {entry['op']}-reduction of {entry['width']} bits\n")

        # Wire alias
        elif kind == 'assign':
            f.write(f"assign {entry['dst']} = {entry['src']};\n")

        # Primitive instance
        elif kind == 'inst':
            prim   = entry['prim']
            iname  = entry['inst']
            ports  = entry['ports']
            port_str = ', '.join(f".{k}({v})" for k, v in ports.items())
            f.write(f"{prim} {iname} ({port_str});\n")

    f.write('\nendmodule\n')

log(f"  Structural SV written -> {sv_out}  OK")

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
log()
log(BANNER)
log("  Pipeline complete -- output files:")
log(BANNER)
manifest = [
    ("Tokens",          p_tokens),
    ("AST",             p_ast),
    ("Symbols",         p_symbols),
    ("Comb netlist",    p_comb),
    ("FF chains",       p_ff_chains),
    ("FF netlist",      p_ff_net),
    ("Structural SV",   sv_out),
]
for label, path in manifest:
    size = os.path.getsize(path) if os.path.exists(path) else 0
    log(f"  {label:<22}  {path}  ({size} bytes)")
log()
