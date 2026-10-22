# paeb: adversary complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Eastern District of Pennsylvania (`paeb`).
Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `usage/FILED-EXAMPLE-adversary-complaint-2.pdf` (Kang Haggerty LLC, filed 2026-09-21) and `usage/FILED-EXAMPLE-adversary-complaint.pdf` (Salzmann Hughes PC, filed 2026-03-24). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-adversary-complaint.md` (the full filing text, ¶¶ 1 to 88, relief, signature, certificate of service); `usage/INPUT-adversary-complaint-2.md` (an excerpt: caption, ¶¶ 1 to 23, Counts I to V, prayer, signature; see Known gaps) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf` and `.docx.pdf` (13 pages each), `usage/OUTPUT-adversary-complaint-2.typst.pdf` and `.docx.pdf` (9 pages each); vendored Times New Roman only, `--ignore-system-fonts`, no warnings; the docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | ok: `usage/OVERLAY-krueger-complaint.pdf` and `.txt` (against the Krueger exemplar); `usage/OVERLAY-tig-reaper-complaint.pdf` and `.txt` (against the TIG exemplar) |
| pages reviewed | 13 of 13 (Krueger) and 9 of 9 (TIG), on both engines, 2026-10-22 (see "Gate 2 review"). |

Build (from the repo root, PATH per the box setup):

```sh
D=courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/adversary-complaint
sh tools/render.sh $D usage/INPUT-adversary-complaint.md
sh tools/overlay.sh $D krueger-complaint $D/usage/SAMPLE-krueger-26-00127-adversary-complaint.pdf
```

File names follow the tools, which read and write `INPUT-`, `OUTPUT-` and `OVERLAY-` names by default (`tools/render.sh` writes `usage/OUTPUT-<id>.pdf`, `tools/overlay.sh` reads it and writes `usage/OVERLAY-<id>.pdf` and `.txt`). The brief's `<id>.md` / `<id>-overlay.pdf` names were not used so that the tools work unchanged.

## Engines

Engine status: typst and docx (`OUTPUT-<id>.docx` and its LibreOffice `.docx.pdf`) on both samples, every line and page alike (XENG-001..003 gated: 329/329 and 233/233 lines); latex not built (`latex/` is empty).

- **typst** (primary, `typst/`): on the shared cross-engine layout model (`lib/typst/xengine.typ`, fb-595.68.34): a 24 pt body pitch (double spaced), 14 pt single lines (court title, caption rows, title, signature, certificate lists, footer), explicit block spaces (12 pt around a heading, 14 pt between cover parts, 24 pt above the signature and the certificate).
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; it named EB Garamond until fb-595.68.34) and `docx/paeb-adversary-complaint.lua` (on `lib/docx/xengine.lua`), which writes every paragraph: the court title, the caption (a borderless three-column table, one row per single line), the numbered allegations (number at 0.5 in, a tab to 1 in), the WHEREFORE clauses (kept with the next block), the headings, the lists (label at 0.5 in, text hanging at 1 in, labelled by `list_numbering`), the signature block, the certificate of service, the footer (a centred PAGE field, ``) and the section (letter, 1 in margins, ``). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh`, `docx/paeb.lua` and a committed `reference.docx`). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none. `sh tools/check.sh <this folder> --engine docx`: every gate green on both samples.

## Governing rules

Each rule was fetched on 2026-10-14 from the URL shown. Current text of the FRBP and FRCP rules took effect 2024-12-01 (FRBP) or as stated.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding; a pleading's caption must substantially conform to the appropriate version of Form 416. | https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption-rows()`, `caption()` |
| Fed. R. Bankr. P. 9004(a) | A document must be clearly legible. | https://www.law.cornell.edu/rules/frbp/rule_9004 | 12 pt type, black text, no decoration |
| Fed. R. Bankr. P. 9004(b) | Caption: (1) the court's name; (2) the case's title; (3) the case number and, if appropriate, the adversary-proceeding number; (4) a brief designation of the document's character. | same | `court-title()`; `caption-rows()` (`Chapter`, `Case No.`, `Adv. Proc. No.`); `title` |
| Fed. R. Civ. P. 10(a) (applied by 7010) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." | https://www.law.cornell.edu/rules/frcp/rule_10 | as 9004(b) |
| Fed. R. Civ. P. 10(b) (applied by 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | same | `body-pieces()` numbers every paragraph in order; headings and lists are not numbered |
| Fed. R. Bankr. P. 7008(a) | "In an adversary proceeding before a bankruptcy court, a complaint … must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | https://www.law.cornell.edu/rules/frbp/rule_7008 | not rendered by the template: it is author content in the body (see Known gaps, 3) |
| L.B.R. 9004-1(b) (PAEB Local Rules, Dec. 1, 2025) | A paper document shall measure 8½ × 11 inches and be stapled or fastened at the top. | https://www.paeb.uscourts.gov/sites/paeb/files/PAEB%20Local%20Rules%20-2025-12-01%20Final.pdf | `page(paper: "us-letter")` |
| L.B.R. 7003-1 (same PDF) | A paper complaint is filed with the Adversary Proceeding Cover Sheet provided by the Clerk. | same | not generated (see Known gaps, 4) |

No E.D. Pa. rule on the typeface, type size, margins, line spacing or page limit was found: I searched the text of the local-rules PDF (93 pages) for font, point, margin, spacing and page limit, and read FRBP 9004 (current text), which has only legibility and caption subdivisions. The typeface, size, margins and spacing are therefore conventions, judged against the two filed exemplars, not mandated form.

## Layout (conventions, judged against the exemplars)

- Letter paper, 1 inch margins, page number centered at the foot.
- Court name in bold capitals, two lines, centered (the exemplars use the same two-line court title).
- Caption: a three-column table. Party column, a column of colons, and a case column with `Chapter`, `Case No.` and `Adv. Proc. No.`. Long party names are written as one row per line in the sample, so the colons line up.
- Title in bold, centered. The lead-in (unnumbered) follows.
- Double spacing (24 pt line pitch at 12 pt), no extra space between paragraphs. An allegation's number at 0.5 in, its text from 1 in. Headings on the body pitch with 12 pt above and below: level 1 bold capitals, centered; levels 2 and 3 bold, left. Headings and WHEREFORE lead-ins stay with the text that follows them.
- Lists are lettered `(a)`, or roman `(i)` when the sample sets `list_numbering`: the label at 0.5 in, the text hanging at 1 in.
- Signature block: "Dated" at left and "Respectfully submitted," with the firm, `By: /s/` and the lines given at right. The last paragraph (a list's last item) stays on the page with the signature block, so a signature never stands alone.
- Optional certificate of service (`certificate:` in the frontmatter), on the page after the signature.

## What the overlay shows

`OVERLAY-<id>.pdf` puts our render in red and the filed exemplar in blue, page against page. The `.txt` map pairs each of our pages with the exemplar page that shares the most words. Both samples are excerpts or transcriptions, so word overlap is not a score (see the page map in each `.txt`). The overlay is a diagnostic only; the review below is the Gate 2 equivalent.

## Gate 2 review (2026-10-22, every page of both engines rendered at 45 dpi and viewed side by side)

Both engines carry the same lines on every page (XENG-003). Krueger, 13 pages (`usage/OUTPUT-adversary-complaint.typst.pdf`, `.docx.pdf`):

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (colons on every row), title, lead-in, The Parties, Jurisdiction (¶¶ 1 to 5) | OK. "§§ 151" kept with its number. |
| 2 | ¶¶ 6 to 14; Procedural Background; Factual Allegations and its level-2 heading | OK. |
| 3 to 6 | ¶¶ 15 to 55 | OK. |
| 7 | ¶¶ 55 to 62; Count I and its level-3 heading I. | OK. |
| 8 | ¶¶ 63 to 71 | OK. |
| 9 | ¶¶ 72 to 77; level-3 heading II. | OK. |
| 10 | ¶¶ 77 to 86; III. Request to Permit State Court to Liquidate Damages | OK. |
| 11 | ¶¶ 87, 88; WHEREFORE; Relief Requested; WHEREFORE; items (i) to (iv) | OK: the WHEREFORE lead-in kept with item (i). |
| 12 | Item (v) and the signature block | ACCEPTED: the last item is kept with the signature, which does not fit on page 11, so page 12 holds one item and the block (the old render moved the whole list). |
| 13 | Certificate of service (kept on one page) | OK. |

TIG Reaper, 9 pages (`usage/OUTPUT-adversary-complaint-2.typst.pdf`, `.docx.pdf`):

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (the plaintiffs' names one row each), title, lead-in, Preliminary Statement ¶¶ 1 to 3 | OK. |
| 2 | ¶¶ 4 to 12; Parties | OK. |
| 3 | Jurisdiction and Venue; Factual Background; ¶¶ 13 to 17 with items (a) and (b) | OK. |
| 4 | ¶¶ 18 to 26; Count I (two-line centered heading) | OK. |
| 5 | ¶¶ 27 to 37; Count I's WHEREFORE; Count II | OK. |
| 6 | ¶¶ 37 to 44; Count II's WHEREFORE; Count III | OK. |
| 7 | ¶¶ 45 to 54; Count III's WHEREFORE; Count IV | OK. |
| 8 | ¶¶ 55 to 60; WHEREFORE clauses; Count V; Prayer for Relief; item (a) | OK. |
| 9 | Items (b) to (e) and the signature block | OK. |

No open tier-2 finding.

## Known gaps and open choices

1. **Typeface (fonts pass, 2026-10-15).** Face required by the rules: none. Verified against the PAEB Local Rules PDF (2025-12-01): L.B.R. 9004-1(b) sets paper size and fastening only, and FRBP 9004 names no face. The house face, Times New Roman (vendored), is used in typst and docx alike (the docx named EB Garamond until fb-595.68.34); the filed exemplars use Times New Roman too (checked with `pdffonts`). Size is 12 pt.
2. **Form 416.** Rule 7010 requires the caption to substantially conform to Official Form 416. The uscourts.gov page I tried for the caption form returned 404, so the form's own layout was not checked. The caption follows the two filed exemplars, which share the same layout.
3. **FRBP 7008(a) consent statement.** Verified text: a complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court. The template does not generate or check this sentence; it is author content. The TIG exemplar has it (¶ 15). The Krueger exemplar has **no** such statement (no match for "consent" in its text), so the filed Krueger complaint does not meet 7008(a) on its face. The Krueger sample follows its exemplar and therefore has no such paragraph; a complaint built from it would need one added.
4. **Clerk's cover sheet.** L.B.R. 7003-1 requires the Clerk's Adversary Proceeding Cover Sheet with a paper complaint. The TIG exemplar's pages 1 and 2 are that form (B1040). The template does not generate it.
5. **CM/ECF header.** The court's header line on each page of the exemplars (`Case 26-00127-pmm Doc 1 Filed … Page N of M`) is added at filing. The template does not reproduce it.
6. **Certificate of service.** The `certificate:` block follows the Krueger exemplar and is optional. L.B.R. 9014-4(a) requires a certificate for a document "required to be served" and names applications, motions, objections and notices; a complaint is served with a summons (FRBP 7004, not fetched for this pass), so the certificate here is author practice. The L.B.F. 9014-4 form was not fetched.
7. **TIG sample is an excerpt.** Paragraphs 24 to 122 of the TIG filing are not transcribed. The template numbers the sample's paragraphs 1 to 60 itself, so they do not match the filing (Count I is filed ¶ 124 and is ¶ 24 in the sample). Paragraph 23's block quotation is abridged and marked in brackets in the sample. The Krueger sample is the full text (¶¶ 1 to 88), and its numbers match the filing.
8. **Alignment.** Body text is left-aligned, not justified. The exemplars' justification could not be read from the text layer; this is a convention choice.
9. **Two filers.** The tier-2 rule asks for 2 or 3 filers. Two are present (Kang Haggerty LLC and Salzmann Hughes PC). Other searches were not usable: Golas v. Bliss (26-00166) and Acey v. City of Philadelphia (26-00162) are scans with no text layer; Shubert v. Chun (26-00205) is not available on RECAP.
10. **Tool checks.** `sh tools/check.sh <this folder>` and `--engine docx` run every gate on both samples: `RESULT: 18 checks passed, 0 failed` (typst) and `RESULT: 26 checks passed, 0 failed` (docx, XENG-001..003 gated).

## Search log (exemplars)

- CourtListener search API, `court=paeb`, `type=r`, `q="adversary proceeding" complaint`, `filed_after=2026-01-01`, 31 results. Downloadable complaints checked: TIG Reaper (chosen), Krueger (chosen), Golas (scan), Acey (scan). Shubert v. Chun (26-00205, Doc 1) is `is_available: false`.
- Dates: docket numbers and filing dates are from each PDF's header stamp.
