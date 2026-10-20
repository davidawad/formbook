# nynb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Northern District of New York (`nynb`).
Folder: `courts/second-circuit/new-york/federal/bankruptcy-northern-district/adversary-complaint/`.

**Exemplar found (1 filer).** `usage/FILED-EXAMPLE-adversary-complaint.pdf` is a real, public,
text-based complaint filed in this court (Adv. No. 15-50001, Dkt 1, filed January 2015). The sample is a transcription of
it. Provenance and the search log are in `usage/SOURCE.md`. Tier 2 would normally be judged against 2 or 3 filers; one
filer is on file, so a second complaint is still wanted (candidate: Stevens, Adv. No. 26-90046, in `usage/SOURCE.md`).

| Item | Status |
|---|---|
| exemplar | **yes**: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (6 pages, text layer) |
| sample md | `usage/INPUT-adversary-complaint.md`: transcription of the filing's text (the 37 numbered paragraphs, the preamble, the WHEREFORE clause, the prayer, the signature block). Frontmatter comment lists every difference from the filing. |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 6 pages, letter, EB Garamond only (embedded), `tools/render.sh` exit 0, no typst warnings |
| overlay | ok: `usage/OVERLAY-adversary-complaint.pdf` and `.txt`, `tools/overlay.sh` exit 0. Page word-overlap: 70.3, 66.6, 66.3, 55.2, 50.5, 84.2 percent (pages 1 to 6) |
| pages reviewed | 6 of 6, each rendered at 70 dpi and viewed. Pages 1 to 4 were viewed before the last template change (the prayer's sticky chain, which begins on page 5); that change cannot move text on pages 1 to 4. Pages 5 and 6 were viewed after it. |

File names: the sample is `INPUT-adversary-complaint.md`; the id is `adversary-complaint` (the render and overlay default
names are `OUTPUT-adversary-complaint.typst.pdf`, `OVERLAY-adversary-complaint.pdf/.txt`).

## Markdown contract (frontmatter)

The sample starts with a YAML block. The template reads these keys:

| Key | Meaning |
|---|---|
| `preamble` | number of leading body chunks printed unnumbered (the "Plaintiff, complaining of the defendant, alleges:" lead-in). Without it, the chunks before the first heading are the preamble. Numbering starts at the next chunk. |
| `counsel` | list of lines, single-spaced, top left of page 1 (optional; the filing has none, so the sample omits it) |
| `debtor.names`, `debtor.tin` | the debtor under "In re:"; `tin` is printed as written (LBR 9004-1(c) allows only the last four digits, which the author must supply; the sample uses a placeholder) |
| `case_number`, `chapter` | right column of the bankruptcy caption |
| `hearing` | not used by the complaint (the motion uses it) |
| `adversary.number`, `adversary.parties[]` | the adversary caption: `names` (list) and `designation` per party; `v.` is inserted between parties |
| `title` | centred bold title of the paper, here `ADVERSARY COMPLAINT` |
| `dated`, `signature.firm`, `signature.signer`, `signature.lines` | the date and signature block |

Body: blank-line-separated chunks. `#` is a centred bold heading, `##` a bold heading flush left. Every other chunk is a
numbered paragraph (FRCP 10(b) via FRBP 7010), except: a chunk starting `(a) ` is an unnumbered prayer item, and a chunk
starting `<!-- unnumbered -->` (an HTML comment, which the template strips) is an unnumbered paragraph (the WHEREFORE clause). It replaces a bare `% ` prefix, which the content check read as text the filing does not show.

## Governing rules

Primary sources, fetched 2026-10-14 (the date verified for every row).

| Rule | Requirement | Kind | Where it is in the template |
|---|---|---|---|
| LBR 9004-1(a)(1)(A) (N.D.N.Y. Local Bankruptcy Rules, effective 12-01-2024, https://www.nynb.uscourts.gov/sites/nynb/files/LBR_GenOrders/Local%20Bankruptcy%20Rules_Effective%2012-01-2024%20Final.pdf; text extracted with pdftotext) | Text, in the body or a footnote, is a minimum of 12-point font | M | `type-size = 12pt`, set on the page for the whole document |
| LBR 9004-1(a)(1)(B) | Double-spaced, except block quotations and footnotes may be single-spaced | M | `pitch = 24pt`, `body-leading = 1.35em` (0.65em line box + 1.35em = 2.0em = 24 pt; the leading after each unit is added by hand) |
| LBR 9004-1(a)(1)(C)-(E) | Legible, single-sided, black ink | M | Output is a single-sided black-ink PDF; not a template choice |
| LBR 9004-1(a)(2)(A) | One-inch margin on all four sides | M | `margin = 1in` |
| LBR 9004-1(a)(2)(B) | Consecutively numbered pages | M | `numbering: "1"`, centred at the foot, on every page including page 1 |
| LBR 9004-1(a)(2)(C) | Letter size, 8½ × 11 | M | `paper: "us-letter"`; the PDF is 612 × 792 pt |
| LBR 9004-1(c) | Caption: court name, case title, case number and chapter, last four SSN/TIN digits only, the adversary name and number if pertinent, and a short title naming the document and the party filing it | M | `bankruptcy-caption`, `adversary-caption`; the SSN/TIN digits and the short title come from the sample |
| LBR 9004-1(d) | The court may decline a document that does not comply | M (consequence) | n/a |
| LBR 7003-1 | An Adversary Proceeding Cover Sheet is required for every adversary filed in CM/ECF or on paper | A (author) | not rendered: a separate form (the court's fillable cover sheet) |
| FRBP 9004(a) (Cornell LII, https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14) | A document must be clearly legible | M | as LBR 9004-1 |
| FRBP 9004(b) (same) | Caption: court's name, the case's title, the case number and adversary number, and a brief designation of the document | M | `title` line and both captions |
| FRBP 7001 (adversary proceeding; the sample cites 7001(1), (2) and (9)) | Categories of adversary proceedings | content, A | in the sample text only |
| FRBP 7003 (Cornell, fetched 2026-10-14) | "Fed. R. Civ. P. 3 applies in an adversary proceeding" | content, A | sample's commencement by complaint |
| FRBP 7008(a) (Cornell, fetched 2026-10-14) | "Fed. R. Civ. P. 8 applies"; the jurisdiction allegation refers to the bankruptcy case by name, number and chapter; the complaint states whether the pleader consents to final orders by the bankruptcy court | M (content) | the sample pleads the jurisdiction paragraphs as the filing does; the consent statement is not in the 2015 filing (the template does not check the wording) |
| FRBP 7010 (Cornell, fetched 2026-10-14) | "Fed. R. Civ. P. 10 applies"; the caption substantially conforms to Official Form 416A | M (caption) | caption layout follows Official Form 416A's structure as the rules describe it; Form 416A's text was not fetched (the uscourts.gov page returned 404) |
| FRCP 10(b) (via FRBP 7010) | Numbered paragraphs, each limited as far as practicable to a single set of circumstances | M (form) | numbering in `body-content` |

Rows marked M are the tier-1 requirements. The filed exemplar (2015) predates the current LBR text in places; where the
exemplar and the rules differ (the caption has no TIN line; the signature is handwritten), the rules govern and the sample
keeps the template's rule-based form. Layout choices the rules leave open are the heading styles, the title placement
(below the caption, centred), the lettering of prayer items, and the signature layout; see the next section.

## Tier-2 comparison with the exemplar (overlay and page review)

| Item | Filed exemplar | Template | Status |
|---|---|---|---|
| Title placement | "ADVERSARY COMPLAINT" in the caption's right column, under the case number | centred below the caption | ACCEPTED: the rules leave the placement open and the short title is present. One exemplar only, so the convention is not established. |
| Prayer labels | "1." to "5." | "(a)" to "(e)" | ACCEPTED: label style; the text and order match. |
| Prayer page break | WHEREFORE on page 6 | WHEREFORE at the foot of page 5, items (a) to (d) on page 5, (e) and the signature on page 6 | ACCEPTED: break position follows the template's keep-with-next rule (only the last prayer item is kept with the signature). |
| Signature | handwritten signature over the firm name | "By: /s/" line over the signer's name | ACCEPTED: `/s/` is the template's electronic-signature convention (FRBP 9011). |
| Counsel block | at the foot of the signature block only | none at the top (frontmatter omits `counsel`) | ACCEPTED: matches the filing. |
| Body spacing and paragraph numbering | double-spaced, numbered 1 to 37 | the same | matches (overlay line positions agree). |

## Known gaps

- **One exemplar.** Tier 2 is judged against a single filer; a second complaint from a different filer is still wanted.
- **Judges' individual practices are not checked.** The LBR text found contains no page limit for a complaint; any judge's
  individual procedures are the author's responsibility.
- **Not rendered, author responsibility:** the Adversary Proceeding Cover Sheet (LBR 7003-1), the summons (LBR 7004-1),
  the redaction of personal identifiers beyond the caption (the rules on privacy protection are not in this template),
  the consent-to-final-orders statement (FRBP 7008(a)), and the signer's Bar Roll number (the sample carries the filing's
  number).
- **TIN placeholder.** The 2015 filing has no TIN line; the sample prints `TIN: xx-xxx0000` as a placeholder so that the
  template's rule-required line exists. The author supplies the real last four digits.
- **No gate checks.** There is no `checks.yaml` for this doc type, so `tools/check.sh` is not wired here and no stamp exists.
  Gates 0 and 1 are not run.
- **Pleading paper is not used.** LBR 9004-1 does not require numbered lines, so the template has none (the cand complaint
  uses line numbers because N.D. Cal. requires them).
- **Footnotes are not exercised** by the sample. The rule (12-point, single-spaced allowed) is stated but no footnote is
  rendered, so the footnote style is untested.
- **Typeface.** LBR 9004-1 sets a minimum size, not a typeface. EB Garamond is our choice, vendored in `fonts/`.

## Engines

**docx** (`docx/`): `build-reference.sh` builds `docx/reference.docx` (EB Garamond 12 pt, exact 24 pt body lines,
13.8 pt single lines, 1 in margins, letter, PAGE field centred in the footer); `docx/nynb-adversary-complaint.lua` builds
the cover, the two caption tables, the numbered paragraphs, the prayer and the signature block. Output:
`usage/OUTPUT-adversary-complaint.docx` and `.docx.pdf` (LibreOffice). The `.docx` converts in LibreOffice with no
error; the zip and XML parts are well formed.

- Matches the typst output: font and size, line pitch, margins, page numbers, caption layout and rules, the numbering
  1 to 37, the prayer (a) to (e) with the last item kept with the signature, the signature block. Page count 6 = 6;
  each of the 6 pages of the `.docx.pdf` was viewed beside the typst page.
- Differs: line breaks fall on other words (Word and LibreOffice set text differently from typst), so a line or two
  moves between pages. Numbers are typed with a tab (text starts at
  1 in); typst sets them with a fixed gap. The caption rules are table borders.
- BLOCKED: `docx`: no `checks.yaml` exists for this doc type, so `tools/check.sh --engine docx` cannot run (exit 2,
  "no such file"). No gate has been run on the docx; the `.docx.pdf` has not been checked against the rules.
