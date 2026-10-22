# Georgia Court of Appeals (gactapp): motion-brief

Doc type: any motion filed in the Court of Appeals (Rule 41; emergency motions Rule 40 (b)). Exemplar: **yes** (`usage/FILED-EXAMPLE-motion-brief.pdf`, the State of Georgia's Emergency Motion for Supersedeas in *State of Georgia v. Democratic Party of Georgia, Inc., DSCC, and Warnock for Georgia*, filed November 21, 2022 by the Office of the Attorney General and Robbins Alloy Belinfante Littlefield, LLC). The Court of Appeals number is blank ("No. ____") on the filed cover, as emergency motions are filed before docketing; the file name uses the trial-court number (Fulton Superior Court 2022-CV-372734). Source: `usage/SOURCE.md`. Nothing here sets a `court.json` status.

## Status

| Item | Result |
|---|---|
| `usage/` | 1 filed motion, text PDF, 29 pages (Century Schoolbook; Democracy Docket's diagonal "retrieved from" watermark is in the text layer, so `pdftotext` shows stray letters) |
| `usage/INPUT-motion-brief.md` | transcription of filed pages i-11 and 19-24: cover, tables, Introduction, Jurisdiction, Background, Argument I.A, II, Conclusion, signature, certificate of service. Argument I.B (filed pages 12-19) is omitted. Id kept for the existing docx outputs |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `usage/OUTPUT-motion-brief.docx` / `.docx.pdf`, 18 pages each, exit 0, no warnings, Times New Roman embedded |
| overlay | ok: `.overlay/courts/eleventh-circuit/georgia/state/court-of-appeals/motion-brief/OVERLAY-motion-brief.pdf` / `.txt` |
| pages reviewed | all 18 pages of both renders (typst and docx) at 40 dpi, the cover, tables, body pages 10-12 and the signature and certificate pages 16-18 at 60 dpi; all 29 exemplar pages |
| cross-engine | docx XENG-001..003 PASS (354/354 lines, 18 pages); `eval.yaml` `params.cross_engine: gate` |

## Governing rules (primary source, read 2026-10-16)

Court of Appeals of Georgia Rules, effective March 26, 2026, `https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf`, read from the Internet Archive copy (gaappeals.gov returns 403 here). Supersedes the secondhand GACA-* table of the previous README.

| Requirement | Rule | Template |
|---|---|---|
| Motions are separate documents, prepared in accordance with Rule 24; e-filed motions limited to 4,200 words "as certified by the filer"; no attachments (except Rule 40 (b) emergency motions) | 41 (b) | form below; word count not computed |
| Letter paper; double spacing except block quotations, headings, captions, footnotes; serif proportional 14 pt+ (Times New Roman, Century Schoolbook named) | 2 (c) (1)-(3) | Times New Roman 14 pt (Liberation Serif fallback), footnotes too; body in 32.2 pt line boxes (2 x Word's 16.1 pt single line); headings, quotations, caption, footnotes, tables and signature single (16.1 pt) |
| Margins 1 in; pages numbered with Arabic numerals at the bottom | 24 (c), (e) | 1 in; every page Arabic, cover = 1 (the exemplar uses roman numerals for its front matter; the rule says Arabic) |
| Certification "This submission does not exceed the word count limit imposed by Rule 24." just above the signature block | 24 (f) (1) | **Changed**: the old template printed its own "I certify that this motion contains N words" certificate, which is not the rule's wording. Now the fixed sentence; `word_count` is accepted and ignored |
| Signature with "/s/" typed name underlined, name below; bar number, address, phone, e-mail | 2 (a), 2 (a) (2) (ii) | **Changed**: `signer_line` underlined, optional `signature.name` printed below it |
| Certificate of service, method identified; e-mail prior-agreement certification | 6 (b) (2), 6 (d) | `service.paragraphs` / `recipients` (new, optional) or the generated sentence |
| Emergency motion content (necessity, filed order, notice of appeal) | 40 (b) | content, not template |

## Overlay page map

Ours pages 1-3 pair with filed pages i-iii; pages 4-13 pair with filed pages 5-14; page 14 pairs with filed page 24; pages 15-16 pair with filed pages 25-26; page 17 pairs with filed page 28; page 18 pairs with filed page 27. These are the pairs from the regenerated same-id overlay. The filed motion has 29 pages; the input transcribes pages i-11 and 19-24 as described above.

## Gate 2 review (18 of 18 pages, typst and docx alike: XENG-001..003 PASS)

| Page | Finding |
|---|---|
| 1 | Cover: court, "Case No. ____", caption (names centered, designations from the middle of the line), lower court, title, counsel in two columns (as filed). Two long bar-number lines wrap in the half-width column (tier 3). OK |
| 2 | Table of contents (`toc: true`), levels indented, page column 36 pt. OK |
| 3-4 | Table of authorities: Cases, Statutes, Constitutional Provisions, generated pages; the last entry runs onto page 4. ACCEPTED (natural pagination; rows are half a line apart) |
| 5-7 | Introduction with footnotes 1-2 (14 pt, single-spaced), Jurisdiction. OK |
| 8-10 | Background (bullet list), footnote 3; page 10 ends early because the Argument heading keeps with its text. OK |
| 11-15 | Argument, headings I, A (bold italic, wrapped line hanging), II. OK |
| 16 | Conclusion, Rule 24 certification, date line and signature block (kept together). OK |
| 17-18 | Certificate of service on its own page; the third recipient group moves to page 18 with the conformed signature (kept together), so the signature never stands alone. OK |

## What changed (template `typst/gactapp-motion-brief.typ`)

Separate cover page by default (`cover_page`, default true; both filed exemplars of this court's motions, this one and the Sierra Club reconsideration motion, use one), centred caption, optional `counsel` on the cover; optional `toc` and generated `authorities`; rule wording of the Rule 24 certification; underlined conformed signature; certificate of service from `paragraphs` / `recipients` / `closing`; headings forced to 14 pt; first-line indent on every paragraph; footnotes 14 pt single spaced and counted in the table of authorities.

## Markdown contract

`court`, `case_number`, `lower_court_case` (optional), `parties` (list of `name`, `role`; a `v.` entry with empty role), `title`, `counsel` (optional cover groups of `names` and `lines`, set two to a row in half-width columns; a group without `lines` is a centered line, such as "Counsel for ..."), `cover_page` (default true: the cover on its own page with the counsel), `toc`, `authorities` (as the briefs: `heading`, `entries` of `cite`, `find`), `signature` (`date`, `lines` printed above the /s/ line, `signer_line`, `name`, `signer` lines), `service` (`date`, `doc_type`, `served_on`, `method`, `address` for the generated sentence; or `paragraphs`, `recipients`, `closing`), `word_count` (ignored).

## Engines (fb-595.68.36)

typst and docx are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): first-fit breaking, no kerning, ligatures or hyphenation, exact line boxes (32.2 pt body, 16.1 pt single; twips = 20 x pt), explicit block spaces (a single line above a heading, half a line below; half a line around quotations, between table rows and between footnotes), footnote rule 11.5 pt below the text (with the rule and half a line the 20.1 pt LibreOffice keeps), the page number centered in a 16.1 pt footer line. The face is Times New Roman in both (`data/exemplar-fonts.json`; the template was TeX Gyre Schola after the exemplar, Rule 2 (c) (3) names Times New Roman as compliant).

docx: `docx/reference.xml` (`base="xengine"`, `{font}`, Head 1/2/3, Body Text Note without widow control, the "Page" variants for the body's first block) and `docx/gactapp-motion.lua` on `docx.xengine`, which writes the cover, the contents and authorities, the signature and the certificate of service, and leaves body paragraphs, quotations, lists and footnotes to pandoc in those styles. Page numbers of the tables come from `fb render`'s passes (needles for the cover, each heading and each occurrence of an authority's `find` text in the body and the footnotes; the typst template marks the same occurrences). The row's three spaces before the leader tab are 8 pt in Word (LibreOffice wants about 4.5 pt more than typst before the page column); `)(` is joined and a slash between letters may break, as typst breaks. `make-reference.sh`, `render.sh` and `reference.docx` are gone.

## Gaps

1. Word count not computed or checked against 4,200.
2. Only one conformed signature is underlined; extra signers in `signer` lines are plain text.
3. The table of authorities lists authorities in the order of the frontmatter, not sorted.
