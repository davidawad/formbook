# Brief on the merits

Typst template for a petitioner's brief on the merits in the Supreme Court of Texas (`typst/main.typ`, module `typst/tex-brief-on-the-merits.typ`). The sample is an excerpt transcribed from the filed *State of Texas v. F.M.V.*, No. 25-0792 brief on the merits (`exemplars/FILED-EXAMPLE-hawthorne-25-0792-brief-on-the-merits.pdf`). Rendered output: `samples/OUTPUT-hawthorne-brief-on-the-merits.pdf`; overlay on the filed brief: `samples/OVERLAY-hawthorne-brief-on-the-merits.pdf` and `.txt`.

## Layout

- Cover (page 1, no number): court and case number, caption, the "On Petition for Review" line, the title between rules, and the lead counsel block at the foot of the page (Rule 9.4(g)).
- Front matter (lower roman, from ii): identities of parties and counsel from the markdown (single-spaced, as the exemplars set counsel lists), then the generated table of contents, then the index of authorities generated from the frontmatter `authorities` list.
- Body (arabic, from 1): the markdown from the heading named in frontmatter `body_start`.
- Text is Liberation Serif 14 pt, double-spaced (32.2 pt baseline pitch, measured with `pdftotext -bbox`), footnotes 12 pt single-spaced, block quotations single-spaced and indented one inch each side. Headings are centered bold (H1) or bold left (H2, H3).
- The contents are generated from the headings with page numbers from the layout. The index of authorities page numbers are typed in frontmatter by the author, measured from the rendered PDF (body page numbers).
- Word count: `word-count` counts the words of the counted sections under the 2026 text of Rule 9.4(i)(1) (headings, footnotes and quotations count; caption, identities, tables, the case, issue and jurisdiction statements, signature, certificates and appendix do not). The count replaces `{{word-count}}` in the certificate of compliance. `assert` fails the render when the count exceeds the limit.

## Governing rules

Source notes. The Texas Rules of Appellate Procedure PDF (`txcourts.gov/media/1463134/...`) returned HTTP 403 to every fetch attempted on October 15, 2026, so the rule numbers below are carried over from the October 14 review and have **not been re-read against the rule text in this session**. The word-count exclusions were confirmed by a secondary search of the 2026 amendment (Misc. Docket No. 25-9104) and should also be read against the rule text.

- Rule 9.4(c)–(e): letter paper; one-inch margins; double-spaced text; conventional typeface at least 14 point; footnotes at least 12 point.
- Rule 9.4(g): cover contents (case style and number, title, filing party, lead counsel's name, address, telephone, email, Texas Bar number).
- Rule 9.4(i)(1)–(2): word limit for a brief on the merits, 15,000 words, computer-generated (`word-limit` in the module). Count exclusions as above.
- Rules 55.1 and 55.2: a merits brief is filed when ordered. Order of contents: identities, table of contents, index of authorities, statement of the case, issues, facts, summary, argument, prayer, certificates, appendix.
- Rule 9.5: certificate of service.

## Exemplars

Three filed merits briefs from three filers, listed with URLs in `exemplars/SOURCE.md`: the State brief (25-0792), Tanner (25-0648), and San Patricio County Appraisal District (26-0153). Tier 2 (cover, contents, authorities, heading layout) is judged against all three.

## Known gaps

- Not done in this pass: `rules.md`, `checks.yaml`, `reviews/`, `LOG.md`, the latex and docx engines, and the `tools/check.sh` gates. The tracker and `court.json` are untouched.
- The sample stops at the statement of facts, so the summary, argument, prayer, signature, certificate of service and certificate of compliance are not exercised by the render. Their template code is untested.
- Index of authorities page numbers must be re-measured whenever the body text changes.
- Appendix and electronic-filing PDF requirements are not implemented.

[Formbook index](../../../../../../README.md)

## Engines

**docx** (`docx/`: `render.sh` runs two pandoc passes, `tex.lua` is the filter, `reference.docx` comes from `build-reference.sh`). Checked on the LibreOffice PDF (`samples/OUTPUT-hawthorne-brief-on-the-merits.docx.pdf`). The `.docx` opened in LibreOffice without a repair prompt; Word was not available and not checked. `checks.yaml` and `rules.md` do not exist yet, so `tools/check.sh --engine docx` cannot run.

Matches the typst form: Liberation Serif 14 pt; exact 32.2 pt double and 16.2 pt single line pitch (same as typst, measured with `pdftotext -bbox`); 1 in margins on letter; cover unnumbered and without a footer; front matter in lower roman from ii; body in arabic from 1; cover lead-counsel block at the bottom margin; the contents with dot leaders and page numbers from the layout (PAGEREF fields, filled from a first pass); the index of authorities from the frontmatter page numbers; word count on the markdown source with the typst rules (1,148 words here, limit 15,000). The contents page numbers equal typst's on this sample. Page count: 12 in both.

Differs:
- Justified lines: typst shrinks word spaces when it justifies, Word and LibreOffice do not, so the docx fits fewer words on some lines. Body lines per page are 19 vs 20 (page 5), 20 vs 21 (page 7) and 21 vs 20 (page 11) in the docx vs typst; the last page is longer in the docx (14 vs 10 lines).
- Space above headings: typst drops it at the top of a page. The docx puts it on the paragraph before each heading (style `BodyBeforeHeading`), so a heading at a page top sits at the margin as in typst.
- Headings are 16 pt bold (H1 centered, H2 flush left), as the typst headings render.
- Table of authorities: page numbers are typed in the frontmatter as in typst; no TOA field.

BLOCKED: tier-1 pagination (body line counts per page): the docx wraps justified lines differently from typst on pages 5, 7, 11 and 12 (renderer difference in word spacing; see `docs/DOCX.md`, "Pagination differs by renderer"). Page count and contents page numbers still match typst on this sample.
