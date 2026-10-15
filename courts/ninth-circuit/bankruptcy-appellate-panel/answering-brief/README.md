# Bankruptcy Appellate Panel of the Ninth Circuit: appellee's answering brief (bap9)

- Court: `bap9` (United States Bankruptcy Appellate Panel of the Ninth Circuit), folder `courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief/`
- Template: `typst/bap9-answering-brief.typ` (entry `typst/main.typ`)
- Sample: `samples/INPUT-fictional-answering-brief.md`, rendered to `samples/OUTPUT-fictional-answering-brief.pdf`
- Status of this doc type:
  - **BLOCKED: no public exemplar.** No filed appellee's answering brief from this court was found, after the searches listed in `exemplars/SOURCE.md` (and the Meridian case searches in `../opening-brief/README.md`). `exemplars/` is empty, so the overlay cannot run.
  - Template built from the rules only.
  - The sample is **fictional** (case, parties, counsel and record cites are invented).

Summary line for the PM: `exemplar=no render=ok overlay=fail pages_reviewed=10`

## Governing rules

Verified 2026-10-14. Primary source: BAP Litigants Manual (Rev'd 01/26), https://cdn.ca9.uscourts.gov/datastore/bap/2026/Litigants_Manual_2026_01_Final.pdf, read in full for the sections cited. FRBP text as quoted in the manual, with one secondary cross-check (see `../opening-brief/README.md`, "Governing rules").

| ID | Requirement | Source |
|---|---|---|
| BAP-CONTENT-001 | Responsive brief meets the opening brief's requirements, except that the statements of jurisdiction, of issues and standards of review, and of the case need not be included. The summary of argument, argument and conclusion remain (FRBP 8014(a)(6)-(7)). Table of contents and table of authorities remain (FRBP 8014(a)(2)). The template requires `Summary of Argument`, `Argument`, `Conclusion`, each under any accepted title. | FRBP 8014(b), Litigants Manual §VIII.5 |
| BAP-CERT-001 | Responsive brief includes a certification of interested parties. It does not include a certification of related cases. | BAP R. 8015(a)-1 as stated in Litigants Manual §VIII.6 |
| BAP-LENGTH-001 | Appellee's initial brief is held to the same limit as the appellant's: 30 pages, or 13,000 words under FRBP 8015(a)(7). Cover, tables, signature and certificates are excluded from the count. | Litigants Manual §VIII.8; FRBP 8015(a)(7) |
| BAP-FORM-001 to -003 | Same as the opening brief: 8½ × 11, one-inch margins, double spaced, 14 pt proportional type, plain roman with italics for emphasis. | FRBP 8015(a)(4)-(6), Litigants Manual §VIII.7 |
| BAP-COVER-001 | Same as the opening brief. The title identifies the appellee. | FRBP 8015(a)(2) (secondary summary) |
| BAP-SIG-001, BAP-SERVICE-001 | Same as the opening brief. | Administrative Order Regarding Electronic Filing, Rules 5(b) and 6 |

Note on FRBP 8014(b): the manual paraphrases this. The opening-brief README says the official text of 8014 and 8015 was not read directly; that applies here too.

## Template

`typst/bap9-answering-brief.typ` is the opening-brief template with its per-type settings block changed (`kind`, `title`, `required`, `certs`). The shared layout code is identical to the opening template, including the two fixes made when the opening brief was checked against its exemplar (see `../opening-brief/README.md`, "Template changes from the overlay"): required headings accept any of their titles, and each heading level has its own show rule, with level 1 centered.

- Leading: 1.3em, which gives the 36.5 pt double-spaced line pitch measured on the render.
- Table of authorities, signature keep-with-last-paragraph, unbreakable certificates: as in the opening brief.

## Sample (`samples/INPUT-fictional-answering-brief.md`)

Fictional. About 950 words of body text. Sections: summary of argument; argument with sub-headings; conclusion. No statements of jurisdiction, issues or the case (correct under FRBP 8014(b)). Interested-parties certificate only. Written to the rules, not transcribed.

File naming follows the tools (`INPUT-` / `OUTPUT-` / `OVERLAY-`), as in the opening-brief folder.

## Overlay

`sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief fictional-answering-brief` exits 1: `no exemplar pdf in .../answering-brief/exemplars`. No overlay file was produced, and none is claimed.

## Gate 2 review (every page rendered at 60 dpi and viewed; 10 PDF pages)

Pages: cover (p1), table of contents (p2, roman i), table of authorities (p3, roman ii), body (p4-p8, numbered 1-5), certificates (p9-p10, numbered 6-7).

- p1 cover: fits on one page; caption, proceeding line and title centered; counsel block complete.
- p2 TOC: entries and page numbers match the body headings (Summary of Argument 1; Argument 2; Conclusion 5).
- p3 TOA: "11 U.S.C. § 548" lists 1, 3, 4; "11 U.S.C. § 544" lists 1, 4; "Law v. Siegel" lists 5; "Fed. R. Bankr. P. 8014" lists 2.
- p4-p8 body: double-spaced; level-1 headings centered and bold (fixed in this pass; they were left-aligned before); sub-headings bold with hanging indent. The conclusion and signature are on the same page (p8, numbered 5).
- p9-p10 certificates: interested parties and compliance on p9; service on p10. Each certificate is unbreakable.

## Known gaps

- No exemplar: the layout beyond the rules is unverified against a filed brief.
- Official FRBP 8014(b) text not read directly.
- Excerpts of record appendix, corporate disclosure statement, paper rules: not generated (as in the opening brief).
- Word count and page count are not checked against the PDF (see the opening-brief README).
- `tools/check.sh` and `tools/check-selftest.sh` were not run for this doc type in this pass.

## Re-check 2026-10-15 (bead fb-595.20.9)

- Re-searched for an exemplar (CourtListener with `court=bap9`, paced; web search). None found. Searches are logged in `exemplars/SOURCE.md`.
- Re-rendered `samples/INPUT-fictional-answering-brief.md` with `sh tools/render.sh`: 10 pages, exit 0. Every page rendered at 60 dpi and viewed; layout unchanged from the review above. The PDF was moved to `/work/artifacts/bap9/` and is not committed.
- `sh tools/overlay.sh` exits 1 (`no exemplar pdf`). Overlay: not produced.
- Status unchanged: **BLOCKED: no public exemplar.**
