# W.D. Wis. Bankruptcy Court: motion with brief in support

Doc type: **motion with brief (memorandum) in support**, one filed document: a written motion in a contested matter with the memorandum of law that supports it. Court: United States Bankruptcy Court, Western District of Wisconsin (`wiwb`). Folder: `courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief/`.

Status: exemplar=yes (one filer), render=ok (19 pages, typst 0.15.0, no warnings), overlay=ok (19 pages, page for page), pages reviewed 19 of 19 of the render and 19 of 19 of the overlay (2026-10-16, depth pass fb-595.38.3). Nothing here sets `court.json` status. This doc-type folder has no `checks.yaml`, so `tools/check.sh` does not run here yet (see gaps).

## What is here

- **Template**: `typst/main.typ` (entry) and `typst/wiwb-motion-brief.typ` (layout). No case-specific text: every name, number, title and date comes from the sample's frontmatter.
- **Exemplar**: `exemplars/FILED-EXAMPLE-johnson-18-10327-motion-brief.pdf`, Hiawatha National Bank's Post-Trial Memorandum of Law in Support of its Motion to Dismiss, *In re Johnson*, No. 18-10327-12, filed by Eckberg Lammers, P.C. (Amanda K. Schlitz), March 16, 2018. 19 pages, Times New Roman, text layer. Details and provenance in `exemplars/SOURCE.md`.
- **Sample**: `samples/INPUT-hiawatha-memorandum.md` is a **full transcription of that exemplar** (all 19 pages): court name, short-title caption, designation, opening paragraph, JURISDICTION AND VENUE, BACKGROUND (paragraphs 1-27), ARGUMENT with subheadings A-G, five block quotations (ten paragraphs), a five-item bulleted list, both footnotes, CONCLUSION, and the signature block. Compared word by word with `pdftotext` of the exemplar: no missing text. The exemplar has no certificate of service, notice of hearing or proposed order, so the sample has none. The id `hiawatha-memorandum` is kept (it already names this filing, and the docx engine's `OUTPUT-hiawatha-memorandum.docx` uses it).
- **Outputs**: `samples/OUTPUT-hiawatha-memorandum.pdf`, `samples/OVERLAY-hiawatha-memorandum.pdf` and `.txt`. The stale `samples/OUTPUT-constructed-motion-brief.pdf` (no matching input) was removed in this pass.

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
| Typeface | EB Garamond 12 pt (vendored, OFL) | No rule governing a motion or brief names a face, so per `docs/FONTS.md` ("No face named") EB Garamond is used. The exemplar is Times New Roman (filer's choice); not chased. |
| Body spacing | double: `body-leading` 1.65em, 27.6 pt pitch; paragraph gap the same | Convention (word-processor "double" line at 12 pt). The overlay lines up line for line on most pages. |
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
sh tools/render.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief samples/INPUT-hiawatha-memorandum.md
sh tools/overlay.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief hiawatha-memorandum
```

- `samples/OUTPUT-hiawatha-memorandum.pdf`: 19 pages (the exemplar is 19). Typst compiled with no warnings. `pdffonts`: EBGaramond-Regular, -Bold, -Italic only, all embedded.
- `samples/OVERLAY-hiawatha-memorandum.pdf` / `.txt`: ours red, filed blue. Page map (word overlap, a diagnostic, not a score): every page pairs with the same filed page, 1→1 through 19→19. Overlap 74% (p.1), 80% (p.2), 91-93% (p.3-4), 72-82% (p.5-7), 46-67% (p.8-14, where our pages run about one paragraph behind), 80% (p.15), 85-96% (p.16-19). Before this pass the map skipped filed pages 9 and 12 and the signature stood alone on page 19.

## Changes in this pass (fb-595.38.3)

1. Caption rebuilt to Official Form 416B for a main-case motion: Case No. moved to the right column, "Debtor." indented under the name, the box rules dropped (they stay for the adversary caption).
2. Designation single-spaced and centred in a narrower block (it had been double-spaced across the full width).
3. Headings single-spaced with one double-spaced line above and below (two-line level-2 headings had been double-spaced and touched the next paragraph).
4. The last body paragraph is kept with the signature block (the signature had been alone on page 19); the date now sits on the "By:" line, as in the exemplar.
5. Stale `OUTPUT-constructed-motion-brief.pdf` removed; README and `exemplars/SOURCE.md` corrected (they said no exemplar existed).

## Visual review (Gate 2 record, 2026-10-16)

Every page of `OUTPUT` rendered at 60 dpi and every page of `OVERLAY` at 120 dpi, each looked at.

| Page | Finding |
|---|---|
| 1 | OK. Court name, Form 416B caption, designation, opening paragraph, JURISDICTION AND VENUE, paragraphs 1-3. ACCEPTED (tier 3): BACKGROUND moves to page 2 (the exemplar fits it and paragraph 4 on page 1); the gap at the foot is the heading kept with its paragraph. |
| 2-4 | OK. Numbered paragraphs 4-23, double-spaced; within one paragraph of the exemplar. |
| 5 | OK. ARGUMENT heading with space above and below. |
| 6-8 | OK. Block quotations single-spaced and indented both sides; citations italic. |
| 9-10 | OK. Subheadings A and B single-spaced with hanging indent, set off from the text. |
| 11-12 | OK. Two block quotations; subheading C. |
| 13 | OK. Footnote 1 at the foot of its page; subheading D. |
| 14-15 | OK. Subheading E and the bulleted list; footnote 2 runs from page 14 to 15 (typst splits a long note); subheading F. |
| 16 | OK. Four-paragraph block quotation. |
| 17-18 | OK. Subheading G; argument on refiling bar. |
| 19 | OK. Last argument paragraph is on page 18 as in the exemplar; CONCLUSION, its paragraph and the signature block share page 19. |

Tier 2 findings across pages:

- ACCEPTED (tier 3): the exemplar's body is fully justified; ours is ragged right. Neither is required.
- ACCEPTED (tier 3): the exemplar types "s/ Amanda K. Schlitz" with an underline and sets the role line in italics; ours prints "/s/" and roman. "/s/" is the usual CM/ECF form.
- ACCEPTED (tier 3): the exemplar puts a tab after paragraph numbers 1-3 and a space after 4-27; the sample types a space throughout.
- ACCEPTED (tier 3): typeface, EB Garamond vs the exemplar's Times New Roman (no rule names a face).

Reviewed pages: 19 of 19 (OUTPUT) and 19 of 19 (OVERLAY).

## Known gaps

1. **One filer.** Tier 2 asks for two or three exemplars from different filers; only one is saved. Searches are in `exemplars/SOURCE.md`.
2. **Exemplar provenance.** The download URL and date of the exemplar were not recorded when it was harvested; see `exemplars/SOURCE.md`.
3. **Local rule.** No current W.D. Wis. bankruptcy local rule on motion form, memoranda or page limits was found. The form choices above are conventions until one is read.
4. **No `checks.yaml` / `rules.md`.** This doc-type folder has neither, so `tools/check.sh` cannot run here (it exits on the missing files). Adding them is outside this pass.
5. **Not generated:** notice of motion and hearing, proposed order, certificate of service. None is in the exemplar and no local rule requiring one was found.
6. **Sample content.** The sample is the filer's text; case citations were not checked against the reporters.

## Engines

Note (fb-595.38.3): the DOCX notes below were written against the earlier typst form. The typst caption now follows Official Form 416B (no rules, Case No. at right) and the signature is no longer alone on the last page; the docx engine was not changed in this pass and still draws the older caption.

DOCX (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference; `docx/wiwb.lua` lays out the cover, caption, enumerated items and signature block; body paragraphs, headings, block quotations and footnotes are pandoc's own, styled from the reference. Built with `sh tools/render.sh --engine docx <this dir> samples/INPUT-hiawatha-memorandum.md`, which writes `samples/OUTPUT-hiawatha-memorandum.docx`.

- **Matches the typst form (by its parameters, not seen on a page):** EB Garamond 12 pt; body at 27.6 pt exact line pitch (double spacing, as the typst leading gives); first-line indent 0.5 in; paragraphs not numbered; level-1 headings bold capitals, centred; level-2 headings bold, left, with a 0.4 in hanging indent; block quotations 0.5 in on both sides, single-spaced; footnotes 10 pt single-spaced; enumerated items with a hanging label; caption with the "In re:" block and its left and bottom rules; title centred bold; signature block in the right 3.1 in column that does not break across pages; 11 pt centred page number; letter paper, 1 in margins. The sample has no adversary caption, so no party column or adversary number is drawn, as the typst form does for it.
- **Differs or unverified:** the enumerated items are typed labels (1., 2., ...), not Word list numbering. Block quotations and the paragraph gap after them are approximated with exact spacing, not typst's spacing rule. The caption rules are table borders. The "By: /s/" line is plain text, not a drawn line. The title and date metadata are printed once, on the cover and in the signature block. Word and LibreOffice may paginate differently; not compared.
- **BLOCKED (docx.pdf and page review):** `soffice` is not installed on this box (no conda package, no root), so `samples/OUTPUT-hiawatha-memorandum.docx.pdf` was not produced, `tools/check.sh --engine docx` cannot run, and no page was rendered or reviewed (pages reviewed for docx: 0). The render script fails at the soffice step after writing the .docx; the .docx itself is valid (zip and every XML part well-formed).
- **BLOCKED (not verified):** the .docx has not been opened in Word or LibreOffice; the font name "EB Garamond" is declared and must be installed to show; the signature block's placement at the foot of the last page is not checked (the typst review left it OPEN on page 19).
- **TOC, TOA:** none, because the typst form has none; no field update is needed.
