# nceb: motion-brief (memorandum of law supporting a motion, adversary proceeding)

Doc type: **motion-brief**, the memorandum of law that accompanies a motion in an adversary proceeding in the United States Bankruptcy Court for the Eastern District of North Carolina (`nceb`).
Folder: `courts/fourth-circuit/north-carolina/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-jsmith-barnhill-25-00084-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-barnhill-memo.md`: the whole 12-page memorandum transcribed (caption, headings, body, quotations, signature, certificate of service) |
| render | ok: `samples/OUTPUT-barnhill-memo.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-barnhill-memo.pdf` and `samples/OVERLAY-barnhill-memo.txt` (page map) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Rules were read from the primary sources on 2026-10-14. The local rules are the "Newest" PDF linked from https://www.nceb.uscourts.gov/court-info/local-rules-and-orders (file `NCEB Local Rules - Newest.pdf`, PDF creation date 2025-03-24; the document carries no revision date of its own, so the version is "as posted 2026-10-14").

| Rule | Requirement | Where it is in the template |
|---|---|---|
| FRBP 9004(a) | Papers "must be clearly legible." Verified at https://www.law.cornell.edu/rules/frbp/rule_9004 (as amended eff. 2024-12-01). | No typeface or size is set by the rule; see Known gaps. |
| FRBP 9004(b) | Caption: the court's name, the case title, the case number and, if appropriate, the adversary number, and a brief designation of the paper. | `caption()` and the `title` frontmatter field. |
| LBR 9004-2 | All documents state in the caption the court and division and the chapter under which the case is administered. | `court`, `division`, `case_number`, `chapter` in the caption. |
| LBR 7007-1(a) | Motions in adversary proceedings state the facts and the relief with particularity and "shall be filed with an accompanying memorandum" (except extensions). | This doc type is the memorandum; the motion (Doc 8 in the exemplar's case) is a separate filing. |
| LBR 9013-2 | Supporting briefs are optional "except as provided in LBR 7007-1". | Not enforced by the template. |
| FRBP 9013(b) | A motion "must state its grounds with particularity and set forth the relief or order requested." | Content of the memorandum; not checked by the template. |
| LBR 9011-4 | Signed papers show the signing attorney's name, firm, address, telephone, email and State Bar number. | `signature` block: `signers` with `sign` and `lines`. |
| Admin Guide, Rule 5005-4(8) (NCEB Administrative Guide, "Newest" PDF, fetched 2026-10-14) | An electronic signature is the signatory's name "preceded by an 's/'" (for example `s/Jane D. Doe`). | `sign` lines, e.g. `/s/ James S. Livermon, III`. |
| LBR 9013-3 | Each document served has a certificate of service "identifying the method of service, including identifying those parties to be served electronically." | `certificate` frontmatter (printed on its own page). |
| LBR 9014-1(a) | A motion is filed with a notice of motion, a certificate of service and a proposed order. | Not generated: these are separate filings (see Known gaps). |

Typography: none of the local rules, the Administrative Guide or FRBP 9004 sets a typeface, point size, margin or line spacing for a memorandum (checked: the NCEB local rules and the Administrative Guide were searched for "font", "point", "margin", "spacing", "8 1/2"; the only paper-size text is the 8½ × 11 inch scanning rule in the Administrative Guide's electronic-filing section). The template therefore uses the exemplar's settings, which are a 12-point serif, double-spaced, 1-inch margins, page numbers at the foot, and italic case names.

## Layout

- Court title (three lines, centered bold caps), division, then the caption: the debtor and the parties on the left with a rule down the right and below; the case number, chapter and adversary number on the right.
- Title centered bold caps below the caption.
- Body: double-spaced (`body-leading` 1.35 em, which gives a 24 pt baseline pitch at 12 pt, as in the exemplar), first-line indent 0.5 inch, left-aligned.
- Level 1 headings (`#`): centered bold caps (INTRODUCTION, LEGAL STANDARD, ARGUMENT, CONCLUSION).
- Level 2 headings (`##`): bold, flush left with a hanging indent (argument points such as "I. ...").
- Block quotations (`>`): indented 1 inch both sides, single-spaced.
- Signature block after the conclusion: "Dated:", "Respectfully submitted," then each signer's `sign` line and lines, single-spaced, in the right half of the page, then the role line in italics.
- Certificate of service on its own page: centered bold caps title, the text, the served parties, the date and the signer.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block followed by the body.

- Frontmatter: `case_number` (main case), `adversary_number`, `chapter`, `court` (list of lines), `division`, `caption` (`in_re`: list of `{names, designation}`; `parties`: list of `{names, designation}`), `title`, `signature` (`date`, `role`, `signers`: list of `{sign, lines}`), `certificate` (`title`, `text`, `served`, `date`, `signer: {sign, lines}`).
- Body: `#` and `##` headings as above; paragraphs; `>` quotations; ordinary markdown lists (the template does not number them). Numbering of argument points is typed by the author ("I.", "A.") as in the exemplar.
- Case names and *Id.* are written in `*...*` (italic), as the exemplar sets them.
- Not supported: tables, footnotes (none used), raw typst.

## Overlay

`sh tools/overlay.sh <doc-type-dir> barnhill-memo` writes `samples/OVERLAY-barnhill-memo.pdf` (red = our render, blue = the filed page, black = both) and `OVERLAY-barnhill-memo.txt`. The page map pairs each of our 10 pages with the filed page sharing most words (word-overlap 55% to 83%). Our page 1 is the caption page; the exemplar's page 1 is its caption too. The overlay is a diagnostic, not a score. The 10 rendered pages against the exemplar's 12 are not analyzed further; the page map is the only comparison made.

## Page review (Gate 2 equivalent; every page rendered at 60 dpi and viewed)

- Page 1: caption, title, start of the Introduction. Pass.
- Page 2: Introduction end, Legal Standard, start of the Argument; the first block quotation. Pass.
- Page 3: Section 1334 paragraph; Section 157 paragraph; heading I. Pass.
- Page 4: Pacor discussion, "Here, Debtor incorrectly asserts...". Pass.
- Page 5: Non-core analysis, plan's effect on the estate. Pass.
- Page 6: heading II. (flush left, bold), Pacor and close-nexus paragraphs. Pass.
- Page 7: heading III. (two lines, hanging indent), the plan quotation begins; the numbered list is inside the quotation. Pass.
- Page 8: list items 5 to 8 of the plan quotation; the jurisdictional argument. Pass.
- Page 9: CONCLUSION, the prayer paragraph, "Dated", the signature block with two "/s/" signers and the role line. Pass.
- Page 10: certificate of service: title, text, served parties, date, signer. Pass.

## Known gaps and open choices

1. **Typography is not in the rules.** The 12-point EB Garamond, double spacing and 1-inch margins follow the exemplar (a Times-style serif). EB Garamond has a smaller x-height than Times at 12 pt, so the text looks smaller than the exemplar. A Times-metric font would remove the difference; that is a vendoring decision for David (fonts/ is shared).
2. **Only one exemplar** (one filer). The tier-2 bar (2 or 3 filers) is not met. Search: the CourtListener API (`/api/rest/v4/search/`, `court=nceb`, `type=rd`, query "motion to dismiss" memorandum). It returned several memoranda; this one has a text layer. Not collected: a second memorandum from a different filer.
3. **Not generated:** the motion itself (LBR 7007-1(a) requires one with the memorandum), the notice of motion and the proposed order (LBR 9014-1(a)), and any summons. The template produces the memorandum only.
4. **Transcription is complete.** The whole 12-page memorandum is in the sample, including the caption, the signature block and the certificate of service. The exemplar's own citation errors (for example "*Id* (citing") are kept as printed.
5. **Italics.** Case names and signals are italic as the author marked them in the transcription. The exemplar's italics were not compared page by page.
6. **File names differ from the brief's naming.** The tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, not `<id>.pdf` and `<id>-overlay.pdf`; the names follow the tools (which the brief forbids editing).
7. **Headings.** Level 3 and deeper headings are not styled (none are used).
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` need the court folder shape (court.json and rules.md at the court root), which this doc-type folder does not have; the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent.
