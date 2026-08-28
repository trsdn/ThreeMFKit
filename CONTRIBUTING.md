# Contributing

Issues and pull requests are welcome. This is a personal project maintained by one person, so there
is no response commitment.

## Before you open a pull request

```bash
swift build
swift test
```

Both must pass. CI runs the same two commands on macOS.

## What a change needs

- **A test for the behaviour, including how it fails.** This package parses untrusted input, so a
  change that adds a parsing path without a test for the malformed case is incomplete.
- **A reason in the commit message.** Describe what was wrong and why this fixes it, not what the
  diff shows.
- **An updated README where the public API changed.** The README example is compiled by
  `READMEExampleTests`, so a rename that breaks it fails the build rather than rotting quietly.

## Public API

This package is consumed by two separate applications, so a breaking change to a `public` symbol
needs a major version. If you are unsure whether something is load-bearing, say so in the pull
request rather than guessing.

## Ownership

Every path is owned by @trsdn — see [.github/CODEOWNERS](.github/CODEOWNERS).
