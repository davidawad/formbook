# caeb: motion-brief

Doc type: **motion-brief**, a memorandum of points and authorities in support of a motion in the United States Bankruptcy Court for the Eastern District of California (`caeb`): a contested matter (Fed. R. Bankr. P. 9013, 9014) or a motion in an adversary proceeding (Fed. R. Bankr. P. 7007). LBR 9004-2(c)(1) and 9014-1(d)(4) make the memorandum a document of its own, separate from the motion, the notice, the evidence and the certificate of service (a motion and its memorandum may be combined only when the whole does not exceed six pages).
Folder: `courts/ninth-circuit/california/federal/bankruptcy-eastern-district/motion-brief/` (self-contained; the court-root `typst/` and `latex/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: three filings of three filers, `usage/FILED-EXAMPLE-motion-brief.pdf` (Fox Rothschild; primary, transcribed), `FILED-EXAMPLE-motion-brief-2.pdf` (Attorney General of California), `FILED-EXAMPLE-motion-brief-3.pdf` (Wanger Jones Helsley). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (most of the 21-page memorandum: caption, introduction, I-X, three footnotes, a list, a block quotation, signature; see `usage/SOURCE.md` for what is left out) |
| typeface | LBR 9004-2(a)(4): 12 to 14 point, "Arial, Courier, Times, Times New Roman, and Helvetica, or their equivalent". Times New Roman 12 pt, named there, the house standard (`docs/FONTS.md`) and the exemplars' face; typst names `("Times New Roman", "Liberation Serif")`, the generated engines the same face. |
| engines | typst (`typst/caeb-motion-brief.typ` on `typst/layout.yaml`, an overlay of `lib/layouts/frcp-motion-brief.yaml` with the shared `pleading` key); latex and docx generated from the merged layout by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml`, `docx/xdoc.lua`; do not edit them by hand) |
| render | `usage/OUTPUT-motion-brief.{typst.pdf,latex.pdf,docx,docx.pdf}`, 19 pages each; letter, pleading paper (28 numbered lines), Times New Roman embedded only, no warnings; "19" at the upper left of page 1 in all three |
| check.sh | typst 10 passed 0 failed; latex 13 passed 0 failed; docx 14 passed 0 failed; XENG-001..003 pass on latex and docx (19 = 19 pages, 0 of 19 page ends moved, 539/539 lines) |
| overlay | diagnostic only, not committed: `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt`; ours p.1-3 pair with filed p.1-3 (67, 94, 55 % word overlap), ours p.5-19 with filed p.6-21 (44-95 %) |
| pages rendered | 57 PNG (19 pages x 3 engines), `pdftoppm -r 60` into `.overlay/<doc path>/png/`; the pod that built this folder could not display images, so every page was reviewed from its text layer and line geometry (below), and the visual look is a PM live check |

## Commands

```
sh tools/render.sh [--engine latex|docx] courts/ninth-circuit/california/federal/bankruptcy-eastern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/ninth-circuit/california/federal/bankruptcy-eastern-district/motion-brief [--engine latex|docx]
just overlay courts/ninth-circuit/california/federal/bankruptcy-eastern-district/motion-brief
cargo run -q --release --manifest-path tools/fb/Cargo.toml -- engines gen courts/ninth-circuit/california/federal/bankruptcy-eastern-district/motion-brief
```

## Governing rules

Primary source: Local Rules of Practice for the United States Bankruptcy Court, Eastern District of California (effective April 2, 2026), https://www.caeb.uscourts.gov/documents/Forms/LocalRules/LBR%20April%202026%20FINAL%20FOR%20POSTING.pdf (court-hosted PDF with a text layer, listed at https://www.caeb.uscourts.gov/LocalRulesAndGeneralOrders; fetched and read 2026-10-29). Rule IDs are those of `../rules.md`.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LBR 9004-2(a)(1), (b)(2) (CAEB-MB-FORM-001) | white letter-size paper; "a margin not less than one-half inch on all four sides of each page" | `margin`: 60 pt top and bottom, 1.5 in left (the line numbers and rules), 1 in right |
| LBR 9004-2(a)(4) (CAEB-MB-FORM-002) | "not less than 12-point type and not more than 14-point type, set for no more than an average of 10 characters per inch. Arial, Courier, Times, Times New Roman, and Helvetica, or their equivalent" | the base's `size: 12`, footnotes 12 pt; Times New Roman (the 10 characters per inch: Known gaps) |
| LBR 9004-2(a)(2), (b)(1) (CAEB-MB-FORM-003) | "consecutively numbered lines, double spaced, in the left margin"; text double-spaced except "identification of counsel, title of action, category headings, footnotes, quotations, and descriptions of real property" | `pleading`: 28 numbered lines of 24 pt; `pitch: {body: 24, single: 12}` |
| LBR 9004-2(c)(3) (CAEB-MB-FORM-005) | "numbered consecutively at the bottom center of the page. Page “1” is the first page of the document bearing the caption" | `page_number: {align: center}`, no separate numbering of the tables: caption page 1, tables 2-4, memorandum from 5 |
| LBR 9004-2(c)(4) (CAEB-MB-FIRST-001) | "The total number of pages of each document shall be noted in the upper left-hand corner on the first page" | `cover`: `{xd.last_page}` on line 1 (the shared model's last-page number, fb-595.99: typst `counter(page).final()`, LaTeX `\pageref*`, Word NUMPAGES) |
| LBR 9004-1(b) (CAEB-MB-FIRST-002) | counsel's name, address, e-mail, telephone and State Bar number, and each party represented by name and interest, "in the upper left-hand corner of the first page" | `cover`: `{counsel}`, `{counsel_role}` in a box 4.5 in wide |
| LBR 9004-2(b)(3) (CAEB-MB-FIRST-002) | "a blank space in the upper right-hand corner measuring at least 2 ½ inches from the right edge and 3 inches from the top edge for the clerk’s filing stamp" | the counsel box ends 6 in from the left edge; the court title starts on line 8 at the earliest (3.17 in down); measured on all three renders: no text right of 6 in above 3 in |
| LBR 9004-2(a)(6), (b)(5); 9014-1(c)(1)-(2), (d)(2) (CAEB-MB-FIRST-003, -004) | the caption: the court, the title of the case, the case (and adversary) number, the title of the document, the Docket Control Number "immediately below the case number" (or the adversary number), and "the date and time of the hearing and the courtroom" | `cover`: the court (constants and `division`), "In re:", the debtor, the adversary parties (optional); at the right `{case_label|Case No.}`, `Adv. Pro. No.` (optional), `DCN:`, `Chapter`, the judge (optional), Date, Time, Place |
| LBR 9004-2(b)(5)(A) (CAEB-MB-FIRST-005) | the title "just below or to the right of the caption on the first page ... may be in bold-faced print" | `cover`: `{brief_title}` centered in bold capitals below the caption |
| LBR 9014-1(d)(3)(C) (CAEB-MB-CONT-002) | the memorandum "shall be a succinct and reasoned explanation of the moving party’s entitlement to relief"; over 10 pages, "a table of contents and table of authorities" | `contents` and `authorities` always set (keyed authorities, `toa:` links) |
| LBR 9004-2(c)(1); 9014-1(d)(4) (CAEB-MB-CONT-001) | motions, notices, declarations, exhibits, memoranda and proofs of service "shall be filed as separate documents" | the template builds the memorandum alone; no motion, notice or certificate |
| LBR 9004-1(c), (c)(1)(A) (CAEB-MB-SIGN-001) | signed by the attorney, the signer's name "typed underneath the signature"; electronically, "an “/s/” and the registered user’s name" | `closing`: Dated, the firm, "/s/ {signer}", the typed names and the party represented |

## Frontmatter contract

```yaml
case_label: "Lead Case No."            # optional, "Case No." by default
case_number: "25-26876"
adversary_number: "26-02001"           # optional: a motion in an adversary proceeding
dcn: "KCO-7"                           # LBR 9014-1(c)
chapter: "11"
judge: "Hon. ..."                      # optional
division: "Sacramento Division"        # optional
counsel: [line, ..]
counsel_role: [line, ..]
caption:
  debtor: {names: [line, ..], designation: "Debtor."}
  parties:                             # optional: the adversary proceeding's parties, "v." between them
    - {names: [line, ..], designation: "Plaintiff,"}
    - {names: [line, ..], designation: "Defendant."}
hearing: {date, time, place}
brief_title: "Memorandum of Points and Authorities in Support of ..."   # set in bold capitals
date: "December 8, 2025"
signature: {firm: [line, ..], signer, lines: [line, ..]}
authorities: {key: {kind: case|statute|rule|other, name, cite, sort}}
```

The body is markdown: `#` a section (numbered I., II. on a line of its own over the title, both centered), `##` A., `###` 1.; `[text](toa:key)` marks an authority's page; `>` a block quotation; `[^n]` footnotes.

## Page review (2026-10-29)

Every page of every engine was rasterized and read from its text layer and line geometry against the exemplar (the latex and docx renders break every line and page where typst does: XENG-002/-003, 539/539 lines, so one reading of the line text covers all three; DEF-FORM-002/-004 cover the margins and line collisions on every page).

| Page | What it is | Finding |
|---|---|---|
| 1 | "19" (page total) on line 1, counsel and role (lines 1-7), the court in three centered lines (8-9), caption: "In re:", debtor, designation, ruled at right and foot; at the right "Lead Case No.", "DCN: KCO-7", chapter, judge, Date/Time/Place; the title centered in bold capitals; page number 1 | as the exemplar's page 1 (DEF-COVER-002: 7 or 8 differences by engine, all ACCEPTED in `eval.yaml`: its ruled title block, check boxes, tab columns) |
| 2 | table of contents, "Page" over the column, I.-X. with A., B. and 1.-4. | OK |
| 3-4 | table of authorities: cases, statutes, rules; "Page(s)" over the first group (p.4 holds its last three rules) | OK |
| 5-10 | introduction and footnote 1, I. Jurisdiction and Venue, II. Factual Background A.-C.4 with footnote 2 | OK; each "I." centered on its own line over the title, as the exemplar |
| 11-12 | III. Relief Requested and its bulleted list | OK; list items hang at 0.5 in |
| 13-16 | IV. Basis for Relief, A. with footnote 3, B. with the block quotation (single-spaced, indented) | OK |
| 16-19 | V.-X., Dated, firm, "/s/ Keith C. Owens", typed names, party | OK; the signature kept with the last paragraph |

## Gate 2 findings (tier 2)

| Page | Finding | Status |
|---|---|---|
| 1 | Page total: Fox Rothschild and Wanger Jones Helsley print the number alone at the upper left of page 1; the Attorney General prints none. The template prints the number alone on line 1 (LBR 9004-2(c)(4) asks only that the total be "noted"). | ACCEPTED |
| all | Footer: Fox Rothschild prints "-1-" only; the Attorney General and Wanger Jones Helsley add a short title (and a file path). LBR 9004-2(c)(3) asks for the page number at the bottom center; the template prints it alone. | ACCEPTED |
| 1 | Title: Fox Rothschild and Wanger Jones Helsley center it below the caption (Fox between two rules); the Attorney General sets it in the caption's right column. The template centers it below the caption in bold capitals, unruled. | ACCEPTED (tier 3) |
| 1 | DCN: Fox writes "DCN KCO-7", the others "DC No.: ..."; the template "DCN: ..." immediately below the case number (LBR 9014-1(c)(1)); Fox puts its jointly administered case number between them. | ACCEPTED |
| 1 | Hearing: Fox heads it "Hearing Information" with "Hearing Date", "Hearing Time", "Location" in a tab column; the others "Date"/"Hearing", "Time", "Place"/"Courtroom", "Judge". The template: Date, Time, Place. | ACCEPTED (tier 3) |
| body | Headings: Fox and Wanger Jones Helsley center "I." on its own line above the centered title, as the template does; the Attorney General sets "I. INTRODUCTION" at the margin. | OK |

## Known gaps

- **Visual review (PM live check).** The 57 PNGs were rendered but could not be displayed in the pod that built the folder; a person should look at the pages once.
- **Characters per inch.** LBR 9004-2(a)(4) asks for type "set for no more than an average of 10 characters per inch"; 12-point Times New Roman sets about 14-15. Read literally no proportional face at 12 point meets it, and all three exemplars are proportional 12-point type; not enforced (the same open question as Civil L.R. 3-4(c)(2)(C) in `../../northern-district/motion-brief/README.md`).
- **Line-fit near-tie (left out of the sample).** The exemplar's footnote 4 is not transcribed: with its mark, the line "as having a low physician supply.4 This shortage of physicians reflects a national" measures 432.04 pt in typst on a 432 pt measure, and LibreOffice fits one more word on it (XENG-003 failed on docx page 9). This is the shared model's open line-fit tolerance item (docs/EVAL-LOOP.md "Not yet in the model"; docs/open-items/fb-595.54.82.md); the gate is kept at `cross_engine: gate` rather than reporting docx.
- **Authority sort keys.** Every authority in the sample has an explicit `sort` of lower-case letters, digits and spaces (see the canb motion brief's README: lib/typst/xdoc.typ `sort-key` does not strip punctuation as lib/pandoc/xdoc.lua `sort_key` does).
- **Joint administration.** The caption has no field for the jointly administered case numbers or the joint debtors' "Affects ..." check boxes Fox prints; they can be written into `caption.debtor.names` lines.
- **Selftest.** `tools/check-selftest.sh` needs a folder-specific `checks.yaml`; this folder uses the default check set and adds no check, so the mutation selftest does not apply.
