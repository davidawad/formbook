# vaeb: adversary complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Eastern District of Virginia (`vaeb`).
Folder: `courts/fourth-circuit/virginia/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-deboer-v-morris-26-03003-adversary-complaint.pdf` (1 filer, counsel for creditors; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-deboer-adversary-complaint.md`: caption, jurisdiction, parties, background, Count I (with the payments table), the first three paragraphs of Count II, the prayer, the signature block and the certificate of service. Paragraphs 36 to 55 of Count II are omitted (the exemplar is 16 pages; the sample is 9). |
| render | ok: `samples/OUTPUT-deboer-adversary-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-deboer-adversary-complaint.pdf` and `.txt` (page map below) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed on the final build; the caption was also checked at 110 dpi) |

File names follow the repo's role-prefix convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`) because `tools/render.sh` and `tools/overlay.sh` read and write those names by default. The brief's `<id>.md` / `<id>-overlay.pdf` names were not used for that reason.

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where in the template |
|---|---|---|
| E.D. Va. LBR 5005-1(C)(1) | Legible, one side of the paper. | Output is one-sided; nothing else to set. |
| E.D. Va. LBR 5005-1(C)(2) | Caption in substantial compliance with the Official Forms; the debtor's name, case number, chapter and adversary number on each document. | `debtor` (name, chapter, case number) and `adversary_number` in the caption; asserted at build. |
| E.D. Va. LBR 5005-1(C)(3) | Letter size; **top margin not less than 1 1/2 inches**; multi-page documents fastened at the top. | `page-w`, `page-h`, `top-margin = 1.5in`. |
| E.D. Va. LBR 5005-1(C)(5) | First page identifies the attorney by name, State Bar number, mailing address, telephone and the party represented. | `counsel` block, top left of page 1; asserted at build. |
| FRBP 7010; Fed. R. Civ. P. 10(a) | Adversary complaint caption must substantially conform to Official Form 416; caption has the court, title, file number and Rule 7(a) designation. | `court-title`, `caption` (parties, `v.`, Chapter, case numbers), `title`. Assert: division, parties, title. |
| Fed. R. Civ. P. 10(b) (via FRBP 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `numbered_sections` in the frontmatter names the sections whose paragraphs are numbered (automatic numbering). |
| FRBP 7008(a) | Grounds for jurisdiction; statement whether the proceeding is core or non-core. Text and Committee Note fetched from Cornell LII 2026-10-14. | Assert: a "JURISDICTION AND VENUE" heading and the word "core" in the body. |
| FRBP 7001 | Types of adversary proceedings (the exemplar cites 7001(6), dischargeability). | Content, not template. The subsection numbers in the exemplar were not re-checked in the rule text. |
| FRBP 9004(a) | Documents must be clearly legible. | Typeset output. |
| Demand for relief (Fed. R. Civ. P. 8(a)(3), applied in adversary proceedings by FRBP 7008(a); neither was re-fetched in this pass) | The complaint demands the relief sought. | Assert: a "PRAYER FOR RELIEF" heading. |
| Certificate of service | Form wording: service by electronic means through the ECF system and by mail. The exemplar's wording is reproduced. Fed. R. Civ. P. 5(d)(1)(B) was not re-fetched in this pass. | `service` frontmatter; `service-block`. Omitted if `service` is absent. |

Governing local rules: the E.D. Va. Local Bankruptcy Rules, version effective December 1, 2025 (Ver. 11/26/25), https://www.vaeb.uscourts.gov/sites/vaeb/files/LBR%20%20changes%2012-1-2025.pdf (the consolidated text, which carries LBR 5005-1(C)(3) and (C)(5) at the same wording as the July 16, 2025 text). The page is https://www.vaeb.uscourts.gov/vaeb-local-rules.

Not produced by this template (separate filings that may be required with the complaint): the Adversary Proceeding Cover Sheet (LBR 7003-1); the summons; the Rule 7007.1 disclosure statement; the proposed order (LBR 9022-1).

## Layout

- Letter size, 1.5 inch top margin, 1 inch other margins, page numbers centered at the foot.
- Font: EB Garamond 12 pt, vendored in `fonts/`. No E.D. Va. rule names a typeface (see Known gaps).
- Double spacing: 1.35 em leading (24 pt pitch at 12 pt), single spacing for the counsel block, caption, table, signature block and service list.
- Counsel block at the top left of page 1, single spaced; court name and division centered; caption as a three-column grid (parties, a column of ")" marks, bankruptcy and adversary numbers); title centered in capitals.
- Paragraphs: first-line indent 0.5 in. Numbered paragraphs (under the named sections) carry their number at the left of the indent.
- Level 1 headings: centered, bold capitals. Level 2: centered bold (the subtitle of a count). Level 3: bold italic.
- Markdown tables render with rules; lists render as (a), (b), ...
- Signature block: date at left; firm, "By: /s/" and the signer at right, counsel's lines below.
- Certificate of service: centered heading, form wording, the service list in two columns, and the signature.

## Overlay (`samples/OVERLAY-deboer-adversary-complaint.pdf`)

Red is our render, blue is the filed exemplar, black is where they agree. The overlay pairs each page with the exemplar page sharing the most words (`samples/OVERLAY-deboer-adversary-complaint.txt`):

```
ours p.1  filed p.1  word-overlap 63.6%
ours p.2  filed p.3  word-overlap 47.4%
ours p.3  filed p.4  word-overlap 50.0%
ours p.4  filed p.5  word-overlap 76.6%
ours p.5  filed p.6  word-overlap 87.4%
ours p.6  filed p.7  word-overlap 90.0%
ours p.7  filed p.8  word-overlap 76.6%
ours p.8  filed p.9  word-overlap 62.9%
ours p.9  filed p.16 word-overlap 67.3%
```

The overlay is a diagnostic, not a score. The page offset is expected: the sample has fewer paragraphs (it stops at Count II paragraph 35), so pages after page 2 are one exemplar page further on. The differences that matter are the ones the template chooses on purpose: the 1.5 inch top margin (the exemplar's text starts about 1 inch from the top, measured from the text layer's positions; the rule requires 1.5 inches) and the Times-metric typeface.

## Known gaps and open choices

1. **One exemplar.** The brief asks for one exemplar per doc type. EVAL-LOOP's tier-2 rule asks for two or three filers, so tier 2 is not judged against two filers here. Other candidates found in the CourtListener RECAP search (E.D. Va. bankruptcy, 2026): *David Jung v. Nelnet* (26-03013, Doc 1, counsel Krumbein) is only 3 pages and is a short-form complaint; *Amaryllis, Inc. v. Adler* (26-01015) and *Keuthan v. Keuthan* (26-01010) were listed but not downloaded.
2. **Typeface.** The exemplar's body is an embedded CID TrueType face (name not in the text layer), with non-embedded Times-Bold and Times-Italic elsewhere, so it is taken to be a Times-style serif. No Times face is vendored, and the brief forbids system fonts, so the template uses EB Garamond. EB Garamond at 12 pt has a smaller x-height than Times at 12 pt; the text looks smaller than the exemplar. The 12 pt minimum is met.
3. **Counsel position.** Both exemplars put the counsel block at the foot of page 1. The template puts it at the top left, which LBR 5005-1(C)(5) allows ("on the first page"). Recorded as ACCEPTED (tier-2 convention, both are common in E.D. Va. filings).
4. **Top margin.** The rule requires 1.5 inches (LBR 5005-1(C)(3)). The exemplar's body text starts about 1 inch from the top, so the exemplar does not meet the rule as written, or the court's ECF header is read as part of the top margin. The template follows the rule. Recorded as OPEN for David: confirm whether the 1.5-inch rule applies to the body text or the whole page.
5. **Caption.** The Form 416 layout is reproduced from the exemplar's arrangement and the rule's content, not from the text of Official Form 416A/B (not fetched in this pass). The blank adversary number is printed as a line (the exemplar has "Case No. ____").
6. **Italics.** The exemplar's text layer has no italic markup, so the sample's case-name italics are the transcriber's, not the filing's.
7. **Transcription.** The sample is a portion of the filing (see the table above). The omitted paragraphs are recorded in the sample's frontmatter (`transcription`), not in the body, so the render shows no gap marker.
8. **Paragraph numbers.** The template numbers paragraphs 1 to 35 in the sample; the exemplar's numbers are the same for these paragraphs.
9. **Page 4.** The page ends with white space of about three lines because paragraph 19 moves to the next page as a whole. This is typesetting, not a rule. Not changed.

## Review of the rendered pages (final build, 9 pages)

- Page 1: counsel block (top left, single spaced), court name and division, caption grid with the ")" column and the adversary "Case No." line, title, the first paragraph and paragraph 1. Pass.
- Page 2: paragraphs 2 to 8; JURISDICTION AND VENUE, PARTIES and BACKGROUND headings centered; the paragraph numbers sit at the indent. Pass.
- Page 3: paragraphs 9 to 14, all double spaced, no overlap. Pass.
- Page 4: paragraphs 15 to 18. Pass (see gap 9).
- Page 5: paragraphs 19 to 24; COUNT I heading with its bold centered subtitle, which wraps to two lines. Pass.
- Page 6: paragraphs 24 to 28, the lead-in to the payments table. Pass.
- Page 7: the payments table (rules, two columns, the Total row), paragraphs 29 to 32. Pass.
- Page 8: COUNT II heading and subtitle (the section sign is kept with its number, "§ 523(a)(2)(A)"); paragraphs 33 to 35; PRAYER FOR RELIEF; the start of the prayer. Pass.
- Page 9: the prayer's end; date and signature block (firm, "By: /s/", signer, address, counsel line); CERTIFICATE OF SERVICE with the form wording and the service list in two columns; the certificate's signature. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).
