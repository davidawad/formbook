# D.R.I. (rid): complaint

Doc type: **complaint** in the United States District Court for the District of Rhode Island (`rid`).
Folder: `courts/first-circuit/rhode-island/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-nightingale-1-26-cv-00213-complaint.pdf` (1 filer, 11 pages; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-nightingale-complaint.md`: the whole filing, converted from the exemplar's text layer and corrected by hand (100 numbered paragraphs, 3 headings per count, prayer, signature). Paragraph numbers are the template's, not transcribed. |
| render | ok: `samples/OUTPUT-nightingale-complaint.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-nightingale-complaint.pdf` and `samples/OVERLAY-nightingale-complaint.txt` |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary sources, fetched 2026-10-14:

- D.R.I. Local Rules, "As Amended through April 1, 2024" (the court's posted "Approved Dec 2024 Rules" PDF), https://www.rid.uscourts.gov/sites/rid/files/documents/Approved%20Dec%202024%20Rules.pdf. The rule numbers below are from that text; the court's index lists "Form of Pleadings" under LR Cv 5 and LR Cr 57, so there is no separate LR Cv 10.
- Fed. R. Civ. P. 8, 10, 11, from https://www.law.cornell.edu/rules/frcp/rule_8, `rule_10`, `rule_11` (the current text; no later amendment was found on the page).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR Cv 5(a) | 8 1/2 by 11 inch paper. | `page-w`, `page-h`. |
| LR Cv 5(a)(1) | Full caption showing the names of all parties. Documents filed after docketing also carry the judge's initials; the complaint is the initial filing, so the case number is blank. | `caption()`, all parties in `caption.parties`; `C.A. No.` blank when `case_number` is empty. |
| LR Cv 5(a)(2) | Title that states the nature of the document and identifies the filer. | `brief_title` ("COMPLAINT"). |
| LR Cv 5(a)(3) | Double-spaced, at least 12-point type; footnotes at least 10-point. | `pitch = 27.6pt`, `body-leading = 1.65em`, `type-size = 12pt`. Pitch is the one measured on both filed exemplars (see below). |
| LR Cv 5(a)(3) | Pages of a document longer than one page are numbered at the bottom center. | `set page(numbering: "1")`: every page, centered in the bottom margin. |
| LR Cv 5(a)(4) | Jury demand to the right of the caption, below the case number. | `jury_demand: true` prints "JURY TRIAL DEMANDED" in the right column under "C.A. No.". |
| LR Cv 5(a)(5) | Signature with name, address and telephone of the signer; bar number; firm name, address, fax, email. | `signature` (`party`, `signers` with `bar`, `firm` lines). |
| LR Cv 5(b) | A civil cover sheet must be filed with the complaint. | Not generated (a separate form; see Known gaps). |
| Fed. R. Civ. P. 8(a)(1)-(3) | Jurisdiction, a short plain statement of the claim, and a demand for relief. | Author content. The template does not check the wording. |
| Fed. R. Civ. P. 10(a) | The title of the complaint names all the parties. | The caption lists every party in `caption.parties`; the assert fails the build if it is missing. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body-content()` numbers every paragraph chunk 1, 2, ...; headings and the "WHEREFORE" prayer are not numbered. |
| Fed. R. Civ. P. 11(a) | Every pleading is signed by an attorney of record (or the party), with name, address, telephone and email. | `signature`. The template prints the "/s/" line; the signer's attestation is the filer's act. |

## Layout

- Court title centered bold (two lines), caption in a two-column grid: parties left (closed by a rule on the right and below), "C.A. No." and the jury demand right.
- Title centered bold below the caption.
- Body: 12-point EB Garamond, first-line indent 0.5 inch, paragraphs numbered "1." with a 0.3 inch tab, double spacing (27.6 pt baseline pitch). Headings: level 1 and level 2 centered bold (the sample's "Introduction", "Parties", "Facts" are level 1; "COUNT I" is level 1 and its parenthetical is level 2).
- Every body block has a trailing gap equal to the leading. Without it the next block starts one base line too early and the lines collide (found on the first render and fixed; see LOG below).
- Signature block: "Dated:" in the left column when given; party line, signers with "/s/" and bar numbers, firm block, all kept on one page.
- Margins: 1 inch all round. No D.R.I. margin rule was found; 1 inch is a convention (tier 2).

## Measured line pitch

The template's double-spacing value is not a guess. `pdftotext -bbox-layout` on both filed exemplars gives a baseline pitch of **27.6 pt** at 12 pt (Nightingale, page 3: 65.64, 93.24, 120.84; Tablada, page 3: 72.49, 100.09, 127.69). That is Word's "double" for 12-point Times New Roman (2 x 13.8 pt). The template sets EB Garamond to the same pitch, which takes 11 pages for the 11-page exemplar. An earlier build at 24 pt (a 1.35em leading) was tighter than the filings and was changed.

## What the overlay shows

`samples/OVERLAY-nightingale-complaint.pdf`: each page of our render in red over the filed page it matches best, in blue. Black is where both agree. The pairing is by word overlap and is printed in `OVERLAY-nightingale-complaint.txt`. Page-level word overlap is 73.6% to 93.4% (page 7 is lowest). The pages line up one to one, so the layout difference is typeface and page-break placement, not missing text. The overlay is a diagnostic, not a score.

## Review log (Gate 2)

Every page was rendered at 60 dpi and viewed. Findings:

| Page | Finding | Action |
|---|---|---|
| all | Numbered paragraphs overlapped at each paragraph break (render 1). | Fixed: trailing leading on each block. |
| all | 24 pt pitch too tight against the filed 27.6 pt. | Fixed: `pitch = 27.6pt`, `body-leading = 1.65em`. |
| 1 | Caption, court title, jury demand and first paragraphs correct. | none |
| 2-10 | Numbering 1 to 100 in order, count headings centered and kept with the paragraph after them. | none |
| 11 | Prayer unnumbered, signature block with both signers, firm block complete. | none |

OPEN: none.

## Known gaps and open choices

1. **One exemplar.** Tier 2 in EVAL-LOOP asks for 2 or 3 filers. The search found Melo v. Lifespan (1:26-cv-00539) and Gifford v. Beacon Mutual (1:26-cv-00340), both complaints in this court. They were not downloaded for layout comparison. Tier-2 conventions here are therefore judged against one filer only.
2. **Caption rule.** The party column is closed by a rule, not the ")" column the other exemplar uses. Both appear in D.R.I. filings; recorded as a tier-2 choice.
3. **Font.** EB Garamond is the only vendored serif. LR Cv 5(a)(3) names no typeface. EB Garamond sets smaller than Times at the same point size, so the text looks lighter than the exemplar. The 12-point minimum is met.
4. **Not produced:** civil cover sheet (LR Cv 5(b)), Rule 7.1 disclosure statement, summons. Separate filings.
5. **Date line.** The exemplar's text layer has no date for the signature. The template prints "Dated:" only when the sample gives one, so the sample has none.
6. **File names.** `tools/render.sh` and `tools/overlay.sh` read and write `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (CLAUDE.md "File roles"). The brief's `<id>.md` and `<id>-overlay.pdf` names are not what the tools read, so the repo convention is used.

LOG:
- 2026-10-14: first render, 10 pages, numbered paragraphs overlapping at each break. Cause: blocks had no trailing leading. Fixed.
- 2026-10-14: pitch changed from 24 pt to 27.6 pt to match the filed exemplars; 11 pages.
