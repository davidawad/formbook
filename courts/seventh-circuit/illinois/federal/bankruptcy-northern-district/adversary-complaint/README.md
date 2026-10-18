# Adversary complaint: U.S. Bankruptcy Court, N.D. Illinois (`ilnb`)

Doc type `adversary-complaint` (FRBP 7001 adversary proceeding, commenced by complaint). Folder of the court: [`bankruptcy-northern-district`](../README.md).

## Status

- Exemplar: yes, one filer (RMW Acquisition Company, LLC, Adv. 13-01437, filed 2013-12-27, 14 pp.). See `usage/SOURCE.md`.
- Render: ok (`sh tools/render.sh <this dir> usage/INPUT-ilnb-adversary-complaint-rmwcomplaint.md`, 13 pages, no typst warnings, EB Garamond only).
- Overlay: ok (`sh tools/overlay.sh <this dir> rmw-complaint`, `usage/OVERLAY-rmw-complaint.pdf` and `.txt`).
- Pages reviewed: 13 of 13 (every page of `usage/OUTPUT-ilnb-adversary-complaint-rmwcomplaint.typst.pdf` rendered at 60 dpi and looked at, after the last template change).
- Second filer: not collected. A candidate is listed in `usage/SOURCE.md` but was not downloaded.

## Governing rules

Verified 2026-10-14 against the primary text. Rule text quoted from the sources; the court's local rules are the version "As amended, Effective September 1, 2024" (the newest version found; check ilnb.uscourts.gov before filing).

| ID | Source | Requirement | How the template meets it |
|---|---|---|---|
| ILNB-CAP-001 | Fed. R. Bankr. P. 7010 (<https://www.law.cornell.edu/rules/frbp/rule_7010>) and Rule 9004(b) (<https://www.law.cornell.edu/rules/frbp/rule_9004>) | Rule 7010: Fed. R. Civ. P. 10 applies "except that a pleading's caption must substantially conform to the appropriate version of Form 416." Rule 9004(b): a caption sets forth the court's name, the case's title, the case number and adversary-proceeding number, and a brief designation of the document. | Court name, title block, debtor and adversary parties, case number, adversary number, descriptive title. |
| ILNB-CAP-002 | N.D. Ill. Bankr. L.R. 5005-2(C)(5) (<https://www.ilnb.uscourts.gov/sites/ilnb/files/Local-Rules-9-1-2024.pdf>, p. 20) | "The first page must contain at the top the case caption with the number of the case or proceeding, the chapter of the bankruptcy case, the name of the assigned judge, and a descriptive title." | Chapter, case number, judge (`caption.judge`), title on page 1. |
| ILNB-CAP-003 | LBR 5005-1(C) (same PDF, p. 18) | "The caption of each document must identify the division of the court to which the case is assigned." | "EASTERN DIVISION" line from `division` in the frontmatter. The RMW exemplar omits it; the rule does not. |
| ILNB-FORM-002 | LBR 5005-2(C)(2) | "Typed documents must be double-spaced, and the font must be at least 12 points." | EB Garamond 13 pt (see Decisions). |
| ILNB-FORM-003 | LBR 5005-2(C)(2) | Double spacing. | 24.0 pt baseline pitch at 13 pt, measured on page 2 of the render. |
| ILNB-FORM-004 | LBR 5005-2(C)(3) | "Margins (top, bottom, right, and left) must be no less than one inch." | 1 in on all sides. |
| ILNB-FORM-005 | LBR 5005-2(C)(4) | "Pages must be consecutively numbered." | Arabic page number, bottom centre, from page 1. |
| ILNB-FORM-006 | LBR 5005-2(C)(11) | Paper: "on 8½x11-inch white paper". | US Letter. |
| ILNB-BODY-001 | Fed. R. Civ. P. 10(b) via Rule 7010; LBR 5005-2(A) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | Each blank-line-separated paragraph of the markdown is numbered. Headings, the prayer and the signature are not. |
| ILNB-SIG-001 | LBR 5005-2(C)(6) | "The last page must contain the name, mailing address, email address, and telephone number of the attorney signing the document." | `signature.counsel` block after the prayer. |
| ILNB-SIG-002 | LBR 5005-2(C)(9) | Electronic signature per the Administrative Procedures. | "s/ Name" line from `signature.signer`. |
| ILNB-FILE-001 | LBR 7003-1 (same PDF, p. 26) | "A plaintiff in an adversary proceeding must file an Adversary Proceeding Cover Sheet, Official Form B 1040, with the adversary complaint." | Not generated (separate form). See Known gaps. |
| ILNB-HEAD-001 | Layout choice, not a rule | (none) | Level-1 headings centred bold capitals; level-2 bold; level-3 bold italic. Never the last line of a page. |

## What the overlay shows

`usage/OVERLAY-rmw-complaint.pdf`: red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by shared words (`usage/OVERLAY-rmw-complaint.txt`):

```
ours p.1  filed p.1  word-overlap 72.1%
ours p.2  filed p.2  word-overlap 81.4%
ours p.3  filed p.3  word-overlap 81.7%
ours p.4  filed p.4  word-overlap 86.2%
ours p.5  filed p.5  word-overlap 71.5%
ours p.6  filed p.6  word-overlap 66.3%
ours p.7  filed p.7  word-overlap 56.7%
ours p.8  filed p.9  word-overlap 43.9%
ours p.9  filed p.10  word-overlap 56.4%
ours p.10  filed p.11  word-overlap 73.6%
ours p.11  filed p.12  word-overlap 87.5%
ours p.12  filed p.13  word-overlap 92.3%
ours p.13  filed p.14  word-overlap 85.9%
```

Pages 1 to 7 pair one to one. From page 8 the pairing is one page later: our page 8 carries the end of paragraph 26 and paragraphs 27 to 29, and the filed copy's page breaks fall elsewhere in that stretch. Every paragraph of the exemplar is in the sample, so the difference is pagination. The overlay is a diagnostic, not a score.

## Decisions (left open by the rules, or interpreted)

- **Font: EB Garamond, 13 pt.** The rule requires at least 12 pt. EB Garamond is the only vendored face, and it sets smaller than Times at the same point size; 13 pt is the size the cand complaint and motion templates use for the same face. This is a style choice, not a rule.
- **Footnotes and the caption are single spaced.** LBR 5005-2(C)(2) says "typed documents must be double-spaced" with no exemption. The filed exemplar single-spaces its footnotes and the caption, and the template does the same. **This is a literal-reading question for David**: if footnotes must be double spaced, change `show footnote.entry` in `typst/ilnb-adversary-complaint.typ`.
- **Count statement is numbered.** The RMW exemplar leaves its count statement ("I. RMW requests the entry of ...") unnumbered and numbers the next paragraph 34. The template numbers every body paragraph, so the count statement is ¶ 34 here and the paragraphs after it run one higher than the exemplar (exemplar ¶ 34 "Plaintiff restates" is ¶ 35 here). Accepted as a tier-2 difference.
- **Division line.** Printed from the frontmatter because LBR 5005-1(C) requires it. The RMW filed copy does not show one.
- **No ECF header.** The filed copy carries the court's ECF header ("Case 13-01437 Doc 1 Filed ..."). The filer does not generate it, so the template does not.
- **Prayer as frontmatter.** The WHEREFORE paragraph and its lettered items are frontmatter fields, not body text, so the paragraph numbering stays clean. The last prayer item is sticky so the signature block never stands alone on a page.

## Known gaps

- Adversary Proceeding Cover Sheet (Official Form B 1040, LBR 7003-1) and summons (Official Form 287 or equivalent) are separate documents and are not generated.
- Exhibits are referred to, not produced. The RMW complaint attaches Exhibits A through U; this sample does not include them.
- The RMW complaint's count is written as one paragraph (see Decisions); a multi-count complaint's count headings are typed by the author in the body.
- No second filer: `usage/` holds one filing. Tier 2 (2 or 3 exemplars from different filers) is not met for this doc type.
- The sample transcribes the full 14-page exemplar, including its footnotes. Typos in the exemplar (for example "as define below", "negations") are kept, not corrected.

## Searches tried

- CourtListener search API, `type=r` (RECAP) and `type=rd` (RECAP documents), court `ilnb`, for complaints with `Complaint` in the description and `filepath_local` set. Hits with archived PDFs: 15-00876 LB Steel (7 pp.), 19-00902 iPROMOTEu.com v. Steinberg (10 pp.), 19-01029 Amos Financial (4 pp.), 09-00848 Indoor Football (6 pp.), 13-01437 RMW Acquisition (14 pp., used).
- Rate limit 5 requests/minute on the API; searches were paced.

## Review log

- Render 1: paragraphs ran together on one line; page 1 left mostly blank above a sticky heading. Fixed by making each numbered paragraph its own block and making headings sticky blocks rather than wrapping them with the whole paragraph.
- Render 2: body leading gave a 24.8 pt pitch; set to 0.54em (24.0 pt).
- Render 3: the signature block stood alone on page 13; the last prayer item is now sticky with the signature. The firm name wrapped; the signature column is 2.5 in.
- Render 4: headings were larger than body text (typst default heading size); headings now set at body size.
- Render 5: the first line of each numbered paragraph sat 17 pt below the previous paragraph instead of 24 pt (paragraph spacing was zero). Paragraph blocks now have `below: body-leading`.
- Render 6: the paragraph numbers lost their 0.5 in first-line indent. A block-first paragraph did not take `first-line-indent` even with `all: true` (checked in a scratch compile, since removed). The indent and number are now inline text at the start of each paragraph block.
- Final pass: all 13 pages of the final render viewed; body pitch 24 pt within and between paragraphs (measured on pages 2, 3 and 5); no open defects beyond the Decisions above.

## Engines

DOCX (`docx/`: `build-reference.sh` builds `reference.docx` from pandoc's default; `ilnb.lua` lays out the cover, caption, numbered paragraphs, prayer and signature). Built with `sh tools/render.sh --engine docx <this dir> usage/INPUT-ilnb-adversary-complaint-rmwcomplaint.md`.

- **Matches the typst form (in the styles and filter; not checked against a rendered page):** EB Garamond 13 pt; exact 24 pt line pitch; 0.5 in first-line indent; US Letter with 1 in margins; centred 12 pt PAGE number in the footer; level-1 headings centred bold capitals, level-2 bold, level-3 bold italic; numbered body paragraphs; lettered prayer items.
- **Differs or unverified:** the caption is a two-column table whose party column is ruled on the right and bottom, with widths taken from the typst layout (3.4 in, 0.3 in gutter), but its borders are not verified against the typst layout. The signature block stacks the "Dated" and city lines above the signature column (typst sets them side by side). Footnotes and body text are pandoc's own footnote and paragraph handling. The docx `.docx` was validated (zip and XML well-formed; every `pStyle` defined; one footer relation resolves); it was not opened in Word.
- **BLOCKED:** `docx.pdf` (`usage/OUTPUT-rmw-complaint.docx.pdf`) is not produced because `soffice` (LibreOffice) is not installed on this box, so `tools/render.sh --engine docx` stops after writing `usage/OUTPUT-ilnb-adversary-complaint-rmwcomplaint.docx`. Pages reviewed: 0. The docx gates (`tools/check.sh --engine docx`) cannot run. Pagination in Word may differ from LibreOffice.
