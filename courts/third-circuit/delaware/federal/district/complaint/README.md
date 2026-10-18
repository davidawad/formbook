# D. Del. (ded): complaint

Doc type: **complaint** in the United States District Court for the District of Delaware (`ded`). Folder: `courts/third-circuit/delaware/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole 8-page complaint (caption, title, allegations under their headings, prayer, jury demand, signature block, footnote 1) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh ...`) |
| overlay | ok: `usage/OVERLAY-boston-scientific-complaint.pdf` and `OVERLAY-boston-scientific-complaint.txt` (`sh tools/overlay.sh ...`) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and looked at after the last template change) |
| tier 2 | not judged against two or three filers: one exemplar only (see Known gaps, 1) |
| typeface | face required: none. LR 5.1.1(a) says "plainly typewritten or printed" and "at least 12 point"; no typeface is named (checked 2026-10-15 against the 2026 rules PDF). Substitute: none; EB Garamond stays (vendored, `fonts/FONTS.md`, "No face named"). Fit: not applicable. |

File names follow the repo's role convention and the tools' defaults (`INPUT-` for the markdown, `OUTPUT-` for our render, `OVERLAY-` for the comparison), not the `<id>.pdf` names in the task brief, because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

Primary source: D. Del. Local Rules of Civil Practice and Procedure, revised, effective September 1, 2026: https://www.ded.uscourts.gov/sites/ded/files/2026%20District%20of%20Delaware%20Revised%20Local%20Rules%20Effective%20September%201.pdf (the court's "Revised Local Rules Effective September 1" PDF, created 2026-08-04). Read and quoted 2026-10-14. The 2016 compilation (`https://www.ded.uscourts.gov/sites/ded/files/local-rules/District%20of%20Delaware%20LOCAL%20RULES%202016.pdf`) has the same 12-point, double-spacing and 1-inch rules, but it is superseded, so the 2026 text governs.

Federal rules: Fed. R. Civ. P. 10(a), 10(b) and 38(b), read from https://www.law.cornell.edu/rules/frcp/rule_10 and https://www.law.cornell.edu/rules/frcp/rule_38 on 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Del. LR 5.1.1(a) | 8½ × 11 white paper; plainly typed, double-spaced "according to typical word processing software" and not "exactly 24 point"; all printed matter at least 12 point; margins at least 1 inch; pages numbered consecutively; the date of filing and a brief descriptive title; Delaware counsel's name, bar number, address, telephone and email under the signature line. | `page-margin` (1 in); `type-size` (13 pt) and `footer-size` (13 pt, page numbers are printed matter); `line-pitch` and `body-leading`; footer page number; `Dated:` line and the counsel block in `signature-block`. |
| D. Del. LR 5.1.1(b) | Exhibits, letters and removed-case papers are exempt. | Not applicable: the complaint is a pleading. |
| D. Del. LR 3.2 | In a patent case, the patents at issue, with any re-examination certificates, are attached to the complaint. | Not checked by the template. The sample's Exhibit A (the '955 Patent) is named in the text and is not in the render. |
| D. Del. LR 3.1(a)-(b) | Civil cover sheet (except pro se); related-action indication on the cover sheet. | Not produced: a separate filing. |
| Fed. R. Civ. P. 10(a) | Every pleading has a caption with the court's name, a title, a file number and a Rule 7(a) designation. | `cover()`: court title (two lines), the parties block in `caption()` with `C.A. No.` and the title below it. The Rule 7(a) designation is in the pleading's title. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers every paragraph; headings and the prayer are not numbered; `!` marks an unnumbered paragraph (WHEREFORE, jury demand), as the filing does. |
| Fed. R. Civ. P. 38(b) | A jury demand may be served in the pleading. | `jury_demand: true` puts `JURY TRIAL DEMANDED` in the caption; the demand paragraph is in the body. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (LR 3.1(a)), the Rule 7.1 disclosure statement, the summons, and any Delaware-specific certification the assigned judge requires.

## Layout

- Letter paper; 1-inch margins; EB Garamond (vendored) at 13 pt; double spacing at about 2.08 em (27 pt at 13 pt).
- Caption: the court title centred on two lines (`IN THE UNITED STATES DISTRICT COURT` / `FOR THE DISTRICT OF DELAWARE`); the parties on the left with `v.` between them and the designation indented; `C.A. No.` and `JURY TRIAL DEMANDED` on the right; the complaint's title centred below.
- Body: paragraphs numbered from 1 with a 0.5 in first-line indent; headings centred bold (level 1 caps, level 2 bold); prayer items lettered `A.`, `B.`, ...
- Signature block: `Dated:` on the left; the firm and the signing counsel on the right, with the `/s/` line; further counsel under them; `Attorneys for ...` last.
- No pleading paper (no line numbers, no rules): the rules do not require it for electronic filing, and the exemplar has none.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number` (blank for a new complaint: prints `C.A. No.` with nothing after it), `caption.parties` (list of `{names, designation}`), `title`, `jury_demand`, `lead_in` (optional unnumbered opening sentence), `date`, `signature` (`firm` lines, `signer`, `lines`), `attorneys_for` (optional lines under the signature).
- Body chunks are separated by blank lines: `#` heading (level 1 centred caps), `##` (level 2 centred bold), `###` (level 3 bold italic); a paragraph (numbered); a list (`1.` items, lettered `A.` by the template); `!` at the start of a paragraph for an unnumbered paragraph.
- Footnotes: `[^name]` in the text and `[^name]: text` anywhere in the body; the template attaches each definition to the paragraph that cites it (cmarker resolves a footnote only when its definition is in the same source).
- The sample must not put numbering in the text: the template numbers the paragraphs.
- No forced line breaks; no case-specific text in the template; no coordinates measured off the exemplar.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/third-circuit/delaware/federal/district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/third-circuit/delaware/federal/district/complaint boston-scientific-complaint
```

- `OVERLAY-boston-scientific-complaint.pdf`: red = our render, blue = exemplar, black = both. The page map pairs pages by word overlap: ours p.1-p.6 with filed p.1-p.6 (78 to 92 percent word overlap), ours p.7 (the prayer end and jury demand) with filed p.7 (28 percent: the jury demand and the page shape differ), ours p.8 (the signature block) with filed p.7 (54 percent). The overlay is a diagnostic, not a score: the exemplar is a Times New Roman filing and the render is EB Garamond, so glyphs do not coincide; the pairing shows which page each render page matches.

## Review of the rendered pages (Gate 2 record, all 8 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption, title, paragraphs 1 to 4 | OK after the caption and paragraph-spacing fixes (caption lines no longer overlap; paragraph spacing equals the body leading, so the next paragraph starts a full line below). |
| 2 | Paragraphs 5 to 11, headings Jurisdiction and Venue, Factual Background | OK. |
| 3 | Paragraphs 12 to 16, count heading | OK. |
| 4 | Paragraphs 17 to 18, footnote 1 at the foot of the page | OK. The footnote renders from the `[^ap196]` definition. |
| 5 | Paragraphs 19 to 20 | OK. |
| 6 | Paragraph 21, Prayer for Relief heading, WHEREFORE (unnumbered), items A to I | OK. |
| 7 | Item J, Jury Trial Demand heading and its unnumbered paragraph | OK. The earlier "24." empty numbered paragraph (a footnote definition rendered as text) is gone. |
| 8 | Date, firm and signing counsel, `/s/`, counsel block, Attorneys for Plaintiffs | OK. The signature block is single-spaced and starts on its own page, since it is not split across pages. |

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers. Checked and not saved: Darcy v. The Chemours Company, No. 1:26-cv-01299 (22 pages, a putative class action, filed 2026-10-08 by Ryan Darcy, text layer present, RECAP `recap/gov.uscourts.ded.94968/gov.uscourts.ded.94968.1.0.pdf`); Secure Ink LLC v. ICE Mortgage Technology, Inc., No. 1:26-cv-01304 (5 pages, filed 2026-10-12, text layer present, a short patent complaint). Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** The rules name no typeface (LR 5.1.1(a), LR 7.1.3(a)(2)), so EB Garamond stays. Liberation Serif (Times metric) is vendored, but the exemplar's Times New Roman is the filer's choice, which the rule does not require, so it is not used. The rule's floor is 12 point and is met at 13 pt; choice of 13 pt is a style choice, recorded here.
3. **Assigned judge's standing order.** The rules set 12 point. A secondary source (a 2019 law-firm newsletter, found by web search, not the order itself) says Chief Judge Connolly's standing order asks for 14-point type in case-dispositive briefs and in concise statements of fact, with word limits and a word-count certificate. The primary order was not retrieved (the standing-orders page could not be opened from this box). Before filing in front of a particular judge, check that judge's standing order; if it sets 14 pt, change `type-size` (and the footer, if the order says "all printed matter").
4. **Double spacing.** LR 5.1.1(a) says double spacing "according to typical word processing software". The template uses about 2.08 em (27 pt at 13 pt), measured from the render; it was not compared with a word processor's "double" for EB Garamond. The exemplar's pitch (about 27.6 pt at 12 pt) is the reference.
5. **Caption style.** The party block is closed by a rule on the right and bottom (N.D. Cal. style) rather than the exemplar's plain layout: the BSC exemplar has no rule at all. Recorded as a convention choice.
6. **LR 3.2 attachments.** The template does not check that the patents are attached; the sample names Exhibit A and Exhibit B but does not render them.
7. **Paragraph numbers.** The template numbers from 1 and the exemplar's numbers match (1 to 21), but the exemplar's numbering was not checked paragraph by paragraph against the transcription beyond the page-by-page review above.
8. **Italics.** Case names and Latin signals in the sample are italicised where the transcription recognised them (`*...*`); the exemplar's italic faces were not compared glyph by glyph.
9. **Separate filings** (civil cover sheet, Rule 7.1 disclosure, summons) are not generated and are not checked.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.docx`, `docx/ded.lua`, `docx/build-reference.sh`): `pandoc --from markdown+smart --to docx --reference-doc=docx/reference.docx --lua-filter=docx/ded.lua usage/INPUT-complaint.md -o usage/OUTPUT-complaint.docx`, run from the court folder. The reference carries the typst form: EB Garamond 13 pt, 27 pt exact line pitch, 1 in margins, 0.5 in first-line indent, single-spaced 13 pt footnotes, centred 13 pt page number. The filter builds the caption (borderless table, `C.A. No.` and `JURY TRIAL DEMANDED` at right), the title, the lead-in, the numbered allegations, the lettered prayer and the signature block. Differences: paragraph numbers are typed text (number and em space), not a Word list; the caption has no rule, as in the typst template; Word and LibreOffice break lines differently from typst.
- Checked here: the `.docx` is a valid zip with well-formed XML parts (CRC read and `xmllint`). Not checked: opening in Word or LibreOffice (LibreOffice is not installed in the build box).
- docx BLOCKED: every gate check measured on the LibreOffice PDF (`usage/OUTPUT-boston-scientific-complaint.docx.pdf`, Gates 0 to 3). No check IDs can be listed: this court folder has no `checks.yaml`. Reason: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.

[Formbook index](../../../../../README.md) | [Delaware federal index](../README.md)
