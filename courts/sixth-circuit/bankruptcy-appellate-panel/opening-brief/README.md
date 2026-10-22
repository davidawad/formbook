# U.S. Bankruptcy Appellate Panel of the Sixth Circuit (bap6): opening brief (appellant's brief)

Doc type `opening-brief` of `courts/sixth-circuit/bankruptcy-appellate-panel`. Self-contained: the court-root `typst/` and `usage/` are not touched.

**Exemplar: yes.** Appellants' Brief, filed 2019-07-31, 38 pages, *In re Chieftain Steel, LLC, et al.*, BAP No. 19-8005 (see "Exemplar" below and `usage/SOURCE.md`).

| Gate | Result |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-opening-brief.pdf` |
| render | ok: `sh tools/render.sh courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief usage/INPUT-opening-brief.md` ran with typst 0.15.0 (vendored fonts), produced `usage/OUTPUT-opening-brief.typst.pdf` (13 pages), zero warnings |
| overlay | ok: `sh tools/overlay.sh courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief chieftain-steel-19-8005` wrote `usage/OVERLAY-chieftain-steel-19-8005.pdf` (13 pages) and `.txt` |
| pages reviewed | 13 of 13 rendered pages viewed as PNG (70 dpi); overlay pages viewed as pairs (80 dpi) |

## Files

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-opening-brief.pdf` | The filed brief, public, with a text layer. |
| `usage/SOURCE.md` | URL, case, docket, filer, date filed, date fetched, SHA-256. |
| `usage/INPUT-opening-brief.md` | Transcription of the filed brief (see "Exemplar"). |
| `usage/OUTPUT-opening-brief.typst.pdf` | `tools/render.sh` output. |
| `usage/OVERLAY-chieftain-steel-19-8005.pdf`, `.txt` | `tools/overlay.sh` output: red = ours, blue = filed, black = both. The `.txt` maps each of our pages to its best-matching filed page. |
| `typst/main.typ`, `typst/bap6-opening-brief.typ` | Entry point and template. |

Build (from the repo root, toolchain on PATH): `sh tools/render.sh courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief usage/INPUT-opening-brief.md`. The render uses only the vendored Times New Roman (`--ignore-system-fonts`); any typst warning fails it.

## Governing rules

Verified 2026-10-14. Sources: Fed. R. Bankr. P. 8014 and 8015 (amended eff. Dec. 1, 2024), read at `https://www.law.cornell.edu/rules/frbp/rule_8014` and `https://www.law.cornell.edu/rules/frbp/rule_8015`; BAP Local Rules, "As Amended December 1, 2014" (`https://www.ca6.uscourts.gov/sites/ca6/files/documents/bap/BapLocalRules.pdf`, read as extracted text); BAP Practice Guidelines, Rev. August 2018 (`https://www.ca6.uscourts.gov/sites/ca6/files/documents/bap/2018%20BAP%20Practice%20Guidelines%20.pdf`).

| Requirement | Rule | Where in the template |
|---|---|---|
| Cover: case number, court, case title, nature of the proceeding and court below, the brief's title naming the party, counsel's name, address and phone | FRBP 8015(a)(2) | `cover` |
| Corporate disclosure statement, when required | FRBP 8012; 8014(a)(1) | `disclosure` page, only when given |
| Table of contents with page references | FRBP 8014(a)(2), (c) | `toc-section` |
| Table of authorities (cases alphabetical, statutes, other) | FRBP 8014(a)(3), (c) | `toa-section` |
| Statement regarding oral argument, one page at most, after the TOA | FRBP 8019(a); LBR 8014-1(b) | `oral_argument` page |
| Typeface: proportionally spaced serif, 14-point or larger; plain roman, case names italic | FRBP 8015(a)(5)(A), (a)(6) | `font-family`, `type-size`, `brief-style` |
| Double spacing; margins at least one inch | FRBP 8015(a)(4); LBR 8014-1(d) | `pitch-double`, `page-margin` |
| Word limit: 13,000 words, or 6,500 for a reply | FRBP 8015(a)(7)(B) | `word-limit`, checked by `brief` |
| Words excluded from the limit | FRBP 8015(g) | `count-words` runs over the body only |
| Certificate of compliance (word count and typeface) | FRBP 8015(h) | "Certificate of Compliance" |

**Conflict: type size.** LBR 8014-1(d) (2014) says "a font not less than 12 points". FRBP 8015(a)(5)(A) (restyled eff. Dec. 1, 2024) says a proportionally spaced face "must be 14-point or larger". The template uses 14 point. The federal rule is taken to govern the local one. That choice is ours, not a ruling; David should confirm it. The Practice Guidelines (§ VI(c)) repeat the 12-point figure and predate the 2024 rule.

**Calibration: double spacing.** Measured on the render with `pdftotext -bbox`: a line in this font advances `0.65em` plus the paragraph `leading`. Single spacing is therefore `1.3em` (18.2 pt at 14 pt) and double is `2.6em` (36.4 pt). `body-leading` is `1.95em`, and paragraph `spacing` equals `body-leading`, so paragraph breaks keep the same 36.4 pt pitch. Consecutive body lines measure 36.4 pt apart. Since the cross-engine port (fb-595.54.3) these pitches are set directly as line boxes: `pitch-double` 36.4 pt, `pitch-single` 18.2 pt (`lib/typst/xengine.typ`).

Required body sections (FRBP 8014(a)(4)-(9), checked by the build): Statement of Jurisdiction, Statement of the Issues, Statement of the Case, Summary of Argument, Argument, Conclusion. Required: a statement regarding oral argument.

## Markdown contract

One `.md` file: YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover, "Case No." line |
| `caption` | yes | list of two sides, each `names` (list) and `designation`; "v." is inserted between them |
| `proceeding` | yes | Cover: nature of the proceeding and the court below |
| `brief_title` | yes | Cover title, printed in capitals (FRBP 8015(a)(2)) |
| `counsel` | yes | list of groups, each `names` and `lines` |
| `phone` | yes | Cover, after counsel |
| `signature` | yes | `signer` and `lines`; printed as "s/ Name" after the body and on each certificate |
| `date` | no | Under the signature and on the certificate of service |
| `disclosure` | no | Corporate disclosure statement (FRBP 8012, through 8014(a)(1)); a page before the TOC when given |
| `oral_argument` | yes for opening; optional for answering (see Template changes) | Statement regarding oral argument, after the TOA (LBR 8014-1(b)). Not used for a reply. |
| `authorities` | yes if the body cites any | Registry: key → `kind` (case, constitution, statute, regulation, rule, other), `name` (optional), `cite`, `sort` (optional). A `[text](toa:KEY)` link with no registry entry stops the build; a registry entry never cited stops the build. |
| `service` | no | `true` adds a certificate of service |

Body: `# Heading` (level 1) sections; `##`, `###`, `####` below. Heading numbers are typed by the author (the template does not number them). Required sections are checked and the build stops when one is missing. `# Addendum` ends the brief: it is rendered after the certificates and is not counted. Footnotes are not supported. Words are counted over the body (headings included, FRBP 8015(g)); the build stops above the limit.

## Exemplar

Filed by counsel of record in the case. Appellants' Brief, filed 2019-07-31, 38 pages. *In re Chieftain Steel, LLC, et al.*, BAP No. 19-8005 (appeal from Bankr. W.D. Ky., Originating Case No. 16-10407). Copy: `usage/FILED-EXAMPLE-opening-brief.pdf`; source, dates and hash in `usage/SOURCE.md`.

Transcription (`usage/INPUT-opening-brief.md`) covers, in the filed order: the filing's cover, disclosure, oral-argument statement (verbatim), jurisdictional statement, issues, statement of the case (pp. 1–6, abridged), standard of review, summary, the start of the argument and Part I (pp. 7–12, abridged), and the conclusion (p. 17).

Not transcribed: Part II and the rest of Part I (pp. 13–16), the addendum (pp. 26–38), and the filed table of contents and table of authorities (the template generates both). The filed certificate of service is replaced by the template's own.

Frontmatter (`caption`, `counsel`, `signature`, `date`, `disclosure`, `oral_argument` where the filing has them) copies the filed cover. The template's own certificate of compliance and certificate of service follow the body.

## How the exemplar was found (2026-10-14)

- Web search (standard, then extended) for BAP appellate briefs in this court. The first filed brief in this court that the search returned was the appellants' brief in No. 19-8005, on law.uky.edu.
- The file names on law.uky.edu follow one pattern, `19-8005 <Document>.pdf`. The other two briefs were fetched by that pattern. Each PDF was checked with `pdfinfo` and `pdftotext`: caption, BAP No., ECF header and filing date match.
- Ruled out before this: CourtListener API (no response from the sandbox) and HTML search (HTTP 403); Justia dockets (HTTP 403); general BAP results (local rules, practice guidelines, the pro se form, opinions). None gave a filed brief.

## Template changes (this pass)

The overlay and the page renders exposed these. All three templates changed the same way, so they stay in step.

1. **Cover spacing.** The opening cover ran onto a second page (the date line). Gaps tightened: caption stack 1.1em to 0.9em, counsel groups 1.2em to 0.9em, the gap before the date 1.4em to 0.8em. The cover is one page in all three.
2. **TOC entries.** Dot leaders were a single line, so a long entry that wrapped left its page number on a line of its own. Entries are now a two-column grid with the page number in the right column. The dot leaders are gone, and wrapped lines stay flush left.
3. **Oral-argument statement.** Required for the opening brief only. The filed appellee's brief in this case has none, so the answering template no longer demands one; it prints the section when the frontmatter has `oral_argument`. The reading of LBR 8014-1(b) is not verified against the rule text (the README's Governing rules say so); David to confirm.

## Page review (Gate 2)

Every page of `usage/OUTPUT-opening-brief.typst.pdf` (13 pages) was rasterised at 70 dpi and viewed, one page at a time, after the last template change. The overlay pages were viewed as pairs. Findings:

2026-10-22 (fb-595.54.3, cross-engine port): every page of the new typst render and of the docx render (13 each) rasterised at 50 dpi and viewed side by side; same lines, same page breaks; the cover now fits its page with the counsel block after a fixed 36.4 pt gap (it was pinned to the foot of the page with `v(1fr)`, which Word cannot set), and the TOC rows carry dot leaders (`listing-row`).

- **Overlay: cover overflow.** The date line ran onto page 2. Fixed in the template (see Template changes).
- **Case names not italic.** The certificate of compliance says case names are in italics; the body was not. Fixed in the transcription.
- **Heading names.** The filing says "JURISDICTIONAL STATEMENT" and "STATEMENT OF ISSUES". The build checks for the names in the template ("Statement of Jurisdiction", "Statement of the Issues"), so the sample uses those.
- **Pages 2 to 12** were checked for spacing, heading placement and page numbers; no further defect.
- **ACCEPTED: cover layout.** The filed cover sets the caption and counsel in a different arrangement. Layout style, not a rule requirement.

## Known gaps

- Table of authorities page references come only from `toa:` links the author places in the body. Nothing checks that every citation is linked.
- Heading numbers are the author's to type.
- The one-page limit on the oral-argument statement (LBR 8014-1(b)) is not measured.
- The 30-page limit (FRBP 8015(a)(7)(A)) is not checked. The word limit (8015(a)(7)(B)) is, and it is the limit that applies when a brief uses the word count.
- The addendum and footnotes are not exercised (no footnotes in the template).
- The certificate of service wording is ours (CM/ECF convention). It is not taken from a rule text that was read.
- The rule text was read through the Legal Information Institute page for FRBP 8014 and 8015 (fetched 2026-10-14), which returns a summary, not the official PDF. Check the wording against the official text before relying on a quoted phrase.
- **One case for all three.** Every exemplar is from BAP No. 19-8005. The opening and reply briefs share a filer group (Dinsmore & Shohl, BGD, Fox, Phoenix); the answering brief is UCB's. The tier-2 standard (two or three filed exemplars from different filers) is not met for any doc type. A second filed brief of each type from another BAP case would meet it.
- **Abridged transcription.** The sample transcribes part of the filed brief (see "Exemplar"). Filed pages that are not transcribed show as blue-only text in the overlay.
- **Certificate of compliance.** None of the filed briefs has one. The template's certificate follows FRBP 8015(h) as the README reads it; it is ours, not the exemplar's.

## Engines

Two engines: typst (the reference) and docx. There is no latex engine for this court.

**Cross-engine layout model** (fb-595.54.3; `docs/EVAL-LOOP.md`, "Cross-engine gate" and its adoption checklist). The typst template applies `lib/typst/xengine.typ` (first-fit breaking, no kerning, ligatures or hyphenation, every line a box of its pitch with the baseline at 0.8 of it, block spaces in pt that collapse to the larger); the docx engine sets the same boxes with Word's exact line spacing. The pitches are this folder's calibration (see "Calibration"): body 36.4 pt (`pitch-double`), single 18.2 pt (`pitch-single`), level-1 headings 19.5 pt type in 24 pt boxes, level-2 headings 17 pt type in 20 pt boxes, the cover title 16 pt. The table of contents and of authorities set each entry with `listing-row`: the text wraps before a page column (36 pt contents, 56 pt authorities) and a dot leader runs from three spaces after the text to the page. `eval.yaml` sets `params.cross_engine: gate`: `tools/check.sh --engine docx` fails unless the docx PDF has typst's page count, starts and ends every page on typst's words and breaks every line after typst's word (XENG-001..003).

Docx engine (`docx/`, built per `docs/EVAL-LOOP.md` "Engines"). `docx/reference.xml` holds the Word styles, from which fb render builds `reference.docx` on pandoc's default reference (`tools/fb/src/docxref.rs`): the recipe of `lib/docx/xengine-reference.sh` (Times New Roman 14 pt, Body Text 36.4 pt exact with a half-inch first-line indent, First Paragraph without it, single 18.2 pt, theme fonts stripped so Times New Roman is the only face embedded, fb-595.63), plus the "Bap Line" and block-quotation styles. Body paragraphs end 2 twips (0.1 pt) short of the margin: LibreOffice sets a body line up to about 0.1 pt narrower than typst (its glyph positions are rounded), and without this a line typst fills to within that much of the margin took one more word (reply brief p. 8). `docx/bap6-brief.lua` writes the cover, the front matter, the headings, the signature block and the certificates as paragraphs with typst's spaces in twips, the body through pandoc with `lib/docx/xengine.lua`'s break rules (a paragraph that follows another is indented, as in typst). The filter also writes the sections (cover: no footer; front matter: lower roman from i; brief: arabic from 1, `FORMBOOK_FINAL`) and the page-number footer (`FORMBOOK_FOOTERS`, the number in a line box of the single pitch). There is no `docx/render.sh`: the TOC and TOA page numbers (FRBP 8014(a)(2)-(3)) come from fb render's multi-pass docx engine (`tools/fb/src/docxpass.rs`, `docxpages.rs`; fb-595.63): the filter writes a needle for every heading (its text and what follows it) and every citation (from the last word of its link text, so a citation that runs over a page end counts on the page where the link text ends, as typst records it), fb render finds them in the LibreOffice PDF and renders again with those pages until they settle; `passim` from 7 pages. Build: `sh tools/render.sh --engine docx courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief usage/INPUT-opening-brief.md`. Needs pandoc, LibreOffice (`soffice`) and poppler.

**Result** (2026-10-22): `tools/check.sh --engine typst` 8 passed, 0 failed; `--engine docx` 12 passed, 0 failed, XENG-001..003 PASS (13 pages, every line of the typst render broken alike). Every page of both PDFs was rendered at 50 dpi and viewed side by side after the last change. Word count in the certificate of compliance: 1,093 on both engines.

**Differs from typst (not gated):** the dot leader of a TOC or TOA row runs to the page number in Word (a right tab beyond the right indent) and stops at the page column in typst; the footer's page number sits a few points apart. Line breaks, page breaks and the text are the same.

**Not verified:** opening the .docx in Microsoft Word itself (only LibreOffice converts it here); Word computes no fields in this document, so its page numbers are the ones fb render wrote from the LibreOffice PDF.

[Formbook index](../../../../README.md) | [Court README](../README.md)
