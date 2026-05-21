#!/usr/bin/env bash
# Tests for extraSeatbeltRules (Darwin-specific)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/../lib.sh"

SANDBOXED_EXTRAS=$(nix-build --no-out-link "$SCRIPT_DIR/../fixtures/extra-args-sandbox.nix")
SANDBOXED_BASIC=$(nix-build --no-out-link "$SCRIPT_DIR/../fixtures/basic-sandbox.nix")

run() { "$SANDBOXED_EXTRAS/bin/sandboxed-bash-extras" --norc --noprofile -c "$@" >/dev/null 2>&1; }
run_basic() { "$SANDBOXED_BASIC/bin/sandboxed-bash" --norc --noprofile -c "$@" >/dev/null 2>&1; }

MARKER_DIR="$HOME/.agent-sandbox-extra-test"
MARKER_FILE="$MARKER_DIR/marker"

mkdir -p "$MARKER_DIR"
echo "extra-rules-test-content" > "$MARKER_FILE"
trap 'rm -rf "$MARKER_DIR"' EXIT

echo "=== extraSeatbeltRules tests (Darwin) ==="
echo

expect_ok "extraSeatbeltRules grants read access to $MARKER_FILE" \
  "cat $MARKER_FILE"

# The basic sandbox only has file-read-metadata on the literal REAL_HOME dir;
# files inside REAL_HOME are blocked. Verify this so the positive test above
# is meaningful — it would be trivially true if all paths were accessible.
if run_basic "cat $MARKER_FILE" 2>/dev/null; then
  echo "FAIL: basic sandbox should NOT be able to read $MARKER_FILE (test is not meaningful)"
  FAIL=$((FAIL + 1))
else
  echo "PASS: basic sandbox correctly cannot read $MARKER_FILE (extra rule is necessary)"
  PASS=$((PASS + 1))
fi

print_results
exit_status
