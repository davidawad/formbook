# C.D. Cal. Bankruptcy Court: motion with memorandum

Doc type: **motion** with notice and a memorandum of points and authorities (FRBP 9013, 9014; LBR 9013-1). Court: United States Bankruptcy Court, Central District of California (cacb). Folder: `courts/ninth-circuit/california/federal/bankruptcy-central-district/motion-brief/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 11 of 11 (the transcribed sample, every page viewed as PNG in its final form). Nothing here sets a court-level `court.json` status.

The exemplar is a filed chapter 7 trustee's motion with a memorandum, *In re James Capital Advisors, Inc.*, 2:23-bk-14820-BB, Doc 48 (Bankr. C.D. Cal., Los Angeles Division, filed August 23, 2023). Its source, filer and search trail are in `exemplars/SOURCE.md`. The sample `samples/INPUT-james-capital-advisors.md` is a **transcription** of that filing in its real order (notice, memorandum, declaration, proof of service). Page 9 of the filing is a rotated scan, read by eye.

The template's layout comes from the rules; the exemplar settles the conventions the rules leave open (section numerals above the titles, unruled tables, a signature block with the firm to the right). The filing uses Times New Roman, and this template uses Liberation Serif, its vendored metric-compatible substitute (`docs/FONTS.md`): see gap 2.

## Governing rules

Sources, read 2026-10-14:

- **Local Bankruptcy Rules, effective October 21, 2024**: https://www.cacb.uscourts.gov/sites/cacb/files/documents/local_rules/COMPLETE%20LBRS%2010-2024%20double-sided.pdf. Sections cited below are its numbering. The court's site also lists a May 2025 edition, **not fetched**; check it before relying on the text here.
- **Central Guide Supplement to LBR 9004-1** (August 2022): https://www.cacb.uscourts.gov/sites/cacb/files/documents/the-central-guide/TCGSupp9004-1_Form-and-Format-of-Documents-to-be-Filed.pdf. Same source as the adversary complaint.
- FRBP 9013 and 9014 are cited from memory of the rules. **Not fetched, not verified.**

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| CACB-FORM-001 to -006 | Central Guide 9004-1(b)(2) | Pages 8.5 x 11; numbered margins (a motion is named in (B)(i)), at most 28 lines; typeface at least 12 point; line 1 at least 1 inch from the top; double spacing; page numbers at the bottom. | `page-w/h`, `lines-per-page`, `pitch`, `type-size`, `top-margin`, `footer-block()`. Typeface: Times New Roman is listed, so `font-family` = "Liberation Serif" (`docs/FONTS.md`). |
| CACB-CAP-001 to -003 | Central Guide 9004-1(c)(1)(A)-(C) | Counsel block on lines 1-7; clerk's space; court title (with the division) centered on or below line 8. | `counsel-block()`, `court-title()` |
| CACB-CAP-004 | Central Guide 9004-1(c)(1)(E)-(F) | Bankruptcy case number to the right of center, opposite the party names; chapter number immediately below. | `caption()` right column |
| CACB-CAP-005 | Central Guide 9004-1(c)(1)(H) | Concise title of the document on the first page, below the chapter number or the caption. Where possible, the proponent's name is in the title. | `caption()`, `brief_title` |
| CACB-CAP-006 | Central Guide 9004-1(c)(1) (hearing), with the sample caption of a motion, 9004-1(c)(1)(I) | Hearing date, time and place, with the courthouse address, immediately below the title, on the first page. | `hearing` (lines) |
| CACB-NOTICE-001 | LBR 9013-1(c)(2) | Written notice of motion, specifying the relief requested and, if applicable, the date, time and place of the hearing, and advising that LBR 9013-1(f) requires a written response at least 14 days before the hearing. | **Author-written, not enforced**: the sample's Notice section carries the advisement. The template does not check it. |
| CACB-MEMO-001 | LBR 9013-1(c)(3)(A) | A written statement of all reasons, with a memorandum of the points and authorities relied on. Not required for applications to retain or compensate professionals, motions for relief from stay, or motions to sell, use, lease or abandon estate assets, unless special circumstances or the court orders one. | Template prints whatever the author writes; **not enforced**. The exemplar's memorandum supports a Rule 9019(b) compromise motion. |
| CACB-DECL-001 | LBR 9013-1(c)(3)(B)-(C) | Declarations required by FRBP 9014(d), 9017 or 9006(d), and copies of all exhibits the motion relies on. | Separate documents; not generated |
| CACB-FINAL-001 | LBR 9013-1(c)(4) | In a contested matter, the moving party must raise any objection to the bankruptcy court's authority to enter a final order in the motion, with authority and evidence; silence is consent. | Author-written. The exemplar carries no such statement, so the sample has none. Not enforced. |
| CACB-TIME-001 | LBR 9013-1(d)(2) | Notice of motion and motion filed and served at least 21 days before the hearing (exceptions listed). | Not checked: a calendar matter. |
| CACB-RESP-001 | LBR 9013-1(f)(1)-(2) | Responses filed and served at least 14 days before the hearing; a response must advise that any reply is due 7 days before the hearing. | Notice advisement (author-written). |
| CACB-REPLY-001 | LBR 9013-1(g) | Reply memorandum at least 7 days before the hearing. | Notice advisement (author-written). |
| CACB-SERVE-001 | LBR 9013-1(e) | Every document filed under the rule must be accompanied by a proof of service (LBR 9013-3). | **Not generated.** Separate document. See gaps. |
| CACB-FORM-LBR-001 | LBR 9013-1(o), (p), (q); LBR 9009-1 | The notice of opportunity to request a hearing (o), notice-only (p) and no-notice (q) procedures carry court-approved forms (F 9013-1.2 family) that must not be altered (LBR 9009-1(b)(4)). | **Not generated.** A motion on those procedures must use the court form. |

## Layout

The page furniture, typeface, spacing and caption are the same as the adversary complaint template (`../adversary-complaint/typst/cacb-adversary-complaint.typ`), with three differences:

- The caption is **single**, not double: a motion in the main case carries "In re: / Debtor." on the left (Central Guide 9004-1(c)(1)(I), the sample caption of a motion). An adversary motion would need the double caption (9004-1(c)(2)); not built.
- Headings are numbered by the template from their level: level 1 is a centered section (NOTICE OF MOTION, MEMORANDUM OF POINTS AND AUTHORITIES), restarting the count; level 2 is a centered bold numeral (I.) above the title in capitals, as in the exemplar; levels 3-5 are A., 1., a. (typed numbers in the sample are not used).
- Paragraphs are unnumbered and indented (memorandum style), and markdown lists are numbered 1., 2., ....
- Declarations and proofs of service sit where the filing puts them. The body is followed by a signature only where the sample has `<!-- signature -->`; `<!-- pagebreak -->` starts a new page. Lines of a declaration numbered in the text are escaped (`1\.`) so they do not become a list.
- Tables (the listings and the service list) are unruled and single-spaced, as in the exemplar.
- The signature block has no "Respectfully submitted," line (the exemplar has none). The `/s/` form of the signer's name stays.

No table of contents or table of authorities is generated. No C.D. Cal. rule that I read requires one for a motion or memorandum; not checked against the full rules (see gaps).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/ninth-circuit/california/federal/bankruptcy-central-district/motion-brief samples/INPUT-james-capital-advisors.md
sh tools/overlay.sh courts/ninth-circuit/california/federal/bankruptcy-central-district/motion-brief james-capital-advisors
```

- `samples/OUTPUT-james-capital-advisors.pdf`: 11 pages, the same count as the filing. Typst compiled with no warnings. Fonts: Liberation Serif only (vendored); `pdffonts` shows `LiberationSerif` and `LiberationSerif-Bold`, embedded. The sample has no italic markup, so no italic face is used.
- Line pitch: `body-leading` 1.345 em and `single-leading` 0.345 em give 24.0 pt and 12.0 pt on the numbered grid, as in the adversary complaint (the leading is set per face because Liberation Serif's line box is 0.655 em).
- `samples/OVERLAY-james-capital-advisors.pdf` and `.txt` were written. Page pairing by word overlap: notice pages 1-2 at 84% and 92%; memorandum pages 3-6 at 94%, 80%, 75%, 71%; declaration and proof of service pages 7, 9, 10, 11 at 85%, 77%, 41%, 80%. Our page 8 pairs with filed page 2 at 17%: a spurious pairing, since the declaration's second page carries few words. The memorandum's conclusion falls on page 6 here and page 7 in the filing; the sample is a transcription, so this is not established as a template finding.

## Visual review (Gate 2 record, all 11 pages of the transcribed sample, rendered at 80 dpi and looked at, final render with Liberation Serif)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel (lines 1-7), court title, caption with case number, chapter, title and hearing lines, start of the Notice | OK. The footer title was clipped at the page edge (it wrapped to two lines) and is now shortened to "Trustee’s Motion to Compromise". |
| 2 | Notice (end), grounds, 14-day advisement, signature block | OK. "Dated" at left, firm name at right, `/s/` block. |
| 3 | MEMORANDUM heading, Introduction (I.), Factual Statement (II.) | OK. Section numerals sit above centered titles, on the line grid, with a blank line before. |
| 4 | Factual statement, the listings table | OK. The table is unruled and single-spaced, as in the filing. |
| 5 | Factual statement end, Legal Discussion (III.), block quote of FRBP 9019(b) | OK. The block quote's spacing is a little loose, accepted. |
| 6 | Legal Discussion end, Conclusion (IV.), signature block | OK. |
| 7 | Declaration heading, ¶¶ 1-5 with the listings table | OK. |
| 8 | Declaration ¶ 6, penalty clause, execution line, name | OK. |
| 9 | Proof of service: items 1-3, the service list table | OK. The table is unruled. |
| 10 | Proof of service item 3 and the declaration with the date, printed name and signature row | OK. |
| 11 | Additional service information: the NEF list and the mandatory-form line | OK. |

Reviewed pages: 11 of 11 (of the transcribed sample).

Defects found and fixed during review: the footer title clipped at the page edge (fixed in the sample, `footer_title`); level-2 headings left-aligned and single-line, where the filing centers the numeral and the title on two lines (template changed); tables drawn with full rules (template now unruled); "Respectfully submitted," in the signature block (removed, the filing has none); the signature block placed after the body, where the declaration and proof of service come later in the filing (template now takes `<!-- signature -->` markers); the time placeholder `__:__` was read as emphasis and dropped in the earlier synthetic sample (superseded by this transcription).

## Known gaps and open choices

1. **One exemplar, one filer.** The exemplar is a chapter 7 trustee's motion by trustee's counsel (Danning, Gill, Israel & Krasnoff). Tier 2 asks for 2 or 3 filers; a second filed motion with a memorandum from a creditor or debtor (for example, Zions Bancorporation's remand motion, 8:26-ap-01060 Doc 16, 30 pages) is the next addition. See `exemplars/SOURCE.md`.
2. **Typeface (CACB-FORM-001 to -006). Resolved in the fonts pass.** The Central Guide lists Times New Roman among the required typefaces; the template uses Liberation Serif, the vendored metric-compatible substitute (`docs/FONTS.md`). Same decision as the adversary complaint: see that README, gap 1. The sample's page count is 11, the same as the filing.
3. **Proof of service (LBR 9013-1(e)).** Required with every document under the rule; not generated. A separate form (F 9013-3.1 family) is needed.
4. **Court-approved notice forms (LBR 9013-1(o), (p), (q)).** If the motion is decided on notice or without a hearing, the court's form must be used (LBR 9009-1(b)(4)). This template makes a free-form notice; it is not those forms.
5. **Memorandum requirement.** LBR 9013-1(c)(3)(A) exempts sale, use, lease, abandonment, stay-relief and professional-compensation motions from the memorandum unless special circumstances or an order apply. The exemplar's memorandum supports a Rule 9019(b) compromise, which the rule does not list as exempt; the template does not decide when one is needed.
6. **Notice advisements, consent statement and the 21-day rule** are author-written content (see the rule table). The template does not check them; a check on the notice's 14-day advisement and the final-order statement would be needed for a true gate.
7. **Table of contents and table of authorities** are not generated. Not verified against the full LBR text whether a C.D. Cal. memorandum needs them; the N.D. Cal. convention does not apply here.
8. **Page limits** (memorandum length) are not checked. Not verified against the LBR text read.
9. **FRBP 9013, 9014, 9017 and 9006(d) text** not fetched; cited from memory.
10. **Transcription.** The sample is a transcription of one filing, not a template-wide layout claim. Page 9 of the filing is a scan, read by eye (¶¶ 5-6 and the signature), so a few words there may differ from the original.
11. **LBR edition.** Read from the October 21, 2024 edition. Check the May 2025 edition before relying on the rule text.
