# laeb: adversary complaint

Doc type: **adversary complaint** (commencing an adversary proceeding) in the United States Bankruptcy Court for the Eastern District of Louisiana (`laeb`).
Folder: `courts/fifth-circuit/louisiana/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (a portion of the complaint: caption, lead-in, jurisdiction, parties, background, Counts I, II and X, prayer, signature; see gap 9) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-babin-crescent-complaint.pdf` and `usage/OVERLAY-babin-crescent-complaint.txt` |
| typeface | EB Garamond, 12 pt. No rule names a face, so `docs/FONTS.md` "No face named" applies and the template keeps EB Garamond (gap 2) |
| pages reviewed | 8 of 8 (re-rendered and every page viewed at 60 dpi on 2026-10-14, fonts pass; output unchanged) |
| BLOCKED | none |

File names: the brief's `usage/<id>.md` and `usage/<id>-overlay.pdf` are written as `INPUT-<id>.md` and `OVERLAY-<id>.pdf/.txt`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default (CLAUDE.md, "File roles are in the name").

## Governing rules

Primary sources, fetched 2026-10-14 (LII text for the federal rules; the court's own PDF for the local rules).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7003 | "Fed. R. Civ. P. 3 applies in an adversary proceeding" (commencement by filing a complaint). https://www.law.cornell.edu/rules/frbp/rule_7003 (as amended Dec. 1, 2024) | The complaint is the document; no template text beyond the caption. |
| Fed. R. Bankr. P. 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding—except that a pleading's caption must substantially conform to the appropriate version of Form 416." https://www.law.cornell.edu/rules/frbp/rule_7010 (as amended Dec. 1, 2024) | `caption()`: court title, parties, case information; `title` frontmatter ("COMPLAINT"). |
| Fed. R. Civ. P. 10(a), via 7010 | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." Title names all parties. https://www.law.cornell.edu/rules/frcp/rule_10 (as amended Dec. 1, 2007) | Court title (`court-lines`), `caption.parties` (all parties, designations), `case_info` (case number, chapter, section, adversary number). |
| Fed. R. Civ. P. 10(b), via 7010 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered by the template; headings, lists and quotations are not. |
| Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." https://www.law.cornell.edu/rules/frbp/rule_9004 (as amended Dec. 1, 2024) | Vendored EB Garamond at 12 pt, black on white; no compressed type. |
| Fed. R. Bankr. P. 9004(b) | Caption: court name, case title, case number (and adversary number), and a brief designation of the document. | As 10(a) above. |
| E.D. La. Local Rules, Part VII (adversary proceedings), 7004-1 | Summons issued under the Administrative Procedures Manual; plaintiff serves the summons and complaint. Rule 7004-1 concerns service, not the complaint's form. https://www.laeb.uscourts.gov/sites/laeb/files/local_rules/LocalRules050113.pdf (rules adopted May 1, 2013) | Not template text. |
| E.D. La. Local Rules, general | No rule on paper size, typeface, margins, line spacing or cover pages for pleadings was found in the 2013 Local Rules (text searched for "pleading", "paper", "font", "point", "margin", "spac", "caption"; only Local Forms, Rule G, bear on form: a deviation from a Local Form is set in bold 12-point type). | Typography is a convention, see gap 2. |
| E.D. La. Clerk's Notes, "Font Size" (copy retrieved 2026-10-14: https://www.laeb.uscourts.gov/sites/laeb/files/ClerksNotes704.pdf; undated), citing LBR 5005-3 | Motions, applications, memoranda and judgments/orders "must be typed or written in a size format that is sufficient to read without difficulty." Names no face. LBR 5005-3 is not in the 2013 Local Rules copy, so its current text was not read. | Vendored EB Garamond at 12 pt (gap 2). |

Not produced by this template (separate filings or court-generated, not part of the complaint body):
- Adversary Proceeding Cover Sheet, Official Form 1040 (the exemplar's pp. 1-2; CM/ECF captures it at e-filing). Filed with the complaint; not generated.
- The ECF header line ("Case 24-01028 Doc 1 Filed ... Page 1 of 19"), which the court's system adds on filing. Not generated.
- Summons (Local Rule 7004-1; Administrative Procedures Manual), civil cover sheet, Rule 7.1 disclosure statement, and the signed exhibits (Exhibit A is the MSA in the exemplar).

## Layout

- Letter paper; 1-inch margins; body double-spaced (24 pt line pitch at 12 pt, from `body-leading`); single-spaced caption, counsel and signature.
- Caption: court title centered and bold on two lines; a left party column closed by a rule at its right edge; case information (case number, chapter, section, adversary number) at right. Parties are separated by a blank line; "v." between parties unless the sample gives `sep: ""` (a debtor's line, and a plaintiff named with the debtor). The exemplar uses an asterisk column; the rule is a convention (gap 3).
- Title "COMPLAINT" centered and bold under the caption. Lead-in paragraph (unnumbered) when given.
- Numbered paragraphs (number at the 0.5-inch indent, text after it). Headings: level 1 centered caps, level 2 centered bold, level 3 centered bold (the exemplar's "Allegations Regarding the A0392 Well" are centered bold). A heading keeps the paragraph after it (sticky) and has one blank line above it.
- Block quotation: indented 0.5 inch both sides, not numbered.
- Lists: items lettered (a), (b), ... (the prayer, and the lists inside counts).
- Footnotes: `text[^key]` with a `[^key]: ...` definition anywhere in the body; the footnote text uses typst's default footnote size.
- Signature block: "Respectfully submitted," then `BY: /s/ <name>` and each counsel block single-spaced on the right half; blocks separated by "And". The block does not break across pages.
- Footer: "Page X of Y" centered, 11 pt.

## Overlay (`usage/OVERLAY-babin-crescent-complaint.pdf`)

`tools/overlay.sh` pairs our pages with the best-matching exemplar pages by shared words (`OVERLAY-babin-crescent-complaint.txt`):

| ours | filed | word overlap |
|---|---|---|
| p.1 | p.3 | 59.7% |
| p.2 | p.5 | 60.5% |
| p.3 | p.6 | 69.6% |
| p.4 | p.7 | 55.4% |
| p.5 | p.9 | 50.3% |
| p.6 | p.11 | 72.5% |
| p.7 | p.17 | 47.8% |
| p.8 | p.19 | 80.2% |

What the overlay shows, as a diagnostic (not a score):
- Page 1: the court title and the caption fall in about the same area as the exemplar's. The blue line across the top is the exemplar's CM/ECF header (not generated, see Governing rules).
- The sample is a portion of the complaint and skips paragraphs, so a sample page can pair with a later exemplar page (our p.7 pairs with filed p.17). The exemplar's pp. 1-2 are the cover sheet, so our p.1 pairs with filed p.3.
- Paragraph numbers differ: the template numbers allegations 1, 2, ... in order, and the filed numbers are not transcribed (the sample omits ¶¶ 21-25 and Counts III-IX), so the numbers do not line up with the exemplar's.
- Typeface: EB Garamond in the template, Times New Roman in the exemplar. The overlaid text looks smaller in ours (gap 2).

## Gate 2 review (pages rendered at 60 dpi and viewed)

- Page 1: court title, caption (debtor, plaintiff, defendants, case information), "COMPLAINT", lead-in, "JURISDICTION AND VENUE", paragraphs 1-6, footnote 1. Pass. (Fixed in this pass: court title lines overlapped; the caption had no blank line between the debtor and the plaintiff.)
- Page 2: "FACTUAL & PROCEDURAL BACKGROUND", ¶¶ 7-10, "The Crescent/Martin Relationship". Pass.
- Page 3: ¶ 11 with the block quotation of MSA ¶ 5.2 (indented, not numbered; fixed in this pass, it had been numbered as ¶ 12), ¶¶ 12-14. Pass.
- Page 4: ¶ 14 continues, ¶¶ 15-17, "COUNT I", "BREACH OF CONTRACT", ¶¶ 18-20 and list (a). Pass.
- Page 5: list (b)-(c), ¶ 21 with list (a)-(c), ¶¶ 22-25. Pass.
- Page 6: "COUNT II" and "NEGLIGENCE", ¶¶ 26-34, the two sub-headings centered bold. Pass.
- Page 7: ¶ 35, "COUNT X", "OBJECTION(S) TO CDF CLAIM", ¶¶ 36-39, "PRAYER FOR RELIEF", ¶ 40 and list (a)-(e). Pass.
- Page 8: list (f)-(k), signature block (both counsel blocks, "And" between). The signature block sits alone on page 8 (gap 4). Pass with that note.

## Known gaps and open choices

1. **One exemplar; tier 2 needs 2 or 3 filers.** The brief asks for one exemplar per doc type. A second adversary complaint was found and checked for text (Crosby Tugs v. Pelican Marine, Adv. 26-01083, 6 pages, filed 2026-10-12; RECAP `gov.uscourts.laeb.211046.1.0.pdf`), and a third (Brown v. Burmaster, Adv. 23-01032, 5 pages, `gov.uscourts.laeb.202033.1.0.pdf`). Neither is saved. Tier 2 is therefore **not** judged against 2 or 3 filers yet.
2. **Font: no face required; EB Garamond kept.** The 2013 Local Rules and the Clerk's Notes (LBR 5005-3, a size-and-legibility rule) name no typeface, so `docs/FONTS.md` "No face named" applies and the template keeps EB Garamond. The filed exemplar is Times New Roman, but the exemplar only settles what the rules leave open. EB Garamond at 12 pt reads smaller than Times at 12 pt, so the overlay text looks smaller. Whether tier 2 wants a Times-metric face (`Liberation Serif`, metric-compatible) is a question for David. If the current LBR 5005-3 text names a face, switch the font list to the `docs/FONTS.md` substitute.
3. **Caption column.** The exemplar closes its party column with asterisks; the template uses a rule at the column's right edge (the form used in cand). Both are seen in practice; recorded as a convention.
4. **Signature block alone on a page** (page 8 of the sample). The signature block does not break and moves whole to the next page when the prayer ends near the foot of page 7. The real filing keeps the signature with the prayer; a template fix would keep the last prayer item with the signature. Not fixed in this pass.
5. **Not generated:** Official Form 1040 cover sheet, CM/ECF header, summons, civil cover sheet, Rule 7.1 statement, exhibits (see Governing rules).
6. **The joint-administration footnote** in the Crosby caption is not supported in the caption block (footnotes work in body text only). Not used by this sample.
7. **Local Rules currency.** The only E.D. La. Local Rules copy retrieved is the 2013 version (adopted May 1, 2013, `LocalRules050113.pdf`). The court's current rules and its Administrative Procedures Manual (which governs summonses and filing format) could not be retrieved: the court's site returned only navigation for those pages. Before this doc type is marked done, check the current rules for a pleading-format rule.
8. **Paragraph numbering** is automatic and does not match the filed numbers (the sample numbers from 1).
9. **Sample is a portion.** The sample transcribes the caption, lead-in, ¶¶ 1-20 (the first sections), Counts I, II and X, and the prayer and signature; it omits ¶¶ 21-25 of the background/H&D section and Counts III-IX, which are not needed to test the form. The rendered length (8 pages) is at the low end of the 8-14 target because the exemplar's complaint is 17 pages with a long factual section.
10. **Check scripts not run.** `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Engines

docx: `docx/build-reference.sh` writes `docx/reference.docx`; `docx/laeb-complaint.lua` builds the caption, court title, title, signature block, numbered allegations and lettered lists. Rendered with `tools/render.sh --engine docx`.

- Matches the typst form: EB Garamond 12 pt (vendored, embedded), 24 pt exact double spacing with no extra space between paragraphs (measured against the typst line grid), 1 in margins on letter paper, caption with a rule at the party column's right edge, centered bold headings, numbered allegations (number at 0.5 in, text from a tab stop at 0.8 in), lettered lists (a), (b) with a hanging indent, block quotations single spaced and indented 0.5 in on both sides, single-spaced signature block at 3 in, footnotes 10 pt, footer "Page X of Y" at 11 pt (PAGE and NUMPAGES fields).
- Differs: 8 pages in both. Pages 1 to 3 break a few lines differently (LibreOffice moves the paragraph that carries footnote 1 to page 2; typst keeps two of its lines on page 1), so later pages start at different lines. LibreOffice places exact-spaced lines about 11 pt lower than typst on each page. The numbers and letters are literal text written by the filter, not Word list numbering, so they do not renumber if a paragraph is moved by hand.
- Checked in LibreOffice only: the .docx converted without error. Word was not available and was not checked.

BLOCKED: none
