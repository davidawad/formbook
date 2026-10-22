# W.D. Wis. Bankruptcy Court: motion with brief in support

Doc type: **motion with brief (memorandum) in support**, one filed document: a written motion in a contested matter with the memorandum of law that supports it. Court: United States Bankruptcy Court, Western District of Wisconsin (`wiwb`). Folder: `courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief/`.

Status: exemplar=yes (one filer), render=ok (19 pages, typst 0.15.0, no warnings), overlay=ok (19 pages, page for page), pages reviewed 19 of 19 of the render and 19 of 19 of the overlay (2026-10-16, depth pass fb-595.38.3). Nothing here sets `court.json` status. This doc-type folder has no `checks.yaml`, so `tools/check.sh` does not run here yet (see gaps).

## What is here

- **Template**: `typst/main.typ` (entry) and `typst/wiwb-motion-brief.typ` (layout). No case-specific text: every name, number, title and date comes from the sample's frontmatter.
- **Exemplar**: `usage/FILED-EXAMPLE-motion-brief.pdf`, Hiawatha National Bank's Post-Trial Memorandum of Law in Support of its Motion to Dismiss, *In re Johnson*, No. 18-10327-12, filed by Eckberg Lammers, P.C. (Amanda K. Schlitz), March 16, 2018. 19 pages, Times New Roman, text layer. Details and provenance in `usage/SOURCE.md`.
- **Sample**: `usage/INPUT-motion-brief.md` is a **full transcription of that exemplar** (all 19 pages): court name, short-title caption, designation, opening paragraph, JURISDICTION AND VENUE, BACKGROUND (paragraphs 1-27), ARGUMENT with subheadings A-G, five block quotations (ten paragraphs), a five-item bulleted list, both footnotes, CONCLUSION, and the signature block. Compared word by word with `pdftotext` of the exemplar: no missing text. The exemplar has no certificate of service, notice of hearing or proposed order, so the sample has none. The id `hiawatha-memorandum` is kept (it already names this filing, and the docx engine's `OUTPUT-motion-brief.docx` uses it).
- **Outputs**: `usage/OUTPUT-motion-brief.typst.pdf`, `usage/OVERLAY-hiawatha-memorandum.pdf` and `.txt`. The stale `usage/OUTPUT-constructed-motion-brief.pdf` (no matching input) was removed in this pass.

## Governing rules

Federal rule text was read on the Legal Information Institute pages (https://www.law.cornell.edu/rules/frbp) on 2026-10-14 (LII shows the 2024 restyled text). Official Form 416B was read from uscourts.gov on 2026-10-16.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| WIWB-MO-001 | Fed. R. Bankr. P. 9013, https://www.law.cornell.edu/rules/frbp/rule_9013 | A request for an order is made by written motion stating its grounds with particularity and the relief sought. | Content, not layout: the sample's opening paragraph and CONCLUSION. The template asserts no heading names (the rule requires substance, not headings). |
| WIWB-MO-002 | Fed. R. Bankr. P. 9014, https://www.law.cornell.edu/rules/frbp/rule_9014 | A contested matter (a motion in the main case, not an adversary proceeding) is begun by motion. | Caption choice: the short-title `In re` caption when the frontmatter has no `caption:` list. |
| WIWB-MO-003 | Fed. R. Bankr. P. 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 | Caption: court name; case title; case number (and adversary number, if any); brief designation of the paper. | `court-title()`, `caption()`, `cover()` |
| WIWB-MO-004 | Official Form 416B, Caption (Short Title), 12/15, https://www.uscourts.gov/forms-rules/forms/caption-short-title-0 (PDF `/sites/default/files/form_b416b_0.pdf`) | Court name centred; "In re" and the debtor's name, "Debtor" beneath, at the left; "Case No." and "Chapter" at the right; designation of the paper centred below. No rules or boxes. | `caption()` main-case branch; title block in `cover()` |
| WIWB-MO-005 | Fed. R. Bankr. P. 9004(a) | Papers must be clearly legible. | body 12 pt, `type-size` |
| WIWB-MO-006 | Fed. R. Bankr. P. 9011(a), https://www.law.cornell.edu/rules/frbp/rule_9011 | Signed by an attorney of record, with address, e-mail and telephone number. | `signature()` |
| WIWB-MO-007 | Fed. R. Bankr. P. 7010 / 7012(b) | Adversary-proceeding caption and Rule 12(b) defenses (for a motion filed in an adversary proceeding). | `caption()` adversary branch (boxed party column, adversary number), used only when the frontmatter gives `caption:` |

**Local rules.** The court's published local rules page (`https://ecf.wiwb.uscourts.gov/wiwb/Decisions/local_rules.htm`, "Revised 6/2015", fetched 2026-10-14) lists seven local bankruptcy rules, none on motions, memoranda, page limits or the form of papers. A current W.D. Wis. rule on form, page limits or the memorandum requirement was **not found**; the template imposes no page limit and no section list. W.D. Wis. LBR 1007-2 names Arial, Times New Roman or Courier, but only for the creditor matrix, not for motions or briefs.

## Parameters: rule or convention

| Parameter | Value | Basis |
|---|---|---|
| Paper, margins | 8½ × 11 in, 1 in all round | Convention (no W.D. Wis. rule found); the exemplar matches. |
| Typeface | Times New Roman 12 pt (vendored), typst and docx | No rule governing a motion or brief names a face; Times New Roman is the house standard (`docs/FONTS.md`), and the exemplar's face. |
| Body spacing | double: exact 27.6 pt line boxes, no extra space between paragraphs; single lines 13.8 pt; footnotes 10 pt in 11.5 pt lines (shared cross-engine model, `lib/typst/xengine.typ`) | Convention (word-processor "double" line at 12 pt). The overlay lines up line for line on most pages. |
| Caption | Official Form 416B layout for a main-case motion | WIWB-MO-004. |
| Designation | bold capitals, centred, single-spaced, narrower than the text block | Fed. R. Bankr. P. 9004(b); Form 416B. Single spacing is convention. |
| Headings | level 1 centred bold capitals; level 2 bold, left, 0.4 in hanging indent; both single-spaced, one double-spaced line above and below, kept with the next paragraph | Convention. |
| Paragraphs | 0.5 in first-line indent; numbers, where the filer uses them, are typed in the text | Convention. |
| Block quotations | 0.5 in both sides, single-spaced | Convention. |
| Footnotes | typst default footnote entry (0.85em, about 10 pt), single-spaced | Convention. |
| Signature | right column 3.1 in: firm (bold), "By: /s/ name" with the date on the same line at the left, then bar number, role, address, phone, e-mail; never split; the last body paragraph is kept on the page with it | Fed. R. Bankr. P. 9011(a) for content; layout is convention. |
| Page number | centred, 11 pt, footer | Convention. |

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief hiawatha-memorandum
```

- `usage/OUTPUT-motion-brief.typst.pdf`: 20 pages (the exemplar is 19). Typst compiled with no warnings. `pdffonts`: Times New Roman regular, bold and italic only, all embedded.
- `usage/OVERLAY-hiawatha-memorandum.pdf` / `.txt`: ours red, filed blue. Page map (word overlap, a diagnostic, not a score): every page pairs with the same filed page, 1→1 through 19→19. Overlap 74% (p.1), 80% (p.2), 91-93% (p.3-4), 72-82% (p.5-7), 46-67% (p.8-14, where our pages run about one paragraph behind), 80% (p.15), 85-96% (p.16-19). Before this pass the map skipped filed pages 9 and 12 and the signature stood alone on page 19.

## Changes in this pass (fb-595.38.3)

1. Caption rebuilt to Official Form 416B for a main-case motion: Case No. moved to the right column, "Debtor." indented under the name, the box rules dropped (they stay for the adversary caption).
2. Designation single-spaced and centred in a narrower block (it had been double-spaced across the full width).
3. Headings single-spaced with one double-spaced line above and below (two-line level-2 headings had been double-spaced and touched the next paragraph).
4. The last body paragraph is kept with the signature block (the signature had been alone on page 19); the date now sits on the "By:" line, as in the exemplar.
5. Stale `OUTPUT-constructed-motion-brief.pdf` removed; README and `usage/SOURCE.md` corrected (they said no exemplar existed).

## Visual review (Gate 2 record, fb-595.68.28)

Every page of the typst and docx renders viewed at 40 dpi (the docx breaks every line and page as typst does, XENG-001..003; page 16 also at 60 dpi on both).

| Page | Finding |
|---|---|
| 1 | OK. Court name, Form 416B caption, designation, opening paragraph, JURISDICTION AND VENUE, paragraphs 1-3, BACKGROUND and paragraph 4 begun. |
| 2-5 | OK. Numbered paragraphs 4-27, double-spaced (the numbers typed by the drafter). Page 4 ends short: ARGUMENT is kept with its first paragraph. |
| 6-8 | OK. ARGUMENT; block quotations single-spaced and indented 0.5 in both sides; citations italic. |
| 9-12 | OK. Subheadings A and B bold, single-spaced, hanging 0.4 in; block quotations. |
| 13-14 | OK. Subheading C; footnote 1 at the foot of page 14 (10 pt, single); subheading D. |
| 15-16 | OK. Subheading E and the bulleted items (bullet at 0.5 in, text hanging at 0.9 in); footnote 2 whole at the foot of page 16; subheading F. |
| 17 | OK. Four-paragraph block quotation. |
| 18-19 | OK. Subheading G; argument on the refiling bar. |
| 20 | OK. CONCLUSION, its paragraph and the signature block (the date beside "By: /s/"), kept together. |

Tier 2 findings across pages:

- ACCEPTED (tier 3): the exemplar's body is fully justified; ours is ragged right (the cross-engine model). Neither is required.
- ACCEPTED (tier 3): the exemplar types "s/ Amanda K. Schlitz" with an underline and sets the role line in italics; ours prints "/s/" and roman. "/s/" is the usual CM/ECF form.
- ACCEPTED (tier 3): the exemplar puts a tab after paragraph numbers 1-3 and a space after 4-27; the sample types a space throughout.
- ACCEPTED (tier 3): 20 pages against the exemplar's 19 (no extra space between paragraphs, but headings and quotations are set off by blank single lines).

Reviewed pages: 20 of 20 (typst) and 20 of 20 (docx).

## Known gaps

1. **One filer.** Tier 2 asks for two or three exemplars from different filers; only one is saved. Searches are in `usage/SOURCE.md`.
2. **Exemplar provenance.** The download URL and date of the exemplar were not recorded when it was harvested; see `usage/SOURCE.md`.
3. **Local rule.** No current W.D. Wis. bankruptcy local rule on motion form, memoranda or page limits was found. The form choices above are conventions until one is read.
4. **tools/check.sh.** Since fb-595.68.28: `sh tools/check.sh <this folder>` and `--engine docx` both exit 0 (typst 9, docx 13 checks passed, 0 failed).
5. **Not generated:** notice of motion and hearing, proposed order, certificate of service. None is in the exemplar and no local rule requiring one was found.
6. **Sample content.** The sample is the filer's text; case citations were not checked against the reporters.

## Engines

DOCX (`docx/`): `docx/reference.xml` holds the Word styles: `base="xengine"` in the typst face (`{font}`, Times New Roman), 12 pt, 552-twip body and 276-twip single line boxes, Footnote Text at 10 pt in 230-twip lines with 6 pt after, Body Text Keep and List Note (Keep) for the paragraphs pandoc writes because they carry a footnote, and the 11 pt page-number footer 0.5 in above the page edge; `fb render` builds the reference document from it. `docx/wiwb.lua` reads the sample's body chunk by chunk, as the typst template does (each chunk with the definitions of the notes it refers to), and writes every paragraph as WordprocessingML on `lib/docx/xengine.lua`, except a paragraph or item with a footnote, which stays a pandoc paragraph so that pandoc writes the note; the frontmatter strings come from fb render's `$FORMBOOK_META`. No script: `fb render` runs pandoc with the filter and packs the archive (fb-595.68.28; were `build-reference.sh` and a committed `reference.docx` naming EB Garamond).

- Cross-engine (fb-595.68.28): `sh tools/check.sh <this folder> --engine docx`: XENG-001..003 PASS (510/510 lines, 20 = 20 pages); `params.cross_engine: gate` in `eval.yaml`. typst 9 and docx 13 checks passed, 0 failed.
- The adversary-proceeding caption (a `caption:` list in the frontmatter) is laid out in both engines but has no sample here.
- The `.docx` converts in LibreOffice without error (the check's conversion); not opened in Word. No table of contents or of authorities.
