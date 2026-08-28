# ThreeMFKit

[![License: MIT](.github/badges/license.svg)](LICENSE)
[![macOS 15+](.github/badges/platform.svg)](#requirements)
[![CI](https://github.com/trsdn/ThreeMFKit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/trsdn/ThreeMFKit/actions/workflows/ci.yml)
[![Conformance](.github/badges/conformance.svg)](docs/self-assessment.md)

Reads `.3mf` packages and pulls a usable preview image out of them, without unpacking the whole
archive or parsing geometry it does not need.

A `.3mf` file is a ZIP container. Slicers write a rendered preview into it, but they disagree on
where and on how many: Bambu Studio and Orca write several, of varying usefulness, under names that
look interchangeable but are not. This package hides that.

```swift
let extractor = ThreeMFPreviewExtractor()

switch extractor.preview(for: url) {
case .preview(let image):
    // image.data is PNG, image.pixelSize is its real size
case .fallback(let fallback):
    // fallback.reason: notAThreeMFPackage, noSupportedImage,
    //                  unreadablePackage, imageNormalizationFailed
}
```

It does not throw. Every failure is a named `fallback` reason, because a preview extension has to
render *something* and needs to know why it is rendering a placeholder.

Pass `maxPixelDimension:` to bound the returned image:

```swift
extractor.preview(for: url, maxPixelDimension: 512)
```

## What it does

- **Picks the right preview.** Slicers embed plate renders, per-object picks and thumbnails side by
  side. Plate renders are what a person wants to see; per-object picks are not. The ranking is
  explicit rather than "first image found".
- **Refuses to guess.** A ZIP that is not a `.3mf` is reported as `notAThreeMFPackage` rather than
  having an unrelated image pulled out of it. That case is real: the Quick Look extensions also
  register for `public.zip-archive`, so they are handed ordinary archives.
- **Reads one entry, not the archive.** Entries are listed as metadata, then only the chosen
  preview is decompressed, so a large package costs a small read.
- **Bounded on untrusted input.** Every entry has an uncompressed-size ceiling, enforced from the
  declared size and again while decompressing, so an entry cannot exceed it by lying in its header.
  `.3mf` previews reach compression ratios near 1000:1, so a declared size alone is not a defence.

## Requirements

- macOS 15 or later
- Swift 6

## Installation

```swift
.package(url: "https://github.com/trsdn/ThreeMFKit.git", from: "1.0.0")
```

## Use in app extensions

The module is verified against the API surface an app extension may link -- CI builds it with
`-Xswiftc -application-extension`. It is consumed that way by
[3MF Quick Look](https://github.com/trsdn/threemf-quicklook), which runs it inside Finder's preview
and thumbnail extensions.

## Design

The three moving parts are separate protocols, so each is testable without the others and a new
slicer's layout is a new resolver rather than a change to the reader:

| Protocol | Responsibility |
|---|---|
| `ThreeMFPackageReading` | list and read entries from the container |
| `PreviewImageResolving` | decide which entry is the preview worth showing |
| `ImageNormalizing` | turn the bytes into a normalized PNG of known size |

`ZIPFoundationThreeMFPackageReader`, `BambuPreviewResolver` and `CGImagePreviewImageNormalizer` are
the shipped implementations.

## Building and testing

```bash
swift build
swift test
```

## Project conventions

Contributions and ownership are described in [CONTRIBUTING.md](CONTRIBUTING.md). Automated agents
should read [AGENTS.md](AGENTS.md) first. Security reporting is in [SECURITY.md](SECURITY.md).

This repository is assessed against the
[trsdn Repository Quality Standard](https://github.com/trsdn/.github); the evidence is in
[docs/self-assessment.md](docs/self-assessment.md).

## License

MIT — see [LICENSE](LICENSE).
