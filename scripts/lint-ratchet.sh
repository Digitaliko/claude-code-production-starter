#!/usr/bin/env bash
# Lint ratchet (optional): the ESLint suppressions file may only shrink.
# Start one with `pnpm exec eslint . --suppress-all` when adopting a strict rule on old code,
# fix files over time, and run `eslint . --prune-suppressions` to drop what you fixed.
# Usage: lint-ratchet.sh <base-ref>. No suppressions file = nothing to ratchet.
set -uo pipefail
base=${1:?usage: lint-ratchet.sh <base-ref>}
f=eslint-suppressions.json
count() { node -e 'let n=0;for(const r of Object.values(JSON.parse(require("fs").readFileSync(0,"utf8")||"{}")))for(const v of Object.values(r))n+=v.count;console.log(n)'; }
[ -f "$f" ] || { echo "lint-ratchet: no $f, nothing to ratchet"; exit 0; }
now=$(count < "$f")
git cat-file -e "$base:$f" 2>/dev/null || { echo "lint-ratchet: $f is new ($now suppressions), that is the baseline"; exit 0; }
before=$(git show "$base:$f" | count)
echo "lint-ratchet: $before suppressions on $base, $now now"
[ "$now" -le "$before" ] || { echo "lint-ratchet: suppressions grew. Fix the new warnings instead of suppressing them." >&2; exit 1; }
