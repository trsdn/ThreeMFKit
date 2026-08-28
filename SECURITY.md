# Security Policy

## Reporting a vulnerability

Report privately through
[GitHub Security Advisories](https://github.com/trsdn/ThreeMFKit/security/advisories/new).
Please do not open a public issue for a vulnerability.

This is a personal project maintained by one person. There is no response-time commitment, but
reports are read.

## Threat model

This package parses **untrusted input**. A `.3mf` file is a ZIP archive that arrives from a model
sharing site, a message, or a download, and it is handed to this code before anyone has looked at
it. In [3MF Quick Look](https://github.com/trsdn/threemf-quicklook) it runs inside a Finder
extension, so it is reached by merely selecting a file — no double-click required.

That shapes what the code does:

- **Uncompressed size is capped per entry.** The cap is checked against the declared size *and*
  again while decompressing, so an entry cannot exceed it by lying in its header. `.3mf` previews
  legitimately compress near 1000:1, so a declared size on its own is not a defence.
- **Only the chosen preview entry is decompressed.** Listing entries reads metadata; nothing else
  is expanded.
- **A ZIP that is not a `.3mf` is rejected by name**, rather than having some arbitrary image
  pulled out of it.
- **No network access, no file writes, no code execution.** The package reads one file and returns
  bytes.

Failure paths are covered by tests: unreadable archives, oversized entries, archives that are not
3MF packages, and packages with no usable image.

## What is out of scope

Geometry parsing and rendering are not in this package. It reads the preview image a slicer
embedded; it does not evaluate model data.
