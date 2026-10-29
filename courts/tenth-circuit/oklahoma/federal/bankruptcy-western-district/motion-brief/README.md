# okwb: motion-brief

Doc type: **motion-brief**, a motion with its brief in support in the United States Bankruptcy Court for the Western District of Oklahoma (`okwb`). LR 9013-1(C) requires the brief and lets it be combined with the motion "provided the title of the Document clearly so indicates"; LR 9013-1(G) puts the Notice of Opportunity for Hearing in the same paper.
Folder: `courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district/motion-brief/` (self-contained; the court-root `typst/` and `latex/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: three filings of three filers, `usage/FILED-EXAMPLE-motion-brief.pdf` (Lindauer & Vaughn; primary, transcribed), `FILED-EXAMPLE-motion-brief-2.pdf` (Garvin, Agee, Carlton & Mashburn, P.C.), `FILED-EXAMPLE-motion-brief-3.pdf` (United States Attorney, W.D. Okla.). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (pages 1-8 of the filing: counsel block, the court-ordered notice and notice of hearing, 25 numbered paragraphs under five headings, a footnote, signature, the certificate of service with its service list; the CM/ECF mailing matrix on pages 9-11 is not transcribed); `usage/INPUT-motion-brief-4.md` (fictional, no exemplar: an adversary caption, the rule's own Notice of Opportunity for Hearing with the days filled in, a certificate with the LR 9007-1(D) particulars) |
| typeface | face required: none (LR 9004-1(A): "printing in no less than 12-point font (including footnotes)"). Times New Roman 12 pt, as all three exemplars and the house standard (`docs/FONTS.md`); typst names `("Times New Roman", "Liberation Serif")`, the generated engines the same face. |
| engines | typst (`typst/okwb-motion-brief.typ` on `typst/layout.yaml`, an overlay of `lib/layouts/frcp-motion-brief.yaml`); latex and docx generated from the merged layout by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml`, `docx/xdoc.lua`; do not edit them by hand) |
| render | `usage/OUTPUT-motion-brief.{typst.pdf,latex.pdf,docx,docx.pdf}`, 8 pages each (the filing's 8 before its mailing matrix); `usage/OUTPUT-motion-brief-4.*`, 3 pages each; letter, Times New Roman Regular and Bold embedded only, no warnings |
| check.sh | typst 22 passed 0 failed; latex 28 passed 0 failed; docx 30 passed 0 failed (both samples; DEF-LEN-001 against the 20-page limit; XENG-001..003 pass on both: 219/219 and 74/74 lines) |
| overlay | diagnostic only, not committed: `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt`; ours p.1-8 pair with filed p.1-8 (word overlap 92-99 %) |
| pages rendered | 33 PNG (8 + 3 pages per engine), `pdftoppm -r 60` into `.overlay/<doc path>/png/`; the pod that built this folder could not display images, so the pages were reviewed from their text layer (below) and the visual look is a PM live check |

## Commands

```
sh tools/render.sh [--engine latex|docx] courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district/motion-brief [--engine latex|docx]
just overlay courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district/motion-brief
cargo run -q --release --manifest-path tools/fb/Cargo.toml -- engines gen courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district/motion-brief
```

## Governing rules

Primary source: Local Rules of the United States Bankruptcy Court for the Western District of Oklahoma, effective January 15, 2026 (amended per General Order No. 26-01), https://www.okwb.uscourts.gov/sites/okwb/files/Local_Rules.pdf (court-hosted PDF with a text layer, fetched 2026-10-29). Rule IDs are those of `../rules.md`.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LR 9004-1(A) (OKWB-FORM-001, OKWB-FONT-001) | "8½ inches wide by 11 inches long"; "printing in no less than 12-point font (including footnotes)"; "margins of no less than one (1) inch"; "double spaced (unless the Document is only one (1) page)"; "shall not include printing or images in color" | the base: letter, 72 pt margins, `size: 12` with 12 pt footnotes, black text; `pitch.body: 27.6` |
| LR 1005-1 (OKWB-CONT-001) | caption per the Official Form; "Every case and adversary proceeding number must be followed by the letters which designate the Judge"; "The Chapter ... should be shown below the case number" | `front`: "In re:", `caption.debtor`, `caption.numbers` (the filer types the number with the judge's letters, then the chapter), `caption.parties` and `adversary_numbers` in an adversary proceeding |
| LR 9004-1(C) (OKWB-CONT-006) | "The title of any Document filed must clearly identify each and every request for relief" | `brief_title`, bold and centered (the filer's words) |
| LR 9013-1(C) (OKWB-CONT-005, OKWB-LEN-001) | a motion "must be accompanied by a concise brief"; "No brief longer than twenty (20) typewritten pages"; a brief over fifteen pages has a table of contents and a table of authorities | `eval.yaml` `params.page_limit: 20` (DEF-LEN-001, every page counted); the tables: see Gaps |
| LR 9013-1(G) (OKWB-CONT-004) | "all motions ... shall include in the title “And Notice of Opportunity for Hearing,” and immediately below the title shall contain the following statement" (the rule's text, with the response days) | `front`, `when: notice`: the heading and, with `notice.days`, the rule's statement word for word (the court's address is the rule's), half an inch in on each side; or `notice.text`, the filer's statement where an order sets another deadline |
| LR 9013-1(F) (OKWB-CONT-007) | notice of a hearing "may be combined in one Document with the request for relief" | `front`, `when: hearing`: "NOTICE OF HEARING" and its text |
| LR 9004-1(D) (OKWB-CERT-001) | beneath the signature line "the electronic filer’s full name, state bar number (if applicable), address, email address, telephone number, facsimile number (if applicable), and name of party or parties represented" | `closing`: "/s/ {signer}" and `signature.lines` beneath it |
| LR 9007-1(D) (OKWB-CERT-002) | a certificate of service with the names and addresses of those served other than through ECF, the date and manner, and the signer's signature, typed name, address, telephone and bar number | `after_tail`: on its own page, `certificate.text`, `certificate.served`, the signer and `certificate.lines` |

## Frontmatter contract

```yaml
counsel: [line, ..]                  # optional: counsel's block at the top left (no rule asks for it)
division: "OKLAHOMA CITY DIVISION"   # optional
caption:
  debtor: [line, ..]
  designation: "Debtor."             # default "Debtor."
  numbers: [line, ..]                # "Case No. 26-11985-sah", "Chapter 11" (LR 1005-1) ("" a blank line)
  parties: [{names: [line, ..], designation}, ..]   # optional: an adversary proceeding, its own caption row
  adversary_numbers: [line, ..]
brief_title: ".. AND BRIEF IN SUPPORT AND NOTICE OF OPPORTUNITY FOR HEARING"
notice: {days: "21", serve: "and the chapter 7 trustee"}    # LR 9013-1(G), the rule's text; or {text: "..."}
hearing: "..."                       # optional: notice of a hearing set by the court
signature: {date_line, intro, signer, lines: [line, ..]}
certificate: {text, served: [line, ..], signer, lines: [line, ..]}
```

`notice.serve` replaces the rule's bracketed "and others who are required to be served" (the default). The body is markdown: `#` a centered bold capitalized heading (the filer types "I." etc.), `##` a point at the margin hung 0.5 in, `###` 0.5 in further; numbered paragraphs typed as `1\.`; `>` quotations; `[^n]` footnotes.

## Page review (2026-10-29)

Every page of every engine was rendered and its text layer read page by page against the exemplar (the latex and docx renders break every line where typst does: XENG-003, 219/219 and 74/74 lines; DEF-FORM-002/-004 cover margins and line collisions on every page).

| Page | What is on it | Finding |
|---|---|---|
| sample p1 | counsel block, court name, division, caption, title, NOTICE OF OPPORTUNITY FOR HEARING, NOTICE OF HEARING | as the exemplar's page 1 (99 % word overlap; DEF-COVER-002: the two differences are Lindauer's break of the court's name, ACCEPTED in `eval.yaml`) |
| sample p2-p6 | "TO THE HONORABLE ...", paragraphs 1-22 under headings I-V, footnote 1 (p2) | each page starts within a line of the filing's (92-98 % overlap) |
| sample p7 | paragraphs 23-25, WHEREFORE, date line, signature block | as the exemplar's p7 |
| sample p8 | certificate of service on its own page, the four service groups, signer | as the exemplar's p8 |
| sample-4 p1-p3 | court name, case and adversary rows, title, the rule's notice with "14 days", the motion and brief, signature (p2), certificate (p3) | no defect found in the text layer |

## Gate 2 findings (tier 2)

| Page | Finding | Status |
|---|---|---|
| p1 | Lindauer sets the caption, title and notices in bold and justifies the notice; the template sets the caption plain and the notice ragged, bold only for the headings and title. The rule sets no type style for it. | ACCEPTED (tier 3) |
| all | Lindauer prints a running footer (short title, "PAGE n"); Mashburn and Sewell print the page number alone, as the template. | ACCEPTED (tier 3) |
| p1 | Mashburn and Sewell put the notice after the argument; LR 9013-1(G) puts it "immediately below the title", where the template and Lindauer set it. | ACCEPTED (the rule decides) |

## Gaps

- **Table of contents and authorities (named, not built).** LR 9013-1(C) requires both for a brief over fifteen pages. The layout does not set them: the shared model has the blocks (`contents`, `authorities` in `lib/typst/xdoc.typ`), but no sample here runs over fifteen pages to gate them. A brief that long needs a layout change (and a sample) before this template serves it; the 20-page limit itself is checked.
- **The title's "And Notice of Opportunity for Hearing"** (LR 9013-1(G)) is the filer's text; no check reads the title for it.
- **Visual review (PM live check).** The PNGs of every page were rendered but could not be displayed in the pod that built the folder; a person should look at the 33 pages once.
- **Mailing matrix.** The CM/ECF label matrix a filer attaches for mail service is a separate printout, not part of the template.
- **Selftest.** `tools/check-selftest.sh` needs a folder-specific `checks.yaml`; this folder uses the default check set and adds no check, so the mutation selftest does not apply (docs/EVAL-LOOP.md, "Tenth Circuit part 00 adoption").
