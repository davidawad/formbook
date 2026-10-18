# Petition for review

Typst template for a petition for review in the Supreme Court of Texas (`typst/main.typ`, module `typst/tex-petition-for-review.typ`). The sample is transcribed from the filed *State of Texas v. F.M.V.*, No. 25-0792 petition (`usage/SAMPLE-tex-petition-for-review-hawthorne250792.pdf`), with every section of the filed petition and the argument excerpted. Rendered output: `usage/OUTPUT-tex-petition-for-review-hawthorne.typst.pdf` (16 pages); overlay on the filed petition: `usage/OVERLAY-hawthorne-petition-for-review.pdf` and `.txt`.

## Layout

- Cover (page 1, no number): case number, court, caption, the "On Review" line, the title between rules, lead counsel (name, address, telephone, email, bar number) at the foot of the page (Rule 9.4(g)).
- Front matter (lower roman, from ii): each H1 section before `body_start` on its own page: the introduction (2026 text only, double-spaced), the identities of parties and counsel (single-spaced); then the generated table of contents (headings to level 3, bookmarked) and the index of authorities from the frontmatter `authorities` list.
- Body (arabic, from 1): the markdown from the heading named in `body_start`. The signature block (frontmatter `signature`: `name`, `office`, `lines`, `for`) is set by the template in the right half of the page after the section whose title contains "prayer"; each section whose title starts with "certificat" gets a short `/s/` signature (Rule 9.5(e)); the appendix index starts a new page.
- Liberation Serif 14 pt (headings too), double-spaced (32.2 pt pitch), every paragraph indented 0.5 in (including the first after a heading, as all three filers do), footnotes 12 pt single-spaced, block quotations single-spaced and indented 1 in each side. Footnote markers are raised digits (`super(typographic: false)`): Liberation Serif has superscript glyphs only for 1-3, so markers 4 and up came out a different size before this change.
- Word count: the counted H1 sections (front matter and body) under Rule 9.4(i)(1), 2026 text; the count, with a thousands separator, replaces `{{word-count}}` in the certificate of compliance. The render fails (`assert`) when the count is over the limit, when the 2026 introduction is over 1,000 words, or when a required section is missing or out of order.
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

- Not done: `rules.md`, `checks.yaml`, `reviews/`, `LOG.md`, the latex engine, the `tools/check.sh` gates, a second (structurally different) sample. The tracker and `court.json` are untouched.
- Index of authorities page numbers are typed in frontmatter and must be re-measured whenever the text moves (no `toa:` links as in the First Circuit reference).
- The Rule 53.2(l) appendix documents themselves (court of appeals opinion, judgment, statutes) are not produced; only the appendix index is.
- Rule 9.4(e)-(g) and 9.5 were not re-read against primary text this session (the TRAP PDF is 403).
- The sample's certificate of compliance wording drops the filer's "created in Microsoft Word ... relying on the word count of the software" sentence, since the count comes from the template.
- docx (`docx/tex.lua`) was not changed: it still uses the 4,500-word limit, splits the count at "Respectfully submitted", has no signature block from frontmatter `signature` and no `rules_edition`. No `soffice` on this box, so `usage/OUTPUT-tex-petition-for-review-hawthorne.docx` and `.docx.pdf` were NOT regenerated and are stale against the extended INPUT.

[Formbook index](../../../../../../README.md)

## Engines

**docx** (`docx/`: `render.sh` runs two pandoc passes, `tex.lua` is the filter, `reference.docx` comes from `build-reference.sh`). Checked on the LibreOffice PDF (`usage/OUTPUT-tex-petition-for-review-hawthorne.docx.pdf`). The `.docx` opened in LibreOffice without a repair prompt; Word was not available and not checked. `checks.yaml` and `rules.md` do not exist yet, so `tools/check.sh --engine docx` cannot run.

Matches the typst form: Liberation Serif 14 pt; exact 32.2 pt double and 16.2 pt single line pitch (same as typst); 1 in margins on letter; cover unnumbered and without a footer; front matter in lower roman from ii; body in arabic from 1; cover lead-counsel block at the bottom margin; the contents with dot leaders and page numbers from the layout (PAGEREF fields, filled from a first pass); the index of authorities from the frontmatter page numbers; word count on the markdown source with the typst rules (656 words here, limit 4,500). Page count: 10 in both.

Differs:
- Justified lines: typst shrinks word spaces when it justifies, Word and LibreOffice do not, so the docx fits fewer words on some lines. Body lines per page are 19 vs 20 (page 5), 19 vs 20 (page 6), 18 vs 20 (page 7) and 19 vs 21 (page 8) in the docx vs typst, so the docx runs about one page later from the statement of the case on.
- Space above headings: typst drops it at the top of a page. The docx puts it on the paragraph before each heading (style `BodyBeforeHeading`).
- Headings are 16 pt bold (H1 centered, H2 flush left), as the typst headings render.
- Table of authorities: page numbers are typed in the frontmatter as in typst; no TOA field.

BLOCKED: tier-1 pagination (body line counts per page): the docx wraps justified lines differently from typst on pages 5 to 8, so the contents labels for ISSUE PRESENTED (docx 3, typst 2), B. F.M.V.'s Detention and Magistration (docx 5, typst 4) and C. Trial and Disposition (docx 6, typst 5) are one page later than typst. Renderer difference in word spacing (see `docs/DOCX.md`, "Pagination differs by renderer"); the contents follow the docx layout. Total pages match (10).
