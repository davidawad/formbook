# nhd: complaint

Doc type: **complaint** in the United States District Court for the District of New Hampshire (`nhd`).
Folder: `courts/first-circuit/new-hampshire/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole 14-page complaint, transcribed from the text layer |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 14 pages, typst 0.15.0, Times New Roman only (`pdffonts`), no warnings |
| overlay | ok: `usage/OVERLAY-nicholas-complaint.pdf` and `OVERLAY-nicholas-complaint.txt` |
| typeface | Rule names no face (LR 5.1(a): "a proportionately spaced font ... no less than twelve (12) point"; no typeface named in the section). Set in **Times New Roman** 12 pt, the house standard (`docs/FONTS.md` rule 6; Liberation Serif as fallback), the filing's face too; EB Garamond before 2026-10-17 (the docx until fb-595.68.17). |
| pages reviewed | 14 of 14 on the earlier EB Garamond render, before fb-595.68 (every page rendered at 60 dpi and viewed after the last template change; re-rendered and re-viewed 2026-10-14 with no template change) |

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.N.H. LR 5.1(a) (2025 Local Rules, as amended through 2025-12-01; https://www.nhd.uscourts.gov/pdf/2025%20Local%20Rules%20-%20District%20of%20New%20Hampshire.pdf, linked from https://www.nhd.uscourts.gov/local-rules-0) | 8 1/2 x 11 paper; typewritten or clearly legible; 12-point type or larger if proportionally spaced; one-inch margins; consecutively numbered at the bottom center; double spaced except quoted material; footnotes sparingly. | `paper: "us-letter"`, `margin: 1in`, `type-size = 12pt`, `pitch-double = 27.6pt` (2 x the 13.8 pt single line), footer page number centered. |
| LR 5.1(b) | Attorney name, address, primary telephone, e-mail and NH bar number on all filings; bar number immediately after the typed name in the signature section. | `signature` frontmatter (`blocks`), `signature-block()`. |
| LR 5.1(c) | Caption, description of the contents, and the party filing; the docket number with the judge's initials suffix on filings after the initial one. | `caption` (court title, party block, `case_number`), `title`. The suffix is not added by the template (see Known gaps). |
| LR 3.1(b) | Initial filing accompanied by a civil cover sheet (JS-44). | Not produced: separate form (see Known gaps). |
| LR 4.1 | Summons or notice of lawsuit and waiver request delivered with the complaint. | Not produced: separate form (see Known gaps). |
| Fed. R. Civ. P. 8(a)(2) (https://www.law.cornell.edu/rules/frcp/rule_8, fetched 2026-10-14) | Short and plain statement of the grounds for jurisdiction, the claim, and the relief sought. | Content only; the template checks nothing about it. |
| Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, fetched 2026-10-14) | Caption with the court's name, the title, and the file number; title names the parties. | `court-title()`, `caption()`, `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers every paragraph (not headings, not lists, not `~` paragraphs). |

Not produced (separate filings): the civil cover sheet (LR 3.1(b)); the summons and waiver request (LR 4.1); the Rule 7.1 disclosure statement if a party is a corporation (LR 7.1.1 and Fed. R. Civ. P. 7.1). The complaint has no certificate of service: it is served with the summons.

## Layout

- Court title (two lines, bold, centered), caption (party names left, `C.A. No.` and `JURY TRIAL DEMANDED` right), the title in bold caps centered.
- Body: 0.5 inch first-line indent, double spaced, numbered allegations 1, 2, ... (the template numbers them). Headings: level 1 centered bold caps (`PROCEDURAL BACKGROUND`, `JURISDICTION AND VENUE`, `COUNT I`); level 2 centered bold (`(Unpaid Overtime Under the FLSA)`); level 3 bold flush left (`I. FEDEX CONTRACTS ...`).
- Markdown lists (`1.` items) are lettered (a), (b), ..., indented, and are not numbered as paragraphs. The prayer for relief is a list.
- A `~ ` paragraph is unnumbered (used for `WHEREFORE` and the jury demand, as in the filing).
- Signature block at the right half of the page: `Respectfully submitted,` the party line, `By his attorneys,`, `/s/` line, then one single-spaced block per counsel.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `caption.parties` (list of `{names, designation}`; `v.` is inserted between parties), `case_number`, `jury_demand` (true/false), `title`, `lead_in` (optional unnumbered opening paragraph), `signature` (`intro`, `party` (optional lines), `signer`, `blocks` (list of counsel line lists)).
- Body chunks, separated by blank lines: `#` heading (level 1), `##` (level 2), `###` (level 3); `1.` list items; `~ ` unnumbered paragraph; any other chunk is a numbered paragraph.
- Not supported: footnotes, tables, raw typst. Text is markdown: italics with `*...*`, but the transcription is roman (the text layer of the exemplar has no italic markup).
- The sample must not put numbers in the text: the template numbers the paragraphs.

## What the overlay shows

`OVERLAY-nicholas-complaint.pdf` (measured on the earlier EB Garamond render, before fb-595.68) is red (our render) on blue (the filed PDF), black where both agree. The sample is the whole filing. Pages 1 to 6 pair one to one. From page 7 our pages pair with the filed page one earlier (ours p.7 with filed p.6, ours p.13 with filed p.12): our pagination runs a little longer, so the text pairs with the page that shares most words. Page 14 pairs with 14. The `.txt` lists the pairing and word overlap. Overlap percentages are word-level and are not a score.

## Known gaps and open choices

1. **One exemplar, not 2 or 3 filers.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search (CourtListener RECAP, `type=rd`, `court=nhd`, `q=complaint`, newest first, 2026-10-14) returned 20 hits on its first page; only this one had a stored PDF, with a text layer and attorney counsel. The other hits had no stored PDF. Later pages were not checked. Tier 2 is therefore **not** judged against two filers.
2. **Font.** LR 5.1(a) names no typeface. The template is Times New Roman 12 pt, the house standard (`docs/FONTS.md` rule 6, David 2026-10-17), as is the filing; it was EB Garamond before 2026-10-17 (the docx until fb-595.68.17). The 12-point minimum is met.
3. **Double spacing.** The template sets the 27.6 pt pitch directly (`pitch-double`, 2 x the 13.8 pt single line, Times 12 pt double spaced); on the earlier EB Garamond template it came from `1.65em` leading. The render is 14 pages, the same page count as the filing.
4. **Footnotes are not transcribed.** The filing has footnotes 1 and 2 (pp. 1 and 4). The markdown contract has no footnotes, so their text is absent from the sample and the overlay shows the difference.
5. **Lettering of the prayer items.** The filing letters the prayer A to D; the template letters every list (a), (b), .... Tier 2, minor; recorded as ACCEPTED.
6. **Caption style.** The party block is not closed by ")" marks; the filing's caption is as transcribed (no rules). Recorded as ACCEPTED.
7. **Judge initials suffix (LR 5.1(c)).** `case_number` is printed as given. For later filings the docket number must carry the judge's initials (for example `1:26-cv-00879-SE-TSM`); the template does not add them.
8. **ECF header.** The filed PDF carries the ECF header (`Case 1:26-cv-00879-SE-TSM Document 1 Filed 10/10/26 Page N of 14`). The template does not add it; the court's system does.
9. **Heading and body spacing.** A heading is kept with the paragraph after it (`breakable: false`), so a page may end with white space. This is intentional; the filing does the same.
10. **Typst warnings.** None: `tools/render.sh` treats any warning as a failure, and the render passed.
11. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The render and overlay were run; the page review below is the Gate 2 equivalent for this doc type.
12. **File names.** The samples are `INPUT-<id>.md` (not `<id>.md`) and the outputs are `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`, because `tools/render.sh` and `tools/overlay.sh` write these names and the brief forbids editing `tools/`.

## Review of the rendered pages (`OUTPUT-complaint.typst.pdf`, 60 dpi)

On the earlier EB Garamond render, before fb-595.68 (14 pages then and now).

- Page 1: court title, caption (party block; `C.A. No.`, `JURY TRIAL DEMANDED`), title, lead-in, procedural background (paragraph 1), page number. No spill. Pass.
- Pages 2 to 4: jurisdiction and venue, parties (paragraphs 2 to 15), facts with Part I (`I. FEDEX CONTRACTS ...`) heading on page 4 with its paragraph (kept together). Pass.
- Pages 5 to 7: lettered lists under paragraphs 25 to 27 (a)–(t) wrap with hanging indent; no overlap. Pass.
- Pages 8 to 12: parts II to VI, numbered paragraphs 35 to 71; headings centered or flush left at heading size equal to body size. Pass.
- Page 13: paragraph 72, `COUNT I`, paragraph 73, `PRAYER FOR RELIEF`, WHEREFORE (unnumbered), items (a) and (b). Pass.
- Page 14: items (c) and (d), `JURY TRIAL DEMAND`, the demand (unnumbered), the signature block (firm line, `/s/`, counsel blocks, LR 5.1(b) details). Pass.

Defects found in review and fixed (kept here so the template does not regress): heading blocks collapsed to zero height and overlapped the text around them (fixed by moving the heading gap into the flow and keeping `below` non-zero); paragraph blocks lost one line of leading between each other (fixed by a trailing one-pitch gap); headings rendered at typst's default heading size (pinned to the body size); the WHEREFORE paragraph was numbered (marked `~`).

## Engines

docx (`fb render --engine docx`, via `sh tools/render.sh --engine docx <dir> usage/INPUT-complaint.md`, builds the reference document from `docx/reference.xml`, the shared cross-engine recipe in the typst face; filter `docx/nhd-complaint.lua`): `usage/OUTPUT-complaint.docx` and `OUTPUT-complaint.docx.pdf` (LibreOffice conversion). Matches typst: Times New Roman 12 pt; exact 27.6 pt body pitch; 13.8 pt single lines; 0.5 in first-line indent; the caption; numbered allegations; lettered lists; the signature block at the 3.25 in indent; centered page number. Page count matches (14 and 14); XENG-001..003 pass (333/333 lines, fb-595.68.17). Word was not available; the file was checked with LibreOffice only.

- BLOCKED on the earlier EB Garamond docx (then built by `docx/build-reference.sh`, since retired into fb render; not re-checked here): prayer lead-in split from its items. In the docx, "WHEREFORE, Plaintiff ... seeks the following relief:" ends page 13 and items (a) to (d) start page 14; typst keeps the lead-in with its items on page 13. Keep-with-next is not applied to this lead-in.
- On that earlier docx, line wraps differed slightly from typst on most pages, and so did some page breaks; the page count was the same.

[Formbook index](../../../../../../README.md)
