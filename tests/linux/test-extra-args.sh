#!/usr/bin/env bash
# Tests for extraBwrapArgs (Linux-specific)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/../lib.sh"

SANDBOXED_EXTRAS=$(nix-build --no-out-link "$SCRIPT_DIR/../fixtures/extra-args-sandbox.nix")

run() { "$SANDBOXED_EXTRAS/bin/sandboxed-bash-extras" --norc --noprofile -c "$@" >/dev/null 2>&1; }

MARKER_DIR="/tmp/agent-sandbox-extra-test"
MARKER_FILE="$MARKER_DIR/marker"

mkdir -p "$MARKER_DIR"
echo "extra-args-test-content" > "$MARKER_FILE"
trap 'rm -rf "$MARKER_DIR"' EXIT

echo "=== extraBwrapArgs tests (Linux) ==="
echo

expect_ok "extraBwrapArgs binds /tmp/agent-sandbox-extra-test into the sandbox" \
  "cat $MARKER_FILE"

print_results
exit_status
