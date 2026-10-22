# ilcb: adversary complaint (U.S. Bankruptcy Court, C.D. Illinois)

Doc type: the complaint that commences an adversary proceeding (FRBP 7001, 7003; ILCB LR 7003-1). Court alias `ilcb`. Court-level status is in `../../court.json` and is not changed here.

## Layout

| Path | What |
|---|---|
| `usage/` | Two filed complaints from different filers, with `SOURCE.md` (URLs, filers, dates). |
| `typst/ilcb-adversary-complaint.typ` | The template: `ilcb-adversary-complaint(meta, md)`. Content-agnostic; each number is a named parameter at the top. |
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...`. |
| `usage/INPUT-adversary-complaint.md` | Transcribed from the first exemplar (I80 Equipment, First Midwest Bank), with the FRBP 7008 consent sentence added (see Gaps). |
| `usage/OUTPUT-adversary-complaint.typst.pdf` | Our typst render (9 pages); `OUTPUT-adversary-complaint.docx` and `.docx.pdf` the docx render (9 pages, the same lines and pages). |
| `usage/OVERLAY-i80-adversary-complaint.pdf`, `.txt` | Red/blue overlay against the first exemplar, and the page map. |

File names follow the repo's role convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`) because `tools/render.sh` and `tools/overlay.sh` read and write those names. The brief's `<id>.md` / `<id>-overlay.pdf` names were not used for that reason.

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/seventh-circuit/illinois/federal/bankruptcy-central-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/seventh-circuit/illinois/federal/bankruptcy-central-district/adversary-complaint i80-adversary-complaint courts/seventh-circuit/illinois/federal/bankruptcy-central-district/adversary-complaint/usage/FILED-EXAMPLE-adversary-complaint.pdf
```

The overlay takes the exemplar as an explicit argument, because its default (the alphabetically first exemplar) is the 3-page Erickson complaint, not the 9-page I80 complaint the sample comes from.

## Governing rules

Verified 2026-10-14. "M" is mandated by a rule, "C" is the court's own convention or guidance, "A" is the filer's responsibility, "T" is a project choice.

| ID | Kind | Requirement | Source (URL, rule, date verified) | How the template handles it |
|---|---|---|---|---|
| ILCB-7010-1 | M | Caption: name of court, title of proceeding, adversary number, designation as a complaint. Civil Rule 10 applies; the caption must substantially conform to Form 416. | FRBP 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 (verified 2026-10-14) | Court name is fixed in the template; parties, debtor case number, chapter and adversary number come from the frontmatter `caption`. |
| ILCB-9004-1 | M | Legible; caption contents (court, title, case number, adversary number, designation). | FRBP 9004(a)-(b), https://www.law.cornell.edu/rules/frbp/rule_9004 (verified 2026-10-14). The Cornell page shows only (a) and (b); no subdivision (c) on paper size was retrieved, see Gaps. | Typeset in a single legible face; caption as above. |
| ILCB-7008-1 | M | Pleader must state whether it does or does not consent to the entry of final orders or judgment by the bankruptcy court. Civil Rule 8 applies, so the jurisdiction statement must identify the case name, number and chapter, and the district and division. | FRBP 7008, https://www.law.cornell.edu/rules/frbp/rule_7008 (verified 2026-10-14) | Author text in the sample (paragraph 2). The template does not generate it; see Gaps. |
| ILCB-10-1 | M | Numbered paragraphs, each limited as far as practicable to a single set of circumstances (Civil Rule 10(b), applied by FRBP 7010). | FRBP 7010 (above); Fed. R. Civ. P. 10(b) | Paragraph numbers are typed by the author (escaped `1\.` so they stay paragraphs); first-line indent. |
| ILCB-7003-1 | M (local) | Complaint is docketed under the event that matches the nature of the suit. | ILCB Local Rules, https://www.ilcb.uscourts.gov/sites/ilcb/files/ILCB%20Local%20Rules%2010.1.2024.pdf (effective Oct. 1, 2024; verified 2026-10-14) | Not a layout rule. Filer responsibility (A). |
| ILCB-SIG-1 | C | Electronic signature: "/s/" followed by the typed name. | Bankruptcy Practice Guide, "Signature Requirements" section, https://www.ilcb.uscourts.gov/sites/ilcb/files/Bankr%20Practice%20Guide%2012.1.25%20rule%20restyling.pdf (Dec. 1, 2025; verified 2026-10-14) | `By: /s/ <signer>` from `signature.signer`. |
| ILCB-SVC-1 | A | Summons issued by the clerk and served under FRBP 7004; proof of service is filed as "Summons Service Executed" (LR 7004-1). | ILCB LR 7004-1 (above) | Not part of the complaint. No certificate is generated for the complaint. |
| ILCB-TYPE-1 | T | Typography: 12 pt Times New Roman (the house standard; vendored, Liberation Serif as its fallback), double spacing (27.6 pt pitch), 1 in margins, centered page number. No CDIL typography rule exists; see Gaps. **Typeface: face required by rule = none; Times New Roman, the house standard (fb-595.68), on typst and docx alike (was EB Garamond 13 pt in the docx until fb-595.68.27).** The Bankruptcy Practice Guide's only "FONT" line is for the Mailing Matrix in computer-readable form ("Do not use script-style fonts"), not for pleadings; the local rules name no face. | Tier 2, from the three exemplars (measured: 27.6 pt line pitch on body pages; Times or Arial; 1 in margins) | `type-size`, `pitch-body`, `pitch-single`, `page-margin` at the top of the template; the docx sets the same numbers in twips (`docx/reference.xml`, `docx/ilcb-adversary-complaint.lua`). |

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `caption.left` | yes | list of party lines, one per line, in the left column (inline markdown allowed). Use ` ` for indentation. |
| `caption.right` | yes | list of case lines, aligned by row with `left` (bankruptcy case number, chapter, adversary number). |
| `document_title` | yes | the title, centered and bold. Wraps naturally; no line breaks. |
| `dated` | no | "Dated: ..." line above the signature block. |
| `signature.firm`, `signature.signer` | yes | the firm (bold), and the typed name after "By: /s/". |
| `signature.counsel` | no | counsel of record lines at the left margin under the signature. |

Body: `#` is a centered bold section heading (INTRODUCTION, COUNTS, REQUEST FOR RELIEF). `##` is a bold heading at the left; `###` bold italic; `####` italic. Heading numbers are typed. Escape paragraph numbers (`1\.`). Footnotes use `[^key]` with a definition anywhere in the file (the template carries definitions to every render call). Sub-paragraphs such as `(i)` are plain paragraphs. The signature block is kept with the last paragraph.

## Overlay

`usage/OVERLAY-i80-adversary-complaint.pdf`: red is our render, blue is the filed I80 complaint, black is where they agree. The page map (`.txt`) pairs our pages to the filed pages by shared words: our pages 1 to 4 pair with filed pages 1 to 4; our page 5 pairs with filed page 4 by word overlap (the pairing is the tool's rule; the page-by-page review did not find a content gap there); our pages 6 to 10 pair with filed pages 5 to 9. Word overlap runs from 30.5% (our page 4) to 83.9% (our page 7). The differences the overlay shows are tier 2 or tier 3, not tier 1: the typeface (measured on the earlier EB Garamond render: EB Garamond against Helvetica and Liberation in the filed copy), the sub-paragraph layout (ours first-line indented, theirs hanging), the footnote text size, and the `Dated:` line wording. The filed copy also carries the CM/ECF header ("Case 18-08003 Doc 1 Filed ...") that the court system adds on filing, which the template does not generate.

## Pages reviewed

Final render, 2026-10-14, every page viewed at 60 dpi (`pdftoppm -r 60`) after the last change:

- pages 1 to 10: reviewed. Page 1: caption and title on the first page, no cover. Pages 2 to 9: numbered paragraphs, centered and left headings, counts, sub-paragraphs, footnote 1 on page 3. Page 10: the last prayer item kept with the signature and counsel block.

Defects found and fixed during review:

1. "§§" split across lines on page 2 (the no-break rule matched a single section sign). Fixed: the rule now covers `§§`.
2. The signature block and the last paragraph separated when a footnote definition ended the file. Fixed: footnote definitions travel with every render call, and the keep-with-signature logic looks at the body, not the definitions.

Pages reviewed: 10 of 10.

Fonts pass, 2026-10-15 (historical; the face is now Times New Roman, see ILCB-TYPE-1): no court rule names a face, so the face then stayed EB Garamond (`pdffonts` on the new render: EBGaramond Regular, Bold, Italic). Re-rendered with zero typst warnings and the overlay regenerated. Every page (1 to 10) was viewed at 60 dpi on the render made before the comment-only template edit; the final render has the same 10 pages and fonts.

## Gaps

- No CDIL typography rule exists (the local rules and FRBP 9004(a) say only "legible"). The face, size, spacing and margins are tier 2, from the three exemplars. Times New Roman 12 pt (the Erickson and Walmart exemplars) is the most common face, no court rule names a face, so the template sets Times New Roman 12 pt, the house standard. This is a convention, not a rule.
- FRBP 7008 consent sentence: the template does not generate it. The sample adds the sentence to paragraph 2 ("Plaintiff consents to the entry of final orders or judgment by the bankruptcy court."); the I80 exemplar did not have it. Filers must state consent or non-consent in every complaint.
- Paper size: FRBP 9004(c) was not retrieved (see ILCB-9004-1). The template uses US Letter, the size of every exemplar. The Practice Guide's 8.5 x 11 rule is for proposed orders, not complaints.
- Exhibits, the summons, and the civil cover sheet are not templated. The exemplars attach exhibits by reference only.
- The CM/ECF header ("Case ... Doc 1 Filed ...") is added by the court system, not by the template.
- Only one exemplar was used for the overlay. The second (Erickson, 3 pages) was checked by reading its text for the caption and signature; it was not overlaid.

## Engines

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; `docs/EVAL-LOOP.md`, "Cross-engine gate"; fb-595.68.27), and `eval.yaml` gates it (`params.cross_engine: gate`): the docx breaks every line and page where typst does.

- **Layout** (both engines): Times New Roman 12 pt; the body in 27.6 pt line boxes (Word's double line), a 0.5 in first-line indent; the court lines, caption rows, title, headings, signature and counsel lines in 13.8 pt boxes (a single line); footnotes 11 pt in 12.65 pt boxes, 7 pt apart; a body line between the court lines and the caption and between the caption and the title, a single line around each heading. The caption is one row per frontmatter line (party line, ")", case line; columns 3.4 in and 0.3 in). Level-1 headings centered bold, level 2 bold, level 3 bold italic, level 4 italic. The last paragraph is kept with the signature block.
- **typst** (primary): `typst/ilcb-adversary-complaint.typ`, 9 pages.
- **docx**: `docx/reference.xml` (the `base="xengine"` style recipe in the typst face, `{font}`; Body Keep, Body Text Note, Footnote Text; pandoc's fancy lists off so "(i)" stays text) and `docx/ilcb-adversary-complaint.lua` (court lines, caption table, title, headings and signature block with exact spacing; body paragraphs and footnotes left to pandoc). `fb render --engine docx` builds the reference document, runs pandoc and converts with LibreOffice: `usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf`, 9 pages. No shell script (`build-reference.sh` and the binary `reference.docx` are gone, fb-595.68.27). Not opened in Word.
- **Checks** (2026-10-22): typst `RESULT: 9 checks passed, 0 failed`; docx `RESULT: 13 checks passed, 0 failed`, XENG-001..003 PASS (9 pages each, 223/223 lines). The docx was EB Garamond 13 pt until then (DEF-FONT-002 and TNR-EMBEDDED failed; 125/224 lines alike, 10 pages against 9).
- **Pages reviewed** (2026-10-22, fb-595.68.27): all 9 pages of the typst and of the docx render, side by side at 45 dpi: caption, title, headings, the "(i)" sub-paragraphs, footnote 1 on page 3, and the signature with the last prayer item on page 9 are alike in both; no defect found. The overlay and page reviews above were made on the earlier EB Garamond renders.
