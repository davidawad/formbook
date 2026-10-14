# W.D. Oklahoma (Bankr.), okwb: adversary complaint

- Court: `okwb`, United States Bankruptcy Court, Western District of Oklahoma (`courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district/`)
- Doc type: `adversary-complaint`. Complaint commencing an adversary proceeding (Fed. R. Bankr. P. 7001(f), dischargeability of a debt).
- Exemplar: `exemplars/FILED-EXAMPLE-ruzycki-26-01003-adversary-complaint.pdf` (*Ian's Enterprise, LLC v. Ruzycki*, Bankr. W.D. Okla. adv. no. 26-01003, filed 2026-01-26; provenance in `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-ruzycki-adversary-complaint.md` (the filed complaint transcribed in full; 12 filed pages).
- Status: template and sample render, overlay, and page review done (pages below). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `okwb-adversary-complaint`. |
| `typst/okwb-adversary-complaint.typ` | Template. Parameter block at the top: `font-family`, `type-size` (12 pt), `page-margin` (1 in), `body-leading` (0.695 em, so the 24 pt double-spaced pitch), caption columns. |
| `samples/INPUT-ruzycki-adversary-complaint.md` | Markdown contract sample (frontmatter: caption rows, lead-in, signature lines, approval line; body: numbered paragraphs, `#` headings, `- ` lettered items, `> ` unnumbered paragraphs). |
| `samples/OUTPUT-ruzycki-adversary-complaint.pdf` | `sh tools/render.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district/adversary-complaint samples/INPUT-ruzycki-adversary-complaint.md` (10 pages, EB Garamond only). |
| `samples/OVERLAY-ruzycki-adversary-complaint.pdf`, `.txt` | `sh tools/overlay.sh <doc-type dir> ruzycki-adversary-complaint` (red = ours, blue = filed, black = agree). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Each rule was read from the text linked below. The local rules were downloaded and read on 2026-10-14; the federal rules on the same day from the Cornell LII pages.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LR 9004-1.A (W.D. Okla. Local Bankruptcy Rules, General Order 26-01, effective 2026-01-15; <https://www.okwb.uscourts.gov/sites/okwb/files/Local_Rules.pdf>, rule at printed p. 49) | Documents 8½ × 11 in; at least 12-point type, footnotes included; margins at least 1 in; double spaced unless one page; one side only; no color; white paper | `type-size = 12pt`, `page-margin = 1in`, `body-leading` (double spacing), `paper: "us-letter"`, the footer page number |
| LR 9004-1.D (same) | The signature block conforms with the filer's CM/ECF profile: full name, state bar number, address, email, telephone, fax if any, and the party represented, beneath the signature line | `signature` (the lines come from `signature.lines` in the sample) |
| LR 9004-1.F (same) | A filer using a post office box must also list a physical street address | the sample's signature block gives the street address; the template does not check for a PO box |
| LR 7003-1 (same, printed p. 40) | An adversary complaint is accompanied by a cover sheet, as the last page of the complaint, unless the complaint is filed electronically (no cover sheet then) | no cover sheet produced. The exemplar (ECF filing) has none |
| LR 7040-1 (same, printed p. 44) | Adversary complaints are assigned to the judge of the related bankruptcy case | none (no assignment text in the complaint); recorded here so the reviewer knows the rule was read |
| Fed. R. Bankr. P. 7001(f) (<https://www.law.cornell.edu/rules/frbp/rule_7001>, text checked 2026-10-14) | "a proceeding to determine whether a debt is dischargeable" is an adversary proceeding | the first cause of action headings in the sample (§ 523) |
| Fed. R. Bankr. P. 7008(a) (<https://www.law.cornell.edu/rules/frbp/rule_7008>, checked 2026-10-14; as amended eff. 2024-12-01) | Fed. R. Civ. P. 8 applies. The complaint must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court; the jurisdiction allegation refers to the case's name, number and chapter, and the district and division | paragraphs 3 to 5 of the sample (the filer's words, as filed; see Known gaps) |
| Fed. R. Bankr. P. 7010 (<https://www.law.cornell.edu/rules/frbp/rule_7010>, checked 2026-10-14) | Fed. R. Civ. P. 10 applies in an adversary proceeding, except the caption must substantially conform to Official Form 416 | `caption` (the party column, the `)` column, the case number and adversary number rows) |
| Fed. R. Bankr. P. 9004(a)-(b) (<https://www.law.cornell.edu/rules/frbp/rule_9004>, checked 2026-10-14) | Legible; caption with the court's name, the case title, the case number and adversary number, and a brief designation of the document | the cover (court name, caption, title in capitals) |
| Fed. R. Civ. P. 10(b) (applies through 7010; not separately fetched) | Claims in numbered paragraphs | `allegations`: the template numbers each plain paragraph; `> ` paragraphs and headings are unnumbered |

## Overlay

`samples/OVERLAY-ruzycki-adversary-complaint.pdf` puts our render (red) over the best-matching filed page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run:

- Sample p.1 ↔ filed p.1 (76%), p.2 ↔ p.2 (66%): cover and caption, and the first numbered paragraphs.
- p.3 ↔ p.4 (59%), p.4 ↔ p.5 (66%), p.5 ↔ p.6 (75%), p.6 ↔ p.7 (75%): body paragraphs and lettered lists line up with the same passages.
- p.7 ↔ p.8 (48%), p.8 ↔ p.10 (55%): weaker pairings; these pages carry the lettered items, whose line breaks differ from the filed page.
- p.9 ↔ p.11 (85%): cause-of-action headings.
- p.10 ↔ p.12 (69%): the end of the WHEREFORE paragraph, signature and "Approved by:" block.

## Page review (Gate 2)

Every page of `OUTPUT-ruzycki-adversary-complaint.pdf` was rendered at 60 dpi and viewed (10 of 10). Typst printed no warnings. Fonts embedded: EB Garamond only.

| Page | Content | Result |
|---|---|---|
| 1 | Court title, caption, COMPLAINT, paragraphs 1-8 | OK. Caption rows separate; `)` column on every row. |
| 2 | Paragraphs 9-17 | OK. |
| 3 | Paragraphs 18-28 | OK. |
| 4 | Paragraphs 29-37 (37 introduces lettered items) | OK. |
| 5 | ¶ 37(a)-(d), ¶¶ 38-42 with lettered items | OK after the fix below. |
| 6 | ¶¶ 43-45(c) with lettered items | OK after the fix below. |
| 7 | ¶ 45(d) to ¶ 53 with lettered items | OK after the fix below. |
| 8 | ¶¶ 54-62 | OK. |
| 9 | Heading and count 1 (§ 523(a)(2)(A)), count 2 (§ 523(a)(2)(B)), count 3 (§ 523(a)(6)), ¶¶ 63-68, start of WHEREFORE | OK. Headings keep the statute's lowercase subsections. |
| 10 | End of WHEREFORE; "Respectfully Submitted" signature block; "Approved by:" line | ACCEPTED: the WHEREFORE paragraph runs two lines onto p.10, so the page is mostly blank below the signature block. |

Fixes made in this pass, found on page review, before the final render: (1) the template passed `measure(width: 100%)`, which typst 0.15 rejects, so `on-grid` now measures against the layout width; (2) the caption and lettered-list lines overlapped, because the line box was not set from ascender to descender; `top-edge`/`bottom-edge` are set, and `body-leading` is 0.695 em, so the double-spaced pitch is 24 pt (measured on p.5 with `pdftotext -bbox`); (3) `upper()` turned "§ 523(a)(2)(A)" into "§ 523(A)(2)(A)"; `heading-caps` uppercases only the text before "§".

## Known gaps

1. One exemplar, one filer (Blackwood Law Firm, for the plaintiff). A second filed complaint from a different filer is needed to judge the conventions a clerk expects (tier 2) against more than one filing. Not yet found.
2. The filed complaint's body is Times New Roman (embedded); our render is EB Garamond. The local rules require only 12-point type (LR 9004-1.A), so the face is a tier-2 choice, not a rule. EB Garamond is the vendored serif; Times New Roman is not vendored.
3. The filed complaint is 12 pages; ours renders 10. The difference is line breaking and list layout, not omitted text: the sample is a full transcription.
4. The caption follows Official Form 416 only in general shape (Fed. R. Bankr. P. 7010). The text of the form itself has not been checked against the template.
5. The filed jurisdiction paragraph (¶ 3, "28 U.S.C. § 1334 and 28 U.S.C. § 157") does not state the case name, number and chapter that Fed. R. Bankr. P. 7008(a) requires. That is the filer's text, transcribed as filed; the template does not check for it. Flagged for the reviewer, not corrected.
6. The sample's ¶ 23 and the caption disagree on the bankruptcy case number (26-13369 and 25-13369). Transcribed as filed; the sample's frontmatter notes it.
7. No cover sheet is produced: LR 7003-1 requires one only for paper filings. A paper version would need a cover sheet as the last page.
8. The PO-box rule (LR 9004-1.F) is not checked by the template.
9. No page or word limit was checked for this document type.
