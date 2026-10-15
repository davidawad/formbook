# E.D. Ky. bankruptcy (kyeb): motion with memorandum

Doc type: **motion** with a memorandum in support (FRBP 9013; KYEB LBR 9013-1). Court: United States Bankruptcy Court for the Eastern District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief/`.

**Exemplar: yes, one filer.** `exemplars/FILED-EXAMPLE-williams-24-60490-motion-brief.pdf` is the motion with memorandum in support filed 09/11/2024 by Harley-Davidson dba Eaglemark Savings Bank in *In re Michael Jason Williams*, Case No. 24-60490 (London Division). It is a public RECAP copy; provenance is in `exemplars/SOURCE.md`. The template was revised against it on 2026-10-15 (fb-595.20.14). Tier 2 needs a second filer (see gap 1), so tier 2 is not finished.

Status: exemplar=yes (one filer), render=ok (`samples/OUTPUT-williams-24-60490.pdf`, 3 pages; `samples/OUTPUT-generic-motion-brief.pdf`, 3 pages), overlay=ok (`samples/OVERLAY-williams-24-60490.pdf` and `.txt`), pages reviewed 3 of 3 for the transcribed sample and 3 of 3 for the fictional sample, each rendered at 60 dpi and viewed. Nothing here sets `court.json` status.

## What the exemplar changed (2026-10-15)

The template was built from the rules alone on 2026-10-14. Compared with the exemplar, these visible conventions differed. Each is now fixed in `typst/kyeb-motion-brief.typ` and re-viewed.

| Item | Before | Exemplar shows | Change | Status |
|---|---|---|---|---|
| Body spacing | double-spaced, 24 pt pitch | single-spaced, with a gap between paragraphs | `body-leading` single; `gap` 12 pt between paragraphs and around headings | FIXED |
| Paragraph numbers | lettered `a.`, `b.` and unnumbered paragraphs | numbered paragraphs 1, 2, 3 … through the whole motion, hanging | numbered paragraphs use a counter (not the author's numbers), so they run on across headings | FIXED |
| Caption | vertical rule and bottom rule on the left column; debtor designation indented 1.8 in | no caption rules; "Debtor." at the margin; judge line in the caption | caption has no rules; designation at margin; optional `judge:` field | FIXED |
| Title | forced line breaks between title lines | title between two rules, bold, centred, wrapped as one paragraph | title lines joined and wrapped; rules above and below | FIXED |
| Signature block | `Dated:` on the left, `By: /s/` on the right | "Respectfully Submitted," then `/s/` name, a rule, then the address lines | block rewritten; no `Dated:` or `By:` lines | FIXED |
| NOTICE | not in the template (only the hearing block) | bold centred NOTICE after the signature, then a flush paragraph | new optional `notice:` field, printed after the signature | FIXED |
| Certificate of service | single paragraph and a `By:` line | markdown text (headings, recipient lines); the `/s/` block repeated | `certificate_of_service.text` is markdown; signature block repeated | FIXED |
| Column widths | 3.3 in and 3.2 in (typed in) | the exemplar's right-hand column starts near the middle of the text | both set to half the text width (`50%`), a layout rule, not a measured offset | FIXED |

## Governing rules

Verified 2026-10-14 against Cornell LII (federal rules, amendments effective Dec. 1, 2024) and the court's local rules PDF (`KYEB 120124 Local Rules`) and APM (`APM effective November 2016`, revision 3.31.26). Not re-verified on 2026-10-15; the rows marked "exemplar" below are conventions the exemplar shows, which the rules leave open.

| ID | Rule | Requirement | Kind | Where it lives |
|---|---|---|---|---|
| KYEB-FORM-001 | KYEB LBR 1001-3; APM § I | No typeface, margin or paper rule applies in this court. The District Court Local Rules do not apply unless the APM lists them, and the APM list does not include LR 5.1. FRBP 9004(a): a document must be "clearly legible". | M (legible); C (the rest) | `font-family`, `type-size`, `margins` in `kyeb-motion-brief.typ` |
| KYEB-CAP-001 | FRBP 9004(b) | Caption: (1) the court's name; (2) the case title; (3) the case number and, if appropriate, the adversary-proceeding number; (4) a brief designation of the document's character. | M | court lines; caption table; `title:` (designation in the title lines) |
| KYEB-CAP-002 | convention (exemplar) | A judge line in the caption, on the right with the case number. Both the exemplar's caption and the 2018 Wells Fargo motion (not saved, see SOURCE.md § 2) print one. | C | `judge:` (optional) |
| KYEB-REQ-001 | FRBP 9013 (first sentence of (a) and (b)) | A request for an order must be made by written motion (unless an application is authorized, or the request is made at a hearing). A motion must state its grounds with particularity and set forth the relief or order requested. | M (content) | body (author-written) |
| KYEB-NOT-001 | KYEB LBR 9013-1(a) | A motion may include a notice and opportunity for hearing setting the time within which objections must be filed and noticed for hearing; if none is filed, the court may grant the relief without further notice. | C (the court's choice; not mandated unless the motion uses it) | `hearing:` block under the title (`objection_deadline`), or `notice:` after the signature (exemplar) |
| KYEB-NOT-002 | KYEB LBR 9013-1(c) | Relief without notice or hearing must be stated expressly, with the basis, unless the matter is on the list in LBR 9013-1(c)(i)-(xix). | M (content, when the relief is sought without notice) | body (author-written) |
| KYEB-NOT-003 | convention (exemplar) | The notice (the 14-day response period, and that an order may be entered without a hearing) is printed after the signature and before the certificate of service. | C | `notice:` (optional) |
| KYEB-HEAR-001 | KYEB LBR 9014-1(a)-(b) | A notice of hearing must include the date, time and location of the hearing; an objection or response must be filed not less than 3 days before the hearing unless the Court orders otherwise. | M (when the motion is set for hearing) | `hearing:` block (`date`, `time`, `place`) |
| KYEB-PROP-001 | KYEB LBR 9013-1(d) | A motion must include a proposed order tendered as an attachment, as specified in the APM. The APM (§ XVIII) says the proposed order is attached with the event "Proposed Order" and contains only the order text and attorney signature. | M | not generated; the proposed order is a separate document, filed as an attachment |
| KYEB-SERV-001 | FRBP 9014(b) | The motion must be served within the time in FRBP 9006(d), and in the manner for serving a summons and complaint under FRBP 7004. | M (service); the certificate is a convention | `certificate_of_service:` (optional) |
| KYEB-SIG-001 | FRBP 9011(a) | Signed by at least one attorney of record in the attorney's own name; the document must state the signer's address and telephone number, "if any". | M | `signature-block()` |
| KYEB-SIG-002 | APM § VI | ECF signature: `/s/` followed by the Certified User's name, with contact information and the role of the filer. | M (in ECF filings) | `signature.signer` and `lines` |
| KYEB-SIG-003 | convention (exemplar) | "Respectfully Submitted," above the `/s/` block; the same `/s/` block, with the name and firm lines, repeated in the certificate of service. | C | `signature-block(opening:)` |
| KYEB-FORM-003 | convention (exemplar) | Single-spaced body with a gap between paragraphs; single-spaced caption, headings, notice and footnotes. The rule is silent; the exemplar shows it. | C | `body-leading`, `gap` |
| KYEB-FORM-004 | convention | Page number centred at the foot. The exemplar carries no footer number; its pages are numbered by the ECF header ("Page 1 of 8"). | C (kept; see gap 6) | page `footer` |
| KYEB-PARA-001 | convention (exemplar) | Motion paragraphs are numbered 1, 2, 3 … through the whole motion: the number sits 0.25 in in from the margin and the text hangs from 0.6 in. | C | `numbered-item()` and the counter |
| KYEB-HEAD-001 | convention | Level 1 centred capitals; level 2 centred bold; level 3 bold at the margin. Headings are typed by the author; the template does not number them. The exemplar's one heading (the memorandum heading) is bold, underlined, flush left. | C (one exemplar; see gap 2) | `show heading` rules |

Not used, and why: LBR 9014-1 is applied through the hearing block, not as a separate form. The memorandum is not a separate document under the rules: no E.D. Ky. bankruptcy rule located requires a separate memorandum of law or a page limit (the local-rules index has no LBR 9013-2). The template therefore accepts one document with its memorandum in the body, as the exemplar does.

Version: the local rules text is the PDF at `kyeb.uscourts.gov/sites/kyeb/files/KYEB 120124 Local Rules CLEAN DRAFT FINAL.pdf`, read 2026-10-14. Its filename says "draft", and a later "POST COMMENT CLEAN FINAL 110424" version also appears in search results. The text of LBR 9013-1 and 9014-1 has not been checked against that later version; **confirm before relying on it.**

## Template

- `typst/kyeb-motion-brief.typ`: the template, `kyeb-motion-brief(meta, body)`. It was adapted from the adversary-complaint template next door for its caption and signature code, and no longer shares that code; the adversary template is unchanged by this pass.
- `typst/main.typ`: the entry point (reads `--input sample=...`).
- Frontmatter contract: `case_number`, `chapter`, `jointly_administered`, `adversary_number` (optional), `court` (lines), `caption` (`debtors`: `names` and `designation`; optional `parties`), `judge` (optional; printed in the caption's right-hand column), `title` (lines, joined and wrapped as one centred paragraph), `date` (required; used in the document properties; not printed), `signature` (`signer`, `lines`; optional `firm`), `notice` (optional; printed after the signature), `hearing` (optional: `date`, `time`, `place`, `objection_deadline`), `certificate_of_service` (optional: `text`, markdown, with its signature block taken from `signature`).
- Body: `#` centred caps; `##` centred bold; `###` bold at the margin; `N.` numbered paragraphs (the number comes from the template's counter, so the author's number is not printed; the sequence runs through the whole motion); `-`, `*` or `+` bullets; blank-line-separated paragraphs, first-line indented; `[^key]` footnotes.

## Samples

- `samples/INPUT-williams-24-60490.md`: a **transcription** of the exemplar's motion, memorandum, NOTICE and certificate of service (filing pages 1 to 4; text copied, typos included). Pages 5 to 8 of the filing are a mailing matrix and are not part of the motion, so they are not transcribed. This is the sample the overlay compares.
- `samples/INPUT-generic-motion-brief.md`: **fictional**. The parties, dates, hearing and citations are invented; the citation is a placeholder for layout only. It exercises a debtor caption with an adversary number, a hearing block, typed headings, a lettered-style list (now printed as numbered paragraphs), a footnote, a signature block and a certificate of service. It is a layout test, not a transcription and not an exemplar.

Length: the exemplar's motion is 4 pages (its full file is 8 pages with the matrix). The transcribed sample renders at 3 pages, because the single spacing is tighter than the filing's and the certificate fits on one page with its signature. The 8-to-14-page guidance in the bead does not apply to this filing.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief samples/INPUT-williams-24-60490.md
sh tools/overlay.sh courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief williams-24-60490
sh tools/render.sh courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief samples/INPUT-generic-motion-brief.md
```

- `samples/OUTPUT-williams-24-60490.pdf`: 3 pages, render ran with no typst warnings. `pdffonts`: EB Garamond Regular and Bold, embedded (no system fonts).
- `samples/OVERLAY-williams-24-60490.pdf` and `.txt`: the overlay pairs our pages 1, 2 and 3 with the filing's pages 1, 2 and 3. The filing's page 4 (the signature block that the filing itself overflows onto) has no counterpart in our render, and its pages 5 to 8 (the matrix) are not paired. The overlay is a diagnostic, not a score; no visual claim below comes from it alone.
- `samples/OUTPUT-generic-motion-brief.pdf`: 3 pages, no typst warnings.

## Gate 2 visual review (williams sample, final render, 3 pages, 60 dpi, each viewed, compared with the filing's pages 1 to 3)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court title, caption (In re / Case No. / Chapter 11 / Judge), title between rules, single-spaced body with a first-line indent, numbered 1 to 3 hanging. Fixed in this pass: double spacing, lettered numbering, caption rule, indented designation, forced title breaks. Judge line sits on the chapter row; the exemplar puts it level with "Debtor.". Our page number is a footer; the exemplar's pages are numbered by the ECF header. The memorandum heading is centred and bold; the exemplar's is bold, underlined, flush left. | FIXED (spacing, numbering, caption, title); ACCEPTED (judge row; footer number; memorandum heading, see gaps 2, 3, 6) |
| 2 | exemplar p.2 | Numbered paragraphs 4 to 8 continue from page 1 (the counter). "WHEREFORE," is first-line indented; the exemplar's is flush left. "Respectfully Submitted," and the `/s/` block with its rule sit at the right, as in the exemplar. NOTICE is a bold centred heading, followed by a flush paragraph, as in the exemplar. Fixed in this pass: the signature (was `Dated:`/`By:`), the NOTICE placement (was none). | FIXED (signature, NOTICE); ACCEPTED (WHEREFORE indent, gap 5) |
| 3 | exemplar p.3 | Certificate heading bold centred; intro paragraph; bold "By Notice of Electronic Filing to:" and "By United States mail to:" headings; the recipients are set closer than the exemplar sets them (one line each, a 3 pt gap), so the certificate and its signature fit one page. The exemplar's own signature breaks onto its page 4. The `/s/` block with rule and name, firm and address lines is repeated, as the exemplar repeats it. The signature block does not run into the bottom margin. | ACCEPTED (recipient spacing, gap 4); PASS on the signature |

Pages reviewed: 3 of 3 (williams sample, final render).

## Gate 2 visual review (generic sample, fictional, 3 pages, 60 dpi, each viewed)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | none (fictional) | Court title, caption with adversary parties (the designation of the plaintiff and defendant is indented, as the adversary template does), title between rules, hearing block, body paragraph, footnote 1 at the foot. | PASS (layout) |
| 2 | none | Headings centred and bold; numbered items 1 and 2 hang; `/s/` block with its rule and lines. Heading spacing follows the paragraph gap. | PASS (layout) |
| 3 | none | Certificate of service moves to its own page as a whole, with its `/s/` block; nothing runs into the margin. | PASS (layout) |

Pages reviewed: 3 of 3 (fictional sample).

## Known gaps and open choices

1. **One filer only.** EVAL-LOOP requires two or three exemplars from different filers before tier 2 can be judged, and this doc type has one. The candidate second filer is the 2018 Wells Fargo motion, Case No. 18-70393 (Doc 12), listed in `exemplars/SOURCE.md` § 2. It has no memorandum section and runs to 33 pages with an exhibit, so it was not saved with this pass; the bead asked for one file. Until a second filer is in, the tier-2 items above are judged against one filer and cannot be called settled.
2. **Memorandum heading style.** The exemplar's heading is bold, underlined and flush left; the template centres level 1 headings. One exemplar does not settle the heading style, so it stays centred and is ACCEPTED here.
3. **Judge line position.** The exemplar puts the judge on the "Debtor." row; the template puts it below the chapter. Both sit in the caption. ACCEPTED.
4. **Certificate recipient spacing.** The recipients are set closer than the exemplar's, so the certificate and its signature fit one page. The exemplar's signature runs onto a second page, which a clerk would notice more. ACCEPTED.
5. **"WHEREFORE" indent.** Indented in the template, flush in the exemplar. One exemplar; ACCEPTED.
6. **Page numbers.** The template prints a centred page number at the foot (KYEB-FORM-004); the exemplar has none, and its pages are numbered by the ECF header. The footer is kept because it costs nothing and KYEB-FORM-004 cites it as a convention.
7. **Typeface.** No face named by a rule (KYEB-FORM-001), so EB Garamond at 13 pt stays, per `docs/FONTS.md`. The exemplar is Times New Roman; the substitute rule applies only to a court that names a face. Glyph-level differences from the exemplar are tier 3.
8. **Hearing wording.** LBR 9014-1 requires the date, time and location; the labels "Hearing:", "Time:", "Place:", "Objections due:" are the template's own. The exemplar has no hearing block (it has the NOTICE paragraph), so the block is not checked against a filing.
9. **Proposed order.** Required by LBR 9013-1(d); not generated. The APM (§ XVIII) governs how it is attached.
10. **Certificate of service.** Printed when `certificate_of_service` is given. The FRBP 9014(b) requirement is for service, not a particular form; the recipient list in the transcription is the filing's, and the generic sample's wording is the template's sample.
11. **Page limits and the memorandum.** No page or word limit applies under the E.D. Ky. bankruptcy rules located (LBR 9013-2 does not exist in this court's list). The template does not count pages.
12. **Relief without notice (KYEB-NOT-002).** The template does not check whether a motion says so; the author must state it in the body.
13. **Not run:** `tools/tracker.sh` (it rewrites the root `README.md`, `STATUS.md` and per-folder READMEs, which this bead does not own), and `tools/check.sh` (this doc type has no `checks.yaml`, so there are no Gate 0 or Gate 1 checks to run). `court.json` is not changed.
14. **Unverified:** whether the court's chambers require a separate memorandum under a judge's standing order; not searched.
