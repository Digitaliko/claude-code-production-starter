#!/usr/bin/env bash
# gate.sh [all|checks|red-proof] [base]  - the definition of done, as a script.
#
#   checks     install, then run the package.json scripts in $GATE_SCRIPTS that exist
#              (default: typecheck lint test build). With a base ref, a script that
#              also fails on the base is reported as PRE-EXISTING, not blamed on you.
#   red-proof  needs a base ref. Changed source needs a changed test, and the changed
#              tests must FAIL on the base code and PASS on yours. Otherwise they
#              prove nothing.
#   all        both (default).
#
# Exit 0 = green, 1 = red, 2 = usage. Used by CI, the Claude Stop hook and you:
#   bash scripts/gate.sh all origin/main
# GATE_SKIP_INSTALL=1 skips the install (you already have node_modules).
set -uo pipefail
mode=${1:-all} base=${2:-}
case "$mode" in all|checks|red-proof) ;; *) echo "usage: gate.sh [all|checks|red-proof] [base]" >&2; exit 2 ;; esac
root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "gate: not a git repository" >&2; exit 2; }
cd "$root" || exit 2

say() { echo "$*"; }
notice() { if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::notice::$*"; else echo "NOTICE $*"; fi; }

[ -f package.json ] || { notice "gate: no package.json yet, nothing to check"; exit 0; }
if [ -n "$base" ] && ! git rev-parse -q --verify "$base^{commit}" >/dev/null; then
  echo "gate: base '$base' not found (in CI, check out with fetch-depth: 0)" >&2; exit 2
fi

W=$(mktemp -d)
cleanup() { [ -d "$W/base" ] && git worktree remove --force "$W/base" >/dev/null 2>&1; rm -rf "$W"; }
trap cleanup EXIT

pm() { if [ -f "$1/pnpm-lock.yaml" ]; then echo pnpm; elif [ -f "$1/bun.lock" ] || [ -f "$1/bun.lockb" ]; then echo bun; else echo npm; fi; }
install() {
  [ "${GATE_SKIP_INSTALL:-}" = 1 ] && return 0
  (cd "$1" && case $(pm "$1") in
    pnpm) pnpm install --frozen-lockfile ;;
    bun) bun install --frozen-lockfile ;;
    *) if [ -f package-lock.json ]; then npm ci; else npm install --no-audit --no-fund; fi ;;
  esac) > "$W/install-$(basename "$1").log" 2>&1
}
has_script() { (cd "$1" && node -e 'process.exit(require("./package.json").scripts?.[process.argv[1]] ? 0 : 1)' "$2"); }
run() { (cd "$1" && case $(pm "$1") in pnpm) pnpm run "$2" ;; bun) bun run "$2" ;; *) npm run -s "$2" ;; esac) > "$W/$2-$3.log" 2>&1; }
base_tree() {
  [ -d "$W/base" ] && return 0
  git worktree add -q --detach "$W/base" "$base" >/dev/null 2>&1 || return 1
  GATE_SKIP_INSTALL='' install "$W/base"   # the base never has node_modules
}

rc=0
head_tested=0

checks() {
  install "$root" || { say "FAIL install (see the log below)"; tail -20 "$W"/install-*.log; rc=1; return; }
  for sc in ${GATE_SCRIPTS:-typecheck lint test build}; do
    has_script "$root" "$sc" || continue
    if run "$root" "$sc" head; then say "PASS $sc"; [ "$sc" = test ] && head_tested=1; continue; fi
    if [ -n "$base" ] && base_tree && has_script "$W/base" "$sc" && ! run "$W/base" "$sc" base; then
      say "PRE-EXISTING $sc (fails on $base too, not blocking)"
    else
      say "FAIL $sc"; tail -25 "$W/$sc-head.log"; rc=1
    fi
  done
}

red_proof() {
  [ -n "$base" ] || { say "SKIP red-proof: no base ref given"; return; }
  local changed tests src red
  changed=$({ git diff --name-only "$base"...HEAD; git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u)
  tests=$(printf '%s\n' "$changed" | grep -E '(^|/)(tests?|__tests__|spec|e2e)/|\.(test|spec)\.[a-z]+$' || true)
  src=$(printf '%s\n' "$changed" | grep -E '\.(ts|tsx|js|jsx|mjs|cjs)$' \
    | grep -vE '(^|/)(tests?|__tests__|spec|e2e)/|\.(test|spec)\.|\.config\.|\.d\.ts$' || true)
  # e2e specs count as tests, but `test` does not run them, so they can't be red-proofed here
  red=$(printf '%s\n' "$tests" | grep -vE '(^|/)e2e/' || true)
  local t; for t in $red; do [ -f "$t" ] || red=$(printf '%s\n' "$red" | grep -vxF "$t"); done

  if [ -z "$tests" ]; then
    [ -n "$src" ] && { say "FAIL red-proof: source changed but no test was added or changed:"; printf '  %s\n' $src; rc=1; return; }
    say "PASS red-proof: no source or test changes, nothing to prove"; return
  fi
  [ -n "$red" ] || { say "PASS red-proof: only e2e specs changed, not red-proofed here"; return; }
  has_script "$root" test || { say "FAIL red-proof: tests changed but package.json has no \"test\" script"; rc=1; return; }

  if [ "$head_tested" = 0 ]; then
    install "$root" || { say "FAIL install"; rc=1; return; }
    run "$root" test head || { say "FAIL red-proof: the tests fail on this branch"; tail -25 "$W/test-head.log"; rc=1; return; }
  fi
  base_tree || { say "FAIL red-proof: could not set up $base"; rc=1; return; }
  for t in $red; do mkdir -p "$W/base/$(dirname "$t")"; cp "$t" "$W/base/$t"; done
  # run this branch's test command on the base code (the base may not even have one)
  # ponytail: a failure can be a missing import rather than behaviour; the reviewer reads the excerpt
  local cmd; cmd=$(node -p 'require("./package.json").scripts.test')
  if (cd "$W/base" && PATH="$W/base/node_modules/.bin:$PATH" sh -c "$cmd") > "$W/red.log" 2>&1; then
    say "FAIL red-proof: the changed tests also pass on $base, so they don't prove the change"; rc=1
  else
    say "PASS red-proof: changed tests fail on $base and pass here ($(echo $red | wc -w | tr -d ' ') file(s)). Why they failed on $base:"
    grep -E -m 8 'FAIL|✗|×|not ok|Error|expected|Expected|received' "$W/red.log" | cut -c1-200 | sed 's/^/  /'
  fi
}

[ "$mode" = red-proof ] || checks
[ "$mode" = checks ] || red_proof
[ "$rc" = 0 ] && say "gate: green" || say "gate: red"
exit "$rc"
