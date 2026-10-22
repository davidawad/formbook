# meb: adversary complaint

Doc type: **adversary complaint** (commencing an adversary proceeding) in the United States Bankruptcy Court for the District of Maine (`meb`). Folder: `courts/first-circuit/maine/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (the whole 5-page complaint, transcribed) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 4 pages (4 also on the earlier EB Garamond render, before fb-595.68), typst 0.15.0, pinned Times New Roman only, no warnings |
| overlay | ok: `usage/OVERLAY-manhart-adversary-complaint.pdf` and `.txt` (page map below) |
| pages reviewed | 4 of 4 (every page rendered at 60 dpi and viewed after the last template change; the EB Garamond render, before fb-595.68) |

File names: the tools read and write `INPUT-<id>.md`, `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt` by default, so the sample uses those names (not `<id>.md` and `<id>-overlay.pdf` as the brief's layout listed). `<id>` is `manhart-adversary-complaint`.

## Governing rules

Verified 2026-10-14. Sources are cited per row; the local rules PDF is the December 2025 version (effective December 1, 2025).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7001 | An adversary proceeding is needed for the listed types of relief (recovery of money or property, lien validity, dischargeability, and so on). The complaint is the paper that commences it. Text from https://www.law.cornell.edu/rules/frbp/rule_7001 (amended effective December 1, 2024). | Author content (the sample's § 547 and § 550 counts). The template does not check the type. |
| Fed. R. Bankr. P. 7008 | Fed. R. Civ. P. 8 applies. The allegation of jurisdiction must reference the name, number and Code chapter of the case, and the complaint must state whether the pleader consents to the entry of final orders or judgment by the bankruptcy judge. https://www.law.cornell.edu/rules/frbp/rule_7008 | Author content (sample ¶¶ on jurisdiction and consent). The template does not check the wording. |
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies. The caption must substantially conform to Official Form 416. https://www.law.cornell.edu/rules/frbp/rule_7010 | `caption()`: the court name, the main case (debtor, chapter, case number) and the adversary rows (parties, "v.", adversary number). |
| Fed. R. Civ. P. 10(b) (via 7010) | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | `numbered-body()`: each body paragraph is numbered; headings and lists are not. |
| Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." https://www.law.cornell.edu/rules/frbp/rule_9004 | Vendored 12 pt type, black on white. |
| D. Me. LBR 7003-1(a) | Every paper in an adversary proceeding contains the main case caption, the names of the parties to the adversary proceeding, the title of the paper, and the adversary proceeding number. Local rules PDF, https://www.meb.uscourts.gov/sites/meb/files/202512_USBC_Local_Rules.pdf | `caption()` and the title line on the cover. |
| D. Me. LBR 7003-1(b) | An unrepresented party files the completed cover sheet, Official Form B1040, with the complaint. | Not produced (a separate form; see gaps). |

Court-published reference (not a rule): the Adversary Complaint Template, https://www.meb.uscourts.gov/sites/meb/files/Adversary_Complaint_Template.pdf (fetched 2026-10-14). It sets the section order used here (jurisdiction, parties, consent to final judgment, statement of claim, relief, closing) and says each claim goes in a separate numbered paragraph and that legal argument is left out. The sample follows that order, with the statement of claim as counts.

Not produced by this template (separate filings, not part of the complaint): the adversary cover sheet (Form B1040); the filing fee; a summons; the Rule 7.1 disclosure where required. Any of these may be needed with the first filing.

## Layout

- US Letter, one-inch margins on all sides; Times New Roman 12 pt (the pinned install; `docs/FONTS.md` rule 6, the house standard; EB Garamond, then the only vendored font, before fb-595.68).
- Court name centered and bold on two lines, then a bordered caption: left column with the debtor (`In re:`) and the parties ("v."), right column with `Chapter N`, `Case No.` and `Adv. Proc. No.`. The adversary row is omitted when the sample has no `parties`.
- Title of the paper centered, bold, capitals. Opening paragraph (`lead_in`) unnumbered.
- Body double-spaced (24 pt pitch). Level-1 headings centered bold capitals; level-2 bold run-in; level-3 bold italic. Headings are set by the template from the markdown `#` prefix (cmarker's own heading output ignores the template's show rules).
- Paragraphs numbered 1, 2, ... continuously (first-line indent 0.5 inch). A list (`1.`) is lettered (a), (b), ...
- Relief paragraph (`wherefore`), unnumbered, then the date and signature block (single spacing), kept on one page.
- Page number centered at the foot, "- n -".

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter: `debtor` (`names`, `designation`), `chapter`, `case_number`, `parties` (list of `names`, `designation`; optional), `adv_number`, `title`, `lead_in` (optional, blank-line-separated paragraphs), `wherefore`, `date`, `signature` (`signer`, `lines`).
- Body: a `#` heading (level 1, centered caps), a `##` heading (level 2), a paragraph (numbered by the template), or a list (lettered). One paragraph per blank-line-separated chunk; no raw typst; no tables; no footnotes.
- The sample must not put numbers in the text; the template numbers the paragraphs.

## What the overlay shows

`usage/OVERLAY-manhart-adversary-complaint.pdf`: red is our render, blue is the filed exemplar, and black is where they agree. The page map (`.txt`), measured on the earlier EB Garamond render, before fb-595.68:

```
ours p.1  filed p.1  word-overlap 67.9%
ours p.2  filed p.2  word-overlap 52.0%
ours p.3  filed p.4  word-overlap 48.2%
ours p.4  filed p.4  word-overlap 41.9%
```

The filed exemplar is 5 pages (its page 1 carries the ECF header, which we do not reproduce). The pairing is by shared words per page, so pages 3 and 4 both match exemplar page 4; this shows which filed page the words came from, not a page-for-page match. Word overlap below 70 percent reflects the different line and page breaks (our EB Garamond, at the time, against the filer's Times) and the ECF header text, not a text difference. The overlay is a diagnostic, not a score.

## Gate 2: page review (rendered at 60 dpi, every page viewed; the earlier EB Garamond render, before fb-595.68)

| Page | Content | Result |
|---|---|---|
| 1 | Court name, caption (debtor, chapter, case number; parties; adversary number), title, opening paragraph, "JURISDICTION AND VENUE", ¶¶ 1–5 | Pass. Caption not overlapping; footer "- 1 -". |
| 2 | ¶ 6, PARTIES (¶¶ 7–9), STATEMENT OF MATERIAL FACTS (¶¶ 10–14) | Pass. Headings centered and bold; paragraphs on the 24 pt grid. |
| 3 | COUNT I (¶¶ 15–23), COUNT II heading and ¶¶ 24–25 | Pass. Heading "COUNT II" not at the foot of the page. |
| 4 | ¶ 26, WHEREFORE paragraph, "Dated: May 20, 2026", signature block | Pass. Relief and signature on the same page. |

Defects found and fixed during review: (1) paragraphs drawn over each other (a block's height was short by one line; fixed by measuring each paragraph and rounding to whole 24 pt lines); (2) the footer rendered as a bullet (`- ` at line start is list syntax; fixed); (3) headings left-aligned (cmarker's heading output ignored the show rules; headings now come from the markdown `#` prefix and the heading block takes the full text width); (4) signature name repeated (fixed in the sample frontmatter); (5) the WHEREFORE paragraph and the signature block split across pages (kept together; not triggered by this 4-page sample but enforced).

## Known gaps and open choices

1. **One exemplar only.** The brief asks for one exemplar per doc type; EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. Other Bankruptcy Court (Maine) complaints seen in the same CourtListener search and not saved: *Walsh, Jr. v. U.S. Department of Education*, Adv. Proc. 25-01004 (19 pages; B1040 cover sheet attached, which suggests an unrepresented filer, not checked); *Dostie v. U.S. Bank*, Adv. Proc. 26-02002 (30 pages; its text layer yields only the ECF header on page 1, so the body was not usable for transcription). Tier 2 is therefore **not** judged against two filers.
2. **Typeface.** No Maine local rule on typeface was found in the December 2025 rules (the rules are silent on form of papers; FRBP 9004(a) requires legibility only). The exemplar is Times-style 12 pt. The template is Times New Roman 12 pt, the house standard (`docs/FONTS.md` rule 6). (Before fb-595.68 it was EB Garamond 12 pt, then the only vendored font, which looked smaller than Times at the same size.)
3. **Margins and paper size.** FRBP 9004(c) (paper size and margins) was not verified: the Cornell page for 9004 showed only subdivisions (a) and (b). The template uses 8½ × 11 with one-inch margins, which matches the exemplar and the usual form; this is unverified against the rule text.
4. **Caption.** The party column is closed by rules (right and bottom) rather than the ")" column of the exemplar's *in re* box. Recorded as ACCEPTED (a convention choice the rules leave open).
5. **Paragraph numbering.** The filed exemplar restarts its numbering at PARTIES (1, 2, 3 again after ¶ 6); the template numbers continuously, as Fed. R. Civ. P. 10(b) and the court's own template suggest. ACCEPTED.
6. **Jurisdiction, consent and counts.** The template checks only layout. The wording of ¶¶ on jurisdiction (FRBP 7008), the consent to final orders, and the counts is author content.
7. **Filed content not reproduced.** The ECF header on each page, the "{P…}" document-ID footer and the exemplar's firm footer are not reproduced; they are added by CM/ECF or the filer.
8. **Adversary cover sheet and fee.** Not generated (see Governing rules). A complaint with the wrong cover sheet or no fee is a clerk's-office problem, not a layout problem, but the court will want both at filing.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids editing `tools/`. The gates were not run. Render and overlay were run, and the review above is the Gate 2 equivalent for this doc type.
10. **Headings must fit the text width.** Headings wrap across lines (the template measures them); no single-line rule is enforced here, unlike the N.D. Cal. template.

## Engines

Typst is the primary engine. This section covers the docx engine (`docx/`): `fb render --engine docx` builds the reference document from `docx/reference.xml` (`base="xengine"`: the page setup and styles in the typst template's face, and the "- n -" footer part), then runs pandoc with the Lua filter `docx/meb-adversary-complaint.lua` (the cover, caption, numbered paragraphs, relief and signature). Render: `sh tools/render.sh --engine docx <this folder> usage/INPUT-adversary-complaint.md` (a wrapper of `fb render --engine docx`). (Until fb-595.68, pandoc 3.6.4 ran with a committed EB Garamond `docx/reference.docx` built by `sh docx/make-reference.sh`.) The "pages reviewed" row and the BLOCKED items below were recorded before fb-595.68.

| Output | Result |
|---|---|
| `usage/OUTPUT-adversary-complaint.docx` | written; zip and well-formed XML parts pass the `render-docx.sh` integrity check |
| `usage/OUTPUT-adversary-complaint.docx.pdf` | now committed (4 pages, as the typst render). Before fb-595.68 **not produced**: LibreOffice did not start in the build environment (see BLOCKED below) |
| pages reviewed in the docx PDF | 0 of 4 (there is no PDF to render; the typst pages are the reference) |

**What matches typst** (the same values, set in the reference styles): US Letter with 1 in margins; Times New Roman 12 pt; body lines exactly 24 pt (double spacing); first-line indent 0.5 in; paragraphs numbered 1, 2, ... as typed text with a tab (the typst template numbers them the same way, not as an automatic list); the caption as a table with the right and bottom rules of the typst box; the title in capitals; level-1 headings centred in capitals; the WHEREFORE paragraph and the signature block kept together; the footer "- n -" from a PAGE field.

**What differs, or is not verified:**

- Line and page breaks are Word's, not measured, so the page count may not be typst's 4.
- Heading spacing is approximated: typst rounds each heading block to whole 24 pt lines, Word uses 12 pt before and after.
- The caption and signature fields are set as plain text, so markdown emphasis in them is dropped (the body keeps it).
- The docx names "Times New Roman" (EB Garamond before fb-595.68) and does not embed it. The font must be installed on the machine that opens the file, or Word substitutes silently.
- Footnote text (not in this sample) inherits 12 pt single spacing from Normal; not checked.

**docx BLOCKED items** (the docx checks run on `usage/OUTPUT-manhart-adversary-complaint.docx.pdf`):

- `BLOCKED: Gate 0 and Gate 1 (tools/check.sh --engine docx)`: no `.docx.pdf` exists, so the page count, the font names and the content gates cannot run. Cause: LibreOffice 25.2 (Debian trixie packages, unpacked without root) stops at bootstrap with a `DeploymentException`, even for `soffice --version`.
- `BLOCKED: Gate 2 (page review of the docx PDF)`: no pages reviewed, for the same reason.
- `BLOCKED: opens in LibreOffice and Word without a repair prompt`: not verified; there is no LibreOffice to open it in.

[Court index](../README.md) | [Formbook index](../../../../../../README.md)
