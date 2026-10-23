#!/usr/bin/env bash
# Self-test for gate.sh: builds throwaway repos (npm, node --test, no dependencies)
# and asserts the gate's exit code for each case. Needs git and node.
set -uo pipefail
GATE="$(cd "$(dirname "$0")" && pwd)/gate.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fails=0 n=0

g() { git -c user.name=gate -c user.email=gate@localhost -c commit.gpgsign=false "$@"; }

# a repo whose main has a buggy add() and no tests; each case branches off it
repo() {
  local d="$T/$1"; mkdir -p "$d"; cd "$d" || exit 1
  g init -q -b main
  printf '%s\n' '{"name":"t","private":true,"scripts":{"test":"node --test"}}' > package.json
  printf '%s\n' 'exports.add = (a, b) => a - b;' > add.js
  printf '%s\n' 'node_modules/' 'package-lock.json' > .gitignore
  g add -A && g commit -qm init && g checkout -qb work
}
fixed()  { printf '%s\n' 'exports.add = (a, b) => a + b;' > add.js; }
good_test() { printf '%s\n' "const t=require('node:test'),a=require('node:assert'),{add}=require('./add');" "t('adds',()=>a.strictEqual(add(2,3),5));" > add.test.js; }
weak_test() { printf '%s\n' "const t=require('node:test'),a=require('node:assert'),{add}=require('./add');" "t('is a function',()=>a.strictEqual(typeof add,'function'));" > add.test.js; }
commit() { g add -A && g commit -qm change; }

expect() {  # expect <exit code> <name> <gate args...>
  local want=$1 name=$2; shift 2; n=$((n + 1))
  out=$(bash "$GATE" "$@" 2>&1); got=$?
  if [ "$got" = "$want" ]; then echo "ok   $name (exit $got)"
  else echo "FAIL $name: want exit $want, got $got"; echo "$out" | sed 's/^/     /'; fails=$((fails + 1)); fi
}

mkdir -p "$T/empty" && cd "$T/empty" && g init -q
expect 0 "no package.json: skips with a notice" all

repo fix-with-test; fixed; good_test; commit
expect 0 "fix + test that fails on main: green" all main

repo src-no-test; fixed; commit
expect 1 "source changed, no test: red" all main

repo weak-test; fixed; weak_test; commit
expect 1 "test that also passes on main: red" all main

repo broken; good_test; commit
expect 1 "new test fails on the branch: red" all main

repo pre-existing
node -e 'const p=require("./package.json");p.scripts.lint="node -e process.exit(1)";require("fs").writeFileSync("package.json",JSON.stringify(p))'
g commit -qam "lint already broken" && g branch -f main HEAD
fixed; good_test; commit
expect 0 "lint fails on main too: pre-existing, green" all main

repo uncommitted; fixed; good_test
expect 0 "uncommitted fix + test: green" all main

repo checks-only; fixed; commit
expect 0 "checks mode ignores red-proof" checks main

echo "$((n - fails))/$n passed"
[ "$fails" = 0 ]
