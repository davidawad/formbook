# mieb: adversary complaint

Doc type: **adversary complaint** (the complaint that starts an adversary proceeding) in the United States Bankruptcy Court for the Eastern District of Michigan (`mieb`). Folder: `courts/sixth-circuit/michigan/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-mieb-adversary-complaint-griffin2604189.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-mieb-adversary-complaint-griffin.md` (the whole 7-page complaint, transcribed; filed wording kept) |
| render | ok: `usage/OUTPUT-mieb-adversary-complaint-griffin.typst.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| overlay | ok: `usage/OVERLAY-griffin-adversary-complaint.pdf` and `-overlay.txt` (`tools/overlay.sh`, see "Overlay" below) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Verified 2026-10-14. Each rule is quoted or closely paraphrased from the source named.

| ID | Rule | Requirement | Source | Where it lives in the template |
|---|---|---|---|---|
| MIEB-FORM-001 | E.D. Mich. LBR 9029-1(h) | 8½ × 11 inch white paper; margins at least 1 inch on the top, sides and bottom; each page numbered consecutively. | Local Bankruptcy Rules PDF, https://www.mieb.uscourts.gov/sites/mieb/files/Local%20Bankruptcy%20Rules.pdf (see caveat below) | `margins = 1in`, `paper: "us-letter"`, footer `N of M`. |
| MIEB-FORM-002 | LBR 9029-1(h) | "Except for standard preprinted forms … type size of all text and footnotes must be no smaller than … 14 point (proportional)." | same | `type-size = 14pt`, `font-family = "EB Garamond"` (vendored in `fonts/`), footer 14 pt. |
| MIEB-FORM-003 | LBR 9029-1(h) | Papers are "double-spaced, except for quoted material and footnotes." | same | `body-leading = 1.35em`: measured line pitch 28.0 pt for 14 pt type, i.e. twice the single-spaced pitch of 14 pt type. |
| MIEB-FORM-004 | LBR 9029-1(h) | "plainly typewritten … clearly legible." | same | Caption, counsel and signature blocks are single-spaced (`single-leading`), a convention the rule does not forbid. |
| MIEB-FORM-005 | LBR 9004-1(b) | "The paper … may use only one side of a page and under the signature line must state any attorney's name, mailing address and telephone number and the name of the client. The pages, excluding exhibits, must be numbered." | same | One-sided output; signature block carries name, firm, address, phone and email (`signature` in the sample). Page numbers (MIEB-FORM-001). |
| MIEB-CAP-001 | LBR 9004-1(a)(1) and (2); Fed. R. Bankr. P. 9004(b) | The caption states the court's name, the case title, the case number and the adversary number, and "the chapter number under which the petition is pending" and "the judge to whom the case is assigned". | same; FRBP 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 (checked 2026-10-14) | `bankruptcy-caption()`: court name, `in_re`, `case.number`, `case.chapter`, `case.judge`. |
| MIEB-CAP-002 | LBR 9004-1(a)(3); Fed. R. Bankr. P. 7010 | "A concise statement of the nature of the document." The caption of an adversary complaint "must substantially conform to" Official Form 416 (FRBP 7010, https://www.law.cornell.edu/rules/frbp/rule_7010, checked 2026-10-14). | same | `adversary-caption()` (parties with their designations, "vs.", chapter, adversary number) and `title` (the nature of the document). |
| MIEB-PLEAD-001 | Fed. R. Bankr. P. 7008(a) | The complaint states the basis for the court's jurisdiction and "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." Fed. R. Civ. P. 8 applies. | FRBP 7008, https://www.law.cornell.edu/rules/frbp/rule_7008 (checked 2026-10-14) | Author content (the sample's "JURISDICTION AND VENUE" section). The template does not check the wording. |
| MIEB-PLEAD-002 | Fed. R. Bankr. P. 7001 | The kind of adversary proceeding (here, to recover money or property, 7001(a), and to avoid transfers under 11 U.S.C. §§ 544, 548 and 550). | FRBP 7001, https://www.law.cornell.edu/rules/frbp/rule_7001 (checked 2026-10-14) | Author content. The template does not classify the claims. |
| MIEB-PLEAD-003 | Fed. R. Civ. P. 10(b), applied by FRBP 7010 and 7008 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | FRCP 10, https://www.law.cornell.edu/rules/frcp/rule_10 (checked 2026-10-14) | Every body paragraph is numbered by the template (`body()`), counting from 1 across the counts. A paragraph beginning WHEREFORE is a prayer and is not numbered. |
| MIEB-BODY-001 | Exemplar convention (tier 2) | Section headings centered, bold, in capitals (JURISDICTION AND VENUE, PARTIES, GENERAL ALLEGATIONS, COUNT I …); count subtitles centered and bold. | The exemplar, `usage/SAMPLE-mieb-adversary-complaint-griffin2604189.pdf` | `# ` and `## ` chunks. |
| MIEB-SIG-001 | LBR 9004-1(b); exemplar convention | The date at the left, the signer and the signature block at the right; the signer's name, firm, address, phone and email. | LBR 9004-1(b); the exemplar | `signature()`. |

Not produced by this template (separate filings or exhibits; the rule text above does not put them inside the complaint): the adversary proceeding cover sheet, the summons (Fed. R. Bankr. P. 7004), the filing fee, and any exhibits.

**Caveat on the local rules.** The E.D. Mich. local bankruptcy rules used here are the PDF on the court's site, whose file metadata gives a creation date of 2018-02-27. A later revision was looked for (courtrules.net, which returned HTTP 403 to fetch; a web search) and not found. Re-check MIEB-FORM-001 to MIEB-FORM-005 against the current LBR before a `done` decision.

## Layout

- Court name centered at the top; a rule; the case block (debtor, case number, chapter, judge) in two columns; a rule; the adversary block (parties with designations, "vs.", chapter, adversary number); a rule; the title in bold capitals centered.
- Lead-in paragraph (the opening "Plaintiff … alleges as follows:") unnumbered, then numbered paragraphs. Headings keep with the paragraph after them (`sticky`).
- Double spacing: 28.0 pt pitch measured with `pdftotext -bbox-layout` on page 2.
- Signature block after the last prayer: date at left, signer at right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line-separated chunks. `# TITLE` is a centered bold heading; `## Subtitle` a centered bold subheading; a chunk beginning `WHEREFORE` is an unnumbered prayer; any other chunk is a numbered paragraph.
- Frontmatter fields: `court` (list of lines), `in_re` (`names`, `role`), `case` (`number`, `chapter`, `judge`), `adversary_number` (may be `""`, which prints a blank line), `caption` (list of `{names, designation}`, "vs." is inserted between), `title`, `lead_in` (the unnumbered opening paragraph), `date`, `signature` (`signer`, `lines`).
- Not supported: footnotes (the template stops with an error if a sample has one), tables, raw typst. A paragraph whose text begins with a digit followed by a period must be escaped (the template numbers its own paragraphs).

## Overlay

`tools/overlay.sh` reads and writes `OUTPUT-<id>.pdf` / `OVERLAY-<id>.pdf` and `.txt`; this doc type uses the names the brief asks for (`usage/<id>.pdf`, `usage/<id>-overlay.pdf`, `usage/<id>-overlay.txt`). The overlay was run on a copy named `OUTPUT-mieb-adversary-complaint-griffin.typst.pdf`, and its outputs were renamed to the `<id>-overlay` names; the copy was deleted. Red = our render, blue = the filed exemplar, black = both. The page map pairs sample pages with exemplar pages by word overlap:

| ours | filed | word overlap |
|---|---|---|
| p.1 | p.1 | 68.1% |
| p.2 | p.2 | 54.5% |
| p.3 | p.3 | 43.7% |
| p.4 | p.3 | 48.8% |
| p.5 | p.4 | 82.9% |
| p.6 | p.5 | 72.9% |
| p.7 | p.6 | 84.5% |
| p.8 | p.7 | 83.3% |

The overlay is a diagnostic, not a score. The filed exemplar is set in a different serif at a smaller size on a different page break, so the two layers do not coincide on text lines; the pairing shows that the sample covers the same passages in the same order.

## Gate 2: visual review (pages rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, lead-in | OK. The "Adversary Proceeding No." blank is drawn as a rule after the label. "JURISDICTION AND VENUE" moved to page 2 with its first paragraph (sticky heading); no heading left alone at a foot. |
| 2 | Jurisdiction, parties | OK. Numbered 1 to 8. |
| 3 | General allegations | OK. Numbered 11 to 17. |
| 4 | General allegations end; COUNT I | OK. Count heading kept with its subtitle and first paragraph. |
| 5 | Count I end, prayer; COUNT II | OK. Prayer unnumbered. |
| 6 | Count II prayer, COUNT III, COUNT IV heading | OK. COUNT IV heading kept with its subtitle; subtitle kept with paragraph 37. |
| 7 | Count IV paragraphs 38 to 43 | OK. |
| 8 | Count IV prayer, COUNT V, prayer, signature block | OK. Signature block single-spaced at the right, date at left. |

Pages reviewed: 8 of 8.

## Known gaps and open choices

1. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for two or three filers. Searched CourtListener RECAP (`court=mieb`, adversary complaint terms) and the web; the other text-based candidates were Leland House LP v. Kraemer Design Group (26-04015), Bullock v. Darana Hybrid (26-04029) and United States v. Kaplan (25-04239, a government filer). They were downloaded and checked for text, but not saved, because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet. The Griffin complaint is a debtor's complaint; a creditor's complaint with a 523 count may differ in its counts.
2. **Local rules date.** See the caveat above. The rules cited are from a 2018 PDF.
3. **Font size.** 14 point is the minimum that LBR 9029-1(h) allows for proportional type; the template uses it. The exemplar is a Times face at a smaller size; the difference is expected.
4. **Lead-in and numbering.** The lead-in is an unnumbered paragraph in frontmatter. A prayer is detected by its first word, WHEREFORE; a numbered paragraph that starts with that word would be left unnumbered.
5. **Footnotes** are not supported in the complaint body; the template stops with an error if one appears (the chunked body renders each paragraph alone).
6. **Typing errors in the exemplar** (for example "Plaintiffs'" and "Concumer Protection Act") were transcribed as filed. Only the template's text is checked, not the author's.
7. **Court-specific cover sheet and summons** not generated (see "Governing rules").
8. **No check script.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc type folder has neither, and the brief forbids editing `tools/`. The render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Engines

docx (`docx/`): `build-reference.sh` builds `reference.docx`; `mieb-adversary-complaint.lua` writes the caption, the numbered body and the signature block; `render.sh` assembles the file. Sample `griffin-adversary-complaint` renders to `usage/OUTPUT-mieb-adversary-complaint-griffin.docx` (`sh tools/render.sh --engine docx`), a valid zip with no duplicate entries and well-formed XML.

- **Matches the typst template (set in the reference, read from the source of `typst/mieb-adversary-complaint.typ`):** EB Garamond (the vendored family, named `EB Garamond` in the styles) at 14 pt; exact 28 pt line pitch for the body (the pitch the typst README measured); no first-line indent; letter paper; 1 in margins; footer "N of M" centered at 14 pt (PAGE and NUMPAGES fields with cached result); headings centered and bold, kept with the next paragraph; signature block "Dated" left, signer right (4752 / 4608 twips, the typst grid widths).
- **Differs from typst:** the caption rules are paragraph borders and the two-column caption is a borderless table; single-spaced caption lines use Word's `auto` 240 spacing, not the typst 0.3 em leading, and paragraph spacing is zero in both (the typst gap was not measured against Word). Numbers are typed as text by the filter, as typst does. Typst `#` headings sit one line of space above and below; the docx headings have none (exact 28 pt lines).
- **Pagination not measured.** The typst render is 8 pages (`pdfinfo`, letter); the docx page count is unknown because the LibreOffice conversion did not run.
- **docx BLOCKED:** `docx.pdf` and the page-by-page review: `soffice` is not installed on this box, so `usage/OUTPUT-griffin-adversary-complaint.docx.pdf` was not produced and no page was viewed. No Word-native feature is needed for this doc type (no TOC, TOA or pleading line numbers in the rules recorded above), so no other docx check is blocked.
