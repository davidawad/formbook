# Motion brief (memorandum of law in support of a motion), D. Minn.

Court: United States District Court for the District of Minnesota (`mnd`), Eighth Circuit.
Doc type: a memorandum of law supporting a Fed. R. Civ. P. 12(b) motion (the example is a partial motion to dismiss under Rule 12(b)(6)). The memorandum is the only document with a word limit and a certificate; the notice of motion, proposed order and any declaration are separate documents and are not covered here.

Status: template built and rendered; overlay built; every page of the current PDF reviewed (see "Review log"). Not a court-level promotion: this folder does not touch `../court.json`, `../typst/` or `../samples/` (the court-root files), and it does not set any `status`.

## Files

| File | What |
|---|---|
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...` and splits its frontmatter from its body. |
| `typst/mnd-motion-brief.typ` | The template: caption, body, headings, footnotes, signature, certificate of compliance. Every case word comes from the sample. |
| `exemplars/FILED-EXAMPLE-adams-v-innes-26-cv-02415-motion-brief.pdf` | Real filed memorandum (Dkt. 37, filed 2026-09-22), public RECAP copy. Source record: `exemplars/SOURCE.md`. |
| `samples/INPUT-adams-motion-brief.md` | Markdown transcription of the exemplar, in the frontmatter contract below (caption, all headings, body, two footnotes, signature block). |
| `samples/OUTPUT-adams-motion-brief.pdf` | Our render of the sample (13 pages). |
| `samples/OVERLAY-adams-motion-brief.pdf` and `.txt` | Red/blue overlay of our render against the exemplar, and its page map. |

## Rules (primary sources)

Source: the District of Minnesota Local Rules, complete set, PDF dated June 10, 2026: https://www.mnd.uscourts.gov/sites/mnd/files/Local-Rules-Master.pdf. Text read from the PDF on 2026-10-14. The court's site blocks direct downloads from this box, so the text was read through a fetch of the same PDF; the file's own date (June 10, 2026) is the version recorded here.

| ID | Requirement | Rule | Kind |
|---|---|---|---|
| `MN-LR71-f1A` | Memorandum of law may not exceed 12,000 words (proportional font). | LR 7.1(f)(1)(A) | M |
| `MN-LR71-f1C` | All text counts (headings, footnotes, quotations) except the caption designation, a table of contents or authorities if any, the signature-block text, and certificates of compliance. | LR 7.1(f)(1)(C) | M |
| `MN-LR71-f2` | A memorandum must be accompanied by a certificate of compliance, executed by the attorney, stating the word count and the name and version of the word-processing software; the count must have been applied to all text. | LR 7.1(f)(2) | M |
| `MN-LR71-h1` | Type size: at least 13-point (footnotes included); double-spaced, except headings and footnotes (single) and quotations more than two lines long (indented and single-spaced). | LR 7.1(h)(1) | M |
| `MN-LR71-h1-page` | 8 1/2 by 11 inch pages; no text outside a 6 1/2 by 9 inch area except page numbers. | LR 7.1(h)(1) | M |
| `MN-LR52-a` | Double-spaced text; pages numbered consecutively at the bottom; the case number and the assigned district and magistrate judges' names or initials on the front page above the title (documents after the case-initiating document). | LR 5.2(a) | M |
| `MN-LR52-c` | Attorney registration number on filed documents. | LR 5.2(c) | M |
| `MN-FRCP-10a` | Caption: court name, title, file number, names of parties. | Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10, text checked 2026-10-14) | M |

Kinds: M = mandated by a rule (tier 1: must be perfect); C = convention a clerk expects (tier 2); T = project rule; A = author responsibility.

Local rules overriding national ones here: LR 7.1(f) sets the 12,000-word limit and LR 7.1(h) the 13-point size; these apply to the memorandum in place of any national default. The Federal Rules do not set a type size.

Not verified: the ECF Electronic Case Filing Procedures Guide (the PDF requirements for e-filing: searchable text, embedded fonts, size cap). LR 5.1 defers to that guide; the guide was not fetched, so no PDF-format requirement is asserted here.

## Layout choices (tier 2, from the rules' gaps and the exemplar)

- Typeface: EB Garamond. D. Minn. LR 7.1(h)(1) (complete set, PDF dated June 10, 2026, text checked 2026-10-14) names no face: it sets the size (13 point), and LR 7.1(f)(1)(A) distinguishes only proportional from monospaced fonts. No court-named substitute applies, so EB Garamond is kept (`docs/FONTS.md`, rule 3). The exemplar is Times New Roman (not embedded in the RECAP copy); that is one filer's choice, not a rule.
- Double spacing is 2.3 em in EB Garamond: 0.65 em natural line plus 1.65 em leading (two 1.15 em lines, the usual Word "double" for a 13-point face). Measured pitch in our render: 29.9 pt, the same pitch the exemplar shows at 13 pt.
- Margins: 1 inch on all sides (the 6 1/2 by 9 inch area of LR 7.1(h)(1)). Page numbers sit in the bottom margin, centred.
- Caption: court name centred and bold; party box with rules above and below the party column; right column: file number, bold title in capitals, "Fed. R. Civ. P. 12(b)(6)" right-aligned. The exemplar's ECF header (the "CASE ... Doc. 37 Filed ... Page x of y" line) is added by the court's system and is not reproduced.
- Headings: level 1 centred bold (INTRODUCTION, CONCLUSION); level 2 bold with a hanging indent; level 3 bold, indented, hanging. Headings are single-spaced and kept with the text after them.
- Footnotes: 13-point, single-spaced (rule: footnotes count as text and must be 13 point).
- Certificate of compliance: a separate last page, body text double-spaced, dated and signed by the attorney. The template asserts the word count is at or below 12,000 (`assert` in `typst/mnd-motion-brief.typ`).
- Signature block: date on the left, firm and signer on the right; `s/` signature style as in the exemplar.

Not chosen (because the exemplar shows a choice the rules leave open, and it is one filer's): the exemplar's Times New Roman, its justification style, its ECF header, and the absence of a certificate in the filed copy (the rule requires one, so the template includes it).

## Frontmatter contract (`samples/<id>.md`)

```
---
case_number: "0:26-cv-02415-JMB-SGE"        # file number with the judges' initials (LR 5.2(a))
caption:                                     # parties, each with names (list) and designation
  - names: ["..."]
    designation: "Plaintiffs ...,"
brief_title: "..."                           # printed in capitals in the right column
rule_line: "Fed. R. Civ. P. 12(b)(6)"        # the rule the motion is brought under
date: "September 22, 2026"
word_count: 3155                             # the attorney's word count (LR 7.1(f)(2)); see Known gaps
word_software: "Microsoft Word for Microsoft 365, version 2609"   # LR 7.1(f)(2)
certificate_signer: "s/ Andrew S. Dosdall"
signature:                                   # one line per entry; "" is a blank line
  - "FIRM NAME"
  - ""
  - "By: s/ ..."
---
```

The body is markdown: `#` for centred headings, `##`/`###` for sub-headings, blank-line-separated paragraphs (double-spaced, first-line indent), `*italic*` for case names and signals, `[^n]` footnotes.

## Commands

From the repository root (the toolchain is in `$HOME/tb/bin`, see the brief):

```
D=courts/eighth-circuit/minnesota/federal/district/motion-brief
sh tools/render.sh $D samples/INPUT-adams-motion-brief.md "$PWD/$D/samples/OUTPUT-adams-motion-brief.pdf"
# overlay.sh reads and writes the OUTPUT-/OVERLAY- names; use a temporary copy, then rename:
cp $D/samples/OUTPUT-adams-motion-brief.pdf $D/samples/OUTPUT-adams-motion-brief.pdf
sh tools/overlay.sh $D adams-motion-brief
mv $D/samples/OVERLAY-adams-motion-brief.pdf $D/samples/OVERLAY-adams-motion-brief.pdf
mv $D/samples/OVERLAY-adams-motion-brief.txt  $D/samples/OVERLAY-adams-motion-brief.txt
rm $D/samples/OUTPUT-adams-motion-brief.pdf
```

`tools/render.sh` resolves an output path relative to the repository root, so pass an absolute output path (above). The render uses the vendored fonts only (`--ignore-system-fonts`); a typst warning fails the render. Last render: no warnings, 13 pages, EB Garamond embedded (three faces), exit 0.

## What the overlay shows

`samples/OVERLAY-adams-motion-brief.pdf` is page by page: red is our render, blue is the filed memorandum, black is where both agree. The map (`.txt`) pairs each of our pages with the exemplar page sharing most words. Pages 1 to 8 pair in order; from page 9 our pagination runs one page behind the exemplar's (our pages break at different lines, so each page carries a different block of text). The word-overlap figure is a diagnostic only, not a score.

Expected differences (tier 3, not chased): typeface (Garamond vs Times, so every glyph is red and blue), line breaks, the ECF header, and the absence of a certificate in the exemplar.

## Review log

Every page of the current PDF was rendered at 60 dpi and viewed. Pages were compared with the exemplar page of the same number.

- Round 1 (first render, 12 pages): page 1 had a paragraph whose first line sat on top of the previous paragraph's last line (paragraph spacing was 0 pt, so a new paragraph started one line too high). Fixed: `spacing` now equals the leading. Page count went to 13.
- Round 1: headings rendered at typst's default heading scale (larger than 13 pt). Fixed: heading text pinned to `type-size`.
- Round 1: the signature block's lines overlapped (each line was a paragraph with no gap). Fixed: lines are set with the single-spaced stack.
- Round 1: the caption's designation line was justified and stretched. Fixed: caption paragraphs are not justified.
- Round 2 (final render): pages 1 to 13 reviewed again. Page 1 (caption, title, first paragraphs): PASS. Pages 2 to 11 (body, headings A to E, footnotes 1 and 2 at 13 point): PASS. Page 12 (conclusion, signature block): PASS. Page 13 (certificate of compliance): PASS.
- Level-3 headings ("A.", "D.", ...) use a hanging indent (the exemplar has a tab at the same place): ACCEPTED, tier 2 choice.

- Fonts pass (fb-595.7.5.13): font list checked against LR 7.1(h)(1), no face named, so EB Garamond kept (no change to the template). Re-rendered with `tools/render.sh` (exit 0, no warnings, 13 pages); `pdffonts`: EB Garamond Regular, Bold and Italic embedded only. Overlay re-run against the exemplar (`exemplars/FILED-EXAMPLE-adams-v-innes-26-cv-02415-motion-brief.pdf`, 13 pages, fetched from the URL in `exemplars/SOURCE.md`). Every page of the new render viewed again: PASS.

Pages reviewed: 13 of 13.

## Known gaps

- Exemplars: one filed memorandum for this doc type (`exemplars/`). The eval loop asks for two or three filers to judge tier 2 against; a second D. Minn. memorandum was not located, so tier-2 judgement rests on one exemplar plus the rules.
- Searches tried for exemplars: CourtListener RECAP search (rate-limited to about five requests a minute for anonymous use, with 202 responses for long stretches), CourtListener docket pages (public docket HTML and RECAP PDFs, which worked), Justia (403 to this box), Clearinghouse (403), WebSearch (several queries), and the court's own site (its local-rules PDF is behind a request filter that rejects direct download).
- The word count (`word_count: 3155`) is `wc -w` over the markdown body with markup stripped, which includes headings and footnotes. Word's own count will differ slightly; the certificate must state the number from the software the attorney used (LR 7.1(f)(2)).
- The certificate's software name is a sample value; the signing attorney must supply theirs.
- No table of contents or table of authorities: D. Minn. does not require them for this memorandum; if one is added, LR 7.1(f)(1)(C) excludes it from the count and the template must be extended.
- The ECF PDF requirements (searchable text, embedded fonts, file size, bookmarks) are not covered: the ECF Guide was not fetched (see Rules).
- The notice of motion, proposed order, and hearing information are not part of this template.
- Judge initials: the template prints `case_number` as given; the caller must include the initials (LR 5.2(a)).

## Engines

The docx engine (`docx/`) is built from `docx/make-reference.sh` (pandoc's default reference document, restyled) and `docx/mnd-motion-brief.lua` (front page, caption table, signature block, certificate of compliance with the 12,000-word check). Outputs: `samples/OUTPUT-adams-motion-brief.docx` and `samples/OUTPUT-adams-motion-brief.docx.pdf` (LibreOffice 25.2 conversion). Typst stays the primary engine; the latex engine is not built for this folder.

- **Matches the typst form:** EB Garamond 13 pt throughout, footnotes included (native footnotes, 13 pt single-spaced); 1-inch margins on letter paper; double spacing at the typst pitch (29.9 pt exact); first-line indent 0.5 inch, with the first paragraph after a heading unindented, as typst does; level 1 headings centred and bold; level 2 and 3 headings single-spaced, bold and hanging; caption with the court file number, bold title and rule line; signature block; certificate of compliance on its own page with the word count and software from the frontmatter; page number centred in the bottom margin.
- **Differs:** pagination. Word's exact line spacing gives each line its full 29.9 pt box, while typst adds leading only between lines, so a page holds 21 lines in docx and 22 in typst. The memorandum runs 14 pages in docx against 13 in typst; the signature block moves to its own page 13 with the body ending on page 12. The word limit is a word count, not a page count, so this does not affect compliance.
- **docx BLOCKED items:** none for the mandated form. No check IDs exist yet for this folder (no `checks.yaml`), so `tools/check.sh --engine docx` has nothing to run; the Gate 2 review of the docx PDF is recorded below.

Review log (docx): every page of `samples/OUTPUT-adams-motion-brief.docx.pdf` (14 pages) was rendered at 60 dpi and viewed against the typst pages: pages 1 to 14 PASS on form (caption, headings, footnotes, signature block, certificate). The `.docx` opens in LibreOffice without a repair prompt; Word was not available to check.
