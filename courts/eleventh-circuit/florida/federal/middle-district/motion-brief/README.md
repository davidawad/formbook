# flmd: motion-brief (motion to dismiss with memorandum)

Doc type: **motion with legal memorandum** (Fed. R. Civ. P. 12(b)(6), 12(c); M.D. Fla. Local Rules 1.08 and 3.01) in the United States District Court for the Middle District of Florida (`flmd`).
Folder: `courts/eleventh-circuit/florida/federal/middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-phillip-8-26-cv-02634-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-phillip-motion-to-dismiss.md` (a portion of the 19-page filing; see "Excerpt") |
| typeface | **BLOCKED: no permitted typeface is vendored.** Stand-in EB Garamond at 14 pt. See "Typeface" in `complaint/README.md`, which applies here too. |
| render | ok: `samples/OUTPUT-phillip-motion-to-dismiss.pdf`, 13 pages, typst 0.15.0, no warnings, vendored font only |
| overlay | ok: `samples/OVERLAY-phillip-motion-to-dismiss.pdf` and `OVERLAY-phillip-motion-to-dismiss.txt` |
| pages reviewed | 13 of 13 (every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| M.D. Fla. Local Rule 1.08(a) | 8½ × 11 paper; 1-inch margins; bottom-center page numbers (none needed on page one); main text at least 13-point, 2.0 double-spaced; indented quotations at least 12-point single-spaced; footnotes at least 11-point single-spaced; permitted typefaces (Book Antiqua, Calisto MT, Century Schoolbook, Georgia, Palatino). | `page-margin`, footer in `flmd-motion-brief()`, `type-size`, `body-leading`, `show quote`. Typeface: BLOCKED (see above). |
| M.D. Fla. Local Rule 1.08(b) | Times New Roman at 14-point main text, 13-point indented quotations, 12-point footnotes. | `type-size = 14pt`. |
| M.D. Fla. Local Rule 3.01(b) | A motion includes, in a single document no longer than twenty-five pages, a concise statement of the precise relief requested, the basis, and a legal memorandum. | Not checked by the template (see gap 3). |
| M.D. Fla. Local Rule 3.01(a) | Page limits exclude the caption, the signature block, any certificate of conferral or service, and any verification or attachment. | Relevant to the 25-page count; not computed. |
| M.D. Fla. Local Rule 3.01(g) | Duty to confer before filing a motion, except for a Rule 11 sanction, injunctive relief, judgment on the pleadings, summary judgment, or class certification. A Rule 12(b)(6) motion to dismiss is **not** exempt. The certificate goes under the heading "Local Rule 3.01(g) Certificate" at the end of the motion. | Sample body: the certificate precedes the signature block. |
| M.D. Fla. Local Rule 3.01(d) | A response to a motion to dismiss is due within 21 days after service. | Not in the document; recorded for the clerk's reference. |
| Fed. R. Civ. P. 7(b)(1) | A request for a court order must be made by motion, stating with particularity the grounds and the relief sought. | Sample lead-in ("move to dismiss ... Defendants state:"). |
| Fed. R. Civ. P. 10(a) | Caption with court, title, file number, Rule 7(a) designation. | `cover()`. |
| Fed. R. Civ. P. 11(a) | Paper signed by counsel of record. | `signature-block()`. |

Sources: Local Rule 1.08 and 3.01 text from the court's amended local rules effective 2025-11-01, https://www.flmd.uscourts.gov/sites/flmd/files/flmd-amended-local-rules-effective-november-01-2025.pdf (rule page https://www.flmd.uscourts.gov/local-rules/rule-108-form-pleading-motion-or-other-paper), read 2026-10-14. Rules 7, 8, 10 and 12 from https://www.law.cornell.edu/rules/frcp/rule_7 etc., fetched 2026-10-14.

## Layout

- Court title single-spaced; caption (parties with closing rule; `CASE NO.:` with judge initials on the right); title centered bold; the Rule 12 lead-in paragraph with indent.
- Body double-spaced (2.0 em baseline pitch), 14-point EB Garamond, 1-inch margins, first-line indent on paragraphs. Body paragraphs are **not** numbered (memoranda are not pleadings under Rule 10(b)).
- Headings: level 1 centered bold (write caps in the sample); level 2 centered bold; level 3 bold, left; level 4 bold italic, left.
- Signature block (after the 3.01(g) certificate): "Respectfully submitted," firm, each counsel's `s/` line and details, address, "Attorneys for Defendants". Kept as one unbreakable block.
- Certificate of service: the sample's `# CERTIFICATE OF SERVICE` and everything after it are printed after the signature block as one unbreakable block.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `case_number` (with judge initials), `division`, `caption.versus`, `caption.parties`, `brief_title`, `footer_title` (not used by this template), `lead_in`, `signature` (`firm`, `counsel` as a list of line-lists, `address`, `for`).
- Body: blank-line-separated chunks. `#` heading (level 1 to 4); a list; a `~ ` chunk is an unindented paragraph (certificate lines); any other text is a body paragraph with indent.
- A backslash at the end of a line is a hard line break inside a `~` chunk (used for "s/Jonathan Kepko" over "Attorney").
- Not supported: footnotes (the exemplar has two; they are not transcribed), tables, raw typst.

## Typeface: BLOCKED

See `complaint/README.md`, "Typeface: BLOCKED". The stand-in is not a Rule 1.08 face; this render is a layout check only.

## Known gaps and open choices

1. **One exemplar.** The CourtListener search (`type=r`, `court=flmd`, query "motion to dismiss" "memorandum", filings from 2026) returned mostly Warden-as-party motions in habeas petitions, which are not motions to dismiss a complaint with a memorandum. Phillip was the only candidate whose RECAP PDF was stored and opened. A second filer was not collected, so tier 2 is not judged against two filers yet.
2. **Excerpt.** The sample transcribes pages 1 to 12 of the filing and the signature and certificate pages, omitting Section III (Request for Judicial Notice) and Section IV.a.ii.D to F (NIED, negligence per se, medical monitoring, FDUPTA). Omissions are marked in the sample with an italic note. The full filing is 19 pages.
3. **25-page limit.** Not computed by the template. The filing's text pages fall under 25; the sample is not the whole brief, so the limit is not tested here.
4. **Footnotes.** Not supported by the markdown contract. The exemplar's footnotes 1 and 2 are omitted.
5. **Level-3 headings.** Long argument headings wrap without a hanging indent. The exemplar's own wrap is not reproduced; cosmetic.
6. **Case names not italic.** The exemplar's text layer has no italic markup; the sample is roman. The template italicizes `*...*` markdown if a sample uses it.
7. **Overlay file names.** See the complaint README, gap 6.
8. **Gates not run.** See the complaint README, gap 7.
9. **Exemplar typos preserved.** The sample reproduces the filing's text, including its "Per to Local Rule 3.01(g)", "Section III. CONCLUSION" after "IV. ARGUMENT", and "failed to identified". They are the filer's, not ours; the sample is a transcription.
10. **Overlay pairing.** Pages are paired by shared words, and the excerpt skips filed pages, so pairs are loose: word overlap is 39 to 47 percent on sample pages 4, 9 and 12 (paired with filed pages 7, 16 and 19). Read the overlay as a diagnostic; the cause of each low pairing was not traced further.

## Review of the rendered pages (current PDF, 60 dpi)

- Page 1: caption, title, Rule 12 lead-in. Pass.
- Page 2: MEMORANDUM OF LAW, I. INTRODUCTION, body with indent, II. LEGAL STANDARD heading kept with its paragraph. Pass.
- Page 3: legal standard continued; no orphaned heading. Pass.
- Page 4: omission note (italic), IV. ARGUMENT, heading a. (bold, wraps to four lines), i. heading kept with paragraph. Pass.
- Page 5: argument i., case quotations. Pass.
- Page 6: argument i. continued. Pass.
- Page 7: argument i. continued. Pass.
- Page 8: heading ii., A. and B. headings. Pass.
- Page 9: C. and b. headings; sub-heading b. wraps. Pass.
- Page 10: b. continued; c. heading. Pass.
- Page 11: c. continued; III. CONCLUSION; LOCAL RULE 3.01(g) CERTIFICATE; "Respectfully submitted," at the foot. Pass (the signature block moved to page 12 whole).
- Page 12: signature block (both counsel, address, "Attorneys for Defendants"). Pass. Page is mostly blank below, by design: the certificate is one unbreakable block.
- Page 13: CERTIFICATE OF SERVICE, served list, `s/Jonathan Kepko` and "Attorney" together. Pass.
