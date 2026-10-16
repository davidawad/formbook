# Federal Circuit (cafc): reply brief

Doc type: **reply-brief**. Court: Court of Appeals for the Federal Circuit (`cafc`).

Status: exemplar found (`exemplars/`); template, sample, render and overlay built; all 13 rendered pages reviewed (see "Page review"). Not a court-level deliverable: the court-root `typst/` and `samples/` are untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, calls the template. |
| `typst/cafc-reply-brief.typ` | Template: `cafc-reply-brief(meta, md)`. Content-agnostic; every number is a rule or a stated style choice. |
| `samples/INPUT-gem-reply-brief.md` | Markdown transcription of the exemplar: frontmatter (cover, counsel, signature, Form 19 data, authorities) and a body of Argument I.A through the block quotation, then the full Conclusion. |
| `samples/OUTPUT-gem-reply-brief.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-appeals/reply-brief samples/INPUT-gem-reply-brief.md` (13 pages). |
| `samples/OVERLAY-gem-reply-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/federal-circuit/court-of-appeals/reply-brief gem-reply-brief` (red = ours, blue = filed, black = both). |
| `exemplars/FILED-EXAMPLE-gem-v-rupp-marine-2026-1817-reply-brief.pdf` | The filed exemplar. |
| `exemplars/SOURCE.md` | Where the exemplar came from (URL, docket, filer, dates). |

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/federal-circuit/court-of-appeals/reply-brief samples/INPUT-gem-reply-brief.md
sh tools/overlay.sh courts/federal-circuit/court-of-appeals/reply-brief gem-reply-brief
```

Typst runs with `--ignore-system-fonts` and the vendored EB Garamond; any warning fails the render (`tools/render.sh` enforces it). The render was verified to exit 0 with no warnings.

## Governing rules

Verified 2026-10-14. Each row gives the rule, what the template takes from it, and where the text came from.

| Rule | What it requires here | Source and verification |
|---|---|---|
| FCR 32(a)(1) | Cover carries the official caption from the clerk ("No. ...", "United States Court of Appeals For the Federal Circuit", party caption, appeal line). | Quoted in the court's *Common Filing Errors* (March 2026), https://www.cafc.uscourts.gov/wp-content/uploads/RulesProceduresAndForms/FilingResources/CommonFilingErrors.pdf. Fetched and text-extracted 2026-10-14. |
| FCR 32(b)(1) | Reply brief limit: **7,000 words**. The template panics above that. | Principal-brief limit of 14,000 words is confirmed by the same guide. The 7,000 reply figure is from a third-party mirror, https://www.courtrules.net/courts/federal/court-of-appeals-federal-circuit/local-rules/rule-32 (the mirror returned 403 on fetch; figure from search summary). **Not confirmed against the official text.** |
| FCR 32(b)(2) | Items exempt from the count (cover, TOC, TOA, signature block, certificates). The count is the markdown body only, so those are excluded by construction. | Cited in the Form 19 instructions and the filing guide. |
| FCR 32(b)(3) | A certificate of compliance is required; the form is Form 19. | Filing guide, same source as FCR 32(a)(1). |
| FRAP 32(a)(4) | Margins at least one inch on all four sides. | Cornell LII, https://www.law.cornell.edu/rules/frap/rule_32 (page amended through the 2024 note; rule text dated Dec. 1, 2019 amendment). Fetched 2026-10-14. |
| FRAP 32(a)(5)(A) | Proportionally spaced serif face, 14-point or larger, everywhere (footnotes and headings included). | Same. Checked with `pdffonts`: only EB Garamond is embedded. |
| FRAP 32(a)(6) | Plain roman with italics or bold for emphasis; case names italicized. | Same. |
| FRAP 32(f) | Headings, footnotes and quotations count toward the limit; the cover, TOC, TOA, signature block and certificates do not. | Same. |
| FRAP 32(a)(7)(B)(ii) | Reply half of the principal limit (6,500). **Overridden** by FCR 32(b)(1) (7,000). | Same. |
| FCR 32(j) (proposed) | Would forbid "passim" in the TOA. Notice dated July 17, 2026; effective **Dec. 1, 2026 if adopted**; comments due Aug. 17, 2026. | Court's proposed-amendments PDF, July 2026, https://www.cafc.uscourts.gov/wp-content/uploads/RulesProceduresAndForms/FederalCircuitRules/FCRProposedAmendments-PublicCleanCopy-July%202026.pdf. Not in force today. The template never prints "passim": every page is listed. |
| Form 19 | Certificate of compliance wording and the proportional-typeface box. | Wording taken from the exemplar's Form 19 (form dated July 2020 on its face). The word count is computed from the sample. |
| Certificate of service | "I hereby certify that on [date], I electronically filed the foregoing [title], with the Court's CM/ECF filing system, which constitutes service, pursuant to Fed. R. App. P. 25(c) and Fed. Cir. R. 25(a)." | Exemplar wording. **FRAP 25(c) and FCR 25(a) are cited as the exemplar cites them; not independently verified.** |

Cover colour: no cover-colour requirement was found in the sources above, and the exemplar is plain white. The template is plain white. Not verified against the official rule text.

Court sections not in the brief: reply briefs have no jurisdiction, issues, or statement of the case sections (the exemplar opens with Argument), and the Statement of Related Cases / Certificate of Interest is filed separately and is not part of this template.

## Template decisions

- Section numbering as the filed exemplar: `I. ARGUMENT`, `A.`, `i.`, `1.`, `a.`; `II. CONCLUSION`. Tables and certificates are unnumbered.
- Page numbering: cover unnumbered; TOC and TOA in roman; body from 1, through the signature, then Form 19 and the certificate of service, as in the exemplar.
- Table of authorities: built from `toa:` links in the body. Every page is listed; "passim" is not used (see FCR 32(j) above).
- Signature block: kept whole (it is about 27 single-spaced lines with three signers). When the Conclusion ends near the foot of a page, the signature block starts its own page, as the filed exemplar does.

## Page review

Every page of `samples/OUTPUT-gem-reply-brief.pdf` (13 pages) was rendered at 60 dpi (`pdftoppm -r 60`) and viewed, PDF pages 1–13. Page numbers below are PDF page numbers.

| PDF page | Finding | Action |
|---|---|---|
| 1 cover | Caption, appeal line, title and counsel fit one page. The firm name "TAFT STETTINIUS & HOLLISTER, LLP" wraps to a second line in each half-width column at 14 pt. | Accepted (see known gaps). |
| 2 TOC (i) | Headings and page numbers right. The TOA heading was listed in the TOC. | Fixed: TOA heading is `outlined: false`. |
| 3 TOA (ii) | Three cases, page numbers 2, 4, 5 matching the body. | None. |
| 4–8 body | Italics for case names and signals; footnotes at 14 pt at the foot of their page; block quotation indented single-spaced. | None. |
| 9 body | Argument ends; "II. CONCLUSION" heading and its first paragraphs. | None. |
| 10 body | Conclusion continues to its last paragraph; the signature block does not fit below it. | Signature kept whole (next page). |
| 11 signature | Signature block whole on its own page: three signers, counsel line. | Fixed: earlier version split the block across two pages. |
| 12 Form 19 | Word count computed as 1,455. Proportional box drawn; the other two options blank. | Fixed: blank lines escaped (typst treats underscores as markup and warned). |
| 13 service | Date, `/s/` line and counsel block correct. | None. |

Overlay (`samples/OVERLAY-gem-reply-brief.txt`): pages pair with the exemplar's pages by word overlap. Body PDF pages 4–8 pair with exemplar pages 5–9 (the Argument, 100%, 82%, 75%, 55%, 50%). The Conclusion (PDF page 9) pairs with exemplar page 36 (the Conclusion), the signature (page 11) with exemplar page 37 (the signature block), Form 19 (page 12) with exemplar page 38, and the service certificate (page 13) with exemplar page 39. PDF pages 2 and 3 (TOC, TOA) show low overlap, as expected: the exemplar's own TOC and TOA list different entries. PDF page 10 pairs weakly (27%) because the sample's last paragraph falls on a page of its own in our layout.

## Known gaps

- **Partial transcription.** The sample transcribes Argument I.A through the block quotation, and the full Conclusion. The exemplar has Argument I.B through I.G, which are not transcribed. Emphasis that is not a case name (for example, the "(emphasis added)" italics in the exemplar) is not transcribed.
- **No addendum.** The template has no addendum handling. A reply brief rarely has one; add it if a filing needs it.
- **Cover firm-name wrap.** The firm name wraps to a second line in each half-width counsel column at 14 pt. Cosmetic; the text is correct.
- **Signature page can stand alone.** If the Conclusion ends near the foot of a page, the signature block starts its own page, as the exemplar does.
- **Cover colour not verified** (see Governing rules).
- **FCR 32(b)(1) reply limit** rests on a third-party mirror (see Governing rules). Confirm against the official rules before relying on the 7,000 limit.
- **FCR 32(j) passim ban** is proposed, not in force. The template avoids passim, which satisfies both versions.
- **No `tools/check.sh` gates for this folder.** The folder has no `checks.yaml`; its validation is the render (no warnings), the font check (only EB Garamond embedded, from `pdffonts`), the page review above, and the overlay.

## Engines

The typst template is the reference. The LaTeX and docx engines are built from the same markdown contract (`docs/EVAL-LOOP.md`, "Engines").

| Engine | Files | Output (`samples/`) | Pages |
|---|---|---|---|
| typst (reference) | `typst/` | `OUTPUT-gem-reply-brief.pdf` | 13 |
| latex | `latex/template.tex`, `latex/cafc.lua`, `latex/render.sh` (tectonic; the counsel block is a two-column table, `-M counsel_columns=true`) | `OUTPUT-gem-reply-brief.latex.pdf` | 13 |
| docx | `docx/reference.docx` (`docx/make-reference.sh`, `docx/styles.xml.in`), `docx/cafc-docx.lua`, `docx/render.sh`, `docx/pages.sh` | `OUTPUT-gem-reply-brief.docx` and `.docx.pdf` | 13 |

**Matches the typst layout:** 14 pt EB Garamond, double spacing at the typst pitch (31.43 pt); 1 in margins; the cover with the counsel in two columns; the contents and authorities with page numbers; the Roman section headings (I. ARGUMENT, II. CONCLUSION) and the A./i./1. sub-headings; the certificate of compliance (Form 19 wording, box checked) and the certificate of service; the footers.

**Differs from the typst layout:**

- The signature block is kept whole, as typst keeps it, and is not joined to the last paragraph of the conclusion. When the block does not fit on the page, it starts a page of its own (latex: page 11; docx: page 11, the conclusion beginning on page 9 and its last paragraph on page 10). This is the typst reply module's own arrangement.
- docx contents and authorities are static text with page numbers from a LibreOffice render (see the opening brief's Engines note for the limits).
- The reply's certificate of service is printed for every reply (typst prints it unconditionally too).

**docx items not verified:** not opened in Word; converted with LibreOffice only.

**Status:** latex render ok; docx render ok. No gate was run (no `checks.yaml` or `check.sh` for this court in this snapshot). The page review is visual.

**Pages viewed:** all 13 pages of the latex render and all 13 of the docx render, at 30 to 40 dpi, in the final state.


## Verification pass 2026-10-16 (fb-595.26.13)

- Rendered: `sh tools/render.sh courts/federal-circuit/court-of-appeals/reply-brief samples/INPUT-gem-reply-brief.md`, exit 0, no typst warnings, 13 pages (same as the committed PDF). Overlay rerun, exit 0: cover 98%, Argument 50–100%, signature 96%, Form 19 90%, certificate of service 95%; TOC and TOA low (17–22%), the sample's TOC and TOA list fewer entries than the filed ones.
- Viewed: all 13 pages at 60 dpi, page 1 again after the fix; the overlay pages at 40 dpi; the exemplar's page 1 against our cover.
- Fixed: cover counsel columns. "TAFT STETTINIUS & HOLLISTER, LLP" does not fit a half-width column at 14 pt and wrapped "LLP" flush left, reading as a separate address line. Each counsel line is now its own paragraph with a 1 em hanging indent.
- Checked, not changed: page 10 holds only the last four lines of the Conclusion and page 11 the whole signature block; the filed brief does the same (its signature block is on a page of its own). Reply briefs are not principal briefs, so Fed. Cir. R. 32(a)(3) (exemplary claims) does not apply.
- LaTeX re-rendered, 13 pages; its cover still wraps the firm name flush left, and its PDF page 6 carries only the block quotation tail and "Appx68." before the Conclusion starts a new page. docx not re-rendered (no LibreOffice): `docx/cafc-docx.lua` keeps an "Is/" signature prefix in a code path this sample does not reach (the committed docx PDF has no "Is/").
- Remaining gaps: as under Known gaps.
