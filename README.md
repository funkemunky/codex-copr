# codex

## Description

Lightweight coding agent that runs in your terminal

## Installation Instructions

```
dnf copr enable funkemunky/codex
dnf install codex
```

## Automatic COPR rebuilds

This repository contains a GitHub Actions workflow that checks the latest
`openai/codex` release once per hour. When the latest upstream tag changes, it
calls the package-specific COPR custom webhook for the `codex` package and then
records the processed upstream tag in `.github/upstream-codex-release.txt`.

Configure this repository secret:

```
COPR_CODEX_WEBHOOK_URL=https://copr.fedorainfracloud.org/webhooks/custom/<ID>/<UUID>/codex/
```

You can find the webhook ID and UUID in the COPR project settings under
Integrations for `funkemunky/codex`.

Create an issue [1] to mark package as outdated or packaging issues. Report
codex related issues to upstream.

[1] https://github.com/ecomaikgolf/codex-copr
