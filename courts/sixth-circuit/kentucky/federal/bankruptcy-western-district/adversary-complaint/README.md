# W.D. Ky. bankruptcy court (kywb): adversary complaint

Doc type: **adversary complaint** (the complaint that starts an adversary proceeding, with Exhibit A where the complaint refers to one). Court: United States Bankruptcy Court, Western District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/adversary-complaint/`.

Status: exemplar=yes, render=ok (typst, no warnings), overlay=ok, pages reviewed 7 of 7 (rendered at 60 dpi and looked at, final render). Nothing here sets a court-level `status`.

## Governing rules

The rules below are the federal rules that govern an adversary complaint in this court, plus the court's local rules. Texts were fetched 2026-10-14 from the Legal Information Institute (law.cornell.edu) and from the court's website. The local rules are a **draft**: the 2025 local rules file on the court's site, "local_rules_2025_v1_incorporated.docx", reads "Effective (______________)" and "[Note: Table of Contents will be updated once Local Rules are finalized]". Verify against the adopted text before relying on any LBR point. The local rules set no typeface, margin or spacing rules; the template's type choices are style choices (below).

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| KYWB-FORM-001 | Fed. R. Bankr. P. 9004(a) (as amended eff. Dec. 1, 2024) | "A petition, pleading, schedule, or other document must be clearly legible." | `typst/kywb-adversary-complaint.typ` (EB Garamond, 13 pt, black on white) |
| KYWB-FORM-002 | Fed. R. Bankr. P. 9004(b) | A document presented for filing must have a caption that sets forth the court's name, the case title, the case number and any adversary-proceeding number, and a brief designation of the document. | `caption()`: court title, debtor block (`caption.debtor_names`, `bankruptcy_lines`), adversary block (`caption.adversary_number`), title (`title`) |
| KYWB-FORM-003 | Fed. R. Bankr. P. 7010 | "Fed. R. Civ. P. 10 applies in an adversary proceeding—except that a pleading's caption must substantially conform to the appropriate version of Form 416." The template uses the full-caption layout of Form 416 (court, debtor block, adversary block, title); the official form text was not retrieved (see gaps). | caption layout |
| KYWB-FORM-004 | Fed. R. Civ. P. 10(b) (applied by Fed. R. Bankr. P. 7010) | A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: one number per blank-line-separated chunk; headings and "~ " paragraphs are unnumbered |
| KYWB-FIRST-001 | Fed. R. Bankr. P. 7008(a) (applies Fed. R. Civ. P. 8) | The allegation of jurisdiction must reference the name, number and Code chapter of the case the adversary relates to, and the district and division; a complaint must state whether the pleader consents to entry of final orders by the bankruptcy court. | Content is the author's (sample ¶¶3–5). The template does not check it (see gaps). |
| KYWB-SIG-001 | W.D. Ky. L.B.R. 9004-1 | "All motions, pleadings, tendered orders, and other related matters shall be typewritten and shall include the address, telephone number, and email address of the person filing the document." | `signature-block()`: counsel's address, telephone, email (`signature.lines`) |
| KYWB-SIG-002 | W.D. Ky. L.B.R. 9011-4; L.B.R. 9011-1(b) | The court will refuse any complaint "if it is not properly signed"; an image of a signature is a representation by the filer (L.B.R. 9011-1(b)(3)). | `signature-block()`: "/s/" line with the signer's name |
| KYWB-EXH-001 | W.D. Ky. L.B.R. 5005-1 (attachments) | Attachments over 40 pages must be filed as excerpts. | Exhibits are tables in the frontmatter (`exhibits`); no page limit enforced |

Not used, and why:
- **Adversary cover sheet** (Official Form 104). The court's website lists an Adversary Proceeding Cover Sheet among its most-requested forms; it is not a local form and no rule text found says the complaint must carry it. Not generated.
- **Summons.** Issued by the clerk under Fed. R. Bankr. P. 7004; not part of the complaint. Not generated.
- **Corporate ownership statement** (L.B.R. 7007.1-1). Applies to each non-individual party other than a governmental unit, so it is the defendant's filing here, not the plaintiff's (the plaintiff is an individual trustee). Not generated.
- **Certificate of service.** Not in the exemplar; no rule cited requires one for a complaint. Not generated.

## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: Complaint to Recover Preferential Transfers, Robert W. Keats, Chapter 7 Trustee v. Specialized Attorney Services Inc., Adv. Proc. No. 21-03007-acs (main case No. 19-30311-acs, jointly administered). Filed January 26, 2021 by the trustee's counsel, Fowler Bell PLLC. 8 pages.
- Provenance, searches and the caveat are in `usage/SOURCE.md`.

## Sample

- `usage/INPUT-adversary-complaint.md`: a transcription of the whole filing, all 26 allegations under the three headings (Nature of the Case, Jurisdiction and Venue, Background; Count I; Count II), the relief requested, the signature block and Exhibit A. The frontmatter carries the caption fields, the signature and the exhibit table (`exhibits`). Lines beginning `~ ` are unnumbered (the lead-in and the prayer's "WHEREFORE"). Relief items are a markdown ordered list, lettered A., B., C. by the template.
- The frontmatter comment records what is not transcribed: the ECF header and footer and the document-control number on the last page are system output and not reproduced.
- Transcription check: the text was copied from the PDF text layer and checked against the source by eye; the only known text-layer oddity is "to the 2 Acquired Firm Shareholders" in ¶7, transcribed as printed. The Exhibit A total is transcribed as printed ("$245,955.065"); see gaps.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
cd /work/repo
sh tools/render.sh courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/sixth-circuit/kentucky/federal/bankruptcy-western-district/adversary-complaint keats-v-specialized
```

- `usage/OUTPUT-adversary-complaint.typst.pdf`: 7 pages. Typst compiled with no warnings (`render.sh` fails on any warning). `pdffonts`: EBGaramond-Regular and -Bold only, embedded. Named `OUTPUT-` (the name `tools/render.sh` writes by default and `tools/overlay.sh` reads); the brief's `<id>.pdf` name was not used because the tool contract is fixed.
- `usage/OVERLAY-keats-v-specialized.pdf` and `OVERLAY-keats-v-specialized.txt`: red = our render, blue = exemplar, black = both. The page map pairs pages by word overlap: ours p.1–3 ↔ filed p.1–3 (76–83%); ours p.4 ↔ p.4 (55%); p.5–6 ↔ p.5–6 (49%, 48%); p.7 ↔ p.8 (63%, our page 7 is the exhibit, the filed exhibit is page 8). The overlay is a diagnostic, not a score: the filing is set in a different face and at a different line length, so text lines will not coincide.

## Visual review (Gate 2 record: all 7 pages, final render at 60 dpi, looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption (court title, debtor block, adversary block), title, lead-in, ¶1 | OK. The debtor block was widened (3.5 in left column) after "AND" wrapped onto its own line. "ROBERT W. KEATS, CHAPTER 7 TRUSTEE" still wraps to two lines in the party column; cosmetic. |
| 2 | ¶¶2–7, Jurisdiction and Venue, Background | OK. Inter-paragraph spacing was measured with `pdftotext -bbox`: 24.0 pt pitch throughout. Before the fix, single-line paragraphs sat 17 pt apart; fixed by giving each block a leading-sized gap above. |
| 3 | ¶¶8–12 | OK. |
| 4 | Count I heading, ¶¶13–19 | OK. |
| 5 | ¶¶20–26, Count II heading, Relief Requested heading | OK. |
| 6 | Prayer (A.–C.), signature block | OK. Items hang under their text; the signature block sits on the right half. |
| 7 | Exhibit A (transfer table), TOTAL row | OK as printed. The "Amount of Transfer" and "Last 4 digits" columns are right-aligned, including their headers. |

## Known gaps and open choices

1. **Tier 2 (exemplars).** One exemplar. The eval-loop tier-2 rule asks for two or three from different filers. Not done; a second kywb complaint (e.g. Brody v. Upstart, 25-03044, 13 pp., in RECAP) would be the next step.
2. **Form 416 not reproduced.** The caption follows the layout of the filed exemplar and the rule's requirement that the caption "substantially conform" to Form 416. The official form text was not retrieved (uscourts.gov returned 404 for the URL tried). Open: check the caption against the current Form 416A text.
3. **Jurisdiction allegation (FRBP 7008(a)).** The rule requires the jurisdictional allegation to reference the case's name, number and Code chapter and the district and division. The exemplar's ¶3 cites 28 U.S.C. §§ 1334 and 157(b) and does not do so; the template renders the author's words and cannot check them. Consent to final orders is present (¶5).
4. **Adversary cover sheet, summons, corporate ownership statement:** not generated (see Governing rules).
5. **Local rules status.** The W.D. Ky. local rules file is a draft with a blank effective date. Every LBR citation above is to that draft.
6. **Exhibit A total does not add up in the filing.** The five transfers sum to $245,955.65; the filing prints the total as "$245,955.065". Transcribed as printed; flagged, not corrected.
7. **Page count.** 7 pages against the filing's 8 (the exhibit is page 7 here). The sample is complete, so the difference is the typeface (EB Garamond 13 pt, not the filer's Times) and the filer's own spacing.
8. **Typeface and spacing are style choices**, not rules. EB Garamond (vendored, OFL) at 13 pt; 24 pt double-spaced lines, as the filed exemplar.
9. **Page numbers** are plain, centered, bottom of page. The filing's ECF header (case number and filing stamp on each page) is system output and is not reproduced.
10. **Caption wrap.** "ROBERT W. KEATS, CHAPTER 7 TRUSTEE" wraps in the party column (see review, page 1).

## Engines

The docx engine (`docx/`) is built, and its `.docx` renders, but its LibreOffice PDF was not made (see BLOCKED). Build: `sh docx/build-reference.sh docx/reference.docx` (pandoc default reference, styles and footer replaced). Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-adversary-complaint.md`, which writes `usage/OUTPUT-adversary-complaint.docx` and then fails at the `soffice` step. `docx/render.sh` (called by `tools/render-docx.sh`) runs pandoc with `docx/kywb-adversary-complaint.lua`, puts back the reference's styles and page setup, and checks the zip and XML parts.

What matches the typst form (set in `docx/reference.docx`; read from its XML, not from a rendering):

- Page: US letter, 1 in margins on all sides (`w:pgSz` 12240 x 15840, `w:pgMar` 1440).
- Font and size: EB Garamond (vendored, `fonts/eb-garamond`), 13 pt (`w:sz` 26) in the body, headings and footnotes; page number 11 pt, centered, in a PAGE field.
- Spacing: body lines exact 24 pt, first-line indent 0.5 in; headings centered, bold, keep with next; caption, counsel and signature lines single spaced.
- Caption: court title, debtor block and adversary block; the party cell carries the right and bottom rule as cell borders; title centered and bold.
- Allegations numbered 1 to 26 by the filter (a paragraph starting `~ ` is not numbered); relief items lettered A. to C. (UpperAlpha).
- Signature block indented 3 in; each exhibit starts on a new page (`pageBreakBefore`), as a bordered table, amount columns right aligned, total row bold.

What differs from typst:

- Paragraph spacing: on the typst render (7 pages, `/work/artifacts/kywb/adversary-complaint/OUTPUT-keats-v-specialized.pdf`, outside the court folder) the line pitch measured with `pdftotext -bbox` on page 2 is 24 pt within a paragraph and 29 pt between paragraphs. The docx sets no gap between paragraphs, so its paragraph pitch is 24 pt. Which one the court expects is not decided here.
- Page count: not measured for the docx (no LibreOffice); the typst render is 7 pages.
- Caption rule and column widths are Word table borders; Word and LibreOffice draw table borders slightly differently.
- Hyphenation, kerning and ligatures are the application defaults for the docx; they are not asserted.

docx BLOCKED (the checks that run on the `.docx.pdf` cannot run):

- `docx.pdf` and the Gate 0 and Gate 1 checks: `soffice` (LibreOffice) is not installed on this box, so `usage/OUTPUT-keats-v-specialized.docx.pdf` was not produced. Not passed.
- Gate 2 page review of the docx: no PDF to look at, so no pages reviewed. Not passed.
- Opening the `.docx` in LibreOffice or Word (no repair prompt): not done. Only the zip, the XML well-formedness and a pandoc read-back were checked.
- Word limits in `docs/DOCX.md` that apply to this form: none. The form has no table of contents, table of authorities or pleading line numbers.
