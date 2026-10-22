# Petition for review

Typst template for a petition for review in the Supreme Court of Texas (`typst/main.typ`, module `typst/tex-petition-for-review.typ`). The sample is transcribed from the filed *State of Texas v. F.M.V.*, No. 25-0792 petition (`usage/FILED-EXAMPLE-petition-for-review.pdf`), with every section of the filed petition and the argument excerpted. Rendered output: `usage/OUTPUT-petition-for-review.typst.pdf` (17 pages; `usage/OUTPUT-petition-for-review.docx` and `.docx.pdf` the same pages); overlay on the filed petition: `usage/OVERLAY-hawthorne-petition-for-review.pdf` and `.txt`.

## Layout

- Cover (page 1, no number): case number, court, caption, the "On Review" line, the title between rules, lead counsel (name, address, telephone, email, bar number) at the foot of the page (Rule 9.4(g)).
- Front matter (lower roman, from ii): each H1 section before `body_start` on its own page: the introduction (2026 text only, double-spaced), the identities of parties and counsel (single-spaced); then the generated table of contents (headings to level 3, bookmarked) and the index of authorities from the frontmatter `authorities` list.
- Body (arabic, from 1): the markdown from the heading named in `body_start`. The signature block (frontmatter `signature`: `name`, `office`, `lines`, `for`) is set by the template in the right half of the page after the section whose title contains "prayer"; each section whose title starts with "certificat" gets a short `/s/` signature (Rule 9.5(e)); the appendix index starts a new page.
- Times New Roman 14 pt (Rule 9.4(e); headings too, bold), footnotes 12 pt; on the shared cross-engine layout model (`lib/typst/xengine.typ`; docs/EVAL-LOOP.md, "Cross-engine gate"): ragged right, first-fit line breaks, no kerning, ligatures or hyphenation, every line a box of its pitch. Pitches: 32.2 pt double-spaced text (Rule 9.4(d); Word's double line at 14 pt), 16.1 pt single lines (cover, headings, quotations, identities, contents, index, signature, footer), 13.8 pt footnote lines, 7 pt between notes. Headings sit on the text's double-spaced grid (12.9 pt above the line, 3.2 pt below) and stay with the text after them; level 1 centered, level 2 flush left, level 3 bold italic half an inch in. Every paragraph indented 0.5 in (also the first after a heading, as the filers do); block quotations single-spaced, 1 in in from each side, a single line around and between their paragraphs; lists with the number or bullet in a half-inch box; identities single-spaced, 8 pt apart.
- Contents rows and index rows: the text wraps before a page column (36 pt contents; 56 pt index, or the page list's own width and 7 pt), the dot leader runs from the end of the text to the page; contents levels step in half an inch, an authority's second line hangs half an inch. The prayer's last paragraph and the signature block are kept on one page.

- Word count: the counted H1 sections (front matter and body) under Rule 9.4(i)(1), 2026 text; the count, with a thousands separator, replaces the count typed in the markdown (literal) in the certificate of compliance. The render fails (`assert`) when the count is over the limit, when the 2026 introduction is over 1,000 words, or when a required section is missing or out of order.
- `rules_edition` (frontmatter): `"2026"` (default) or `"2025"`. The sample uses `"2025"` because the filed petition (Oct. 10, 2025) predates the amendments; the 2026 path (introduction first, 6,500 words) was rendered from a temporary copy of the sample with an `# INTRODUCTION` section before the identities and checked (introduction on page ii, listed in the contents). Removing the introduction under 2026 fails the render, as intended.

## Governing rules

Primary source read this session (October 16, 2026): the text of the amendments in Misc. Docket No. 25-9104 (Tex. Dec. 23, 2025; effective for petitions filed on or after January 1, 2026), reproduced as the appendix of D. Todd Smith, *The Appellate Advocate* vol. 35 no. 2 (Spring 2026), <https://www.texappcounsel.com/wp-content/uploads/sites/958/2026/06/Smith-SCOTX-PFR-Article-in-Appellate-Adv-V35-No2-.pdf>. The Court's own copies (<https://www.txcourts.gov/media/1461814/259104.pdf>, the TRAP PDF) still return HTTP 403 to this box, so the redline was read through that reprint; read it against the Court's PDF before relying on it.

- Rule 9.4(c)-(e): letter paper; one-inch margins; double-spaced text (footnotes, block quotations, short lists and issues may be single-spaced); conventional typeface at least 14 point; footnotes at least 12 point. Not re-read this session (unchanged by 25-9104).
- Rule 9.4(g): cover contents (case style and number, title, party, lead counsel's name, mailing address, telephone, email, State Bar number). Not re-read this session.
- Rule 9.4(i)(1) (2026): excluded from the count: caption, identity of parties and counsel, statement regarding oral argument, table of contents, index of authorities, statement of the case, statement of issues presented, statement of jurisdiction, statement of procedural history, signature, proof of service, certification, certificate of compliance, appendix. Read.
- Rule 9.4(i)(2)(D) (2026): petition for review 6,500 words, inclusive of the introduction (former limit 4,500). Rule 9.4(i)(3): certificate stating the number of words. Read.
- Rule 53.2 (2026), in order: (a) introduction (at most 1,000 words, counted), (b) identity of parties and counsel, (c) table of contents (bookmarked), (d) index of authorities, (e) statement of the case, (f) statement of jurisdiction, (g) issues presented (with record cites for preservation), (h) statement of facts, (i) summary of the argument, (j) argument, (k) prayer, (l) appendix (bookmarked). Read. The redline shows a struck "(g) Introduction ... summarizing the reasons" line; read as deleted.
- Rule 9.5: certificate of service, signed. Not re-read this session.

## Exemplars

Three filed petitions from three filers, listed with URLs in `usage/SOURCE.md`: the State petition (25-0792, Oct. 2025, former rules), Tanner (25-0648, Aug. 2025, former rules), and San Patricio County Appraisal District (26-0153, Feb. 2026, the only one under the 2026 rules: introduction on pages ii-iv before "Parties and Counsel"). Tier-2 cross-check this pass: the SPCAD petition's front matter (introduction placement, counsel list, contents) and the signature and certificate layout of all three filers (signature block in the right half after the prayer; `/s/` and name under each certificate), which the template now follows.

## Depth pass (fb-595.38.2, October 16, 2026)

Sample extended from the statement of facts (10 pages) to the full structure: introduction and summary of the argument (with footnotes 1-8), argument (A with the timeline entry, a bulleted list and a block-quoted Q&A; B; B.1 at level 3), conclusion and prayer, generated signature block, certificate of service, certificate of compliance, appendix index. 16 rendered pages (cover, ii-iv, body 1-12); all 16 rendered at 60 dpi and looked at.

Overlay page map (ours -> filed, word overlap): 1->1 (67%), 2->4 identities (97%), 3->2 contents (69%), 4->3 index (32%, ours is the measured short index), 5-11 -> 5-11 (60-86%), 12->13, 13->16, 14->23, 15->24 signature and certificates (75%), 16->25 appendix (82%). Tier-3 differences (filed pages run at a different measure; filed places the contents before the identities, which the rule orders the other way): not chased.

Template fixes from the deeper sample: cover listed the lead counsel's name after the address (now first); first paragraph after a heading was not indented; footnote markers 4 and up were a smaller glyph; no signature block or certificate signatures existed (only typed in markdown); the contents stopped at level 2 (Rule 53.2(c) wants each point); the contents had no bookmark; the word limit was the former 4,500 under the 2026 exclusions; no check of the required sections and their order; the count missed "statement of procedural history" and "certification" exclusions; the count had no thousands separator.

Index of authorities page numbers re-measured from this render with `pdftotext` per page.

## Known gaps

- Not done: `rules.md`, `checks.yaml`, `reviews/`, `LOG.md`, the latex engine, a second (structurally different) sample. The tracker and `court.json` are untouched.
- Index of authorities page numbers are typed in frontmatter (re-measured with `pdftotext` per page on the fb-595.68.36 render) and must be re-measured whenever the text moves (no `toa:` links as in the First Circuit reference).
- The Rule 53.2(l) appendix documents themselves (court of appeals opinion, judgment, statutes) are not produced; only the appendix index is.
- Rule 9.4(e)-(g) and 9.5 were not re-read against primary text this session (the TRAP PDF is 403).
- The sample's certificate of compliance wording drops the filer's "created in Microsoft Word ... relying on the word count of the software" sentence, since the count comes from the template.

[Formbook index](../../../../../../README.md)

## Engines

**typst** (`typst/`): the reference. **docx** (`docx/`, fb-595.68.36): `reference.xml` (base="xengine": the cross-engine recipe in the typst face, `{font}`, with the pitches in twips: 644 body, 322 single, 276 footnotes; Heading 1-3, Block Text, Body Text Note, Body Keep, Identity) and the filter `docx/tex-*.lua` on `docx.xengine`, which writes the cover (the lead counsel in a frame at the foot of the page), the front matter, the contents, the index, the headings, the signature block and the certificates' signatures with the typst spacing, and leaves paragraphs, lists, quotations and footnotes to pandoc in those styles. The contents' page numbers come from fb render's needles (one per heading, in document order) on the LibreOffice PDF; three sections: the cover without a number, the front matter in lower roman from ii, the body in arabic from 1. The docx breaks every line and page where typst does: `eval.yaml` gates XENG-001..003 (`params.cross_engine: gate`). The former `build-reference.sh`, `render.sh` (two pandoc passes for the contents) and `reference.docx` are gone; the docx was Liberation Serif, justified and failed TNR-EMBEDDED and DEF-FONT-002. Word itself was not available; the checks run on the LibreOffice PDF.
