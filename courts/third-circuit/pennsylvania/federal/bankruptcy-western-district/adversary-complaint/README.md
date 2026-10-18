# pawb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding) in the United States Bankruptcy Court for the Western District of Pennsylvania (`pawb`).
Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-pawb-adversary-complaint-snydervbiros2302020.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-pawb-adversary-complaint-snyder.md`: the whole complaint (Parties through Count VI, prayers, signature, certificate of service) |
| typeface | face required: **none** (LBR 5005-13(b)(4) names Courier only as the size benchmark, "12 Courier or an equivalent font size"; no face is mandated). Substitute: none needed. Used: **EB Garamond** (vendored), 13 pt. Metric-compatible: n/a. See Known gaps 1. |
| render | ok: `usage/OUTPUT-pawb-adversary-complaint-snyder.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
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
| PAWB-ADV-004 | M | Font no smaller than "12 Courier or an equivalent font size", footnotes included. | W.PA LBR 5005-13(b)(4) | `type-size = 13pt` (EB Garamond); footnote entries use `type-size`. See Known gaps 1. |
| PAWB-ADV-005 | M | Created directly to PDF (not scanned), flattened, fully text-searchable. | W.PA LBR 5005-13(b)(5), (d) | Typst output; `pdftotext` yields the full text (checked: every word of the sample markdown is in the PDF) |
| PAWB-ADV-006 | M | Caption substantially conforms to Official Form 416D: court name; debtor and case number; chapter; plaintiff and defendant; Adv. Proc. No.; the title of the paper. | FRBP 7010 (FRCP 10 applies; caption per Form 416); FRBP 9004(b); W.PA LBR 7010-1(a); Form 416D | `caption(meta)`: boxed debtor and party column, case number and chapter on the right, Adv. Proc. No. blank until assigned |
| PAWB-ADV-007 | M | The judge's initials appended to the bankruptcy case number. | W.PA LBR 7010-1(a) | Frontmatter `bankruptcy_case` (the initials are part of the number as written, e.g. `22-20823-GLT`); the template prints it as given |
| PAWB-ADV-008 | M | Statement whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | FRBP 7008(a) | Author content: the sample's ¶ 9. **Not enforced by the template** (see Known gaps 3). |
| PAWB-ADV-009 | M | Jurisdiction allegation names the case, its number and chapter, the district and division (FRCP 8 via FRBP 7008(a)). | FRBP 7008(a) | Author content: ¶¶ 5 to 8 of the sample. Not enforced. |
| PAWB-ADV-010 | M | Electronic signature: "/s/" before the name, then name, address, telephone, e-mail and state Bar registration number. | W.PA LBR 5005-6(d) | `signature-block()`: "/s/ NAME", name, PA I.D., firm, address, phone, e-mail |
| PAWB-ADV-011 | A | Summons, adversary cover sheet, filing fee, FRBP 7007.1 disclosure, and any Judge-specific procedure (LBR 9013-5(a)). | FRBP 7004; Official Form 416A/B; W.PA LBR 9013-5(a) | Separate filings; not produced by this template |
| PAWB-ADV-012 | C | Double spacing with first-line indent of ½ inch; body text justified, not hyphenated. | Both exemplars (no W.PA rule sets spacing) | `body-leading = 1.35em` (double at EB Garamond's measured line box), `para-indent = 0.5in`, `hyphenate: false` |
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

- `usage/SAMPLE-pawb-adversary-complaint-snydervbiros2302020.pdf`: Snyder, as assignee of the Chapter 7 trustee, v. Biros and Biros Irrevocable Life Insurance Trust, Adv. Proc. No. 23-02020 (main case 22-20823-GLT). 13 pages, filed 2023-02-28. Provenance in `usage/SOURCE.md`.
- `usage/INPUT-pawb-adversary-complaint-snyder.md` transcribes the complaint in full: every paragraph, the six counts and their prayers, the signature block of two attorneys, and the certificate of service with its own date and signature. Paragraph numbers are generated by the template (they match the filing, which numbers its paragraphs 1 to 71; the sample has the same count). Transcription is verbatim, including the filing's own typos ("FRAUDLENT", "Chapter 7 Trustee for U Lock Inc." without the apostrophe). Paragraph 61 is transcribed as filed, which omits "value" after "reasonably equivalent".

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/adversary-complaint usage/INPUT-pawb-adversary-complaint-snyder.md
sh tools/overlay.sh courts/third-circuit/pennsylvania/federal/bankruptcy-western-district/adversary-complaint snyder-adversary-complaint
```

- `render.sh` fails on any typst warning. The render uses only the vendored EB Garamond (`pdffonts` lists EBGaramond-Regular and -Bold, embedded).
- The overlay (red = ours, blue = filed, black = both) pairs pages by word overlap: ours p.1 with filed p.1, p.2 with p.2, p.3 with p.4, p.4 with p.5, and so on to p.11 with p.12 (word overlap 51% to 92%). The pairing is coarse because the filing is 13 pages and its text flows differently; the overlay is a diagnostic, not a score. Differences that matter are in the review below.

## Visual review (Gate 2 record: all 11 pages of the current PDF, rendered at 60 dpi and viewed)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title, boxed caption (debtor, parties, case number with GLT, chapter, Adv. Proc. No.), title, lead-in, Parties heading, ¶¶ 1 to 4. | PASS |
| 2 | exemplar p.2 | Jurisdiction and Venue (¶¶ 5 to 9, consent in ¶ 9), Facts heading, ¶¶ 10 to 16. Double spacing holds. | PASS |
| 3 | exemplar p.3 | ¶¶ 17 to 26. Paragraph spacing equals the leading (fixed this pass; the first draft overlapped every paragraph). | PASS |
| 4 | exemplar p.4 | ¶¶ 27 to 32; the insider paragraph ends the Facts section. | PASS |
| 5 | exemplar p.5 | COUNT I heading centered bold caps; ¶¶ 33 to 40; WHEREFORE unnumbered; COUNT II heading and ¶¶ 41 to 42. | PASS |
| 6 | exemplar p.6 | ¶¶ 43 to 50; COUNT III and COUNT IV headings, each kept with its first paragraph. | PASS |
| 7 | exemplar p.7 | ¶¶ 51 to 60; COUNT V (§ 5104) heading wraps to two centered lines. | PASS |
| 8 | exemplar p.8 | ¶¶ 61 to 68; COUNT V (§ 5105) heading. | PASS |
| 9 | exemplar p.9 | ¶¶ 69 to 71; COUNT VI heading wraps ("§550" on the second line). Page ends with white space: the signature block did not fit and moved to p.10 whole. | ACCEPTED (heading wrap; the block is kept together by design) |
| 10 | exemplar p.10 | "Respectfully submitted," date, two single-spaced attorney blocks with "/s/". | PASS |
| 11 | exemplar p.11 | CERTIFICATE OF SERVICE: unnumbered, address blocks single-spaced with a blank line between them, date and signature. | PASS |

Every row was checked against the final PDF (the render after the last change). Gate 2 rows are recorded here, not in `reviews/`, because this folder has no `reviews/` directory.

## Known gaps and open choices

1. **Type size and face (PAWB-ADV-004).** The rule reads "12 Courier or an equivalent font size". "Or an equivalent font size" makes Courier a size benchmark, not a required face, so no substitute from `docs/FONTS.md` (TeX Gyre Cursor, Liberation Mono) is used and EB Garamond stays. The template sets EB Garamond at 13 pt: the only vendored font is EB Garamond, whose x-height is smaller than Times or Courier at 12 pt, so 13 pt is the reading that cannot be faulted. A reading of "12 pt as typed" would allow 12 pt. This is a choice for David. At 12 pt the sample would be shorter; that render was not made.
2. **Unnumbered WHEREFORE and certificate (PAWB-ADV-003).** LBR 5005-13(b)(3) says "sequentially paragraph numbered except as to briefs". The exemplar leaves each WHEREFORE clause and the certificate unnumbered, and the template follows the exemplar. A literal reading would number them. Open reading for David.
3. **Consent and jurisdiction (PAWB-ADV-008, -009).** FRBP 7008(a) requires the statement; the template does not generate or check it. A Gate 1 check (a required consent sentence) belongs in `checks.yaml` when this folder gets one.
4. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` need a court folder with `court.json` and `rules.md` (the court root has `court.json` but no `rules.md`, and this doc-type folder has neither). The gates were not run; the render and overlay were run and the review above is the Gate 2 equivalent. Gate 0 was checked by hand: every word of the sample markdown occurs in the PDF text (0 missing after the final render).
5. **Tier 2 is judged against one filer only.** Second adversary complaints that the search found, not collected (the brief asks for one exemplar per doc type): Kyle S. Uhlman v. Cardona, Adv. 23-02118, doc 1 (3 pages, https://storage.courtlistener.com/recap/gov.uscourts.pawb.383454/gov.uscourts.pawb.383454.1.0.pdf); Dlubak v. Cuddy, Adv. 23-02016 (the complaint is doc 1 of RECAP docket 66812781; not downloaded). EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met.
6. **Layout not in the rules.** Margins, spacing, caption box and the title's placement are conventions from the one exemplar and the general practice seen in W.D. Pa. filings; no rule sets them. The pleading-paper numbered lines used by the N.D. Cal. template are not used here: no W.D. Pa. rule requires them and neither exemplar uses them.
7. **Adversary number.** The number is blank until the clerk assigns it (as in the exemplar). Frontmatter `adversary_number` fills it.
8. **Local rules effective date.** W.PA LBR 1001-3 says the rules take effect July 1, 2026. The compilation read is the one the court publishes as "Localrules2026.pdf"; I did not check for a later Standing Order (LBR 1001-4) affecting caption or format.

## Engines

- **typst** (primary, `typst/`): the reference for the form.
- **docx** (`docx/reference.docx`, `docx/pawb.lua`, `docx/build-reference.sh`; output `usage/OUTPUT-pawb-adversary-complaint-snyder.docx`): pandoc 3.6.4 on the reference: EB Garamond 13 pt, exact 26 pt double and 14.95 pt single lines (the pitch measured on the typst render), 1 in margins on US Letter, 0.5 in first-line indent, page number centered in the footer. The Lua filter builds what the typst template builds: the court title, the Form 416D caption (a borderless table whose two left cells carry the rules), the title, the typed "N." paragraph numbers with a 1 in tab (not Word list numbering), the unnumbered lead-in, WHEREFORE clauses and certificate, the single-spaced address groups, the signature block from the frontmatter, and a new page for the certificate of service.
- Differences from typst: paragraph numbers are text, not automatic numbering; the caption rules are cell borders, which Word and LibreOffice draw slightly differently; the page break before the certificate is a 1 pt paragraph; EB Garamond is not embedded, so the machine that opens the file needs it installed; line breaks and page count are whatever Word or LibreOffice produce from these styles, not measured.
- Checked here: `ziptool` reads all 17 parts and `xmllint --noout` passes on every XML part; the docx was not rendered and has no visual review.
- docx BLOCKED: no checks file is readable (this folder has no `checks.yaml` and no `rules.md`; the `PAWB-ADV-*` IDs in the rules table are rule IDs, not gate checks). Every gate check measured on `usage/<id>.docx.pdf` is BLOCKED: LibreOffice cannot run in the build box, so the `.docx.pdf` cannot be produced or checked.
