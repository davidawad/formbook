# Bankr. N.D. Ga.: adversary complaint (`adversary-complaint`)

Doc type: **adversary complaint** in an adversary proceeding in the United States Bankruptcy Court for the Northern District of Georgia (`ganb`). Folder: `courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, 1 filer: `usage/SAMPLE-ganb-adversary-complaint-gatetruckinfletcher2505046.pdf` (see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-ganb-adversary-complaint-fletcher2505046.md`, the whole filing (caption, 38 numbered paragraphs, prayer, signature, certificate) |
| render | ok: `usage/OUTPUT-ganb-adversary-complaint-fletcher2505046.typst.pdf`, 6 pages, typst 0.15.0, vendored EB Garamond only (embedded), no warnings |
| overlay | ok: `usage/OVERLAY-fletcher-25-05046.pdf` and `OVERLAY-fletcher-25-05046.txt`, made 2026-10-14 against the RECAP copy of the exemplar (the exemplar PDF is not committed; see gaps 11) |
| pages reviewed | 6 of 6 re-rendered and viewed 2026-10-14 (fonts pass; the face did not change, see Typeface below) |

## Typeface

| Item | Result |
|---|---|
| Face required by the rules | None named. The BLR 5005-1 text read (search excerpts of courtrules.net) names no typeface; FRBP 9004(a) says "clearly legible" with no face. Subsection (f) of BLR 5005-1 (caption style) was not seen (see gaps 1). |
| Substitute (`docs/FONTS.md`) | None needed: the "No face named" row, so **EB Garamond** stays. |
| Fit | n/a (the rules name no face to be metric-compatible with) |
| Embedded (`pdffonts`) | `EBGaramond-Regular`, `EBGaramond-Bold` (both embedded, CID Type 0C) |

Not a `court.json` status; nothing here sets `status`. The court-root `README.md` and `court.json` are not touched.

## File names

The brief asked for `usage/<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. The shared tools write and read `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`, so the sample uses those names. `<id>` is `fletcher-25-05046`.

## Governing rules

Verification date for everything below: 2026-10-14.

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| GANB-RULE-001 | Fed. R. Bankr. P. 7010 (as amended eff. Dec. 1, 2024; https://www.law.cornell.edu/rules/frbp/rule_7010) | "Fed. R. Civ. P. 10 applies in an adversary proceeding — except that a pleading's caption must substantially conform to the appropriate version of Form 416." | `court_title`, `caption`, `title`. The caption follows the Form 416 layout (court, parties, case and adversary numbers, chapter, title). The exact Form 416 text was not fetched (see gaps). |
| GANB-RULE-002 | Fed. R. Civ. P. 10(b) (applied by Rule 7010; text not fetched in this session) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Allegations are numbered 1, 2, … by the template. Paragraphs that begin "WHEREFORE" are not numbered. |
| GANB-RULE-003 | Fed. R. Bankr. P. 7008(a) (as amended eff. Dec. 1, 2024; https://www.law.cornell.edu/rules/frbp/rule_7008) | A complaint "must state whether the pleader does or does not consent" to entry of final orders or judgment by the bankruptcy court. | Author content (the sample's paragraph 4). The template does not check it. |
| GANB-RULE-004 | Fed. R. Bankr. P. 9004(a)-(b) (as amended eff. Dec. 1, 2024; https://www.law.cornell.edu/rules/frbp/rule_9004) | (a) "clearly legible". (b) caption: court name; case title; case number and adversary-proceeding number; a brief designation of the document. | `caption` (case number and adversary number in the right column), `title`. |
| GANB-FORM-001 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*: courtrules.net text, see gaps 1) | Paper 8½ × 11 inch; first page leaves a clear space 2 in × 2 in in the upper right corner for the filing stamp. | `page1-caption-gap` (0.4 in after the court title, so the caption starts below 2 in). Measured on the render: nothing enters the stamp area. |
| GANB-FORM-003 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*) | Adversary and contested-matter papers: "at least one and one-half spaces between lines". | `body-leading = 1.075em`: 1.5 × the 1.15em single pitch. Measured: 22.4 pt pitch at 13 pt. |
| GANB-FORM-002 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*, no font named); FRBP 9004(a) | Legible, proportional serif. | `font-family = "EB Garamond"`, `type-size = 13pt` (see gaps). |
| GANB-FORM-005 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*) | "All pages must be numbered consecutively at the bottom center of the page." | `footer`: page number, centered, 11 pt. |
| GANB-SIG-001 | Bankr. N.D. Ga. BLR 5005-1 (*secondary*) | Attorney name, complete address, telephone, e-mail and Georgia bar number on every paper an attorney files. | `signature.lines`. |
| GANB-SIG-002 | Fed. R. Civ. P. 5(d)(1)(B) (text from https://www.law.cornell.edu/rules/frcp/rule_5, fetched 2026-10-14); the bankruptcy service rule, Fed. R. Bankr. P. 7005, not fetched | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." Otherwise a certificate must be filed. | Optional `certificate:` (markdown). The sample uses it because the exemplar has one (it also says service on the debtor was by first-class mail, which needs one). |
| GANB-PRAY-001 | Convention (the exemplar); not a rule | Prayer items lettered (a), (b), … | Markdown list after the WHEREFORE paragraph; the template letters the items. |

Not used, and why:
- Fed. R. Bankr. P. 7008(a) core/non-core statement: the rule as amended in 2016 requires only the consent statement (Cornell committee note, fetched 2026-10-14).
- The adversary proceeding cover sheet, the summons and the Civil Cover Sheet: separate forms, not generated.
- Fed. R. Bankr. P. 7004 (service of summons): cited in the exemplar's certificate text only.

## Layout

- Letter paper, 1 inch margins, page number bottom center on every page.
- Page 1: court title (centered, bold capitals), 0.4 in gap, caption (")" column, parties at left, case and adversary numbers at right), rule, title (centered, bold capitals), then the unnumbered lead-in paragraph from `lead_in:`.
- Body: 1.5 spacing, first-line indent ½ in. Numbered paragraphs: the number, a tab, then the text. Lettered prayer items: "(a)", "(b)", …, each its own paragraph.
- After the prayer: the date line (`signature.dated`), then the counsel block at the right half of the page.
- Certificate of service (optional): centered heading, text, counsel block.
- No count headings and no table of contents: the exemplar has neither.

## Markdown contract (for samples)

Frontmatter: `court_title`, `caption` (rows `[left, right]`, `["", ""]` for a blank row), `title` (list of lines), `lead_in` (unnumbered opening paragraph), `signature` (`dated`, `lines`), `certificate` (optional markdown). Same meaning as in the motion template (see `../motion-brief/README.md`).

Body:
- Blank-line-separated paragraphs. Each one is numbered by the template: **do not type the number.**
- A paragraph that begins with `WHEREFORE` is unnumbered (the prayer lead-in).
- A markdown list (`1. …`, `2. …`) becomes lettered items (a), (b), …; one item per line.
- `#` heading: centered, bold capitals (not used by this sample; the template supports it).
- Case names and signals in `*italics*`. Not supported: tables, raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district/adversary-complaint usage/INPUT-ganb-adversary-complaint-fletcher2505046.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district/adversary-complaint fletcher-25-05046
```

- `usage/OVERLAY-fletcher-25-05046.pdf`: red = ours, blue = filed, black = both. Page pairing (from `OVERLAY-fletcher-25-05046.txt`): ours p.1 ↔ filed p.1 (91.6%), p.2 ↔ p.2 (87.6%), p.3 ↔ p.3 (67.3%), p.4 ↔ p.4 (62.2%), p.5 ↔ p.5 (50.5%), p.6 ↔ p.6 (88.1%). Both are 6 pages. The overlay is a diagnostic, not a score.

## Defects found and fixed (Gate 2 record)

1. First render: all 38 numbered paragraphs ran together as one paragraph. Cause: the chunks were concatenated without a paragraph break. Fixed by a `parbreak()` before each chunk and each prayer item.
2. The filed text has "⁋" (U+204B) in paragraph 20. The vendored EB Garamond does not contain it, so it printed as a placeholder glyph. The sample uses "¶" (U+00B6), which the font has. This is a transcription change; the paragraph reads the same.
3. Typst's `#h(...)(` parse error on the lettered prayer label. Fixed by building the label as a string.

## Visual review (all 6 pages rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption, rule, title, lead-in, paragraphs 1-4 | OK. Numbers at ½ in, text after a tab; caption clear of the stamp area. |
| 2 | Paragraphs 5-16 | OK. Each paragraph separate. |
| 3 | Paragraphs 17-27 | OK. ¶ 1, 2 in paragraph 20 renders correctly after the glyph change. |
| 4 | Paragraphs 28-37 | OK. The "§" and "(a)(2)(A)" cites set cleanly. |
| 5 | Paragraph 38, WHEREFORE, prayer (a)-(c), date, counsel block | OK. Prayer items lettered, each on its own line. |
| 6 | Certificate of service, counsel block | OK. |

Reviewed pages: 6 of 6.

## Engines

| Engine | Result here | Output |
|---|---|---|
| typst (primary, `typst/`) | unchanged by this work | `usage/OUTPUT-ganb-adversary-complaint-fletcher2505046.typst.pdf` |
| docx (`docx/`) | `.docx` built and XML-checked; `.docx.pdf` **not produced** (no LibreOffice in this box), so no page was rendered or reviewed | `usage/OUTPUT-ganb-adversary-complaint-fletcher2505046.docx` |

`docx/make-reference.sh` builds `docx/reference.docx` from pandoc's default reference: EB Garamond 13 pt; body text 1.5 spaced (exact 22.4 pt, the typst pitch); half-inch first-line indent; footnotes 11 pt; letter page, 1-inch margins; centered 11 pt page number. `docx/ganb-adversary-complaint.lua` builds the first page (caption as a borderless table: 3.4 in, 0.3 in ")" column, the rest; 0.4 in gap for the filing stamp; rule; title), numbers the allegations and letters the prayer as typed text (number at ½ in, text at 0.8 in), and builds the signature and certificate blocks in the right half of the page, as the typst template does.

- **Matches (by construction, from the typst parameters):** font, size, line pitch, margins, indent, caption columns, stamp gap, page-number footer, certificate placement.
- **Differs:** the docx has not been paginated or viewed, so page count and line breaks are unknown. Word and LibreOffice may break lines differently. The title is set with the All Caps property, so "523(a)(2)(A)" stays in the source text; the typst template's `upper()` turns it into "523(A)(2)(A)" (a typst-side defect, not changed here).
- **docx BLOCKED** (Gate 0 and Gate 1 are measured on the `.docx.pdf`; `docs/DOCX.md`):
  - BLOCKED: GANB-FORM-001: the `.docx.pdf` cannot be made in this box (conda-forge has no `libreoffice`, and there is no root for a system install), so the stamp-area measurement cannot run.
  - BLOCKED: GANB-FORM-002: as above (font and size of the PDF).
  - BLOCKED: GANB-FORM-003: as above (line pitch of the PDF).
  - BLOCKED: GANB-FORM-005: as above (page-number footer on the PDF).
  - BLOCKED: GANB-SIG-001: as above (counsel block on the PDF).
  - BLOCKED: GANB-SIG-002: as above (certificate on the PDF).
  - BLOCKED: GANB-PRAY-001: as above (lettered prayer on the PDF).
  - BLOCKED: GANB-RULE-001: as above (caption layout on the PDF).
  - BLOCKED: GANB-RULE-004: as above (caption and title on the PDF).

## Known gaps and open choices

1. **Local rule text is secondary.** BLR 5005-1 (format) is read from a search-result excerpt of courtrules.net; the fetch tool and curl return HTTP 403 for that site, and the court's 2019 PDF returns an error page. Official text not checked. **Needs a check of the current BLR 5005-1 against the court's PDF before this template is called complete.**
2. **Form 416 text not fetched.** The caption layout follows the Form 416 family as described by secondary sources (the adversary-proceeding caption carries "Adversary Proceeding No."). The official Form 416 PDF was not retrieved. Needs a check against the uscourts.gov form.
3. **Rule 10(b) text not fetched.** Numbered paragraphs follow Fed. R. Civ. P. 10(b) as applied by Rule 7010; the Civil Rule text itself was not fetched in this session.
4. **Font.** EB Garamond at 13 pt, the same choice as the motion template.
5. **Tier 2: one exemplar only.** EVAL-LOOP asks for two or three filers. The CourtListener RECAP search (`court=ganb`, "adversary proceeding" complaint) also surfaced the 2016 Lafayette complaint (16-05224), the 2010 Shaw complaint (10-06025) and the 2025 Aliera complaint (25-05098). Only the Fletcher complaint was saved, as the most recent text-based one.
6. **Exemplar inconsistencies, kept as filed.** Paragraph 1 says "Chapter 12" while the caption says "CHAPTER 7 BANKRUPTCY"; the certificate of service says "Amended Complaint" on a Doc 1 filing; the adversary number is blank in the caption ("ADVERSARY CASE NO. ______") though the ECF header shows 25-05046. The transcription keeps them.
7. **Certificate page does not repeat the caption.** Not required by any rule I could read; the exemplar does not repeat it either.
8. **Not generated:** the adversary cover sheet, the summons, the civil cover sheet. Separate filings.
9. **Filing stamp area.** Kept for paper filing (BLR 5005-1, secondary); ECF copies do not need it.
10. **Local practice not checked:** judge-specific standing orders, and the 2024 amendments to Rules 7008 and 7010 (restyling only, per the committee notes).
11. **Exemplar PDF not in the repo.** Only `usage/SOURCE.md` is committed. For the 2026-10-14 overlay the RECAP copy was fetched from the URL in `SOURCE.md` into a scratch directory and passed to `tools/overlay.sh` as its third argument. Committing the PDF is a repo decision, not made here.
12. **BLR 5005-1 subsection (f) and the 2019 PDF not retrieved (2026-10-14).** courtrules.net returns HTTP 403; the court's 2019 local-rules PDF returns an 855-byte error page. The font conclusion rests on the excerpts, which name no face; re-check subsection (f) against the court's PDF.
