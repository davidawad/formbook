# flnd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Florida (`flnd`).
Folder: `courts/eleventh-circuit/florida/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`: the whole 9-page complaint, transcribed (word-diff against the filing: body text identical; differences are caption, title, signature and running headers, which the frontmatter or the template supplies) |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only (pdffonts), no warnings |
| overlay | ok: `usage/OVERLAY-winton-complaint.pdf` and `OVERLAY-winton-complaint.txt` |
| typeface | face required: **none named** (Loc. R. 5.1(C) says "at least 14-point font"; checked 2026-10-14 against the local rules PDF). Substitute: none; **EB Garamond** kept, as `docs/FONTS.md` "No face named" requires. Not metric-compatible with the exemplar's Times New Roman (known gap 2). |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change; re-checked 2026-10-14 after the fonts pass, same 9 pages, same overlay map) |
| BLOCKED | none (an exemplar was found) |

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| N.D. Fla. Loc. R. 5.1(B) | The first page begins with the case style: court name, case number including the assigned judges' initials, at least one party on each side; then a heading that identifies the document. Source: https://flnd.uscourts.gov/sites/flnd/files/local_rules/local_rules_0.pdf (the court's local rules PDF; the copy fetched has a 2015 revision date on its file metadata, see known gap 1). | `court-title`, `caption` (case number with judge initials in frontmatter `case_number`), title in `brief_title`. |
| N.D. Fla. Loc. R. 5.1(C) | Double spaced; at least 14-point font; at least one-inch margins on all four sides; pages numbered. Same source. | `type-size = 14pt` everywhere (footer included), `pitch = 32.2pt` (measured on the filed exemplars), `margin: 1in`, centered page number footer. |
| N.D. Fla. Loc. R. 5.1(D) | Attorney signature block: handwritten or electronic signature, typed name, bar number, street and email addresses, telephone; identifies the party. Same source. | `signature-block`: `signature.by`, `signature.lines` (name, bar numbers, firm, address, telephone, email, "Attorney for ..."). |
| N.D. Fla. Loc. R. 5.1(F) | Certificate of service, except where the document is served only through the electronic system on counsel who have appeared, or served by formal process (a complaint: summons). Same source. | Not in the complaint template: a complaint is served with a summons under Fed. R. Civ. P. 4, which 5.1(F)(1)(b) excepts. |
| Fed. R. Civ. P. 8(a)(1)-(3) | Short and plain statement of jurisdiction, of the claim, and a demand for relief. Fetched from https://www.law.cornell.edu/rules/frcp/rule_8 on 2026-10-14 (amended eff. Dec. 1, 2010). | Content (the sample's jurisdiction, claims and prayer); the template does not check the wording. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the title names all parties. Fetched from https://www.law.cornell.edu/rules/frcp/rule_10 on 2026-10-14 (amended eff. Dec. 1, 2007). | `court-title`, `caption` (all parties in `caption.parties`), `brief_title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. Same source. | `allegations()`: each body paragraph is numbered by the template; headings, lists and the WHEREFORE clause are not numbered. |

Not produced by this template (separate filings, not part of the complaint, not verified here): the civil cover sheet (Form JS 44); the Rule 7.1 disclosure statement; the summons.

## Layout

- Letter paper, one-inch margins, 14-point EB Garamond, double spaced at a 32.2 pt baseline pitch (measured on the exemplar: Winton p. 3, 32.2 pt; the template reproduces it, verified on p. 3 of the render).
- Court name, division (from frontmatter `division`), centered bold, single spaced.
- Caption: parties on the left, closed by a rule at the foot of the party column; "CASE NO." and the number on the right; "v." between parties.
- Title centered bold; the lead-in paragraph (unnumbered, frontmatter `lead_in`) follows it.
- Numbered paragraphs (1 to 37 in the sample, matching the filing), first-line indent 0.5 in, number then a 0.4 in gap.
- Level-1 headings (`#`): centered bold capitals. Level-2 (`##`): count headings, centered bold. Level-3 (`###`): count subtitle, centered bold.
- Lists (`1.`): roman numerals (i., ii., ...), used for the damages list in paragraph 25.
- A paragraph beginning WHEREFORE is unnumbered (the prayer), as in the filed complaint.
- Signature block: date on the left; "Respectfully submitted," and the signing attorney's block on the right. Single spaced.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number` (with judge initials), `division`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `lead_in` (optional, unnumbered), `date`, `signature` (`firm` lines, `by` line, `lines`).
- Body: blank-line-separated chunks. `#`, `##`, `###` headings; `1.` lists; paragraphs (numbered unless they begin WHEREFORE). Italic with `*...*`.
- The sample must not put numbering in the text: the template numbers the paragraphs.

## What the overlay shows

`usage/OVERLAY-winton-complaint.pdf` (red = our render, blue = filed exemplar, black = both). The page map in `OVERLAY-winton-complaint.txt`:

    ours p.1 filed p.1 (86.6%)  p.2/p.2 (81.7%)  p.3/p.3 (79.1%)  p.4/p.4 (91.7%)  p.5/p.5 (93.5%)
    p.6/p.6 (73.8%)  p.7/p.8 (67.7%)  p.8/p.8 (65.3%)  p.9/p.9 (85.7%)

The overlay pairs pages by shared words, so it is a diagnostic. Our pages 7 and 8 both pair with the filed page 8: the text breaks fall at different places, so the best word match for both is the same filed page. Line positions use the same 32.2 pt pitch on both sides. The overlay is not a score.

## Gate 2 review (every page of the current PDF, at 60 dpi)

| Page | Review |
|---|---|
| 1 | Court title, caption (parties left, CASE NO. right), title, lead-in, heading and paragraphs 1 to 2 on the numbered pitch. Pass. |
| 2 | Paragraphs 3 to 6, JURISDICTION, VENUE, AND PARTIES heading kept with paragraph 5. No overlap. Pass. |
| 3 | Paragraphs 7 to 14, FACTUAL ALLEGATIONS heading. Pass. |
| 4 | Paragraphs 15 to 20 (the tracking numbers are in the filing's text). Pass. |
| 5 | Paragraphs 21 to 25, the damages list begins (i. to iii.). Pass. |
| 6 | List items iv. to vi., CAUSES OF ACTION, COUNT I heading and subtitle, paragraphs 26 to 28. Pass. |
| 7 | Paragraphs 29 to 31, WHEREFORE (count I), COUNT II heading and paragraph 32. Pass. |
| 8 | Paragraphs 33 to 37 and the start of the WHEREFORE clause. Pass. |
| 9 | End of WHEREFORE, PRAYER FOR RELIEF heading, WHEREFORE paragraph, "Dated", "Respectfully submitted," signature block (signer and "Attorney for Plaintiff" italic). Pass. |

Fixed during review: (1) paragraphs ran together on one line (per-paragraph blocks), (2) paragraphs and headings overlapped (block heights do not include the leading after the last line; paragraph and heading spacing set to the leading), (3) caption and court-title lines overlapped (stack spacing), (4) the case number wrapped at a hyphen (CASE NO. on its own line).

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search (CourtListener API, `type=r`, `court=flnd`, complaints filed 2026-05 to 2026-10) found recent complaints from other filers (Desantis v. Collection Management Co., 5:26-cv-00278; Adessi v. Bystrom, 5:26-cv-00266; Altitude Property Management v. Unhitched RV Park, 3:26-cv-04969; Langla v. Pfizer, 3:26-cv-04852; Griffin v. Clarity Services, 4:26-cv-00353; Guman v. Beech-Nut, 3:26-cv-03762). None was downloaded and checked beyond the list. Tier 2 is **not** judged against two filers yet.
2. **Font size and face.** The rule requires 14 point and names no face. The exemplar is Times New Roman 14 pt, which is the filer's choice; the template uses EB Garamond 14 pt, as `docs/FONTS.md` ("No face named") requires. EB Garamond has a smaller x-height, so the text looks smaller than the exemplar at the same point size. The point size meets the rule; the look is a tier-2 difference, ACCEPTED. A Liberation Serif (Times-metric) template would look closer to the exemplar but is not required by the rule.
3. **Double spacing read.** The body is double spaced at the exemplar's measured pitch. The caption, the court title, the signature block and the single-line party names are single spaced (customary in N.D. Fla. filings; the rule text does not say). Recorded as an interpretation.
4. **Caption.** The party column is closed by a rule at its foot (the exemplar has the same closing rule and no ")" column). Florida filings often use a line of underscores ending in "/"; the rule is a tier-2 convention choice, ACCEPTED.
5. **Footer.** The footer carries only the page number. The ECF header of the filed exemplar is added by the court system and is not reproduced.
6. **Paragraph numbers.** The sample's paragraphs run 1 to 37, which equals the filing's numbering. The template numbers the paragraphs itself; a different filing with unnumbered recitals would need the markdown to carry them as unnumbered (the WHEREFORE rule does this for prayers only).
7. **Telephone number.** Loc. R. 5.1(D) requires a telephone number in the signature block; the sample carries one because the filing does.
8. **No gate scripts run.** `tools/check.sh` reads a court folder with `court.json` and `checks.yaml`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render, overlay and the page review above are the checks run.
9. **Local rules version.** The local rules fetched on 2026-10-14 are the court's posted PDF (its file metadata gives a November 2015 creation date and the text cites the 2015 revision). A Florida Bar News item reports "major revisions" planned for N.D. Fla. rules; I did not confirm whether any later amendment changed Rules 5.1 or 7.1. David should check the court's current local rules before this is used as the reference.

## Engines

typst (`typst/`) is the reference. The docx engine (`docx/`) follows it; the LaTeX engine is not built for this doc type.

| Engine | Output (`usage/`) | Status |
|---|---|---|
| typst | `OUTPUT-complaint.typst.pdf` (9 pp) | reference |
| docx | `OUTPUT-complaint.docx` and `OUTPUT-flnd-complaint-winton.docx.pdf` (9 pp) | ok: rendered with LibreOffice 26.8.1; every page compared with the typst page at 60 dpi |

```sh
sh tools/render.sh --engine docx courts/eleventh-circuit/florida/federal/northern-district/complaint usage/INPUT-complaint.md
```

`docx/reference.docx` is built by `docx/make-reference.sh` (pandoc's default reference, restyled); `docx/render.sh` runs pandoc on the sample; `docx/flnd-complaint.lua` builds the cover, the numbering, the lists and the signature block. The sample is read as CommonMark with smart punctuation, the reading typst's cmarker gives (pandoc's markdown reader pairs a star page's `*` with a later `*` and adds a no-break space after "No.").

- *Matches typst:* EB Garamond 14 pt everywhere, including the footer (embedded; `pdffonts` shows only EB Garamond); US Letter with 1-inch margins; body double spaced at the 32.2 pt pitch; cover lines at 16 pt; the caption (parties, closing rule, CASE NO., "v." between parties); the title; numbered allegations with the WHEREFORE paragraph unnumbered; roman-numbered list (i. to vi.) with the typst indents; headings in capitals or bold centered, at typst's default sizes (level 1 19.5 pt, level 2 17 pt, level 3 14 pt); signature block (date at left; "Respectfully submitted,"; firm; signer) with typst's gaps; centered page number at the foot. Page count is 9 in both. Lines break at the same words on most lines.
- *Differs:* some lines break one word earlier or later (LibreOffice and typst shape text differently; DOCX.md "Known limits"), so a page break can fall a line or two apart from typst's. The cover sits about 3 pt lower than typst's. Paragraph numbers 10 and up set their text at the same tab stop as 1 to 9 (1.04 in); typst's gap follows the width of the number.
- *Not checked:* not opened in Microsoft Word (none on this box). LibreOffice converts it with no warning. The gate scripts were not run: `tools/check.sh` needs `court.json` and `checks.yaml`, which this doc-type folder does not have (see "Gate 2 review" above and known gap 8).
- *docx BLOCKED items:* none. LibreOffice is not on conda-forge; the official build (26.8.1, from download.documentfoundation.org) was used instead, with its X11 libraries from conda-forge. The `.docx.pdf` checks therefore ran.

[Court README](../README.md) | [Motion-brief README](../motion-brief/README.md)
