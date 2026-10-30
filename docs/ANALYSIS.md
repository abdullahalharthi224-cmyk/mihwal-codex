# Mihwal / مِحوَل — Phase 0 analysis

## Product boundary

Mihwal is an offline, on-device iPhone application for PDF and image operations. It
will target iOS 17 and later, use SwiftUI and Swift 5.9, and make no network requests.
Every input remains in the app sandbox or a user-selected security-scoped location;
outputs are written to a temporary working directory before preview, sharing, or export.

The first release has 21 tools. Each will conform to the common `FileTool` protocol,
with an engine containing Foundation/framework logic only, a SwiftUI view, and an
`@MainActor` view model. Engines will accept a cancellation-aware progress reporter,
perform expensive work outside the main actor, and return output URLs plus descriptive
metadata.

## Tool specifications

Difficulty is relative to a polished, fully offline iOS implementation: Low, Medium,
High, or Limited (a native API cannot faithfully deliver the advertised format or
result).

### Organize PDF

| Tool | Input | Options and behavior | Output / edge cases | Native implementation | Difficulty |
| --- | --- | --- | --- | --- | --- |
| Merge | Two or more PDFs, including password-protected PDFs after unlock | Drag-reorder documents; optionally preserve source names in metadata | One PDF. Reject empty selections, unreadable/corrupt files, and incorrect passwords; preserve page dimensions and rotations. | PDFKit (`PDFDocument` insert), Foundation file coordination | Medium |
| Split | One PDF | Visual page picker; split after selected pages or produce a file per selected page range | Multiple PDFs in a ZIP-free export session. Reject overlapping/empty ranges; clearly report a locked document. | PDFKit | Medium |
| Compress | One PDF | Quality preset; downsample embedded raster content where possible | A rewritten PDF plus before/after bytes. Vector-heavy PDFs may barely shrink or grow; never claim a guaranteed reduction. | PDFKit page rendering, Core Graphics PDF context, ImageIO | High |
| Rotate | One PDF | Select pages visually; rotate ±90°/180° | One PDF. Preserve unselected pages; page rotation uses PDF metadata rather than rasterizing. | PDFKit (`PDFPage.rotation`) | Low |
| Delete pages | One PDF | Multi-select visual thumbnails | One PDF; disallow deleting every page, which has no valid useful PDF result. | PDFKit | Low |
| Extract pages | One PDF | Multi-select visual thumbnails, retaining the displayed order | One PDF containing selected pages. Reject an empty selection. | PDFKit | Low |
| Reverse order | One PDF | No additional option beyond confirmation | One PDF whose page order is reversed. | PDFKit | Low |
| Page numbers | One PDF | Visual page selection; position, font size, color, starting number, and optional prefix/suffix | One flattened/re-written PDF. Existing content remains visible; avoid crop boxes and account for rotated pages. | PDFKit for source pages; Core Graphics/Core Text for overlay | Medium |
| Text watermark | One PDF | Text, opacity, size, color, angle, position, and selected pages | One flattened/re-written PDF. Arabic text uses attributed/Core Text layout, including RTL. | PDFKit, Core Graphics, Core Text | Medium |
| Strip metadata | One PDF | Confirmation; no content options | Rewritten PDF with document attributes and common XMP-style metadata omitted. Embedded metadata that PDFKit does not expose may remain; disclose this limitation. | PDFKit, Core Graphics PDF context | Medium |
| Remove restrictions | A PDF that is encrypted/permission-restricted, plus its owner or user password | Password entry; validate by opening the document | An unlocked rewritten PDF. It must **not** attempt to bypass encryption or restrictions without a valid password. Some producer-specific restrictions may require rasterized reconstruction and should instead fail clearly. | PDFKit (`unlock(withPassword:)`), Core Graphics | Medium |

### Convert

| Tool | Input | Options and behavior | Output / edge cases | Native implementation | Difficulty |
| --- | --- | --- | --- | --- | --- |
| PDF to Word | PDF | Page/range selection | A real, text-only `.docx` will be produced with a minimal dependency-free OOXML/ZIP writer. Arabic paragraphs will be marked RTL. PDF layout, fonts, images, tables, and links are intentionally not preserved; scanned PDFs need OCR. | PDFKit text extraction; Vision OCR fallback; Foundation + custom ZIP/OOXML writer | High |
| PDF to text | PDF | Page/range selection; OCR only for pages without a text layer | UTF-8 `.txt`; preserve reading order as available. Complex columns/tables can be imperfect. Detect no text on a page, render it at an appropriate resolution, then OCR Arabic and English. | PDFKit; Vision (`VNRecognizeTextRequest` with `ar-SA`, `en-US`) | Medium |
| Text to PDF | Plain-text file or entered text | Paper size, margins, font size, alignment, and document title | PDF with correct Arabic shaping, bidi ordering, line wrapping, and pagination. Unsupported fonts fall back to a system font. | Core Text / `NSAttributedString`, Core Graphics PDF context | High |
| Images to PDF | One or more images: PNG, JPEG, HEIC, WebP where ImageIO decodes it | Drag-reorder, fit/fill, page size, margins, orientation | One PDF. Read EXIF orientation, bound decoded pixel size, and reject unsupported/corrupt images. | PhotosUI/UniformTypeIdentifiers input; ImageIO; Core Graphics | Medium |
| PDF to images | PDF | Page selection, PNG/JPEG, output scale/quality | One image per page. Very large pages can require reduced scale to avoid memory pressure; transparent PDF regions become opaque in JPEG. | PDFKit rendering; Core Graphics; ImageIO | Medium |

### Images

| Tool | Input | Options and behavior | Output / edge cases | Native implementation | Difficulty |
| --- | --- | --- | --- | --- | --- |
| Convert formats | PNG, JPEG, HEIC, and WebP when ImageIO can decode it | Choose PNG or JPEG only | Converted image. Preserve orientation; transparency is flattened for JPEG. WebP is input-only and unavailable decoder support produces a clear error. | ImageIO, UniformTypeIdentifiers, Core Graphics | Medium |
| Compress | Raster image | Quality preset/slider; optional maximum pixel dimension | JPEG/HEIC output with before/after bytes. PNG is lossless and may not shrink; transparency requires PNG, so lossy conversion needs consent. | ImageIO | Medium |
| Resize | Raster image | Exact dimensions, aspect-ratio lock, fit/fill | Resized image; prevent upscaling by default and retain orientation. | ImageIO thumbnail/downsampling APIs, Core Graphics | Low |
| Rotate / flip | Raster image | 90° increments and horizontal/vertical flip | Transformed image. Normalize EXIF orientation into output pixels. | Core Graphics, ImageIO | Low |
| Text watermark | Raster image | Text, Arabic/English font, opacity, color, size, angle, position | Watermarked image. Use attributed/Core Text drawing so RTL text is shaped and connected correctly. | Core Graphics, Core Text, ImageIO | Medium |

## Framework and format decisions

- **PDFKit** is the source of truth for page access, page thumbnails, reordering,
  extraction, page rotation, document metadata, and password validation.
- **Core Graphics** writes reconstructed PDFs and renders source pages safely into
  bounded bitmap contexts. It is also used for image transforms.
- **Core Text** lays out text-to-PDF and watermarks; this is required for Arabic
  shaping and bidirectional layout rather than drawing individual glyphs.
- **ImageIO** decodes, downsamples, transforms, and encodes raster formats while
  preserving or normalizing orientation deliberately.
- **Vision** performs offline OCR when an otherwise textless PDF page needs it.
- **UniformTypeIdentifiers** defines import/export document types and validates
  supported content types. **PhotosUI** supplies image selection from the photo
  library. **QuickLook** previews completed outputs.

`PDFDocument` can read and assemble PDFs, but it is not a general-purpose PDF
optimizer, redaction engine, permission cracker, or Word-document converter. Compression
will be an explicit rebuild/downsample strategy, not a misleading promise of lossless
optimization. Likewise, PDF-to-Word will be presented as best-effort text conversion
unless a future custom OOXML implementation is approved.

## UX ideas that improve on a website

- Put a persistent offline promise and privacy explanation on the first-run screen:
  processing never leaves the iPhone.
- Make the home screen a searchable, Arabic-first grid with favorites and recent tools;
  let users pin their most frequent workflow without creating an account.
- Use an image-rich page workspace for all PDF page tools: lazy thumbnails, long-press
  selection, drag reordering, page-count badges, and undo before processing. Never ask
  people to type page ranges for ordinary tasks.
- Show a processing sheet with the current phase, byte/page progress, an honest time
  estimate only when measurable, and a real Cancel action. Completed jobs stay in a
  local, user-clearable recent-output shelf for immediate Quick Look, sharing, or saving.
- For compression, present a previewable result card with original and new sizes,
  percent change, and a warning if the output grew. Offer “keep original” as the safe
  default.
- Make document password entry scoped to the current job, never persist it, and explain
  that unlocking requires a password the user is authorized to use.
- Provide bilingual controls that mirror in RTL, Dynamic Type-safe layouts, VoiceOver
  labels describing page selections and output state, and restrained haptics for
  selection, completion, and recoverable errors.

## Cross-cutting implementation risks and mitigations

1. **Memory for large PDFs/images:** render thumbnails on demand, create autorelease
   pools around page/image loops, use ImageIO downsampling, write incremental outputs,
   and release source references between pages.
2. **Security-scoped imported URLs:** copy inputs into a uniquely named app working
   directory immediately after `startAccessingSecurityScopedResource()`, then always
   clean temporary outputs after export/share completion where possible.
3. **Cancellation and progress:** every engine checks `Task.isCancelled` between pages
   and reports completed units/total units through a shared actor; partial files are
   removed before surfacing cancellation.
4. **Document fidelity:** page-overlay tools can preserve source page content; rebuild
   operations (compression, watermark, numbering, metadata stripping, unlocking) need
   targeted fixtures for rotation, crop boxes, encryption, Arabic text, and images.
5. **Exporting multiple files:** Split and PDF-to-images will maintain a job output
   collection, preview individual results, and offer Share/Files export together. A
   ZIP archive is deliberately out of scope unless later requested.

## Delivery plan confirmation

Phase 1 should create only the XcodeGen project, CI workflow, test target, design-system
foundation, localized catalog, and the empty-but-navigable home grid. Engines and import
logic begin in Phase 2, then tools are delivered in the requested groups. This order keeps
the first GitHub Actions build small and makes CI failures easy to diagnose.

## Approved product decisions (before Phase 1)

- Bundle identifier: `com.abdullah.mihwal.codex`.
- WebP is decode-only; the app exports PNG and JPEG, never WebP. No third-party library
  will be introduced for this.
- Camera/document scanning is out of scope for this release.
- PDF-to-Word must produce an actual `.docx`. The implementation will own a minimal ZIP
  and OOXML writer, output text only, and set Arabic paragraphs RTL; it makes no layout
  fidelity claim.
- Page numbers and PDF text watermarking may flatten interactive links and forms. Their
  confirmation UI must warn users before work starts.
