# N.D. W. Va. Bankruptcy Court (wvnb): adversary complaint

Doc type: **adversary complaint** initiating an adversary proceeding (FRBP 7001 et seq.). Court: United States Bankruptcy Court for the Northern District of West Virginia. Folder: `courts/fourth-circuit/west-virginia/federal/bankruptcy-northern-district/adversary-complaint/`.

**BLOCKED: no exemplar.** No filed complaint from this court was found after the searches listed in `exemplars/SOURCE.md`. The template is built from the rules below, and the sample is fictional. The overlay cannot run without an exemplar PDF.

Status: exemplar=no, render=ok (typst, no warnings), overlay=fail (`tools/overlay.sh` exits 1: "no exemplar pdf"), pages reviewed 5 of 5 (rendered at 60 dpi and viewed). Nothing here sets `status` in `court.json`.

## Governing rules

Dates: rules text fetched and read 2026-10-14. "Local rules" means the N.D. W. Va. Local Bankruptcy Rules text below, which is the November 21, 2003 version (the only copy the court publishes that could be retrieved). It may have been amended since, and no current text was found.

| ID | Rule | Requirement | Source (URL) | Where it lives in the template |
|---|---|---|---|---|
| WVNB-ADV-001 | FRBP 7001 (scope), LBR 7001-1 | Adversary proceedings are governed by Parts VII and IX of the Bankruptcy Rules; the Federal Rules of Civil Procedure apply unless modified. | https://www.wvnb.uscourts.gov/sites/wvnb/files/local_rules/Local%20Rules.pdf (LBR 7001-1, p. 50) | Whole template; FRCP 10 caption and numbered paragraphs. FRBP 7001 text itself was not fetched. |
| WVNB-ADV-002 | FRBP 7010, FRCP 10(a) | The caption has the court name, a title, a file number and a designation; the caption substantially conforms to the Form 416 series. | https://www.law.cornell.edu/rules/frbp/rule_7010 ; https://www.law.cornell.edu/rules/frcp/rule_10 (both fetched 2026-10-14; FRBP 7010 amended eff. Dec. 1, 2024) | `court-caption()`: court lines, caption table, complaint title. |
| WVNB-ADV-003 | FRBP 9004(b) | A document's caption states the court's name, the case title, the case number and adversary number when appropriate, and a brief designation of the document. | https://www.law.cornell.edu/rules/frbp/rule_9004 (fetched 2026-10-14; eff. Dec. 1, 2024) | Caption: "Case No.", "Adv. Pro. No.", title. |
| WVNB-ADV-004 | FRCP 10(b) (via FRBP 7001) | Claims are stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | https://www.law.cornell.edu/rules/frcp/rule_10 (fetched 2026-10-14) | `enum` numbering: one counter across the whole complaint, so counts continue the numbering. |
| WVNB-ADV-005 | FRBP 7008(a) | The complaint states whether the pleader consents to entry of final orders or judgment by the bankruptcy court. | https://www.law.cornell.edu/rules/frbp/rule_7008 (fetched 2026-10-14) | Sample ¶ 8 (sample text, not a template control). |
| WVNB-ADV-006 | LBR 7003-1 | The complaint is accompanied by a fully completed Bankruptcy Cover Sheet (Form BC 104). | local rules p. 51 (2003 text) | **Not generated.** Known gap; see below. |
| WVNB-ADV-007 | LBR 9004-2(a) | The style of an adversary pleading complies with the official caption form (the 2003 text says "Official Form 16C"). | local rules p. 57 (2003 text) | Caption layout (see the form-number question below). |
| WVNB-FMT-001 | LBR 9004-1 (search-result excerpt only, not verified) | Font not less than 10 pt; line spacing not more than double and not less than single. | https://www.courtrules.net/courts/federal/bankruptcy-northern-district-west-virginia/local-rules/7166 (HTTP 403; excerpt from a search result) | `type-size = 12pt`; `body-leading = 0.85em` (about 1.5 spacing). **Unverified; check the court's current text.** |
| WVNB-FMT-002 | Paper, margins, page numbers | Not stated in the LBR text read. | none | 8½ × 11 in, 1 in margins, page number footer: convention, not a rule. |

## Form-number question (open)

The 2003 LBR 9004-2(a) cites "Official Form 16C". FRBP 7010 (2024) refers to the Form 416 series. The search index showed Form 416D as the adversary caption form, but that result could not be confirmed on uscourts.gov (fetch returned 404). The template follows the elements that FRBP 9004(b) and FRCP 10(a) require, which were verified, rather than any one form layout. A clerk who expects an exact Form 416 layout would need that form checked.

## Fonts and layout (what is decided, and why)

- EB Garamond from `fonts/eb-garamond/` (vendored; the only font used). Other typefaces are not available to the build.
- 12 pt body, 10 pt footer. Numbered paragraphs use a 0.5 in first-line indent with a hanging number.
- Caption: a two-column table. The left cell has a right rule and a bottom rule; the right cell has the chapter, case number, judge and adversary number. No forced line breaks: the court and party lines are separate content.
- Signature block: "Respectfully submitted", the signer name in bold with "s/", and the lines from frontmatter.

## What the sample shows

`samples/INPUT-example-adversary-complaint.md` is fictional: a Chapter 7 trustee suing a transferee and an insider under 11 U.S.C. §§ 544(b), 548, 550 and 502(d). It has 34 numbered paragraphs, three counts, a prayer and a signature. It exercises the caption (with the "In re" debtor block), part headings, count headings, subheadings, the continuous numbering, and the prayer.

Render: `sh tools/render.sh <this-dir> samples/INPUT-example-adversary-complaint.md` produced `samples/OUTPUT-example-adversary-complaint.pdf`, 5 pages, embedded fonts EBGaramond-Regular and EBGaramond-Bold only, no typst warnings.

The file names differ from the brief's naming on purpose. `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name and writes `OVERLAY-<id>.pdf` and `.txt`, so these are the names used. The sample is `samples/<id>.md` as specified.

## Page review (Gate 2 record, 60 dpi, every page viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block, court title, caption, complaint title, Parts and ¶¶ 1–2 | OK after fixes: court lines no longer overprint; right caption column widened so "Adv. Pro. No." does not wrap; counsel block no longer indented. |
| 2 | ¶¶ 3–12 under PARTIES, JURISDICTION AND VENUE, FACTS | OK. Paragraph spacing correct (an earlier build had none, so paragraphs overprinted). |
| 3 | ¶¶ 13–25, Count I heading | OK. The Count I heading is two lines and centered. |
| 4 | ¶¶ 26–34, Count II, Count III, PRAYER | OK. The prayer items are indented first lines, not hanging indents. Accepted: minor. |
| 5 | Prayer ends, date, signature | OK. Page 1 ends with white space because the PARTIES heading and ¶ 3 keep together (sticky heading); accepted. |

## Known gaps

- **Cover sheet (Form BC 104, LBR 7003-1)** is not generated. A filer must attach it.
- **Summons** is issued by the clerk (LBR 7004-2); not generated.
- **Form number** of the caption (see above) is unresolved.
- **Local rule text** is from 2003 and the 9004-1 excerpt is unverified.
- **Page limits and paper rules** for complaints are not checked by the template; no rule found.
- Authorities in the sample (28 U.S.C. §§ 157(b)(2)(F), (H); 11 U.S.C. §§ 544, 548, 550, 502(d)) are statute cites written from memory, not fetched.
- No exemplar, so no tier-2 comparison with a filed complaint was possible.
