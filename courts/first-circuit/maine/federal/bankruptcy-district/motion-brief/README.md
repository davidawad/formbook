# meb: motion brief

Doc type: **motion with incorporated memorandum** (a contested-matter motion under Fed. R. Bankr. P. 9013 whose grounds and argument are set out in the same filing, with a certificate of service) in the United States Bankruptcy Court for the District of Maine (`meb`). Folder: `courts/first-circuit/maine/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: a portion of the 38-page filing (caption, introduction, facts ¶¶ 1–46, Section F, Sections IV and V, WHEREFORE, signature, certificate). Pages 10 to 33 of the filing are not transcribed; footnotes are not transcribed. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 11 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-mattson-motion-brief.pdf` and `.txt` (page map below) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed; pages 1–2 and 9–10 after their last fix) |

File names: the tools read and write `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt`, so the sample uses those names (not `<id>.md` and `<id>-overlay.pdf` as the brief's layout listed). `<id>` is `mattson-motion-brief`.

## Governing rules

Verified 2026-10-14. The local rules PDF is the December 2025 version (effective December 1, 2025).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 | A request for an order is made by written motion unless a rule authorizes an application or the request is made during a hearing. The motion states its grounds with particularity and sets forth the relief or order requested. (Paraphrase from https://www.law.cornell.edu/rules/frbp/rule_9013, fetched 2026-10-14; the page did not give the full text verbatim.) | Author content: the facts and argument, the WHEREFORE paragraph (`wherefore`). |
| Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." https://www.law.cornell.edu/rules/frbp/rule_9004 | Vendored 12 pt type, black on white. |
| D. Me. LBR 9013-1(a) | Each written motion is accompanied by a proposed form of order, which indicates whether it is issued after notice and hearing or an opportunity for a hearing; the court's posted form is used if there is one. Local rules PDF, https://www.meb.uscourts.gov/sites/meb/files/202512_USBC_Local_Rules.pdf | Not produced (a separate document; see gaps). |
| D. Me. LBR 9013-1(c)(2) | When a motion includes a separately identified statement of facts under the header "Facts", any written response must admit or deny each factual allegation under Fed. R. Civ. P. 8(b). | The sample's heading "II. Facts" is the header this rule keys on. The template does not enforce the header name; authors should know the effect. |
| D. Me. LBR 9013-1(d)(1) | A reply is limited to five pages. | Not a template matter (replies are separate papers). |
| D. Me. LBR 9013-3 | A motion filed under this local rule states, in the upper right corner of the first page, "Relief Requested Without a Hearing". | `without_hearing: true` puts the legend in the upper right corner of page 1. The sample does not use it; the exemplar does not carry the legend. |
| D. Me. LBR 7003-1(a) | In an adversary proceeding, every paper carries the main case caption, the party names, the title of the paper, and the adversary proceeding number. | `caption()`: the main case rows always; the adversary rows only when the sample has `parties` (and `adv_number`). |
| Certificate of service | The exemplar carries a certificate of service on its own page with the service list. The rule that requires it was not verified (gap 5). | `certificate` frontmatter: a page of its own, with the body, date, signature and service list. |

Also referenced by the sample, not enforced by the template: D. Me. LBR 9013-4(a)(2)(B) (expedited determination).

## Layout

- US Letter, one-inch margins; EB Garamond 12 pt (vendored, the only font in `fonts/`).
- Court name centered and bold on two lines; a bordered caption with the debtor (`In re:`, `Chapter N`, `Case No.`) in the first row. Title of the paper centered, bold, capitals.
- Opening paragraphs (`lead_in`, blank-line-separated) unnumbered, indented.
- Body double-spaced (24 pt pitch). Level-1 headings centered bold, as typed (roman numerals: I., II., ...), matching the exemplar's title case. Level-2 bold run-in (e.g. "F. Beliveau Does not Request..."); level-3 bold italic.
- Paragraphs numbered 1, 2, ... continuously through facts, argument and conclusion (first-line indent 0.5 inch).
- Closing WHEREFORE paragraph, unnumbered, kept on one page with the date and signature block (single spacing; the sample's counsel block is in the signature).
- Certificate of service on a new page: centered bold title, body, date, signature, and the service list.
- Page number centered at the foot, "- n -".

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `debtor` (`names`, `designation`), `chapter`, `case_number`, `title`, `lead_in`, `date`, `wherefore`, `signature` (`signer`, `lines`), `certificate` (`title`, `body` list, `date`, `signature`, `service` list); optional `without_hearing`, `parties`, `adv_number`.
- Body: a `#` heading (level 1), a `##` heading (level 2), a paragraph (numbered), or a list (lettered). Not supported: tables, footnotes, raw typst.

## What the overlay shows

`usage/OVERLAY-mattson-motion-brief.pdf`: red is our render, blue is the filed exemplar, black is agreement. The page map (`.txt`):

```
ours p.1   filed p.1   word-overlap 93.6%
ours p.2   filed p.2   word-overlap 68.5%
ours p.3   filed p.3   word-overlap 61.0%
ours p.4   filed p.5   word-overlap 66.6%
ours p.5   filed p.6   word-overlap 78.5%
ours p.6   filed p.7   word-overlap 59.4%
ours p.7   filed p.8   word-overlap 43.1%
ours p.8   filed p.35  word-overlap 45.8%
ours p.9   filed p.36  word-overlap 64.1%
ours p.10  filed p.37  word-overlap 67.3%
ours p.11  filed p.38  word-overlap 86.3%
```

Pages 1 to 7 pair with the filed pages that carry the same facts. Pages 8 to 11 pair with the exemplar's closing pages (35 to 38), which we transcribed. The pairing is by shared words per page, so it shows which filed page the words came from, not a page-for-page match. Our paragraph numbers run 1 to 56 where the filing's run to 147, because the omitted pages 10 to 33 removed their paragraphs (the template numbers sequentially). The overlay is a diagnostic, not a score.

## Gate 2: page review (rendered at 60 dpi, every page viewed)

| Page | Content | Result |
|---|---|---|
| 1 | Court name, caption, title, the three opening paragraphs and "In support of his Motion" | Pass. The heading "I." and ¶ 1 are kept together and moved to page 2, leaving about three lines blank at the foot. Accepted (keep-with-next). |
| 2 | "I. Constitutional Authority, Jurisdiction, and Venue" (¶ 1); "II. Facts" (¶¶ 2–11) | Pass. Headings centered bold, title case. |
| 3 | ¶¶ 12–18 | Pass. ¶ 12 carries the exemplar's parenthetical, quoted as filed. |
| 4 | ¶¶ 19–26 | Pass. |
| 5 | ¶¶ 27–34 | Pass. |
| 6 | ¶¶ 35–40 | Pass. |
| 7 | ¶¶ 41–46 (the Trustee's Position Statement quote is set as filed) | Pass. Footnote markers are removed; the footnotes are not transcribed (gap 3). |
| 8 | ¶ 47; "F. Beliveau Does not Request Any Relief under 11 U.S.C. § 324(b)"; "IV. Request for Expedited Determination" (¶¶ 48–51); "V. Conclusion" (¶¶ 52–53) | Pass. |
| 9 | ¶¶ 54–56 | Pass. The WHEREFORE paragraph moved to page 10 with the signature block (kept together). |
| 10 | WHEREFORE paragraph; "Dated: September 29, 2026"; signature block | Pass. |
| 11 | "CERTIFICATE OF SERVICE" on its own page; certificate paragraph; date and signature; service list | Pass. |

Defects found and fixed during review: (1) paragraphs in the opening block drawn over each other (several paragraphs in one measured block; now one measured block per paragraph); (2) the signature block alone on page 10 (the WHEREFORE paragraph now stays with it); (3) headings uppercased, unlike the exemplar's title-case headings (the motion's level-1 headings are title case as typed); (4) the sample's YAML was broken by unindented paragraphs in the opening block (fixed); (5) a transcription error in ¶ 12 (the parenthetical was paraphrased; now quoted as filed); (6) the sample ended a paragraph where page 9 of the exemplar ends, so the paragraph is dropped rather than completed from memory.

## Known gaps and open choices

1. **One exemplar, and it is a motion with an incorporated memorandum, not a separate memorandum.** The filing has its own statement of facts and argument (Sections I to V). A separate memorandum in support, with a motion of its own, is a different layout that this template does not cover; that exemplar was not found in the search. Tier 2 is **not** judged against two filers.
2. **Typeface.** As in the complaint: no Maine local rule on typeface was found; EB Garamond 12 pt is used because it is the only vendored font. Question for David.
3. **Partial transcription.** The sample omits the filing's pages 10 to 33 (Sections III.A to III.E) and every footnote (the exemplar has four). The sample's paragraph numbers therefore do not match the filing's after ¶ 46. The render is the review of this sample only.
4. **Proposed order.** D. Me. LBR 9013-1(a) requires a proposed form of order with the motion; the exemplar's certificate lists a "proposed Order" among the papers served. The template does not produce an order. Separate document.
5. **Certificate of service.** The template produces the page the exemplar has, but the service rule it certifies (Fed. R. Bankr. P. 9014 and 7004/7005 service) was not verified against the rule text in this pass; the certificate's wording is the exemplar's. Open.
6. **Page limits.** No page limit for a motion or memorandum was found in the December 2025 local rules (the only page limits are the five-page reply under LBR 9013-1(d)(1) and five pages for discovery memoranda under LBR 7026-1(b)(2)). The template does not count pages. Not checked.
7. **Relief without a hearing.** The legend (LBR 9013-3) appears only when the sample sets `without_hearing: true`; the template does not decide which motions qualify (that is LBR 9013-3's list).
8. **Hearing date.** The exemplar states its hearing date in the text (the expedited request, ¶ 143), not in the caption; the template has no hearing line. Not a gap in the rules as read.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids editing `tools/`. The gates were not run. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Engines

Typst is the primary engine. This section covers the docx engine (`docx/`): pandoc 3.6.4 with `docx/reference.docx` (the page setup and styles; rebuild with `sh docx/make-reference.sh docx`) and the Lua filter `docx/meb-motion-brief.lua` (the cover, caption, numbered paragraphs, relief, signature and certificate of service). Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md`.

| Output | Result |
|---|---|
| `usage/OUTPUT-motion-brief.docx` | written; zip and well-formed XML parts pass the `render-docx.sh` integrity check |
| `usage/OUTPUT-mattson-motion-brief.docx.pdf` | **not produced**: LibreOffice does not start in the build environment (see BLOCKED below) |
| pages reviewed in the docx PDF | 0 of 11 (there is no PDF to render; the typst pages are the reference) |

**What matches typst** (the same values, set in the reference styles): US Letter with 1 in margins; EB Garamond 12 pt; body lines exactly 24 pt (double spacing); first-line indent 0.5 in; paragraphs numbered 1 to 56 as typed text with a tab (as the typst template does); a list lettered (a), (b) with a hanging indent; the caption as a table with the right and bottom rules of the typst box; the "Relief Requested Without a Hearing" legend when the sample sets it; the title in capitals; level-1 headings centred and kept as typed; the WHEREFORE paragraph and the signature block kept together; the certificate of service on its own page with its service list; the footer "- n -" from a PAGE field.

**What differs, or is not verified:**

- Line and page breaks are Word's, not measured, so the page count may not be typst's 11.
- Heading spacing is approximated: typst rounds each heading block to whole 24 pt lines, Word uses 12 pt before and after.
- The caption, signature and certificate fields are set as plain text, so markdown emphasis in them is dropped (the body keeps it).
- The docx names "EB Garamond" and does not embed it. The font must be installed on the machine that opens the file, or Word substitutes silently.
- Footnotes are not transcribed in the sample; footnote text inherits 12 pt single spacing from Normal, not checked.

**docx BLOCKED items** (the docx checks run on `usage/OUTPUT-mattson-motion-brief.docx.pdf`):

- `BLOCKED: Gate 0 and Gate 1 (tools/check.sh --engine docx)`: no `.docx.pdf` exists, so the page count, the font names and the content gates cannot run. Cause: LibreOffice 25.2 (Debian trixie packages, unpacked without root) stops at bootstrap with a `DeploymentException`, even for `soffice --version`.
- `BLOCKED: Gate 2 (page review of the docx PDF)`: no pages reviewed, for the same reason.
- `BLOCKED: opens in LibreOffice and Word without a repair prompt`: not verified; there is no LibreOffice to open it in.

[Court index](../README.md) | [Formbook index](../../../../../../README.md)
