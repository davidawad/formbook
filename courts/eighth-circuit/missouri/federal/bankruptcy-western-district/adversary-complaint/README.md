# W.D. Mo. Bankruptcy: adversary complaint (mowb)

Doc type: **adversary-complaint**, the complaint that starts an adversary proceeding (Fed. R. Bankr. P. 7001) in the United States Bankruptcy Court for the Western District of Missouri (Kansas City). Folder: `courts/eighth-circuit/missouri/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, 2 filers: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (35 pp, Enterprise Bank and Trust, 2025) and `usage/FILED-EXAMPLE-adversary-complaint-2.pdf` (7 pp, Standley Enterprises, 2019). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-adversary-complaint.md` (a portion of the Carlson complaint, see gap 6) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 11 pages (10 on the earlier EB Garamond render), typst 0.15.0, Times New Roman only (pinned; vendored Liberation Serif fallback), no warnings |
| typeface | no face named by the court's rules (checked 2026-10-14); Times New Roman 12 pt, the house standard (`docs/FONTS.md`, rule 6; EB Garamond 13 pt until then) |
| overlay | fail (2026-10-14): `tools/overlay.sh` cannot run, because `usage/` holds only `SOURCE.md` and the filed PDFs are not in this snapshot. The `OVERLAY-enterprise-carlson-complaint.txt` shown is from the earlier run; no `.pdf` overlay exists. |
| pages reviewed | 10 of 10 (every page of the 2026-10-14 render, EB Garamond, rasterized at 60 dpi and viewed) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`INPUT-` for the markdown, `OUTPUT-` for the render, `OVERLAY-` for the overlay), which is the file-role naming in CLAUDE.md. The overlay tool writes `OVERLAY-<id>.pdf`; it does not write `<id>-overlay.pdf`.

## Governing rules

Primary sources. Fetched 2026-10-14.

| ID | Rule | Requirement | Where it lives in the template |
|---|---|---|---|
| MOWB-AC-001 | Fed. R. Bankr. P. 7010 (Cornell LII, `rule_7010`) | "Fed. R. Civ. P. 10 applies in an adversary proceeding"; the pleading's caption "must substantially conform to the appropriate version of Form 416" (Official Form 416D is the adversary caption; the form number comes from a secondary search, not from uscourts.gov, so verify). | `caption-block`: court lines, debtor, case number, chapter, plaintiff, defendant, adversary number. |
| MOWB-AC-002 | Fed. R. Bankr. P. 7008(a) (Cornell LII, `rule_7008`) | The allegation of jurisdiction must reference the name, number and Code chapter of the case, and the district and division. A complaint must state whether the pleader "does or does not consent to the entry of final orders or judgment by the bankruptcy court." | Caption (name, number, chapter, division) and `consent` in the frontmatter, printed after the lead-in as an unnumbered paragraph. The jurisdiction paragraphs are author text (the template does not check the wording). |
| MOWB-AC-003 | Fed. R. Bankr. P. 9004(a)-(b) (Cornell LII, `rule_9004`, subdivisions (a) and (b) only) | (a) Papers must be "clearly legible"; (b) a caption with the name of the court, the title of the case, the bankruptcy docket number, and a brief designation of the paper. | `court`, `title`, `adv_number`. Paper size and quality, subdivisions (c) and (d), were not retrieved (see gap 1). |
| MOWB-AC-004 | W.D. Mo. Bankr. L.R. 17004-1(A) (2012 text, see gap 1) | Adversary captions carry the debtor's name, case number, chapter and judge assignment, plus the plaintiff, the defendant, the adversary case number once assigned, and the judge. | `debtor`, `case_number`, `chapter`, `judge`, `plaintiffs`, `defendants`, `adv_number`. |
| MOWB-AC-005 | W.D. Mo. Bankr. L.R. 9011-4 (2012 text) | Pleadings filed by an attorney carry the signature in the attorney's individual name with: name, bar number, firm name, address, telephone number, fax number, and e-mail address. | `signature` (`firm`, `signer`, `bar`, `lines` = address, telephone, fax, e-mail, `role`). All fields are required by the template. |
| MOWB-AC-006 | W.D. Mo. Bankr. L.R. 9013-3 (2012 text) | "Each pleading shall have a signed certificate of service at the end of the pleading or on a separate, captioned certificate, stating: the manner and date of service, and each person served." A pleading without a proper certificate may be stricken. | `certificate` (date and manner are required; the signature is generated). The "each person served" part is given by the manner text (CM/ECF notice to registered parties). |
| MOWB-AC-007 | W.D. Mo. Bankr. L.R. 17004-1(C), (E) (2012 text) | The clerk prepares the summons; the filing fee is paid at filing by cashier's check, money order or cash. | Not generated. These are separate papers and payment steps. |

Not produced by this template (separate filings, not part of the complaint): the summons (clerk-prepared, L.R. 17004-1(C)); the adversary proceeding cover sheet (believed to be Official Form 104; not verified); the filing fee (L.R. 17004-1(E)). A W.D. Mo. adversary complaint has no table of contents or table of authorities requirement in the rules I could read.

## Layout

- Letter paper, 1 inch margins on all sides, no line numbers (no W.D. Mo. rule requires them; neither exemplar has them).
- Court title (two lines), centered, capitals, then the division in parentheses if the frontmatter gives one (Barnhart, 2014, prints "(KANSAS CITY)"; the Carlson sample has none, as the exemplar).
- Caption as one row per line: a party column, a closing ")" column, and a right column for the case number, chapter, judge and adversary number. Each row has a fixed height, so the ")" marks line up. Blank rows hold a space (an empty cell has no height).
- Document title, bold and centered, under the caption.
- Body double-spaced, one full line pitch (24 pt) between lines and between paragraphs. Paragraphs numbered 1, 2, ... from the first heading on (Fed. R. Civ. P. 10(b)); the lead-in before the first heading and any paragraph beginning WHEREFORE are unnumbered.
- Level-1 headings: bold, centered, capitals, unnumbered. Level-2 headings: bold, roman numerals (I., II., ...), counted continuously.
- Markdown lists are lettered (a), (b), ... (the prayer for relief and the lists of documents).
- Page number centered at the foot.
- Signature block after the prayer (right half of the page), with "Dated:" on the left. Certificate of service last, with the signature line.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court` (list of lines), `division` (optional), `debtor`, `case_number`, `chapter`, `judge` (optional), `plaintiffs` (list), `defendants` (list), `adv_number` (blank until assigned), `title`, `consent` (required, FRBP 7008(a)), `date` (optional), `signature` (`firm` list, `signer`, `bar`, `lines` list, `role`), `certificate` (`date`, `manner`).
- YAML pitfall: a value containing ` #` (for example `MO # 70041`) must be quoted, or YAML reads the `#` as a comment.
- Body: `# Heading` is a level-1 heading; `## Heading` is level 2 (roman numbered). Blank-line-separated paragraphs. `1.` items are lettered by the template. Case names in `*italics*`.
- Not supported: tables, footnotes, raw typst.

## Overlay

`sh tools/overlay.sh courts/eighth-circuit/missouri/federal/bankruptcy-western-district/adversary-complaint enterprise-carlson-complaint`. Pages are paired by word overlap (the first exemplar in `usage/`, which is Carlson). The page map from the final run (`usage/OVERLAY-enterprise-carlson-complaint.txt`): ours p.1 to p.7 pair with filed pp. 1, 2, 4, 5, 6, 8 and 9 (word overlap 53% to 85%); ours p.8 to p.10 pair with filed p.34 and p.35 (63.9%, 58.9% and 26.8%), because the sample's Count XI and prayer come from the end of the filing. The page pairing is by word overlap, so it is coarse. The overlay is a diagnostic, not a score. The visible differences are tier-3 ones: the Carlson filing is in a different typeface (ours was then EB Garamond), its paragraph numbers are not ours, and the sample omits most of its text.

## Gate 2 review (the 2026-10-14 EB Garamond PDF, every page rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, division, caption, title, lead-in, consent statement, Introduction 1-2 | OK. Caption rows aligned; the party column is 3.8 in wide so "METROPOLITAN COMMUNITY COLLEGE" would fit (checked on the memorandum sample). Consent statement printed as an unnumbered paragraph after the lead-in (placement is a convention). |
| 2 | Introduction end, Parties, Factual Allegations I, paragraphs 8-10 | OK. Body double-spaced, paragraphs indented. |
| 3 | Paragraphs 11-15 | OK. |
| 4 | Paragraphs 16-18 with the lettered list (a)-(e) | OK. The list is indented and its items line up. |
| 5 | Paragraphs 19-25, headings II and III, list (a)-(g) | OK. Heading numbers and text on one line. |
| 6 | List (a)-(j) of promissory notes, paragraphs 26-27 | OK. |
| 7 | List (a)-(h) of security agreements, paragraphs 28-32 | OK. |
| 8 | Paragraphs 33-39, the COUNT XI heading (five lines, caps) | ACCEPTED: the long count title is set as one centered heading; a clerk would not object. |
| 9 | Paragraphs 40-41, Prayer for Relief, lettered list, Dated line, signature block | OK. Signature block right half, left-aligned lines, fax and e-mail present. |
| 10 | Certificate of Service alone on the last page | ACCEPTED: the certificate does not fit under the signature on page 9 and is kept whole. |

## Known gaps and open choices

1. **Rule text is not the current one.** The W.D. Mo. bankruptcy local rules I could read are the 2012 text ("Adopted November 30, 2012, effective January 1, 2013", `mow.uscourts.gov/sites/mow/files/BK_Archive_bk_rules.pdf`). The older 2003 text (`BK_Archive_local_rules_of_practice.pdf`) has the same 9011-4, 9013-3 and 17004-1 wording. The 2019 proposed amendments (`2019-BK-Proposed-LR-Amendments.pdf`) redirect and were not read. Whether these rules were amended after 2013 is **not verified**. The court's current local rules page was not reachable (mow.uscourts.gov pages returned 403/404 to the fetch tool). **David or the PM should check the current W.D. Mo. bankruptcy local rules before this template is treated as final.** The FRBP text is from Cornell LII, which is the current federal text as posted, but Rule 9004 subdivisions (c) and (d) (paper size and quality) were not retrieved, so the template asserts no paper-size rule.
2. **Type face and size.** No W.D. Mo. or FRBP rule sets a font or type size for a complaint that I could read. The exemplars use Times New Roman (embedded in Carlson, Lewallen and Barnhart). Re-checked 2026-10-14: the W.D. Mo. bankruptcy rules page on courtrules.net returned 403 and a web search did not reach the court's own text, so no typeface rule was found for this court. The template sets Times New Roman 12 pt, the house standard (`docs/FONTS.md`, rule 6) and the exemplars' face and size; it was EB Garamond at 13 pt (about Times 12 pt by apparent size) before. This is a tier-2 choice.
3. **Double spacing and margins** follow the Carlson exemplar (tier 2). No rule requires them.
4. **Judge.** L.R. 17004-1(A) requires the judge assignment in the caption. Carlson's caption shows no judge. The sample's judge, Honorable Cynthia A. Norton, is inferred from the case-number suffix "-CAN" (the same suffix as the 2013 Barnhart case, whose caption names her). It is not printed on the Carlson exemplar, so it is an inference and the sample says so here.
5. **Fax number.** Carlson's signature block has a facsimile line; the template requires one by L.R. 9011-4 (2012 text).
6. **The sample is a portion.** It transcribes Carlson paragraphs 1-11 and 14-23, 30-37 and 39, the Count XI paragraphs 203-210, the prayer and the signature block. Omitted: paragraphs 12-13 and 24 (cut or only partly legible in the text layer), 25-29, and 38 (the sentence is cut in the text layer), and most of the factual section. The paragraph numbers in the sample are the template's, starting at 1, so they do not match the filing (the overlay shows this). The render is 10 pages, which is within the brief's 8-14 page target for an exemplar of this length.
7. **Transcription.** The exemplar's printed errors are kept (for example "judgement", "case Enterprise", "guarantied", "Amendments" for "Amendment", and the unbalanced parenthesis in the definition of the Pinnacle Security Agreements). They are visual fidelity, not checked content.
8. **Second filer is not overlaid.** Standley (2019) is kept for the tier-2 comparison. Its body is in a different face (Liberation Sans/Helvetica), so it was used for the caption and the "COMPLAINT" heading only.
9. **Certificate of service.** Required by L.R. 9013-3. Carlson has one (CM/ECF notice). Standley (7 pages) has none in its text layer.
10. **Not checked by the template.** The jurisdiction and core-proceeding paragraphs are author text. The template checks only that a consent statement is present, not what it says. Whether the complaint must also plead the case's name, number and chapter in the jurisdiction paragraph (FRBP 7008(a)) is a matter for the author; the caption carries them.
11. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` are for court folders with `court.json` and `rules.md`, which a doc-type folder does not have. The brief forbids running `tools/tracker.sh`. Render, overlay and the page review are the checks run here.
12. **Searches.** CourtListener RECAP (`type=r`, `court=mowb`), queries "adversary proceeding" complaints: Carlson (25-04017), Standley (19-03015), Rose (04-06024, a 5-page dischargeability complaint in Helvetica, not saved), American Trailer & Storage (09-04156, not saved), Farmland Industries (04-04322, not saved). govinfo (`USCOURTS-mowb`) holds opinions and orders, not party complaints. The W.D. Mo. court website (mow.uscourts.gov) returned 403/404 to the fetch tool.

## Engines

- **typst** (primary, `typst/`): the reference for this doc type. Unchanged by the docx work.
- **docx** (`docx/`): `reference.xml` (from which `fb render` builds the reference document on the shared cross-engine recipe: styles, US Letter, 1 inch margins, centred PAGE footer; `docx/make-reference.sh` built a committed `reference.docx` until fb-595.68) and `mowb.lua` (caption, numbering, lettered lists, signature block and certificate). Output: `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (`sh tools/render.sh --engine docx <this folder> usage/INPUT-adversary-complaint.md`).
  - **Matches typst:** US Letter, 1 inch margins, Times New Roman 12 pt (the declared face; a machine without it substitutes silently), caption rows with the ")" column, numbered paragraphs 1 to 42 with WHEREFORE unnumbered, lettered (a), (b) lists, headings I., II. (continuous), the consent statement before the first heading, the signature block with "Respectfully submitted," and the certificate of service.
  - **Differs from typst** (measured on the earlier EB Garamond build, before fb-595.68; both engines are 11 pages now): the body is set at an exact 24 pt line pitch with 15.6 pt between paragraphs, which reads looser than the typst body. The Carlson sample is 12 pages in docx and 10 in typst. The signature block is kept together (`keepNext`), so it moves to page 12 with the certificate.
  - **Checked** (on the earlier EB Garamond build): the `.docx.pdf` is the LibreOffice 26.8.1 conversion (fonts embedded: EB Garamond only). Every page (1-12) was rendered at 60 dpi and viewed beside the typst pages. The `.docx` was not opened in Word.
  - **BLOCKED** (then; the committed `usage/.check-docx.txt` now reads PASS): `tools/check.sh --engine docx` had not been run. This folder has no `court.json` or `rules.md`, so Gates 0-3 are not run here and no `.check-docx.txt` stamp is written.
