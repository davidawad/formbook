# wyb: motion-brief

Doc type: **memorandum in support of a dispositive motion in an adversary proceeding** in the United States Bankruptcy Court for the District of Wyoming (`wyb`). The brief asks for "motion with memorandum"; under the court's rules the motion and the memorandum are separate filings (LBR 9013-1(A)(1), (A)(2)), so this template covers the memorandum and not the motion.
Folder: `courts/tenth-circuit/wyoming/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (caption, the Nature of the Case, the undisputed facts, the Applicable Law through the Maverick paragraph, the Attorney Fees and Conclusion, the relief list, the signature and the certificate; pages 10 to 12 of the filed memorandum are omitted and marked in the sample) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages, typst 0.15.0, vendored EB Garamond only (embedded as EBGaramond-Regular/Italic/Bold), no warnings |
| overlay | ok: `usage/OVERLAY-tear-drop-memo.pdf` and `usage/OVERLAY-tear-drop-memo.txt` (every page paired with a filed page, 40% to 87% word overlap; pages 8 and 9 of the render pair with exemplar pages 13 and 14 because the sample omits exemplar pages 10 to 12) |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed after the last template change) |
| BLOCKED | none. Tier 2 is not judged against two or three filers yet (see Known gaps). |

## Governing rules

Primary sources, all fetched 2026-10-14:

| Source | Requirement | Where it is in the template |
|---|---|---|
| Local Bankruptcy Rules, D. Wyo., LBR 9004-1(A), as posted at https://www.wyb.uscourts.gov/sites/wyb/files/local-rules.pdf (rules marked "Effective July 1, 2012"; LBR 9004-1 is printed p. 59 of the 108-page PDF) | Letter-size paper, typewritten or printed on one side; **not less than 13 point** type (footnotes too); counsel headings not smaller than 10 point; double spaced; top margin one inch. | `body-size = 13pt`, `small-size = 11pt` (counsel block and signature lines), `body-leading` (double spacing), `margin-top = 1in`, `us-letter`. |
| LBR 9004-1(B) | First page, top left: the client, and the name, address, telephone, fax and bar license number of the signing attorney. | `counsel` and `client` frontmatter, single spaced at top left. |
| Typeface: no face named. Searched the whole posted local-rules PDF (checked 2026-10-15) for typeface, font and proportional, and for each face in `docs/FONTS.md`: none is named. LBR 9004-1(A) sets only the size (13 point). The Times New Roman in the exemplar is the filer's choice, not a rule. | Court names no face, so the template keeps **EB Garamond** (`docs/FONTS.md`, "No face named"). Typeface row: face required = none; substitute = EB Garamond (vendored); visual only. | `font-family = "EB Garamond"`. |
| LBR 9004-1(A), last sentence | Names typed or printed under the signature line. | `signature.signatures` and `signature.lines`; the names are in the sample. |
| LBR 9013-1(A)(1), (A)(2) (printed p. 65) | Every request is a separate motion; a dispositive motion in an adversary proceeding must be accompanied by a separate memorandum (LBR 9013-2). | Scope of the template: the memorandum only. |
| LBR 9013-2 (printed p. 67) | Memorandum required with dispositive motions in an adversary proceeding; filed and served at least seven days before the hearing; **no memorandum may exceed 20 pages**, exclusive of the table of contents and exhibits, without the court's permission; responses due 14 days after service. | Not checked by the template (see Known gaps). |
| LBR 9013-3 (printed p. 68) | Certificate of service: the name and address of each attorney or party served, the capacity in which each is served, the manner and date of service; filed within seven days of service; with the official mailing list attached where required. | `certificate(meta)`: date, CM/ECF manner, recipient lines (`service.recipients`), signer. |
| FRBP 9004(a), (b) (Cornell LII, fetched 2026-10-14) | Clearly legible; a caption with the court's name, the case title, the case number and adversary-proceeding number, and a brief designation of the document. | `court-title()` (fixed for this court), `caption(meta)` (`bankruptcy_case`, `adversary`, `parties`, `third_party`), `title`. |

Not produced by this template: the motion itself and its notice of hearing (LBR 9013-1(A)(1)); the proposed order (LBR 9013-1(C)); exhibits and affidavits (LBR 9013-1(A)(2)).

## Layout

- Letter paper, 1 inch margins, 13 point EB Garamond, double spaced (2.0 em line pitch; EB Garamond's line box is 0.65 em, so `body-leading` is 1.35 em).
- Counsel block single spaced at top left (11 point).
- Court title centered and bold (two lines), then the caption: the parties in the left column with `v.` between sides, a rule, the third-party parties in the same column, closed by a right rule and a bottom rule; the right column holds the lead bankruptcy case and the adversary proceeding number.
- The title centered and bold, then the body.
- Body paragraphs have a 0.5 inch first-line indent and are not numbered (the author types any numbers, escaped as `1\.`). Headings: `#` bold, left aligned; `##` bold italic. Headings are sticky, so a heading never ends a page.
- The date and the signature block stay together (`breakable: false`). The signatures are stacked, then the firm lines, right aligned.
- The certificate of service follows, with its heading, the certificate text, the recipients and the signer.
- Footer: page number centered.

## Markdown contract (for samples)

- YAML frontmatter, then the body. The body is blank-line separated chunks: `#` heading, `##` heading, or a paragraph.
- Frontmatter fields: `counsel` (lines), `client`, `bankruptcy_case`, `adversary`, `parties` (list of `{names, designation}`, `v.` inserted between), `third_party` (same shape, a second group below a rule), `title`, `date`, `signature` (`signatures`, `lines`), `service` (`date`, `signer`, `recipients`).
- Inline markdown works (`*italic*`, `**bold**`). Escape a paragraph that begins with a number or marker: `1\. Ordering ...`.
- Not supported: tables, footnotes, raw typst.

## Check and render

```sh
export PATH="$HOME/tb/bin:$PATH"   # or the bootstrap toolchain
sh tools/render.sh courts/tenth-circuit/wyoming/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/tenth-circuit/wyoming/federal/bankruptcy-district/motion-brief tear-drop-memo
```

`tools/check.sh` and `tools/check-selftest.sh` are not run here. Both read a court folder with `court.json` at its root, and this doc-type folder is not that shape. The render warning check (any typst warning fails the build) and the vendored-font check are what `tools/render.sh` enforces, and both passed.

## Gate 2 (visual review), pages as rendered 2026-10-14

- Page 1: counsel block, court title, caption (parties, third-party group, lead case and adversary numbers), title. Pass.
- Page 2: heading "Nature of the Case" and its first three paragraphs. Pass.
- Page 3: paragraphs of the Nature of the Case (the jurisdiction paragraph and the Stern paragraph), "Undisputed Facts", the first numbered fact. Pass.
- Page 4: numbered facts 2 to 7. Pass.
- Page 5: numbered facts 8 to 12, "Applicable Law" heading and the first paragraph. Pass.
- Page 6: the Applicable Law paragraphs, the two-question list. Pass.
- Page 7: Devon's defense paragraphs. Pass.
- Page 8: the Maverick quotation, the omission marker (italic, bracketed), "Prejudgment Interest" and "Attorney Fees" headings. Pass. The omission marker is a transcription note, not text from the filing.
- Page 9: the attorney-fee paragraphs, "Conclusion", the start of the relief request. Pass.
- Page 10: relief items 1 to 7. Pass.
- Page 11: relief items 8 to 13. Pass.
- Page 12: the date, the two `/s/` signatures, the firm lines, the certificate of service with its recipients and signer. Pass. The date and signatures are not split from the body.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for two or three filers. The search (CourtListener RECAP, `court=wyb`) looked at motions and memoranda in adversary proceedings. Diamond Oak, Inc. v. Bickford (25-02006, doc 13, plaintiff's motion for summary judgment) returned an empty file from its RECAP path. The Miller v. Water Works motion for summary judgment (20-02029) has no RECAP storage path. Tier 2 is therefore **not** judged against two filers yet.
2. **Type size: the rule says 13 point, the exemplar is smaller.** LBR 9004-1(A) requires not less than 13 point. The exemplar's body text measures about 12.2 pt (median word bounding-box height, `pdftotext -bbox`), set in Times New Roman. The template follows the rule (13 pt); the render is therefore longer than the exemplar's page count would suggest. Recorded as a rule-over-exemplar choice.
3. **Page limit (LBR 9013-2).** The complete filed memorandum is 17 pages in the exemplar's type size. The sample omits pages 10 to 12 of the filing (a marked gap), so the render is 12 pages. The 20-page limit is not checked by the template; a full memorandum at 13 point must be checked by the filer.
4. **Certificate of service (LBR 9013-3).** The rule requires the name and address of each person served. The exemplar's certificate gives names and email addresses only; the template prints the recipient lines as the author supplies them, so a postal address must be added by the filer. The template does not check the seven-day filing period.
5. **Consent and jurisdiction statements.** The memorandum relies on the bankruptcy court's non-core and consent analysis (Stern, 28 U.S.C. §157(c)). The template does not check that the statement matches the complaint's consent paragraph.
6. **Italic case names.** The exemplar's text layer has no italic markup, so the sample is roman throughout (for example "Pennaco Energy, Inc. v. KD Company, LLC"). The template italicizes `*...*`; a reviewer should italicize case names before filing (FRAP and LBR convention; the local rules do not require it).
7. **Transcription.** The sample is the exemplar's text, typed as written, including its own typos ("Tear Drops land", "Tear drop did not execute", "Fed Bank. R. P.", "cgregersen@crowley fleck.com"). The omitted pages are marked in the sample.
8. **Relief list.** The exemplar's relief items are numbered 1 to 13 and the template prints them as numbered paragraphs (escaped in the sample), not as a list.
9. **No table of contents.** LBR 9013-2 excludes a table of contents from the page limit, but the rules do not require one for a memorandum, and the exemplar has none; none is generated.
10. **Local rules version.** The posted PDF is the court's local rules marked "Effective July 1, 2012". If the court has issued a newer edition, LBR 9004-1, 9013-1, 9013-2 and 9013-3 must be checked against it.

## Engines

**docx** (`docx/reference.docx` + `docx/wyb-motion-brief.lua`; output `usage/OUTPUT-motion-brief.docx`).

- Matches: EB Garamond 13 pt body, 1 in margins, letter paper, exact 26 pt (double) line pitch, 0.5 in first-line indent, bold centered court title, caption table with the party rule and bottom rule and case information on the right, counsel block 11 pt single spaced, page number footer 11 pt centered, footnote text 13 pt.
- Differs: the filter lays out the cover in a table with plain-text caption values (no inline markdown in caption parties), and the pleading-paper paragraph numbers and lettered prayer items are typed text, not Word list numbering. Heading and signature keep-together uses keepNext, so Word and LibreOffice may break pages differently.
- BLOCKED: docx.pdf (`soffice` not installed on this box, no root and no conda-forge package), so Gate 0 and Gate 1 are not run on the docx.
- BLOCKED: `tools/render-docx.sh` zip integrity step: `unzip` is not installed, so `unzip -tq` fails and the command exits 1 after writing the .docx. The XML parts were checked by hand with `xmllint --noout` after unpacking with libzip's `ziptool`; all well-formed.
- BLOCKED: visual review of the docx pages (no LibreOffice to render them). pages_reviewed for docx: 0.
- Not done: opening the .docx in Word for a repair-prompt check; the reference.docx was built with `ziptool` edits, not a committed build script.
- The typst montage review (60 dpi, every page in one strip) was used only to compare the typst layout with the docx styles; it is not a docx review.
