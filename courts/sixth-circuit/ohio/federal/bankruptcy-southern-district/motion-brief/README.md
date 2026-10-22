# ohsb: motion with memorandum in support

Doc type: **motion with memorandum in support** (FRBP 9013) in the United States Bankruptcy Court for the Southern District of Ohio (`ohsb`).
Folder: `courts/sixth-circuit/ohio/federal/bankruptcy-southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, the U.S. Trustee; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (full transcription of the motion and memorandum, all ten footnotes and the certificate of service; the exemplar's mailing matrix is not transcribed) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, 7 pages each, the same lines and pages (XENG-001..003 gated in `eval.yaml`), vendored Times New Roman only, no warnings (2026-10-22) |
| typeface | Face required: none. The LBRs name no face for filings (S.D. Ohio LBR 9004-1(b): "at least 10-12 font size"). Template face: Times New Roman (vendored, the house face, also the exemplar's), typst and docx alike (the docx named EB Garamond until fb-595.68.30). |
| overlay | ok: `usage/OVERLAY-actual-brewing-ust-motion.pdf` and `OVERLAY-actual-brewing-ust-motion.txt` (page map below). Run 2026-10-15 against the exemplar fetched from the CourtListener URL in `usage/SOURCE.md` to `/tmp`; the PDF is not kept in the repo |
| pages reviewed | 7 of 7 on each engine (typst and docx, re-rendered 2026-10-22, every page at 60 dpi and viewed; see the visual review below) |

## Governing rules

Each rule was read from its primary source. The local rules are the S.D. Ohio Local Bankruptcy Rules as amended effective October 1, 2020 (PDF on the court's site: https://www.ohsb.uscourts.gov/sites/ohsb/files/local_rules/Final%20Version%20of%20Amended%20LBRs_Effective%20Oct%201%202020.pdf), read 2026-10-14. A search on 2026-10-14 found no later bankruptcy LBR amendment on the court's site (the amendment orders found were dated 2009, 2011, 2016 and 2020). That is not proof there is none, so confirm the current text with the clerk before treating this as final.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013, read 2026-10-14) | (a) A request for an order is made by written motion unless an exception applies. (b) The motion must state its grounds with particularity and set forth the relief requested; it must be served on the parties named in the rule. | the motion paragraph and the memorandum (author content); the template does not check grounds or relief |
| Fed. R. Bankr. P. 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004, read 2026-10-14) | Legible; a caption with the court's name, the case title, the case number, and a brief designation of the document. | `court-title`, `caption`, `brief_title` |
| S.D. Ohio LBR 9004-1(b) | 8½ × 11 bond paper; double spaced; side margins; top margin of at least one inch; typed print at least 10 to 12 point. | `margin` = 1 in on all sides; `type-size` = 12 pt; `pitch-body` = 24 pt line boxes (double spacing at 12 pt) |
| S.D. Ohio LBR 9004-2 | Caption with the debtor's name, case number, chapter, adversary number (if any) and the judge's name; the nature of the paper and the specific relief requested; a statement of the relationship to prior filings. | caption right column (case number, chapter, judge); title (`brief_title`); the relief is in the motion paragraph |
| S.D. Ohio LBR 9013-1(a)(1)(A) | A motion is accompanied by a memorandum in support. | the memorandum is part of the document (the exemplar's form) |
| S.D. Ohio LBR 9013-1(a)(1)(B) and LBR 9013-3 | A certificate of service, except for ex parte relief or a motion the clerk notices; the parties to be served are the debtor, the debtor's attorney, the trustee, the U.S. Trustee, and parties directly affected or requesting notice. | `CERTIFICATE OF SERVICE` in the sample; the template does not check the list of parties |
| S.D. Ohio LBR 9013-1(a)(1)(C) and (a)(2) | A 21-day notice substantially in the form of the rule's sample (or Official Form 420A), except where the Federal Rules, General Order #12, another local rule or a court order provides otherwise. | `{{NOTICE_21_DAY}}` directive, filled from `notice:` frontmatter (`movant`, `relief`, `clerk_address`, `movant_address`, `others`). **Not used in the sample** (see gaps) |
| S.D. Ohio LBR 9013-2(a) | Briefs and memoranda are limited to 20 pages without leave. | not checked (the sample body is 7 pages; no page counter exists) |

## Layout

The cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line a box of its pitch (24 pt body, 14 pt single lines), the spaces between blocks explicit, first-fit line breaking with no kerning, ligatures or hyphenation, so the docx breaks every line and page where typst does (Gate 4, `params.cross_engine: gate` in `eval.yaml`).

- Court title (three centered bold single lines): UNITED STATES BANKRUPTCY COURT / SOUTHERN DISTRICT OF OHIO / the division.
- Caption, a blank single line below: the debtor on the left (3.4 in), a column of ")" marks (0.3 in), and the case information on the right, 0.15 in in (Case No., Chapter, Judge); one row per single line (docx: a borderless table).
- Title of the paper, bold, centered, single spaced, a blank single line below the caption; a blank double line, then the text.
- Body: paragraphs unnumbered with a 0.5 inch first-line indent; headings at the type size on the body pitch, centered (`MEMORANDUM IN SUPPORT` level 1 in bold capitals, level 2 bold as written), kept with the next block; the numbered list of missing documents with the number half an inch in and the text hanging at 0.9 in; the lettered quotations of 11 U.S.C. § 1112(b)(4) double spaced 0.75 in in, the "***" elisions centered; the certificate's address blocks (hard-broken lines) single spaced, unindented, a blank single line around each.
- Signature block at each `{{SIGNATURE}}` (after the motion and after the memorandum), 12 pt below the paragraph and kept on one page: "Dated:" and the date at the left of the first line, the firm, a blank line, and the signer's lines in a column 2.8 in from the margin, single spaced.
- `{{NOTICE_21_DAY}}`: the LBR 9013-1(a)(2) notice (heading and six body paragraphs, the movant and relief from `notice` in the frontmatter).
- Footnotes at 12 pt, single spaced, 7 pt apart, a short rule above them. Footer: the page number, centered, its line box ending 0.5 in above the page edge.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: `#` (level 1: centered bold capitals), `##` (level 2: centered bold), a markdown list (`1.` items, numbered by the list), a lettered quotation "(A) ..." (indented), the centered asterisks "***", the directives `{{SIGNATURE}}` (the signature block from frontmatter) and `{{NOTICE_21_DAY}}` (the 21-day notice from frontmatter), or a paragraph (unnumbered).
- A paragraph with hard line breaks (a backslash at the end of a line) is set single spaced and unindented (used for address blocks).
- Footnotes: `[^n]` references and `[^n]: text` definitions (the definitions can sit anywhere; they are removed from the body and placed at their references). A space after a reference is kept.
- Frontmatter: `case_number`, `chapter`, `judge`, `division`, `caption.left` and `caption.right` (one entry per line; empty strings are blank rows), `brief_title`, `date` (used for "Dated:"), `signature` (`closing` optional, `firm` optional, `lines` for the signer and counsel), and `notice` (only when the sample uses `{{NOTICE_21_DAY}}`).
- Not supported: tables (the motion has none), raw typst, HTML, the ECF header lines.

## Overlay

`tools/overlay.sh` pairs each sample page with the exemplar page sharing the most words (`usage/OVERLAY-actual-brewing-ust-motion.txt`):

```
ours p.1  filed p.1  word-overlap 94.1%
ours p.2  filed p.2  word-overlap 93.4%
ours p.3  filed p.3  word-overlap 72.7%
ours p.4  filed p.4  word-overlap 66.4%
ours p.5  filed p.5  word-overlap 70.7%
ours p.6  filed p.6  word-overlap 50.0%
ours p.7  filed p.7  word-overlap 38.7%
```

The page map above is from the 2026-10-15 EB Garamond render; `just overlay <this folder>` writes a fresh one to `.overlay/`. Red = our render, blue = the filed exemplar, black = both. The exemplar is a Times New Roman document with no line numbers; that render was EB Garamond (the template is now Times New Roman), so its glyph outlines did not coincide, but the page-level pairing is right: the first seven pages of the exemplar are the motion and memorandum, and the render's seven pages are the same content. The overlay is a diagnostic, not a score. The word-overlap figures fall as the render's text moves across page breaks differently from the exemplar's (the typeface and line length differ), not because of missing text.

## Visual review (Gate 2 record, all 7 pages on each engine, rendered at 60 dpi and looked at, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 195/195).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption with ")" column, title, the motion paragraph, "Dated:" and the firm and signer block | OK: the signature block fits under the motion, as filed. |
| 2 | MEMORANDUM IN SUPPORT, INTRODUCTION, SUMMARY OF FACTS, items 1 to 5, footnote 1 | OK. |
| 3 | Items 6 to 13, the deadlines paragraph, CAUSE heading, quotations (A), (E), (F) with a centered "***" | OK: list numbers aligned at 0.5 in, the text hanging at 0.9 in. |
| 4 | Quotations (H), (K), (M) with footnote 2; the duties paragraphs with footnotes 3 to 5 | OK: footnote numbers 2 to 5 at the foot match the references. |
| 5 | The Rule 1007(c) argument; footnotes 6 to 9 | OK. |
| 6 | CONCLUSION, WHEREFORE, the second signature block, CERTIFICATE OF SERVICE (begun), footnote 10 | OK. |
| 7 | End of the certificate: three address blocks, the matrix line and the "/s/" lines | OK: address blocks single spaced, unindented. |

No open tier-2 finding.

## Known gaps and open choices

1. **One filer only.** The brief asks for one exemplar per doc type, and the CourtListener search was rate-limited before a second, post-2024 debtor-side motion with a memorandum was found. Tier 2 is judged against one filer, not two or three.
2. **No 21-day notice in the sample.** The exemplar (filed March 2019) has no 21-day notice. LBR 9013-1(a)(1)(C), as posted with the 2020 amendments, requires one unless an exemption applies, and the template renders it when the sample carries `{{NOTICE_21_DAY}}` and a `notice:` block. The sample does not carry it, so the render does not show it. Whether the U.S. Trustee's motion to convert or dismiss is exempt under General Order #12 was not checked. Decide before a real filing; the template is ready.
3. **Local-rule numbers in the filed text predate the 2020 numbering.** The exemplar cites LBR 1007-1, 1007-2, 1015-2, 1074-1 and 5005-4. These are kept as filed. Whether those numbers are current in the 2020 LBR was not checked against each rule.
4. **Font.** Times New Roman 12 pt in typst and docx (the docx named EB Garamond until fb-595.68.30), as the exemplar. The LBR names no typeface and requires 10 to 12 point.
5. **Footnotes single spaced at 12 pt** and the certificate's address blocks single spaced. LBR 9004-1(b) asks for double spacing of the filing; footnotes and address blocks are conventionally single spaced, and the rule does not name either. This is a reading, recorded here.
6. **Typos in the filed text are kept**, as transcribed: "exits" for "exists", "covert" for "convert", "Chapter11", "Non− Individuals", and a stray numeral before "or in the alternative" that is dropped (noted in the sample's header; it has no footnote behind it).
7. **Mailing matrix not transcribed** (exemplar pages 8 and 9). The certificate lists the parties by name; the attached matrix is a separate document in practice.
8. **Page count.** 7 pages for the body; the exemplar's body is also 7 pages (its pages 8 and 9 are the matrix). Inside the target for the content transcribed.
9. **LBR 9013-2(a) 20-page limit** is not counted by the template; the sample is 7 pages.
10. **Tool checks.** `tools/check.sh <this folder>` and `--engine docx` run every gate: `RESULT: 9 checks passed, 0 failed` (typst) and `RESULT: 13 checks passed, 0 failed` (docx, XENG-001..003 gated). `tools/check-selftest.sh` takes a court root with `court.json` and does not run on this doc-type folder.
11. **File names.** The brief names outputs `usage/<id>.pdf` and `usage/<id>-overlay.pdf`. The tools read and write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` by default, and `tools/overlay.sh` reads `OUTPUT-<id>.pdf` to build its overlay, so this folder follows the tools' names. The sample is `INPUT-<id>.md`, the same convention.

## Engines

Engine status: typst `OUTPUT-motion-brief.typst.pdf`; docx `OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice), 7 pages each, every line and page as typst (XENG-001..003 gated); latex not built.

**docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; Body Text in exact 24 pt lines with a 0.5 in first-line indent; single lines and footnotes in 14 pt boxes, 7 pt after a footnote; "List Number", "Quotation Lettered" and "Lines" as the typst template sets them) and `docx/ohsb-motion-brief.lua` (on `lib/docx/xengine.lua`): the court title, the caption table, the headings, the signature blocks, the 21-day notice, the footer (a centered PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). All 10 footnotes are Word footnotes. No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh`, `docx/render.sh` and a committed `reference.docx` in EB Garamond). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).

- The notice directive renders in both engines (checked on a scratch copy of the sample with `{{NOTICE_21_DAY}}` and a `notice` block; not part of the committed sample). On that copy a footnote that typst splits across a page end ran differently in LibreOffice (which keeps a note with its reference line), so pages 5 to 8 broke elsewhere; the committed sample has no such note.

[Court folder](../README.md)
