#!/bin/bash
# PreToolUse hook for Bash. Blocks force pushes and pushes to main/master.
# exit 0 = allow, exit 2 = block (stderr goes back to the agent).
# Don't add `|| true` or `2>/dev/null` around it: both silently switch it off.
CMD=$(jq -r '.tool_input.command // empty')
[[ "$CMD" != *"git push"* ]] && exit 0

if [[ "$CMD" =~ (--force|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+[^[:space:]]) ]]; then
  echo "Force push is not allowed. Push a new commit instead." >&2
  exit 2
fi

# Explicit main/master target, or any push while on main/master.
BRANCH=$(git -C "${CLAUDE_PROJECT_DIR:-.}" branch --show-current 2>/dev/null)
if [[ "$CMD" =~ [[:space:]:](main|master)([[:space:]]|$) || "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "Pushing to main is not allowed. Push a branch and open a PR." >&2
  exit 2
fi
exit 0
