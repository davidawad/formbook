# M.D. Ga. Bankruptcy Court: motion with memorandum

Doc type: **motion-brief** (a written motion under FRBP 9013 with its memorandum of law, in one filed document). Court: United States Bankruptcy Court, Middle District of Georgia (`gamb`, Eleventh Circuit). Folder: `courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, partial: `exemplars/FILED-EXAMPLE-gordon-14-07017-motion-brief.pdf` is the supporting **memorandum** (not the motion itself; see gaps). 1 filer; see `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-gordon-memorandum.md` (caption, title, Statement of the Case, Statement of the Facts with footnote, Issues, Argument IV.A and IV.B, Conclusion, signature block, certificate of service with placeholders) |
| render | ok: `samples/OUTPUT-gordon-memorandum.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-gordon-memorandum.pdf` and `OVERLAY-gordon-memorandum.txt` |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed; page 1 viewed again after the caption fix; all 10 re-rendered and viewed again 2026-10-14 in the fonts pass, no change) |

This folder is self-contained. It does not touch the court-root `typst/` or `samples/`.

## Governing rules

Primary sources, fetched 2026-10-14. Rule text was read from the LII copies (FRBP) and from the court's own PDFs (LBR and Clerk's Instructions, April 2025 compilation).

| ID | Source | Requirement | Where in the template |
|---|---|---|---|
| GAMB-MOT-001 | FRBP 9013 (https://www.law.cornell.edu/rules/frbp/rule_9013) | A request for an order must be made by written motion. The motion must state its grounds with particularity and set forth the relief requested. | Author content (the sample's opening paragraph states the relief). Not checked by the template. |
| GAMB-MOT-002 | LBR 9013-1(b) (Local Rules, Apr. 2025, https://www.gamb.uscourts.gov/USCourts/sites/default/files/local_rules/Local_Rules_Apr_2025.pdf, p. 38) | All motions should indicate the applicable code sections, rules or other legal authorities. | Author content. Not checked. |
| GAMB-MOT-003 | LBR 9013-1(c); LBR 9004-1(c)(1), (c)(5)(B) (same, pp. 35-36); Clerk's Instructions, Appendix L (Notice of Motion, p. 76) | Every motion must be accompanied by a notice of motion that complies with LBR 9004-1(c). The notice is a **separate document** unless it fits on one page with a short pleading. | **Not produced.** See gaps. |
| GAMB-MOT-004 | LBR 9013-1(a) (same, p. 38) | A motion that may be granted without a hearing needs a proposed order, sent as an E-Order. | **Not produced.** See gaps. |
| GAMB-CAP-001 | FRBP 9004(b) (LII copy) | Caption: court's name, case title, case number and adversary-proceeding number, and a brief designation of the document. | court lines, `caption()`, `title` |
| GAMB-CAP-002 | Clerk's Instructions, "Form and Caption of Complaint" (p. 37), Form 416D; LBR 9004-2(a) (Local Rules p. 36) | Caption shows the chapter; the case number includes the judge's initials. | `chapter` and `case_number` ("12-70482", which in the exemplar carries no judge initials, see gaps) |
| GAMB-CAP-003 | LBR 9004-2(b) (Local Rules p. 36) | The title designates the relief sought; "motion" alone is not enough. | `title` |
| GAMB-FORM-001 | FRBP 9004(a) (LII copy) | "A petition, pleading, schedule, or other document must be clearly legible." | Whole template: EB Garamond 13 pt, 1-inch margins, us-letter, body double-spaced (24 pt) |
| GAMB-FORM-002 | No face named for motions. Checked 2026-10-14: the only face rule in the Clerk's Instructions ("Courier or Times New Roman", item f of the section on proposed **orders**) does not reach motions or briefs, and the Local Rules (Apr. 2025) name no typeface. Required face: none. Vendored substitute: none (EB Garamond kept). Fit: n/a. | Stays EB Garamond (no face required). See gaps. | `font-family` |
| GAMB-SIG-001 | LBR 9011-1(b) (Local Rules p. 37) | Attorney's name, State Bar number, office address, telephone and e-mail (the CM/ECF registration address) in immediate proximity to the signature. | `signature-block()` and `attorney-block()` |
| GAMB-SERV-001 | LBR 9013-3(a) (amended April 7, 2021, Local Rules p. 38) | Every motion, brief and other document that requires notice to parties in interest contains a certificate of service specifying the parties served (with addresses, except those served through CM/ECF under LBR 2002-1(e)), the method of service, the date of service, and an attorney's signature. | `certificate-of-service()`. The wording of the statement is the template's (not from the exemplar, which has no certificate). |
| GAMB-PAGE-001 | Proposed amendment, Clerk's memo of Aug. 13, 2026 (`Memo LBR 9013-1 Brief Page Limit`, https://www.gamb.uscourts.gov/USCourts/sites/default/files/pdf/Memo%20LBR%209013-1%20Brief%20Page%20Limit%20Public%20Commentary.pdf) | **Proposed:** new LBR 9013-1(d) would limit motions, responses and briefs to 20 pages (replies 10), exhibits excluded, unless the court grants leave. Comments were due Sept. 18, 2026. | Not enforced. The sample is 10 pages. Check the court's site for whether the amendment took effect before filing. |

Not produced by this template, and why:
- **Notice of motion** (LBR 9004-1(c), Appendix L text). A separate document. The rule requires it on every motion (GAMB-MOT-003).
- **Proposed order** (LBR 9013-1(a)). A separate E-Order document (GAMB-MOT-004).
- **Certificate of service as a separate document.** Generated inside the memorandum, because LBR 9013-3(a) requires it on the document. The rule does not require a separate filing.
- **Adversary cover sheet, summons.** Only for the complaint (see `../adversary-complaint/`).

## Layout

- Court title centered, three lines from the `court` frontmatter. Caption per Form 416D, with "In re:" before the debtor, "v." before the defendants, and the right column giving the bankruptcy case number, the chapter and the adversary number.
- Title centered in capitals.
- Body: double-spaced (24 pt), first-line indent. Author-typed headings: level 1 centered bold (for "I. STATEMENT OF THE CASE"), level 2 bold left ("A. Prima Facie Case ..."), level 3 bold italic. The template does not number headings, so the memorandum's own labels stay as typed.
- Block quotations (`>`) are indented 0.75 in on both sides, single-spaced.
- Footnotes at 12 pt, single-spaced.
- Signature block: "Respectfully submitted this ..." (frontmatter `dated`), then one `/s/` block per attorney. The block is unbreakable.
- Certificate of service after the signature: a statement, then the list of CM/ECF parties and the list of parties served by mail, then the attorney signature.

## Markdown contract (for samples)

- Frontmatter: `court`, `title`, `case_number`, `chapter`, `adversary_number`, `parties` (list of `{kind, names, role}`, as in the complaint template), `dated` (the sentence before the signature), `signature` (list of `{signer, bar, firm, phone, email, role}`; an empty `role` prints no role line), `service` (`{date, ecf: [...], mail: [...]}`, each entry a line of text).
- Body: ordinary markdown. `#` headings, paragraphs, block quotations with `>`, footnotes `text[^1]` with `[^1]: ...`. Escape a leading number in running text (`1\.`) so it is not read as a list.
- No tables. No raw typst. The template panics on missing frontmatter fields.

Build and check (from the repo root, with the toolchain on PATH: `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/motion-brief samples/INPUT-gordon-memorandum.md
sh tools/overlay.sh courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district/motion-brief gordon-memorandum
```

- `samples/OUTPUT-gordon-memorandum.pdf` is the render. The names follow `tools/render.sh` and `tools/overlay.sh` (`OUTPUT-` and `OVERLAY-`), not the brief's `<id>.pdf` and `<id>-overlay.pdf`, because those tools are shared and fix the names.
- `samples/OVERLAY-gordon-memorandum.pdf` (red = our render, blue = exemplar, black = both) and `.txt`. The page map pairs pages by word overlap. Our pages 1-3 pair with filed pages 1-3, and our page 10 (certificate) pairs with filed page 16 at 17%, which is low because the certificate is not in the exemplar. The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record, all 10 pages, rendered at 60 dpi and viewed)

| Page | Content | Finding |
|---|---|---|
| 1 | Court title, caption with "In re:", Chapter 7 and adversary number, title, opening "COMES NOW" paragraph | Defendant names wrapped badly in the first render (long lines in the party column). Fixed by rebreaking the names in the sample; re-rendered and checked. |
| 2 | I. Statement of the Case; II. Statement of the Facts with footnote 1 | OK. Footnote 1 at foot of page at 12 pt. |
| 3 | Facts (end), III. Issues of the Law, issues 1-2 | OK. Issue numbers escaped in the markdown, so they are paragraphs, not a list. |
| 4 | Issues 3-8 | OK. |
| 5 | IV. Argument; A. heading; statute quotation (§ 548(a)(1)) | OK. Block quotation indented and single-spaced. |
| 6 | End of § 548 quotation; facts paragraphs; B. heading; § 547(b) lead-in | OK. |
| 7 | § 547(b) block quotation; Wolas discussion | OK. |
| 8 | Security-interest discussion (Ga. Code § 11-9-203) | OK. |
| 9 | Remaining argument (A, B), V. Conclusion | OK. |
| 10 | Date line, signature block, certificate of service | OK. The signature block stands at the top of the page, after the conclusion's last line on p. 9 (see gaps, item 9). |

## Known gaps and open choices

1. **The exemplar is the memorandum, not the motion.** The motion itself (ECF Doc. 62) is not available in the RECAP archive. The template's motion-with-memorandum form (title, caption, memorandum, signature, certificate) is built from the rules, not from a filed combined document. The opening "COMES NOW" paragraph is the memorandum's own. A combined motion needs its own opening paragraphs, which the author writes.
2. **Partial transcription.** The sample has Statement of the Case, Facts (with footnote 1), Issues, Argument IV.A and IV.B, and the Conclusion. Argument IV.C through IV.H (contemporaneous exchange, ordinary course, subsequent new value, equity, § 550, final judgment) and footnote 2 are not transcribed, to keep the render at 10 pages. The exemplar is 16 pages. The eval-loop target (8-14 pages) is met by the render.
3. **Title.** The exemplar's printed title says "MEMORANDUM IN SUPPORT OF MOTION FOR MOTION FOR FULL OR PARTIAL SUMMARY JUDGMENT ...". The sample has "MOTION FOR" once. This is a correction of the exemplar's apparent typo, not a verified change.
4. **Certificate of service and placeholders.** The exemplar has no certificate. Its service details in the sample are bracketed placeholders (`[date of service]`, `[name and address ...]`), because the exemplar does not say who was served or when. Fill them in before filing. The template's statement wording is the template's, not a court form.
5. **Case number and judge initials (GAMB-CAP-002).** The exemplar's case number "12-70482" has no judge initials in the printed caption (it is a Chapter 7 case). LBR 9004-2(a) requires them. The sample follows the exemplar. The template prints `case_number` as given; put the initials in the frontmatter before filing.
6. **Case names are roman in the sample.** The exemplar's text layer has no italic markup. The template italicizes `*...*`, so a future sample can italicize case names and signals (*Id.*, *See*).
7. **Page limit.** No current page limit applies to motions in this court (see GAMB-PAGE-001). A proposed 20-page limit is out for comment. Not enforced.
8. **Font and size.** No face, font size or spacing rule for motions in this court (GAMB-FORM-002, checked 2026-10-14; see `../adversary-complaint/README.md`, gap 2). EB Garamond at 13 pt, with footnotes at 12 pt, per the fonts pass for a court that names no face.
9. **Signature not kept with the last paragraph.** The conclusion ends on p. 9 and the signature block (unbreakable) starts p. 10. A signature alone on a page is discouraged in practice. The template keeps the signature block whole but does not keep it with the preceding paragraph (cmarker output is not a single block to attach a `sticky` to). Fixing this needs a change to how the body is rendered; not done.
10. **Signature twice.** The memorandum signature and the certificate of service signature both appear (the convention in the template; the exemplar has only the first).
11. **Notice of motion and proposed order** are not produced (GAMB-MOT-003, GAMB-MOT-004). Both are separate documents that must be filed with the motion.
12. **Overlay naming.** See "Build and check."
