# U.S. Bankruptcy Court, S.D. Georgia (gasb): motion with memorandum of law

Doc type: **motion with memorandum** (a written motion under FRBP 9013, or a Rule 12 motion in an adversary proceeding under FRBP 7012 (cited by the exemplar; its text was not fetched), with the memorandum of law in the same document). Court: United States Bankruptcy Court for the Southern District of Georgia. Folder: `courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district/motion-brief/`.

Status: exemplar=yes (2 filed exemplars, 2 filers; the sample follows the first), render=ok, overlay=ok, pages reviewed 7 of 7. Nothing here sets `court.json` status.

## Governing rules

Dates: each rule below was fetched on 2026-10-14. The federal rules are from Cornell LII (current text, as amended Apr. 2, 2024, eff. Dec. 1, 2024). The local rules are the court's own, and older than the federal rules: see "Local rules currency" in `../adversary-complaint/README.md`, which applies here too.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| GASB-FORM-001 | FRBP 9004(a) (https://www.law.cornell.edu/rules/frbp/rule_9004) | "A petition, pleading, schedule, or other document must be clearly legible." | typeset body |
| GASB-FORM-002 | S.D. Ga. LBR, Uniformity of Practice (https://www.gasb.uscourts.gov/sites/gasb/files/local_rules/GASB-localRules.pdf, "current as of May 2017") incorporating S.D. Ga. LR 10.1 (https://www.gasd.uscourts.gov/sites/gasd/files/Local_Rules_of_Civil_Procedure_Printable_rev_June_2016.pdf, Rev. June 2016) | "… be double-spaced, be numbered on each page …" | `line-pitch` = 24 pt, `body-leading` |
| GASB-FORM-003 | LR 10.1 (as incorporated) | Page numbering "shall begin on the first page of a submission, including any title page, cover sheet …" | the caption page is page 1 |
| GASB-CAP-001 | FRBP 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | Caption: (1) the court's name, (2) the case's title, (3) the case number and, if appropriate, the adversary-proceeding number, (4) "a brief designation of the document's character." | `court-title`, `caption-table`, `title` (the chapter is also printed, as the exemplar does) |
| GASB-CAP-002 | FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010), FRCP 10(a) | The caption must name the parties. | `caption-left`: the `caption` sides and the trustee block |
| GASB-CAP-003 | FRBP 7010 | Caption "must substantially conform to the appropriate version of Form 416." | **Open: not verified** (see `../adversary-complaint/README.md`, GASB-CAP-003). |
| GASB-MOT-001 | FRBP 9013(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9013) | A request for an order is made "by written motion," which "must state its grounds with particularity and set forth the relief or order requested." | author-written: the body and the closing requests (the template checks neither) |
| GASB-MOT-002 | S.D. Ga. LR 7.1(b) (district rule; incorporated only "if directed by the Bankruptcy Judge or by the Notice issued by the Bankruptcy Clerk," per the Uniformity of Practice table) | "A motion and supporting memorandum (brief) may be filed as one document." | the motion and memorandum are one document (as in the exemplar) |
| GASB-CERT-001 | S.D. Ga. LR 5.1 (as incorporated, Rev. June 2016) | "Each paper served other than by a United States Marshal shall include a certificate of the person or firm making service, his or its relationship to the parties, action, or proceeding, and the date, method, and address of service. The original of a certificate shall also be signed by the party or his attorney at whose instance service was made." | `certificate-block`: required in the metadata (the template stops without it) |
| GASB-SIG-001 | S.D. Ga. LR 11.1 (as incorporated, substituting FRBP 9011) | Counsel's name, complete address (street and post office box), telephone number and State Bar Number, on every pleading, motion or other paper. | `signature-block`: `signature.firm`, `signer`, `role`, `address` are required |

Not generated, on purpose (see Known gaps): the proposed order. LBR 9072-1(a) (the court's 2017 local rules, see "Local rules currency") says: "At the time of filing a motion seeking any relief in this Court, the movant shall file along with the motion, a proposed order." The proposed order is a separate document (LBR 9072-1(d) also sets how its signer is identified).

Not applied, because the rule is conditional and the judge has not been shown to direct it: LR 7.1(a) (26-page limit on a brief, which counts the certificate of service; title pages, tables of contents and tables of cases are optional). The sample is 7 pages.

## Exemplars

Two filed exemplars, from different filers. The first is primary; the second is for the tier-2 comparison.

1. **`usage/SAMPLE-gasb-motion-brief-howard2305004.pdf`** (primary): Defendant's Motion to Dismiss Adversarial Complaint and Memorandum of Law in Support, ECF 12, *Howard v. City of Douglas Utility Dept.*, Adv. Pro. No. 23-05004, Chapter 13 No. 23-50574, Waycross Division (Judge Michele J. Kim). 7 pages, text layer present. Filed Jan. 5, 2024 by Freeman Mathis & Gary, LLP (Brian S. Goldberg) for the City of Douglas Utility Department. Its embedded document title is a SharePoint draft path, but the RECAP entry is the filed document.
2. **`usage/SAMPLE-gasb-motion-brief-prucohirsch2304021.pdf`** (second filer): Memorandum of Law in Support of Motion to Dismiss Crossclaim, ECF 29, *Pruco Life Insurance Co. v. Hirsch et al.*, Adv. Pro. No. 23-04021-EJC, Savannah Division. 27 pages, text layer present. Filed Mar. 1, 2024 by Jones & Walden LLC (Leon S. Jones) for Judith Hirsch. **The memorandum only**: the motion it supports (ECF 28) is not on RECAP, so the notice-of-motion part of this doc type is not shown by this exemplar. Used for memorandum style, not for the caption.

Provenance and searches: `usage/SOURCE.md`.

## Sample

- `usage/INPUT-gasb-motion-brief-howard.md` transcribes the whole of the primary exemplar: caption (with the trustee block), the introduction, the three argument headings (A, B, C) with their text, the conclusion with its four requests, the signature block and the certificate of service.
- Transcription choices: the filing's paragraph symbol "⁋" is written as "¶"; the filing's "(Emphasis added.)" in the § 106(a)(3) quotation is kept, but the emphasis it refers to is not reproduced (pdftotext does not show italics, and the emphasis is not marked in the transcription). Typos in the filing ("Federal Rule of Procedure 12(b)(6)", "Plaintiff's Attorney", "the Bankruptcy code") are kept as written.
- Frontmatter schema for this doc type: same as `../adversary-complaint/README.md`, plus `trustee` (optional list of lines under the debtor block), `judge` (optional), `certificate` (`document`, `method`, `service` list; required by LR 5.1), and `submitted_on` as the date phrase after "This".

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district/motion-brief
sh tools/render.sh $D usage/INPUT-gasb-motion-brief-howard.md     # -> usage/OUTPUT-gasb-motion-brief-howard.typst.pdf
sh tools/overlay.sh $D howard-motion-brief $D/usage/SAMPLE-howard-23-05004-motion-brief.pdf
```

- `usage/OUTPUT-gasb-motion-brief-howard.typst.pdf`: 7 pages. Typst compiled with no warnings. Only the vendored EB Garamond is embedded.
- `usage/OVERLAY-howard-motion-brief.pdf` and `.txt`: red = our render, blue = the filed exemplar, black = both. The page map pairs ours p.1-7 with filed p.1-7; word overlap 62-100%. Diagnostic only: the exemplar is set in Times with a different caption rule, so text lines do not coincide.
- File names follow the tools (`OUTPUT-`, `OVERLAY-`, `INPUT-`), not the brief's `<id>.pdf` / `<id>-overlay.pdf` names.

## Visual review (Gate 2 record: all 7 pages rendered at 60 dpi and looked at, after the final template change)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (In re block, trustee, plaintiff v. defendant, CHAPTER 13, CASE NO., Judge, ADV. PRO. NO.), title, COMES NOW, start of Introduction | OK after one fix: the numbered headings were drawn at 1.2× body size (fixed to body size). The caption border is a right-and-bottom rule. |
| 2 | Introduction (rest), summary paragraph, II. ARGUMENT, A. Motion to Dismiss Standard | OK. Headings I., II., A. hang correctly. Italic *Id.* and *See*. |
| 3 | A (rest), B. heading (two lines), start of the § 106 argument | OK. Long block quotation in running text, as in the exemplar (no block indent). |
| 4 | Rest of B (punitive damages; ante litem notice) | OK. Italic *Jove Eng'g*, *In re Otoh*, *Copeland*, *Harris*. |
| 5 | End of B; C. heading (standing) and its argument | OK. |
| 6 | End of C; III. CONCLUSION, the four numbered requests; "This 5th day of January, 2024"; signature block | OK. The left "This … day" line and the right firm block align at the top. |
| 7 | CERTIFICATE OF SERVICE: the method sentence, the centered service list, the italic "Attorney for Debtor/Plaintiff", the signature block | OK. |

Pages reviewed: 7 of 7.

## Known gaps and open choices

1. **Official Form 416 (GASB-CAP-003).** Not verified; the caption follows the exemplar and FRBP 9004(b). See `../adversary-complaint/README.md`.
2. **Proposed order (LBR 9072-1(a)).** Required with a motion; not generated. The template produces only the motion.
3. **Local rules currency.** The bankruptcy and district local rules used here are the 2017 and 2016 versions, unverified against the current ones. See `../adversary-complaint/README.md`.
4. **Notice of motion and hearing.** The exemplar (Howard) has no separate notice of hearing; the court's hearing-notice practice is not in the rules found, so the template does not generate one. The Pruco exemplar shows only the memorandum.
5. **Page limit.** LR 7.1(a) (26 pages) applies only if the judge directs; not counted. The sample is 7 pages.
6. **Typeface (fonts pass, 2026-10-14).** Face required: **none** (the same local-rule text as `../adversary-complaint/README.md`, searched 2026-10-14). Vendored substitute: **EB Garamond** at 13 pt, the "no face named" row of `docs/FONTS.md`. Fit: n/a. The exemplar is set in Times; the rules do not require it.
7. **Margins.** 1 inch all round: a style choice (no margin rule found).
8. **Paragraph and citation checks.** The template does not check the citation form, that every fact is supported by a citation (LR 7.1(b), if directed), or that the requests match the motion. Author-written.
9. **Privacy redactions** (FRBP 9037 / FRCP 5.2): the filer's job; not checked.
10. **Table of contents and authorities.** None generated; not required by any rule found for a motion of this length.
11. **Caption page numbering.** LR 10.1, as incorporated, numbers the caption page; the exemplar's caption page shows its number, so it agrees here.

## Engines

The docx engine (`docx/`: `reference.docx` from `make-reference.sh`, and `gasb-motion-brief.lua`) is built next to the typst template. Render: `sh tools/render.sh --engine docx courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district/motion-brief usage/INPUT-gasb-motion-brief-howard.md` (from the repository root) writes `usage/OUTPUT-gasb-motion-brief-howard.docx` and its LibreOffice PDF `usage/OUTPUT-gasb-motion-brief-howard.docx.pdf`.

- **Matches typst:** EB Garamond 13 pt throughout (embedded in the LibreOffice PDF); body double-spaced (exact 24 pt) with a half-inch first-line indent; 1-inch margins on letter paper; the court title, the caption table with the trustee block and the rule under and beside the left cell, the chapter, case number, judge and adversary number at right, the title in bold capitals; headings bold, single-spaced, with the labels I., A., 1., a. hanging half an inch and each level half an inch deeper; numbered paragraphs (the conclusion's requests); footnotes at 13 pt; the signature block; the certificate of service (its method sentence, the service list at 24 pt a line (typst sets it about 34 pt a line; not a rule, not copied), the signature block); a page number on every page (11 pt, centered).
- **Differs from typst:** (1) the list numbers are left-aligned at half an inch with the text hanging at 0.75 in; typst right-aligns each number. (2) Word and LibreOffice paginate slightly differently; the page count here is the LibreOffice PDF's (7 pages, the same as typst). (3) The docx does not embed EB Garamond: a machine that opens the `.docx` in Word needs EB Garamond installed, or Word substitutes a font. (4) The caption rules are Word table borders (0.75 pt), not typst's 0.7 pt lines. (5) The heading labels are typed text (I., A., ...) written by the filter, not Word list numbering, so they do not renumber if the author adds a heading in Word. (6) pandoc does not write the YAML title as a title block (the caption carries it); the core "title" property is not set.
- **docx BLOCKED items:** none recorded. The mechanical gates (`tools/check.sh --engine docx`) were **not run**: this snapshot has no `checks.yaml` for this court, so Gate 1 cannot run. The LibreOffice PDF was made and every page was rendered at 60 dpi and looked at (7 of 7; see the table above for the typst pages). The `.docx` was not opened in Word (none is installed here); LibreOffice converted it headless; a repair prompt is an interactive dialog and was not checked.
- **Rebuilding the reference:** `sh docx/make-reference.sh` (needs pandoc, perl, unzip, zip, xmllint); the filter and the reference are both in `docx/`.
