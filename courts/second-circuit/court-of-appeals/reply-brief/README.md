# Second Circuit: reply brief (`ca2`, doc type `reply-brief`)

Status of this doc type (2026-10-14): **exemplar=yes, render=ok, overlay=ok, pages_reviewed=14** (every page of the sample PDF rendered at 60 dpi and looked at; see "Page review").

This folder is self-contained. The court's rules (below) decide the layout; the filed exemplars settle only what the rules leave open.

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-lowe-moneylion-26-655-reply-brief.pdf` | Primary exemplar: reply brief of defendant-appellant MoneyLion, 2d Cir. No. 26-655, filed 2026-09-10 by counsel. 45 pages, text layer. |
| `exemplars/FILED-EXAMPLE-alisigwe-24-960-reply-brief.pdf` | Second filer, for conventions only (criminal reply, Federal Defenders of New York). Not transcribed, not overlaid. |
| `exemplars/SOURCE.md` | URL fetched from, case, docket, filer, date filed, date fetched, for both. |
| `samples/INPUT-lowe-reply-brief.md` | Transcription of the Lowe exemplar: cover, tables, Introduction, Argument Points I and II.A, Conclusion, signature, certificates. A portion (about 1,600 of the brief's 6,994 words). |
| `samples/OUTPUT-lowe-reply-brief.pdf` | Render of the sample (14 pages). |
| `samples/OVERLAY-lowe-reply-brief.pdf`, `.txt` | Red/blue overlay of the render on the Lowe exemplar, and the page map. |
| `typst/main.typ` | Entry point; reads `--input sample=...`, splits frontmatter from body, calls the template. |
| `typst/ca2-reply-brief.typ` | The template: `ca2-reply-brief(meta, md)`. Content-agnostic; every number is a named parameter at the top or traces to a rule. |

## Governing rules

Verified 2026-10-14. The Second Circuit's own rule text is from its rules page; the FRAP text is from the Cornell LII copy (the official FRAP PDF was not fetched). Rule IDs in the template comments refer to this table.

| ID | Rule | Requirement | Where | Source |
|---|---|---|---|---|
| CA2-LEN-001 | 2d Cir. Local Rule 32.1(a)(4)(B) | Reply brief: no more than **7,000 words**. (Principal brief: 14,000, rule 32.1(a)(4)(A).) The template panics above 7,000. | `word-limit` | https://www.ca2.uscourts.gov/clerk/case_filing/rules/title7/local_rule_32_1.html |
| CA2-FORM-000 | 2d Cir. Local Rule 32.1(a) | Briefs "must conform to FRAP 32(a)", except as the local rule sets out. | whole template | same |
| CA2-COVER-001 | 2d Cir. Local Rule 32.1(a)(1) | Cover title names the party or parties; the docket number "in type at least one inch high". | `docket-size = 72pt` | same |
| CA2-COVER-002 | FRAP 32(a)(2)(A)-(F) | Cover: docket number at top; court name; title of the case; nature of the proceeding and the court below; brief title identifying the party; counsel's name, office address, telephone. | `cover-body` | https://www.law.cornell.edu/rules/frap/rule_32 |
| CA2-FORM-002 | FRAP 32(a)(4) | Margins at least one inch on all four sides. | `page-margin = 1in` | same |
| CA2-FORM-004 | FRAP 32(a)(5)(A) | Proportionally spaced face, **14-point or larger** (text, headings, footnotes, cover, certificates). | `type-size = 14pt`, footnotes at `type-size` | same |
| CA2-FORM-005 | FRAP 32(a)(6) | Case names italicized or underlined. The template italicizes what the author marks; it does not guess case names. | markdown | same |
| CA2-CONT-001 | FRAP 28(c) | Reply brief has a table of contents with page references and a table of authorities (cases alphabetized, then statutes and other authorities) with the pages where cited. | `toc-section`, `toa-section` | https://www.law.cornell.edu/rules/frap/rule_28 |
| CA2-CERT-001 | FRAP 32(g)(1), Form 6 | Certificate of compliance stating the word count (FRAP 32(f) exclusions) and the typeface and type-style statements of FRAP 32(a)(5)-(6). | `certificate-of-compliance` | https://www.law.cornell.edu/rules/frap/rule_32 |
| CA2-CERT-002 | FRAP 25(d)(1) | Proof of service is required for service **other than** through the court's electronic-filing system. The certificate of service here is the exemplar's convention (electronic filing). Off unless `service.certificate: true`; the sample sets it on, as the exemplar does. | `certificate-of-service` | https://www.law.cornell.edu/rules/frap/rule_25 |

Also checked: FRAP 28(a) lists the appellant's brief contents and does not apply to a reply brief except as 28(c) says.

## Decisions (where the rules leave a choice)

- **Docket number at 72 pt.** Local Rule 32.1(a)(1) says "type at least one inch high". This template reads it as a 1-inch type size, which is 72 pt; the exemplar's docket line box is about 86 pt tall, consistent with that. A cap-height reading (digits one inch tall) would need about 105 pt type instead. That is not implemented. Open question for David: confirm which reading the clerk applies.
- **Word limit 7,000, not FRAP's 6,500.** FRAP 32(a)(7)(B)(ii) gives half the principal limit (13,000 / 2 = 6,500). The local rule sets its own limits "except as set forth below" (14,000 principal, 7,000 reply). The template uses the local rule. A brief over 6,500 words that is under 7,000 is compliant under the local rule; this is a deliberate choice to check.
- **Double spacing.** The exemplar is double spaced (leading set so the baseline pitch is about 2.2 x type size). The fetched rule text does not require double spacing, so this is a convention (tier 2).
- **Counsel on the cover.** Each counsel group carries its own telephone number (the exemplar does this; FRAP 32(a)(2)(F) requires it per counsel).
- **Signature block.** `Dated:` then `Respectfully submitted,` then the signer, `/s/` form, as in the exemplar. The exemplar also lists the other counsel above the signature; the template prints the signer only (see Known gaps).
- **Cover uses baseline bottom edge.** The cover is one page and the counsel block is long. Body text uses the ascender/descender edges of the ca9 template; the cover alone uses the baseline, because with descender edges the cover measured 679 pt against 648 pt available. This is a typesetting choice, not a coordinate.
- **Certificates on their own pages, numbered on.** Compliance then service, each on its own page, continuing the arabic numbering as in the exemplar.

## Markdown contract (this doc type)

A sample is one `.md` file: a YAML frontmatter block followed by the body. The contract is the ca9 contract (`courts/ninth-circuit/court-of-appeals/README.extra.md`) with these differences:

| Field | Required | Notes |
|---|---|---|
| `case_number` | yes | Docket number, shown at the top of the cover at 72 pt and in the document title. |
| `caption` | yes | List of two sides; each has `names` and `designation` (right-aligned). |
| `proceeding` | yes | "On Appeal from the United States District Court for ..."; printed in capitals. |
| `district_court_case`, `judge` | no | Shown after the proceeding, in capitals: "NO. 1:25-CV-4098, HON. DALE E. HO". |
| `brief_title` | yes | Cover title (capitals, bold) and the certificate of service. |
| `counsel_for` | no | "Counsel for Defendant-Appellant ..." under the cover counsel and in the signature block. |
| `counsel` | yes | Groups of `names`, `lines` (italic: firm, address), and **`phone` (required per group)**. Two columns on the cover. |
| `signature` | yes | `signer` (printed "/s/ Name" and in capitals) and `lines`. |
| `date` | yes | "Dated:" line and the dates on the certificates. |
| `typeface_software`, `typeface` | yes | The certificate's statement: "prepared in a proportionally spaced typeface using X in Y 14-point font". State the truth: `Typst` and `EB Garamond` for these renders. |
| `service` | no | `certificate: true` adds the certificate of service (default off in the template; the sample sets it on, as the exemplar does). |
| `authorities` | yes if the body cites any | As in ca9. Citations link as `[text](toa:key)`; an unknown key stops the build. |

There is no `word_limit_basis`, no addendum, no related-cases statement, no Form 8 check boxes, and no manually counted images: the Second Circuit has no equivalent form in the fetched rules. The word count is computed from the markdown (everything in the body, footnotes included, excluding the cover, tables, signature and certificates).

## Build and check

From the repo root (`PATH` must include the toolchain):

```sh
sh tools/render.sh courts/second-circuit/court-of-appeals/reply-brief samples/INPUT-lowe-reply-brief.md
sh tools/overlay.sh courts/second-circuit/court-of-appeals/reply-brief lowe-reply-brief \
  "$PWD/courts/second-circuit/court-of-appeals/reply-brief/exemplars/FILED-EXAMPLE-lowe-moneylion-26-655-reply-brief.pdf"
```

The overlay is given the Lowe exemplar explicitly: `overlay.sh` with no third argument takes the first PDF in `exemplars/` alphabetically, which here would be the Alisigwe brief.

Render result: `typst compile` with vendored EB Garamond and vendored cmarker 0.1.10, `--ignore-system-fonts`, no warnings, exit 0. `pdffonts` shows only `EBGaramond-Regular`, `-Bold`, `-Italic`, all embedded.

`tools/check.sh` and `tools/check-selftest.sh` are not wired for this doc type; the checks in this folder are the render, the overlay and the page review below.

## Overlay (what it shows)

Red is our render; blue is the filed exemplar; black is where they agree. Pages are paired by word overlap, not index (`samples/OVERLAY-lowe-reply-brief.txt`):

| Our page | Filed page | Word overlap | Note |
|---|---|---|---|
| 1 (cover) | 1 | 95.8% | Cover pairs with the exemplar's cover. |
| 2 (contents) | 2 | 32.3% | Contents layout differs; expected. |
| 3 (authorities) | 3 | 39.0% | Authorities layout differs; expected. |
| 4 (other authorities) | 6 | 12.8% | Spill page; see Known gaps. |
| 5-10 (body) | 7, 8, 9, 11, 12, 13 | 48-89% | Introduction (89%) and the Point I/II opening (89%, 79%) pair closely; Point II.A (48%, 62%) pairs more loosely. |
| 11 (body 7) | 15 | 49.6% | Point II.A continues. |
| 12-14 (conclusion, certificates) | 43, 44, 45 | 50%, 81%, 94.5% | Certificate pages pair with the exemplar's last pages. Page 12 pairs with the exemplar's last page (43), which is the signature page, at 50%. |

The overlay is a diagnostic, not a score. It is a word-overlap pairing; it does not measure leading or margins, which the render's own checks cover (the PDF page size and the 1-inch margins are set in the template, not measured off the exemplar).

## Page review

All 14 pages of `samples/OUTPUT-lowe-reply-brief.pdf` were rendered at `pdftoppm -r 60` and looked at. Physical page numbers: 1 cover; 2-4 contents and authorities; 5-12 body (body pages 1-8); 13-14 certificates.

| Physical page | Finding | Action |
|---|---|---|
| 1 cover | Fits on one page, docket at 72 pt top, counsel in two columns, counsel-for line at the foot. | none |
| 2 contents | Entries and page numbers right; point headings hang under their labels. | none |
| 3-4 authorities | Cases, statutes, rules & regulations, other authorities grouped; passim not triggered in the sample. Page 4 holds only one entry ("Other Authorities", Black's). | accepted, see Known gaps |
| 5-6 Introduction | Left-aligned (ragged right), first-line indents, 14-point. | none |
| 7-8 Argument | Point I heading in capitals, hanging; footnote 1 at 14 pt; "32 C.F.R." broke across a line. | **fixed**: `NNN C.F.R.`, `U.S.C.`, `U.S.`, `F.3d` now stay on one line |
| 9-11 Argument | Point II and II.A headings; footnote 2; short form *Id.* linked. | none |
| 8-9 Conclusion | Before the fix the signature block stood alone on a page after the Conclusion, because the footnote definitions at the end of the markdown were taken as the last paragraph. | **fixed**: the last paragraph before the footnote definitions is kept with its heading and signature block; the definitions render in the same pass as the text that references them. |
| 12 conclusion | Conclusion heading, text, "Dated", signature, counsel-for line on one page. | confirmed after fix |
| 13 certificate of compliance | Word count from the markdown; Local Rule 32.1(a)(4)(B) and FRAP 32(a)(5)-(6) statements; signature. | none |
| 14 certificate of service | Electronic-filing wording; date; signature. | none |

## Known gaps

- **Portion, not whole brief.** The sample transcribes the cover, tables, Introduction, Points I and II.A, and the Conclusion and certificates. The exemplar's Points II.B-IV and the rest of II.A are not transcribed. The word count in the certificate is therefore 1,634, not the exemplar's 6,994.
- **Signature block lists only the signer.** The exemplar also lists the other counsel above the signature. Tier 2, not a rule.
- **Authorities page 4.** The last authority ("Other Authorities") spills to its own page. Cosmetic. Not tried: tighter spacing between groups might pull it back.
- **Word count is not cross-checked.** The template counts words from the markdown with its own rules; the exemplar's 6,994 is the filer's Word count. No independent count and no PDF text check are implemented for this doc type.
- **FRAP text is from the Cornell LII copy,** not the official PDF. The Second Circuit rule is from the court's own page. Both verified 2026-10-14.
- **Rule 32.1 text is the court's rule page, not a certified copy.** The page shows Local Rule 32.1 (not a separate 32.1.1). Its (a)(1)-(a)(4) were quoted, and nothing else from the local rules was used.
- **Cover color, binding, and paper requirements** are not in the fetched rule text and are not implemented.
- **Overlay pairing for the body** is by word overlap, so a sample page can pair with an exemplar page one or two away; read the overlay with the `.txt` page map beside it.
- **Alisigwe exemplar** is kept for conventions only; a second overlay against it is not run.
