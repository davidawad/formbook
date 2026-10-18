# mssb: motion with memorandum (memorandum brief in support)

Doc type: **motion-brief**: the memorandum brief that supports a motion, in the United States Bankruptcy Court for the Southern District of Mississippi (`mssb`). Folder: `courts/fifth-circuit/mississippi/federal/bankruptcy-southern-district/motion-brief/`. One self-contained doc-type folder: no shared files.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `usage/FILED-EXAMPLE-motion-brief.pdf` (Dkt 48, "Memorandum in Support of Motion for Summary Judgment", 15 pp., defendant's counsel). The motion itself is not in the exemplar, and the memorandum states no docket reference. See `usage/SOURCE.md` and Known gaps. |
| sample md | `usage/INPUT-motion-brief.md`: the whole memorandum, transcribed, with the signature block and the certificate of service |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-lentz-motion-brief.pdf` and `.txt` (`sh tools/overlay.sh`) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed, final template) |
| tier 1 | rules-driven template; asserts that stop the build if the title, the docket reference (`related_docket`), the caption case data, or counsel's e-mail, Bar number, telephone or street address is missing (checked: a sample with no docket reference fails with the rule cited). |

`court.json` and the court-root `typst/`, `usage/` are untouched. `tools/check.sh` and `tools/check-selftest.sh` were not run, for the same reason as the complaint folder (they expect `court.json` and `rules.md`).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `mssb-motion-brief`. |
| `typst/mssb-motion-brief.typ` | Template. Parameters at the top, each with its rule. Rule asserts in `check-meta`. |
| `usage/INPUT-motion-brief.md` | Markdown contract sample (frontmatter + body). |
| `usage/OUTPUT-motion-brief.typst.pdf` | `sh tools/render.sh courts/fifth-circuit/mississippi/federal/bankruptcy-southern-district/motion-brief usage/INPUT-motion-brief.md` |
| `usage/OVERLAY-lentz-motion-brief.pdf`, `.txt` | `sh tools/overlay.sh <this folder> lentz-motion-brief` (red = ours, blue = filed, black = agree) |
| `usage/` | The filed exemplar and `SOURCE.md`. |

File names follow the file-role convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`), which is what `tools/render.sh` and `tools/overlay.sh` read and write by default.

## Governing rules

Primary source for the local rules: Joint Uniform Local Bankruptcy Rules, Northern and Southern Districts of Mississippi, as amended December 1, 2022, <https://www.mssb.uscourts.gov/sites/mssb/files/mssb_local_rules_20221201.pdf>. Text extracted and read in this box on 2026-10-14 (page numbers are the rulebook's printed pages). **Caveat:** a proposed redline of the joint rules, "Eff. 3-1-2026", is posted at <https://www.msnb.uscourts.gov/sites/msnb/files/Proposed%20Uniform%20Local%20Rules%20%28Redline%20Version%29%20Eff.%203-1-2026.pdf>. Its adoption is not confirmed here. Check the operative rules before relying on this table.

Federal rules: Fed. R. Bankr. P. 9004 read in full on 2026-10-14 from Cornell LII (<https://www.law.cornell.edu/rules/frbp/rule_9004>; a secondary copy). Fed. R. Bankr. P. 9013 was **not** fetched in this box; the template relies on the local rule that implements it (Miss. Bankr. L.R. 9013-1), so check the official text before relying on the federal citation. Rule 7056-1 governs the memorandum when the motion is for summary judgment.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Miss. Bankr. L.R. 9013-1(a) (p. 54) | Each motion specifies the rules and statutory provisions it relies on. | The memorandum states the grounds in the text (author text, not checked by the template). The rules cited by the filing are in the body. |
| Miss. Bankr. L.R. 9013-1(b) (pp. 54–55) | Service of the motion and response: the persons listed in (b)(2) are served. | Certificate of service at the end of the body (author text); the template does not check the service list. |
| Miss. Bankr. L.R. 9004-1(b) (p. 50) | A paper that relates to a previously filed document identifies it by its docket number, in the form "(Dkt. # ______)". | `related_docket` frontmatter, printed under the title as "(Dkt. # …)"; `check-meta` asserts it is present. |
| Miss. Bankr. L.R. 5005-1(a)(2)(D)(i) (p. 36) | Every motion has a proposed order attached. | Not in this template: the proposed order is a separate attachment (see Known gaps). |
| Miss. Bankr. L.R. 5005-1(a)(2)(G) (p. 37) | Papers 8½ × 11 in.; legible in a font no smaller than 12 point; double-spaced, except that quotations, footnotes and legal descriptions may be single-spaced. | `page`, `type-size = 12pt` (headings, footnotes and the footer too), `body-leading` (24 pt pitch), single-spaced block quotations and footnotes. |
| Miss. Bankr. L.R. 5005-1(a)(2)(H)(i) (p. 37) | Every paper: counsel's name, complete address, telephone, e-mail and Bar number. | Signature block; `check-meta` asserts each item. |
| Miss. Bankr. L.R. 5005-1(a)(2)(I) (p. 38) | Clear designation of content; a paper with several contents puts them all in the caption. | `title` frontmatter, printed in bold capitals under the caption; `check-meta` asserts it. |
| Fed. R. Bankr. P. 9004(b) | Caption: court name; case title; case and adversary numbers; brief designation. | `cover`, `caption`. |
| Miss. Bankr. L.R. 7056-1(3)(A)–(C) (p. 48) | A motion for summary judgment is accompanied by a memorandum brief; response within 21 days; reply within 14 days. | Applies to this memorandum when the motion is for summary judgment. The memorandum's form is the template's. The timing is not in the template. |
| Miss. Bankr. L.R. 7056-1(1)–(2) (pp. 47–48) | A summary-judgment motion lists the material facts with cited evidence (and the response answers them). | Not in this template: the statement of material facts is a separate filing (see Known gaps). |
| Miss. Bankr. L.R. 9011-1(a)(2) | Signature: the attorney's name under the login is shown as "/s/" and the typed name. | `signature-block` prints `/s/ <signer>`. |

## Layout

- Court name centred (bold) on two or three lines (a division line if the frontmatter gives one).
- Caption: debtor block with case number and chapter on the right; the plaintiff with PLAINTIFF on the right; "V." with "ADV. PROC. NO." on the right; the defendant with DEFENDANT on the right.
- Title in bold capitals, centred; "(Dkt. # …)" under it.
- Body: double-spaced; 0.5 in. first-line indent; no paragraph numbers. Level-1 headings centred bold capitals (`#`: I., II., ...); level-2 bold at the left (`##`: A., B., ...); level-3 bold italic (`###`). Block quotations (`>`) are single-spaced and indented 0.75 in. on the left and 0.5 in. on the right; each `>` paragraph is a separate block.
- Footnotes single-spaced at the foot of the page.
- The signature block (date line, "Respectfully submitted," the party, "/s/", counsel details, in the right half of the page) closes the text. It is kept on the same page as the last paragraph, so a signature never stands alone on a page.
- The certificate of service starts a new page, as in the filing.
- Every double-spaced block is rounded up to whole 24 pt rows (`on-grid`), so the next block starts on the grid. A quotation and an address block are not rounded (their measure differs from their width), and each gets a space below.

## Engines

Three engines run from one markdown contract. `typst/` is the primary template and the reference for this form. `docx/` was added here. No `latex/` yet.

| Engine | Output in `usage/` | Result |
|---|---|---|
| typst | `OUTPUT-motion-brief.typst.pdf` | unchanged |
| docx | `OUTPUT-motion-brief.docx` | written and checked for package integrity; `.docx.pdf` BLOCKED (below) |

Build: `sh docx/make-reference.sh` once (writes `docx/reference.docx`), then `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`. The filter is `docx/mssb-motion-brief.lua`. The render script's LibreOffice step fails on the box used here; the `.docx` is written before that step.

What the docx build sets to the typst form (from the same frontmatter). These are settings in the XML and the filter, not a rendered comparison: no page has been rendered (see below).

- US Letter, 1 in margins. EB Garamond 12 pt for the body, caption, quotations, footnotes and footer (5005-1(a)(2)(G)).
- Double spacing as exact 24 pt lines, the same pitch as the typst template. Single spacing for caption, quotations, address blocks, counsel and signature lines, and footnotes (5005-1(a)(2)(G) allows this).
- Cover: court name, division, caption table with a 3.6 in party column, title in bold capitals, and the docket line `(Dkt. # ...)`.
- Body paragraphs are unnumbered, with a 0.5 in first-line indent. Level-1 headings are centred capitals (I., II., ...), level-2 bold at the left (A., B., ...), level-3 bold italic.
- Block quotations are single spaced, indented 0.75 in on the left and 0.5 in on the right.
- The signature block (party, "/s/", signer, counsel) sits in the right half (3.25 in indent) after the text. The certificate of service starts a new page after it.
- Footer: centred page number, 12 pt.

What differs, by design or by Word:

- Labels inside a block quotation ("1.", "b.", "V.", "(1)") are typed text with a tab, as the filed text prints them, not Word list numbering. They carry no hanging indent, so a wrapped line returns to the quotation's left edge.
- Headings are styled paragraphs (`MSSB Heading ...`), not Heading 1-3, so there is no navigation pane or outline.
- No on-grid rounding. Typst rounds each block up to whole 24 pt rows; Word keeps each paragraph's own height.
- Keep-together: headings and the signature block keep with the next paragraph. The last body paragraph is not held with the signature, as typst holds it.
- The sample has no pipe tables. A table in another memorandum would fall back to pandoc's table style, which is not the typst layout, and is not checked.
- Pagination differs between Word and LibreOffice; page counts are not measured for the docx.

docx BLOCKED (not verified by a render):

- `docx.pdf` (Gates 0 to 3 on the LibreOffice PDF, `tools/check.sh --engine docx`): BLOCKED. LibreOffice cannot start on the box used here. The Debian LibreOffice 25.2 packages (extracted without root, all shared libraries resolved) exit at bootstrap with a `DeploymentException`. No `.docx.pdf` exists, so no page was rendered or viewed (pages reviewed: 0), and `usage/.check-docx.txt` is not written. `tools/check.sh` also needs `yq` and a court folder with `court.json` and `rules.md`, which a doc-type folder does not have.
- The `.docx` has not been opened in Word or LibreOffice. Its package parts are well-formed XML and the zip is valid, which is necessary, not sufficient.

## Overlay

`usage/OVERLAY-lentz-motion-brief.pdf` puts our render (red) over the best-matching page of the filed memorandum (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the final run:

- p.1 ↔ p.1 (58%): caption, title, the start of the introduction and of Part II.
- p.2 ↔ p.3 (80%): the DNA and DAA quotations. The filed quotations sit on different pages.
- p.3 ↔ p.4 (61%), p.4 ↔ p.6 (61%): the account history and the procedural history.
- p.5 ↔ p.8 (51%): the standard of review and the elements. The filed page 8 carries the fraudulent-transfer elements; the pairing is the closest match.
- p.6 ↔ p.9 (63%), p.7 ↔ p.11 (69%), p.8 ↔ p.12 (60%): Argument A (fraudulent transfer) and B (turnover).
- p.9 ↔ p.14 (38%): the conclusion and signature. The filed signature is on page 14, so the pairing is by content, and the score is low.
- p.10 ↔ p.15 (89%): the certificate of service.

## Page review (Gate 2)

Every page of `OUTPUT-motion-brief.typst.pdf` was rendered at 60 dpi and viewed in its final form.

| Page | Content | Result |
|---|---|---|
| 1 | Court name, caption, title and docket reference; I. INTRODUCTION; II. (first paragraph) | OK. Headings are bold and centred at 12 pt (an earlier build set them at the heading scale; fixed). |
| 2 | II. (DNA paragraph); DNA quotation with the ellipses; DAA start | OK. |
| 3 | DAA quotation (continued); fee paragraph; CRA paragraph; placeholder for the table; disbursement paragraph | OK. The placeholder stands in for the filed bank-statement image (see Known gaps). |
| 4 | Procedural history; III. heading (with its first paragraph) | OK. |
| 5 | Standard of review; quotations; elements in (1)–(4) and (1)–(5) | OK. The element lists are indented quotations; no overlap with the citations after them (an earlier build overlapped; fixed). |
| 6 | IV. ARGUMENT; A. Fraudulent Transfer Claims; the § 548 quotation | OK. |
| 7 | Argument A (continued); B. Turnover Claims; footnote 1 marker | OK. |
| 8 | Argument B (continued); footnote 1 | OK. The lower part of the page is blank: the conclusion moves to page 9 with its signature (keep-with-next). ACCEPTED. |
| 9 | V. CONCLUSION; date; signature block | OK. |
| 10 | Certificate of service (new page); the two address blocks; "/s/" and "OF COUNSEL" | OK. |

Tier-2 findings (OPEN or ACCEPTED):

- Body typeface: EB Garamond, the only serif vendored in `fonts/`. The filing's face is not confirmed here: `pdffonts` reports the exemplar's text as Liberation Sans-named subsets, but the page image reads as a Times-style serif. At 12 pt, EB Garamond has a smaller x-height than Times, so the text looks smaller, and the filed memorandum runs 15 pages to our 10. The rule's 12 point minimum is met. ACCEPTED pending David's decision on the size (see Known gaps).
- Page 8 white space above the conclusion: ACCEPTED (see the page review).
- Heading and footnote styling were checked against the rule and the filing's text layer only, not against the filed page images, beyond the one page (p. 5) viewed. Not a tier-2 finding; recorded so the gap is visible.

## Known gaps

1. **The motion is not in the exemplar.** The exemplar is the memorandum (Dkt 48). The template produces the memorandum; the motion itself (a separate document with its own caption) is not built here.
2. **Docket reference.** The filed memorandum states no docket number for the motion it supports (Miss. Bankr. L.R. 9004-1(b)). The sample's `related_docket` is a visible bracketed placeholder ("[not stated in the filed exemplar]"), not an invented number. A real filing needs the motion's docket number.
3. **Proposed order.** Miss. Bankr. L.R. 5005-1(a)(2)(D)(i) requires a proposed order with every motion. It is a separate document and not produced here.
4. **Statement of material facts.** For a summary-judgment motion, Miss. Bankr. L.R. 7056-1(1)–(2) requires a statement of the material facts with cited evidence. The filed memorandum refers to exhibits and docket entries in the text; the statement itself is a separate filing and not produced here.
5. **Bank-statement table (exemplar p. 5).** The table in the Lentz memorandum is an image (a screenshot of six "Customer Fee" entries) with no text layer. The sample shows a bracketed description of it, not its contents. The total ($73.55) is in the text and is transcribed.
6. **Word-level check.** Every word of the sample appears in the filing's text layer, except the placeholders, the frontmatter keys, and the template's fixed words. The filing's ECF header and footer (Dkt number, "Filed", "Entered", "Page", the filer's document number on each page) are not transcribed.
7. **Margins.** The uniform rules set none; the template uses one inch on each side. The filing's margins are not measured.
8. **Length.** The sample renders at 10 pages against the filing's 15 (see the typeface finding).
9. **Single exemplar, one filer.** The RECAP searches run in this box found no second filer's memorandum in support of a motion with a text layer in storage. Lentz Dkt 40 (a memorandum on a motion to reconsider) is the same filer (NDR). The On-Site Fuel memorandum (Dkt 10) is not in storage. The Park Energy / First Service Bank motion to dismiss (26-06008-JAW, Dkt 13) is a motion, and its memorandum is a separate entry not in storage. Tier 2 is judged against the one filing. A search beyond these is not done.
10. **Federal rule not checked.** Fed. R. Bankr. P. 9013 was not fetched in this box (see Governing rules).
