# Petition for discretionary review

## Governing rules

Rules verified October 14, 2026 against the current [Texas Rules of Appellate Procedure](https://www.txcourts.gov/media/1463134/texas-rules-of-appellate-procedure-02062026.pdf), which the official [Rules & Standards page](https://www.txcourts.gov/rules-forms/rules-standards/) lists as amended February 6, 2026.

- **TRAP 9.4(b)–(e), (g), (i), (j) (mandated):** 8.5 by 11 inch page; one-inch margins; double-spaced text, with stated exceptions; conventional computer type no smaller than 14 point and footnotes no smaller than 12 point; cover contents; 4,500-word maximum for a computer-generated petition (excluding the items listed in 9.4(i)(1)); word-count certificate; text-searchable unlocked PDF for e-filing.
- **TRAP 9.5 (mandated):** serve each party and include proof of service.
- **TRAP 68.3–68.4 (mandated):** file with the Court of Criminal Appeals; include identity of judge, parties, and counsel; table of contents; alphabetical index of authorities; oral-argument statement; case statement; procedural history; numbered grounds or concise questions; direct concise argument; prayer; and the court of appeals opinion in the appendix.
- **TRAP 68.6 (mandated):** a nonconforming or unnecessarily lengthy petition may be struck, redrawn, or refused.

## Markdown contract and template

The markdown file begins with YAML frontmatter: `case_number`, `style_petitioner`, `style_respondent`, `filing_party`, `brief_title`, `appeal_from`, `lead_counsel`, `counsel_lines`, and optional `filed_date`. The body supplies the document-specific required sections and text, including tables, signature, certificate of compliance, and proof of service. The layout module builds the cover and renders markdown with vendored cmarker; it does not create a table of contents or authorities automatically.

Build from the repository root:

```sh
sh tools/render.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/petition-for-discretionary-review samples/ukw-pdr.md
sh tools/overlay.sh courts/fifth-circuit/texas/state/court-of-criminal-appeals/petition-for-discretionary-review ukw-pdr
```

## Overlay and page review

The red/blue overlay is `samples/ukw-pdr-overlay.pdf`; its page map is `samples/ukw-pdr-overlay.txt`. The sample uses the filed petition's cover, opening case identity, table headings and representative petition sections. The five rendered pages were rendered at 60 dpi and reviewed on October 14, 2026.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Cover, caption, title, filing party, counsel, contact details, and filing date fit on one page. | PASS |
| 2 | exemplar p.2 | Party and counsel list, followed by a compact table of contents; heading wraps naturally. | PASS |
| 3 | exemplar p.6 | Index of authorities, oral-argument statement, and statement of the case remain readable. | PASS |
| 4 | overlay paired exemplar p.3 | Procedural history, grounds, argument, and prayer are legible. The text-based pairing has low overlap on this page. | PASS |
| 5 | exemplar p.24 | Signature, word-count certificate, and service certificate fit without clipping. | PASS |

## Known gaps

- One filed exemplar is available here; it shows one filer's style, not a cross-filer convention.
- Tables of contents and authorities remain author-supplied markdown and are not page-numbered from the final rendered document. The sample's page references are retained from the filed exemplar and will not remain accurate after its text is shortened or reflowed.
- The template does not calculate the 4,500-word limit or certificate count, verify service recipients, attach the court of appeals opinion, create bookmarks, or mechanically check all Rule 68.4 sections. Confirm those filing-specific requirements before use.
- The sample is a representative excerpt, not the complete petition or appendix. This task rendered and visually reviewed the Typst sample; no other engine or automated rule-check suite was run.
