# C.D. Cal. Bankruptcy Court: motion with memorandum

Doc type: **motion** with notice and a memorandum of points and authorities (FRBP 9013, 9014; LBR 9013-1). Court: United States Bankruptcy Court, Central District of California (cacb). Folder: `courts/ninth-circuit/california/federal/bankruptcy-central-district/motion-brief/`.

Status: **BLOCKED: no exemplar.** exemplar=no, render=ok (synthetic sample only), overlay=fail (no exemplar PDF to overlay against; `tools/overlay.sh` exits 1), pages reviewed 4 of 4 (synthetic sample). Nothing here sets a court-level `court.json` status.

The searches tried are in `exemplars/SOURCE.md`. The template is built from the rules, as the brief directs. The sample is **synthetic**: fictional parties, placeholder counsel, placeholder amounts, and statute-only citations. It is there to exercise the template, not to match a filing.

## Governing rules

Sources, read 2026-10-14:

- **Local Bankruptcy Rules, effective October 21, 2024**: https://www.cacb.uscourts.gov/sites/cacb/files/documents/local_rules/COMPLETE%20LBRS%2010-2024%20double-sided.pdf. Sections cited below are its numbering. The court's site also lists a May 2025 edition, **not fetched**; check it before relying on the text here.
- **Central Guide Supplement to LBR 9004-1** (August 2022): https://www.cacb.uscourts.gov/sites/cacb/files/documents/the-central-guide/TCGSupp9004-1_Form-and-Format-of-Documents-to-be-Filed.pdf. Same source as the adversary complaint.
- FRBP 9013 and 9014 are cited from memory of the rules. **Not fetched, not verified.**

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| CACB-FORM-001 to -006 | Central Guide 9004-1(b)(2) | Pages 8.5 x 11; numbered margins (a motion is named in (B)(i)), at most 28 lines; typeface at least 12 point; line 1 at least 1 inch from the top; double spacing; page numbers at the bottom. | `page-w/h`, `lines-per-page`, `pitch`, `type-size`, `top-margin`, `footer-block()` |
| CACB-CAP-001 to -003 | Central Guide 9004-1(c)(1)(A)-(C) | Counsel block on lines 1-7; clerk's space; court title (with the division) centered on or below line 8. | `counsel-block()`, `court-title()` |
| CACB-CAP-004 | Central Guide 9004-1(c)(1)(E)-(F) | Bankruptcy case number to the right of center, opposite the party names; chapter number immediately below. | `caption()` right column |
| CACB-CAP-005 | Central Guide 9004-1(c)(1)(H) | Concise title of the document on the first page, below the chapter number or the caption. Where possible, the proponent's name is in the title. | `caption()`, `brief_title` |
| CACB-CAP-006 | Central Guide 9004-1(c)(1) (hearing), with the sample caption of a motion, 9004-1(c)(1)(I) | Hearing date, time and place, with the courthouse address, immediately below the title, on the first page. | `hearing` (lines) |
| CACB-NOTICE-001 | LBR 9013-1(c)(2) | Written notice of motion, specifying the relief requested and, if applicable, the date, time and place of the hearing, and advising that LBR 9013-1(f) requires a written response at least 14 days before the hearing. | **Author-written, not enforced**: the sample's Notice section carries the advisement. The template does not check it. |
| CACB-MEMO-001 | LBR 9013-1(c)(3)(A) | A written statement of all reasons, with a memorandum of the points and authorities relied on. Not required for applications to retain or compensate professionals, motions for relief from stay, or motions to sell, use, lease or abandon estate assets, unless special circumstances or the court orders one. | Template prints whatever the author writes; **not enforced**. The sample includes one for a sale motion, which the rule does not require. |
| CACB-DECL-001 | LBR 9013-1(c)(3)(B)-(C) | Declarations required by FRBP 9014(d), 9017 or 9006(d), and copies of all exhibits the motion relies on. | Separate documents; not generated |
| CACB-FINAL-001 | LBR 9013-1(c)(4) | In a contested matter, the moving party must raise any objection to the bankruptcy court's authority to enter a final order in the motion, with authority and evidence; silence is consent. | Author-written (the sample's consent statement). Not enforced. |
| CACB-TIME-001 | LBR 9013-1(d)(2) | Notice of motion and motion filed and served at least 21 days before the hearing (exceptions listed). | Not checked: a calendar matter. |
| CACB-RESP-001 | LBR 9013-1(f)(1)-(2) | Responses filed and served at least 14 days before the hearing; a response must advise that any reply is due 7 days before the hearing. | Notice advisement (author-written). |
| CACB-REPLY-001 | LBR 9013-1(g) | Reply memorandum at least 7 days before the hearing. | Notice advisement (author-written). |
| CACB-SERVE-001 | LBR 9013-1(e) | Every document filed under the rule must be accompanied by a proof of service (LBR 9013-3). | **Not generated.** Separate document. See gaps. |
| CACB-FORM-LBR-001 | LBR 9013-1(o), (p), (q); LBR 9009-1 | The notice of opportunity to request a hearing (o), notice-only (p) and no-notice (q) procedures carry court-approved forms (F 9013-1.2 family) that must not be altered (LBR 9009-1(b)(4)). | **Not generated.** A motion on those procedures must use the court form. |

## Layout

The page furniture, typeface, spacing and caption are the same as the adversary complaint template (`../adversary-complaint/typst/cacb-adversary-complaint.typ`), with three differences:

- The caption is **single**, not double: a motion in the main case carries "In re: / Debtor." on the left (Central Guide 9004-1(c)(1)(I), the sample caption of a motion). An adversary motion would need the double caption (9004-1(c)(2)); not built.
- Headings are numbered by the template from their level: level 1 is a centered section (NOTICE OF MOTION, MEMORANDUM OF POINTS AND AUTHORITIES), restarting the count; levels 2-5 are I., A., 1., a. (typed numbers in the sample are not used).
- Paragraphs are unnumbered and indented (memorandum style), and markdown lists are numbered 1., 2., ....

No table of contents or table of authorities is generated. No C.D. Cal. rule that I read requires one for a motion or memorandum; not checked against the full rules (see gaps).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/ninth-circuit/california/federal/bankruptcy-central-district/motion-brief samples/INPUT-synthetic-trustee-motion.md
sh tools/overlay.sh courts/ninth-circuit/california/federal/bankruptcy-central-district/motion-brief synthetic-trustee-motion   # fails: no exemplar
```

- `samples/OUTPUT-synthetic-trustee-motion.pdf`: 4 pages. Typst compiled with no warnings. Fonts: EB Garamond only (vendored).
- The overlay was run: it exits 1 with "no exemplar pdf in .../exemplars". No `OVERLAY-*` file is produced. File names follow `tools/` (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), as in the adversary complaint.

## Visual review (Gate 2 record, all 4 pages of the synthetic sample, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel (lines 1-7), court title (lines 8-10), caption with title and hearing lines, start of the Notice | OK after one fix. The caption's bold title was double-spaced because the right-hand column did not set the single pitch; fixed, and the title now sits on single lines with the hearing block below it. The Notice starts on page 1. |
| 2 | Notice (end), MOTION (relief list), grounds, LBR 9013-1(c)(4) statement, MEMORANDUM heading, Introduction | OK. Numbered relief items hang correctly. |
| 3 | Facts with A. The liens; Argument III. A., 1., a., b. | OK. Heading levels step in (A at 0.5 in, 1. at 1 in, a. at 1.5 in). |
| 4 | Argument A.2, B. with numbered list, Conclusion, signature block | OK. "Dated" at left, "Respectfully submitted" and the signature at right. |

Reviewed pages: 4 of 4 (of the synthetic sample).

Defects found and fixed during review: the caption title double-spacing (above); the time placeholder `__:__` was read as emphasis and dropped, so the sample uses "[time]".

## Known gaps and open choices

1. **Exemplar: none. BLOCKED.** No filed motion with a memorandum in this court was found as a text-layer public PDF (searches in `exemplars/SOURCE.md`). Without one: no depth target (8-14 pages) can be checked, no tier-2 comparison is possible, and the overlay cannot run. The template is therefore unverified against a filing. Next step: a filed C.D. Cal. bankruptcy motion with a memorandum, from a different filer than a trustee's own form.
2. **Typeface (CACB-FORM-001 to -006). Needs David's call.** The Central Guide lists Arial, Courier, Times New Roman, Helvetica, Geneva and Letter Gothic as the required typefaces. Only EB Garamond is vendored in `fonts/`, and it is not on the list. Same gap as the adversary complaint: see that README, gap 1.
3. **Proof of service (LBR 9013-1(e)).** Required with every document under the rule; not generated. A separate form (F 9013-3.1 family) is needed.
4. **Court-approved notice forms (LBR 9013-1(o), (p), (q)).** If the motion is decided on notice or without a hearing, the court's form must be used (LBR 9009-1(b)(4)). This template makes a free-form notice; it is not those forms.
5. **Memorandum requirement.** LBR 9013-1(c)(3)(A) exempts sale, use, lease, abandonment, stay-relief and professional-compensation motions from the memorandum unless special circumstances or an order apply. The sample includes one for a sale; the template does not decide when one is needed.
6. **Notice advisements, consent statement and the 21-day rule** are author-written content (see the rule table). The template does not check them; a check on the notice's 14-day advisement and the final-order statement would be needed for a true gate.
7. **Table of contents and table of authorities** are not generated. Not verified against the full LBR text whether a C.D. Cal. memorandum needs them; the N.D. Cal. convention does not apply here.
8. **Page limits** (memorandum length) are not checked. Not verified against the LBR text read.
9. **FRBP 9013, 9014, 9017 and 9006(d) text** not fetched; cited from memory.
10. **Structure of the synthetic sample** is not evidence of how a C.D. Cal. motion is laid out: it is a template exercise. Do not treat it as a transcription.
11. **LBR edition.** Read from the October 21, 2024 edition. Check the May 2025 edition before relying on the rule text.
