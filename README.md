# Mihwal / مِحوَل

An offline, on-device iOS utility for PDF and image work. It targets iOS 17+ and uses
SwiftUI, PDFKit, Core Graphics, Core Text, ImageIO, Vision, and Apple system frameworks
only—there are no third-party dependencies, accounts, analytics, or network calls.

## Development

The Xcode project is generated, never hand-edited:

```sh
xcodegen generate
```

GitHub Actions generates the project, runs the XCTest target on an iPhone simulator,
builds an unsigned device Release app, and uploads `Mihwal-unsigned.ipa` as an artifact.
The configured bundle identifier is `com.abdullah.mihwal`.

## Product decisions

- WebP is decode-only when ImageIO supports the source; image export is PNG or JPEG.
- Camera scanning is intentionally out of scope.
- PDF-to-Word will produce a text-only `.docx` using a minimal, dependency-free OOXML/ZIP
  writer. It will preserve Arabic RTL text but not PDF layout.
- Page numbers and PDF text watermarks may flatten interactive links and forms; the tool
  UI will warn before processing.
