# ohsb: motion with memorandum in support

Doc type: **motion with memorandum in support** (FRBP 9013) in the United States Bankruptcy Court for the Southern District of Ohio (`ohsb`).
Folder: `courts/sixth-circuit/ohio/federal/bankruptcy-southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-actual-brewing-2-19-bk-50813-motion-brief.pdf` (1 filer, the U.S. Trustee; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-actual-brewing-ust-motion.md` (full transcription of the motion and memorandum, all ten footnotes and the certificate of service; the exemplar's mailing matrix is not transcribed) |
| render | ok: `samples/OUTPUT-actual-brewing-ust-motion.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond-Regular and -Bold, embedded), no warnings |
| overlay | ok: `samples/OVERLAY-actual-brewing-ust-motion.pdf` and `OVERLAY-actual-brewing-ust-motion.txt` (page map below) |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Each rule was read from its primary source. The local rules are the S.D. Ohio Local Bankruptcy Rules as amended effective October 1, 2020 (PDF on the court's site: https://www.ohsb.uscourts.gov/sites/ohsb/files/local_rules/Final%20Version%20of%20Amended%20LBRs_Effective%20Oct%201%202020.pdf), read 2026-10-14. A search on 2026-10-14 found no later bankruptcy LBR amendment on the court's site (the amendment orders found were dated 2009, 2011, 2016 and 2020). That is not proof there is none, so confirm the current text with the clerk before treating this as final.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013, read 2026-10-14) | (a) A request for an order is made by written motion unless an exception applies. (b) The motion must state its grounds with particularity and set forth the relief requested; it must be served on the parties named in the rule. | the motion paragraph and the memorandum (author content); the template does not check grounds or relief |
| Fed. R. Bankr. P. 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004, read 2026-10-14) | Legible; a caption with the court's name, the case title, the case number, and a brief designation of the document. | `court-title`, `caption`, `brief_title` |
| S.D. Ohio LBR 9004-1(b) | 8½ × 11 bond paper; double spaced; side margins; top margin of at least one inch; typed print at least 10 to 12 point. | `margin` = 1 in on all sides; `type-size` = 12 pt; `body-leading` = 1.35 em (24 pt pitch at 12 pt) |
| S.D. Ohio LBR 9004-2 | Caption with the debtor's name, case number, chapter, adversary number (if any) and the judge's name; the nature of the paper and the specific relief requested; a statement of the relationship to prior filings. | caption right column (case number, chapter, judge); title (`brief_title`); the relief is in the motion paragraph |
| S.D. Ohio LBR 9013-1(a)(1)(A) | A motion is accompanied by a memorandum in support. | the memorandum is part of the document (the exemplar's form) |
| S.D. Ohio LBR 9013-1(a)(1)(B) and LBR 9013-3 | A certificate of service, except for ex parte relief or a motion the clerk notices; the parties to be served are the debtor, the debtor's attorney, the trustee, the U.S. Trustee, and parties directly affected or requesting notice. | `CERTIFICATE OF SERVICE` in the sample; the template does not check the list of parties |
| S.D. Ohio LBR 9013-1(a)(1)(C) and (a)(2) | A 21-day notice substantially in the form of the rule's sample (or Official Form 420A), except where the Federal Rules, General Order #12, another local rule or a court order provides otherwise. | `{{NOTICE_21_DAY}}` directive, filled from `notice:` frontmatter (`movant`, `relief`, `clerk_address`, `movant_address`, `others`). **Not used in the sample** (see gaps) |
| S.D. Ohio LBR 9013-2(a) | Briefs and memoranda are limited to 20 pages without leave. | not checked (the sample body is 7 pages; no page counter exists) |

## Layout

- Court title (three centered lines in bold): UNITED STATES BANKRUPTCY COURT / SOUTHERN DISTRICT OF OHIO / the division.
- Caption: the debtor on the left, a column of ")" marks, and the case information on the right (Case No., Chapter, Judge). Each line is a fixed-height row, so the marks line up with the debtor's lines.
- Title of the paper, bold, centered.
- Body: the motion paragraph (unnumbered, 0.5 inch first-line indent); the signature block ("Dated:" at the left, the firm and the signer at the right, single spaced); `MEMORANDUM IN SUPPORT` (level 1, centered bold capitals) with level-2 headings (centered bold); the enumerated summary of facts; the lettered quotation of § 1112(b)(4), indented 0.75 inch with the "***" omissions centered; footnotes at 12 pt single spaced; the WHEREFORE paragraph; a second signature block; the certificate of service.
- Paragraph spacing equals the leading (1.35 em), so the gap between paragraphs carries the second half of the double-spaced pitch. Headings keep with the next paragraph (`sticky`).
- Footer: page number, centered.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: `#` (level 1: centered bold capitals), `##` (level 2: centered bold), a markdown list (`1.` items, numbered by the list), a lettered quotation "(A) ..." (indented), the centered asterisks "***", the directives `{{SIGNATURE}}` (the signature block from frontmatter) and `{{NOTICE_21_DAY}}` (the 21-day notice from frontmatter), or a paragraph (unnumbered).
- A paragraph with hard line breaks (a backslash at the end of a line) is set single spaced and unindented (used for address blocks).
- Footnotes: `[^n]` references and `[^n]: text` definitions (the definitions can sit anywhere; they are removed from the body and placed at their references). A space after a reference is kept.
- Frontmatter: `case_number`, `chapter`, `judge`, `division`, `caption.left` and `caption.right` (one entry per line; empty strings are blank rows), `brief_title`, `date` (used for "Dated:"), `signature` (`closing` optional, `firm` optional, `lines` for the signer and counsel), and `notice` (only when the sample uses `{{NOTICE_21_DAY}}`).
- Not supported: tables (the motion has none), raw typst, HTML, the ECF header lines.

## Overlay

`tools/overlay.sh` pairs each sample page with the exemplar page sharing the most words (`samples/OVERLAY-actual-brewing-ust-motion.txt`):

```
ours p.1  filed p.1  word-overlap 94.1%
ours p.2  filed p.2  word-overlap 93.4%
ours p.3  filed p.3  word-overlap 72.7%
ours p.4  filed p.4  word-overlap 66.4%
ours p.5  filed p.5  word-overlap 70.7%
ours p.6  filed p.6  word-overlap 50.0%
ours p.7  filed p.7  word-overlap 38.7%
```

Red = our render, blue = the filed exemplar, black = both. The exemplar is a Times New Roman document with no line numbers; the render is EB Garamond, so glyph outlines do not coincide, but the page-level pairing is right: the first seven pages of the exemplar are the motion and memorandum, and the render's seven pages are the same content. The overlay is a diagnostic, not a score. The word-overlap figures fall as the render's text moves across page breaks differently from the exemplar's (the typeface and line length differ), not because of missing text.

## Visual review (Gate 2 record, all 7 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: court title, caption with ")" column, title, motion paragraph, "Dated" and the firm and signer block | OK. Caption and signature are aligned; no overlap. |
| 2 | Memorandum heading, INTRODUCTION, SUMMARY OF FACTS, items 1 to 6, footnote 1 (quotation of § 1112(b)(1)) | OK. |
| 3 | Items 7 to 13, the deadlines paragraph, CAUSE heading, the lettered quotation (A), (E), (F) with centered "***" | OK. |
| 4 | Quotation (H), (K), (M) with footnote 2; the duties paragraphs with footnotes 3 to 6 | OK after the fix below. Footnote numbers 2 to 6 at the foot match the references (checked in the text layer). |
| 5 | Summary of the Rule 1007(c) argument; footnotes 7 to 10 | OK after the fix below. |
| 6 | CONCLUSION, WHEREFORE, the second signature block, the start of the certificate of service | OK. |
| 7 | End of the certificate: address blocks and the "/s/" line | OK. Address blocks single spaced, unindented. |

Defects found and fixed during this review (for the record): (1) the space after a footnote reference was lost ("Trustee.³The"), because markdown drops whitespace at segment edges; now kept (`seg()`); the same defect was found in the complaint (fixed there too); (2) the certificate's address lines were indented and double spaced, reading as separate paragraphs; now a hard-broken chunk is single spaced and unindented.

## Known gaps and open choices

1. **One filer only.** The brief asks for one exemplar per doc type, and the CourtListener search was rate-limited before a second, post-2024 debtor-side motion with a memorandum was found. Tier 2 is judged against one filer, not two or three.
2. **No 21-day notice in the sample.** The exemplar (filed March 2019) has no 21-day notice. LBR 9013-1(a)(1)(C), as posted with the 2020 amendments, requires one unless an exemption applies, and the template renders it when the sample carries `{{NOTICE_21_DAY}}` and a `notice:` block. The sample does not carry it, so the render does not show it. Whether the U.S. Trustee's motion to convert or dismiss is exempt under General Order #12 was not checked. Decide before a real filing; the template is ready.
3. **Local-rule numbers in the filed text predate the 2020 numbering.** The exemplar cites LBR 1007-1, 1007-2, 1015-2, 1074-1 and 5005-4. These are kept as filed. Whether those numbers are current in the 2020 LBR was not checked against each rule.
4. **Font.** EB Garamond at 12 pt. The exemplar is Times New Roman (embedded). The LBR names no typeface and requires 10 to 12 point. Both are choices; the difference is recorded, not treated as a rule.
5. **Footnotes single spaced at 12 pt** and the certificate's address blocks single spaced. LBR 9004-1(b) asks for double spacing of the filing; footnotes and address blocks are conventionally single spaced, and the rule does not name either. This is a reading, recorded here.
6. **Typos in the filed text are kept**, as transcribed: "exits" for "exists", "covert" for "convert", "Chapter11", "Non− Individuals", and a stray numeral before "or in the alternative" that is dropped (noted in the sample's header; it has no footnote behind it).
7. **Mailing matrix not transcribed** (exemplar pages 8 and 9). The certificate lists the parties by name; the attached matrix is a separate document in practice.
8. **Page count.** 7 pages for the body; the exemplar's body is also 7 pages (its pages 8 and 9 are the matrix). Inside the target for the content transcribed.
9. **LBR 9013-2(a) 20-page limit** is not counted by the template; the sample is 7 pages.
10. **`tools/check.sh` and `tools/check-selftest.sh` are not run.** They expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape; the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 record.
11. **File names.** The brief names outputs `samples/<id>.pdf` and `samples/<id>-overlay.pdf`. The tools read and write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` by default, and `tools/overlay.sh` reads `OUTPUT-<id>.pdf` to build its overlay, so this folder follows the tools' names. The sample is `INPUT-<id>.md`, the same convention.

[Court folder](../README.md)
