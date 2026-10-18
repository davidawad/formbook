# ilsd: motion-brief

Doc type: **motion to dismiss with a brief in support** (Fed. R. Civ. P. 12(b)(6), with the memorandum in the same document, as the exemplar does) in the United States District Court for the Southern District of Illinois (`ilsd`).
Folder: `courts/seventh-circuit/illinois/federal/southern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole exemplar (caption, motion, brief, conclusion, signature, certificate of service, 12 footnotes) |
| typeface | face required by rules: **none** (S.D. Ill. LR 7.1(a)(3) sets 12-point font; LR 5.1(a) sets paper and spacing; no typeface named). Vendored substitute: **EB Garamond** (kept, because no face is named). Fit: n/a. |
| render | ok (re-rendered 2026-10-15): `usage/OUTPUT-motion-brief.typst.pdf`, 7 pages, typst 0.15.0, `pdffonts`: EB Garamond only (Regular, Bold, Italic, embedded), no warnings |
| overlay | **fail** (2026-10-15): `tools/overlay.sh` needs `usage/*.pdf`, which is not in this snapshot (only `usage/SOURCE.md` is tracked). `usage/OVERLAY-shelton-motion-to-dismiss.txt` is the earlier output and was not regenerated; no `.pdf` overlay is present. |
| pages reviewed | 7 of 7 (2026-10-15: every page rendered at 60 dpi and viewed; no template change in that pass) |
| `check.sh` | not run: same reason as `../complaint/README.md` (this doc-type folder is not a court folder with `court.json` and `rules.md`). The review below is the Gate 2 equivalent. |

File names: the overlay tool reads and writes `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` (its fixed names).

## Governing rules

Sources, all read on 2026-10-14:

| ID | Rule | Kind | Requirement | Where it is in the template |
|---|---|---|---|---|
| ILSD-LR-7.1(a)(3) | S.D. Ill. Local Rule 7.1(a)(3) (LocalRules10-30-2023.pdf, https://www.ilsd.uscourts.gov/sites/ilsd/files/LocalRules10-30-2023.pdf; read on 2026-10-14) | M | "[N]o brief shall be submitted which is longer than 20 double-spaced typewritten pages in 12-point font", unless the Court authorizes more (habeas responses excepted). The page limits exclude "cover pages, tables of content, tables of authority, signature pages, certificates of service, exhibits, and Statements of Material Facts" etc. | `type-size = 12pt` (footnotes too); `body-leading` gives a 24 pt pitch (double spacing). The 20-page limit is not checked (see Gaps). |
| ILSD-LR-7.1(a)(1) | S.D. Ill. Local Rule 7.1(a)(1) (same PDF) | M | "A motion shall state its grounds with particularity and shall set forth the relief sought." | Author content: the first two paragraphs of the sample (grounds, relief). Not asserted by the template. |
| ILSD-LR-7.1(a)(2) | S.D. Ill. Local Rule 7.1(a)(2) (same PDF) | M | "All briefs shall contain a short, concise statement of the party's position, together with citations to relevant legal authority and to the record." | Author content: the Argument and Authorities section. Not asserted. |
| ILSD-LR-7.1(a)(4) | S.D. Ill. Local Rule 7.1(a)(4) (same PDF) | M, for replies | Reply briefs are limited to five pages and are disfavored. | Not applicable to this doc type (no reply). |
| ILSD-LR-5.1(a), (b) | S.D. Ill. Local Rule 5.1 (same PDF) | M for pro se paper originals; counsel file electronically under (b)(1) | 8½ × 11 white paper, double-spaced, every page numbered consecutively, for paper originals; counsel file under the court's electronic procedures. | Page size, page numbers (centered), double spacing. See `../complaint/README.md`. |
| FRCP-12-001 | Fed. R. Civ. P. 12(b)(6) (https://www.law.cornell.edu/rules/frcp/rule_12; quoted 2026-10-14) | M | Defense of "failure to state a claim upon which relief can be granted". | Content: the first and "Standard" sections of the sample. |
| FRCP-7-001 | Fed. R. Civ. P. 7(b)(1)(B) (https://www.law.cornell.edu/rules/frcp/rule_7; quoted 2026-10-14) | M | A request for a court order must "state with particularity the grounds for seeking the order". | Content; the same requirement as ILSD-LR-7.1(a)(1). |
| FRCP-5-001 | Fed. R. Civ. P. 5(b)(2)(E) (https://www.law.cornell.edu/rules/frcp/rule_5; partly quoted 2026-10-14) | M for electronic service | Service is made "by filing it with the court's electronic-filing system" for a registered user. | The certificate of service (generated from frontmatter `service`): its wording follows the exemplar's certificate, which cites the court's electronic system. |
| FRCP-10-001 | Fed. R. Civ. P. 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10; quoted 2026-10-14) | M | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." A motion is not a pleading, but the exemplar and the court's practice use the same caption. | Caption: court name, parties with designations, "Civil Action No." on the right, title centered. |
| CONV-001 | Caption with ")" column | C | The Pro-Life complaint uses ")" marks; this exemplar uses a "§" column. Both are filed in this court; the ")" style is the one used for the complaint in this folder set. | `caption()`. Not a choice the rules dictate. |
| CONV-002 | Signature block and certificate | C | The exemplar's signature block ("Respectfully submitted," / "By:_/s/" / attorney in charge, bar numbers, firm, address, phone, fax, email, "ATTORNEYS FOR DEFENDANT") and certificate. | `signature()` and `certificate()`. |

Local practice not checked: the judges' standing orders and case-management procedures (SDIL-LR 7.1(a)(4) directs readers to them for replies), and the ECF Procedures (not read for this box).

## Layout

- Court name on two lines, centered; caption (parties, ")" column, "Civil Action No." on the right); title centered and bold.
- Body: one document rendered by cmarker. Paragraphs have a 0.5 in first-line indent and a 24 pt baseline pitch (measured on page 2: 24.0 pt between body lines; footnote lines 14 pt).
- Headings are numbered by the template (not typed): level 1 `#` → I., II., III. (label on its own line, centered, bold); level 2 `##` → A., B., ... (bold, label hanging at 0.5 in); level 3 `###` → 1., 2., ... (indented 0.5 in). The sample types no numbers.
- Footnotes at 12 pt; single spaced inside the footnote area.
- Signature block: "Dated this ..." on the left, then "Respectfully submitted," and the signer, the counsel lines and the role, starting at 3.0 in (`breakable: false`).
- Certificate of service on its own page, after the signature (`pagebreak`), with the recipients from frontmatter `service.recipients`.
- Page numbers centered at the foot of each page. The exemplar's footer carries the title and "PAGE n"; the template does not (see Gaps).

## Sample

- `usage/INPUT-motion-brief.md` transcribes the whole exemplar, its 7 pages: the caption, the opening paragraph, I (Grounds), II (Argument and Authorities, A. The Standard; B. Preemption; C. Damages; D. Jury Trial), III (Conclusion), the signature, the certificate of service, and footnotes 1 to 12.
- Case names and signals are italic exactly where the filed PDF's italic runs are (the exemplar embeds TimesNewRomanPS-ItalicMT; its italic runs were read with `pdftohtml -xml -i`, `<i>` tags): *Hecker v. Deere & Co.*, *Tierney v. Vahle*, *Metropolitan Life Ins. Co. v. Taylor*, *Hartland Lakeside…*, *Pohl…*, *Olsen…*, *Cannon…*, *FMC Corp. v. Holiday*, *Aetna Health Inc. v. Davila*, *See, e.g.*, *Pilot Life…*, *Di Joseph…*, *Mertens…*, *Massachusetts Mutual…*, *McDougall…*, *Bell Atlantic…*, *Ashcroft v. Iqbal*, *Pilot Life Ins. Co.* (short form). *Id.* does not occur.
- The sample uses the exemplar's text, including the typed "215e ILCS 155." (footnote 2 gives the complaint paragraphs), "29 U.S.C. § 1001, et seq.," and "Doc. 1-1" as printed.
- The exemplar's Exhibit A and B are not part of the document (they are attachments); the sample refers to them as the exemplar does.

## Review of the rendered pages (current PDF, 60 dpi, every page viewed)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Court name, caption with ")" column, Civil Action No., centered two-line title; opening paragraph; section I label and heading (heading was enlarged before the fix: heading text now 12 pt); footnotes 1 to 5 at 12 pt. | FIXED (heading size), then re-viewed: PASS |
| 2 | exemplar p.2 | Continuing I; II. ARGUMENT AND AUTHORITIES centered; A. THE STANDARD hanging label; footnotes 6 to 9. | FIXED (heading size), then re-viewed: PASS |
| 3 | exemplar p.3 | B. heading two lines, label hanging; Hecker, Tierney italic; footnote 10. | FIXED (heading size), then re-viewed: PASS |
| 4 | exemplar p.4 | Body; *Pilot Life* italic; footnotes 11 and 12 (the ¶ and ¶¶ marks render). | PASS |
| 5 | exemplar p.5 | C. and D. headings; III. CONCLUSION centered; conclusion paragraph ends the page. | FIXED (heading size), then re-viewed: PASS |
| 6 | exemplar p.6 | Signature block only: "Dated this 4th day of March 2026."; "Respectfully submitted," the signer, counsel lines, "ATTORNEYS FOR DEFENDANT". The "P.C." wrapped to its own line; sig indent narrowed to 3.0 in, fixed. | OPEN (see Gap 3): the signature block is alone on this page; the sig indent was narrowed to 3.0 in and fixed, but the page itself has no body text. |
| 7 | exemplar p.7 (certificate of service) | CERTIFICATE OF SERVICE centered; the certificate text; "Christopher A. Koester / Email: koester@taylor.net"; date and "/s/ Iwana Rademaekers". The recipient list sits close under "as follows:". | ACCEPTED (tier 2 spacing; see Gap 4) |

Reviewed pages: 7 of 7.

## Overlay

`sh tools/overlay.sh courts/seventh-circuit/illinois/federal/southern-district/motion-brief shelton-motion-to-dismiss` writes `usage/OVERLAY-shelton-motion-to-dismiss.pdf` and `.txt`. Page map: ours p.1 ↔ filed p.1 (89.7% word overlap), p.2 ↔ p.2 (86.3%), p.3 ↔ p.3 (77.7%), p.4 ↔ p.4 (66.0%), p.5 ↔ p.5 (54.8%), p.6 ↔ p.6 (34.6%: the signature page is short in both, and the exemplar's p.6 has the signature block at a different position), p.7 ↔ p.7 (82.6%). The overlay is a diagnostic: the exemplar's caption is in a § column and its footer carries the title and page, so the two layers differ at those places.

## Known gaps and open choices

1. **One exemplar, one filer.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search for S.D. Ill. 12(b)(6) motions with a memorandum returned mostly orders and pro se papers. Shelton is the only one found with a complete text layer. Clearinghouse pages (which listed the U.S. v. Illinois motion, 3:25-cv-01691, ECF 18) returned HTTP 403, so that motion was not checked. The tier-2 judgement is against one filer.
2. **Font.** EB Garamond (vendored, OFL) at 12 pt. The local rules name no typeface (LR 7.1(a)(3) sets "12-point font"), so `docs/FONTS.md` keeps EB Garamond. The exemplar is Times New Roman, 12 pt (`usage/SOURCE.md`): a tier-2 convention, not a rule. Liberation Serif (metric-compatible Times substitute) is vendored and would switch the font if David decides the convention outweighs the rule. EB Garamond at 12 pt reads smaller than Times at 12 pt; the rule's minimum is met.
3. **Signature page without body text.** The conclusion ends page 5 and the signature block (kept together with `breakable: false`) falls to page 6 alone. The exemplar keeps the conclusion and the signature on one page. A fix would keep the last body paragraph with the signature (not done: the markdown body is rendered as one document, and a general keep-with-next for the last paragraph is not implemented). Tier 2; recorded as OPEN, not fixed.
4. **Certificate spacing.** The recipient list is close to "as follows:" (6 pt). The exemplar's certificate spacing was not measured. Tier 2; ACCEPTED.
5. **Footer.** The exemplar's footer carries the title and "PAGE n" on each page; the template prints a centered page number only. The rules do not require a footer title; ACCEPTED as tier 3 (filer style).
6. **Page limit (SDIL-LR 7.1(a)(3)).** The template does not count pages. This sample is 7 pages; the 20-page limit applies to the author.
7. **Tables.** No table of contents and no table of authorities. The rule excludes them from the count (LR 7.1(a)(3)); they are not required by the rule for a brief of this length. A brief over about 10 pages needs them as a convention; the template does not produce them (the ca9 and cand templates do, and the same approach could be copied). Not built here.
8. **Exhibits and proposed orders.** Not produced (separate filings). Exhibits A and B of the exemplar are attachments.
9. **Caption style.** The ")" column is used. The exemplar uses a "§" column. Both appear in S.D. Ill. filings; the choice is a tier-2 convention and is not asserted by any rule.

## Engines

DOCX (`docx/`; built 2026-10-15, not reviewed):

- Files: `docx/build-reference.sh` (same build as `complaint/docx/`: EB Garamond 12 pt, exact 24 pt line pitch, 0.5 in first-line indent, 1 in margins, letter, footnotes 12 pt single, centered PAGE footer, custom styles), `docx/reference.docx` (committed build output), `docx/ilsd.lua` (cover, caption table, headings labelled I., A., 1. by the filter, signature block, certificate of service, from the frontmatter).
- Output: `usage/OUTPUT-motion-brief.docx`, written by `sh tools/render.sh --engine docx courts/seventh-circuit/illinois/federal/southern-district/motion-brief usage/INPUT-motion-brief.md`. The `.docx` opens as a valid zip and every XML part is well-formed (`unzip -tq`, `xmllint --noout`). The footer relationship (`footer1.xml`) and its content type are present.
- Matches the typst form, by construction (not checked on a render): font and size, double spacing, 0.5 in first-line indent, 1 in margins, centered page number, 12 pt footnotes, heading labels and hanging indents, the signature block at 3.0 in, and the certificate of service on its own page with the recipients from the frontmatter.
- Differs or unverified: the caption ")" column relies on exact 14 pt caption lines in a borderless table; the spacing around the caption, title, signature and certificate is set by style, not measured against typst. The date line and the certificate's right-aligned signer use a right tab at 6.5 in. The typst signature block is kept together (`breakable: false`); the docx signature paragraphs use keep-with-next, which Word and LibreOffice may honour differently. The open tier-2 finding in this folder (the signature block alone on a page, README "Review") may recur.
- BLOCKED: `docx.pdf` not produced (`soffice` is not installed on this box, and cannot be installed here). The LibreOffice PDF gates (Gates 0 to 3, `sh tools/check.sh --engine docx`) cannot run. The docx.pdf render and page review are the REMAINING work.
- Page review (Gate 2 for docx): 0 of 7 pages reviewed.
- Cover and caption table borders are not verified against the typst layout (the table is set to no borders; the view was not checked).
- No TOC or TOA: the typst template has none for this doc type either.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/illinois/federal/southern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/seventh-circuit/illinois/federal/southern-district/motion-brief shelton-motion-to-dismiss
pdftoppm -r 60 -png courts/seventh-circuit/illinois/federal/southern-district/motion-brief/usage/OUTPUT-motion-brief.typst.pdf /tmp/rev/motion/p
```

[Doc type index](../../../../../../README.md) · [Southern District](../README.md)
