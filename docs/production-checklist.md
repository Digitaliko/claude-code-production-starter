# From prototype to production: 25 checks before launch

For an app built with an AI tool, by a freelancer or left by an agency. It takes an hour. Where you can't answer, you have a question for whoever built the app.

A missing item isn't a reason to rewrite. It's a to-do list.

## A. Login, permissions and secrets

- [ ] **1. Access control is on every entry point.** In the API too, not just on the main screen. Check: log in as a normal user and try to open someone else's record via its address.
- [ ] **2. Passwords and keys aren't in the code.** If they ever were, they have been replaced.
- [ ] **3. Only an admin sees admin functions.** Not just a hidden button.
- [ ] **4. Password reset and invitations can't be abused.** The link expires and works only once.
- [ ] **5. Forms are protected against bots** and limit the number of attempts.

## B. Data

- [ ] **6. Backups run automatically.** And you have restored one for real at least once.
- [ ] **7. Database changes go through migrations.** Not manual edits on the live database.
- [ ] **8. Test data and live data are separate.** Experiments don't happen on customers.
- [ ] **9. Personal data is only where it's needed.** You know where it is and who can access it.

## C. Deployment and environments

- [ ] **10. Deploying is one command or one button.** Not done by hand from one computer.
- [ ] **11. There is a way back.** You can roll back to the previous version in minutes.
- [ ] **12. You have a test environment** separate from live operation.
- [ ] **13. Someone else can run the app from scratch.** Following the instructions, on a clean computer.

## D. Quality

- [ ] **14. The main flows have tests.** Sign-up, payment, the thing the customer pays for.
- [ ] **15. Tests really fail when something breaks.** A green tick without tests is decoration.
- [ ] **16. CI blocks the merge** when tests fail. It doesn't just report.
- [ ] **17. Integrations have a verified API and limits.** Payment gateway, email, third-party services. Check them before you build a plan on them.

## E. Operations

- [ ] **18. An alert reports an outage,** not a customer.
- [ ] **19. Errors are logged** and someone reads them.
- [ ] **20. Background jobs are watched.** Whatever runs on its own will one day quietly stop.
- [ ] **21. You know what it costs to run** and what happens to the cost with 10 times more users.

## F. Ownership and accounts

- [ ] **22. The repository is in your company's name,** with its full history.
- [ ] **23. Domain, cloud and payment accounts are in the company's name.** Not on the personal account of whoever clicked it together.
- [ ] **24. More than one person can access the accounts.**
- [ ] **25. The contract says who owns the code** and what you get when you leave the vendor.

## Scoring

Count the ticked items. But look at items 1, 2, 6 and 22 first. If even one of them is missing, fix it before launch, whatever the score.

| State | Verdict | What it means |
|---|---|---|
| The base holds, tests check something, deployment is repeatable | **Continue** | Keep building features and fill in the missing items along the way |
| The app works, but security, tests or monitoring are missing | **Harden** | Fix those first, then new features |
| Fixes would take longer than a new version | **Start over** | The prototype stays as the brief; the code is rewritten |

The most common outcome isn't a rewrite. It's a few security fixes, a working deployment and then normal work.

## What this template already covers

| Item | Covered by |
|---|---|
| 2. No keys in code | `.claude/hooks/secret-scan.sh` (agent and git pre-commit), `.env` reads denied in `.claude/settings.json` |
| 13. Someone else can run it | the 3 steps in the [README](../README.md), `.nvmrc`, frozen lockfile in CI |
| 14. Main flows have tests | Vitest `unit` and `int` projects, Playwright smoke test in `e2e/`. Add yours. |
| 15. Tests really fail when something breaks | red-proof in [`scripts/gate.sh`](../scripts/gate.sh): changed tests must fail on `main` |
| 16. CI blocks the merge | [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) plus branch protection requiring `ci` (README step 3) |
| 22. Repository with full history | force push and history rewrites blocked by `.claude/hooks/push-gate.sh` and branch protection |
| 24. More than one person has access | `.github/CODEOWNERS` once you fill it in |

Everything else (backups, migrations, environments, monitoring, accounts, contracts) depends on where and how you run the app. That's the to-do list.

## Using it with an agent

Ask the agent to go through sections A to D against the code and report each item as PASS, FAIL or UNKNOWN with the file it looked at. Sections E and F are about accounts and contracts; a person answers those.

---

The full guide with examples, as a PDF: [From prototype to production](https://www.digitaliko.com/resources/prototype-to-production-en.pdf). Made by [Digitaliko](https://www.digitaliko.com).
