# Bankruptcy Appellate Panel of the Ninth Circuit: appellant's opening brief (bap9)

- Court: `bap9` (United States Bankruptcy Appellate Panel of the Ninth Circuit), folder `courts/ninth-circuit/bankruptcy-appellate-panel/opening-brief/`
- Template: `typst/bap9-opening-brief.typ` (entry `typst/main.typ`)
- Exemplar: `exemplars/FILED-EXAMPLE-meridian-SC-16-1227-opening-brief.pdf` (see `exemplars/SOURCE.md`)
- Sample: `samples/INPUT-meridian-opening-brief.md`, a transcription of the exemplar, rendered to `samples/OUTPUT-meridian-opening-brief.pdf`; overlay `samples/OVERLAY-meridian-opening-brief.pdf` and `.txt`
- Status of this doc type:
  - **Exemplar found.** `County of Imperial Treasurer-Tax Collector v. Stadtmueller (In re RW Meridian LLC)`, BAP No. SC-16-1227, appellant's opening brief dated and filed October 7, 2016. It is a scan (200 ppi JBIG2 images) with an invisible OCR text layer, not a born-digital PDF; the overlay pairs pages by that OCR text, and the OCR has errors (see the sample's header comment).
  - The sample is a transcription (cover, tables, a substantial run of body, signature, certificates). It is abridged: 14 rendered pages, the filer's 41-page brief is not transcribed in full. Omitted: the Argument after § A.1 (sub-parts 2-9), footnotes 2-3, the Summary's paragraph on the sale date, the Procedural History's June 2016 supplemental-briefing and hearing sentences, and the service list.
  - The template is built from the rules and tested against this exemplar; see "Template changes from the overlay" below.

Summary line for the PM: `exemplar=yes render=ok overlay=ok pages_reviewed=14`

## Governing rules

Verified 2026-10-14. Primary sources are the BAP's own Litigants Manual (Rev'd 01/26) and the Federal Rules of Bankruptcy Procedure as quoted in it.

| ID | Requirement | Source | Verified |
|---|---|---|---|
| BAP-CONTENT-001 | Contents, in order: corporate disclosure if FRBP 8012 requires one; table of contents with page references; table of authorities; statement of jurisdiction; statement of issues and applicable standards of review; statement of the case with record references; summary of argument and argument; short conclusion stating the relief sought. The template requires each of the six sections in `doc.required`, under any of the titles listed for it (filers title them differently: the exemplar says "Jurisdictional Statement" and "Standard of Review"). | FRBP 8014(a)(1)-(7) as quoted in BAP Litigants Manual §VIII.5 (Rev'd 01/26), https://cdn.ca9.uscourts.gov/datastore/bap/2026/Litigants_Manual_2026_01_Final.pdf | manual text read 2026-10-14 |
| BAP-CONTENT-002 | Brief must make specific references to the record (excerpts of record). | FRBP 8014(a)(6), (8); Litigants Manual §VIII.9 | manual text read 2026-10-14 |
| BAP-CERT-001 | Opening brief includes a certification of interested parties. | BAP R. 8015(a)-1, Litigants Manual §VIII.6 | manual text read; local rule text not fetched |
| BAP-CERT-002 | Opening brief includes a certification of related cases. | BAP R. 8015(a)-1, Litigants Manual §VIII.6 | manual text read; local rule text not fetched |
| BAP-CERT-004 | Certificate of compliance for the type-volume limit; states the word count. | FRBP 8015(h), as summarized in the secondary fetch below | secondary source only |
| BAP-FORM-001 | 8½ × 11 in paper; margins at least one inch on all four sides. | FRBP 8015(a)(4), Litigants Manual §VIII.7 | manual text read 2026-10-14 |
| BAP-FORM-002 | Proportionally spaced typeface, 14-point or larger (monospaced: 10½ characters per inch); plain roman type, italics or bold for emphasis; case names italic or underlined. | FRBP 8015(a)(5)-(6), Litigants Manual §VIII.7 | manual text read 2026-10-14 |
| BAP-FORM-003 | Text double spaced; long quotations, headings and footnotes may be single spaced. | FRBP 8015(a)(4), Litigants Manual §VIII.7 | manual text read 2026-10-14 |
| BAP-COVER-001 | Cover: case number, court name, case title, proceeding type and lower court, brief title identifying the party filing, counsel's contact information including email. | FRBP 8015(a)(2), as summarized in the secondary fetch below | secondary source only |
| BAP-LENGTH-001 | Principal brief: 30 pages, or 13,000 words (type-volume alternative). Cover, tables, signature block and certificates are excluded from the count. | FRBP 8015(a)(7) and (g); Litigants Manual §VIII.8 | page and type-volume figures cross-checked between the manual and the secondary fetch; **official rule text not checked** |
| BAP-SIG-001 | Electronic signature is "/s/" followed by the typed name. | BAP Administrative Order Regarding Electronic Filing, Rule 5(b), Litigants Manual, Administrative Order Regarding Electronic Filing, manual p. 54 et seq. | manual text read 2026-10-14 |
| BAP-SERVICE-001 | Certificate of service is required for every electronic filing; sample wording. | BAP Administrative Order Regarding Electronic Filing, Rule 6(a)-(b) and sample certificates, Litigants Manual | manual text read 2026-10-14 |

Secondary fetch: https://www.law.cornell.edu/rules/frbp/rule_8015 (fetched 2026-10-14 through an automated summarizer; its quotations were paraphrased in places). Use it only as a cross-check. The official text of FRBP 8014 and 8015 (https://www.uscourts.gov/rules-policies/current-rules-practice-procedure) is still to be read directly before this template is marked reviewed.

## Exemplar search (2026-10-14)

Goal: a real filed appellant's opening brief from this court, public, with text.

Found: `exemplars/FILED-EXAMPLE-meridian-SC-16-1227-opening-brief.pdf`, from https://www.cacttc.org/assets/documents/3%20-%20meridian%20appellants%20bap%20brief.pdf (the California Association of County Treasurers and Tax Collectors' copy). Details and caveats are in `exemplars/SOURCE.md`.

Searches that did not find a brief of this type from the BAP (the same searches are recorded for the other two types):

- CourtListener REST `type=r&court=bap9`, `q=brief` and `q="opening brief"`: 0 results. `type=rd&court=bap9` for `"answering brief"` and `"reply brief"`: 0 results. Unfiltered phrase searches returned other courts only.
- CourtListener REST `type=rd` for `Meridian Stadtmueller`: 380 hits, all bankruptcy-court docket entries (casb 3:16-bk-00629), not appellate briefs.
- Web searches (standard and extended): the BAP Litigants Manual, BAP rules, Ninth Circuit memoranda with BAP captions, BAP briefing orders, pro se forms, the Tracht Gut case, the CSAC amicus motion in the Meridian case (its PDF link returned an HTML page, not the file), and other BAP chapter 7 and 13 appeals. Only the Meridian opening brief is a party's brief.
- Not checked: www.bap9.uscourts.gov case-document pages (not indexed by the search tool); PACER (not accessible from this box).

## Template changes from the overlay

Two template defects showed on the first render of the Meridian transcription:

1. **Required headings matched exactly.** The check (`doc.required`) failed on the exemplar's "Jurisdictional Statement", so the transcription could not render. FRBP 8014(a) fixes the content, not the title, so each requirement now lists the titles it accepts. The same change is in `answering-brief/typst/` and `reply-brief/typst/` (the reply has no required headings).
2. **Level-1 headings were not centered.** A generic `show heading` rule came first and returned the heading unchanged, and the level-1 rule's `block` had no width, so `align(center)` did not center. Each level now has its own show rule, and level 1 sets `width: 100%`. Verified on the render (page 4 and the body pages). The same change is in the answering and reply templates.

Neither change alters a rule-driven value; both were tested on the transcription, the fictional answering sample and the fictional reply sample (all three still render).

## Template (`typst/bap9-opening-brief.typ`)

Built from BAP-FORM-001 to -003 and BAP-COVER-001. Parameters at the top of the file, each tied to a rule ID. Compiled only through `tools/render.sh` (vendored fonts, `--ignore-system-fonts`, any typst warning fails).

- Type: EB Garamond (vendored), 14 pt.
- Leading: `body-leading = 1.3em`, which gives a 36.5 pt line pitch on the render. See the spacing item under "Gate 2 review".
- Page: US Letter, one-inch margins. Cover, table of contents and table of authorities in roman numerals; body arabic from 1.
- Table of contents: `outline` at depth 2 (level-1 and level-2 headings).
- Table of authorities: from the frontmatter `authorities` registry. Every link `[text](toa:KEY)` in the body records its page. "passim" at seven or more pages. A registry entry that is never cited stops the build.
- Signature block: the last body paragraph is kept on the same page as the signature (it never stands alone). Verified on the render.
- Certificates (each on the page group, unbreakable): interested parties; related cases; compliance (word count computed from the body); service (sample wording, with an unregistered-party list if given).
- Required headings: the build fails if a required section has none of its titles as a level-1 heading.
- Word limit: the build fails above 13,000 words (body only).

## Sample (`samples/INPUT-meridian-opening-brief.md`)

A transcription of the exemplar, not a fictional sample. The filer's headings and wording are kept; OCR errors were corrected against the page images (the cover, the first body page and page 8 were checked by eye). Frontmatter carries the caption, counsel, the eleven interested parties, the authorities, and `related_cases: none`, as filed. Authorities are cited with `toa:` links, so the table of authorities is generated from the body. Body: about 1,780 words (the template's count: 1,782 in the compliance certificate).

The compliance certificate reports the transcription's word count (1,782). The filer's certificate states 10,462 for the whole brief; that figure is not reproduced because the sample is abridged.

File naming: the sample is `INPUT-meridian-opening-brief.md`; the fictional sample it replaces is removed. The id is the case short name and the doc type, following the tools' `INPUT-`/`OUTPUT-`/`OVERLAY-` convention.

## Overlay

`sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/opening-brief meridian-opening-brief` exits 0 and writes `samples/OVERLAY-meridian-opening-brief.pdf` (14 pages) and `.txt` (the page map).

Page map (ours → filed PDF page, word overlap): 1→1 (70%), 2→2 (40%), 3→5 (26%), 4→7 (63%), 5→3 (48%), 6→8 (51%), 7→9 (37%), 8→9 (44%), 9→11 (41%), 10→13 (34%), 11→14 (35%), 12→36 (29%), 13→37 (61%), 14→40 (45%). Low overlap on the TOC and TOA is expected (their page numbers and layout differ from the filed body). The pairing is by shared words, so pages 8→9 and 12→36 are the body's nearest matches, not a page-for-page claim.

## Gate 2 review (every page rendered at 70 dpi and viewed)

Pages: 14 PDF pages: cover (p1), table of contents (p2), table of authorities (p3), body (p4-p12, numbered 1-9), certificates (p13-p14).

- p1 cover: fits on one page. The court name wraps with "CIRCUIT" alone on line 2. The filing wraps the same way; accepted.
- p1 cover: no "In re: RW Meridian LLC, Debtor" line, which the filing has. The template has no debtor line and the rules do not require one. Accepted.
- p2 TOC: entries and page numbers match the body pages (checked against the rendered headings, pages 4-9).
- p3 TOA: each authority with its pages, matching the body (e.g. "11 U.S.C. § 108(b)" 2, 6, 8; "Butner" 7).
- p4-p12 body: level-1 headings centered and bold (fixed, see above); level-2 bold, hanging indent; level-3 bold. The conclusion and signature are on the last body page (p12, numbered 9).
- p13-p14 certificates: interested parties (11 items) and related cases on p13; compliance and service on p14. Each certificate is unbreakable.
- **OPEN, for David: body spacing.** The template's body has a 36.5 pt line pitch (double spacing at 14 pt, per BAP-FORM-003). Measured on the exemplar's OCR text-line boxes, the filed body's line pitch is about 22.6 pt, which is tighter than double spacing. The rule governs layout ("the filed exemplar only settles what the rules leave open"), so the template keeps its double spacing and the difference is recorded here, not copied.
- Interested-parties list: the filing lists them single spaced in a block. The template prints one party per paragraph, with paragraph spacing. Accepted.

## Known gaps

- The exemplar is a scan with an OCR text layer, not a born-digital PDF. The transcription was corrected against the images where the OCR was garbled, but a few words may still differ from the filed text.
- The official text of FRBP 8014 and 8015 was not read directly; the citations above come from the Litigants Manual and a secondary summary.
- Excerpts of record (manual §VIII.10) are not generated. The brief cites ER pages; the appendix is a separate filing.
- Corporate disclosure statement (FRBP 8012) is not generated.
- Paper rules (FRBP 8015(a)(1)-(3): reproduction, binding, cover color) are not a PDF concern and are not produced.
- Word count is a whitespace-token count over the body text. It is not Word's count, and it is not checked against the PDF.
- Page count is not checked. The type-volume route (13,000 words) is what the certificate claims, so pages are not the binding limit once the word count is stated.
- No reply-specific content rules are required here. See `reply-brief/README.md`.
- `tools/check.sh` and `tools/check-selftest.sh` were not run for this doc type in this pass (the brief asked for render, overlay and review only).
