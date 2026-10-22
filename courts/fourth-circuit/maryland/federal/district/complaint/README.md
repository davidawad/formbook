# mdd: complaint

Doc type: **complaint** (original complaint) in the United States District Court for the District of Maryland (`mdd`). Folder: `courts/fourth-circuit/maryland/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-complaint.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md` (about two-thirds of the 16-page filing's text, the rest omitted paragraph by paragraph; see the sample's frontmatter) |
| typeface | Rule names Times New Roman (LR-102.2.b, "Times New Roman or larger typeface"). Set in **Times New Roman** itself (the pinned files of `docs/FONTS.md` rule 1; Liberation Serif only as fallback), on typst and docx. Text 12 pt (the complaint has no footnotes; 10 pt where a doc type has them). |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 12 pages, typst 0.15.0, Times New Roman only (`pdffonts`: `TimesNewRomanPSMT`, `TimesNewRomanPS-BoldMT`), no warnings |
| overlay | ok: `usage/OVERLAY-grecco-complaint.pdf` and `usage/OVERLAY-grecco-complaint.txt`, against the filed exemplar fetched from the RECAP URL in `usage/SOURCE.md` and checked against its SHA-256 (the exemplar PDF is not committed in this snapshot; it is passed to `tools/overlay.sh` as the third argument) |
| pages reviewed | 11 of 11 on the earlier Liberation Serif render, before fb-595.68 (every page rendered at 70 dpi and viewed) |
| render command | `sh tools/render.sh courts/fourth-circuit/maryland/federal/district/complaint usage/INPUT-complaint.md` |
| overlay command | `sh tools/overlay.sh courts/fourth-circuit/maryland/federal/district/complaint grecco-complaint` |

File names: the brief asks for `usage/<id>.md`, `<id>.pdf` and `<id>-overlay.*`. The repo's tools read `INPUT-<id>.md` and write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` by default, so the names follow the tools (as in the ca9 and cand folders); the tools were not edited.

## Governing rules

Primary sources, fetched 2026-10-14:

- **D. Md. Local Rules, effective December 1, 2025** (the adopted version; the court's amendments page lists no later change): https://www.mdd.uscourts.gov/sites/mdd/files/LocalRules.pdf (linked from https://www.mdd.uscourts.gov/local-rules). Quoted text below is from that PDF.
- **Fed. R. Civ. P.** 7(a), 8(a), 10(a)-(b), 38(b): https://www.law.cornell.edu/rules/frcp/rule_10 and the same path for rules 7, 8, 38.

| ID | Rule | Requirement (quoted or closely paraphrased) | Where it lives |
|---|---|---|---|
| LR-102.2.a | D. Md. L.R. 102.2.a | The short caption (first plaintiff and first defendant) applies to all court documents, *except* the original complaint, which "shall contain the names and addresses of all parties and the county of residence of any Maryland party." | `caption()`: every party needs `address`; a Maryland address needs `county` (checked, panics) |
| LR-102.2.b | D. Md. L.R. 102.2.b | 8½ × 11 inch paper, one-inch margin on all sides; lines double-spaced except quotations and footnotes; "Pages shall be numbered at the bottom of every page after the first page"; at least 12-point text and 10-point footnotes "in Times New Roman or larger typeface." | `margins`, `pitch-double` (27.6 pt, 2 x the 13.8 pt single line), `page-footer` (no number on page 1), `font-family` Times New Roman, `type-size` 12 pt (Known gaps 1) |
| LR-102.1.b.i | D. Md. L.R. 102.1.b.i | "At the bottom of all court documents, counsel … shall state their name, address, telephone number, email and fax number. Counsel shall also state their bar number." | `signature-block()` (panics if any of name, bar, firm, address, phone, fax, email, role is missing) |
| LR-102.1.c | D. Md. L.R. 102.1.c | Proof of service: "all court documents other than the original complaint must bear a signed certificate." | Not applicable to the complaint; no certificate is generated |
| LR-103.1.c | D. Md. L.R. 103.1.c | "Any pleading that states a claim for relief shall set forth each count separately and provide a clear statement of the supporting facts for each count." | Author content: each count is a `# … CAUSE OF ACTION` heading |
| LR-103.1.d | D. Md. L.R. 103.1.d | "Pleadings … shall not exceed forty (40) pages in length" (except removals). | End check, `max-pages = 40` (panics) |
| FRCP 10(a) | Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation. The title of the complaint must name all the parties." | `court-title`, `caption` (all parties in the caption), `case_number` blank until the clerk assigns it, `brief_title` "COMPLAINT" |
| FRCP 10(b) | Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | `allegations()`: each paragraph chunk is numbered 1, 2, …; headings and lists are not |
| FRCP 7(a) | Fed. R. Civ. P. 7(a) | A complaint is a pleading. | The "COMPLAINT" title |
| FRCP 38(b) | Fed. R. Civ. P. 38(b) | A jury demand may be included in a pleading. | Author content: the unnumbered "VII. DEMAND FOR JURY TRIAL" paragraph (`^ ` marker) |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet and two copies if not filed electronically (LR 103.1.a), the related-case designation on the cover sheet (LR 103.1.b), the summons (LR 103.2), and the disclosure of affiliations and financial interest (LR 103.3, not checked against this filing). Not checked: standing orders of individual judges.

## Layout

- Court title (three lines, centered, from `court`), then the caption: parties in a left column closed by a rule on the right and the bottom, "Case No." on the right. A party's block is its names, its address lines, its county (for a Maryland party), and its designation, indented. "v." sits between parties.
- Title "COMPLAINT", centered and bold, under the caption.
- Body: double-spaced; each numbered paragraph has a 0.5 in first-line indent, then the number in a 0.5 in box; headings are centered caps (level 1), bold with a hanging indent (level 2), bold italic (level 3), or centered (level 4, for cause sub-titles).
- Prayer items are lettered (a), (b), … (a markdown list in the sample). The WHEREFORE paragraph and the jury demand are unnumbered: a chunk that starts with `^ ` is printed without a number.
- Signature block at the foot, with "/s/", counsel's name, bar number, firm, address, telephone, facsimile, email and role, after "Respectfully submitted,". "Dated:" is printed only when the sample gives a `date`.
- The whole of the last body paragraph and the signature block are kept together on one page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number` (blank for a new complaint), `court` (lines), `caption.parties` (each `{names, address, county?, designation}`), `brief_title`, `lead_in` (optional unnumbered lead-in paragraph), `signature` (`name`, `bar`, `firm`, `address`, `phone`, `fax`, `email`, `role`), `date` (optional).
- Body chunks are blank-line separated: `#` heading (level 1 centered caps), `##` heading (level 2), `###` (level 3), `####` (level 4, centered); a markdown list (lettered by the template); a paragraph beginning `^ ` (unnumbered); any other paragraph (numbered by the template). Do not type paragraph numbers.
- Not supported: tables, raw typst, footnotes in the complaint body (none used in the exemplar).

## Overlay

`usage/OVERLAY-grecco-complaint.pdf` (measured on the earlier 11-page Liberation Serif render, before fb-595.68): red = our render, blue = the filed exemplar, black = both. Pages are paired by word overlap, as the tool does. The pairing is coarse here: the sample skips filed paragraphs (see the frontmatter), so later sample pages pair with later filed pages that share the most words (ours p.5 with filed p.6, ours p.8 with filed p.11, ours p.9 with filed p.13, ours p.10 with filed p.15, ours p.11 with filed p.16). Word overlap is 38-61%. The overlay is a diagnostic, not a score; the visible differences that matter are the caption (the filed caption has no party addresses, LR-102.2.a) and the paragraph numbers (the filed numbers are not transcribed).

## Known gaps and open choices

1. **Font and size (LR-102.2.b).** The rule asks for 12-point text and 10-point footnotes "in Times New Roman or larger typeface." The template now sets Times New Roman itself at exactly the rule's 12 pt (fb-595.68.18), with a 27.6 pt double pitch and 13.8 pt single lines set directly (`pitch-double`, `pitch-single`); the render is 12 pages. History: a 13 pt EB Garamond stand-in (12 pages), then Liberation Serif at 12 pt (the body leading re-measured for its line box, double 27.6 pt and single 13.9 pt from `pdftotext -bbox`; 11 pages), then Times New Roman.
2. **Caption addresses (LR-102.2.a).** The filed caption lists names only. The rule requires names and addresses of all parties, and the county of a Maryland party. The template enforces this; the sample adds the addresses the complaint itself gives (¶ 9 for the plaintiff; ¶¶ 16 and 20 for New Century and Taylor) and "Frederick County, Maryland" for Taylor: the complaint gives Frederick, Maryland (¶ 20) and does not name the county, so the county is inferred from the city and should be confirmed. For New Century the only address in the complaint is its registered agent's; it is given as such. This is the most visible difference from the exemplar, and the exemplar is not a tier-1 model on this point.
3. **One exemplar only.** EVAL-LOOP tier 2 asks for two or three filers. The search and the candidates not saved (Yukich v. USA Fencing, Mestek v. 1987 Machinery) are in `usage/SOURCE.md`.
4. **Partial sample.** The filed text runs to paragraph 97; the sample transcribes about two-thirds of it (the omitted paragraphs are listed in the sample's frontmatter). Images in the filed document (the photograph and the screenshot) are omitted; the text around them is kept.
5. **Paragraph numbers.** The template numbers the paragraphs from 1. The filed numbers are not transcribed and do not match.
6. **Ragged right.** Body text is left-aligned, not justified. The exemplar's justification cannot be read from the text layer; this is a convention, not a rule.
7. **Headings are typed by the author** (the Roman numerals and the letters are part of the heading text, as in the exemplar).
8. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder (`court.json`, `rules.md`) and this doc-type folder does not have that shape; the brief forbids editing `tools/`. The render and the overlay were run; the review below is the Gate 2 record for this doc type.
9. **Overlay file names** follow the tool (`OVERLAY-<id>`), not the brief's `<id>-overlay`.

## Review of the rendered pages (Gate 2 record; on the earlier 11-page Liberation Serif render, before fb-595.68)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (two parties, addresses, county, "Case No." line), "COMPLAINT", the lead-in paragraph | OK. No page number (LR-102.2.b). About 1 in of blank at the foot: I. INTRODUCTION moves to page 2 with its first paragraph (keep-with-next). |
| 2 | I. INTRODUCTION, ¶¶ 1-8 | OK. Number "2" at the foot. About 1 in of blank at the foot: II. PARTIES moves to page 3 with ¶ 9 (keep-with-next). ACCEPTED: layout, not a rule point. |
| 3 | II. PARTIES, ¶¶ 9-16 | OK. |
| 4 | ¶¶ 17-25; III. JURISDICTION, VENUE, AND DIVISIONAL ASSIGNMENT; IV. FACTUAL ALLEGATIONS, A | OK. |
| 5 | ¶¶ 26-34 | OK. |
| 6 | ¶¶ 35-41; B. heading | OK. |
| 7 | ¶¶ 42-51; C. heading | OK. |
| 8 | ¶¶ 52-59 (¶ 59 begins); FIRST CAUSE OF ACTION and its sub-title | OK. |
| 9 | ¶ 59 (continued), ¶¶ 60-64; SECOND CAUSE OF ACTION and its sub-title | OK. |
| 10 | ¶¶ 65-66; VI. PRAYER FOR RELIEF, WHEREFORE paragraph, items (a)-(c) | OK. |
| 11 | Prayer items (d)-(g); VII. DEMAND FOR JURY TRIAL (unnumbered); signature block | OK. |

Reviewed pages: 11 of 11 of the earlier Liberation Serif render (rendered at 70 dpi, viewed as 2×2 montages; the montages are in `/work/artifacts/review`, outside the repo).

## Engines

**typst** is the reference (`typst/`, `usage/OUTPUT-complaint.typst.pdf`, 12 pages). **latex**: not built for this doc type. **docx** (`docx/reference.xml`, from which `fb render --engine docx` builds the reference document on the shared cross-engine recipe in the typst face; `docx/mdd-complaint.lua`; `docx/make-reference.sh` and `docx/reference.docx` were retired into fb render in fb-595.68.18): built and rendered with LibreOffice (`usage/OUTPUT-complaint.docx`, `usage/OUTPUT-complaint.docx.pdf`, 12 pages, as typst). XENG-001..003 pass (fb-595.68.18).

- *Reviewed (the earlier Liberation Serif docx):* all 12 pages of the docx PDF at 60 dpi (4 per montage), and all 11 typst pages paired beside the docx page at 60 dpi. Pages reviewed: 12 of 12 (docx).
- *Matches typst (seen on the pages of that docx; the face is now Times New Roman on both, regular and bold only):* double spacing at 27.6 pt; 1-inch margins; the cover (court, caption with addresses and county, "Case No." line, title, lead-in); numbered paragraphs with the number then a tab; no number on page 1 and a centered page number from page 2; headings as the template sets them, with level-4 cause sub-titles in bold; lettered prayer items (a) to (g) with hanging indent; the signature block in the right half, with "Respectfully submitted,", kept with the jury demand.
- *Differs (tier 2; seen on that earlier docx, not re-checked here; both engines are 12 pages now):* pagination. The docx was 12 pages, the typst output 11; body lines break at other words, so page breaks fall one or two lines apart. The jury demand and signature block sit alone on page 12 (kept together), where typst fits them on page 11. Number gap: a tab stop at 1.0 in, not a fixed 0.3 in after each number (typst's gap varies with the number's width). The declared font was Liberation Serif; it is now Times New Roman, the face the rule names.
- *Not verified:* the .docx has not been opened in Word, so the no-repair check in Word is not done. LibreOffice converted it without error. Both the zip and the XML parts were checked.
- *Gates:* `tools/check.sh` gates both engines on `eval.yaml` (`usage/.check-typst.txt`, `usage/.check-docx.txt`: PASS; typst 9 and docx 13 checks passed, fb-595.68.18).
- *Rebuild:* `sh tools/render.sh --engine docx courts/fourth-circuit/maryland/federal/district/complaint usage/INPUT-complaint.md`.
