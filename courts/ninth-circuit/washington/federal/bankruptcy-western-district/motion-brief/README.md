# wawb: motion-brief

Doc type: **motion with a combined memorandum of law** (LBR 9013-1(c)(3)(A): the notice is the first part of the text) in the United States Bankruptcy Court for the Western District of Washington (`wawb`).
Folder: `courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes. Primary: `usage/FILED-EXAMPLE-motion-brief.pdf` (19 pp., Debtor's motion and memorandum, William C. Budigan). Second filer: `usage/FILED-EXAMPLE-motion-brief-2.pdf` (15 pp., memorandum in support of partial summary judgment, The Rigby Law Firm; filed 2015 under the old rules). Both re-downloaded 2026-10-14 from the URLs in `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: transcription of exemplar pp. 1 to 11 and 17 to 18 (notation, caption, motion, memorandum, signature, certificate of service). Pages 12 to 16 and 19 are not transcribed; see Known gaps. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 14 pages, Letter, typst 0.15.0 through `tools/render.sh`, no typst warnings, vendored Times New Roman only (all embedded); docx `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`, 14 pages (see Engines). |
| overlay | ok: `usage/OVERLAY-smith-motion-memorandum.pdf` and `usage/OVERLAY-smith-motion-memorandum.txt` (page map), against the Smith exemplar. |
| pages reviewed | 12 of 12: every page rasterized at 80 dpi and viewed in the final render (after the caption and signature fixes, all pages were viewed again). |

Commands (from the repo root):

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief smith-motion-memorandum courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief/usage/FILED-EXAMPLE-motion-brief.pdf
```

The overlay tool's default exemplar is the first PDF in `usage/` alphabetically, which is the Pigida filing. The Smith exemplar is passed explicitly because it is the one the sample was transcribed from.

## Governing rules

Verified 2026-10-14. Primary source: the W.D. Wash. Local Bankruptcy Rules, "Effective Dec. 1, 2023" (court PDF, https://www.wawb.uscourts.gov/sites/wawb/files/attachments/2023%20rules.clean%20-23.10.27%20FINAL.pdf, pp. 34 to 38 of the PDF: LBR 9004-1 and LBR 9013-1). Secondary, for the notation and length conventions only: the court's "Motion Practice" primer, https://www.wawb.uscourts.gov/sites/wawb/files/MotionsPracticePrimer.pdf. I did not check whether any 2026 amendment changes LBR 9004-1 or 9013-1(c) or (d); if one does, re-verify before the next render.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LBR 9004-1(a) (M) | 8-1/2 x 11; standard embedded font, 11 or 12 point; double spaced. | `page-w`, `page-h`; `type-size = 12pt`; `pitch = 24pt` (double spacing); `footer-size = 11pt`. |
| Typeface | Face required: none. LBR 9004-1(a) says "a standard embedded font" and names no face; no other W.D. Wash. local rule names one (checked 2026-10-15 against the same 2023 PDF). | Face: Times New Roman (`font-family` in `typst/wawb-motion-brief.typ`; the docx names the same face through `{font}`), the house standard where the rule names no face. The filed exemplars use Times New Roman and Arial. |
| LBR 9004-1(b)(1) (M) | Numbered paper: line numbers in the left margin. | `line-numbers()`: 27 numbered lines, level with their text. The filed exemplar (Smith) has none; the template follows the rule. |
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

- Page 1: notation top right (lines 1 to 6, single spaced); court title on lines 8 to 10; caption on lines 12 to 18 (debtor block with one ")" per line, the case number and the title at right); the notice-and-motion paragraph follows.
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

Typst render of 2026-10-22 (fb-595.68.24), every page at 60 dpi; the docx pages are in `reviews/docx.md`.

- Page 1: notation top right from line 1, court title, caption with ")" column, case number and bold title, the notice-and-motion paragraph, "Background for Motion" and the first bullet. Pass.
- Page 2: the other bullets, RELIEF REQUESTED, the arrears and accelerated-amount paragraphs. Pass.
- Page 3: the reduction request, "As explained below", MEMORANDUM OF LAW, the first statute-of-limitations paragraph. Pass.
- Page 4: Copper Creek and Merritt, Citing line, the two-line acceleration heading kept with its paragraph. Pass.
- Page 5: Merritt block quotation, POLICY heading, LUV block quotation. Pass.
- Page 6: "Impact of bankruptcy Filing", the Johnson quotation, the discharge paragraph. Pass.
- Page 7: the stay paragraph, the RCW 4.16.230 quotation, "Impact of US Bankruptcy laws", Hazel. Pass.
- Pages 8 to 10: Hazel facts and ruling, the 11 U.S.C. 108(c) quotations. Pass.
- Page 11: the last quotation, FIRST MORTGAGE HISTORY (two lines) and the loan paragraphs; lines 26 and 27 empty because the next three-line heading moves on with its paragraph. Pass.
- Page 12: YEARS IN BANKRUPTCY heading, bankruptcy history, the three-item gap list; lines 26 and 27 empty (the omitted-table note would leave one line). Pass.
- Page 13: the omitted-table note, the "Dated:" signature kept whole, CERTIFICATE OF SERVICE and the party list. Pass.
- Page 14: the last two lines of the party list. Pass.

## Known gaps

1. **Length (LBR 9013-1(d)(1)(C), M).** The template does not count pages or decide whether the motion is dispositive. The sample renders to 14 pages including the notice, the certificate and the party list. The filed exemplar's memorandum runs past 12 pages (the filing is 19 pages). If this is a non-dispositive motion, the memorandum needs prior court approval to exceed 12 pages; if it is dispositive, the limit is 24. Counsel decides which. This is the author's responsibility (A).
2. **Notice text (LBR 9013-1(c)(3)(B), M).** The notice must say that a response must be filed by the response date and that if none is filed the court may grant the motion before the hearing without further notice. The sample does not say so: the filed exemplar does not either. The template cannot add it. This is the author's responsibility (A).
3. **Declaration and proposed order (LBR 9013-1(d)(1)(A), (d)(1)(D), M).** The sample does not include a declaration of the debtor, although the certificate's title names one; the transcription did not reach the filing's declaration pages. The proposed order is a separate exhibit under LBR 9013-1(d)(1)(D) and is not produced by this template.
4. **Transcription omissions.** Not transcribed: the recording-history table (exemplar pp. 10 and 11; replaced by a bracketed note in the sample), the foreclosure-cost analysis and exhibit arithmetic (exemplar pp. 12 to 16), and the declaration (p. 19). The sample ends with the certificate of service.
5. **Block quotations double spaced.** LBR 9004-1(a) says all pleadings are double spaced, so the template double spaces block quotations. The filer single-spaces them. This is a tier-2 choice I resolved toward the rule; if the court's clerks accept single-spaced block quotations, change `quote-indent` handling in `typst/wawb-motion-brief.typ`.
6. **Pleading line count.** LBR 9004-1(b)(1) requires line numbers but does not say how many. 27 lines of 24 pt between 1 in margins, as the sibling complaint template; it is not set by the rule.
7. **Caption entries.** The debtor names are split into one frontmatter entry per line (`MELANIE A SMITH`, `*aka* M A SMITH`, `*aka* M SMITH,`) so that each ")" lines up with one name line. This is sample data, not a template break.
8. **Second filer not overlaid.** The Pigida filing (2015) was used for the tier-2 cross-check of the notation, caption and bottom notation. It is not overlaid because its pleading format predates the 2023 rules.
9. **Gate 2 record.** `reviews/docx.md` records the docx pages; the page review above is the typst one.
10. **Adversary complaint.** The sibling `adversary-complaint/` folder has no `OUTPUT` or `OVERLAY` PDF and no `README` outputs in `usage/`. Not touched in this change.

## Engines

Both engines are on the shared cross-engine layout model (lib/typst/xengine.typ, lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"), and the docx is gated against the typst render (`eval.yaml`: `params.cross_engine: gate`): it breaks every line and page where typst does (XENG-001..003). `sh tools/check.sh <this dir> --engine typst|docx` runs every gate (`usage/.check-typst.txt`, `.check-docx.txt`).

**typst** (`typst/`): Times New Roman 12 pt in exact line boxes: 24 pt for the numbered lines and the body (block quotations included), 12 pt for the single-spaced notation and caption (two to a numbered line; each block starts 9.6 pt below a numbered line's top, so every other line sits on a number's baseline), 12 pt for the 11 pt bottom notation; 27 numbered lines, the numbers level with their text. The space that brings the notation and the caption back onto the numbered lines is counted from their items, as the docx engine counts it: an odd number of wrapped extra lines would leave the court title half a line off the numbers, in both engines alike (the sample's notation wraps by an even number and stays on them).

**docx** (`docx/`): `docx/reference.xml` (the cross-engine styles in the typst face, `{font}`) and `docx/wawb-motion-brief.lua`, which writes every paragraph at the typst pitches and spaces (the author's hard line breaks as Word line breaks), the footer (`$FORMBOOK_FOOTERS`: the line numbers in a page-anchored text box, the pleading rules as page-anchored lines, the bottom notation from `footer_title` and `footer_counsel`) and the last section (`$FORMBOOK_FINAL`). `fb render` builds the reference document and runs the pass; no script. Output: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf` (LibreOffice), 14 pages, as typst. The bullets are typed "•" and a tab, not a Word list. Not verified in Word (only LibreOffice here); Word may paginate differently.
