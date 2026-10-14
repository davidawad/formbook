# ctd: motion-brief

Doc type: **motion-brief**: the memorandum of law in support of a motion in the United States District Court for the District of Connecticut (`ctd`), for a Rule 12(b) motion to dismiss. The template is the memorandum; the motion paper itself (the notice and relief sought) is a separate filing (see Governing rules). Folder: `courts/second-circuit/connecticut/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `exemplars/FILED-EXAMPLE-whitfield-3-26-cv-00324-motion-brief.pdf` (see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-whitfield-motion-brief.md`: cover and caption, table of contents and table of authorities (generated), Preliminary Statement, Legal Standards, Argument A and B with footnotes 1 and 2, Conclusion, signature blocks, certification of service. Argument C and D are not transcribed (see Known gaps). |
| render | ok: `samples/OUTPUT-whitfield-motion-brief.pdf`, 11 pages (cover, TOC i, TOA ii, body 1 to 6, signature 7, certification 8), typst 0.15.0, vendored EB Garamond only (`pdffonts`: EBGaramond Regular, Italic and Bold, embedded), no typst warnings |
| overlay | ok: `samples/OVERLAY-whitfield-motion-brief.pdf` and `OVERLAY-whitfield-motion-brief.txt` |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi and viewed after the last template change) |

Commands (run with `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/second-circuit/connecticut/federal/district/motion-brief samples/INPUT-whitfield-motion-brief.md
sh tools/overlay.sh courts/second-circuit/connecticut/federal/district/motion-brief whitfield-motion-brief
```

File names follow the repo tools, as in `complaint/README.md`: `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt`, and `INPUT-<id>.md`.

## Governing rules

Primary sources, fetched 2026-10-14:
- D. Conn. Local Rules of Civil Procedure (rules PDF "Current-Revised-Local-Rules-9.4.26"), https://www.ctd.uscourts.gov/sites/default/files/Current-Revised-Local-Rules-9.4.26.pdf. Rules 7(a), 7(d) and 10 quoted below.
- Electronic Filing Policies and Procedures, rev. Oct. 3, 2025, https://www.ctd.uscourts.gov/sites/default/files/Electronic-Filing-Policies-and-Procedures-10.3.25.pdf (sections I.F.2, II, XI.B).
- Fed. R. Civ. P. 12(b), retrieved from https://www.law.cornell.edu/rules/frcp/rule_12 (quoted: "(1) lack of subject-matter jurisdiction ... (6) failure to state a claim upon which relief can be granted"). Fed. R. Civ. P. 5(b)(2)(E), https://www.law.cornell.edu/rules/frcp/rule_5 (service by filing with the court's electronic-filing system; service is complete upon filing).

| ID | Rule | Requirement | Where it is in the template |
|---|---|---|---|
| CTD-FORM-001 | L. Civ. R. 7(a)(5) | "memoranda shall be double-spaced (except headings, footnotes, and block quotes)". | `line-pitch = 27.6pt`, paragraphs `spacing: body-leading` so the gap between paragraphs is a full pitch. Headings, footnotes and block quotes are single spaced. |
| CTD-FORM-002 | L. Civ. R. 7(a)(5) | "text shall appear in at least 12 point font; footnotes shall appear in at least 10 point font." | `type-size = 12pt`; `footnote-size = 10pt` (`show footnote.entry`). Headings are pinned to `type-size` (typst's default heading scale is larger). |
| CTD-FORM-003 | EFPP I.F.2 | Fonts embedded in the PDF; base-14 fonts or legally embeddable fonts. | EB Garamond (vendored, OFL), embedded. See Known gaps. |
| CTD-FORM-004 | L. Civ. R. 10 | "margins of at least 1"". | `margin = 1in` on all sides. |
| CTD-FORM-005 | L. Civ. R. 7(a)(5) | Page limit: "no more than forty (40) 8 1/2" by 11" printed pages, exclusive of pages containing a table of contents, table of statutes, rules or the like." | Not enforced: the template does not count pages (see Known gaps). |
| CTD-FIRST-001 | Fed. R. Civ. P. 10(a) | Caption with court name, title, file number and designation. | `court`, `caption` (every party), `brief_title`, `case_number`. |
| CTD-FIRST-002 | L. Civ. R. 10 | "The complete docket number, including the initials of the Judge to whom the case has been assigned, shall be typed on each pleading. The date of each pleading shall be included in the case caption." | `case_number` (with judge initials, as given) and `date` in the caption right column. The exemplar's caption has no date; the template follows the rule. |
| CTD-FIRST-003 | L. Civ. R. 7(a)(1), 7(a)(2) | Motion: "shall indicate in the lower margin of the motion whether oral argument is requested." Opposition memoranda: the same, on the first page. | `oral_argument` (optional frontmatter) prints "ORAL ARGUMENT REQUESTED" or "NOT REQUESTED" in the lower margin of the cover. The rule places this on the motion; the template offers it on the memorandum's cover for the single-document case. Not in the exemplar. |
| CTD-CONT-001 | L. Civ. R. 7(a)(1) | A motion involving disputed issues of law "shall be accompanied by a memorandum of law". | Template is the memorandum. The notice of motion and relief sought are not produced here. |
| CTD-CONT-002 | L. Civ. R. 7(d) | Replies: "may not exceed 10 pages". | Not this template (a reply template would reuse it). |
| CTD-CONT-003 | Convention (not a D. Conn. rule) | Table of contents and table of authorities for a memorandum of this length. The exemplar has both. | `toc-section()` from headings; `toa-section()` from `toa:KEY` links in the body; `passim` at 7 or more pages. |
| CTD-SIG-001 | L. Civ. R. 10; EFPP XI.B | "BY: /s/" name, typewritten name, office address, telephone, fax, e-mail, federal bar number. | `signature` (`signer`, `bar`, `lines`, optional `others` for a second signer). |
| CTD-CERT-001 | L. Civ. R. 5(c); Fed. R. Civ. P. 5(b)(2)(E) | Proof of service "by a certificate of counsel"; where service is made on all parties through CM/ECF, "the transmission notice on the Notice of Electronic Filing shall be deemed a sufficient certificate of service." Service through the electronic-filing system is complete upon filing (Rule 5(b)(2)(E)). A separate certificate is needed only for a party not served through CM/ECF. | `certification` (optional frontmatter): "CERTIFICATION OF SERVICE", text, signer. The sample includes it as filed. |

## Layout

- Cover (page 1, no number): court title, caption (left party column with indented designations, right column with case number, date and title in bold caps), optional oral-argument legend in the lower margin.
- Front matter: table of contents (roman i), table of authorities (roman ii on). Body from arabic 1, page numbers centred in the bottom margin.
- Body: double spaced (27.6 pt pitch), first-line indent 0.5 in, paragraphs separated by a full pitch. Level 1 headings centred bold caps; level 2 "A.", "B." with hanging labels; level 3 "1.", level 4 "a.". Headings single spaced.
- Footnotes 10 pt single spaced; block quotations single spaced, indented 0.5 in both sides.
- Signature block unbreakable, "Dated:" left, "Respectfully submitted," and each signer right; the block moves to a new page when the conclusion ends near the foot of a page (memorandum page 7, PDF page 10).
- Certification: a level-1 heading not in the table of contents (the exemplar's is not), flush text, signature block right-aligned.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`, `court` (list), `caption` (list of `{names, designation}`), `brief_title`, `date`, `authorities` (registry, see below), `signature` (`signer`, `bar`, `lines`, optional `others`), `certification` (optional, `date`, `text`, `signer`, `lines`), `oral_argument` (optional).
- Authorities registry: `key: {kind: case|statute|rule|regulation|other, name: "...", cite: "..."}`. For a case, `name` is printed in italics and `cite` follows. Every key used in the body must appear here (the template fails otherwise).
- Body: `# ` = level 1 heading, `## ` = level 2, `### ` = level 3. Citations to authorities are links whose target is `toa:KEY`: `[Ashcroft v. Iqbal](toa:iqbal)`. The TOA page list is built from those links, so an authority cited without a link is missing from the TOA (the template cannot find it). Footnotes are markdown `[^n]` footnotes.
- Lists: `1)`-style and `1.`-style items are numbered "1)"; `-` bullets are bullets. Block quotations are `>`.
- Do not put heading numbers ("A.", "I.") in the text: the template numbers headings.

## Known gaps and open choices

1. **One exemplar.** The eval-loop tier-2 rule asks for two or three filers, each a different filer. The brief asks for one exemplar per doc type; the other D. Conn. filings checked (Succow v. Bondi, Doc. 57-1, a federal-defendant memorandum; Schuster v. Liberty Bank, Doc. 18-1, a partial motion) are in `exemplars/SOURCE.md` and were not saved. Tier 2 is judged against the rules and this filing.
2. **Sample is partial.** Argument C (pre-recorded calls) and D (standing for injunctive relief), the last pages of the memorandum, are not transcribed, to keep the render at 11 pages. The table of authorities lists only authorities cited in the transcribed text, so it is shorter than the exemplar's. The overlay pairs render pages 4 to 9 (body 1 to 6) with exemplar pages 7 to 12, and render pages 10 and 11 (signature and certification) with exemplar page 19; the pairing is coarse.
3. **Page limit not checked.** L. Civ. R. 7(a)(5) allows 40 pages excluding the TOC and TOA. The template does not count pages; the author must check before filing.
4. **Font.** EFPP I.F.2 names Times New Roman among the base-14 fonts. The only font vendored in `fonts/` is EB Garamond (embedded). At 12 pt it looks smaller than Times. A Times-metric font vendored into `fonts/` would remove this difference; that is a David decision (vendoring).
5. **Oral argument legend.** The rule places it on the motion; the exemplar memorandum has none. The template prints it only when `oral_argument` is set, so the sample does not show it.
6. **Date in caption.** The exemplar's caption has no date; L. Civ. R. 10 requires one. The template follows the rule.
7. **TOA coverage depends on the author.** The TOA is generated from `toa:` links only. An authority cited without a link is silently absent. A check that every registry key is used, and that every citation has a link, belongs in a future gate; none exists now.
8. **Signature page.** The unbreakable signature block moves to its own page when the conclusion ends near the foot of a page (memorandum page 7, PDF page 10). Acceptable, but a clerk would see a page with only a signature block.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither, and the brief forbids touching `tools/`. Render, overlay and the page review are the Gate 2 equivalent.
10. **Footnote 1 link.** Footnote 1 carries a `toa:` link (Barton v. Delfgauw, 47 C.F.R. § 64.1200). The TOA lists its page (4) correctly in the render.
11. **Typographical errors kept.** "SOLICITION" (heading), "Comunity" and similar, and "Calls" in the transcribed text are as filed.

## Review of the rendered pages (11 of 11, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 (cover, no number) | Court title, caption with designations indented, case number, date and bold title | OK. No oral-argument legend (none set). |
| 2 (TOC, i) | Table of contents: five entries with dot leaders, page column "Page", the long Argument A heading hanging under its label | OK. Page numbers match the body (1, 2, 3, 3, 5, 6). |
| 3 (TOA, ii) | Cases, Statutes, Federal Rules, Regulations; page numbers right; italic case names; "passim" not needed | OK. Entries wrap under the title with a hanging indent. |
| 4 (body 1) | Introduction paragraph (indented), PRELIMINARY STATEMENT, the list 1) to 3) | OK. Heading size matches body text after the fix. |
| 5 (body 2) | List item 4); LEGAL STANDARDS; the citations with links and italic *Id.* | OK. |
| 6 (body 3) | End of Legal Standards; ARGUMENT; heading A (three lines, bold caps); opening paragraph of A | OK. Heading at the top of the page is kept with the paragraph after it. |
| 7 (body 4) | Continuation of A; block quotation (single spaced, indented); footnote 1 at the foot of the page | OK. Footnote 10 pt. |
| 8 (body 5) | End of A with footnote 2; heading B (two lines); the start of B | OK. |
| 9 (body 6) | Rest of B; CONCLUSION | OK. |
| 10 (signature) | Dated; "Respectfully submitted"; "BY: /s/" and the name with Fed. Bar No.; second signer | OK. The block starts a new page (see Known gaps, item 8). |
| 11 (certification, page 8 of the memorandum numbering) | CERTIFICATION OF SERVICE; text; right-aligned /s/ signature | OK. |
