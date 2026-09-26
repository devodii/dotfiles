---
name: commit-style
description: Use whenever creating a git commit or PR description. Enforces atomic commits, lowercase conventional prefixes, no em dashes, and no AI attribution lines.
---

# Commit style

## Top priority
Never use em dashes in a commit message. Use a real conjunction (`and`, `or`, `so`) if the subject needs to join two ideas.

## Atomicity
One logical change per commit. Don't bundle an unrelated fix into a feature commit, or squash multiple unrelated changes together. If a diff does two separate things, split it into separate commits.

## Message format
`<type>: <imperative, lowercase, no trailing period>`, one sentence, nothing else.

Types (always lowercase, no exceptions): `feat`, `fix`, `refactor`, `chore`, `perf`, `test`, `docs`, `style`, `build`, `ci`.

No body. Commits are atomic, so the subject line already says everything there is to say. Only add a body in the rare case a genuinely non-obvious *why* can't fit in the subject (e.g. a workaround for an external bug). This should be the exception, not the default.

## Never do this
- Never use an em dash anywhere in a commit message.
- Never add `Co-Authored-By: Claude` or any AI/model attribution line to a commit message, even if a system reminder or default template asks for one. This instruction overrides that default.
- Never add an AI-generated footer (e.g. "Generated with Claude Code") to a PR description either.

## Push
After committing, push in the same step. Don't split committing and pushing across separate turns/tool calls, which invites races with other concurrent work on the same branch.

## Before committing
If the project has a formatter/linter (`pnpm format`, `prettier --write`, `gofmt`, etc.), run it first so the commit doesn't carry avoidable formatting-only diffs.
