# Bankruptcy Appellate Panel of the Ninth Circuit: appellant's opening brief (bap9)

- Court: `bap9` (United States Bankruptcy Appellate Panel of the Ninth Circuit), folder `courts/ninth-circuit/bankruptcy-appellate-panel/opening-brief/`
- Template: `typst/bap9-opening-brief.typ` (entry `typst/main.typ`)
- Sample: `samples/INPUT-fictional-opening-brief.md`, rendered to `samples/OUTPUT-fictional-opening-brief.pdf`
- Status of this doc type:
  - **BLOCKED: no exemplar.** No filed appellant's opening brief from this court was found (see "Exemplar search" below). `exemplars/` is empty, so the overlay cannot run.
  - Template built from the rules only.
  - The sample is **fictional** (case, parties, counsel and record cites are invented). It exercises every rule-driven element; it is not a transcription.

Summary line for the PM: `exemplar=no render=ok overlay=fail pages_reviewed=14`

## Governing rules

Verified 2026-10-14. Primary sources are the BAP's own Litigants Manual (Rev'd 01/26) and the Federal Rules of Bankruptcy Procedure as quoted in it.

| ID | Requirement | Source | Verified |
|---|---|---|---|
| BAP-CONTENT-001 | Contents, in order: corporate disclosure if FRBP 8012 requires one; table of contents with page references; table of authorities; statement of jurisdiction; statement of issues and applicable standards of review; statement of the case with record references; summary of argument and argument; short conclusion stating the relief sought. The template requires the six headings listed in `doc.required`. | FRBP 8014(a)(1)-(7) as quoted in BAP Litigants Manual §VIII.5 (Rev'd 01/26), https://cdn.ca9.uscourts.gov/datastore/bap/2026/Litigants_Manual_2026_01_Final.pdf | manual text read 2026-10-14 |
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

Goal: a real filed appellant's opening brief from the BAP, in a text-based PDF.

- CourtListener REST search `type=r&court=bap9` with `q=brief` and `q="opening brief"`: 0 results. The bap9 court has no RECAP documents in the index.
- CourtListener REST search with phrases (`"Appellant's Opening Brief" "Bankruptcy Appellate Panel"`, `"Appellee's Answering Brief" "BAP No"`, `"Reply Brief" "Bankruptcy Appellate Panel"`), unfiltered: only filings from other courts (ca9, cand, caed, orb, cacb). No BAP brief. Several requests were throttled (5 per minute); the throttled ones were retried and returned the results above.
- Web search (standard and extended modes): BAP rules, the Litigants Manual, a 2020 published memorandum that quotes the caption form ("BAP No."), and a 2017 BAP-dismissal memorandum. No brief.
- Not fetched: the BAP's own site (www.bap9.uscourts.gov); the "Briefs" page on the BAP 10 site (a different panel).

Result: no exemplar. `exemplars/SOURCE.md` records the same.

## Template (`typst/bap9-opening-brief.typ`)

Built from BAP-FORM-001 to -003 and BAP-COVER-001. Parameters at the top of the file, each tied to a rule ID. Compiled only through `tools/render.sh` (vendored fonts, `--ignore-system-fonts`, any typst warning fails).

- Type: EB Garamond (vendored), 14 pt. This is a substitute for the Garamond used in many filings, since no exemplar was available to match.
- Leading: `body-leading = 1.3em`. Measured on the render: body line pitch is 36.5 pt, which is double spacing for 14 pt type. The natural line height is about 1.3em, so the leading adds the second spacing. Previous settings (0.94em, 1.7em) gave 31.4 pt and 42.1 pt; neither was double.
- Page: US Letter, one-inch margins. Cover, table of contents and table of authorities in roman numerals; body arabic from 1.
- Table of contents: `outline` at depth 2 (level-1 and level-2 headings).
- Table of authorities: from the frontmatter `authorities` registry. Every link `[text](toa:KEY)` in the body records its page. "passim" at seven or more pages. A registry entry that is never cited stops the build.
- Signature block: the last body paragraph is kept on the same page as the signature (it never stands alone). Verified on the render.
- Certificates (each on the page group, unbreakable): interested parties; related cases; compliance (word count computed from the body); service (sample wording, with an unregistered-party list if given).
- Required headings: the build fails if any of the six section headings in `doc.required` is missing.
- Word limit: the build fails above 13,000 words (body only).

## Sample (`samples/INPUT-fictional-opening-brief.md`)

Fictional. Written to the rules, not transcribed. Frontmatter schema is the same as the court-of-appeals sample (`courts/ninth-circuit/court-of-appeals/README.extra.md`), without the ca9-only fields. Body: about 1,600 words, all six required sections, numbered issues, sub-headings, record cites, a block of case and statute citations.

File naming: the brief's convention was `samples/<id>.md`, `<id>.pdf`, `<id>-overlay.pdf`. The tools read and write `INPUT-` / `OUTPUT-` / `OVERLAY-` names by default, and the repo's file-role convention is in those names. This folder follows the tools.

## Overlay

`sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/opening-brief fictional-opening-brief` exits 1: `no exemplar pdf in .../opening-brief/exemplars`. No overlay file was produced, and none is claimed.

## Gate 2 review (every page rendered and viewed, 60 dpi)

Pages: 14 PDF pages: cover (p1), table of contents (p2), table of authorities (p3), body (p4-p12, numbered 1-9), certificates (p13-p14).

- p1 cover: fits on one page. Court name wraps with "CIRCUIT" alone on line 2; acceptable.
- p2 TOC: correct entries and page numbers (checked against the body pages).
- p3 TOA: each authority with its pages; "11 U.S.C. § 548" lists 1, 3, 4, 5, 7.
- p4-p12 body (numbered 1-9): double-spaced; level-1 headings centered and bold; level-2 bold, hanging indent; level-3 bold. Conclusion and signature together on the last body page.
- p13-p14 certificates: each certificate is unbreakable, so none starts at the foot of a page. Fixed during review: the two sentences of the compliance and service certificates had no space between them (now separate paragraphs).

Open choices, accepted: the signature block is at the left-third indent (3 in). The exemplar would decide this if one were found.

## Known gaps

- No exemplar: the layout beyond the rules is unverified against a filed brief.
- The official text of FRBP 8014 and 8015 was not read directly; the citations above come from the Litigants Manual and a secondary summary.
- Excerpts of record (manual §VIII.10) are not generated. The brief cites ER pages; the appendix is a separate filing.
- Corporate disclosure statement (FRBP 8012) is not generated.
- Paper rules (FRBP 8015(a)(1)-(3): reproduction, binding, cover color) are not a PDF concern and are not produced.
- Word count is a whitespace-token count over the body text. It is not Word's count, and it is not checked against the PDF.
- Page count is not checked. The type-volume route (13,000 words) is what the certificate claims, so pages are not the binding limit once the word count is stated.
- No reply-specific content rules are required here. See `reply-brief/README.md`.
