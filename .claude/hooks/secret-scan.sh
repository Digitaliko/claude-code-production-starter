#!/bin/bash
# Secret scan before a commit. Two entry points, one script:
#   - Claude Code PreToolUse(Bash): reads the tool call on stdin, acts only on `git commit`
#   - git pre-commit (via .husky/pre-commit): empty stdin
# Uses gitleaks when installed, else a small regex scan. Exit 2 = block.
in=$( [ -t 0 ] || cat )
if [ -n "$in" ]; then
  cmd=$(printf '%s' "$in" | jq -r '.tool_input.command // empty')
  [[ "$cmd" == *"git commit"* ]] || exit 0
  # `git commit -a` commits tracked changes that are not staged yet
  diff_args=(--cached); [[ "$cmd" =~ [[:space:]]-[a-zA-Z]*a ]] && diff_args=(HEAD)
else
  diff_args=(--cached)
fi

added=$(git diff "${diff_args[@]}" -U0 --no-color 2>/dev/null | grep -E '^\+[^+]' || true)
files=$(git diff "${diff_args[@]}" --name-only --diff-filter=AM 2>/dev/null)

block() { echo "Blocked: $1. Move secrets out of the repo (see AGENTS.md, Secrets)." >&2; exit 2; }

# env files with real values never get committed; .env.example is fine
printf '%s\n' "$files" | grep -qE '(^|/)\.env($|\.)' && \
  printf '%s\n' "$files" | grep -E '(^|/)\.env($|\.)' | grep -qvE '\.example$' && block "an .env file is staged"

if command -v gitleaks >/dev/null 2>&1; then
  printf '%s\n' "$added" | gitleaks stdin --no-banner --redact --log-level error >&2 || block "gitleaks found a secret"
  exit 0
fi
pat='AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|sk-(ant-)?[A-Za-z0-9_-]{32,}|xox[abposr]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(api[_-]?key|secret|token|password)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_/+=-]{16,}["'"'"']'
hit=$(printf '%s\n' "$added" | grep -oiE "$pat" | head -1)
[ -n "$hit" ] && block "possible secret in the change: ${hit:0:12}..."
exit 0
