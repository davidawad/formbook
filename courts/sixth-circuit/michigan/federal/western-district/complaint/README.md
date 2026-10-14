# miwd: complaint

Doc type: **complaint** in the United States District Court for the Western District of Michigan (`miwd`).
Folder: `courts/sixth-circuit/michigan/federal/western-district/complaint/`. Self-contained: it does not touch the court root (`court.json`, `typst/`, `samples/`, `exemplars/`).

| Item | Status |
|---|---|
| exemplar | yes: 2 filers, `exemplars/FILED-EXAMPLE-google-calhoun-1-25-cv-724-complaint.pdf` (primary, Goodman Hurwitz & James) and `exemplars/FILED-EXAMPLE-cohen-interlochen-1-26-cv-2598-complaint.pdf` (second filer, Flood Law). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-google-complaint.md`: a portion of the 42-page filing (7 rendered pages) |
| render | ok: `samples/OUTPUT-google-complaint.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-google-complaint.pdf` and `samples/OVERLAY-google-complaint.txt` (against the primary exemplar) |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed; see the review below) |

Build, from the repo root (`PATH` must include the toolchain, see the brief's setup):

```sh
sh tools/render.sh courts/sixth-circuit/michigan/federal/western-district/complaint samples/INPUT-google-complaint.md
sh tools/overlay.sh courts/sixth-circuit/michigan/federal/western-district/complaint google-complaint exemplars/FILED-EXAMPLE-google-calhoun-1-25-cv-724-complaint.pdf
```

`tools/render.sh` writes `samples/OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `samples/OVERLAY-<id>.pdf` and `.txt`. The brief names these `<id>.pdf` and `<id>-overlay.pdf`; the tools (which this box must not edit) use the `OUTPUT-`/`OVERLAY-` names, so those are what is delivered.

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| LCivR 10.1 (W.D. Mich.) | All documents double spaced, 8 1/2 x 11, one side; type no smaller than 12 point; margins at least one inch. (Electronic filings must be PDF: LCivR 5.7(d)(i), same source.) | Local Civil Rules, as posted: https://www.miwd.uscourts.gov/sites/miwd/files/Local%20Civil%20Rules.pdf (text dated "Updated February 1, 2018"; the court's rules page shows last modified January 1, 2019). | `type-size = 12pt`, `pitch = 24pt`, `margin = 1in`, `body-leading` (typst/miwd-complaint.typ). |
| LCivR 10.3 | Date of signing and the address and telephone number of the signing attorney. | same | `signature` frontmatter (`signer`, `lines`), `date`. |
| LCivR 5.1 | A civil cover sheet obtained from the Clerk is filed with each new case. | same | Not produced (a separate form). |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all parties. | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14) | `court-title`, `caption`. The Rule 7(a) designation is in the title. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | same | `allegations()`: every paragraph is numbered 1, 2, ... until the `numbering_stops_at` heading. |
| Fed. R. Civ. P. 11(a) | Every paper signed by at least one attorney, stating the signer's address, e-mail address and telephone number. | https://www.law.cornell.edu/rules/frcp/rule_11 (verified 2026-10-14, lead-in text) | `signature-block`. |
| Fed. R. Civ. P. 5.2(a) | Social-security, taxpayer, birth-date, minor and financial-account information is redacted. | https://www.law.cornell.edu/rules/frcp/rule_5.2 | Author responsibility (not checked by the template). |

Not produced by this template (separate filings or author responsibility): the civil cover sheet (LCivR 5.1), the summons, the Rule 7.1 disclosure statement, the redaction of Rule 5.2 information (author), and any W.D. Mich. certificate of service.

## Layout (as built)

- Cover, page 1 (no number): court title centered (three lines, the division from the frontmatter), the caption (parties in the left column closed by a rule; the case number, judge and title in the right column), then the counsel block, single spaced, at the lower left.
- Page 2 opens with the title centered in bold, then the lead-in paragraph.
- Body: double spaced (24 pt pitch), first-line indent 0.5 in. Numbered paragraphs (number at 0.5 in, text after a 0.3 in gap, wrapped lines flush left). Headings centered: level 1 bold capitals, level 2 bold, level 3 regular, each followed by one blank line.
- Lists (the request for relief) are lettered A., B., ... with one double-spaced line between items.
- Signature: "Dated" on the left, "Respectfully submitted," the firm, "By: /s/" the signer and the remaining lines on the right. It is kept unbreakable with the final paragraph, so it never stands alone on a page.
- Page numbers centered at the foot of every page after the cover (convention; the rules set no footer).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number` (blank prints a blank line), `judge` (blank prints a blank line), `division`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `counsel` (list of `{names, lines}` groups), `lead_in` (optional, unnumbered), `date`, `signature` (`firm` list, `signer` string, `lines` list), `numbering_stops_at` (heading text after which paragraphs are not numbered; the request for relief).
- Body: blank-line-separated chunks. `#` heading (level 1 centered bold capitals), `##` (level 2 centered bold), `###` (level 3 centered); a list (`1.` items, lettered by the template); or a paragraph (numbered by the template). Do not type paragraph numbers.
- Not supported: tables, footnotes (none used), raw typst.

## Review (Gate 2 equivalent, current PDF)

Each page was rendered at 60 dpi and viewed. The comparison is with the primary exemplar (Google, filed 06/27/25), and with the second filer (Cohen, filed 09/16/26) for layout conventions.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | Google p.1 (caption, counsel) | Court title, caption with rule, case number and judge blanks, title in the right column, counsel below the caption. The filed page carries a CM/ECF header ("Case 1:25-cv-00724-MV ECF No. 1 ... Filed 06/27/25 Page 1 of 42") that the clerk's system adds; the template does not produce it. Cohen p.1 places the title below the caption; both conventions appear. | ACCEPTED (the clerk's header is not author content; title placement is a tier-2 choice seen in both filers) |
| 2 | Google p.2 | Title centered, lead-in, "JURISDICTION AND VENUE" heading, numbered paragraphs 1 to 3. | PASS |
| 3 | Google p.3 | "PARTIES" and "GENERAL ALLEGATIONS" centered; paragraphs 4 to 15 double spaced, no overlap. | PASS |
| 4 | Google p.4 | Paragraphs 16 to 25; page ends with white space because the next heading is kept with its paragraph. | PASS |
| 5 | Google p.9 (general allegations) | Paragraphs 26 to 34, numbering continuous. | PASS |
| 6 | Google p.15 (count I) | "CLAIMS FOR RELIEF", "COUNT I" and its subtitle centered; paragraphs 36 to 42. | PASS |
| 7 | Google p.40 to 41 (prayer, jury demand, signature) | Request for relief unnumbered, items A to E, "JURY DEMAND" heading, date and signature block kept together. | PASS |

Tier-2 items that are open choices and are recorded as accepted:

- **Font.** The exemplars are set in Times New Roman (Google) and Garamond (Cohen). Only EB Garamond is vendored here, so the template uses it. LCivR 10.1 sets the size (12 point) and not the family, so the rule is met. EB Garamond has a smaller x-height than Times, so the text looks smaller on the page than the exemplar. A Times-metric font would remove the difference; whether to vendor one is David's call.
- **Signature.** The Google exemplar signs after the prayer and again after the jury demand. The template prints one signature block, after the jury demand. No rule requires the repeat.

## Overlay (`samples/OVERLAY-google-complaint.pdf`)

Red is our render, blue is the filed exemplar (Google), black is where both agree. Pages are paired by shared words, not by index: ours p.1 with filed p.1 (93.5% word overlap), p.2 with p.2 (70.6%), p.3 with p.5 (56.0%), p.4 with p.6 (42.0%), p.5 with p.9 (65.0%), p.6 with p.15 (61.7%), p.7 with p.41 (69.6%); the mapping is `samples/OVERLAY-google-complaint.txt`. The differences are the typeface, the sample's paragraph numbers (they start at 1 and do not match the filed numbers) and the omitted paragraphs. The overlay is a diagnostic, not a score.

## Known gaps

1. **Sample is a portion.** The filing is 42 pages; the sample carries filed paragraphs 1 to 26, 29 to 38, 41 to 46 and 69 to 75, the request for relief and the jury demand. Paragraph numbers in the sample run from 1.
2. **One filer per type is the brief's minimum; two are collected.** Both are in `exemplars/`. Gate 2 was done against the primary; the second filer was compared for layout only.
3. **Font** (above).
4. **Not produced:** cover sheet (JS-44), summons, Rule 7.1 disclosure, Rule 5.2 redaction (author), certificate of service.
5. **Checker not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder has neither. The brief forbids editing `tools/`, so the gates were not run; the review above stands in for Gate 2.
6. **Proposed local-rule change.** Administrative Order 26-RL-054 (June 26, 2026; comment period closed July 27, 2026; https://www.miwd.uscourts.gov/sites/miwd/files/Admin%20Order%2026-RL-054.pdf) proposes the same LCivR 10.1 text, with an e-mail address added to LCivR 10.3. I did not find a final adopted version. Check before landing.
7. **Caption placement.** The Google exemplar places the title at the right of the caption and repeats it on page 2; the template does the same.

## Searches (exemplar)

CourtListener search for W.D. Mich. complaints (`court=miwd`, RECAP `type=r`, filed 2024 to 2026). Candidates were downloaded and checked for a text layer. Gulley (2009, scanned) and Phifer (2008, no RECAP PDF) were set aside for age. Chosen: Google (42 pp., Times, counsel-drafted) and Cohen (45 pp., Garamond, counsel-drafted).
