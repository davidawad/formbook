# Adversary complaint: United States Bankruptcy Court, District of Hawaii

Template built from the court's local rules, one filed exemplar, and one transcribed sample. Not a check.sh-gated court folder: no `rules.md`, `checks.yaml`, `reviews/` or pass stamp yet.

## Files

| Path | Role |
| --- | --- |
| `typst/main.typ` | entrypoint; reads `samples/INPUT-<id>.md` via `--input sample=` |
| `typst/hib-adversary-complaint.typ` | template: counsel block, caption, body, signature |
| `exemplars/FILED-EXAMPLE-hawaii-brewery-26-90013-adversary-complaint.pdf` | filed complaint, Dkt. 1, Adv. 26-90013 (26 pp.) |
| `exemplars/SOURCE.md` | URL, filer, date, and why this exemplar |
| `samples/INPUT-hawaii-brewery.md` | transcription (frontmatter + markdown body) |
| `samples/OUTPUT-hawaii-brewery.pdf` | our render, 12 pages |
| `samples/OVERLAY-hawaii-brewery.pdf` / `.txt` | red (ours) over blue (filed), page map |

Render and overlay (run from `/work/repo`):

```
sh tools/render.sh courts/ninth-circuit/hawaii/federal/bankruptcy-district/adversary-complaint samples/INPUT-hawaii-brewery.md
sh tools/overlay.sh courts/ninth-circuit/hawaii/federal/bankruptcy-district/adversary-complaint hawaii-brewery
```

Both ran with exit 0 and produced the files above. Typst 0.15.0; vendored EB Garamond only.

## Rules

Verified against the official LBR compilation, December 1, 2025 edition (hib.uscourts.gov, `LBR2025_dec01_8001-1_to_9074-1.pdf`, p. 125; `LBR2025_dec01_7001-2_to_7067-2.pdf`, p. 104), text extracted locally with `pdftotext`:

| Rule | Text (abridged) | Template |
| --- | --- | --- |
| LBR 9004-1(a)(1)-(5) | white paper; documents may not exceed 8.5 × 11 in; no staples/clips/covers; no tabs; one-sided | US-letter page; one-sided PDF. Paper stock is outside the template. |
| LBR 9004-1(b)(1) | "All memoranda, including footnotes, shall utilize 14-point type." | Does **not** bind a complaint (not a memorandum). Type set at 14 pt to match the filed exemplar (Times New Roman, 14 pt by pdftohtml size). Left open by the rule; see Gaps. |
| LBR 9004-1(b)(2) | "The text of the document must be double-spaced, except for identification of counsel, title of the case, quotations, footnotes, and exhibits." | Body double-spaced (`body-leading = 1em`, 2.3 em pitch). Counsel block, caption, quotations (indented, single-spaced) and footnotes single-spaced. |
| LBR 9004-1(b)(3) | "Margins must be 1 inch from the edge of the document." | `margin = 1in` on all sides. |
| LBR 7003-1 | "Every complaint initiating an adversary proceeding must be accompanied by a cover sheet substantially conforming to the Director's Procedural Form (Adversary Proceeding Cover Sheet)." | Not rendered. The cover sheet (Official Form B 1040) is a separate filed form, not part of the complaint. |

Not verified in this run (cited from the rule text as I know it, not re-fetched): FRBP 7008(a) (statement of core/non-core and consent to final orders), FRBP 7010 (caption as in Rule 1005), FRBP 9004(b) (form of papers). The complaint's ¶¶ 13–16 in the exemplar follow that practice.

## What the overlay shows

Pairing is by word overlap, not index (`tools/overlay.sh`). From `OVERLAY-hawaii-brewery.txt`:

| Our page | Filed page | Word overlap |
| --- | --- | --- |
| 1 | 3 | 80.3% |
| 2 | 4 | 33.3% |
| 3 | 4 | 51.6% |
| 4 | 6 | 78.5% |
| 5 | 7 | 79.3% |
| 6 | 8 | 72.1% |
| 7 | 9 | 66.0% |
| 8 | 11 | 50.5% |
| 9 | 12 | 56.4% |
| 10 | 13 | 73.1% |
| 11 | 14 | 69.3% |
| 12 | 26 | 69.5% |

The page map is a rough guide. Our page 2 is the caption spill (filed p. 4 carries the same caption continuation), so the low score there is expected. Our page 12 pairs with the filed prayer and signature page (p. 26); this was not checked visually. Overlay PNGs were not inspected page by page in this run; the layout review below was done on the render alone.

## Review (render, pages 1 to 12, each viewed as PNG at 70 dpi)

- p. 1: counsel block and court title; caption starts at the foot of the page. Caption continues on p. 2. Matches the filed p. 3 (caption from the first page).
- p. 2: caption continuation (Plaintiff / v. / Defendants) and the opening paragraph, then "Plaintiff hereby alleges..." Matches filed p. 3–4.
- pp. 3–10: numbered paragraphs ¶¶ 1–60 with a 0.5 in first-line indent and double spacing; centered bold section headings; bold sub-headings; footnotes 1 and 2 at 14 pt at the foot of the page; lease bullets (¶ 19) with hanging text. Body runs straight through pages without a forced break.
- p. 11: ¶ 61, the bracketed transcription note, the WHEREFORE paragraph, prayer items A–H.
- p. 12: the signature block alone (DATED line and the /s/ block, right column). See Gaps.

Clerk-facing points checked on the render: 8.5 × 11 page size; 1-inch margins; double spacing in the body; single spacing in the counsel block, caption, quotations and footnotes; page numbers bottom centre.

## Gaps and open items

1. **Excerpt, not the full complaint.** The sample transcribes ¶¶ 1–61 and the prayer and signature. ¶¶ 62–133 and Counts I–VI (pp. 13–25 of the filed PDF) are omitted and the sample says so in a bracketed note between ¶ 61 and WHEREFORE. Length target (8–14 pp.) is met at 12 pp. The full complaint would run about 24 pp. when rendered.
2. **Signature orphaned on p. 12.** The DATED line and signature block (about 8 lines) do not fit under prayer item H on p. 11 and move to p. 12 whole. The filed complaint keeps the signature with the prayer. OPEN tier-2 item, not fixed in this run: the template keeps the signature block unbreakable but does not pull the last prayer item onto the signature page. A fix would keep prayer item H with the signature block.
3. **Font.** The only vendored font is EB Garamond, not Times New Roman (the filed exemplar's face). Metrics differ, so line breaks differ from the filed page. Tier-3 (matching one filer's face) is not chased.
4. **Type size is rule-open.** LBR 9004-1(b)(1) binds memoranda, not complaints. 14 pt follows the exemplar and the court's memorandum rule; the rule does not require it for a complaint. Recorded so a reviewer can change it if the court's practice differs.
5. **ECF header and footer omitted.** The filed PDF's footer line ("U.S. Bankruptcy Court - Hawaii #26-90013 Dkt # 1 Filed 05/15/26 Page x of y") is applied by the court's ECF system at filing, not typed by counsel. The template prints only a page number.
6. **Cover sheet not included.** Official Form B 1040 (LBR 7003-1) is a separate form. It is not in the template or the sample.
7. **Justification.** Body text is left-aligned (ragged right), as in the filed exemplar. Not a rule requirement.
8. **Exemplar count.** One filer (Klein Law Group / Bosko Petricevic, AAL, LLLC), per `exemplars/SOURCE.md`. Tier-2 judged against one filer only; a second exemplar (Collins v. Hughes Network Systems, Adv. 24-90002) was checked and not saved.
9. **No gate run.** `tools/check.sh`, `check-selftest.sh`, `rules.md`, `checks.yaml` and `reviews/` are not part of this run; the court folder is not claimed or stamped.
