# U.S. Bankruptcy Appellate Panel of the Sixth Circuit (bap6): answering brief (appellee's brief)

Doc type `answering-brief` of `courts/sixth-circuit/bankruptcy-appellate-panel`. Self-contained: the court-root `typst/` and `usage/` are not touched.

**Exemplar: yes.** Appellees' Brief, filed 2019-08-30, 15 pages, *In re Chieftain Steel, LLC, et al.*, BAP No. 19-8005 (see "Exemplar" below and `usage/SOURCE.md`).

| Gate | Result |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-answering-brief.pdf` |
| render | ok: `sh tools/render.sh courts/sixth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-answering-brief.md` ran with typst 0.15.0 (vendored fonts), produced `usage/OUTPUT-answering-brief.typst.pdf` (13 pages), zero warnings |
| overlay | ok: `sh tools/overlay.sh courts/sixth-circuit/bankruptcy-appellate-panel/answering-brief chieftain-steel-19-8005` wrote `usage/OVERLAY-chieftain-steel-19-8005.pdf` (13 pages) and `.txt` |
| pages reviewed | 13 of 13 rendered pages viewed as PNG (70 dpi); overlay pages viewed as pairs (80 dpi) |

## Files

| Path | What |
|---|---|
| `usage/FILED-EXAMPLE-answering-brief.pdf` | The filed brief, public, with a text layer. |
| `usage/SOURCE.md` | URL, case, docket, filer, date filed, date fetched, SHA-256. |
| `usage/INPUT-answering-brief.md` | Transcription of the filed brief (see "Exemplar"). |
| `usage/OUTPUT-answering-brief.typst.pdf` | `tools/render.sh` output. |
| `usage/OVERLAY-chieftain-steel-19-8005.pdf`, `.txt` | `tools/overlay.sh` output: red = ours, blue = filed, black = both. The `.txt` maps each of our pages to its best-matching filed page. |
| `typst/main.typ`, `typst/bap6-answering-brief.typ` | Entry point and template. |

Build (from the repo root, toolchain on PATH): `sh tools/render.sh courts/sixth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-answering-brief.md`. The render uses only vendored fonts (Times New Roman) (`--ignore-system-fonts`); any typst warning fails it.

## Governing rules

Verified 2026-10-14. Sources: Fed. R. Bankr. P. 8014 and 8015 (amended eff. Dec. 1, 2024), read at `https://www.law.cornell.edu/rules/frbp/rule_8014` and `https://www.law.cornell.edu/rules/frbp/rule_8015`; BAP Local Rules, "As Amended December 1, 2014" (`https://www.ca6.uscourts.gov/sites/ca6/files/documents/bap/BapLocalRules.pdf`, read as extracted text); BAP Practice Guidelines, Rev. August 2018 (`https://www.ca6.uscourts.gov/sites/ca6/files/documents/bap/2018%20BAP%20Practice%20Guidelines%20.pdf`).

| Requirement | Rule | Where in the template |
|---|---|---|
| Cover: case number, court, case title, nature of the proceeding and court below, the brief's title naming the party, counsel's name, address and phone | FRBP 8015(a)(2) | `cover` |
| Corporate disclosure statement, when required | FRBP 8012; 8014(a)(1) | `disclosure` page, only when given |
| Table of contents with page references | FRBP 8014(a)(2), (c) | `toc-section` |
| Table of authorities (cases alphabetical, statutes, other) | FRBP 8014(a)(3), (c) | `toa-section` |
| Statement regarding oral argument, one page at most, after the TOA | FRBP 8019(a); LBR 8014-1(b) | `oral_argument` page |
| Typeface: proportionally spaced serif, 14-point or larger; plain roman, case names italic | FRBP 8015(a)(5)(A), (a)(6) | `font-family`, `type-size`, `brief-style` |
| Double spacing; margins at least one inch | FRBP 8015(a)(4); LBR 8014-1(d) | `body-leading`, `page-margin` |
| Word limit: 13,000 words, or 6,500 for a reply | FRBP 8015(a)(7)(B) | `word-limit`, checked by `brief` |
| Words excluded from the limit | FRBP 8015(g) | `count-words` runs over the body only |
| Certificate of compliance (word count and typeface) | FRBP 8015(h) | "Certificate of Compliance" |

**Conflict: type size.** LBR 8014-1(d) (2014) says "a font not less than 12 points". FRBP 8015(a)(5)(A) (restyled eff. Dec. 1, 2024) says a proportionally spaced face "must be 14-point or larger". The template uses 14 point. The federal rule is taken to govern the local one. That choice is ours, not a ruling; David should confirm it. The Practice Guidelines (§ VI(c)) repeat the 12-point figure and predate the 2024 rule.

**Calibration: double spacing.** Measured on the render with `pdftotext -bbox`: a line in this font advances `0.65em` plus the paragraph `leading`. Single spacing is therefore `1.3em` (18.2 pt at 14 pt) and double is `2.6em` (36.4 pt). `body-leading` is `1.95em`, and paragraph `spacing` equals `body-leading`, so paragraph breaks keep the same 36.4 pt pitch. Consecutive body lines measure 36.4 pt apart.

Required body sections (FRBP 8014(b), checked by the build): Summary of Argument, Argument, Conclusion. The other items need not appear unless the appellee is dissatisfied with the appellant's statement. The statement regarding oral argument is optional for an answering brief (see Template changes).

Note: the copied sample's cover first read "Brief of Appellant"; it was corrected in the sample frontmatter to "Brief of Appellee".

## Markdown contract

One `.md` file: YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | Cover, "Case No." line |
| `caption` | yes | list of two sides, each `names` (list) and `designation`; "v." is inserted between them |
| `proceeding` | yes | Cover: nature of the proceeding and the court below |
| `brief_title` | yes | Cover title, printed in capitals (FRBP 8015(a)(2)) |
| `counsel` | yes | list of groups, each `names` and `lines` |
| `phone` | yes | Cover, after counsel |
| `signature` | yes | `signer` and `lines`; printed as "s/ Name" after the body and on each certificate |
| `date` | no | Under the signature and on the certificate of service |
| `disclosure` | no | Corporate disclosure statement (FRBP 8012, through 8014(a)(1)); a page before the TOC when given |
| `oral_argument` | yes for opening; optional for answering (see Template changes) | Statement regarding oral argument, after the TOA (LBR 8014-1(b)). Not used for a reply. |
| `authorities` | yes if the body cites any | Registry: key → `kind` (case, constitution, statute, regulation, rule, other), `name` (optional), `cite`, `sort` (optional). A `[text](toa:KEY)` link with no registry entry stops the build; a registry entry never cited stops the build. |
| `service` | no | `true` adds a certificate of service |

Body: `# Heading` (level 1) sections; `##`, `###`, `####` below. Heading numbers are typed by the author (the template does not number them). Required sections are checked and the build stops when one is missing. `# Addendum` ends the brief: it is rendered after the certificates and is not counted. Footnotes are not supported. Words are counted over the body (headings included, FRBP 8015(g)); the build stops above the limit.

## Exemplar

Filed by counsel of record in the case. Appellees' Brief, filed 2019-08-30, 15 pages. *In re Chieftain Steel, LLC, et al.*, BAP No. 19-8005 (appeal from Bankr. W.D. Ky., Originating Case No. 16-10407). Copy: `usage/FILED-EXAMPLE-answering-brief.pdf`; source, dates and hash in `usage/SOURCE.md`.

Transcription (`usage/INPUT-answering-brief.md`) covers, in the filed order: the filing's cover, disclosure, statement of the issues, statement of the case (pp. 1–5, abridged), standard of review, summary of argument, the first part of the argument (pp. 6–8, abridged: the cash collateral orders and the plan), and the conclusion (p. 11).

Not transcribed: pp. 8–10 (the plan's release, the cases the appellants cite), the filed table of contents and table of authorities (the template generates both), and the filed certificate of service (replaced by the template's own).

Frontmatter (`caption`, `counsel`, `signature`, `date`, `disclosure`, `oral_argument` where the filing has them) copies the filed cover. The template's own certificate of compliance and certificate of service follow the body.

## How the exemplar was found (2026-10-14)

- Web search (standard, then extended) for BAP appellate briefs in this court. The appellees' brief is in the same case folder on law.uky.edu, found by filename once the opening brief was located.
- The file names on law.uky.edu follow one pattern, `19-8005 <Document>.pdf`. The other two briefs were fetched by that pattern. Each PDF was checked with `pdfinfo` and `pdftotext`: caption, BAP No., ECF header and filing date match.
- Ruled out before this: CourtListener API (no response from the sandbox) and HTML search (HTTP 403); Justia dockets (HTTP 403); general BAP results (local rules, practice guidelines, the pro se form, opinions). None gave a filed brief.

## Template changes (this pass)

The overlay and the page renders exposed these. All three templates changed the same way, so they stay in step.

1. **Cover spacing.** The opening cover ran onto a second page (the date line). Gaps tightened: caption stack 1.1em to 0.9em, counsel groups 1.2em to 0.9em, the gap before the date 1.4em to 0.8em. The cover is one page in all three.
2. **TOC entries.** Dot leaders were a single line, so a long entry that wrapped left its page number on a line of its own. Entries are now a two-column grid with the page number in the right column. The dot leaders are gone, and wrapped lines stay flush left.
3. **Oral-argument statement.** Required for the opening brief only. The filed appellee's brief in this case has none, so the answering template no longer demands one; it prints the section when the frontmatter has `oral_argument`. The reading of LBR 8014-1(b) is not verified against the rule text (the README's Governing rules say so); David to confirm.

## Page review (Gate 2)

Every page of `usage/OUTPUT-answering-brief.typst.pdf` (13 pages) was rasterised at 70 dpi and viewed, one page at a time, after the last template change. The overlay pages were viewed as pairs. Findings:

- **Overlay: case names not italic.** Fixed in the transcription (see opening brief).
- **Overlay: TOC entries.** Wrapped TOC entries stranded page numbers. Fixed in the template (see Template changes).
- **OPEN (minor, for David): signature block.** "Respectfully submitted" falls to the top of page 7, after the Conclusion on page 6. The template keeps each signature block whole but does not keep it with the Conclusion before it. The filed brief has the signature on the same page as its conclusion.
- **Oral-argument statement.** The filed appellee brief has none; the section is not printed here, and the template no longer requires it for this doc type (see Template changes).

## Known gaps

- Table of authorities page references come only from `toa:` links the author places in the body. Nothing checks that every citation is linked.
- Heading numbers are the author's to type.
- The one-page limit on the oral-argument statement (LBR 8014-1(b)) is not measured.
- The 30-page limit (FRBP 8015(a)(7)(A)) is not checked. The word limit (8015(a)(7)(B)) is, and it is the limit that applies when a brief uses the word count.
- The addendum and footnotes are not exercised (no footnotes in the template).
- The certificate of service wording is ours (CM/ECF convention). It is not taken from a rule text that was read.
- The rule text was read through the Legal Information Institute page for FRBP 8014 and 8015 (fetched 2026-10-14), which returns a summary, not the official PDF. Check the wording against the official text before relying on a quoted phrase.
- **One case for all three.** Every exemplar is from BAP No. 19-8005. The opening and reply briefs share a filer group (Dinsmore & Shohl, BGD, Fox, Phoenix); the answering brief is UCB's. The tier-2 standard (two or three filed exemplars from different filers) is not met for any doc type. A second filed brief of each type from another BAP case would meet it.
- **Abridged transcription.** The sample transcribes part of the filed brief (see "Exemplar"). Filed pages that are not transcribed show as blue-only text in the overlay.
- **Certificate of compliance.** None of the filed briefs has one. The template's certificate follows FRBP 8015(h) as the README reads it; it is ours, not the exemplar's.

## Engines

Docx engine (`docx/`, built per `docs/EVAL-LOOP.md` "Engines"). `docx/reference.xml` holds the Word styles, from which fb render builds `reference.docx` on pandoc's default reference (`tools/fb/src/docxref.rs`); `docx/bap6-brief.lua` builds the cover, the front matter, the signature block and the certificates from the frontmatter and applies the rules checks (required sections, oral-argument statement, word limit, every registered authority cited). There is no `docx/render.sh`: fb render's multi-pass docx engine (`tools/fb/src/docxpass.rs`, `docxpages.rs`) adds the footers and the last section. Build: `sh tools/render.sh --engine docx courts/sixth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-answering-brief.md`; output `usage/OUTPUT-answering-brief.docx` and `.docx.pdf`. Needs pandoc and LibreOffice (`soffice`).

**Matches the typst form** (typst values measured on `usage/OUTPUT-answering-brief.typst.pdf` with `pdftohtml -xml` and `pdftotext -bbox-layout`):

- Font: Times New Roman 14 pt, the typst face; the PDF embeds TimesNewRomanPSMT, -BoldMT and -ItalicMT only. The font name is declared in the styles; it must be installed where the file is opened.
- Spacing: double spacing as the typst body pitch, exact 37.1 pt (typst 37.08 pt); single spacing (cover, contents, authorities, signature) exact 18.8 pt (typst 18.81 pt); first-line indent 0.5 in, none on the first paragraph after a heading.
- Page: US Letter, 1 in margins on all four sides (typst adds 4 pt to the bottom margin to keep its last line's descenders inside it; the LibreOffice exact lines keep the text inside 1 in, DEF-FORM-002 passes).
- Headings: level 1 and the front-matter titles bold 19.5 pt centered (typst 19.6 pt), level 2 bold 17 pt (typst 16.8 pt), level 3 bold indented 0.5 in, level 4 italic indented 1 in; the space above a heading is the typst gap, none at the top of a page.
- Sections: cover without a number; front matter lower roman from i; the brief arabic from 1, as typst.
- Table of contents (every heading, as typst) and table of authorities (dot leaders, pages in page order, `passim` from 7 pages) with page numbers, FRBP 8014(a)(2)-(3): the filter writes a needle for every heading and citation, fb render finds them in the LibreOffice PDF and renders again with those pages until they settle (fb-595.63). Every entry was checked against the body pages.
- Certificate of compliance: the word count equals typst's (1,185 words) and it names the typeface used, Times New Roman at 14-point, as typst; certificate of service with the same wording.

**Differs from typst (tier 2, not chased):**

- 13 pages (typst 13). Line and page breaks follow LibreOffice; Word may paginate slightly differently from the LibreOffice PDF the contents and authorities pages come from (`docs/DOCX.md`).
- Cover: the counsel block follows a fixed gap, not pinned to the foot of the page (`v(1fr)` in typst); the whole cover, date included, stays on page 1.
- Below a heading the first body line sits about 3 pt (level 1) to 14 pt (level 3) lower than in typst: an exact Word line puts its extra height above the text.
- Contents: a wrapped entry is indented under its title and its page number is set on the last line (typst sets it on the first line and starts the wrapped line at the margin).

docx check (fb-595.63, 2026-10-21): `sh tools/check.sh courts/sixth-circuit/bankruptcy-appellate-panel/answering-brief --engine docx`: RESULT: 11 checks passed, 0 failed (TNR-EMBEDDED and DEF-FONT-002 failed before, when the reference named EB Garamond). Every page of `usage/OUTPUT-answering-brief.docx.pdf` was viewed. The .docx passes DEF-DOCX-OPEN (valid zip, well-formed XML, every relationship resolves, LibreOffice converts it headless); it has not been opened in Word.

**BLOCKED (docx):** none.

[Formbook index](../../../../README.md) | [Court README](../README.md)
