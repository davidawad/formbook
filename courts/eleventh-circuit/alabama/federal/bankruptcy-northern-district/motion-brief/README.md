# alnb: motion with memorandum (typst)

Court: United States Bankruptcy Court, N.D. Alabama (`alnb`). Doc type: motion (a Rule 12 motion with the argument embedded, one filed document; no table of contents or authorities).

Status of this folder: typst template and one transcribed sample rendered and overlaid. **No latex or docx engine, no `rules.md`, no check stamp, no Gate 1 checker.** `court.json` is untouched.

## Files

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-dombrowski-v-american-estate-17-80079-motion-brief.pdf` | Primary exemplar: United States' Rule 12 motion, Doc 37, 11 pages, filed 2018-05-07 (US DOJ counsel) |
| `exemplars/FILED-EXAMPLE-wright-v-belmont-hill-19-80069-motion-brief.pdf` | Second filer: NCS Rule 12(b)(6) motion, Doc 6, 8 pages, filed 2019-10-14 (private counsel) |
| `typst/main.typ` | Entry point; reads `--input sample=` (default: the Dombrowski sample) |
| `typst/alnb-motion-brief.typ` | Template: caption, title, body, signature block, certificate of service |
| `samples/INPUT-dombrowski-motion-brief.md` | Transcription of the Dombrowski motion (frontmatter = caption, title, signature, date) |
| `samples/OUTPUT-dombrowski-motion-brief.pdf` | Our render, 11 pages, every font embedded |
| `samples/OVERLAY-dombrowski-motion-brief.pdf` / `.txt` | Red = ours, blue = filed, black = both; the `.txt` is the page map |

Render: `sh tools/render.sh courts/eleventh-circuit/alabama/federal/bankruptcy-northern-district/motion-brief samples/INPUT-dombrowski-motion-brief.md` (exit 0, no typst warnings). Overlay: `sh tools/overlay.sh <court-dir> dombrowski-motion-brief`.

## Rules cited

Checked 2026-10-14 against the N.D. Ala. Bankruptcy Local Rules, March 1, 2023 revision (`https://www.alnb.uscourts.gov/sites/alnb/files/Local%20Rules%20Mar%201%202023.pdf`, 35 pages, read in full by text extraction).

| ID | Source | Kind | What the template does |
|---|---|---|---|
| ALNB-CERT-001 | N.D. Ala. Bankr. L.R. 9013-3 (Eff. 12/1/2017): "Any certificate of service filed in this Court must list the names and addresses of all parties served." | M | The certificate lists every party served, with address, on a page of its own (`# CERTIFICATE OF SERVICE` in the sample). |
| ALNB-FORM-001 | The local rules contain **no** typeface, point size, margin, line spacing, paper size, or page-limit rule for motions. The index has no Rule 9013-1 and no rule on the form of papers. | none | Nothing is mandated. Choices below are conventions taken from the exemplars. |

Tier 1 for this court is therefore one requirement (ALNB-CERT-001). Everything else is tier 2 or 3 and was judged against the two exemplars.

Not verified in this session, so not cited as rules: the national Federal Rules of Bankruptcy Procedure text on paper and legibility (FRBP 9004) and FRBP 9013. Both exemplars are letter size (612 x 792 pt), which the template follows.

## Choices (tier 2, judged against the two exemplars)

| Choice | Template | Dombrowski (US) | Wright (private) | Status |
|---|---|---|---|---|
| Body type | EB Garamond 12 pt (vendored) | Times New Roman 12 pt (embedded TrueType) | Times New Roman body, Arial Bold headings | Gap, see below |
| Margins | 1 inch all sides | left 1.5 in, top 1 in | left 1 in | Open choice: one filer each way |
| Caption | court header, `)` column, right column for case/chapter/adv. no. | `)` column | `§` column | Open choice: `)` used, `§` not |
| Page number | arabic, centred, on every page | none on page 1, centred after | running footer "Page n" | Open choice |
| Headings | I./A. typed in the text, bold caps for point headings, bold sub-headings hang | same scheme | same scheme | PASS |
| Signature | "Dated:" left, "Respectfully submitted," at the centre column, `/s/` line, OF COUNSEL | same | same | PASS |
| WHEREFORE | kept with the signature block (no signature alone on a page) | WHEREFORE on p.9, signature p.10 | n/a | PASS |

## Overlay (`samples/OVERLAY-dombrowski-motion-brief.pdf`)

Page map (`.txt`): our page n pairs with filed page n, for all 11 pages (word overlap 58% to 91%). What the overlay shows:

- Horizontal offset: the filed body text starts at 1.5 in (measured: x = 108 pt on page 2); ours starts at 1 in. Every line of the body shows the difference.
- The filed ECF footer ("Case 17-80079-CRJ Doc 37 Filed 05/07/18 ...") appears only in blue. It is the court's stamp, which the template does not reproduce (see `exemplars/SOURCE.md`).
- Vertical positions and line pitch were not measured against the filed pages in this pass; the overlay was looked at at 60 dpi only.

The overlay is a diagnostic, not a score (tier 3 differences are left alone).

## Gaps

1. **Typeface.** The exemplars use Times New Roman. Only EB Garamond is vendored in `fonts/`, and system fonts are not allowed, so the template uses EB Garamond at 12 pt. This is a visible difference on every page. Fix: vendor a Times-metric font with its licence, then switch `font-family`.
2. **Margins.** Dombrowski uses 1.5 in left; Wright uses 1 in. The template uses 1 in. Which to follow is David's call (no rule decides it).
3. **Page 1 number.** Dombrowski has none on page 1; the template numbers it. Left as an open choice.
4. **Caption glyph.** `)` (Dombrowski) versus `§` (Wright). The template uses `)`.
5. **Sample.** One sample, transcribed from the Dombrowski motion, with its typos kept as filed ("Dombrowksi", "121 F.35", "Plaintiff"). The sample is not structurally different from the exemplar, so it does not test generalization. A second sample (a shorter motion with no argument headings, for instance) would.
6. **Gate 1 / check stamp.** There is no `rules.md` and no `checks.yaml` for this court, so `tools/check.sh` is not run and no stamp is written. The only mechanical requirement is ALNB-CERT-001.
7. **Latex and docx.** Not started.

## Pages reviewed

All 11 pages of the final render were viewed as PNG (80 dpi): 1 caption and opening, 2 to 7 body and argument, 8 footnote 1 and sovereign immunity, 9 end of argument, 10 WHEREFORE with the signature block, 11 certificate of service.
