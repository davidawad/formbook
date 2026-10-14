# scb (D.S.C. Bankruptcy): adversary-complaint

Doc type: **complaint in an adversary proceeding** (Fed. R. Bankr. P. 7001), United States Bankruptcy Court for the District of South Carolina (`scb`).
Folder: `courts/fourth-circuit/south-carolina/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-joye-25-80012-adversary-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-haigler-joye.md`: the whole 9-page filing transcribed (caption, jurisdiction, 50 numbered allegations, three causes of action, prayer, signature) |
| render | ok: `samples/OUTPUT-haigler-joye.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`sh tools/render.sh <this-dir> samples/INPUT-haigler-joye.md`) |
| overlay | ok: `samples/OVERLAY-haigler-joye.pdf` and `samples/OVERLAY-haigler-joye.txt` (`sh tools/overlay.sh <this-dir> haigler-joye`) |
| typeface | face required: **none** (the FRBP cited below and the SC LBR name no typeface; the exemplar's Times New Roman is a filer's choice, which the rules do not require). Vendored substitute: **EB Garamond** (kept, no court face). Fit: n/a. Re-checked 2026-10-14 in the fonts pass: `pdffonts` shows only EB Garamond embedded. The SC LBR PDF could not be read through WebFetch that day, so its no-typeface reading rests on the earlier 2026-10-14 fetch recorded in the Governing rules table below, not on a re-read. |
| pages reviewed | 8 of 8 (every page rasterized at 60 dpi and viewed after the last template change; re-viewed 2026-10-14 in the fonts pass) |

File names: the brief asked for `samples/<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. The sample is `<id>.md` as asked. The render and overlay use the names `tools/render.sh` and `tools/overlay.sh` write (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf`/`.txt`); `overlay.sh` reads `OUTPUT-<id>.pdf` by name and cannot be pointed elsewhere.

## Governing rules

Sources were fetched 2026-10-14. Rule text is from the sources listed; the rule number and date are the verification record.

| Rule | Requirement | Where it lives |
|---|---|---|
| Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010, fetched 2026-10-14) | Fed. R. Civ. P. 10 applies to a complaint in an adversary proceeding, except that the caption must substantially conform to the adversary-complaint version of Official Form 416. | Cover: `court-title`, `caption` (bankruptcy block, adversary parties, case number, adversary number, title). The Form 416 text itself was not fetched; the caption follows the exemplar. |
| Fed. R. Civ. P. 10(a)-(b), applied by Rule 7010 | Caption with court, title, file number and designation; claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | Allegations are numbered by the template (`allegations`); headings, quotations and the prayer are not. Text of Rule 10 was not separately fetched. |
| Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008, fetched 2026-10-14) | Jurisdiction allegation must reference the case's name, number and chapter, and the district and division; the complaint must state whether the pleader consents to final orders by the bankruptcy court. | Author content (the sample's paragraphs 1 and 2). The template does not check the wording. |
| Fed. R. Bankr. P. 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14) | (a) legible. (b) caption with (1) court's name, (2) case title, (3) case number and adversary number, (4) brief designation of the document. | Cover. Items 1-4 come from the frontmatter (`court`, `bankruptcy`, `caption`, `adversary_number`, `title`). |
| Fed. R. Bankr. P. 9037(a) (https://www.law.cornell.edu/rules/frbp/rule_9037, fetched 2026-10-14) | Redaction: last four digits of an SSN or taxpayer number, the birth year only, a minor's initials, the last four digits of a financial-account number. | Author content. The sample shows "account ending in 0097" (last four digits, as the filing has it). The template does not check redaction. |
| SC LBR 9011-4 (https://www.scb.uscourts.gov/pdf/Local_Rules/2026LocalRulesAugAmendments.pdf, fetched 2026-10-14) | Signature shown as "/s/" or "s/" and the signer's typed name; each signer's name, address, telephone, email address, and U.S.D.C. ID number (where applicable). | Signature block: `signature` frontmatter. **Gap:** the filed exemplar has no email address (see Known gaps). |
| SC LBR 7001-1 and 9013-1 | Not used by this doc type. 9013-1 applies to motions "other than adversary proceedings". | |

Not generated (separate filings, outside this template): the Adversary Proceeding Cover Sheet (the docket shows it as Attachment 1 to a complaint filing), the summons, and any disclosure statement the filer must file with the complaint.

## Layout

- Page: US Letter, 1-inch margins on all sides, page number centered at the foot. No pleading-paper line numbers: no SC bankruptcy rule requires them (the exemplar has none).
- Court title centered, two lines (the second bold), as the exemplar.
- Caption (Official Form 416 layout as the exemplar uses it): left column with "In re:", debtor, "Debtor." (right-aligned) and a closing rule; the adversary parties ("Plaintiff," / "v." / "Defendant.") in the same column, closed by a rule. Right column: case number, chapter, adversary number, and the title in bold.
- Body: double spacing. Body lines sit 24.0 pt apart (`body-leading` 0.54em at 13 pt; checked with `pdftotext -bbox-layout`, where a number and its text are separate boxes on one baseline). Headings and the quotation are spaced on their own.
- Allegations: number at the margin, a 0.5 inch gap, wrapped lines flush left (as the exemplar). Headings `##` are centered and bold. Block quotations (`>`) are single-spaced and indented 0.5 inch on both sides.
- Continuation paragraphs after a quotation or list, and a lead-in paragraph before a list ("WHEREFORE ... for:"), are not numbered.
- The prayer list is lettered (a.), (b.), ...; the last two chunks (the prayer's lead-in and list) stay on one page with the signature block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `court` (list of lines), `bankruptcy` (`debtor` lines, `case_number`, `chapter`), `caption.parties` (list of `{names, designation}`; "v." between parties is inserted by the template), `adversary_number` (the blank is written as underscores, as on the filed copy), `title`, `lead_in` (optional, the unnumbered opening paragraph), `signature` (`date`, `signer`, `lines`, `role`).
- Body: blank-line-separated chunks. `##` heading (centered bold). Paragraph = a numbered allegation, unless it follows a quotation or list or leads into a list. `>` block quotation. A numbered markdown list is the prayer, lettered by the template.
- Do not type numbers in front of allegations; the template numbers them. Keep a list tight (no blank line between its items), or each item becomes its own chunk.
- Italic case names with `*...*`.

## Known gaps and open choices

1. **One exemplar only.** The second filer found (*Fort, Trustee v. Kauffman Precast, LLC*, Adv. No. 18-80024-hb, 6 pp., 2018, Roe Cassidy) is recorded in `exemplars/SOURCE.md`, not saved. Tier-2 comparison against two or three filers is therefore **not** done.
2. **Typeface and size.** Neither the FRBP nor the SC LBR names a typeface or size. The exemplar is Times New Roman. The template uses EB Garamond (the only vendored font) at 13 pt, because EB Garamond sets smaller than Times at the same size (the same choice as the CAND motion template). Whether the court's judges want a larger apparent size is a choice for David.
3. **ECF header not reproduced.** The "Case 25-80012-eg Doc 1 Filed ... Page N of 9" line is added by CM/ECF on filing and is not part of the document.
4. **Email address missing from the signature (SC LBR 9011-4).** The exemplar's signature block has no email address, and the rule requires one. The template prints only the lines given in the frontmatter, so the transcription keeps the exemplar's omission. A filing needs the email added to `signature.lines`.
5. **Signature date.** The exemplar prints "Dated: March 4, 2025" under the block. The template does the same.
6. **Caption rule for Official Form 416.** The caption follows the exemplar. The Form 416 text was not fetched; a check against the form is an open item.
7. **Judge's standing orders** can change the form. Not reflected.
8. **Redaction (FRBP 9037(a))** is author content; the template does not check it.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and `tools/` was not to be edited. Render and overlay were run; the review above is the page-by-page check for this doc type.
10. **Typos in the filed text are kept**, for example "FOR A FOUTH CAUSE OF ACTION". The transcription keeps the filing's words.

## Review of the rendered pages (current PDF, 60 dpi)

- Page 1: court title, caption (both blocks, rules closing each), lead-in, heading "JURISDICTION AND VENUE", paragraphs 1-3. Pass.
- Page 2: "FACTUAL ALLEGATIONS", paragraphs 4-16, heading "FOR A FIRST CAUSE OF ACTION" with its parenthetical. Pass.
- Page 3: the quoted 11 U.S.C. § 547(b) (items (1)-(5), sub-items (a)-(c)), its unnumbered citation, paragraphs 17-21. Pass.
- Page 4: paragraphs 22-27, second cause of action. Pass.
- Page 5: paragraphs 28-35, third cause of action. Pass.
- Page 6: paragraphs 36-42, fourth cause of action heading, the quotation of S.C. Code § 27-23-10 and its unnumbered continuation. Pass.
- Page 7: quotation from *Windsor Props.*, its unnumbered citation in italics, paragraphs 43-50. Pass.
- Page 8: "WHEREFORE" lead-in, prayer (a.)-(d.), signature block (/s/ and the signer's details), "Dated" line. Pass.

Numbering check: `pdftotext` on the render gives allegations 1 through 50 in order, none missing or repeated (verified after the final template change).

Gate 2 rows: the review above. There is no `reviews/` folder for this doc type.

## Reproduce

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/fourth-circuit/south-carolina/federal/bankruptcy-district/adversary-complaint samples/INPUT-haigler-joye.md
sh tools/overlay.sh courts/fourth-circuit/south-carolina/federal/bankruptcy-district/adversary-complaint haigler-joye
```

[Formbook index](../../../../../../README.md) | [Court README](../README.md)
