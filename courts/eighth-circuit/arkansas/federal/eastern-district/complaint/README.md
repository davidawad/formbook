# E.D. Ark. (ared): complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Arkansas (`ared`). Folder: `courts/eighth-circuit/arkansas/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-hess-equifax-3-26-cv-00016-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-hess-equifax.md` (the whole complaint, 89 numbered paragraphs, prayer, signature; OCR typos corrected, see gap 9) |
| render | ok: `samples/OUTPUT-hess-equifax.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| typeface | face required: **none** (E.D. Ark. LR 5.5(a) sets a type-size minimum, "elite", and names no face) → **EB Garamond** kept (no substitute needed; visual-only for any Times expectation) |
| overlay | not regenerated on 2026-10-14: the filed exemplar PDF is absent from this snapshot (only `exemplars/SOURCE.md` is tracked), so `overlay.sh` exits 1. `samples/OVERLAY-hess-equifax.txt` is from the earlier run. |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed; pages 1 to 8 before the signature-block fix, page 9 after it) |

## Governing rules

Each rule was read from its primary text on 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 8(a) | Short and plain statement: grounds for jurisdiction, claim showing entitlement to relief, demand for relief. Fetched from https://www.law.cornell.edu/rules/frcp/rule_8. | Author content (the sample's paragraphs and prayer). The template does not check content. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and a Rule 7(a) designation; the complaint's title names all parties. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10. | `court-title`, `caption` (case number from `case_number`, parties from `caption.parties`). The Rule 7(a) designation is the title "Complaint". |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers every paragraph chunk; headings and lists are not numbered; `~ ` marks an unnumbered paragraph (the prayer lead-in). |
| Fed. R. Civ. P. 11(a) | Signed by at least one attorney of record; the paper states the signer's address, e-mail address and telephone number. | `signature-block` (`signature.firm`, `signature.signer`, `signature.lines`). The sample carries the e-mail and phone. |
| Fed. R. Civ. P. 38(b) | Jury demand served and filed no later than 14 days after the last pleading directed to the issue; may be included in a pleading. | Body paragraph (Hess ¶ 89 under "DEMAND FOR TRIAL BY JURY"). The caption line `DEMAND FOR JURY TRIAL` prints only if `jury_demand: true`. |
| Fed. R. Civ. P. 5.2(a) | Redaction of SSNs, taxpayer IDs, birth dates, names of minors, and financial-account numbers (filer's duty). | Not checked by the template. The sample has none of those items. |
| E.D. Ark. Local Rule 5.5(a) | Filed papers: type not less than elite, double space, letter size, one side of the page, unfolded, no manuscript covers. Fetched from the joint Local Rules PDF (are.uscourts.gov, All_LR.pdf, via the court's local-rules page, 2026-10-14). | `page-w`/`page-h` (letter), `pitch = 24pt` (double space), `type-size = 12pt`, one-sided pages. |
| E.D. Ark. Local Rule 5.5(c)(1) | Signed by at least one attorney of record, with the attorney's address, zip code, telephone number, and Arkansas Supreme Court identification number (or other Supreme Court identification number, if applicable). | `signature-block`. The number is not enforced: the template prints the lines the sample gives. See gap 3. |
| E.D. Ark. Local Rule 5.1 | Attorneys must file electronically, except case-initiating documents (complaints, petitions, notices of removal, indictments) and any document that adds a party. | Not a layout rule. Recorded so the filer knows the complaint may be filed on paper (see gap 7). |

Not produced by this template (separate filings, not part of the complaint): civil cover sheet (JS-44); summons; Rule 7.1 disclosure statement (Rule 7.1(a)(2) citizenship disclosure applies to diversity actions); any consent or class-certification motion. Verify whether the case needs them with the first filing.

## Layout

- Letter size, 1 inch margins on every side. A page number centered in the bottom margin; no other footer text (no rule requires one).
- No cover page and no counsel block at the top left (LR 5.5 and Rule 11 put counsel on the signature block; the exemplar has no top-left block).
- Court title (two lines, plus the division if the sample gives one), caption (party column closed by a rule at right and bottom; the case number and title at right), then the body on the same page.
- Body double-spaced (24 pt baseline pitch at 12 pt). Numbered paragraphs with a 0.5 inch first-line indent; the number is followed by a 0.3 inch space.
- Headings: level 1 centered bold capitals (JURISDICTION AND VENUE, PARTIES, FACTUAL ALLEGATIONS, Damages, FIRST CAUSE OF ACTION, DEMAND FOR TRIAL BY JURY, PRAYER FOR RELIEF); level 2 centered bold (the cause-of-action sub-heading). A heading never ends a page: it moves with the paragraph after it.
- Lists (the enumerated failures in ¶ 83, the prayer items) are lettered (a), (b), ... and may break across pages.
- Signature block: "Dated:" at left; "Respectfully submitted," and the firm at right; "By: /s/" name; lines (phone, e-mail, bar number, "Attorneys for Plaintiff").

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `caption.parties` (list of `{names, designation}`; the template puts "v." between parties); `brief_title`; `jury_demand` (true/false); `lead_in` (the unnumbered opening paragraph, optional); `date`; `signature` (`firm` lines, `signer`, `lines`); `division` (optional).
- Body: blank-line-separated chunks. `#` = level 1 heading; `##` = level 2; a `1.` list = lettered items; a paragraph = numbered; a paragraph starting `~ ` = unnumbered (the prayer's "WHEREFORE ... as follows:").
- Numbers are not typed by the author. A sample must not start a paragraph with a digit and period (that would make a list).
- Not supported: tables (none in the complaint exemplar), footnotes (none), raw typst.

## Exemplar

`exemplars/FILED-EXAMPLE-hess-equifax-3-26-cv-00016-complaint.pdf`: *Hess v. Equifax Information Services, LLC and Trans Union, LLC*, No. 3:26-cv-00016-DPM, "Class Action Complaint and Demand for Jury Trial", 11 pages, filed 2026-01-12 by Plaintiff's counsel Stein Saks, PLLC. Provenance, search trail and the rejected candidates are in `exemplars/SOURCE.md`.

The sample is the whole filing: 89 paragraphs as numbered in the exemplar, with the prayer items (a) to (h). The template's numbering reproduces the filed numbers (the first page of the overlay shows ¶ 1 to 7 at the same place; the signature page shows the prayer).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env in $HOME/tb)
D=courts/eighth-circuit/arkansas/federal/eastern-district/complaint
sh tools/render.sh $D samples/INPUT-hess-equifax.md $D/samples/OUTPUT-hess-equifax.pdf
sh tools/overlay.sh $D hess-equifax $D/exemplars/FILED-EXAMPLE-hess-equifax-3-26-cv-00016-complaint.pdf
```

The tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`. This doc type's file names follow the brief (`<id>.pdf`, `<id>-overlay.pdf`, `<id>-overlay.txt`), so the outputs were renamed after the overlay ran. `tools/` was not edited.

The overlay is a diagnostic, not a score. Its page map (`OVERLAY-hess-equifax.txt`) pairs pages by word overlap: ours 1 and 2 with filed 1 and 2 (79% and 78%); ours 3 with filed 3 (48%); ours 4 with filed 5; ours 8 with filed 10. The filed pages paginate differently (the exemplar runs 11 pages with the same text), so the page numbers do not line up one to one; the text layers do not coincide line by line either.

## Visual review (every page rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption, lead-in, ¶ 1 to 7, JURISDICTION AND VENUE heading | OK. Caption closed by rule; case number and title at right. |
| 2 | PARTIES, ¶ 8 to 19 | OK. Heading kept with its first paragraph. |
| 3 | FACTUAL ALLEGATIONS, ¶ 20 to 33 | OK. The heading moved to this page with ¶ 20 (page 2 has three blank lines at its foot). Acceptable. |
| 4 | ¶ 34 to 47 | OK. |
| 5 | ¶ 48 to 59, DAMAGES heading, ¶ 60 | OK. |
| 6 | ¶ 61 to 76, FIRST CAUSE OF ACTION and sub-heading | OK. Level 1 and level 2 headings centered; the sub-heading sits on the page with ¶ 76. |
| 7 | ¶ 77 to 83; the lettered list (a) to (d) | OK. The list is lettered and its items are hanging-indented. |
| 8 | List (e) to (h), ¶ 84 to 89, DEMAND FOR TRIAL BY JURY, PRAYER FOR RELIEF and its lead-in | OK. The prayer lead-in sits at the foot of the page; its list starts on page 9. The heading and lead-in are kept together. Acceptable. |
| 9 | Prayer items (a) to (h), "Dated", signature block | OK after the fix. The signer's name was printed twice (once under the signature, once in the "By: /s/" line); the template now prints it once. |

## Engines

**typst** (primary): the section above; `samples/OUTPUT-hess-equifax.pdf`, 9 pages, reviewed page by page.

**docx**: `docx/make-reference.sh` builds `docx/reference.docx` (EB Garamond 12 pt; 24 pt exact double spacing; 0.5 in first-line indent; headings on the same 24 pt grid, level 1 centered bold capitals, level 2 centered bold, level 3 bold italic; 1-inch margins; a centered page-number footer at 11 pt). `docx/complaint.lua` adds what pandoc does not: the court title, the caption table (rules at right and bottom of the party column), the case number and title, numbered paragraphs (1 to 89, a `~ ` paragraph is unnumbered), lettered lists "(a)", the lead-in, and the signature block. Built with `sh tools/render.sh --engine docx <this folder> samples/INPUT-hess-equifax.md`, which writes `samples/OUTPUT-hess-equifax.docx`.

| Item | Result |
|---|---|
| The `.docx` opens | Checked as a zip with well-formed XML parts and read back with pandoc (text in order, 89 numbered paragraphs, prayer (a) to (h), signature). Not opened in Word or LibreOffice. |
| Built to the typst values | Font face and size, double spacing, margins, caption rules, numbering, lettered list, signature block, page number: set in the reference and filter as above. Not compared with the typst pages. |
| Visual review (Gate 2) | Not done. No page of the docx has been rendered or looked at. |
| BLOCKED: `docx.pdf` checks | `soffice` could not be installed in the build box (conda-forge has no `libreoffice` package on 2026-10-15), so `samples/OUTPUT-hess-equifax.docx.pdf` was not produced. Gates 0 and 1 and the Gate 2 page review, which docs/DOCX.md measures on the LibreOffice PDF, cannot run. The docx is delivered without them. |
| Word substitution | The font is EB Garamond (vendored in `fonts/`). Word substitutes silently when the font is not installed on the machine that opens the file. |
| Caption and signature | Built as tables, so table-border rendering differs between Word and LibreOffice (docs/DOCX.md). Not judged. |

## Known gaps and open choices

1. **Only one exemplar.** The brief asks for one per doc type; EVAL-LOOP's tier-2 rule asks for two or three filers. Tier 2 is therefore **not** judged against two filers. The second E.D. Ark. complaint is the next pick (see `exemplars/SOURCE.md` for the candidates and the rejected state-court removal attachments).
2. **Font.** EB Garamond (vendored, OFL) at 12 pt, the only font vendored in `fonts/`. The exemplar is a scan with a Times-like text layer. Garamond sets smaller than Times at the same point size. The 12-point size is the working equivalent of the rule's "elite" minimum (LR 5.5(a)). Whether the court wants a Times-metric font is a question for David.
3. **Arkansas bar number (LR 5.5(c)(1)).** The rule requires the Arkansas Supreme Court identification number, "or other Supreme Court identification number, if applicable". The exemplar's counsel is an out-of-state lawyer and gives no bar number, so the sample carries none. The template does not assert the number: a sample for an Arkansas-admitted filer must add `Ark. Bar No. ...` to `signature.lines`. Recorded as an open question.
4. **"Elite" (LR 5.5(a)).** Elite is a fixed-pitch measure (12 characters per inch). The rule's text applies to typewritten papers; a proportional font at 12 pt is the working equivalent here, not measured. Recorded as an interpretation.
5. **Divisions.** The exemplar's caption has no division line. ED Ark has divisions (Central, Eastern, Jonesboro, and others), and the caption can carry one through the optional `division` frontmatter field. Not checked against the Local Rules' division list.
6. **Class action legend.** The exemplar is a class action (Rule 23). The template has no "Class Action" legend line; the title in the caption carries "CLASS ACTION" from the sample. No rule in the Local Rules text checked requires a separate legend.
7. **Filing mode (LR 5.1).** Complaints are case-initiating documents and may be filed on paper; the template does not choose a mode. The exemplar's stamps show an electronic filing, so the sample follows that.
8. **Paragraph numbers.** The rendered numbers run 1 to 89, the same sequence and end point as the filed document (the last numbered paragraph is 89, the jury demand). This was checked on the rendered page images at the paragraph level for pages 1, 3, 6 and 9; it is not a line-by-line comparison.
9. **OCR in the exemplar.** The text layer is an OCR of a scan. Corrections in the sample: "Plaintifrs" to "Plaintiff's"; "maccuracy" to "inaccuracy"; "139l" to "1391"; "168la" to "1681a"; the duplicated "Trans Union remove" to "removed"; "Plaintiffs" to "Plaintiff's". Unverified: the statute subsection at ¶ 10 and ¶ 15 reads "1681a(t)" in the text layer; the scan may read otherwise. Recorded so the sample is not treated as a verbatim copy.
10. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape; `tools/` was not edited. Render and overlay were run; the page review above is the Gate 2 equivalent for this doc type.
11. **Heading length.** Headings are centered and may wrap; they are rounded up to the line grid. A long heading wraps onto two double-spaced lines, which is a template defect if it happens. Not seen in this sample.
