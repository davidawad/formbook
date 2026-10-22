# N.D. Alabama (alnd): motion brief (memorandum in support of a motion)

- Court: `alnd`, United States District Court for the Northern District of Alabama (`courts/eleventh-circuit/alabama/federal/northern-district/`)
- Doc type: `motion-brief`. The memorandum that accompanies a Rule 12(b) motion, with a table of contents and a table of authorities, the body, the signature block and a certificate of service.
- Exemplar: `usage/FILED-EXAMPLE-motion-brief.pdf` (*The Southeastern Conference v. Rousse, et al.*, No. 2:26-cv-01586-ACA, Doc. 27-1, filed 2026-09-25, 33 pages; provenance in `usage/SOURCE.md`). Re-downloaded from CourtListener RECAP on 2026-10-14. The companion motion (Doc. 27) is a separate filing and is not part of this exemplar.
- Sample: `usage/INPUT-motion-brief.md` (excerpt of the memorandum; see Known gaps).
- Status: template present, render and overlay re-run on 2026-10-14 (fonts pass: no face named by the court's rules; the template is now Times New Roman, the house standard, `docs/FONTS.md` rule 6; see Typeface), one layout defect fixed (below); every page of the render reviewed (10 of 10, on the earlier EB Garamond render, before fb-595.68). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `alnd-motion-brief`. |
| `typst/alnd-motion-brief.typ` | Template. Parameter block at the top: typeface (Times New Roman 12 pt), double spacing (24 pt pitch), paragraph spacing, margins, headings, table of contents and table of authorities built from the body's links. |
| `usage/INPUT-motion-brief.md` | Markdown contract sample: YAML frontmatter (court, caption, case number, title, date line, signature, certificate, authorities) plus the body in markdown. Citations to authorities are links of the form `[text](toa:key)`. |
| `usage/OUTPUT-motion-brief.typst.pdf` | `sh tools/render.sh courts/eleventh-circuit/alabama/federal/northern-district/motion-brief usage/INPUT-motion-brief.md` (10 pages: cover, TOC `i`, TOA `ii`, body 1 to 7). |
| `usage/OVERLAY-sec-motion-brief.pdf`, `OVERLAY-sec-motion-brief.txt` | `sh tools/overlay.sh courts/eleventh-circuit/alabama/federal/northern-district/motion-brief sec-motion-brief` (red = ours, blue = filed, black = agree). |
| `usage/` | The filed exemplar and `SOURCE.md`. |

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

The copy read is the 2019 revision (`ALND Local Rules Revised 12-04-2019`, <https://www.alnd.uscourts.gov/sites/alnd/files/ALND%20Local%20Rules%20Revised%2012-04-2019.pdf>), read 2026-10-14: headed "(Effective December 4, 2019)", PDF modified 2019-12-09. The LR 5.5 and 5.6 text above matches it. The template header cites "rev. Dec. 4, 2019", which is the same revision.

Judge's standing orders are not local rules and are not applied here (see Typeface for one that names a face). Page limits in a judge's order are not checked for this template.

## Typeface

| Face required | Vendored substitute | Fit |
|---|---|---|
| None. The court's Local Rules (2019) name no typeface, so the template (typst and docx) uses the house standard, Times New Roman (`docs/FONTS.md` rule 6; EB Garamond until fb-595.68). | Times New Roman (the pinned install, `docs/FONTS.md` rule 1) | n/a |

A single judge's standing order can set a face for that judge's cases. Judge Johnson's Initial Order (Huntsville, `https://www.alnd.uscourts.gov/sites/alnd/files/HNJ%20Initial%20Order%20without%20Rule%2026%20Language.docx`, read 2026-10-14) says "The parties motions and briefs shall be in Times New Roman font and 14-point type", double-spaced, with footnotes in 12 pt. It binds only that judge's cases and is not a court rule, so this template does not follow it. A per-judge variant (Liberation Serif, 14 pt; `docs/FONTS.md` "Times New Roman") would be a separate template and is not built here.

The filed exemplar's body text is Times New Roman (`pdffonts` on the exemplar, 2026-10-14). The overlay compares against it as a visual reference only; that is not a rule, and the layout is not changed to match it.

## Layout defect found and fixed in this pass (on the earlier EB Garamond template, before fb-595.68)

The first render had overprinted lines at every paragraph break in the body: the last line of one paragraph and the first line of the next sat 8.4 pt apart instead of 24 pt, so the two lines printed on top of each other (at the paragraph breaks on body pages 1 to 4, PDF pages 4 to 7). Cause: the body's paragraph `spacing` was 0 pt, and the leading was dropped between paragraphs (the 24 pt pitch is the 15.6 pt leading plus the 8.4 pt line box). Fix in `typst/alnd-motion-brief.typ`: the paragraph spacing is now `body-leading`, which restores the pitch. Measured on the render: the first line of the paragraph after "...(2013)." moved from 8.5 pt to 24 pt below the line before. A scan of every page for line gaps under 12 pt (`pdftotext -bbox`) finds none. The body grew from 6 to 7 pages as a result (the render is 10 pages in total).

## Overlay

`usage/OVERLAY-sec-motion-brief.pdf` (measured on the earlier EB Garamond render, before fb-595.68) puts our render (red) over the best-matching exemplar page (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run:

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

Every page of `OUTPUT-motion-brief.typst.pdf` was rasterized (`pdftoppm -r 60`) and viewed: 10 of 10 (the earlier EB Garamond render, before fb-595.68). Typst printed no warnings. Only EB Garamond was embedded then. The page numbers in the table of contents and the table of authorities come from the live layout, so they were read off the final render.

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

## Engines

The docx engine (`docx/`: `fb render --engine docx` builds the reference document from `reference.xml`, the cross-engine recipe, `base="xengine"`, in the typst template's face, and runs the passes, see below; `alnd-motion-brief.lua` builds the cover, the contents, the authorities, the body's heading labels, the signature block and the certificate) renders `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (the LibreOffice conversion). Every page of the `.docx.pdf` (10 of 10) was rasterized (`pdftoppm -r 60`) and compared with the typst render of the same sample (on the earlier EB Garamond renders, before fb-595.68).

Two passes for the contents and the authorities (as recorded before fb-595.68, when `docx/render.sh` and `pages.awk` ran them; `fb render` runs the passes now, `docs/DOCX.md`): pass 1 writes the heading texts and the citation texts; LibreOffice renders it; `pdftotext` finds the body page of each (`pages.awk`: a heading or citation is found on the page where it starts, also when it runs on into the next page); pass 2 writes the page numbers into the contents and the authorities. The body pages are the same in both passes, which the contents page numbers were checked against.

| Item | typst (primary) | docx |
|---|---|---|
| Typeface, spacing, margins | Times New Roman 12 pt, 24 pt pitch, 1 in margins | same |
| Cover | court, caption with the civil action number, title; no page number | same |
| Contents and authorities | roman i, ii; dot leaders; `passim` from 7 pages | same; the contents page numbers match the headings' pages in the PDF |
| Body | arabic from 1; heading labels I., A., 1., a. | same, labels as text with a hanging indent |
| Signature block | date, two firms side by side, the lines below | same, kept together with the date |
| Certificate of service | own page; text, date and signature | same; the date and signature are at the left margin, as the typst render has them |

What differs:

- Headings (recorded before fb-595.68, on EB Garamond 13 pt): the typst template set no size for its headings, so they take typst's default heading size: the level 1 glyph box measures 23.8 pt against 17.0 pt for body text (about 1.4 times, `pdftotext -bbox`). The docx keeps 13 pt bold for every heading. If the larger size is wanted, the typst template needs a size and the docx reference needs the same value.
- Certificate: the typst template places the date and signature on the right (`h(1fr)`), but the typst render has them at the left margin. The docx follows the render, not the intent; the right-hand placement is a question for the typst template.
- Pagination (on the earlier EB Garamond renders, before fb-595.68): LibreOffice breaks lines at different points, so some headings move a page (for example "II. The SEC Turns to Federal Court." is on body page 3 in the docx and page 2 in typst). The docx contents gives the docx page, which is the one a reader of the docx sees.
- Word was not available. The `.docx` was not opened interactively; a headless LibreOffice conversion cannot show a repair prompt.

docx BLOCKED items:

- `BLOCKED: TA/TOA fields (docs/DOCX.md, "Use the Word-native feature"): the authorities are typed entries with the page numbers of the first pass, not TOA fields. LibreOffice does not evaluate TA/TOA fields; Word would not update them either. A body edit needs a re-render (`sh tools/render.sh --engine docx`, i.e. `fb render --engine docx`) for the numbers to follow.`
- `BLOCKED: TOC field update: the contents is a TOC field whose cached result holds the first-pass page numbers. LibreOffice does not update it on load, so the numbers are right only for the LibreOffice layout (docs/DOCX.md, "Known limits"); Word may paginate slightly differently.`
- `BLOCKED: tools/check.sh --engine docx: not run, because the court folder has no checks.yaml yet.`

## Known gaps

1. The sample is an excerpt of the 33-page memorandum. It transcribes the cover, TOC, TOA, the introduction, the background (I in part, II in part), Argument I.A (in part), the conclusion, the signature block and the certificate of service. Argument I.B and I.C, and Arguments II to IV, are headings only; their text is not transcribed. Footnotes are not transcribed.
2. The table of authorities is built only from the `toa:` links in the body: it lists the authorities the sample cites, not every authority in the filed brief. A link inside a heading is not allowed (it would list as an authority).
3. The page references in the TOA are computed by the template from the body's pages, not copied from the filed exemplar.
4. The judge's standing order, which may set page, typeface or word limits for briefs, was not checked. The template sets no length limit.
5. The certificate of service is the CM/ECF wording of the sample; it does not list unregistered recipients.
6. The typeface is Times New Roman, the house standard (`docs/FONTS.md` rule 6), because the court's rules name no face. The 14-point Times New Roman rule in Judge Johnson's standing order is not applied (see Typeface).
7. The 2019 local rules are read (see Governing rules).
