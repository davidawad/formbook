# W.D. Wash. Bankruptcy (wawb): motion with memorandum in support (`motion-brief`)

- Court: `wawb`, United States Bankruptcy Court, Western District of Washington at Seattle (`courts/ninth-circuit/washington/federal/bankruptcy-western-district/`)
- Doc type: `motion-brief`. One combined notice, motion and memorandum (LBR 9013-1(c)(3)(A)), with the certificate of service.
- Exemplars (`exemplars/`, provenance in `exemplars/SOURCE.md`):
  - `FILED-EXAMPLE-smith-24-10218-motion-brief.pdf`: the primary exemplar, 19 pages, filed 2025-04-09 (Dkt. 139). The sample is transcribed from it.
  - `FILED-EXAMPLE-pigida-14-01248-motion-brief.pdf`: a second filer, a 2015 memorandum (15 pages). Used for the caption and line-number conventions only. Not overlaid (see Gaps).
- Sample: `samples/INPUT-smith-motion-memorandum.md` (frontmatter + markdown body).
- Render: `sh tools/render.sh courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief samples/INPUT-smith-motion-memorandum.md` writes `samples/OUTPUT-smith-motion-memorandum.pdf`, 13 pages, no typst warnings, vendored font only.
- Overlay: `sh tools/overlay.sh courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief smith-motion-memorandum courts/ninth-circuit/washington/federal/bankruptcy-western-district/motion-brief/exemplars/FILED-EXAMPLE-smith-24-10218-motion-brief.pdf` writes `samples/OVERLAY-smith-motion-memorandum.pdf` (13 pages) and `.txt` (page map). The third argument is needed: without it the tool takes the first `exemplars/*.pdf` alphabetically, which is the Pigida memorandum.
- Status: template built, rendered, overlaid and every rendered page viewed (13 of 13). Not reviewed by a human; `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `motion-brief`. |
| `typst/wawb-motion-brief.typ` | Template. Parameter block at the top: font, 12-point type, double-spacing leading, margins, caption and notation settings. |
| `samples/INPUT-smith-motion-memorandum.md` | Transcription of the Smith motion and memorandum (see Gaps for what is left out). |
| `samples/OUTPUT-smith-motion-memorandum.pdf` | Our render. |
| `samples/OVERLAY-smith-motion-memorandum.pdf`, `.txt` | Red = our render, blue = filed exemplar, black = both. `.txt` maps each of our pages to its best-matching filed page. |

## Governing rules

Local rules, W.D. Wash. Bankruptcy. The versions were not fully verifiable on 2026-10-14; see Gaps.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LBR 9004-1 (form of papers), text as quoted from <https://www.wawb.uscourts.gov/node/828> | Pleadings on 8½ × 11 paper, in a standard embedded font, 11 or 12 point, double spaced. Each pleading bears line numbers in the left margin (the Official Forms and clerk's forms are excepted). The right side of the top of the first page carries the assigned judge's name; motions and notices carry the notations required by LBR 9013-1(d). The bottom of each page carries an abbreviated title and page number on the left, and the preparer's name, address and phone on the right. | `set page` (us-letter), `EB Garamond` at `12pt`, `body-leading`, `par.line` numbering per page, `top-notations`, `pleading-footer` |
| LBR 9013-1(b)(3), (c)(3)(A) (as summarized in search results from wawb.uscourts.gov, Local Form 1) | Motion and hearing notice, with date, time and place of hearing, the response date, and the statement that the court may grant the motion without further notice if no timely response is filed. The notice may be combined with the motion if the caption says so and the notice is the first part of the text. | `top-notations` (hearing location, date, time, response date); the sample's first part is the notice |
| LBR 9013-1(d)(1)(A), (B) (heading only confirmed: "Notation of Judge, Chapter, Location, Date, Time of Hearing, and Response Date") | The notation block at the top of the first page. | `top-notations`; field labels follow the Local Form 1 fields |
| Exemplar `exemplars/SOURCE.md` (Smith filing) | Structure of the filed paper: notation block at top right, ")" caption column, footer with title and page number and counsel block. | `caption` (party block, ")" column, case block), footer layout |

Line numbers: the fetched LBR 9004-1 text requires them, so the template numbers the text lines of each page from 1 (typst `par.line`, scope `page`). The Smith filing has none, which the SOURCE.md notes; the template follows the rule, not that filing.

## Overlay

Page map (`samples/OVERLAY-smith-motion-memorandum.txt`): ours p.1 → filed p.1 (71% word overlap), p.2 → 2, p.3 → 2, p.4 → 3, p.5 → 4, p.6 → 5, p.7 → 9, p.8 → 12, p.9 → 13, p.10 → 14, p.11 → 17 (21%), p.12 → 18, p.13 → 19. The map is by word overlap, not by index, because the transcription is partial: our page 7 corresponds to filed page 9, and filed pages 6–8 and 15–16 are not transcribed.

What the overlay shows: on page 1 (checked at 70 dpi, a coarse view) the court name, the top-right notation block and the caption fall in the same area as on the filed page, with visible offsets of a line or so between the red and blue text in the notation block. The overlay was not re-examined at higher resolution, and the later pages were compared only through the page map above, so body-line drift and quotation spacing are not measured here. Tier-2 spacing against the filed page is therefore not established.

## Gaps

1. **LBR 9004-1 version.** The text fetched is the copy effective 12/01/2017. The SOURCE.md refers to the December 1, 2023 local rules; that revision was not retrieved, so its form requirements are unverified.
2. **LBR 9013-1(d) and the Local Form 1 fields.** Only the heading of (d)(1)(B) was confirmed. The field list follows the Local Form 1 summary. The court site has two Form 1 versions (Eff. 12/19 and a generic motion form eff. 6/23); which one governs was not resolved.
3. **Margins.** The fetched rule text gives no margin dimensions. The template uses 1 inch on all sides and a 1.4-inch bottom margin for the footer; this is a choice, not a rule value.
4. **Line numbers** are numbered per text line, restarting on each page, not as the fixed 1–28 pleading-paper rules that the old paper form uses. Caption and headings are unnumbered.
5. **Certificate of service** is set flush left (no first-line indent) because its address blocks are paragraphs. The filed certificate indents its first paragraph.
6. **Signature keep-together.** The date line and signature block are held together. In this render they moved to page 11 alone, leaving that page nearly blank after the memorandum ends on page 10.
7. **Transcription is partial.** The sample is 13 rendered pages (the brief's range is 8–14). Omitted from the filed 19 pages: the first-mortgage recording table (replaced with a bracketed note in the sample), the second-mortgage proof-of-claim calculations and their exhibits (filed pages 14–17), and the exhibit pages. The bracketed note is the only inserted text.
8. **Second exemplar not overlaid.** `overlay.sh` takes one exemplar per run. The Pigida memorandum was filed in 2015, under the rules before the current LBR; it informed the caption and line-number choices only.
9. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` were not run for this doc type; the brief asked for render and overlay only. No `tracker.sh`, `STATUS.md` or `court.json` change.
