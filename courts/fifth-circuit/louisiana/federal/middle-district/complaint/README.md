# lamd: complaint

Doc type: **complaint** in the United States District Court for the Middle District of Louisiana (`lamd`).
Folder: `courts/fifth-circuit/louisiana/federal/middle-district/complaint/`. Court-root `typst/` and `samples/` are not touched.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-parker-3-25-cv-01162-complaint.pdf` (one counsel-filed complaint; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-parker-complaint.md` (the whole 5-page filing, transcribed) |
| render | ok: `samples/OUTPUT-parker-complaint.pdf`, 5 pages, `tools/render.sh`, typst 0.15.0, vendored EB Garamond only, no typst warnings |
| overlay | ok: `samples/OVERLAY-parker-complaint.pdf` and `samples/OVERLAY-parker-complaint.txt` (`tools/overlay.sh`, page map below) |
| pages reviewed | 5 of 5 (every page rendered at 60 dpi and viewed after the last template change) |
| gates | `tools/check.sh` and `tools/check-selftest.sh` not run: they expect a court folder with `court.json` and `rules.md`, and the brief forbids touching `tools/`. No `court.json` or stamp written. |

File names: the brief names `samples/<id>.md` and `samples/<id>-overlay.pdf`. The tools use `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (CLAUDE.md: "The tools read and write these names by default"), so the tool names are used.

## Governing rules

Primary source: M.D. La. Local Civil Rules, "2022 Local Rules" (effective 2022-06-30), https://www.lamd.uscourts.gov/sites/default/files/pdf/2022_Local_Rules_6-30-2022.pdf. Fetched and read 2026-10-14 (78-page PDF, text extracted with `pdftotext -layout`). The rules text is the version posted on the court's site; the search did not show any later revision. Fed. R. Civ. P. 8, 10 and 7.1 are cited by number from the Federal Rules; their text was not re-fetched in this pass.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 10(a)(1) | 8½ × 11 paper, numbered sequentially, typeface no smaller than standard 12-point, double spaced, margins no less than 1 inch, nothing printed in the margins except page numbers, page numbers no less than ½ inch from the bottom. Footnotes may be 10-point; quotations and footnotes may be single spaced. | `page-w`/`page-h`, `type-size = 12pt`, `margin = 1in`, `body-leading = 1.35em` (24 pt pitch), `footer-descent = 0.6in`, `page-footer()`. No block quotations in this doc type; a `>` line in the markdown is an unnumbered paragraph (the jurisdiction statement, the WHEREFORE lead-in). |
| LR 10(a)(2) | After allotment, the caption shows the initials of the district judge and the magistrate judge (example `10-CV-292-JVP-SCR`). | `civil_action_no` + `judges` in the frontmatter build the file number; `judge`/`magistrate` lines are optional. |
| LR 10(a)(3) | Civil Cover Sheet accompanies the initial pleading. | Not produced here (separate filing). |
| LR 10(a)(4) | Civil complaints are accompanied by a separately filed, signed certificate of interested persons. | Not produced here (separate filing). The complaint itself is not required to carry it. |
| LR 11(a)(1), (3) | Signed by counsel admitted to practice here; counsel's name, address, telephone and fax numbers, email and Attorney Identification Number typed under the signature. | `signature.lines` (sample carries them); the `RESPECTFULLY SUBMITTED:` block is in the template, at 3 in from the left. |
| LR 7.1 | Certificate of interested persons: separate, signed, with a complete list or a statement that there are none. | Not produced here (separate filing). |
| Fed. R. Civ. P. 10(a) | Caption with the court name, the title of the action, the file number, and the title of the paper. | `court-name` (the court's name, a constant of the template), caption grid, `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers every paragraph; headings, lists and `>` paragraphs are unnumbered. |
| Fed. R. Civ. P. 7(a) | The pleading is a complaint (the designation is the title). | `title` in the sample. |

Not checked by the template: the wording of counts, whether a jury demand is made (Fed. R. Civ. P. 38; no jury line is in the template, the sample has none), and whether LR 9 special matters apply.

## Layout

- Court name in bold, centered, two lines, at the top of page 1 (LR 10(a)(1) is silent on it; the court's name is the Rule 10(a) caption).
- Caption: party names in a left column, one line each, "VERSUS" between the parties; the civil action number with the judge initials (`CIVIL ACTION NO. 3:25-cv-01162-SDD-EWD`) and the optional judge lines in the right column. No column of asterisks: the Parker exemplar has one, but the other M.D. La. exemplar captions (Carpenter, First Horizon) do not, so it is one filer's style (EVAL-LOOP tier 3) and was dropped.
- Title centered, bold, uppercase; subtitle centered, roman.
- Body: double spaced, first-line indent ½ inch, paragraphs numbered 1, 2, ... (Rule 10(b)). Section headings are centered bold caps (`# I. JURISDICTION AND VENUE`); count headings are centered bold (`## COUNT 1 – NEGLIGENCE`); sub-headings are bold, left (`### A. ...`). A heading is kept with the paragraph after it.
- Prayer items (markdown list) are numbered 1., 2., ... unindented, with the list kept together with the signature block.
- Signature block: `RESPECTFULLY SUBMITTED:`, a signature line `BY: ____`, then the counsel lines, single spaced, at 3 in from the left margin. The last chunk of the body is kept on the same page as the signature block, so a signature never starts a page alone.
- Page numbers: centered, in the bottom margin, ½ inch or more from the bottom edge.
- Ragged right (no justification). The exemplar's justification could not be read from its text layer.

## Measured (render)

- Body baseline pitch: 24.0 pt (measured from `pdftotext -bbox` on page 2; line pitch of double-spaced body text). Paragraph spacing is set equal to the pitch: with spacing 0 consecutive paragraphs overprinted (found on the first render, fixed).
- Page 1: court name at top margin; caption rows single spaced; file number `CIVIL ACTION NO. 3:25-cv-01162-SDD-EWD` on one line (the first render wrapped it; the party column is 2.7 in; checked with `pdftotext -bbox`, pages 2 to 5 unchanged by that edit).
- Text area 6.5 × 9 in; 27 double-spaced lines per full page.

## Overlay (red = ours, blue = filed; pages paired by word overlap)

From `samples/OVERLAY-parker-complaint.txt`:

```
ours p.1  filed p.1  word-overlap 76.0%
ours p.2  filed p.2  word-overlap 63.1%
ours p.3  filed p.3  word-overlap 53.7%
ours p.4  filed p.4  word-overlap 36.6%
ours p.5  filed p.5  word-overlap 56.6%
```

The overlay is a diagnostic, not a score. Differences seen: the filed caption and body are Times New Roman, ours is EB Garamond, so glyph shapes and widths differ on every page. Page breaks differ: the filed page 4 ends in paragraph 22 and filed page 5 starts with the damages bullets; ours page 4 ends after the WHEREFORE paragraph and page 5 starts with the prayer list (kept with the signature). That is why page 4 pairs at only 36.6%.

## Gate 2 review (every page of the current PDF, viewed at 60 dpi)

| Page | Exemplar page | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | court name, caption (names, VERSUS, file number with judge initials on one line), title, subtitle, opening paragraph, paragraphs 1-2 under I. | PASS |
| 2 | exemplar p.2 | paragraphs 3-13, headings II, III, A-C left bold, numbering 3-13 matches the filing. | PASS |
| 3 | exemplar p.3 | paragraphs 14-25, D and E sub-headings, IV, COUNT 1 and COUNT 2 centered. | PASS |
| 4 | exemplar p.4 | paragraphs 26-30, COUNT 3, V DAMAGES bullets, VI PRAYER heading, WHEREFORE paragraph. | PASS |
| 5 | exemplar p.5 | prayer items 1-5, signature block (RESPECTFULLY SUBMITTED, BY line, counsel lines). The signature block is on page 5 with the prayer list. | PASS |

Tier-2 conventions (judged against the one exemplar available; see Known gaps): caption layout, numbered paragraphs, centered section headings with bold count headings, signature block placement.

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The RECAP search (`court=lamd`, document search for "COMPLAINT", many queries) found one counsel-filed complaint with a PDF: Parker (this exemplar). `Verdin` (3:25-cv-00658, amended complaint, Document 43, 12 pages, Arial) has no counsel named on the docket entry; it was not saved. The CourtListener API rate limit (5 requests/minute) cut the search short. Tier 2 is therefore **not** judged against two filers for this doc type. A second counsel-filed MDLA complaint should be sought before the doc type is called done.
2. **Font.** LR 10(a)(1) requires "standard" 12-point type. The exemplar is Times New Roman. The only serif vendored in `fonts/` is EB Garamond, which at 12 pt has a smaller x-height, so the text looks smaller than the exemplar. The point size meets the rule; a Times-metric font would remove the difference. Question for David: vendor a Times-metric font, or accept EB Garamond (as the ca9 templates do).
3. **Second structurally different sample not made.** EVAL-LOOP Gate 3 asks for a second, fictional sample. The brief asks for one transcription per doc type; not done.
4. **Certificate of interested persons (LR 7.1, LR 10(a)(4)).** Required with the complaint; not produced by this template (separate filing).
5. **Judge initials.** The sample carries `SDD`/`EWD` as the allotted initials. The exemplar header shows them; the caption in the exemplar leaves the JUDGE lines blank. The template prints the judge lines only when the frontmatter gives them.
6. **Jury demand.** Not in the template (the rule for it is Fed. R. Civ. P. 38, not an LR 10 form rule). The sample has none; a complaint with a jury demand would need the line added by the author.
7. **Paragraph text is ragged-right.** Justification not read from the exemplar.
8. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` need `court.json` and `rules.md` in the court folder; this doc-type folder has neither. The Gate 2 table above is the review record.
