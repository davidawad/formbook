# U.S. Bankruptcy Court, M.D. Pennsylvania (pamb): motion brief

Doc type: **motion-brief** (the brief, or memorandum of law, that supports a motion under Fed. R. Bankr. P. 9013 in a contested matter, filed with the motion). Court: United States Bankruptcy Court for the Middle District of Pennsylvania. Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/motion-brief/`.

Status: exemplar=yes (one brief, one filer; the motion it supports is not in the exemplar), render=ok, pages reviewed 7 of 7 on typst and docx. Typst and docx are on the shared cross-engine layout model (fb-595.68.34): the docx breaks every line and page where typst does (XENG-001..003 gated, `eval.yaml`). Nothing here sets `status` in `court.json`.

## Governing rules

Sources, all fetched 2026-10-14:

- **Local rules.** United States Bankruptcy Court, M.D. Pa., Local Bankruptcy Rules PDF, `https://www.pamb.uscourts.gov/sites/default/files/local-rules/usbc_pamb_local_rules.pdf` (the court's list, https://www.pamb.uscourts.gov/court-info/local-rules-and-orders, shows it as effective October 1, 2025). The PDF's cover prints "Effective: January 1, 2005", which is inconsistent with the court's list; confirm the operative version. Quotations below are from that PDF.
- **Federal rules.** Fed. R. Bankr. P. 9013 and 9004 as published on Cornell LII (`https://www.law.cornell.edu/rules/frbp/rule_9013`, `.../rule_9004`), current text effective December 1, 2024.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| PAMB-MOT-001 | FRBP 9013(a)-(b) | "A request for an order must be made by written motion." "A motion must state its grounds with particularity and set forth the relief or order requested." | The brief states the grounds (author content, from the sample). `title` carries the relief. |
| PAMB-MOT-002 | L.B.R. 9013-1(a) | "The title of each motion must identify the party filing the motion and the nature of the relief sought." | `title` (frontmatter, required). The template does not check the wording; the author must. |
| PAMB-MOT-003 | L.B.R. 9013-1(b) | "Each motion must be accompanied by a proposed form of order." | **Not generated.** A separate document. See gaps. |
| PAMB-MOT-004 | L.B.R. 9013-1(c)-(e) | Service of the motion on the respondent, the debtor, committees and others, unless served through ECF. | Not generated (the service list is the author's). The certificate of service carries the service record (PAMB-MOT-006). |
| PAMB-MOT-005 | L.B.R. 9013-2(a), (b), (d) | (a) "no brief ... shall exceed fifteen (15) pages"; (b) a brief may run to 5,000 words, with "a certificate ... that the brief complies with the word-count limit" that "must state the actual number of words"; (d) "a table of contents, with page references, and table of citations" for a brief of more than 15 pages. A brief "may address only one motion." | (a) and (d): the template **stops the build** with a message if the document exceeds 15 pages, because it does not generate the table of contents and table of authorities. (b): `word_count` in the frontmatter prints the certificate; the template does not count words. One-motion rule: author. |
| PAMB-MOT-006 | L.B.R. 9013-3 | A certificate of service containing "(a) the title of the paper served; (b) the names and addresses of all persons upon whom the paper has been served; (c) the entities the persons served represent; and (d) a description of when and how service was made." | `certificate-of-service` (title, names, addresses, `represents`, date, method, signer). |
| PAMB-MOT-007 | FRBP 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." No paper-size, font, or margin rule in the current text. | Vendored Times New Roman only (`fallback: false`); 12 pt; 1 in margins; US Letter. |
| PAMB-MOT-008 | L.B.R. 9004-1 | A pleading in a contested matter must have a caption "substantially in compliance with L.B.F. 9004-1." The form was not retrieved. | `caption-table` follows the filed exemplar's main-case caption (court, debtor block, chapter, case no.). Not checked against L.B.F. 9004-1. |
| PAMB-MOT-009 | L.B.R. 7007-1(a), (e) | For a motion filed in an adversary proceeding: a descriptive title, a caption substantially compliant with Official Form 416D, and a proposed order attached. | **Not built**: this template covers the contested-matter caption only. See gaps. |

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: "Brief in Support of Debtor's Motion to Deem Bankruptcy Filing Effective as of February 4, 2022", James Mullen, Chapter 13 debtor, Case No. 5-22-00237, by counsel Tullio DeLuca, Esq. Filed 2022-05-16. 8 pages, text layer present (embedded none; Times and Helvetica standard fonts, Liberation Sans embedded).
- Provenance and searches: `usage/SOURCE.md`.
- The exemplar is the **brief**. Its motion (the debtor's Motion to Deem Bankruptcy Filing Nunc Pro Tune, filed 2022-04-16) is not in this folder. The template covers the caption, title, memorandum, signature, and certificate of service of the brief.
- Only one exemplar of a motion memorandum from this court with a text layer. The eval-loop tier-2 rule asks for two or three from different filers. Not met; see gaps.
- Text-layer note: the PDF's text layer maps some glyphs wrongly (the roman "I." reads as "1.", and apostrophes are dropped). The printed page image was checked for the heading and the apostrophe ("DEBTOR'S"), and the sample follows the image.

## Sample

- `usage/INPUT-motion-brief.md`: the caption, title, the lead-in, the four sections (Statement of Facts, Question Presented, Argument, Conclusion) with the argument in full, the signature block and the certificate of service. The filed certificate does not state which entity each served person represents; the sample's `represents` fields are bracketed placeholders.
- Frontmatter: `court`, `debtor` (name, chapter, case_number), `title`, `signature` (signer, lines), `date` (printed on the certificate), `certificate_of_service` (date, method, served list, signer). Optional: `word_count` (prints the L.B.R. 9013-2(b) certificate).
- Headings: top level numbered I., II., ...; second level A., B., ...; third level 1., 2., ... The template numbers them; the author does not type numbers. The filed copy uses roman numerals at the top level (confirmed on the page image).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq
sh tools/render.sh courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/motion-brief mullen-deem-effective
```

- File names follow the tools: `usage/OUTPUT-motion-brief.typst.pdf` (our render; 7 pages; typst with no warnings), `usage/OVERLAY-mullen-deem-effective.pdf` and `.txt` (red = ours, blue = filed, black = both).
- Fonts: Times New Roman 12 pt (vendored), in typst and docx alike (it was EB Garamond until fb-595.68.34).
- Overlay page map (of the earlier EB Garamond render, not re-run): ours p.1-4 ↔ filed p.1-4 (89%, 75%, 61%, 49%); ours p.5 ↔ filed p.6 (59%); ours p.6 ↔ p.7 (73%); ours p.7 ↔ p.8 (74%). The filed brief has one page more of body than ours; the overlay is a diagnostic, not a score, and the typefaces differ.

## Visual review (Gate 2 record: all 7 pages on each engine, rendered at 45 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 168/168).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (IN RE, the three name lines single spaced, "Debtor"; Chapter 13, Case No.), title, lead-in, I. Statement of Facts begins | OK. |
| 2 | Statement of Facts end, II. Question Presented, III. Argument begins | OK. Headings keep with their text; the label in a 0.5 in box, the title after it. |
| 3 | Argument: Rule 5005, retroactive relief, italic *In re* and *nunc pro tunc* | OK. |
| 4 | Argument: the factors applied, equities | OK. |
| 5 | Argument: equities end, Pennsylvania analogy | OK. The page ends a third short: the conclusion is kept with the signature. Accepted (the signature never stands alone). |
| 6 | IV. Conclusion, signature block | OK. |
| 7 | Certificate of service: court title and caption repeated, title, served persons with addresses and representation placeholders, date and signature | OK. The whole certificate fits on the page. |

Pages reviewed: 7 of 7 (typst), 7 of 7 (docx). No open tier-2 finding. Changes in this pass: the debtor's name lines single spaced (were apart by cmarker's paragraph spacing); headings on the body pitch with no space of their own (were single spaced with 12 pt around them); the signature and certificate lines single spaced from 3.3 in.

## Known gaps and open choices

1. **Proposed order (PAMB-MOT-003).** L.B.R. 9013-1(b) and 7007-1(e) require one. A separate document; not generated.
2. **Table of contents and table of authorities (PAMB-MOT-005).** Required above 15 pages. Not generated: the template stops instead of printing a non-compliant brief. The stop is not exercised by a test here.
3. **Word-count certificate.** Printed only when `word_count` is given; the template does not count words. The rule requires the count to be the word-processor's, stated as an actual number.
4. **Adversary-proceeding caption (PAMB-MOT-009).** Not built. A brief in an adversary must carry the complete adversary caption and be substantially compliant with Form 416D. The contested-matter caption here is not that.
5. **L.B.F. 9004-1 caption.** The contested-matter caption is modeled on the filed exemplar; the form itself was not retrieved.
6. **Title content (PAMB-MOT-002).** The template requires `title` but does not check that it names the filing party and the relief.
7. **Font, margins, spacing.** Typeface row: face required = none; Times New Roman, the house face (`docs/FONTS.md` row "No face named"; was EB Garamond); fit = n/a. Checked 2026-10-15 against the full text of the local rules PDF (no rule on font, typeface, point size, margins or spacing; L.B.R. 9004-1 governs the caption only) and FRBP 9004(a) (legibility only). Times New Roman 12 pt, 1 in margins, double-spaced body (24 pt pitch), following the filed copy's look. Convention.
8. **Paper size.** US Letter; no rule text found. Convention.
9. **Tier-2 exemplars.** One exemplar. A second and third from different filers were not found as text-based PDFs. Also examined and not used: the Madeam trustee's Memorandum of Law in Support of Motion to Dismiss (5-22-bk-01575, Doc 33, 7 pages, text layer present), a standalone memorandum from a trustee; it could serve as a second tier-2 reference in a later pass.
10. **Certificate placeholders.** `represents` is a bracketed placeholder for each served person (the filed certificate does not state it).
11. **Lists in the body.** Not supported: every chunk that is not a heading is a paragraph in both engines (typst sets a list chunk as a paragraph; the docx filter rejects a list, a quotation or a table rather than drop it). The sample has none.

## Engines

Engine status: typst `OUTPUT-motion-brief.typst.pdf`; docx `OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice), 7 pages each, every line and page as typst (XENG-001..003 gated); latex not built.

- **typst** (primary, `typst/`): on `lib/typst/xengine.typ`: a 24 pt body pitch, 14 pt single lines (court title, caption, title, signature, certificate, footer), explicit block spaces.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 24 pt lines with a 0.5 in first-line indent; single lines in 14 pt boxes) and `docx/pamb.lua` (on `lib/docx/xengine.lua`; the same file as the adversary complaint's but for its `CFG.kind`), which writes every paragraph: the court title, the caption (a one-row table, the left cell bordered at the right and foot), the title, the labelled headings (I., A., 1., a. and a tab), the signature block, the certificate of service on its own page, the word-count certificate when `word_count` is given, the footer (a centred PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh` and a committed `reference.docx` in EB Garamond 13 pt). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- The 15-page limit of L.B.R. 9013-2(a) stops the typst build; the docx does not count pages (DEF-LEN-001 SKIPs: no machine-readable `page_limit`). No table of contents or authorities in either engine (see gaps).
- **docx BLOCKED items:** none. `tools/check.sh <this folder> --engine docx`: `RESULT: 13 checks passed, 0 failed`; typst: `RESULT: 9 checks passed, 0 failed`.

## Searches tried

- CourtListener search API (`/api/rest/v4/search/`), `type=rd`, `court=pamb`: "Brief in Support", "Memorandum of Law", "Motion" with "Memorandum of Law", "Motion" with "Brief in Support", "motion to dismiss brief in support". Hosted PDFs checked: the Mullen brief (5-22-00237, Doc 32, 8 pages, text) used; the Madeam trustee memorandum (5-22-bk-01575, Doc 33, 7 pages, text) examined, not used as the exemplar; the sanctions motion (214443, Doc 127, 26 pages) a scan with no text layer, not used; Rosario, Memorandum of Law and Fact (264466, Doc 59, 3 pages) not examined in full.
- Web search for pamb memoranda and briefs: no further text-based PDFs.

[Court root](../README.md) | [Adversary complaint](../adversary-complaint/README.md)
