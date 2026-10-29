# okd (Western District of Oklahoma): motion with brief in support

Doc type: **motion-brief**, a Rule 12(b)(6) motion to dismiss with its brief in support, in the United States District Court for the Western District of Oklahoma (folder `district`, alias `okd`; see Known gaps 5).
Folder: `courts/tenth-circuit/oklahoma/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer: the City of Oklahoma City, by its Municipal Counselor's office; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole 9-page filing, transcribed; see below) |
| typeface | LCvR7.1(d) names no face (13-point minimum and margins only). Times New Roman 13 pt, the house standard (`docs/FONTS.md` rule 6) and the exemplar's face |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 9 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with W.D. Okla.'s local rules overlaid in `typst/layout.yaml` (fb-595.17.19) |
| overlay | `just overlay courts/tenth-circuit/oklahoma/federal/district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 9 of 9 on typst, latex and docx (every page of the three renders viewed side by side at 40 dpi after the move onto the FRCP base, 2026-10-29) |

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Where it is in the template | Source |
|---|---|---|---|
| Fed. R. Civ. P. 7(b)(1) | A motion must be in writing, state with particularity the grounds for the order, and state the relief sought. | The title and the opening paragraph of the sample state the relief and the grounds; the template does not check the wording. | https://www.law.cornell.edu/rules/frcp/rule_7 |
| Fed. R. Civ. P. 12(b) and 12(b)(6) | Failure to state a claim is a defense that may be asserted by motion; the motion must be made before pleading. | Content of the sample; timing is not a template matter. | https://www.law.cornell.edu/rules/frcp/rule_12 |
| W.D. Okla. LCvR7.1(b) | Each motion and brief is clearly titled to identify on whose behalf it is presented. | `brief_title`, set in centered bold capitals under the caption (`front` in `typst/layout.yaml`). | https://okwd.uscourts.gov/sites/okwd/files/LocalRules2026.pdf (local rules effective April 2026) |
| LCvR7.1(c) | Each motion is a separate document, except where the rules or a court order allow otherwise. | Not a template check; the sample is one motion. | same |
| LCvR7.1(d) | 13-point type or larger, footnotes included; margins at least one inch on the top, bottom and sides. | `typst/layout.yaml` `size: 13`, `footnote: {size: 13}`; the base's one-inch margins; `eval.yaml` `font.size_pt: 13` (DEF-FORM-003). | same |
| LCvR7.1(e) | Opening briefs not over 25 pages (30 for summary judgment), without leave; cover, table of contents, table of authorities, signature block, certificate of service and exhibits are not counted; a brief longer than 15 pages must have an indexed table of contents and table of authorities. | `eval.yaml` `params.page_limit: 15` (DEF-LEN-001, every engine): the template makes no tables, so it holds a brief to 15 pages (see gap 1). | same |
| LCvR7.1(k) | A motion and brief in support may be one document if so identified in the title. | `brief_title` names both ("... MOTION TO DISMISS AND BRIEF IN SUPPORT"); `typst/okd-motion-brief.typ` asserts the word "brief". | same |
| LCvR5.2(a) | 8 1/2 by 11 inch paper, double-spaced if typewritten, clearly legible. | The base's letter page; `typst/layout.yaml` `pitch: {body: 27.5}` (see below). | same |

Not produced by this template: the certificate of service text beyond the sample's own certificate, the table of contents and table of authorities (gap 1), a proposed order (LCvR5.5), and the response or reply periods (LCvR7.1(g), (h)).

## Layout

The generic FRCP brief with W.D. Okla.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there):

- Letter, one-inch margins, Times New Roman 13 pt (footnotes too); body double spaced at 27.5 pt, single lines 14.95 pt (1.15 x 13 pt); first-line indent half an inch. Page number centered at the foot.
- Court name in bold capitals, centered (`constants`); caption with a ")" column; `Case No.` at the right and `JURY TRIAL DEMANDED` under it when `jury_demand` is true; the title in bold capitals, centered and underlined, below the caption (no separate cover page; the filing has none).
- Headings: level 1 centered bold capitals (STATEMENT OF THE CASE, ARGUMENT AND AUTHORITY, CONCLUSION); level 2 bold at the margin; level 3 bold italic half an inch in. The section numbers and the statement paragraph numbers are typed in the sample, as in the filing.
- Quotations single-spaced, half an inch in on each side; lists as markdown lists.
- Signature (the base's closing): "Respectfully submitted," at the body pitch, then at the right the supervising counsel's lines (`firm`), a signature line and the signer's block; kept with the body's last paragraph.
- Certificate: on a new page; the title (`service.title`, a certificate of mailing here), the certificate text, the parties served half an inch in, then the signer's lines at the right.

### Measured line pitch

The filed exemplar's double-spaced baseline pitch is 27.5 pt (measured with `pdftotext -bbox` on the exemplar, the same pitch as the complaint folder's exemplar). The layout uses it (`pitch.body: 27.5`).

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields (the base's): `case_number`, `case_label` (optional, default `Case No.`), `caption.parties` (list of `{names, designation}`; `names` one string, a newline between lines; "v." is inserted between parties), `brief_title` (must contain "brief", LCvR7.1(k)), `signature` (`date_line`, `firm` (lines above the signature line), `blocks` (a list of line lists), `counsel_for` optional). W.D. Okla.'s: `jury_demand`, `service` (`title`, `text`, `served` (lines), `signed` (lines)).
- Body: blank-line-separated chunks. `# Heading` centered; `## Heading` bold; `### Heading` bold italic. Type the section numbers ("I.", "A.") in the heading text.
- Statement paragraphs are numbered by typing the number with the period escaped: `1\. City is ...`. An unescaped `1. ` would be a markdown list and render as one.
- Not supported: raw typst.

## Known gaps and open choices

1. **Table of contents and table of authorities are not produced.** LCvR7.1(e) requires both for a brief longer than 15 pages. DEF-LEN-001 (`params.page_limit: 15`) fails a render over 15 pages, rather than delivering such a brief without them. A brief of 15 pages or less needs neither.
2. **The 25-page limit is not checked separately.** It is above the 15-page limit the template holds.
3. **Typed numbers.** Section numbers and statement paragraph numbers are typed in the sample, not generated, as in the filing.
4. **One exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `okwd`, motions to dismiss filed 2026) found several other motions with stored PDFs (Benne, Loftis, Harris, Shugard); they were not saved. Tier 2 is therefore **not** judged against two filers yet.
5. **The "okd" folder.** CourtListener lists `okd` as not in use. The live Oklahoma federal courts are `okwd`, `oknd` and `oked`. The template follows the Western District's local rules and names the Western District (`constants.district`), and the exemplar is from the Western District. If the folder should be a different district, the rules and the exemplar change. This is a question for David.
6. **Certificate.** The sample uses a certificate of mailing (the exemplar's), since the filer served a pro se party by mail; `service.title` names it.
7. **Left-aligned body.** Body text is left-aligned; the exemplar is justified. Not asserted.
8. **Self-test.** There is no `check-selftest.sh` run: the doc-type folder has no `court.json`.

## Gate 2 review (2026-10-29, the three renders after the move onto the FRCP base, every page)

| Page | What is on it | Finding | Status |
|---|---|---|---|
| 1 | Court name, caption with ")" column, `Case No.` and `JURY TRIAL DEMANDED`, the title, the opening paragraph, STATEMENT OF THE CASE, paragraphs 1 to 3 | none | PASS |
| 2 | Paragraphs 4 to 8; ARGUMENT AND AUTHORITY; heading I and its first lines | none | PASS |
| 3 | Heading I (end); heading II; heading III and its sub-heading A | none | PASS |
| 4 | Sub-heading B; the Twombly and § 1983 paragraphs | none | PASS |
| 5 | Municipal liability paragraphs | none | PASS |
| 6 | The end of III.B | none | PASS |
| 7 | Sub-heading C; negligence and nuisance | none | PASS |
| 8 | The end of III.C; CONCLUSION; the signature (Respectfully submitted, the supervising counsel, the signature line, the signer's block) | none | PASS |
| 9 | CERTIFICATE OF MAILING on its own page; the served party; the signer | none | PASS |

## Engines

typst (`typst/okd-motion-brief.typ` names the face and asserts LCvR7.1(k); `typst/layout.yaml` the W.D. Okla. overlay); latex (`latex/template.tex`, `latex/xdoc.lua`) and docx (`docx/reference.xml`, `docx/xdoc.lua`) generated by `fb engines gen` from the merged layout. `params.cross_engine: gate` in `eval.yaml`.

- typst: `RESULT: 12 checks passed, 0 failed`.
- latex: `RESULT: 15 checks passed, 0 failed`; XENG-001..003 PASS (9 pages, 202/202 typst lines break after the same word).
- docx: `RESULT: 16 checks passed, 0 failed`; XENG-001..003 PASS (9 pages, 202/202).
- BLOCKED: none.
