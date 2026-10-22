# Adversary complaint: U.S. Bankruptcy Court, D. Utah (utb)

Doc type folder for a complaint commencing an adversary proceeding. Engines: typst (`typst/`, the reference) and docx (`docx/`). Exemplars and their filers are in `usage/SOURCE.md`.

## Files

| Path | What it is |
|---|---|
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...` |
| `typst/utb-adversary-complaint.typ` | The template: parameters, caption, numbered allegations, prayer, signature, verification |
| `docx/reference.xml` | The Word styles, page and footer (built by `fb render`; base `xengine`) |
| `docx/utb-adversary-complaint.lua` | The docx filter: the same chunks, caption, signature and verification as the typst template |
| `eval.yaml` | `params.cross_engine: gate` |
| `usage/INPUT-adversary-complaint.md` | Our transcription of the Plaza 106 verified complaint (frontmatter + body) |
| `usage/OUTPUT-adversary-complaint.typst.pdf` | Our render, `sh tools/render.sh`, 10 pages |
| `usage/OUTPUT-adversary-complaint.docx` / `.docx.pdf` | The docx render and its LibreOffice PDF, 10 pages |
| `usage/OVERLAY-plaza106-verified-complaint.pdf` / `.txt` | Red (ours) / blue (filed) / black (both) overlay against `FILED-EXAMPLE-adversary-complaint.pdf`, and the page map |
| `usage/FILED-EXAMPLE-adversary-complaint.pdf` | Filed exemplar, Doc 1, 19 pp. |
| `usage/FILED-EXAMPLE-adversary-complaint-2.pdf` | Second filed exemplar (different filer), Doc 1, 19 pp. with exhibits; not overlaid |

Commands (run from the repo root, toolchain on PATH):

```
sh tools/render.sh courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint plaza106-verified-complaint courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint/usage/FILED-EXAMPLE-adversary-complaint.pdf
```

`overlay.sh` with no third argument picks the first PDF in `usage/` alphabetically, which is the Clauson filing. Pass the Plaza file explicitly to overlay the sample in this folder.

## Rules

The sample and the template follow these rules. The "text checked" column records what was actually read in this run (2026-10-14). Anything marked "cited, not re-read" is carried from the template's own comments and still needs a primary-text check.

| Rule | Requirement used | Where to check (not fetched) | Text checked |
|---|---|---|---|
| Fed. R. Bankr. P. 7001, 7008(a), 7010 | Adversary proceeding types; jurisdiction and consent-to-final-orders statement; caption substantially in Form 416 | uscourts.gov, current bankruptcy rules | cited, not re-read |
| LBR 9004-1(a)(2), (b) | Caption per Official Form 416D; title | court site, https://www.utb.uscourts.gov/ | cited, not re-read |
| LBR 5005-3(a)(2)–(7) | Margins, minimum 12 pt, page number at foot | court site, https://www.utb.uscourts.gov/ | cited, not re-read |
| LBR 7003-1 | Cover sheet filed separately (not in this template) | court site, https://www.utb.uscourts.gov/ | cited, not re-read |
| DUCivR 10-1(1), (3), (4), (6)(A) | Top margin 1½ in, side margins 1 in, 12 pt, double spacing, contact block (applies in bankruptcy through LBR 1001-1(a)) | court site, https://www.utd.uscourts.gov/ | cited, not re-read |
| Fed. R. Civ. P. 10(b) | Numbered paragraphs | uscourts.gov, current civil rules | cited, not re-read |

The "where to check" column is a pointer, not a fetched source. The court's local-rules pages were not retrievable from this environment (the court's `/local-rules` paths returned 404, and the public mirror at courtrules.net returned 403).

What was read in this run: the court's Proposed Local Rule Amendments summary dated 2024-10-23 (proposed effective 2024-12-01), https://www.utb.uscourts.gov/sites/utb/files/Proposed%20LR%20Amendments%2010-23-24.pdf. It covers LBR 1007-1, 2003-1 and 9013-1(m)–(n). It does not amend LBR 5005-3, 7003-1 or 9004-1, and it does not give the text of the rules this template uses.

## Overlay: what it shows

The overlay compares our render with the Plaza 106 filing (Doc 1, 19 pp.) page by page. Pages are paired by shared words, not by index.

- Page map (`OVERLAY-plaza106-verified-complaint.txt`): ours p.1–5 map to filed p.1–5; ours p.6 → filed p.7; p.7 → filed p.8; p.8 → filed p.9; p.9 → filed p.18.
- Caption, counsel block, court title, and the title line agree closely in the overlay (word overlap 89% on p.1).
- The body runs at the same rhythm as the filing: numbered paragraphs, headings, the prayer's lettered items, and the verification.
- Our sample is shorter than the filing (about 2,600 words against about 5,200 in the filing). Filed pp.9–17 are blue-only: the rest of the general allegations and the later counts. Ours p.9 maps to filed p.18, where the prayer and verification sit.

## Gaps

1. **Partial transcription.** The sample transcribes the caption, jurisdiction, parties, general allegations through Count 1, and the prayer. It does not transcribe the rest of the general allegations or the later counts (filed pp.9–17). The sample is kept as-is per the "keep unless broken" rule; the blue-only pages in the overlay are this gap.
2. **FRBP 7008(a) statement is ours, not the filer's.** Paragraph 4 of the sample states "Plaintiff does not consent to the entry of final orders or judgment by the bankruptcy court." Neither filed exemplar contains that statement: the text of both PDFs has no "consent" in it (checked this run; see `usage/SOURCE.md`). The template asserts that the statement is present, so the sample supplies it. This is the one place the sample departs from the exemplar.
3. **Verification.** The date and place of execution are blanks (`__________`) in the sample's frontmatter, as the input gives them. The template prints them as given.
4. **Rule text.** The rules in the table above are cited, not re-read. Nothing in this folder is verified against the court's current local-rules text.
5. **Page count.** Our render is 10 pages; the filing is 19 pages, including the verification and no exhibits. Ten pages is inside the 8–14 target for the body the sample transcribes; it is not the full filing.
6. **Second exemplar not overlaid.** The Clauson filing (a different filer, with exhibits) is kept as a second exemplar for tier-2 comparison. It is not overlaid here and is not used in the sample.

## Engines

The typst template is the reference; the docx engine is in `docx/` (`reference.xml`, the Word styles; `utb-adversary-complaint.lua`, the filter). Command: `sh tools/render.sh --engine docx courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md`. `fb render` builds the reference document from `docx/reference.xml`; no shell script and no binary `reference.docx` (fb-595.68).

Both engines are on the shared cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`; docs/EVAL-LOOP.md, "Cross-engine gate"), and the docx breaks every line and page where the typst render does: `eval.yaml` sets `params.cross_engine: gate`, and XENG-001..003 pass (248/248 lines, 10 = 10 pages).

- **Face and size**: Times New Roman 12 pt on both (no rule names a face, UTB-FORM-004; the docx used to name EB Garamond and failed DEF-FONT-002). The docx names the face only as `{font}`, the typst template's face.
- **Pitches** (Word's exact line spacing; twips = 20 x pt): the body double-spaced at 24 pt (480; DUCivR 10-1(4)), no extra space between paragraphs; counsel block, court title, caption, title, headings, signature and verification lines single-spaced at 13.8 pt (276). Headings 12 pt bold (levels 1 and 2 centered, level 3 at the margin), 18 pt above and 6 pt below, kept with the text after them. The parts of the first page 24 pt apart.
- **Body** (chunk by chunk, in both engines alike): the lead-in before the first heading and the WHEREFORE paragraph unnumbered, indented 0.5 in; every other paragraph a numbered allegation (Fed. R. Civ. P. 10(b)), its number ("1.") in a 0.4 in box after the 0.5 in indent, the text from 0.9 in and its other lines at the margin; a prayer item "A. ..." with its letter in the same box and its lines hanging at 0.9 in; a list's label in a 0.5 in box.
- **Caption** (Form 416D): the party column 3.3 in wide, ruled on its right and at its foot (0.75 pt; its text 10 pt from the right rule and 8 pt above the foot), a blank single line between its elements; the case numbers and the judge 0.15 in right of the 0.25 in gutter. The docx writes it as a one-row table.
- **Signature and verification**: "DATED ..." at the margin, the firm beside it at 3.4 in, a blank single line, "/s/" and the signer's lines under the firm; the last chunk (the last prayer item) is kept on one page with the signature block (it stood alone on the page before). The verification (28 U.S.C. § 1746) is kept on one page: the heading, the declaration double-spaced, "Executed on ..." at the margin, the declarant's name and title under it at 3.4 in (they stood beside a wrapped "Executed on" line before).
- **Page**: letter, top margin 1.5 in (DUCivR 10-1(1)), 1 in on the other sides; the page number centered at the foot of every page in a single-pitch line whose box ends 0.5 in above the page edge.
- **Reading**: the docx filter reads the sample chunk by chunk (the text between blank lines), as typst does, and the frontmatter as written (`$FORMBOOK_META`: "__________" stays a blank, not a rule). Break rules both engines share: no break inside ")(" or between a sign and its number ("§§ 1334(b)": typst boxes `[§¶]+ \S+`, the docx binds it with a no-break space), no break at a hyphen before a digit, a break after a slash before a letter.
- **Limits**: footnotes are not supported (both engines read the body chunk by chunk, so a footnote's definition would be a chunk of its own; the sample has none). The allegation numbers are typed text, not Word list numbering, so they do not renumber on edit in Word.
