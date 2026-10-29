# akd: motion-brief

Doc type: **motion-brief**: a Rule 12(b) motion to dismiss with its memorandum of points and authorities, in the United States District Court for the District of Alaska (`akd`). The template is the memorandum (the document that carries the argument); the notice of motion is a separate two-page filing and is not generated. Folder: `courts/ninth-circuit/alaska/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (two filers; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: an excerpt of the 42-page memorandum (see Sample) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 11 pages each, on the generic FRCP brief (fb-595.92); vendored Times New Roman only, no warnings; latex and docx break every line and page where typst does (XENG-001..003 gated) |
| overlay | `just overlay` writes `.overlay/<this folder>/OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 11 of 11 on each engine (2026-10-29, the FRCP-base render: `reviews/2026-10-29.md`) |

Build and check (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/ninth-circuit/alaska/federal/district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/alaska/federal/district/motion-brief naec-motion-to-dismiss
```

## Governing rules

Primary source: the District of Alaska Local Civil Rules, "Effective October 15, 2025". Fetched 2026-10-14 from https://www.akd.uscourts.gov/sites/akd/files/local_rules/Local_Civil_Rules_10-2025.pdf (see the complaint README for the fetch note).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| L.Civ.R. 7.1(a)(1)-(2) | A motion states the requested relief and the applicable points and authorities. | The memorandum's Introduction, Background, Legal Standard and Argument; the relief is stated in the Introduction and Conclusion. |
| L.Civ.R. 7.1(b)(1) | A proposed order is not required with a Rule 12 motion. | Not generated. |
| L.Civ.R. 7.1(f) | "Oral Argument Requested" immediately below the title of a motion, if requested. | `cover`: `when: oral_argument`; not used in the sample. |
| L.Civ.R. 7.4(a)(1) | A Rule 12(b) motion memorandum must not exceed 35 pages or 10,000 words (reply 20 pages or 5,700 words). | Not counted by the template (no page or word counter). The exemplar's body is about 35 pages after the front matter; see the exemplar SOURCE.md. |
| L.Civ.R. 7.4(a)(4) | Page and word limits do not include the caption, signature blocks, tables of contents and authorities, Rand notices, or reproduced statutes. | Front matter is separately numbered (roman); the body restarts at 1. |
| L.Civ.R. 7.5(a)(1)(A)-(E) | Double-spaced; margins of at least 1 inch including footers; page number and case name and number footer on every page of a multi-page document; at least 13-point proportionally spaced font, "or the equivalent" (7.5(a)(1)(D); no face named, re-read 2026-10-15). | the base's one-inch margins; `size: 13`, `pitch: {body: 30, single: 15}`; `page_number` a running footer of three lines (the number, `{footer_title}`, `{case_name}, Case No. {case_number}`), its top 6 pt below the text, inside the bottom margin (`descent: 6`, fb-595.92). |
| L.Civ.R. 7.5(a)(2)(A) | Letter size, white paper. | the base's letter paper. |
| L.Civ.R. 7.5(b)(1)-(5) | First-page layout: counsel block upper left; court title; case number with the judge's initials; caption; title of the document. | `cover` in `typst/layout.yaml`: `{counsel}`, the court's name (`constants`), the caption (the case number and `{judge}` at right), `{title}`. |
| L.Civ.R. 7.5(c)(1)-(2) | Names and bar numbers beneath signatures; the attorney identifies each party represented. | `closing`: `{date}`, `signature.preamble`, the `/s/` line, `signature.lines` (including "Counsel for Defendants"). |
| L.Civ.R. 8.1(a) | Statute relied on, in parentheses under the title of a pleading. | `statute` under the title; the memorandum shows the Rule relied on, as the exemplar does not. (Not a pleading; kept for the motion's citation.) |
| Fed. R. Civ. P. 12(b)(1) | Lack of subject-matter jurisdiction is a defense, asserted by motion. Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_12 (the text of 12(b) and (b)(1) was read). | Cited in the Legal Standard and on the title line. |

Not generated: the notice of motion; a proposed order (not required for Rule 12 motions, L.Civ.R. 7.1(b)(1)); a certificate of service (the exemplar has none; the template generates one only when the frontmatter has a `certificate`, see Known gaps).

## Typeface

| Item | Value |
|---|---|
| Face required | None named. L.Civ.R. 7.5(a)(1)(D) asks for a 13-point, proportionally-spaced font "or the equivalent". `docs/FONTS.md` applies only where the rule names a face. The exemplar's Times look is not a requirement. |
| Vendored substitute | Not needed. Times New Roman, the house standard (`docs/FONTS.md` rule 6): `font-family = ("Times New Roman", "Liberation Serif")` (the pinned install; Liberation Serif from `fonts/liberation-serif/` as fallback). EB Garamond until fb-595.68. |
| Metric fit | Not applicable (no court-named face). |
| Verified | `pdffonts` (2026-10-29, the FRCP-base renders): typst and docx embed TimesNewRomanPSMT, -BoldMT and -ItalicMT; latex TeX Gyre Termes X (newtx, the same metrics) in the three shapes. |

## Layout

- Page i: counsel block (upper left, single-spaced), court title, caption (party column closed by a rule; case number and judge at right), document title, statute.
- Page ii: table of contents, generated from the headings (`outline` of levels 1 to 4), with page numbers.
- Page iii and on: table of authorities, generated from `toa:KEY` links in the body; cases alphabetical, then statutes (by section number, via the `sort` key), rules, regulations and other authorities. An authority cited on 7 or more pages prints "passim".
- Body from page 1: double-spaced paragraphs with a 0.5 inch first-line indent; headings: level 1 centered bold capitals (INTRODUCTION, BACKGROUND, ARGUMENT, CONCLUSION); level 2 Roman numerals (I.), level 3 letters (A.), level 4 numbers (1.), level 5 letters (a.); block quotations single-spaced and indented; footnotes 13 pt, single-spaced.
- The signature block follows the Conclusion: "Respectfully submitted" date line, the preamble, the `/s/` line, and the signer's details, kept together.

## Measured spacing

Single line 15 pt, double 30 pt at 13 pt (`pitch` in `typst/layout.yaml`, on the cross-engine model). The contents and authorities rows are single-spaced, 6 pt apart.

## Sample

`usage/INPUT-motion-brief.md` transcribes the exemplar memorandum's caption, counsel block, title and signature block; its Introduction (complete); Background, section I (the Outer Continental Shelf Lands Act, complete); the Legal Standard (complete, with footnote 5 of the filing as the footnote); the opening of Argument section I and its sub-section A (first paragraph); and the Conclusion. Omitted: Background sections II and III (and the filing's footnotes 3 and 4, which belong to Background III); Argument I.B, II and III; the rest of Argument I.A after its first paragraph. The filed table of contents and table of authorities are **not** transcribed as printed: the template rebuilds both from the sample (the filed page numbers are not reproduced because they refer to the full filing). The sample's table of authorities covers the authorities cited in the excerpt only (18 authorities: 11 cases, 4 statutes, 1 rule, 2 regulations). The filing itself is 42 pages; the excerpt renders to 11 pages.

## Overlay

`OVERLAY-naec-motion-to-dismiss.pdf`: red is our render, blue is the filed exemplar, black where both agree. Pages are paired by word overlap (`OVERLAY-naec-motion-to-dismiss.txt`). Our pages 1 to 11 map to filed pages 1, 2, 6, 9, 10, 11, 12, 13, 18, 19 and 42. The pairing is coarse (our page 3 matches filed page 6 at 23% overlap; our page 11 matches filed page 42 at 56%, because the sample's last page is the signature page and the filed signature page is 42). The overlay is a diagnostic, not a score. The layers differ on text lines because the exemplar's text is set on a different pagination.

## Visual review

The Gate 2 record of the FRCP-base render (every page of the typst, latex and docx renders) is
`reviews/2026-10-29.md`.

## Known gaps and open choices

1. **Only one exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The State of Alaska's motion to dismiss in the same case (Docket 59) is a second filer, but its memorandum was not in RECAP (404). Tier 2 is not judged against two filers.
2. **Font.** No face is named by L.Civ.R. 7.5(a)(1)(D); the template sets Times New Roman 13 pt (`docs/FONTS.md` rule 6; see Typeface and the complaint README, Known gap 2), the face of the exemplar's memorandum. Until fb-595.68 it used EB Garamond, which reads smaller at the same point size.
3. **Length.** The template does not count pages or words for L.Civ.R. 7.4(a)(1) (35 pages or 10,000 words, the tables, caption and signature excluded: neither alone is a hard limit). The full memorandum must be checked by hand before filing.
4. **Signature block.** Kept whole and with the last paragraph (the base's `keep_with_closing`): it follows the Conclusion on page 8.
5. **Certificate of service.** Not in the exemplar; not in the sample. The template generates one when the frontmatter has a `certificate: {text, signer}` map. The 2025 local rules call for a Certificate of Service only where service is not through CM/ECF (L.Civ.R. 5.1(c)(4), sealed filings served by other means); for an ordinary CM/ECF filing the Notice of Electronic Filing is the proof of service (5.1(c)(3)).
6. **Notice of motion.** The filing's notice (Document 57, 2 pages) is not generated; the template is the memorandum only.
7. **Footnotes.** Single-spaced at 13 pt. L.Civ.R. 7.5(a)(1)(A) does not mention footnotes; the convention is a choice.
8. **Heading style.** Level-2 headings are bold with Roman numerals; the exemplar's are bold too, with the same numbering scheme. ACCEPTED.
9. **Checks.** `tools/check.sh <this folder> --engine typst`, `latex` and `docx` exit 0 (fb-595.92); DEF-COVER-002 is reported, not gated (`eval.yaml`).
10. **File names.** The brief names the files `<id>.md`, `<id>.pdf` and `<id>-overlay.pdf`. The tools read and write `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (see `tools/render.sh` and `tools/overlay.sh`), so the tool names are used.
11. **Judge's standing orders** may change the form. Not reflected.

## Engines

The folder is on the generic federal district brief (`lib/layouts/frcp-motion-brief.yaml`, fb-595.17) and the shared
document model (docs/EVAL-LOOP.md, "Generated engines"): `typst/layout.yaml` names the base and overlays D. Alaska's
local rules, each with its rule; `typst/akd-motion-brief.typ` only names the face. `fb engines gen` writes `latex/`
(`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) from the merged layout; `eval.yaml` sets
`params.cross_engine: gate`, so latex and docx must break every line and page where typst does (XENG-001..003). The
docx is checked with LibreOffice only (Word is not available here).

## FRCP base (fb-595.92): moved

L.Civ.R. 7.5(a)(1)(C)'s footer is the base's running footer (fb-595.92, shared with the District of Oregon): a
`page_number.text` that names frontmatter fields and holds `<br>` lines, here the page number, the sample's
`footer_title`, and `case_name` with `case_number`, set the same way in typst (`lib/typst/xdoc.typ` footer-lines),
LaTeX (`\xd@foot`, `lib/latex/xdoc.lua`) and Word (the footer `lib/docx/xdoc.lua` writes); `page_number.descent` keeps
its three lines inside the bottom margin, 6 pt below the text, as the template set them before the move. Changes from
the earlier template: the sample's level-1 headings in capitals, as filed (the contents list them as written); the case
names of the authorities in italics in the frontmatter (`*..*`), a comma and the citation after them; the contents
indent "I." half an inch and "A." an inch (both filers); the designations half an inch in, and "v." before the party the
sample marks `versus` (both filers); the contents' "Page" label is gone (the model has none for the contents; the first
filer's contents have none either); the signature block now follows the Conclusion on page 8 (kept with the last
paragraph).
