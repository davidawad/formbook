# njb: adversary-complaint

Doc type: **adversary complaint** (FRBP 7001) in the United States Bankruptcy Court for the District of New Jersey (`njb`).
Folder: `courts/third-circuit/new-jersey/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-supor-26-01475-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-supor-adversary-complaint.md` (excerpt: caption, parties, jurisdiction, paragraphs 6 to 23, paragraphs 198 to 214, WHEREFORE and signature; see Known gaps) |
| render | ok: `samples/OUTPUT-supor-adversary-complaint.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-supor-adversary-complaint.pdf` and `OVERLAY-supor-adversary-complaint.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |

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
- Court name centered and bold, then "Caption in Compliance with D.N.J. LBR 9004-1" (right) and the caption: a left column for the debtor and the parties, a right column for the case number, chapter, judge and adversary number. The title is centered and bold below the caption; the body starts on the same page (the cover is not a separate page).
- Paragraphs are numbered 1, 2, ... by the template (FRCP 10(b)), first-line indent 0.5 in. Headings are not numbered. Chunks that start with `WHEREFORE` and chunks in square brackets (`[...]`, a transcription note) are unnumbered.
- Prayer items (markdown `1.` list) are lettered (a), (b), ... .
- Signature block: "Dated:" left, "Respectfully submitted," with the firm block and `/s/` signer on the right; kept together.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `counsel` (lines), `debtor` (lines), `case_no`, `chapter`, `judge`, `adv_no`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `date`, `signature` (`firm`, `signer`, `lines`), `lead_in` (optional, unnumbered), `hearing` (optional).
- YAML items containing a colon must be quoted (for example `- "Telephone: (973) 848-4000"`).
- Body: blank-line-separated chunks. `#` = centered bold caps heading; `###` = bold italic left sub-heading; `1.` items = lettered prayer; anything else = numbered paragraph. Do not type paragraph numbers in the text.
- Not supported: tables, footnotes (none used in the sample; the exemplar's footnote 1 and footnote 2 are omitted), raw typst.

## Known gaps and open choices

1. **One exemplar.** Tier 2 of EVAL-LOOP asks for two or three filers from different firms. The search (CourtListener RECAP, `court=njb`, adversary complaints filed 2026-07 to 2026-10) found Murray v. Santander Consumer USA Inc. (26-01342, 11 pages, docket 73663852), Avrumi Lubin (26-01435, 13 pages) and Stanger v. Unison Agreement Corp. (26-01384). Those were not downloaded for comparison. Tier 2 is therefore **not** judged against two filers yet.
2. **Typeface and size are a convention, not a mandate.** No bankruptcy rule in the package sets a typeface or a size. The District's Local Civil Rule 7.2(d) (12 pt non-proportional or 14 pt proportional, e.g. Times New Roman 14) is the nearest rule, but it is not incorporated into the bankruptcy rules (LBR 1001-1, 2015 comment). The exemplar's body measures about 14 pt Times New Roman (word boxes, `pdftotext -bbox`). The template uses EB Garamond 14 pt because it is the only face vendored in `fonts/`; EB Garamond has a smaller x-height than Times, so it looks smaller than the exemplar at the same size. Whether a larger face is needed is for David to decide.
3. **Hearing date.** LBR 9004-1(b) asks for the applicable hearing date. A complaint has no motion hearing, so the caption carries none; the template does not require one here (the `motion-brief` template does).
4. **Excerpt, not the whole filing.** The sample transcribes paragraphs 1 to 23 and 198 to 214 with the WHEREFORE and the signature, and says so with a bracketed note. The exemplar's paragraph numbers are not reproduced; the template renumbers from 1. The exemplar repeats paragraph 19 in its text layer; the sample keeps the first one.
5. **Filer's text kept as filed.** The exemplar's own errors (for example, "Secured Creditors" in the singular, "Mr. Wu" with no introduction) appear in the sample because it is a transcription. They are not template defects.
6. **Caption layout.** The party column is closed by a rule on the right and bottom, not the column of ")" marks sometimes used; the exemplar's own debtor block is a boxed layout. Recorded as a layout choice, not a rule requirement.
7. **Line spacing** is set by eye against the exemplar's page pitch (`body-leading`). It was not measured against the exemplar's baseline grid.
8. **Italics.** The exemplar's text layer has no italic markup, so case names are roman in the sample. The template italicizes `*...*` when a sample carries it.
9. **Check scripts not run.** `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (OUTPUT-supor-adversary-complaint.pdf, 8 pages)

- Page 1: counsel block top left, court name, the LBR 9004-1 caption note, the debtor block and case data, the adversary block, and the title "COMPLAINT". Nothing spills. Pass.
- Page 2: lead-in (unnumbered), THE PARTIES heading, paragraphs 1 to 5, JURISDICTION AND VENUE heading with the start of paragraph 6 on the same page (the heading is kept with its paragraph; the paragraph breaks across the page). Pass.
- Page 3: paragraphs 6 to 10 and the end of paragraph 9. No heading at a page foot. Pass.
- Page 4: ALLEGATIONS COMMON TO ALL CLAIMS FOR RELIEF on one line, the sub-heading "A." in bold italic, paragraphs 11 to 15. Pass.
- Page 5: paragraphs 15 to 23, the "B. The Sale Process." sub-heading, and the excerpt note. Pass.
- Page 6: the excerpt note, paragraphs 22 to 32. Pass.
- Page 7: paragraphs 33 to 38, WHEREFORE (unnumbered) and item (a)-(c). Pass.
- Page 8: item (d), "Dated: October 12, 2026", the signature block with the firm and "/s/" line. Pass.

Overlay (`OVERLAY-supor-adversary-complaint.txt`): pages 1 to 5 pair with the same exemplar pages (word overlap 64 to 84 percent). Pages 6 to 8 pair with exemplar pages 32 to 34 because the sample's paragraphs 198 to 214 sit at the end of the filing. The overlay is a diagnostic, not a score.
