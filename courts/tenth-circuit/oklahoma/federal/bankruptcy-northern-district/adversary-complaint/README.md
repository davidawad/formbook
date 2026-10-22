# N.D. Okla. Bankruptcy Court (oknb): adversary complaint

Doc type: **adversary complaint** (complaint commencing an adversary proceeding, FRBP 7001). Court: United States Bankruptcy Court for the Northern District of Oklahoma. Folder: `courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/adversary-complaint/`.

Status: **exemplar=yes**, render=ok, overlay=ok, pages reviewed 8 of 8 (every page rendered at 70 dpi and viewed). Nothing here sets a court-level `court.json` status.

## Governing rules

Dates: the local rules were read from the PDF on the court's site (version shown on its cover: "Updated March 21, 2025"); the FRBP and FRCP texts were read from Cornell LII on 2026-10-14. Statute and rule references not listed in the table below (11 U.S.C. §§ 101(36), 523(a)(2)(A)-(B), 28 U.S.C. §§ 157, 1334, 1408, 1409, FRBP 4007(c), 7004, 9015, Fed. R. Civ. P. 38-39) were **not re-fetched** this session; they are cited from the author's knowledge and must be checked before this folder is treated as complete.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| OKNB-ADV-001 | Fed. R. Bankr. P. 7001 (https://www.law.cornell.edu/rules/frbp/rule_7001), read 2026-10-14 | A proceeding to determine dischargeability of a debt (7001(6)) is an adversary proceeding, commenced by complaint. | the document type itself |
| OKNB-ADV-002 | Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008), read 2026-10-14 | The allegation of jurisdiction names the case, its number, its Code chapter, and the district where it is pending. A complaint in an adversary proceeding states whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. | `jurisdiction-md` (generated from `jurisdiction`, `core`) |
| OKNB-ADV-003 | Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010), read 2026-10-14, with Fed. R. Civ. P. 10(a)-(c) (https://www.law.cornell.edu/rules/frcp/rule_10), read 2026-10-14 | Caption with the court's name, a title, the file number; the title names all parties; claims in numbered paragraphs, each limited as far as practicable to one set of circumstances; a claim founded on a separate transaction goes in a separate count. | `caption`; `allegations` (numbered paragraphs; prayer unnumbered) |
| OKNB-ADV-004 | LBR 9004-1(A) (court's local rules PDF, Updated March 21, 2025) | 8 1/2 x 11 inches; no less than 12-point font including footnotes; margins no less than one inch; one side only; pleadings and briefs double spaced. | `type-size` 13pt; `margin` 1in; `body-leading` 1.35em (2.0em pitch); footnote size = `type-size` |
| OKNB-ADV-005 | LBR 9004-2(A) | Caption: name of the court, title of the case, the bankruptcy case number and adversary number, the chapter number directly under the case number, and a title that describes the nature of the document. | `court-title`, `caption` (Case No., Chapter, Adv. No.), `title-block` |
| OKNB-ADV-006 | LBR 9004-1(C), LBR 9011-1 | Attorney signature block shows full name, state bar number, address, email, telephone, fax if any, and the party represented. | `signature-block` (asserts `bar_number`, `telephone`, `email`) |
| OKNB-ADV-007 | LBR 7010-1 | "Form of pleadings in an adversary proceeding": see LBR 9004-1 and 9004-2. | OKNB-ADV-004, OKNB-ADV-005 |
| OKNB-ADV-008 | LBR 7003-1 | An adversary complaint not filed through ECF is accompanied by an Adversary Proceeding Cover Sheet (Official Form). | **not generated** (see gaps) |
| OKNB-ADV-009 | LBR 7004-2 | The clerk issues the summons after the complaint is filed; the summons is a separate document. | **not generated** (clerk-issued) |

Not used, and why: LBR 7007.1-1 (corporate ownership statement) applies to a corporate party and is a separate form, not part of this document. The prayer and the jury demand are conventions: a jury demand appears only when `jury_demand: true` (FRBP 9015).

## Typeface

LBR 9004-1(A) (court's local rules, "Updated March 21, 2025"; the rule text as quoted on courtrules.net, checked 2026-10-15) requires no less than 12-point font, footnotes included. It names no typeface. Under `docs/FONTS.md` rule 6 (the house standard where no face is named), the template sets **Times New Roman** 12 pt (Liberation Serif fallback; it was EB Garamond 13 pt before), and the docx names the same face. Face required: none. The 2009 exemplar sets LiberationSans (embedded) with Helvetica and Courier base-14 names (per `pdffonts`); that is the filer's choice, not a rule.

## Exemplar

`usage/FILED-EXAMPLE-adversary-complaint.pdf`: the complaint in *Atlas Telephone Company, Inc. v. Retherford*, Adv. No. 09-01059-M (Bankr. N.D. Okla., main case 09-01996-M, Chapter 7), filed July 1, 2009 by Mark A. Craige (MorrelSaffaCraige, P.C.) for four plaintiffs. 8 pages, text-based (body text extracts; EB Garamond is not used by the filer; the fonts are embedded LiberationSans and Helvetica). Source, searches, and the candidates rejected (three scanned complaints, a trustee's avoidance complaint, short student-loan complaints) are in `usage/SOURCE.md`.

Only one exemplar from this court, from one filer. Tier 2 is therefore judged against this filing and the rules, not against two or three filers. A second filer was not found on the public record reachable from this box.

## Sample

- `usage/INPUT-adversary-complaint.md` is a **transcription** of the exemplar (not synthetic). Its frontmatter says so. Parties, numbers and facts are the filer's; they are typed from the PDF's text layer, with the filer's own spelling and punctuation kept (for example "SFR" and "f/k/a/").
- Jurisdiction paragraphs (the filing's own ¶¶ 1-2) are generated from the frontmatter (`jurisdiction`, `core`), so the sample does not repeat them. The filer's paragraph numbers are not typed; the template numbers the body.
- Length: 8 rendered pages, inside the 8-14 page target for an exemplar that long.
- Naming: `INPUT-adversary-complaint.md` / `OUTPUT-adversary-complaint.typst.pdf` / `OVERLAY-adversary-complaint.pdf` and `.txt`, as the tools read and write them.

### Where the transcription departs from the filing

1. **Consent.** The filing says nothing about consent to final orders (FRBP 7008(a)). The template generates a consent sentence from `core.consent`. The frontmatter sets `consent: false`, so the generated text reads "Plaintiff does not consent..." That sentence is generated, not in the exemplar; the exemplar is silent. This is a template-versus-filing gap, not a transcription choice.
2. **Preamble numbering.** The filer's unnumbered preamble ("Ervin D. 'Bud' Raus ... allege and state that:") is numbered as ¶ 5 by the template. A complaint's preamble is unnumbered in the filing. Open (see gaps).
3. **Paragraph numbers.** The filing's ¶ 3 is ¶ 6 in the render, and so on, because the generated jurisdiction paragraphs come first. Expected; not a defect in the content.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/adversary-complaint adversary-complaint
```

- render: **ok**. `usage/OUTPUT-adversary-complaint.typst.pdf`, 8 pages, 612 x 792 pt. typst emitted no warnings (render.sh fails on any). Fonts: EBGaramond-Regular and -Bold only, embedded (that render, on the earlier EB Garamond template).
- overlay: **ok**. The filed PDF is not in this checkout; it was fetched from the RECAP URL in `usage/SOURCE.md` to a scratch directory (8 pages, matching the record) and passed to `tools/overlay.sh` as its third argument. `usage/OVERLAY-adversary-complaint.pdf` and `.txt` written. Word overlap per page, as the tool reports it: p.1 58.5%, p.2 85.3%, p.3 90.2%, p.4 82.4%, p.5 70.9%, p.6 52.9%, p.7 35.6%, p.8 60.7%. The overlay is a diagnostic, not a score. The lowest pages are 7 (35.6%) and 6 (52.9%); I did not chase the cause in this pass, and I do not claim it is line breaks.

## Visual review (Gate 2, all 8 pages rendered at 70 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (In re block, party block, Case No. / Chapter / Adv. No.), title, Jurisdiction and Venue ¶¶ 1-4, the preamble | Caption and title OK. **OPEN (tier 2):** the preamble is numbered ¶ 5; the filing's preamble is unnumbered. |
| 2 | Statement of Facts ¶¶ 6-8 | OK. Double spacing, headings, page number. |
| 3 | ¶¶ 9-12 | OK. |
| 4 | ¶¶ 13-15 | OK. |
| 5 | ¶¶ 16-22 | OK. |
| 6 | ¶¶ 23-27 (ends the facts) | OK. |
| 7 | First Claim for Relief, Second Claim for Relief (¶¶ 28-31) | OK headings. **OPEN (tier 2):** "under §" ends one line and "523(a)(2)(A)." starts the next. A non-breaking space after § is needed; the template does not add one. |
| 8 | Third Claim (¶¶ 32-33), Prayer for Relief, signature block | OK. Prayer unnumbered; signature block carries bar number, phone, email, and the party. |

Defects the overlay and the review found during the build: none in the template for this court's adversary folder in this pass. The template was not changed for this exemplar.

## Known gaps and open choices

1. **Preamble numbering** (OPEN, tier 2): the template numbers the unnumbered preamble. A complaint's opening paragraph is conventionally unnumbered.
2. **Non-breaking § ** (OPEN, tier 2): "§" can end a line, separated from its number. Fix in the template by setting a non-breaking space after § in body text.
3. **Consent** (see the sample notes): the exemplar states no consent; the template's generated sentence says "does not consent" in the sample. This is a transcription choice that the template forces.
4. **Adversary cover sheet** (LBR 7003-1) is not generated; it is an Official Form filed with the complaint when the complaint is not filed through ECF.
5. **Summons** (LBR 7004-2) is issued by the clerk; not generated.
6. **Certificate of service:** none. A complaint is served with the summons under FRBP 7004; no certificate is in the rules this template reads.
7. **Font:** Times New Roman 12 pt, the house standard (was EB Garamond 13 pt, because EB Garamond sets small at 12); it meets the LBR 9004-1(A) floor. This is a choice; the court's rule names no font (see Typeface). The committed `docx/reference.docx` names Times New Roman but still sets 13 pt on a 26 pt line. The exemplar is in LiberationSans/Helvetica, 2009.
8. **Caption layout:** the In re block and party block sit in one left column with a rule, and the case-number column on the right. LBR 9004-2(A) fixes what the caption contains, not its layout. The exemplar's layout is similar.
9. **Electronic filing:** the court's May 2024 how-to says to print the finished complaint to PDF rather than save the Word file as a PDF, so the document is flattened. The typst output is a flattened PDF.
10. **Core / non-core and consent** (FRBP 7008(a)): generated from `core`. The sample says core under § 157(b)(2)(I) and no consent. The author must choose these per complaint; the template does not decide them.
11. **Dischargeability deadline** (FRBP 4007(c)) is in the filing's ¶ 27 text, not a rule the template enforces.
12. **Jurisdiction paragraphs** cite 28 U.S.C. §§ 1334(b), 157(a), (b)(1), and venue §§ 1408, 1409(a). These are not re-fetched this session (see the governing-rules note).

## Engines

**docx** (`docx/reference.docx`, no Lua filter; built from pandoc's default reference by a scratch script).

- Matches the typst form (as built; the reference sizes are the earlier 13 pt ones, the typst template now sets 12 pt on a 24 pt line): US Letter, 1 in margins on all sides, Times New Roman 13 pt body (the typst face), footnote text 13 pt, body and headings on an exact 26 pt (double) line, block quotes and footnotes single spaced, level-1 headings bold capitals, level-2 bold centred, level-3 bold italic, page number centred in the footer. No line numbers or rules (the template has none).
- Differs: pandoc writes only the markdown body. The caption, the court title block, the generated jurisdiction and venue paragraphs (FRBP 7008(a)), the consent sentence and the signature block are produced by the typst template from the frontmatter and are **not** in the docx. Paragraph numbers follow the markdown (pandoc's own numbering), not the typst counter. The frontmatter `title` appears as pandoc's Title paragraph. This docx is therefore not a filable complaint yet.
- BLOCKED: `docx.pdf` and Gates 0-1 on the LibreOffice PDF: `soffice` is not installed on this box and cannot be installed here.
- BLOCKED: visual review of the docx pages: 0 docx pages viewed (only the typst pages were rendered and reviewed).
- BLOCKED: `tools/render-docx.sh` stops at its `unzip -tq` step because `unzip` is not installed on this box (the failure is reported as "not a valid zip"); the `.docx` itself is written before that step and was checked with libzip `ziptool` and `xmllint` (all 17 XML/rels parts well-formed).
- Not done: opening the `.docx` in Word or LibreOffice for the no-repair check; the Word pagination of the body.
