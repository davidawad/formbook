# Adversary complaint: United States Bankruptcy Court, D. Puerto Rico (`prb`)

Doc type: complaint commencing an adversary proceeding (FRBP 7001, 7003) in the United States Bankruptcy Court for the District of Puerto Rico. Templated: the caption, the title, numbered paragraphs, headings, lettered prayer items, and the signature block. Not templated: the B1040 cover sheet and the summons (separate filings, see below).

## Rules

Local rules text is from the court's "Local Bankruptcy Rules" compilation (PRLBRs-2013, https://www.prb.uscourts.gov/sites/default/files/local_rules/PRLBRs-2013_Complete_0.pdf, fetched 2026-10-14; the copy fetched is the 2013 compilation as posted with a 2019 PDF date, so later amendments may not be reflected; not verified against the court's current web version). Federal rule text is from Cornell LII (fetched 2026-10-14).

| Rule | Requirement | Where in the template |
|---|---|---|
| FRBP 7010 (as amended Apr. 2, 2024, eff. Dec. 1, 2024; https://www.law.cornell.edu/rules/frbp/rule_7010) | FRCP 10 applies in an adversary proceeding, but the caption must substantially conform to the appropriate Official Form 416 version (416A for a complaint). | `caption()` and `cover()`: court name, debtor, parties, title, adversary number. |
| FRCP 10(a) (https://www.law.cornell.edu/rules/frcp/rule_10) | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation. | `cover()`: the title names the complaint; the caption carries the court, the case and the adversary number. |
| FRCP 10(b) | A party states its claims in numbered paragraphs, each covering one set of circumstances where practical. | `body-chunks()`: each body paragraph is numbered; headings and the prayer list are not. |
| FRBP 9004(b) (as amended Apr. 2, 2024, eff. Dec. 1, 2024; https://www.law.cornell.edu/rules/frbp/rule_9004) | A document's caption sets out the court's name, the case title, the case number and, if appropriate, the adversary number, and a brief designation of the document's character. | `caption()`: `bankruptcy_case`, `adversary`; the title is the designation. |
| LBR 1005-1(a) (2013 compilation) | The bankruptcy case name, number, judge's initials and chapter appear on all documents filed electronically or with the clerk. | `caption()`: `bankruptcy_case` (the judge's initials are in the number, "19-01789 (ESL)") and `chapter` are asserted present. |
| LBR 1005-1(b) | Every document is a pdf measuring 8 1/2 x 11 inches in a legible orientation; resolution at most 300 dpi. | `page-w`, `page-h`: US Letter. The 300 dpi limit applies to scans; the template's output is vector. |
| LBR 1005-1(c) | Each paper's signature block gives the name, mailing address, email address, telephone and facsimile numbers of the filer; for an attorney, the firm name, the client's name and the bar admission number. | `signature-block()`: `signature.signer` (printed `/s/`), `signature.lines`; asserted present. See gap 2. |
| LBR 5005-4(b)(2)(C)(ii) | An electronic signature is the filer's name preceded by "/s/". | `signature-block()`: prints `/s/ ` before the signer's name. |
| LBR 7003-1 | With the complaint, counsel files the AO Form B 1040 cover sheet. | Not templated (a separate filing; see gap 5). |
| LBR 7004-2 | The clerk issues a summons on the LBF D form; it is not part of the complaint. | Not templated (a separate filing). |
| Typeface (fonts pass, 2026-10-14) | Face required: **none named** in the PR bankruptcy LBRs (2013 compilation, PRLBRs-2013, and the LBR 1005-1 text checked by search; no typeface or size clause found). LBR 1001-1(b) falls back to the District Court's local civil rules for matters not covered; their Local Rule 10 text was not retrieved, so this is OPEN. Vendored substitute: **none needed**; keeps **EB Garamond** (`docs/FONTS.md`, "No face named"). Metric fit: n/a. | `font-family` in `prb-adversary-complaint.typ`. |

## What the overlay shows

`usage/OVERLAY-organic-power-complaint.pdf` (red: our render; blue: the filed exemplar; black: both agree) and `.txt` (page map). The exemplar is the full 96-page RECAP PDF; the overlay pairs each of our 8 pages to the exemplar page with the most shared words:

- ours p.1-5 -> filed p.4, 5, 7, 9, 11 (intro, parties, jurisdiction, facts start);
- ours p.6-8 -> filed p.24, 25, 26 (prayer and signature).

The filed pages between 11 and 24 (the body that holds Counts II and III) are not transcribed. The overlay therefore shows blue-only regions where those pages would pair, which is the sample's gap, not a template defect. Page layout differs (the filing's line pitch and its ECF header differ from ours), so the overlay is a text-content comparison, not a layout check.

## Known gaps

1. **Transcription is condensed.** `usage/INPUT-prb-adversary-complaint-organicpowercomplaint.md` jumps from "V. Count I" to "VIII. Count IV" (the Roman numerals skip VI and VII), so Counts II and III and their headings are missing. It is a partial transcription, not the full complaint. Completing it would add about 12 exemplar pages. Not done in this pass: the sample was kept as the brief asked (not broken, renders, all required structure present).
2. **Signature block (LBR 1005-1(c)).** The rule asks for the client's name and the filer's facsimile number. The sample's block reads "Counsel for Plaintiff" (client not named) and has no fax number. The filed exemplar's block is the same, so the sample reproduces it. Whether to add "Organic Power, LLC" and a fax line is for David to decide; the template prints the lines it is given.
3. **Second exemplar not collected.** `usage/SOURCE.md` records that the only other bankruptcy-court adversary complaints found were scanned images (20-00027) or a pro se upload (23-03241, entry 115). Tier 2 (conventions) is therefore judged against one filer only. This is OPEN.
4. **Typeface.** No PR bankruptcy rule sets a typeface or size. The template uses EB Garamond 12 pt (the only serif in `fonts/`, and the convention both exemplars follow at 12 pt). The exemplar's text is Times New Roman (embedded, per `usage/SOURCE.md`); EB Garamond at the same point size reads smaller, so the render is not a face match.
5. **Cover sheet and summons** (LBR 7003-1, 7004-2) are separate documents and are not generated.
6. **Paragraph numbering** restarts for each complaint and is continuous across headings (as in the exemplar); a complaint with amendments is a separate document under LBR 1005-1(d), which requires the word "AMENDMENT" in bold. Not templated; the title field is the place to put it.

## Gate 2 review

- Page 1: caption (court, debtor, parties, case number, chapter, adversary blank), title, "COME NOW" lead-in, paragraphs 1-3 start. Pass.
- Pages 2-8 (our render): headings, numbered paragraphs, Count I and Count IV headings, prayer letters A-F, signature block on page 8 with "Respectfully submitted" and the date. Pass as layout. OPEN on content: the missing Counts II and III (gap 1), and the signature-block lines (gap 2).
- All 8 pages were rasterized and viewed (render and overlay).

## Engines

docx: `docx/build-reference.sh` builds `docx/reference.docx` (EB Garamond 12 pt, exact 24 pt double pitch, 13.8 pt single lines, 0.5 in first-line indent, 1 in margins, PAGE field in the footer); `docx/prb-complaint.lua` builds the caption table, the numbered paragraphs, the lettered prayer and the signature block from the frontmatter. Checked on `usage/OUTPUT-prb-adversary-complaint-organicpowercomplaint.docx.pdf` (LibreOffice). Opened with LibreOffice only; Word was not checked.

Matches the typst form (measured on the PDFs): US Letter, one-inch margins, EB Garamond 12 pt, body line pitch 24.0 pt and single-line pitch 13.8 pt in both, 8 pages in both, caption, title and lead-in positions within about 1 pt, numbers then a tab at 1 in, lettered prayer, footer page number, `/s/` signature block.

Differs:
- LibreOffice breaks some lines at other words than typst (glyph advance and no justification), so the same text falls on a different line on most pages; the page count is the same.
- The typst signature block stands alone on page 8; the docx keeps "Respectfully submitted" with prayer items E and F on page 8 (keep-with-next), so page 8 is laid out differently on purpose.
- Prayer items have a 16 pt gap after each item in both; the docx spacing reads slightly looser.

BLOCKED: none.
