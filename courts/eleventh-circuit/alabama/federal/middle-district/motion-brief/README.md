# almd: motion-brief

Doc type: **motion-brief**, the brief in support of a Rule 12(b) motion to dismiss, in the United States District Court for the Middle District of Alabama (`almd`).
Folder: `courts/eleventh-circuit/alabama/federal/middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: two filed motion memoranda from different filers, `usage/FILED-EXAMPLE-motion-brief.pdf` and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: an excerpt of the Nutrien brief (caption, introduction, procedural history, standard of review, Argument I and II through the block quotation, then the conclusion, signature, of-counsel block and certificate of service). Sections III and IV are omitted and marked in the sample |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 10 pages, `tools/render.sh` exit 0, no typst warnings, embedded fonts EB Garamond only |
| overlay | ok: `usage/OVERLAY-nutrien-motion-brief.pdf` and `usage/OVERLAY-nutrien-motion-brief.txt` (against the Nutrien exemplar) |
| pages reviewed | 10 of 10: every page rendered at 60 dpi and viewed after the last template change |

File names follow the repo's tools and `CLAUDE.md` file roles (`INPUT-`, `OUTPUT-`, `OVERLAY-`), not the `<id>.md` names in the brief, because `tools/render.sh` and `tools/overlay.sh` read and write those names.

## Governing rules

Verified 2026-10-14. Sources:

- **M.D. Ala. Local Rules**: https://www.almd.uscourts.gov/sites/default/files/forms/ALMD%20Local%20Rules.pdf, linked from https://www.almd.uscourts.gov/forms/local-rules, which gives "Effective Date: December 1, 2010". The PDF we could read is a 2011 print ("All Rules for Review--Redacted"). The court's Civil Administrative Procedures page (https://www.almd.uscourts.gov/forms/almd-civil-administrative-procedures) was read and says nothing on typeface, margins, spacing or briefs. **Verify against the current rules before relying on them.**
- **Federal Rules of Civil Procedure**: Cornell LII (https://www.law.cornell.edu/rules/frcp/rule_10, `rule_11`, `rule_5`), text checked 2026-10-14.

| ID | Source | Requirement | Kind | Where in the template |
|---|---|---|---|---|
| FRCP-10a | FRCP 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; a later paper names the first party on each side and may refer generally to others. | M | `court`, `caption`, `title`; `caption()`, `court-title()` |
| FRCP-11a | FRCP 11(a) | Signed by at least one attorney of record, with the signer's address, e-mail and telephone. | M | `signature`, `of_counsel`; `signature-block()`, `of-counsel()` |
| FRCP-5d | FRCP 5(d)(1)(B) | "No certificate of service is required when a paper is served by filing it with the court's electronic-filing system." | C (the exemplars include one) | `certificate`; `certificate()` |
| LR-5.6 | M.D. Ala. LR 5.6 | 8-1/2 x 11 inch white paper, flat, not stapled; "double-spaced, except for quoted material"; each page numbered consecutively. | M | `page(paper: "us-letter")`, page numbers, body leading (32.2 pt baseline pitch at 14 pt), block quotations single-spaced |
| LR-7.1a | M.D. Ala. LR 7.1(a) | A Conflict Disclosure Statement with the initial pleading or other paper (form in Appendix A). | M (author) | Not produced: a separate filing. |
| LR-5.2a | M.D. Ala. LR 5.2(a) | Redact SSNs to the last four digits, minors' names to initials, dates of birth to the year, financial account numbers to the last four digits, and an individual's address to city and state where relevant. | M (author) | Not templated. |

The local rules set no typeface, type size, margin, or length limit for a brief (the full text was searched for "font", "point", "margin", "inch", "page", "words"). Type size and margins are therefore tier 2 (convention), and no length limit is checked. Motion practice in this district may be set by judges' standing orders, which were not checked.

## Tier 1 (mandated form)

Built into the template: letter paper, one-inch margins, consecutive page numbers, double spacing, the FRCP 10(a) caption, the FRCP 11(a) signature block, and the certificate of service in the exemplars' form. Not built in, and each is a separate document: the conflict disclosure statement (LR 7.1) and the redaction of identifiers (LR 5.2). The motion itself is not part of this folder.

Mechanical checks: none in this folder. The only check run is an ad hoc word comparison: the sample body's word tokens all occur in the PDF at least as often (`pdftotext` of the render against the markdown with frontmatter removed). No body token is missing.

## Tier 2 (professional convention), judged against the two filed memoranda

| Convention | Nutrien (filer 1) | Beasley Allen memorandum (filer 2) | This template | Verdict |
|---|---|---|---|---|
| Court title centered | centered, bold | not checked (text only) | centered, bold | matched to Nutrien |
| Caption: names left, ")" column, "v.", case number right | yes; "Case No.:" right | not checked (text only) | yes; "Case No.:" right | matched to Nutrien |
| Body type size and double spacing | 14 pt (32.2 pt pitch) | 14 pt (32.2 pt pitch) | 14 pt EB Garamond, 32.2 pt pitch | matched |
| Title of the paper | bold, underlined | not checked | bold, not underlined | ACCEPTED: underlining seen in one filer only |
| "INTRODUCTION" and other level-1 headings | bold, centered | not checked | bold, centered | matched to Nutrien |
| Argument headings I., II. | not checked page by page | not checked | bold, flush left, hanging indent, numbers typed in the sample | ACCEPTED: open choice; not compared with a filed heading |
| Block quotation | indented (text layer; spacing not checked) | not checked | indented 0.5 in both sides, single-spaced | matched to Nutrien in indent only |
| Signature: "/s/", ASB numbers, "Attorneys for ..."; "OF COUNSEL" block; certificate of service with e-filing wording | yes (text layer) | not checked | yes | matched to Nutrien (text) |

The Beasley Allen memorandum was measured (line pitch, type size, text layer) but not overlaid and not compared page by page. Its only contribution is the type-size convention. The caption, heading and certificate conventions rest on the Nutrien filing alone, together with the two complaint captions in the sibling folder. That is one filer for these checks, and it is stated here rather than hidden.

Overlay (`usage/OVERLAY-nutrien-motion-brief.pdf`): pages 1 to 8 pair with exemplar pages 1 to 8 (71% to 97% word overlap). Pages 9 and 10 pair with exemplar page 29 (the conclusion and certificate), because the excerpt omits Sections III and IV. The differences in pages 1 to 8 are flow and leading: tier 3.

## Engines

- **typst** (primary): `typst/`, unchanged. Renders `usage/OUTPUT-motion-brief.typst.pdf` (10 pages).
- **docx**: `docx/reference.docx` (built by `sh docx/make-reference.sh`), `docx/almd.lua`. Writes `usage/OUTPUT-motion-brief.docx` from `usage/INPUT-motion-brief.md`. Needs pandoc, unzip, zip, xmllint and perl on PATH, and EB Garamond installed where the file is opened.
  - Matches the typst values, set in the reference and the filter: EB Garamond 14 pt; US Letter with 1-inch margins; body lines double-spaced at 32.2 pt exact, 0.5 in first-line indent, 23.1 pt between paragraphs; the title and the court title centered and bold; the FRCP 10(a) caption as a borderless three-column table (3.4 in, 0.15 in, 2.95 in) with "Case No.:"; headings: level 1 centered and bold, levels 2 and 3 flush left with a hanging half inch; a block quotation single-spaced and indented 0.5 in on both sides; the date line; the signature block; the "OF COUNSEL" block; the certificate of service; a centered page number in the footer.
  - Differs or unknown: none checked on a rendered page yet (see BLOCKED). Word and LibreOffice may break lines and pages differently from typst. The argument headings keep the typed "I." and "A." of the sample, as the typst template does. No table of contents or table of authorities is built (the sample has none); a brief that needs one needs a field or a written table, and this folder has neither yet.
  - Checked so far: the package unzips, every XML part is well formed, and the text reads back in order (`pandoc -f docx -t plain`), with the caption, the date line, the "OF COUNSEL" block and the certificate in place.
  - BLOCKED: `BLOCKED: docx.pdf checks (Gates 0 to 3 on usage/OUTPUT-nutrien-motion-brief.docx.pdf): LibreOffice (soffice) cannot be installed on this box. conda-forge has no LibreOffice package, and apt needs root. So no .docx.pdf was made, no page was rendered to PNG, and tools/check.sh --engine docx cannot run. Pages reviewed: 0 of 10.` The .docx must still be opened in LibreOffice and Word, with the result recorded under `## sample nutrien-motion-brief docx` in a review file (none exists in this folder yet).

## Known gaps

- The sample is an excerpt, not a full brief. Sections III and IV, with their subsections, are not transcribed. The template is tested on the excerpt's structure only: no footnotes, no table of contents or table of authorities, and no level-4 headings.
- Argument headings are numbered by hand in the sample (I., A.). The template does not number them.
- Judge-specific page limits or formatting in standing orders were not checked, and the local rules copy is effective 2010 (per the court's page). Check against the current rules.
- The motion itself, the conflict disclosure statement (LR 7.1) and the redaction of identifiers (LR 5.2) are not produced.
- No second structural sample and no machine check (`checks.yaml`, Gate 0 to 3) exist for this folder.
