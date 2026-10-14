# wawb: motion-brief

Doc type: **motion with a combined memorandum of law** (LBR 9013-1(c)(3)(A): the notice is the first part of the text) in the United States Bankruptcy Court for the Western District of Washington (`wawb`).
Folder: `courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes. Primary: `exemplars/FILED-EXAMPLE-smith-24-10218-motion-brief.pdf` (19 pp., Debtor's motion and memorandum, William C. Budigan). Second filer: `exemplars/FILED-EXAMPLE-pigida-14-01248-motion-brief.pdf` (15 pp., memorandum in support of partial summary judgment, The Rigby Law Firm; filed 2015 under the old rules). Both re-downloaded 2026-10-14 from the URLs in `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-smith-motion-memorandum.md`: transcription of exemplar pp. 1 to 11 and 17 to 18 (notation, caption, motion, memorandum, signature, certificate of service). Pages 12 to 16 and 19 are not transcribed; see Known gaps. |
| render | ok: `samples/OUTPUT-smith-motion-memorandum.pdf`, 12 pages, Letter, typst 0.15.0 through `tools/render.sh`, no typst warnings, fonts: EB Garamond Regular, Bold and Italic only (`pdffonts`, all embedded). |
| overlay | ok: `samples/OVERLAY-smith-motion-memorandum.pdf` and `samples/OVERLAY-smith-motion-memorandum.txt` (page map), against the Smith exemplar. |
| pages reviewed | 12 of 12: every page rasterized at 80 dpi and viewed in the final render (after the caption and signature fixes, all pages were viewed again). |

Commands (from the repo root):

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief samples/INPUT-smith-motion-memorandum.md
sh tools/overlay.sh courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief smith-motion-memorandum courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief/exemplars/FILED-EXAMPLE-smith-24-10218-motion-brief.pdf
```

The overlay tool's default exemplar is the first PDF in `exemplars/` alphabetically, which is the Pigida filing. The Smith exemplar is passed explicitly because it is the one the sample was transcribed from.

## Governing rules

Verified 2026-10-14. Primary source: the W.D. Wash. Local Bankruptcy Rules, "Effective Dec. 1, 2023" (court PDF, https://www.wawb.uscourts.gov/sites/wawb/files/attachments/2023%20rules.clean%20-23.10.27%20FINAL.pdf, pp. 34 to 38 of the PDF: LBR 9004-1 and LBR 9013-1). Secondary, for the notation and length conventions only: the court's "Motion Practice" primer, https://www.wawb.uscourts.gov/sites/wawb/files/MotionsPracticePrimer.pdf. I did not check whether any 2026 amendment changes LBR 9004-1 or 9013-1(c) or (d); if one does, re-verify before the next render.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LBR 9004-1(a) (M) | 8-1/2 x 11; standard embedded font, 11 or 12 point; double spaced. | `page-w`, `page-h`; `type-size = 12pt`; `pitch = 24pt` (double spacing); `footer-size = 11pt`. |
| LBR 9004-1(b)(1) (M) | Numbered paper: line numbers in the left margin. | `line-numbers()`: 28 numbered lines. The filed exemplar (Smith) has none; the template follows the rule. |
| LBR 9004-1(b)(2) (M) | Judge's name at the right side of the top of the front page. | `notation()`: judge at top right. |
| LBR 9013-1(d)(1)(B) (M) | On the motion, notice, response and reply: judge, chapter, location, date and time of hearing, and response date, in the top right-hand corner. | `notation()`: chapter, hearing location, date, time, response date (from the frontmatter `hearing`). |
| LBR 9004-1(b)(3) (M) | Bottom left: abbreviated title and page number. Bottom right: name, address and telephone of the attorney or firm. | `footer-block()`: `footer_title` and page number; `footer_counsel` at right. |
| LBR 9013-1(c)(3)(A) (M) | Notice combined with the motion: the caption says so, the notice is the first part of the text, the parts are separately headed. | Caption title and the frontmatter `brief_title` name the memorandum in support; the text opens with the notice-and-motion paragraph ("COMES NOW ... moves the Court ... and states as follows"). |
| LBR 9013-1(c)(3)(B) (M) | The notice states the hearing date, time and place, the relief and grounds, that a response must be filed by the response date, and that if none is filed the court may grant the motion without further notice. | Hearing and response data: yes (notation). The response-consequence sentences: not in the sample; see Known gaps. |
| LBR 9013-1(d)(1)(A) (M) | Motion includes the statement of reasons and memorandum of points and authorities; affidavits and declarations are filed with it. | Body: motion, then memorandum headings. Declaration: not in the sample (see Known gaps). |
| LBR 9013-1(d)(1)(C) (M) | Opening memoranda: 12 pages for motions other than summary judgment or other dispositive motions; 24 pages for dispositive motions, without prior approval. | Not enforced; see Known gaps. |
| LBR 9013-1(d)(1)(D) (M) | Proposed order attached as a separate exhibit (not in this template). | Not produced by this template. |

Tier-2 conventions, checked against both filed exemplars (both use these; the template follows them):

- Judge's name and hearing notation at the top right of page 1 (Smith and Pigida).
- A ")" column between the party names and the case number and title on the right, with the rule under the party column (Smith and Pigida).
- Court title centered in capitals above the caption (Smith and Pigida).
- Bottom notation, counsel at right: LBR 9004-1(b)(3) requires it. Only the Pigida filing prints it; the Smith filing has the page number alone at the foot. The template follows the rule.

## Layout

- Page 1: notation top right (lines 1 to 6); court title on lines 7 to 9; caption on lines 11 to 19 (debtor block with one ")" per line, the case number and the title at right); the notice-and-motion paragraph follows.
- Body: double spaced on the 24 pt grid; first-line indent; no paragraph numbers (LBR 9013-1 does not number them and neither exemplar numbers the motion paragraphs). Level-1 headings centered in bold capitals (RELIEF REQUESTED, MEMORANDUM OF LAW, CERTIFICATE OF SERVICE); level-2 headings bold, left aligned; level-3 italic. Block quotations are indented 0.5 in on both sides and double spaced (see Known gaps). Lists are bulleted.
- Signature: the paragraph beginning "Dated:" is kept whole on one page (`blocks()`), so the signature never splits.
- Certificate of service: the transcribed certificate, with the party list. The party list is in the markdown body with hard line breaks.

## What the overlay shows

Red = our render, blue = the filed exemplar, black = both. The page map pairs each sample page with the exemplar page sharing the most words (`OVERLAY-smith-motion-memorandum.txt`):

| ours | filed | word overlap |
|---|---|---|
| p.1 | p.1 | 82.9% |
| p.2 | p.2 | 85.0% |
| p.3 | p.3 | 75.4% |
| p.4 | p.4 | 54.4% |
| p.5 | p.5 | 43.3% |
| p.6 | p.5 | 50.0% |
| p.7 | p.6 | 57.7% |
| p.8 | p.7 | 48.5% |
| p.9 | p.8 | 66.6% |
| p.10 | p.9 | 78.9% |
| p.11 | p.10 | 67.6% |
| p.12 | p.18 | 59.5% |

The overlay is a diagnostic, not a score. Pages 1 to 3 agree most closely: the notation, the caption and the first body pages. Pages 4 to 8 pair by shared words, and the memorandum's citations and block quotations split differently from the filing, so the pairing is weaker there (ours p.6 pairs with filed p.5). I did not check every word on those pages against the filing; the text was transcribed from the public text layer. Page 12 pairs with filed page 18: the signature and certificate, which the filing sets at its end. The overlay also shows the line numbers and the bottom counsel block, which the filing lacks: the template follows LBR 9004-1(b)(1) and (b)(3), the filing does not.

## Page review

- Page 1: notation top right, court title, caption with ")" column and case number and title, the notice-and-motion paragraph and the start of the background list. Pass.
- Page 2: background list (continued), RELIEF REQUESTED, the arrears and accelerated-amount paragraphs. Pass.
- Page 3: the reduction request, "As explained below", MEMORANDUM OF LAW and the first statute-of-limitations paragraphs. Pass.
- Page 4: Citing line, the acceleration heading (two lines, kept with its paragraph), Merritt block quotation. Pass.
- Page 5: POLICY heading, LUV block quotation, "Impact of bankruptcy Filing" heading, the Johnson and Dewsnup quotation. Pass.
- Page 6: discharge paragraph, the stay paragraph, "Washington state laws" and the RCW 4.16.230 block quotation (kept on one page). Pass.
- Page 7: "Impact of US Bankruptcy laws", the Hazel facts, the court's ruling. Pass.
- Page 8: 11 U.S.C. 108(c) block quotation and the Thurman analysis. Pass.
- Page 9: the minority-jurisdiction and Ninth Circuit paragraphs and the Southern Cal. Plastics quotation. Pass.
- Page 10: Southern Cal. Plastics (continued), Hazel conclusion, FIRST MORTGAGE HISTORY heading (two lines, kept with its paragraph), loan transfer paragraphs. Pass.
- Page 11: YEARS IN BANKRUPTCY heading, bankruptcy history, the three-item gap list, the omitted-table note. Lines 25 to 28 are empty because the signature block moves to page 12 as one unit. Pass (accepted: the signature block is kept whole by design).
- Page 12: signature block, CERTIFICATE OF SERVICE, the declaration and the party list. Pass.

## Known gaps

1. **Length (LBR 9013-1(d)(1)(C), M).** The template does not count pages or decide whether the motion is dispositive. The sample renders to 12 pages including the notice, the certificate and the party list. The filed exemplar's memorandum runs past 12 pages (the filing is 19 pages). If this is a non-dispositive motion, the memorandum needs prior court approval to exceed 12 pages; if it is dispositive, the limit is 24. Counsel decides which. This is the author's responsibility (A).
2. **Notice text (LBR 9013-1(c)(3)(B), M).** The notice must say that a response must be filed by the response date and that if none is filed the court may grant the motion before the hearing without further notice. The sample does not say so: the filed exemplar does not either. The template cannot add it. This is the author's responsibility (A).
3. **Declaration and proposed order (LBR 9013-1(d)(1)(A), (d)(1)(D), M).** The sample does not include a declaration of the debtor, although the certificate's title names one; the transcription did not reach the filing's declaration pages. The proposed order is a separate exhibit under LBR 9013-1(d)(1)(D) and is not produced by this template.
4. **Transcription omissions.** Not transcribed: the recording-history table (exemplar pp. 10 and 11; replaced by a bracketed note in the sample), the foreclosure-cost analysis and exhibit arithmetic (exemplar pp. 12 to 16), and the declaration (p. 19). The sample ends with the certificate of service.
5. **Block quotations double spaced.** LBR 9004-1(a) says all pleadings are double spaced, so the template double spaces block quotations. The filer single-spaces them. This is a tier-2 choice I resolved toward the rule; if the court's clerks accept single-spaced block quotations, change `quote-indent` handling in `typst/wawb-motion-brief.typ`.
6. **Pleading line count.** LBR 9004-1(b)(1) requires line numbers but does not say how many. 28 lines follows the sibling complaint template in this court; it is not set by the rule.
7. **Caption entries.** The debtor names are split into one frontmatter entry per line (`MELANIE A SMITH`, `*aka* M A SMITH`, `*aka* M SMITH,`) so that each ")" lines up with one name line. This is sample data, not a template break.
8. **Second filer not overlaid.** The Pigida filing (2015) was used for the tier-2 cross-check of the notation, caption and bottom notation. It is not overlaid because its pleading format predates the 2023 rules.
9. **Gate 2 record.** No `reviews/` file for this doc type. The page review above is the visual check; it is not a recorded Gate 2 review.
10. **Adversary complaint.** The sibling `adversary-complaint/` folder has no `OUTPUT` or `OVERLAY` PDF and no `README` outputs in `samples/`. Not touched in this change.
