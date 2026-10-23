# Rules for AI agents in this repository

Keep this file short. The agent loads it on every run; the more text, the worse it sticks to what matters. Rules for one module go in a file inside that module's folder.

## This repository

<!-- Fill in. Delete this comment. -->
- **What it is:** one sentence about the app and who uses it.
- **Stack:** Next.js (App Router), TypeScript strict, Vitest, Playwright, ESLint, pnpm, Node 22.
- **Layout:** `app/` pages and routes, `lib/` logic with unit tests next to it, `tests/int/` integration tests, `e2e/` Playwright.

## Commands

| Command | Use it |
|---|---|
| `pnpm verify` | after every change: typecheck, lint, unit tests |
| `pnpm verify:full` | before you open a PR: plus integration tests and build |
| `bash scripts/gate.sh all origin/main` | before you say done: plus red-proof |
| `pnpm test:e2e` | when you touch a page or a route |

## Definition of done

The task is done when **`bash scripts/gate.sh all origin/main` is green**, and not before:

- typecheck, lint, tests and build pass;
- **red-proof:** if you changed source, you changed or added a test, and that test fails on `main` and passes on your branch. A test that also passes on `main` proves nothing;
- the PR template is filled in, including what you did not do.

"Tests pass" means you ran them and read the output. The Stop hook runs the fast checks and sends you back if they are red. CI runs all of it again.

## The agent must not

| # | Never | What stops it |
|---|---|---|
| 1 | Connect to the production database. Use a read-only replica or a log export for diagnostics. | setting (deny) + separate credentials |
| 2 | Read secrets: `.env`, keys, tokens. Scripts load them; nobody prints them. | setting (deny) + secret scan + secrets outside the repo |
| 3 | Use production cloud credentials. | setting (deny) |
| 4 | Run a deploy or a production migration. A human does that. | setting (ask) + environment approval in CI |
| 5 | Force-push, `reset --hard`, push to `main`, or skip hooks with `--no-verify`. | setting + push-gate hook + branch protection |
| 6 | Change the test it is graded by to make it pass. | red-proof in CI + reviewer |
| 7 | Approve or merge its own change. | required human approval |
| 8 | Put customer or personal data into a prompt. | just a sentence + team agreement |

Number 8 is honestly "just a sentence". Nothing enforces it mechanically.

If a rule or hook blocks you, stop and say so. Never route around it: a script that prints `.env` is still reading `.env`.

## The agent may, without asking

- Read and edit code, run the app locally, run tests, linters and the gate.
- Create a branch, commit on it, open a draft PR when the task is done.
- Add a dependency when the task needs it, and say why in the PR.

## Before starting a task

- The task says what done looks like. If it doesn't, write your assumption at the top of the PR.
- If the task does not match the code (the file, the bug, the API isn't there), stop and report. Don't invent the premise.

## Tests

- A bug fix comes with a test that fails on the old code and passes on the new one.
- A new feature comes with a test of its main flow.
- A test exercises behaviour: it calls the function, renders the page or hits the route. Reading source files as text or asserting on implementation details is not a test.
- Never weaken, skip or delete an existing test to get green. If a test is wrong, say so in the PR and let a human decide.
- Only a human adds the `skip-red-proof` label.

## Pull requests

- One task, one PR. Branch off `main`: `feat/`, `fix/`, `refactor/`, `chore/`, `docs/`, `test/`, `ci/`, `perf/`.
- Conventional commits: `fix(auth): expire reset links`. The message says why; the diff shows what.
- A visible UI change includes before and after screenshots.
- CI must be green before review. A human who did not write the change reviews it. The AI review comments are advisory.

## Review levels

| Level | Who | What happens |
|---|---|---|
| Auto-block | CI: lint, types, tests, build, red-proof | The merge is impossible until green. |
| Human review | the reviewer | Correctness, security, scope. They approve or send it back. |
| Advisory | AI review, suggestions | Read it, decide, move on. |

## Secrets

- Secrets live outside the repository (a secrets manager or your deploy platform). `.env.example` lists the names, never the values.
- Never commit a secret. If one was ever committed, it gets rotated, not just deleted.
- Never paste a secret into a command, a log, a PR or an issue. CI uses clearly fake values.

## Where new rules come from

From review. A comment that comes up a second time is a hole in the rules.

- First time: fix it.
- Second time: add a rule here.
- Third time: add a lint, test or hook that catches it.

Owner of these rules: [name]. Changes go through a PR the owner approves.
