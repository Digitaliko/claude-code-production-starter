# SECURITY.md for claude-code-production-starter

> [!IMPORTANT]
> One docs PR, nothing leaves. Two settings wait on Filip: the `security@` mailbox and GitHub private vulnerability reporting.

## Decide
### May need you
- **ai-sbom-claude-code-production-starter-mail · Create `security@` and turn on private vulnerability reporting**
  - Why: SECURITY.md says `[security@ mailbox: Filip creates]`; private vulnerability reporting is off on this public repo (`gh api .../private-vulnerability-reporting`: `false`). Both are Filip's (account settings).

## What happened
- B2 of `rooms/team/legal/ai-act-cra/enforcement-plan.md` (approved as `ai-act-kb-5a`): the plan lists B1 no (a starter, nothing to install), B2 yes, B3 "already has dependabot: keep".
- `SECURITY.md`: private reporting, 3 working days to acknowledge, 30 days target for critical fixes, latest `main` supported. The CRA 24 h line is left out: a starter you copy is not a product we place on the market.
- Dependabot alerts are on for this repo (`gh api .../vulnerability-alerts`: 204).

## Change
| repo | file | what |
|---|---|---|
| claude-code-production-starter | `SECURITY.md` | vulnerability policy |

## Goes out
Nothing leaves (merging puts the page on the public repo).

## Proof
- No code changed: docs only. `wizrd pr gate` in the worktree.
