# W.D. Wis. (wiwd): motion brief (memorandum in support of a motion to dismiss)

Doc type: **motion-brief**: a brief in support of a Rule 12(b) motion to dismiss, one filed document, in the United States District Court for the Western District of Wisconsin (`wiwd`).
Folder: `courts/seventh-circuit/wisconsin/federal/western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-drone-3-26-cv-00539-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-drone-motion-to-dismiss.md` (the whole brief: caption, opening, Parts I and II, conclusion, signature) |
| render | ok: `samples/OUTPUT-drone-motion-to-dismiss.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-drone-motion-to-dismiss.pdf` and `OVERLAY-drone-motion-to-dismiss.txt` (page map below) |
| pages reviewed | 7 of 7 rendered at 60 dpi and viewed (see the review section) |

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
2. **Font and length.** The filed exemplar uses Century Schoolbook; the vendored font is EB Garamond. At 12 pt EB Garamond is narrower, so the sample is 7 pages where the filed brief is 10. The brief's 8-to-14-page target is not met in page count; the content is the whole brief. A Century-Schoolbook-metric font would close this; none is vendored.
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
