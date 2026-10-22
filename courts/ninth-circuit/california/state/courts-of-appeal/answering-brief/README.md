# California Court of Appeal: answering brief (respondent's brief)

Court: Court of Appeal of the State of California (all districts). Doc type: answering brief. In California the answering brief is the **respondent's brief** (the party that won below). The exemplar and the template use that title.

Status: exemplar=yes, render=ok, overlay=ok, pages_reviewed=16 of 16. Full depth in the sense of the brief: cover, certificate of interested entities, table of contents, table of authorities, introduction, statement of the case, argument (points I and II), conclusion, signature, certificate of compliance, certificate of service. The body is an excerpt of the filed brief (see "Known gaps").

## Layout

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-answering-brief.pdf` | Filed respondent's brief, Third District, C095798 (March 21, 2024). Text-based. |
| `usage/SOURCE.md` | URL, case, docket, filer, date filed, date fetched. |
| `usage/INPUT-answering-brief.md` | Markdown transcription of the exemplar (frontmatter = cover and certificate data; body = the excerpt). |
| `usage/OUTPUT-answering-brief.typst.pdf` | `sh tools/render.sh courts/ninth-circuit/california/state/courts-of-appeal/answering-brief usage/INPUT-answering-brief.md` (15 pages, TeX Gyre Schola). |
| `usage/OVERLAY-brown-respondents-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/ninth-circuit/california/state/courts-of-appeal/answering-brief brown-respondents-brief`. |
| `typst/main.typ` | Entry point (reads the sample named by `--input sample=...`). |
| `typst/calctapp-answering-brief.typ` | The template: `calctapp-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top and traces to a rule or a style choice. |

Build (from the repo root; the toolchain is `typst` 0.15.0, poppler, ImageMagick):

```sh
export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
D=courts/ninth-circuit/california/state/courts-of-appeal/answering-brief
sh tools/render.sh $D usage/INPUT-answering-brief.md
sh tools/overlay.sh $D brown-respondents-brief
```

## Governing rules

All rules are California Rules of Court. Verified 2026-10-14 against the courts.ca.gov rule pages (fetched through a summarizing reader, so the quoted language below is paraphrase with short quotations, not a verbatim copy; re-read the official text before a filing relies on exact wording).

| Requirement | Rule and subdivision | Source | Used for |
|---|---|---|---|
| Font type: any conventional roman face, proportional or monospaced; case names italic. Rule 8.74(b)(1) (electronic filing) adds: a proportionally spaced serif, Century Schoolbook "preferred" | rule 8.204(b)(2), (b)(3); rule 8.74(b)(1) | https://www.courts.ca.gov/cms/rules/index/eight/rule8_204; https://courts.ca.gov/cms/rules/index/eight/rule8_74 | `font-family`; `*Case v. Name*` in the markdown. Face: none required; rule 8.74(b)(1) prefers Century Schoolbook, the exemplar's face, so TeX Gyre Schola (vendored, the Century substitute of docs/FONTS.md; since 2026-10-17, EB Garamond before). Checked 2026-10-15 against the rule text, when the font list was EB Garamond. |
| Font size, footnotes included, not smaller than 13 point | rule 8.204(b)(4) | same | `type-size = 13pt`; footnote entry at `type-size` |
| Spacing: lines unnumbered, at least 1½ spaced; headings, footnotes and block quotations may be single-spaced | rule 8.204(b)(5) | same | `body-leading` (about 23.4 pt pitch at 13 pt, the exemplar's measured pitch of 23.5 pt) |
| Margins: at least 1½ in left and right, 1 in top and bottom | rule 8.204(b)(6) | same | `margin-side`, `margin-tb` |
| Page numbers in Arabic numerals, consecutive from the cover as page 1; cover number may be suppressed | rule 8.204(b)(7) | same | cover unnumbered; all later pages numbered from the cover |
| Cover: title of the brief; title, trial court number and Court of Appeal number of the case; names of the trial court and each participating trial judge; the party each attorney represents | rule 8.204(b)(10) | same | cover (`district`, `proceeding`, `trial_judge`, `trial_case_number`, `counsel`, `counsel_for`) |
| Brief length: 14,000 words including footnotes (computer-produced) | rule 8.204(c)(1) | same | `word-limit`; the template panics above it |
| Excluded from the limit: tables, cover information, the certificate of interested entities, the word-count certificate, signature block | rule 8.204(c)(3) | same | certificate of compliance text |
| Certificate of interested entities or persons (first page after the cover) | rule 8.208 (the form, APP-008) | rule 8.208(d), (e)(2) as cited on the form and in the exemplar; **not fetched** | page 2 wording (`interested-page`) |
| Word-count certificate | rule 8.204(c) | rule 8.204 | `certificate-of-compliance` |
| Electronic filing: text-searchable PDF | rule 8.212 (summary snippet from a courts.ca.gov search result; **page not fetched**) | not generated (the court's e-filing pipeline) |

Rule 8.520 was checked and is **not** the governing word-limit rule for this doc type: it governs Supreme Court review briefs. The exemplar's certificate cites it; the sample does not repeat that citation.

Not in the rules on file, and not verified: rule 8.212(c)(1) (cited in the exemplar's proof of service; the sample reproduces that citation as written).

### Exemplar search (2026-10-14)

1. Web search for Second District and general Court of Appeal respondent's briefs: returned court self-help pages and a Second District docket page, no PDF.
2. Web search with `courtlistener` / `justia` / `courts.ca.gov` terms: returned rule pages only; no filed brief on CourtListener or Justia for a California Court of Appeal.
3. Stanford Law School's publication page for *Brown v. CDCR* (Third District, C095798): direct PDF, text-based, filed-stamped. **Used.**

## Overlay (`OVERLAY-brown-respondents-brief.pdf`)

Red = our render only; blue = the filed exemplar only; black = both agree. Pages are paired by word overlap (`-overlay.txt`). The sample is an excerpt, so most pairings are approximate by design; the overlay is a diagnostic, not a score. Pairings that matter: our cover (p.1) to the filed cover (p.1), 90% overlap; the TOA (p.4) is the exemplar's TOA page 6; the introduction (p.5-6) to filed pp.11-12; the argument (p.10-13) to filed pp.31-35, the same text, different body pages.

Rendering differences the overlay shows, accepted:

- Typeface (on the earlier EB Garamond render; the template has set TeX Gyre Schola, a Century Schoolbook substitute, since 2026-10-17). The exemplar is Century Schoolbook. EB Garamond was used then. It is roman, proportional, and 13 point, as the rule requires, but its x-height is smaller, so the same point size sets a little smaller on the page. Accepted; the rule is met on size and the page length is comparable.
- Line pitch: 23.4 pt against the exemplar's 23.5 pt.
- Running e-filing stamp at the top of the cover page (court-generated) is not reproduced.

## Gate 2 review (visual, every page, `pdftoppm -r 60`)

All 16 pages rendered and looked at (on the earlier EB Garamond render, before the 2026-10-17 switch to TeX Gyre Schola). Findings and their state:

| Page | Finding | State |
|---|---|---|
| 1 (cover) | Counsel in two narrow columns wrapped SBN numbers mid-line | fixed: lead firm centered across the page, other firms in two columns |
| 1 (cover) | Cover page exceeded one page at 13 pt | fixed: cover lines use the ascender-to-baseline box (`text(top-edge: "ascender", bottom-edge: "baseline")`); the cover fits at zero gap |
| 2 (certificate) | none | ok |
| 3 (TOC) | none | ok |
| 4 (TOA) | none | ok |
| 5-13 (body) | none | ok |
| 10 | "(Ibid..)" double period from a misplaced period after a link | fixed in the sample |
| 14 (signature) | "By:" with no signature line | fixed: a signature line is drawn after "By:" |
| 16 (service) | Paragraphs ran together ("8610.On", "follows:BY FIRST-") | fixed: explicit paragraph breaks; name and address on separate lines |

Open, accepted:
- Page count: 16 rendered pages against a target of 8-14. The cover, certificate, TOC, TOA and both certificates are fixed by the form; the excerpt body is 10 pages. Accepted rather than cutting the excerpt below the sample's usefulness.

## Known gaps

- The sample body is an excerpt: introduction (complete), statement of the case A and B (partial), argument I.A and I.B, point II (headings and the first paragraphs), conclusion. The filed brief has statement C-G and argument I.C, III and IV that are not transcribed. The table of contents and table of authorities list only what the sample cites.
- The word-count certificate states the sample's own count (2,560 words), computed from the markdown. A real brief gets its own count from its own text.
- The certificate of interested entities reproduces the form's wording on page 2. The official APP-008 form must be used in a filing; the template is a layout reference.
- Not generated: attachments under rule 8.204(d) (10-page cap), a running header, the e-filing stamp, and any second appendix.
- Front matter numbering: the cover is page 1 (unnumbered), so the certificate of interested entities is page 2, as in the exemplar.

## Engines

Docx engine (`docx/`), rebuilt 2026-10-21 (fb-595.63). `docx/reference.xml` holds the Word styles and the page; fb render builds `reference.docx` from it and pandoc's default reference (`tools/fb/src/docxref.rs`). `docx/calctapp.lua` writes, in the typst order: the cover (rules between the parts, the lead counsel centered and the others in two columns, bar numbers kept whole), the certificate of interested entities or persons (drawn check boxes), the table of contents and the table of authorities with dot leaders and page numbers (`passim` from 7 pages), the body (pandoc; heading labels as typst: I./A./1./a. in the Argument, A./1./a./(1) elsewhere), the signature block kept with the last paragraph, the certificate of compliance (its word count, 2,560, is typst's) and the certificate of service. The table pages come from fb render's multi-pass docx engine (`tools/fb/src/docxpass.rs`, as ca9): the filter writes a needle for every heading and citation, fb render finds them in the LibreOffice PDF and renders again until they settle. Form: TeX Gyre Schola 13 pt everywhere, the typst face (vendored; it named EB Garamond before, so DEF-FONT-002 failed), footnotes included; body lines exact 467 twips (23.35 pt, the typst body pitch); first-line indent 0.5 in; headings single-spaced, bold, black, level 1 in capitals; block quotations single-spaced, indented 0.5 in each side; US Letter; 1.5 in left and right, 1 in bottom and 1.1 in top (Schola's ascent sets the first line of a cover or heading page above a 1 in top margin in LibreOffice, DEF-FORM-002; typst sets it on the margin); one section, page numbers from the cover on, the cover's not shown (`titlePg`); footnotes numbered through the brief (pandoc's `eachSect` restart was read by LibreOffice as a restart on every page, so the second footnote printed as 1 and DEF-CONT-001 failed). Not set: line numbers (the typst template sets none).

Differs from typst: LibreOffice's pagination (17 pages, typst 15), so the table page numbers differ from typst's; Word may paginate slightly differently again from the LibreOffice PDF the numbers come from.

`sh tools/check.sh courts/ninth-circuit/california/state/courts-of-appeal/answering-brief --engine docx`: RESULT 7 checks passed, 0 failed. Every page of the 17-page `.docx.pdf` was viewed.

## Verification pass 2026-10-16 (fb-595.26.16)

- Rendered with `sh tools/render.sh .../answering-brief usage/INPUT-answering-brief.md`: exit 0, no typst warnings, 16 pages (the committed PDF was also 16 pages, so it was not stale). `pdffonts`: EB Garamond Regular, Italic and Bold only. Committed PDF: `603456c5fb07fa93…`.
- Viewed all 16 pages at 60 dpi (pages 1, 3, 15 and 16 again after the fixes), and the 16 overlay pages at 40 dpi. Our cover was compared with the exemplar's page 1 (90% word overlap).
- Overlay rerun (`tools/overlay.sh`): pairings unchanged from the "Overlay" section above.
- Fixed, in `typst/calctapp-answering-brief.typ`:
  - Cover (page 1): bar numbers split across lines in the two-column counsel block ("WENDY MUSELL (SBN No. / 203507)"). A parenthetical on a counsel line is now kept whole, so "(SBN No. 203507)" moves to its own line, as the exemplar sets it. The cover still fits one page.
  - TOC (page 3): same two-column entry as the other doc types (`toc-page-width`), so a long title cannot strand its page number. Wrapped entries now break a little earlier.
  - Certificate of compliance (page 15): the signer block was right-aligned text (ragged left) in a box at the left half. It is now left-aligned and starts at the middle of the page, like the brief's signature block on page 14.
  - Certificate of service (page 16): the declarant's name, the same defect and fix.
  - The no-break rule for a section sign and its number now covers "§§" (`[§¶]+ \S+`).
- Accepted, not changed (tier 3): "else / —discuss" (page 9), an em dash at the start of a line, which is a legal break.
- Remaining gaps: one exemplar (one filer), so tier 2 cannot be finished; no `checks.yaml`, so Gates 0 and 1 have not run; latex not rendered (no `latex/` in this folder).
