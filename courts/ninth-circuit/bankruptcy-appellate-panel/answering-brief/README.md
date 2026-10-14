# Bankruptcy Appellate Panel of the Ninth Circuit: appellee's answering brief (bap9)

- Court: `bap9` (United States Bankruptcy Appellate Panel of the Ninth Circuit), folder `courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief/`
- Template: `typst/bap9-answering-brief.typ` (entry `typst/main.typ`)
- Sample: `samples/INPUT-fictional-answering-brief.md`, rendered to `samples/OUTPUT-fictional-answering-brief.pdf`
- Status of this doc type:
  - **BLOCKED: no exemplar.** No filed appellee's answering brief from this court was found (see "Exemplar search" in `../opening-brief/README.md`, which covers the same search for all three doc types). `exemplars/` is empty, so the overlay cannot run.
  - Template built from the rules only.
  - The sample is **fictional** (case, parties, counsel and record cites are invented).

Summary line for the PM: `exemplar=no render=ok overlay=fail pages_reviewed=11`

## Governing rules

Verified 2026-10-14. Primary source: BAP Litigants Manual (Rev'd 01/26), https://cdn.ca9.uscourts.gov/datastore/bap/2026/Litigants_Manual_2026_01_Final.pdf, read in full for the sections cited. FRBP text as quoted in the manual, with one secondary cross-check (see `../opening-brief/README.md`, "Governing rules").

| ID | Requirement | Source |
|---|---|---|
| BAP-CONTENT-001 | Responsive brief meets the opening brief's requirements, except that the statements of jurisdiction, of issues and standards of review, and of the case need not be included. The summary of argument, argument and conclusion remain (FRBP 8014(a)(6)-(7)). Table of contents and table of authorities remain (FRBP 8014(a)(2)). The template requires `Summary of Argument`, `Argument`, `Conclusion`. | FRBP 8014(b), Litigants Manual §VIII.5 |
| BAP-CERT-001 | Responsive brief includes a certification of interested parties. It does not include a certification of related cases. | BAP R. 8015(a)-1 as stated in Litigants Manual §VIII.6 |
| BAP-LENGTH-001 | Appellee's initial brief is held to the same limit as the appellant's: 30 pages, or 13,000 words under FRBP 8015(a)(7). Cover, tables, signature and certificates are excluded from the count. | Litigants Manual §VIII.8; FRBP 8015(a)(7) |
| BAP-FORM-001 to -003 | Same as the opening brief: 8½ × 11, one-inch margins, double spaced, 14 pt proportional type, plain roman with italics for emphasis. | FRBP 8015(a)(4)-(6), Litigants Manual §VIII.7 |
| BAP-COVER-001 | Same as the opening brief. The title identifies the appellee. | FRBP 8015(a)(2) (secondary summary) |
| BAP-SIG-001, BAP-SERVICE-001 | Same as the opening brief. | Administrative Order Regarding Electronic Filing, Rules 5(b) and 6 |

Note on FRBP 8014(b): the manual paraphrases this. The opening-brief README says the official text of 8014 and 8015 was not read directly; that applies here too.

## Template

`typst/bap9-answering-brief.typ` is the opening-brief template with its per-type settings block changed (`kind`, `title`, `required`, `certs`). The shared layout code is identical, so a fix to one must be copied to the others (the opening template is `../opening-brief/typst/bap9-opening-brief.typ`).

- Leading: 1.3em, which gives the 36.5 pt double-spaced line pitch measured on the opening-brief render.
- Table of authorities, signature keep-with-last-paragraph, unbreakable certificates: as in the opening brief.

## Sample (`samples/INPUT-fictional-answering-brief.md`)

Fictional. About 950 words of body text (1,158 words including frontmatter). Sections: summary of argument; argument with sub-headings; conclusion. No statements of jurisdiction, issues or the case (correct under FRBP 8014(b)). Interested-parties certificate only. Written to the rules, not transcribed.

File naming follows the tools (`INPUT-` / `OUTPUT-` / `OVERLAY-`), as in the opening-brief folder.

## Overlay

`sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief fictional-answering-brief` exits 1: `no exemplar pdf in .../answering-brief/exemplars`. No overlay file was produced.

## Gate 2 review (every page rendered and viewed, 60 dpi)

Pages: 11 PDF pages: cover (p1), table of contents (p2), table of authorities (p3), body (p4-p9, numbered 1-6), certificates (p10-p11).

- p1 cover: fits on one page; the caption, the proceeding line and the title are centered; counsel block is complete.
- p2 TOC: entries and page numbers match the body pages.
- p3 TOA: "11 U.S.C. § 548" lists 1, 3, 5; "11 U.S.C. § 544" lists 1, 5; "Law v. Siegel" lists 5; "Fed. R. Bankr. P. 8014" lists 2.
- p4-p9 body: double-spaced; level-1 headings centered and bold; sub-headings bold with hanging indent. The conclusion and signature are on the same page (body page 6).
- p10-p11 certificates: interested parties and compliance on p10; service on p11. Each certificate is unbreakable.

Open items, accepted: "11 U.S.C." and "§ 544" can break across a line (the §-number box keeps "§ 544" together but not "11 U.S.C. §"). A non-breaking space in the sample would fix it; this is a sample-authoring point, not a template defect.

## Known gaps

- No exemplar: the layout beyond the rules is unverified against a filed brief.
- Official FRBP 8014(b) text not read directly.
- Excerpts of record appendix, corporate disclosure statement, paper rules: not generated (as in the opening brief).
- Word count and page count are not checked against the PDF (see the opening-brief README).
