#!/bin/bash
# Stop hook: the agent can't finish while the checks are red.
# Runs the fast part of scripts/gate.sh (no build, no red-proof: CI does those).
# Blocks once per stop; stop_hook_active stops an endless loop.
in=$(cat)
[ "$(printf '%s' "$in" | jq -r '.stop_hook_active // false')" = true ] && exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
[ -f scripts/gate.sh ] && [ -d node_modules ] || exit 0
# nothing changed since the last commit on main: nothing to check
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  git rev-parse -q --verify origin/main >/dev/null || exit 0
  [ -z "$(git log --oneline origin/main..HEAD 2>/dev/null)" ] && exit 0
fi
out=$(GATE_SKIP_INSTALL=1 GATE_SCRIPTS="typecheck lint test" bash scripts/gate.sh checks 2>&1) && exit 0
jq -n --arg r "Checks are red. Fix them before you say the task is done:
$(printf '%s' "$out" | tail -c 3000)" '{decision: "block", reason: $r}'
