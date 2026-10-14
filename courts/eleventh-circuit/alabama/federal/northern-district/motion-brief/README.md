# N.D. Alabama (alnd): motion brief (memorandum in support of a motion)

- Court: `alnd`, United States District Court for the Northern District of Alabama (`courts/eleventh-circuit/alabama/federal/northern-district/`)
- Doc type: `motion-brief`. The memorandum that accompanies a Rule 12(b) motion, with a table of contents and a table of authorities, the body, the signature block and a certificate of service.
- Exemplar: `exemplars/FILED-EXAMPLE-sec-2-26-cv-01586-motion-brief.pdf` (*The Southeastern Conference v. Rousse, et al.*, No. 2:26-cv-01586-ACA, Doc. 27-1, filed 2026-09-25, 33 pages; provenance in `exemplars/SOURCE.md`). Re-downloaded from CourtListener RECAP on 2026-10-14. The companion motion (Doc. 27) is a separate filing and is not part of this exemplar.
- Sample: `samples/INPUT-sec-motion-brief.md` (excerpt of the memorandum; see Known gaps).
- Status: template present, render and overlay re-run on 2026-10-14, one layout defect fixed (below); every page of the render reviewed (10 of 10). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `alnd-motion-brief`. |
| `typst/alnd-motion-brief.typ` | Template. Parameter block at the top: typeface (EB Garamond 13 pt), double spacing (24 pt pitch), paragraph spacing, margins, headings, table of contents and table of authorities built from the body's links. |
| `samples/INPUT-sec-motion-brief.md` | Markdown contract sample: YAML frontmatter (court, caption, case number, title, date line, signature, certificate, authorities) plus the body in markdown. Citations to authorities are links of the form `[text](toa:key)`. |
| `samples/OUTPUT-sec-motion-brief.pdf` | `sh tools/render.sh courts/eleventh-circuit/alabama/federal/northern-district/motion-brief samples/INPUT-sec-motion-brief.md` (10 pages: cover, TOC `i`, TOA `ii`, body 1 to 7). |
| `samples/OVERLAY-sec-motion-brief.pdf`, `OVERLAY-sec-motion-brief.txt` | `sh tools/overlay.sh courts/eleventh-circuit/alabama/federal/northern-district/motion-brief sec-motion-brief` (red = ours, blue = filed, black = agree). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

## Governing rules

Primary sources:

| Rule | Requirement | Where the template uses it |
|---|---|---|
| Fed. R. Civ. P. 7(b)(1)(B), (C) (text read 2026-10-14, <https://www.law.cornell.edu/rules/frcp/rule_7>) | A motion must "state with particularity the grounds for seeking the order" and "state the relief sought." | the memorandum states the motion it supports; not a layout rule |
| Fed. R. Civ. P. 10(a) (text read 2026-10-14, <https://www.law.cornell.edu/rules/frcp/rule_10>) | Caption with the court's name, a title, a file number, and the Rule 7(a) designation. | `cover`: court heading, caption, case label and number, title |
| Fed. R. Civ. P. 11(a) (cited, not re-read, <https://www.law.cornell.edu/rules/frcp/rule_11>) | Signature by at least one attorney of record, with address, email and telephone number. | `signature-block` |
| N.D. Ala. LR 5.5 (text from the court's Local Rules PDF, below) | Documents may be filed, signed and verified by electronic means under the court's General Order on electronic case filing. | the `/s/` signature and the CM/ECF certificate wording |
| N.D. Ala. LR 5.6 (same PDF) | Transmission by the Notice of Electronic Filing constitutes service on each registered Filing User; other parties are served under the rules. | the certificate of service's CM/ECF wording |

The court's Local Rules are at <https://www.alnd.uscourts.gov/local-rules>. The copy read for this README is the PDF linked as "ALND Local Rules" (<https://www.alnd.uscourts.gov/sites/alnd/files/forms/ALND%20Local%20Rules.pdf>), read 2026-10-14. It is undated (PDF metadata: created 2015-12-14), 14 pages, headed "Effective Upon Approval by Circuit Judicial Council". Quoted from it:

> LR 5.5 Filing of Documents By Electronic Means. Documents may be filed, signed and verified by electronic means to the extent and in the manner authorized by the court's General Order regarding Electronic Case Filing Policies and Procedures.

> LR 5.6 Service of Documents By Electronic Means. ... Transmission by the Notice of Electronic Filing constitutes service of the filed document upon each party in the case who is registered as a Filing User.

Its text contains no rule on typeface, font size, margins, spacing, page length or word limit for briefs, or a certificate-of-service requirement. The layout therefore follows the filed exemplar.

**Unverified:** the court's Local Rules page says the rules are "as of December 4, 2019" and links a PDF ("ALND Local Rules Revised 12-04-2019"). That PDF could not be retrieved from this box (the site rejected the request), so the 2019 text is not checked here. The template header cites "rev. Dec. 4, 2019"; that date comes from the court's page, not from the PDF text. Judge's standing orders (which may set page or typeface rules) were not checked.

## Layout defect found and fixed in this pass

The first render had overprinted lines at every paragraph break in the body: the last line of one paragraph and the first line of the next sat 8.4 pt apart instead of 24 pt, so the two lines printed on top of each other (at the paragraph breaks on body pages 1 to 4, PDF pages 4 to 7). Cause: the body's paragraph `spacing` was 0 pt, and the leading was dropped between paragraphs (the 24 pt pitch is the 15.6 pt leading plus the 8.4 pt line box). Fix in `typst/alnd-motion-brief.typ`: the paragraph spacing is now `body-leading`, which restores the pitch. Measured on the render: the first line of the paragraph after "...(2013)." moved from 8.5 pt to 24 pt below the line before. A scan of every page for line gaps under 12 pt (`pdftotext -bbox`) finds none. The body grew from 6 to 7 pages as a result (the render is 10 pages in total).

## Overlay

`samples/OVERLAY-sec-motion-brief.pdf` puts our render (red) over the best-matching exemplar page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run:

```
ours p.1  filed p.1   87.1%   cover
ours p.2  filed p.2   93.4%   table of contents
ours p.3  filed p.3   32.8%   table of authorities (a different layout from the filed page; expected)
ours p.4  filed p.7   60.2%   introduction
ours p.5  filed p.9   69.2%   background
ours p.6  filed p.14  53.2%   Argument I, I.A
ours p.7  filed p.15  77.0%   Argument I.A (continued)
ours p.8  filed p.2   55.3%   Argument headings I.B to IV; conclusion
ours p.9  filed p.32  89.8%   signature blocks
ours p.10 filed p.33  89.4%   certificate of service
```

Pairing is by word overlap, not by layout: the low score for p.3 (table of authorities) is expected, and the p.8 pairing with the filed TOC (p.2) is a word match only, not a layout match. Neither is a layout check.

## Page review (Gate 2)

Every page of `OUTPUT-sec-motion-brief.pdf` was rasterized (`pdftoppm -r 60`) and viewed: 10 of 10. Typst printed no warnings. Only EB Garamond is embedded. The page numbers in the table of contents and the table of authorities come from the live layout, so they were read off the final render.

| Page | Content | Result |
|---|---|---|
| 1 | Cover: court heading, caption, `Civil Action No.`, title | OK. |
| 2 | Table of contents `i` | OK. Page column aligned; CERTIFICATE OF SERVICE on page 7. |
| 3 | Table of authorities `ii` | OK. Only linked citations listed; "Page(s)" column. |
| 4 | Body 1: introduction | OK after the fix. |
| 5 | Body 2: rest of the introduction; BACKGROUND; I and II headings | OK after the fix. |
| 6 | Body 3: Argument I, I.A (standing) | OK after the fix. |
| 7 | Body 4: rest of I.A | OK after the fix. |
| 8 | Body 5: Argument headings I.B to IV; CONCLUSION | OK. |
| 9 | Body 6: date line and the two signature blocks (two firms in columns); `*Admitted pro hac vice` | OK. |
| 10 | Body 7: CERTIFICATE OF SERVICE (CM/ECF wording, date, `/s/` signature) | OK. |

Tier-2 findings (OPEN or ACCEPTED):

- ACCEPTED, p.8 (body 5): Argument I.B, I.C and II to IV are in the sample as headings only; the text under them is not transcribed (see Known gaps). The render shows the headings, not the argument.
- OPEN, p.9 (body 6): the signature blocks start on a new page, after the conclusion ends on p.8; the filed exemplar's page placement was not compared line by line.

## Known gaps

1. The sample is an excerpt of the 33-page memorandum. It transcribes the cover, TOC, TOA, the introduction, the background (I in part, II in part), Argument I.A (in part), the conclusion, the signature block and the certificate of service. Argument I.B and I.C, and Arguments II to IV, are headings only; their text is not transcribed. Footnotes are not transcribed.
2. The table of authorities is built only from the `toa:` links in the body: it lists the authorities the sample cites, not every authority in the filed brief. A link inside a heading is not allowed (it would list as an authority).
3. The page references in the TOA are computed by the template from the body's pages, not copied from the filed exemplar.
4. The judge's standing order, which may set page, typeface or word limits for briefs, was not checked. The template sets no length limit.
5. The certificate of service is the CM/ECF wording of the sample; it does not list unregistered recipients.
6. Only the vendored EB Garamond is available. No Times New Roman or Century Schoolbook is vendored (`fonts/` is shared and not edited here); the typeface is a stated choice, not a rule.
7. The 2019 local-rules text was not retrieved (see Governing rules).
