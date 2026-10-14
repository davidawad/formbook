# M.D.N.C. (ncmd): motion brief (memorandum in support of a Rule 12(b) motion)

Doc type: **motion-brief**: the brief in support of a motion to dismiss, filed in the United States District Court for the Middle District of North Carolina (`ncmd`). The motion itself is a separate document (LR 7.3(a)); this template covers the brief.
Folder: `courts/fourth-circuit/north-carolina/federal/middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-braham-26-cv-00455-motion-brief.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-braham-labcorp-brief.md` (a portion: cover, Introduction, Background, Standards of Review, the start of Argument A.1, Conclusion, signature, certificates; see gap 4) |
| render | ok: `samples/OUTPUT-braham-labcorp-brief.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-braham-labcorp-brief.pdf` and `OVERLAY-braham-labcorp-brief.txt` |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed; see the table below) |
| tier 2 | one exemplar only, so tier 2 is not judged against two or three filers (see gaps) |

## Governing rules

Primary source: M.D.N.C. Local Civil Rules, effective June 1, 2026 (adopted by the order of May 27, 2026). PDF: https://www.ncmd.uscourts.gov/sites/ncmd/files/mdnc%20local%20civil%20rules%2020260601.pdf (linked from https://www.ncmd.uscourts.gov/local-rules-and-orders). Fetched 2026-10-14; rule text read from that PDF with `pdftotext`.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| NCMD-FORM-001 | LR 7.1(a) | Letter-size paper; single-sided; unfolded and bound at the top; numbered at the bottom; no manuscript cover. | `page` settings (paper, numbered footer) |
| NCMD-FORM-002 | LR 7.1(a) | "fixed-pitch type size no smaller than ten characters per inch or in a proportional font size no smaller than 13 point." Proportional font, so 13 pt, footnotes included. | `type-size = 13pt`, `font-family` |
| NCMD-FORM-003 | LR 7.1(a) | "Typewritten ... documents shall be double spaced." and "no more than 27 lines of regularly spaced text on a page." | `pitch = 23pt`, `body-leading` (see gap 2) |
| NCMD-FORM-004 | LR 7.1(a) | Margins: top "not less than one and one-quarter inches"; bottom, left and right "not less than one inch." | `top-margin = 1.25in`, `bottom-margin`, `side-margin` |
| NCMD-FORM-005 | LR 7.1(a) | Pages "numbered at the bottom." | `running-footer` (centred page number) |
| NCMD-FIRST-001 | LR 7.1(b) | Signing party or attorney states telephone number, mailing address and e-mail address; an attorney admitted to this Court states the state bar number. | `signatures` block: the template refuses to build without `signer`, `address`, `phone`, `email`, `role`; `bar_number` is required by convention for admitted counsel and may be omitted otherwise |
| NCMD-FIRST-002 | LR 7.3(c)(1) | Motions are decided "on the pleadings ... motion papers and briefs, without hearing or oral argument, unless otherwise ordered." | No hearing date or time on the cover (CAND-style hearing block is not used) |
| NCMD-CONT-001 | LR 7.2(a) | An opening brief contains a statement of the nature of the matter, a concise statement of facts (each supported by a reference to the record), the questions presented, and the argument, which refers to all statutes, rules and authorities relied upon. | Author content, not checked by the template. The sample transcribes the exemplar's sections. |
| NCMD-CONT-002 | LR 7.3(a) | "Each motion shall be set out in a separate document" and the motion "shall be accompanied by a brief." | Scope of this template: the brief only; the notice of motion is a separate document. |
| NCMD-CONT-003 | LR 7.3(d)(1) | Briefs prepared on a computer "shall not exceed 6,250 words"; the word count "shall include the body of the brief, headings and footnotes" and excludes the caption, signature lines, certificate of service and cover or index; "Each brief shall include a certificate of word count, signed by counsel ... which includes a certification that the brief complies with this rule." | `certificates()`: "Certificate of Word Count" is generated with the 6,250-word statement and the signer. The template does **not** count words (gap 1). |
| NCMD-CONT-004 | LR 7.3(d)(3) | No incorporation by reference of other briefs. | Author content. |

Not used, and why: LR 7.3(b) (contents of the motion, not the brief), LR 7.3(e) (supporting documents), LR 7.3(d)(2) (typewritten briefs, 20-page limit; the template is computer-prepared). The table of contents and table of authorities are produced by the template as in the exemplar; the rule does not call for them.

## Layout

- Letter paper, 1.25 in top margin, 1 in bottom, left and right margins.
- Body is 13 pt EB Garamond on a 23 pt line pitch: 27 lines of text fit in the 630 pt text height (621 pt used). Measured with `pdftotext -bbox` on the render: 23.00 pt pitch on every body line.
- Cover page (unnumbered): court title, caption (parties left, closed by a right and bottom rule; case number and the title in bold right). No counsel block at the top of page 1: the exemplar has none; the counsel information is in the signature block.
- Table of contents (roman i) and table of authorities (roman ii, ...), both generated from the body's headings and `toa:` links; the body starts at page 1 in arabic numerals.
- Headings: level 2 roman (I., II.), level 3 letter (A.), level 4 number (1.), numbered by the template; level 1 centred caps for the TOC/TOA titles only.
- Signature block: "Dated" at left, "Respectfully submitted," at right, one block per signer (`/s/`, name, bar number if any, address, phone, e-mail, role in italics).
- The last section (the conclusion) is kept with the signature block, so a sign-off never stands alone on a page.
- Certificate of Word Count (LR 7.3(d)(1)) and Certificate of Service follow the signature. Neither is a numbered page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body: `#` for level 1 (not used in the body), `##`, `###`, `####` for headings, blank-line-separated paragraphs. Italics with `*...*`; footnotes `[^id]` with the definition on its own line.
- Authority links: `[text](toa:KEY)`; each KEY must appear under `authorities:` in the frontmatter (kind `case`, `statute`, `rule`, `regulation`, or `other`; `name` for cases; `cite`). A link's page is recorded in the table of authorities.
- Frontmatter fields: `case_number`; `court` (list of lines); `caption` (list of `{names, designation}`); `brief_title` (written in capitals as in the filing; the template does not change case, so rule citations keep their case); `date` (the "Dated:" line); `certificate_date` (the "This the ... day of ..." line of the certificate of word count); `service_date`; `signatures` (list of `{firm, signer, bar_number, address (list), phone, email, role}`); `authorities`.
- Escape literal asterisks used for Westlaw star pagination (`at \*3`).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/fourth-circuit/north-carolina/federal/middle-district/motion-brief samples/INPUT-braham-labcorp-brief.md
sh tools/overlay.sh courts/fourth-circuit/north-carolina/federal/middle-district/motion-brief braham-labcorp-brief
```

- `samples/OUTPUT-braham-labcorp-brief.pdf`: 10 pages. typst compiled with no warnings. Fonts: EBGaramond-Regular, -Italic, -Bold only (`pdffonts`).
- `samples/OVERLAY-braham-labcorp-brief.pdf` and `.txt`: red is our render, blue the exemplar, black where both agree. Page map: ours p.1 ↔ filed p.1 (cover); p.2 ↔ p.2 (contents); p.3 ↔ p.3 (authorities); p.4 to p.8 ↔ filed p.8 to p.14 (the memorandum); p.9 ↔ filed p.31 (signature); p.10 ↔ filed p.33 (certificate of service). The overlay is a diagnostic, not a score: the exemplar's page breaks, footers and line grid are not the same as ours.

## Visual review (every page rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: court title, caption, title (in capitals, rule citations "12(b)(1)" and "12(b)(6)" kept in lower case) | OK after fixing a defect: the template had upper-cased the title, turning "12(b)(1)" into "12(B)(1)". Fixed: the title is no longer upper-cased by the template. |
| 2 | Table of contents (roman i) | OK. Entries with leaders; page numbers in their own column. |
| 3 | Table of authorities (roman ii) | OK. Cases italic, federal rules in their own group, page numbers right-aligned. |
| 4 | Body page 1: Introduction, start of the memorandum | OK. Double spacing on the 23 pt grid; case names italic where linked. |
| 5 | Body page 2: remainder of Introduction, Background heading | OK. |
| 6 | Body page 3: Background, with a linked *Advanced Salon* cite | OK. |
| 7 | Body page 4: Background end, Standards of Review | OK. Linked *Beck*, *Twombly*, *Iqbal* cites. |
| 8 | Body page 5: Argument IV, heading A., heading 1., first paragraphs | OK. Headings kept with their text. |
| 9 | Body page 6: Conclusion (V) and both signature blocks | OK after the change that keeps the conclusion with the signature. Two signers, the second with an N.C. bar number. |
| 10 | Body page 7: Certificate of Word Count and Certificate of Service | OK. Signed by the first signer. |

Reviewed pages: 10 of 10. The cover (page 1), the argument page (5) and the signature page (6) were viewed on the final render. Pages 2 to 4, 7, 8 and 10 were viewed on the render before the last two changes (title case and keeping the conclusion with the signature); their text and pagination did not change.

## Known gaps and open choices

1. **Word count is not checked.** LR 7.3(d)(1) caps the brief at 6,250 words, counting the body, headings and footnotes. The template cannot count words; it prints the certificate text. The author must count (the filer may rely on word-processor word count) before signing. The sample is a portion and well under the cap; the exemplar is 33 pages including its front matter.
2. **"Double spaced" versus 27 lines.** The same question as the complaint: LR 7.1(a) requires double spacing and no more than 27 lines per page. A true double space at 13 pt gives about 18 lines per page; the template uses the 27-line cap at 23 pt. This is the reading the render follows. Whether the court reads "double spaced" as a fixed ratio is a question for David.
3. **Font.** Rule examples are Times-type; the exemplar is Times New Roman with Century Schoolbook headings. Only EB Garamond is vendored in `fonts/`, so the template uses EB Garamond at 13 pt (the rule's floor). EB Garamond has a smaller x-height than Times, so the text looks lighter than the exemplar.
4. **Sample is a portion.** The sample transcribes the cover, the first sections of the memorandum (Introduction, Background, Standards of Review), the first sub-heading of Argument A and its first paragraph, the conclusion, the signature blocks and both certificates. Argument A.1 onward and B to D are not transcribed, so the table of authorities lists only the authorities linked in the portion (10 entries). It is not a full table of authorities.
5. **Italics in the transcription.** The exemplar's text layer has no italic markup; case names are italic only where the sample links them (`toa:` links are italicised by hand). Unlinked case names and *Id.* are roman in the sample. The template does render `*...*`.
6. **Certificate of service.** The text is a convention modelled on the exemplar's certificate (electronic service through CM/ECF). It is not checked against Fed. R. Civ. P. 5(b) in this run (not fetched); the rule's proof-of-service requirement should be confirmed before the template is treated as complete.
7. **Local rules of the judge.** Individual judges' practice standards may add requirements not in the Local Civil Rules; not reflected.
8. **Motion and proposed order.** The notice of motion (LR 7.3(a), a separate document) and any proposed order are not generated; the proposed-order requirement was not checked in this run.
9. **Tier 2.** One exemplar only; EVAL-LOOP asks for two or three filers.
10. **Gate scripts.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither, and the brief forbids editing `tools/`. The gates were not run; render and overlay were run and the review above is the Gate 2 equivalent for this doc type.
