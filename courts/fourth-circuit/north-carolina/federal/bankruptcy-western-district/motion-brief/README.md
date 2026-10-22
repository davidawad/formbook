# W.D.N.C. Bankruptcy Court (ncwb): motion with memorandum

Doc type: **motion-brief**: a motion under FRBP 9013 with its memorandum in one filing, plus the notice of hearing and certificate of service that the local rules require with it. Court: United States Bankruptcy Court, Western District of North Carolina (Charlotte Division in the exemplar). Folder: `courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district/motion-brief/`.

Status: exemplar=yes (one filing; tier-2 needs two or three, see gaps), render=ok, overlay=ok, pages reviewed 10 of 10 on the earlier EB Garamond render, before fb-595.68 (every page rendered at 60 dpi and looked at; the current render is 11 pages). Nothing here sets `status` in `court.json`.

## Governing rules

All text read 2026-10-14. Federal rules: Legal Information Institute (LII) pages, text effective December 1, 2024 (I read FRBP 9013(a)-(b) and the summary of 7012(b) that the exemplar cites; not the rest of Rule 9013). Local rules: the court's posted PDF (Sept 2021), extracted with `pdftotext`; page numbers are the PDF's printed page numbers.

| ID | Source (URL, rule, page) | Requirement | Where it lives |
|---|---|---|---|
| NCWB-MOT-001 | FRBP 9013(a)-(b), https://www.law.cornell.edu/rules/frbp/rule_9013 | A request for an order must be made by written motion. A motion "must state its grounds with particularity and set forth the relief or order requested." It is served on the trustee or debtor in possession and on the entities the rules specify. | Body (author-written); service in `certificate()` |
| NCWB-LR-MOT-001 | W.D.N.C. Bankruptcy Local Rules (Sept 2021), LR 7007-1(a), p. 78 | Motions in an adversary proceeding "shall state with particularity the facts supporting the motion and shall state the relief requested." A brief or memorandum "shall state the relief requested and shall be filed in accordance with Local Rule 9013-2." | Body; the memorandum is rendered inline, as in the exemplar |
| NCWB-LR-MOT-002 | Same PDF, LR 7007-1(d), p. 78 | "Each motion shall be accompanied by a separate notice of the time, date, and place of the hearing on the motion in accordance with Local Rule 9013-1." | `notice-page()`: a separate caption and signature after the memorandum (the exemplar prints it that way) |
| NCWB-LR-MOT-003 | Same PDF, LR 9013-1(a)-(c), p. 90 | (a) Every filing is served on the trustee, including the standing Chapter 13 trustee. (b) Motions in Chapter 7 and 11 cases must be served on the Bankruptcy Administrator. (c) "Each pleading or document to be served on any party shall be accompanied by a certificate of service," which "shall indicate the names and addresses of the specific parties served." | `certificate()`, from the frontmatter `service` block |
| NCWB-LR-MOT-004 | Same PDF, LR 9013-2(a), p. 96 | Briefs: page limit 25; font size "a minimum of 12 point"; "double-spaced"; "margins must be one inch on all sides"; "each page must be numbered". Contents: (1) a concise statement of the facts; (2) all admissions and stipulations, if applicable; (3) a summary of the points of law, citing authorities; (4) any anticipated evidentiary problems, if applicable. | `type-size` 12 pt; `double`; `margin` 1 in; page numbers. Contents (1) and (3) are in the sample; (2) and (4) are not (see gaps). |
| NCWB-LR-MOT-005 | Same PDF, LR 9013-2(b), p. 96 | Briefs are filed and received by opposing counsel at least 5 business days before the hearing; replies 3; surreplies 1. | Not a layout rule; not checked by the template. |
| NCWB-CAP-001 | FRBP 9004(b) and 7010 (see the complaint README, NCWB-PLEAD-003/004) | Caption: court name, case title, case number and adversary number, document designation. | `court-title()`, `caption()`, `title-block()` |

Paper size: the local rules are silent (checked). Letter is used. Not a rule.

Typeface: face required by the rules: **none**. LR 9013-2(a) says only "the font size is a minimum of 12 point"; no face name appears anywhere in the Sept 2021 local rules text (checked 2026-10-14). The template is set in **Times New Roman** 12 pt, the house standard where no face is named (`docs/FONTS.md` rule 6; Liberation Serif as fallback), on typst and docx; EB Garamond before 2026-10-17 (the docx until fb-595.68.18). Fit: n/a. The faces in the filed exemplar (Helvetica and Courier-Bold, not embedded) are exemplar evidence, not a rule.

## Exemplar

- `usage/FILED-EXAMPLE-motion-brief.pdf`: Motion of Hyatt Corporation to Dismiss First Amended Complaint for Failure to State a Claim (Rule 12(b)(6)), with the Notice of Hearing, *Cole Hayes, Chapter 7 Trustee v. Hyatt Corporation, et al.*, Adv. No. 25-03091 (Bankr. W.D.N.C., Charlotte Division), Doc 28, filed November 13, 2025, by Hyatt Corporation. 11 pages: pp. 1-9 motion with memorandum, pp. 10-11 notice of hearing with its own caption and signature.
- Provenance and searches: `usage/SOURCE.md`.
- Fonts in the exemplar: Helvetica and Courier-Bold, not embedded; the body typeface cannot be read from the file.
- The exemplar carries no certificate of service and cites a Declaration (Michelle Theis) that is not in the RECAP copy.

## Sample

- `usage/INPUT-motion-brief.md` transcribes the whole exemplar, verbatim, including its own slips (for example "Hyatt Corp.." and the quote "'Park Hyatt" in ¶ 5, and "seeks to the avoid" in ¶ 6). The notice of hearing is transcribed as filed, which says "Motion ... to Dismiss Complaint" (not "First Amended Complaint").
- Frontmatter drives every case word: caption, debtor, adversary, title, signature, and `service` (the certificate of service). The service list is written by us, not transcribed: the trustee and the Bankruptcy Administrator (LR 9013-1(a)-(b)) with a placeholder for addresses, and "all other parties registered for electronic service". The exemplar does not show these; the rules require them.
- Paragraph numbers are typed by the author and escaped (`1\.`), as in the exemplar; section numbers (I., II., A.) are typed by the author too.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district/motion-brief applied-machinery-25-03091
```

- `usage/OUTPUT-motion-brief.typst.pdf`: 11 pages, letter. Compiled with no typst warnings. `pdffonts`: Times New Roman Regular, Italic and Bold, all embedded (the pinned files of `docs/FONTS.md` rule 1).
- `usage/OVERLAY-applied-machinery-25-03091.pdf` and `.txt` (made on the earlier 10-page EB Garamond render, before fb-595.68): red = our render, blue = filed exemplar, black = both. Page map from the tool (word overlap): ours p.1-3 pair with filed p.1-3 (87.0%, 72.0%, 54.2%); ours p.4-6 pair with filed p.5-7 (51.1%, 65.2%, 76.4%); ours p.7 pairs with filed p.11 (65.3%; our conclusion and memorandum signature against the notice signature); ours p.8-9 pair with filed p.10-11 (89.6%, 80.6%; the notice of hearing); ours p.10 (certificate of service, not in the exemplar) pairs with filed p.1 at 24.0%, which is not a real match. The overlay is a diagnostic, not a score.
- File names: as in the complaint README (`OUTPUT-`, `OVERLAY-`, `INPUT-`), not the brief's `<id>.pdf`.

## Visual review (Gate 2 record; all 10 pages, rendered at 60 dpi and looked at, on the earlier EB Garamond render, before fb-595.68)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtor box, adversary box with Adv. No.), title, opening paragraph | OK. Double-spaced; first-line indent on the opening paragraph. |
| 2 | I. PRELIMINARY STATEMENT, II. RELEVANT BACKGROUND, A. The Adversary Complaint, ¶¶ 1-4 | OK. Section headings centered and bold; sub-heading flush left and bold. |
| 3 | ¶¶ 5-10, B. heading, III. LEGAL STANDARD heading and ¶ 10 | OK. |
| 4 | ¶ 11, IV. ARGUMENT, A. heading (two lines), ¶ 12, start of the § 548(a) block quotation | OK. |
| 5 | Rest of the § 548(a) quotation, ¶ 13 and the N.C. quotation, ¶ 14 | OK. The statute's sub-paragraphs are single-spaced with little gap between them, as in the exemplar. |
| 6 | ¶ 14 end, ¶ 15, numbered sub-paragraph "1." | OK. White space at the foot of the page: V. CONCLUSION moves to page 7 with its paragraph. |
| 7 | V. CONCLUSION, WHEREFORE, memorandum signature block | OK. The signature block fits on the page. |
| 8 | Notice of hearing: caption repeated, heading, first three notice paragraphs | OK. |
| 9 | Last notice paragraph, bracketed remainder line, signature block for the notice | OK. |
| 10 | Certificate of service (LR 9013-1(c)) | OK as laid out. Addresses are placeholders (gap 4). |

## Known gaps and open choices

1. **Tier-2 exemplars (one only).** Two or three filings from different filers are needed. Searches: web search for "Western District of North Carolina bankruptcy motion Rule 9013 memorandum Case No. pdf courtlistener" (local rules and aggregator pages only); CourtListener RECAP search (`https://www.courtlistener.com/api/rest/v4/search/?type=rd&court=ncwb`) for "memorandum in support" (31 results; the first page read: a Kennedy memorandum, a Garlock brief, a Power Home Solar response, and others, none a W.D.N.C. motion with memorandum from a second filer that I downloaded); "motion to dismiss" "adversary proceeding" (225 results; the first page read: JTR1 doc 8, a 5-page joinder whose title in the PDF metadata is "Complaint Discharge", not used; Congressional Federal Credit Union v. Pusateri, 2009, not downloaded; Hayes v. Hyatt, used). Still to do: a second and third motion from a different filer.
2. **The memorandum is inline.** The exemplar's motion contains its memorandum, with no separate memorandum. LR 7007-1(a) says a memorandum "shall be filed in accordance with Local Rule 9013-2", which is the same brief rule. The template renders the memorandum inside the motion, as the exemplar does. A separately filed memorandum would need its own doc type; not decided.
3. **LR 9013-2(a) contents (2) and (4).** The sample has (1) the facts (Relevant Background) and (3) the points of law with authorities. It has no admissions-and-stipulations paragraph (2) and no anticipated-evidentiary-problems paragraph (4). Both are "if applicable"; the exemplar does not say whether they apply. The motion relies on the Theis declaration, which may raise an evidentiary point. Open for counsel or David.
4. **Certificate of service has placeholders.** LR 9013-1(c) requires names and addresses. The exemplar has no certificate, and the trustee and Bankruptcy Administrator addresses are not in it. The sample says "[address to be added by counsel]". The certificate does not meet LR 9013-1(c) until those addresses are supplied; the template enforces nothing here, so the frontmatter must be completed before filing.
5. **Page limit (LR 9013-2(a), 25 pages)** is not counted by the template. The sample's memorandum ran pp. 1-7 on the earlier EB Garamond render.
6. **Notice of hearing wording.** Transcribed as filed; it refers to the "Complaint" (the original), while the motion is directed to the First Amended Complaint. The template does not check this.
7. **Typeface and spacing.** The rules name no face (see Governing rules), so the template is Times New Roman (`docs/FONTS.md` rule 6, the house standard, David 2026-10-17; EB Garamond before 2026-10-17, the docx until fb-595.68.18) at 12 point, double-spaced, one-inch margins, per LR 9013-2(a). The exemplar's faces (Helvetica and Courier-Bold, per `pdffonts`, not embedded) are not the body face, so they are not a rule.
8. **ECF header** ("Case 25-03091 Doc 28 Filed ...") is added by CM/ECF and not reproduced.
9. **Exemplar slips** are transcribed as filed (see the Sample section).
10. **Local rules currency.** The Sept 2021 PDF is the latest I could find; not checked for a later version.

## Engines

Typst (`typst/`) is the reference. The docx engine is built here (`docx/`: `reference.xml`, from which `fb render --engine docx` builds the reference document on the shared cross-engine recipe in the typst face, and `ncwb.lua` for the caption, notice of hearing, signature blocks and certificate; `make-reference.sh` and `reference.docx` were retired into fb render in fb-595.68.18). The latex engine is not built for this folder.

| Engine | Output (`usage/`) | Status |
|---|---|---|
| typst | `OUTPUT-motion-brief.typst.pdf` (11 pp) | reference |
| docx | `OUTPUT-motion-brief.docx` and `OUTPUT-motion-brief.docx.pdf` (LibreOffice, 11 pp) | ok: converted without error; XENG-001..003 pass, `usage/.check-docx.txt` PASS (typst 9 and docx 13 checks passed, fb-595.68.18). The by-eye review (all 11 pages of the earlier EB Garamond `.docx.pdf` at 60 dpi, beside typst pages 1 to 10) predates the port |

Rebuild and render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`.

- *Matches typst* (seen on the earlier EB Garamond docx; the face is now Times New Roman 12 pt on both, Regular, Bold and Italic embedded): US Letter; one-inch margins; body double-spaced at exact 24 pt, half-inch first-line indent, 16 pt after each paragraph; section headings centered (level 1), flush left bold (level 2), bold italic (level 3); block quotations single-spaced, indented 0.5 in both sides. The statute and rule quotations keep their markers as written ("(a) (1) The trustee", "(A) made", "a. Was engaged"): pandoc now reads the sample without `fancy_lists`, so they stay text (the earlier docx turned them back into paragraphs with a filter). The court title, caption, title, the memorandum's signature block, the notice of hearing on a new page with the caption repeated, its own signature, and the certificate of service on its own page with the parties listed. A centered page number on every page.
- *Differs (tier 2, not chased; on that earlier docx, not re-checked here; both engines are 11 pages now):* body line breaks fell at other words in LibreOffice, so page breaks fell at other paragraphs: 11 pages against typst's 10. The memorandum's "V. CONCLUSION" moves to page 8 with its WHEREFORE and signature (the docx keeps them together, so page 7 ends with white space; typst keeps the conclusion on page 7). The notice runs pages 9 and 10 (typst 8 and 9), and the bracketed "[Remainder of Page Intentionally Blank ...]" line sits with the notice signature on page 10. The certificate is on page 11 (typst 10). The signature blocks are paragraphs with a tab stop, not a table, so that "WHEREFORE" stays with its signature in LibreOffice; Word may paginate differently.
- *Not built:* nothing the typst form has. Addresses in the certificate are placeholders, as in the sample (gap 4 above).
- *Word:* not opened in Word (not installed on this box). Checked: `unzip -tq` is clean, every XML part passes `xmllint --noout`, no style ID is defined twice, and LibreOffice converts the file without error. The no-repair check in Word is not done.
- *Exemplars:* the filed exemplar this README cites is not in `usage/` in this checkout (only `SOURCE.md` is there), so the docx is judged against the typst render only, not against a filed exemplar.
- *BLOCKED:* none. Every mandated element above renders; the open items are tier 2 or the Word check.

[Formbook index](../../../../../../README.md) | [Status table](../../../../../../STATUS.md) | [Complaint sibling](../adversary-complaint/README.md)
