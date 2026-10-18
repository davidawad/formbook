# txeb: motion brief (motion with argument and authorities)

Doc type: **motion with argument and authorities** in an adversary proceeding (FRBP 9013 motion; the argument and authorities are in the same document, as the filed exemplar has them) in the United States Bankruptcy Court for the Eastern District of Texas (`txeb`), Sherman Division as transcribed.
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole 8-page filing, transcribed; paragraph numbers left to the template) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 7 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-ballout-wisner-motion.pdf` and `OVERLAY-ballout-wisner-motion.txt` (page map) |
| typeface | face required: none (the 2022 E.D. Tex. Bankr. local rules name no typeface; checked 2026-10-14). Font: EB Garamond (vendored, kept). No substitute applies. |
| pages reviewed | 7 of 7 (every page rendered at 60 dpi and viewed after the last template change) |

Gate files: none (this folder has no `court.json` or `.check-*` stamp).

## Governing rules

Each row was read from the text of the rule, fetched 2026-10-14. The local rules are the most recent copy the court publishes that I could read.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013, as amended eff. 2024-12-01; fetched 2026-10-14) | A request for court action must be made by motion, except where the rules provide an application or the request is made at a hearing. | The document is a motion (`title`); the template does not check the rule's other parts. |
| Fed. R. Bankr. P. 7010 (same source as above; fetched 2026-10-14) | Civil Rule 10 applies in an adversary proceeding; the caption must substantially conform to Official Form 416 (the version for other papers). | `caption()`, `caption-rows()`. The form itself was not fetched; the caption follows the filed exemplar and LBR 7010-1. |
| Fed. R. Bankr. P. 9004(b) (fetched 2026-10-14) | Caption: the court's name; the case's title; the case number and, if appropriate, the adversary number; a brief designation of the document. | `court-title()`, `caption()`, `title`. |
| E.D. Tex. LBR 7007-1 (Local Rules, "Revised: December 1, 2017", https://www.txeb.uscourts.gov/sites/txeb/files/2017%20TXEB%20Local%20Rules_clean_rev%2012-1-17.pdf; fetched 2026-10-14) | Motions in adversary proceedings are governed by LBR 9004, 9007 and 9013. Except for the listed motions (summary judgment, preliminary injunction, temporary restraining order, quash, protective order, default judgment), a motion in an adversary proceeding must contain the 14-day negative notice "which must appear as presented and be located in the motion text — preferably on the initial page". | `negative-notice()`: the rule's text is printed verbatim as the first item after the title (`negative_notice: true` by default). |
| E.D. Tex. LBR 7010-1 (same PDF) | Caption: the district and division; the style of the case with the debtor's name, address, last four digits of the TIN, case number and chapter; the plaintiffs and defendants; a space for the adversary number; a descriptive title. | `caption-rows()`: as for the complaint. The sample has no address or TIN (blank fill-ins). |
| E.D. Tex. LBR 9004-1(a), (b), (c) (same PDF) | Caption identifies the district and division, the debtor's name, address and last four digits of the TIN, the case number and chapter. The title must designate the relief sought "in the motion and proposed order". One form of relief per motion (with listed exceptions). | Caption as above; `title`. A motion to dismiss seeks one form of relief. |
| E.D. Tex. LBR 9013-1(a), (b), (d), (e) (same PDF) | (a) the motion must contain all required information, including negative-notice language; (b) **a proposed order with a title that describes the relief must accompany the motion; a missing proposed order may result in dismissal**; (d) personal identifiers redacted; (e) a certificate of service showing the parties served (with addresses), the method, the date, and signed by an attorney. | `motion-body()` prints the certificate when the sample has one (`# CERTIFICATE OF SERVICE` with `~|` and `~>` lines). The proposed order is **not produced** by this template (see gap 1). The sample has no personal identifiers. |

No font, type size, margin, paper, or spacing rule was found in FRBP 9013, FRBP 9004, FRBP 7010, the 2017 local rules, the 2022 local rules (LBR 9004-1, "Revised: August 22, 2022", https://www.txeb.uscourts.gov/sites/txeb/files/2022%20LOCAL%20RULES_rev%20as%20of%208-22-22.pdf; read 2026-10-14: no typeface, point size or paper size for a pleading), or the Court's Guide to Practice (as of 8-22-22, https://www.txeb.uscourts.gov/sites/txeb/files/GUIDE_Prac_Proc_TXEB_as%20of%208-22-22.pdf). The template's choices: EB Garamond 12 pt (the only vendored font), 1-inch margins, letter paper, double spacing (as the exemplar is double spaced), and a centered page number at the foot.

## Layout

- Court title, caption (as for the complaint), then the title of the motion, centered and bold.
- The 14-day negative notice: a bold heading "14-DAY NEGATIVE NOTICE – LBR 7007:" followed by the rule's text, single spaced, before the body.
- Body: double spaced. Numbered paragraphs (1, 2, ...) with a 0.5-inch first-line indent; unnumbered "~ " paragraphs (the opening "COMES NOW" and the closing request); "# " centered bold headings (BACKGROUND FACTS, STANDARD, ARGUMENT AND AUTHORITIES); "## " bold flush-left sub-headings (unused); "> " block quotations (single spaced, indented 0.75 inch both sides); "- " relief items.
- Signature: `<<signature>>` marks the place; "Dated" at left, the firm and the signer at right.
- Certificate of service: `# CERTIFICATE OF SERVICE`, then "~" text, "~|" addresses (flush left) and "~>" signature (right half).

## What the overlay shows

`OVERLAY-ballout-wisner-motion.pdf`: red is our render, blue is the filed page, black is where they agree. Pages are paired by shared words; the map in `OVERLAY-ballout-wisner-motion.txt` pairs our pages 1 to 4 with filed pages 1 to 4, our page 5 with filed page 6, our page 6 with filed page 7, and our page 7 with filed page 8. Filed page 5 has no render page paired with it by word overlap; our page 5 pairs with filed page 6. The word-overlap figures (44% to 85%) are a diagnostic, not a score. The visible differences are the typeface, the line length, and the caption's blank fill-ins (the filed caption has no addresses or TINs).

## Page review (Gate 2 equivalent; 7 of 7 pages)

| Page | Result |
|---|---|
| 1 | Court title; caption with "Chapter 7", "Case No. 21-41120", "Adv. Proc. No. 21-04121"; the title; the 14-day negative notice (verbatim, bold heading); "COMES NOW" lead-in; paragraph 1. Pass. |
| 2 | Paragraphs 2 to 6; "BACKGROUND FACTS" heading kept with paragraph 2; block quotation of the relief in paragraph 6 (its paragraphs separated). Pass. |
| 3 | Paragraphs 7 to 11; the relief items 1 to 6 (single spaced, indented; list numbers escaped in the sample). Pass. |
| 4 | Paragraphs 12 to 16; "STANDARD" and "ARGUMENT AND AUTHORITIES" headings, the latter kept with paragraph 16. Pass. |
| 5 | Paragraphs 17 to 22; block quotation of Rule 4007(c) (paragraph 20). Pass. |
| 6 | Paragraphs 23 to 25; block quotation of Rule 15(c)(1)(A) (paragraph 23 and its quoted subparagraph); the closing request moved to page 7 with the signature (sticky). Pass. |
| 7 | Closing request; signature block with "Dated" at left and the firm at right; "CERTIFICATE OF SERVICE" heading, text, the counsel address and "/s/" line. Pass. |

## Known gaps and open choices

1. **No proposed order.** LBR 9013-1(b) requires a proposed order that describes the relief and that the motion be granted or denied, and says a missing proposed order may lead to dismissal. This template does not produce one. The exemplar is the motion document only (Doc 11); any proposed order is a separate docket entry, which was not downloaded. A proposed order template is needed before filing; it is not a tier-1 item for this folder but it is a required companion.
2. **Argument in the motion itself.** The exemplar has no separate memorandum; the authorities are inside the motion (paragraphs 15 to 25). The template follows the exemplar. If the court's practice requires a separate brief, that is a question for David.
3. **Typeface.** The exemplar is Times New Roman; the template uses EB Garamond (vendored, the only font in `fonts/`). The x-height difference is visible at the same point size.
4. **Debtors' address and TIN.** LBR 7010-1(2) and 9004-1(a) require the debtor's address and the last four digits of the TIN in the caption. The filed exemplar shows neither, so the sample has blank fill-ins ("Address: ____", "Last four digits of TIN: ____") for both debtors. The template does not invent values.
5. **Negative notice text.** The template prints the LBR 7007-1 text from the 2017 rule. The rule's exception list does not include a motion to dismiss, so the notice is required. The current rule should be checked before filing (see the complaint README, gap 7).
6. **Length.** The filed exemplar is 8 pages; the template renders the same text in 7 pages, because of the typeface and line metrics (not missing text).
7. **Footnotes.** The exemplar has none, so none are supported.
8. **Signature.** The "Dated" line and the firm block are in the sample's frontmatter; "By: /s/" is the signer's own line, as filed. The template does not supply signatures.

## Searches tried (exemplar)

CourtListener RECAP search with `court=txeb`, `type=r`: "motion to dismiss" with "memorandum" (2024 to 2026 filings first, then earlier). Candidates checked: BDO USA, P.C. v. JSCo Enterprises, Inc., Adv. No. 24-04087, Doc 13 (4 pages, Times New Roman, Sherman Division, filed 2025-01-27: a bare motion, no argument); Ballout Real Estate v. Wisner, Adv. No. 21-04121, Doc 11 (8 pages, filed 2022-02-25: the motion with argument and authorities; chosen). Two other results (Texas Farm Credit, 26-04060; Anderson v. Hardwick, 21-04065) were seen in search results and not downloaded.

## Engines

Typst is the primary engine (above). The docx engine is in `docx/`: `reference.docx` (built by `docx/make-reference.sh`), `txeb-motion-brief.lua` (the caption, court title, 14-day negative notice, signature block, certificate of service, allegation numbers) and `render.sh` (pandoc). Output: `usage/OUTPUT-motion-brief.docx`. The latex engine is not built for this folder.

- **Matches the typst form (built from the typst values; no docx page has been rendered or looked at):** EB Garamond 12 pt; letter paper with 1-inch margins; body double spaced at exact 24 pt; allegation numbers with a half-inch first-line indent and the text after a tab; the caption as a borderless table of exact 14.5 pt rows with the § column; the court title; the centered bold title; the 14-day negative notice text, verbatim, single spaced, before the body; the Roman headings centered and the sub-headings flush left; single-spaced block quotations and relief items indented 0.75 in; the signature block with "Dated" at the left and the signer from 3.25 in; the certificate of service with flush-left address lines and the right-half signature; a centered PAGE field in the footer.
- **Differs from typst:** pagination is set by Word and LibreOffice, not typst (not measured); the page number is a PAGE field; the "Dated" line uses a tab stop, not a grid; the docx has no bookmarks or tagged PDF.
- **docx BLOCKED:** the `.docx.pdf` checks cannot run here. LibreOffice (`soffice`) is not installable in this image (conda-forge has no LibreOffice package; no root, no apt), so `usage/OUTPUT-ballout-wisner-motion.docx.pdf` is not produced and Gates 0 to 3 on the docx PDF (`tools/check.sh --engine docx`) are BLOCKED. Gate 2 (every page rendered and looked at) is not done for the docx. The `.docx` opens with pandoc and is a valid zip of well-formed XML; it has not been opened in Word or LibreOffice. The proposed order (LBR 9013-1(b)) is not produced, as for the typst template.
