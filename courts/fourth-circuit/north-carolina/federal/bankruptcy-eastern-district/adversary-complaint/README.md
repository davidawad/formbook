# nceb: adversary-complaint

Doc type: **adversary-complaint**, the complaint that opens an adversary proceeding in the United States Bankruptcy Court for the Eastern District of North Carolina (`nceb`).
Folder: `courts/fourth-circuit/north-carolina/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-jsmith-second-wind-25-00159-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-jsmith-complaint.md`: an excerpt of the 38-page complaint (caption, introduction, jurisdiction, parties, factual allegations, part of the First Claim, prayer, signature); see Known gaps |
| render | ok: `samples/OUTPUT-jsmith-complaint.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| typeface | rules name no face: EB Garamond kept (`docs/FONTS.md`, "No face named"); no substitute needed. Checked 2026-10-14 against the NCEB Local Rules and Administrative Guide (see Typography). |
| overlay | ok: `samples/OVERLAY-jsmith-complaint.pdf` and `samples/OVERLAY-jsmith-complaint.txt` (page map; exemplar copy fetched from CourtListener RECAP on 2026-10-14, 38 pages, matching `exemplars/SOURCE.md`) |
| pages reviewed | 8 of 8 (fonts pass, 2026-10-14: every page rendered at 70 dpi and viewed after the re-render) |

## Governing rules

Rules were read from the primary sources on 2026-10-14.

| Rule | Requirement | Source | Where it is in the template |
|---|---|---|---|
| FRBP 7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding; the caption "must substantially conform" to the appropriate official form. | https://www.law.cornell.edu/rules/frbp/rule_7010 (amended eff. 2024-12-01) | Caption: court lines, division, case, adversary and chapter lines, the title. |
| FRCP 10(a) | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation. | https://www.law.cornell.edu/rules/frcp/rule_10 (fetched 2026-10-14) | `court`, `case_number`, `adversary_number`, `title`. |
| FRCP 10(b) | A party states its claims in numbered paragraphs, "each limited as far as practicable to a single set of circumstances." | same | The template numbers the allegations (`allegation` counter); headings, lettered items, tables and the prayer list are not numbered. |
| FRBP 7008(a) | The complaint "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court," and must include the case's name, number and chapter, and the district and division. | https://www.law.cornell.edu/rules/frbp/rule_7008 (amended eff. 2024-12-01) | Author content (the sample's jurisdiction paragraphs state core status and consent); the template does not check the wording. |
| FRBP 9004(a), (b) | Legible; caption with the court, title, case and adversary numbers, designation. | https://www.law.cornell.edu/rules/frbp/rule_9004 | As above. |
| LBR 9004-2 | Captions state the court, the division and the chapter. (NCEB Local Rules, "Newest" PDF, creation 2025-03-24; see the motion-brief README for the version note.) | NCEB local rules | Caption: division line and `Chapter` line. |
| LBR 9011-4 | Signed papers show the signing attorney's name, firm, address, telephone, email and State Bar number. | NCEB local rules | `signature` block: `firm`, `signers` (`sign` line and `lines`). |
| Admin Guide, Rule 5005-4(8) | An electronic signature is the signatory's name "preceded by an 's/'". | NCEB Administrative Guide, "Newest" PDF (fetched 2026-10-14) | `sign` line `BY: s/Joseph Z. Frost`. |

Typography: no local rule or Admin Guide provision sets a typeface, size, margin or spacing for a complaint (the same search as the motion-brief README). The template uses the exemplar's settings: a 12-point serif, double-spaced, 1-inch margins, page numbers at the foot.

Fonts pass (2026-10-14): the Administrative Guide's only face wording is in the creditor-matrix instructions (Rule 1007-2, "Twelve (12) pitch Times New Roman and Courier New fonts create good print quality"). That applies to the mailing matrix, not to a complaint. The Local Rules and the Administrative Guide were fetched in full from the court's "Newest" PDFs and searched for font, typeface, point, margin and spacing terms. No rule names a face for this doc type, so `docs/FONTS.md` ("No face named") keeps EB Garamond. The TeX Gyre Schola substitute is not used.

Not produced by this template (separate filings): the Adversary Proceeding Cover Sheet, the summons, and the civil-procedure disclosure statement, if any. The template does not produce a certificate of service for the complaint (service is by summons).

## Layout

- Court lines (`UNITED STATES BANKRUPTCY COURT`, `EASTERN DISTRICT OF NORTH CAROLINA`), then the division, centered bold caps.
- Caption: the debtor ("In re") and the parties on the left with a rule down the right and below; the case number, the chapter and the adversary number on the right.
- Title "COMPLAINT", centered bold caps.
- Body: double-spaced (24 pt baseline pitch at 12 pt, as in the exemplar), left-aligned.
- The lead-in ("NOW COMES ...") before the first heading is unnumbered.
- Level 1 headings: centered bold caps. Level 2: centered bold (a claim's name). Level 3: centered (a statutory citation).
- Allegations: numbered 1, 2, ... with a 0.5-inch first-line indent.
- Lettered items (`A. `, `B. `): unnumbered, indented 0.5 inch.
- Bracketed notes (`[...]`): unnumbered, italic (used only to mark omitted pages of the transcription).
- Parentheticals (`(...)`): unnumbered continuation of the paragraph before (used after the transfers table).
- Paragraphs starting with `~` are not numbered (the `~` is removed): used for the prayer's lead-in paragraph.
- Block quotations (`>`): indented 1 inch both sides, single-spaced.
- Tables: single-spaced, the markdown table as given.
- Prayer for relief: a markdown list (`1.` ...), numbered by the markdown.
- Signature block: `lead` sentence, the firm in capitals, each signer's `sign` line and lines, single-spaced, in the right half of the page, then the role line in italics.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block followed by the body.

- Frontmatter: `case_number` (main case), `adversary_number`, `chapter`, `court`, `division`, `caption` (`in_re`: list of `{names, designation}`; `parties`: list of `{names, designation}`), `title`, `signature` (`lead`, `firm`, `signers`: list of `{sign, lines}`, `role`).
- Body: `#` and `##` and `###` headings; allegations as plain paragraphs (the template numbers them: do not type numbers); `A.`-style lettered items; `>` quotations; markdown tables; `1.` list for the prayer.
- Not supported: footnotes (none used), raw typst.

## Overlay

`sh tools/overlay.sh <doc-type-dir> jsmith-complaint` writes `samples/OVERLAY-jsmith-complaint.pdf` (red = our render, blue = the filed page, black = both) and `OVERLAY-jsmith-complaint.txt`. The page map pairs our 8 pages with exemplar pages by shared words: ours 1 and 2 with exemplar 1 and 2, ours 3 with 4, ours 4 with 5, ours 5 with 6, ours 6 with 14, ours 7 with 36, ours 8 with 37. Word overlap runs from 35% to 70%. Page 7 has the lowest overlap (34%): it holds the first omitted-pages note and the start of the prayer, and its exemplar page is 36. The overlay is a diagnostic, not a score.

## Page review (Gate 2 equivalent; every page rendered at 60 dpi and viewed)

- Page 1: caption (court lines, division, debtor and parties, case, chapter, adversary number wrapping onto a second line), title, lead-in, Introduction, lettered items A to C. Pass; the adversary number wraps at the hyphen, a cosmetic point (see Known gaps).
- Page 2: Jurisdiction and Authority, paragraphs 2 to 8, Identification of the Parties heading at the foot. Pass.
- Page 3: paragraphs 9 to 16, the Form 206Sum table and the officers table, which starts at the foot. Pass.
- Page 4: the officers table continues, Factual Allegations, paragraphs 17 to 22 (22 continues to page 5). Pass.
- Page 5: paragraphs 23 to 27, the block quotation of Section 9 (indented, single-spaced), the contacts table. Pass.
- Page 6: paragraphs 28 to 33: the transfers table, the "(collectively ...)" continuation, the omitted-pages note, the First Claim heading, paragraph 34 and the start of 35. Pass.
- Page 7: the block quotation of § 542(a), paragraph 35's citations, the omitted-pages note, the prayer lead-in (unnumbered), items 1 to 4. Pass.
- Page 8: prayer item 4 (continued) to item 9, "Respectfully submitted," the firm, the signature block with the `BY: s/` line and both counsel, the role line. Pass.

## Known gaps and open choices

1. **Excerpt, not the whole complaint.** The exemplar is 38 pages. The sample transcribes filed paragraphs 1 to 28 and 57 to 63, the First Claim's heading, and the prayer and signature (pages 36 to 38). Filed paragraphs 29 to 56 are omitted, as are filed paragraphs 64 to 74 and pages 15 to 35 (the rest of the First Claim and the Second to Seventh Claims for Relief). Each omitted range is marked in the sample with a bracketed note. The claims-for-relief pages are not transcribed, so the Second to Seventh Claims are not checked against the template.
2. **Numbering.** The template numbers the allegations from 1 in the sample. The filed numbers differ after the first omission: filed paragraph 62 (the First Claim's incorporation paragraph) renders as paragraph 34. The filed numbers are not transcribed.
3. **The exemplar's own numbers disagree.** The caption reads "CASE NO. 23-02734-5-JNC," but paragraph 9 says "BK Case No. 23-02437-5-JNC." The transcription keeps both as printed. A template cannot resolve the discrepancy; it is a question about the filing.
4. **Only one exemplar** (one filer). The tier-2 bar (2 or 3 filers) is not met. The search: the CourtListener API for `court=nceb` with `type=r` and the query "complaint adversary" returned many adversary-complaint dockets; the one downloaded and checked is JSmith Civil v. Second Wind (this one, which has a text layer and a 12-point Century Schoolbook body). Other results seen in the search (Hussein v. L&W Supply, 25-00050; Wayne Bailey v. Nationwide, 20-00026) were not downloaded.
5. **Typography is not in the rules.** EB Garamond at 12 pt is used; the exemplar body is Century Schoolbook, which has a larger x-height. No rule names a face, so the template keeps EB Garamond. TeX Gyre Schola (Century Schoolbook substitute) is vendored if David wants the exemplar's look as a tier-2 choice; switching is not required by any rule.
6. **The adversary-number line wraps** ("25-________-5-JNC" breaks at the hyphen on page 1). The caption column is 3.2 inches; widening it squeezes the party column. Not changed.
7. **Not generated:** the Adversary Proceeding Cover Sheet, the summons, any disclosure statement, and the exhibits (EXHIBIT 1 to 4 are referred to but not included).
8. **File names differ from the brief's naming.** The tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, not `<id>.pdf` and `<id>-overlay.pdf`; the names follow the tools (which the brief forbids editing).
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` need the court folder shape (court.json and rules.md at the court root), which this doc-type folder does not have; the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent.
