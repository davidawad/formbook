# U.S. Bankruptcy Appellate Panel of the Sixth Circuit (bap6): reply brief

Doc type `reply-brief` of `courts/sixth-circuit/bankruptcy-appellate-panel`. Self-contained: the court-root `typst/` and `samples/` are not touched.

**Exemplar: yes.** Appellants' Reply Brief, filed 2019-09-12, 12 pages, *In re Chieftain Steel, LLC, et al.*, BAP No. 19-8005 (see "Exemplar" below and `exemplars/SOURCE.md`).

| Gate | Result |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-chieftain-steel-19-8005-reply-brief.pdf` |
| render | ok: `sh tools/render.sh courts/sixth-circuit/bankruptcy-appellate-panel/reply-brief samples/INPUT-chieftain-steel-19-8005.md` ran with typst 0.15.0 (vendored fonts), produced `samples/OUTPUT-chieftain-steel-19-8005.pdf` (10 pages), zero warnings |
| overlay | ok: `sh tools/overlay.sh courts/sixth-circuit/bankruptcy-appellate-panel/reply-brief chieftain-steel-19-8005` wrote `samples/OVERLAY-chieftain-steel-19-8005.pdf` (10 pages) and `.txt` |
| pages reviewed | 10 of 10 rendered pages viewed as PNG (70 dpi); overlay pages viewed as pairs (80 dpi) |

## Files

| Path | What |
|---|---|
| `exemplars/FILED-EXAMPLE-chieftain-steel-19-8005-reply-brief.pdf` | The filed brief, public, with a text layer. |
| `exemplars/SOURCE.md` | URL, case, docket, filer, date filed, date fetched, SHA-256. |
| `samples/INPUT-chieftain-steel-19-8005.md` | Transcription of the filed brief (see "Exemplar"). |
| `samples/OUTPUT-chieftain-steel-19-8005.pdf` | `tools/render.sh` output. |
| `samples/OVERLAY-chieftain-steel-19-8005.pdf`, `.txt` | `tools/overlay.sh` output: red = ours, blue = filed, black = both. The `.txt` maps each of our pages to its best-matching filed page. |
| `typst/main.typ`, `typst/bap6-reply-brief.typ` | Entry point and template. |

Build (from the repo root, toolchain on PATH): `sh tools/render.sh courts/sixth-circuit/bankruptcy-appellate-panel/reply-brief samples/INPUT-chieftain-steel-19-8005.md`. The render uses only the vendored EB Garamond (`--ignore-system-fonts`); any typst warning fails it.

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

Required body sections: none beyond the cover, TOC and TOA. FRBP 8014(c) requires a reply to comply with (a)(2)-(3) only. No statement regarding oral argument: LBR 8014-1(b) applies to the appellant's and appellee's briefs. Word limit: 6,500 (half of the principal brief's).

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

Filed by counsel of record in the case. Appellants' Reply Brief, filed 2019-09-12, 12 pages. *In re Chieftain Steel, LLC, et al.*, BAP No. 19-8005 (appeal from Bankr. W.D. Ky., Originating Case No. 16-10407). Copy: `exemplars/FILED-EXAMPLE-chieftain-steel-19-8005-reply-brief.pdf`; source, dates and hash in `exemplars/SOURCE.md`.

Transcription (`samples/INPUT-chieftain-steel-19-8005.md`) covers, in the filed order: the filing's cover, introduction, Argument I (pp. 1–3, abridged), II (pp. 3–4, abridged), III.A (p. 6), III.B (p. 7, abridged), and the conclusion (p. 8).

Not transcribed: the filed table of authorities (the template generates a TOC and TOA) and the filed certificate of service (replaced by the template's own).

Frontmatter (`caption`, `counsel`, `signature`, `date`, `disclosure`, `oral_argument` where the filing has them) copies the filed cover. The template's own certificate of compliance and certificate of service follow the body.

## How the exemplar was found (2026-10-14)

- Web search (standard, then extended) for BAP appellate briefs in this court. The reply is in the same case folder on law.uky.edu, found by filename once the opening brief was located.
- The file names on law.uky.edu follow one pattern, `19-8005 <Document>.pdf`. The other two briefs were fetched by that pattern. Each PDF was checked with `pdfinfo` and `pdftotext`: caption, BAP No., ECF header and filing date match.
- Ruled out before this: CourtListener API (no response from the sandbox) and HTML search (HTTP 403); Justia dockets (HTTP 403); general BAP results (local rules, practice guidelines, the pro se form, opinions). None gave a filed brief.

## Template changes (this pass)

The overlay and the page renders exposed these. All three templates changed the same way, so they stay in step.

1. **Cover spacing.** The opening cover ran onto a second page (the date line). Gaps tightened: caption stack 1.1em to 0.9em, counsel groups 1.2em to 0.9em, the gap before the date 1.4em to 0.8em. The cover is one page in all three.
2. **TOC entries.** Dot leaders were a single line, so a long entry that wrapped left its page number on a line of its own. Entries are now a two-column grid with the page number in the right column. The dot leaders are gone, and wrapped lines stay flush left.
3. **Oral-argument statement.** Required for the opening brief only. The filed appellee's brief in this case has none, so the answering template no longer demands one; it prints the section when the frontmatter has `oral_argument`. The reading of LBR 8014-1(b) is not verified against the rule text (the README's Governing rules say so); David to confirm.

## Page review (Gate 2)

Every page of `samples/OUTPUT-chieftain-steel-19-8005.pdf` (10 pages) was rasterised at 70 dpi and viewed, one page at a time, after the last template change. The overlay pages were viewed as pairs. Findings:

- **Overlay: TOC entries.** Long TOC entries wrapped and stranded their page numbers. Fixed in the template (see Template changes).
- **Case names not italic.** Fixed in the transcription.
- **OPEN (for David): table of contents.** The filed reply has a table of authorities (page ii) and no table of contents. The template renders a TOC for a reply, as the Governing rules say FRBP 8014(a)(2) requires. The sample keeps the TOC. Decide whether 8014(c) requires it for a reply; if not, the reply template should drop it.

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

Docx engine (`docx/`, built per `docs/EVAL-LOOP.md` "Engines"). `docx/build-reference.sh` makes `docx/reference.docx` from pandoc's default reference; `docx/render.sh` runs pandoc with `docx/reference.docx` and `docx/bap6-brief.lua` (cover, front matter, certificates, TOC/TOA/TA fields, the rules checks). Build: `sh tools/render.sh --engine docx courts/sixth-circuit/bankruptcy-appellate-panel/<doc-type> samples/INPUT-chieftain-steel-19-8005.md`. Needs pandoc, unzip, zip, xmllint, perl.

**Matches the typst reference** (typst values measured on `/work/artifacts/bap6/<doc-type>/OUTPUT-chieftain-steel-19-8005.pdf` with `pdftohtml -xml` and `pdftotext -bbox`; docx values read from `styles.xml` and `sectPr`):

- Font: EB Garamond (family name confirmed from `fonts/eb-garamond/*.otf`), body 14 pt (`sz` 28). Typst embeds EB Garamond Regular, Bold and Italic.
- Body spacing: exact 36.4 pt line pitch (typst measures 36.4 pt between body lines). Block quotations, cover, TOC, TOA, signature and certificates: exact 18.2 pt.
- Page: US Letter (12240 x 15840 twips), 1 in margins on all four sides (typst body text starts at x = 72 pt).
- First-line indent 0.5 in; the first paragraph after a heading is not indented (typst measures the same).
- Headings: bold; level 1 and the front-matter titles 19.5 pt (typst 19.6 pt, Word rounds to half points); level 2 17 pt (typst 16.8 pt); level 3 indented 0.5 in; level 4 italic, indented 1 in.
- Footer: centered PAGE field. Cover without footer; front matter lower-roman; brief arabic from 1 (as in typst).
- Word count in the certificate of compliance equals typst's count: 1,093 words (opening brief), 1,185 (answering brief), 970 (reply brief), the same figures typst prints.

**Differs from typst (not measured against a rendered docx):**

- Cover: the counsel block sits after a fixed gap, not pinned to the bottom of the page as in typst (`v(1fr)`). The gap is an estimate.
- Table of contents and table of authorities: the TOC is a TOC field and each citation carries a TA field; the TOA is one TOA field per kind. Their cached results list the headings and authorities without page numbers. Word fills in the page numbers when fields update (`updateFields` is set, so Word asks on open). LibreOffice does not.
- Cover title is printed with `caps` (typst uses `upper()`); the text is the same.

**BLOCKED (docx):**

- `docx.pdf` and page review: `soffice` (LibreOffice) is not installed on this box and cannot be installed here. No `OUTPUT-<id>.docx.pdf` exists, so Gates 0 to 3 on the LibreOffice PDF did not run, and no page was rendered or viewed (pages reviewed: 0). `tools/check.sh --engine docx` was not run for the same reason.
- Opening in Word and LibreOffice without a repair prompt: not verified. Only the zip structure and XML well-formedness were checked (`tools/render-docx.sh`).
- TOC page numbers: Word-native field, computed by Word on update; not computed by LibreOffice (`docs/DOCX.md`, "Fields"). Needs a populated result to pass a page-number check.
- TOA page numbers: TA/TOA fields; LibreOffice does not honor them (`docs/DOCX.md`, "Table of authorities"). Needs a populated result to pass.
- Fonts: EB Garamond must be installed where the file is opened, or Word substitutes silently (`docs/DOCX.md`, "Fonts").

[Formbook index](../../../../README.md) | [Court README](../README.md)
