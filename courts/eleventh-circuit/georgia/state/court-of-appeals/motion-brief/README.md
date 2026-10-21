# Georgia Court of Appeals (gactapp): motion-brief

Doc type: any motion filed in the Court of Appeals (Rule 41; emergency motions Rule 40 (b)). Exemplar: **yes** (`usage/FILED-EXAMPLE-motion-brief.pdf`, the State of Georgia's Emergency Motion for Supersedeas in *State of Georgia v. Democratic Party of Georgia, Inc., DSCC, and Warnock for Georgia*, filed November 21, 2022 by the Office of the Attorney General and Robbins Alloy Belinfante Littlefield, LLC). The Court of Appeals number is blank ("No. ____") on the filed cover, as emergency motions are filed before docketing; the file name uses the trial-court number (Fulton Superior Court 2022-CV-372734). Source: `usage/SOURCE.md`. Nothing here sets a `court.json` status.

## Status

| Item | Result |
|---|---|
| `usage/` | 1 filed motion, text PDF, 29 pages (Century Schoolbook; Democracy Docket's diagonal "retrieved from" watermark is in the text layer, so `pdftotext` shows stray letters) |
| `usage/INPUT-motion-brief.md` | transcription of filed pages i-11 and 19-24: cover, tables, Introduction, Jurisdiction, Background, Argument I.A, II, Conclusion, signature, certificate of service. Argument I.B (filed pages 12-19) is omitted. Id kept for the existing docx outputs |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 18 pages, exit 0, no warnings, Liberation Serif embedded |
| overlay | ok: `.overlay/courts/eleventh-circuit/georgia/state/court-of-appeals/motion-brief/OVERLAY-motion-brief.pdf` / `.txt` |
| pages reviewed | all 18 output pages and all 29 exemplar pages rendered at 60 dpi and inspected |

## Governing rules (primary source, read 2026-10-16)

Court of Appeals of Georgia Rules, effective March 26, 2026, `https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf`, read from the Internet Archive copy (gaappeals.gov returns 403 here). Supersedes the secondhand GACA-* table of the previous README.

| Requirement | Rule | Template |
|---|---|---|
| Motions are separate documents, prepared in accordance with Rule 24; e-filed motions limited to 4,200 words "as certified by the filer"; no attachments (except Rule 40 (b) emergency motions) | 41 (b) | form below; word count not computed |
| Letter paper; double spacing except block quotations, headings, captions, footnotes; serif proportional 14 pt+ (Times New Roman, Century Schoolbook named) | 2 (c) (1)-(3) | Liberation Serif 14 pt; `body-leading 1.65em` (32.3 pt pitch, measured) |
| Margins 1 in; pages numbered with Arabic numerals at the bottom | 24 (c), (e) | 1 in; every page Arabic, cover = 1 (the exemplar uses roman numerals for its front matter; the rule says Arabic) |
| Certification "This submission does not exceed the word count limit imposed by Rule 24." just above the signature block | 24 (f) (1) | **Changed**: the old template printed its own "I certify that this motion contains N words" certificate, which is not the rule's wording. Now the fixed sentence; `word_count` is accepted and ignored |
| Signature with "/s/" typed name underlined, name below; bar number, address, phone, e-mail | 2 (a), 2 (a) (2) (ii) | **Changed**: `signer_line` underlined, optional `signature.name` printed below it |
| Certificate of service, method identified; e-mail prior-agreement certification | 6 (b) (2), 6 (d) | `service.paragraphs` / `recipients` (new, optional) or the generated sentence |
| Emergency motion content (necessity, filed order, notice of appeal) | 40 (b) | content, not template |

## Overlay page map

Ours pages 1-3 pair with filed pages i-iii; pages 4-13 pair with filed pages 5-14; page 14 pairs with filed page 24; pages 15-16 pair with filed pages 25-26; page 17 pairs with filed page 28; page 18 pairs with filed page 27. These are the pairs from the regenerated same-id overlay. The filed motion has 29 pages; the input transcribes pages i-11 and 19-24 as described above.

## Gate 2 review (18 of 18 pages)

| Page | Finding |
|---|---|
| 1 | Cover: court, "Case No. ____", caption with roles, lower court, title, two counsel groups. OK |
| 2 | Table of contents (`toc: true`). OK |
| 3 | Table of authorities: Cases, Statutes, Constitutional Provisions, generated pages. OK |
| 4-6 | Introduction with footnotes 1-2 (14 pt, single spaced). OK |
| 6-9 | Jurisdiction, Background (bullet list), footnote 3. OK |
| 9-12 | Argument, headings I, A (bold italic), II. OK |
| 14-15 | Final argument and conclusion. OK |
| 16 | Rule 24 certification, date line and signature block. OK |
| 17 | Certificate of service with three recipient groups. The conformed signature moves to the next page. OPEN |
| 18 | Orphaned certificate signature (`/s/ Vincent Russo`, name and bar number) without certificate text. OPEN; requires layout adjustment |

Fixed in review: signature block width (`100% - 3.25in` inside a padded block collapsed to a one-word column); case number with markdown escapes printed backslashes (the cover prints `case_number` as plain text); the certificate's signature repeated every counsel line and broke across pages (now /s/ line, name and first line, unbreakable).

## What changed (template `typst/gactapp-motion-brief.typ`)

Separate cover page by default (`cover_page`, default true; both filed exemplars of this court's motions, this one and the Sierra Club reconsideration motion, use one), centred caption, optional `counsel` on the cover; optional `toc` and generated `authorities`; rule wording of the Rule 24 certification; underlined conformed signature; certificate of service from `paragraphs` / `recipients` / `closing`; headings forced to 14 pt; first-line indent on every paragraph; footnotes 14 pt single spaced and counted in the table of authorities.

## Markdown contract

`court`, `case_number`, `lower_court_case` (optional), `parties` (list of `name`, `role`; a `v.` entry with empty role), `title`, `counsel` (optional cover groups), `cover_page`, `toc`, `authorities` (as the briefs: `heading`, `entries` of `cite`, `find`), `signature` (`date`, `lines` printed above the /s/ line, `signer_line`, `name`, `signer` lines), `service` (`date`, `doc_type`, `served_on`, `method`, `address` for the generated sentence; or `paragraphs`, `recipients`, `closing`), `word_count` (ignored).

## Gaps

1. Word count not computed or checked against 4,200.
2. The exemplar's counsel are set in two columns on the cover and signature page; ours stack them (tier 3).
3. Only one conformed signature is underlined; extra signers in `signer` lines are plain text.
4. docx: **not regenerated** (no `soffice` on this box). `OUTPUT-motion-brief.docx` / `.docx.pdf` are renders of the old synthetic sample and the docx form still prints the old word-count certificate and starts the body on the cover. Open docx items: Rule 24 (f) (1) wording, underlined signature, cover page, `toc` / `authorities`, `service.paragraphs`.
