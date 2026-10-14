# W.D. Tex. (txwd): complaint

Doc type: **complaint** in the United States District Court for the Western District of Texas (`txwd`).
Folder: `courts/fifth-circuit/texas/federal/western-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-lilly-5-26-cv-05147-complaint.pdf` (counsel-drafted, used for the sample) and `exemplars/FILED-EXAMPLE-callier-3-26-cv-01039-complaint.pdf` (self-represented, not transcribed). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-lilly-first-amended-complaint.md` (an excerpt of the 35-page filing: caption, parties, jurisdiction, opening general allegations, the first count, prayer in part, jury demand, signature). |
| render | ok: `samples/OUTPUT-lilly-first-amended-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings. |
| overlay | ok: `samples/OVERLAY-lilly-first-amended-complaint.pdf` and `.txt` (see "Overlay" below). |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change). |
| gates | `tools/check.sh` not run: it expects a court folder with `court.json` and `rules.md`, which this doc-type folder does not have, and the brief forbids editing `tools/`. |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| W.D. Tex. Local Rule CV-10(a) | Typed or printed in 12-point or larger font (including footnotes), double-spaced, on 8½ × 11 paper, one-inch margins on all sides; endorsed with the style of the case and the descriptive name of the document. Headings, footnotes and quotations more than two lines long may be single-spaced. | `page` (us-letter, `margin: 1in`), `type-size = 13pt`, `body-leading` (2.0 em pitch), `title`, `caption`. |
| W.D. Tex. Local Rule CV-10(b) | Represented party: attorney's mailing address, e-mail, signature, state bar card number, telephone and fax numbers, including area code. | `signature-block` (from the frontmatter `signature`). |
| W.D. Tex. Local Rule CV-10(c) | Unrepresented party: address, e-mail, signature, telephone and fax. | Not separately templated; the same block serves (a self-represented filer uses the party's own details). |
| Fed. R. Civ. P. 10(a) | Caption: court name, title of the action, file number, and the Rule 7(a) designation of parties. | `court-title`, `caption` (a § column, the W.D. Tex. convention seen in both exemplars), `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Each body paragraph is numbered by the template (`counter-para`); headings, count headings and lists are not. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the grounds for jurisdiction, the claim, and a demand for relief. | Author content; the template does not check it. |
| Fed. R. Civ. P. 38(b) | Jury demand (here, "JURY TRIAL DEMANDED" in the caption and a demand section). | Caption row and sample section; the template does not require it. |

Not produced by this template (separate filings): the civil cover sheet, the filing fee and summons (Local Rule CV-3); the certificate of interested parties, the Rule 7.1 disclosure and the summons. No certificate of service is generated: the rules do not require one for a complaint served with the summons.

## Layout

- 8½ × 11, one-inch margins on all sides (CV-10(a)). No pleading-paper numbered lines: W.D. Tex. does not require them (the cand complaint does, and it is a different court).
- EB Garamond at 13 pt. CV-10 says 12 pt or larger; 13 pt gives the same apparent size as the 12-pt Times in the exemplar (Garamond sets smaller at the same point size). Footnotes would be 13 pt too. This is a choice inside the rule, not a deviation.
- Double spacing: 2.0 em pitch (26 pt at 13 pt), with paragraph spacing equal to the leading so paragraphs sit one pitch apart.
- Caption: party column (3.7 in), § column, case-number column; each row one line; empty rows get a fixed one-line height so they do not collapse. The party column is wide enough that no party line wraps.
- Caption and signature block single-spaced (CV-10(a) allows single spacing for headings and quotations; the caption and signature are the same convention in both exemplars).
- Headings: centred bold capitals for level 1 and 2 (`# THE PARTIES`, `## FIRST CAUSE OF ACTION`); left bold for level 3 (`### I. FDA's ...`); count sub-headings are centred single-spaced lines (`> ...`).
- Body paragraphs: first-line indent 0.5 in; numbers at the indent, then text.
- Prayer lead-in (`~ WHEREFORE ...`) is unnumbered, as in the exemplar.
- Lists (prayer items) render with the markdown numbering; sub-items are bullets (see gaps).
- Footer: centred page number.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `court` (lines, centred bold), `caption` (rows of `[left, right]`; the template adds § in the middle of every row; leading spaces in a left cell indent it), `title`, `date`, `signature` (`lines`, and `signer` printed after "/s/"). A `""` line in `signature.lines` is a blank line.
- Body chunks are separated by blank lines: `#` centred bold capitals, `##` centred bold, `###` left bold, `> ` centred single-spaced lines (one per line), `~ ` an unnumbered paragraph, `1.`-style list, or a plain paragraph (numbered by the template).
- Not supported: tables, footnotes (none in the sample), raw typst, Roman-numeral lists (markdown has none; the exemplar's prayer sub-items are romanettes).
- The template numbers paragraphs from 1. The filed paragraph numbers are not kept: the sample's paragraph 25 is filed paragraph 73.

## Overlay

`sh tools/overlay.sh <court-dir> lilly-first-amended-complaint <exemplar.pdf>`. The exemplar is passed explicitly: the tool otherwise takes the alphabetically first PDF in `exemplars/`, which is the Callier file.

- The tool writes `samples/OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`, not the `<id>-overlay.*` names in the brief. The tool was not changed (the brief forbids editing `tools/`); file roles follow CLAUDE.md (`OVERLAY-<id>`).
- Page map (word-overlap pairing): ours p.1-7 ↔ filed p.1-8; ours p.8 ↔ filed p.32 (prayer); ours p.9 ↔ filed p.35 (signature). The overlay is a diagnostic, not a score: the filing has footnotes and romanette lists the sample does not reproduce, and the exemplar's line spacing differs.

## Review of the rendered pages (Gate 2 record; every page viewed at 60 dpi)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title (3 lines), caption with § column, title, paragraph 1 | OK. Caption rows single-spaced, no wrapping, no overlap. "JURY TRIAL DEMANDED" on the Astra row. |
| 2 | Paragraphs 2 to 4 | OK. Double-spaced; paragraphs one pitch apart. |
| 3 | Paragraphs 5 to 7 | OK. |
| 4 | Paragraphs 8 to 11, "THE PARTIES" heading (centred) | OK. Heading kept with its paragraph. |
| 5 | Paragraphs 12 to 16, "JURISDICTION AND VENUE" | OK. |
| 6 | Paragraphs 17 to 20, "GENERAL ALLEGATIONS", "I." sub-heading (left, bold, two lines) | OK. |
| 7 | Paragraphs 21 to 26, "CAUSES OF ACTION", "FIRST CAUSE OF ACTION", count sub-title (centred lines) | OK. Count title lines centred; the quote marker is stripped. |
| 8 | Paragraph 27, "PRAYER FOR RELIEF", WHEREFORE lead-in, item 1 with four declarations, "JURY DEMAND", paragraph 28 | OK. Sub-items are bullets (gap 3). |
| 9 | Signature block only ("Dated", "Respectfully submitted", /s/, counsel lines, "Counsel for Plaintiff") | Acceptable: the block is unbreakable so it moves whole. Page 9 is mostly blank (gap 5). |

Reviewed pages: 9 of 9.

## Known gaps and open choices

1. **Two filers, one transcribed.** EVAL-LOOP tier 2 asks for two or three filers. The Callier complaint is saved as a second exemplar but not transcribed, and the overlay is against Lilly only. The two filings differ (counsel-drafted vs self-represented), so the tier-2 comparison is not done.
2. **Sample is an excerpt.** Paragraph 17 is cut after its first sentence, paragraphs 18–24 and the first count are transcribed, the remaining counts and most of the prayer are omitted. The sample is 9 pages; the filing is 35.
3. **Prayer sub-items.** Item 1 of the prayer lists four of the eight declarations, with bullets where the exemplar has romanettes (i to viii). Romanette lists are not supported by the markdown contract.
4. **Footnotes.** The exemplar has eight footnotes; the sample omits them. The template has no footnote rule; CV-10(a) requires 12 pt or larger for footnotes, which the 13 pt setting satisfies, but the layout is untested.
5. **Signature block on its own page.** Page 9 holds only the signature block because the block is unbreakable. A breakable block would let the last paragraphs and the block share page 8; left as is because the convention is to keep the signature with the text, which here means a page break.
6. **Font.** EB Garamond (vendored, OFL), 13 pt. The exemplar is Times New Roman 12 pt. The choice follows the brief (vendored fonts only). The W.D. Tex. rule does not name a font.
7. **Justification.** Body text is left-aligned (ragged right). The exemplar's justification could not be read from the text layer; not asserted.
8. **Paragraph numbers differ from the filing.** Numbering is by the template; the filed numbers are not carried over.
9. **Characters per line.** Not measured; CV-10 does not set a characters-per-inch limit.
10. **Count headings.** The count sub-title is a centred block of single-spaced lines; the exemplar's count heading is in the same form.
11. **No certificate.** None is generated (see Governing rules).
12. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this is a doc-type folder. The brief forbids changes to `tools/`, so the gates were not run here. The render and overlay were run; the review above is the Gate 2 record for this doc type.
