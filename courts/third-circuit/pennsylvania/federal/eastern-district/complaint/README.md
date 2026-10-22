# paed: complaint

Doc type: **complaint** (complaint and jury demand) in the United States District Court for the Eastern District of Pennsylvania (`paed`). Folder: `courts/third-circuit/pennsylvania/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer, counsel-filed; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a portion of the 22-page filing; see the frontmatter comment) |
| typeface | face required: **none** (the E.D. Pa. local civil rules name no face; see Governing rules). Font: **Times New Roman** 12 pt (vendored, docs/FONTS.md), the exemplar's face and the house standard; the typst, docx and LibreOffice PDF all name it (`fb lint fonts` does not report the folder) |
| render | ok (2026-10-22): `usage/OUTPUT-complaint.typst.pdf`, 11 pages, and `usage/OUTPUT-complaint.docx` with its LibreOffice PDF, 11 pages; `fb render`, vendored fonts only, no warnings |
| overlay | `just overlay` writes `.overlay/<doc path>/OVERLAY-complaint.pdf` (not committed); a diagnostic, not a score |
| pages reviewed | 11 of 11, both engines, side by side at 50 dpi (2026-10-22, the renders of fb-595.68.35) |
| tier 1 (mandated form) | checked against the rules below; no mandated typography exists in the E.D. Pa. local rules |
| tier 2 (professional convention) | judged against one filer only (see Known gaps 1) |

Naming: file roles follow the repo's convention (`INPUT-` / `OUTPUT-` / `OVERLAY-`), which `tools/render.sh` and `tools/overlay.sh` read and write by default. The brief's bare `<id>.md` / `<id>.pdf` names would not match those tools.

## Governing rules

Primary source: **Local Rules of Civil Procedure, E.D. Pa.** (the consolidated civil rules PDF listed at https://www.paed.uscourts.gov/local-rules/Local%20Civil%20Rules, dated 05/08/2023): https://www.paed.uscourts.gov/sites/paed/files/documents/locrules/civil/cvrules.pdf. Downloaded and read 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| EDPA-COMP-001 | Fed. R. Civ. P. 10(a) | Caption with the court's name, the title of the action, the file number, and the title of the pleading. Not fetched in this run; the text is the standard Rule 10(a). | `court_lines`, `caption`, `case_number`, `brief_title` (`typst/paed-complaint.typ`, `cover()`) |
| EDPA-COMP-002 | Fed. R. Civ. P. 10(b) | Allegations in numbered paragraphs, each limited as far as practicable to a single set of circumstances. Not fetched in this run. | numbering in `allegations()` (`typst/paed-complaint.typ`); headings and lists are not numbered |
| EDPA-COMP-003 | Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, the claim, and the relief sought. Content, not form: the template does not check it. | author content (`sample`) |
| EDPA-COMP-004 | E.D. Pa. Local Civil Rule 5.1.1 | No pleading asserting unliquidated damages may state a specific dollar amount claimed, but must allege jurisdiction and reveal whether the case is subject to arbitration under Local Civil Rule 53.2. | author content. The template does not check for dollar figures; the sample states facts ($79,000, $2,400) as facts, not as damages claimed. The arbitration statement is not in the sample (see Known gaps 4). |
| EDPA-COMP-005 | E.D. Pa. Local Civil Rule 40.1 (b) | Attorneys must indicate relatedness on the Civil Cover Sheet and the Designation Form that accompany the complaint. | not generated: separate filings, listed under "Not produced" |
| EDPA-COMP-006 | E.D. Pa. Local Civil Rule 5.1.2(7) | Certificate of service for documents filed through ECF. Applies to documents served by ECF; the initial complaint is served with a summons under Fed. R. Civ. P. 4, so it carries no certificate in the exemplar, and the template does not add one. | `motion-brief/` carries the certificate for filed motions |

Local typography and margin rules: **none in the E.D. Pa. local civil rules text above.** Re-checked 2026-10-15 by extracting the full text of the 05/08/2023 PDF (poppler `pdftotext`): no typeface, font size, spacing or margin rule in Rules 5.1, 5.1.1, 5.1.2 or elsewhere. So no face is named; the template sets Times New Roman, the face of the filed exemplar and the house standard. The only page limits in that text are for habeas petitions and responses (30 and 150 pages), and Local Civil Rule 7.1(c) directs counsel to each judge's policies. The typeface, size, spacing and margins below are therefore convention, not rule; they are chosen to match the filed exemplar where the exemplar is readable (double spacing, 12 point, 1-inch margins).

Not produced by this template (separate filings the Clerk needs with the complaint): the Civil Cover Sheet (JS-44C) and the Designation Form (LR 40.1(b)); the Rule 7.1 disclosure statement if the party is a corporation; the summons. The exemplar's docket entry lists its Civil Cover Sheet and Designation Form as ECF attachments (# 1 and # 2).

## Layout (the convention, from the exemplar)

- Letter paper, 1-inch margins on all sides, Times New Roman 12 pt. Footer: centered page number in a single-pitch line ending 0.5 in above the page edge, no ECF header.
- The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch, 24 pt for the body (double spacing, as the exemplar), 13.8 pt for single lines (court title, caption, title, signature, footer); the spaces between blocks explicit.
- Caption: court title in bold centered single lines (`court_lines`), a blank single line, then the party block in single lines, a column of `:` marks (one per party line), and `Civil Action No.` on the middle line of the party column (the upper middle when the count is even) at the right. A blank case number prints as a line for the Clerk.
- Title of the pleading bold and centered, a blank single line below the caption and above the text.
- Body: numbered paragraphs, the number at the half-inch indent in a 0.5 in box (the text starts 1 in from the margin; a tab in the docx).
- Section headings at the type size on the body pitch with no space of their own, kept with the next block: level 1 centered bold capitals; level 2 centered bold; level 3 bold italic at the left margin.
- Lettered lists `(a)`, `(b)`, ... (markdown `1.` items): the letter half an inch in, the text hanging at 0.9 in.
- A paragraph opening with `WHEREFORE` is the request for relief and is not numbered.
- Signature block, single-spaced at the margin, 24 pt below the last paragraph and kept with it: firm, `BY: /s/` the signer and the signer's lines, `Date:` line, 12 pt apart.

## Markdown contract (for samples)

- YAML frontmatter: `case_number` (blank for a new filing), `court_lines` (list), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `lead_in` (unnumbered introductory sentence, optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` heading (level 1, centered caps), `##` (level 2, centered bold), `###` (level 3, bold italic), a list (`1.` items, lettered), or a paragraph (numbered by the template).
- Not supported: tables, footnotes (none used), raw typst. The sample must not number its own paragraphs.

## Render and overlay

```sh
sh tools/render.sh courts/third-circuit/pennsylvania/federal/eastern-district/complaint usage/INPUT-complaint.md
sh tools/render.sh --engine docx courts/third-circuit/pennsylvania/federal/eastern-district/complaint usage/INPUT-complaint.md
just overlay courts/third-circuit/pennsylvania/federal/eastern-district/complaint
```

The overlay (red = our render, blue = exemplar, black = both) is a diagnostic, not a score: the filed exemplar has an ECF header and its own line breaking, so text lines will not coincide.

## Visual review (all 11 pages, typst and docx side by side at 50 dpi, 2026-10-22)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, lead-in, Introduction, paragraphs 1 to 4 | OK, both engines alike. Caption colon column aligned; "Civil Action No." blank line on the "v." line. |
| 2 | Paragraphs 4 to 9: the introduction's end, jurisdiction and venue | OK. Ends three lines short: the PARTIES heading stays with paragraph 10. |
| 3 | PARTIES, FACTS, consumer-reports heading, paragraphs 10 to 15 | OK. |
| 4 | Insurance-reporting and mixed-file sections, paragraphs 16 to 22 | OK. |
| 5 | Paragraphs 23 to 29, Case Background, Two Different Consumers, list (a) and (b) | OK. |
| 6 | List (c) to (j), paragraph 30 | OK; the hanging text of each item at 0.9 in. |
| 7 | Paragraphs 31 to 38, the insurance and disputes headings | OK. |
| 8 | Paragraphs 39 to 44 | OK. |
| 9 | Paragraphs 44 to 51, Count One heading | OK. |
| 10 | Paragraphs 52 to 55, jury demand, prayer, (a) to (d) | OK. Ends short: item (e) is kept with the signature. |
| 11 | Item (e), signature block | OK; the signature never stands alone. |

The docx PDF breaks every line and page where the typst PDF does (XENG-001..003: 280/280 lines, 11/11 pages).

Defects of the earlier template (fixed by the cross-engine port, fb-595.68.35): blocks snapped to whole 24 pt rows by measuring (`on-grid`), unbreakable paragraphs that left gaps at page foot, the number 0.3 in before the text (the docx used a tab), and a docx in EB Garamond with one blank 24 pt paragraph where typst set 16 pt.

## Known gaps and open choices

1. **One filer only.** The tier-2 rule asks for two or three exemplars from different filers. Two more E.D. Pa. complaints with text layers were located and checked (Evenstad v. CoilPlus, 2:26-cv-07849, Gurmankin; Johnson v. La Academia, 5:26-cv-07834, Zeff) but not saved, per the brief's one-exemplar-per-doc-type rule. Tier 2 is therefore not yet judged against the 2-to-3-filer standard. **Needs a call from David**: save both as further exemplars.
2. **Typeface.** The local rules name no face. Times New Roman 12 pt, the face of the filed exemplar and the house standard, in every engine.
3. **Margins and spacing.** The local rules set none; 1-inch margins and double spacing match the exemplar.
4. **Arbitration statement (LR 5.1.1).** The rule requires the complaint to reveal whether the case is subject to arbitration under LR 53.2. The sample's jurisdiction and venue section does not carry that statement, because the full text of the exemplar has no such statement (a search of the whole text layer finds none, so the filed complaint omits it); a real filing needs it. The template does not check for it. Author content.
5. **ECF header.** Not reproduced; court-generated.
6. **Paragraph numbers.** The sample numbers from 1; the filed numbers are not transcribed, so the overlay's paragraph numbers do not match.
7. **Partial transcription.** The sample is a portion of the 22-page filing (introduction, jurisdiction, parties, selected facts, Count One, prayer, signature); passages are omitted without ellipses (see the frontmatter comment).
8. **Civil Cover Sheet, Designation Form, Rule 7.1 statement, summons** are not generated (see Governing rules).
9. **Selftest.** `tools/check-selftest.sh` needs a `court.json`, which this doc-type folder does not have; `tools/check.sh` runs on it (typst and docx, 0 failed).
10. **Citations to Fed. R. Civ. P. 10 and 8** were not fetched in this run; only the E.D. Pa. local rules PDF was downloaded and read.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"): the docx render breaks every line and every page where the typst render does, and `eval.yaml` gates it (`params.cross_engine: gate`, fb-595.68.35).

- **typst** (primary, `typst/paed-complaint.typ`): the reference.
- **docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, the typst face `{font}` = Times New Roman, 12 pt; Body Text in exact 24 pt line boxes with a 0.5 in first-line indent, single lines 13.8 pt; the heading levels at the type size on the body pitch; "Numbered Paragraph" with a tab 1 in from the margin; "Lettered" hanging at 0.9 in; letter page, 1 in margins, the footer 0.5 in above the edge) and `docx/paed-complaint.lua` on `lib/docx/xengine.lua`, which writes the court title, the caption table, the title, the lead-in, the numbered paragraphs and lettered items (numbers typed, as typst types them), the signature kept with the last item, the footer (`$FORMBOOK_FOOTERS`) and the last section (`$FORMBOOK_FINAL`). `fb render` builds the reference and runs the passes; no shell script (fb-595.68).
- Checks (2026-10-22): typst 9 passed, 0 failed; docx 13 passed, 0 failed, XENG-001..003 PASS (280/280 lines, 11/11 pages).
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
