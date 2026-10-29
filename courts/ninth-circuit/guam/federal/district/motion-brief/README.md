# gud (District Court of Guam): motion-brief

Doc type: **motion-brief**, a Rule 12 motion with its memorandum, in the United States District Court of Guam (`gud`). The exemplar is a memorandum in support of a Rule 12(b)(6) and 12(f) motion to dismiss or strike a counterclaim.
Folder: `courts/ninth-circuit/guam/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (full transcription of the 12-page memorandum, Doc. 13-1; footnotes 1 and 2 not transcribed, see gaps) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages, with `.latex.pdf` and `.docx`/`.docx.pdf` generated from the same layout (fb-595.17.12); vendored Times New Roman only, no warnings |
| overlay | `just overlay` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| typeface | face required: none (GNLR 5.1(a), 2022: no typeface or point size; the memorandum's exemplar is Times New Roman, a convention only). Font: **Times New Roman** 12 pt (vendored), the exemplar's face, in typst and docx alike (fb-595.68.22; was EB Garamond). |
| pages reviewed | 11 of 11 on every engine (2026-10-29, the FRCP-base render; see "Review of the rendered pages") |

Tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the names in `tools/`); the brief's `<id>.pdf` and `<id>-overlay.pdf` names are not what the tools write, so the tool names are used.

## Governing rules

Primary source: **General Local Rules of Practice for the District Court of Guam, effective April 19, 2022 ("GNLR")**, https://www.gud.uscourts.gov/sites/gud/files/General%20Local%20Rules%2020220419%20final_0.pdf, fetched and read 2026-10-14. This is the newest version found; it is not confirmed as current.

Federal rules, text from the Legal Information Institute mirror, fetched 2026-10-14: FRCP 5 https://www.law.cornell.edu/rules/frcp/rule_5, FRCP 7 https://www.law.cornell.edu/rules/frcp/rule_7, FRCP 10 https://www.law.cornell.edu/rules/frcp/rule_10, FRCP 12 https://www.law.cornell.edu/rules/frcp/rule_12.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| GNLR 5.1(a) | White paper, 8 1/2 x 11 in.; all papers double-spaced except counsel identification, title of the case, footnotes, quotations and exhibits; all pages numbered consecutively at the bottom. | the base (`lib/layouts/frcp-motion-brief.yaml`): letter paper, the body at 24 pt (double), the page number centred at the bottom; counsel, caption, quotations and the signature single-spaced (13.8 pt). |
| GNLR 5.1(b) | Court title centred, commencing not less than three inches from the top of the page. | `front` in `typst/layout.yaml`: beside the counsel column an empty column 130.2 pt high (3 in. less the margin and the single line above the title), so the title starts at 3 in.; a longer counsel block pushes it down, never up. |
| GNLR 5.1(c)(1) | Counsel name, address and telephone at the upper left; space right of centre reserved for the clerk's filing stamp. | the counsel column, 3.25 in. wide (the page centre is 4.25 in. from the left edge). |
| GNLR 5.1(c)(2) | Title of the action below and to the left of the court title. | the parties column of the caption, "v." between the parties. |
| GNLR 5.1(c)(3) | Right of the title of the action: file number, civil designation, brief description, and a mention of any notice of motion or memorandum in support. | the right column: `case_number`, `designation` ("CIVIL"), `case_notes`, `brief_title` ("MEMORANDUM IN SUPPORT OF MOTION ..."), `brief_subtitle` (the Rule 12 grounds). |
| GNLR 5.1(c)(4) | Cover sheets accompany documents initiating civil actions. | Not applicable: a motion-brief is not an initiating document. |
| GNLR 5.1(d) | The name typed below the signature. | `closing`: "/s/" and the signer, the typed name below. |
| FRCP 7(b)(1) | A motion must be in writing, state with particularity the grounds, and state the relief sought. | Content (the author's), not checked by the template. The memorandum's "Introduction" states the three grounds and the relief. |
| FRCP 10(a) | Caption: court name, title, file number, Rule 7(a) designation. | `constants.court` and the caption in `front`. |
| FRCP 12(b)(6), 12(f) | Defences of failure to state a claim, and motions to strike redundant or immaterial matter. | Named in `brief_subtitle`. |
| FRCP 5(d)(1)(B) | No certificate of service is required for a paper served through the court's e-filing system. | The sample's CERTIFICATE OF SERVICE section (the exemplar has one) is the `tail`, on a page of its own; those served (`service.served`) and the signature follow it (`after_tail`). |

GNLR 2022 contains no page limit, no memorandum-length rule, no typeface or point-size rule, and no motion-format rule beyond GNLR 5.1 (GNLR 10.1 sets the motion day only). None of those is asserted here. Local practice may add them; the current rules should be checked before the template is called final.

## Layout

Set by `typst/layout.yaml` (the generic FRCP brief, `lib/layouts/frcp-motion-brief.yaml`, with this court's overlay; each value cites its rule):

- Counsel single-spaced in a 3.25 in. column at the upper left; the court title bold and centred, at 3 in. or a single line below a longer counsel block (the exemplar's counsel block puts it at 3.19 in.).
- Caption a double line below: the parties in a 3.25 in. column ruled at its right and foot (as the exemplar), each party's names, its designation an inch in, "v." half an inch in a line from each; at the right the file number, "CIVIL", the removal notice (`case_notes`), a double line below the bold title and a line below it the Rule 12 grounds.
- Body double-spaced (24 pt), first lines indented half an inch, unnumbered paragraphs; quotations single-spaced, half an inch in on each side.
- Headings bold on the body pitch with a double line above: level 1 centred capitals (`I. INTRODUCTION`, `II. ARGUMENT`, `III. CONCLUSION`), level 2 at the margin (`A.`, `B.`, `C.`); a heading is kept with the paragraph after it.
- Signature: "Respectfully submitted this ... ." then, 3 in. in, the firm, "/s/" and the signer, the signer's lines; kept whole and with the last paragraph.
- Certificate of service (a body section whose heading starts "CERTIFICATE"): a new page, its text double-spaced, each person served single-spaced a line apart, the signature again.
- Pages numbered at the bottom centre from page 1.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `designation`, `case_notes` (list, optional), `caption.parties` (`{names: [...], designation}`), `brief_title`, `brief_subtitle` (optional), `counsel` (list of single-spaced lines), `date`, `signature` (`firm`, `signer`, `lines`), `service.served` (optional: one multi-line address per person served; with `service`, the signature is repeated after the certificate).
- Body: markdown set by the shared document model: `# I. HEADING` (level 1), `## A. Heading` (level 2), paragraphs, lists, block quotations, footnotes (`[^1]`), `*italics*`; a level-1 section whose heading starts "CERTIFICATE" is the certificate (set after the signature, on its own page).
- The markers of the old template (`<!-- signature -->`, `<!-- single -->`) are gone (fb-595.17.12): the signature follows the body and the certificate; the addresses of those served are `service.served`. The court title is the layout's constant (no `court_title`), "v." is the layout's (no `caption.between`).

## Known gaps and open choices

1. **One exemplar, one filer.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; this is not met. Candidates seen and not saved: *Prutehi Guahan v. U.S. Department of the Air Force*, 1:22-cv-00001, Doc. 19 (a motion to dismiss on the RECAP index; not downloaded). *Develles v. Government of Guam*, 1:24-cv-00019, Doc. 45 (a motion to dismiss, but the RECAP PDF is a one-page scan with no text layer; not usable). *Guam Visitors Bureau*, 1:26-cv-00017, Doc. 20 (a first motion to dismiss for lack of jurisdiction, 12 pages, a scan with no text layer; not usable).
2. **Only the memorandum (Doc. 13-1) is the exemplar.** The motion itself (Doc. 13, 3 pages, same counsel, same caption) is not transcribed or saved. The template renders the caption, the memorandum and the certificate; a standalone motion would use the same chrome with its own body.
3. **Footnotes not transcribed.** The exemplar has footnote 1 (the Citizen Participation in Government Act, on its page 9) and footnote 2 (the SLAPP argument, 7 GCA § 17101 et seq., on its page 11). The shared model sets footnotes, but the sample still omits both, so the transcription is not complete at those two places.
4. **Typeface.** No court-named face: GNLR 5.1 (2022) sets none. The template sets vendored Times New Roman 12 pt, the exemplar's face, in all three engines.
5. **Italics are supplied by the transcription.** The exemplar's text layer has no italic markup; case names and signals are italicised by the transcriber, following the usual convention. Not checked against the filed typography.
6. **Emphasis lost.** The memorandum says "(emphasis added)" in two places; the emphasis is not in the text layer and is not reproduced.
7. **Caption rules.** The parties column is ruled at its right and foot, as the exemplar (fb-595.17.12; the earlier template had no rules). No ")" column; the exemplar has none.
8. **Left-aligned** (ragged right), as in the complaint.
9. **Headings centred.** The exemplar sets its numbered section headings indented at the left (its certificate's title centred); the template centres every level-1 heading, the base's and the federal convention, so the certificate's title stays centred too. DEF-COVER-002 reports this one difference (`eval.yaml` `params.cover_structure: report`; typst and docx are listed in `data/cover-structure-baseline.txt`).
10. **Line pitch and clearance** as measured on the PDF: counsel lines 13.8 pt, body 24.0 pt, the court title's first line 3.19 in. from the top of the page (below the counsel block).

## Review of the rendered pages (11 of 11, 2026-10-29, the FRCP-base render)

Every page of the typst, LaTeX and Word renders was read as its text layout and word boxes (`pdftotext -layout`, `-bbox`, the rules from `pdftocairo -svg`); the three break every line and page alike (XENG-001..003), and the typst render breaks every page where the render before the port did.

- Page 1: counsel block top left, single-spaced; court title bold, centred, 3.19 in. from the top; the caption, the parties ruled at the right and foot, the file number, "CIVIL", the removal notice, bold title and Rule 12 grounds at the right; heading I and the first paragraphs. Pass.
- Pages 2 to 3: heading II, A., paragraphs with the italic case names and signals. Pass.
- Pages 4 to 6: the end of A.; heading B. kept with its paragraph; Rule 12(f) and the cases; "as follows:" ends page 6. Pass.
- Page 7: the counterclaim paragraphs "123 –" to "129 –" and the *Id.* line. Pass.
- Page 8: the affirmative-defense paragraphs ("82 –" to "116 –"); the end of B.; heading C. Pass.
- Page 9: C. (*Noerr-Pennington*). Pass.
- Page 10: C. end; III. CONCLUSION; the signature block kept with the last paragraph. Pass.
- Page 11: CERTIFICATE OF SERVICE on its own page, its text double-spaced; the two persons served single-spaced; the signature block again. Pass.

Tier 2 is **not** judged against a second filer (gap 1). OPEN: the second exemplar (gap 1), the footnotes (gap 3).

## Engines

On the generic federal district brief since fb-595.17.12: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template (`typst/gud-motion-brief.typ`) only names the face; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter (`docx/gud-motion-brief.lua`) are removed. docs/EVAL-LOOP.md, "Generated engines", has the layout grammar.

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst | `usage/OUTPUT-motion-brief.typst.pdf` (11 pages) | `RESULT: 10 checks passed, 0 failed` | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` (11 pages) | `RESULT: 13 checks passed, 0 failed` | PASS (301/301 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (11 pages) | `RESULT: 14 checks passed, 0 failed` | PASS (301/301 lines) |

DEF-COVER-002 is REPORTED on every engine (gap 9). Word repair prompt: not checked (no Word). TOC, TOA, cross-references: none in this doc type. Line numbering: not required by GNLR 5.1.
