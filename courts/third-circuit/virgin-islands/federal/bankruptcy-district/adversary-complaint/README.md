# Adversary complaint: United States Bankruptcy Court, D.V.I. (`vib`)

Doc type `adversary-complaint`, under [`../`](../) (the bankruptcy district court). Governing rules: FRBP 7001 (adversary proceedings), 7008, 7010; LBR of the District Court of the Virgin Islands, Bankruptcy Division (`LBR 5005-1`, `LBR 7008-1`).

## What is here

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...`, splits frontmatter, calls the template. |
| `typst/vib-adversary-complaint.typ` | The template: `complaint(meta, md)`. Every number is a named parameter or traces to a rule. |
| `usage/INPUT-vib-adversary-complaint-springelfirstamended.md` | Transcription of the filed First Amended Complaint, with the frontmatter contract below. Two sentences are marked `ADDED` (see VIB-AC-JURIS). |
| `usage/OUTPUT-vib-adversary-complaint-springelfirstamended.typst.pdf` | Our render (`tools/render.sh`). 10 pages. |
| `usage/OVERLAY-springel-first-amended.pdf` / `.txt` | Red (ours) / blue (filed) overlay and the page map (`tools/overlay.sh`). |
| `usage/SAMPLE-vib-adversary-complaint-springelglobalbank0903071.pdf` | The filed exemplar (13 pp., text layer). |
| `usage/SOURCE.md` | Where it came from, filer, case, date filed, URL, date fetched. |

File names follow the tools, not the brief: `tools/render.sh` writes `usage/OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name and writes `OVERLAY-<id>.pdf/.txt`. The sample is `INPUT-<id>.md` so the file role is in the name (CLAUDE.md).

Build and check (from the repo root):

```sh
sh tools/render.sh courts/third-circuit/virgin-islands/federal/bankruptcy-district/adversary-complaint usage/INPUT-vib-adversary-complaint-springelfirstamended.md
sh tools/overlay.sh courts/third-circuit/virgin-islands/federal/bankruptcy-district/adversary-complaint springel-first-amended
```

Typst is run by `render.sh` with the vendored fonts only (`--ignore-system-fonts`); any warning fails the render. The embedded fonts are `EBGaramond-Regular`, `-Bold`, `-Italic` (checked with `pdffonts`).

## Governing rules (verified 2026-10-14)

| ID | Requirement | Source (verified text) |
|---|---|---|
| VIB-AC-CAPTION | Caption: court name, case title, case number and adversary number, designation of the document (FRBP 9004(b)). The adversary caption substantially conforms to Form 416 (FRBP 7010), which LBR 7008-1(A) specifies as Official Form 416D. | FRBP 9004(b) and 7010: <https://www.law.cornell.edu/rules/frbp/rule_7010>; LBR 7008-1(A) in the VI bankruptcy local rules: <https://www.vid.uscourts.gov/sites/vid/files/local_rules/NewBK_RulesDec2017.pdf> |
| VIB-AC-NUMBER | All paragraphs in pleadings are sequentially numbered (LBR 5005-1(A)); paragraphs numbered consecutively, each limited as far as practicable to a single set of circumstances (FRCP 10(b), applied by FRBP 7010). | LBR 5005-1(A) (same PDF); FRCP 10(b): <https://www.law.cornell.edu/rules/frcp/rule_10> |
| VIB-AC-FONT | Font size no smaller than 12 Courier, or an equivalent size for another face (LBR 5005-1(B)). The template uses 13 pt EB Garamond. Typeface: face required = none (Courier is the size benchmark; any other face is allowed at an equivalent size), so the template keeps EB Garamond and no substitute is needed (visual-only: the face is not court-named). | LBR 5005-1(B), text verified 2026-10-15 from the court's local rules PDF ("no smaller than 12 Courier or an equivalent size if a different font face is used"). The choice of 13 pt is ours, made so the x-height is at least that of 12 pt Courier; 12 pt would be the literal minimum. |
| VIB-AC-PAGE | 8½ × 11 paper; pages sequentially numbered (LBR 5005-1(A)). Footer carries "Page n of N". | LBR 5005-1(A) |
| VIB-AC-JURIS | The jurisdiction allegation names the case (name, number, Code chapter), the district and the division; the complaint states whether the pleader consents to final orders by the bankruptcy court. | FRBP 7008(a): <https://www.law.cornell.edu/rules/frbp/rule_7008> |
| VIB-AC-SIGNATURE | Dated, signed by counsel (`/s/`), with each counsel's name, bar number and address. | FRBP 9011 (signing convention), and the exemplar's signature block |
| VIB-AC-SPACING | Double-spaced body; first-line indent. | The exemplar's line pitch (about twice the type size). Not a rule of the VI bankruptcy court; a convention (tier 2). |

Not a rule of this court, and not generated: a page limit (complaints have none in LBR); the ECF header stamp (the court's, added at filing); the adversary cover sheet and summons (separate documents).

## Frontmatter contract

| Field | Required | Feeds |
|---|---|---|
| `division` | yes | Court header: "DIVISION OF ___, BANKRUPTCY DIVISION". |
| `debtor` | yes | `names` (lines) and `designation` ("Debtor.") in the caption. |
| `chapter`, `case_number` | yes | Right column of the caption. |
| `caption` | yes | Two sides, plaintiff then defendant: `names` and `designation`. "v." between them. |
| `adversary` | yes | `number` (the adversary number), optional `note` (e.g. the "all pleadings to be filed in" line). |
| `title` | yes | Title under the caption, in capitals. |
| `footer` | no | Short title for the footer. Defaults to `title`; keep it short so the footer fits on one line. |
| `date` | yes | "Dated:" line. |
| `signature` | yes | Groups: `signer` (optional, printed as `/s/ name`) and `lines`. Groups are separated by "- and –". |

Markdown body: each numbered paragraph is a markdown list item (`1. ...`). The template numbers them 1, 2, 3, ... through the whole document (counter, not the typed number), so numbering continues across headings. Sub-items stay inline as (a), (b). Unnumbered paragraphs (the opening paragraph, the prayer) are plain paragraphs. `#` is a centered bold heading (PARTIES, PRAYER); `##` is a centered bold heading (Count headings). Footnotes use `[^n]`. Nested lists are not supported.

## What the overlay shows

`usage/OVERLAY-springel-first-amended.txt` pairs each of our 10 pages to the filed page it shares the most words with:

| ours | filed | word overlap |
|---|---|---|
| p.1 | p.1 | 90.7% |
| p.2 | p.2 | 73.4% |
| p.3 | p.3 | 61.8% |
| p.4 | p.5 | 66.6% |
| p.5 | p.6 | 85.9% |
| p.6 | p.8 | 65.6% |
| p.7 | p.9 | 56.7% |
| p.8 | p.10 | 64.6% |
| p.9 | p.11 | 54.4% |
| p.10 | p.12 | 45.6% |

The filed document is 13 pages and ours is 10, so later pages drift (the page pairing is by word overlap, so a page that is shorter in ours pairs with a later filed page). Differences that matter for tier 1 or 2 are: the filed document's ECF stamp (not ours), its firm document ID line in the footer (not ours), and its line breaks (tier 3, not chased). The overlay PDF itself was not opened by eye in this pass; the page map above is word-overlap only. The layout claims in "Pages reviewed" come from the rendered pages of `OUTPUT-vib-adversary-complaint-springelfirstamended.typst.pdf`.

## Pages reviewed (Gate 2, this PDF)

All 10 pages of `usage/OUTPUT-vib-adversary-complaint-springelfirstamended.typst.pdf` were rendered at 60 dpi and looked at:

- p.1: cover. Caption, title and first paragraph on one page. Fixed in this pass: caption lines were indented by the paragraph indent (now zero inside the caption); the footer wrapped to three lines and ran into the bottom margin (now a short `footer` field).
- p.2: headings (PARTIES, JURISDICTION) were larger than the body (set to the body size); paragraphs 1–4.
- p.3–p.6: paragraphs 6–34, footnotes 1–3 at the foot of their pages, count headings centered and bold, numbering continuous across the heading "CAUSES OF ACTION" and "Count" headings.
- p.7–p.9: paragraphs 35–66, the "RESERVATION OF RIGHTS" and "PRAYER" headings.
- p.10: the signature block. Fixed in this pass: counsel lines printed literal asterisks (now rendered as markdown) and the "- and –" separator was read as a bullet (now escaped).

Open findings (Gate 2):

- VIB-AC-JURIS (rule text, tier 1): the filed exemplar does not state the consent to final orders, and its paragraph 3 does not name the division. The sample adds both sentences, marked `ADDED`, so the sample meets FRBP 7008(a). The exemplar predates the current wording of the rule; the sample follows the current text. The template cannot write these sentences (they are case content), so the author must.
- ACCEPTED (tier 3): the filed exemplar's line breaks, the firm document-ID line in the footer and its use of a Times-like face.

## Known gaps

- One exemplar, one filer. Tier 2 asks for two or three exemplars from different filers. A second VI bankruptcy adversary complaint was not located in this pass (searches: CourtListener RECAP `type=rd`, `court=vib`, queries "adversary complaint", "adversary proceeding", "Amended Complaint"; results were mostly motions and orders, and the other complaint PDFs are not available). Tier 2 is therefore judged against this one filer, and the overlay is a diagnostic only.
- No cover sheet, summons or certificate of service is generated. Those are separate filings; the README of the motion records the service gap for the motion.
- The footer uses the sample's `footer` field, not the title, so a sample with a long title and no `footer` field gets a long footer (may wrap to two lines).
- The complaint has no page-limit check (none in the rules).
- No Gate 1 checker for this doc type yet; the claims above are checked by reading the rendered pages, the text layer, and `pdffonts`.

## Log

- 2026-10-14: exemplar found (CourtListener RECAP, Adv. 09-03071, ECF 35); sample transcribed; template built; render ok (no typst warnings); overlay ok; all 10 pages reviewed. Fixes listed above.

## Engines

`docx/` (pandoc 3.6.4, `reference.docx` from `docx/build-reference.sh`, cover and numbering in `docx/vib.lua`). Built from the court folder:

```sh
sh adversary-complaint/docx/build-reference.sh adversary-complaint/docx/reference.docx
pandoc --from markdown+smart --to docx --reference-doc=adversary-complaint/docx/reference.docx \
  --lua-filter=adversary-complaint/docx/vib.lua adversary-complaint/usage/INPUT-springel-first-amended.md \
  -o adversary-complaint/usage/OUTPUT-springel-first-amended.docx
```

- **Matches the typst template:** EB Garamond 13 pt; every line (body, caption, signature) at the 19.5 pt pitch that the typst render measures; 1 in margins on US Letter; 0.5 in first-line indent; footnotes at 13 pt; numbered paragraphs 1 to 66 from one counter through the document (the typed numbers are not used, as in the template); centered bold headings; the court header, the caption table with the Form 416 rules (box around the debtor and parties, vertical rule between the columns), the title, the "Dated:" line and the counsel groups separated by "- and –"; footer "Page n of N".
- **Differs (pandoc and Word limits):** the footer carries no short title (a reference footer cannot take per-document text in pandoc); the caption row padding is approximate; pandoc's metadata title and date are not written into the body (the cover has them) and the document title property is empty; pagination can differ in Word.
- **Not checked here:** the docx has not been opened in Word or LibreOffice (LibreOffice is not installed in the build box). The `.docx` is a valid zip (ziptool reads every entry) and every XML part is well formed (xmllint).
- **BLOCKED (docx.pdf):** this court folder has no checks file (no `checks.yaml`), so no gate check ID is readable. The requirement IDs of `README.md` (VIB-AC-CAPTION, VIB-AC-NUMBER, VIB-AC-FONT, VIB-AC-PAGE, VIB-AC-JURIS, VIB-AC-SIGNATURE, VIB-AC-SPACING) are all measured on the `.docx.pdf`, so all are BLOCKED with the reason: LibreOffice cannot run in the build box, so the .docx.pdf cannot be produced or checked.
- **Finding for the template (tier 2, not changed here):** the typst body pitch is 19.5 pt, about 1.5 times the 13 pt type size, not the double spacing the template comment and VIB-AC-SPACING describe. The docx copies the measured typst pitch so the two match. Whether to double it is a decision for the template owner.

[Formbook index](../../../../../../README.md)
