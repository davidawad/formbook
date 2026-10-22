# Brief on the merits

Typst template for a petitioner's brief on the merits in the Supreme Court of Texas (`typst/main.typ`, module `typst/tex-brief-on-the-merits.typ`). The sample is transcribed from the filed *State of Texas v. F.M.V.*, No. 25-0792 brief on the merits (`usage/FILED-EXAMPLE-brief-on-the-merits.pdf`), every section of the filed brief with the argument excerpted. Rendered output: `usage/OUTPUT-brief-on-the-merits.typst.pdf` (18 pages; `usage/OUTPUT-brief-on-the-merits.docx` and `.docx.pdf` the same pages); overlay on the filed brief: `usage/OVERLAY-hawthorne-brief-on-the-merits.pdf` and `.txt`.

## Layout

- Cover (page 1, no number): case number, court, caption, the "On Petition for Review" line, the title between rules, lead counsel block at the foot of the page (Rule 9.4(g)).
- Front matter (lower roman, from ii): each H1 section before `body_start` on its own page (identities single-spaced), then the generated table of contents (headings to level 3, bookmarked) and the index of authorities from the frontmatter `authorities` list.
- Body (arabic, from 1): the markdown from `body_start`. The signature block (frontmatter `signature`: `name`, `office`, `lines`, `for`) is set in the right half of the page after the section whose title contains "prayer"; each "certificat..." section gets a short `/s/` signature (Rule 9.5(e)); the appendix index starts a new page.
- Times New Roman 14 pt (Rule 9.4(e); headings too, bold), footnotes 12 pt; on the shared cross-engine layout model (`lib/typst/xengine.typ`; docs/EVAL-LOOP.md, "Cross-engine gate"): ragged right, first-fit line breaks, no kerning, ligatures or hyphenation, every line a box of its pitch. Pitches: 32.2 pt double-spaced text (Rule 9.4(d); Word's double line at 14 pt), 16.1 pt single lines (cover, headings, quotations, identities, contents, index, signature, footer), 13.8 pt footnote lines, 7 pt between notes. Headings sit on the text's double-spaced grid (12.9 pt above the line, 3.2 pt below) and stay with the text after them; level 1 centered, level 2 flush left, level 3 bold italic half an inch in. Every paragraph indented 0.5 in (also the first after a heading, as the filers do); block quotations single-spaced, 1 in in from each side, a single line around and between their paragraphs; lists with the number or bullet in a half-inch box; identities single-spaced, 8 pt apart.
- Contents rows and index rows: the text wraps before a page column (36 pt contents; 56 pt index, or the page list's own width and 7 pt), the dot leader runs from the end of the text to the page; contents levels step in half an inch, an authority's second line hangs half an inch. The prayer's last paragraph and the signature block are kept on one page.

- Word count: every counted H1 section under Rule 9.4(i)(1) (2026 text), with a thousands separator, into the count typed in the markdown (literal); the render fails over 15,000 words or when a Rule 55.2 section is missing or out of order. `rules_edition` `"2026"` (default; no statement of jurisdiction required, one may still be included) or `"2025"` (jurisdiction required). The sample uses the default; the filed brief (July 2026) keeps a statement of jurisdiction, an introduction and a standard of review between the required sections, which the order check allows.

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

- Not done: `rules.md`, `checks.yaml`, `reviews/`, `LOG.md`, the latex engine, a second (structurally different) sample. The tracker and `court.json` are untouched.
- Index of authorities page numbers are typed in frontmatter (re-measured with `pdftotext` per page on the fb-595.68.36 render) and must be re-measured whenever the text moves.
- Rule 9.4(e)-(g) and 9.5 were not re-read against primary text this session.
- The sample's certificate of compliance drops the filer's "relying on the word count of the software" wording, since the template supplies the count.

[Formbook index](../../../../../../README.md)

## Engines

**typst** (`typst/`): the reference. **docx** (`docx/`, fb-595.68.36): `reference.xml` (base="xengine": the cross-engine recipe in the typst face, `{font}`, with the pitches in twips: 644 body, 322 single, 276 footnotes; Heading 1-3, Block Text, Body Text Note, Body Keep, Identity) and the filter `docx/tex-*.lua` on `docx.xengine`, which writes the cover (the lead counsel in a frame at the foot of the page), the front matter, the contents, the index, the headings, the signature block and the certificates' signatures with the typst spacing, and leaves paragraphs, lists, quotations and footnotes to pandoc in those styles. The contents' page numbers come from fb render's needles (one per heading, in document order) on the LibreOffice PDF; three sections: the cover without a number, the front matter in lower roman from ii, the body in arabic from 1. The docx breaks every line and page where typst does: `eval.yaml` gates XENG-001..003 (`params.cross_engine: gate`). The former `build-reference.sh`, `render.sh` (two pandoc passes for the contents) and `reference.docx` are gone; the docx was Liberation Serif, justified and failed TNR-EMBEDDED and DEF-FONT-002. Word itself was not available; the checks run on the LibreOffice PDF.
