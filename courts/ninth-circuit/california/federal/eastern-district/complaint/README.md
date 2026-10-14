# caed: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of California (`caed`).
Folder: `courts/ninth-circuit/california/federal/eastern-district/complaint/` (self-contained; the court root's `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-morgan-brothers-1-26-cv-07747-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-morgan-complaint.md`: caption, paragraphs 1 to 35 (pages 1 to 11 of the filing), the prayer (1 to 12), signature, jury demand. Paragraphs 36 to 85 and Counts 1 to 8 are not transcribed (see Known gaps) |
| render | ok: `samples/OUTPUT-morgan-complaint.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this folder> samples/INPUT-morgan-complaint.md`) |
| overlay | ok: `samples/OVERLAY-morgan-complaint.pdf` and `samples/OVERLAY-morgan-complaint.txt` (`sh tools/overlay.sh <this folder> morgan-complaint`) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed; pages 1 to 10 were viewed before a footer-title and signature-line fix, and that fix is confined to the footer text and the signature block, which pages 11 and 12 show in their final form) |

File names: the tools name files by role (`INPUT-` is the markdown, `OUTPUT-` is our render, `OVERLAY-` is the comparison). This folder follows them rather than the `<id>.md` / `<id>-overlay.pdf` names in the brief, because `tools/render.sh`, `tools/overlay.sh` and `CLAUDE.md` read those names.

## Governing rules

Primary source: **E.D. Cal. Local Rules, effective 1 January 2025** (the current version posted; no 2026 revision was found), https://www.caed.uscourts.gov/caednew/assets/File/EDCA%20LOCAL%20RULES%20EFF%201-1-25%20(FINAL).pdf, read 2026-10-14. The text was read from the PDF (280 pages); the rule text quoted below is from that PDF.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| E.D. Cal. L.R. 130(b) | White paper, 8½ × 11, "with numbered lines in the left margin." | `line-numbers()`: 28 numbers down the left margin; `pleading-rules()`. |
| E.D. Cal. L.R. 130(c) | "Documents shall be double-spaced except for the identification of counsel, title of the action, category headings, footnotes, quotations, exhibits and descriptions of real property." | `pitch = 24pt`, `body-leading`; counsel, caption, signature and headings single-spaced or on the grid. |
| E.D. Cal. L.R. 130(d) | "Each page shall be numbered consecutively at the bottom and shall provide a brief description of the document on the same line." | `footer-block()`: the description (left) and the page number (right) are on one line. |
| E.D. Cal. L.R. 131(a) | Name, address, telephone and State Bar number of all attorneys, and "the specific identification of each party represented by name and interest," in the upper left-hand corner of the first page. | `counsel` frontmatter (lines 1 to 7); the last counsel line names the party represented. |
| E.D. Cal. L.R. 131(b), (c) | Signature by the attorney; "/s/" for an attorney's electronic signature; the name typed under it. | `signature-block()`: "Dated:", the firm, "By: /s/ <signer>", the signer's name, the role. |
| E.D. Cal. L.R. 133(a) | The Court is a CM/ECF district; "all complaints ... shall be electronically filed." | Not a layout rule; it governs filing, and the template produces the PDF for filing. |
| E.D. Cal. L.R. 133(f) | A courtesy paper copy to chambers for any electronically filed document over 25 pages. | Not in the template (the exemplar is 27 pages; the sample is 12). The courtesy-copy rule applies to the filing, not the layout. |
| Fed. R. Civ. P. 10(a) | Caption with "the court's name, a title, a file number, and a Rule 7(a) designation." Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14 (text: "As amended Apr. 30, 2007, eff. Dec. 1, 2007."). | `court-title()` (court name and division), `caption()` (`Case No.`, title), the title of the paper. |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs," "each limited as far as practicable to a single set of circumstances." Same source. | `allegations()` numbers each body paragraph; headings, the WHEREFORE clause and the jury demand are unnumbered. |
| Fed. R. Civ. P. 38 | Jury demand. | `jury_demand: true` puts "DEMAND FOR JURY TRIAL" in the caption; the jury demand is its own section at the end. |

Not produced by this template (separate filings that accompany a complaint): the civil cover sheet (JS-44); the summons; the Rule 7.1 disclosure statement; the Certification of Interested Entities (N.D. Cal. has that rule, E.D. Cal. was not checked for an equivalent and is not asserted here).

## Layout

- Numbered lines 1 to 28 down the left margin, a double rule at the text's left edge and a single rule at its right (the pleading form, as in the exemplar).
- Top margin 1 inch; the 28 lines end at 10.33 inches; the footer is in the bottom margin.
- Counsel block single-spaced from line 1; the court title starts on line 8 (`counsel-lines = 7`), and more counsel lines push it down.
- Court title: UNITED STATES DISTRICT COURT / EASTERN DISTRICT OF CALIFORNIA / the division (from `division`).
- Caption: the party column closed by a rule; "Case No.:" and the title on the right; "DEMAND FOR JURY TRIAL" under the title when `jury_demand` is set.
- Numbered paragraphs (Fed. R. Civ. P. 10(b)), 0.5 inch first-line indent; headings: level 1 centered caps, level 2 centered bold, level 3 bold left.
- Prayer items are numbered 1, 2, ... (as in the exemplar), with a hanging indent.
- Each block of text is a whole number of 24 pt rows (`on-grid`), so paragraphs and signature blocks land on the numbered lines.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks:
  - `#`, `##`, `###` headings (level 1 centered caps; level 2 centered bold; level 3 bold, left). A heading must fit one numbered line (the template fails the build otherwise).
  - `1.`-style list items: the prayer, numbered 1, 2, ... by the template.
  - `---`: where the signature block goes. Put one `---` where the signature belongs, and one after the jury demand.
  - `[unnumbered] ...`: a paragraph that is not an allegation (WHEREFORE, the jury demand text).
  - any other paragraph: a numbered allegation. The template numbers it; the sample must not type the number.
- Frontmatter: `case_number` (blank as filed), `division`, `counsel` (lines; the last names the party), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `footer_title` (one line), `jury_demand`, `lead_in` (the unnumbered lead-in paragraph), `date`, `signature` (`firm`, `signer`, `lines`), `omitted` (a note on what the sample leaves out; not rendered).
- Not supported: tables, footnotes, raw typst.

## Overlay

`samples/OVERLAY-morgan-complaint.pdf`: our render in red, the filed exemplar in blue, multiplied (black where both agree), one page per sample page, each paired with the exemplar page sharing the most words. `OVERLAY-morgan-complaint.txt` has the pairing and word-overlap percentages. The overlay is a diagnostic, not a score. The sample is an excerpt: pages 1 to 9 pair with exemplar pages 1 to 10 at 46 to 77 percent word overlap, and pages 10 to 12 pair with exemplar pages 24, 25 and 27 (the prayer and signature) at 55 to 79 percent. The lower pairs (pages 5, 9 and 12) are where the excerpt skips pages, not where the template differs.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type. EVAL-LOOP's tier-2 rule asks for two or three filers. Other E.D. Cal. complaints were found by CourtListener search (not saved; see `exemplars/SOURCE.md`): Kennedy v. Thrive Causemetics (1:26-cv-07817, class action, 10 pp.) and others. Tier 2 is therefore **not** judged against two filers yet.
2. **Font.** No E.D. Cal. rule names a typeface or type size. The exemplar is Times New Roman 12 pt. This template uses EB Garamond, the only font vendored in `fonts/`. EB Garamond at 12 pt has a smaller x-height than Times at 12 pt. This is an open choice for David (a vendored Times-metric font would remove the difference); it is not a rule failure.
3. **Excerpt.** The sample transcribes paragraphs 1 to 35 (exemplar pages 1 to 11), the prayer (exemplar pages 24 to 25), the signature and the jury demand (pages 26 to 27). Paragraphs 36 to 85 and Counts 1 to 8 (exemplar pages 11 to 23) are not transcribed. The filed paragraph numbers match the sample's (they are the filed numbers), so the sample's numbering is the filing's own up to paragraph 35. The filing's signature appears twice (after the prayer and after the jury demand); the sample carries both.
4. **Footer.** The exemplar centers the page number on its own line with the title below. L.R. 130(d) says the number and the description are on the same line, so the template follows the rule. This differs from the exemplar on purpose.
5. **Caption: the case number.** The filed complaint leaves "Case No." blank (the clerk assigns the number and judge initials). The sample does the same.
6. **Court title position.** The rules do not fix the line; the template puts the court title on line 8 (as the N.D. Cal. complaint does). The exemplar puts it on line 7 with five counsel lines. Both are within L.R. 131(a).
7. **Signature block and page breaks.** The template does not hold the last allegation with the signature (the motion template does); in this sample the signature falls on a page with room, so no defect is visible, but a longer prayer could strand a signature. Recorded as a known limitation.
8. **Page limits.** The Local Rules set no page limit for a complaint. The 25-page threshold in L.R. 133(f) triggers a courtesy copy to chambers; it is not a limit.
9. **Headings.** A heading must fit one numbered line (the build fails otherwise). A longer heading needs a shorter title or a template change.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. The render and overlay were run; the Gate 2 review above is the equivalent for this doc type.

## Review of the rendered pages (final PDF)

Rendered at 60 dpi and viewed page by page.

- Page 1: counsel single-spaced on lines 1 to 5, court title on lines 8 to 10, party column and caption on lines 12 to 20, title and "DEMAND FOR JURY TRIAL" at the right, footer on one line. Pass.
- Page 2: lead-in, I. THE PARTIES, paragraphs 1 and 2, II. JURISDICTION AND VENUE, paragraphs 3 to 6 on the grid. Pass.
- Page 3: paragraphs 6 (end) to 10, III. FACTUAL BACKGROUND centered. Pass.
- Page 4: paragraphs 11 to 13 on the grid; the "A." subheading moved to page 5 with its first paragraph (keep-with-next), leaving four numbered lines blank at the foot. Pass (intended).
- Page 5: A. MBI's business and trademark rights, paragraphs 14 to 17. Pass.
- Page 6: paragraphs 18 to 23. Pass.
- Page 7: B. The Business Separation and Territorial Agreement, paragraphs 24 to 27. Pass.
- Page 8: paragraphs 28 to 31. Pass.
- Page 9: paragraphs 32 to 35; C. RDM's Sponsored Advertisements subheading. Pass.
- Page 10: paragraph 35 end, PRAYER FOR RELIEF, WHEREFORE (unnumbered), prayer items 1 to 5. Pass.
- Page 11: prayer items 5 to 12, "Dated:" with the firm and signature block (one signer name under "By: /s/"). Pass.
- Page 12: JURY DEMAND (unnumbered paragraph), second signature block. Pass.

Defects found and fixed during review: the signer's name printed three times (sample `signature.lines` repeated it; fixed); the footer title wrapped to two lines (shortened to "COMPLAINT; DEMAND FOR JURY TRIAL"; fixed).
