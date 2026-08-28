# Changelog

All notable changes to this package are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] — 2026-08-28

### Fixed

- The target declared `.unsafeFlags(["-application-extension"])`. SwiftPM refuses to resolve a
  package that uses unsafe flags when it is depended on by version from a remote repository, so
  every consumer outside this repository failed to build with *"cannot be used as a dependency of
  this target because it uses unsafe build flags"*. It only ever worked because the package was a
  local path dependency. The guarantee has not been dropped: CI now builds with
  `-Xswiftc -application-extension`, and the consuming extension targets already set
  `APPLICATION_EXTENSION_API_ONLY`.

## [1.0.0] — 2026-08-28

First standalone release.

This code was previously a directory inside
[printfilemanager](https://github.com/trsdn/printfilemanager) and was consumed by two Xcode
projects that had to sit next to each other on disk. It is genuinely independent of both, so it now
lives on its own and both consumers depend on it as a versioned package. History is preserved.

### Added

- `EntrySizeLimitTests`, covering the uncompressed-size ceiling that is this package's only defence
  against a decompression bomb. It was previously untested, which is indistinguishable from absent.
  Both halves are exercised: the declared size in the archive metadata, and the running total while
  decompressing an entry that compresses 8 MB into well under 1 MB.
- `READMEExampleTests`, which compiles the example the README shows, so renaming a public symbol
  breaks the build rather than leaving the documentation quietly wrong.

### Existing behaviour

- Preview extraction for `.3mf` packages, ranking plate renders above per-object picks and
  excluding picking masks.
- Named fallback reasons — `notAThreeMFPackage`, `noSupportedImage`, `unreadablePackage`,
  `imageNormalizationFailed` — instead of an empty optional.
- Reader, resolver and normalizer as separate protocols, so a new slicer layout is a new resolver.
- Built with `-application-extension`, so it can be linked by Quick Look extensions.
