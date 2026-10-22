# U.S. Bankruptcy Court, M.D. Pennsylvania (pamb): adversary complaint

Doc type: **adversary-complaint** (the complaint that starts an adversary proceeding under Part VII of the Federal Rules of Bankruptcy Procedure). Court: United States Bankruptcy Court for the Middle District of Pennsylvania. Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/adversary-complaint/`.

Status: exemplar=yes (one filing, one filer), render=ok, pages reviewed 3 of 3 on typst and docx. Typst and docx are on the shared cross-engine layout model (fb-595.68.34): the docx breaks every line and page where typst does (XENG-001..003 gated, `eval.yaml`). Nothing here sets `status` in `court.json`.

## Governing rules

Sources, all fetched 2026-10-14:

- **Local rules.** United States Bankruptcy Court, M.D. Pa., Local Bankruptcy Rules PDF, `https://www.pamb.uscourts.gov/sites/default/files/local-rules/usbc_pamb_local_rules.pdf` (the court's list, https://www.pamb.uscourts.gov/court-info/local-rules-and-orders, shows it as effective October 1, 2025). The PDF's own cover prints "Effective: January 1, 2005"; that date is inconsistent with the court's list, so confirm the operative version before relying on this file. Quotations below are from that PDF.
- **Federal rules.** Fed. R. Bankr. P. 7008, 7010, 9004 as published on Cornell LII (`https://www.law.cornell.edu/rules/frbp/rule_7008`, `.../rule_7010`, `.../rule_9004`), current text effective December 1, 2024.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| PAMB-ADV-001 | L.B.R. 7003-1 | "Any paper complaint filed under Part VII of the Federal Rules of Bankruptcy Procedure must be accompanied by an Adversary Proceeding Cover Sheet (Official Form 1040)." | **Not generated.** The cover sheet is a separate form. See gaps. |
| PAMB-ADV-002 | FRBP 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding"; the caption must "substantially conform to the appropriate version of Form 416." | `caption-table` in `typst/pamb-adversary-complaint.typ` |
| PAMB-ADV-003 | L.B.R. 9004-1 | A pleading filed in an adversary proceeding must have a caption "substantially in compliance with the Caption for Use in Adversary Proceeding (Official Form 416D)." | `caption-table`: court title, debtor block, rule line, party designations, chapter, case number, adversary number (blank line when none). |
| PAMB-ADV-004 | FRBP 7008(a) | The jurisdiction allegation "must include a reference to the name, number, and Code chapter of the case that the adversary proceeding relates to and the district and division where it is pending," and "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | `jurisdiction-block`. The case sentence is generated from `debtor` and `jurisdiction.district`. The core and consent statements come from `jurisdiction.core` and `jurisdiction.consent`, which the template requires (it panics without them). |
| PAMB-ADV-005 | FRCP 10(b) (incorporated by FRBP 7010) | Claims in numbered paragraphs, each "limited as far as practicable to a single set of circumstances." Stated from the rule's text; not fetched in this session. | `set enum(...)` in the template: the allegations are numbered from 1 at the margin. |
| PAMB-ADV-006 | FRBP 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." The current text has no paper-size, font, or margin rule. | Vendored Times New Roman only (`fallback: false`, no system fonts); 12 pt; 1 in margins; US Letter. |
| PAMB-ADV-007 | FRBP 9011 (signature) | Convention: the signature block names the firm, the signer, and the contact lines. The rule does not prescribe the layout. | `signature-block` |

Not used: the Official Form 416A/416D text itself was not retrieved; the caption follows the structure of the filed exemplar and the rule's description of the form. Check the form before calling the caption exact.

## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: "Trustee's Complaint for Turnover of Funds", Robert P. Sheils, Jr., Esquire, Chapter 7 Trustee, against National Debt Relief, LLC. Adversary No. 5:20-ap-00078-MJC; main case *In re Joseph Ryan Webb*, Case No. 5-20-00695. Filed 2020-11-18. 3 pages, text layer present (`pdftotext` reads it; Helvetica non-embedded, Liberation Sans embedded).
- Provenance, searches and the reasons this one was chosen are in `usage/SOURCE.md`.
- Only one exemplar. The eval-loop tier-2 rule asks for two or three from different filers. Not met; see gaps.
- The filed copy has no FRBP 7008(a) jurisdiction statement and leaves the adversary number blank. The template adds the statement (see PAMB-ADV-004); the sample fills it with bracketed placeholders for the pleader to choose.

## Sample

- `usage/INPUT-adversary-complaint.md`: the complete text of the exemplar (caption, title, the lead-in, allegations 1 to 11, the fee table, the prayer and the signature block). The caption spelling "JOSPEH" is kept as filed.
- Frontmatter fields: `court`, `debtor` (name, chapter, case_number), `adversary_number` (blank), `caption` (sides with names and designation), `title`, `jurisdiction` (district, core, consent), `signature` (firm, signer, id, lines). Optional: `date` (printed as "Dated:").
- The sample is 3 pages in the exemplar and 4 in the render. The depth target (8 to 14 pages) applies to exemplars of that length; this one is 3 pages, so the sample is the whole document.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq
sh tools/render.sh courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district/adversary-complaint webb-trustee-turnover
```

- File names follow the tools, not the brief's `<id>-overlay` form: `usage/OUTPUT-adversary-complaint.typst.pdf` (our render; 3 pages; typst with no warnings), `usage/OVERLAY-webb-trustee-turnover.pdf` and `.txt` (red = ours, blue = filed, black = both). The sample is `usage/INPUT-adversary-complaint.md` (no `INPUT-` prefix; `render.sh` strips only `INPUT-` when naming the output).
- Fonts: Times New Roman 12 pt (vendored), in typst and docx alike (it was EB Garamond until fb-595.68.34).
- Overlay page map (of the earlier 4-page EB Garamond render, not re-run): ours p.1 ↔ filed p.1 (42%), p.2 ↔ p.2 (54%), p.3 ↔ p.2 (35%), p.4 ↔ p.3 (78%). The pairing is by word overlap and coarse; the filed copy is the same text on fewer pages, and the render's extra page is the prayer and signature moved together by the sticky rule. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record: all 3 pages on each engine, rendered at 45 and 80 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 72/72).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (two rows: IN RE and the debtor beside the chapter and case number; the parties beside the blank adversary number), title, Statement of Jurisdiction, lead-in, allegations 1 and 2 | OK. The two bracketed placeholders for core and consent print where the pleader must fill them in; this is intentional. The blank adversary number is underlined in both engines. |
| 2 | Allegations 3 to 11 | OK. The number at the indent in a 0.5 in box, the text after it, the lines below at the margin, as filed. |
| 3 | Fee table, prayer ("WHEREFORE"), signature block | OK. The table is kept whole (it moved to page 3 with the 11th allegation's end on page 2); the prayer is kept on the page with the signature. |

Pages reviewed: 3 of 3 (typst), 3 of 3 (docx). No open tier-2 finding. Changes in this pass: the allegation numbers at the indent with the text running back to the margin (were a hanging list at the margin, unlike the filed copy); the caption in two rows, the adversary number beside the parties as filed; headings on the body pitch; the fee table borderless, 1 in in, on the body pitch (was a ruled grid; the filed table has no rules); the signature block single spaced from 3.3 in.

## Known gaps and open choices

1. **Cover sheet (PAMB-ADV-001).** L.B.R. 7003-1 requires the Adversary Proceeding Cover Sheet (Official Form 1040) with a paper complaint. Not generated: it is a separate form, and the e-filing system prompts for the same information. Not verified against the form's current text.
2. **Core and consent statements (PAMB-ADV-004).** The filed exemplar has neither. The template requires both fields and prints them as written; the sample's values are bracketed placeholders, so the sample is not a finished pleading until the pleader chooses. Neither statement's legal conclusion is supplied by the template.
3. **Summons and service.** Not generated (FRBP 7004 not checked).
4. **Font, margins, spacing.** Typeface row: face required = none; Times New Roman, the house face (`docs/FONTS.md` row "No face named"; was EB Garamond); fit = n/a. Checked 2026-10-15 against the full text of the local rules PDF (no rule on font, typeface, point size, margins or spacing; L.B.R. 9004-1 governs the caption only) and the federal text (FRBP 9004(a): legibility only). Times New Roman 12 pt, 1 in margins, double-spaced body (24 pt pitch) follow the look of the filed copy: convention, not a rule.
5. **Paper size.** US Letter; no rule text found. Convention.
6. **Tier-2 exemplars.** One exemplar. The eval-loop rule asks for two or three from different filers. A second and third M.D. Pa. adversary complaint with text layers were not found on CourtListener's RECAP archive (RECAP hits were orders, certificates of service, stipulations, or scanned complaints such as 5:17-ap-00098, which has no text layer).
7. **Caption exactness (PAMB-ADV-002, -003).** Built from the rule's description and the filed copy, not from the Form 416 images, which were not retrieved.
8. **Glyph check.** The filed copy's text layer drops apostrophes ("Sheriffs"). This complaint's text was checked against the text layer only; the exemplar page image was not compared. Compare against the page image before relying on the sample's apostrophes (the motion-brief exemplar's image was checked and shows them, see that folder's README).
9. **Page-limit and other checks.** No rule check runs over the rendered output. The required-field panics (`jurisdiction.core`, `jurisdiction.consent`, `debtor`, `caption`, and the others) are not exercised by a test here.
10. **Allegation numbering.** A chunk that starts "N." is an allegation, numbered as CommonMark numbers the list (the first item's number, then one more each); typst and docx number alike. A paragraph that starts with a number and a period must be escaped (`1\.`), as in any markdown.

## Engines

Engine status: typst `OUTPUT-adversary-complaint.typst.pdf`; docx `OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice), 3 pages each, every line and page as typst (XENG-001..003 gated); latex not built.

- **typst** (primary, `typst/`): on `lib/typst/xengine.typ`: a 24 pt body pitch, 14 pt single lines (court title, caption, title, signature, footer), explicit block spaces.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 24 pt lines with a 0.5 in first-line indent; single lines in 14 pt boxes) and `docx/pamb.lua` (on `lib/docx/xengine.lua`; the same file as the motion brief's but for its `CFG.kind`), which writes every paragraph: the court title, the caption (a two-row table, the left cells bordered at the right and foot), the title, the Statement of Jurisdiction, the numbered allegations, the fee table, the signature block, the footer (a centred 11 pt PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh` and a committed `reference.docx` in EB Garamond 13 pt). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none. `tools/check.sh <this folder> --engine docx`: `RESULT: 13 checks passed, 0 failed`; typst: `RESULT: 9 checks passed, 0 failed`.

## Searches tried

- CourtListener search API (`/api/rest/v4/search/`), `type=r` and `type=rd`, `court=pamb`: "adversary complaint", "Adversary Complaint", "complaint filed by", "complaint summons adversary proceeding plaintiff", "complaint dischargeability", "complaint for declaratory". Hosted PDFs were checked: Sheils (adversary 5:20-ap-00078) text-based and used; DeLuca / Tullio (adversary 5:17-ap-00098, doc 1, 9 pages) a scan with no text layer, not used.
- Web search for `gov.uscourts.pamb` adversary complaint PDFs: nothing beyond the RECAP archive.
- The court's website lists forms and rules but not filed complaints.

[Court root](../README.md) | [Motion brief](../motion-brief/README.md)
