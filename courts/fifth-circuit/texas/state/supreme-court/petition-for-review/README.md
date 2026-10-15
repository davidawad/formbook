# Petition for review

Typst template for a petition for review in the Supreme Court of Texas (`typst/main.typ`, module `typst/tex-petition-for-review.typ`). The sample is an excerpt transcribed from the filed *State of Texas v. F.M.V.*, No. 25-0792 petition (`exemplars/FILED-EXAMPLE-hawthorne-25-0792-petition-for-review.pdf`). Rendered output: `samples/OUTPUT-hawthorne-petition-for-review.pdf`; overlay on the filed petition: `samples/OVERLAY-hawthorne-petition-for-review.pdf` and `.txt`.

## Layout

- Cover (page 1, no number): court and case number, caption, the "On Petition for Review" line, the title between rules, and the lead counsel block at the foot of the page (Rule 9.4(g)).
- Front matter (lower roman, from ii): identities of parties and counsel from the markdown, then the generated table of contents, then the index of authorities generated from the frontmatter `authorities` list.
- Body (arabic, from 1): the markdown from the heading named in frontmatter `body_start`.
- Text is Liberation Serif 14 pt, double-spaced (32.2 pt baseline pitch, measured with `pdftotext -bbox`), footnotes 12 pt single-spaced, block quotations single-spaced and indented one inch each side. Headings are centered bold (H1) or bold left (H2, H3).
- The contents are generated from the headings with page numbers from the layout. The index of authorities page numbers are typed in frontmatter by the author, measured from the rendered PDF (body page numbers).
- Word count: `word-count` in the template counts the words of the counted sections under the 2026 text of Rule 9.4(i)(1) (headings, footnotes and quotations count; caption, identities, tables, the case, issue and jurisdiction statements, signature, certificates and appendix do not). The count replaces `{{word-count}}` in the certificate of compliance. `assert` fails the render when the count exceeds the limit.

## Governing rules

Source notes. The Texas Rules of Appellate Procedure PDF (`txcourts.gov/media/1463134/...`) returned HTTP 403 to every fetch attempted on October 15, 2026, so the rule numbers below are carried over from the October 14 review and have **not been re-read against the rule text in this session**. The word-count exclusions were confirmed by a secondary search of the 2026 amendment (Misc. Docket No. 25-9104) and should also be read against the rule text.

- Rule 9.4(c)–(e): letter paper; one-inch margins; double-spaced text; conventional typeface at least 14 point; footnotes at least 12 point.
- Rule 9.4(g): cover contents (case style and number, title, filing party, lead counsel's name, address, telephone, email, Texas Bar number).
- Rule 9.4(i)(1)–(2): word limit for a petition for review, 4,500 words, computer-generated (`word-limit` in the module). Count exclusions as above.
- Rule 53.2: order of contents: identities, table of contents, index of authorities, statement of the case, jurisdiction, issues, facts, summary, argument, prayer, appendix.
- Rule 9.5: certificate of service.

## Exemplars

Three filed petitions from three filers, listed with URLs in `exemplars/SOURCE.md`: the State petition (25-0792), Tanner (25-0648), and San Patricio County Appraisal District (26-0153). Tier 2 (cover, contents, authorities layout) is judged against all three.

## Known gaps

- Not done in this pass: `rules.md`, `checks.yaml`, `reviews/`, `LOG.md`, the latex and docx engines, and the `tools/check.sh` gates. The tracker and `court.json` are untouched.
- The sample stops at the statement of facts, so the conclusion, prayer, signature, certificate of service and certificate of compliance are not exercised by the render. Their template code is untested.
- Index of authorities page numbers must be re-measured whenever the body text changes.
- Appendix and electronic-filing PDF requirements (searchable text, bookmarks, size cap) are not implemented.

[Formbook index](../../../../../../README.md)

## Engines

**docx** (`docx/`: `render.sh` runs two pandoc passes, `tex.lua` is the filter, `reference.docx` comes from `build-reference.sh`). Checked on the LibreOffice PDF (`samples/OUTPUT-hawthorne-petition-for-review.docx.pdf`). The `.docx` opened in LibreOffice without a repair prompt; Word was not available and not checked. `checks.yaml` and `rules.md` do not exist yet, so `tools/check.sh --engine docx` cannot run.

Matches the typst form: Liberation Serif 14 pt; exact 32.2 pt double and 16.2 pt single line pitch (same as typst); 1 in margins on letter; cover unnumbered and without a footer; front matter in lower roman from ii; body in arabic from 1; cover lead-counsel block at the bottom margin; the contents with dot leaders and page numbers from the layout (PAGEREF fields, filled from a first pass); the index of authorities from the frontmatter page numbers; word count on the markdown source with the typst rules (656 words here, limit 4,500). Page count: 10 in both.

Differs:
- Justified lines: typst shrinks word spaces when it justifies, Word and LibreOffice do not, so the docx fits fewer words on some lines. Body lines per page are 19 vs 20 (page 5), 19 vs 20 (page 6), 18 vs 20 (page 7) and 19 vs 21 (page 8) in the docx vs typst, so the docx runs about one page later from the statement of the case on.
- Space above headings: typst drops it at the top of a page. The docx puts it on the paragraph before each heading (style `BodyBeforeHeading`).
- Headings are 16 pt bold (H1 centered, H2 flush left), as the typst headings render.
- Table of authorities: page numbers are typed in the frontmatter as in typst; no TOA field.

BLOCKED: tier-1 pagination (body line counts per page): the docx wraps justified lines differently from typst on pages 5 to 8, so the contents labels for ISSUE PRESENTED (docx 3, typst 2), B. F.M.V.'s Detention and Magistration (docx 5, typst 4) and C. Trial and Disposition (docx 6, typst 5) are one page later than typst. Renderer difference in word spacing (see `docs/DOCX.md`, "Pagination differs by renderer"); the contents follow the docx layout. Total pages match (10).
