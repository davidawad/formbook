# M.D. Alabama Bankruptcy Court: motion (`almb`)

Doc-type folder for a motion with its grounds in numbered paragraphs (a contested matter in the main case). Engine: typst (`typst/`). Parent court: [`../README.md`](../README.md).

- Exemplars: **two** (see `usage/SOURCE.md`). Primary: `FILED-EXAMPLE-motion-brief.pdf` (Bankruptcy Administrator's Motion to Dismiss, Britt B. Griggs, 12 pages). Second filer, tier 2 only: `FILED-EXAMPLE-motion-brief-3.pdf` (U.S. Attorney's memorandum of law in an adversary proceeding, 19 pages).
- Transcribed sample: `usage/INPUT-motion-brief.md`, the whole of the Ebury Street motion: caption, LBR 1017-2 notice legend, title, introduction, paragraphs 1-41 (with the filer's own numbering, including the jump from 16 to 21 and the repeated 39 and 40), the bulleted list in paragraph 3, six headings, prayer, signature block, certificate of service and the full service list (4 mail, 16 CM/ECF).
- Render: `usage/OUTPUT-motion-brief.typst.pdf`, **11 pages**, Times New Roman only (embedded; `pdffonts`), no typst warnings (12 pages in EB Garamond on 2026-10-16, before fb-595.68). `sh tools/render.sh <this-dir> usage/INPUT-motion-brief.md`. **render=ok** (2026-10-16).
- Overlay: `usage/OVERLAY-ebury-motion-brief.pdf` and `.txt` via `sh tools/overlay.sh <this-dir> ebury-motion-brief`. **overlay=ok** (2026-10-16). The tool takes the first PDF in `usage/` by name, which is the Ebury Street motion.
- Synthetic sample kept: `usage/INPUT-motion-brief-2.md` (invented, bracketed placeholders), re-rendered after the template fixes: `usage/OUTPUT-motion-brief-2.typst.pdf`, 5 pages in Times New Roman (6 in EB Garamond before fb-595.68, 5 before the double-spacing fix), no warnings.

## Engines

- **typst** (primary): `typst/`, as above.
- **docx**: `docx/reference.xml` (from which `fb render --engine docx` builds the reference document: the cross-engine recipe, `base="xengine"`, in the typst template's face, Times New Roman 12 pt; `docx/make-reference.sh` is retired) and `docx/almb-motion-brief.lua` (the court title, caption, notice legend, title, signature block and certificate of service; the body stays pandoc's). `sh tools/render.sh --engine docx <this-dir> usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx` and the LibreOffice PDF `usage/OUTPUT-motion-brief.docx.pdf` (11 pages; the `-2` sample 5 pages).
- **docx lagged the typst form** (recorded 2026-10-16, before fb-595.68 rebuilt the docx on `docx/reference.xml`; the filter now writes the notice legend and the certificate of service): (a) level-1 headings are 18 pt caps in the docx, body size and as-written case in typst; (b) the docx filter does not read the new frontmatter fields `notice`, `certificate_signature`, `service` or `signature.closing`, so the LBR 1017-2 / 9007-1 legend and the LBR 9013-3 service list are missing from a docx render of the Ebury sample; (c) the docx was never rendered to pages, so line breaks, page count and caption spacing are unchecked. Earlier notes (reference styles: letter, 1 in margins, EB Garamond 13 pt, exact 24 pt double spacing, 0.5 in first-line indent, boxed caption table, keep-with-next prayer, certificate on its own page, "-N-" footer) described the docx then.
- **docx BLOCKED** (see `docs/DOCX.md`; recorded before fb-595.68, when `soffice` was not available): Gates 0-2 on the `.docx.pdf` need `soffice`, which is not installed (conda-forge has no LibreOffice). `pages_reviewed=0` for docx. `tools/check.sh` for any engine is also blocked for this court: it has no `checks.yaml` yet.

## Rules (requirement IDs)

Kind: **M** mandated by a rule, **C** convention, **A** author responsibility. Local rules: M.D. Ala. Local Bankruptcy Rules effective 2024-04-01, `https://www.almb.uscourts.gov/sites/almb/files/ALMB%20Local%20Rules%2C%20April%201%2C%202024.pdf` (linked from `https://www.almb.uscourts.gov/local-rules-and-administrative-orders`), text read 2026-10-16. The 2017 set (`.../Local_Rules_Dec_1_%202017.pdf`) was read as well; it is superseded.

| ID | Requirement | Kind | Source (verified) |
|---|---|---|---|
| ALMB-MOT-001 | A motion must state its grounds with particularity and set forth the relief or order requested. | M | FRBP 9013(b), https://www.law.cornell.edu/rules/frbp/rule_9013 (verified 2026-10-14). Numbered grounds are the author's; the rule does not fix the layout. |
| ALMB-MOT-002 | The caption shows the court name, the case title, the case number and a brief designation of the document. A main-case motion has no adversary number. | M | FRBP 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 (verified 2026-10-14). |
| ALMB-MOT-003 | The document is legible. | M | FRBP 9004(a), same URL. |
| ALMB-MOT-004 | Every paper shows, in a signature block at the end of the text or elsewhere, the full name of each signer, at least one complete and current mailing address, and at least one current telephone number and/or email address. The filer's name on a signature block with the CM/ECF login is the signature; `/s/` is used. | M | LBR 5005-4(e)-(f) (2024, pp. 36-37). This replaces 2017 LBR 9011-1, which required both telephone and email. |
| ALMB-MOT-005 | A motion for relief from the automatic stay states why relief is requested and attaches the documents that support the movant's interest. | M | LBR 4001-1 (2024, p. 28; the 2017 text, LBR 4001-1(a), was read in detail). Author responsibility in the synthetic sample, which attaches nothing. |
| ALMB-MOT-006 | A certificate of service is filed, stating with specificity who was served and how; it lists the names and addresses of all parties served, states the method for each, and designates the addresses or email addresses used for each method. | M | LBR 9013-1(b) and LBR 9013-3 (2024, pp. 46-47). The template prints the certificate text, an optional signature (`certificate_signature`) and a service list grouped by method (`service: [{method, parties}]`). |
| ALMB-MOT-008 | When a motion is served under a negative-notice rule, the rule's legend is printed "in all capital letters, bolded, and centered on the page under the style of the case". | M | LBR 1017-2(b) (motions to dismiss by a trustee or the Bankruptcy Administrator, 2024 p. 9); LBR 9007-1(c) (filings on the Negative Notice List, p. 43); LBR 4001-1 for chapter 7 stay motions (2017 text 4001-1(b)). The template sets the `notice` frontmatter text that way; the author supplies the wording of the rule invoked. |
| ALMB-MOT-007 | No typography, margin or spacing rule in the local rules. Font, size, margins and double spacing are the template's style choices, matched to the adversary complaint in this court. | C | 2024 and 2017 local rules, full text searched for font, point, margin, spacing: none. Typeface per `docs/FONTS.md` (no face named: Times New Roman, the house standard, rule 6). |

## What the overlay shows

Page map (`usage/OVERLAY-ebury-motion-brief.txt`), ours against filed:

| Ours | Filed | Word overlap | Content |
|---|---|---|---|
| 1 | 1 | 62.8% | caption, legend, title, introduction |
| 2 | 2 | 45.7% | paras 1-3 and the bullets |
| 3 | 3 | 86.7% | paras 4-8 |
| 4 | 4 | 74.7% | paras 9-13, "Section 1112(b)" |
| 5 | 5 | 66.4% | paras 13-22 |
| 6 | 6 | 58.5% | paras 22-30 |
| 7 | 8 | 54.1% | paras 31-37 (filed p.7 is not best match for any page: our p.7 starts at para 31 where filed p.7 starts mid-para 27) |
| 8 | 9 | 74.0% | paras 37-40 |
| 9 | 10 | 90.5% | second 39-41, prayer, signature block |
| 10 | 11 | 74.7% | certificate, mail list |
| 11 | 12 | 59.1% | CM/ECF list |
| 12 | 12 | 33.0% | last four CM/ECF entries |

Same page count (12 vs 12; measured on the earlier EB Garamond render, before fb-595.68). Our body ran about one page shorter (13 pt EB Garamond at a 24 pt pitch sets more words per page than the filed 12 pt Times), and the service list runs one page longer because our entries keep a 12 pt gap and the CM/ECF heading moves to a new page. Left margin and top of the text block coincide on every body page; the legend and title land lower on p.1 because our caption is a box with padding, not the filed two-column text caption.

## Gate 2 review (2026-10-16)

Every page of `OUTPUT-motion-brief.typst.pdf` (12; the earlier EB Garamond render, before fb-595.68) and `OVERLAY-ebury-motion-brief.pdf` (12) was rendered to PNG and viewed; every page of `OUTPUT-motion-brief-2.typst.pdf` (6) was viewed after the template changes. **pages_reviewed=12** (Ebury output; 12 overlay pages and 6 synthetic pages also viewed).

| Page | Finding | Tier | Status |
|---|---|---|---|
| all body | Body was **not double-spaced**: a `set par(leading: single-leading)` for the caption stayed in force for the whole body (pitch about 19.5 pt, not 24 pt). Fixed: body leading restored after the title, block spacing equal to the leading so the pitch is the same between paragraphs. The synthetic sample's earlier "5 pages, double-spaced" note was wrong for the same reason. | 2 | FIXED |
| 4, 5, 6, 7, 9 | Headings were 18 pt and a two-line heading was double-spaced; both exemplars set headings at body size. Fixed: body size, single-spaced, centered bold, case as written (the template no longer upper-cases them; the synthetic sample already writes caps). | 2 | FIXED (docx not updated) |
| 1 | LBR 1017-2 legend could not be expressed. Added `notice`: caps, bold, centered under the caption (ALMB-MOT-008). The filed legend is justified full-width, not centered; the rule says centered. | 1 | FIXED |
| 10-12 | Service list could not be expressed (certificate was one paragraph). Added `certificate_signature` and `service` grouped by method with the method line underlined (ALMB-MOT-006). | 1 | FIXED |
| 2-3 | The template prefixed every non-numbered block with the paragraph indent, which would have put a stray indent before a list. Fixed before the first render: lists are not prefixed; list indent 0.5 in. Bullets checked on pages 2-3. | 2 | FIXED |
| 9 | Signature block: filed has `/s/`, title and ASB number at right and the office address at left; ours stacks office, `/s/` and all lines in the right column (the firm line prints above `/s/`). All LBR 5005-4(f) items present. | 3 | ACCEPTED |
| 1 | Caption: ours is the boxed left column with case number and chapter at right; filed is unboxed text with CHAPTER 11 opposite the debtor and CASE NO. opposite "DEBTOR."; the second exemplar (Wheat) uses the `)` column caption. Each filer differs; ours carries every FRBP 9004(b) element. | 3 | ACCEPTED |
| 1 | Title: filed is bold underlined; ours bold caps, not underlined. | 3 | ACCEPTED |
| all body | Numbered paragraphs: filed puts the number at 0.5 in and text at 1 in (tab); ours number at 0.5 in with a word space. | 3 | ACCEPTED |
| 10 | Certificate text double-spaced (filed single). | 3 | ACCEPTED |
| all | Footer "-N-" centered; filed has a right-aligned bare number. Neither is a rule. | 3 | ACCEPTED |

### Tier 2 against the second exemplar (Wheat, U.S. Attorney)

- Matches: letter, double-spaced body, centered bold headings at body size, first-line-indented paragraphs, `s/` signature with address/telephone/email per signer, certificate of service on its own page stating method and listing non-CM/ECF parties with addresses.
- Differences, OPEN: Wheat numbers its headings with Roman numerals ("I. STATEMENT OF THE CASE") and uses no numbered paragraphs (a brief, not a motion); the template supports both (`#` headings as written, unnumbered paragraphs), so this is author content. Wheat's signature block carries two signers and "By:"; the template takes one signer plus free lines (a second signer can be written into `lines`, but not with its own `/s/`). OPEN, tier 2: multi-signer blocks.
- Wheat's adversary caption (plaintiff v. defendants, ADV. NO.) is outside this doc type; see `../adversary-complaint/`.

## Template changes in this pass

- Body leading restored to double spacing after the single-spaced caption and title (defect fix).
- Headings at body size, single-spaced, not upper-cased.
- Optional `notice` (negative-notice legend), `certificate_signature`, `service` (list of `{method, parties}`), `signature.closing` (empty string omits "Respectfully submitted,"), `signature.firm` optional.
- Bulleted lists render without the paragraph indent prefix; block quotations single-spaced.

## Gaps

- **docx** lags the typst changes above and cannot be rendered to pages (no `soffice`). See Engines.
- **No gate run.** This court has no `checks.yaml`; `tools/check.sh` and `tools/check-selftest.sh` were not run.
- **Overlay PDF page size.** `tools/overlay.sh` writes pages at 241 x 312 pt, not letter size; viewing needs `pdftoppm -scale-to`. Tool issue, not changed here.
- **Exemplar provenance.** The retrieval URLs of both exemplars were not recorded (`usage/SOURCE.md`).
- **Multi-signer signature blocks** (tier 2, from Wheat): not expressible with a separate `/s/` per signer.
