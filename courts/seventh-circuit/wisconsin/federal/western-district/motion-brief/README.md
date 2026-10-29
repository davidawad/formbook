# W.D. Wis. (wiwd): motion brief (memorandum in support of a motion to dismiss)

Doc type: **motion-brief**: a brief in support of a Rule 12(b) motion to dismiss, one filed document, in the United States District Court for the Western District of Wisconsin (`wiwd`).
Folder: `courts/seventh-circuit/wisconsin/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole brief: caption, opening, Parts I and II, conclusion, signature) |
| typeface | Face required by the rules: **none named** (W.D. Wis. LR list and Briefing Guidelines checked; see "Not verified" below). Vendored substitute: none needed. Font: **Times New Roman** (vendored), the house standard (`docs/FONTS.md`), in typst and docx alike (fb-595.68.28; David's 2026-10-17 ruling: the exemplar's Century Schoolbook is one filer's style, tier 3; the typst had been TeX Gyre Schola and the docx EB Garamond). `data/exemplar-fonts.json` records `template_face` Times New Roman over the audited Schola match. |
| render | ok (re-rendered 2026-10-22, fb-595.68.28): `usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, 7 pages each, typst 0.15.0, vendored Times New Roman only (regular, bold, bold italic, embedded), no warnings |
| overlay | **not re-run**: the filed exemplar PDF is not in `usage/` in this snapshot (only `SOURCE.md`), so `tools/overlay.sh` cannot run. `usage/OVERLAY-drone-motion-to-dismiss.txt` is the page map from an earlier run against the filed PDF; `OVERLAY-drone-motion-to-dismiss.pdf` is not in the snapshot. |
| pages reviewed | 7 of 7, typst and docx, re-rendered at 50 dpi and viewed 2026-10-22 (see the review section) |

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

Since fb-595.17.16 the folder is on the generic federal district brief: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay (each choice cited there), `typst/wiwd-motion-brief.typ` names the face, and `lib/typst/xdoc.typ` sets the layout; `latex/` and `docx/` are generated from the merged layout by `fb engines gen`.

- Court title centered in bold caps (`{xd.court}` / `{xd.district}`, layout constants), a rule across the page; the caption with the parties on the left (each party's names, its designation 1.5 in in, `v.` at the margin, a single line between) and `Case No.` beside them, centered on their height; a rule, the title of the brief centered in bold, a rule, as the exemplar (its three underscore rows).
- Body double-spaced (24 pt line boxes at 12 pt; single lines 13.8 pt), first-line indent 0.5 in, paragraphs unnumbered (a brief, not a numbered pleading).
- Headings at 12 pt on the body pitch, no space of their own: level 1 centered bold caps (`CONCLUSION`); level 2 bold at the left margin (argument headings, `I.`, `II.` as typed); level 3 bold italic at the left margin (sub-argument).
- Lists: the model's numbered list, the number in a half-inch box at the margin, the lines hanging after it (the exemplar's `a.)` lettering is that filer's style, tier 3).
- Signature block 2.75 in from the margin, kept with the last paragraph: the preamble ("Respectfully submitted this [date]"), a double line, `/s/` signature, the signer's name and the lines for bar number, role, address, telephone, fax, email.
- Page number (12 pt, the base's) centered at the foot.

## Markdown contract (for samples)

- YAML frontmatter, then the body: a `#` heading (level 1, centered caps), a `##` heading (argument heading, bold, left), a `###` heading (sub-argument, bold italic, left), a list (`1.` items), or a paragraph (indented, unnumbered).
- Frontmatter fields: `case_number`, `caption.parties` (`{names, designation}`; "v." inserted between parties), `brief_title`, `date` (not printed), `signature` (`preamble` lines, `signer`, `lines`).
- Not supported: raw typst, certificates (none in this sample).
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

The overlay is a diagnostic, not a score. The sample is the whole brief, so the pairing is one-to-one in content, but the page breaks differ: the filed brief is 10 pages (Century Schoolbook), and this render is 7 pages (that overlay was run with EB Garamond, before the switch to Times New Roman). The filed caption is a `*` column; the template uses a rule-closed party column (a convention). The filed exemplar's fonts differ, so letterforms differ on every page; that is expected.

## Known gaps and open choices

1. **W.D. Wis. form rules not located (open question for David).** Font size, margins, spacing and signature placement are conventions matched to the exemplar, not rule citations. The W.D. Wis. page limit for briefs is not checked (`eval.yaml` has no `page_limit`). A future pass needs the civil local rules (LR 7, LR 10 or their equivalent) or confirmation from the clerk.
2. **Font and length.** The filed exemplar uses Century Schoolbook, but no rule names a face, so the template is set in Times New Roman 12 pt, the house standard, in both engines (fb-595.68.28; was TeX Gyre Schola in typst and EB Garamond in the docx). The sample is 7 pages where the filed brief (Century Schoolbook, wider) is 10; the content is the whole brief.
3. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `court=wiwd`, brief-in-support-of-motion-to-dismiss entries) found 2700 Winter LLC v. Paine (7 pages, Times New Roman, counsel for the City of Superior; text layer present) and Inspired Pursuits LLC v. Paragon Component Systems (8 pages; no text layer). The 2700 Winter brief would be the second filer if collected. Tier 2 is not judged against two filers.
4. **Caption.** Since fb-595.17.16 the caption follows the exemplar: rules across the page under the court name and around the title, no box; the exemplar's `*` column is not copied (tier 3).
5. **No table of contents or table of authorities.** The brief is under 10 pages and the exemplar has neither. A longer brief would need them; the template does not produce them.
6. **Italics.** Case names are roman in the transcription (the text layer of the exemplar carries no italic markup). The template italicizes `*...*` markdown, so future samples can carry italics.
7. **Paragraph numbering.** Briefs are not numbered; the sample's paragraphs are unnumbered and the exemplar's are too.
8. **Gate scripts.** Since fb-595.17.16: `sh tools/check.sh <this folder>` exits 0 on typst (11 passed), latex (14) and docx (15), 0 failed; XENG-001..003 PASS on latex and docx (191/191 lines, 7 = 7 pages); DEF-COVER-002 PASS on all three (3 rules vs 3), so the folder left `data/cover-structure-baseline.txt`.

## Review of the rendered pages (`OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx.pdf`, 7 pages each)

Re-rendered on the FRCP base (fb-595.17.16) and reviewed page by page as text layout and word boxes (`pdftotext -layout`, the cover-structure measurer); the latex and docx renders break every line and page as typst does (XENG-001..003), so one review covers the three.

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, rule, caption (Case No. centered beside the parties), rule, two-line bold title, rule, opening paragraphs. | Pass. DEF-COVER-002 0 differences. |
| 2 | Opening continued; the four-line "I." argument heading kept with its first paragraph. | Pass. |
| 3 | Part I continued; the bold italic sub-heading kept with its first paragraph. | Pass. |
| 4 | Part I, the counts. | Pass. |
| 5 | Part I ends. | Pass. |
| 6 | "II." argument heading; the four elements, numbered 1. to 4., the third hanging after its number. | ACCEPTED: numbered, not lettered `a.)` as the filer (tier 3). |
| 7 | CONCLUSION centered; final paragraphs; the signature block 2.75 in from the margin. | Pass. |

## Engines

**typst** is the primary engine (`typst/main.typ`, `typst/wiwd-motion-brief.typ`, `typst/layout.yaml`). **latex** (`latex/template.tex`, `latex/xdoc.lua`) and **docx** (`docx/reference.xml`, `docx/xdoc.lua`) are generated by `fb engines gen` from the merged layout (`fb engines gen --check` fails on a stale one) and set by the shared code (`lib/pandoc/xdoc.lua`, `lib/latex/xdoc.lua`, `lib/docx/xdoc.lua`). The old docx filter `docx/wiwd-motion-brief.lua` is removed. The `.docx` converts in LibreOffice without error; not opened in Word. TOC and TOA: not produced (the brief is under 10 pages).
