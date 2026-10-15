# Adversary complaint (U.S. Bankruptcy Court, D. Hawaii)

Complaint initiating an adversary proceeding, in the Typst engine (`typst/`), rendered from one markdown sample (`samples/INPUT-hawaii-brewery-adversary-complaint.md`).

| File | Role |
|---|---|
| `typst/main.typ`, `typst/hib-adversary-complaint.typ` | Template (entry point and rule-driven layout) |
| `samples/INPUT-hawaii-brewery-adversary-complaint.md` | Markdown input, transcribed from the filed exemplar (frontmatter = caption, counsel, signature) |
| `samples/OUTPUT-hawaii-brewery-adversary-complaint.pdf` | Our render (`tools/render.sh`), 10 pages |
| `samples/OVERLAY-hawaii-brewery-adversary-complaint.pdf` / `.txt` | Red (ours) / blue (filed) overlay and page map (`tools/overlay.sh`) |
| `exemplars/FILED-EXAMPLE-hawaii-brewery-26-90013-adversary-complaint.pdf` | The filed exemplar (26 pages; cover sheet pp. 1-2, complaint pp. 3-26) |
| `exemplars/SOURCE.md` | Filer, case, date filed, URL, date retrieved |

Engines: typst only. No latex or docx engine is delivered for this doc type.

## Rules

Quoted from the primary text. Retrieved 2026-10-14.

| ID | Requirement | Source (URL; date) |
|---|---|---|
| HIB-ADV-FORM-001 | Caption: court name, parties, adversary number, a designation of the paper (FRBP 9004(b)). The complaint's caption must "substantially conform to the appropriate version of Form 416" (FRBP 7010, which applies FRCP 10 in an adversary proceeding). FRCP 10(a): the title names all parties. | FRBP 7010: https://www.law.cornell.edu/rules/frbp/rule_7010 (text as shown Dec. 1, 2024 version); FRBP 9004: https://www.law.cornell.edu/rules/frbp/rule_9004 (Dec. 1, 2024); FRCP 10: https://www.law.cornell.edu/rules/frcp/rule_10 |
| HIB-ADV-FORM-002 | Type size: not set for a complaint. LBR 9004-1(b)(1) sets 14-point type for "All memoranda, including footnotes"; a complaint is not a memorandum. The template uses 12 pt, which is a tier-2 convention (the exemplar's body is 12 pt in a Calibri face). | LBR 9004-1(b)(1), D. Haw. Local Bankruptcy Rules, Dec. 1, 2025: https://www.hib.uscourts.gov/sites/hib/files/documents/local-rules/LBR2025_dec01_8001-1_to_9074-1.pdf |
| HIB-ADV-FORM-003 | Line spacing: "The text of the document must be double-spaced, except for identification of counsel, title of the case, quotations, footnotes, and exhibits." Block quotations are single-spaced and indented (template `quote` rule). | LBR 9004-1(b)(2) (same PDF) |
| HIB-ADV-FORM-004 | Paper 8.5 x 11 in.; margins 1 in. from the edge of the document. | LBR 9004-1(a)(2), (b)(3) (same PDF) |
| HIB-ADV-FORM-005 | Counsel identification at the top left, single-spaced. | LBR 9004-1(b)(2) (exempts counsel identification from double spacing); layout follows the exemplar (convention) |
| HIB-ADV-FORM-006 | Claims in numbered paragraphs, "each limited as far as practicable to a single set of circumstances." Statements may be adopted by reference, and a written instrument attached as an exhibit is part of the pleading. | FRCP 10(b), (c): https://www.law.cornell.edu/rules/frcp/rule_10 |
| HIB-ADV-FORM-007 | Jurisdiction: the allegation must name the bankruptcy case (name, number, Code chapter) and the district and division where the proceeding is pending; the complaint must state whether the pleader consents to entry of final orders or judgment by the bankruptcy court. | FRBP 7008: https://www.law.cornell.edu/rules/frbp/rule_7008 (Dec. 1, 2024) |
| HIB-ADV-FORM-008 | Cover sheet: "Every complaint initiating an adversary proceeding must be accompanied by a cover sheet substantially conforming to the Director's Procedural Form (Adversary Proceeding Cover Sheet)." Filed separately; not rendered by this template (see gaps). | LBR 7003-1, D. Haw. Local Bankruptcy Rules, Dec. 1, 2025: https://www.hib.uscourts.gov/sites/hib/files/documents/local-rules/LBR2025_dec01_7001-2_to_7067-2.pdf |
| HIB-ADV-FORM-009 | Exhibits: separated from the text by a page identifying the exhibit; no tabs; exhibits are exempt from the formatting rules of LBR 9004-1(b). The sample refers to the lease as Exhibit "A" without transcribing it. | LBR 9004-1(a)(4), (b) (same PDF as HIB-ADV-FORM-002) |
| HIB-ADV-FORM-010 | Signature block after the prayer, with the date line "DATED:" (convention). | Exemplar; no local rule text on complaint signatures |
| HIB-ADV-FONT-001 | Typeface: **no face named.** LBR 9004-1(b)(1) is headed "Font style" but sets only the size (14-point, memoranda); the full Dec. 1, 2025 compilation names no typeface. Typeface row: face required = none; substitute = EB Garamond (vendored, `docs/FONTS.md` "No face named"); fit = n/a. | LBR 9004-1(b)(1) (same PDF as HIB-ADV-FORM-002; text searched 2026-10-15) |

No local rule numbered LBR 7010 or LBR 7008 appears in the December 1, 2025 compilation (the index of LBR 7001-2 through 7067-2 lists 7001-2, 7003-1, 7016-1, 7017-1, 7026-1 and later). The FRBP 7010 and 7008 rules above therefore govern the form and content of the complaint.

Note on how the local-rule text was obtained: the court's PDF is not text-extractable through the fetch tool, so the rule text was extracted with `pdftotext` from the saved copy of the PDF on 2026-10-14. Quotations above are from that extraction.

LBR 7016-1(b) (scheduling conference on filing of a complaint) also applies to the plaintiff, but it governs procedure, not the document's form, so it is not a template requirement.

## Tier 1 and tier 2

- Tier 1 (mandated form): paper size, 1-inch margins, double spacing, caption content, numbered paragraphs, jurisdiction and final-order statements in the body, and the cover-sheet requirement (LBR 7003-1, which this template does not render; see gaps). The 14-point rule does not apply (complaint, not memorandum).
- Tier 2 (convention): caption layout (adversary number and title on the right; "v." between parties; the caption continuing to page 2, as the exemplar does), centered section headings, footnotes, block quotations, signature block. Judged against one filer only (see gaps).

## What the overlay shows

`samples/OVERLAY-hawaii-brewery-adversary-complaint.pdf` (red = our render, blue = filed exemplar, black = both). Page pairing by text (`OVERLAY-hawaii-brewery-adversary-complaint.txt`):

| Our page | Filed page | Word overlap | Reading |
|---|---|---|---|
| 1 | 3 | 87.7% | Caption page. Counsel block and caption positions differ from the filed page. Tier 2. |
| 2 | 5 | 53.7% | Caption continuation and the start of the body (the filed p. 4 carries the same two things). Tier 2. |
| 3-8 | 6, 8, 9, 11, 12, 14 | 62-75% | Body (¶¶ 5-62, the lease bullets on our p. 4, the headings). Line pitch differs (EB Garamond at 12 pt vs Calibri), so the lines do not coincide. Tier 3 (font). |
| 9 | 15 | 37.5% | Block quotation (¶ 63) and the start of the prayer. Tier 3, plus the omitted paragraphs. |
| 10 | 26 | 34.4% | Signature block alone (the prayer ends on our p. 9). Pairs with filed p. 26, the signature page. Tier 3 and content (the omitted paragraphs and the signature layout). |

## Gaps (open)

1. **Cover sheet (LBR 7003-1, Director's Form B1040).** Not rendered. The filed exemplar's pp. 1-2 are the B1040 form, which is a separate filing. The overlay therefore compares our caption page against the exemplar's page 3, not against the cover sheet. Open: the court may want the cover sheet generated, which would be a separate doc type.
2. **Division (FRBP 7008).** FRBP 7008 requires the allegation of jurisdiction to name "the district and division where it is pending." The exemplar's ¶ 10 names the case and district but not a division. The sample follows the exemplar. Open: whether this court's complaints must state a division.
3. **Certificate of service (LBR 9013-3).** None in the sample; the exemplar transcribed has none. LBR 9013-3(a) requires a certificate of service unless Rule 7005 governs service and every party served is a registered ECF user. A complaint is served with the summons under FRBP 7004, so whether 9013-3 applies is unclear. Open: needs a ruling on the complaint's service method before a certificate block is added.
4. **Body abridged.** The sample transcribes ¶¶ 1-63, the first block quotation, the prayer ¶¶ A-H and the signature; ¶¶ 64-133 and the Lease (Exhibit A) are marked as omitted in the sample text. The exemplar is 24 pages of complaint; the sample is 10 pages, inside the 8-14 page band.
5. **One filer only.** Tier 2 is judged against one exemplar (Hawaii Brewery Development Co., Adv. 26-90013). A second filer was identified (Collins v. Hughes Network Systems, LLC, Adv. 24-90002, Square One Legal, 9 pp.) but not saved, per `exemplars/SOURCE.md`. Tier 2 therefore cannot be fully judged; this is stated, not hidden.
6. **Typeface.** The local rules name no typeface (HIB-ADV-FONT-001), so the template keeps EB Garamond (vendored), as `docs/FONTS.md` prescribes for a court that names no face. The exemplar is Calibri (one filer; tier 3).

[Court README](../README.md)
