# mieb: motion with brief in support

Doc type: **motion** (a written motion, with a brief in support, filed in one document) in the United States Bankruptcy Court for the Eastern District of Michigan (`mieb`). Folder: `courts/sixth-circuit/michigan/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-heitmann-24-41956-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-heitmann-motion-brief.md` (an excerpt of the brief; the motion and the certificate are complete) |
| render | ok: `samples/OUTPUT-heitmann-motion-brief.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `samples/OVERLAY-heitmann-motion-brief.pdf` and `-overlay.txt` (`tools/overlay.sh`, see "Overlay" below) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Verified 2026-10-14. Federal rules are quoted or closely paraphrased from the Legal Information Institute text; the local rules from the court's PDF.

| ID | Rule | Requirement | Source | Where it lives in the template |
|---|---|---|---|---|
| MIEB-FORM-001 | E.D. Mich. LBR 9029-1(h) | 8½ × 11 inch white paper; margins at least 1 inch on the top, sides and bottom; each page numbered consecutively. | Local Bankruptcy Rules PDF, https://www.mieb.uscourts.gov/sites/mieb/files/Local%20Bankruptcy%20Rules.pdf (see caveat below) | `margins = 1in`, `paper: "us-letter"`, footer `N of M`. |
| MIEB-FORM-002 | LBR 9029-1(h) | "type size of all text and footnotes must be no smaller than … 14 point (proportional)." | same | `type-size = 14pt`, `font-family = "EB Garamond"` (vendored in `fonts/`); footnotes 14 pt; footer 14 pt. |
| MIEB-FORM-003 | LBR 9029-1(h) | "double-spaced, except for quoted material and footnotes." | same | `body-leading = 1.35em` (28.0 pt pitch at 14 pt, measured with `pdftotext -bbox-layout`); block quotations and footnotes single-spaced (`footnote-leading`). |
| MIEB-FORM-004 | LBR 9004-1(b); LBR 9029-1(h) | One side of each page; "under the signature line must state any attorney's name, mailing address and telephone number and the name of the client"; "plainly typewritten … clearly legible." | same | Signature block (`signature()`) carries the signer, firm, address, phone and email. Caption and signature blocks single-spaced (convention). |
| MIEB-CAP-001 | LBR 9004-1(a)(1), (2) and (3)(A); Fed. R. Bankr. P. 9004(b) | Caption with the court's name, the case title, the case number, "the chapter number", "the judge to whom the case is assigned", and for a motion, "identification of the movant and specific relief sought". FRBP 9004(b): court, case title, case number (and adversary number if any), "a brief designation of the document's character" (https://www.law.cornell.edu/rules/frbp/rule_9004, checked 2026-10-14). | LBR PDF (above); FRBP 9004 | `caption()`: court, `in_re`, `case.chapter`, `case.number`, `case.judge`, and the document's title (`titles`), which states the movant and the relief. |
| MIEB-MOT-001 | Fed. R. Bankr. P. 9013(a), (b) | A request for an order is made "by written motion"; "A motion must state its grounds with particularity and set forth the relief or order requested." (https://www.law.cornell.edu/rules/frbp/rule_9013, checked 2026-10-14) | FRBP 9013 | Author content: the motion's numbered grounds and its WHEREFORE/relief paragraph. The template does not check the grounds. |
| MIEB-MOT-002 | LBR 9014-1(a) | "Unless permitted otherwise by applicable rule, a party seeking relief must file a motion." | LBR PDF | Scope of this doc type. |
| MIEB-MOT-003 | LBR 9014-1(c)(1)-(4) | The motion attaches, as exhibits: (1) a proposed order (Exhibit 1); (2) a completed "Notice of Motion and Opportunity to Object" form (Exhibit 2); (3) a brief, when required (Exhibit 3); (4) a certificate of service (Exhibit 4). | LBR PDF | The certificate of service is written by the author as the third document of the body; the template gives it its caption and signature block only. Exhibits 1 and 2 are **not** produced (see gaps). |
| MIEB-MOT-004 | LBR 9014-1(f) | "A brief, not more than 25 pages in length, including footnotes and signatures, must be filed in support of and in opposition to … (1) a motion in an adversary proceeding … ." For other motions, "there is no requirement to file a brief … unless otherwise ordered." A reply brief is at most seven pages. | LBR PDF | Page length is **not** counted by the template (see gaps). The exemplar is a contested matter in the main case, so 9014-1(f) did not apply to it; the brief was filed voluntarily. |
| MIEB-BODY-001 | Exemplar convention (tier 2) | Level-1 headings (RELEVANT BACKGROUND, ARGUMENT) centered and bold in capitals; level-2 headings (Debtor Exceeds the Debt Limit for Chapter 13) bold, sentence case; the numbered motion paragraphs typed by the author. | The exemplar | `show heading.where(level: 1/2/3)`. |
| MIEB-SIG-001 | LBR 9004-1(b); exemplar convention | "Dated" at the left, "Respectfully submitted," and the signature block at the right, after each document. | LBR 9004-1(b); the exemplar | `signature()`, kept whole (`breakable: false`). |

**Caveat on the local rules.** The E.D. Mich. local bankruptcy rules used here are the PDF on the court's site, whose file metadata gives a creation date of 2018-02-27. A later revision was looked for (courtrules.net, which returned HTTP 403 to fetch; a web search) and not found. Re-check MIEB-FORM-001 to MIEB-FORM-004 and MIEB-MOT-003 and -004 against the current LBR before a `done` decision.

## Layout

- Each document of the filing (`---` in the sample body) starts on its own page with its own caption: court name centered; a rule; the case block (debtor, chapter, case number, judge) in two columns, with the "/" line; a rule; the title in bold capitals, centered.
- Motion: an introductory line, numbered paragraphs (typed by the author as `1\.`), signature block.
- Brief in support: the introductory line, then body text (first-line indent, double spacing), level-1 and level-2 headings, footnotes at 14 pt, signature block.
- Certificate of service: "Re:" paragraph, service statement, the address (a hard line break in one paragraph), signature block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is the documents of the filing, separated by a line holding only `---`. The frontmatter `titles` lists one title per document, in order (a mismatch is an error).
- Frontmatter fields: `court` (list of lines), `in_re` (`names`, `role`), `case` (`number`, `chapter`, `judge`), `titles`, `date`, `signature` (`signer`, `lines`).
- Body: `# HEADING` is level 1 (centered caps), `## Heading` level 2 (bold), `### Heading` level 3 (bold italic). Footnotes `text[^1]` and `[^1]: text` work (one numbering for the whole PDF). Case names are italic (`*...*`). A hard line break is a backslash at the end of a line. Numbered paragraphs are typed by the author, escaped as `1\.`.

## Overlay

`tools/overlay.sh` reads and writes `OUTPUT-<id>.pdf` / `OVERLAY-<id>.pdf` and `.txt`; this doc type uses the names the brief asks for (`samples/<id>.pdf`, `samples/<id>-overlay.pdf`, `samples/<id>-overlay.txt`). The overlay was run on a copy named `OUTPUT-heitmann-motion-brief.pdf`, and its outputs were renamed; the copy was deleted. Red = our render, blue = the filed exemplar, black = both. The page map:

| ours | filed | word overlap |
|---|---|---|
| p.1 | p.1 | 95.3% |
| p.2 | p.2 | 87.8% |
| p.3 | p.3 | 70.7% |
| p.4 | p.7 | 48.1% |
| p.5 | p.8 | 58.0% |
| p.6 | p.24 | 42.5% |
| p.7 | p.23 | 96.1% |
| p.8 | p.24 | 76.9% |

The overlay is a diagnostic, not a score. Pages 4 to 6 of the sample (the background and argument) pair with filed pages 7 to 8 and 24 because the sample is an excerpt and the exemplar's argument runs on past them; the word overlap is low there for that reason. Page 7 (the certificate) pairs with the filed certificate on page 23.

## Gate 2: visual review (pages rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Motion: caption, title, paragraphs 1 to 3, signature | OK. Numbered paragraphs with first-line indent. |
| 2 | Brief caption and title; opening paragraphs | OK. |
| 3 | RELEVANT BACKGROUND (level 1), background paragraphs | OK. |
| 4 | Background end, footnotes 1 and 2 (14 pt, single-spaced), ARGUMENT, level-2 heading "Debtor Exceeds the Debt Limit for Chapter 13" | OK after the heading spacing fix (headings have a full line above them). |
| 5 | Debt-limit paragraphs; level-2 "Debtor Did Not File This Case in Good Faith"; the excerpt marker (`* * *`) | OK. The asterisk marker is set small in EB Garamond; it reads as an excerpt break. |
| 6 | The WHEREFORE paragraph, then the signature block | OK. Page is mostly empty because the excerpt ends here. |
| 7 | Certificate of service: caption, title, "Re:" line, service statements, address | OK. |
| 8 | The last lines of the certificate's signature block, alone on the page | **Defect, not fixed.** The signature block (kept whole) moved to a new page after the address, so page 8 holds only the signature with no text above it. Reflowing the double-spaced address to free up the room was not done; see gap 5. |

Pages reviewed: 8 of 8.

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for two or three filers. Searched CourtListener RECAP (`court=mieb`, "brief in support", "motion to dismiss") and the web. The other candidates were Stockman's motion to dismiss the adversary in Jayakumar v. Perez (26-02010, 30 pp., with its brief as Exhibit 3 and a third-party complaint in the same filing) and Ashmark Construction's motion to dismiss its own case (25-46693, no brief). Tier 2 is therefore **not** judged against two filers yet.
2. **Excerpt sample.** The brief occupies most of the 24-page filing; the sample transcribes its opening, background, one argument section, the WHEREFORE clause, and the certificate of service. The notice, the omitted argument sections and the proposed order are not transcribed. The excerpt marker (`* * *`) shows the cut; nothing else was altered.
3. **Exhibits not generated** (MIEB-MOT-003): the proposed order (Exhibit 1) and the "Notice of Motion and Opportunity to Object" form (Exhibit 2). The 14-day response period (LBR 9014-1(b)) belongs to that notice. The template produces the motion, the brief, and the certificate only.
4. **Page length not counted** (MIEB-MOT-004). LBR 9014-1(f) limits a brief in an adversary proceeding to 25 pages including footnotes and signatures; the template does not count pages. Check the rendered length before filing.
5. **Certificate signature block alone on a page** (see Gate 2, page 8). This is a layout defect in the sample. Fixing it needs the address lines single-spaced, which the markdown contract does not express. Open choice for David: add a single-spaced block form, or accept the orphaned signature.
6. **Footnote numbering** runs across the whole PDF (typst). Whether the filed exemplar restarts numbering in each document was not checked.
7. **Heading styles** are read from the exemplar's layout, not from a rule: no E.D. Mich. local rule was found that sets heading form.
8. **Local rules date.** See the caveat above. The rules cited are from a 2018 PDF.
9. **No check script.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc type folder has neither, and the brief forbids editing `tools/`. The render and overlay were run; the review above is the Gate 2 equivalent for this doc type.
