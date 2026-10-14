# D.R.I. Bankruptcy Court (rib): adversary complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding; FRBP 7008 pleading). Court: United States Bankruptcy Court, District of Rhode Island. Folder: `courts/first-circuit/rhode-island/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, two filers: `exemplars/FILED-EXAMPLE-pisaturo-sunflower-19-ap-01020-adversary-complaint.pdf` (Chapter 7 trustee, 11 pages) and `exemplars/FILED-EXAMPLE-ustrustee-ziegelmayer-18-ap-01066-adversary-complaint.pdf` (U.S. Trustee, 9 pages). Provenance in `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-pisaturo-sunflower.md` (full transcription, 66 paragraphs, both counts, prayer, signature); `samples/INPUT-ustrustee-ziegelmayer.md` (full transcription, 71 paragraphs, one count, prayer, signature; deposition excerpts absent from the exemplar's text layer are placeholders) |
| render | ok: `samples/OUTPUT-pisaturo-sunflower.pdf` (9 pages), `samples/OUTPUT-ustrustee-ziegelmayer.pdf` (7 pages). typst 0.15.0, vendored EB Garamond only (`pdffonts`), no warnings. |
| overlay | ok: `samples/OVERLAY-pisaturo-sunflower.pdf` and `.txt`; `samples/OVERLAY-ustrustee-ziegelmayer.pdf` and `.txt` |
| pages reviewed | 16 of 16 (9 + 7), each rendered at 50-60 dpi and viewed after the last template change |

File names: the brief asked for `samples/<id>.md`, `<id>.pdf` and `<id>-overlay.*`. The repo's file-role convention and the tools fix the names instead: `INPUT-<id>.md` (input), `OUTPUT-<id>.pdf` (our render), `OVERLAY-<id>.pdf`/`.txt` (overlay). `tools/overlay.sh` reads `OUTPUT-<id>.pdf`, so the tool's names were kept.

## Governing rules

Primary sources. Local rules: the District of Rhode Island Bankruptcy Court's Local Bankruptcy Rules, December 1, 2024 compilation, https://www.rib.uscourts.gov/sites/default/files/general-ordes/December_1_2024_LBRs.PDF (fetched and text-extracted 2026-10-14; rule dates as printed in that compilation). National rules: FRBP 7008, from https://www.law.cornell.edu/rules/frbp/rule_7008 (amended through December 1, 2024; read 2026-10-14, paraphrased, not quoted verbatim).

| Rule | Requirement | Where in the template |
|---|---|---|
| LBR 1005-1(a) [Amended 12/1/22] | Bankruptcy case name, number and chapter on every paper, and on the signature page. | Caption (`in_re`, `chapter`, `case_number`, `adversary_number`); signature block "In re ..." line. |
| LBR 1005-1(b) | 8 1/2 x 11; text at least 11 point; footnotes at least 10 point; double spaced, except quotations and footnotes. | `type-size = 12pt`, `footnote-size = 10pt`, `body-leading = 1.35em` (24 pt pitch, measured on page 2), single-spaced quotations. |
| LBR 1005-1(c) | Filer's name, original signature, address, telephone, e-mail, firm, state bar identification number, client name. | `signature` frontmatter: `client`, `signer`, `bar_id` (required: the template prints "RI Bar No."), `firm`, `lines`. |
| LBR 1005-1(d)(1) | Response-time language on every motion. | Not applicable: a complaint is not a motion. |
| LBR 7003-1(b) and 5005-1(b) | Cover sheet in the required form (Official Form B1040) with every non-electronically filed adversary complaint. | Not generated; a separate filing (see gaps). |
| LBR 7007-1 | Papers in an adversary proceeding comply with LBR 1005-1. | As LBR 1005-1 above. |
| FRBP 7008(a) (Cornell text) | The complaint's jurisdictional allegations, and a statement whether the pleader consents to final orders or judgment by the bankruptcy court. | Author content; the template does not generate the consent statement (see gaps). |
| FRCP 10(a)-(b) as applied in adversary proceedings (text not fetched this session) | Caption with court, title and number; claims in numbered paragraphs. | Numbered paragraphs (`allegations()`), caption from frontmatter. |

Searches and what they settled: CourtListener RECAP search (`court=rib`, `type=r`, adversary dockets `-ap-`, results 2012 to 2025) and the entry-1 storage PDFs of those dockets. Two text-based complaints from different filers were kept (table in `exemplars/SOURCE.md`). Freeman v. JPMorgan (19-ap-01026, 24 pages) was skipped: its body is image-only (the text layer holds only the ECF header).

## Layout

- Court title (court-level text, `court-name`), caption grid: the bankruptcy caption ("In re", debtor, "Debtor.") above a rule, the adversary parties below it, and on the right the chapter, bankruptcy case number and adversary proceeding number. Then the title of the paper (centered bold capitals).
- Lead-in paragraphs (`lead_in`) are unnumbered, as in the exemplars.
- Body: `#` headings are centered bold capitals; `##` centered bold; `###` centered bold italic; all sticky, so a heading never ends a page. Paragraphs are numbered 1, 2, ... (not typed in the sample). A paragraph that starts with WHEREFORE is unnumbered. A `1.` list is lettered (a), (b), ...; `>` quotations are single spaced and indented.
- Signature block: "Dated", "Respectfully submitted", client and capacity, `/s/` signer, printed name, firm, bar number, address and contact lines. Kept as one unbreakable block.
- Page numbers at foot, centered, 11 point. Margins 1 inch.

## Markdown contract (for samples)

- YAML frontmatter: `in_re` (list), `debtor_designation`, `chapter`, `case_number`, `adversary_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `title`, `lead_in` (list), `date`, `signature` (`client`, `by`, `signer`, `bar_id`, `firm`, `lines`).
- Body: blank-line-separated chunks as above. Lists use `1.`; quotations use `>`. Inline italics `*...*` for case names.
- Not supported: tables, images, raw typst.

## Overlay: what it shows

`samples/OVERLAY-<id>.pdf`: red = our render, blue = the filed exemplar, black = both. `OVERLAY-<id>.txt` is the page map (our page to the exemplar page sharing the most words). The overlay is a diagnostic, not a score. The exemplars use Times, with no line numbers; our render uses EB Garamond at 24 pt pitch, so text lines will not coincide. The page map pairs pages by word overlap; a page with a low overlap (for example Pisaturo `ours p.8` to `filed p.10`) means the text pages differ in where the page breaks fall, not that text is missing.

## Known gaps and open choices

1. **Bar numbers.** Neither exemplar shows a Rhode Island bar number (the U.S. Trustee signer is a government attorney). LBR 1005-1(c) requires one. Both samples carry `bar_id: "(not shown in exemplar)"`, which prints on the rendered signature block. A real filing must replace it with the signer's number. This is a transcription artifact and is flagged, not invented.
2. **Consent statement (FRBP 7008(a)).** The exemplars (2018 and 2019) do not carry the current consent statement, and the template does not generate one. The author must write it in `lead_in` or the body.
3. **Cover sheet (LBR 5005-1(b), Official Form B1040).** Not generated. A non-electronically filed adversary complaint needs it as a separate document.
4. **Chapter on the caption.** The U.S. Trustee exemplar's caption omits the chapter, and its adversary number is blank in the caption (the docket supplies it). The template prints the chapter and the adversary number, because LBR 1005-1(a) requires them. This is a rule-driven departure from that exemplar.
5. **Deposition excerpts.** The U.S. Trustee exemplar's testimony excerpts (¶¶ 40-42) are not in its text layer. The sample carries bracketed placeholders, marked as such.
6. **Date.** The Pisaturo exemplar has no dated line. The sample's `date` is the filing date from the docket (May 21, 2019).
7. **Font and page count.** EB Garamond at 12 point (vendored); the exemplars are Times. The Pisaturo render is 9 pages against the exemplar's 11. The sample transcribes every paragraph, so the difference is layout (the exemplar's own line pitch and face), not missing text. The 8 to 14 page target is met.
8. **Numbering convention.** The WHEREFORE prayer lists are lettered (a), (b); the U.S. Trustee exemplar letters them A., B. (tier-2 difference, not a rule requirement).
9. **Tier-2 review against two exemplars.** Both are complaints from different filers, and both are used for the caption, the numbered paragraphs and the signature block. The template's signature-page case line follows LBR 1005-1(a) and is not in either exemplar.
10. **No table of contents or authorities.** Not required for a complaint under the rules above, and neither exemplar has one.
11. **Not verified verbatim:** FRBP 7008(a) (paraphrase from the Cornell text summary) and FRCP 10 (cited by rule number only).

## Review of the rendered pages (Gate 2 record)

Every page of both samples was rendered at 50-60 dpi and viewed after the last template change.

| Sample | Page | Finding |
|---|---|---|
| Pisaturo | 1 | Caption, title, lead-in, numbered 1-6, headings at body size. Pass. |
| Pisaturo | 2 | Headings with space above; lettered list (a)-(c) starts. Pass. |
| Pisaturo | 3 | List (d)-(i), numbered 16-21. Pass. |
| Pisaturo | 4 | Numbered 22-32; deposition block quote starts at the foot. Pass (quote breaks across pages, acceptable). |
| Pisaturo | 5 | Quotes of pages 32 and 35 in single spacing, numbered 33-40. Pass. |
| Pisaturo | 6 | Numbered 41-52. Pass. |
| Pisaturo | 7 | CLAIMS FOR RELIEF, COUNT I, subtitles, block quotation of § 542(a). Pass. |
| Pisaturo | 8 | COUNT II, numbered 62-66, WHEREFORE, list (a)-(c). Pass. |
| Pisaturo | 9 | List (d)-(h), signature block with case line, date and bar placeholder. Pass. |
| U.S. Trustee | 1 | Caption with chapter and adversary number on the right; lead-in; headings. Pass. |
| U.S. Trustee | 2 | FACTUAL BACKGROUND heading at top; numbered 4-15. Pass. |
| U.S. Trustee | 3 | Numbered 16-28. Pass. |
| U.S. Trustee | 4 | Numbered 29-42; placeholders for testimony excerpts. Pass. |
| U.S. Trustee | 5 | Numbered 43-56. Pass. |
| U.S. Trustee | 6 | Numbered 57-67. Pass. |
| U.S. Trustee | 7 | CLAIMS FOR RELIEF, COUNT I, numbered 68-71, WHEREFORE list, signature block. Pass. |

[Formbook index](../../../../../../README.md) | [Status table](../../../../../../STATUS.md)
