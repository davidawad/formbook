# E.D. Ky. bankruptcy (kyeb): motion with memorandum

Doc type: **motion** with a memorandum in support (FRBP 9013; KYEB LBR 9013-1). Court: United States Bankruptcy Court for the Eastern District of Kentucky. Folder: `courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief/`.

**BLOCKED: no exemplar.** No public, text-based filed motion with a supporting memorandum from this court was found after the searches in `exemplars/SOURCE.md`. The template is built from the rules below, not from a filing. Its layout is tested on a fictional sample only; nothing in it is tier-2 judged.

Status: exemplar=no, render=ok (fictional test sample only), overlay=fail (no exemplar to compare against), pages reviewed 3 of 3 (fictional sample). Nothing here sets `court.json` status.

## Governing rules

Verified 2026-10-14 against Cornell LII (federal rules, amendments effective Dec. 1, 2024) and the court's local rules PDF (`KYEB 120124 Local Rules`) and APM (`APM effective November 2016`, revision 3.31.26).

| ID | Rule | Requirement | Kind | Where it lives |
|---|---|---|---|---|
| KYEB-FORM-001 | KYEB LBR 1001-3; APM § I | No typeface, margin or paper rule applies in this court. The District Court Local Rules do not apply unless the APM lists them, and the APM list does not include LR 5.1. FRBP 9004(a): a document must be "clearly legible". | M (legible); C (the rest) | `font-family`, `type-size`, `margins` in `kyeb-motion-brief.typ` |
| KYEB-CAP-001 | FRBP 9004(b) | Caption: (1) the court's name; (2) the case title; (3) the case number and, if appropriate, the adversary-proceeding number; (4) a brief designation of the document's character. | M | court lines; caption table; `title:` (designation in the title lines) |
| KYEB-REQ-001 | FRBP 9013 (first sentence of (a) and (b)) | A request for an order must be made by written motion (unless an application is authorized, or the request is made at a hearing). A motion must state its grounds with particularity and set forth the relief or order requested. | M (content) | body (author-written) |
| KYEB-NOT-001 | KYEB LBR 9013-1(a) | A motion may include a notice and opportunity for hearing setting the time within which objections must be filed and noticed for hearing; if none is filed, the court may grant the relief without further notice. | C (the court's choice; not mandated unless the motion uses it) | `hearing:` block under the title (`objection_deadline`) |
| KYEB-NOT-002 | KYEB LBR 9013-1(c) | Relief without notice or hearing must be stated expressly, with the basis, unless the matter is on the list in LBR 9013-1(c)(i)-(xix). | M (content, when the relief is sought without notice) | body (author-written) |
| KYEB-HEAR-001 | KYEB LBR 9014-1(a)-(b) | A notice of hearing must include the date, time and location of the hearing; an objection or response must be filed not less than 3 days before the hearing unless the Court orders otherwise. | M (when the motion is set for hearing) | `hearing:` block (`date`, `time`, `place`) |
| KYEB-PROP-001 | KYEB LBR 9013-1(d) | A motion must include a proposed order tendered as an attachment, as specified in the APM. The APM (§ XVIII) says the proposed order is attached with the event "Proposed Order" and contains only the order text and attorney signature. | M | not generated; the proposed order is a separate document, filed as an attachment |
| KYEB-SERV-001 | FRBP 9014(b) | The motion must be served within the time in FRBP 9006(d), and in the manner for serving a summons and complaint under FRBP 7004. | M (service); the certificate is a convention | `certificate_of_service:` (optional) |
| KYEB-SIG-001 | FRBP 9011(a) | Signed by at least one attorney of record in the attorney's own name; the document must state the signer's address and telephone number, "if any". | M | `signature-block()` |
| KYEB-SIG-002 | APM § VI | ECF signature: `/s/` followed by the Certified User's name, with contact information and the role of the filer. | M (in ECF filings) | `signature.signer` and `lines` |
| KYEB-FORM-003 | convention | Double-spaced body; single-spaced caption, headings and footnotes. | C | `line-pitch` 24 pt, `body-leading` |
| KYEB-FORM-004 | convention | Page number centred at the foot. | C | page `footer` |
| KYEB-HEAD-001 | convention | Level 1 centred capitals; level 2 centred bold; level 3 bold at the margin. Headings are typed by the author; the template does not number them. | C (no exemplar to confirm) | `show heading` rules |

Not used, and why: LBR 9014-1 is applied through the hearing block, not as a separate form. The memorandum is not a separate document under the rules: no E.D. Ky. bankruptcy rule located requires a separate memorandum of law or a page limit (the local-rules index has no LBR 9013-2). The template therefore accepts one document with its memorandum in the body.

Version: the local rules text is the PDF at `kyeb.uscourts.gov/sites/kyeb/files/KYEB 120124 Local Rules CLEAN DRAFT FINAL.pdf`, read 2026-10-14. Its filename says "draft", and a later "POST COMMENT CLEAN FINAL 110424" version also appears in search results. The text of LBR 9013-1 and 9014-1 has not been checked against that later version; **confirm before relying on it.**

## Template

- `typst/kyeb-motion-brief.typ`: the template, `kyeb-motion-brief(meta, body)`. It shares its caption, signature and footnote code with `../adversary-complaint/typst/kyeb-adversary-complaint.typ`, adapted: paragraphs are unnumbered (no rule numbers a motion's paragraphs), the caption's parties are optional (a main-case motion has the debtors only), and an optional hearing block and certificate of service are printed.
- `typst/main.typ`: the entry point (reads `--input sample=...`).
- Frontmatter contract: `case_number`, `chapter`, `jointly_administered`, `adversary_number` (optional), `court`, `caption` (`debtors` and optional `parties`), `title`, `hearing` (optional: `date`, `time`, `place`, `objection_deadline`), `date`, `signature` (`firm`, `signer`, `lines`), `certificate_of_service` (optional: `text`).
- Body: `#` centred caps; `##` centred bold; `###` bold; blank-line-separated paragraphs, first-line indented and unnumbered; `1. ` for a lettered list; `[^key]` footnotes.

## Sample (fictional)

- `samples/INPUT-generic-motion-brief.md`: **fictional**. The parties, dates, hearing and citations are invented; the citation is a placeholder for layout only. It is not a transcription of a filing and is not an exemplar.
- It exercises every feature: a debtor caption with an adversary number, a hearing block with an objection deadline, typed headings I.-IV. with sub-headings A. and B., a lettered list, a footnote, a signature block and a certificate of service.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief samples/INPUT-generic-motion-brief.md
sh tools/overlay.sh courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district/motion-brief generic-motion-brief
```

- `samples/OUTPUT-generic-motion-brief.pdf`: 3 pages, render ran with no typst warnings. `pdffonts`: EBGaramond-Regular, -Bold, -Italic, embedded.
- The overlay **failed** (exit 1): `no exemplar pdf in .../exemplars`. This is the correct result, not a bug: `overlay.sh` compares against a filed exemplar, and none exists. No overlay file was written.

## Gate 2 visual review (fictional sample, 3 pages, rendered at 60 dpi, each viewed)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | none (no exemplar) | Court title centred bold; caption (debtor, parties, chapter, case no., Adv. No.); title in bold; hearing block (date, time, place, objection deadline); body paragraph; footnote 1 at foot in smaller type. | PASS on the rules; no exemplar to compare with |
| 2 | none | Headings: "MEMORANDUM IN SUPPORT" and "I. Introduction" centred, "A. The Complaint" bold at the margin; lettered list a., b. hanging; italic case name. Heading spacing is tight against the paragraph before it. | PASS; spacing above headings is a convention and may need tuning once an exemplar exists |
| 3 | none | Signature block (moved to this page as a whole, with the conclusion on page 2); certificate of service heading centred, text, and its own `/s/` line. | PASS; the block is kept whole |

Pages reviewed: 3 of 3 (fictional sample).

## Known gaps and open choices

1. **No exemplar (BLOCKED).** Every layout choice above that a clerk would expect to see (heading style, hearing-block wording, certificate wording, sub-heading spacing) is a convention unconfirmed by a filing. See `exemplars/SOURCE.md` for the searches and what would unblock it.
2. **Typeface.** EB Garamond at 13 pt, not Times (as in the adversary-complaint folder; see that README, gap 1). Only EB Garamond is vendored.
3. **Hearing wording.** LBR 9014-1 requires the date, time and location; the labels "Hearing:", "Time:", "Place:", "Objections due:" are the template's own. Not checked against a filing.
4. **Proposed order.** Required by LBR 9013-1(d); not generated. The APM (§ XVIII) governs how it is attached.
5. **Certificate of service.** Printed only when `certificate_of_service` is given. The FRBP 9014(b) requirement is for service, not a particular certificate form; the wording in the test sample is the template's sample, not a form.
6. **Page limits and the memorandum.** No page or word limit applies under the E.D. Ky. bankruptcy rules located (LBR 9013-2 does not exist in this court's list). The template does not count pages.
7. **Relief without notice (KYEB-NOT-002).** The template does not check whether a motion says so; the author must state it in the body.
8. **Unverified:** whether the court's chambers require a separate memorandum under a judge's standing order; not searched.
