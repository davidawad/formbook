# akd: complaint

Doc type: **complaint** (verified complaint for injunctive relief, a pleading under Fed. R. Civ. P. 8 and 10) in the United States District Court for the District of Alaska (`akd`). Folder: `courts/ninth-circuit/alaska/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-launch-alaska-3-25-cv-00141-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-launch-alaska-complaint.md`: an excerpt of the 18-page filing (see Sample) |
| render | ok: `samples/OUTPUT-launch-alaska-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-launch-alaska-complaint.pdf` and `OVERLAY-launch-alaska-complaint.txt` |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change) |

Build and check (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/ninth-circuit/alaska/federal/district/complaint samples/INPUT-launch-alaska-complaint.md
sh tools/overlay.sh courts/ninth-circuit/alaska/federal/district/complaint launch-alaska-complaint
```

## Governing rules

Primary source: the District of Alaska Local Civil Rules, "Effective October 15, 2025" (51 pages). Fetched 2026-10-14 from https://www.akd.uscourts.gov/sites/akd/files/local_rules/Local_Civil_Rules_10-2025.pdf (the page is not reachable with curl from this box; the text was read from the fetched copy). Rule text quoted below is from that copy.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Alaska L.Civ.R. 7.5(a)(1)(A) | Documents double-spaced (quotations over 50 words or 5 lines single-spaced and indented). | `body-leading = 1.35em` (double; see Measured spacing). |
| L.Civ.R. 7.5(a)(1)(B) | Margins of at least 1 inch around all text, including footers. | `margins = 1in`; footer inside the bottom margin. |
| L.Civ.R. 7.5(a)(1)(C) | If more than 1 page: a page number and a footer including the case name and number, at the bottom of each page. | `running-footer`: page number, then `footer_title` and `Case No.`. |
| L.Civ.R. 7.5(a)(1)(D) | At least 13-point, proportionally spaced font, or the equivalent. | `type-size = 13pt`, EB Garamond (proportional). See Known gaps 2. |
| L.Civ.R. 7.5(a)(1)(E) | No interlineation; one side of the paper. | Not applicable to the generated PDF. |
| L.Civ.R. 7.5(a)(2)(A) | Letter size, white paper (conventional filing). | `paper: "us-letter"`. |
| L.Civ.R. 7.5(a)(3) | Electronic filings: PDF, word searchable. | Typst PDF with embedded text (pdftotext reads it). |
| L.Civ.R. 7.5(b)(1)(A)-(C) | First page: attorney's name, address, telephone, e-mail, placed upper left at least 1 inch below the top; the attorney identifies the party represented. | `counsel` frontmatter (counsel block at the top margin); the last line states the party. |
| L.Civ.R. 7.5(b)(2) | Title of the court centered, at least 1 inch below the top edge and at least half an inch below the counsel block. | `court-title`, after `v(0.8in)`. |
| L.Civ.R. 7.5(b)(3)(A)-(B) | Space at the top right for the clerk's marks; case number below the court title, right side, with the judge's initials. | Top right left blank; `case_number` at right of the caption (judge initials are part of the number, e.g. `-GMS`). |
| L.Civ.R. 7.5(b)(4)(A)-(C) | Title of action to the left of centre below the court title; for complaints, party names not shortened to "et al.". | `caption` (full party names from frontmatter). |
| L.Civ.R. 7.5(b)(5) | Title of document centered below the court title and case number. | `doc-title`. |
| L.Civ.R. 7.5(c)(1)-(2) | Names and Alaska bar numbers typed beneath signatures; the attorney identifies each party represented. | `signature-block`: firm, role, `/s/` line, signer, bar number. |
| L.Civ.R. 8.1(a) | Statute relied on, in parentheses immediately below the title of a complaint seeking relief under a specific statute. | `statute` frontmatter line under the title. |
| L.Civ.R. 8.1(b) | Jurisdictional statement at the beginning of the body of the complaint, with citations to the federal statutes relied on. | The body's first heading (Parties, Jurisdiction, and Venue) carries the statement; the sample transcribes it. |
| L.Civ.R. 10.1 | Form of pleadings governed by 7.5 and 8.1. | Both applied. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10. | Caption, `case_number`, `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs. Fetched 2026-10-14 (same URL). | `render-body`: every paragraph chunk is numbered 1, 2, ...; headings, lists and quotations are not. |
| Fed. R. Civ. P. 38(b) | Jury demand. Not fetched in this pass. | `jury_demand: true` adds the demand paragraph; the sample does not use it (the exemplar has none). |

Not produced by this template (separate filings or the civil cover sheet): the civil cover sheet (JS-44); the Rule 7.1 disclosure statement; the summons. Any of these may be required with the first filing.

## Layout

- Single-spaced attorney block at the top left, the court title centered, the caption with a rule closing the party column (right and bottom), the case number at right, then the title and the statute in parentheses.
- Body double-spaced; numbered paragraphs with a 0.5 inch first-line indent; headings are centered and bold; the top-level headings are Roman numerals (I., II., ...).
- Prayer for relief: lettered items (a), (b), (c).
- Date line and signature block set to the right half of the page, kept together (`breakable: false`).
- Verification page (plaintiff's verification of the factual allegations) when the frontmatter has a `verification`.

## Measured spacing

Measured from `pdftotext -bbox` on page 2 of the render: consecutive lines of one paragraph are 34.5 pt apart; a single-spaced line (leading 0) is 17.0 pt. The double-spacing ratio is therefore 2.0 on EB Garamond's own line height (which is taller than Times's, so 34.5 pt at 13 pt is the double-spaced pitch for this face). The earlier template comment in `typst/akd-complaint.typ` that gave a 0.65em line box was wrong and is corrected.

## Sample

`samples/INPUT-launch-alaska-complaint.md` is a transcription of the exemplar's text, not the whole filing (18 pages filed, 9 rendered). Included: the counsel block and caption; paragraphs 1 to 9 (Parties, Jurisdiction, and Venue; the first mission paragraphs); paragraphs 40 to 57 and 59 (grant award and administrative appeal), with footnotes 8, 9 and 13 as footnotes 1 to 3; Count I (paragraphs 70 to 80); the prayer for relief; the signature block; the verification. Omitted: paragraphs 10 to 39, 58 and 60 to 69 of the filing (the template numbers the transcribed paragraphs 1 to 39 in order, so the numbers on the render do not match the filed numbers). The excerpt was chosen to keep the render at 8 to 14 pages.

## Overlay

`OVERLAY-launch-alaska-complaint.pdf`: red is our render, blue is the filed exemplar, black where both agree. Pages are paired by word overlap (`OVERLAY-launch-alaska-complaint.txt`): ours p.1 to p.9 map to filed p.1, 2, 8, 9, 11, 12, 15, 16, 17. The pairing is coarse because the sample skips paragraphs; it is a diagnostic, not a score. The exemplar has no pleading-paper line numbers (none are required by L.Civ.R. 7.5), so the layers differ on text lines wherever the two layouts disagree.

## Visual review (Gate 2 record, all 9 pages)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block, court title, caption, title, statute, lead-in | OK. Caption closed by a rule; case number at right; no spill. |
| 2 | Part I (paragraphs 1 to 5), the first General Allegations heading and paragraphs 6 to 8 | OK. |
| 3 | Paragraphs 9 to 14; footnotes 1 and 2 at foot | OK. |
| 4 | Paragraphs 15 to 19; footnote 3 (long URL) at foot | OK. |
| 5 | Paragraphs 20 to 23; the appeal heading | OK. |
| 6 | Paragraphs 24 to 30; Part III heading and Count I heading | OK. The count heading is kept with the paragraph after it. |
| 7 | Paragraphs 31 to 37 | OK. |
| 8 | Paragraphs 38 to 39; Prayer for Relief (a) to (c); date and signature block | OK. The signature block moved onto page 8 after the signature-block width and single-spacing fixes (it sat alone on page 9 before). |
| 9 | Verification of factual allegations, signature line | OK. |

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. Other D. Alaska complaints were found (Native Village of Hooper Bay v. Burgum, 3:25-cv-00316; Sovereign Inupiat for a Living Arctic v. Burgum, 3:25-cv-00356; NAEC v. Trump, 3:25-cv-00038, doc 1, 46 pages) but not compared. Tier 2 is therefore **not** judged against two filers.
2. **Font.** D. Alaska requires "13-point, proportionally-spaced font, or the equivalent". EB Garamond at 13 pt meets the size and proportional-spacing wording, but its x-height is smaller than Times New Roman, so the text looks smaller than a Times filing at the same point size. Whether a smaller-looking face counts as the equivalent is a question for David; a vendored Times-metric face would remove the question.
3. **Footer size.** 13 pt, the same as the text, because 7.5(a)(1)(D) does not exempt footers.
4. **Caption.** The party column is closed by a rule rather than the ")" column used in the exemplar. A convention choice; ACCEPTED.
5. **Heading level 2 and 3** are centered bold rather than the exemplar's mixed styles. ACCEPTED.
6. **Paragraph numbering in the sample** is the template's (1 to 39), not the filing's. See Sample.
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the Gate 2 table above is the review.
8. **Certificate of service** is not generated: L.Civ.R. 7.5 does not call for one on a complaint, and the exemplar has none. Service of a complaint is by summons, which is not part of this template.
9. **File names.** The brief names the files `<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. The tools read and write `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (see `tools/render.sh` and `tools/overlay.sh`), so the tool names are used.
