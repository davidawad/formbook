# W.D. Wis. (wiwd): complaint

Doc type: **complaint** in the United States District Court for the Western District of Wisconsin (`wiwd`).
Folder: `courts/seventh-circuit/wisconsin/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-olson-3-26-cv-01012-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-olson-complaint.md` (a portion of the 34-page filing: caption, sections I to IV in part, prayer A to F, jury demand, signature) |
| render | ok: `samples/OUTPUT-olson-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-olson-complaint.pdf` and `OVERLAY-olson-complaint.txt` (page map below) |
| pages reviewed | 9 of 9 rendered at 60 dpi and viewed (see the review section) |

File names: the brief asks for `<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh` and `tools/overlay.sh` read and write the role-prefixed names (`INPUT-`, `OUTPUT-`, `OVERLAY-`), so those are used here (see CLAUDE.md, "File roles are in the name").

## Governing rules

| Rule | Requirement | Where it is in the template | Verified |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | `court-title`, `caption` (case number, parties, title). | Text fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10 |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | `allegations()` numbers every ordinary paragraph. Prayer lead-in and jury demand are unnumbered (`^` marker in the sample). | Same page as above, first sentence. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, of the claim, and of the relief. | Author content. The template does not check the wording. | Cited from the rule; not re-fetched in this pass. |
| W.D. Wis. LR 5.1 (Rule 5 of the posted Local Rules) | "Unless otherwise ordered by the court, papers shall be filed, signed and served electronically as required by the Court's Administrative Procedures for Electronic Filing and Service." | Not template content. The Administrative Procedures are not on the court's site (see gaps). | Read from https://www.wiwd.uscourts.gov/sites/default/files/Local_Rules.pdf (the 2018 posted set; read 2026-10-14). |
| Fed. R. Civ. P. 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." | No certificate of service is generated for the complaint. A complaint is not usually served by the filer's own CM/ECF notice; the summons and service are separate. | Text fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_5 |

**Not verified: the W.D. Wis. form rules.** The court's posted Local Rules (the 2018 set, five rules: LR 83.5, 72.1, 16.6 CJ, 47.2, 5.1) have no rule on the form of papers. The civil local rules (LR 7, LR 10) are not on https://www.wiwd.uscourts.gov/local-rules. The court's Briefing Guidelines (https://www.wiwd.uscourts.gov/sites/default/files/Briefing_Guidelines.pdf, dated 8/07 in the footer) give no font, spacing or margin rules. So the template's font (12 pt), margins (1 in), double spacing and page size are **conventions, matched to the exemplar**, not rule citations. Recorded as an open question for David (see Known gaps, 1).

Not produced by this template (separate filings, or not called for by the rules reviewed): civil cover sheet (JS-44; the filed exemplar attaches one with its summons), Rule 7.1 disclosure statement, summons, Civil cover sheet. The exemplar's attachments are not in the sample.

## Layout

- Court title centered in bold caps (`UNITED STATES DISTRICT COURT` / `WESTERN DISTRICT OF WISCONSIN`), then a caption: parties on the left in a column closed by a rule, `Case No.` on the right.
- Title of the paper centered in bold below the caption.
- Body double-spaced (24 pt pitch at 12 pt, `body-leading = 1.35em`), 1-inch margins, page number centered in the footer.
- Headings: level 1 centered bold caps (`I. NATURE OF THE CASE`, `PRAYER FOR RELIEF`); level 2 centered bold; level 3 bold italic at the left margin (the sub-heading `A.`, `B.`, `C.` of the facts).
- Numbered allegations, first-line indent 0.5 in. Markdown lists become lettered items (`A.`, `B.`, ...).
- Signature block: "Dated:", "Respectfully submitted," the firm, then `/s/ name` and the lines for each signer, single-spaced.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are separated by a blank line: a `#` heading (level 1); a list (`1.` items, lettered by the template); a paragraph starting with `^` (rendered unnumbered, `^` removed); any other paragraph (numbered by the template).
- Frontmatter fields: `case_number`, `caption.parties` (`{names, designation}`; "v." inserted between parties), `brief_title`, `counsel` (optional, not rendered; the exemplar has counsel at the end), `date`, `signature` (`firm`, `signers` with `name` and `lines`, `role`).
- Not supported: tables, footnotes, raw typst. Lists are lettered (`A.`), not numbered.
- The template numbers the allegations; the sample does not type the numbers.

## Overlay: what it shows

`OVERLAY-olson-complaint.txt` pairs each sample page with the filed page that shares the most words:

```
ours p.1  filed p.1  word-overlap 62.4%
ours p.2  filed p.6  word-overlap 39.5%
ours p.3  filed p.8  word-overlap 50.6%
ours p.4  filed p.9  word-overlap 51.8%
ours p.5  filed p.11  word-overlap 66.1%
ours p.6  filed p.13  word-overlap 46.3%
ours p.7  filed p.31  word-overlap 64.6%
ours p.8  filed p.33  word-overlap 57.6%
ours p.9  filed p.34  word-overlap 48.8%
```

The overlay is a diagnostic, not a score. Pages 2 to 6 of the sample are paired with filed pages that are not in the sample (the sample is a portion), so the overlap there is low by design. The caption (page 1) and the prayer and signature (pages 8 and 9) line up with their filed pages. The filed exemplar's font (Times New Roman) is not EB Garamond, so letterforms differ on every page; that is expected.

## Known gaps and open choices

1. **W.D. Wis. form rules not located (open question for David).** The template's font, size, margins and spacing are conventions matched to the exemplar, not rule citations. A future pass needs the civil local rules (LR 7, LR 10 or their equivalent) or a confirmation from the clerk. Until then the template makes no claim that it complies with a W.D. Wis. form rule.
2. **Font.** The filed exemplar uses Times New Roman. The vendored font is EB Garamond (the only font in `fonts/`). EB Garamond at 12 pt is narrower and has a smaller x-height, so the sample is shorter than the exemplar at the same page count. A Times-metric font would close this; it is not vendored.
3. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `court=wiwd`, complaints filed 2026-10-02 to 2026-10-13) found Iconocare Strategic Branding (3:26-cv-01023, 7 pages, Times New Roman and Calibri, counsel Reimann; too short to show a full complaint) and Sieverding v. Koritzinsky & Karls (3:26-cv-00627, 36 pages, scanned, no text layer). Tier 2 is therefore not judged against two filers.
4. **Caption.** The party column is closed by a right rule and a bottom rule, not a column of `)` marks. The exemplar uses the same party/case-number split with no column of marks; this is a convention choice.
5. **Counsel block at the top.** The exemplar puts counsel at the end (signature block). The template follows the exemplar and has no top counsel block. A court that wants the N.D. Cal.-style top block would need the `counsel` field rendered; the field exists but is not rendered.
6. **Paragraph numbers differ.** The sample numbers its allegations from 1; the filed numbers run to 216. The sample's section headings are transcribed as filed (roman numerals and lettered sub-headings), but filed pages 13 to 29 are only partly transcribed, so some paragraph numbers in the sample have no filed counterpart.
7. **Italics.** Case names and statutes are roman in the transcription (the text layer has no italic markup for this filing).
8. **Not run: `tools/check.sh`, `tools/check-selftest.sh`, `tools/tracker.sh`.** These expect a court folder with `court.json` and `rules.md` in the court directory; this doc-type folder has neither. The brief forbids running the tracker and editing `tools/`. The render and overlay steps were run; the review below is the Gate 2 equivalent.
9. **Medical detail omitted** from the transcription (filed paragraphs on the plaintiff's health are not transcribed).

## Review of the rendered pages (`OUTPUT-olson-complaint.pdf`, 9 pages)

Each page rendered at 60 dpi and viewed after the last template change.

- Page 1: court title, caption with the case number at right, title centered, section I heading, paragraphs 1 to 4 double-spaced with indent, no overlap. Pass.
- Page 2: paragraph 5; section II PARTIES (paragraphs 6 to 8); section III heading (paragraph 9). Pass.
- Page 3: paragraphs 10 to 12; section IV heading; sub-heading A (bold italic, left) kept with its first paragraph; paragraphs 13 to 20. Pass.
- Page 4: paragraphs 21 to 31; sub-heading B kept with its first paragraph. Pass.
- Page 5: paragraphs 32 to 41; sub-heading C on page 5 with its first paragraph. Pass.
- Page 6: paragraphs 42 to 55. Pass.
- Page 7: paragraphs 56 to 62; the last paragraph carries onto page 8. Pass.
- Page 8: paragraphs 63 and 64; PRAYER FOR RELIEF heading; WHEREFORE lead-in unnumbered (`^`); items A to D. Pass.
- Page 9: items E and F; JURY DEMAND heading; the demand unnumbered; "Dated:", the firm, both `/s/` signature blocks. Pass.

Defects found during review and fixed: (a) the first render stacked lines on top of each other (block spacing zero against a 0.65 em line box; fixed by setting block spacing to the double-spacing leading and by stacking the court title as a single-spaced block); (b) WHEREFORE and the jury-demand sentence were numbered (fixed with the `^` marker).
