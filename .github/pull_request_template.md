## What

<!-- What changed, in one or two sentences. Link the issue: Closes #123 -->

## Why

<!-- The problem this solves. Skip if the issue says it. -->

## How it was checked

- [ ] `bash scripts/gate.sh all origin/main` is green, including red-proof (or a human added `skip-red-proof`, reason below).
- [ ] Tests added or updated. A bug fix has a test that fails without the fix.
- [ ] No existing test was weakened, skipped or deleted (or the reason is below).
- [ ] UI change: before and after screenshots below, or "No screenshots: <reason>".

## Risk

- [ ] Touches login, permissions, payments or personal data
- [ ] Includes a database migration (reversible? tested on a copy?)
- [ ] Adds or changes a secret, env variable or third-party integration

## Not done

<!-- What you left out on purpose, and assumptions you made. -->

---
Reviewer: someone who did not write this change. Written review comments, not just a call.
