# N.D. Okla. Bankruptcy Court (oknb): motion with memorandum

Doc type: **motion with memorandum** (a contested-matter motion under FRBP 9013/9014, with the memorandum of law in the same filed document, and the notice of opportunity for hearing under LBR 9013-1(B)). Court: United States Bankruptcy Court for the Northern District of Oklahoma. Folder: `courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/motion-brief/`.

Status: **exemplar=no**, render=ok, overlay=**fail** (not produced: there is no exemplar to overlay), pages reviewed 5 of 5. Nothing here sets a court-level `court.json` status.

BLOCKED: no exemplar. No filed motion with memorandum from this court was found after the searches in `exemplars/SOURCE.md`. The template is built from the rules below; the sample is synthetic and written to those rules.

## Governing rules

Dates: the local rules were read from the PDF on the court's site (cover: "Updated March 21, 2025"); FRBP 9013 and 9004 were read from Cornell LII on 2026-10-14. Rules not listed in the table (FRBP 4003(d), 9006(f), 9014, 5005-1(E) text, 11 U.S.C. §§ 101(36), 522(b), 522(f)(1)(A), 522(f)(2)(A), Fed. R. Bankr. P. 9015 etc.) were **not re-fetched** this session; they are cited from the author's knowledge and must be checked before this folder is treated as complete. Note LBR 9013-1(B) quotes its prescribed statement; the template reproduces it from the local rules PDF.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| OKNB-MOT-001 | Fed. R. Bankr. P. 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013), read 2026-10-14 | A request for a court order is made by written motion, which states its grounds with particularity and specifies the relief sought. | the motion itself (sample `# Relief Requested`) |
| OKNB-MOT-002 | LBR 9013-1(A)-(B) (court's local rules PDF, Updated March 21, 2025) | A motion for which the Code permits but does not require a hearing carries the words "And Notice of Opportunity for Hearing" in its title and the prescribed NOTICE OF OPPORTUNITY FOR HEARING statement in its body, with the response period (14 days where no period is prescribed, including the 3 mailing days of FRBP 9006(f)). | `title` check (asserts the phrase when `notice_of_opportunity: true`); `notice-block` (prescribed text, `response_days`) |
| OKNB-MOT-003 | LBR 9013-1(D)(6) | The notice procedure does not apply to Part VII (adversary) requests, except a motion to dismiss a complaint objecting to discharge (LBR 7041-1). | why this sample is a contested matter (§ 522(f) lien avoidance, FRBP 4003(d)), not an adversary motion |
| OKNB-MOT-004 | LBR 9013-1(G)(2), LBR 5005-1(E) | Motions are served on parties not registered for ECF by mail within two days of filing, and a certificate of service is filed within seven days. | `certificate-block` (served list from frontmatter) |
| OKNB-MOT-005 | LBR 7007-1(A) | A brief in an adversary proceeding is not to exceed 20 pages. This is an adversary-proceeding rule. No page limit for a contested-matter motion was found in the local rules read. | not enforced; no page counter (see gaps) |
| OKNB-MOT-006 | LBR 9004-1(A) | 8 1/2 x 11; no less than 12-point font including footnotes; margins at least one inch; one side; pleadings and briefs double spaced. | `type-size` 13pt; `margin` 1in; `body-leading` 1.35em (2.0em pitch); footnote size = `type-size` |
| OKNB-MOT-007 | LBR 9004-2(A) | Caption: court name, title of the case, bankruptcy case number and adversary number (if any), the chapter number directly under the case number, and a title that describes the document. | `court-title`, `caption`, `title-block`; adversary number printed only when given |
| OKNB-MOT-008 | LBR 9004-1(C), LBR 9011-1 | Attorney signature block: full name, state bar number, address, email, telephone, fax if any, and the party represented. | `signature-block` (asserts `bar_number`, `telephone`, `email`) |
| OKNB-MOT-009 | FRBP 4003(d) (not re-fetched) and FRBP 9014 (not re-fetched) | A motion to avoid a lien under 11 U.S.C. § 522(f) is a contested matter under Rule 9014, commenced by motion. | the sample's `# Argument` and `# Relief Requested` text |

## Exemplar

None. See `exemplars/SOURCE.md`: local rules and govinfo orders were read; no party-filed motion from this court was found; CourtListener was blocked to this box (HTTP 403). Tier 2 is judged against the rules only.

## Sample

- `samples/INPUT-motion-brief.md` is **synthetic**: fictional debtor John Quincy Example, fictional creditor (Sample Creditor Bank), fictional property and numbers. The motion avoids a judicial lien under § 522(f)(1)(A), with a memorandum in the same document. Its frontmatter says it is synthetic.
- The template generates the notice of opportunity for hearing, the caption from `caption`, the certificate of service from `certificate`, and the signature block. The sample's headings are numbered by the template (I., A., 1.); the sample types no numbers.
- Length: 5 rendered pages, the last of them the certificate of service. Shorter than the 8-14 page target because there is no exemplar length to match; the argument is one § 522(f)(2)(A) computation with its procedure. Not padded.
- Naming: `INPUT-motion-brief.md` / `OUTPUT-motion-brief.pdf`, as for the complaint (the tools' conventions; the brief's `<id>.pdf` layout would not feed `tools/overlay.sh`).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/motion-brief samples/INPUT-motion-brief.md
sh tools/overlay.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/motion-brief motion-brief
```

- render: **ok**. `samples/OUTPUT-motion-brief.pdf`, 5 pages, 612 x 792 pt. typst emitted no warnings. Fonts: EBGaramond-Regular, -Bold, -BoldItalic (vendored), embedded.
- Measured: body line pitch 26.00 pt at 13 pt type on page 2 (2.0 em, double spacing per LBR 9004-1(A)), with `pdftotext -bbox`. Margins 1 inch.
- overlay: **fail**. `tools/overlay.sh` exits 1 with "no exemplar pdf in .../exemplars"; no `OVERLAY-motion-brief.pdf` or `.txt` produced.

## Visual review (Gate 2, all 5 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (In re block, Case No., Chapter), title ("…And Notice of Opportunity for Hearing"), the prescribed NOTICE OF OPPORTUNITY box, the response-time paragraph, I. Relief Requested (begins) | OK. The notice box is a bordered single-spaced block; the statement reads as LBR 9013-1(B) prescribes, with 14 days filled from `response_days`. |
| 2 | Relief completes, II. Background with footnote 1, III. Argument, A. Legal Standard (begins) | OK. Footnote 1 at foot of page. |
| 3 | A. Legal Standard completes, B. with 1. The Computation Uses the Schedules, C. Motion Is Timely | OK. Nested heading labels (B., 1.) with hanging indent; the 1. heading is bold italic. |
| 4 | C. 1. Procedure, IV. Conclusion (items (a)-(c)), signature block | OK. Signature block carries bar number, phone, email and party. |
| 5 | Certificate of Service (starts on its own page, by design: `pagebreak(weak: true)`), served list, signature | OK. Certificate is kept together. |

Defects found and fixed during the build (all in `typst/oknb-motion-brief.typ`):

1. Headings overlapped the paragraph after them (EB Garamond's 0.65 em line box), and the heading after a paragraph landed inside that paragraph's last line. Fixed as in the complaint: a fixed block height for the title and the notice, and `above`/`below` spacing of `body-leading` on headings.
2. `pad(hanging-indent: …)` is not a typst argument. Level-2 and level-3 headings now put their label in a 0.5 in box and use `par(hanging-indent: 0.5in)`.
3. A `set` rule inside a content-block argument was rejected. Rewritten as a block.
4. The certificate of service split across pages 4-5. Now starts on a new page.

## Known gaps and open choices

1. **No exemplar** (BLOCKED, above). Tier 2 has no filer to compare against.
2. **Page limit:** not counted. LBR 7007-1(A) caps briefs in adversary proceedings at 20 pages; no page limit for a contested-matter motion was found in the local rules read. Not checked by the template.
3. **TOC and TOA:** not generated. No oknb local rule found requires them. A longer memorandum would need them as a convention; the CAND template has them.
4. **Proposed order:** not generated. LBR 9013-1(B) addresses a request for entry of an order after the response period; the proposed order is a separate document.
5. **Declaration of value** (footnote 1 in the sample): the template does not generate or check it; the author attaches it.
6. **Certificate of service:** generated from `certificate` (served list written by the author; the method is the author's choice). The LBR 5005-1(E) rule that the ECF notice serves registered users is stated in the certificate text. The author confirms the parties are not registered before using it.
7. **Response period:** `response_days` is the author's calculation (LBR 9013-1(B): 14 days where no period is prescribed, including FRBP 9006(f)'s 3 mailing days; add to a prescribed period unless hand-delivered). The template does not compute it.
8. **Bracketed text in the notice:** "[and others who are required to be served]" is reproduced from the local rule's form with its brackets, as the rule prints it. The author deletes the brackets and the words, or keeps them, per the notice's filing.
9. **Font:** EB Garamond (vendored, OFL) at 13 pt, not Times New Roman. 13 pt because EB Garamond sets small at 12; both meet the LBR 9004-1(A) floor. A choice, not a court-specified font.
10. **Statute and rule text** not re-fetched (see governing rules): § 522(f)(1)(A), (f)(2)(A), § 101(36), FRBP 4003(d), 9006(f), 9014. Check before this folder is treated as complete.
