# cacd: complaint

Doc type: **complaint** in the United States District Court for the Central District of California (`cacd`).
Folder: `courts/ninth-circuit/california/federal/central-district/complaint/` (self-contained: `typst/`, `usage/`, `usage/`).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer: Plaintiffs' counsel, Kuzyk Law LLP; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a portion of the 33-page filing; see below) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 8 pages, typst 0.15.0 via `tools/render.sh`, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular, -Bold, -BoldItalic, all embedded), no typst warnings (the earlier EB Garamond render, before fb-595.68; the committed render is Times New Roman, 9 pages) |
| overlay | ok: `usage/OVERLAY-alarcon-complaint.pdf` and `usage/OVERLAY-alarcon-complaint.txt` (page map below) |
| pages reviewed | 8 of 8: every page rendered at 60 dpi and viewed at the final template state (of the earlier EB Garamond render) |

File names: the repo tools (`tools/render.sh`, `tools/overlay.sh`) write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.{pdf,txt}`, and `INPUT-<id>.md` is the sample. The `<id>` is `alarcon-complaint`. This follows CLAUDE.md's file-role naming rather than `<id>.pdf`/`<id>-overlay.pdf`.

## Governing rules

The court's rules decide the layout. Sources and what was checked:

| Rule | Requirement | Where in the template | Source checked |
|---|---|---|---|
| C.D. Cal. L.R. 11-3.1 | Typewritten or printed, black or dark blue ink. | Rendering | CACD Local Rules, Chapter I, copy at https://www.cacd.uscourts.gov/sites/default/files/documents/LocalRules_Chap1.pdf (fetched 2026-10-14; footer dated 6/1/2020 — see Known gaps 1) |
| L.R. 11-3.1.1 | Proportionally spaced font, standard (non-condensed) **14-point or larger**. | `type-size = 14pt` | same |
| L.R. 11-3.2 | 8½ × 11 paper, numbered left margin, **not more than 28 lines per page**, double spaced, line 1 at least one inch below the top edge. | `lines-per-page = 28`, `pitch = 24pt`, `top-margin = 72pt`, `line-numbers()` | same |
| L.R. 11-3.3 | Pages numbered consecutively at the bottom. | `footer-block` (page number, centered) | same |
| L.R. 11-3.6 | Double spaced, including citations and quotations. Footnotes may be single spaced (11-3.6.1). | Body on the 24-pt grid (`on-grid`, `body-leading`); quotations are not used in the sample | same |
| L.R. 11-3.7 | Block quotations indented. | Not exercised by the sample (no block quotations); the template has no quotation style | same |
| L.R. 11-3.8(a) | Counsel's name, bar number, office address, telephone, fax and e-mail, starting at line 1, left margin, single spaced; the party represented identified beneath. | `counsel` frontmatter, `counsel-block` | same |
| L.R. 11-3.8(b) | Lines 1-7 to the right of centre left blank for the clerk. | Counsel block is left-only; the court title starts below it | same |
| L.R. 11-3.8(c) | Court title centred on or below line 8. | `court-title`: a counsel block of 7 lines or fewer keeps the title on line 8; longer counsel pushes it down (the sample's 15 counsel lines put it on line 11) | same |
| L.R. 11-3.8(d) | Party names below the court title, left of centre, single spaced. | `caption` (left column) | same |
| L.R. 11-3.8(e) | Docket number right of centre, opposite the parties; a concise description of the document below it. | `caption` (right column: `Case No.`, `brief_title`, optional `legend`) | same |
| L.R. 11-3.8(f) | The title of a complaint states the nature of the action. | `brief_title` (sample: "Complaint for Damages, Equitable, Declaratory, and Injunctive Relief") | same |
| Fed. R. Civ. P. 10(a) | Caption: court name, title, file number, Rule 7(a) designation. | As above | https://www.law.cornell.edu/rules/frcp/rule_10 (fetched 2026-10-14; "As amended Apr. 30, 2007, eff. Dec. 1, 2007") |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs. | Each body paragraph is numbered by the template (`allegations()`); headings and lists are not numbered | same |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the claim; jurisdiction and relief. | Content, not layout | **not fetched in this run**; text from memory, verify before relying on it |
| Fed. R. Civ. P. 38 | Jury demand. | `jury_demand: true` puts `DEMAND FOR JURY TRIAL` in the caption; the demand paragraph is in the body | **not fetched in this run** |

Not produced (separate filings): the civil cover sheet, the summons, and any certification or notice of interested parties the court requires with a first filing (not checked in this run).

## Layout

- Numbered lines 1 to 28, a double rule at the text's left edge and a single rule at its right.
- Top margin 1 inch: line 1 sits on the top margin; the 28 lines end at 10.33 inches; the footer sits in the bottom margin.
- Counsel block single-spaced from line 1; court title below it (line 11 in the sample, because the counsel block has 15 lines).
- Text is on the 24-pt grid: `on-grid` rounds each block to whole lines, so paragraphs, headings and the signature block land on the numbers.
- Paragraphs are numbered 1, 2, ... by the template. Headings stay with the paragraph after them. The signature block is unbreakable (`block(breakable: false)`), so "Dated / Respectfully submitted" never stands alone at the foot of a page.
- Body lines are exact 24 pt line boxes (`xengine` and `edges(pitch)`, the cross-engine layout model of `lib/typst/xengine.typ`), so text baselines fall on the numbered lines. (The earlier EB Garamond template set `1.064em` of leading for the same pitch.)

## Overlay (red/blue)

`tools/overlay.sh` pairs each render page with the exemplar page sharing the most words (map measured on the earlier 8-page EB Garamond render, before fb-595.68):

```
ours p.1  filed p.1  word-overlap 89.5%
ours p.2  filed p.2  word-overlap 48.0%
ours p.3  filed p.5  word-overlap 59.8%
ours p.4  filed p.7  word-overlap 48.1%
ours p.5  filed p.20 word-overlap 24.6%
ours p.6  filed p.20 word-overlap 68.6%
ours p.7  filed p.32 word-overlap 80.3%
ours p.8  filed p.33 word-overlap 27.1%
```

Red is our render, blue is the filed page, black is where they agree. The overlap figures are a diagnostic, not a score: the sample is a portion of the filing, so pages 5 to 6 pair with exemplar pages whose content we did not transcribe. The overlay was read for page pairing only; the visual differences it shows were not itemized in this run.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number`, `caption.parties` (list of `{names, designation}`, "v." inserted between parties), `legend` (optional; "CLASS ACTION" in the sample), `brief_title`, `footer_title`, `counsel` (lines), `lead_in` (optional unnumbered paragraph), `jury_demand`, `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: a `#` heading (level 1 centred capitals), `##` (centred bold), `###` (bold italic, left); a list (`-` items, lettered (a), (b) ... by the template, may break across pages); or a paragraph (numbered by the template). Numbering must not appear in the text.
- Not supported: tables, footnotes (none used), raw typst.

## Known gaps and open choices

1. **Rules version.** The copy of the CACD Local Rules that was reachable is the 6/1/2020 edition of Chapter I. The December 2025 edition named in the search index (`.../2025%20December%20LRs%20Chap%201.pdf`) returned 404; courtrules.net returned 403. The 11-3 format rules have been stable for years, but **the current text has not been confirmed**. Confirm before the PR.
2. **Typeface.** L.R. 11-3.1.1 requires a standard proportional font at 14 pt or larger. The template uses Times New Roman 14 pt (the pinned install, Liberation Serif fallback; docs/FONTS.md rule 6), a standard proportional face. The 14-pt minimum is met as written.
3. **TOC and TOA line spacing (motion-brief only).** See that README.
4. **One exemplar.** EVAL-LOOP's tier 2 asks for two or three filers. Two more cacd complaints were found and not saved: Greenberg v. Creative Artists Agency (2:26-cv-11882, Dkt. 1, 10 pp., Harmon Seidman & Bruss) and Huemen, Inc. v. Ludo Fact USA (5:23-cv-00516, Dkt. 1, 10 pp.). Tier 2 is therefore not judged against a second filer.
5. **Caption style.** The party column is closed by a rule on its right and bottom edges. Recorded as a convention choice; not checked against a second filer.
6. **Footer.** 10 pt, one line of title and case number, and the page number centred above. L.R. 11-3.3 requires only the page number at the bottom; the title and case number are convention.
7. **Signature page.** The sample ends with the jury demand (page 7) and the signature block alone on page 8. The template keeps the signature block together but does not carry the last paragraph over with it. Acceptable under the rules; a tier-2 clerk convention would keep the last paragraph with the signature.
8. **Sample is partial.** The sample transcribes pages 1 to 7 of the 33-page filing in part (see the frontmatter comment). Filed paragraphs 40 to 54 and 58 to 75 and the second to eighth causes of action are not transcribed, so the sample is 8 pages against a 33-page exemplar.
9. **Italics.** The text layer of the exemplar carries no italic markup, so case names and "i.e." are roman in the sample. The template italicizes `*...*` markdown, so future samples can carry italics.
10. **Rule 8 and Rule 38 text** were not fetched in this run (see the table); the template does not depend on their wording.

## Engines

**docx** (`docx/`: `fb render --engine docx` builds the reference document from `reference.xml`, the shared cross-engine recipe in the typst face, then runs pandoc with `cacd-complaint.lua` (and `lib/lines.lua`), which writes the footer from the sample and the section, `FORMBOOK_FOOTERS` and `FORMBOOK_FINAL`). Checked with LibreOffice only; Word was not available. Render: `sh tools/render.sh --engine docx complaint usage/INPUT-complaint.md`, which gives `OUTPUT-complaint.docx` and `.docx.pdf` (8 pages, all viewed, on the earlier EB Garamond build; the committed `.docx.pdf` is 9 pages).

- Matches the typst output: Times New Roman 14 pt; exact 24 pt line pitch on the 27-line grid; letter size, 1 in top margin; 27 line numbers on every page (a frame in the footer, anchored to the page at the top margin); pleading rules (page borders); counsel block single spaced from line 1 with the court title on line 11 in the sample; caption with the party column's right and bottom rules; numbered allegations; headings centered or bold italic; signature block kept together on one page; footer with page number, title and case number.
- Differs: the pleading rules are page borders around the text area, not full-height lines. The caption and signature block are tables. A title too long for its footer cell wraps to two lines. `-` list items render as bullets, which is what the typst template's `list` produces; the contract text above says lettered (a), (b), which the typst code does not do for `-` items.
- BLOCKED: `sh tools/check.sh <court-dir> --engine docx` cannot run in this folder: it needs `court.json` and `checks.yaml` beside `typst/`, and neither exists (not created here). No check IDs exist yet, so no check result is claimed.
