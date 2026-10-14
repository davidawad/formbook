# Bankruptcy Appellate Panel of the Ninth Circuit: appellant's reply brief (bap9)

- Court: `bap9` (United States Bankruptcy Appellate Panel of the Ninth Circuit), folder `courts/ninth-circuit/bankruptcy-appellate-panel/reply-brief/`
- Template: `typst/bap9-reply-brief.typ` (entry `typst/main.typ`)
- Sample: `samples/INPUT-fictional-reply-brief.md`, rendered to `samples/OUTPUT-fictional-reply-brief.pdf`
- Status of this doc type:
  - **BLOCKED: no exemplar.** No filed reply brief from this court was found (see "Exemplar search" in `../opening-brief/README.md`, which covers the same search for all three doc types). `exemplars/` is empty, so the overlay cannot run.
  - Template built from the rules only. The reply-specific content rules are a **gap** (see below).
  - The sample is **fictional** (case, parties, counsel and record cites are invented).

Summary line for the PM: `exemplar=no render=ok overlay=fail pages_reviewed=6`

## Governing rules

Verified 2026-10-14. Primary source: BAP Litigants Manual (Rev'd 01/26), https://cdn.ca9.uscourts.gov/datastore/bap/2026/Litigants_Manual_2026_01_Final.pdf. FRBP text as quoted in the manual, with one secondary cross-check (see `../opening-brief/README.md`, "Governing rules").

| ID | Requirement | Source |
|---|---|---|
| BAP-LENGTH-001 | Reply brief: 15 pages, or half the type-volume limit of the principal brief (13,000 words / 2 = 6,500 words). Cover, tables, signature and certificates are excluded. | Litigants Manual §VIII.8; FRBP 8015(a)(7) (secondary summary for the "half" rule) |
| BAP-CERT-004 | Certificate of compliance for the type-volume limit, stating the word count. | FRBP 8015(h) (secondary summary) |
| BAP-CERT-005 | No certification of interested parties or of related cases is listed for a reply. The template prints only the compliance certificate and the service certificate. | Litigants Manual §VIII.6 lists the certifications for the opening and responsive briefs only |
| BAP-FORM-001 to -003 | Same as the opening brief. | FRBP 8015(a)(4)-(6), Litigants Manual §VIII.7 |
| BAP-COVER-001 | Same as the opening brief. The title identifies the appellant. | FRBP 8015(a)(2) (secondary summary) |
| BAP-SIG-001, BAP-SERVICE-001 | Same as the opening brief. | Administrative Order Regarding Electronic Filing, Rules 5(b) and 6 |

## Gap: no reply content rules

FRBP 8014(a) and (b) and the manual's §VIII.5 set out contents for the opening and responsive briefs. The manual gives no section list for a reply, and the official FRBP 8014(c) text was not read. The template therefore requires no headings (`doc.required: ()`). The sample uses `# Argument` and `# Conclusion` only because that is how a reply is usually organized. This is an open question for David: does the Panel require any reply heading, and is the official FRBP 8014 text (not yet read here) silent on it?

## Template

`typst/bap9-reply-brief.typ` is the opening-brief template with its per-type settings block changed (`kind`, `title`, `required`, `word-limit`, `certs`). The shared layout code is identical to the opening brief's.

- Leading: 1.3em, which gives the 36.5 pt double-spaced line pitch measured on the opening-brief render.
- Table of contents: printed for the reply. Table of authorities: printed only when the sample's frontmatter gives an `authorities` registry (the reply sample does).

## Sample (`samples/INPUT-fictional-reply-brief.md`)

Fictional. About 350 words of body text (478 words including frontmatter). Two argument headings and a conclusion. Compliance and service certificates only. Written to the rules, not transcribed.

File naming follows the tools (`INPUT-` / `OUTPUT-` / `OVERLAY-`), as in the opening-brief folder.

## Overlay

`sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/reply-brief fictional-reply-brief` exits 1: `no exemplar pdf in .../reply-brief/exemplars`. No overlay file was produced.

## Gate 2 review (every page rendered and viewed, 60 dpi)

Pages: 6 PDF pages: cover (p1), table of contents (p2), table of authorities (p3), body (p4-p5, numbered 1-2), certificates (p6).

- p1 cover: fits on one page; the title reads "APPELLANT'S REPLY BRIEF".
- p2 TOC: entries and page numbers match the body pages.
- p3 TOA: "Law v. Siegel" lists 2; "11 U.S.C. § 548" lists 1. The sample cites § 544 only in headings, not in a linked citation, so it is not listed; that is correct behaviour for an unlinked mention, and a citation in the body would be listed once linked.
- p4-p5 body: double-spaced; headings as in the opening brief. The conclusion and signature are on body page 2.
- p6 certificates: compliance (word count 344, from the body) and service, on one page.

Open items, accepted: none beyond the content gap above.

## Known gaps

- No exemplar: the layout beyond the rules is unverified against a filed brief.
- Reply content rules (see the gap section).
- Official FRBP 8015(a)(7)(B) "half" text and FRBP 8014(c) not read directly.
- Word count and page count are not checked against the PDF (see the opening-brief README).
