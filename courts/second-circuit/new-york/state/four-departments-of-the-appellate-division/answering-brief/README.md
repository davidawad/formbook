# Appellate Division (all four Departments): answering brief (respondent's brief)

Status: **BLOCKED: no exemplar.** No filed answering brief of any Appellate Division Department could be downloaded (search record in `exemplars/SOURCE.md`). The template is built from 22 NYCRR 1250.8. The sample is **rule-built placeholder text, not a transcription** of any filed brief, and is not a model for any filing.

| Gate | Result |
|---|---|
| exemplar | no |
| render | ok (`sh tools/render.sh courts/second-circuit/new-york/state/four-departments-of-the-appellate-division/answering-brief samples/INPUT-nyappdiv-answering-brief-sample.md`; re-run 2026-10-14: 10 pages; vendored EB Garamond only; no typst warnings) |
| overlay | fail (`sh tools/overlay.sh …/answering-brief nyappdiv-answering-brief-sample` exits 1: `no exemplar pdf in …/exemplars`; no `-overlay.pdf` written; re-run 2026-10-14) |
| pages reviewed | 10 of 10 (re-rendered and every page rasterized at 60 dpi and viewed on 2026-10-14) |

`BLOCKED: no exemplar`. A second search on 2026-10-14 found one candidate, *Fuks v. Rakia Associates* (First Department, plaintiff-respondent brief filed 2024-04-17). Its only host returns 403 to curl and WebFetch, so it is not saved. See `exemplars/SOURCE.md`, "Second search pass". Tier 2 (professional convention, judged against filed exemplars) has not been assessed. Tier 1 is not claimed as met: see the table of authorities gap below.

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

- `typst/main.typ`: entrypoint; reads `sample=` from `--input`.
- `typst/nyappdiv-answering-brief.typ`: template. The structure follows `courts/second-circuit/new-york/state/court-of-appeals/answering-brief/typst/`, with the numbers and certificate wording changed to 1250.8.
- `samples/INPUT-nyappdiv-answering-brief-sample.md`: rule-built placeholder sample (frontmatter schema below).
- `samples/OUTPUT-nyappdiv-answering-brief-sample.pdf`: render output (10 pages).
- `samples/nyappdiv-answering-brief-sample-overlay.*`: **not produced** (overlay failed; see above).
- `exemplars/SOURCE.md`: search record.

## Markdown contract (frontmatter)

| Field | Required | Feeds |
|---|---|---|
| `index_no` | yes | cover, top left, e.g. `Index No. 000000/2025` |
| `docket` | yes | cover, top left under the index number, e.g. `[Department] Department Docket No. CA 00-00000` |
| `court` | yes | cover, centered: the Supreme Court and Judicial Department |
| `calendar` | yes | cover, upper right. `mode: argued` (with `argued_by`, `time`) or `mode: submitted` |
| `caption` | yes | list of two sides, each with `names` and `designation`; "–against–" between sides |
| `brief_title` | yes | cover title (printed in capitals, see gaps) and document title |
| `counsel` | yes | cover, lower right: `names`, `lines`, and `email` |
| `phone` | yes | cover, lower right |
| `signature` | yes | `signer` and `lines`, after the Conclusion and on the printing statement |
| `date` | no | under the signature, on the printing statement, and on the affidavit |
| `service` | no | `method`, `affiant`, and `unregistered` (list of `{name, address}`); shown only when given |
| `authorities` | yes if the body cites any | table of authorities: `kind` (case, constitution, statute, regulation, rule, other), `name`, `cite` |

Body: `#` is a section (centered, bold, capitals). `##` is a POINT heading (bold, left); `###` is the point's title; `####` is a sub-argument letter (italic). Block quotations are `>`. Footnotes are `[^key]` with a definition anywhere in the file. Escape markdown-looking leading characters (`1\.`).

## What the overlay shows

Not produced. `tools/overlay.sh` pairs each rendered page with the best-matching exemplar page by word overlap. There is no exemplar, so there is nothing to overlay.

## Known gaps (from the 10-page review)

1. **No exemplar; tier 2 not assessed.** Layout is judged against the rule only. Blocked until a filed App Div answering brief is saved (see `exemplars/SOURCE.md`).
2. **Table of authorities has no page references.** 1250.8(b)(2) requires "indicating the pages of the brief where they are cited." The template lists authorities but does not generate page numbers. **Tier 1 gap, not fixed.** A real filing needs it.
3. **Signature block alone on page 8.** The Conclusion ends on page 7 with room for about a quarter page; the signature block (about 2.2 inches) moves to the next page with no text above it. No keep-with-next control between the Conclusion and the signature block. Not fixed.
4. **Word count is approximate.** The certificate-style count is whitespace-delimited tokens of the markdown body, minus footnote definitions. It includes markup tokens (`#`, `>`, `[^`), so it overcounts slightly; the sample's printing statement reads 797 words. It is not a filing count, and the word-processor count should be substituted (1250.8(j) lets the party rely on it). No page-limit or word-limit check is enforced.
5. **Cover title in capitals.** `brief_title` is printed in capitals on the cover. 1250.8(f)(1) bars all-capital words except in headings; the cover title is treated as a heading. Judgment call, not verified against any filed cover.
6. **Double spacing is estimated, not measured.** `body-leading = 1.2em` was chosen by eye against the rendered page. Rule (h) says double-spaced; no exemplar exists to measure it against. Measure against a filed brief when one is found.
7. **Block quotation and heading spacing tuned by eye** (same caveat as item 6).
8. **Questions Presented.** The first numbered item sits flush, and item 2 takes a first-line indent (paragraph after a heading vs. after a paragraph). Cosmetic; not fixed.
9. **Pagination.** The cover counts as page 1 but is not printed. The TOC and TOA are numbered 2 and 3, and the body starts on page 4. Whether 1250.8(h)'s "numbered consecutively" wants the cover counted is not resolved by the rule text.
10. **Counterstatement and CPLR 5531.** The sample includes a respondent's counterstatement only as an optional heading. The CPLR 5531 statement (appellant-side addendum in the First and Second Departments) is not generated; see NYAD-ADD-001.
11. **Sample depth.** The sample body is roughly 800 words of placeholder text and renders to 10 pages. It is rule-built and not depth-matched to any filed brief.

## Searches for an exemplar

See `exemplars/SOURCE.md`. The sibling folder `courts/second-circuit/new-york/state/court-of-appeals/answering-brief/` is also blocked (no exemplar); its README records the same kind of search.

[Formbook index](../../../../../../README.md) | [Court folder](../README.md)

## Engines

**docx** (`docx/build-reference.sh`, `docx/reference.docx`, `docx/nyappdiv-answering-brief.lua`; output `samples/OUTPUT-<id>.docx`).

- Matches the typst form: letter, 1 in margins, EB Garamond 14 pt body, double-spaced body with a 0.5 in first-line indent, single-spaced headings, block quotations, signature block and printing statement; centered page number in the footer, none on the cover.
- Differs: "double" is Word's double spacing (`w:line="480"`), not the typst leading, so line breaks and page counts differ. Word and LibreOffice also paginate differently from each other.
- Differs: the contents is a TOC field with cached entries and no page numbers; Word or LibreOffice must update fields. The authorities list has no page references (a TOA field needs the same update, and LibreOffice does not honor TA/TOA fields).
- The cover is a centered layout with the calendar notation on the right. Footnote text is 12 pt, as the typst template sets. The affidavit of service prints the method and affiant from the metadata.
- The word count and the word limit are computed by the filter from the markdown source, not by Word.
- Validated: `tools/render.sh --engine docx` writes the `.docx`; `unzip -tq` and `xmllint --noout` pass on every XML part of the output and of `reference.docx`.

BLOCKED (docx engine, not passable on this box):

- **docx.pdf gates (Gates 0 and 1, `tools/check.sh --engine docx`): BLOCKED.** LibreOffice (`soffice`) is not installed on this box, so no `samples/OUTPUT-<id>.docx.pdf` exists and the check cannot run. Stamp `samples/.check-docx.txt` not written.
- **Pages reviewed: 0.** No `.docx` page was rendered or looked at, and the file was not opened in Word or LibreOffice, so no "no repair prompt" result is recorded.
