# N.D. Ga. (gand): complaint

Doc type: **complaint** in the United States District Court for the Northern District of Georgia (`gand`).
Folder: `courts/eleventh-circuit/georgia/federal/northern-district/complaint/`.

**Typeface (tier 1): resolved.** LR 5.1(C) permits Times New Roman (at least 14 point), Courier New (at least 12), Century Schoolbook (at least 13) or Book Antiqua (at least 13). The template uses the first listed face, Times New Roman 14 pt, and renders it with its substitute **Liberation Serif** (metric-compatible, per `docs/FONTS.md`; vendored, SIL OFL). The font is one parameter (`font-name` / `font-family` in `typst/gand-complaint.typ`). The leading is set to 1.645em so the baseline pitch stays at 32.2 pt, the pitch the EB Garamond build had. The earlier EB Garamond build was not Times-metric, so the page count moved from 12 to 13 pages on the same sample; the page count is now a Times-metric result.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-serveco-4-26-cv-00299-complaint.pdf` (primary, 30 pages, counsel-filed); second filer `exemplars/FILED-EXAMPLE-washington-4-26-cv-00302-complaint.pdf` (22 pages, counsel-filed). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-serveco-complaint.md` (a portion of the Serveco complaint; see Sample below) |
| render | ok: `samples/OUTPUT-serveco-complaint.pdf`, 13 pages, typst 0.15.0, vendored fonts only (`pdffonts`: LiberationSerif and LiberationSerif-Bold embedded), no typst warnings. sha256 `685b8a7ee217f80058a3bcd9705e7f0684a0c53ae3226e2da4e75642b45604fb`. |
| overlay | ok: `samples/OVERLAY-serveco-complaint.pdf` and `OVERLAY-serveco-complaint.txt` |
| pages reviewed | 12 of 12, each rendered at 60 dpi and viewed in the final PDF |

File names: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`. The brief's `<id>.pdf` and `<id>-overlay.pdf` names differ from the tools' names; the tools are shared and may not be edited, so the tools' names are used.

## Governing rules

Primary source: N.D. Ga. Local Rules, Civil (`NDGARulesCV_4_0_26.pdf`, title "Civil Local Rules 2026-08-25"), https://www.gand.uscourts.gov/sites/gand/files/local_rules/NDGARulesCV_4_0_26.pdf (listed at https://www.gand.uscourts.gov/court-info/local-rules-and-orders/local-rules). Downloaded and read 2026-10-14. Federal rules: Fed. R. Civ. P. 10 and 11(a) fetched from https://www.law.cornell.edu/rules/frcp/rule_10 and …/rule_11 on 2026-10-14.

M = mandated by a rule (tier 1). C = convention (tier 2). A = author responsibility or a separate filing (not generated).

| ID | Rule | Requirement | M/C/A | Where in the template |
|---|---|---|---|---|
| GAND-FORM-001 | LR 5.1(C) | Computer documents in Times New Roman at least 14 point (or the other listed fonts and sizes). | M | `font-name` = "Liberation Serif" (substitute for Times New Roman), `type-size` = 14pt. |
| GAND-FORM-002 | LR 5.1(C) | Double-spaced between lines; footnotes, headings and indented citations may be single-spaced. | M | `body-leading` = 1.65em (32.2 pt baseline pitch, matched to the filed exemplar, Serveco p.2). Headings and the caption are single-spaced. |
| GAND-FORM-003 | LR 5.1(D) | Top, bottom, left and right margins at least one inch. | M | `margin` = 1in on all four sides. |
| GAND-FORM-004 | LR 5.1(E) | Pages numbered consecutively at the bottom center. | M | `page-footer()`: arabic numbers, centered in the footer. |
| GAND-FORM-005 | LR 5.1(G) | Every document carries the attorney's name, complete address, telephone, email and bar number. | M | `signature-block()`: asserts `name`, `bar`, `email` for every attorney; address and phone from frontmatter. |
| GAND-FORM-006 | LR 5.1(J); FRCP 7(a) | Captions bear the pleading designation; the complaint's title names all the parties. | M | `cover()`: title from frontmatter; party designations (`Plaintiff,` / `Defendant.`). |
| GAND-FORM-007 | LR 5.1(K) | Documents carry the assigned case number with the three-initial judge suffix. | M (after assignment) | `caption()`: `Civil Action No.` with `case_number`; blank line before assignment. |
| GAND-CAP-001 | FRCP 10(a) | Caption: court name, title, file number, Rule 7(a) designation. | M | `court-title()`, `caption()`, `title`. |
| GAND-CAP-002 | FRCP 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | M | `allegations()` numbers every body paragraph (1, 2, ...); headings and lists are unnumbered; `^^ ` marks unnumbered text (WHEREFORE, jury demand). |
| GAND-SIG-001 | FRCP 11(a) | The paper states the signer's address, email and telephone. | M | `signature-block()`. |
| GAND-SEP-001 | LR 5.1(H) | The complaint is accompanied by the civil cover sheet, prepared by counsel. | A | Not generated (separate filing). |
| GAND-SEP-002 | LR 3.3(A), (C) | Counsel for a private party files a Certificate of Interested Persons and Corporate Disclosure Statement at first appearance, in the form of LR 3.3(C). | A | Not generated (separate filing). Required with the first filing. |

## Layout (what the template does)

- Letter paper, 1-inch margins, 14 pt body, double-spaced, page number bottom center. No pleading-paper line numbers: N.D. Ga. Local Rules do not require numbered lines (both exemplars have none).
- Cover: three-line court title (`IN THE UNITED STATES DISTRICT COURT / FOR THE NORTHERN DISTRICT OF GEORGIA / <DIVISION> DIVISION`), then a caption with a column of `)` marks, the case number on the right, `JURY TRIAL DEMANDED` on the right if `jury_demand`, then the title in bold capitals.
- Party names are one caption line each. A name wider than the party column is a render error (the template measures each line), so the sample splits names over lines as the filed caption does.
- Body: numbered paragraphs; `#` headings centered bold capitals; `##` centered bold; `###` bold left (the Serveco exemplar's sub-headings A., B.); markdown lists lettered A., B., ... (the prayer).
- Signature: "Dated:" line, `/s/` signer, attorney names with bar numbers, firm, address, telephone, emails, role.
- No counsel block at the top left: both N.D. Ga. complaint exemplars put counsel's identification in the signature block, which LR 5.1(G) allows.

## Sample (`samples/INPUT-serveco-complaint.md`)

A transcription of the Serveco complaint (exemplar pp. 1–8, 24–25, 28–30): caption, the lead-in, Nature of the Action (¶¶ 1–7), The Parties (¶¶ 8–10), Jurisdiction and Venue (¶¶ 11–22, with footnote 1), Factual Background A and B (¶¶ 23–30), Count III (¶¶ 87–93), Prayer for Relief (items A–I), Demand for Jury Trial, and the signature block. Paragraphs 31–86, Counts I, II and IV, and the exemplar's footnotes other than footnote 1 are not transcribed. The template numbers the sample's paragraphs from 1, so its numbers differ from the filed numbers (the filed Count III starts at ¶ 87; the sample's at ¶ 31).

The overlay pairs sample pages with exemplar pages by word overlap, which is coarse: ours p.9–10 map to filed p.24 because the sample skips ¶¶ 31–86.

## Gate 2 review (current PDF, all 13 pages rendered at 60 dpi and viewed, 2026-10-14)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title, caption (party column with `)` marks, case number, jury demand), title, lead-in, NATURE OF THE ACTION heading, ¶ 1. | PASS |
| 2 | exemplar p.2 | Double-spaced body, ¶¶ 2–4. | PASS |
| 3 | exemplar p.3 | ¶¶ 5–10; THE PARTIES heading centered bold capitals. | PASS |
| 4 | exemplar p.4 | JURISDICTION AND VENUE heading; ¶¶ 11–14. | PASS |
| 5 | exemplar p.5 | ¶¶ 15–18; footnote 1 at the foot of the page, 14 pt single-spaced. | PASS |
| 6 | exemplar p.6 | ¶¶ 19–21. | PASS |
| 7 | exemplar p.7 | ¶¶ 22–23; FACTUAL BACKGROUND; sub-heading "A. ServeCo and Its Business" bold left. | PASS |
| 8 | exemplar p.8 | ¶¶ 24–27; sub-heading B. | PASS |
| 9 | exemplar p.9 | ¶¶ 28–31; COUNT III and its sub-heading centered. The sample skips filed ¶¶ 31–86, so the text does not match the filed page (overlap 62%); the layout does. | PASS |
| 10 | exemplar p.24 | ¶¶ 32–35. | PASS |
| 11 | exemplar p.29 | ¶¶ 36–37; PRAYER FOR RELIEF heading, WHEREFORE clause unnumbered; items A–E lettered with hanging indent. | PASS |
| 12 | exemplar p.30 | Items F–I; DEMAND FOR JURY TRIAL; unnumbered demand. | PASS |
| 13 | exemplar p.30 | "Dated" line and signature block only (bar numbers, address, telephone, emails). The page has no body text. | OPEN (tier 2, see Known gaps 1a) |

Rows are per the final PDF (sha256 above). The tier-2 comparison is against one filer's layout for the cover; the second filer (Washington) uses the same caption form (`)` column, "IN THE ..." court title) with counsel identification in the signature block on its last page, which matches the template. Its page-by-page layout was not compared.

## Known gaps and open choices

1. **Font (tier 1): resolved, see the top of this file.** The render uses Liberation Serif 14 pt as the Times New Roman substitute. Whether a Times-metric render is accepted as the filed face is for David to confirm, since the filer prepares the brief in Times New Roman itself.
   - **Orphan signature page (tier 2, OPEN).** Page 13 carries only the "Dated" line and the signature block. A clerk would expect the signature to share a page with the last text of the demand; not fixed here, because that needs a keep-with-next rule in the template.
2. **Caption line breaks.** The court title is three fixed lines of the court's name, not wrapped text. The party names are split by the sample's frontmatter, not by the template.
3. **Case number.** Before assignment the template prints a blank number. After assignment, `case_number` must carry the judge suffix (LR 5.1(K)); the template does not check the suffix format.
4. **Standing orders.** Individual judges' standing orders (for example, the Standing Order Regarding Civil Litigation, which appears in the same RECAP docket listings) may impose more form requirements. They were not read for this doc type.
5. **Separate filings.** The civil cover sheet (LR 5.1(H)) and the Certificate of Interested Persons (LR 3.3) are not generated.
6. **Tier 2 filers.** Two filers were collected (Serveco and Washington, both counsel-filed). EVAL-LOOP's tier-2 rule asks for two or three filers; two are on file. The second filer adds a "Certificate of Compliance with Local Rule 5.1" on its last page (font and margins, not required for a complaint by LR 5.1 or LR 7.1(D)); seen in one filer only, so it is tier 3 and not added.
7. **Checkers not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`, which this doc-type folder does not have; the brief forbids editing `tools/`. Gate 0 (content) and Gate 1 (rules) were not run mechanically. The table above is the Gate 2 record.
8. **Italics.** The exemplar's text layer has no italic markup, so case names in the sample are roman. The template does italicize `*...*`.
