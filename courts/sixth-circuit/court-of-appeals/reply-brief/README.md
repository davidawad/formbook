# Sixth Circuit (ca6): reply brief

Self-contained folder for one document type of the Court of Appeals for the Sixth Circuit: the appellant's **reply brief** (FRAP 28(c)). The principal brief lives elsewhere and is not touched here.

| Item | State |
|---|---|
| Exemplar (filed, text-based) | yes: `usage/SAMPLE-ca6-reply-brief-smithvpamtransport245549.pdf` (see `usage/SOURCE.md`) |
| Sample markdown | `usage/INPUT-ca6-reply-brief-smith.md` (a portion: cover, tables, Introduction, Argument point I to the printed page 7 paragraph, Conclusion, signatures, certificates) |
| Render | `sh tools/render.sh courts/sixth-circuit/court-of-appeals/reply-brief usage/INPUT-ca6-reply-brief-smith.md` → 12 pages, no typst warnings |
| Overlay | `usage/OVERLAY-smith-reply-brief.pdf` and `-overlay.txt` (`tools/overlay.sh`, against the exemplar) |
| Pages reviewed | 12 of 12, each rendered at `pdftoppm -r 60` and looked at, in the final state |
| Known gaps | see "Known gaps and open findings" below |

## Governing rules

Sources were read on 2026-10-14 from the Sixth Circuit's own publications:

- Full rules (FRAP last amended Dec. 1, 2025; 6 Cir. R. last amended July 13, 2026): https://www.ca6.uscourts.gov/sites/ca6/files/documents/rules_procedures/Full%20Rules%20w%20FRAP_0.pdf
- Checklist for Briefs (the court's own form-and-length summary): https://www.ca6.uscourts.gov/sites/ca6/files/documents/rules_procedures/Briefs%20Checklist.pdf
- Appendix: Length Limits Stated in the FRAP: https://www.ca6.uscourts.gov/sites/ca6/files/documents/rules_procedures/Appendix.pdf

| ID | Requirement | Rule | Where it lands in the template |
|---|---|---|---|
| CA6-FORM-004 | 8½ × 11; double spaced; margins at least 1 in. on all four sides; quotations over two lines may be single-spaced; headings and footnotes single-spaced | FRAP 32(a)(4); checklist "Typefaces", "Margins" | `page-margin`, `body-leading`, `single-leading`, block quotes |
| CA6-FORM-005 | Proportionally spaced serif face, 14-point or larger; checklist: footnotes at the same size as text | FRAP 32(a)(5)(A); checklist "Typefaces" | `type-size-pt = 14`, footnote show rule; `font-family` |
| CA6-FORM-006 | Plain roman type; case names italicized; emphasis by italics or bold | FRAP 32(a)(6) | sample markdown: `*Case v. Name*` |
| CA6-LEN-001 | Reply brief: no more than half the principal-brief type-volume: 6,500 words (15 pages or 650 monospaced lines are the alternatives) | FRAP 32(a)(7)(A), (B)(ii); Appendix | `word-limit = 6500`, `count-words`; the build stops above the limit |
| CA6-LEN-002 | Excluded from length: cover, disclosure, TOC, TOA, oral-argument statement, addendum of rules, certificates, signature block, proof of service | FRAP 32(f); 6 Cir. R. 32(b)(1) | `count-words` counts only the body markdown (headings, text, footnotes, quotations) |
| CA6-COVER-001 | Case number centered at the top | FRAP 32(a)(2)(A) | `No. #case_number` |
| CA6-COVER-002 | Name of the court: UNITED STATES COURT OF APPEALS FOR THE SIXTH CIRCUIT | FRAP 32(a)(2)(B) | `court-name`, in a block 4.4 in. wide so it wraps after APPEALS (a width, not a break) |
| CA6-COVER-003 | Title of the case | FRAP 32(a)(2)(C) | `caption` |
| CA6-COVER-004 | Nature of the proceeding and the court below | FRAP 32(a)(2)(D) | `proceeding` |
| CA6-COVER-005 | Title of the brief identifying the party | FRAP 32(a)(2)(E) | `brief_title` |
| CA6-COVER-006 | Name, office address and telephone of counsel | FRAP 32(a)(2)(F) | `counsel` (`names`, `lines`) |
| CA6-COVER-007 | Cover color: white for an electronically filed reply brief | checklist: "Colored covers are not required for electronically filed briefs" (FRAP 32(a)(2) names gray for a reply; the court's checklist waives color for e-filed briefs) | cover is white |
| CA6-CONT-010 | Table of contents with page references; table of authorities (cases alphabetized, statutes, other authorities) with the reply's page references | FRAP 28(c); checklist "Brief components" | `toc-section`, `toa-section` (page numbers from the layout, not typed) |
| CA6-CONT-011 | Reply brief sections: Introduction, Argument, Conclusion (the reply does not repeat the principal brief's statements) | FRAP 28(c) and the checklist's brief components | `# Introduction`, `# Argument`, `# Conclusion` in the markdown |
| CA6-CONT-012 | Argument headings: point headings I., II. (bold, hanging from the margin); sub-headings A., 1., a. | convention; the court's exemplar (point headings hang, bold) | `heading-label`, `style-heading` |
| CA6-SIG-001 | Signature by the filing attorney: `s/Name` | 6 Cir. R. 25(d)(1) (as cited in the checklist, "Conclusion") | `signatures` (`s/ #signer`) |
| CA6-CERT-001 | Certificate of compliance: the word count and the typeface statement, immediately after the signature | FRAP 32(g)(1); 6 Cir. R. 32(a) ("must immediately follow the signature at the end of the brief") | `certificate-of-compliance`, placed directly after the signature block (no page break) |
| CA6-CERT-002 | Certificate of service, required only when service is not through the court's e-filing system | FRAP 25(d)(2) (checklist "Certificate of service") | `certificate-of-service`, only with `service.certificate: true` |

FRAP 32(g)(2) names Form 6 as an acceptable certificate; this template follows the content FRAP 32(g)(1) requires (the number of words, and the type-volume and typeface statements), and does not reproduce Form 6 itself.

## Files

- `typst/main.typ`: entry point. Reads the sample named by `--input sample=...`, splits frontmatter from body, calls the template.
- `typst/ca6-reply-brief.typ`: the template, `ca6-reply-brief(meta, md)`. Content-agnostic: every number is a named parameter at the top and traces to a rule (or is a style choice noted as such). No case-specific text, no coordinates taken from the exemplar, no forced line breaks.
- `usage/INPUT-ca6-reply-brief-smith.md`: the sample, transcribed from the exemplar.
- `usage/OUTPUT-ca6-reply-brief-smith.typst.pdf`, `-overlay.pdf`, `-overlay.txt`: render and overlay.
- `usage/`: the filed PDF and `SOURCE.md`.

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body.

Frontmatter:

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover "No.", PDF title |
| `caption` | yes | list of two sides; each has `names` (one centered line each, inline markdown allowed) and `designation` |
| `proceeding` | yes | "On Appeal from ..." on the cover |
| `brief_title` | yes | Cover title (capitals), certificate of service |
| `counsel` | yes | cover counsel groups: `names` and `lines` |
| `signatures` | yes | list of `signer` (printed as `s/ Name`) and `lines` (the block under it) |
| `date` | when `service.certificate` | certificate of service |
| `service` | no | `certificate: true` adds the certificate of service; `upon` is its list of served counsel |
| `authorities` | yes if the body cites any | the table of authorities; each key has `kind` (`case`, `constitution`, `statute`, `regulation`, `rule`, `other`), `name` (optional; italic for cases) and `cite` |

Body:

- `# Heading` is a section (Introduction, Argument, Conclusion), centered bold capitals. Under `# Argument`, `## ...` is a point heading (numbered I., II.), `###` is A., `####` is 1., `#####` is a. Sub-headings are numbered automatically; never type the numbers.
- Authorities: link the citation to `toa:KEY`, e.g. `[*Schlosser v. VRHabilis, LLC*, 113 F.4th 674 (6th Cir. 2024)](toa:schlosser)`; short forms link to the same key. An unregistered key stops the build.
- Footnotes: `text[^1]` and `[^1]: note`. Block quotations: `> text`.
- Smart punctuation is on. Escape a leading `$` as `\$` (dollar amounts).

## Decisions

- **Typeface: EB Garamond at 14 pt; no face named.** FRAP 32(a)(5)(A) and (a)(6) require a proportionally spaced serif at 14 pt and name no face. The Sixth Circuit Briefs Checklist ("Typefaces") says "a proportionally spaced font at 14 pt. (such as Times New Roman)"; "such as" is an example, not a requirement. So `docs/FONTS.md`'s "no face named" row applies and the template keeps the vendored EB Garamond (`fonts/eb-garamond/`). The exemplar is Times New Roman, so the overlay shows the glyph difference on every line; it is a face difference, not a layout one.
- **White cover.** FRAP 32(a)(2) calls for gray on a reply. The court's own checklist says colored covers are not required for electronically filed briefs, so the template follows the checklist.
- **Compliance certificate directly after the signature.** 6 Cir. R. 32(a) says it "must immediately follow the signature at the end of the brief", so there is no page break before it. The Conclusion and its signature are kept together as one block.
- **Certificate of service optional.** The exemplar has one (a CM/ECF service statement with the unregistered-party text left out); FRAP 25(d)(2) requires one only for service other than through the e-filing system. The sample includes it because the exemplar does.
- **Certificate counts.** The compliance certificate states the word count the template computes from the markdown. For this sample that is the transcribed portion (1,458 words), not the filed brief's count (4,576 words per the exemplar's certificate). A real filing must use the count from its own text.
- **No addendum section.** The exemplar has none, and the template does not implement one. Add it if a reply ever needs one.

## Overlay

`usage/OVERLAY-smith-reply-brief.txt` is the page map (`tools/overlay.sh` pairs each sample page with the exemplar page sharing the most words):

| Sample page | Exemplar page | Word overlap |
|---|---|---|
| 1 (cover) | 1 | 90.3% |
| 2 (TOC) | 2 | 50.0% |
| 3 (TOA) | 3 | 29.0% |
| 4–9 (Introduction, Argument I) | 4–9 | 69–89% |
| 10 (Conclusion, signatures) | 1 | 42.8% |
| 11 (Certificate of compliance) | 23 | 29.5% |
| 12 (Certificate of service) | 24 | 82.9% |

The page-10 pairing is a matcher artifact: the Conclusion's words are few, and the counsel names on the cover match them. The filed Conclusion is at printed page 19 of the exemplar. The overlay is a diagnostic. It shows where the two renders differ, and the sample is a portion of the brief, so the exemplar's later pages (Argument points II to IV) have no red counterpart.

## Known gaps and open findings

1. **Sample is a portion.** Argument points II to IV, and the rest of point I's text after the printed page 7 paragraph, are not transcribed. The table of contents and table of authorities list only what is in the sample. The brief asks for a sample that renders to 8–14 pages; this one renders to 12.
2. **Compliance certificate on its own page (page 8).** It does not fit below the signatures on page 7, so the certificate starts a new page. It still follows the signature in sequence (6 Cir. R. 32(a)). OPEN: compare with the filed brief, which keeps it on the signature page.
3. **Partly empty page 6.** The final paragraph of the Argument and the Conclusion are kept with the signature block, so page 6 ends early. This follows the rule that a signature does not stand alone; it is a deliberate choice, not a defect.
4. **One exemplar only.** The eval loop asks for two or three exemplars from different filers for tier 2. This box found one text-based filed reply brief in this court within the time available, and the brief for this unit asks for one. Tier 2 is OPEN until a second filer's reply is added.
5. **Emphasis from the exemplar.** The italic runs (*As discussed above*, *treatment*, *caused*, *result*, *i.e.*) were found by reading the PDF's italic font, not by reading the brief. They match the exemplar's `(emphasis added)` passages.
6. **Searches run.** CourtListener API (court `ca6`, RECAP search for "REPLY BRIEF" filings): five text-based candidates downloaded (*Smith v. PAM Transport*, 24-5549, 24 pp; *Linney's Pizza*, 25-6038, 52 pp; *Scoggins v. Menard*, 24-3760, 15 pp; *Bashaw v. Majestic Care*, 24-3292, 19 pp; *Blankenship v. Louisville-Jefferson*, 25-5014, 29 pp). *Smith* was chosen: it is short, text-based, and carries the full reply structure.

## Engines

Same rules and numbers as the typst template (the reference). **latex** (`latex/`, tectonic): EB Garamond 14 pt from `fonts/`; 10 pages against typst's 12; certificate word count 1,458 (same as typst). Differs: the cover is more compact at the top than typst's; the counsel block is narrower so a long name does not wrap; pagination differs, so TOC and TOA page numbers follow the latex body. **docx** (`docx/`): 12 pages, same as typst; fonts EB Garamond only; certificate word count 1,458 matches. Differs: TOA page numbers for Johnson (p. 7, typst 6), McNeal (p. 4, typst 3) and Fed. R. Evid. 801(d)(2) (pp. 6–7) follow the docx's pagination; signature-block gaps are approximate; copy-paste from the docx includes a word joiner in "32(a)(7)(B)"-style tokens. The addendum path is removed (the typst has none). BLOCKED: none; `tools/check.sh` cannot run here (no `checks.yaml`).

## Verification pass 2026-10-16 (fb-595.26.6)

- Re-rendered `usage/OUTPUT-ca6-reply-brief-smith.typst.pdf` with `tools/render.sh` (exit 0, no typst warnings): 12 pages, the same count and the same text on every page as the committed render (not stale). Overlay rerun: same page map as in the table above.
- All 12 pages viewed at 60 dpi; the 12 overlay pages viewed at 40 dpi, and overlay page 1 (cover against the filed cover) at 150 dpi. Cover fits one page; TOC page numbers (Introduction 1, Argument 3, I. 3, Conclusion 7, certificates 8 and 9) match the printed footers; TOA pages match the citing pages (McNeal 3, Schlosser 5, Johnson and Wyatt 6).
- Changed (shared typography with the other two doc types, no visible change in this sample): "14-point" in the certificate of compliance is kept on one line; the no-break rule for section signs now also covers "§§".
- Open (tier 2/3, not changed): the cover has no closing rule under the counsel block and sets the party designations and "Counsel for Appellants" in roman, where the filed cover uses a rule and italics. Known gaps 2 and 3 above still hold (certificate of compliance starts printed page 8; printed page 6 ends early).
- The latex PDF was re-rendered (10 pages, unchanged count); the docx outputs were not touched (no LibreOffice in this box).
