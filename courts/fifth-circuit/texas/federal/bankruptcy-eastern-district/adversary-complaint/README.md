# txeb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding) in the United States Bankruptcy Court for the Eastern District of Texas (`txeb`), Sherman Division as transcribed.
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-lrk-96-simpson-25-04019-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-lrk-96-simpson-complaint.md` (the whole 15-page filing, text transcribed, paragraph numbers left to the template) |
| render | ok: `samples/OUTPUT-lrk-96-simpson-complaint.pdf`, 13 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-lrk-96-simpson-complaint.pdf` and `OVERLAY-lrk-96-simpson-complaint.txt` (page map) |
| pages reviewed | 13 of 13 (every page rendered at 60 dpi and viewed after the last template change) |

Gate files: none (this doc type has no `court.json` or `.check-*` stamp; the court-level gates belong to the court folder, not this folder).

## Governing rules

Each row was read from the text of the rule, fetched 2026-10-14. The local rules are the most recent copy the court publishes that I could read.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, as amended eff. 2024-12-01; fetched 2026-10-14) | Civil Rule 10 applies to a pleading in an adversary proceeding; the caption must substantially conform to Official Form 416 (the version for a complaint). | `caption()`, `caption-rows()`; the Form 416 layout was not fetched, so the caption follows the filed exemplar and LBR 7010-1, not the form itself. |
| Fed. R. Bankr. P. 9004(b) (same source; fetched 2026-10-14) | Caption: (1) the court's name; (2) the case's title; (3) the case number and, if appropriate, the adversary number; (4) a brief designation of the document. | `court-title()` (line 1 to 3), `caption()` (case number and adversary number), `title` (designation). |
| E.D. Tex. LBR 7010-1 (Local Rules, "Revised: December 1, 2017", https://www.txeb.uscourts.gov/sites/txeb/files/2017%20TXEB%20Local%20Rules_clean_rev%2012-1-17.pdf; fetched 2026-10-14) | Caption identifies: (1) the district and division; (2) the style of the case with the debtor's name, address, last four digits of the TIN, case number and chapter; (3) the plaintiffs and defendants; (4) a space for the adversary number; (5) a descriptive title. | `court-title()` (district, division from `division`); `caption-rows()` (chapter, debtor, address, last four digits of TIN as a fill-in if not supplied, parties, adversary space); `title`. |
| Fed. R. Civ. P. 10(b) (https://www.law.cornell.edu/rules/frcp/rule_10; the text "single set of circumstances" was confirmed on 2026-10-14) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `complaint-body()` numbers each body paragraph; headings and block quotations are not numbered. |
| E.D. Tex. LBR 7007-1 and 9013-1 (same 2017 PDF) | Not applicable to the complaint: the 14-day negative notice belongs to motions in adversary proceedings (see `../motion-brief/README.md`). LBR 9013-1(e) (certificate of service) is written for motions and other papers. The filed complaint has none, and the rules read here do not settle whether a complaint needs one (service is by summons under FRBP 7004, which is not produced here). | Not in this template. |

No font, type size, margin, paper, or spacing rule was found in FRBP 7010, FRBP 9004, the 2017 local rules (LBR 7010-1, 9004-1), or the Court's Guide to Practice (as of 8-22-22, https://www.txeb.uscourts.gov/sites/txeb/files/GUIDE_Prac_Proc_TXEB_as%20of%208-22-22.pdf). The template's choices for those are: EB Garamond 12 pt (the only vendored font), 1-inch margins, letter paper, double spacing, and a `§` caption column. Double spacing and the caption layout follow the filed exemplar (checked by the overlay). Numbered pleading paper is not used: the filed exemplar does not use it and no rule read here requires it.

## Layout

- Caption: court title, then a grid of single-spaced rows: "IN RE:", the debtor's names, the address (LBR 7010-1(2)), the last four digits of the TIN (fill-in `____`), the party designations, "v.", and the adversary number beside "v.". The § column is drawn on every row.
- Title centered and bold in capitals.
- Body: double spaced. "# " headings are centered bold (roman-numeral sections); "## " headings are bold, indented (count headings). Numbered paragraphs use a 0.5-inch first-line indent. "> " block quotations are single spaced and indented both sides. "- " items are the prayer. "~ " is an unnumbered paragraph (the lead-in).
- Signature block: "Dated" at left, the signer's block at right (`<<signature>>` marks its place).
- Footer: title in capitals and "PAGE n OF N".

## What the overlay shows

`OVERLAY-lrk-96-simpson-complaint.pdf`: red is our render (`OUTPUT-lrk-96-simpson-complaint.pdf`), blue is the filed page, black is where they agree. Pages are paired by shared words, so the map in `OVERLAY-lrk-96-simpson-complaint.txt` pairs our page 1 with filed page 1, and later pages drift by one or two pages because our render has fewer lines per page than the filing (13 pages against 15). The word-overlap figures (50% to 86%) are a diagnostic, not a score. The visible differences are the typeface (EB Garamond against Times New Roman), the body's line length, and the footer's small capitals.

## Page review (Gate 2 equivalent; 13 of 13 pages)

| Page | Result |
|---|---|
| 1 | Court title on three centered lines; caption rows aligned; § column unbroken; "COMPLAINT" centered; Parts I and II start with numbered paragraphs 1 to 3. Pass. |
| 2 | Paragraphs 4 to 8; footnote 1 inline in brackets. Pass. |
| 3 | Paragraphs 9 to 14; the Part III heading is at the top of the page. Pass. |
| 4 | Paragraphs 15 to 21; no heading at the foot of a page. Pass. |
| 5 | Paragraphs 22 to 26; Part IV and "A. Count 1" headings; the heading is kept with its paragraph. Pass. |
| 6 | Paragraphs 27 to 31; case-name italics and the quoted passages. Pass. |
| 7 | Paragraphs 32 to 39; "B. Count 2". Pass. |
| 8 | Paragraphs 40 to 49; block quotation for TUFTA § 24.005(a)(1), single spaced, indented. Pass. |
| 9 | Paragraphs 50 to 57; block quotation for TUFTA § 24.005(a)(2). Pass. |
| 10 | Paragraphs 58 to 66; "G. Count 7" heading kept with its paragraph; block quotation for § 523(a)(2)(A). Pass. |
| 11 | Paragraphs 67 to 72; block quotation for § 523(a)(4). Pass. |
| 12 | Paragraphs 73 to 78; "I. Count 9" heading and block quotation for § 523(a)(6). Pass. |
| 13 | Part V (prayer items (i) to (vii)); signature block with "Dated" at left. Pass. |

Paragraph 14 is cross-referenced in paragraphs 47 and 53 of the filing ("the Acuity Transfers referenced in paragraph 14"); the template's numbering puts the Acuity Transfers at paragraph 14 too, so the cross-reference holds.

## Known gaps and open choices

1. **One exemplar only.** Tier 2 asks for two or three filers. A second txeb complaint was found and not saved or overlaid: *DEJ Partners, LLC v. Ralls*, Adv. No. 24-06047 (Doc 1, 26 pages, filed by Steven Rech, 2024-11-25; https://storage.courtlistener.com/recap/gov.uscourts.txeb.206128/gov.uscourts.txeb.206128.1.0.pdf). Tier 2 is therefore not judged against two filers yet.
2. **Typeface.** The exemplar is Times New Roman. The template uses EB Garamond, the only font vendored in `fonts/` (the brief forbids new fonts and system fonts). EB Garamond's x-height is smaller, so the text looks smaller than the exemplar at the same point size.
3. **Debtor's TIN.** LBR 7010-1(2) requires the last four digits of the debtor's TIN in the caption. The filed exemplar shows neither the TIN nor the address, so the sample has a blank TIN fill-in and takes the address from the complaint's paragraph 4 (the defendant-debtor's residence). The template prints the fill-in blank; it does not invent a value. A filer must supply the TIN.
4. **Footnotes.** The template has no footnote support. The filed footnotes (1 to 5) are placed in brackets at their reference points in the sample ("[fn. 1: ...]"). The filed layout puts them at the foot of the page.
5. **ECF header.** The "Case 25-04019 Doc 1 Filed ..." stamp at the top of each filed page is added by the court's system and is not reproduced.
6. **Companion filings not produced:** the summons (FRBP 7004), the Adversary Proceeding Cover Sheet (Official Form 1040 as the court requires), and any Rule 7.1 disclosure. Each may be required with the first filing.
7. **Local rules version.** The 2017 local rules are the newest copy I could read; the court's website may have a later revision. The 14-day negative notice text (used in `../motion-brief`) matches the 2017 rule and the 2022 Guide's adversary-practice references, but the current rule should be checked before filing.
8. **Length.** The sample transcribes the whole filing. The template runs to 13 pages against the exemplar's 15; the difference comes from the typeface and the line metrics, not from missing text.

## Searches tried (exemplar)

CourtListener RECAP search with `court=txeb`, `type=r`, queries "adversary proceeding complaint" and "motion to dismiss memorandum adversary" (2024 to 2026 filings first, then earlier). The first complaint with a text layer and a complete body was LRK-96 LLC v. Simpson (25-04019). DEJ Partners (24-06047) is the second candidate, listed above.
