# D. Del. (ded): complaint

Doc type: **complaint** in the United States District Court for the District of Delaware (`ded`). Folder: `courts/third-circuit/delaware/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole 8-page complaint (caption, title, allegations under their headings, prayer, jury demand, signature block, footnote 1) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf` and `OUTPUT-complaint.docx` / `.docx.pdf`, 8 pages each, Times New Roman 12 pt, no warnings; the docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | ok: `usage/OVERLAY-boston-scientific-complaint.pdf` and `OVERLAY-boston-scientific-complaint.txt` (`sh tools/overlay.sh ...`) |
| pages reviewed | 8 of 8 on each engine (rendered at 45 dpi and looked at side by side after the last template change, 2026-10-22) |
| tier 2 | not judged against two or three filers: one exemplar only (see Known gaps, 1) |
| typeface | face required: none. LR 5.1.1(a) says "plainly typewritten or printed" and "at least 12 point"; no typeface is named (checked 2026-10-15 against the 2026 rules PDF). Substitute: Times New Roman, the house face (vendored, `docs/FONTS.md`, "No face named"; the exemplar is Times New Roman too); the docx names the typst face (`{font}`). It was EB Garamond 13 pt until fb-595.68.34. Fit: not applicable. |

File names follow the repo's role convention and the tools' defaults (`INPUT-` for the markdown, `OUTPUT-` for our render, `OVERLAY-` for the comparison), not the `<id>.pdf` names in the task brief, because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

Primary source: D. Del. Local Rules of Civil Practice and Procedure, revised, effective September 1, 2026: https://www.ded.uscourts.gov/sites/ded/files/2026%20District%20of%20Delaware%20Revised%20Local%20Rules%20Effective%20September%201.pdf (the court's "Revised Local Rules Effective September 1" PDF, created 2026-08-04). Read and quoted 2026-10-14. The 2016 compilation (`https://www.ded.uscourts.gov/sites/ded/files/local-rules/District%20of%20Delaware%20LOCAL%20RULES%202016.pdf`) has the same 12-point, double-spacing and 1-inch rules, but it is superseded, so the 2026 text governs.

Federal rules: Fed. R. Civ. P. 10(a), 10(b) and 38(b), read from https://www.law.cornell.edu/rules/frcp/rule_10 and https://www.law.cornell.edu/rules/frcp/rule_38 on 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Del. LR 5.1.1(a) | 8½ × 11 white paper; plainly typed, double-spaced "according to typical word processing software" and not "exactly 24 point"; all printed matter at least 12 point; margins at least 1 inch; pages numbered consecutively; the date of filing and a brief descriptive title; Delaware counsel's name, bar number, address, telephone and email under the signature line. | `page-margin` (1 in); `type-size` (12 pt, the footnotes and the page number too: printed matter); `pitch-body` (27.6 pt); footer page number; `Dated:` line and the counsel block in `signature-block`. |
| D. Del. LR 5.1.1(b) | Exhibits, letters and removed-case papers are exempt. | Not applicable: the complaint is a pleading. |
| D. Del. LR 3.2 | In a patent case, the patents at issue, with any re-examination certificates, are attached to the complaint. | Not checked by the template. The sample's Exhibit A (the '955 Patent) is named in the text and is not in the render. |
| D. Del. LR 3.1(a)-(b) | Civil cover sheet (except pro se); related-action indication on the cover sheet. | Not produced: a separate filing. |
| Fed. R. Civ. P. 10(a) | Every pleading has a caption with the court's name, a title, a file number and a Rule 7(a) designation. | `cover()`: court title (two lines), the parties block in `caption()` with `C.A. No.` and the title below it. The Rule 7(a) designation is in the pleading's title. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `render-chunk()` numbers every paragraph; headings and the prayer are not numbered; `<!-- unnumbered -->` marks an unnumbered paragraph (WHEREFORE, jury demand), as the filing does. |
| Fed. R. Civ. P. 38(b) | A jury demand may be served in the pleading. | `jury_demand: true` puts `JURY TRIAL DEMANDED` in the caption; the demand paragraph is in the body. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (LR 3.1(a)), the Rule 7.1 disclosure statement, the summons, and any Delaware-specific certification the assigned judge requires.

## Layout

- Letter paper; 1-inch margins; Times New Roman (vendored) at 12 pt; double spacing on a 27.6 pt pitch (2 x 1.15 x 12 pt, LR 5.1.1(a) "typical word processing software"; the exemplar's pitch); single lines, footnotes and the footer on a 13.8 pt pitch. Cross-engine layout model (`lib/typst/xengine.typ`): first fit, ragged right (the sample's `word:` justification map is gone with `word-compat`), no hyphenation.
- Caption: the court title centred on two lines (`IN THE UNITED STATES DISTRICT COURT` / `FOR THE DISTRICT OF DELAWARE`); the parties on the left with `v.` between them and the designation 2 in in, the party column ruled at its right (as the exemplar); `C.A. No.` and `JURY TRIAL DEMANDED` on the right; the complaint's title centred below.
- Body: paragraphs numbered from 1, the number at the 0.5 in indent and the text from 1 in; headings bold on the body pitch with no space of their own (level 1 centred caps, level 2 centred, level 3 bold italic); prayer items lettered `A.`, `B.`, ... half an inch in, the text hanging at 1 in.
- Signature block: single lines in a column from 3.1 in, `Dated:` left of its first line; the firm, a blank line, the signing counsel with the `/s/` line, further counsel, a blank line and `Attorneys for ...`. It runs over a page as the filed one does.
- No pleading paper (no line numbers, no rules): the rules do not require it for electronic filing, and the exemplar has none.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number` (blank for a new complaint: prints `C.A. No.` with nothing after it), `caption.parties` (list of `{names, designation}`), `title`, `jury_demand`, `lead_in` (optional unnumbered opening sentence), `date`, `signature` (`firm` lines, `signer`, `lines`), `attorneys_for` (optional lines under the signature).
- Body chunks are separated by blank lines: `#` heading (level 1 centred caps), `##` (level 2 centred bold), `###` (level 3 bold italic); a paragraph (numbered); a list (`1.` items, lettered `A.` by the template); `<!-- unnumbered -->` at the start of a paragraph for an unnumbered paragraph (the docx filter reads the rest of that line again as markdown: CommonMark takes the line for an HTML block).
- Footnotes: `[^name]` in the text and `[^name]: text` anywhere in the body; 12 pt single-spaced under a short rule (LR 5.1.1(a): all printed matter at least 12 point).
- The sample must not put numbering in the text: the template numbers the paragraphs.
- No forced line breaks; no case-specific text in the template; no coordinates measured off the exemplar.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/third-circuit/delaware/federal/district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/third-circuit/delaware/federal/district/complaint boston-scientific-complaint
```

- `OVERLAY-boston-scientific-complaint.pdf`: red = our render, blue = exemplar, black = both. The page map pairs pages by word overlap: ours p.1-p.6 with filed p.1-p.6 (78 to 92 percent word overlap), ours p.7 (the prayer end and jury demand) with filed p.7 (28 percent: the jury demand and the page shape differ), ours p.8 (the signature block) with filed p.7 (54 percent). The overlay is a diagnostic, not a score; it predates the move to Times New Roman and the 27.6 pt pitch (fb-595.68.34) and was not re-run.

## Review of the rendered pages (Gate 2 record, all 8 pages on each engine, rendered at 45 dpi and looked at side by side, 2026-10-22)

Every page of the typst and docx renders carries the same lines (XENG-003, 194/194).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (the party column ruled at its right; `C.A. No.` and `JURY TRIAL DEMANDED` at the right), title, lead-in, Nature of the Action, Parties, paragraphs 1 to 3 | OK. |
| 2 | Paragraphs 4 to 11; Jurisdiction and Venue; Factual Background | OK: "§§ 1331" kept with its number. |
| 3 | Paragraphs 11 to 16; Count I heading | OK. |
| 4 | Paragraphs 16 to 18 | OK. |
| 5 | Paragraphs 18 to 20; footnote 1 under a short rule | OK: the footnote at 12 pt, single spaced. |
| 6 | Paragraph 21; Prayer for Relief; WHEREFORE (unnumbered); items A to D | OK: letters half an inch in, the text hanging at 1 in. |
| 7 | Items E to J; Jury Trial Demand and its unnumbered paragraph; `Dated:` and the signature block to "Sarah Jack" | ACCEPTED (tier 2): the block runs over the page, as the filed one does (filed pp. 7 to 8); here one counsel group is split between the pages. |
| 8 | The rest of the counsel groups; `Attorneys for Plaintiffs` | OK. |

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers. Checked and not saved: Darcy v. The Chemours Company, No. 1:26-cv-01299 (22 pages, a putative class action, filed 2026-10-08 by Ryan Darcy, text layer present, RECAP `recap/gov.uscourts.ded.94968/gov.uscourts.ded.94968.1.0.pdf`); Secure Ink LLC v. ICE Mortgage Technology, Inc., No. 1:26-cv-01304 (5 pages, filed 2026-10-12, text layer present, a short patent complaint). Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** The rules name no typeface (LR 5.1.1(a), LR 7.1.3(a)(2)), so the house face applies: Times New Roman 12 pt, the exemplar's face too, at the rule's floor (it was EB Garamond 13 pt until fb-595.68.34).
3. **Assigned judge's standing order.** The rules set 12 point. A secondary source (a 2019 law-firm newsletter, found by web search, not the order itself) says Chief Judge Connolly's standing order asks for 14-point type in case-dispositive briefs and in concise statements of fact, with word limits and a word-count certificate. The primary order was not retrieved (the standing-orders page could not be opened from this box). Before filing in front of a particular judge, check that judge's standing order; if it sets 14 pt, change `type-size` (and the footer, if the order says "all printed matter").
4. **Double spacing.** LR 5.1.1(a) says double spacing "according to typical word processing software". The template uses 27.6 pt (2 x 1.15 x 12 pt), the exemplar's pitch, in exact line boxes in both engines.
5. **Caption style.** The party column is ruled at its right, as in the exemplar; no rule below it. The exemplar underlines its title and headings; the template sets them bold without a rule (tier 3).
6. **LR 3.2 attachments.** The template does not check that the patents are attached; the sample names Exhibit A and Exhibit B but does not render them.
7. **Paragraph numbers.** The template numbers from 1 and the exemplar's numbers match (1 to 21), but the exemplar's numbering was not checked paragraph by paragraph against the transcription beyond the page-by-page review above.
8. **Italics.** Case names and Latin signals in the sample are italicised where the transcription recognised them (`*...*`); the exemplar's italic faces were not compared glyph by glyph.
9. **Separate filings** (civil cover sheet, Rule 7.1 disclosure, summons) are not generated and are not checked.

## Engines

Engine status: typst `OUTPUT-complaint.typst.pdf`; docx `OUTPUT-complaint.docx` and `.docx.pdf` (LibreOffice), 8 pages each, every line and page as typst (XENG-001..003 gated, `eval.yaml`); latex not built.

- **typst** (primary, `typst/`): on `lib/typst/xengine.typ`: a 27.6 pt body pitch, 13.8 pt single lines (court title, caption, title, signature, footnotes, footer), explicit block spaces.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 27.6 pt lines with a 0.5 in first-line indent; single lines and footnotes in 13.8 pt boxes, 7 pt after a footnote; "Numbered Paragraph" with a tab to 1 in for the number and "List Letter" hanging at 1 in) and `docx/ded-complaint.lua` (on `lib/docx/xengine.lua`): the court title, the caption (a one-row table, the party cell bordered at its right), the title, the numbered paragraphs and prayer items (paragraphs pandoc writes, so footnotes are Word footnotes), the headings, the signature block, the footer (a centred PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh` and a committed `reference.docx` in EB Garamond 13 pt). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none.

[Formbook index](../../../../../README.md) | [Delaware federal index](../README.md)
