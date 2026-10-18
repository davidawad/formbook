# W.D. Wis. (wiwd): complaint

Doc type: **complaint** in the United States District Court for the Western District of Wisconsin (`wiwd`).
Folder: `courts/seventh-circuit/wisconsin/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (a portion of the 34-page filing: caption, sections I to IV in part, prayer A to F, jury demand, signature) |
| typeface | Face required by the rules: **none named** (W.D. Wis. LR list and Briefing Guidelines checked; see "Not verified" below). Vendored substitute: none needed. Font kept: **EB Garamond** (`docs/FONTS.md`, "No face named"). Times substitute `Liberation Serif` is vendored but not used, since no rule asks for Times. |
| render | ok (re-rendered 2026-10-15): `usage/OUTPUT-complaint.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only (pdffonts: EB Garamond Regular, Bold, BoldItalic, all embedded), no warnings |
| overlay | **not re-run**: the filed exemplar PDF is not in `usage/` in this snapshot (only `SOURCE.md`), so `tools/overlay.sh` cannot run. `usage/OVERLAY-olson-complaint.txt` is the page map from an earlier run against the filed PDF; `OVERLAY-olson-complaint.pdf` is not in the snapshot. |
| pages reviewed | 9 of 9 re-rendered at 60 dpi and viewed 2026-10-15 (see the review section) |

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
2. **Font.** The filed exemplar uses Times New Roman, but no rule the template cites names a face, so the template keeps EB Garamond. `Liberation Serif`, the Times-metric substitute, is vendored (`docs/FONTS.md`). EB Garamond at 12 pt is narrower and has a smaller x-height, so the sample is shorter than the exemplar at the same page count. Switching to `Liberation Serif` is a filer's choice unless a local rule or the clerk requires Times.
3. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `court=wiwd`, complaints filed 2026-10-02 to 2026-10-13) found Iconocare Strategic Branding (3:26-cv-01023, 7 pages, Times New Roman and Calibri, counsel Reimann; too short to show a full complaint) and Sieverding v. Koritzinsky & Karls (3:26-cv-00627, 36 pages, scanned, no text layer). Tier 2 is therefore not judged against two filers.
4. **Caption.** The party column is closed by a right rule and a bottom rule, not a column of `)` marks. The exemplar uses the same party/case-number split with no column of marks; this is a convention choice.
5. **Counsel block at the top.** The exemplar puts counsel at the end (signature block). The template follows the exemplar and has no top counsel block. A court that wants the N.D. Cal.-style top block would need the `counsel` field rendered; the field exists but is not rendered.
6. **Paragraph numbers differ.** The sample numbers its allegations from 1; the filed numbers run to 216. The sample's section headings are transcribed as filed (roman numerals and lettered sub-headings), but filed pages 13 to 29 are only partly transcribed, so some paragraph numbers in the sample have no filed counterpart.
7. **Italics.** Case names and statutes are roman in the transcription (the text layer has no italic markup for this filing).
8. **Not run: `tools/check.sh`, `tools/check-selftest.sh`, `tools/tracker.sh`.** These expect a court folder with `court.json` and `rules.md` in the court directory; this doc-type folder has neither. The brief forbids running the tracker and editing `tools/`. The render and overlay steps were run; the review below is the Gate 2 equivalent.
9. **Medical detail omitted** from the transcription (filed paragraphs on the plaintiff's health are not transcribed).

## Review of the rendered pages (`OUTPUT-complaint.typst.pdf`, 9 pages)

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

## Engines

**typst** is the primary engine (sections above). **latex**: not built here. **docx**: built, not checked.

Files: `docx/reference.docx` (made by `docx/build-reference.sh <out>`: pandoc plus libzip's `ziptool`, no `zip` or `unzip` needed) and `docx/wiwd-complaint.lua` (cover, caption table, numbered allegations, lettered lists, signature block). No case text is in either file.

What matches typst (set in the reference; checked against the source, not a rendered docx):
- Font: EB Garamond 12 pt, the only vendored face (`docs/FONTS.md`), named in the document defaults and the body, heading and footer styles. Typst's PDF embeds EB Garamond Regular, Bold and BoldItalic only (`pdffonts`, measured).
- Page: US Letter, 1 in margins on every side (`w:pgSz` 12240 x 15840, `w:pgMar` 1440; measured in the output `.docx`).
- Line pitch: exact 24 pt for body text, headings and lettered items (the "double" pitch in `wiwd-complaint.typ`).
- First-line indent 0.5 in on numbered allegations; numbers are typed as `N.` followed by a tab.
- Footer: centered `PAGE` field, 11 pt.
- Typst output for comparison: 9 pages, EB Garamond only (`/work/artifacts/wiwd/complaint/OUTPUT-olson-complaint.pdf`, outside the court folder). The `.docx` page count is not measured.

What differs from typst (not verified in a rendered docx):
- Paragraph gaps: the docx sets no space before or after body paragraphs; `wiwd-complaint.typ` sets block spacing equal to the body leading. The gap on the page is not measured.
- Allegation numbers are typed text, not Word list numbering, so they do not renumber when a paragraph is added.
- Caption: a Word table, with the right and bottom rules on the left cell. Borders differ between Word and LibreOffice (`docs/DOCX.md`).
- The cover and signature take plain text from the frontmatter; markdown inside frontmatter values (italics) is not carried.
- Headings use keep-with-next and keep-lines; that is not checked against a render.

BLOCKED (docx):
- `docx.pdf` and the page-by-page review: `soffice` (LibreOffice) is not installed on this box and cannot be installed here. Gates 0 and 1 cannot run on `usage/OUTPUT-olson-complaint.docx.pdf`.
- `tools/render-docx.sh` integrity check: `unzip` is not installed on this box, so the script exits 1 at its zip test, before `soffice`. Checked by hand instead: the `.docx` lists 17 parts and every `.xml` and `.rels` part is well formed (`xmllint`), and pandoc reads its text back in order.
- TOC and TOA: not produced. The typst template does not produce them and the complaint has none.
- Pleading line numbers: not in the typst template, so not built.
