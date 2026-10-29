# akb: motion-brief

Doc type: **motion-brief**, a motion or a memorandum in support of one in the United States Bankruptcy Court for the District of Alaska (`akb`): a contested matter (Fed. R. Bankr. P. 9013, 9014) or a motion in an adversary proceeding (Fed. R. Bankr. P. 7007, 7012(b)).
Folder: `courts/ninth-circuit/alaska/federal/bankruptcy-district/motion-brief/` (self-contained; the court-root `typst/` and `latex/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: three filings of three filers, `usage/FILED-EXAMPLE-motion-brief.pdf` (Birch Horton Bittner & Cherot; primary, transcribed), `FILED-EXAMPLE-motion-brief-2.pdf` (David H. Bundy, P.C.), `FILED-EXAMPLE-motion-brief-3.pdf` (Erik LeRoy, P.C.). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (the whole 8-page memorandum: 23 footnotes, a block quotation, three headings, signature and certificate of service in frontmatter); `usage/INPUT-motion-brief-4.md` (fictional, no exemplar: an adversary-proceeding caption in the Official Form 416D form, lettered argument headings) |
| typeface | face required: none (LBR 9004-1(a)(7): "twelve (12) point or ten (10) pitch type"). Times New Roman 12 pt, the house standard (`docs/FONTS.md`); typst names `("Times New Roman", "Liberation Serif")`, the generated engines the same face. The exemplars are set in Arial (two) and Arial with Times New Roman (one): one filer's choice each, tier 3. |
| engines | typst (`typst/akb-motion-brief.typ` on `typst/layout.yaml`, an overlay of `lib/layouts/frcp-motion-brief.yaml`); latex and docx generated from the merged layout by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml`, `docx/xdoc.lua`; do not edit them by hand) |
| render | `usage/OUTPUT-motion-brief.{typst.pdf,latex.pdf,docx,docx.pdf}`, 8 pages each (as the filing); `usage/OUTPUT-motion-brief-4.*`, 3 pages each; letter, Times New Roman Regular and Bold embedded only, no warnings |
| check.sh | typst 20 passed 0 failed; latex 26 passed 0 failed; docx 28 passed 0 failed (both samples; XENG-001..003 pass on both: 196/196 and 62/62 lines) |
| overlay | diagnostic only, not committed: `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt`; ours p.1-8 pair with filed p.1-8 (word overlap 49-86 %) |
| pages rendered | 33 PNG (22 pages x the engines: 8 + 3 per engine), `pdftoppm -r 60` into `.overlay/<doc path>/png/`; the pod that built this folder could not display images, so the pages were reviewed from their text layer (below) and the visual look is a PM live check |

## Commands

```
sh tools/render.sh [--engine latex|docx] courts/ninth-circuit/alaska/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/ninth-circuit/alaska/federal/bankruptcy-district/motion-brief [--engine latex|docx]
just overlay courts/ninth-circuit/alaska/federal/bankruptcy-district/motion-brief
cargo run -q --release --manifest-path tools/fb/Cargo.toml -- engines gen courts/ninth-circuit/alaska/federal/bankruptcy-district/motion-brief
```

## Governing rules

Primary source: Local Bankruptcy Rules, District of Alaska (12/2024), https://www.akb.uscourts.gov/sites/akb/files/2024%20-%20Local%20Bankruptcy%20Rules.pdf (court-hosted PDF with a text layer, fetched 2026-10-29). Rule IDs are those of `../rules.md`.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LBR 9004-1(a)(1)-(2) (AKB-FORM-001) | "letter size (8½ inches X 11 inches) white paper"; "a margin of not less than one inch (1”) on all four sides of each page" | the base layout: letter page, 72 pt margins |
| LBR 9004-1(a)(4) (AKB-FORM-002) | "double-spaced or one-and-one-half-spaced ... except that quotations exceeding fifty (50) words are to be single-spaced and indented" | `pitch.body: 27.6` (double); `quote`: single-spaced, 0.5 in each side |
| LBR 9004-1(a)(5) (AKB-FORM-004) | "each consecutive page numbered at the bottom of each page" | the base's centered page number in the bottom margin |
| LBR 9004-1(a)(7) (AKB-FORM-003) | "twelve (12) point or ten (10) pitch type" | `size: 12`, footnotes 12 pt too |
| LBR 9004-1(a)(9) (AKB-CERT-001) | "names are to be typed or printed beneath signatures" | `closing`: "By: /s/ {signer}" then the signers' typed lines; the certificate's signer the same |
| LBR 9004-1(c)(1) (AKB-COVER-002) | a caption that conforms to Official Form 416B, or 416D in an adversary proceeding | `front`: "In re", the debtor, its designation, the parties when `caption.parties` is given, a ")" column, the numbers at the right |
| LBR 9004-1(c)(2) (AKB-COVER-001) | "The name, address, telephone number and email address of the attorney ... and the name of the party ... in the space to the left of center of the paper and beginning at least one inch (1”) below the top edge", then the party represented | `front`: `{counsel}` in a 4-inch column at the top left, inside the 1-inch margin |
| LBR 9013-1(a) (AKB-MOT-001) | "a clear and concise written statement of the relief requested and reasons in support thereof, including relevant facts and citations to authorities" | the body (the filer's); the exhibits, proposed order and declarations are separate papers |
| LBR 9011-1(a)(1)[B] | "the form of “/s/” followed by the registered participant’s typed name" | `By: /s/ {signature.signer}` |
| FRBP 9004(b) | caption: court name, title of the case, case number (and adversary number), brief designation of the character of the paper | `constants` (court name), `caption`, `brief_title` |
| FRBP 7005, 9014(b); FRCP 5(b), (d)(1)(B) (AKB-MOT-004) | service, shown by a certificate | `after_tail` certificate when the frontmatter has `certificate` |

No local rule limits the length of a motion or memorandum (the 12/2024 rules were searched for "page"); DEF-LEN-001 skips. The rules name no face.

## Frontmatter contract

```yaml
counsel: [line, ..]                  # LBR 9004-1(c)(2): name(s), bar numbers, firm, address, telephone, e-mail; "" for a blank line; whom they represent
caption:
  debtor: [line, ..]                 # the debtor's names as in the case title
  designation: "Debtor."             # default "Debtor."
  parties:                           # optional: an adversary proceeding (Official Form 416D)
    - {names: [line, ..], designation: "Plaintiff,"}
    - {names: [line, ..], designation: "Defendant."}
  numbers: [line, ..]                # at the right: "Case No. ..", "Chapter ..", "Adv. Proc. No. .." ("" a blank line)
brief_title: "MEMORANDUM IN SUPPORT OF .."
signature: {date_line, firm, counsel_for: [line, ..], signer, lines: [line, ..]}
certificate: {text, served: [line, ..], signer, lines: [line, ..]}   # optional
```

The body is markdown: `#` a centered bold heading, `##` an argument heading at the margin (hung 0.5 in), `###` a sub-heading 0.5 in; `>` a block quotation; `[^n]` footnotes.

## Page review (2026-10-29)

Every page of every engine was rendered and its text layer read page by page against the exemplar (the latex and docx renders break every line where typst does: XENG-003, 196/196 and 62/62 lines, so one reading of the line text covers all three; DEF-FORM-002/-004 cover the margins and line collisions on every page).

| Page | What is on it (both samples, every engine) | Finding |
|---|---|---|
| sample p1 | counsel block, court name, caption with ")" column and rule, title, opening paragraph, "Background Facts" | as the exemplar's page 1 (DEF-COVER-002: the six differences are Birch Horton's letterhead shift and running footer, ACCEPTED in `eval.yaml`) |
| sample p2-p6 | body, the block quotation (p2), 23 footnotes at the page feet | the filed page breaks fall within a few lines of ours (overlay page map p1-p8 = filed p1-p8) |
| sample p7 | last paragraphs, "Conclusion", date line and signature block kept with the last paragraph | as the exemplar (its signature is on p7) |
| sample p8 | certificate of service | as the exemplar (p8) |
| sample-4 p1-p3 | 416D caption (debtor, then plaintiff v. defendant, numbers at the right), lettered headings, signature, certificate on p3 | no defect found in the text layer |

## Gate 2 findings (tier 2)

| Page | Finding | Status |
|---|---|---|
| all | All three filers print a running footer with a short title and the page ("MEMO IN SUPPORT ... PAGE 1 OF 8", "Motion to Determine Tax Liabilities B Page 1", "NEA's Cash Collateral Motion page 1"); the template prints the page number alone, which LBR 9004-1(a)(5) asks for. The shared model's footer takes `{page}` and `{pages}` only, no frontmatter field (`lib/typst/xdoc.typ` `page_number.text`), so a short-title footer needs a change to the shared model in all three engines. | ACCEPTED |
| p1 | Birch Horton's letterhead runs down the left edge and shifts its text 84 pt right; Bundy and LeRoy set the text at the margin, as the template does. | ACCEPTED (tier 3) |
| p1 | The rule under the caption's party column: Birch Horton draws it, Bundy types it as underscores, LeRoy has none; the template draws it under the party and ")" columns. | ACCEPTED |
| last | Birch Horton and Bundy set the certificate of service in a narrow block at the left; the template sets it at the full measure, single-spaced (no rule asks either). | ACCEPTED (tier 3) |

## Gaps

- **Visual review (PM live check).** The PNGs of every page were rendered but could not be displayed in the pod that built the folder; a person should look at the 33 pages once.
- **Italics not transcribed.** The exemplar italicizes case names; `pdftotext` cannot see italics, so the sample does not mark them.
- **Notice of the motion.** The 12/2024 rules require a notice with a motion (unless ex parte); it is a separate paper, not built here.
- **Selftest.** `tools/check-selftest.sh` needs a folder-specific `checks.yaml`; this folder uses the default check set and adds no check, so the mutation selftest does not apply (as for the other default-check bankruptcy folders, docs/EVAL-LOOP.md "Tenth Circuit part 00 adoption").
