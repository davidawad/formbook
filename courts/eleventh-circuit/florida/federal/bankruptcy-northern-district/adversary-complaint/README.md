# Adversary complaint, U.S. Bankruptcy Court, N.D. Florida (flnb)

Template for a complaint commencing an adversary proceeding. Engine: typst (`typst/`). Court folder for the tools: this directory.

## Rules applied (primary sources)

Verified 2026-10-14 against the Local Rules of the U.S. Bankruptcy Court, N.D. Fla. (effective Feb. 26, 2024; `https://www.flnb.uscourts.gov/sites/flnb/files/local_rules_02-26-2024.pdf`) and the Local Rules of the U.S. District Court, N.D. Fla. (PDF `https://www.flnd.uscourts.gov/sites/flnd/files/local_rules/local_rules_0.pdf`, stated effective Nov. 24, 2015).

| Requirement | Source | Template |
|---|---|---|
| District Local Rules apply in all bankruptcy cases, adversary proceedings included, unless inconsistent with a bankruptcy local rule | Bankr. N.D. Fla. LBR 1001-1(B)-(C) | Pulls the district 14-point and format rules in (next row) |
| 14-point font or larger; double spaced; at least one-inch margins on all four sides; pages numbered; case style, then heading | N.D. Fla. LR 5.1(B)-(C) | `font-family`/`type-size` 14 pt; double-spaced leading; 1 in margins; centred page number; caption then title |
| Signature block: attorney signature, typed name, bar number, street and email addresses, telephone; identify the party | N.D. Fla. LR 5.1(D) | Counsel block and signature block from frontmatter |
| Typeface: none named (LR 5.1 sets the size only) | `docs/FONTS.md`: no face named → EB Garamond | Typeface row: face required = none; font = **EB Garamond** (no substitution, so no metric claim) |
| Complaint commences with an adversary proceeding cover sheet; caption conforms substantially to the Official Form | Bankr. N.D. Fla. LBR 7001-1 | Caption uses the Official Form style (court, debtor case, adversary style); the cover sheet is a separate filing, not in this template (see gaps) |
| First page caption; designation of the party; title describes the contents; injunctive-relief words in the title if a Rule 7065 prayer is included | Bankr. N.D. Fla. LBR 9004-1(A)-(B) | Title from frontmatter (`title_lines`) |

No case-specific text, coordinates or forced line breaks are in the template: the caption, title, counsel block and signature lines come from the sample's frontmatter, and paragraphs are paragraphs.

## What the overlay shows

Sample: `samples/INPUT-ochlockonee.md` (transcription of the filed complaint, 10 pages, Doc 1 of Adv. No. 25-05002-KKS). Render: `samples/OUTPUT-ochlockonee.pdf` (9 pages). Overlay: `samples/OVERLAY-ochlockonee.pdf` (red = our render, blue = filed exemplar, black = both) with page map `samples/OVERLAY-ochlockonee.txt`.

- Line pitch matches the filing: about 32 pt baseline-to-baseline at 14 pt double-spaced (the filing is 32.2 pt).
- Layout: caption, title, numbered paragraphs, claim headings and subtitles, prayer, counsel and signature block all land in the same order as filed.
- Pagination differs: our render is 9 pages, the filing is 10. The overlay pairs pages by shared words, so later pages overlap less (word overlap per page: p1 94%, p2 88%, p3 83%, p4 68%, p5 59%, p6 74%, p7 59%, p8 50%, p9 61%). The overlap is text-pairing drift, not a rule failure.
- Fonts: the filing is Times New Roman; the rule names no face, so EB Garamond is used (see gaps). `pdffonts` on the render: EB Garamond Regular and Bold, embedded.

## Gaps

- **Font face (accepted, tier 2).** The local rule requires 14-point, not a face, so `docs/FONTS.md` keeps EB Garamond. The filed exemplar is Times New Roman; the vendored Times substitute is Liberation Serif (metric-compatible). Switching is a choice of the clerk-convention reading, not a rule requirement, so it is not made here. The visual difference is the overlay's largest colour difference.
- **Hanging paragraph numbers.** Paragraph numbers are typed as in the filing (`1)`), with a first-line indent. Filing numbers are not auto-generated, so a paragraph inserted into a transcription must be renumbered by hand.
- **Adversary cover sheet** (LBR 7001-1; Official Form B 1040) and **summons** are separate filings and are not part of this template.
- **Filed-text quirks** are transcribed as filed: the third claim heading reads "III. VI. THIRD CLAIM FOR RELIEF" (filing error), and sub-items (a)-(e) are plain paragraphs.
- **Second filer not used.** White Wilson Medical Center, PA v. Austin Business Finance LLC (Adv. 25-04007-KKS, 20 pp.) was located, but it is a complaint for temporary injunctive relief that starts with the Official Form cover sheet, so it is recorded in `exemplars/SOURCE.md` and not used for overlay.
- **Pages reviewed.** All 9 pages of the final render were viewed as PNG (montages at 70-80 dpi): pages 1, 5, 6 and 9, then pages 2, 3, 4, 7 and 8, after the layout fixes (heading stickiness, caption column).

[Court index](../README.md)
