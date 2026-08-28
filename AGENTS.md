# Notes for automated agents

## What this is

A Swift package that reads `.3mf` packages and extracts a preview image. Roughly 400 lines of
source. It has no application, no UI and no network access.

## Validation

```bash
swift build
swift test
```

CI runs exactly these two commands. There is nothing else to run.

If dependency resolution fails with `cannot use bare repository ... safe.bareRepository is
'explicit'`, that is a local git setting, not a defect in this package:

```bash
GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.bareRepository GIT_CONFIG_VALUE_0=all swift test
```

## Things worth knowing before changing code

- **This parses untrusted input.** A `.3mf` arrives from the internet and, through the Quick Look
  extensions, is opened by merely selecting it in Finder. Any new parsing path needs a test for the
  malformed case, not only the well-formed one.
- **The size ceiling is checked twice on purpose.** Once against the declared size in the archive
  metadata, and again against a running total while decompressing, because the declared size can
  lie. Do not simplify this to one check.
- **When writing a test fixture, `addEntry` stores uncompressed by default.** A "decompression
  bomb" fixture built without `compressionMethod: .deflate` is not compressed at all and proves
  nothing. `EntrySizeLimitTests` asserts the fixture really is compressed for this reason.
- **The module must stay extension-safe.** It is compiled with `-application-extension`. An API
  that is unavailable to app extensions will fail to build for consumers even if it builds here.
- **The README example is compiled.** `READMEExampleTests` mirrors it, so renaming a public symbol
  means updating the README in the same change.

## Public API is load-bearing

Two separate applications depend on this package. A breaking change to a `public` symbol requires a
major version.
