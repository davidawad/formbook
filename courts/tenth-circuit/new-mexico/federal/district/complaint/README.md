# nmd: complaint

Doc type: **complaint** in the United States District Court for the District of New Mexico (`nmd`).
Folder: `courts/tenth-circuit/new-mexico/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-pillow-1-26-cv-03383-complaint.pdf` (1 filer, counsel-filed; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-pillow-complaint.md` (a portion of the 15-page filing; see Known gaps) |
| render | ok: `samples/OUTPUT-pillow-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-pillow-complaint.pdf` and `OVERLAY-pillow-complaint.txt` (`tools/overlay.sh`) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change) |

File names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (the sample id is the `.md` name). The brief's `<id>-overlay` names are not what `tools/overlay.sh` writes, so the tool's names are used.

## Governing rules

Primary sources, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.N.M.LR-Civ. 10.1 (Form) | 8½ × 11 white paper, one side; typewritten "at least 12 pitch", letter quality; margins: left, right and bottom at least 1 inch, **top at least 1½ inches**; text double spaced except footnotes and quotations; **first page has the case file number and initials of the assigned judges**. Source: https://www.nmd.uscourts.gov/sites/nmd/files/local_rules/Local%20Rules%20of%20Civil%20Procedure%20Adopted%20October%201%2C%202020_0.pdf (Local Rules of Civil Procedure, "Amended Effective October 1, 2020"; index page https://www.nmd.uscourts.gov/court-info/local-rules-and-orders/local-rules). | `margins` (top 1.5 in; others 1 in); `pitch`; `body-leading` for both the line leading and the paragraph spacing (24 pt double spacing at 12 pt); `case_number` on page 1 in `caption()`. |
| D.N.M.LR-Civ. 83.4(a) | An attorney's entry of appearance (and the initial pleading it signs) gives name, firm name, address, telephone number, electronic address and facsimile number; the attorney signs the initial pleading. | `signature-block()`: `signature.firm`, `signature.blocks` (one block per attorney group, separated by "and"), `signature.attorneys_for`. |
| D.N.M.LR-Civ. 3.1 | A civil cover sheet must be attached to the initiating pleading. | Not produced by this template (a separate form). See Known gaps. |
| Fed. R. Civ. P. 10(a) | Caption: court name, title, file number, and Rule 7(a) designation. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14. | `court-title()`, `caption()`, `cover()`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph; headings and lists are not numbered. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of the claim, the grounds for jurisdiction, and a demand for the relief sought. Content only; the template does not check it. Fetched from https://www.law.cornell.edu/rules/frcp/rule_8 on 2026-10-14. | Author content. |
| Fed. R. Civ. P. 11(a) | Every pleading must be signed by an attorney of record, and must state the signer's address, e-mail address, and telephone number. Fetched from https://www.law.cornell.edu/rules/frcp/rule_11 on 2026-10-14. | `signature-block()` (the `/s/` line and contact lines are sample content). |

## Layout

- Letter paper, top margin 1½ in, other margins 1 in. Page numbers centered in the bottom margin (no footer title: the exemplar has none).
- Court title (two lines, centered, bold) at the top of page 1; caption: parties on the left with a column of ")" marks, "Case No." on the right; the title of the paper centered and bold below the caption.
- Body text 12 pt EB Garamond, double spaced at a 24 pt pitch (measured: 24.00 pt between every pair of body lines), first-line indent ½ in, left aligned.
- Numbered paragraphs (`1.`, `2.`, ...) at a ½ in indent. Headings: level 1 centered bold caps (INTRODUCTION, PARTIES, FACTS, COUNT I); level 2 a centered bold caps sub-heading (the count's name). A heading stays with the paragraph after it.
- Lists (the enumerated breaches) are lettered `a.`, `b.` ... and may break across pages.
- The request for relief (WHEREFORE) and the jury demand are unnumbered paragraphs.
- Signature block at the right of the page, single spaced, kept together on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks: a `#` heading (level 1: centered bold caps; `##` level 2: centered bold caps sub-heading), a list (`1.` items, lettered by the template), a paragraph (numbered by the template), or an **unnumbered paragraph written with a leading `^ `** (the marker is removed; use it for WHEREFORE paragraphs and the jury demand, which are not allegations).
- Frontmatter fields: `case_number` (with judges' initials after it, e.g. `1:26-cv-03220 JMR/GJF`, once assigned), `court` (lines), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title` (set in the sample's own capitalization; the template does not change case), `lead_in` (optional, unnumbered sentence before the first heading), `date` (optional), `signature` (`firm` lines, `blocks` (a list of line lists, each for one attorney group), `attorneys_for`).
- Not supported: tables, footnotes (cmarker renders them as an inline note), raw typst.
- The sample must not put numbers in the text: the template numbers the allegations.

## Overlay

`samples/OVERLAY-pillow-complaint.pdf`: each page of our render is shown in red and paired with the filed page sharing the most words (blue; black where they agree). The pairing is by text, not by index. The page map is in `OVERLAY-pillow-complaint.txt`:

```
ours p.1  filed p.1  word-overlap 77.6%
ours p.2  filed p.2  word-overlap 63.5%
ours p.3  filed p.3  word-overlap 51.1%
ours p.4  filed p.5  word-overlap 51.7%
ours p.5  filed p.6  word-overlap 71.8%
ours p.6  filed p.7  word-overlap 69.4%
ours p.7  filed p.8  word-overlap 72.6%
ours p.8  filed p.9  word-overlap 89.6%
ours p.9  filed p.15 word-overlap 51.8%
```

The overlay is a diagnostic, not a score. The filed pages carry an ECF header ("Case 1:26-cv-03383 Document 1 Filed 10/08/26 Page x of 15"), which adds words our render does not have, and the sample omits Count IV, so the pages after Count III pair with filed pages by shared words only. The lower overlaps are those pages, not a layout difference.

## Review of the rendered pages (final render)

Every page was rendered at 60 dpi and viewed.

- Page 1: court title, caption with ")" marks, "Case No. 1:26-cv-3383" on the right; "COMPLAINT" centered; the lead-in; INTRODUCTION; ¶¶ 1–5. The judges' initials are not on this page (see Known gaps). Pass.
- Page 2: PARTIES, JURISDICTION AND VENUE, FACTS; ¶¶ 6–12. Headings kept with the paragraph after them. Pass.
- Page 3: ¶¶ 13–21, numbered paragraphs at ½ in indent, double spaced. Pass.
- Page 4: ¶¶ 22–28; COUNT I and NEGLIGENCE centered on consecutive lines; the list of breaches begins at (a). Pass.
- Page 5: the list continues (f–h); ¶¶ 29–31; WHEREFORE unnumbered; COUNT II heading. Pass.
- Page 6: ¶¶ 34–39 (paragraph 33 begins on page 5). Pass.
- Page 7: ¶¶ 40–47; WHEREFORE. Pass.
- Page 8: COUNT III; ¶¶ 48–52; WHEREFORE; DEMAND FOR JURY TRIAL heading and its unnumbered demand. Pass.
- Page 9: signature block (firm, two attorney groups separated by "and", "Attorneys for Plaintiff") at the right, on a page by itself because the block is not split. Pass.

Measured: body line pitch 24.00 pt; 100 characters per full 6.5 in line (about 15 characters per inch, above the "at least 12 pitch" minimum).

## Known gaps and open choices

1. **One exemplar only.** The tier-2 rule asks for 2 or 3 filers. Searched: CourtListener RECAP (`type=r`, `court=nmd`, complaints filed 2026-06 to 2026-10). Candidates checked for text and format: Pillow v. Sig Sauer (saved); Larson v. Beckett Collectibles, LLC, 1:26-cv-02563 (Doc. 1, class action, 37 pages, Egolf + Ferlic + Martinez and Hall Attorneys, text layer yes; the second-filer candidate, not saved); Myers v. Moreno, 1:26-cv-02122 (scanned image, 222 words of text: rejected). Tier 2 is therefore **not** judged against two filers yet.
2. **Judges' initials on page 1.** LR 10.1 requires the case number and the initials of the assigned judges on the first page. The exemplar was filed before assignment and shows `1:26-cv-3383` with no initials. The template prints `case_number` as given, so the initials are added in the sample once the case is assigned. **Open for David:** whether the template should refuse a sample without initials (it does not now).
3. **Font.** The rules say "at least 12 pitch" and "letter quality", which is a typewriter measure; the template uses 12 pt EB Garamond (the only serif vendored in `fonts/`; a Times-metric font would be a different vendored file). The 12 pt proportional line measures about 15 characters per inch. EB Garamond has a smaller x-height than Times, so the text looks smaller than the exemplar. Whether the court wants a larger apparent size is a question for David.
4. **Footnotes.** Not supported: cmarker renders a markdown footnote as an inline note, not a page footnote. The sample has none (the exemplar's footnotes are not transcribed).
5. **Italics.** The exemplar's text layer has no italic markup, so case names in the sample are roman. The template italicizes `*...*` markdown, so a future sample can carry italics.
6. **The sample is a portion.** It transcribes the caption, the lead-in, the introduction and parties, the facts (¶¶ 1–23 of the filing), Counts I to III in full, and the closing request for relief and the jury demand. Count IV (filed pages 10 to 14) is not transcribed, so the sample's closing WHEREFORE follows Count III's WHEREFORE: the two read as adjacent in the render, and the sample's frontmatter comment says why.
7. **Paragraph numbers differ.** The template numbers allegations from 1 in the sample; the filed numbers run to 83 for the whole pleading. Not transcribed.
8. **Ragged right.** Body text is left aligned. The exemplar's justification could not be read from its text layer; this is a tier-2/3 choice and is not asserted.
9. **Signature block.** The exemplar's "~and~" between attorney groups is rendered as a plain line "and". The exemplar's "/s/" and bar-number lines are sample content.
10. **Not produced by this template.** The civil cover sheet (D.N.M.LR-Civ. 3.1), summons, and any Rule 7.1 disclosure statement are separate filings.
11. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at the court root, and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
12. **Headings must fit the layout.** Headings wrap and are kept with the paragraph after them; no heading is forced onto one line.

[Formbook index](../../../../../../README.md)
