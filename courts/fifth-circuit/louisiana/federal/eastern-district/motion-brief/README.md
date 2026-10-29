# laed: motion-brief

Doc type: **motion-brief**, the memorandum supporting a motion, in the United States District Court for the Eastern District of Louisiana (`laed`). The sample is a Rule 12(b)(6) memorandum. The same template serves any memorandum supporting a motion (the page limit is the memorandum limit, LR 7.7).
Folder: `courts/fifth-circuit/louisiana/federal/eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole memorandum, 9 pages in the filing) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 8 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with the local rules overlaid in `typst/layout.yaml` (fb-595.17.6) |
| overlay | ok: `usage/OVERLAY-walker-motion-brief.pdf` and `OVERLAY-walker-motion-brief.txt` (page map; re-run 2026-10-14 against a copy of the exemplar fetched from the URL in `usage/SOURCE.md`, not committed) |
| page limit | LR 7.7 (25 pages) is enforced by the build: a 27-page test memorandum fails with the rule's message (checked 2026-10-14) |
| typeface | Rule names no face (LR 10.1 "standard font"). Times New Roman 12 pt (the pinned install, `docs/FONTS.md` rule 1; Liberation Serif fallback), the house standard (`docs/FONTS.md` rule 6) and the exemplar's face; see known gap 1. |
| pages reviewed | 8 of 8 on typst, latex and docx (every page of the three renders viewed at 40 dpi after the move onto the FRCP base, 2026-10-29; see "Engines"; older reviews below were made on earlier renders) |

## Governing rules

Primary sources, fetched 2026-10-14:

- E.D. La. Local Civil Rules, text from https://www.laed.uscourts.gov/sites/default/files/local_rules/2022%20CIVIL%20RULES%20LAED%20w%20Amendment%202%204%2025.pdf (linked from https://www.laed.uscourts.gov/attorney-information/rules-and-orders/local-rules). LR 7.1 to 7.8 and LR 10.1 read in full. The rule text carries amendment dates (for example LR 7.5, "Amended January 1, 2024").
- Federal Rules of Civil Procedure, from https://www.law.cornell.edu/rules/frcp/rule_5, `rule_7`, `rule_12`. Rule 7(b)(1) and Rule 12(b) read in part; Rule 5(b)(2)(E) read as an excerpt.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 7.4 | A contested motion is accompanied by a separate memorandum with a concise statement of reasons and citations of authority; memoranda may not be supplemented without leave. | Doc-type boundary. This template produces the memorandum only. It does not check the content. |
| LR 7.7 | A memorandum supporting or opposing a motion must not exceed 25 pages, excluding exhibits (a reply, 10 pages). | `memo-page-limit = 25`; a `context` block at the end of `laed-motion-brief()` calls `panic()` when the final page count is above the limit. The build fails, it does not warn. The count includes the caption, the certificate and the signature (the conservative reading). |
| LR 7.2 | The motion is noticed for submission at filing, with at least 15 days' actual notice; the motion and memorandum are served with the notice. | Separate filing (the notice of submission). Not produced. |
| LR 7.5 | Opposition due no later than eight days before the submission date; reply by 4:00 p.m., two working days before. | Context for the filer. Not produced. |
| LR 10.1 (form) | As for the complaint: 8-1/2 x 11, double spaced, standard font, page numbers from "2", margins of at least one inch, caption with Section and judge and magistrate judge. | `margin`, `footer-descent`, `body-leading`, the `footer`, `font-family`, `caption()`. |
| FRCP 7(b)(1) | A motion must be in writing, state with particularity the grounds, and state the relief sought. | The motion (Document 18-0 in the exemplar) is a separate filing. Not produced. |
| FRCP 5(b)(2)(E) | Service by filing with the court's electronic-filing system, to registered users. | `certificate()`: the certificate of service states service through the Court's Electronic Filing System. |
| FRCP 12(b)(6) | Failure to state a claim upon which relief can be granted, a defense that may be raised by motion. | Content, not template. |

## Layout

- Court title centered and bold; caption in a grid: party column with a right and a bottom rule (party names; "VERSUS" between the sides; designations under the names), case fields on the right as a label over its value (civil action number, section, judge, magistrate judge).
- Title centered and bold, in capitals.
- Body double spaced (24 pt pitch), first-line indent 0.5 in, not numbered (memoranda are not paragraph-numbered). Headings centered bold (level 1), bold (level 2), bold italic (level 3). Lettered sub-headings ("A.", "B.") are typed by the author.
- Block quotations (`>`), single spaced and indented.
- A `CERTIFICATE OF SERVICE` heading, the service sentence, the date, and the `/s/` line, when `service` is given. It sits after the signature block.
- Signature block on the right half of the page (`sig-indent`), "Respectfully submitted," then the counsel groups, single spaced.
- Page numbers from page 2 (LR 10.1).

## Markdown contract (for samples)

A sample is one `.md` file: a YAML frontmatter block, then the body. The same contract as the complaint, with three differences: `caption` uses "VERSUS" (not "v."), the body is never numbered, and `service` is available.

Frontmatter:

| Field | Type | Meaning |
|---|---|---|
| `civil_action_no`, `section`, `judge`, `magistrate` | string, optional | Caption fields. An empty value draws a blank. |
| `caption` | list of `{names, designation}` | Party sides, names printed one per line, designation under them. |
| `title` | string | The title of the memorandum (bold, centered, capitals). |
| `date` | string, optional | Printed as `Dated: ...` on the left of the signature block. |
| `signature` | list of `{names, lines}` | Counsel groups. The first group sits under "Respectfully submitted,"; put the `/s/` line first in `names`. `lines` are printed after the names (for example the role of the signer). |
| `service` | map, optional | `date` (the text after "This", for example `28th day of September, 2026`) and `signer`. Adds the certificate of service. |

Body:

- `# Heading` is level 1 (centered bold); `## Heading` level 2 (bold); `### Heading` level 3 (bold italic). Type the heading as the filing does, including any "A." label.
- A paragraph is not numbered; it is indented.
- A paragraph starting `A. ` or `(a) ` is a lettered item (hanging indent).
- A paragraph starting `> ` is a single-spaced block quotation.
- Case names and signals in italics: `*Ashcroft v. Iqbal*`, `*See e.g.*,`, `*Id.*`.
- No tables, footnotes, or raw typst. No forced line breaks.

## Overlay (`usage/OVERLAY-walker-motion-brief.pdf`)

Red is our render, blue is the filed memorandum, black is where they agree. Pages are paired by word overlap. The page map in `OVERLAY-walker-motion-brief.txt` (measured on the earlier EB Garamond render, before fb-595.68):

```
ours p.1  filed p.1   ours p.5  filed p.6
ours p.2  filed p.2   ours p.6  filed p.7
ours p.3  filed p.3   ours p.7  filed p.8
ours p.4  filed p.5   ours p.8  filed p.9
```

Our pages 4 to 8 pair with filed pages 5 to 9, so filed page 4 is not paired with any of our pages. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Font.** Same as the complaint: LR 10.1 requires a "standard font" and names no face. The template is set in Times New Roman 12 pt, the house standard (`docs/FONTS.md` rule 6) and the filed exemplar's face; until fb-595.68 it kept EB Garamond.
2. **Point size.** LR 10.1 sets none; 12 pt, as in the exemplar.
3. **One exemplar; no second filer found.** A second text-based E.D. La. Rule 12(b) memorandum with a downloadable PDF was not found in the RECAP search (`type=rd`, `court=laed`, filed from 2026-01-01, "memorandum in support of motion to dismiss"). The Lycee Francais memorandum (2:26-cv-00946, Doc. 5-1) was seen but is marked "FILED IN ERROR SEE DOC. 6" on the docket, so it was not used. Tier 2 is judged against one filer. Options: a second search for an E.D. La. memorandum, or accept the single filer.
4. **"VERSUS".** The filed memorandum joins the parties with "VERSUS"; the complaint exemplar uses "v.". Neither LR 10.1 nor FRCP 10(a) sets the word. Each doc type follows its exemplar; recorded as accepted.
5. **Certificate of service.** The wording (service "via the Court's Electronic Filing System") follows the filed memorandum and FRCP 5(b)(2)(E). The template prints it; a filer whose practice differs must edit the template, not the sample.
6. **Sample is the memorandum only.** The motion (Doc. 18-0), the notice of submission (Doc. 18-2) and any proposed order are separate filings and are not in the sample. The motion's page limit and the notice's timing (LR 7.2) are not checked here.
7. **Page limit counting.** The LR 7.7 guard counts every page of the rendered document (caption, body, certificate). Exhibits are not in the rendered document, so the count is the memorandum's count (conservative).
8. **Output and overlay names.** `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`; the brief named `<id>.pdf` and `<id>-overlay.pdf`. The tools were not edited.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`. This doc-type folder has neither, and `tools/` is shared. Render, overlay and the page-limit test ran.
10. **Headings are typed by the author.** The template does not number them.

## Review of the rendered pages (final state of the earlier EB Garamond render, before fb-595.68)

| Page | What was checked | Result |
|---|---|---|
| 1 | Court title; caption with the case fields as label-over-value (no mid-number wrap); title; opening paragraphs (intro, first paragraph indented). No page number. | Pass. |
| 2 | Paragraph 4 of the introduction, "Relevant Procedural History" (centered bold), "Legal Standard", "Argument" and the level-2 "A." heading (bold). | Pass. |
| 3 | Argument A continued: Julian and Smith citations (italic), the Windhauser parenthetical, Smithson with its quotation and italic signal. | Pass. |
| 4 | Argument B (bold level-2 heading) and the start of C; italic *Cicalese* citation. | Pass. |
| 5 | Argument C continued: the *Cicalese* and *Raj* quotations; the paragraph on Count Two and "Doc 17". | Pass. |
| 6 | Argument C ending; Argument D (bold) with *Stripling*, *Villarreal* and *North Cypress* citations. | Pass. |
| 7 | Argument D ending (*Brooks*, *D.L. Markham*); "Conclusion" (centered bold); "Respectfully submitted," with the counsel group single spaced, firm and email lines. | Pass. |
| 8 | CERTIFICATE OF SERVICE (centered bold), the service sentence, "This 28th day of September, 2026.", and the `/s/` line on the right. | Pass. |

## Gate 2 review on the FRCP base (2026-10-29, every page of the typst, latex and docx renders viewed)

- Page 1: court title, caption (no rules now, as the exemplar), title bold and centered half an inch in from each side, opening paragraphs. No page number (LR 10.1). Pass.
- Pages 2 to 7: body at the 24 pt pitch, centered and bold headings, italic case names; page numbers centered. Pass.
- Page 8: conclusion, "Respectfully submitted," and the counsel group at 3 inches, the certificate of service with its /s/ line. Pass.
- ACCEPTED (tier 3): the exemplar underlines its title; the template does not (LibreOffice splits an underlined "12(b)(6)", so the docx would break the line elsewhere than typst). ACCEPTED (tier 1 over the exemplar): the SECTION blank, LR 10.1 (`eval.yaml` `cover_structure_accepted`).
- Frontmatter now: `case_number`, `section`, `judge`, `magistrate`, `caption.parties`, `brief_title`, `signature: {date, blocks, counsel_for}`, `service` (the base's names; the Markdown contract above predates them).

## Engines

On the shared document model (docs/EVAL-LOOP.md, "Generated engines"; fb-595.17.6): `typst/layout.yaml` names the generic FRCP brief (`base: /lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and overlays what this court sets itself, each with its rule: the district's name; page numbers from page 2 (LR 10.1); the LR 10.1 caption (civil action number, Section, judge and magistrate judge, each a label over its value, a blank for a field the sample leaves out; the parties with "VERSUS" a line from each, no rules, as the exemplar); headings on the body pitch as typed; the signature block from 3 inches beside an optional date; the certificate of service when the sample gives `service`. `typst/laed-motion-brief.typ` names the face and hands the layout to `lib/typst/xdoc.typ`. `latex/` and `docx/` are generated from the merged layout by `fb engines gen` (do not edit them); the old per-folder template code and docx filter are removed. The page limit is `eval.yaml` `params.page_limit` (DEF-LEN-001, every engine).

| Engine | Status |
|---|---|
| typst | reference; `sh tools/check.sh <dir>` exits 0 |
| latex | generated; `--engine latex` exits 0, XENG-001..003 pass (every page and line breaks where typst breaks it) |
| docx | generated; `--engine docx` exits 0, XENG-001..003 pass; `.docx.pdf` by LibreOffice. BLOCKED: none |

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
