# pawb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding) in the United States Bankruptcy Court for the Western District of Pennsylvania (`pawb`).
Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md`: the whole complaint (Parties through Count VI, prayers, signature, certificate of service) |
| typeface | face required: **none** (LBR 5005-13(b)(4) names Courier only as the size benchmark, "12 Courier or an equivalent font size"; no face is mandated). Used: **Liberation Sans** 12 pt (vendored), the audited exemplar's face (Arial metrics, `data/exemplar-fonts.json`), in typst and docx alike (EB Garamond 13 pt until fb-595.68.34). See Known gaps 1. |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf` and `.docx.pdf`, 11 pages each, vendored Liberation Sans only, no warnings; the docx breaks every line and page where typst does (XENG-001..003 gated, `eval.yaml`, fb-595.68.34) |
| overlay | ok: `usage/OVERLAY-snyder-adversary-complaint.pdf` and `.txt` (page map) |
| pages reviewed | 11 of 11 (every page of the final PDF rendered at 60 dpi and viewed) |
| check gates | not run: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this folder is a doc-type folder (see Known gaps) |

## Governing rules

Primary sources, read 2026-10-14. Local rules: the W.D. Pa. Local Bankruptcy Rules compilation linked from the court's "Local Rules Currently in Effect" page, https://www.pawb.uscourts.gov/sites/default/files/lrules2026/Localrules2026.pdf (rules take effect July 1, 2026, LBR 1001-3). Federal rules: Federal Rules of Bankruptcy Procedure as restyled effective 2024-12-01, from https://www.law.cornell.edu/rules/frbp/ (rules 7001, 7008, 7010, 9004, 9013). Official Form 416D (12/15), https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf.

Kind: **M** mandated by a rule (tier 1), **C** convention seen in the exemplar (tier 2), **A** author responsibility (content the template does not produce).

| ID | Kind | Requirement | Source (rule text) | Where it lives |
|---|---|---|---|---|
| PAWB-ADV-001 | M | 8½ × 11 inch paper. | W.PA LBR 5005-13(b)(1) | `paper: "us-letter"` in `typst/pawb-adversary-complaint.typ` |
| PAWB-ADV-002 | M | Sequential page numbers on every page. | W.PA LBR 5005-13(b)(2) | `page-footer()`: centered, page 1 included |
| PAWB-ADV-003 | M | Paragraphs sequentially numbered (complaint; the brief exception does not apply). | W.PA LBR 5005-13(b)(3) | `allegations()`: each body paragraph numbered from 1; see Known gaps 2 for the unnumbered WHEREFORE and certificate |
| PAWB-ADV-004 | M | Font no smaller than "12 Courier or an equivalent font size", footnotes included. | W.PA LBR 5005-13(b)(4) | `type-size = 12pt` (Liberation Sans). See Known gaps 1. |
| PAWB-ADV-005 | M | Created directly to PDF (not scanned), flattened, fully text-searchable. | W.PA LBR 5005-13(b)(5), (d) | Typst output; `pdftotext` yields the full text (checked: every word of the sample markdown is in the PDF) |
| PAWB-ADV-006 | M | Caption substantially conforms to Official Form 416D: court name; debtor and case number; chapter; plaintiff and defendant; Adv. Proc. No.; the title of the paper. | FRBP 7010 (FRCP 10 applies; caption per Form 416); FRBP 9004(b); W.PA LBR 7010-1(a); Form 416D | `caption(meta)`: boxed debtor and party column, case number and chapter on the right, Adv. Proc. No. blank until assigned |
| PAWB-ADV-007 | M | The judge's initials appended to the bankruptcy case number. | W.PA LBR 7010-1(a) | Frontmatter `bankruptcy_case` (the initials are part of the number as written, e.g. `22-20823-GLT`); the template prints it as given |
| PAWB-ADV-008 | M | Statement whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | FRBP 7008(a) | Author content: the sample's ¶ 9. **Not enforced by the template** (see Known gaps 3). |
| PAWB-ADV-009 | M | Jurisdiction allegation names the case, its number and chapter, the district and division (FRCP 8 via FRBP 7008(a)). | FRBP 7008(a) | Author content: ¶¶ 5 to 8 of the sample. Not enforced. |
| PAWB-ADV-010 | M | Electronic signature: "/s/" before the name, then name, address, telephone, e-mail and state Bar registration number. | W.PA LBR 5005-6(d) | `signature-block()`: "/s/ NAME", name, PA I.D., firm, address, phone, e-mail |
| PAWB-ADV-011 | A | Summons, adversary cover sheet, filing fee, FRBP 7007.1 disclosure, and any Judge-specific procedure (LBR 9013-5(a)). | FRBP 7004; Official Form 416A/B; W.PA LBR 9013-5(a) | Separate filings; not produced by this template |
| PAWB-ADV-012 | C | Double spacing with first-line indent of ½ inch; not hyphenated. | Both exemplars (no W.PA rule sets spacing) | `pitch-body = 24pt` (exact double), `para-indent = 0.5in`; ragged right, not hyphenated (the cross-engine model; the exemplar is justified, a tier-3 difference) |
| PAWB-ADV-013 | C | 1-inch margins. | Both exemplars (no W.PA rule sets margins) | `margin = 1in` |
| PAWB-ADV-014 | C | Court title in bold caps, centered, on two lines above the caption. | Both exemplars | `caption()`: "IN THE UNITED STATES BANKRUPTCY COURT / FOR THE WESTERN DISTRICT OF PENNSYLVANIA" |
| PAWB-ADV-015 | C | Count headings centered and bold; the WHEREFORE clause after each count unnumbered; the certificate of service after the signature block. | Exemplar (Snyder) | `heading.where(level: 1)`; `allegations()`; `pawb-adversary-complaint()` splits the body at `# CERTIFICATE` |

## Layout

- Letter paper, 1-inch margins, page numbers centered at the foot of every page.
- Caption: court title, then a two-column box. Left: "In re:", the debtor, the parties with "v." omitted (the exemplar uses no "v."), and the designations ("Plaintiff," "Defendants."). Right: "Case No." with the judge's initials, the chapter, and "Adv. Proc. No." (blank until assigned).
- Title centered in bold caps below the caption.
- Lead-in paragraph ("AND NOW, ...") unnumbered; numbered paragraphs begin at the first heading.
- Headings: level 1 bold caps centered (COUNT headings), level 2 bold centered (Parties, Jurisdiction and Venue, Facts). A heading is sticky and stays with the paragraph after it.
- Signature block single-spaced after the last WHEREFORE clause, with "/s/" before each attorney's name.
- The certificate of service starts a new page; its paragraphs are unnumbered, its address blocks single-spaced.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `debtor` (`name`, `designation`), `bankruptcy_case` (with the judge's initials), `chapter`, `caption.parties` (list of `{names, designation}`), `adversary_number` (may be empty), `title`, `date`, `signature.blocks` (list of `{signer, pa_id, lines}`).
- Body: blank-line-separated chunks. A `#` heading is a level-1 heading (COUNT headings; the CERTIFICATE OF SERVICE); a `##` heading is level 2. Any other chunk is one numbered paragraph, except the lead-in before the first heading, a chunk that starts with WHEREFORE, and anything after `# CERTIFICATE`. A chunk with hard line breaks (trailing `\`) is set single-spaced and unindented (addresses).
- Not supported: tables, footnotes (none needed for this doc type), raw typst. Lists are lettered `(a)` by the template if used (none in the sample).
- The template contains no case-specific text; the sample's frontmatter and body supply all of it.

## Exemplar and sample

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: Snyder, as assignee of the Chapter 7 trustee, v. Biros and Biros Irrevocable Life Insurance Trust, Adv. Proc. No. 23-02020 (main case 22-20823-GLT). 13 pages, filed 2023-02-28. Provenance in `usage/SOURCE.md`.
- `usage/INPUT-adversary-complaint.md` transcribes the complaint in full: every paragraph, the six counts and their prayers, the signature block of two attorneys, and the certificate of service with its own date and signature. Paragraph numbers are generated by the template (they match the filing, which numbers its paragraphs 1 to 71; the sample has the same count). Transcription is verbatim, including the filing's own typos ("FRAUDLENT", "Chapter 7 Trustee for U Lock Inc." without the apostrophe). Paragraph 61 is transcribed as filed, which omits "value" after "reasonably equivalent".

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/adversary-complaint snyder-adversary-complaint
```

- `render.sh` fails on any typst warning. The render uses only the vendored Liberation Sans.
- The overlay (red = ours, blue = filed, black = both) pairs pages by word overlap: ours p.1 with filed p.1, p.2 with p.2, p.3 with p.4, p.4 with p.5, and so on to p.11 with p.12 (word overlap 51% to 92%). The pairing is coarse because the filing is 13 pages and its text flows differently; the overlay is a diagnostic, not a score. Differences that matter are in the review below.

## Visual review (Gate 2 record: all 11 pages on each engine, rendered at 45 dpi and viewed, 2026-10-22)

The typst and docx renders were viewed side by side; every page carries the same lines (XENG-003, 288/288).

| Page | What it is | Finding | Status |
|---|---|---|---|
| 1 | Court title, Form 416D caption (debtor row ruled at its top, party row at its foot), title, lead-in, Parties, ¶¶ 1 to 5 | Both engines alike. | PASS |
| 2 | ¶¶ 5 to 16; Jurisdiction and Venue (consent in ¶ 9); Facts | "§§ 1408" kept with its number. | PASS |
| 3 | ¶¶ 17 to 26 | | PASS |
| 4 | ¶¶ 26 to 32 | | PASS |
| 5 | COUNT I; ¶¶ 33 to 40; WHEREFORE unnumbered; COUNT II; ¶¶ 41 to 42 | Headings centered bold caps on the body pitch, kept with their paragraph. | PASS |
| 6 | ¶¶ 43 to 49; COUNT III, COUNT IV | | PASS |
| 7 | ¶¶ 50 to 59; COUNT V (§ 5104) on two centered lines | | PASS |
| 8 | ¶¶ 60 to 69; COUNT V (§ 5105) | | PASS |
| 9 | ¶¶ 69 to 71; COUNT VI | The page ends with white space: the last WHEREFORE is kept on one page with the signature block. | ACCEPTED (the signature never stands alone) |
| 10 | The last WHEREFORE; "Respectfully submitted,", the date, two single-spaced attorney blocks with "/s/" | | PASS |
| 11 | CERTIFICATE OF SERVICE: unnumbered, address blocks single-spaced with a blank line around each, date and signature | | PASS |

Changes in this pass: body on the exact 24 pt pitch, ragged right (was justified, 1.345 em leading); a paragraph's number in a 0.5 in box at the indent (was 0.3 in after the number); headings on the body pitch with no space of their own; the caption rule the height of each row; the address and signature lines on a 14 pt single pitch.

## Known gaps and open choices

1. **Type size and face (PAWB-ADV-004).** The rule reads "12 Courier or an equivalent font size". "Or an equivalent font size" makes Courier a size benchmark, not a required face, so no substitute from `docs/FONTS.md` (TeX Gyre Cursor, Liberation Mono) is used. The template sets Liberation Sans 12 pt, the face of the audited exemplar (Arial metrics; `data/exemplar-fonts.json`, which `fb lint fonts` enforces); the house face, Times New Roman, would need a `template_face` ruling there. Liberation Sans at 12 pt is larger on the page than 12 pt Times, so the size reading is safe.
2. **Unnumbered WHEREFORE and certificate (PAWB-ADV-003).** LBR 5005-13(b)(3) says "sequentially paragraph numbered except as to briefs". The exemplar leaves each WHEREFORE clause and the certificate unnumbered, and the template follows the exemplar. A literal reading would number them. Open reading for David.
3. **Consent and jurisdiction (PAWB-ADV-008, -009).** FRBP 7008(a) requires the statement; the template does not generate or check it. A Gate 1 check (a required consent sentence) belongs in `checks.yaml` when this folder gets one.
4. **Gate scripts.** `tools/check.sh <this folder>`: `RESULT: 8 checks passed, 0 failed` (typst) and `RESULT: 12 checks passed, 0 failed` (docx, XENG-001..003 gated).
5. **Tier 2 is judged against one filer only.** Second adversary complaints that the search found, not collected (the brief asks for one exemplar per doc type): Kyle S. Uhlman v. Cardona, Adv. 23-02118, doc 1 (3 pages, https://storage.courtlistener.com/recap/gov.uscourts.pawb.383454/gov.uscourts.pawb.383454.1.0.pdf); Dlubak v. Cuddy, Adv. 23-02016 (the complaint is doc 1 of RECAP docket 66812781; not downloaded). EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met.
6. **Layout not in the rules.** Margins, spacing, caption box and the title's placement are conventions from the one exemplar and the general practice seen in W.D. Pa. filings; no rule sets them. The pleading-paper numbered lines used by the N.D. Cal. template are not used here: no W.D. Pa. rule requires them and neither exemplar uses them.
7. **Adversary number.** The number is blank until the clerk assigns it (as in the exemplar). Frontmatter `adversary_number` fills it.
8. **Local rules effective date.** W.PA LBR 1001-3 says the rules take effect July 1, 2026. The compilation read is the one the court publishes as "Localrules2026.pdf"; I did not check for a later Standing Order (LBR 1001-4) affecting caption or format.

## Engines

Engine status: typst `OUTPUT-adversary-complaint.typst.pdf`; docx `OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice), 11 pages each, every line and page as typst (XENG-001..003 gated); latex not built.

- **typst** (primary, `typst/`): on `lib/typst/xengine.typ`: a 24 pt body pitch, 14 pt single lines (court title, caption, title, addresses, signature, footer), explicit block spaces.
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Liberation Sans 12 pt; Body Text in exact 24 pt lines with a 0.5 in first-line indent; single lines in 14 pt boxes) and `docx/pawb.lua` (on `lib/docx/xengine.lua`), which writes every paragraph: the court title, the Form 416D caption (a two-row table, the left cells bordered), the title, the numbered paragraphs (typed "N." and a tab to 1 in), the headings, the address lines, the signature block, the certificate of service on a new page, the footer (a centred PAGE field, `$FORMBOOK_FOOTERS`) and the section (letter, 1 in margins, `$FORMBOOK_FINAL`). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh` and a committed `reference.docx` in EB Garamond 13 pt). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none.
