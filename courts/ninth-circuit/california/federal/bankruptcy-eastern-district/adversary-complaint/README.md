# Adversary complaint: U.S. Bankruptcy Court, E.D. California (caeb)

Doc-type folder of [caeb](../README.md). Typst is the template; the court's local rules decide the layout.

## Rules (verified 2026-10-14)

| Requirement | Rule | Source (URL) | Kind |
|---|---|---|---|
| Caption conforms to the official caption form; Rule 10 applies to adversary complaints | FRBP 7010 | https://www.law.cornell.edu/rules/frbp/rule_7010 | M |
| Title names all parties; claims in numbered paragraphs | FRCP 10(a), 10(b) (via FRBP 7010) | https://www.law.cornell.edu/rules/frcp/rule_10 | M |
| Jury demand immediately after the complaint's title | LBR 7038-1(b) | https://www.caeb.uscourts.gov/documents/Forms/Misc/Local%20Rules%20February%202025%20Final%20for%20Posting.pdf (Local Rules, Feb. 2025) | M |
| Documents formatted to LBR 9004-2; counsel block in upper left of page 1 with email, phone, State Bar number and party designation; signatures and typed name under them | LBR 9004-1(a), (b), (c) | same PDF | M |
| Letter paper, black ink | LBR 9004-2(a)(1) | same PDF | M |
| Consecutively numbered lines in the left margin, double spaced | LBR 9004-2(a)(2), (b)(1) | same PDF | M |
| Font 12 to 14 point; Arial, Courier, Times, Times New Roman, Helvetica "or their equivalent" | LBR 9004-2(a)(4) | same PDF | M |
| Typeface: face required Times New Roman (named in the list above) → vendored substitute `Liberation Serif` (docs/FONTS.md; metric-compatible) | LBR 9004-2(a)(4) | same PDF | M |
| Caption: court, case number, adversary number, title of document | LBR 9004-2(a)(6), (b)(5) | same PDF | M |
| Margins at least one-half inch on all four sides | LBR 9004-2(b)(2) | same PDF | M |
| Upper-right blank space for the clerk's stamp, at least 2 1/2 in. from the right edge and 3 in. from the top | LBR 9004-2(b)(3) | same PDF | M |
| Page number bottom center; page 1 is the page bearing the caption | LBR 9004-2(c)(3) | same PDF | M |
| Total page count in the upper-left corner of page 1 | LBR 9004-2(c)(4) | same PDF | M |

The local rules text was read from the Feb. 2025 PDF on 2026-10-14. The court also posts earlier editions (2022 redline, July 2024); the Feb. 2025 text is the one used here. The template's § no-break spacing and the footer title are typography, not rules: see "What the template does" and gap 2.

## What the template does

- `typst/main.typ` is the entry point; `typst/caeb-adversary-complaint.typ` holds the parameters, page furniture and body.
- Layout: 28 numbered lines on a 24 pt pitch, 13 pt Liberation Serif (Times New Roman substitute), pleading rules, 1.5 in left margin, 0.75 in right, 0.5 in top, page number at the bottom center, page total at the top left of page 1.
- Counsel block, court title and caption fill page 1; the body is numbered paragraphs (FRCP 10(b)) generated from the markdown, one per paragraph chunk; markdown lists become (a), (b), ...; a lead-in marked `^` is an unnumbered paragraph (for example "WHEREFORE").
- Signature blocks render `/s/` and the typed name (LBR 9004-1(c)(1)(A) for electronic filing).
- A section sign is joined to its number with a no-break space, so "§ 9-406" never splits across lines.
- Content is case-specific only through the sample's frontmatter; no coordinates are measured off any filing.

## Samples and exemplars

- `samples/INPUT-dlp-hronis-complaint.md`: transcription of the DLP Funding complaint (Doc 1, 10 pages) in `exemplars/FILED-EXAMPLE-dlp-hronis-complaint.pdf`. Caption, headings, 33 numbered paragraphs, prayer, signature blocks.
- `samples/OUTPUT-dlp-hronis-complaint.pdf`: our render. 9 pages, Liberation Serif only (`pdffonts`: LiberationSerif Regular, Italic, Bold embedded), no typst warnings. The pre-change EB Garamond render was also 9 pages, so the substitute did not change the length.
- `samples/OVERLAY-dlp-hronis-complaint.pdf` and `.txt`: red = ours, blue = filed, black = both. Pages are paired by word overlap; the `.txt` lists the pairs (ours p.1 to p.9 against filed p.1, p.3 to p.10). Page 1 pairs with filed page 1 (67.8%). Later pages pair at 80 to 90% word overlap, and our page 9 (signatures only) pairs with filed p.10 at 46.8%. The overlay is a diagnostic, not a score.
- `exemplars/FILED-EXAMPLE-kaur-grewal-complaint.pdf` (second filer, 6 pages): checked for convention only. It shares the footer title with the DLP filing (see gaps).

Every page of the render (9 of 9) was rendered to PNG and viewed. The rows are not recorded in a `reviews/` file because this doc type has no `checks.yaml` yet.

## Gaps

1. **Font (resolved).** LBR 9004-2(a)(4) names Times New Roman among the faces allowed "or their equivalent". The template now sets `Liberation Serif`, the metric-compatible Times New Roman substitute in `docs/FONTS.md`, instead of EB Garamond. Both filed exemplars set their body in Times New Roman (`pdffonts`: `TimesNewRomanPSMT` in the DLP filing, `Times-Roman` in the Kaur filing), so the substitute matches the filed practice. Visual check: every page of the new render was viewed (9 of 9). Remaining risk: the rule allows "equivalent" faces, so a clerk is not bound to Times New Roman, but the Times-metric choice is the conservative one.
2. **Footer title (tier 2).** Both exemplars carry the document title in the footer; the LBR requires only the page number. A footer title would sit inside the one-half-inch bottom margin, which LBR 9004-2(b)(2) reserves, and no short form of the title fits beside the number. Not added; recorded as an open tier-2 item.
3. **Sub-paragraph numbering.** The DLP filing numbers its sub-paragraphs 29.1 to 29.4; the template renders markdown lists as (a) to (d) and bullets. One filer's style, so tier 3, not chased.
4. **No certificate of service.** Neither exemplar has one, so the template has none. Add one if a filed sample needs it.
5. **Official Form 416A caption.** FRBP 7010 requires the caption to "substantially conform" to the official form. The caption layout follows the DLP and Kaur filings; the form text itself was not checked.
6. **FRBP 9004 is not verified.** The template comment cites FRBP 9004(a) and (b) for the caption; that text was not checked here. The docket control number rule (LBR 9014-1(c)(1)) covers motions and papers for or against them, so an adversary complaint carries none.
7. **Signatures.** Every signature line is printed with `/s/`, which is correct for ECF filing without a scanned original (LBR 9004-1(c)(1)(A)). A wet-signed filing would need a different line.
8. **Gate checks.** No `checks.yaml`, `reviews/` or selftest exists for this doc type yet. The rules above are verified by reading the sources, not by a mechanical check.
