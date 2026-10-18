# Appellate Division (all four Departments): answering brief (respondent's brief)

Status: **exemplar found** (2026-10-16): a First Department respondent's brief, *NYCLA v. State of New York*, App. No. 2022-03908 (see `usage/SOURCE.md`). The template was rebuilt on this court's reply-brief template and the sample is now a partial transcription of the exemplar. Render ok, overlay ok, 19 of 19 pages reviewed.

| Gate | Result |
|---|---|
| exemplar | yes: `usage/SAMPLE-nyappdiv-answering-brief-nycla202203908.pdf` (First Dept, NYSCEF Doc. 17, filed 2023-04-19, Kramer Levin for plaintiffs-respondents) |
| render | ok: `sh tools/render.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/answering-brief usage/INPUT-nyappdiv-answering-brief-nycla202203908answering.md`, 19 pages, EB Garamond Regular/Bold/Italic only, no typst warnings (2026-10-16) |
| overlay | ok: `sh tools/overlay.sh …/answering-brief nycla-2022-03908-answering`, wrote `usage/OVERLAY-nycla-2022-03908-answering.pdf` and `.txt` (2026-10-16) |
| pages reviewed | 19 of 19 (every page rasterized at 60 dpi and viewed, 2026-10-16); overlay viewed as a 40 dpi contact sheet, pages 1, 5 and 12 at 100 dpi |

## Governing rules

Primary rule: **22 NYCRR 1250.8**, "Form and Content of Briefs," Part 1250 (Rules of the Appellate Division), which applies to all four Departments. Text read from the Cornell LII copy <https://www.law.cornell.edu/regulations/new-york/22-NYCRR-1250.8>, fetched **2026-10-14**; LII gives the adoption date as 9/17/2018. **Verification limit:** the official nycourts.gov text was not reached from this box, so the rule text is checked against a secondary copy. Confirm against the official text before relying on the template. Department-specific local rules (for example, the Fourth Department's own rules) were not checked.

| ID | Rule (22 NYCRR 1250.8 unless stated) | Verified |
|---|---|---|
| NYAD-COVER-001 | (a) Cover: title of the action; upper right: argued or submitted, time required if argued, name of the attorney who will argue; lower right: name, address, telephone and email of the filing attorney and whom they represent. | LII copy, 2026-10-14 |
| NYAD-ORDER-001 | (c) respondent's brief conforms to (b): table of contents (point headings and appendix contents), table of cases and authorities with pages cited, questions involved (counterstatement only if the respondent disagrees), nature of the case and facts, argument in points, printing statement (j). | LII copy |
| NYAD-TYPE-001 | (f)(1) serifed proportional or serifed monospaced face; no narrow or condensed faces; no bold and no all-capital words except in headings and in quotations of language set that way in the source. | LII copy |
| NYAD-TYPE-002 | (f)(1)(i) proportional face: body 14-point; footnotes no less than 12-point. | LII copy |
| NYAD-FACE-001 | Typeface row. Face required: **none named**. 1250.8(f)(1) says "a serifed, proportionally spaced typeface such as Times Roman" (or a serifed monospaced face such as Courier); "such as" is an example. Substitute: none; **EB Garamond kept** (any serifed proportional face is allowed). Fit: not applicable. Checked 2026-10-15 against LII. | LII copy, 2026-10-15 |
| NYAD-WORD-001 | (f)(2) appellants' and respondents' computer-generated briefs: not more than 14,000 words, inclusive of point headings and footnotes, exclusive of signature blocks and the pages with the table of contents, table of citations, proof of service, certificate of compliance, and any addendum under (k). | LII copy |
| NYAD-FORM-001 | (h) one-inch margins on all sides. | LII copy |
| NYAD-FORM-002 | (h) text double-spaced; quotations of more than two lines may be indented and single-spaced; headings and footnotes may be single-spaced; pages numbered consecutively. | LII copy |
| NYAD-FORM-003 | (h) as above; the template single-spaces block quotations, headings, footnotes, the cover, and certificates. | LII copy |
| NYAD-PRINT-001 | (j) printing specifications statement at the end of the brief: typeface name, point size, line spacing and word count; the signature counts as the signer's representation of accuracy; the word count may come from the word processor. | LII copy |
| NYAD-SERV-001 | Proof of service is a page excluded from the word count by (f)(2). The form of the proof is not in 1250.8; the template uses a generic affidavit-of-service page. | not verified beyond (f)(2) |
| NYAD-DISC-001 | No corporate disclosure statement is required by 1250.8. The template has no disclosure page. (The Court of Appeals rule 500.1(f) does not apply here.) | not verified beyond 1250.8 |
| NYAD-ADD-001 | (b)(7): in the First and Second Departments, the appellant's brief carries the CPLR 5531 statement. Whether a respondent's brief must carry it through (c) is **not resolved** by the rule text. The template does not generate it. | unresolved |

Rule dates: 1250.8 as read is dated 9/17/2018 (LII). No later amendment was seen in the LII copy's version note.

## Folders

- `typst/main.typ`: entry point; reads `sample=` from `--input` (default `usage/INPUT-nyappdiv-answering-brief-nycla202203908answering.md`).
- `typst/nyappdiv-answering-brief.typ`: the template, `nyappdiv-answering-brief(meta, md)`. Copied from `../reply-brief/typst/nyappdiv-reply-brief.typ` (cover, TOC, TOA with page references, signature, printing statement, blank affidavit of service) with these changes: word limit 14,000 (1250.8(f)(2)); headings outside the Argument are lettered A., 1. (the exemplar's Counterstatement of Facts) while Argument points stay I., A.; point headings in capitals only under the Argument; the docket is printed as written; a caption side may carry its own `joiner` ("– and –"); an optional `closing` line in the signature block.
- `usage/INPUT-nyappdiv-answering-brief-nycla202203908answering.md`: partial transcription of the exemplar (see "Sample").
- `usage/OUTPUT-nyappdiv-answering-brief-nycla202203908answering.typst.pdf`: render output (19 pages).
- `usage/OVERLAY-nycla-2022-03908-answering.pdf`, `.txt`: overlay on the exemplar and its page map.
- `usage/SAMPLE-nyappdiv-answering-brief-nycla202203908.pdf`, `usage/SOURCE.md`: the exemplar, its source and the search record.

## Markdown contract (frontmatter)

The same schema as `../reply-brief` (see its README), plus `joiner` and `closing`.

| Field | Required | Feeds |
|---|---|---|
| `docket` | yes | cover, top left, printed as written (e.g. `Appellate No. 2022-03908`) |
| `county_clerk_index` | no | cover, top left, under the docket |
| `department` | yes | cover: "Appellate Division—*department*" |
| `argument` | yes | cover, upper right (1250.8(a)): `presenter` and `time_requested`; without `presenter`, "Submitted without oral argument" |
| `caption` | yes | list of sides: `names` (list), `designation`, optional `joiner` (the word above this side; default "– against –") |
| `caption_note` | no | a line under the caption |
| `brief_title` | yes | cover title (capitals, bold) and document title |
| `counsel` | yes | cover, lower right: list of `{firm, lines}` (name, address, telephone and email lines) |
| `attorneys_for` | yes | cover, under counsel |
| `signature` | yes | `date`, `place`, optional `closing`, `attorneys_for`, `blocks` (list of `{firm, names, lines, by?}`) |
| `authorities` | if cited | key: `{kind, name?, cite, sort?}`; kind is case, constitution, statute, regulation, rule or other. Only authorities cited with a `[text](toa:key)` link are listed, with the printed pages of those links |

Body: `#` section (centered, bold, capitals); `##` under the Argument is a point (I., capitals), elsewhere a lettered sub-heading (A.); `###` under a point is A.; `####` 1. Text before the first heading is printed as an untitled opening paragraph. Block quotations are `>`. Footnotes are `[^key]`.

## Sample

`usage/INPUT-nyappdiv-answering-brief-nycla202203908answering.md` is the filer's text, partly transcribed: the cover; the opening paragraph and its footnote; the Preliminary Statement's first four paragraphs and its last; the Counterstatement of Question Presented (complete); from the Counterstatement of Facts, the start of A., the start of B., the start of C., the first and the last two paragraphs of D.; the Argument's standard-of-review paragraph; Point I (complete); Point II.A's first two paragraphs; II.B's first two paragraphs and the first paragraph of its footnote; II.C's first two paragraphs; the Conclusion and the signature block. Everything else is left out, so the render is 19 pages against the exemplar's 52, and its word count (2,873) is the sample's, not the filed 10,394. Footnotes are renumbered (the exemplar's footnote 3 is footnote 2). The exemplar's typo "CLPR 3211(e)" is kept in the text; the TOA entry reads "CPLR 3211(e)", as the exemplar's TOA does.

## What the overlay shows

`usage/OVERLAY-nycla-2022-03908-answering.txt` pairs every rendered page with an exemplar page: cover with cover (83%), TOC with TOC (96%), the transcribed body pages with their source pages (43–100%), the printing statement with the filed one (50%), and the blank affidavit with nothing real (7%; the exemplar copy has no proof of service). Where the text is the same, our lines sit close to the filed lines; the drift down a page is about a line. The filed cover spreads its parts over the page and prints the court banner as an image; ours stacks them with rules between, the reply-brief cover. The filed signature puts the names above the firm; ours puts the firm first (tier 3, not chased).

## Verification pass 2026-10-16 (fb-595.26.22)

- Exemplar: none before this pass. Searched again (13 searches, `usage/SOURCE.md`); one First Department respondent's brief saved.
- Render before the fixes: the old template and placeholder sample, 10 pages, exit 0. All 10 viewed. Defects: no page numbers in the table of authorities (tier 1, 1250.8(b)(2)); the argued/submitted notation below the caption, not in the upper right (tier 1, 1250.8(a)); the TOC listed "POINT I" with no point heading (tier 1, 1250.8(b)(1)); the signature block alone on page 8; counsel lines right-aligned with paragraph spacing.
- Fixed by rebuilding the template on the reply-brief template (see "Folders") and replacing the placeholder sample with the transcription. The placeholder `INPUT-nyappdiv-answering-brief-sample.md` and its PDF are removed.
- Render after: 19 pages, exit 0, no warnings. All 19 viewed: cover on one page; TOC with point headings and page numbers; TOA with printed page numbers (two pages, `ii`–`iii`); body 1–13; Conclusion kept with the signature block on page 13; printing statement on 14; blank affidavit on 15.
- Not fixed (tier 2/3): the citation line under a block quotation takes the first-line indent (the exemplar sets it flush); the firm name on the cover wraps and its two lines sit tight; body page 12 ends half empty because the Conclusion and signature are kept together.

## Known gaps

1. **Exemplar is First Department.** Part 1250 governs all four Departments; Department rules (Parts 600, 670, 800, 1000) were not checked.
2. **Footnotes** are printed at body size (14 pt; the rule minimum is 12 pt), single-spaced, as in the reply-brief template.
3. **Word count** is the template's count of the markdown body (links keep their text, markup removed), not a word-processor count. The 14,000-word limit is a hard stop.
4. **Proof of service** is a blank affidavit form; its form is not verified against Part 1250. The exemplar copy has none.
5. **CPLR 5531 statement** (appellant's addendum in the First and Second Departments) is not generated; see NYAD-ADD-001.
6. **Double spacing** (`body-leading`) is the reply-brief value, checked by overlay against the First Department exemplars only.
7. **docx engine not updated.** The docx filter (`docx/nyappdiv-answering-brief.lua`) reads the old frontmatter schema (`index_no`, `calendar`, `counsel.names`, `phone`, `service`). The committed `usage/OUTPUT-nyappdiv-answering-brief-nyappdivansweringbriefsample.docx` is from the removed placeholder sample; it was not touched in this pass. The docx engine needs the new schema before it can render the new sample.

[Formbook index](../../../../../../README.md) | [Court folder](../README.md)

## Engines

**docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/nyappdiv-answering-brief.lua`; output `usage/OUTPUT-<id>.docx`).

- Matches the typst form: letter, 1 in margins, EB Garamond 14 pt body, double-spaced body with a 0.5 in first-line indent, single-spaced headings, block quotations, signature block and printing statement; centered page number in the footer, none on the cover.
- Differs: "double" is Word's double spacing (`w:line="480"`), not the typst leading, so line breaks and page counts differ. Word and LibreOffice also paginate differently from each other.
- Differs: the contents is a TOC field with cached entries and no page numbers; Word or LibreOffice must update fields. The authorities list has no page references (a TOA field needs the same update, and LibreOffice does not honor TA/TOA fields).
- The cover is a centered layout with the calendar notation on the right. Footnote text is 12 pt, as the typst template sets. The affidavit of service prints the method and affiant from the metadata.
- The word count and the word limit are computed by the filter from the markdown source, not by Word.
- Validated: `tools/render.sh --engine docx` writes the `.docx`; `unzip -tq` and `xmllint --noout` pass on every XML part of the output and of `reference.docx`.

BLOCKED (docx engine, not passable on this box):

- **docx.pdf gates (Gates 0 and 1, `tools/check.sh --engine docx`): BLOCKED.** LibreOffice (`soffice`) is not installed on this box, so no `usage/OUTPUT-<id>.docx.pdf` exists and the check cannot run. Stamp `usage/.check-docx.txt` not written.
- **Pages reviewed: 0.** No `.docx` page was rendered or looked at, and the file was not opened in Word or LibreOffice, so no "no repair prompt" result is recorded.
