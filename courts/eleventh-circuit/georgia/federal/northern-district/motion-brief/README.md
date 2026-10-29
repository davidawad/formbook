# N.D. Ga. (gand): motion brief (Rule 12(b) motion with supporting memorandum)

Doc type: **motion-brief**: a motion to dismiss under Fed. R. Civ. P. 12(b)(6) with the supporting memorandum of law, in one document (the form of the primary exemplar). Court: United States District Court for the Northern District of Georgia (`gand`). Folder: `courts/eleventh-circuit/georgia/federal/northern-district/motion-brief/`.

**Typeface (tier 1): resolved.** LR 5.1(C) permits Times New Roman (at least 14 point), Courier New (at least 12), Century Schoolbook (at least 13) or Book Antiqua (at least 13). The template uses the first listed face, Times New Roman 14 pt, rendered in **Times New Roman** itself (the pinned install, `docs/FONTS.md` rule 1), with Liberation Serif (metric-compatible, vendored) as the fallback. The font is `font-family` in `typst/gand-motion-brief.typ`, the size `size: 14` in `typst/layout.yaml`; the body pitch is 32.2 pt (`pitch.body`). The sample renders to 11 pages.

The LR 7.1(D) certificate (`after_tail` in `typst/layout.yaml`) names **Times New Roman** at 14 point, the face and size the layout sets; the rendered PDF embeds Times New Roman.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (primary: motion with memorandum, 18 pages, counsel for the State); second filer `usage/FILED-EXAMPLE-motion-brief-2.pdf` (separate memorandum, 16 pages). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (a portion of the Durand motion; see Sample below) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages (typst), with `.latex.pdf` and `.docx`/`.docx.pdf` generated from the same layout; TimesNewRomanPSMT and TimesNewRomanPS-BoldMT embedded, no typst warnings |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 11 of 11 on every engine (2026-10-29, see "Gate 2 review") |

File names: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`; the brief's `<id>.pdf` and `<id>-overlay.pdf` names differ from the tools' names, which may not be edited.

## Governing rules

Primary source: N.D. Ga. Local Rules, Civil (`NDGARulesCV_4_0_26.pdf`), https://www.gand.uscourts.gov/sites/gand/files/local_rules/NDGARulesCV_4_0_26.pdf. Downloaded and read 2026-10-14. Quoted text below is from that PDF (LR 5.1 at CV-20 and CV-21; LR 7.1 at CV-24).

M = mandated by a rule (tier 1). C = convention (tier 2). A = author responsibility or a separate filing.

| ID | Rule | Requirement (quoted or closely paraphrased) | M/C/A | Where in the template |
|---|---|---|---|---|
| GAND-FORM-001 | LR 5.1(C) | "Computer documents must be prepared in one of the following fonts: Times New Roman (at least 14 point), Courier New (at least 12 point), Century Schoolbook (at least 13 point), or Book Antiqua (at least 13 point)." | M | `font-family` = ("Times New Roman", "Liberation Serif") in `typst/gand-motion-brief.typ` (Liberation Serif the fallback); `size: 14` in `typst/layout.yaml`. |
| GAND-FORM-002 | LR 5.1(C) | "be double-spaced between lines"; "Footnotes, headings, and indented citations may be single-spaced." | M | `pitch: {body: 32.2, single: 16.1}` (the filed exemplar's body pitch, Durand p.2). Headings, footnotes, block quotations single-spaced. |
| GAND-FORM-003 | LR 5.1(D) | "The top, bottom, left, and right margins ... must be at least one inch." | M | the base: `margin` 72 pt on every side. |
| GAND-FORM-004 | LR 5.1(E) | "All pages shall be numbered consecutively at the bottom center of the page." | M | the base: `page_number: {align: center}`. |
| GAND-FORM-005 | LR 5.1(G) | Every document presented by counsel includes the attorney's name, complete address, telephone, email and bar number. | M | `closing` in `typst/layout.yaml`; the typst template asserts `name`, `bar`, `email` per attorney, and the address, phone and role. |
| GAND-FORM-006 | LR 5.1(J) | "All pleadings ... must bear specific pleading designations, in accordance with ... Fed. R. Civ. P. 7." | M | `front`: the title of the paper; the caption's party designations. |
| GAND-FORM-007 | LR 5.1(K) | Documents carry the assigned case number "which includes a three-initial suffix which will identify the district judge." | M | `front`: `case_number` (`1:26-cv-03458-SDG`). |
| GAND-CAP-001 | Fed. R. Civ. P. 10(a) | "a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | M | `front` in `typst/layout.yaml`. |
| GAND-MEM-001 | LR 7.1(A)(1) | "Every motion presented to the clerk for filing shall be accompanied by a memorandum of law which cites supporting authority." | M | The template produces one document containing the motion and the memorandum (the primary exemplar's form). A separate memorandum (the second exemplar) is equally compliant; the template does not generate a separate one. |
| GAND-LIM-001 | LR 7.1(D) | "briefs filed in support of a motion ... are limited in length to twenty-five (25) pages." | M | `eval.yaml` `page_limit: 25`, checked on every render; the sample is 11 pages. |
| GAND-CERT-001 | LR 7.1(D) | "At the end of the brief, counsel must certify that the brief has been prepared with one of the font and point selections approved by the Court in LR 5.1(B) [sic; the font rule is LR 5.1(C)]." | M | `after_tail`: "I certify that the foregoing brief conforms to the requirements of LR 5.1(C). The brief is prepared in 14-point Times New Roman font." The face is the one the layout sets. |
| GAND-SVC-001 | Fed. R. Civ. P. 5(b)(2)(E), 5(d)(1)(B) | Service through the court's electronic filing system; a certificate of service is not required for ECF service. | C | `after_tail`: included because both the primary and second exemplar carry one; the date text comes from frontmatter (`service_text`). |
| GAND-FIL-001 | Fed. R. Civ. P. 11(a) | The paper states the signer's address, email and telephone. | M | `closing`. |
| GAND-SEP-001 | LR 3.3 | Certificate of Interested Persons and Corporate Disclosure Statement at first appearance. | A | Not generated (separate filing). |

Not used: Fed. R. Civ. P. 12(b) is the basis of the motion (content), not a form requirement. No table of contents or table of authorities is required by the Local Rules for a brief of this length; the exemplar (18 pages) has neither, so the template has none (the ca9 and cand templates have them for their own rules).

## Layout (what the layout sets)

Set by `typst/layout.yaml` (the generic FRCP brief, `lib/layouts/frcp-motion-brief.yaml`, with this court's overlay; each value cites its rule):

- Court name ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF GEORGIA", exemplars 2 and 3) and "<division> DIVISION" bold and centered.
- Caption: the parties in a 3.2 in column at the left (each party's names, its designation half an inch in, "v." between them, a blank line between each, as exemplars 1 and 2), a ")" beside every line, "Civil Action No." (`case_label`) and the number with the judge's suffix at the right, centered on the parties' height (LR 5.1(K)). Title bold capitals, centered.
- Body 14 pt Times New Roman (LR 5.1(C)), double-spaced at 32.2 pt, first lines indented half an inch, unnumbered. Footnotes 14 pt, quotations half an inch in on each side and headings single-spaced (LR 5.1(C)). Headings bold with a single line above and below: level 1 centered capitals, level 2 at the margin (letters typed in the sample).
- Signature (LR 5.1(G)): "Respectfully submitted," at the margin; from 2.7 in, "s/" and the signer, each attorney's name and Georgia Bar number, the office, address, telephone, each attorney's e-mail and whom they represent. Kept whole and with the last paragraph.
- The LR 7.1(D) font certificate and the certificate of service, each centered and bold, its text double-spaced, the "s/" line at the right, each kept on one page.
- Pages numbered at the bottom center from page 1 (LR 5.1(E)).
- The typst template asserts the fields LR 5.1(G) needs (`name`, `bar`, `email` for every attorney; the office, address, telephone, role) and `division` and `service_text`: a missing one stops the render.

## Sample (`usage/INPUT-motion-brief.md`)

A transcription of the Durand motion (exemplar pp. 1–9 and 14, and the conclusion on p.16; the signature block and the certificates are set by the layout from frontmatter, as the exemplar pp. 16–18 do): the motion paragraph, INTRODUCTION (two paragraphs), FACTUAL BACKROUND (paragraphs to p.5, with footnote 1 in full), ARGUMENT A (both paragraphs), B (the opening paragraphs, the McDonough block quotation, the limited-public-forum paragraphs and "Importantly", to p.9), C (the first paragraphs), CONCLUSION.

Not transcribed (to stay within the 8–14 page target): Argument B from "Next, the challenged restriction is reasonable..." (exemplar p.9) to the end of B (pp.9–14), the rest of Count Two (exemplar pp.14–15), and Argument D (qualified immunity, pp.15–16). Footnotes 2 and 3 of the exemplar are not transcribed (they belong to omitted text).

Changes from the exemplar, and why:

- The exemplar's footnote 1 marker sits on the heading "FACTUAL BACKROUND"; the sample attaches it to the end of the first facts paragraph, because a footnote reference inside a heading does not survive the heading's uppercase rule. This is a tier-3 placement difference.
- Case names and signals (*Id.*, *See*) are roman: the exemplar's text layer has no italic markup.
- The exemplar's typos are kept as printed ("FACTUAL BACKROUND", "dismiss all claim"). They are the filed text, not the template's.
- Counsel block: only the signing attorney (Roger A. Chalmers) is in the sample's signature block. The exemplar also lists the Attorney General and Deputy Attorney General with bar numbers. Their email addresses are not in the text the exemplar gives us, so they cannot be transcribed with the LR 5.1(G) email; they are omitted and the template would reject them without emails.

The overlay pairs our pages with the exemplar by word overlap, which is coarse: ours p.9 maps to filed p.14 and ours p.10 to filed p.18, where the sample stops early and the exemplar continues. It is a diagnostic, not a score.

## Known gaps and open choices

1. **Font (tier 1): resolved, see the top of this file.** The certificate names Times New Roman, the face LR 5.1(C) lists, and the PDF embeds Times New Roman.
2. **LR 7.1(D) cross-reference.** The rule's own text says the font selections are "approved by the Court in LR 5.1(B)"; the font selections are in LR 5.1(C) (5.1(B) is paper). The template cites LR 5.1(C), as the exemplar's certificate does. David should confirm the reading.
3. **Page limit.** LR 7.1(D) limits the brief to 25 pages: checked on every render (`eval.yaml` `page_limit: 25`); the sample is 11 pages.
4. **Second exemplar.** The separate memorandum (First Horizon, 16 pages) is on file. It was checked on page 1 only; its layout was not compared, so tier 2 is judged against the primary exemplar's layout plus the LR rules.
5. **Standing orders.** The judges' standing orders (for example, the Standing Order Regarding Civil Litigation of Judge Grimberg and Judge Brown in the same RECAP listings) may impose format, page or briefing requirements. Not read for this doc type.
6. **Signature block and emails.** Only the signing attorney is transcribed (see Sample); a filed brief with several attorneys needs an email for each.
7. **Gates run:** `tools/check.sh` on typst, latex and docx, every gate green (2026-10-29).
8. **Tier-2 choices.** The cover follows the primary exemplar's layout; the court title uses the "IN THE" form, which 3 of the 4 N.D. Ga. filings on file use (the primary exemplar does not). The sub-heading style (bold left, typed letters) is the primary exemplar's.

## Gate 2 review (11 of 11 pages, 2026-10-29, the FRCP-base render)

Every page of the typst, LaTeX and Word renders was read as its text layout and word boxes (`pdftotext -layout`, `-bbox`); the three break every line and page alike (XENG-001..003).

- Page 1: court name and division; the caption with a ")" on every line, the case number centered at the right; the title; the motion's opening; INTRODUCTION. Pass.
- Pages 2 to 7: introduction, FACTUAL BACKROUND (as filed), ARGUMENT AND CITATION OF AUTHORITY, A., B.; no heading ends a page. Pass.
- Page 8: the indented quotation single-spaced, half an inch in on each side. Pass.
- Page 9: the rest of B.; C. Count Two. Pass.
- Page 10: CONCLUSION, the signature block, the LR 7.1(D) certificate. Pass.
- Page 11: CERTIFICATE OF SERVICE, kept whole on its own page. Pass.

## Engines

On the generic federal district brief since fb-595.17.5: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template names the face and keeps the LR 5.1(G) asserts; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter (`docx/gand-motion-brief.lua`) are removed. docs/EVAL-LOOP.md, "Generated engines", has the layout grammar.

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst (reference) | `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages | 12 checks passed, 0 failed | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` | 15 checks passed, 0 failed | PASS (232/232 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (LibreOffice) | 16 checks passed, 0 failed | PASS (232/232 lines) |

The LR 7.1(D) 25-page limit is checked on every render (`eval.yaml` `page_limit`). The asserts run in typst only (the generated engines do not check frontmatter). No item is BLOCKED.
