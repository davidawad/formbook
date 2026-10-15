# Adversary complaint: U.S. Bankruptcy Court, D. Utah (utb)

Doc type folder for a complaint commencing an adversary proceeding. Engine: typst (`typst/`). Exemplars and their filers are in `exemplars/SOURCE.md`.

## Files

| Path | What it is |
|---|---|
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...` |
| `typst/utb-adversary-complaint.typ` | The template: parameters, caption, numbered allegations, prayer, signature, verification |
| `samples/INPUT-plaza106-verified-complaint.md` | Our transcription of the Plaza 106 verified complaint (frontmatter + body) |
| `samples/OUTPUT-plaza106-verified-complaint.pdf` | Our render, `sh tools/render.sh`, 9 pages |
| `samples/OVERLAY-plaza106-verified-complaint.pdf` / `.txt` | Red (ours) / blue (filed) / black (both) overlay against `FILED-EXAMPLE-plaza106-26-02063-adversary-complaint.pdf`, and the page map |
| `exemplars/FILED-EXAMPLE-plaza106-26-02063-adversary-complaint.pdf` | Filed exemplar, Doc 1, 19 pp. |
| `exemplars/FILED-EXAMPLE-clauson-23-02053-adversary-complaint.pdf` | Second filed exemplar (different filer), Doc 1, 19 pp. with exhibits; not overlaid |

Commands (run from the repo root, toolchain on PATH):

```
sh tools/render.sh courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint samples/INPUT-plaza106-verified-complaint.md
sh tools/overlay.sh courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint plaza106-verified-complaint courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint/exemplars/FILED-EXAMPLE-plaza106-26-02063-adversary-complaint.pdf
```

`overlay.sh` with no third argument picks the first PDF in `exemplars/` alphabetically, which is the Clauson filing. Pass the Plaza file explicitly to overlay the sample in this folder.

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
2. **FRBP 7008(a) statement is ours, not the filer's.** Paragraph 4 of the sample states "Plaintiff does not consent to the entry of final orders or judgment by the bankruptcy court." Neither filed exemplar contains that statement: the text of both PDFs has no "consent" in it (checked this run; see `exemplars/SOURCE.md`). The template asserts that the statement is present, so the sample supplies it. This is the one place the sample departs from the exemplar.
3. **Verification.** The date and place of execution are blanks (`__________`) in the sample's frontmatter, as the input gives them. The template prints them as given.
4. **Rule text.** The rules in the table above are cited, not re-read. Nothing in this folder is verified against the court's current local-rules text.
5. **Page count.** Our render is 9 pages; the filing is 19 pages, including the verification and no exhibits. Nine pages is inside the 8–14 target for the body the sample transcribes; it is not the full filing.
6. **Second exemplar not overlaid.** The Clauson filing (a different filer, with exhibits) is kept as a second exemplar for tier-2 comparison. It is not overlaid here and is not used in the sample.

## Engines

The typst template is the primary form. The DOCX engine is in `docx/` (`reference.docx`, `utb-adversary-complaint.lua`, `build-reference.sh`). Command: `sh tools/render.sh --engine docx courts/tenth-circuit/utah/federal/bankruptcy-district/adversary-complaint samples/INPUT-plaza106-verified-complaint.md`.

**What the docx matches** (the same mandated form as the typst template): EB Garamond 12 pt; exact 24 pt line pitch; 0.5 in first-line indent; letter paper with a 1.5 in top margin and 1 in other margins; centred bold level-1 and level-2 headings; 12 pt single-spaced footnotes; a bottom-centre page number (PAGE field in the footer). The cover is built from the same metadata: counsel block, court title, Form 416D caption (a borderless table with a right and a bottom rule on the party column), title. Numbered allegations: the filter types `1.`, `2.`, ... at 0.5 in with the text at 0.9 in on the first line (a tab stop); the lead-in and the WHEREFORE paragraph are unnumbered; the prayer items `A.`-`H.` hang at 0.9 in. Signature block and verification are borderless tables.

**What differs**: the numbers are typed text, not Word list numbering, so they do not renumber on edit. Word and LibreOffice break lines differently, so the page count of the docx is not the typst page count (the typst render is 9 pages). Table rules are drawn by the application. The EB Garamond font must be installed where the file is opened, or Word substitutes silently. The template has no table of contents or table of authorities.

**BLOCKED for the docx engine** (not done on this box):
- `docx.pdf` (`samples/OUTPUT-plaza106-verified-complaint.docx.pdf`, the LibreOffice PDF on which Gates 0 and 1 are measured): BLOCKED, `soffice` not installed on the box (no conda-forge package, no root).
- Zip integrity step of `tools/render-docx.sh` (`unzip -tq`): BLOCKED, `unzip` not installed on the box. `tools/render.sh --engine docx` wrote `samples/OUTPUT-plaza106-verified-complaint.docx` and then exited 1 with `render-docx.sh: unzip: not found` and `not a valid zip`. As a substitute, every XML and rels part was checked with `ziptool` and `xmllint --noout`: all well-formed.
- Visual review of the docx pages (opened in LibreOffice or Word, no repair prompt): BLOCKED, no LibreOffice and no Word. Pages reviewed: 0. The typst render (9 pages) was reviewed page by page; the docx was not.
- `sh tools/check.sh <dir> --engine docx` not run to a pass: it needs the `.docx.pdf` (see above), so no `.check-docx.txt` stamp is written.
