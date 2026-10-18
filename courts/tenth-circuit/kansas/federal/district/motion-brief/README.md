# ksd: motion brief (memorandum in support of a motion to dismiss)

Doc type: **motion-brief**, the memorandum in support of a Rule 12(b) motion, in the United States District Court for the District of Kansas (`ksd`).
Folder: `courts/tenth-circuit/kansas/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole memorandum, 11 pages, transcribed (case names and signals italic as the filed copy sets them) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages, typst 0.15.0, vendored Liberation Serif only (`pdffonts`: LiberationSerif, -Bold, -Italic), no warnings (`tools/render.sh`); the page-limit check passes (the brief body ends on page 11, the signature block; the certificate is on page 12) |
| overlay | fail: `tools/overlay.sh` exits 1, "no exemplar pdf": `usage/` holds no `SAMPLE-*.pdf` in this snapshot. `usage/OVERLAY-blatnick-motion-brief.txt` is left from the EB Garamond render and is stale; no `.pdf` overlay exists |
| pages reviewed | 12 of 12: every page rendered at 70 dpi and viewed after the Liberation Serif change (fonts pass) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Kan. R. 5.1(a) | Papers are letter-size, double-spaced, in no less than 12-point (10-point for footnotes), "Times New Roman or similar," uncompressed font. Source: https://www.ksd.uscourts.gov/sites/ksd/files/MASTER%20COPY%20updated%204%2027%2026.pdf (Rules of Practice, "As amended 4/1/26"; text checked 2026-10-14). | `page` (US Letter), `double-leading` (27.6 pt pitch; measured on the render with `pdftotext -bbox`, identical on pages 2 to 10), `type-size` 12 pt, `footnote-size` 12 pt, `font-family` "Liberation Serif" (the docs/FONTS.md substitute for Times New Roman; metric-compatible). |
| D. Kan. R. 5.1(b) | Signature block: names, addresses, telephone, facsimile and email; attorneys' registration numbers. | `signature-block()` prints the lines the sample gives. Facsimile and registration numbers are author content (not asserted; see Known gaps). |
| D. Kan. R. 5.1(f) | Certificate of service states the name and address of each person served, the capacity in which served, the manner of service, and the date. | `certificate()`: an assertion stops the build if any recipient lacks a name, address, capacity or manner, or if the date is missing. |
| D. Kan. R. 7.1(a) | The brief (opening brief or motion) must contain (1) a statement of the specific relief sought, (2) a statement of the nature of the matter, (3) a concise statement of the facts with record references, and (4) the argument, referring to all authorities relied on. Same source. | Two assertions: a level 1 heading naming the facts or background, and a level 1 CONCLUSION heading (the relief). Items (2) and (4) are author content; the template does not check citations. |
| D. Kan. R. 7.1(d)(3) | Principal brief in support of a motion other than discovery, summary judgment or class certification: 15 pages at most. Same source. | `page-limit` = 15. The assertion counts pages from the caption through the signature block (`<brief-end>`), which is the conservative reading (the certificate of service is not counted). |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system; other service needs one. Source: https://www.law.cornell.edu/rules/frcp/rule_5 (text checked 2026-10-14). | The certificate is optional (`service` in the frontmatter). The sample has one because the recipient (the plaintiff) is served by email. |

Not produced by this template: a motion (a separate filing; this template is the memorandum), a proposed order, a certificate of compliance (D. Kan. has no word limit for this motion, so none is required by the local rules), a table of contents or table of authorities (no D. Kan. rule requires them for a memorandum of 15 pages or fewer), and the exhibit index required by D. Kan. R. 7.1(e) when exhibits are attached (the sample attaches none).

## Layout

- Letter paper, 1-inch margins on all sides, no pleading paper (D. Kan. does not require it).
- Cover: the same caption as the complaint template (court name, a ")" column as tall as the party column, "Case No." on the right, the title in centered bold capitals).
- Body double-spaced at 27.6 pt, with a 0.5-inch first-line indent on every paragraph (including the first after a heading), and 27.6 pt between paragraphs (no extra space).
- Headings: level 1 centered bold capitals, unnumbered (INTRODUCTION, STATEMENT OF FACTS, ARGUMENTS AND AUTHORITIES, CONCLUSION); level 2 bold, A., B., ... with a hanging letter; level 3 bold, 1., 2., ... (reset under each level 2); level 4 italic, a., b., ... (reset under each level 3). The author types no letters or numbers.
- Block quotations: single-spaced, indented 0.5 inch on both sides, double-spaced after.
- Typeface: Liberation Serif, 12 pt. D. Kan. R. 5.1(a) names "Times New Roman or similar"; `docs/FONTS.md` maps Times New Roman to Liberation Serif (metric-compatible). EB Garamond is not used here.
- Footnotes: 12 pt, single-spaced, with a short rule above them. (No footnotes in the sample; the footnote path is exercised only by a scratch render, see the log.)
- Signature block: date on the left when given; "Respectfully submitted," and the firm on the right; "/s/" signer; the lines given in the frontmatter, single-spaced; kept on one page.
- Certificate of service (optional): centered bold capitals; the author's text; each recipient's name, address, capacity and manner; the signer's "/s/" line and name. Kept on one page.
- Page number centered at the foot of every page, including the first.

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body.

**Frontmatter**

| Field | Required | Feeds |
|---|---|---|
| `case_number` | no (blank as filed) | "Case No." in the caption |
| `caption.parties` | yes | list of `{names: [...], designation: "..."}`; "v." is inserted between parties |
| `title` | yes | the centered title (printed in capitals) |
| `jury_demand` | no | "JURY DEMANDED" in the caption (not used for a memorandum) |
| `date` | no | "DATED:" line beside the signature block |
| `signature.intro` | yes | lines above the signer ("Respectfully submitted," and the firm) |
| `signature.signer` | yes | the "/s/" line, e.g. `/s/ Ryan M. Peck` |
| `signature.lines` | yes | lines after the signer; `""` is a blank line; `*...*` is italic |
| `service` | no | certificate of service: `date`, `text` (the author's paragraph), `signer`, `signer_name`, `recipients` (each `name`, `address` (list), `capacity`, `manner`) |

**Body**: the text before the first heading is an unnumbered opening paragraph. `# HEADING` (level 1), `## Heading` (level 2), `### Heading` (level 3), `#### Heading` (level 4). Footnotes as `[^key]` with `[^key]: text` anywhere in the body. Case names and signals in `*...*`, as the filed copy sets them (*Id.*, *See*, *But see*, short-form case names). The template does not guess what a case name is. Not supported: tables, raw typst.

## Known gaps and open choices

1. **Font (resolved by the fonts pass).** D. Kan. R. 5.1(a) names "Times New Roman or similar", so the template uses Liberation Serif, the `docs/FONTS.md` substitute (metric-compatible), in place of EB Garamond. The render grew from 11 to 12 pages: Times-metric lines carry more text than EB Garamond's, so the body now ends on page 11 and the certificate moves to page 12. The body is still within the 15-page limit. The filed copy is not in this snapshot, so the visual match to it was not re-checked.
2. **Margins.** The D. Kan. rules set no margin. One inch was chosen; the exemplar's margins were not measured (measuring them would be a coordinate-based template, which the rules forbid).
3. **Page limit.** The assertion counts from the caption through the signature block. A brief that is 15 pages through the signature and has a certificate on page 16 passes; if D. Kan. counts the certificate, the assertion is too lenient by the certificate's pages. The rule does not say which pages count.
4. **Additions to the certificate.** The filed certificate gives the recipient's name, address and email, and says the copy was "sent via email," but states no capacity. D. Kan. R. 5.1(f)(2) requires the capacity, so the sample adds "Capacity: Plaintiff" (from the caption) and "Manner of service: email" (from the certificate's text). These two lines are the only text not in the filed copy.
5. **Facsimile and registration numbers.** D. Kan. R. 5.1(b)(1)(D) lists facsimile numbers, and R. 5.1(b)(2) lists attorneys' registration numbers. The filed copy has a Fax line and "#21223" numbers, so the sample carries them; the template does not check that they are present.
6. **Heading style.** The filed copy's level 2 headings are letters with a hanging indent, which the template reproduces. The filed copy's level 3 headings are not used in this sample (the memorandum has none), so their style is untested against an exemplar.
7. **Combined motion.** The memorandum is a separate filing from the motion (Doc. 6 and Doc. 7). A combined motion and brief would need the motion's own caption and relief statement, which this template does not produce.
8. **Overlay pairing.** The sample and the filed copy have the same page count (11), so the overlay pairs pages by index. The overlay is a diagnostic, not a score.
9. **Output and overlay file names.** As in the complaint: `usage/INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`, the names `tools/render.sh` and `tools/overlay.sh` read and write.
10. **Check scripts not run.** As in the complaint, `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json`, `rules.md` and `checks.yaml`; this doc-type folder has none, and the brief forbids editing `tools/`.
11. **Block quotations and footnotes.** The sample has neither. The paths are exercised by a scratch sample rendered once with a block quotation, a footnote, levels 3 and 4, a list and the certificate (the scratch sample was deleted after the render). The footnote number is set tight to its text (typst 0.15 has no separate number gap for footnote entries).

## Review of the rendered pages (`usage/OUTPUT-motion-brief.typst.pdf`, 12 pages, Liberation Serif)

| Page | Content | Result |
|---|---|---|
| 1 | Court name, caption with ")" column, "Case No.", title in two lines, opening paragraph, INTRODUCTION (first paragraphs) | Pass |
| 2 | Introduction (end); STATEMENT OF FACTS, first paragraphs | Pass |
| 3 | Statement of facts (end); ARGUMENTS AND AUTHORITIES; A. STANDARD OF REVIEW | Pass |
| 4 | Standard of review (end); B. (hanging letter, bold) | Pass |
| 5 | C. (two-line heading with hanging indent); italic case names | Pass |
| 6 | C. (end); D. (two-line heading) | Pass |
| 7 | D. (end) | Pass |
| 8 | E. (two-line heading) | Pass |
| 9 | E. (end); F. (two-line heading) | Pass |
| 10 | G. (two-line heading); the injunction paragraphs | Pass |
| 11 | G. (end); CONCLUSION; signature block with "/s/", counsel lines and the italic "Attorneys for Defendant" line | Pass |
| 12 | CERTIFICATE OF SERVICE: the author's text, the recipient's name, address, capacity and manner, and the "/s/" line | Pass |

Gate 2 rows are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Log of changes made during review

- Paragraphs overprinted: a single rendered body gave no gap between paragraphs (typst adds none). Fixed: paragraph spacing equals the double leading, so the pitch is 27.6 pt throughout (the render went from 10 to 11 pages, the filed copy's count).
- Caption and signature lines inherited the first-line indent. Fixed: line stacks set no first-line indent.
- Line breaks split "§" from its number. Fixed in the sample only: non-breaking spaces after "§" and "¶" (the text is unchanged).
- A footnote-number gap option was tried and rejected (typst 0.15 has no such parameter for footnote entries).

## Engines

**docx** (`docx/reference.docx`, `docx/ksd-motion-brief.lua`): pandoc with the reference and the filter; the caption, headings (A., 1., a. with hanging indents), block quotations, signature block, footer page number and certificate of service are Word paragraphs in `Ksd ...` styles. Matches the typst template: Liberation Serif 12 pt, exact 27.6 pt double spacing, letter paper, 1 in margins, 0.5 in first-line indent on every body paragraph, centered page number, certificate on the page that follows the signature (no forced page break).

Differs from typst: no ")" column in the caption; the page-limit assertion (15 pages, D. Kan. R. 7.1(d)(3)) is not run for docx, since page counts come from the LibreOffice PDF; Word may paginate differently.

BLOCKED (docx gates cannot run on this box):
- `docx.pdf` (LibreOffice conversion): `soffice` is not installed on the box, so `tools/render-docx.sh` stops after writing `usage/OUTPUT-motion-brief.docx`.
- Visual review of the docx pages: 0 pages reviewed; the typst pages were viewed as the comparison.
- Page limit (15 pages through the signature, D. Kan. R. 7.1(d)(3)): not measured for docx.
