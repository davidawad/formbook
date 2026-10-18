# paed: complaint

Doc type: **complaint** (complaint and jury demand) in the United States District Court for the Eastern District of Pennsylvania (`paed`). Folder: `courts/third-circuit/pennsylvania/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer, counsel-filed; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a portion of the 22-page filing; see the frontmatter comment) |
| typeface | face required: **none** (the E.D. Pa. local civil rules name no face; see Governing rules). Font: **EB Garamond** (vendored), kept under `docs/FONTS.md` "No face named"; no substitution made. `pdffonts` on the 2026-10-15 render: only EB Garamond embedded (Regular, Bold, BoldItalic) |
| render | ok (re-run 2026-10-15): `usage/OUTPUT-complaint.typst.pdf`, 10 pages, typst 0.15.0, `--ignore-system-fonts`, no warnings |
| overlay | **fail** (re-run 2026-10-15): `tools/overlay.sh` exits 1 because `usage/` holds only `SOURCE.md`; the filed PDF named there is not in this snapshot. `usage/OVERLAY-murphy-complaint.txt` is the earlier page map, not regenerated; no `OVERLAY-murphy-complaint.pdf` exists |
| pages reviewed | 10 of 10 (re-rendered 2026-10-15 at 60 dpi; every page looked at, none changed) |
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

Local typography and margin rules: **none in the E.D. Pa. local civil rules text above.** Re-checked 2026-10-15 by extracting the full text of the 05/08/2023 PDF (poppler `pdftotext`): no typeface, font size, spacing or margin rule in Rules 5.1, 5.1.1, 5.1.2 or elsewhere. So no face is named and EB Garamond stays. The only page limits in that text are for habeas petitions and responses (30 and 150 pages), and Local Civil Rule 7.1(c) directs counsel to each judge's policies. The typeface, size, spacing and margins below are therefore convention, not rule; they are chosen to match the filed exemplar where the exemplar is readable (double spacing, 12 point, 1-inch margins).

Not produced by this template (separate filings the Clerk needs with the complaint): the Civil Cover Sheet (JS-44C) and the Designation Form (LR 40.1(b)); the Rule 7.1 disclosure statement if the party is a corporation; the summons. The exemplar's docket entry lists its Civil Cover Sheet and Designation Form as ECF attachments (# 1 and # 2).

## Layout (the convention, from the exemplar)

- Letter paper, 1-inch margins on all sides. Footer: centered page number, no ECF header.
- Caption: court title in two bold centered lines (`court_lines`); then the party block in single spacing, a column of `:` marks, and `Civil Action No.` on the right. A blank case number prints as a line for the Clerk.
- Title of the pleading bold and centered, below the caption.
- Body double-spaced (24 pt baseline pitch at 12 pt), first-line indent, numbered paragraphs.
- Section headings: level 1 centered bold capitals; level 2 centered bold; level 3 bold italic at the left margin.
- Lettered lists `(a)`, `(b)`, ... (markdown `1.` items).
- A paragraph opening with `WHEREFORE` is the request for relief and is not numbered.
- Signature block: firm, `BY: /s/` the signer, the signer's name and address lines, `Date:` line.

## Markdown contract (for samples)

- YAML frontmatter: `case_number` (blank for a new filing), `court_lines` (list), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `lead_in` (unnumbered introductory sentence, optional), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` heading (level 1, centered caps), `##` (level 2, centered bold), `###` (level 3, bold italic), a list (`1.` items, lettered), or a paragraph (numbered by the template).
- Not supported: tables, footnotes (none used), raw typst. The sample must not number its own paragraphs.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/third-circuit/pennsylvania/federal/eastern-district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/third-circuit/pennsylvania/federal/eastern-district/complaint murphy-complaint
```

- `usage/OVERLAY-murphy-complaint.pdf`: red = our render, blue = exemplar, black = both. `OVERLAY-murphy-complaint.txt` is the page map (our page to the filed page with the most shared words). The overlay is a diagnostic, not a score: the filed exemplar is Times with an ECF header and a different line breaking, so text lines will not coincide.

## Visual review (all 10 pages rendered at 60 dpi and looked at, final render)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, lead-in, Introduction, paragraphs 1 to 4 | OK. Caption colon column aligned; "Civil Action No." blank line. |
| 2 | Paragraphs 5 to 11: the introduction's end, jurisdiction and venue, parties | OK. |
| 3 | FACTS, consumer-reports heading, paragraphs 12 to 17 | OK. |
| 4 | Mixed-file section, paragraphs 18 to 25 | OK. |
| 5 | Case background, Two Different Consumers, paragraphs 26 to 29, list (a) to (e) | OK. |
| 6 | List (f) to (j), paragraphs 30 to 33 | OK. |
| 7 | Mr. Murphy's disputes, paragraphs 34 to 39 | OK. |
| 8 | Paragraphs 40 to 46 | OK. |
| 9 | Paragraphs 47 to 53, Count One heading | OK. |
| 10 | Paragraphs 54 and 55, jury demand, prayer (a) to (e), signature | OK. |

Defects found during review and fixed in the template:

1. Numbered paragraphs and headings overlapped one another on the first render (no fixed block height). Fixed by snapping every paragraph, heading and the request for relief to whole pitch rows (`on-grid`, the same device the CAND complaint uses).
2. Level-1 and level-2 headings printed at the default heading size (about 1.4 em). Fixed by setting `size: type-size` in the heading show rules.
3. A paragraph that broke across a page could overlap the paragraph after it (a fixed-height block that splits). Fixed by making paragraph blocks unbreakable (`on-grid(breakable: false)`): a paragraph moves whole to the next page, which can leave a short gap at the foot of a page.

## Known gaps and open choices

1. **One filer only.** The tier-2 rule asks for two or three exemplars from different filers. Two more E.D. Pa. complaints with text layers were located and checked (Evenstad v. CoilPlus, 2:26-cv-07849, Gurmankin; Johnson v. La Academia, 5:26-cv-07834, Zeff) but not saved, per the brief's one-exemplar-per-doc-type rule. Tier 2 is therefore not yet judged against the 2-to-3-filer standard. **Needs a call from David**: save both as further exemplars.
2. **Typeface.** The local rules name no face, so EB Garamond stays (`docs/FONTS.md`, "No face named"). The filed exemplar is Times New Roman, which is a choice by its filer, not a requirement. EB Garamond sets smaller at 12 pt than Times, so the text looks smaller than the exemplar. The 12-point size is met; the difference is visible, not a rule defect.
3. **Margins and spacing.** The local rules set none; 1-inch margins and double spacing match the exemplar.
4. **Arbitration statement (LR 5.1.1).** The rule requires the complaint to reveal whether the case is subject to arbitration under LR 53.2. The sample's jurisdiction and venue section does not carry that statement, because the full text of the exemplar has no such statement (a search of the whole text layer finds none, so the filed complaint omits it); a real filing needs it. The template does not check for it. Author content.
5. **ECF header.** Not reproduced; court-generated.
6. **Paragraph numbers.** The sample numbers from 1; the filed numbers are not transcribed, so the overlay's paragraph numbers do not match.
7. **Partial transcription.** The sample is a portion of the 22-page filing (introduction, jurisdiction, parties, selected facts, Count One, prayer, signature); passages are omitted without ellipses (see the frontmatter comment).
8. **Civil Cover Sheet, Designation Form, Rule 7.1 statement, summons** are not generated (see Governing rules).
9. **Shared tools not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run. Render and overlay were run; the review above is the Gate 2 record for this doc type.
10. **Citations to Fed. R. Civ. P. 10 and 8** were not fetched in this run; only the E.D. Pa. local rules PDF was downloaded and read.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/paed.lua`): pandoc on a reference with the template's typography (EB Garamond 12 pt, exact 24 pt line pitch, 0.5 in first-line indent, 1 in margins on US Letter, centered page number, centered and bold headings with level 3 in bold italic at the margin, single-spaced caption and counsel block). The Lua filter builds what pandoc cannot write from the markdown contract: the cover (court title, caption table with its column of colons, title of the pleading), the lead-in, the numbered allegations (numbers typed by the filter, so the numbering runs from 1; a paragraph opening with WHEREFORE is not numbered), the lettered lists `(a)`, and the signature block. Output: `usage/OUTPUT-complaint.docx`. Built with `sh docx/build-reference.sh docx/reference.docx` and `pandoc --from markdown+smart --to docx --reference-doc=docx/reference.docx --lua-filter=docx/paed.lua usage/INPUT-complaint.md -o usage/OUTPUT-complaint.docx`. Checked only as a zip of well-formed XML (every entry read, every XML part passes `xmllint --noout`). Not opened in Word or LibreOffice.
- **docx differs from typst**: the caption's right cell is top-aligned (typst centers it vertically); the numbers are typed text, so Word does not renumber them when a paragraph is inserted; the space between blocks is one 24 pt line where typst uses 16.2 pt; pagination is Word's, so page breaks and the gaps that typst's unbreakable paragraphs leave at page foot differ.
- **docx BLOCKED**: this court folder has no checks file (no `checks.yaml`), so no gate check ID can be listed. Gates 0 to 3 on `usage/OUTPUT-murphy-complaint.docx.pdf` are BLOCKED. Reason: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.
