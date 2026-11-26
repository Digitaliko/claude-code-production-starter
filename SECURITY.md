# Security policy

## Supported versions

This is a starter you copy, not a package you install: fixes land on `main`. Only the latest `main` is supported. A project made from it owns its own copy and its own security policy.

## Reporting a vulnerability

Please report a vulnerability privately, never in a public issue, pull request or discussion.

- Email: [security@ mailbox: Filip creates]
- Or GitHub private vulnerability reporting: the "Report a vulnerability" button under this repository's Security tab, when it is turned on.

Include what is affected (version or commit), how to reproduce it, and the impact you see. Tell us if you want to be credited.

## What happens next

- We acknowledge your report within 3 working days.
- We aim to fix critical issues within 30 days and tell you when the fix is out. These are our targets, not a legal deadline.
- We publish an advisory once a fix is available, and credit you if you want.

## How this repository checks its dependencies

- Dependabot (`.github/dependabot.yml`) opens weekly update pull requests for the npm packages and the GitHub Actions, and GitHub's Dependabot alerts flag known vulnerabilities in `pnpm-lock.yaml`.
