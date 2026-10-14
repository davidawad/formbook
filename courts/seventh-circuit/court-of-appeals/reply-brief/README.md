# Court of Appeals for the Seventh Circuit: reply brief (`ca7` / `reply-brief`)

Status of this doc type: exemplar yes (2 filers), typst template built, sample rendered, overlay built, every page reviewed.
Not wired into the court-level eval loop (no `rules.md`, `checks.yaml` or `check.sh` gates for this folder; see "Known gaps").

## Governing rules

Rules verified 2026-10-14 against the Seventh Circuit's own rules PDF, https://www.ca7.uscourts.gov/assets/pdf/rules.pdf
(the Federal Rules of Appellate Procedure and Circuit Rules as printed there). The FRAP 32 text was cross-checked against
https://www.law.cornell.edu/rules/frap/rule_32. The PDF carries no effective date in its text; re-verify if the court amends
its rules.

| ID | Rule | Page of the PDF | What it sets |
|---|---|---|---|
| CA7-FORM-001 | FRAP 32(a)(1), (3) | 85-86 | Paper reproduction: 8½ x 11, one side. Binding and flatness: Cir. R. 32(a) relaxes "lie reasonably flat". |
| CA7-COV-001 | FRAP 32(a)(2)(A)-(F) | 86 | Cover contents: case number centered at top; court name; case title; nature of proceeding and court below; title of brief identifying the party; counsel's name, office address and telephone. FRAP 32(a)(2) makes a reply brief's cover **gray**; see Known gaps 1. |
| CA7-FORM-003 | FRAP 32(a)(4) | 86 | Margins at least 1 inch on all four sides; page numbers may sit in the margin. |
| CA7-FORM-004 | FRAP 32(a)(4) | 86 | Text double-spaced; quotations over two lines may be indented and single-spaced; headings and footnotes single-spaced. |
| CA7-FORM-005 | FRAP 32(a)(5)(A), **Cir. R. 32(b)** | 86, 89 | Proportionally spaced serif face. FRAP asks 14 pt; **Cir. R. 32(b) replaces it with 12 pt body and 11 pt footnotes.** The template uses those. |
| CA7-FORM-006 | FRAP 32(a)(6) | 86 | Plain roman type; italics or bold for emphasis; case names italicized or underlined. |
| CA7-LEN-001 | FRAP 32(a)(7)(B)(ii), **Cir. R. 32(c)** | 87, 89 | Reply brief: **no more than 7,000 words** (Cir. R. 32(c)); FRAP's 6,500 is replaced by the circuit rule. |
| CA7-LEN-002 | FRAP 32(f) | 88 | Excluded from the count: cover, TOC, TOA, certificate of counsel, signature block, proof of service. Headings and footnotes count. |
| CA7-CERT-001 | FRAP 32(g)(1)-(2), Form 6 | 88, 127-128 | Certificate of compliance: type-volume limit (the word count), in Form 6's wording. Form 6 is stated to satisfy the rule. |
| CA7-CERT-002 | Form 6 (typeface and type-style paragraph); FRAP 32(a)(5)-(6) | 127 | Typeface statement: the word processor (here Typst 0.15.0), body size and footnote size. |
| CA7-CONT-001 | FRAP 28(c) | 69 | A reply brief must contain a table of contents with page references and a table of authorities (cases alphabetically, statutes, other authorities) with reply-brief page references. |
| CA7-CONT-002 | FRAP 28(a)(2), (3) (applied to reply by 28(c)) | 68-69 | TOC and TOA as above. |
| CA7-SVC-001 | FRAP 25(d)(1) | 58 | Proof of service needed if served other than through the court's e-filing system. The template prints a CM/ECF certificate anyway, as the exemplar does. |
| CA7-SVC-002 | Cir. R. 31(b) | 84 | Clerk accepts ten copies as substantial compliance; the certificate states the number of paper copies when `service.paper_copies` is given. |
| (not generated) | FRAP 26.1; Cir. R. 26.1(a)-(b) | 63, 64 | Corporate disclosure and the attorney disclosure statement are **separate filings**, not part of the brief. The exemplar has none. |

## Layout

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits the frontmatter, calls the template. |
| `typst/ca7-reply-brief.typ` | The template: `ca7-reply-brief(meta, md)`. Content-agnostic. Every number is a named parameter at the top and traces to a rule ID above. |
| `samples/INPUT-act-now-reply-brief.md` | Markdown transcribed from the primary exemplar (cover, the body through Point II.A, the conclusion, the certificate metadata). A portion, not the whole brief. |
| `samples/OUTPUT-act-now-reply-brief.pdf` | `sh tools/render.sh courts/seventh-circuit/court-of-appeals/reply-brief samples/INPUT-act-now-reply-brief.md`. 12 pages. |
| `samples/OVERLAY-act-now-reply-brief.pdf`, `-overlay.txt` | `sh tools/overlay.sh courts/seventh-circuit/court-of-appeals/reply-brief act-now-reply-brief`. Red = ours, blue = filed, black = both. |
| `exemplars/FILED-EXAMPLE-act-now-v-doe-26-2473-reply-brief.pdf` | Primary exemplar: the whole 19-page reply brief, 26-2473. |
| `exemplars/FILED-EXAMPLE-d-ambrosio-25-2231-reply-brief.pdf` | Second filer, for the tier-2 cross-check: a motion (pp. 1-3) with the reply brief attached (pp. 4-17). |
| `exemplars/SOURCE.md` | Filer, case, docket, date filed, URL, date fetched, for both. |

Build, from the repo root:

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (see the setup note in the PR)
sh tools/render.sh courts/seventh-circuit/court-of-appeals/reply-brief samples/INPUT-act-now-reply-brief.md
sh tools/overlay.sh courts/seventh-circuit/court-of-appeals/reply-brief act-now-reply-brief
```

The template is built with the vendored fonts only (`--ignore-system-fonts`) and the vendored cmarker package. Any typst
warning fails the render. The render was clean.

## Markdown contract

Frontmatter (YAML), then the body.

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Top of the cover (FRAP 32(a)(2)(A)); PDF title. |
| `caption` | yes | Two sides, each `names` (one line each) and `designation`. "v." between. |
| `proceeding` | yes | "On Appeal from ..." (FRAP 32(a)(2)(D)). |
| `district_court_case`, `judge` | no | "No. X (judge)" under the proceeding. |
| `brief_title` | yes | Cover title (FRAP 32(a)(2)(E)), also the description on the service certificate. |
| `counsel` | yes | Groups of `names` and `lines` (office address and telephone go in `lines`, FRAP 32(a)(2)(F)). `column: right` puts a group in the right-hand cover column. |
| `counsel_note` | no | Italic line closing the right column (e.g. "Attorneys for ..."). |
| `signature` | yes | `signer` (printed as `/s/ Name` and in capitals) and `lines` under it. |
| `date` | yes for the certificate of service; printed as "Dated:" under the signature | |
| `authorities` | yes if the body links to any | Registry, `kind` one of `case`, `constitution`, `statute`, `regulation`, `rule`, `other`. |
| `service` | no | `certificate: true` adds the certificate of service; `paper_copies: N`; `unregistered: [{name, address}]`. |

Body: `##` is a point heading (I., II., III.), `###` is A., `####` is 1., `#####` is a. (numbered automatically; do not type the
numbers). `#` is not used. Authorities: `[*Rust v. Sullivan*, 500 U.S. 173 (1991)](toa:rust)`. Footnotes:
`text[^key]` with `[^key]: text` anywhere in the file. Word count: everything in the markdown is counted, footnotes
included; the cover, TOC, TOA and certificates are not.

## Visual review (Gate 2 by eye)

All 12 pages of `OUTPUT-act-now-reply-brief.pdf` were rasterized at 60 dpi and viewed. Pages 9-10 were re-viewed after the
signature-block fix.

| PDF page | Printed page | Content | Finding |
|---|---|---|---|
| 1 | (none) | Cover | Case number at top; court name; caption; proceeding; title; two-column counsel. Fits one page. OK. |
| 2 | ii | TOC | Point and sub-point entries with dot leaders, page column right. OK. |
| 3 | iii | TOA | Cases only (the sample cites no statutes). Page references computed. OK. |
| 4 | 1 | Body | Double-spaced: 27.7 pt baseline pitch, 23 lines per page. Point I heading. OK. |
| 5 | 2 | Body, footnotes 1-2 | 11 pt footnotes, single-spaced, separator rule. OK. |
| 6 | 3 | Body | OK. |
| 7 | 4 | Body | Pilcrow pair "¶¶" in a record citation renders with the vendored face. OK. |
| 8 | 5 | Body, Point II | OK. Footnote 3 (Nieves, FKFJ) on the page. |
| 9 | 6 | Body, II.A, footnote 6 | Large gap above the footnote block: the conclusion moved to the next page with its signature (see below). Accepted. |
| 10 | 7 | Conclusion, signature | Conclusion and signature block on one page (not alone). OK. |
| 11 | 8 | Certificate of compliance | Form 6 content; word count computed (2,085). OK. |
| 12 | 9 | Certificate of service | CM/ECF statement; Cir. R. 31(b) paper copies. OK. |

Pages reviewed: 12 of 12.

## Overlay (diagnostic, not a score)

`samples/OVERLAY-act-now-reply-brief.txt`: each of our pages is paired with the filed page sharing most words (the tool's
pairing, not a verified alignment). Lowest word overlap: ours p.3 (TOA, 36%: the filed TOA lists more authorities than the
transcribed portion), ours p.10 (conclusion and signature, 38%: paired with filed p.17, which is outside the transcribed
portion), ours p.11 (certificate, 46%: different certificate wording). These reflect what the sample omits or words
differently, not layout defects; the page-by-page review above is the layout check.

## Word count check

Template count (certificate): 2,085 words, computed from the markdown with Word's whitespace rule. Cross-check: the PDF's
text for the body pages, excluding page numbers and the signature block, comes to about 2,050 words (headings and footnotes
included). The difference is about 2%. The certificate number is the template's count; before filing a real brief, confirm it
in the word processor the brief was typed in.

## Known gaps

1. **Gray cover (FRAP 32(a)(2)).** The rule says a reply brief's cover is gray. The template renders the e-filing PDF with a
   white cover, as the exemplar does. The rule text does not limit the color to paper, but whether the court's e-filing PDFs
   carry the gray cover was not verified here. **Open question for David: does the e-filing PDF need the gray cover?**
2. **Body typeface.** The vendored fonts (`fonts/`) contain EB Garamond only. The exemplar is Times New Roman 12 pt. EB Garamond
   at 12 pt is rule-compliant (Cir. R. 32(b)) but looks smaller on the page than TNR 12. A Times-metric face is not vendored; not
   added here (a shared font change belongs to the tools/fonts owners).
3. **Court's e-filing header.** The exemplar's top line ("Case: 26-2473 Document: 29 Filed ... Pages: 19") is added by the
   court's system at filing, not by the brief. The template does not reproduce it.
4. **Disclosure statement.** Not generated: it is a separate attorney filing (Cir. R. 26.1), and the exemplar has none.
5. **Addendum and appendix.** Not supported. A reply brief with a short appendix would need a template change.
6. **Portion only.** The sample transcribes the introduction, Point I, Point II and II.A (in part), and the conclusion. Point II.B
   and Point III are not transcribed. The rule compliance of the template does not depend on this; it is a visual sample.
7. **Exemplar citation error, not copied.** The ACT NOW certificate says the type-volume limit is "Circuit Rule 29". The
   limit is Circuit Rule 32(c). The template follows the rule.
8. **Signature block.** Only the signer, firm and telephone are transcribed; the exemplar's full signature block was not
   separately verified beyond the cover.
9. **No automated gates.** There is no `checks.yaml` / `check.sh` / stamp for this doc type. The review above is by eye, one
   page at a time, and the word count is a cross-check, not a gate.
10. **Tier 2 with two filers.** Two filers, two firms (ACT NOW: Eimer Stahl; D'Ambrosio: Trent Law Firm), which meets the
    eval loop's minimum. The D'Ambrosio file is used as a cross-check of the cover, TOC, TOA and certificate layout; it was not
    overlaid, because the overlay tool reads the first exemplar only.

[Formbook index](../../../../README.md) | [Court README](../README.md)
