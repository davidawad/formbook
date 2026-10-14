# Fourth Circuit: answering brief (appellee's brief)

One self-contained folder for one document type of the Fourth Circuit. Built for `fb-595.28.22-ca4`.

| Path | What |
|---|---|
| `typst/ca4-answering-brief.typ` | The template: `ca4-brief(meta, md)`. Content-agnostic; each number is a named parameter at the top or traces to a rule ID below. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits the frontmatter from the body, calls the template. |
| `samples/chapman-answering-brief.{md,pdf}` | Transcribed from the exemplar: cover, FRAP 26.1 disclosure statement, table of contents, table of authorities, Questions Presented, part of the Statement of the Case, Summary of Argument, Argument (I, II, II.A), Conclusion, signature, certificates. An excerpt of about 1,734 words of the filed 9,350-word brief. |
| `samples/chapman-answering-brief-overlay.{pdf,txt}` | Red/blue overlay of the sample on the exemplar (`tools/overlay.sh`) and the page map. |
| `exemplars/FILED-EXAMPLE-chapman-v-msp-24-1766-answering-brief.pdf` | The filed exemplar (Brief of Appellee, No. 24-1766, March 21, 2025). |
| `exemplars/SOURCE.md` | Where the exemplar came from, the searches tried, and the SHA-256. |

Build and check, from the repo root (the toolchain must be on `PATH`):

```sh
sh tools/render.sh courts/fourth-circuit/court-of-appeals/answering-brief samples/INPUT-chapman-answering-brief.md   # -> samples/OUTPUT-chapman-answering-brief.pdf
sh tools/overlay.sh courts/fourth-circuit/court-of-appeals/answering-brief chapman-answering-brief            # -> samples/...-overlay.pdf and -overlay.txt
```

Typst runs as `typst compile --root <court-dir> --font-path fonts --ignore-system-fonts --package-cache-path vendor/typst-packages --input sample=samples/NAME.md typst/main.typ out.pdf`. The font (EB Garamond, OFL) and the cmarker package are vendored; a warning fails the build (`tools/render.sh`).

## Governing rules

The form is set by the Federal Rules of Appellate Procedure; the Fourth Circuit's Rule 32 page reproduces FRAP 32 and was read for this folder. "Verified" means the text was read on 2026-10-14. The Fourth Circuit's local rules were not read in full. Where a rule was cited from a secondary text and not read, the row says so.

| ID | Requirement | Source | Verified | Kind |
|---|---|---|---|---|
| CA4-FORM-004 | Proportionally spaced serif face, 14-point or larger; plain roman type (italics and bold for emphasis only). | FRAP 32(a)(5), 32(a)(6). Fourth Circuit Rule 32 page, <https://www.ca4.uscourts.gov/rules/Rule32.html>, dated March 23, 2026. | 2026-10-14 (page read) | court-mandated |
| CA4-FORM-003 | Text double-spaced; quotations of more than two lines indented and single-spaced; headings and footnotes single-spaced. | FRAP 32(a)(4), same page. | 2026-10-14 | court-mandated |
| CA4-FORM-002 | 8½ × 11 paper; margins of at least one inch on all four sides. | FRAP 32(a)(4), same page. | 2026-10-14 | court-mandated |
| CA4-LIMIT-001 | Appellee's principal brief: no more than 13,000 words (or 1,300 lines if monospaced). The template refuses to build above 13,000 words, counted from the markdown body. | FRAP 32(a)(7)(B)(i), same page. | 2026-10-14 | court-mandated |
| CA4-COVER-001 | Cover: case number at top; name of the court; title of the case; nature of the proceeding and the court below; title of the brief identifying the party; name, office address and telephone of counsel. | FRAP 32(a)(2)(A)–(F), same page. | 2026-10-14 | court-mandated |
| CA4-COVER-002 | Cover color: appellee's brief red (appellant blue, reply gray). **Not produced**; see known gaps. | FRAP 32(a)(2), same page. | 2026-10-14 | court-mandated (paper copies) |
| CA4-DISC-001 | FRAP 26.1 disclosure statement, when required. Produced from `disclosure:` metadata (seven yes/no answers, in the form's order). Optional: the template omits the page when the metadata has no `disclosure:` key. | FRAP 28(a)(1) (which 28(b) requires of the appellee), FRAP 26.1; the questions and wording of the court's form, as printed in the exemplar, pp. 2–3. | 2026-10-14 (FRAP 28 read; the form's questions read from the exemplar) | court-mandated |
| CA4-CONT-001 | Appellee's brief contents: disclosure (28(a)(1)), table of contents (28(a)(2)), table of authorities (28(a)(3)), summary of argument (28(a)(7)), argument (28(a)(8)), certificate of compliance (28(a)(10)). Jurisdictional statement, statement of the issues, statement of the case and standard of review need not appear unless the appellee is dissatisfied with the appellant's statement. | FRAP 28(b), read from the Cornell LII text, 2026-10-14. | 2026-10-14 | court-mandated |
| CA4-CONT-002 | Conclusion: a short conclusion stating the relief sought. FRAP 28(b) does not list 28(a)(9) among the appellee's requirements, but the template includes a Conclusion and the filed exemplar has one. Kept as a convention. | FRAP 28(a)(9), 28(b); exemplar p. 36. | 2026-10-14 | convention |
| CA4-CONT-012 | Argument sub-headings numbered I., A., 1., a.; the Statement of the Case sub-headings are unnumbered bold lines (as in the exemplar's table of contents). | Exemplar pp. ii–iii, 1–9. | 2026-10-14 | convention |
| CA4-CERT-001 | Certificate of compliance: type-volume statement (word count, excluding FRAP 32(f) parts) and typeface statement (FRAP 32(a)(5), 32(a)(6)). The word count is computed from the markdown body. | FRAP 28(a)(10), 32(g)(1), read as cross-referenced in FRAP 28 (2026-10-14). The exclusions of FRAP 32(f) were **not** re-read; the template and sample follow the exemplar's wording. | partly | court-mandated |
| CA4-CERT-002 | Certificate of compliance, typeface statement names the typeface (`EB Garamond`, vendored). | Exemplar p. 37 gives the form; the typeface line is ours. | — | author |
| CA4-CERT-003 | Certificate of service: date, the document served, and a signature. Shown only when `service.certificate: true`. Placed on the same page as the certificate of compliance when it fits (as in the exemplar). | FRAP 25(d) (the proof-of-service rule; cited from the FRAP committee notes, the text of Rule 25(d) was **not** re-read). | partly | court-mandated |

Rules not checked and therefore not claimed: the Fourth Circuit's Appendix Pagination & Brief Citation Guide (record cites are written as in the exemplar); FRAP 32.1; the Fourth Circuit's local rules on electronic filing of paper copies.

## Markdown contract

A sample is one `.md` file: a YAML frontmatter block, then the body. It follows the ca9 contract (`courts/ninth-circuit/court-of-appeals/README.extra.md`) with these differences.

Frontmatter:

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover "No. ..."; disclosure statement; PDF title. |
| `caption` | yes | Cover caption: each side `names` (one centered line each) and `designation`. "v." is inserted. |
| `proceeding` | yes | Cover: "On Appeal from ...". |
| `judge` | no | Cover line under the proceeding (give the parentheses in the value). |
| `brief_title` | yes | Cover title (in capitals); certificate of service. |
| `party_line` | yes | Cover, bottom right (e.g. `Attorneys for Appellee`). |
| `date` | yes | Cover, bottom left. |
| `phone` | yes | Appended to the last counsel group. |
| `counsel` | yes | Cover counsel block: `names` and `lines` per group. |
| `disclosure` | no | `party`, `role`, `answers` (seven `yes`/`no`, in form order), `signer`, `date`. Omitted: no disclosure page. |
| `signature` | yes | `lead` (lines before the /s/ line), `signer` (printed as `/s/ Name`), `lines` (after it). |
| `service` | no | `certificate: true`, `date` (the sentence's date, e.g. "21st day of March, 2025"), `served_on`. |
| `authorities` | yes if the body links any | Table of authorities registry, as in ca9: `kind` (case, constitution, statute, regulation, rule, other), `name`, `cite`, optional `sort`. |

Body: as ca9, with these template-specific rules.

- Level 1 headings are the sections. The Argument's sub-headings are numbered (level 2 = I., level 3 = A., level 4 = 1., level 5 = a.). Outside the Argument, sub-headings are unnumbered and bold (level 2 and below).
- No addendum. The template has no `# Addendum` section (the exemplar has none).
- No related-cases statement (the exemplar has none; the Fourth Circuit form is not a Form 17).
- Authorities: `[*Case v. Name*, 1 F.3d 1 (4th Cir. 2000)](toa:key)`; short forms link to the same key; a key that is not in `authorities:` stops the build.
- Footnotes: `text[^key]` and `[^key]: text`.
- Escape any line that starts with a list marker: `1\. The question`.

## What the overlay shows

`overlay.sh` pairs each sample page with the exemplar page sharing the most words, then draws the sample in red and the filed page in blue (black where they agree). Read `samples/OVERLAY-chapman-answering-brief.txt` for the pairs.

| Sample page | Paired exemplar page | Read |
|---|---|---|
| 1 cover | 1 | Correct pairing. Layout matches the filed cover's order; the filed cover uses rules of different length and underscores. |
| 2 disclosure | 3 (41%) | Partial match, as expected: the filed disclosure form spans pp. 2–3 and the sample's disclosure is one page. |
| 3 TOC | 4 | Correct. |
| 4–5 TOA | 6, 8 | Correct. Authorities list differs from the exemplar: see known gaps (Burlington). |
| 6–8 Questions Presented, Statement of the Case | 9, 10, 11 | Correct pairing. Line positions differ (EB Garamond is set on a different line pitch from the filed Times New Roman); words agree. |
| 9–10 Procedural History, Summary | 20, 22 | Correct. |
| 11–12 Argument I, II, II.A | 24, 26 | Correct. |
| 13 Conclusion and signature | 1 (**wrong**) | The pairing picks the cover because the signature block repeats cover words; the filed conclusion is p. 44. A text-pairing limit of `overlay.sh`, not a layout fault. Read this page against exemplar p. 44 by hand. |
| 14 certificates | 45 | Correct. |

Overlay: `samples/OVERLAY-chapman-answering-brief.pdf` (14 pages). Visual check: pages 6 and 13 of the overlay were viewed; the red and blue lines are offset by the difference in line pitch and typeface, which is expected from a different typeface, not a layout fault.

## Pages reviewed

The sample PDF was rendered to PNG at 60 dpi (`pdftoppm -r 60`) and every page was viewed.

- Pages 1–13: viewed on the first render (15 pages at that point).
- Page 14: re-rendered and viewed after two fixes (below). Pages 1–13 were byte-identical across the two renders (compared by `cmp`), so the first review still holds for them.

Count: **14 of 14 pages reviewed**.

Defects found in review and fixed:

- The two certificate-of-compliance items ran together as one paragraph. Fixed with a paragraph break.
- The certificate of service was on its own page (15 pages in total). It now follows the compliance certificate on the same page, as in the exemplar. 14 pages total.

## Known gaps

- **Cover color (CA4-COVER-002) is not produced.** The exemplar's cover is white (mean RGB 0.97), as a filed PDF is. FRAP 32(a)(2) makes the appellee's cover red for paper copies. ca9 handles its cover color the same way: not produced. A paper-copy cover needs a red stock or a separate cover file.
- **ECF header is not produced.** The "USCA4 Appeal … Doc … Filed … Pg" header on every page of the exemplar is applied by the court's ECF system on filing.
- **Disclosure statement reproduces the questions and answers only.** The form's bullet instructions are not reproduced. The answers are all "NO" (checked on the exemplar at higher resolution for items 1–3; items 4–7 are the same in the extracted text).
- **Authorities differ from the exemplar.** The sample's table of authorities lists *Burlington Northern & Santa Fe Railway Co. v. White*, which the sample's Von Gunten parenthetical cites. The exemplar's own table omits it. FRAP 28(a)(3) requires every cited authority, so the sample lists it.
- **Excerpt, not the whole brief.** The sample transcribes about 1,734 words of 9,350. Pages of the filed argument (II.A.1 onward, II.B, III, the footnotes after note 1) are not in the sample. Its TOA lists only the authorities of the transcribed part.
- **Typeface.** EB Garamond, not Times New Roman. The certificate names the typeface honestly. FRAP 32(a)(5) is met at 14 pt.
- **Word count** is computed from the markdown (headings, text, footnotes, quotations; not the cover, tables or signature). It is not a Word count, and for this excerpt it is not the filed count.
- **"prima facia"** in the source (Section II.A) is the filer's spelling and is kept as transcribed.
- **Typst page numbers in the TOC and TOA** are for this excerpt; they do not match the exemplar's page numbers, which belong to the full brief.
- **No check gate.** This folder has no `checks.yaml` and no `tools/check.sh` gate of its own; it is a structure and rendering check.
