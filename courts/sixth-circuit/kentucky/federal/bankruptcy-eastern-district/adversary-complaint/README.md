# E.D. Ky. bankruptcy (kyeb): adversary complaint

Doc type: **adversary complaint** commencing an adversary proceeding (FRBP 7001). Court: United States Bankruptcy Court for the Eastern District of Kentucky (divisions Ashland, Covington, Frankfort, Lexington, London, Pikeville). Folder: `courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/adversary-complaint/`.

Status: exemplar=yes (2 filers), render=ok, overlay=ok, pages reviewed 14 of 14. Nothing here sets `court.json` status.

## Governing rules

Verified 2026-10-14 against the text on Cornell LII (federal rules, amendments effective Dec. 1, 2024) and the court's own local rules and Administrative Procedures Manual (APM) PDFs. The local rules read are `KYEB 120124 Local Rules CLEAN DRAFT FINAL.pdf` (its filename says "draft"; a later "POST COMMENT CLEAN FINAL 110424" version also exists and was not checked, so the LBR 1001-3 text should be confirmed against it). The APM read is the "effective November 2016, 3.31.26 revisions" PDF.

| ID | Rule | Requirement | Kind | Where it lives |
|---|---|---|---|---|
| KYEB-FORM-001 | E.D. Ky. LBR 1001-3; APM § I | No typeface, margin or paper rule applies in this court. LBR 1001-3: the District Court Local Rules do not apply unless the APM lists them. The APM's list (§ I) does not include LR 5.1 (form of papers); it includes LR 16.2, 26.1, 37.1, 54.3, 65.1.1, 83.x. Font size and margins are therefore conventions. FRBP 9004(a) requires that a document be "clearly legible". | M (legible); C (the rest) | `kyeb-adversary-complaint.typ` `font-family`, `type-size`, `margins` |
| KYEB-CAP-001 | FRBP 9004(b) | A document must contain a caption with (1) the court's name, (2) the case title, (3) the case number and, if appropriate, the adversary-proceeding number, and (4) a brief designation of the document's character. | M | court lines, caption table, `brief_title` in `title:` |
| KYEB-CAP-002 | FRBP 7010 (applies FRCP 10(a)) | A pleading's caption must substantially conform to the applicable version of Official Form 416 (Form 416A for an adversary complaint). FRCP 10(a): the title must name all the parties. | M | caption table (debtors left, chapter and case number right, parties, Adv. No.) |
| KYEB-NUM-001 | FRCP 10(b), applied by FRBP 7010 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | M | `body-blocks()`: paragraphs after the first heading are numbered by the template; the author types no numbers |
| KYEB-NUM-002 | FRCP 10(c), applied by FRBP 7010 | Statements may be adopted by reference; a written instrument attached as an exhibit is part of the pleading. | M (content) | not checked by the template; the author refers to exhibits |
| KYEB-JUR-001 | FRBP 7008(a) (applies FRCP 8) | The jurisdiction allegation must refer to the name, number and chapter of the case to which the proceeding relates, and to the district and division where it is pending. The complaint must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | M (content) | body (author-written; the sample has ¶¶ 2-7 and the consent paragraph) |
| KYEB-PRIV-001 | FRCP 5.2(a), applied to bankruptcy by FRBP 9037 (9037 not fetched; applies by its own terms) | A filing may show only the last four digits of an SSN or taxpayer-identification number, the birth year, a minor's initials, and the last four digits of a financial-account number. | M (content) | the sample's debtor footnote shows last four digits of TINs only |
| KYEB-SIG-001 | FRBP 9011(a) | Every pleading must be signed by at least one attorney of record in the attorney's individual name, and must state the signer's address and telephone number, "if any". A party without counsel signs. An unsigned document is struck unless corrected. | M | `signature-block()`: `/s/` line, firm, address, telephone (from `signature:`) |
| KYEB-SIG-002 | convention | E-mail address under the signature (the rule does not require it; both exemplars print it). | C | `signature.lines` |
| KYEB-FORM-003 | convention | Double-spaced numbered paragraphs, single-spaced caption, headings and footnotes. Both exemplars are double-spaced. | C | `line-pitch` 24 pt, `body-leading`, `single-leading` |
| KYEB-FORM-004 | convention | Page number centred at the foot of each page. Both exemplars carry it. | C | page `footer` |
| KYEB-HEAD-001 | convention | Section headings centred, bold, capitals; Count titles centred bold, with the statute in a parenthetical line beneath (both exemplars). | C | `show heading` rules; the `(...)` line under a heading is centred by `body-blocks()` |
| KYEB-LIST-001 | convention | Lists of relief are lettered (a., b., c.), hanging-indented; the prayer's lead-in line is not numbered (both exemplars). | C | `set enum(numbering: "a.")`; a paragraph ending in ":" or starting WHEREFORE is unnumbered |
| KYEB-FOOT-001 | convention | Debtor list in a footnote on the caption (both exemplars). | C | `caption.debtors.footnote` |
| KYEB-CERT-001 | none required | No certificate of service is generated for the complaint: service is by summons under FRBP 7004 (not generated here; see gaps). The exemplars have none. | — | not generated |

Not used, and why: E.D. Ky. LBR 9013-1 and 9014-1 govern motions, not complaints. The local-rules index has no LBR 7001; its only 7000-series rules are 7026-1 and 7067-1. The joint district rule LR 83.12 (referral) is cited in the Fox complaint's ¶ 1; it is not a requirement of this template.

## Exemplars (two filers)

- `usage/SAMPLE-kyeb-adversary-complaint-kennedycambrian1951200.pdf`: Complaint to Avoid Transfers, *Kennedy (Cambrian Liquidating Trust) v. Appalachian Security, Inc.*, Lexington Division, main case 19-51200, Doc 1800, filed June 15, 2021. Filer: Dinsmore & Shohl LLP for the liquidating trustee. 17 pages. **Transcribed in the sample.**
- `usage/SAMPLE-kyeb-adversary-complaint-foxvbiden2206032.pdf`: Complaint to Recover Fraudulent Transfer and for Turnover, *Fox (Chapter 11 trustee, Americore Health) v. Biden*, London Division, main case 19-61608, Adv. 22-06032, Doc 1, filed July 7, 2022. Filer: Nelson Mullins Riley & Scarborough LLP. 16 pages. Used for the tier-2 comparison (caption style, heading and paragraph conventions).
- Provenance, searches, and the note on the blank adversary number: `usage/SOURCE.md`.

## Sample

- `usage/INPUT-kyeb-adversary-complaint-kennedycambrian1951200.md`: a transcription of the Kennedy complaint: caption, title, lead-in, every section heading in order, paragraphs 1-62 (numbers not typed), the five counts, the prayer, the footnotes, and the signature block. The Statement of Account (Exhibit A, a table of transfers) is not transcribed. Tables are not supported by the markdown contract.
- Frontmatter contract (the template reads these fields; a missing one stops the build): `case_number`, `chapter`, `jointly_administered`, `adversary_number` (optional, blank prints `Adv. No. ____`), `court` (list of lines, upper case), `caption` (`debtors` with `names`, optional `footnote`, `designation`; `parties` with `names`, optional `serve` lines, `designation`), `title` (list of lines, upper case), `date`, `signature` (`firm`, `signer`, `lines`).
- Body contract: `# Heading` is a centred section; `## Heading` is a centred Count title; a parenthesised paragraph directly under a heading is its centred subtitle. Blank lines separate paragraphs. Paragraphs after the first heading are numbered 1, 2, 3 …; the lead-in before the first heading, paragraphs starting WHEREFORE and paragraphs ending with a colon are not. `1. ` starts a lettered list (the template letters it a., b., …). Footnotes: `[^key]` in the text and `[^key]: text` as its own paragraph. Escaping is not needed for numbers because the author never types paragraph numbers.

Sample naming: the tools read and write `INPUT-` / `OUTPUT-` / `OVERLAY-` names (`tools/render.sh`, `tools/overlay.sh`), so the sample is `INPUT-kyeb-adversary-complaint-kennedycambrian1951200.md`, the render is `usage/OUTPUT-kyeb-adversary-complaint-kennedycambrian1951200.typst.pdf`, and the overlay is `usage/OVERLAY-kennedy-cambrian-19-51200.pdf` with `.txt`. The brief's `<id>.pdf` / `<id>-overlay.pdf` names are not used because the tools do not read them.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/adversary-complaint usage/INPUT-kyeb-adversary-complaint-kennedycambrian1951200.md
sh tools/overlay.sh courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/adversary-complaint kennedy-cambrian-19-51200 courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/adversary-complaint/usage/SAMPLE-kyeb-adversary-complaint-kennedycambrian1951200.pdf
```

- `usage/OUTPUT-kyeb-adversary-complaint-kennedycambrian1951200.typst.pdf`: 14 pages. `render.sh` ran typst with no warnings (it fails on any). `pdffonts`: EBGaramond-Regular, -Italic, -Bold, embedded; no fallback font.
- The overlay is run against the Kennedy exemplar, because that is the one the sample was transcribed from. `overlay.sh` with no third argument would use the first exemplar alphabetically (Fox), which is the wrong comparison for this sample. The page map (`OVERLAY-kennedy-cambrian-19-51200.txt`) pairs ours p.1-4 with filed p.1-4, ours p.7 with filed p.8, and ours p.13-14 with filed p.15-16. Word overlap runs 45-88%. The overlay is a diagnostic (tier 3): the filed copies use Times with ECF headers and Exhibit A; the render uses Garamond and has none of those.

## Gate 2 visual review (all 14 pages, rendered at 60 dpi, each viewed)

Compared with the Kennedy exemplar (`exemplar p.n`) and, for caption and headings, the Fox exemplar. Reviewed on the final render (sha256 of the reviewed PDF: `46d6d6806022938c453216a8fff74bfcadf12a6742401ef1bd70df2442e3c2ae`).

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title, caption box (debtors, chapter, case no., Adv. No. blank), plaintiff, "Serve:" block, defendant; debtor footnote with TIN last four digits. Caption is taller than the exemplar's (Garamond at 13 pt, box rule); the court title and caption fit. | ACCEPTED: tier-3 type face; see gap 1 |
| 2 | exemplar p.2 | Title (3 lines, bold, centred) and lead-in start on page 2: page 1 holds the court title, caption and footnote 1, and the title block does not fit below them. Heading "NATURE OF THE CASE" centred; ¶ 1 numbered with first-line indent. | ACCEPTED: layout consequence of the footnote; the exemplar fits its title on page 1 because its caption is set in Times 12 pt |
| 3 | exemplar p.3 | Headings centred and bold; ¶¶ 2-11 numbered in order, each a separate paragraph. | PASS |
| 4 | exemplar p.4 | ¶¶ 12-16; heading "THE PARTIES" centred; first-line indent on each paragraph. | PASS |
| 5 | exemplar p.5 | ¶ 17-20; footnote marker "years.² In connection" (the space after the marker is kept; this was fixed after the first render). | PASS |
| 6 | exemplar p.6 | ¶ 20 continues; footnote 2 at foot in smaller type than body; ¶¶ 21-24. | PASS |
| 7 | exemplar p.7 | ¶¶ 24-27; list-free prose. | PASS |
| 8 | exemplar p.8 | End of ¶ 27, then ¶¶ 28-32, each paragraph a separate block. | PASS |
| 9 | exemplar p.9 | End of ¶ 32, then ¶¶ 33-36 (end of the factual background). | PASS |
| 10 | exemplar p.10 | "CLAIMS FOR RELIEF" centred; "COUNT I" centred bold; subtitle "(Avoidance of Preference Period Transfers – 11 U.S.C. § 547)" centred; ¶¶ 37-46. | PASS |
| 11 | exemplar p.11 | ¶¶ 47-52 with COUNT II list items a., b., c. hanging-indented; COUNT III heading and subtitle. | PASS |
| 12 | exemplar p.12 | ¶¶ 53-62; COUNT IV and V headings and subtitles. | PASS |
| 13 | exemplar p.15 | PRAYER FOR RELIEF heading; WHEREFORE and the "As to Counts I through V" lead-in unnumbered; relief items a.-h. lettered. | PASS |
| 14 | exemplar p.16 | Signature block alone on the last page: "Dated: June 15, 2021", firm, `/s/` line, counsel address, telephone, e-mail. The block is kept whole, so it moves to this page as a unit. The exemplar also has its signature on a page without body text. | ACCEPTED: the signature block is never split; no rule requires body text on the signature page |

Pages reviewed: 14 of 14.

## Known gaps and open choices

1. **Typeface (KYEB-FORM-001).** No face is named by a rule, and `docs/FONTS.md` says a court that names none keeps EB Garamond (fonts pass, 2026-10-15). The template stays EB Garamond 13 pt. Both exemplars are set in Times, and `fonts/liberation-serif/` (the Times substitute, metric-compatible) is vendored, so switching `font-family` to `"Liberation Serif"` is a one-line change if David prefers to match the exemplars. That is a style choice, not a rule, and is left open. **Needs David's call.**
2. **Pleading paper.** Neither exemplar uses numbered pleading lines; no E.D. Ky. rule requires them in this court (LR 5.1 is not in the APM list). Not drawn.
3. **Adversary cover sheet (Official Form 1040).** Not verified in this session. If FRBP 7003 or the APM requires it with the complaint, the filing needs it separately. Not generated.
4. **Summons (FRBP 7004; Official Form 2600 series).** Issued separately; not generated.
5. **ECF header.** The filed copies carry the ECF stamp ("Case 19-51200-grs Doc 1800 Filed …"). It is printed by the court's system at filing, not by the author, so the template does not draw it.
6. **Exhibits.** Exhibit A (the statement of account) is a table. Markdown tables are not supported by the template. The sample names the exhibit in the text and does not transcribe it.
7. **Paragraph numbering in the sample.** The sample's paragraphs are numbered by the template from 1 (the exemplar's numbers are not transcribed). Gate-level comparison of numbers is therefore not applicable.
8. **Lettered lists.** Items are lettered a., b., c. (the Fox exemplar's style). The Kennedy prayer uses capitals A., B., C. (its own style, tier 3).
9. **Tier-2 count.** Two exemplars from two filers (Dinsmore & Shohl; Nelson Mullins), both E.D. Ky. complaints. Tier 2 is judged against them (see the table above).
10. **Adversary number.** The Kennedy copy has the adversary number blank. The template prints `Adv. No. ____` when `adversary_number` is empty, which is what the copy shows.

## Engines

- **typst** (primary): `typst/`, unchanged.
- **docx**: `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference (EB Garamond 13 pt, exact 24 pt body line pitch, 0.5 in first-line indent, 1 in margins on US Letter, single-spaced caption, signature and footnotes, 12 pt centered PAGE footer). `docx/kyeb-adversary-complaint.lua` builds the caption table, court and title lines, the signature block and the template's paragraph numbering (typed "N." plus a tab; the author types no numbers); lists are lettered a., b., c. Font, size, line pitch, margins, footer and caption layout match the typst form.
- **Differs from typst**: (a) the caption rules come from the table style, so the rule under the right column and the rule between the two caption rows are drawn too (typst draws them under the left column only). (b) Paragraph numbers are literal text, not a list, so Word and LibreOffice do not renumber them if the text is edited. (c) Line breaks and page breaks follow Word or LibreOffice font metrics, not typst's.
- **BLOCKED (docx.pdf gates, Gates 0 to 3 on `OUTPUT-<id>.docx.pdf`)**: LibreOffice (`soffice`) is not installed on the box used for this build, so the LibreOffice PDF was not produced and no page was reviewed in the docx engine. `usage/OUTPUT-kyeb-adversary-complaint-kennedycambrian1951200.docx` was produced and checked only for a valid zip and well-formed XML parts; it has not been opened in Word or LibreOffice (no repair-prompt check).
