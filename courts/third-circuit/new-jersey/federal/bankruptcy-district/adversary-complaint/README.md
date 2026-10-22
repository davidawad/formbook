# njb: adversary-complaint

Doc type: **adversary complaint** (FRBP 7001) in the United States Bankruptcy Court for the District of New Jersey (`njb`).
Folder: `courts/third-circuit/new-jersey/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (excerpt: caption, parties, jurisdiction, paragraphs 6 to 23, paragraphs 198 to 214, WHEREFORE and signature; see Known gaps) |
| typeface | face required: none. Times New Roman 14 pt, the house face (`docs/FONTS.md`, "No face named"), vendored, in typst and docx alike (was EB Garamond until fb-595.68.34). Checked 2026-10-15 against the D.N.J. Local Bankruptcy Rules package (as posted, 2025): no typeface or point-size text in it, and LBR 1001-1's 2015 comment says an unincorporated Local Civil Rule does not apply. Judges' preferences (Judges' Info tab) were not checked. |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 10 pages; `OUTPUT-adversary-complaint.docx` and `.docx.pdf`, 10 pages, every line and page as typst (XENG-001..003 gated, `eval.yaml`; fb-595.68.34) |
| overlay | earlier render only (`just overlay` writes to the gitignored `.overlay/`; not re-run for fb-595.68.34) |
| pages reviewed | 10 of 10 on each engine (2026-10-22, below) |

File names follow the tools: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf/.txt`, so the brief's `<id>.pdf` and `<id>-overlay.pdf` are named that way here. The sample is `INPUT-<id>.md` for the same reason.

## Governing rules

| Rule | Requirement | Where in the template |
|---|---|---|
| FRBP 7001 | Adversary proceeding types (money or property, liens, dischargeability, injunction, subordination, declaratory judgment). The filing is a complaint for the proceeding it starts. | Not checked by the template; the sample's relief sets it. |
| FRBP 7010 | Pleadings in an adversary proceeding follow Fed. R. Civ. P. 10, except the caption must substantially conform to Official Form 416. Fetched from https://www.law.cornell.edu/rules/frbp/rule_7010, 2026-10-14. | `cover()` (caption); `allegations()` (numbered paragraphs, FRCP 10(b)). |
| FRBP 9004(a) | Papers must be clearly legible. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004, 2026-10-14. | `type-size`, `body-leading`, one-inch margins. |
| FRBP 9004(b) | Caption: court name, case title, case number and adversary number, and a brief designation of the document. | `court-name`, `caption()` (debtor block, adversary block, `adv_no`, `title`). |
| D.N.J. LBR 9004-1(a) | Top left of the first page: attorney of record's name, address, telephone and direct email, and the party represented. Text from the NJB Local Rules package, https://www.njb.uscourts.gov/sites/njb/files/Local%20Rules%20Package.pdf (fetched 2026-10-14; package as posted, 2025 comments). | `cover()`: `counsel` frontmatter. |
| D.N.J. LBR 9004-1(b) | A document requiring a caption includes the chapter, the judge's initials and the applicable hearing date. | `cover()`: chapter and judge in the caption. No hearing date: a complaint has no motion hearing (see Known gaps). |
| D.N.J. LBR 7003-1 | A complaint filed by non-electronic means is accompanied by the adversary proceeding cover sheet (Director's Form 1040). | Not part of the template (a separate document). |
| D.N.J. LBR 1001-1 (2015 comment) | Local Civil Rules are not incorporated unless the bankruptcy rules say so. | Basis for not applying the District's typeface rule (see Known gaps). |

Not produced by this template (separate filings): the adversary cover sheet (LBR 7003-1, Director's Form 1040); the summons; the Rule 7.1 disclosure statement; any certification required with the first filing. The template does not check the wording of the allegations.

## Layout

- US Letter, one-inch margins, page number centered in the footer.
- Counsel block single-spaced at the top left (LBR 9004-1(a)).
- Court name centered and bold, then "Caption in Compliance with D.N.J. LBR 9004-1" (right) and the caption: a left column for the debtor and the parties, a right column for the case number, chapter, judge and adversary number, each block ruled at the right and foot of its left column (the rule the height of the row). The caption fills page 1; the title opens page 2, centered and bold, as filed.
- Cross-engine layout model (`lib/typst/xengine.typ`): body on a 28 pt pitch (double spaced at 14 pt), single lines (counsel, court, caption, signature, footer) on a 16 pt pitch, explicit block spaces; headings at the type size on the body pitch with no space of their own.
- Paragraphs are numbered 1, 2, ... by the template (FRCP 10(b)): the number at the 0.5 in indent in a 0.5 in box, the text from 1 in. Headings are not numbered. Chunks that start with `WHEREFORE` and chunks in square brackets (`[...]`, a transcription note, centered italic) are unnumbered.
- Prayer items (markdown `1.` items) are lettered (a), (b), ... by their number, the letter 0.5 in in, the text hanging at 0.9 in.
- Signature block: "Dated:" left of the first line, "Respectfully submitted," the firm block and the `/s/` signer from 3.1 in, single lines; kept on one page with the last paragraph.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `counsel` (lines), `debtor` (lines), `case_no`, `chapter`, `judge`, `adv_no`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `date`, `signature` (`firm`, `signer`, `lines`), `lead_in` (optional, unnumbered), `hearing` (optional).
- YAML items containing a colon must be quoted (for example `- "Telephone: (973) 848-4000"`).
- Body: blank-line-separated chunks. `#` = centered bold caps heading; `###` = bold italic left sub-heading; `1.` items = lettered prayer; anything else = numbered paragraph. Do not type paragraph numbers in the text.
- Not supported: tables, footnotes (none used in the sample; the exemplar's footnote 1 and footnote 2 are omitted), raw typst.

## Known gaps and open choices

1. **One exemplar.** Tier 2 of EVAL-LOOP asks for two or three filers from different firms. The search (CourtListener RECAP, `court=njb`, adversary complaints filed 2026-07 to 2026-10) found Murray v. Santander Consumer USA Inc. (26-01342, 11 pages, docket 73663852), Avrumi Lubin (26-01435, 13 pages) and Stanger v. Unison Agreement Corp. (26-01384). Those were not downloaded for comparison. Tier 2 is therefore **not** judged against two filers yet.
2. **Typeface and size are a convention, not a mandate.** No bankruptcy rule in the package sets a typeface or a size. The District's Local Civil Rule 7.2(d) (12 pt non-proportional or 14 pt proportional, e.g. Times New Roman 14) is the nearest rule, but it is not incorporated into the bankruptcy rules (LBR 1001-1, 2015 comment). The exemplar's body measures about 14 pt Times New Roman (word boxes, `pdftotext -bbox`). The template uses Times New Roman 14 pt, the house face where no rule in the package names one (checked 2026-10-15), which is also the exemplar's face and size.
3. **Hearing date.** LBR 9004-1(b) asks for the applicable hearing date. A complaint has no motion hearing, so the caption carries none; the template does not require one here (the `motion-brief` template does).
4. **Excerpt, not the whole filing.** The sample transcribes paragraphs 1 to 23 and 198 to 214 with the WHEREFORE and the signature, and says so with a bracketed note. The exemplar's paragraph numbers are not reproduced; the template renumbers from 1. The exemplar repeats paragraph 19 in its text layer; the sample keeps the first one.
5. **Filer's text kept as filed.** The exemplar's own errors (for example, "Secured Creditors" in the singular, "Mr. Wu" with no introduction) appear in the sample because it is a transcription. They are not template defects.
6. **Caption layout.** The party column is closed by a rule on the right and bottom, not the column of ")" marks sometimes used; the exemplar's own debtor block is a boxed layout. Recorded as a layout choice, not a rule requirement.
7. **Line spacing** is double spacing at the type size (`pitch-body` 28 pt); it was a 25.2 pt pitch with a 9.8 pt paragraph gap set by eye before fb-595.68.34. It was not measured against the exemplar's baseline grid.
8. **Italics.** The exemplar's text layer has no italic markup, so case names are roman in the sample. The template italicizes `*...*` when a sample carries it.
9. **Tool checks.** `tools/check.sh <this folder>`: `RESULT: 9 checks passed, 0 failed` (typst) and `RESULT: 13 checks passed, 0 failed` (`--engine docx`, XENG-001..003 gated).
10. **Title page.** The old render set the title alone on page 2 (the cover ran over) and the body from page 3; the title now opens page 2 and the body follows it, as filed.

## Review of the rendered pages (Gate 2 record, all 10 pages on each engine, rendered at 45 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 228/228).

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block, court name, LBR 9004-1 note, the debtor and adversary captions | OK: each left column ruled at its right and foot; nothing spills. |
| 2 | Title, lead-in, THE PARTIES, paragraphs 1 to 4 | OK. |
| 3 | Paragraphs 5 to 8; JURISDICTION AND VENUE | OK. |
| 4 | Paragraphs 9 to 11; ALLEGATIONS COMMON TO ALL CLAIMS FOR RELIEF; sub-heading A | OK: "§§ 1408" kept with its number. |
| 5 | Paragraphs 12 to 16 | OK. |
| 6 | Paragraphs 17 to 23; sub-heading B; the excerpt note | OK. |
| 7 | Paragraphs 24 to 30 | OK. |
| 8 | Paragraphs 31 to 37 | OK. |
| 9 | Paragraph 38; WHEREFORE; items (a) to (c) | OK: the page ends short because item (d) is kept with the signature. |
| 10 | Item (d); "Dated:" and the signature block | OK. |

No open tier-2 finding.

## Engines

Engine status: typst `OUTPUT-adversary-complaint.typst.pdf`; docx `OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice), 10 pages each, every line and page as typst (XENG-001..003 gated); latex not built.

- **typst** (primary, `typst/`): the reference for the form, on `lib/typst/xengine.typ`.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 14 pt; Body Text in exact 28 pt lines with a 0.5 in first-line indent; single lines in 16 pt boxes) and `docx/njb-adversary-complaint.lua` (on `lib/docx/xengine.lua`), which writes every paragraph: the counsel block, court, note, caption tables, title (opening page 2), numbered allegations, headings, lettered prayer items, notes, the signature block, the footer (a centred 12 pt PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh`, `docx/njb.lua` and a committed `reference.docx` in EB Garamond). Paragraph numbers and prayer letters are typed text, not Word numbering. Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none. No TOC or TOA in this template.
