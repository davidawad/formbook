# alsb: motion-brief

Doc type: **motion-brief**, a motion, or a motion with its brief or memorandum of law, in the United States Bankruptcy Court for the Southern District of Alabama (`alsb`): a contested matter (Fed. R. Bankr. P. 9013, 9014) or a motion in an adversary proceeding (Fed. R. Bankr. P. 7007).
Folder: `courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/motion-brief/` (self-contained; the court-root `typst/` and `latex/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: three filings of three filers, `usage/FILED-EXAMPLE-motion-brief.pdf` (Baird Holm LLP with Norman, Wood, Kendrick & Turner; primary, transcribed), `FILED-EXAMPLE-motion-brief-2.pdf` (Hand Arendall, L.L.C.), `FILED-EXAMPLE-motion-brief-3.pdf` (Donald J. Stewart, Cabaniss, Johnston). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (the whole 9-page motion: a case and adversary caption, numbered paragraphs, a bulleted list, two footnotes, the WHEREFORE paragraph, a long signature block of two firms); `usage/INPUT-motion-brief-4.md` (fictional, no exemplar: the LBR 9007-1 negative notice legend, a division line, Roman-numbered argument headings, a certificate of service) |
| typeface | face required: none (FRBP 9004(a) asks only that a paper be "clearly legible"; the July 1, 2026 local rules have no form rule). Times New Roman 12 pt, as all three exemplars and the house standard (`docs/FONTS.md`); typst names `("Times New Roman", "Liberation Serif")`, the generated engines the same face. |
| engines | typst (`typst/alsb-motion-brief.typ` on `typst/layout.yaml`, an overlay of `lib/layouts/frcp-motion-brief.yaml`); latex and docx generated from the merged layout by `fb engines gen` (`latex/template.tex`, `latex/xdoc.lua`, `docx/reference.xml`, `docx/xdoc.lua`; do not edit them by hand) |
| render | `usage/OUTPUT-motion-brief.{typst.pdf,latex.pdf,docx,docx.pdf}`, 9 pages each (as the filing); `usage/OUTPUT-motion-brief-4.*`, 3 pages each; letter, Times New Roman Regular and Bold embedded only, no warnings |
| check.sh | typst 20 passed 0 failed; latex 26 passed 0 failed; docx 28 passed 0 failed (both samples; XENG-001..003 pass on both: 218/218 and 72/72 lines) |
| overlay | diagnostic only, not committed: `just overlay` writes `.overlay/<doc path>/OVERLAY-motion-brief.pdf` and `.txt`; ours p.1-7 pair with filed p.1-7, ours p.8-9 with filed p.7-8 (word overlap 35-92 %) |
| pages rendered | 36 PNG (9 + 3 pages per engine), `pdftoppm -r 60` into `.overlay/<doc path>/png/`; the pod that built this folder could not display images, so the pages were reviewed from their text layer (below) and the visual look is a PM live check |

## Commands

```
sh tools/render.sh [--engine latex|docx] courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/check.sh courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/motion-brief [--engine latex|docx]
just overlay courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/motion-brief
cargo run -q --release --manifest-path tools/fb/Cargo.toml -- engines gen courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district/motion-brief
```

## Governing rules

Primary sources: the Federal Rules of Bankruptcy Procedure, and the court's Local Bankruptcy Rules effective July 1, 2026, https://www.alsb.uscourts.gov/sites/alsb/files/ALSB%20Local%20Rules%207-1-2026.pdf (a scan without a text layer, fetched 2026-10-29 and read by OCR; LBR 9029-3(d) rescinds all earlier local rules). Rule IDs are those of `../rules.md`.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRBP 9004(a) (ALSB-FORM-001) | papers "clearly legible" | 12 pt Times New Roman, double-spaced (the exemplars' form; no rule sets size, margins or spacing) |
| FRBP 9004(b) (ALSB-CONT-001) | caption: the court's name, the title of the case, the case number (and adversary number), a brief designation of the character of the paper | `constants` and `division`; `caption.debtor`, `numbers`; `caption.parties` and `adversary_numbers` (a second row); `brief_title` |
| FRBP 9013; 7007 (FRCP 7(b)(1)) (ALSB-MOT-001) | a written motion that states its grounds with particularity and the relief sought | the body (the filer's) |
| LBR 9007-1(b)(2) (ALSB-MOT-002) | a motion on negative notice carries "a negative notice legend prominently displayed on the face of the first page", "in a form substantially as follows" | `front`, `when: negative_notice`: the rule's legend in a ruled box under the title, with `negative_notice.days` and `negative_notice.serve_on` |
| LBR 9007-1(b)(3), (f) (ALSB-MOT-003) | 21 days (14 for FRBP 4001(d) agreements, 30 for claim objections); none against the United States | the filer chooses `days`; not checked |
| FRBP 9011(a) (ALSB-MOT-004, ALSB-CERT-001) | signed by an attorney of record, with the signer's address, e-mail address and telephone number | `closing`: "/s/ {signer}" and `signature.lines` at the right; `of_counsel` at the margin when given |
| FRBP 7005, 9014(b); FRCP 5(b), (d)(1)(B) | service, and proof of it | `after_tail` certificate when the frontmatter has `certificate` |
| LBR 5005 (ALSB-ELEC-002) | no filing by facsimile or e-mail | (filing practice; nothing in the paper) |

No local rule limits length (DEF-LEN-001 skips) or names a face.

## Frontmatter contract

```yaml
division: "SOUTHERN DIVISION"        # optional, under the court's name
caption:
  in_re: "In re:"                    # default "In re:"
  debtor: [line, ..]
  designation: "Debtor."             # default "Debtor."
  numbers: [line, ..]                # beside the debtor: "Chapter ..", "Case No. .." ("" a blank line)
  parties:                           # optional: an adversary proceeding, its own caption row
    - {names: [line, ..], designation: "Plaintiff,"}
    - {names: [line, ..], designation: "Defendants."}
  adversary_numbers: [line, ..]      # beside the parties: "Adv. Proc. No. .."
brief_title: "MOTION .."
negative_notice: {days: "21", serve_on: "name and address"}    # optional: LBR 9007-1 legend
signature: {date_line: [line, ..], intro, signer, lines: [line, ..], of_counsel: [line, ..]}
certificate: {text, served: [line, ..], signer, lines: [line, ..]}   # optional
```

The body is markdown: `#` a centered bold capitalized heading, `##` an argument heading at the margin (hung 0.5 in), `###` 0.5 in further; numbered paragraphs typed as `1\.`; `-` lists; `>` quotations; `[^n]` footnotes.

## Page review (2026-10-29)

Every page of every engine was rendered and its text layer read page by page against the exemplar (the latex and docx renders break every line where typst does: XENG-003, 218/218 and 72/72 lines; DEF-FORM-002/-004 cover margins and line collisions on every page).

| Page | What is on it | Finding |
|---|---|---|
| sample p1 | court name, the case row (In re, debtor, ")" column, chapter and case number), the adversary row (parties, "v.", adversary number), title, opening paragraph, "BACKGROUND", paragraph 1 and footnote 1 | as the exemplar's page 1, which also ends after footnote 1 (DEF-COVER-002: 26/29 lines paired, 0 differences) |
| sample p2-p7 | numbered paragraphs, the bulleted list (p2-p3), footnote 2 (p6), "RELIEF REQUESTED", "BASIS FOR RELIEF AND MEMORANDUM OF LAW" | the page breaks fall within a few lines of the filing's |
| sample p8-p9 | paragraphs 13-16 (p8, 18 lines), then on p9 the WHEREFORE paragraph (kept with the signature), the date lines and the two-firm signature block | the filing starts its signature on p8 and ends it on p9; the template keeps the last paragraph with a signature it does not split |
| sample-4 p1-p3 | division line, caption, title, the boxed negative notice legend, the motion, Roman-numbered headings, signature, certificate | no defect found in the text layer |

## Gate 2 findings (tier 2)

| Page | Finding | Status |
|---|---|---|
| p1 | The Baird Holm caption is set in bold and closes the case row with a rule ("____)"); Hand Arendall and Stewart set the caption plain with no rule, as the template does. | ACCEPTED (tier 3) |
| p1 | Hand Arendall uses a ":" column; Baird Holm and Stewart ")", as the template. | ACCEPTED (tier 3) |
| all | Footnotes: the exemplars set them at 10-11 pt; the template keeps them at the 12-point floor of the base (no S.D. Ala. rule sets either). | ACCEPTED |
| p8 | The WHEREFORE paragraph goes to p9 with the signature (the 20-line signature group is never split and keeps the last paragraph with it); p8 is 18 lines, the others 22-27. | ACCEPTED |

## Gaps

- **Visual review (PM live check).** The PNGs of every page were rendered but could not be displayed in the pod that built the folder; a person should look at the 36 pages once.
- **Local rules by OCR.** The 2026 local rules exist only as a scan; the rules quoted here come from OCR output (tesseract), checked by reading the OCR text, not against the page images.
- **Italics not transcribed** (case names): `pdftotext` cannot see them.
- **The filing's "⁋⁋".** The primary exemplar types a reversed pilcrow (U+204B); the sample types the common sign "¶¶" (U+00B6), a transcription choice.
- **Selftest.** `tools/check-selftest.sh` needs a folder-specific `checks.yaml`; this folder uses the default check set and adds no check, so the mutation selftest does not apply (docs/EVAL-LOOP.md, "Tenth Circuit part 00 adoption").
