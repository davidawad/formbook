# S.D. W. Va. Bankruptcy Court (wvsb): motion (FRBP 9013)

Doc type: **motion with its supporting argument** (FRBP 9013 written motion, grounds stated with particularity). The exemplar puts the argument inside the motion; no separate memorandum of law from this court was found (see gap 1). Court: United States Bankruptcy Court for the Southern District of West Virginia. Folder: `courts/fourth-circuit/west-virginia/federal/bankruptcy-southern-district/motion-brief/`.

Status: exemplar=yes (two, from different filers), render=ok, overlay=ok, pages reviewed 14 of 14. Nothing here sets `court.json` status.

## Governing rules

Dates are the date each text was read (2026-10-14). Federal rule text comes from Cornell LII (current text, "eff. Dec. 1, 2024" restyling). The local rules are the court's 2012 edition (`wvsb.uscourts.gov/sites/wvsb/files/localrules.pdf`, 138 pp.); its currency is not confirmed (gap 5).

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| WVSB-FORM-001 | FRBP 9004(a) (verified, eff. 12/1/2024) | "A petition, pleading, schedule, or other document must be clearly legible." No paper-size rule found. | `typst` page `us-letter` (convention) |
| WVSB-FORM-002 | None found (S.D. W. Va. local rules 2012 ed., full text searched 2026-10-14 for typeface, font and point size: none) | No typeface or point size is set by rule, so the template keeps EB Garamond, 13 pt (`docs/FONTS.md`: "No face named"). A style choice. Vendored in `fonts/eb-garamond/`. | `font-family`, `type-size` |
| WVSB-FORM-003 | None found | Double spacing, as in the exemplar. Convention. | `line-pitch` = 24 pt |
| WVSB-FORM-004 | None found | 1-inch margins, as in the exemplar. Convention. | `margins` |
| WVSB-CAP-001 | FRBP 9004(b)(1)-(4) (verified) | Caption states the court's name, the case title, the case number and adversary-proceeding number (if any), and a brief designation of the document. | `court`, `caption`, `case_info`, `title` |
| WVSB-CAP-002 | LR 9004-2 (2012 ed.) | The caption identifies any other filed pleading to which the document relates. Not used here: this motion relates to no other paper. | `title` (none needed) |
| WVSB-MOT-001 | FRBP 9013(a) (verified) | A request for an order must be made by written motion, unless another rule authorizes an application or the request is made at a hearing. | Document form (motion) |
| WVSB-MOT-002 | FRBP 9013(b) (verified) | "A motion must state its grounds with particularity and set forth the relief or order requested." The template does not check content; the sample's ¶ 23 states the relief. | Sample (¶¶ 23–51) |
| WVSB-MOT-003 | FRBP 9013(b) (verified) | Service on the trustee or debtor in possession and on the entities the rules specify; if the rules do not say, the court designates. | Notice paragraph (¶ 52) in sample; certificate (WVSB-MOT-004) |
| WVSB-MOT-004 | LR 9013-1(a)(3) (2012 ed.); LR 9013-3 (2012 ed.) | Every motion carries a certificate of service that states the name and address of every party served and the method of service. "All creditors listed on the mailing matrix" may be recited if the matrix is attached. | `certificate` (template page 'Certificate of Service') |
| WVSB-MOT-005 | LR 9013-1(a)(1) (2012 ed.) | Every motion is filed with a proposed order granting the relief. | **Not generated** (separate paper). Gap 2. |
| WVSB-MOT-006 | LR 9013-1(a)(2), (c) (2012 ed.) | A "negative notice" is needed only for motions in default practice. The listed motions (compromise, sale, stay relief, redemption, lien avoidance, executory contracts) do not include this one. The list is "not limited to". | **Not generated.** Gap 3. |
| WVSB-MOT-007 | LR 9013-1(b) (2012 ed.) | All motions are served on the debtor and, if represented, the debtor's counsel. | Notice paragraph (¶ 52) in sample; not checked by template |
| WVSB-MOT-008 | LR 9013-1(f) (2012 ed.) | A request to shorten time or for expedited consideration is indicated in the caption. Not applicable here. | Not used |
| WVSB-CMP-005 | FRBP 9011(a) (verified, eff. 12/1/2024) | Signed by an attorney of record; "must state the signer's address and telephone number, if any." | `signature.blocks` |
| WVSB-CMP-006 | LR 9011-4 (2012 ed.) | Electronic signature: a scanned image, or `/s/` followed by the typed name. | `signature.blocks` (`/s/` lines) |

Not used, and why: FRCP 10 (which governs complaints under FRBP 7010) does not govern motions; the caption rule for motions is FRBP 9004(b). The 2020 Blackjewel Procedures Order (requires a notice of hearing as the first page of motions) is a case order, not a court rule; it is not applied (see gap 6).

## Exemplars

- `usage/SAMPLE-wvsb-motion-brief-blackjewel1930289doc1938.pdf`: 21 pages (15-page motion plus a 6-page Core/2002 service list). Doc. 1938, *In re Blackjewel, L.L.C., et al.*, Case No. 3:19-bk-30289 (Bankr. S.D. W. Va.), filed April 24, 2020 by the Official Committee of Unsecured Creditors (Whiteford, Taylor & Preston LLP). **The sample transcribes this one.** Text layer present.
- `usage/SAMPLE-wvsb-motion-brief-blackjewel1930289doc1196.pdf`: 10 pages (5-page emergency motion plus a 5-page proposed order). Doc. 1196, same case, filed October 7, 2019 by the debtors (Supple Law Office; Squire Patton Boggs). Used for the caption and title conventions, a second filer.
- Provenance, caveats and the searches tried are in `usage/SOURCE.md`.

## Sample

- `usage/INPUT-wvsb-motion-brief-blackjeweldoc1938.md`: transcribed from Doc. 1938. Caption and debtors footnote, title, opening paragraph, headings (Preliminary Statement through Notice), ¶¶ 1–52, footnotes 2–4 (in the body), the WHEREFORE clause (carried in the `closing:` key so it stays with the signature), the signature blocks.
- Certificate of service: **template-supplied, not in the exemplar.** The exemplar has none. The date and method are bracketed placeholders for counsel. The wording follows the exemplar's Notice paragraph (¶ 52).
- The template's `closing:` key holds the WHEREFORE clause. It is set in the same unbreakable block as the signature, so the signature never stands alone on a page.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/fourth-circuit/west-virginia/federal/bankruptcy-southern-district/motion-brief
sh tools/render.sh $D usage/INPUT-wvsb-motion-brief-blackjeweldoc1938.md   # -> usage/OUTPUT-wvsb-motion-brief-blackjeweldoc1938.typst.pdf
sh tools/overlay.sh $D blackjewel-doc1938 $D/usage/SAMPLE-blackjewel-19-30289-doc1938-motion-brief.pdf
```

- The overlay takes the exemplar explicitly. Without the third argument it picks the first PDF in `usage/` (doc1196), which is the wrong exemplar for this sample.
- `usage/OUTPUT-wvsb-motion-brief-blackjeweldoc1938.typst.pdf`: 14 pages (13 of motion, 1 certificate). Typst compiled with no warnings. Fonts: EBGaramond-Regular, -Bold, -Italic only (embedded).
- File names follow the tools (`OUTPUT-`, `OVERLAY-`); the brief's `<id>.pdf` and `<id>-overlay.pdf` names differ.
- Overlay pairing (ours → filed Doc. 1938): p.1–8 ↔ 1–8; p.9 ↔ 10; p.10 ↔ 11; p.11 ↔ 12; p.12 ↔ 13; p.13 ↔ 14; p.14 (certificate) ↔ 21, which is a service-list page with no counterpart (7.6%, expected). Word-overlap pairing is coarse; it is a diagnostic, not a score.

## Visual review (Gate 2 record: all 14 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtors; case no., joint administration, chapter, judge at right), title, opening paragraph, PRELIMINARY STATEMENT, debtors footnote | OK. |
| 2 | Preliminary statement (cont.), JURISDICTION AND VENUE ¶¶ 1–3, BACKGROUND ¶¶ 4–7 | OK. |
| 3 | ¶¶ 7–10, CURRENT STATUS, footnote 2 | OK. |
| 4 | ¶¶ 10–17, footnote 3 | OK. |
| 5 | ¶¶ 17–22, footnote 4 | OK. Page ends with white space: RELIEF REQUESTED moves to the next page with its text. |
| 6 | RELIEF REQUESTED ¶ 23, LEGAL BASIS ¶¶ 24–26, block quotations | OK. Quotations single-spaced and indented. |
| 7 | ¶ 26 (cont.) items, ¶¶ 27–29 | OK. |
| 8 | Heading A (numbered "A.", two lines), heading 1 ("1."), ¶¶ 30–32 | OK. Heading sizes match the body. |
| 9 | ¶¶ 33–37, heading 2 ("2.") | OK. |
| 10 | ¶¶ 38–42, heading B | OK. |
| 11 | ¶¶ 43–45, heading C | OK. |
| 12 | ¶ 45 (cont.), unnumbered "See, e.g." continuation, ¶¶ 46–48, heading D | OK. |
| 13 | ¶¶ 49–52, NOTICE, WHEREFORE, "Dated," both counsel blocks in two columns | OK. The WHEREFORE clause sits directly above the signature. |
| 14 | CERTIFICATE OF SERVICE (template-supplied; bracketed placeholders) | OK as layout. The placeholders must be completed before filing. |

Pages reviewed: 14 of 14. The first version had the signature block alone on page 14; the WHEREFORE clause was moved into the unbreakable block with the signature. Heading sizes were pinned to body size (Typst's defaults made them larger than the exemplar's).

## Known gaps and open choices

1. **No separate memorandum.** The brief names "motion with memorandum". The court's exemplars put the argument inside the motion, and no separately filed memorandum of law from this court was found. The template follows the exemplars.
2. **Proposed order (LR 9013-1(a)(1), 2012 ed.).** Every motion must be filed with a proposed order. Not generated: it is a separate paper.
3. **Negative notice (LR 9013-1(a)(2), (c)).** Not needed for the listed default-practice motions. The list is "not limited to", and whether a conversion motion needs one was not decided. Not generated.
4. **Certificate of service.** The exemplar has none. The certificate page is template-supplied with placeholder date and method. A certificate is required by LR 9013-1(a)(3) (2012 ed.), and whether the method is first-class mail, CM/ECF, or both is counsel's choice.
5. **Local rules currency.** The 2012 edition is the latest version I could read; the court's site was not reachable in full. A newer edition could exist and was not seen. No page limit or font rule for motions was found in either edition (the 1994 "Complete Package" has none either).
6. **Notice of Hearing.** The 2020 Blackjewel Procedures Order requires a notice of hearing on page 1 of motions. It is case-specific and not applied. Whether a court-wide form requires one was not verified.
7. **Typeface and spacing.** No rule sets them (FRBP 9004(a) requires legibility only). EB Garamond 13 pt double-spaced is a style choice. The exemplars use Times New Roman (`pdffonts`). Judge-specific standing orders were not checked.
8. **"(emphasis added)" markers.** The exemplar's emphasis is not visible in the text layer, so the sample keeps the marker and not the emphasis.
9. **Two exemplars, one case.** Both are from *Blackjewel*, the only case for which this court's filed motions were found. Tier 2 is judged against these two only.
10. **ECF header.** Each page of the exemplar has an ECF header (case number, filed and entered stamps). The template does not reproduce it, because the court system generates it.

## Engines

**docx** (`docx/`: `build-reference.sh` makes `reference.docx`; filter `wvsb-motion-brief.lua`; measured on the LibreOffice PDF, `usage/OUTPUT-wvsb-motion-brief-blackjeweldoc1938.docx.pdf`, 15 pages; see `docs/DOCX.md`).

- Matches the typst form: EB Garamond 13 pt (the PDF embeds EBGaramond-Regular, -Bold, -Italic only); letter paper; 1 in margins; body double-spaced at an exact 24 pt pitch with a 0.5 in first-line indent; caption, counsel blocks, footnotes and headings single-spaced at an exact 17 pt pitch; level 1 headings centred in capitals; levels 2 to 4 labelled "A.", "1.", "a." by the filter, hanging at the margin; the WHEREFORE clause kept with the signature; the certificate of service on a new page; page number centred in the footer at 11 pt.
- Differs: (a) the caption rules are paragraph borders, as in the adversary complaint. (b) Heading labels and lettered or numbered items are typed text, not Word list numbering (the labels are the ones the sample gives or the typst heading scheme produces). (c) Between paragraphs the typst output has a single-line pitch (about 17 pt, `par(spacing: 0pt)`); the docx keeps 24 pt, so the docx is longer (15 pages against typst's 14). The typst template was not changed; this is for review. (d) The certificate of service is template-supplied with the bracketed placeholders from the sample.
- Reviewed: all 15 docx pages and all 14 typst pages rendered at 60 dpi and looked at.
- BLOCKED: `sh tools/check.sh <folder> --engine docx` cannot run: this folder has no `checks.yaml` (exit 2, `Error: open .../checks.yaml: no such file or directory`), and `court.json` is also not found in the doc-type folder (jq error). No check ID was evaluated, so the gates are unverified for docx.
