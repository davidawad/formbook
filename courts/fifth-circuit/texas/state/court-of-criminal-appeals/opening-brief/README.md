# Opening brief (initial brief on the merits)

## Governing rules

Rules verified October 14, 2026 against the current [Texas Rules of Appellate Procedure](https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf), which the official [Rules & Standards page](https://www.txcourts.gov/rules-forms/rules-standards/) lists as amended February 6, 2026.

- **TRAP 9.4(b)–(e), (g), (i), (j) (mandated):** 8.5 by 11 inch page; one-inch margins; double-spaced text, with stated exceptions; conventional computer type no smaller than 14 point and footnotes no smaller than 12 point; cover contents; applicable length limit and word-count certificate; text-searchable unlocked PDF for e-filing. Rule 70.3 makes Rule 9 applicable to a brief on the merits.
- **TRAP 9.5 (mandated):** serve each party and include proof of service.
- **TRAP 38.1 (mandated through TRAP 70.3):** brief contents and their order, including identity of parties and counsel, contents, authorities, oral-argument statement, case and procedural history, issues, facts, argument, conclusion, and signature. Rule 70.3 dispenses with the appendix required by Rule 38.1(k).
- **TRAP 70.1 (mandated):** after discretionary review is granted, the petitioner (or the losing party where no petition was filed) files the initial brief within 30 days.
- **TRAP 70.3 (mandated):** merits briefs comply with Rules 9 and 38, except that the appendix is not required.

## Markdown contract and template

The markdown file begins with YAML frontmatter: `case_number`, `style_petitioner`, `style_respondent`, `filing_party`, `brief_title`, `appeal_from`, `lead_counsel`, `counsel_lines`, and optional `filed_date`. The body supplies the document-specific sections and text, including contents, authorities, signature, certificate of compliance, and proof of service. The layout module builds the cover and renders markdown with vendored cmarker; it does not create tables of contents or authorities automatically.

Build from the repository root:

```sh
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/opening-brief samples/INPUT-becerra-merits.md
sh tools/overlay.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/opening-brief becerra-merits
```

## Overlay and page review

The red/blue overlay is `samples/OVERLAY-becerra-merits.pdf`; its page map is `samples/OVERLAY-becerra-merits.txt`. The sample uses the filed brief's cover, front matter, table headings, and representative argument and certificate sections. The five rendered pages were rendered at 60 dpi and reviewed on October 14, 2026.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Caption, appellate cause number, procedural origin, brief title, filing party, and counsel/contact block fit on one page. | PASS |
| 2 | overlay paired exemplar p.2 | Identity of parties and counsel, table of contents, index of authorities, and compliance certificate are legible. | PASS |
| 3 | exemplar p.10 | Oral argument, case and procedural history, and facts are readable. | PASS |
| 4 | overlay paired exemplar p.52 | Summary, issue response, prayer, signature block, and service certificate fit on the page. | PASS |
| 5 | exemplar p.53 | Compliance certificate is readable and not clipped. | PASS |

## Known gaps

- One filed exemplar is available here; it shows one filer's style, not a cross-filer convention.
- Tables of contents and authorities remain author-supplied markdown and are not page-numbered from the final rendered document. The sample's page references are retained from the filed exemplar and will not remain accurate after its text is shortened or reflowed.
- The template does not calculate word limits or certificate counts, verify service details, create bookmarks, or mechanically check every Rule 38.1 requirement. Confirm case-specific requirements and any applicable length limit before use.
- The sample is a representative excerpt, not the complete brief. This task rendered and visually reviewed the Typst sample; no other engine or automated rule-check suite was run.
