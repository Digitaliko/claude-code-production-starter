# Claude Code production starter

A small Next.js app with the guardrails a real team needs once AI agents write most of the code: agent rules, hooks that stop bad commands, a CI gate that proves tests mean something, and a launch checklist.

For vibe coders whose prototype is about to meet real users, and for small dev teams where everyone already uses Claude Code, Codex or Cursor, each in their own way.

The app itself is deliberately tiny (one page, one API route, one function). Keep the tooling, replace the app.

## Use it in 3 steps

1. **Create your repo.** Click "Use this template", clone it, then:
   ```bash
   pnpm install              # Node 22, pnpm. Also installs the git hooks.
   pnpm verify               # typecheck, lint, unit tests
   pnpm dev                  # http://localhost:3000
   ```
2. **Make it yours.** Fill in the "This repository" section of `AGENTS.md`, replace `app/` and `lib/` with your app, and adjust the deny list in `.claude/settings.json` to your tools (your database CLI, your deploy command).
3. **Turn on the server side.** Settings, Branches, add a rule for `main`: require a pull request, one approval, and the status check **`ci`**. Hooks only run where they are installed; branch protection runs for everyone.

Then go through [`docs/production-checklist.md`](docs/production-checklist.md) with your team.

## What enforces what

A rule in a text file is a request. Every rule here sits as high on this ladder as it can:

| Level | Strength | In this repo |
|---|---|---|
| Just a sentence | weakest | `AGENTS.md` (read by Claude Code through `CLAUDE.md`, and by Codex, Cursor and others) |
| Setting or hook | medium | `.claude/settings.json`, `.claude/hooks/`, `.husky/` |
| CI | strong | `.github/workflows/ci.yml` and branch protection |
| Lint or test | strongest | ESLint, TypeScript strict, Vitest, Playwright |

A rule broken twice moves one level up.

### The pieces

| Piece | What it stops |
|---|---|
| `.claude/settings.json` | The agent reading `.env` files and keys, force-pushing, `reset --hard`, skipping git hooks, connecting to a database CLI. Pushes, merges, migrations and deploys ask first. |
| `.claude/hooks/push-gate.sh` | Any push to `main`/`master` and any force push, which a settings pattern can't tell apart. |
| `.claude/hooks/secret-scan.sh` | A commit with a staged `.env` file or something that looks like a key. Uses [gitleaks](https://github.com/gitleaks/gitleaks) if installed, else a small regex scan. Runs for the agent and as the git pre-commit hook. |
| `.claude/hooks/stop-gate.sh` | The agent saying "done" while typecheck, lint or tests are red. It gets the failure and has to fix it. |
| `.husky/` | Pre-commit: secret scan and lint on staged files. Commit-msg: `type(scope): summary`. Pre-push: warns on pushing to `main` or a branch not named `<type>/<desc>`, then runs `pnpm check`. |
| `scripts/gate.sh` | The definition of done as one script, used by CI, the Stop hook and you. Runs typecheck, lint, test and build. With a base branch, a failure that also fails on the base is reported as pre-existing, not blamed on you. |
| Red-proof (in `gate.sh`) | Tests that prove nothing. Changed source needs a changed test, and the changed tests must **fail on the base branch and pass on yours**. Run it locally: `bash scripts/gate.sh all origin/main`. |
| `.github/workflows/ci.yml` | Merging red. Jobs: `check`, `test` (unit and integration), `build`, `e2e` (Playwright, report uploaded on failure), `red-proof`, the gate self-test, and one `ci` job that sums them up. Docs-only changes skip the app jobs. |
| `scripts/lint-ratchet.sh` | Optional. When you adopt a strict lint rule on old code, `eslint --suppress-all` records today's violations; CI fails if that number ever grows. |
| `.github/pull_request_template.md` | A PR that doesn't say how it was checked. |
| `.github/CODEOWNERS` | Placeholder. Fill it in and require code owner review for `.claude/` and `.github/`. |
| `.github/dependabot.yml` | Stale dependencies and actions. Weekly, minor and patch grouped. |

A change no test can prove (a pure refactor, config) gets the `skip-red-proof` label on the PR. A human decides that, not the agent.

### Optional: AI review and @claude

Both use the public [claude-code-action](https://github.com/anthropics/claude-code-action) and need an `ANTHROPIC_API_KEY` repository secret plus the Claude GitHub app (`/install-github-app` in Claude Code). Without the secret they skip.

- `ai-review.yml` reviews every PR with fresh eyes: correctness, security, tests that prove something, scope. It comments and never blocks. A human still approves.
- `claude.yml` answers when someone with write access mentions `@claude` in an issue or PR comment. Its changes go through a PR and CI like anyone else's.

Don't want them? Delete the two files.

## Scripts

| Command | What | When |
|---|---|---|
| `pnpm check` | typecheck and lint | pre-push |
| `pnpm verify` | check and unit tests | before you push, fast |
| `pnpm verify:full` | verify, integration tests, build | what CI runs |
| `pnpm test:e2e` | Playwright smoke test (`pnpm exec playwright install chromium` once) | before a release, and in CI |
| `bash scripts/gate.sh all origin/main` | everything above plus red-proof against `main` | before you say done |
| `bash scripts/gate-selftest.sh` | proves the gate itself works | CI runs it |

## Bringing your own app

Replace the Next.js app with any JavaScript or TypeScript project. Keep the script names (`typecheck`, `lint`, `test`, `build`) and the gate works with pnpm, bun or npm, picked from the lockfile. Without a `package.json` the gate and CI skip with a notice, so the rules alone also work.

## More

- The full launch guide as a PDF: [From prototype to production](https://www.digitaliko.com/resources/prototype-to-production-en.pdf)
- Made by [Digitaliko](https://www.digitaliko.com). We build custom software with AI agents and use this setup on our own projects. Questions: info@digitaliko.com

## License

MIT. See `LICENSE`.
