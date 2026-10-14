# N.D. Ga. (gand): motion brief (Rule 12(b) motion with supporting memorandum)

Doc type: **motion-brief**: a motion to dismiss under Fed. R. Civ. P. 12(b)(6) with the supporting memorandum of law, in one document (the form of the primary exemplar). Court: United States District Court for the Northern District of Georgia (`gand`). Folder: `courts/eleventh-circuit/georgia/federal/northern-district/motion-brief/`.

**Typeface (tier 1): resolved.** LR 5.1(C) permits Times New Roman (at least 14 point), Courier New (at least 12), Century Schoolbook (at least 13) or Book Antiqua (at least 13). The template uses the first listed face, Times New Roman 14 pt, and renders it with its substitute **Liberation Serif** (metric-compatible, per `docs/FONTS.md`; vendored, SIL OFL). The font is `font-name` in `typst/gand-motion-brief.typ`. The leading is 1.645em so the baseline pitch stays at 32.2 pt, as before. The page count stays at 10 pages on this sample.

The LR 7.1(D) certificate names **Times New Roman** (`rule-font-name`), not the substitute: the filer certifies the face it prepares the brief in, and the substitute has the same metrics. The rendered PDF uses Liberation Serif, so the certificate describes the filing, not the PDF's embedded font. Whether that reading is right is for David to confirm (see Known gaps 1).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-durand-1-26-cv-03458-motion-brief.pdf` (primary: motion with memorandum, 18 pages, counsel for the State); second filer `exemplars/FILED-EXAMPLE-electronic-maintenance-1-26-cv-03121-memorandum.pdf` (separate memorandum, 16 pages). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-durand-motion-brief.md` (a portion of the Durand motion; see Sample below) |
| render | ok: `samples/OUTPUT-durand-motion-brief.pdf`, 10 pages, typst 0.15.0, vendored fonts only (`pdffonts`: LiberationSerif and LiberationSerif-Bold embedded), no typst warnings. sha256 `3b681a99945dc4a3340124577be62b572068892b16b5db8624d5c1ddde0d684b`. |
| overlay | ok: `samples/OVERLAY-durand-motion-brief.pdf` and `OVERLAY-durand-motion-brief.txt` (run 2026-10-14 on the Liberation Serif render) |
| pages reviewed | 10 of 10, each rendered at 60 dpi and viewed in the final PDF |

File names: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`; the brief's `<id>.pdf` and `<id>-overlay.pdf` names differ from the tools' names, which may not be edited.

## Governing rules

Primary source: N.D. Ga. Local Rules, Civil (`NDGARulesCV_4_0_26.pdf`), https://www.gand.uscourts.gov/sites/gand/files/local_rules/NDGARulesCV_4_0_26.pdf. Downloaded and read 2026-10-14. Quoted text below is from that PDF (LR 5.1 at CV-20 and CV-21; LR 7.1 at CV-24).

M = mandated by a rule (tier 1). C = convention (tier 2). A = author responsibility or a separate filing.

| ID | Rule | Requirement (quoted or closely paraphrased) | M/C/A | Where in the template |
|---|---|---|---|---|
| GAND-FORM-001 | LR 5.1(C) | "Computer documents must be prepared in one of the following fonts: Times New Roman (at least 14 point), Courier New (at least 12 point), Century Schoolbook (at least 13 point), or Book Antiqua (at least 13 point)." | M | `font-name` = "Liberation Serif" (substitute for Times New Roman), `type-size` = 14pt. |
| GAND-FORM-002 | LR 5.1(C) | "be double-spaced between lines"; "Footnotes, headings, and indented citations may be single-spaced." | M | `body-leading` = 1.65em (32.2 pt baseline pitch, matched to the filed exemplar's body text, Durand p.2). Headings, footnotes, block quotations single-spaced. |
| GAND-FORM-003 | LR 5.1(D) | "The top, bottom, left, and right margins ... must be at least one inch." | M | `margin` = 1in on all four sides. |
| GAND-FORM-004 | LR 5.1(E) | "All pages shall be numbered consecutively at the bottom center of the page." | M | `page-footer()`. |
| GAND-FORM-005 | LR 5.1(G) | Every document presented by counsel includes the attorney's name, complete address, telephone, email and bar number. | M | `signature-block()`: asserts `name`, `bar`, `email` per attorney; address, phone and role from frontmatter. |
| GAND-FORM-006 | LR 5.1(J) | "All pleadings ... must bear specific pleading designations, in accordance with ... Fed. R. Civ. P. 7." | M | `cover()`: the title of the paper; the caption's party designations. |
| GAND-FORM-007 | LR 5.1(K) | Documents carry the assigned case number "which includes a three-initial suffix which will identify the district judge." | M | `caption()`: `case_number` (`1:26-cv-03458-SDG`). |
| GAND-CAP-001 | Fed. R. Civ. P. 10(a) | "a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | M | `court-title()`, `caption()`, `title`. |
| GAND-MEM-001 | LR 7.1(A)(1) | "Every motion presented to the clerk for filing shall be accompanied by a memorandum of law which cites supporting authority." | M | The template produces one document containing the motion and the memorandum (the primary exemplar's form). A separate memorandum (the second exemplar) is equally compliant; the template does not generate a separate one. |
| GAND-LIM-001 | LR 7.1(D) | "briefs filed in support of a motion ... are limited in length to twenty-five (25) pages." | M | Not enforced (no page counter). The sample is 10 pages; the author must keep the brief within 25. |
| GAND-CERT-001 | LR 7.1(D) | "At the end of the brief, counsel must certify that the brief has been prepared with one of the font and point selections approved by the Court in LR 5.1(B) [sic; the font rule is LR 5.1(C)]." | M | `font-certificate()`: "I certify that the foregoing brief conforms to the requirements of LR 5.1(C). The brief is prepared in 14-point Times New Roman font." The face is `rule-font-name`, the rule's face; the PDF embeds the metric-compatible Liberation Serif (see the top of this file). |
| GAND-SVC-001 | Fed. R. Civ. P. 5(b)(2)(E), 5(d)(1)(B) | Service through the court's electronic filing system; a certificate of service is not required for ECF service. | C | `service-certificate()`: included because both the primary and second exemplar carry one; the date text comes from frontmatter (`service_text`). |
| GAND-FIL-001 | Fed. R. Civ. P. 11(a) | The paper states the signer's address, email and telephone. | M | `signature-block()`. |
| GAND-SEP-001 | LR 3.3 | Certificate of Interested Persons and Corporate Disclosure Statement at first appearance. | A | Not generated (separate filing). |

Not used: Fed. R. Civ. P. 12(b) is the basis of the motion (content), not a form requirement. No table of contents or table of authorities is required by the Local Rules for a brief of this length; the exemplar (18 pages) has neither, so the template has none (the ca9 and cand templates have them for their own rules).

## Layout (what the template does)

- Letter paper, 1-inch margins, 14 pt body, double-spaced, page number bottom center.
- Cover: three-line court title (`IN THE UNITED STATES DISTRICT COURT / FOR THE NORTHERN DISTRICT OF GEORGIA / <DIVISION> DIVISION`), caption with a `)` column, `Civil Action No.` on the right, the title of the paper in bold capitals.
- Body: unnumbered paragraphs with a 0.5-inch first-line indent; `#` headings centered bold capitals (INTRODUCTION, FACTUAL BACKROUND, ARGUMENT AND CITATION OF AUTHORITY, CONCLUSION); `##` bold left-aligned sub-headings (the author types A., B., and the sub-headings' own text); block quotations (`>`) single-spaced and indented 0.5 inch on both sides; footnotes 14 pt single-spaced.
- Signature: "Respectfully submitted," then `s/` signer, attorney name and bar number, firm, address, telephone, email, role.
- Certificates: LR 7.1(D) font certificate, then a certificate of service with the date from `service_text`.

## Sample (`samples/INPUT-durand-motion-brief.md`)

A transcription of the Durand motion (exemplar pp. 1–9 and 14, and the conclusion on p.16; the signature block and the certificates are generated by the template from frontmatter, as the exemplar pp. 16–18 do): the motion paragraph, INTRODUCTION (two paragraphs), FACTUAL BACKROUND (paragraphs to p.5, with footnote 1 in full), ARGUMENT A (both paragraphs), B (the opening paragraphs, the McDonough block quotation, the limited-public-forum paragraphs and "Importantly", to p.9), C (the first paragraphs), CONCLUSION.

Not transcribed (to stay within the 8–14 page target): Argument B from "Next, the challenged restriction is reasonable..." (exemplar p.9) to the end of B (pp.9–14), the rest of Count Two (exemplar pp.14–15), and Argument D (qualified immunity, pp.15–16). Footnotes 2 and 3 of the exemplar are not transcribed (they belong to omitted text).

Changes from the exemplar, and why:

- The exemplar's footnote 1 marker sits on the heading "FACTUAL BACKROUND"; the sample attaches it to the end of the first facts paragraph, because a footnote reference inside a heading does not survive the heading's uppercase rule. This is a tier-3 placement difference.
- Case names and signals (*Id.*, *See*) are roman: the exemplar's text layer has no italic markup.
- The exemplar's typos are kept as printed ("FACTUAL BACKROUND", "dismiss all claim"). They are the filed text, not the template's.
- Counsel block: only the signing attorney (Roger A. Chalmers) is in the sample's signature block. The exemplar also lists the Attorney General and Deputy Attorney General with bar numbers. Their email addresses are not in the text the exemplar gives us, so they cannot be transcribed with the LR 5.1(G) email; they are omitted and the template would reject them without emails.

The overlay pairs our pages with the exemplar by word overlap, which is coarse: ours p.9 maps to filed p.14 and ours p.10 to filed p.18, where the sample stops early and the exemplar continues. It is a diagnostic, not a score.

## Gate 2 review (current PDF, all 10 pages rendered at 60 dpi and viewed, 2026-10-14)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title (IN THE form, matching the complaint's and the second exemplar's), caption with `)` column and four-line defendant name (the first build overlapped; fixed by splitting names in the frontmatter and measuring each caption line), title, opening paragraph, INTRODUCTION. | PASS |
| 2 | exemplar p.2 | Introduction, double-spaced. | PASS |
| 3 | exemplar p.3 | FACTUAL BACKROUND heading; first facts paragraph; footnote 1 at the foot of the page, 14 pt single-spaced. | PASS |
| 4 | exemplar p.4 | Facts paragraphs; "¶ ¶" and "§" glyphs render. | PASS |
| 5 | exemplar p.5 | Facts end; ARGUMENT AND CITATION OF AUTHORITY heading; A. sub-heading; Argument A. | PASS |
| 6 | exemplar p.6 | Argument A ends; B. Count One sub-heading; Argument B opening. | PASS |
| 7 | exemplar p.7 | Block quotation (McDonough), single-spaced and indented; the paragraph after it on the grid. | PASS |
| 8 | exemplar p.8 | Limited-public-forum paragraphs; C. Count Two sub-heading; Count Two opening. | PASS |
| 9 | exemplar p.17 (signature) | Count Two's jurisdiction paragraph; CONCLUSION; "Respectfully submitted,"; signature block with bar number, address, telephone, email, role; LR 7.1(D) certificate. | PASS |
| 10 | exemplar p.18 | Certificate of service with date and `s/` signature. | PASS |

## Known gaps and open choices

1. **Font (tier 1): resolved, see the top of this file.** The certificate names Times New Roman, the face LR 5.1(C) lists, while the PDF embeds the metric-compatible Liberation Serif. David should confirm that a certificate naming the rule's face, over a Times-metric render, is the intended reading.
2. **LR 7.1(D) cross-reference.** The rule's own text says the font selections are "approved by the Court in LR 5.1(B)"; the font selections are in LR 5.1(C) (5.1(B) is paper). The template cites LR 5.1(C), as the exemplar's certificate does. David should confirm the reading.
3. **Page limit.** LR 7.1(D) limits the brief to 25 pages. Not checked by the template; the sample is 10 pages.
4. **Second exemplar.** The separate memorandum (First Horizon, 16 pages) is on file. It was checked on page 1 only; its layout was not compared, so tier 2 is judged against the primary exemplar's layout plus the LR rules.
5. **Standing orders.** The judges' standing orders (for example, the Standing Order Regarding Civil Litigation of Judge Grimberg and Judge Brown in the same RECAP listings) may impose format, page or briefing requirements. Not read for this doc type.
6. **Signature block and emails.** Only the signing attorney is transcribed (see Sample); a filed brief with several attorneys needs an email for each.
7. **Checkers not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`, which this doc-type folder does not have; `tools/` may not be edited. Gate 0 and Gate 1 were not run mechanically. The table above is the Gate 2 record.
8. **Tier-2 choices.** The cover follows the primary exemplar's layout; the court title uses the "IN THE" form, which 3 of the 4 N.D. Ga. filings on file use (the primary exemplar does not). The sub-heading style (bold left, typed letters) is the primary exemplar's.
