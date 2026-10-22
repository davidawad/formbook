# M.D. Ga. Bankruptcy Court: adversary complaint

Doc type: **adversary-complaint** (a complaint commencing an adversary proceeding). Court: United States Bankruptcy Court, Middle District of Georgia (`gamb`, Eleventh Circuit). Folder: `courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (caption, all 96 numbered paragraphs, prayer, signature block) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 14 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-galardi-complaint.pdf` and `OVERLAY-galardi-complaint.txt` |
| pages reviewed | 14 of 14 (every page rendered at 60 dpi and viewed; pages 1-2 and 13-14 viewed again after the final changes; all 14 re-rendered and viewed again 2026-10-14 in the fonts pass, no change) |

This folder is self-contained. It does not touch the court-root `typst/` or `usage/`.

## Governing rules

Primary sources, fetched 2026-10-14. Rule text was read from the LII copies (FRBP) and from the court's own PDFs (LBR and Clerk's Instructions).

| ID | Source | Requirement | Where in the template |
|---|---|---|---|
| GAMB-COURT-001 | FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010); Clerk's Instructions, "Form and Caption of Complaint" (https://www.gamb.uscourts.gov/USCourts/sites/default/files/local_rules/Clerks_Instructions_Apr_2025.pdf, p. 37) | The caption must conform substantially to Form 416D. | `caption()` |
| GAMB-CAP-001 | FRBP 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | Caption sets forth (1) the court's name, (2) the case's title, (3) the case number and, if appropriate, adversary-proceeding number, and (4) a brief designation of the document's character. | court lines, `caption()`, `title` |
| GAMB-CAP-002 | LBR 9004-2(a) (Local Rules, Apr. 2025, https://www.gamb.uscourts.gov/USCourts/sites/default/files/local_rules/Local_Rules_Apr_2025.pdf, p. 36) | Caption shows the chapter, and the case number includes the assigned judge's initials. | `chapter`, `case_number` (sample: "22-50035-JPS") |
| GAMB-CAP-003 | LBR 9004-2(b) (same) | The title designates the relief sought; "motion" alone is not enough. | `title` (author supplies it) |
| GAMB-CONT-001 | Clerk's Instructions, "Contents of Complaint" (p. 38); FRCP 8(a) through FRBP 7008 | Jurisdictional statement naming the case (name, number, chapter), district and division; short plain statement of the claim; demand for judgment. | Author content. Not checked by the template. |
| GAMB-CONT-002 | FRCP 10(a), (b) through FRBP 7010 | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body()`: paragraphs after the first heading are numbered 1, 2, ... |
| GAMB-CONT-003 | FRCP 10(c) | Exhibits attached to a pleading are part of it. Exhibits are filed as attachments, not in the render. | Not produced (the sample refers to Exhibits A-F; they are not in the render). |
| GAMB-SIG-001 | LBR 9011-1(b) (Local Rules p. 37) | Attorney's name, State Bar number, office address, telephone and e-mail (the registered CM/ECF address) appear in immediate proximity to the signature. | `signature-block()`, one block per attorney, with a `/s/` line |
| GAMB-FORM-001 | FRBP 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." | Whole template: EB Garamond, 13 pt, 1-inch margins, us-letter |
| GAMB-FORM-002 | No face named for pleadings. Checked 2026-10-14: the only face rule in the Clerk's Instructions ("Courier or Times New Roman", item f of the section on proposed **orders**) does not reach complaints, and the Local Rules (Apr. 2025, 51 pp.) name no typeface. Required face: none. Vendored substitute: none (EB Garamond kept). Fit: n/a. | Stays EB Garamond (no face required). See gaps. | `font-family` |

Not produced by this template, and why:
- **Adversary cover sheet (Form B1040).** Required only when the complaint is not filed electronically (Clerk's Instructions, "Adversary Cover Sheet"). It is a separate form.
- **Summons and notice of pretrial conference.** Issued by the Clerk on filing (Clerk's Instructions, "Issuance of Summons"). Not part of the complaint.
- **Certificate of service.** Not required: the summons and complaint are served under FRBP 7004. The certificate rule in LBR 9013-3 is for motions, briefs and other documents, and is in the `motion-brief` template.
- **Jury demand.** Not in the sample, and the template has no jury-demand option (gap 5).
- **Filing fee ($350, 28 U.S.C. § 1914(a))**, not a document item.

## Layout

- Court title centered, three lines from the `court` frontmatter.
- Caption (Form 416D order): "In re:" and the debtor; the plaintiffs; "v."; the defendant. The party column is closed by a rule on its right and bottom edges. The right column gives "Bankruptcy Case No." (with the judge's initials), the chapter, and the adversary number (a blank line when the number is not yet assigned, as in the exemplar).
- Title centered in capitals.
- Body: double spacing (24 pt baseline pitch), first-line indent. Level 1 headings are centered capitals, level 2 bold, level 3 bold italic. Headings are unnumbered.
- Paragraphs after the first heading are numbered from 1. A paragraph before the first heading (the "COME NOW" lead-in) is unnumbered. A chunk starting "(a)", "(1)", etc. is a lettered sub-item with a hanging label, not a numbered paragraph.
- Block quotations are indented and single-spaced (not used in the sample).
- WHEREFORE paragraph (frontmatter `wherefore`), then the date line, then one signature block per attorney. The WHEREFORE block is sticky, so it stays with the signature when the page breaks.

## Markdown contract (for samples)

- Frontmatter fields: `court` (list of lines), `title`, `case_number` (includes judge initials), `chapter`, `adversary_number` (empty string shows a blank line), `parties` (list of `{kind: debtor|plaintiff|defendant, names: [...], role: "..."}`; the template prints "In re:" before a debtor and "v." between a plaintiff side and a defendant side), `wherefore` (markdown string), `date` (the line before the signature), `signature` (list of `{signer, bar, firm: [...], phone, email, role}`).
- Body: blank-line-separated chunks. `#` heading; `(a)`-style sub-item; `>` block quotation; any other chunk is a numbered paragraph after the first heading. Escape a leading number or marker in running text (`2\.`) so it is not read as a list.
- No tables, footnotes, or raw typst. The template panics on missing frontmatter fields.

Build and check (from the repo root, with the toolchain on PATH: `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/adversary-complaint galardi-complaint
```

- `usage/OUTPUT-adversary-complaint.typst.pdf` is the render. The file names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-` and `OVERLAY-` prefixes), not the `<id>.pdf` and `<id>-overlay.pdf` names in the task brief, because those tools are shared and fix the names.
- `usage/OVERLAY-galardi-complaint.pdf` (red = our render, blue = exemplar, black = both) and `.txt` (the page map). The page map pairs pages by word overlap, which is coarse: our pages 3-4 pair with filed pages 4 and 6, and so on. It is a diagnostic, not a score.

## Visual review (Gate 2 record, all 14 pages, rendered at 60 dpi and viewed)

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, Form 416D caption, title, lead-in "COME NOW", ¶¶1-2 | OK. The lead-in was first set flush left; fixed to indent like a body paragraph. |
| 2 | ¶¶3-10 | OK. Headings centered and bold. |
| 3 | ¶¶11-18 | OK. |
| 4 | ¶¶19-28 | OK. The sub-heading "Teri's Funding of the JGJ Subtrust" stays with its paragraph. |
| 5 | ¶29 with sub-items (a)-(d) | OK. Hanging labels align. |
| 6 | ¶¶30-37 | OK. |
| 7 | ¶¶38-50 | OK. |
| 8 | ¶¶51-57 | OK. |
| 9 | ¶¶58-66, COUNT I heading | OK. |
| 10 | ¶¶67-75 | OK. |
| 11 | ¶¶76-84, COUNT II heading | OK. |
| 12 | ¶¶85-90, COUNT III heading | OK. |
| 13 | ¶¶91-96 | OK. |
| 14 | WHEREFORE, date, two signature blocks | OK after the change: WHEREFORE now moves with the signature (before, the signature stood alone on p. 14). |

Numbering check: the sample's COUNT I begins at ¶63 and COUNT II at ¶81, which matches the exemplar's cross-references ("paragraphs 1 through 62").

## Known gaps and open choices

1. **One exemplar only.** The eval-loop tier-2 rule asks for two or three filers. A CourtListener API search (`court=gamb`, `type=r`, "adversary proceeding" complaint) found other adversary dockets: Morrison v. SN Servicing (23-05003), Padgett v. Bank of America (19-05042) and Harvey v. Nationstar (22-01008). In the search results I saw, none listed an available complaint PDF (the cover-sheet and order entries were unavailable), and I did not open those dockets. The Galardi complaint is the only text-based M.D. Ga. adversary complaint I downloaded. Tier 2 is not judged against two filers.
2. **Font and size (GAMB-FORM-002).** No M.D. Ga. bankruptcy rule names a face, font size or spacing for pleadings (checked 2026-10-14 against the Clerk's Instructions and the Local Rules, Apr. 2025; the only face rule is for proposed orders). Per the fonts pass, a court that names no face keeps EB Garamond, the template's font. The exemplar is Times New Roman, which is one filer's choice (tier 3), not a rule. Switching to Liberation Serif would be a style decision, not a rule requirement, and is not made here.
3. **Exhibits and numbering.** The sample transcribes all 96 paragraphs of the exemplar's body. Exhibits A-F (attachments to ECF Doc. 1) are not in the exemplar PDF and are not reproduced. The exemplar's numbering skips ¶93 (it goes 92, 94). The template numbers consecutively, so from ¶93 on the sample's numbers are one lower than the exemplar's. No cross-reference in the complaint points past ¶81, so none is affected.
4. **Transcription.** The exemplar's second signature block prints "Will Geer" under the `/s/ Garrett Nail` line; the sample uses Garrett Nail (see `usage/SOURCE.md`). Other typos in the exemplar are reproduced as printed (for example "is resides", "Subrust", "serve as the successor trustee"). Straight quotes in the sample are typeset as curly quotes by the template.
5. **Jury demand, and other options.** No jury-demand option is built. A complaint seeking a jury trial would need one (FRCP 38 through FRBP 9015). Not in this exemplar.
6. **Adversary number.** The exemplar leaves the adversary number blank (it is assigned by the Clerk). The template shows a blank line when `adversary_number` is empty.
7. **Case names are roman in the sample.** The exemplar's text layer has no italic markup; the template italicizes `*...*` markdown, so a future sample can italicize case names.
8. **Overlay naming.** See "Build and check": the tool-fixed names differ from the brief's `<id>-overlay.pdf`.

## Engines

The typst template above is the primary engine. The docx engine is in `docx/`: `reference.docx` (built by `docx/make-reference.sh`), `gamb.lua` (the caption, the title, the numbering of the paragraphs, the "(a)" sub-items, the WHEREFORE and the signature blocks) and `render.sh` (pandoc with `--from markdown+smart-fancy_lists`, so a typed "(a)" stays text). Build and check:

```sh
sh tools/render.sh --engine docx courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/adversary-complaint usage/INPUT-adversary-complaint.md
```

This writes `usage/OUTPUT-adversary-complaint.docx` and `usage/OUTPUT-adversary-complaint.docx.pdf` (LibreOffice 26.8, EB Garamond from `fonts/eb-garamond`).

- **Matches the typst render:** EB Garamond 13 pt; letter; 1-inch margins; body double-spaced (24 pt exact) with a half-inch first-line indent; headings centered bold (level 1), bold (level 2), bold italic (level 3); the Form 416D caption as a table with a rule on the right and bottom of the party column; the court lines and title; paragraphs after the first heading numbered 1, 2, ... ; "(a)" sub-items with a hanging label; the WHEREFORE paragraph kept with the signature blocks; a centered page number on every page.
- **Differs:** the docx PDF is 16 pages against 14 for typst. LibreOffice places the first line of an exact 24 pt line about 6 pt lower than typst, so a page holds about one line fewer. The WHEREFORE and signature chain moves as one, so page 15 holds only ¶ 96. No rule sets a page count here. Word may paginate differently again (docs/DOCX.md). The numbers are typed text, as in the typst template, not Word list numbering.
- **Not opened in Word.** The `.docx` was checked for well-formed XML parts and unique style IDs; it was opened only in LibreOffice.
- **Gates:** `tools/check.sh --engine docx` was not run for this folder. It needs `checks.yaml`, `reviews/`, a `court.json` and `yq` (mikefarah), and the court-level files are not in this snapshot. Every page of the `.docx.pdf` was rendered at 60 dpi and viewed against the typst pages (pages 1-16).
- **docx BLOCKED:** none recorded. Gates 0-3 have not been run, so no check ID is cleared for docx yet.

## Shared-engine adoption status (verified 2026-10-22)

This verification supersedes older DOCX-blocked status notes above. The current typst and DOCX check runs pass with zero failed checks, including `DEF-COVER-001` and `DEF-TOC-001`; DOCX passes XENG-001..003 against typst. The DOCX face resolves from `docx/reference.xml` through `{font}` to the typst template's declared face. The folder has no LaTeX template, no per-court DOCX shell builder or script-only artifact, and no `.shell-safety-baseline.json` entry. There are no remaining engine-match exceptions for this folder.
