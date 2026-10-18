# Brief on the merits

Typst template for a petitioner's brief on the merits in the Supreme Court of Texas (`typst/main.typ`, module `typst/tex-brief-on-the-merits.typ`). The sample is transcribed from the filed *State of Texas v. F.M.V.*, No. 25-0792 brief on the merits (`usage/FILED-EXAMPLE-brief-on-the-merits.pdf`), every section of the filed brief with the argument excerpted. Rendered output: `usage/OUTPUT-brief-on-the-merits.typst.pdf` (18 pages); overlay on the filed brief: `usage/OVERLAY-hawthorne-brief-on-the-merits.pdf` and `.txt`.

## Layout

- Cover (page 1, no number): case number, court, caption, the "On Petition for Review" line, the title between rules, lead counsel block at the foot of the page (Rule 9.4(g)).
- Front matter (lower roman, from ii): each H1 section before `body_start` on its own page (identities single-spaced), then the generated table of contents (headings to level 3, bookmarked) and the index of authorities from the frontmatter `authorities` list.
- Body (arabic, from 1): the markdown from `body_start`. The signature block (frontmatter `signature`: `name`, `office`, `lines`, `for`) is set in the right half of the page after the section whose title contains "prayer"; each "certificat..." section gets a short `/s/` signature (Rule 9.5(e)); the appendix index starts a new page.
- Liberation Serif 14 pt (headings too), double-spaced (32.2 pt pitch), every paragraph indented 0.5 in, footnotes 12 pt single-spaced, block quotations single-spaced and indented 1 in each side, footnote markers as raised digits (Liberation Serif has superscript glyphs only for 1-3).
- Word count: every counted H1 section under Rule 9.4(i)(1) (2026 text), with a thousands separator, into `{{word-count}}`; the render fails over 15,000 words or when a Rule 55.2 section is missing or out of order. `rules_edition` `"2026"` (default; no statement of jurisdiction required, one may still be included) or `"2025"` (jurisdiction required). The sample uses the default; the filed brief (July 2026) keeps a statement of jurisdiction, an introduction and a standard of review between the required sections, which the order check allows.

## Governing rules

Primary source read this session (October 16, 2026): the amendments in Misc. Docket No. 25-9104 (Tex. Dec. 23, 2025; effective January 1, 2026), reproduced as the appendix of D. Todd Smith, *The Appellate Advocate* vol. 35 no. 2 (Spring 2026), <https://www.texappcounsel.com/wp-content/uploads/sites/958/2026/06/Smith-SCOTX-PFR-Article-in-Appellate-Adv-V35-No2-.pdf>. The Court's PDFs (<https://www.txcourts.gov/media/1461814/259104.pdf>, the TRAP PDF) return HTTP 403 to this box; read the redline against them before relying on it.

- Rule 9.4(c)-(e): letter paper; one-inch margins; double-spaced text (footnotes, block quotations, short lists and issues may be single-spaced); typeface at least 14 point; footnotes at least 12 point. Not re-read this session.
- Rule 9.4(g): cover contents. Not re-read this session.
- Rule 9.4(i)(1) (2026) exclusions (read): caption, identity of parties and counsel, statement regarding oral argument, table of contents, index of authorities, statement of the case, issues presented, statement of jurisdiction, statement of procedural history, signature, proof of service, certification, certificate of compliance, appendix.
- Rule 9.4(i)(2)(B): brief 15,000 words, unchanged in 2026 (read). Rule 9.4(i)(3): certificate stating the word count (read).
- Rule 55.1 (2026): a merits brief is filed only when ordered. Rule 55.2 (2026), in order (read): (a) identity of parties and counsel, (b) table of contents (bookmarked), (c) index of authorities, (d) statement of the case, (e) issues presented (with preservation cites), (f) statement of facts, (g) summary of the argument, (h) argument, (i) prayer. The 2026 text drops the statement of jurisdiction (read from the redline lettering "(fe) Issues Presented" and the article's summary).
- Rule 9.5: certificate of service, signed. Not re-read this session.

## Exemplars

Three filed merits briefs from three filers, listed with URLs in `usage/SOURCE.md`: the State brief (25-0792), Tanner (25-0648), and San Patricio County Appraisal District (26-0153). Tier-2 cross-check this pass: signature block and certificates in all three (signature in the right half after the prayer; `/s/` plus name under each certificate), which the template now follows.

## Depth pass (fb-595.38.2, October 16, 2026)

Sample extended from the statement of facts (12 pages) to the full structure: the timeline as a bulleted list (as filed), summary of the argument, standard of review, argument I (with a footnote) and II (with the numbered findings), conclusion and prayer, generated signature block, certificate of service, certificate of compliance, appendix index; the index of authorities now lists the 9 cases, 4 statutes and 2 rules cited, page numbers measured from this render. 18 rendered pages (cover, ii-iv, body 1-14); all 18 rendered at 60 dpi and looked at.

Overlay page map (ours -> filed, word overlap): 1->1 (60%), 2->6 identities (98%), 3->2 contents (42%), 4->4 index (56%), 5->7, 6->9, 7->10, 8->12, 9->13 (99%), 10->14, 11->15, 12->16, 13->18, 14->20, 15->21, 16->35 signature and service (78%), 17->36 compliance (69%), 18->37 appendix (86%). Tier-3 differences (filed text set at a narrower measure, "Page X of Y" footers, contents before identities against the rule's order): not chased.

Template fixes from the deeper sample: same as the petition template (shared code): lead counsel's name first on the cover; first paragraph after a heading indented; footnote markers from 4 up no longer a different glyph size; signature block and certificate signatures generated from frontmatter; contents to level 3 and bookmarked; required sections and order checked under Rule 55.2; count exclusions brought to the 2026 list; thousands separator in the count.

## Known gaps

- Not done: `rules.md`, `checks.yaml`, `reviews/`, `LOG.md`, the latex engine, the `tools/check.sh` gates, a second (structurally different) sample. The tracker and `court.json` are untouched.
- 18 pages is above the 8-14 target of this pass; the excerpt keeps one paragraph or a short list from each section rather than dropping a required section.
- Index of authorities page numbers are typed in frontmatter and must be re-measured whenever the text moves.
- Rule 9.4(e)-(g) and 9.5 were not re-read against primary text this session.
- The sample's certificate of compliance drops the filer's "relying on the word count of the software" wording, since the template supplies the count.
- docx (`docx/tex.lua`) was not changed: no signature block from frontmatter `signature`, count still split at "Respectfully submitted", no `rules_edition` or order check. No `soffice` on this box, so `usage/OUTPUT-brief-on-the-merits.docx` and `.docx.pdf` were NOT regenerated and are stale against the extended INPUT.

[Formbook index](../../../../../../README.md)

## Engines

**docx** (`docx/`: `render.sh` runs two pandoc passes, `tex.lua` is the filter, `reference.docx` comes from `build-reference.sh`). Checked on the LibreOffice PDF (`usage/OUTPUT-brief-on-the-merits.docx.pdf`). The `.docx` opened in LibreOffice without a repair prompt; Word was not available and not checked. `checks.yaml` and `rules.md` do not exist yet, so `tools/check.sh --engine docx` cannot run.

Matches the typst form: Liberation Serif 14 pt; exact 32.2 pt double and 16.2 pt single line pitch (same as typst, measured with `pdftotext -bbox`); 1 in margins on letter; cover unnumbered and without a footer; front matter in lower roman from ii; body in arabic from 1; cover lead-counsel block at the bottom margin; the contents with dot leaders and page numbers from the layout (PAGEREF fields, filled from a first pass); the index of authorities from the frontmatter page numbers; word count on the markdown source with the typst rules (1,148 words here, limit 15,000). The contents page numbers equal typst's on this sample. Page count: 12 in both.

Differs:
- Justified lines: typst shrinks word spaces when it justifies, Word and LibreOffice do not, so the docx fits fewer words on some lines. Body lines per page are 19 vs 20 (page 5), 20 vs 21 (page 7) and 21 vs 20 (page 11) in the docx vs typst; the last page is longer in the docx (14 vs 10 lines).
- Space above headings: typst drops it at the top of a page. The docx puts it on the paragraph before each heading (style `BodyBeforeHeading`), so a heading at a page top sits at the margin as in typst.
- Headings are 16 pt bold (H1 centered, H2 flush left), as the typst headings render.
- Table of authorities: page numbers are typed in the frontmatter as in typst; no TOA field.

BLOCKED: tier-1 pagination (body line counts per page): the docx wraps justified lines differently from typst on pages 5, 7, 11 and 12 (renderer difference in word spacing; see `docs/DOCX.md`, "Pagination differs by renderer"). Page count and contents page numbers still match typst on this sample.
