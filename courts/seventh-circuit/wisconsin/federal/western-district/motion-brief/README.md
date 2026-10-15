# W.D. Wis. (wiwd): motion brief (memorandum in support of a motion to dismiss)

Doc type: **motion-brief**: a brief in support of a Rule 12(b) motion to dismiss, one filed document, in the United States District Court for the Western District of Wisconsin (`wiwd`).
Folder: `courts/seventh-circuit/wisconsin/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-drone-3-26-cv-00539-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-drone-motion-to-dismiss.md` (the whole brief: caption, opening, Parts I and II, conclusion, signature) |
| typeface | Face required by the rules: **none named** (W.D. Wis. LR list and Briefing Guidelines checked; see "Not verified" below). Vendored substitute: none needed. Font kept: **EB Garamond** (`docs/FONTS.md`, "No face named"). Century substitute `TeX Gyre Schola` is vendored but not used, since no rule asks for Century. |
| render | ok (re-rendered 2026-10-15): `samples/OUTPUT-drone-motion-to-dismiss.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only (pdffonts: EB Garamond Regular, Bold, BoldItalic, all embedded), no warnings |
| overlay | **not re-run**: the filed exemplar PDF is not in `exemplars/` in this snapshot (only `SOURCE.md`), so `tools/overlay.sh` cannot run. `samples/OVERLAY-drone-motion-to-dismiss.txt` is the page map from an earlier run against the filed PDF; `OVERLAY-drone-motion-to-dismiss.pdf` is not in the snapshot. |
| pages reviewed | 7 of 7 re-rendered at 60 dpi and viewed 2026-10-15 (see the review section) |

File names: the brief asks for `<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh` and `tools/overlay.sh` read and write the role-prefixed names (`INPUT-`, `OUTPUT-`, `OVERLAY-`), so those are used here (see CLAUDE.md, "File roles are in the name").

## Governing rules

| Rule | Requirement | Where it is in the template | Verified |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation. | `court-title`, `caption`, `brief_title`. | Text fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10 |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order must be made by motion; the motion must state with particularity the grounds for seeking the order. | The brief's title names the motion it supports. The template does not check the motion. | Cited from the rule; not re-fetched in this pass. |
| Fed. R. Civ. P. 12(b)(1), (6) | Grounds for dismissal: lack of subject-matter jurisdiction; failure to state a claim. | Author content (the exemplar argues both). | Cited from the rule and the exemplar; not re-fetched. |
| Fed. R. Civ. P. 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." | No certificate of service is generated; the brief is served through CM/ECF. | Text fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_5 |
| W.D. Wis. LR 5.1 (Rule 5 of the posted Local Rules) | "Unless otherwise ordered by the court, papers shall be filed, signed and served electronically as required by the Court's Administrative Procedures for Electronic Filing and Service." | Not template content. | Read from https://www.wiwd.uscourts.gov/sites/default/files/Local_Rules.pdf (the 2018 posted set; read 2026-10-14). |
| W.D. Wis. Briefing Guidelines | "MOTIONS PURSUANT TO Fed. R. Civ. P. 12(b)(6) or 12(c). If either party desires to present to the court matters outside of the pleadings, leave to do so must be obtained from the court by filing a request in motion format." | Not template content. The brief must not rely on matters outside the pleadings without leave. The exemplar's Rooker-Feldman argument relies on the complaint's own allegations and the state-court record it cites; the template does not check this. | https://www.wiwd.uscourts.gov/sites/default/files/Briefing_Guidelines.pdf (footer dated 8/07; read 2026-10-14). The guideline is dated; treat it as the last posted version. |

**Not verified: the W.D. Wis. form rules.** The posted Local Rules (five rules, 2018 set) have no rule on the form of papers, and the civil local rules (LR 7, LR 10) are not on the court's site. The Briefing Guidelines give no font, spacing, margin, or page-limit rule. So the 12-point type, 1-inch margins, double spacing, page size, and the signature block placement are **conventions, matched to the exemplar**, not rule citations. The page limit for briefs is not checked. Recorded as an open question for David (see Known gaps, 1).

Not produced by this template: the proposed order (separate filing), any declaration or exhibit, the Rule 7.1 disclosure statement, and a table of contents or table of authorities (the exemplar has neither; the brief is under 10 pages). A certificate of service is not generated (see Rule 5(d)(1)(B) above).

## Layout

- Court title centered in bold caps (`IN THE UNITED STATES DISTRICT COURT` / `FOR THE WESTERN DISTRICT OF WISCONSIN`), then the caption with parties on the left and `Case No.` on the right.
- Title of the brief centered in bold below the caption.
- Body double-spaced (24 pt pitch at 12 pt), first-line indent 0.5 in, paragraphs unnumbered (a brief, not a numbered pleading).
- Headings: level 1 centered bold caps (`CONCLUSION`); level 2 bold at the left margin (argument headings `I.`, `II.`); level 3 bold italic at the left margin (sub-argument).
- Lists: lettered items (`a.`, `b.`, ...).
- Signature block in the right half of the page, left-aligned within it: "Respectfully submitted this [date]", then `/s/` signature, the signer's name and the lines for bar number, role, address, telephone, fax, email.
- Page number centered in the footer.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are separated by a blank line: a `#` heading (level 1, centered caps, used for CONCLUSION only in this sample), a `##` heading (argument heading, bold, left), a `###` heading (sub-argument, bold italic, left), a list (`1.` items, lettered `a.` by the template), or a paragraph (indented, unnumbered).
- Frontmatter fields: `case_number`, `caption.parties` (`{names, designation}`; "v." inserted between parties), `brief_title`, `date`, `signature` (`preamble` lines, `signer`, `lines`).
- Not supported: tables, footnotes, raw typst, certificates (none in this sample).

## Overlay: what it shows

`OVERLAY-drone-motion-to-dismiss.txt` pairs each sample page with the filed page that shares the most words:

```
ours p.1  filed p.1  word-overlap 66.0%
ours p.2  filed p.3  word-overlap 58.2%
ours p.3  filed p.4  word-overlap 76.2%
ours p.4  filed p.5  word-overlap 56.8%
ours p.5  filed p.7  word-overlap 83.7%
ours p.6  filed p.8  word-overlap 67.9%
ours p.7  filed p.10  word-overlap 49.2%
```

The overlay is a diagnostic, not a score. The sample is the whole brief, so the pairing is one-to-one in content, but the page breaks differ: the filed brief is 10 pages (Century Schoolbook), and this render is 7 pages (EB Garamond, narrower). The filed caption is a `*` column; the template uses a rule-closed party column (a convention). The filed exemplar's fonts differ, so letterforms differ on every page; that is expected.

## Known gaps and open choices

1. **W.D. Wis. form rules not located (open question for David).** Font size, margins, spacing and signature placement are conventions matched to the exemplar, not rule citations. The W.D. Wis. page limit for briefs is not checked, and the template has no page counter. A future pass needs the civil local rules (LR 7, LR 10 or their equivalent) or confirmation from the clerk.
2. **Font and length.** The filed exemplar uses Century Schoolbook, but no rule the template cites names a face, so the template keeps EB Garamond. `TeX Gyre Schola`, a metric-compatible Century Schoolbook substitute, is vendored (`docs/FONTS.md`). At 12 pt EB Garamond is narrower, so the sample is 7 pages where the filed brief is 10. The brief's 8-to-14-page target is not met in page count; the content is the whole brief. Switching to `TeX Gyre Schola` is a filer's choice unless a local rule or the clerk requires Century.
3. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `court=wiwd`, brief-in-support-of-motion-to-dismiss entries) found 2700 Winter LLC v. Paine (7 pages, Times New Roman, counsel for the City of Superior; text layer present) and Inspired Pursuits LLC v. Paragon Component Systems (8 pages; no text layer). The 2700 Winter brief would be the second filer if collected. Tier 2 is not judged against two filers.
4. **Caption.** The party column is closed by a right rule and a bottom rule. The exemplar uses a `*` column; this is a convention choice.
5. **No table of contents or table of authorities.** The brief is under 10 pages and the exemplar has neither. A longer brief would need them; the template does not produce them.
6. **Italics.** Case names are roman in the transcription (the text layer of the exemplar carries no italic markup). The template italicizes `*...*` markdown, so future samples can carry italics.
7. **Paragraph numbering.** Briefs are not numbered; the sample's paragraphs are unnumbered and the exemplar's are too.
8. **Not run: `tools/check.sh`, `tools/check-selftest.sh`, `tools/tracker.sh`.** The same reason as the complaint folder: these expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither, and the brief forbids running the tracker and editing `tools/`.

## Review of the rendered pages (`OUTPUT-drone-motion-to-dismiss.pdf`, 7 pages)

Each page rendered at 60 dpi and viewed after the last template change.

- Page 1: court title, caption with `Case No. 26 CV 539` at right, title centered bold, opening paragraphs. Pass.
- Page 2: continuation of the opening; "I." argument heading bold, left, kept with its first paragraph; first paragraphs of Part I. Pass.
- Page 3: Part I continued; sub-argument heading (bold italic) kept with its first paragraph. Pass.
- Page 4: Part I list of counts, paragraphs (indentation consistent). Pass.
- Page 5: Part I ends; the conclusion of Part I on page 5 (no heading at the foot of a page). Pass.
- Page 6: "II." argument heading at the top of the page; the lettered elements a. to d. render as a list. Pass.
- Page 7: "CONCLUSION" centered; final paragraphs; signature block in the right half, left-aligned within it. Pass (after the change from right-aligned lines; see below).

Defects found during review and fixed: (a) the first render stacked blocks on top of each other (the same zero-spacing cause as the complaint; fixed by block spacing equal to the double-spacing leading); (b) the signature block was right-aligned line by line, which wrapped the preamble badly; it is now left-aligned in the right half.

## Engines

**typst** is the primary engine (sections above). **latex**: not built here. **docx**: built, not checked.

Files: `docx/reference.docx` (made by `docx/build-reference.sh <out>`: pandoc plus libzip's `ziptool`, no `zip` or `unzip` needed) and `docx/wiwd-motion-brief.lua` (cover, caption table, lettered lists, signature block in the right half). No case text is in either file.

What matches typst (set in the reference; checked against the source, not a rendered docx):
- Font: EB Garamond 12 pt, the only vendored face (`docs/FONTS.md`), named in the document defaults and the body, heading and footer styles. Typst's PDF embeds EB Garamond Regular, Bold and BoldItalic only (`pdffonts`, measured).
- Page: US Letter, 1 in margins on every side (`w:pgSz` 12240 x 15840, `w:pgMar` 1440; measured in the output `.docx`).
- Line pitch: exact 24 pt for body text, headings and lettered items (the "double" pitch in `wiwd-motion-brief.typ`).
- First-line indent 0.5 in on body paragraphs; paragraphs are not numbered.
- Headings: level 1 centered bold caps; level 2 bold at the left margin; level 3 bold italic at the left margin.
- Signature block: a "Signature" paragraph style indented 2.75 in (typst: pad 2.75 in), `/s/` line, the signer's name, then the lines.
- Footer: centered `PAGE` field, 11 pt.
- Typst output for comparison: 7 pages, EB Garamond only (`/work/artifacts/wiwd/motion-brief/OUTPUT-drone-motion-to-dismiss.pdf`, outside the court folder). The `.docx` page count is not measured.

What differs from typst (not verified in a rendered docx):
- Paragraph gaps: the docx sets no space before or after body paragraphs; `wiwd-motion-brief.typ` sets block spacing equal to the body leading. The gap on the page is not measured.
- Lettered items are typed `a.` followed by a tab, not Word list numbering.
- Caption: a Word table, with the right and bottom rules on the left cell. Borders differ between Word and LibreOffice (`docs/DOCX.md`).
- The cover and signature take plain text from the frontmatter; markdown inside frontmatter values (italics) is not carried.
- Headings use keep-with-next and keep-lines; that is not checked against a render.

BLOCKED (docx):
- `docx.pdf` and the page-by-page review: `soffice` (LibreOffice) is not installed on this box and cannot be installed here. Gates 0 and 1 cannot run on `samples/OUTPUT-drone-motion-to-dismiss.docx.pdf`.
- `tools/render-docx.sh` integrity check: `unzip` is not installed on this box, so the script exits 1 at its zip test, before `soffice`. Checked by hand instead: the `.docx` lists 17 parts and every `.xml` and `.rels` part is well formed (`xmllint`), and pandoc reads its text back in order.
- TOC and TOA: not produced. The typst template does not produce them and the brief is under 10 pages in the sample.
- Pleading line numbers: not in the typst template, so not built.
