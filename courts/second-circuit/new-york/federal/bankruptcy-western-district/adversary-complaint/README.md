# nywb: adversary-complaint

Doc type: **adversary complaint** commencing an adversary proceeding in the United States Bankruptcy Court, Western District of New York (`nywb`). Folder: `courts/second-circuit/new-york/federal/bankruptcy-western-district/adversary-complaint/`. The exemplar is a chapter 7 trustee's complaint to avoid preferential and fraudulent transfers and to disallow claims under 11 U.S.C. §§ 502(d), 544, 547, 548 and 550.

| Item | Status |
|---|---|
| exemplar | yes, 1 filer: `exemplars/FILED-EXAMPLE-wallach-rothstein-1-11-01078-adversary-complaint.pdf` (8 pages, text layer present; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-wallach-rothstein-complaint.md` (transcribed in full: caption, lead-in, every section, all five counts, prayer, signature) |
| render | ok: `samples/OUTPUT-wallach-rothstein-complaint.pdf`, 8 pages, letter size, typst 0.15.0, vendored EB Garamond only (embedded), no typst warnings |
| overlay | ok: `samples/OVERLAY-wallach-rothstein-complaint.pdf` and `.txt` (page map below) |
| typeface | Face required by the rules: none named (LBR 9004-1 requires only "plainly and legibly written"; re-checked 2026-10-15). Vendored substitute: none needed, so EB Garamond is kept (`docs/FONTS.md`, "No face named"). Metric fit: n/a. |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed; see Gate 2 table) |
| tier 2 | **not met**: EVAL-LOOP asks for 2 or 3 filers; only one was found (see Known gaps) |

## Governing rules

Verified 2026-10-14 from the primary sources below. No rule was found that sets a font, type size, spacing or margins for this court's pleadings.

| Source | Requirement | Where in the template |
|---|---|---|
| Fed. R. Bankr. P. 7001 (https://www.law.cornell.edu/rules/frbp/rule_7001, as amended 2024) | Lists the proceedings that must be brought as adversary proceedings, among them proceedings to recover money or property and to object to or revoke a discharge. | Content (the sample's jurisdiction paragraph cites Rule 7001). Not checked mechanically. |
| Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008, as amended 2024) | Civil Rule 8 applies. A complaint must include a reference to the name, number and chapter of the case and the district and division where it is pending, and must state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | Content (author). The sample's jurisdiction paragraphs do not include the consent statement (see Known gaps). |
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, as amended 2024) | Civil Rule 10 applies, except that the caption must substantially conform to Form 416. | `court_name`, `debtor`, `caption.parties`, `case_number`, `chapter`, `judge`, `adv_number`, `brief_title`. |
| Fed. R. Bankr. P. 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004, as amended 2024) | Caption: court name; case title; case number and adversary-proceeding number; a brief designation of the document's character. | Same as above. |
| Fed. R. Civ. P. 10(b) (through Rule 7010; text as fetched for `cand-complaint` on 2026-10-14) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers every body paragraph. |
| W.D.N.Y. Local Bankruptcy Rules, LBR 9004-1 and 9004-2 (https://www.nywb.uscourts.gov/sites/nywb/files/Local%20Rules.pdf, PDF p. 19) | Letter-size paper; caption with the judge's initial at the end of the docket number; the paper dated and signed, with the name, address and telephone of each attorney. | `page-w`/`page-h`; `case_number` with the judge's initial in the sample (`09-13438K`, the K initial); `date`; `signature`. |

Not checked mechanically: the layout values are conventions taken from the filed exemplar (tier 2), not rules. The 2013 local-rules PDF on the court's site is the only local-rules text found; confirm it is current (see Known gaps).

## Layout and typography (conventions, tier 2)

- Letter paper; one-inch margins; page numbers centered at the foot from the cover on (the exemplar numbers its cover too).
- EB Garamond 12 pt (embedded). The exemplar is Helvetica 12 pt, non-embedded (its text lines are on a 27.6 pt pitch, measured from the text layer). The template uses double spacing at the same 27.6 pt pitch. The typeface differs from the exemplar: a tier 3 choice, since no W.D.N.Y. rule names a font (re-checked 2026-10-15 against LBR 9004-1 and 9004-2; no vendored substitute is needed).
- Caption: court title centered; a caption grid with the bankruptcy case (`In re:`, the debtor) above the adversary parties (`vs.`), a right rule and a bottom rule on the party column; on the right, `Case No.`, `Chapter`, `Hon.`, `Adv. Pro. No.` (a blank line if the clerk's number is not known, as in the exemplar), then the title in bold.
- Lead-in ("... alleges as follows:") unnumbered, on page 1 after the caption.
- Numbered paragraphs: number, then the text, first line indented 0.5 in, double-spaced.
- Headings: level 1 (`I. PROCEDURAL HISTORY`) centered bold caps; level 2 (`COUNT I`, count titles) centered bold; level 3 (`A. Lease & Consulting Agreements`) bold italic at the margin. Each heading is kept with the text after it.
- Block quotations (a markdown `>` chunk): single-spaced, indented 0.5 in on both sides, not numbered.
- Prayer: a `WHEREFORE` line (unnumbered, kept with the list), then the items as an upper-case lettered list (A., B., ...).
- Signature: `Dated:` on the left; firm, `By: /s/` signer and the signer's lines on the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `court_name` (list of lines), `debtor` (`names`, `designation`; the template prints `In re:` above it), `case_number` (with the judge's initial in the number, e.g. `09-13438K`), `chapter`, `judge`, `adv_number` (optional), `caption.parties` (list of `{names, designation}`; "vs." between parties), `brief_title`, `lead_in` (unnumbered), `date`, `signature` (`firm` lines, `signer`, `lines`), `counsel` (optional; not used by the sample).
- Body: `#` (level 1), `##` (level 2), `###` (level 3) headings; each blank-line-separated paragraph is a numbered allegation; a chunk starting with `>` is a block quotation; a chunk starting with `WHEREFORE` is the unnumbered prayer lead-in; a markdown list is the lettered prayer.
- Not supported: tables, footnotes, raw typst. The template does not number paragraphs inside a block quotation or a list.

## Overlay (`samples/OVERLAY-wallach-rothstein-complaint.pdf`)

Red is our render, blue is the filed exemplar, black is where both agree. The overlay pairs pages by shared words, not by index. It is a diagnostic, not a score. Page map from `OVERLAY-wallach-rothstein-complaint.txt`:

| Our page | Filed page paired | Word overlap |
|---|---|---|
| 1 | 1 | 68.7% |
| 2 | 2 | 73.4% |
| 3 | 3 | 68.9% |
| 4 | 4 | 62.9% |
| 5 | 5 | 63.1% |
| 6 | 6 | 71.6% |
| 7 | 7 | 77.4% |
| 8 | 8 | 87.3% |

The pages line up one-to-one. Our paragraph numbers are the template's (1 to 47, as the filed numbers), so the numbering matches the exemplar's; the text of the sample is a transcription of the exemplar.

## Gate 2: visual review (current PDF)

Reviewed sha256 of `samples/OUTPUT-wallach-rothstein-complaint.pdf`: `e7619466e3b1546d8a54b7791575abff181ee70db1296ed073c4e2a09d4f7eca` (re-rendered 2026-10-15 with typst 0.15.0 after the typeface check; the template is unchanged). Each page was rendered at 60 dpi and viewed again on 2026-10-15, all 8 pages; the 2026-10-14 pixel-identity check was not repeated against the earlier file.

The exemplar pages were compared through their text layer (`pdftotext -bbox` for positions) and the overlay pairing; they were not rendered to images for this review, so layout claims about the exemplar are from its text positions.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Cover: `In re:` debtor block above the adversary parties; `Case No.`, `Chapter 7`, `Hon.` and a blank `Adv. Pro. No.` line on the right; bold title; the lead-in on this page (the first render forced a page break after the caption, which moved the lead-in to page 2; removed). | FIXED (cover page break removed; re-viewed) |
| 2 | exemplar p.2 | Section III (jurisdiction and venue) and section IV (factual background) headings; paragraphs 4 to 10; subsection A heading. | PASS |
| 3 | exemplar p.3 | Paragraphs 11 to 14; section B heading (level 3, bold italic). The first render printed the block quotation as a numbered paragraph ("12." on a line of its own, the quotation after it) and shifted the numbering; fixed by treating a `>` chunk as an unnumbered, indented, single-spaced block. The quotation layout is not measured against the exemplar. | FIXED (re-viewed; quote layout is a convention, tier 2) |
| 4 | exemplar p.4 | Paragraphs 15 to 21; section C heading; the COUNT I heading and its title on separate centered lines. The first render had the title overprint paragraph 21 (the level-2 heading had no gap below it); fixed; re-viewed. | FIXED |
| 5 | exemplar p.5 | Paragraphs 22 to 31; COUNT II heading and title. | PASS |
| 6 | exemplar p.6 | Paragraphs 32 to 40; COUNT III heading, its title wrapping to two centered lines. | PASS |
| 7 | exemplar p.7 | Paragraphs 41 to 47; COUNT IV and COUNT V headings; section VI heading and the WHEREFORE line. In the first render the WHEREFORE line sat alone at the foot of the page with its list on page 8; fixed by keeping it with the list; re-viewed. | FIXED |
| 8 | exemplar p.8 | Lettered prayer items A. to F., the date and the signature block on the right. | PASS |

## Known gaps and open choices

1. **Tier 2 is not met: one filer.** EVAL-LOOP asks for two or three filers. This is the only usable adversary complaint found in RECAP for this court. Other nywb adversary dockets checked (Advisory Trust Group v. Doud 2-22-02073; Telasco 2-21-02003, whose doc 1-2 is only a proposed summons; WebsterNT v. Lowy 1-25-01022) had no stored doc 1. The CourtListener docket pages for Dailey (1-25-01001), Pynn (1-25-01019), Hartman (2-26-02008) and Lunn (2-16-02014) returned HTTP 202 with no content on the last try and were not reviewed. The Continental adversary's doc 1 is not stored either (its docket page lists no document 1 PDF).
2. **The exemplar predates the 2016 amendment to Rule 7008(a).** It has "This action is a core proceeding" (¶ 6) and no statement of consent to final orders, which the current rule requires. The sample reproduces the filing as written, so it also lacks the consent statement. An adversary complaint filed today needs one; the template does not check it (content, author responsibility).
3. **No table of authorities or cover sheet.** The adversary cover sheet (Form 1040) is a separate filing; this template does not produce it. The sample has no table of authorities.
4. **Adversary number.** The exemplar's caption leaves the `Adv. Pro. No.` blank; the template prints a blank line when `adv_number` is absent, and the sample follows the exemplar. The clerk assigns the number.
5. **Italics.** The text layer of the exemplar has no italic markup, so case names are not italic in the sample. The template renders `*...*` italic.
6. **Typeface.** No W.D.N.Y. font rule (re-checked 2026-10-15); EB Garamond (vendored) instead of the exemplar's Helvetica. Tier 3.
7. **Local-rules version.** The only local-rules text found is a PDF whose creation date is 2013-08-14. Confirm that LBR 9004-1 and 9004-2 are current.
8. **Exhibits.** Exhibits A to E are referenced in the sample and are not part of the template.
9. **tools/check.sh not run.** The checker expects a court directory with `court.json` and `rules.md` at its root; this doc-type folder has neither, and the brief forbids editing `tools/`. Gate 0 and Gate 1 have not been run; the review above is the Gate 2 equivalent.
10. **Page count.** The exemplar is 8 pages and the sample renders to 8 pages, within the 8-14 target.

## Build

```
export PATH="$HOME/tb/bin:$PATH"
D=courts/second-circuit/new-york/federal/bankruptcy-western-district/adversary-complaint
sh tools/render.sh $D samples/INPUT-wallach-rothstein-complaint.md
sh tools/overlay.sh $D wallach-rothstein-complaint
```

File names follow the tools and CLAUDE.md contract (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the brief's `<id>.md` and `<id>-overlay.pdf` (the tools read and write the prefixed names).
