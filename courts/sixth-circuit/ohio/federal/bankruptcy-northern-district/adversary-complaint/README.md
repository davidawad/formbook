# N.D. Ohio Bankruptcy Court: adversary complaint

Status: template built, sample rendered on typst and docx, overlay run, every page reviewed on both engines (Gate 2 by eye, 2026-10-22). Engines: typst and docx on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; XENG gated in `eval.yaml`); latex not built.

## Governing rules (verified 2026-10-14)

| Requirement | Kind | Source | Verified | What the template does |
|---|---|---|---|---|
| Caption: court name, title of the case, case number and adversary number, brief designation of the document | M | FRBP 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | 2026-10-14 | Court name, debtor caption, case no., chapter, judge, adversary no., title |
| Caption substantially conforms to Official Form 416A; FRCP 10 applies in an adversary proceeding | M | FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | 2026-10-14 | Caption layout (parties on the left, numbers on the right) |
| Jurisdiction allegation names the bankruptcy case (name, number, chapter, district, division) and states whether the pleader consents to final orders by the bankruptcy court | M | FRBP 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | 2026-10-14 | Frontmatter fields for case no. and chapter; the body carries the consent paragraph (Rule 7012(b)) |
| Paper: 8 1/2 x 11 inch, one side, no pre-punched holes | M | LBR 5005-1(a) (N.D. Ohio Local Bankruptcy Rules, last revised May 16, 2011, https://www.ohnb.uscourts.gov/sites/default/files/file-list/local-bankruptcy-rules.pdf) | 2026-10-14 | US Letter, one-sided output |
| Signature block: typewritten name, firm, address, telephone, e-mail, bar number, "s/name" | M | LBR 5005-1(c) (same PDF) | 2026-10-14 | `signature` block; the sample carries the bar number |
| Adversary cover sheet at commencement | M | LBR 7003-1 (same PDF) | 2026-10-14 | **Not generated** (see Known gaps) |
| Complaint in numbered paragraphs, one set of circumstances each | M (via FRCP 10(b), which FRBP 7010 applies) | FRBP 7010 text, above | 2026-10-14 (the FRCP 10(b) text itself was not fetched) | Numbered paragraphs written as escaped markdown (`1\. `) |
| Type size 12 pt | C | LBR 9013-2(a) sets 12 pt for motions and briefs only; complaints have no N.D. Ohio size rule | 2026-10-14 | 12 pt Times New Roman (convention; the face of both filed complaints) |
| Margins, double spacing, heading style | C | No N.D. Ohio rule found; chosen from the filed exemplar | - | 1 in margins, 24 pt body pitch, 13.8 pt single lines (court lines, caption, title, signature), centred bold caps headings on the body pitch |

Not verified in this session: FRBP 7001 (adversary categories) and FRCP 10(b) text. Nothing in the template depends on them beyond the citations above.

## Files

- `typst/main.typ`: entry point; reads `usage/<id>.md` (`--input sample=`).
- `typst/ohnb-adversary-complaint.typ`: template `ohnb-adversary-complaint(meta, body)`.
- `usage/`: two filed complaints (Alrachid, debtor counsel; Stone, U.S. Trustee). Sources in `usage/SOURCE.md`.
- `usage/INPUT-adversary-complaint.md`: body of the Alrachid complaint (caption, jurisdiction, parties, background, Counts II to VI, prayer, signature). Exhibits are not transcribed. The signature address is two lines, as filed (was one line, 2026-10-22).
- `usage/OUTPUT-adversary-complaint.typst.pdf`, `.docx`, `.docx.pdf`: our renders (6 pages each, the same lines and pages).
- `docx/reference.xml`: the Word styles (`base="xengine"`, Times New Roman 12 pt, Body Text on 480 twips with a 720 twip first-line indent, single lines 276 twips; "Body Text Keep" for the last chunk).
- `docx/ohnb-adversary-complaint.lua`: the docx filter (court lines, caption table, title, headings, body, signature, the footer and the section through `$FORMBOOK_FOOTERS` and `$FORMBOOK_FINAL`).
- `eval.yaml`: `params.cross_engine: gate`.
- Overlays: `just overlay <this folder>` writes `.overlay/.../OVERLAY-adversary-complaint.pdf` (gitignored).

Build and check:

```sh
cd /work/repo
sh tools/render.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/render.sh --engine docx courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/check.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/adversary-complaint --engine typst
sh tools/check.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/adversary-complaint --engine docx
sh tools/overlay.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/adversary-complaint adversary-complaint
```

## Gate 2 review (by eye, every page of the current PDFs)

Reviewed 2026-10-22: every page of `usage/OUTPUT-adversary-complaint.typst.pdf` and of the LibreOffice PDF `usage/OUTPUT-adversary-complaint.docx.pdf` rendered at 60 dpi side by side and viewed; page 1 compared with page 1 of both filed complaints (Alrachid, Stone). The two engines set every line and page alike (XENG-001..003 gated: 6 = 6 pages, 157/157 lines), so one table serves both.

| Page | Finding | Status |
|---|---|---|
| 1 | Court lines centred bold capitals (as both filed complaints); caption: debtor, plaintiff and defendant lines at the left, the ")" column, case, chapter, judge and adversary numbers at the right, one single line per row; the bold centred title single-spaced; JURISDICTION, PARTIES; paragraphs 1 to 4. | PASS |
| 2 | Paragraphs 5 to 11, BACKGROUND. Double spacing, 0.5 in first-line indent; the page ends two lines short (paragraph 12 kept whole: widow and orphan control). | PASS |
| 3 | Paragraphs 12 to 22, Counts II to IV headings centred bold at the type size on the body pitch. | PASS |
| 4 | Paragraphs 23 to 33, Count VI. "§§ 1336.04" kept with its number. | PASS |
| 5 | Paragraphs 34 to 39, Count V, PRAYER FOR RELIEF, prayer items 1 to 5. | PASS |
| 6 | Prayer item 6, the closing paragraph kept with the signature block, which stands single-spaced from the middle of the line as in both filed complaints (was at the left margin with double-spaced lines, alone on page 6). | FIXED |

Open tier-2 rows: none. The .docx was opened in LibreOffice only (no repair prompt), not in Word.

## Known gaps

- Length: the sample renders to 6 pages, short of the 8 to 14 page target. The transcription covers the whole body of the exemplar (paragraphs 1 to 39 and the prayer); the exemplar's extra length is the exhibit ledger (pp. 8 to 31), which is not transcribed.
- Adversary cover sheet (LBR 7003-1) is not generated. A court-issued form is required; the PR for this court must carry it separately.
- FRBP 7008(a) requires the jurisdiction allegation to name the bankruptcy case, its number, chapter, district and division. The Alrachid exemplar does not do so in paragraph 1, and the sample transcribes it as filed. The template does not generate that sentence and no check enforces it yet: a tier-1 gap for a future check, to be closed before this doc type is marked done.
- Count I's heading does not appear in the exemplar's text layer. The sample does not invent one.
- Tier 2 (line spacing, caption ")" column, heading style) is judged against the Alrachid and Stone exemplars only by eye; the overlay is not a score. Stone's caption shows the adversary number blank.
- LaTeX is not built for this doc type.

## Engines

docx (`docx/`): `docx/reference.xml` (fb render builds the styles from the cross-engine recipe, `base="xengine"`, in the typst face Times New Roman; was `build-reference.sh`, `render.sh` and a committed `reference.docx` in EB Garamond, fb-595.68.30) and `docx/ohnb-adversary-complaint.lua` on `lib/docx/xengine.lua`: every paragraph in exact line boxes of the typst pitches (480 and 276 twips), the caption a borderless fixed table of 5040, 432 and 3888 twips (typst 3.5, 0.3 and 2.7 in), the signature 4680 twips (3.25 in) from the margin, the footer's centred page number 720 twips from the bottom edge (typst footer-foot 0.5 in), the typst break rules on every run (no break inside ")(", a break after a slash before a letter, a doubled section sign bound to its number).

- `sh tools/check.sh <this folder> --engine docx`: every gate green, XENG-001..003 PASS (6/6 pages, 157/157 lines).
- `tools/check-selftest.sh` takes a court root with `court.json` and does not run on this doc-type folder.
- Not generated by either engine: TOC, TOA, pleading line numbers (no N.D. Ohio rule requires them).
- The .docx was opened in LibreOffice only, not in Word.
