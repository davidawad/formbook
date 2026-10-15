# United States Court of International Trade (cit): complaint

- Court: `cit`, United States Court of International Trade (`courts/federal-circuit/court-of-international-trade/`)
- Doc type: `complaint`. Pleading under USCIT Rule 7(a)(1); one self-contained folder.
- Exemplar: `exemplars/FILED-EXAMPLE-trek-bicycle-complaint.pdf` (*Trek Bicycle Corp. v. United States*, Ct. No. 25-00917, filed 2025-12-23, ECF No. 2, 11 pages; provenance in `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-trek-bicycle.md`, transcribed from that complaint (caption, cause of action, parties, jurisdiction, facts, counts I-V, prayer, signature). Sample render is 9 pages against the filed 11.
- Status: template complete; render, overlay and page review done (below). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `cit-complaint`. |
| `typst/cit-complaint.typ` | Template. Parameter block at the top (type size, leading, page, margins, caption widths). |
| `samples/INPUT-trek-bicycle.md` | Markdown contract sample: YAML frontmatter plus body. |
| `samples/OUTPUT-trek-bicycle.pdf` | `sh tools/render.sh courts/federal-circuit/court-of-international-trade/complaint samples/INPUT-trek-bicycle.md` (9 pages). |
| `samples/OVERLAY-trek-bicycle.pdf`, `.txt` | `sh tools/overlay.sh courts/federal-circuit/court-of-international-trade/complaint trek-bicycle` (red = ours, blue = filed, black = agree). |
| `exemplars/` | The filed complaint and `SOURCE.md`. |

## Markdown contract (frontmatter)

| Key | Required | Meaning |
|---|---|---|
| `court` | yes | list of court-name lines, printed in capitals at the top of the cover |
| `court_no` | yes | court number, e.g. `"25-00917"`, printed right of the caption (Rule 81(g) status) |
| `before` | no | assigned judge, printed under the court number when the case is assigned |
| `caption` | yes | list of sides; each has `names` (list) and `designation` (`Plaintiff,` / `Defendants.`) |
| `brief_title` | yes | title of the pleading, e.g. `COMPLAINT` |
| `lead_in` | no | opening paragraph before Cause of Action |
| `unnumbered` | no | headings whose paragraphs are not numbered (e.g. `PRAYER FOR RELIEF`) |
| `date` | yes | date line of the signature block |
| `signature` | yes | `signer` and `lines` (counsel block; Rule 11(a) requires address, e-mail and telephone) |

The body is markdown. Each blank-line-separated paragraph that is neither a heading nor a list is numbered (Rule 10(b)); headings are unnumbered; lists are lettered.

## Governing rules

Primary source: United States Court of International Trade, Rules of the Court, "As amended August 21, 2026, eff. August 21, 2026", <https://www.cit.uscourts.gov/sites/cit/files/COMPLETE%20RULES%20AND%20FORMS.pdf> (the complete rules and forms PDF, 487 pages). Downloaded and read on 2026-10-14.

| Requirement ID | Rule (quoted in part) | Where the template uses it |
|---|---|---|
| CIT-PAPER-001 | Rule 81(f): "Pleadings and other papers must be 8½ by 11 inches in size" | `page-w`, `page-h`, `paper: "us-letter"` |
| CIT-PAPER-002 | Rule 81(f): "typed matter not exceeding 6½ by 9½ inches" | `margin-x`, `margin-y` (1 inch all round, 6½ × 9 in typed area; the page number sits in the bottom margin) |
| CIT-TYPE-001 | Rule 81(f): "type size of 12 points or larger, including type used in footnotes" | `type-size = 12pt`; `set text(size:)` |
| CIT-SPACE-001 | Rule 81(f): "Typed matter must be double spaced except footnotes, ..., quoted material, ... and titles, schedules, tables ..." | `pitch = 24pt`, `body-leading`; caption, counsel and signature lines single-spaced (permitted by the same sentence) |
| CIT-NUM-001 | Rule 81(d): "The pages of each paper must be numbered consecutively, commencing with the number 1" | `numbering: "1"`, `running-number()` |
| CIT-NUM-002 | Rule 81(f): "Pages must be numbered on the bottom." | page number in the footer |
| CIT-CAP-001 | Rule 10(a): "Every pleading must have a caption with the court's name, a title, a court number, and a Rule 7(a) designation. The caption of the summons and the complaint must name all the parties" | `cover`, `caption` (all parties, designations, court number) |
| CIT-CAP-002 | Rule 7(a): the pleadings allowed are a complaint, answers and the rest; the designation is the party's role (Plaintiff / Defendants) | `designation` field per side |
| CIT-COUNT-001 | Rule 10(b): "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances" | `allegations()` numbers each body paragraph |
| CIT-SIG-001 | Rule 11(a): "Each paper must state the signer's address, e-mail address, and telephone number." | `signature-block` lines |
| CIT-SIG-002 | Rule 11(a): signed by "at least one attorney of record in the attorney's name" | `/s/` line with `signature.signer` |
| CIT-STAT-001 | Rule 81(g): papers must identify "the court number assigned to the case" and, if assigned, the judge | `court_no`, optional `before` |
| CIT-PDF-001 | Rule 81(b): e-filed papers "must be filed in Portable Document Format (PDF) and must be text-searchable to the maximum extent possible" | typst output is a text-searchable PDF with embedded fonts (checked with `pdffonts`, `pdftotext`) |

Not applicable to the complaint and not in the template: Rule 7(b) motion requirements (see `../motion-brief/README.md`); Rule 81(h) confidential-information sets (none in the sample).

## Overlay

`samples/OVERLAY-trek-bicycle.pdf` puts our render (red) over the best-matching page of the filed complaint (blue); black is where both agree. Pages are paired by word overlap, not by index. Diagnostic only, not a score. Pairings from the last run:

- p.1 ↔ filed p.1 (40%): cover. Our caption is a ")" column; the filed caption uses rules above and below and a bold title. Layout differs; see Known gaps.
- p.2 ↔ p.2 (73%), p.3 ↔ p.3 (69%): numbered paragraphs line up.
- p.4 ↔ p.5 (56%), p.5 ↔ p.6 (80%), p.6 ↔ p.7 (75%), p.7 ↔ p.8 (54%): facts and counts follow the same passages.
- p.8 ↔ p.10 (63%), p.9 ↔ p.11 (35%): prayer, signature block. The filed signature block sits on its own page; ours follows the prayer.

## Page review (Gate 2)

Every page of `OUTPUT-trek-bicycle.pdf` was rendered at 70 dpi and viewed (9 of 9), next to the filed complaint's 11 pages in a contact sheet. Typst printed no warnings. Fonts embedded: EB Garamond only.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | Cover: court name, caption, counts of parties, "COMPLAINT" centered. Caption uses ")" column; filed uses rules. Tier 2 convention not settled (one filer). | ACCEPTED |
| 2 | exemplar p.2 | Numbered paragraphs, centered section headings. Headings bold but not underlined; filed headings are bold and underlined. | ACCEPTED |
| 3 | exemplar p.3 | Paragraph numbering and double spacing as filed. | PASS |
| 4 | exemplar p.4 | STATEMENT OF FACTS heading and numbered paragraphs 18-21 as filed. | PASS |
| 5 | exemplar p.5 | Numbered paragraphs 22-28 as filed. | PASS |
| 6 | exemplar p.6 | Numbered paragraphs 29-36 as filed. | PASS |
| 7 | exemplar p.7 | COUNT I-IV headings centered, bold. | PASS |
| 8 | exemplar p.8 | COUNT V heading and paragraphs 50-52; PRAYER FOR RELIEF heading, lettered list (a)-(h). | PASS |
| 9 | exemplar p.9-11 | Prayer list (a)-(h) on p.8 as filed. Signature block on its own page 9 with the /s/ line, counsel lines and date; the filed signature block continues to p.11. | PASS |

## Engines

Typst is the primary engine (`typst/`). The docx engine is in `docx/`. There is no `latex/` engine and no `checks.yaml` for this doc type.

### docx

| Path | What |
|---|---|
| `docx/make-reference.sh` | Builds `docx/reference.docx` from pandoc's default: EB Garamond 12 pt, 24 pt exact double spacing for body text and list items, single spacing for headings, block quotations and footnotes, letter paper, 1 in margins, a centered PAGE field in the footer. |
| `docx/cit-complaint.lua` | Pandoc filter: the cover and caption (a borderless table with the ")" column), numbered allegations, lettered list items (a), (b), ..., the signature block. |
| `samples/OUTPUT-trek-bicycle.docx` | `sh tools/render.sh --engine docx courts/federal-circuit/court-of-international-trade/complaint samples/INPUT-trek-bicycle.md` (writes the `.docx` and the `.docx.pdf`). |
| `samples/OUTPUT-trek-bicycle.docx.pdf` | LibreOffice 26.8.1 conversion (10 pages). Fonts embedded: EB Garamond only (`pdffonts`). |

**Matches the typst output:** letter paper, 1 in margins, EB Garamond 12 pt, double spacing (24 pt), court name and caption with the ")" column and the court number at right, the title centered, centered bold headings, numbered allegations with the number at 0.5 in, the lettered prayer (a)-(h), the centered page number at the bottom, the `/s/` signature block with the Rule 11(a) lines. Every page of the `.docx.pdf` was rendered at 60 dpi and viewed (10 of 10), and the page text was compared with the typst render (`pdftotext`).

**Differs from the typst output:**

- Length: 10 pages against the typst 9. The line breaks fall differently from page 3 on (the docx page 8 starts at paragraph 40; the typst page 8 starts at paragraph 49), so the signature block is on its own page 10 and the prayer ends on page 9. Length is not mandated for a complaint; the difference is LibreOffice's line breaking, not the form.
- Paragraph numbers are typed text followed by a tab, not Word list numbering, so the numbers do not renumber if a paragraph is added by hand in Word.
- Word was not run. The file has no Word repair check; it is valid XML in a zip (`render-docx.sh`), and the `.docx.pdf` is LibreOffice's rendering.

**docx BLOCKED items:** none for this doc type.

## Known gaps

- **Exemplars: one filer.** Only the Sidley Austin complaint is in `exemplars/`. Tier 2 (house style vs convention) needs 2 or 3 filers; the caption layout and heading underlining above are open until a second filer's complaint is checked. Not judged against one filer.
- **Caption.** The sample's caption uses a ")" column per line (with `pad` for designations). The filed caption uses horizontal rules and no ")" column. Both satisfy Rule 10(a); which one the clerks prefer is not settled.
- **Headings.** Filed section headings are underlined; ours are bold only.
- **Length.** The sample is 9 pages, the filed complaint 11; the sample is an excerpt-length transcription, so the page count is not a measure of compliance.
- **Engines.** Typst and docx (see Engines). No `latex/` engine and no `checks.yaml` for this doc type.
- **Overlay pairing.** Word-overlap pairing is noisy on the cover (40%) and the signature page (35%); the pairs are given above, not claimed as exact matches.
