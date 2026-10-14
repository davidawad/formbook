# U.S. Bankruptcy Appellate Panel of the Sixth Circuit (bap6): opening brief (appellant's brief)

Doc type `opening-brief` of `courts/sixth-circuit/bankruptcy-appellate-panel`. Self-contained: the court-root `typst/` and `samples/` are not touched.

**BLOCKED: no exemplar.** No public, filed opening brief (appellant's brief) from this court was found (see "Searches"). The template is built from the rules below; it has not been checked against a filed brief.

| Gate | Result |
|---|---|
| exemplar | no (`exemplars/SOURCE.md`) |
| render | ok: `sh tools/render.sh courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief samples/INPUT-placeholder.md` ran with typst 0.15.0, produced `samples/OUTPUT-placeholder.pdf`, zero warnings. The sample is a placeholder fixture, not an exemplar transcription. |
| overlay | fail: `sh tools/overlay.sh courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief placeholder` exits 1 with "no exemplar pdf in exemplars". No `OVERLAY-` file is written. |
| pages reviewed | see "Page review" (all pages of `samples/OUTPUT-placeholder.pdf`, rasterised with `pdftoppm -r 60`) |

## Files

| Path | What |
|---|---|
| `exemplars/SOURCE.md` | The search record. No filed exemplar. |
| `samples/INPUT-placeholder.md` | Placeholder fixture (not a filing). Frontmatter per the contract below; body with every section the template requires. |
| `samples/OUTPUT-placeholder.pdf` | `tools/render.sh` output of the fixture. |
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits the frontmatter, calls the template. |
| `typst/bap6-opening-brief.typ` | The template: `brief-style`, `brief(meta, body)`. Content-agnostic; every number is a named parameter traced to a rule or marked as a style choice. |

Build (from the repo root, toolchain on PATH): `sh tools/render.sh courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief samples/INPUT-placeholder.md`. The render uses only the vendored EB Garamond (`--ignore-system-fonts`); any typst warning fails it.

Note on file names: the brief asks for `samples/<id>-overlay.pdf`; `tools/overlay.sh` writes `samples/OVERLAY-<id>.pdf` and `.txt`, and the tool's names are used here.

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

Required body sections (FRBP 8014(a)(4)-(9), checked by the build): Statement of Jurisdiction, Statement of the Issues, Statement of the Case, Summary of Argument, Argument, Conclusion. Required: a statement regarding oral argument.

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
| `oral_argument` | yes for opening and answering | Statement regarding oral argument, after the TOA (LBR 8014-1(b)). Not used for a reply. |
| `authorities` | yes if the body cites any | Registry: key → `kind` (case, constitution, statute, regulation, rule, other), `name` (optional), `cite`, `sort` (optional). A `[text](toa:KEY)` link with no registry entry stops the build; a registry entry never cited stops the build. |
| `service` | no | `true` adds a certificate of service |

Body: `# Heading` (level 1) sections; `##`, `###`, `####` below. Heading numbers are typed by the author (the template does not number them). Required sections are checked and the build stops when one is missing. `# Addendum` ends the brief: it is rendered after the certificates and is not counted. Footnotes are not supported. Words are counted over the body (headings included, FRBP 8015(g)); the build stops above the limit.

## Overlay

Not produced: the overlay compares our render with a filed exemplar, and none exists. When an exemplar is added to `exemplars/`, run `sh tools/overlay.sh courts/sixth-circuit/bankruptcy-appellate-panel/opening-brief <id>`.

## Searches (2026-10-14)

Looking for a filed BAP brief of this type. Each search below returned no filed brief from this court:

1. CourtListener API v4 search, `court=bap6`, `type=r`, `q="brief of appellant"` and `q="appellee's brief"`: 0 results.
2. CourtListener: the BAP dockets list (`/api/rest/v4/dockets/?court=bap6`) returned HTTP 401; the CourtListener HTML search returned HTTP 403. Not usable from the fetch tool.
3. Web search (standard and extended) for "Bankruptcy Appellate Panel of the Sixth Circuit" with brief terms: returned the BAP practice guidelines, the local rules, the pro se brief form, BAP clerk letters on Justia, and BAP opinions on GPO and Justia. No appellate briefs.
4. The Justia and GPO BAP dockets (e.g. ca6 12-8025, 15-8056, 15-8037): clerk letters and opinions only; the Justia docket page returned HTTP 403.
5. `In re Wedgewood Properties`, No. 24-8007 (BAP, oral argument May 22, 2025, on the ca6 calendar): the calendar lists counsel; no brief or docket was found.
6. The pro se BAP form (`bap_brief2.pdf`, "B.A.P. Pro Se Appellant's Brief"): a blank fillable form, not a filed brief. Ruled out.
7. A broad CourtListener RECAP search surfaced district-court bankruptcy appeal briefs (e.g. E.D. Mich. 2:23-cv-10171, "Bankruptcy Brief of Appellant"). Those are appeals to the district court, not the BAP, so they are not exemplars for this court. Ruled out.

The next place to look: the BAP's own docket (PACER or the Sixth Circuit's CM/ECF) for a specific BAP case number, or a public record copy from a party. Neither was available here.

## Page review (Gate 2)

Every page of `samples/OUTPUT-placeholder.pdf` was rasterised at `pdftoppm -r 60` and viewed. 14 of 14 pages of `samples/OUTPUT-placeholder.pdf`. Defects found and fixed: (1) paragraphs overlapped (paragraph spacing was 0): spacing now equals `body-leading`; (2) body lines were 1.2 times single spacing (leading 0.94em): now `body-leading` 1.95em; (3) the certificate of service's signature block was orphaned on its own page: each certificate is one unbreakable block; (4) "14pt" in the certificate was set in a fallback monospace face (typst's bundled DejaVu Sans Mono): now `str(type-size / 1pt)-point`. Pages 2, 13 and 14 were viewed after all four fixes. Pages 5 to 12 were viewed after fix 2 and before fixes 3 and 4; fixes 3 and 4 change only the certificate pages, and the footers and content of pages 8 to 12 were rechecked with `pdftotext`. Pages 2 to 4 were viewed again in the final render, after fix 2, so their line spacing was checked. Page 1 (cover) uses single spacing, which fix 2 does not change; it was viewed in the render before fixes 1 and 2.

## Known gaps

- No exemplar: the layout is not compared with a filed brief. The cover carries no colour (none of the rules read requires one for a BAP brief; not verified against the Sixth Circuit Guide to Electronic Filing, which LBR 8011-1 adopts and which was not read).
- Table of authorities page references come only from `toa:` links the author places in the body. Nothing checks that every citation is linked.
- Heading numbers are the author's to type.
- The one-page limit on the oral-argument statement (LBR 8014-1(b)) is not measured.
- The 30-page limit (FRBP 8015(a)(7)(A)) is not checked. The word limit (8015(a)(7)(B)) is, and it is the limit that applies when a brief uses the word count.
- The addendum and footnotes are not exercised (no footnotes in the template).
- The certificate of service wording is ours (CM/ECF convention). It is not taken from a rule text that was read.
- The rule text was read through the Legal Information Institute page for FRBP 8014 and 8015 (fetched 2026-10-14), which returns a summary, not the official PDF. Check the wording against the official text before relying on a quoted phrase.

[Formbook index](../../../../README.md) | [Court README](../README.md)
