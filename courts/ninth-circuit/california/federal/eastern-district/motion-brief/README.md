# caed: motion-brief

Doc type: **motion-brief**, a Rule 12(b) motion to dismiss (or for a more definite statement) with the notice of motion and a memorandum of points and authorities, in the United States District Court for the Eastern District of California (`caed`).
Folder: `courts/ninth-circuit/california/federal/eastern-district/motion-brief/` (self-contained; the court root's `typst/` and `usage/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: caption, notice of motion (pages 1 to 2 of the filing) and its signature, the table of contents and table of authorities (in full), memorandum introduction and facts (part), Rule 12(e) argument (part), conclusion and signature. Memorandum Part III.A to III.C are not transcribed (see Known gaps). |
| typeface | face required: none in the E.D. Cal. Local Rules (checked, 2026-10-14; the local-rules text itself was not re-fetched on 2026-10-15). Judge standing orders may set a face or size; the assigned judge's standing order (TLN Civil Standing Order) was not read, so it is not verified. Font: **Times New Roman** 12 pt (vendored; the exemplar's face), in typst and docx alike (fb-595.68.22). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf` and `.docx.pdf`, 9 pages each (typst 0.15.0, pdfLaTeX, LibreOffice), no warnings (2026-10-29, on the shared document model, fb-595.96) |
| overlay | `just overlay <this folder>` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 9 of 9 on each engine rendered to PNG at 60 dpi (27 images, `.overlay/`); read by their text layout and line geometry (2026-10-29: the image viewer of the agent pod could not open them; see Gate 2 review) |

File names: the tools name files by role (`INPUT-` is the markdown, `OUTPUT-` is our render, `OVERLAY-` is the comparison). This folder follows them rather than the `<id>.md` / `<id>-overlay.pdf` names in the brief, because `tools/render.sh`, `tools/overlay.sh` and `CLAUDE.md` read those names.

## Governing rules

Primary sources, read 2026-10-14:

| Rule | Requirement | Source | Where it is in the template |
|---|---|---|---|
| E.D. Cal. L.R. 130(b)–(d) | Numbered lines in the left margin; double spacing (except counsel, title, headings, footnotes, quotations); page number and a brief description of the document "on the same line" at the bottom. | Local Rules, effective 1 January 2025: https://www.caed.uscourts.gov/caednew/assets/File/EDCA%20LOCAL%20RULES%20EFF%201-1-25%20(FINAL).pdf | layout.yaml `pleading.lines: 27`, `pitch.body: 24`; `page_number`: `"{footer_title}<tab>{page}"`, the description at the left and the number at the right of one line (fb-595.96) |
| E.D. Cal. L.R. 131(a) | Counsel's name, address, telephone and State Bar number, and "the specific identification of each party represented," in the upper left of the first page. | same | `counsel` frontmatter in a box at least seven numbered lines high (`min_height: 168`; 18 lines in the sample, so the court title moves down) |
| E.D. Cal. L.R. 131(b), (c) | Signature by the attorney; the name typed under the "/s/" signature. | same | layout.yaml `lead.closing` and `closing` (the signature). |
| E.D. Cal. L.R. 133(k) | "Briefs exceeding fifteen (15) pages in length shall be accompanied by an indexed table of contents related to the headings or subheadings and by an indexed table of statutes, rules, ordinances, cases, and other authorities cited." | same | layout.yaml `contents` (from the headings, with their pages) and `authorities` (the `authorities` frontmatter, with the filed page references). |
| E.D. Cal. L.R. 230(b) | A motion is "set for hearing ... not less than thirty-five (35) days after service and filing of the motion" on the assigned judge's calendar. | same | `hearing` (date, time, place) and `action_filed` in the caption; the timing is not checked by the template. The exemplar's hearing (October 15, 2026) is 41 days after filing (September 4, 2026). |
| E.D. Cal. L.R. 230(c), (d) | Opposition within 14 days after the motion is filed; reply within 10 days after the opposition. | same | Not in the template (these govern the parties' briefing; the notice does not state them). |
| E.D. Cal. L.R. 133(f) | Courtesy paper copy to chambers for any electronically filed document over 25 pages. | same | Not in the template; the sample is 9 pages (fb-595.68.22), so it does not apply to the sample. |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim is a defense that may be raised by motion. Fetched from https://www.law.cornell.edu/rules/frcp/rule_12 on 2026-10-14. | Cornell LII (as amended through Dec. 1, 2024) | Named in the notice and the Rule 12(e) argument; the template does not check the content. |
| Fed. R. Civ. P. 12(e) | "A party may move for a more definite statement of a pleading to which a responsive pleading is allowed ... vague or ambiguous ..." (opening quoted; the remainder paraphrased). Same source. | same | The alternative request in the notice and the argument. |

Judge-specific rules are not in the template and were **not verified**: the filing cites the assigned judge's Civil Standing Order (Section 4(A), meet and confer), and a judge's standing order may set a memorandum page limit. The Local Rules text read here sets none.

## Layout

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`) with E.D. Cal.'s rules overlaid in `typst/layout.yaml`, set by the shared document model (`lib/typst/xdoc.typ`; `latex/` and `docx/` generated by `fb engines gen`, fb-595.96).

- Pleading paper (layout.yaml `pleading`): the numbers 1 to 27, right-aligned on 1 in, one per 24 pt numbered line from the one-inch top margin; a double rule at 1.3 in and 1.34 in from the page's left edge and a single rule at 7.6 in. `eval.yaml` params.pleading_lines: 27 drops the numbers from the text the checks read.
- Footer on one line (L.R. 130(d)): the description (`footer_title`) at the left, the page number at the right, 10 pt, 54 pt above the page's foot.
- The caption page and the notice (a `lead` paper, numbered from 1): counsel from line 1 in a box at least seven numbered lines high (the court title on line 8 or below; 18 counsel lines in the sample, so on line 10); the caption: the party column ruled at its right and foot, "Case No.", the judges, the title in bold, the concurrent-filing note, the hearing and the "Action Filed" date on the right; the notice on the next page, signed.
- The tables (from i): the contents from the memorandum's headings, half an inch further in per level; the authorities from the frontmatter, grouped, with the filed page references, single-spaced, 12 pt apart.
- The memorandum (from 1): its title (`memo_title`) centred in bold capitals; headings as the sample writes them (labels typed), bold: level 1 centred, level 2 at the margin, level 3 half an inch in; paragraphs with a 0.5 in first-line indent; lists half an inch in; the signature, kept with the last paragraph.

## Markdown contract (for samples)

- Frontmatter: `case_number`, `judge`, `magistrate`, `counsel` (lines; "" a blank line), `caption.parties` (list of `{names, designation}`; "v." between parties), `brief_title`, `concurrent`, `hearing` (`date`, `time`, `place`), `action_filed`, `division` (optional), `footer_title`, `date`, `signature` (`firm`, `signer`, `lines`), `memo_title`, `authorities` (a list of groups `{heading, entries: [{cite, pages}]}`: the filed page references).
- Body: the notice's paragraphs, then the line `<!-- memorandum -->` (the end of the caption-and-notice paper), then the memorandum: `#`, `##`, `###` headings with their labels typed ("# I. INTRODUCTION"), paragraphs, `1.` lists.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type. EVAL-LOOP's tier-2 rule asks for two or three filers. The second candidate is Wilce v. Willow Health Services, Inc., 2:26-cv-02465-DAD-AC, Document 7 (a Rules 12(b)(1), (2), (f) motion with memorandum, 28 pp., George LLP; not saved; see `usage/SOURCE.md`). Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** No E.D. Cal. rule names a typeface or type size. The exemplar is Times New Roman 12 pt; the template now sets vendored Times New Roman 12 pt in typst and docx (fb-595.68.22), so the earlier EB Garamond x-height difference is gone. Not a rule requirement.
3. **Excerpt.** The sample transcribes the notice (pages 1 to 2 of the filing) and its signature (page 3); the full table of contents (page i) and table of authorities (pages ii to iii); memorandum page 1 (introduction and the start of the facts, with the footnote omitted); the argument's Rule 12(e) section (page 17 of the memorandum) and the conclusion (page 18), with signature. Memorandum Parts III.A to III.C (filing pages 4 to 16) are not transcribed, so the sample's argument headings run from D to III. The table of contents lists only the headings in the sample.
4. **Table of authorities page references.** The entries are the filed table's entries, with the filed page numbers. They do not match the sample's pages, because the sample is an excerpt. A complete sample would need its own page numbers, which the template does not compute. Recorded here so no one reads the page numbers as the excerpt's.
5. **Memorandum title.** The memorandum title line comes from `memo_title` (layout.yaml `front`), in the exemplar's position (page top, centered caps). The exemplar's title sits above the introduction on the same page, as here.
6. **Keep-with-signature.** The last paragraph is held with the signature block (the base's keep_with_closing). In this sample the conclusion moved to memorandum page 3 with its signature, which leaves a gap at the foot of memorandum page 2. That is the intended trade (a signature alone on a page is worse).
7. **Notice signature.** The exemplar signs the notice on its own page 3; the sample signs it on page 3 after the conference paragraph, a layout consequence of the excerpt and not a rule.
8. **Checks.** `sh tools/check.sh <this folder>` runs on all three engines (`eval.yaml`: the cross-engine gate, pleading_lines 27, cover_structure: report): typst 10, latex 13, docx 14 passed, 0 failed (fb-595.96).

## Gate 2 review (2026-10-29)

After the move onto the shared model (fb-595.96): every page of the three renders (9 typst, 9 latex, 9 docx: 27 pages) rasterized at 60 dpi with pdftoppm into `.overlay/`. The agent's image viewer could not open the PNGs in its pod, so each page was read by its text layout (`pdftotext -layout`) and its line geometry (`fb measure`); a look at the images themselves is left to the reviewer (PR). The three engines break every line and page alike (XENG-001..003 PASS).

| Page | Printed | What it is | Finding (all three engines) | Status |
|---|---|---|---|---|
| 1 | 1 | Caption: counsel (lines 1-9), court title, caption with judges, title, concurrent note, hearing, action filed | Structure as the rules ask; the exemplar's wider title column and centred, ruled footer differ (eval.yaml `cover_structure: report`). | ACCEPTED (tier 3) |
| 2-3 | 2-3 | Notice of motion, conference statement, signature | OK. | OK |
| 4 | i | Table of contents | OK: "Page" over the page column. | OK |
| 5-6 | ii-iii | Table of authorities: Cases, Statutes, Other Authorities, the filed page references | OK. | OK |
| 7-9 | 1-3 | Memorandum: title, I. to IV., the list 1 to 7, conclusion, signature | OK. | OK |
| all | | Footer: description at the left, number at the right (L.R. 130(d)) | OK. | OK |

Reviewed pages: 9 of 9 on each engine (27).

## Engines

All three engines are generated from one layout (docs/EVAL-LOOP.md, "Generated engines"; fb-595.96): `typst/layout.yaml` over `lib/layouts/frcp-motion-brief.yaml`; `typst/caed-motion-brief.typ` names the face and hands the layout to `lib/typst/xdoc.typ`; `fb engines gen` writes `latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml` and `docx/xdoc.lua` (`docx/caed-motion-brief.lua` is gone; the LaTeX engine is new). The one-line footer is the model's `<tab>` (fb-595.96). `eval.yaml` gates the cross-engine check (`params.cross_engine: gate`).

`sh tools/check.sh <dir>`: typst 10 passed, 0 failed; `--engine latex`: 13 passed, 0 failed; `--engine docx`: 14 passed, 0 failed; XENG-001..003 PASS on both. Not verified in Word (LibreOffice only).

[Parent: california/federal/eastern-district](../README.md)
