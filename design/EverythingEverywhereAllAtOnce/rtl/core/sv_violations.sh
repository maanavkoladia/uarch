#!/usr/bin/env bash

set -e

TARGET=${1:-.}

echo "Scanning SystemVerilog violations in: $TARGET"
echo "------------------------------------------------------------"

# 1. typedef struct (BIG ONE)
echo "[1] typedef struct usage:"
grep -RIn --exclude-dir=.git "typedef[[:space:]]\+struct" "$TARGET" || true
echo ""

# 2. struct usage in declarations ( *_t pattern heuristic)
echo "[2] Possible struct types (*_t declarations):"
grep -RIn --exclude-dir=.git "[a-zA-Z0-9_]\+_t" "$TARGET" || true
echo ""

# 3. dotted struct access (a.b)
echo "[3] Struct/member access (a.b pattern):"
grep -RIn --exclude-dir=.git "[a-zA-Z0-9_]\+\.[a-zA-Z0-9_]\+" "$TARGET" || true
echo ""

# 4. unpacked arrays in declarations (SV-style)
echo "[4] Unpacked array declarations:"
grep -RIn --exclude-dir=.git "\[[0-9]*\][[:space:]]*\[[0-9]*\]" "$TARGET" || true
echo ""

# 5. logic keyword (SV-only replacement for wire/reg)
echo "[5] 'logic' usage:"
grep -RIn --exclude-dir=.git "\blogic\b" "$TARGET" || true
echo ""

# 6. always_ff / always_comb (SV procedural blocks)
echo "[6] always_ff / always_comb:"
grep -RIn --exclude-dir=.git "always_ff\|always_comb" "$TARGET" || true
echo ""

# 7. interface usage
echo "[7] interface usage:"
grep -RIn --exclude-dir=.git "\binterface\b" "$TARGET" || true
echo ""

# 8. struct-like field access on signals (heuristic)
echo "[8] Heuristic dotted access (likely struct unpacking needed):"
grep -RIn --exclude-dir=.git "[A-Za-z0-9_]*_[A-Za-z0-9_]*\.[A-Za-z0-9_]" "$TARGET" || true
echo ""

# 9. parameterized types / SV typedef patterns
echo "[9] typedef / parameterized type usage:"
grep -RIn --exclude-dir=.git "typedef\|type\s\+=" "$TARGET" || true
echo ""

echo "------------------------------------------------------------"
echo "Done."
