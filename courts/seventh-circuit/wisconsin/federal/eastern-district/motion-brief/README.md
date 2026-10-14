# wied: motion-brief

Doc type: **motion-brief**, the memorandum (brief) in support of a Rule 12(b)(6) motion to dismiss, in the United States District Court for the Eastern District of Wisconsin (`wied`).
Folder: `courts/seventh-circuit/wisconsin/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-nocams-2-26-cv-01863-motion-brief.pdf` (14 pp.; the overlay reference). Second filer: `FILED-EXAMPLE-schmidt-2-26-cv-00611-motion-brief.pdf` (9 pp.). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-nocams-motion-brief.md` (the whole brief, transcribed from the text layer) |
| render | ok: `samples/OUTPUT-nocams-motion-brief.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-nocams-motion-brief.pdf` and `OVERLAY-nocams-motion-brief.txt` (against the Nocams exemplar) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed in montage, three montages covering pages 1 to 12, after the last template change) |

## Governing rules

Primary source: Local Rules of the United States District Court for the Eastern District of Wisconsin, "Local Rules 2010-0201, Amended 2026-0729" (71 pp.), fetched 2026-10-14 from https://www.wied.uscourts.gov/sites/wied/files/documents/Local%20Rules%202010-0201-Amended%202026-0729.pdf (linked from https://www.wied.uscourts.gov/local-rules-and-guidance).

Federal Rules of Civil Procedure, from the Legal Information Institute (https://www.law.cornell.edu/rules/frcp), fetched 2026-10-14: Rule 12(b).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| General L.R. 5(a)(5) | 8½ × 11 inch paper; double-spaced text; quotations more than two lines long may be indented and single-spaced; headings and footnotes may be single-spaced; margins of at least one inch on all four sides; page numbers may go in the margins. | `margin = 1in`, `body-leading` (24 pt baseline pitch, measured), `single-leading` for caption, headings, block quotations, signature. Page number centered in the bottom margin. Block quotations (markdown `>`) are single-spaced and indented 0.5 in each side. |
| General L.R. 5(a)(6) | A proportionally spaced face must include serifs (sans-serif allowed in headings and captions) and be 12-point or larger. | `font-family = "EB Garamond"`, `type-size = 12pt`. |
| General L.R. 5(a)(7) | Plain roman type; italics or boldface for emphasis; case names italicized or underlined. | Body is roman; `*...*` in markdown renders italic (`inl`, `md`). The sample italicizes case names; see gap 1. |
| General L.R. 5(c) | Signature block: `s/ [attorney name]`, attorney name, bar number, attorney for (party), firm, address, telephone, e-mail. | `signature-block()`, one `s/` line per signer. |
| Civil L.R. 7(a) | A motion must state the rule it is made under and be accompanied by a supporting memorandum (or a certificate that none will be filed). | The brief is the memorandum; the motion itself is a separate document, not produced here. |
| Civil L.R. 7(f) | The principal memorandum in support of a motion must not exceed 30 pages; a reply must not exceed 15 pages; the caption, cover, tables and signature block are excluded from the count. | No check in the template (the count is not enforceable in typst). The Nocams sample is 12 pages including the caption and signature (about 11 pages of text), well under 30. |
| Civil L.R. 7(j) | Unreported decisions may be cited; an unavailable one must be served on the parties (and on pro se parties). | Content only. |
| Civil L.R. 7(k) | Notice of Supplemental Authority is a separate filing without argument. | Not produced here. |
| Fed. R. Civ. P. 12(b)(6) | Motion to dismiss for failure to state a claim. | The brief's standard of review and argument are the sample's content, not the template's. |

Not produced by this template (separate filings, not part of the brief): the motion itself (Civil L.R. 7(a)), any declaration or exhibits, the proposed order (Civil L.R. 7(a)), and any certificate of service. A certificate of service is not required for papers served through ECF (Civil L.R. 5); a paper served on a pro se party needs one. The ECF header is added by the court's electronic system at filing and is not added here.

## Layout

- Court title, centered bold caps, on the first page; caption with party names on the left, "Case No." on the right, no ruled box.
- Document title centered bold caps (for example, "BRIEF IN SUPPORT OF DEFENDANTS' MOTION TO DISMISS").
- Body paragraphs are not numbered. A first-line indent of 0.5 in; double-spaced (24 pt pitch).
- Section headings (`#`, e.g. INTRODUCTION, ARGUMENT, CONCLUSION): centered bold caps.
- Argument headings (`##`, "I. TEXT"): bold, with the numeral in a hanging column; wrapped lines align with the text.
- Sub-headings (`###`, "a. Text"): bold italic, indented 0.5 in.
- Block quotations (`>`): single-spaced, indented 0.5 in on each side, double-spaced above and below.
- Signature block: "Dated this ... day of ..." (sample field `date`), then firm, role, `s/` line, name, bar number for each signer, address, telephone and e-mail, in the right half of the page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number`, `caption.parties` (list of `{names: [...], designation}`; "v." is inserted between parties), `document_title`, `jury_demand` (not used by briefs; keep false), `date` (the words after "Dated this", e.g. `7th day of October, 2026`), `signature` (`firm`, `role`, `signers: [{name, bar, email}]`, `address: [lines]`, `telephone`).
- Body: blank-line-separated chunks. `#` = section heading; `##` = argument heading ("I. TEXT"); `###` = sub-heading ("a. Text"); `>` = block quotation; any other chunk = a paragraph.
- Case names and signals (*Id.*, *See*) are italic in the markdown (`*...*`).
- Not supported: tables (none in this doc type's exemplars), footnotes, raw typst, numbered paragraphs (briefs are not numbered).

## Known gaps and open choices

1. **Case-name italics are not from the exemplar.** General L.R. 5(a)(7) requires case names in italics or underline. The Nocams text layer carries no italic information, so the exemplar's roman case names could not be copied as-is. The sample italicizes case names as the rule requires. The template is rule-driven; the italics come from the sample's markdown, not the template.
2. **Font.** Same as the complaint: EB Garamond at 12 pt, which has a smaller x-height than the Times New Roman of the exemplars. The 12-point minimum is met. The Times-metric system font is not allowed, and `fonts/` is shared, so it is not changed here.
3. **Signature block alone on the last page.** The conclusion ends on page 11 and the whole signature block (unbreakable, `breakable: false`) starts page 12. The exemplar puts its signature block after its last paragraph on the same page, but the pagination differs with the font. Accepted; not forced.
4. **No table of contents or table of authorities.** E.D. Wis. Civil L.R. 7 does not require one for a brief under 30 pages (the Nocams and Schmidt briefs have none). The template does not generate one.
5. **Second filer, not overlaid.** `tools/overlay.sh` compares against the first exemplar only (Nocams). Schmidt was checked by reading its layout (caption, roman-numeral headings, conclusion, signature), not by overlay.
6. **Page limit not enforced.** Civil L.R. 7(f) limits the principal brief to 30 pages. The template cannot count pages against the limit; the reviewer must check the rendered page count.
7. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and a `rules.md` in the court directory. This doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent for this doc type.

## Review of the rendered pages (`samples/OUTPUT-nocams-motion-brief.pdf`, 12 pages)

Rendered at 60 dpi, viewed in montage (pages 1 to 4, 5 to 8, 9 to 12) after the last template change.

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, caption (parties; case number right), document title, opening paragraph, INTRODUCTION. | Pass. Caption and title fit on the first page. |
| 2 | ARGUMENT heading, I. STANDARD OF REVIEW, sub-heading a., paragraphs. | Pass. Hanging numeral aligned; sub-heading indented; no heading at the foot of a page. |
| 3 | Continuation of section I (sub-heading b.); II. heading wraps to two lines with the text aligned after the numeral. | Pass. |
| 4 | Section II and III headings; section III's heading wraps to two lines, aligned. | Pass. |
| 5 | Section III paragraphs (Tuggle, Edwards, Katz citations). | Pass. Italic case names and signals. |
| 6 | Section III to IV heading. | Pass. |
| 7 | Section IV, sub-heading a. (Haidinger standing). | Pass. |
| 8 | Section IV sub-heading b. (associational standing), paragraphs. | Pass. |
| 9 | Associational standing, paragraphs. | Pass. |
| 10 | Sub-heading c. (taxpayer standing), block quotation (single-spaced, indented, with spacing above and below). | Pass. Block quotation as General L.R. 5(a)(5) allows. |
| 11 | Taxpayer standing paragraphs, CONCLUSION. | Pass. |
| 12 | "Dated this 7th day of October, 2026." and the signature block with two signers, address, telephone and e-mail. | Pass. Block alone on the last page (gap 3). |

Gate 2 rows, with the overlay: page-level word overlap is 31% (page 12, the signature page) to 95% (page 1); see `samples/OVERLAY-nocams-motion-brief.txt`. The low pages are the signature page and pages where the exemplar's pagination differs. Not a score.
