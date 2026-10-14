# ncmb: motion-brief

Doc type: **motion brief**: a brief or memorandum of law in support of a written motion in an adversary proceeding (LR 7007-1(c)); the same form serves a contested-matter motion (LR 9013-1(e)). Court: United States Bankruptcy Court for the Middle District of North Carolina (`ncmb`). Folder: `courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-eastwood-bryant-25-02009-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`). It is a brief in support of a summary judgment motion, not a 9013-1 motion memorandum; see gap 1. |
| sample md | `samples/INPUT-eastwood-msj-brief.md`: caption, title, introduction, Nature of the Matter, the Statement of Undisputed Facts I to VII with footnotes 1 and 2, the Conclusion, the signature block and the certificate of service. The Argument is not transcribed (gap 2). |
| typeface | face required: none. The 2022 local rules, the 2025 comment draft and the 2026 rules (`Local Rules 1.1.26.pdf`) name no typeface, point size or spacing (read 2026-10-14). Substitute: none needed; the template keeps EB Garamond, the "No face named" row of `docs/FONTS.md`. See gap 6. |
| render | ok (re-rendered 2026-10-14): `samples/OUTPUT-eastwood-msj-brief.pdf`, 11 pages, typst 0.15.0, `tools/render.sh` (vendored fonts only, zero typst warnings); `pdffonts`: EB Garamond Regular, Bold and Italic embedded |
| overlay | ok (re-run 2026-10-14): `samples/OVERLAY-eastwood-msj-brief.pdf` and `samples/OVERLAY-eastwood-msj-brief.txt`. The filed exemplar is not committed, so it is passed as the third argument (see Render and overlay) |
| pages reviewed | 11 of 11 (2026-10-14: every page rendered at 80 dpi with `pdftoppm` and viewed) |

File names: the shared `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`, so those names are used rather than `<id>.pdf` and `<id>-overlay.pdf`. `tools/` was not edited.

## Governing rules

Primary sources, read 2026-10-14. The local rules are the copy dated October 7, 2022 (court PDF: https://www.ncmb.uscourts.gov/sites/default/files/local_rules/Local%20Bankruptcy%20Rules%20-%20NCMB%20%28October%207%2C%202022%29.pdf). The court's September 2025 comment draft (https://www.ncmb.uscourts.gov/sites/default/files/Local%20Rules%20for%20Comment%209.2.25.pdf) was also read; where the draft differs it is noted as a draft. The 2026 text, `Local Rules 1.1.26.pdf` (https://www.ncmb.uscourts.gov/sites/default/files/local_rules/Local%20Rules%201.1.26.pdf), was read on 2026-10-14 (see gap 4).

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NCMB-MOT-001 | LR 7007-1(a)(1)-(4) (2022 text) | A written motion in an adversary proceeding states with particularity the facts supporting it; clearly conveys the relief in separately numbered paragraphs; cites the statutes or rules relied on; and is served. | the motion itself (not part of this template); the brief supplies the authorities |
| NCMB-MOT-002 | LR 7007-1(c) (2022 text) | A brief or memorandum in support is optional but must be filed and served contemporaneously with the motion. It is limited in length to 20 pages, and page limits can be exceeded only by leave of the court. The 2025 draft, LR 7007-1(c)(2)(A), would instead limit electronically prepared briefs to 6,250 words (the word count excludes the caption, signature lines and certificate of service). | not enforced: the template does not count pages or words (gap 3) |
| NCMB-MOT-003 | LR 9013-1(b) and (e) (2022 text) | The same motion form for a contested matter: facts, numbered relief, cited rules, service. A brief in support is optional but filed contemporaneously. | as NCMB-MOT-001 and NCMB-MOT-002 |
| NCMB-MOT-004 | LR 7056-1(b) (2025 draft only) | A motion for summary judgment is accompanied by a brief and by a separate "Statement of Undisputed Material Facts" in numbered paragraphs, each supported by a record citation. The draft's LR 7056-1 heading was read; the 2022 text was not read at this level. | not produced: the exemplar puts its facts inside the brief (gap 5) |
| NCMB-SIG-001 | LR 9011-4 (2022 text), https://www.ncmb.uscourts.gov/sites/default/files/local_rules/Local%20Bankruptcy%20Rules%20-%20NCMB%20%28October%207%2C%202022%29.pdf | Every paper filed by an attorney carries the attorney's state bar number in the signature block; telephone and email should also appear. | `signature` frontmatter: `bar` and `email` for each signer, and `phone`, are required (the build fails if one is missing) |
| NCMB-SERV-001 | LR 9004-1 (2022 text), "Form of Certificate of Service" | Proof of service includes the recipient, the method of delivery, the address if the service was not through CM/ECF or hand delivery, and the identity of the person who served. | `service` frontmatter and `certificate()`: each recipient's `lines` (name and address), `method`; the `/s/` signer is the person who served |
| NCMB-FORM-001 | Fed. R. Bankr. P. 9004(a) (legible) and 9004(b) (caption), https://www.law.cornell.edu/rules/frbp/rule_9004 | Papers are clearly legible; the caption has the court's name, the case title, the case and adversary numbers, and a brief designation of the paper. | `caption`, `title`, `court` frontmatter |
| NCMB-FORM-002 | Fed. R. Bankr. P. 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 | Fed. R. Civ. P. 10 applies in an adversary proceeding; the caption must substantially conform to the appropriate Official Form 416. Form 416D (adversary proceeding caption) is the one used. Form 416D itself was not fetched; the identification is from a web search summary of the form titles. | caption, as above |

Not used and why: Fed. R. Bankr. P. 7056 (summary judgment in an adversary proceeding) is the rule the exemplar's motion rests on, but its text was not read here. No typeface, margin, line-spacing or page-number rule was found in the 2022 local rules or in the Federal Rules as read; the form below is a convention matched to the exemplar (gap 6). The certificate of service is produced because LR 9004-1 requires the proof of service to carry the listed items and the exemplar has one.

## Layout

- US Letter, 1 inch margins. The first page is the caption page: court title, caption, title of the paper, and the body starts on the same page (no separate cover page, as in the exemplar). The first page has no page number; later pages have the number centered at the foot.
- Caption: a party column, a ")" column in every row, and a case-number column; the ")" marks run the full height of the caption and the caption closes with a rule. The title is bold and centered below the rule.
- Body: double spacing (line pitch 24.0 pt, measured with `pdftotext -bbox-layout` on page 5); paragraphs indented 0.5 inch. Headings: level 1 centered bold caps (unnumbered: "Nature of the Matter", "Statement of Undisputed Facts", "Conclusion"); level 2 numbered I., II., ... bold with a hanging indent; level 3 A., B., ...; level 4 1., 2., ...; level 5 a., b., ... Headings are kept with the paragraph after them (`sticky`).
- Lists: markdown `1.` lists are numbered 1., 2., ... (as in the facts section of the exemplar).
- Footnotes: native markdown footnotes (`[^1]`, `[^1]: text`).
- Block quotations: single-spaced, indented 0.5 inch on each side.
- Signature block: the date line ("This the 14th day of November, 2025."), then `/s/` for the signer, then each attorney with bar number and email, the firm, the address, telephone and role, in a column at 3.25 inches. The block is kept together.
- Certificate of service: a new page; the statement; each recipient's name and address lines, with the method of service in italics below; the date line and `/s/` for the person who served.
- No table of contents or table of authorities: neither the local rules nor the exemplar calls for them (the exemplar has none), and a 27-page brief without them is the exemplar's form.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `court` (lines), `caption.left` and `caption.right` (rows; a row is a string or `{t, a}` with `a` = `l`, `c` or `r`), `title` (the title of the paper), `signature` (`dated`, `signed_by`, `signers` (`name`, `bar`, `email`), `firm` (lines), `address` (lines), `phone`, `role` (lines)), and `service` (optional: `statement`, `recipients` (`lines`, `method`)).
- Body: standard markdown. `#` = level 1 (centered caps), `##` = level 2 (numbered I.), `###` = level 3 (A.). Sample headings are written without numbers; the template numbers them. `*...*` italics for *Id.* and *See*, as the exemplar.
- Not supported: tables; a numbered paragraph is not numbered by the template (briefs are not numbered paragraphs).

## Known gaps and open choices

1. **The exemplar is a brief in support of a summary judgment motion, not a 9013-1 motion memorandum.** The exemplar is a filed brief in an adversary proceeding, filed with ECF 31 (the motion) under Rule 7056 and LR 7007-1(c). The template serves both the adversary brief and the contested-matter memorandum (LR 9013-1(e)), which share the same form. Only one exemplar was found (see gap 7).
2. **The Argument is not transcribed.** The sample covers the caption, the introduction, Nature of the Matter, Statement of Undisputed Facts I to VII (filed pages 1 to 9), then the Conclusion, the signature block and the certificate of service (filed pages 25 to 27). The Argument (filed pages 10 to 25, except the last paragraph of the Argument on filed page 25) is omitted. The sample therefore goes from Section VII straight to the Conclusion; the overlay shows this.
3. **Page and word limits are not enforced.** LR 7007-1(c) (2022 text) limits the brief to 20 pages. The filed brief is 27 pages including the caption, the signature block and the certificate of service. Either leave of court was given or the limit does not count those pages; the docket was not checked. The 2025 draft's 6,250-word limit for electronically prepared briefs would be counted by word, not page, and is not enforced by the template. **For David:** which limit governs (the 2022 text, the 2025 draft, or the January 2026 text) needs to be decided before the template is treated as complete.
4. **Effective January 2026 local rules: read in part.** The court's news archive lists "Local Rules Effective January 1, 2026". Earlier fetches of the court's site found no PDF link for it. On 2026-10-14 a search found the posted PDF, `Local Rules 1.1.26.pdf` (45 pages), and its text was extracted with `pdftotext`. Its LR 7007-1(c)(2) matches the 2025 draft: a 6,250-word limit for electronically prepared briefs and a 20-page limit for handwritten ones. It contains no typeface, point-size or spacing rule. Its LR 7056-1 was not compared in full, so gap 5 is still open against the 2026 text.
5. **Separate statement of undisputed facts.** The 2025 draft's LR 7056-1(b) requires a separate "Statement of Undisputed Material Facts" in numbered paragraphs. The exemplar's facts are inside the brief, in sections I to VII, not numbered paragraphs. If the draft text takes effect, a motion for summary judgment needs that separate statement, which this template does not produce. The 2022 text's LR 7056-1 was not read at this level.
6. **Typeface and size.** No rule names a typeface, so `docs/FONTS.md` ("No face named") keeps EB Garamond (vendored; no substitute to switch to). The 2022 text, the 2025 draft and the 2026 text were searched for font, typeface, point and spacing terms and none was found. The exemplar embeds Times New Roman (`pdffonts`; its point size was not measured); that is the filer's choice, not a rule. This template uses EB Garamond at 13 pt, because EB Garamond sets smaller at the same size. Visual comparison is in the overlay. The 13 pt is a style choice, not a rule.
7. **One exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers. Other NCMB motions found and not used: Eastwood's motion to disqualify (25-02009 Doc 49, 8 pages, pro se, image-only); Cournoyer v. Schamens (24-02010 Doc 10, motion to dismiss, image-only); Freeland v. U.S. Bank (26-02001) and Reid v. Assurant (25-02023), whose motions are only in RECAP as orders. No OCR tool is installed on this box. Tier 2 is judged against one filer.
8. **Certificate of service is produced in full.** The exemplar's certificate lists recipients by name and address, with the method of delivery. LR 9004-1 requires the same items.
9. **Overlay pairing.** The overlay pairs pages by word overlap. Pages 1 to 3 pair with their filed pages; later pairs can be one page off because the sample has no argument pages and the filed brief has different page breaks. The overlay is a diagnostic, not a score.

## Gate 2 review (all 11 pages, rendered at 80 dpi and looked at, 2026-10-14)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption with the ")" column, title (bold), the introduction, the heading "Nature of the Matter" | OK. No page number on the caption page (as the exemplar). |
| 2 | "Nature of the Matter" (continued); "Statement of Undisputed Facts"; Section I (facts); Section II starts | OK. The roman headings hang with their text. |
| 3 | Section II (continued) with the numbered list 1 to 4 | OK. The list hangs under its text at 0.5 inch. |
| 4 | Section II (end), Section III; footnote 1 at the foot | OK. |
| 5 | Section III (continued); footnote 2 (Judge Gregory) at the foot | OK. |
| 6 | Section IV; Section V (start) | OK. |
| 7 | Section V (continued) | OK. |
| 8 | Section V (end), Section VI | OK. |
| 9 | Section VII; "Conclusion" and its paragraph | OK. |
| 10 | Signature block alone: the date line, `/s/`, the three signers with bar numbers and emails, firm, address, telephone and role | ACCEPTED: the signature block is on its own page, as in the exemplar (its page 26). The Conclusion sits on the previous page. A keep-with-next rule would move the Conclusion to page 10; not done, because the exemplar does the same. |
| 11 | Certificate of service: statement, recipients with addresses and method in italics, date line and `/s/` | OK. |

Gate 2 rows: `OK` = viewed and acceptable. Open items: gaps 3, 4 and 5 (the rule questions), not page defects. No `OPEN` page rows.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/motion-brief samples/INPUT-eastwood-msj-brief.md
sh tools/overlay.sh courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district/motion-brief eastwood-msj-brief <path-to>/FILED-EXAMPLE-eastwood-bryant-25-02009-motion-brief.pdf
```

`exemplars/` holds `SOURCE.md` only: the filed PDF is not committed. Fetch it from the URL in `exemplars/SOURCE.md` into a directory outside the repo and pass it as the third argument, because `overlay.sh` otherwise takes the first PDF in `exemplars/`.

The overlay's page map (`samples/OVERLAY-eastwood-msj-brief.txt`) pairs sample pages 1 to 9 with filed pages 1 to 10 (word overlap 32% to 89%), and sample pages 10 and 11 with filed pages 26 and 27 (79% and 96%): the conclusion, signature and certificate are the same text in both. The gap in the middle (filed pages 11 to 25) is the Argument, which is not transcribed.

See also: [[adversary-complaint]] (the other doc type in this court).
