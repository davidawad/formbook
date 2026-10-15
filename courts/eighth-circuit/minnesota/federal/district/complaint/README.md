# Complaint, D. Minn.

Court: United States District Court for the District of Minnesota (`mnd`), Eighth Circuit.
Doc type: the complaint that starts a civil action: caption, numbered allegations (Fed. R. Civ. P. 8 and 10), counts, jury demand, prayer and signature. The example is a patent complaint (35 U.S.C. § 271) with two counts and 36 numbered paragraphs.

Status: template built and rendered; overlay built; every page of the current PDF reviewed (see "Review log"). This folder does not touch `../court.json`, `../typst/` or `../samples/` (the court-root files), and it sets no `status`.

## Files

| File | What |
|---|---|
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...` and splits its frontmatter from its body. |
| `typst/mnd-complaint.typ` | The template: caption, lead-in, numbered allegations, headings, lettered prayer items, signature. Every case word comes from the sample. |
| `exemplars/FILED-EXAMPLE-3m-v-saint-gobain-14-cv-00128-complaint.pdf` | Real filed complaint (Dkt. 1, filed 2014-01-14), public RECAP copy. Source record: `exemplars/SOURCE.md`. |
| `samples/INPUT-3m-complaint.md` | Markdown transcription of the exemplar, in the frontmatter contract below (caption, every heading, all 36 numbered paragraphs, the jury demand, the prayer, the signature block). |
| `samples/OUTPUT-3m-complaint.pdf` | Our render of the sample (13 pages). |
| `samples/OVERLAY-3m-complaint.pdf` and `.txt` | Red/blue overlay of our render against the exemplar, and its page map. |

## Rules (primary sources)

| ID | Requirement | Source | Verified | Kind |
|---|---|---|---|---|
| `FRCP-8a` | Short and plain statement of the grounds for jurisdiction, of the claim, and a demand for relief. | Fed. R. Civ. P. 8(a)(1)-(3), https://www.law.cornell.edu/rules/frcp/rule_8 (amended through 2010; the page lists the most recent amendment) | 2026-10-14 | M |
| `FRCP-10a` | Caption: court's name, a title, a file number, and the names of all parties. | Fed. R. Civ. P. 10(a), https://www.law.cornell.edu/rules/frcp/rule_10 (as amended 2007, eff. 2007-12-01) | 2026-10-14 | M |
| `FRCP-10b` | Claims and defences in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Fed. R. Civ. P. 10(b), same page | 2026-10-14 | M |
| `FRCP-38b` | Jury demand: a party may demand a jury trial by serving a written demand (the complaint may carry it). | Fed. R. Civ. P. 38(b). Text not fetched on 2026-10-14; the sample's demand paragraph is the exemplar's text. | not verified | M |
| `MN-LR52-a` | Double-spaced text; pages numbered consecutively at the bottom. The case number and judge initials on the front page apply only to documents filed after the case-initiating document, so the complaint carries none. | D. Minn. LR 5.2(a), https://www.mnd.uscourts.gov/sites/mnd/files/Local-Rules-Master.pdf (the complete set, PDF dated June 10, 2026; read 2026-10-14) | 2026-10-14 | M |
| `MN-LR52-c` | Attorney registration number on the filed document. | D. Minn. LR 5.2(c), same PDF | 2026-10-14 | M |

Kinds: M = mandated by a rule (tier 1: must be perfect); C = convention a clerk expects (tier 2).

No D. Minn. local rule sets a type size for complaints: LR 7.1(h) covers memoranda of law only. The type size is therefore a tier-2 choice here (see below).

Not verified: the ECF Electronic Case Filing Procedures Guide (PDF requirements for e-filing). LR 5.1 defers to it; it was not fetched, so no PDF-format requirement is asserted here.

## Layout choices (tier 2)

- Typeface: EB Garamond. D. Minn. LR 7.1(h)(1) (complete set, PDF dated June 10, 2026, text checked 2026-10-14) sets a 13-point size and names no face, so no court-named substitute applies and EB Garamond is kept (`docs/FONTS.md`, rule 3). The exemplar's Times New Roman is one filer's choice, not a requirement.
- Size and spacing: 13 point, double-spaced (2.3 em; measured pitch 29.9 pt in our render). The exemplar is Times New Roman at 13 point with the same pitch (measured from the filed PDF's line spacing). Choosing 13 point matches the memorandum template in this court; it is a tier-2 choice, not a rule.
- Margins: 1 inch on all sides; page numbers centred in the bottom margin (LR 5.2(a)).
- Caption: court name centred and bold; party box with rules above and below the party column; right column: "Civil No. ____" (the clerk fills the file number; a complaint has none until filed), then the bold title in capitals. The exemplar's caption matches this structure.
- Lead-in paragraph (unnumbered) before the first heading, from the frontmatter `lead_in`.
- Numbered allegations: the template numbers every paragraph from 1, in order, starting at the first heading (PARTIES). The jury demand and the prayer are not numbered (the exemplar does not number them either). The numbering is done by the template, so the sample carries no numbers: the 36 paragraphs of the exemplar come out as 1 to 36 (checked in the PDF text).
- Headings: level 1 centred and bold in capitals (PARTIES, COUNT I: ..., DEMAND FOR A JURY TRIAL, PRAYER FOR RELIEF); level 2 centred and bold (the statute under which a count is brought).
- Prayer for relief: lettered items (A., B., ...) hanging from the letter, unnumbered.
- Signature: date on the left, firm and signer block on the right, attorney designation last. The exemplar's signature block is used as filed (no `s/` prefix, which the 2026 memorandum uses).
- No certificate: LR 7.1(f)(2) applies to memoranda of law only.

## Frontmatter contract (`samples/<id>.md`)

```
---
case_number: ""                      # blank for a complaint: prints "Civil No. ____"
caption:                             # parties, each with names (list) and designation
  - names: ["..."]
    designation: "Plaintiffs,"
brief_title: "Complaint and Demand for Jury Trial"
lead_in: "Plaintiffs ... state and allege as follows:"
date: "January 14, 2014"
signature:                           # one line per entry; "" is a blank line
  - "FIRM NAME"
  - ""
  - "Attorney Name"
  - "ATTORNEYS FOR PLAINTIFFS ..."
---
```

The body is markdown: `#` for a centred heading, `##` for a sub-heading (level 2), blank-line-separated paragraphs (numbered, unless under DEMAND or PRAYER), `A.`-style lines for lettered prayer items, `*italic*` for case names.

## Commands

From the repository root (the toolchain is in `$HOME/tb/bin`, see the brief):

```
D=courts/eighth-circuit/minnesota/federal/district/complaint
sh tools/render.sh $D samples/INPUT-3m-complaint.md "$PWD/$D/samples/OUTPUT-3m-complaint.pdf"
# overlay.sh reads and writes the OUTPUT-/OVERLAY- names; use a temporary copy, then rename:
cp $D/samples/OUTPUT-3m-complaint.pdf $D/samples/OUTPUT-3m-complaint.pdf
sh tools/overlay.sh $D 3m-complaint
mv $D/samples/OVERLAY-3m-complaint.pdf $D/samples/OVERLAY-3m-complaint.pdf
mv $D/samples/OVERLAY-3m-complaint.txt  $D/samples/OVERLAY-3m-complaint.txt
rm $D/samples/OUTPUT-3m-complaint.pdf
```

`tools/render.sh` resolves an output path relative to the repository root, so pass an absolute output path. Last render: no typst warnings, 13 pages, EB Garamond embedded (two faces), exit 0.

## What the overlay shows

`samples/OVERLAY-3m-complaint.pdf`: red is our render, blue is the filed complaint, black is where both agree. The `.txt` page map pairs each of our pages with the exemplar page sharing most words. Our pages 1 to 4 pair in order; after that the pairing wanders, because the same numbered paragraphs and count headings repeat (the counts follow the same pattern), so word overlap does not map pages reliably for this document. The word-overlap figure is a diagnostic only, not a score.

Expected differences (tier 3, not chased): typeface, line breaks, the exemplar's Times New Roman glyphs (every glyph shows red and blue), and the exemplar's e-filing header (none in our render).

## Review log

Every page of the current PDF was rendered at 60 dpi and viewed. Pages were compared with the exemplar page of the same number.

- Round 1: the complaint rendered with every heading, paragraph and the signature block; the prayer letters hung correctly. Paragraph numbering checked in the PDF text: 1 to 36, the prayer items unnumbered.
- Round 1 fix (transcription): paragraph 12's exhibit citation read "(See Ex. C, Norton TORQ Instructions;" in the sample; corrected to the exemplar's "(See Ex. C; Norton TORQ Instructions;". Re-rendered (still 13 pages).
- Final review, pages 1 to 13 on the current PDF: page 1 (court name, caption, lead-in, PARTIES, paragraphs 1 to 3): PASS. Page 2 (paragraphs 4 to 7, JURISDICTION AND VENUE, PATENTS-IN-SUIT): PASS. Page 3 (paragraphs 8 to 12, COUNT I heading and sub-heading): PASS. Page 4 (paragraphs 12 to 15, indirect-infringement sub-heading): PASS. Page 5 (paragraphs 15 to 16): PASS. Page 6 (paragraphs 16 to 18): PASS. Page 7 (paragraphs 19 to 21): PASS. Page 8 (paragraphs 21 to 26, COUNT II): PASS. Page 9 (paragraphs 26 to 28): PASS. Page 10 (paragraphs 28 to 30): PASS. Page 11 (paragraphs 31 to 34, the 271(c) sub-heading at the top): PASS. Page 12 (paragraphs 34 to 36, DEMAND, PRAYER, items A and B): PASS. Page 13 (prayer items C to E, date, signature block): PASS.
- Page 1 has a few lines of white space at the foot: the heading "JURISDICTION AND VENUE" is kept with its first paragraph, which does not fit. ACCEPTED: keep-with-next is the intended behaviour.

- Fonts pass (fb-595.7.5.13): font list checked against the rule, no face named, so EB Garamond kept (no change to the template). Re-rendered with `tools/render.sh` (exit 0, no warnings, 13 pages); `pdffonts`: EB Garamond Regular and Bold embedded only. Overlay re-run against the exemplar (`exemplars/FILED-EXAMPLE-3m-v-saint-gobain-14-cv-00128-complaint.pdf`, 14 pages, fetched from the URL in `exemplars/SOURCE.md`). Every page of the new render viewed again: PASS.

Pages reviewed: 13 of 13.

## Known gaps

- Exemplars: one filed complaint for this doc type (`exemplars/`). The eval loop asks for two or three filers to judge tier 2 against. Tier-2 choices here rest on the rules and this one exemplar.
- The exemplar is from 2014, a patent complaint by a corporate plaintiff, so it predates the June 2026 local-rules text. It is used for layout only, never as the source of a requirement. It was chosen because it is the only public D. Minn. complaint whose PDF was retrievable from this box.
- Searches tried for exemplars: CourtListener RECAP search (rate-limited; 202 responses for long stretches), CourtListener docket pages (the 3M docket and the Adams docket worked; the Adams complaint is sealed (Dkt. 1), and the Luckoff complaint is not in RECAP (entry 1 returns 404)), Justia (403 to this box), Clearinghouse (403 to this box), WebSearch (several queries), and the court's own site (the local-rules PDF is behind a request filter).
- Judge initials: none on the complaint, correct under LR 5.2(a) for the case-initiating document.
- The Fed. R. Civ. P. 38(b) text was not re-fetched; the jury-demand paragraph follows the exemplar.
- The ECF PDF requirements (searchable text, embedded fonts, size cap, bookmarks) are not covered: the ECF Guide was not fetched (see Rules).
- Civil cover sheet (LR 3.1), Rule 7.1 disclosure statement and summons are separate documents and are not covered here.

## Engines

The docx engine (`docx/`) is built from `docx/make-reference.sh` (pandoc's default reference document, restyled) and `docx/mnd-complaint.lua` (front page, caption table, numbering, prayer items, signature block). Outputs: `samples/OUTPUT-3m-complaint.docx` and `samples/OUTPUT-3m-complaint.docx.pdf` (LibreOffice 25.2 conversion). Typst stays the primary engine; the latex engine is not built for this folder.

- **Matches the typst form:** EB Garamond 13 pt throughout; 1-inch margins on letter paper; double spacing at the typst pitch (29.9 pt exact, checked on every page of the PDF); centred bold headings with a double line above and below; first-line indent 0.5 inch with unindented paragraphs after headings; numbered allegations 1 to 36 (checked in the PDF text); lettered prayer items hanging from the letter; caption (party column between rules, "Civil No. ____", bold title); signature block (date left, firm and signer right); page number centred in the bottom margin.
- **Differs:** pagination. Word's exact line spacing gives each line its full 29.9 pt box, while typst adds leading only between lines, so a page holds 21 lines in docx and 22 in typst. The complaint runs 14 pages in docx against 13 in typst, and the signature block falls alone on page 14. Same pitch, one line less per page; the rule does not set a page count.
- **Differs:** the typeface is rendered by LibreOffice; kerning and line breaks differ slightly from typst.
- **docx BLOCKED items:** none for the mandated form. No check IDs exist yet for this folder (no `checks.yaml`), so `tools/check.sh --engine docx` has nothing to run; the Gate 2 review of the docx PDF is recorded below.

Review log (docx): every page of `samples/OUTPUT-3m-complaint.docx.pdf` (14 pages) was rendered at 60 dpi and viewed against the typst pages: pages 1 to 14 PASS on form (caption, headings, numbering, prayer, signature); page 14 carries only the signature block (pagination note above). The `.docx` opens in LibreOffice without a repair prompt; Word was not available to check.
