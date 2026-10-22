# Ninth Circuit: appellant's reply brief (`ca9` / `reply-brief`)

Self-contained folder for the reply brief of an appellant or petitioner in this court (FRAP 28(c), Circuit Rule 32-1(b)). It does not share files with the principal brief at the court root (`../typst/`, `../usage/`), which is a separate doc type.

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-reply-brief.pdf` | The filed reply (34 pp., text-based, Garamond embedded). |
| `usage/SOURCE.md` | Where it was fetched from, filer, date filed, date fetched, and the exemplar's known defects. |
| `usage/INPUT-reply-brief.md` | Transcription of the exemplar: cover, related-cases statement, point I.A, introduction and conclusion. A portion, not the whole reply (it is about 1,960 of the reply's 6,998 counted words). |
| `usage/OUTPUT-reply-brief.typst.pdf` | The template's render of that sample (14 pages since the 2026-10-16 pass). |
| `usage/OVERLAY-bl-productions-reply-brief.pdf`, `-overlay.txt` | Red (ours) / blue (filed) overlay, 14 pages, with the page map. |
| `typst/main.typ`, `typst/ca9-reply-brief.typ` | The template. Copied from `../typst/` and changed only where the reply rules differ (see below). |

## Governing rules (verified 2026-10-14)

Primary source: the Ninth Circuit's *FRAP, Ninth Circuit Rules, Circuit Advisory Committee Notes*, effective June 1, 2026, https://cdn.ca9.uscourts.gov/datastore/uploads/frap-June%201%202026.pdf (fetched and searched today). Page numbers below are the handbook's printed pages.

| Rule | What it requires for a reply brief | Where the template does it |
|---|---|---|
| FRAP 28(c), HB p. 110 | Appellant's reply: a table of contents with page references and a table of authorities (cases alphabetized, statutes, other authorities) with the pages of the reply where each is cited. No jurisdictional statement, issues or statement of the case is required. | Always emitted (TOC, TOA). Front matter, body and conclusion are whatever the sample supplies. |
| Circuit Rule 32-1(b), HB p. 141 | A reply brief filed by the appellant may not exceed half the length in (a) (14,000 words), so **7,000 words**. | `let limit = 7000` in `ca9-reply-brief.typ`; the build panics above it. |
| Circuit Rule 32-1(a), HB p. 141 | Principal briefs: 14,000 words (the basis for the half above). | Not used directly. |
| Circuit Rule 32-1(c), HB p. 141; FRAP 32(f), HB p. 140 | Excluded from the count: cover, TOC, TOA, related-cases statement, certificate of compliance, signature block, certificate of service. | The word count is taken from the body only (everything before `# Addendum`). |
| Circuit Rule 32-1(e), HB p. 141; Form 8 | A word-count brief must be accompanied by Form 8. | Certificate of compliance, Form 8 wording, `word_limit_basis` selects the box (`standard` = "complies with the word limit of Cir. R. 32-1"). |
| FRAP 32(a)(1)–(6), HB pp. 138–139; Circuit Rule 32-1(d) | Form: 8½ × 11, one-inch margins, double spacing, 14-point proportional serif, italics for case names. | Same settings as the principal template (see `../rules.md`, CA9-FORM-001 to -005). |
| FRAP 32(a)(2), HB p. 138; Circuit Rule 25-5(c), HB p. 84 | A reply brief's cover is **gray**, on paper copies only when the Court requests them. The electronic PDF has a white cover, as the exemplar does. | Not implemented (see Known gaps). |
| Circuit Rule 28-2.6, HB p. 115; Form 17 | The statement of related cases is required of an initial brief. A reply does not need it. | Emitted only when the metadata has `related_cases`. The exemplar includes one; the sample does too. |
| Circuit Rule 25-5(g), HB p. 85; Form 15 | Certificate of service only when the brief is not served through ACMS. | Opt-in: `service.certificate: true`. Not in this sample. |
| Circuit Rule 25-5(e), (f), HB p. 85 | Searchable text PDF; `s/` signatures. | Text is extracted from the render; signature block `s/ Name`. |

Cross-appeal replies are different: FRAP 28.1(c)(4) and Circuit Rule 28.1-1(d) (HB pp. 118–120) also cap the appellee's reply at half of 14,000 words (7,000), with a gray cover and the Form 8 cross-appeal box. This folder does not cover that filing; see Known gaps.

## Why the exemplar is this, and not a stub

Sweet v. McMahon (the principal-brief exemplar at the court root) is a principal brief; it does not show a reply. This reply is the one usable filed ca9 reply found in the searches below, and it is a real ECF filing (DktEntry 28, 12/01/2023) with the full front matter. Searches tried, in order: CourtListener API search for `type=rd` ca9 "reply brief" (returned docket entries and clerk orders, few PDFs); CourtListener dockets for NetChoice v. Bonta (25-2366; the docket that came back was a 2023 NetChoice appeal), Culture of Life Family Services v. Bonta (25-3828: the reply is DktEntry 25, but the RECAP PDF for it is not on CourtListener), and Pepper v. Apple; Justia docket pages (blocked by Cloudflare from this box); Clearinghouse (blocked by CloudFront from this box); general web searches for ca9 reply-brief PDFs on EFF, ACLU, DOJ and state-AG sites. The filing that worked was counsel's public copy at michellawyers.com, found through a notice-of-errata filing in the same case.

## What the overlay shows

`sh tools/overlay.sh courts/ninth-circuit/court-of-appeals/reply-brief bl-productions-reply-brief` pairs each sample page with the filed page sharing the most words (`-overlay.txt`). Red is our render, blue is the filed page, and black is where they agree. The pairing is by text, so it aligns the cover, TOC, TOA, introduction, the Argument pages, conclusion and Forms 17 and 8 with their filed pages. Word-overlap by page: cover 89%, introduction 95%, argument pages 37–87%. The lower values are where a page carries different text (the TOA pages, and the conclusion page, which the filed brief shows at its own page 30 of 34). The overlay is a diagnostic: the filed brief continues for 21 more pages that the sample does not reproduce, so most of the filed pages have no match.

## Render and page review

*Before the cross-engine port of 2026-10-22, which moved the typst pages (Times New Roman, the root's pitches): the review of the current renders is under "Engines".*

Commands (from the repo root, with `$HOME/tb/bin` on `PATH` for typst, poppler and ImageMagick):

```sh
sh tools/render.sh courts/ninth-circuit/court-of-appeals/reply-brief usage/INPUT-reply-brief.md   # no typst warnings
sh tools/overlay.sh courts/ninth-circuit/court-of-appeals/reply-brief bl-productions-reply-brief
pdftoppm -r 60 -png courts/ninth-circuit/court-of-appeals/reply-brief/usage/OUTPUT-reply-brief.typst.pdf /tmp/p
```

Render: ok (14 pages, typst 0.15.0, vendored EB Garamond, no warnings; rerun 2026-10-16). Overlay: ok (14 pages, rerun 2026-10-16).

Pages reviewed: 14 of 14 (every page rendered at 60 dpi and looked at, 2026-10-16).

| Page | Printed folio | Content | Finding |
|---|---|---|---|
| 1 | none | Cover | Case number, caption, D.C. No. and judge, title, two counsel groups each with its phone. One page. |
| 2 | i | Table of contents | Entries and page numbers match the body (Argument 2, Conclusion 8, Related cases 9, Certificate 10). The exemplar also lists the TOC and TOA themselves; this one does not. |
| 3 | ii | Table of authorities | Cases, Constitutional Provisions, Statutes; pages match the citations. |
| 4 | iii | Table of authorities (cont.) | Rules, Other Authorities. |
| 5 | 1 | Introduction | Double-spaced, 14 pt. Ends mid-sentence, as the filed introduction does. |
| 6 | 2 | Argument I, A | Point heading centered; sub-heading A hangs with its label. |
| 7–8 | 3–4 | Argument, footnotes 1 and 2 | Footnotes 14 pt, marked, with links into the table of authorities. |
| 9–10 | 5–6 | Argument | Short-form citations (*Id.*, *Bruen*, *Teixeira*, B&L Orange Cnty.) italic. Block quotation indented and single-spaced. |
| 11 | 7 | Argument | Continues to the last paragraph of I.A. |
| 12 | 8 | Conclusion, signature | Signature block kept with the last paragraph. |
| 13 | 9 | Statement of Related Cases (Form 17) | Selected box drawn, pending case listed. |
| 14 | 10 | Certificate of Compliance (Form 8) | "complies with the word limit of Cir. R. 32-1" checked. Counted words 1,964 (the sample's count, not the filing's). |

Defects found in the review and fixed: an Argument sub-heading was typed at level 2, which made it a point (II) instead of sub-heading B (fixed in the sample; the sample now stops at I.A). The counsel block printed one phone number for both counsel groups (fixed: each group carries its own `phone`).

## Known gaps

- **Cover color.** The reply's cover is gray (FRAP 32(a)(2)), on paper copies only (Circuit Rule 25-5(c)). The template produces the white electronic cover, as the exemplar does.
- **Second signature.** The filed brief has two signature blocks (Barvir for Michel & Associates; Kilmer for the Second Amendment Foundation). The template takes one `signature`. The sample has Barvir's only.
- **Cover layout.** The filed cover sets the two counsel groups side by side. The template stacks them.
- **Table of contents.** Lists the Argument and its sub-headings, the conclusion and the certificates; not the TOC and TOA themselves, which the exemplar lists.
- **Certificate of service** is supported (`service.certificate: true`) but not exercised by this sample.
- **Cross-appeal replies** (FRAP 28.1(c)(4), Cir. R. 28.1-1(d)) and the appellant's response-and-reply brief (FRAP 28.1(c)(3), 14,000 words) are different filings. They are not built here.
- **Sample is a portion** (point I.A, introduction, conclusion and certificates). The filed reply is 6,998 counted words in 24 body pages; the exemplar's own introduction stops mid-sentence and the errata notice (DktEntry 31) adds two missing words to it. The sample keeps the filed text, including that.
- **Checks:** `tools/check.sh` runs the default checks (`data/checks-default.yaml`) and Gate 4 on this folder (see "Engines"); the CA9-* checks of `../checks.yaml` are the principal brief's contract and are not machine-checked here.

## Engines

The same markdown renders through three engines, on the cross-engine layout model of the court root (docs/EVAL-LOOP.md, "Cross-engine gate"; ported in fb-595.54.4, 2026-10-22). Typst (`typst/`) is the reference; the LaTeX and Word renders break every line and every page where it does, and Gate 4 gates that (`params.cross_engine: gate` in `eval.yaml`).

| Engine | Output (`usage/`) | `tools/check.sh --engine …` |
|---|---|---|
| typst | `OUTPUT-reply-brief.typst.pdf` (14 pp) | RESULT: 8 checks passed, 0 failed (XENG: reference, SKIP) |
| latex | `OUTPUT-reply-brief.latex.pdf` (14 pp) | RESULT: 11 checks passed, 0 failed (XENG-001..003 PASS, 302 of 302 lines) |
| docx | `OUTPUT-reply-brief.docx`, `.docx.pdf` (14 pp) | RESULT: 12 checks passed, 0 failed (XENG-001..003 PASS) |

```sh
sh tools/render.sh --engine typst|latex|docx courts/ninth-circuit/court-of-appeals/reply-brief usage/INPUT-reply-brief.md
sh tools/check.sh courts/ninth-circuit/court-of-appeals/reply-brief --engine typst|latex|docx
```

**The port.** The three templates are copies of the court root's, which pass the gate (`../typst/ca9-brief.typ`, `../latex/template.tex` and `ca9.lua`, `../docx/ca9.lua` and `make-reference.sh`), changed only where the reply brief differs:

- *all engines:* the 7,000-word limit (Circuit Rule 32-1(b)) stops the build; the Statement of Related Cases only when the metadata has `related_cases` (Circuit Rule 28-2.6); a footnote is never split across pages (typst `keep-together`, LaTeX `\interfootnotelinepenalty=10000`, Word's Footnote Text style keeps its lines).
- *typst:* the word count drops emphasis underscores before it reads backslash escapes, so the escaped blanks of "\_\_ U.S. \_\_" are words, as the pandoc engines count them (1,965; it was 1,964).
- *latex:* a counsel group's own `phone` after its lines (the last group without one takes the brief's `phone`, as the typst cover does); the table of authorities sorts by the citation as written (the inline rules bind "§" to its number with a no-break space, which the sort key dropped); an ellipsis (U+2026) set as one 1 em glyph whose PDF text is the character ("Amendment….”" and "exchange … products"; T1 newtx has no such glyph and `\ldots` put three periods into the text).
- *docx:* `docx/reference.docx` rebuilt by `docx/make-reference.sh` on `lib/docx/xengine-reference.sh` (Times New Roman 14 pt; before, EB Garamond); the cover, tables, signature, Form 17 and Form 8 are built (before: BLOCKED, pandoc's body only).

Typst moved with the port (it is the reference, so every page was looked at again): Times New Roman 14 pt (was EB Garamond), the root's line pitches (29.4 pt body, 17 pt single, 20 pt section headings), contents and authorities rows with the page column, no kerning or ligatures. Before the port: latex 12 vs 14 pages, 59.3 % of lines alike; docx 12 vs 8 pages, 5.4 %.

**Page review of the port (2026-10-22).** All 14 pages of the typst PDF and of the latex and docx PDFs were rendered at 50 dpi and looked at side by side (the ellipsis at 150 dpi). PDF page | content | finding:

| PDF page | Content | Finding |
|---|---|---|
| 1 | Cover | OK. One page; caption, D.C. No. and judge, title, two counsel groups each with its own telephone. The gaps between the cover's parts differ a little between engines; every line breaks alike. |
| 2 | Table of contents (i) | OK. Argument I and I.A, conclusion, Form 17 and Form 8 with their pages. |
| 3 | Table of authorities (ii) | OK. Cases italic; constitutional provisions; statutes. A page list wider than the 56 pt column ("3, 4, 5, 6, 7") widens its own row; its leader then runs up to the list. |
| 4 | Table of authorities (iii) | OK. Rules; other authorities. |
| 5 | Introduction (1) | OK. Ends mid-sentence, as the filed introduction does. |
| 6 | Argument; point I; sub-heading A (2) | OK. |
| 7-8 | Argument; footnotes 1 and 2 (3-4) | OK. Each footnote whole on its page, single-spaced, 14 pt. |
| 9-11 | Argument; block quotation (5-7) | OK. Page 5 ends a line early: the next paragraph's first line may not stand alone at the foot of a page (no orphans), the same in every engine. |
| 12 | Conclusion; signature (8) | OK. |
| 13 | Statement of Related Cases (Form 17) | OK. The pending-case box checked; the case listed. |
| 14 | Certificate of Compliance (Form 8) | OK. 1,965 words in every engine. |

Open (tier 2, not changed): in Word the leader runs up to the page number (the right indent and tab, the root's design), in typst and LaTeX it stops three spaces short of the page column; the relationship text of the related case ends in a period inside the parenthesis, so the line reads "together.)." (sample text, tier 3).

## Verification pass 2026-10-16 (fb-595.26.9)

- **Rendered:** `sh tools/render.sh` on the committed sample first gave 13 pages, the same as the committed PDF, and exit 0 with no typst warnings. After the sample fix below it gives 14 pages, also exit 0 with no warnings. The PDF embeds only the four EB Garamond faces.
- **Viewed:** all 14 pages of the typst PDF at 60 dpi, the exemplar's page 1 beside our cover, and all 14 overlay pages (at 40 and 150 dpi).
- **Overlay:** rerun with `sh tools/overlay.sh`. Our p.1 ↔ filed p.1 (89%), p.5-8 ↔ filed p.7-10 (69-95%), p.13-14 ↔ filed p.32-33 (Forms 17 and 8, 73-81%). The two TOA pages both pair with filed p.5 (23-25%). Body pitch and margins match the filed pages.
  - Tier-2 differences, not changed: the filed Forms 17 and 8 use the court's form layout (form title, instructions URL, form footer). The filed signature block names the firm and the represented parties. The filed cover sets the two counsel groups side by side.
- **Defect found and fixed (sample transcription, not template):** the table of authorities left out authorities that the transcribed text cites and that the exemplar's TOA lists:
  - Assembly Bill 893;
  - Fed. R. Civ. P. 12 (the `frcp12` entry existed but nothing linked to it);
  - the First and Second Amendments.

  FRAP 28(a)(3) requires each authority with the pages where it is cited. They are now `toa:` links. The amendments are under Constitutional Provisions, where the exemplar puts them under Other Authorities. The TOA runs to two pages (ii-iii), so the PDF is 14 pages. The body page numbers and the TOC are unchanged.
  - Stale statement corrected: the old page table said the TOA had a Rules group. The old render had none.
- **Template:** no change.
- **LaTeX:** rebuilt with `sh tools/render.sh --engine latex` (exit 0, 14 pages, the same page count as typst, EB Garamond only). Pages 1-4 (cover, TOC, TOA) were viewed this pass; the TOA groups and page numbers match typst. Pages 5-14 of the latex PDF were not viewed this pass.
- **Remaining gaps:** as listed under Known gaps (excerpt sample, one signature, stacked counsel groups, cover colour). Also, the Forms 17 and 8 are not in the court's form layout. DOCX is untouched (no `soffice`).

Reference styles (2026-10-22, fb-595.54.4): `docx/make-reference.sh` and the committed `docx/reference.docx` are replaced by `docx/reference.xml`, from which fb render builds the reference (`tools/fb/src/docxref.rs`, as master's fb-595.63 folders do); its styles are XML-identical to the old reference's, theme-font attributes stripped. Every `.docx.pdf` re-rendered byte-identical; `check.sh --engine docx` 0 failed, XENG-001..003 PASS.
