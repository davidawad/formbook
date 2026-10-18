# moeb: adversary complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding, filed by a plaintiff) in the United States Bankruptcy Court for the Eastern District of Missouri, Eastern Division (`moeb`). Folder: `courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-adversary-complaint.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-adversary-complaint.md` (the whole complaint, pages 3 to 8 of the exemplar; the Form 104 cover sheet is not transcribed) |
| render | ok: `usage/OUTPUT-adversary-complaint.typst.pdf`, 6 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-riske-dempster.pdf` and `usage/OVERLAY-riske-dempster.txt` (page map) |
| pages reviewed | 6 of 6 (every page rendered at 60 dpi and viewed; see the review table) |

File names: the sample is `INPUT-adversary-complaint.md`, so `tools/render.sh` and `tools/overlay.sh` produce `OUTPUT-adversary-complaint.typst.pdf` and `OVERLAY-riske-dempster.{pdf,txt}`. These are the repo's file-role names (CLAUDE.md), not the `<id>.pdf` / `<id>-overlay.pdf` names in the brief; the tools fix them.

## Governing rules

Primary source: **E.D. Mo. Local Rules of Bankruptcy Procedure, "as revised effective December 1, 2025"** (cover page of the PDF). Fetched 2026-10-14 from https://www.moeb.uscourts.gov/sites/moeb/files/Local_Rules_Dec_1_2025.pdf. The court's site blocks direct downloads from this box (F5 "Request Rejected"), so the PDF was read through WebFetch, which saved a copy that was then text-extracted (`pdftotext -layout`, 104 pages). Quotations below are from that text.

Caveat: the rule text's own L.R. 1001(C) still reads "These Rules become effective on December 1, 2022." The cover page says 2025. This template follows the 2025 cover page. David should confirm which is current.

Federal rules, from LII (https://www.law.cornell.edu/rules/frbp/…, fetched 2026-10-14; LII reproduces the Administrative Office text, but check the uscourts.gov PDF before relying on the exact wording):

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| MOEB-AC-001 | L.R. 7003(A) | "An 'Adversary Proceeding Cover Sheet' (Local Form 18) must accompany all adversary complaints." | Not produced (separate clerk form). README, this section. |
| MOEB-AC-002 | L.R. 7003(B) | Filing fee per the Procedures Manual. | Not produced. |
| MOEB-AC-003 | L.R. 7003(C), 9004(A) | Caption of all pleadings in an adversary: court and division; top left the debtor and the plaintiff and defendant; top right the case number with judge code, chapter, adversary number (once assigned), and any hearing date, time, location and response date. | `caption()` in `typst/moeb-adversary-complaint.typ`; `case_number`, `judge`, `chapter`, `caption.debtor`, `caption.parties` in the sample frontmatter. |
| MOEB-AC-004 | L.R. 9004(B) | Descriptive title of the relief sought. | `title` (sample frontmatter). |
| MOEB-AC-005 | L.R. 9004(C) | Paper 8½ × 11 inches; margins no less than 1 inch; one side; "standard, 12-point font"; all factual and legal allegations in separately numbered paragraphs (memoranda excepted). | `margin = 1in`, `type-size = 12pt` (footer included), numbered paragraphs in `allegations()`. |
| MOEB-AC-006 | L.R. 9004(D) | "All filings must include, or be accompanied by, a certificate of service" (CM/ECF service needs no listing; a non-ECF party must be named; a separate certificate may follow within 24 hours, D)(3)). | Optional `certificate` block (`certificate-block()`); not in this sample (the exemplar has none). See open question 2. |
| MOEB-AC-007 | Fed. R. Bankr. P. 7010 | Form of adversary pleadings: Fed. R. Civ. P. 10 applies; caption "must substantially conform to the appropriate version of Form 416". | Caption (MOEB-AC-003). |
| MOEB-AC-008 | Fed. R. Bankr. P. 7008(a) | Jurisdiction: "a reference to the name, number, and Code chapter of the case … and the district and division where it is pending"; "a complaint … must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | `{{consent}}` marker in the jurisdiction paragraph (sample ¶7); `consent-md()` renders the statement, or a bold placeholder when the sample has no `consent` value. The build fails (an `assert`) if the body lacks the marker. |
| MOEB-AC-009 | Fed. R. Civ. P. 10(b) (via 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Numbered paragraphs (template). Counts are headings. |
| MOEB-AC-010 | Fed. R. Bankr. P. 9004(a)–(b) | Legible; caption with (1) court name, (2) title of the case, (3) case number and adversary number, (4) brief designation of the document's character. | Caption and title. |

Not produced (separate filings, or the court's own forms): Adversary Proceeding Cover Sheet (Local Form 18; the exemplar's cover is Form 104 "L.F. 18"); the summons (L.R. 7004(A): the court issues it, so the plaintiff does not file one); the civil filing fee.

## Layout choices (not rule-fixed)

- **Font**: EB Garamond 12 pt, the only vendored face (`fonts/`). L.R. 9004(C) names no typeface. The exemplar uses Times. EB Garamond sets about the same number of lines, and the render comes to 6 pages, the same as the exemplar's complaint pages.
- **Spacing**: double (27.6 pt baseline pitch, which is 2 × the 13.8 pt single line). The local rules fix no line spacing; double is the custom in the exemplar. Headings and caption are single-spaced.
- **Footer**: arabic page number, centered, bottom. The exemplar's ECF header (`Case 25-04038 Doc 1 … Pg n of 8`) and the filer's document number at the foot of each page are court or word-processor output; not reproduced.
- **No line numbers, no pleading rules.** Unlike N.D. Cal. (Civil L.R. 3-4), E.D. Mo. has no pleading-paper requirement. The exemplar has none.
- **Caption**: the debtor and party block sits in the left column with a rule on its right and bottom; the case block sits in the right column (Form 416 layout). The exemplar uses the same layout.
- **Paragraph numbers**: the template numbers the allegations 1, 2, …; they match the exemplar's numbers because the sample transcribes the text in the same order. The WHEREFORE clauses are unnumbered (`%` marker), as in the exemplar.
- **Section sign**: a non-breaking space after "§" and between "U.S.C." and "§", so "§ 548" never splits (the exemplar's Count II heading does split).
- **Trailing spacing**: each paragraph block carries `below: body-leading`. Typst does not include a paragraph's trailing leading in its height; without it, paragraphs collide (a defect found and fixed during this review).
- **Keep-together**: the last chunk is kept in one unbreakable block with the signature block and certificate, so a signature never stands alone on a page.

## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `judge`, `chapter`, `adversary_number` (blank for a new complaint), `caption.debtor` (lines), `caption.parties` (`names`, `designation`), `title`, `lead_in` (unnumbered first paragraph), `consent` (`consents` or `does not consent`; absent renders a placeholder), `signature` (`date`, `firm`, `by`, `attorneys`, `lines`), and optional `hearing` (lines) and `certificate` (paragraphs).
- Body: blank-line-separated chunks. `# …` section heading (centered caps); `## …` sub-heading (centered bold); `1. …` or `- …` list (lettered (a), (b), …); `%…` unnumbered paragraph; `%%…` centered unnumbered; anything else a numbered paragraph.
- `{{consent}}` goes inside the jurisdiction paragraph, not on a line of its own, so it does not shift the numbering.
- No tables, no forced line breaks, no raw typst in the sample.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env, see below)
sh tools/render.sh courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/adversary-complaint riske-dempster
```

Toolchain: `micromamba create -p ~/tb -c conda-forge typst=0.15.0 poppler imagemagick gawk jq` (the box has no root and no typst). `typst --version` → 0.15.0.

Overlay page map (`usage/OVERLAY-riske-dempster.txt`): ours p.1 ↔ filed p.3 (70.4%), p.2 ↔ p.4 (66.0%), p.3 ↔ p.5 (63.8%), p.4 ↔ p.6 (66.3%), p.5 ↔ p.7 (67.4%), p.6 ↔ p.8 (69.1%). The pairing is by word overlap (coarse); the exemplar's cover sheet (filed pages 1 and 2) has no counterpart in our render, so the offset is the cover sheet. The overlay is a diagnostic, not a score.

## Gate 2: visual review (every page, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtor and parties left, case block right), title, lead-in, ¶¶ 1–6 | OK. No overlap. Caption rule closes the left column. |
| 2 | ¶ 7 with the bold consent placeholder, ¶ 8, FACTS heading, ¶¶ 9–16 | OK. Placeholder is intentional (see open question 1). |
| 3 | ¶ 17, COUNT I heading, ¶¶ 18–25 | OK. Heading and first paragraph spaced correctly after the fix. |
| 4 | ¶¶ 26–34, WHEREFORE (Count I), COUNT II heading (two lines), ¶ 30–34 | OK. "11 U.S.C. § 548" held together; the heading breaks after "PURSUANT TO", as in the exemplar. |
| 5 | ¶ 35, WHEREFORE (Count II), COUNT III heading, ¶¶ 36–41 | OK. Empty space at foot is the keep-together for the last WHEREFORE with the signature. |
| 6 | WHEREFORE (Count III), date, signature block with attorneys, bar numbers and contacts | OK. Signature block does not stand alone. |

Layout findings fixed during this review (not in the final render): paragraphs overlapped their neighbours (no trailing leading in block height; fixed with `below`); a heading and the paragraph after it overlapped the same way (the wrapper block lacked `below`); a signature block alone on page 6 (fixed with the keep-together).

## Open questions and gaps (for David)

1. **Consent statement (FRBP 7008(a)).** The exemplar does not state whether the trustee consents to final orders by the bankruptcy judge. The rule requires it ("must state whether the pleader does or does not consent"; failure "does not constitute consent"). The sample shows the bold `[COUNSEL TO STATE …]` placeholder at ¶ 7 rather than inventing a position for the trustee. The 23andMe complaint (below) states it at its ¶ 10 ("the Debtors consent to the entry of a…"). Decision needed: which position the sample should carry for a template fixture. The template is correct either way.
2. **Certificate of service (L.R. 9004(D)).** The rule says all filings must include or be accompanied by one; the exemplar has none, and the complaint's summons certificate is separate (L.R. 7004(B)). The template renders a certificate only when the sample supplies `certificate`. Should the template require one? My reading: L.R. 9004(D)(3) allows a separate certificate within 24 hours, so the complaint itself need not carry one; confirm.
3. **Local Form 18 (cover sheet).** Required by L.R. 7003(A), not produced here. The exemplar's cover sheet is the same clerk form (its footer says "L.F. 18 Rev. 06/08"). Whether to produce it is a separate decision.
4. **Font.** EB Garamond, not Times (open question 2 in the cand README applies here too). No rule names a face.
5. **Effective date.** See the caveat under Governing rules (L.R. 1001(C) says 2022; cover says 2025).
6. **Length.** The exemplar's complaint is 6 pages and so is the render. The brief's 8–14 target does not apply: the transcribed complaint is that length, and no text was added to reach 8.

## Exemplar search (what was tried)

- CourtListener REST search (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=moeb&q=…`), queries: "adversary complaint"; with paging; then per-result RECAP PDF lookup. Usable complaints found: Riske v. Dempster, 25-04038 (8 pages, 2025-06-16; **saved**); 23andMe Holding Co. v. J.R., 25-04011 (25 pages, 2025-04-14; Carmody MacDonald PC; text layer yes; **not saved**, checked for structure and the consent paragraph); Jimmie Lee Brown, 19-04194 (3 pages, Casamatta complaint); Bernard Steven Hooks, 22-04032 (3 pages). Morrell adversary 25-04009 (corrected complaint, 8 pages) was in the results and not downloaded.
- Second and third filers for tier 2 (CLAUDE.md asks for 2 or 3): 23andMe 25-04011 is one; a second one from a different filer would be needed for a full tier-2 judgment. The brief asks for one exemplar per doc type, so only one is saved.
- The court's own site (https://www.moeb.uscourts.gov/) is blocked from this box for direct downloads; the local rules were read through WebFetch.

## Engines

Three engines from one markdown contract. typst is the primary template and is unchanged here. This section covers the docx engine (`docx/`), added with the DOCX export (fb-595.23.14).

| Engine | Folder | Output for `riske-dempster` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `usage/OUTPUT-adversary-complaint.typst.pdf` (not in the snapshot; `tools/render.sh`) | unchanged |
| docx | `docx/` | `usage/OUTPUT-adversary-complaint.docx`, `usage/OUTPUT-adversary-complaint.docx.pdf` | rendered by LibreOffice; all 6 pages rendered at 60 dpi and viewed |

Build: `sh docx/make-reference.sh <absolute path>/docx/reference.docx` rebuilds the reference (pandoc's default reference, edited for the court's form). `sh tools/render.sh --engine docx <court-dir> usage/INPUT-adversary-complaint.md` writes the `.docx` and the LibreOffice PDF. `docx/moeb-adversary-complaint.lua` builds the caption table, the numbered paragraphs, the consent sentence, the signature block and the certificate (if the sample has one).

LibreOffice here is 26.8.1, unpacked from the document-foundation Linux tarball (conda-forge has no LibreOffice). The vendored EB Garamond is installed for the user running LibreOffice (`docs/DOCX.md`), so the PDF embeds only EB Garamond.

**Matches typst** (measured on page 1 of both PDFs with `pdftotext -bbox`, and read on every page):

- US Letter, 1 in margins, arabic page number centred at the foot, 12 pt including the footer.
- EB Garamond 12 pt throughout. Body lines at 27.6 pt (double), caption, signature block and served entries at 13.8 pt (single).
- Caption: a table, the debtor and parties left with a rule on the right and bottom, the case block right, court name centred and bold.
- Numbered paragraphs: first line at 0.5 in, the number, then the text at a fixed tab stop. `%` paragraphs unnumbered, `%%` centred.
- Heading 1 centred bold caps, Heading 2 centred bold, both kept with the next paragraph.
- `{{consent}}` becomes the FRBP 7008(a) sentence, or the bold placeholder when the sample has no `consent`.
- No break after "U.S.C." or before and after "§".
- The signature block and the last paragraph stay together, as in typst.

**Differs from typst** (not tier-1):

- Two-digit paragraph numbers: typst starts the text after the number plus 0.5 in, so it sits about 6 pt further right than the docx, which uses one tab stop for every number.
- Heading 1 is 17 pt in the docx, 16.8 pt in typst. The caption title sits within 1 pt of typst; the lead-in after it is about 7 pt lower in the docx (LibreOffice places exact-height lines differently).
- Widow/orphan control is off, as in typst. Pagination is still close but not identical: page 1 ends after ¶ 5 in the docx and after ¶ 6 in typst; both are 6 pages.
- Not opened in Microsoft Word (not available here). LibreOffice opens and converts the file; the renderer checks the parts are well-formed XML. Word may paginate slightly differently.

**docx BLOCKED items:** none for the layout. The gate runner (`tools/check.sh --engine docx`) is not run: this court folder has no `rules.md`, `checks.yaml` or `reviews/` yet, so MOEB-AC-001 to 010 are checked by hand on the docx PDF, not by the gate. BLOCKED: gate runner, gates 0 to 3 on docx, no `checks.yaml` in the court folder yet.

**Source issue (not changed):** `usage/INPUT-adversary-complaint.md` writes "11 U.S.C § 550" (no period after "C") in the Count III WHEREFORE clause. Both engines reproduce it as written.
