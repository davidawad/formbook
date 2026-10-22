# ctd: motion-brief

Doc type: **motion-brief**: the memorandum of law in support of a motion in the United States District Court for the District of Connecticut (`ctd`), for a Rule 12(b) motion to dismiss. The template is the memorandum; the motion paper itself (the notice and relief sought) is a separate filing (see Governing rules). Folder: `courts/second-circuit/connecticut/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `usage/FILED-EXAMPLE-motion-brief.pdf` (see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: cover and caption, table of contents and table of authorities (generated), Preliminary Statement, Legal Standards, Argument A and B with footnotes 1 and 2, Conclusion, signature blocks, certification of service. Argument C and D are not transcribed (see Known gaps). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 13 pages (cover, TOC i, TOA ii and iii, body 1 to 9), typst 0.15.0, vendored Times New Roman only (embedded), no typst warnings; docx: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`, the same 13 pages, every line as typst |
| typeface | no face named by the rules; Times New Roman, the house face (vendored, embedded). See Known gaps 4 |
| overlay | ok: `usage/OVERLAY-whitfield-motion-brief.pdf` and `OVERLAY-whitfield-motion-brief.txt` (pairs by text; exemplar PDF `usage/FILED-EXAMPLE-motion-brief.pdf` fetched from the SOURCE.md URL on 2026-10-15) |
| pages reviewed | 11 of 11 (every page rendered at 60 dpi to PNG and viewed on 2026-10-15) |

Commands (run with `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/second-circuit/connecticut/federal/district/motion-brief usage/INPUT-motion-brief.md
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
| CTD-FORM-001 | L. Civ. R. 7(a)(5) | "memoranda shall be double-spaced (except headings, footnotes, and block quotes)". | `pitch-body = 27.6pt` (lib/typst/xengine.typ line boxes), no extra space between paragraphs. Headings, footnotes and block quotes are single spaced (`pitch-single = 13.8pt`, `pitch-note = 11.5pt`). |
| CTD-FORM-002 | L. Civ. R. 7(a)(5) | "text shall appear in at least 12 point font; footnotes shall appear in at least 10 point font." | `type-size = 12pt`; `note-size = 10pt` (`show footnote.entry`). Headings are pinned to `type-size` (typst's default heading scale is larger). |
| CTD-FORM-003 | EFPP I.F.2 | Fonts embedded in the PDF; base-14 fonts or legally embeddable fonts. | Times New Roman (vendored), embedded on both engines. See Known gaps. |
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
- Body: double spaced (27.6 pt pitch), first-line indent 0.5 in, no extra space between paragraphs. Level 1 headings centred bold caps; level 2 "A.", "B." with hanging labels; level 3 "1.", level 4 "a.". Headings single spaced, a blank single line above.
- Footnotes 10 pt single spaced; block quotations single spaced, indented 0.5 in both sides.
- Signature block: "Dated:" at the margin and "Respectfully submitted," in the signature column on one line, then each signer; kept in one block with the conclusion (from the last level 1 heading), so a sign-off never stands alone.
- Certification: a centred bold title not in the table of contents (the exemplar's is not), the text on the body pitch, the signer in the signature column; one block.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`, `court` (list), `caption` (list of `{names, designation}`), `brief_title`, `date`, `authorities` (registry, see below), `signature` (`signer`, `bar`, `lines`, optional `others`), `certification` (optional, `date`, `text`, `signer`, `lines`), `oral_argument` (optional).
- Authorities registry: `key: {kind: case|statute|rule|regulation|other, name: "...", cite: "..."}`. For a case, `name` is printed in italics and `cite` follows. Every key used in the body must appear here (the template fails otherwise).
- Body: `# ` = level 1 heading, `## ` = level 2, `### ` = level 3. Citations to authorities are links whose target is `toa:KEY`: `[Ashcroft v. Iqbal](toa:iqbal)`. The TOA page list is built from those links, so an authority cited without a link is missing from the TOA (the template cannot find it). Footnotes are markdown `[^n]` footnotes.
- Lists: `1)`-style and `1.`-style items are numbered "1)"; `-` bullets are bullets. Block quotations are `>`.
- Do not put heading numbers ("A.", "I.") in the text: the template numbers headings.

## Known gaps and open choices

1. **One exemplar.** The eval-loop tier-2 rule asks for two or three filers, each a different filer. The brief asks for one exemplar per doc type; the other D. Conn. filings checked (Succow v. Bondi, Doc. 57-1, a federal-defendant memorandum; Schuster v. Liberty Bank, Doc. 18-1, a partial motion) are in `usage/SOURCE.md` and were not saved. Tier 2 is judged against the rules and this filing.
2. **Sample is partial.** Argument C (pre-recorded calls) and D (standing for injunctive relief), the last pages of the memorandum, are not transcribed, to keep the render short (13 pages). The table of authorities lists only authorities cited in the transcribed text, so it is shorter than the exemplar's. The overlay pairing with the exemplar is coarse.
3. **Page limit not checked.** L. Civ. R. 7(a)(5) allows 40 pages excluding the TOC and TOA. The template does not count pages; the author must check before filing.
4. **Font.** No rule text read for this doc type names a face. EFPP I.F.2 (fetched 2026-10-15) lists Times New Roman among the base-14 fonts only as fonts that need not be embedded. Local Rule 7 and 10 name none in the text checked (the 9.4.26 rules PDF cited above returned 404 on 2026-10-15; re-verify against the live rules). The template sets Times New Roman, the house standard and the face of every exemplar (vendored, embedded), on both engines. Judge-specific orders are separate: the Electronic Filing Order of Judge Vanessa L. Bryant (revised 1/17/2018, fetched 2026-10-15, text in the order's own PDF) says "All documents must be typewritten using Arial bold 12 point font, double spaced" for documents in cases before her. That is one judge's order, not a court rule. Arial is substituted by Liberation Sans (`docs/FONTS.md`), but the template does not switch per judge: a memorandum filed before Judge Bryant must be set in Arial by hand, and that is a filer's choice to confirm with the assigned judge's order.
5. **Oral argument legend.** The rule places it on the motion; the exemplar memorandum has none. The template prints it only when `oral_argument` is set, so the sample does not show it.
6. **Date in caption.** The exemplar's caption has no date; L. Civ. R. 10 requires one. The template follows the rule.
7. **TOA coverage depends on the author.** The TOA is generated from `toa:` links only. An authority cited without a link is silently absent. A check that every registry key is used, and that every citation has a link, belongs in a future gate; none exists now.
8. **Signature page.** The conclusion and the signature block are one unbreakable block, so a conclusion that ends near the foot of a page moves on with the signatures (body page 7 is half free in the sample). Acceptable.
9. **Checks.** `sh tools/check.sh <folder> --engine typst|docx` runs on this folder (court.json and rules.md at the court root); both engines pass every gate.
10. **Footnote 1 link.** Footnote 1 carries a `toa:` link (Barton v. Delfgauw, 47 C.F.R. § 64.1200). The TOA lists its page (4) correctly in the render.
11. **Typographical errors kept.** "SOLICITION" (heading), "Comunity" and similar, and "Calls" in the transcribed text are as filed.

## Review of the rendered pages (13 of 13 on both engines, rendered at 40 dpi, the cover, tables, body pages 4 and 5 and the last three pages at 70 dpi, viewed on 2026-10-22 against `usage/FILED-EXAMPLE-motion-brief.pdf`)

| Page | What it is | Finding |
|---|---|---|
| 1 (cover, no number) | Court title, caption ("v." between blank lines, designations indented), case number, date and bold title | OK. No oral-argument legend (none set). |
| 2 (TOC, i) | TABLE OF CONTENTS, "Page"; five entries with dot leaders; Argument A and B hanging under their labels | OK. Page numbers match the body (1, 2, 4, 4, 6, 8) on both engines. |
| 3 (TOA, ii) | TABLE OF AUTHORITIES, "Page(s)"; Cases, italic names, hanging second lines | OK |
| 4 (TOA, iii) | Last case; Statutes, Federal Rules, Regulations | OK |
| 5 (body 1) | Opening paragraph, PRELIMINARY STATEMENT, items 1) and 2) | OK |
| 6 (body 2) | Items 3) and 4); LEGAL STANDARDS | OK |
| 7 (body 3) | Rest of Legal Standards | OK. Ends four lines short: ARGUMENT, heading A (four lines) and two lines of its paragraph do not fit and move on together. |
| 8 (body 4) | ARGUMENT; heading A; footnote 1 (10 pt) | OK |
| 9 (body 5) | Rest of A, the Gillam block quotation (single spaced, indented both sides); footnote 2 | OK |
| 10 (body 6) | Heading B; Worsham and Meyer | OK |
| 11 (body 7) | Griffin and Dobronski; "For these reasons" | OK. Half a page free: the conclusion is kept with the signature block. |
| 12 (body 8) | CONCLUSION; "Dated" and "Respectfully submitted," on one line; both signers | OK |
| 13 (body 9) | CERTIFICATION OF SERVICE; text; "/s/" and the signer's lines in the signature column | OK. Heading, text and signer kept together. |

ACCEPTED (tier 3): the exemplar underlines its title and its level 1 headings, puts "PRELIMINARY STATEMENT" etc. in the contents with dot leaders but without labels for the level 1 entries, and has no date in the caption (L. Civ. R. 10 requires one); the template keeps bold headings and the date.

## Engines

Both engines run on the shared cross-engine layout model (fb-595.68.25; docs/EVAL-LOOP.md, "Cross-engine gate"): `typst/ctd-motion-brief.typ` on `lib/typst/xengine.typ` (pitches, explicit block spacing, `listing-row` for the contents and authorities), `docx/motion-brief.lua` on `lib/docx/xengine.lua`, with the same numbers in twips. Times New Roman on both (the docx had named EB Garamond): 12 pt text in 27.6 pt line boxes (L. Civ. R. 7(a)(5): double-spaced), headings, quotations, table rows and signature lines in 13.8 pt boxes (single-spaced, as the rule allows), footnotes 10 pt in 11.5 pt boxes 4 pt apart; a blank single line above a heading, a quotation, a table row or group; a blank body line around the signature block and the certification; the page number centred 0.5 in above the bottom edge.

**docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, `{font}`, `pandoc-from` CommonMark with smart punctuation and footnotes, as cmarker reads the body) holds the styles; fb render builds the reference document from it. `docx/motion-brief.lua` writes the cover, the tables, the headings, the lists, the quotations, the signature block and the certification, and the sections: the cover unnumbered (fb render's `rIdFtrNone`, or a legend footer when `oral_argument` is set), the tables in lower roman, the body from 1 (`$FORMBOOK_FINAL`, the page-number footer in `$FORMBOOK_FOOTERS`). The tables' page numbers come from needles (`$FORMBOOK_NEEDLES`: the table titles, the body's first words, each heading, each `toa:` citation, in document order), which replace `docx/render.sh` and `pagemap.awk`. No shell script.

`fb diff --engines`: 13 pages each, 0 page ends differ, 261/261 typst lines identical; the contents and authorities pages have the same text and page numbers. `eval.yaml` sets `params.cross_engine: gate`. Not verified in Word (only LibreOffice); Word may paginate a line differently, and the table page numbers are text, not fields.
