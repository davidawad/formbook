# txnd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of Texas (`txnd`).
Folder: `courts/fifth-circuit/texas/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-lilly-v-brown-3-26-cv-03514-complaint.pdf` (Eli Lilly, non-class complaint); second filer `exemplars/FILED-EXAMPLE-burkes-bsw-3-26-cv-03570-complaint.pdf` (Burkes, class complaint). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-lilly-complaint.md` (a portion of the 35-page filing: caption, sections I to III of the general allegations, cause of action 1, prayer, jury demand, signature) |
| render | ok: `samples/OUTPUT-lilly-complaint.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-lilly-complaint.pdf` and `samples/OVERLAY-lilly-complaint.txt` (page map) |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed after the last template change) |
| file names | the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf` (the names `tools/render.sh` and `tools/overlay.sh` use); the brief's `<id>.pdf` and `<id>-overlay.pdf` were not used, to keep the tools unchanged |

## Governing rules

No primary-source text was fetched for the rules below in this run. The court's rule pages and the Cornell LII copy of the FRCP were not reachable from this box (courtrules.net returned 403 to a direct fetch, and txnd.uscourts.gov returned 404 for the local-rules page). The "checked" column records the search-result excerpts used, not the full text. Before the complaint template is treated as final, the full text of each rule must be read from the court's own site.

| Rule | Requirement | Checked | Where it is in the template |
|---|---|---|---|
| Fed. R. Civ. P. 8(a) | Short and plain statement of jurisdiction, claim and relief. | not fetched (from the rule's text as known; to verify) | Author content; the template does not check it. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, title, file number. | not fetched | `cover()`: court title, `CIVIL ACTION NO.` (file number), title of the paper. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited to a single set of circumstances. | not fetched | `allegations()` numbers each body paragraph; headings and lists are not numbered. |
| N.D. Tex. LR 10.1 (Required Form) | Typed or printed, 8½ × 11, numbered pages, title on each paper, signature block with bar number, fax and email. | search excerpt, courtrules.net, `local-rules/26607`, 2026-10-14 | `signature-block()` carries bar number, telephone, fax, email; page numbers at the foot of each page. |
| N.D. Tex. LR 3.1 / 3.2 (complaint filing) | A complaint is filed with a civil cover sheet, the fee or an IFP application, and a separately signed certificate of interested persons (LR 3.1(c)). Paper filers also give a summons per defendant (LR 3.2). | search excerpt, courtrules.net `local-rules/2500` and `2499`, 2026-10-14 | Not produced by this template (separate filings). Listed under known gaps. |
| N.D. Tex. LR 7.2 | 12-point or larger type, double spacing, margins of at least one inch. Written for briefs. | search excerpt, courtrules.net `local-rules/26655`, 2026-10-14 | Applied to the complaint by convention (12 pt, 24 pt pitch, 1 inch margins). The rule does not state that it governs complaints. |

Judge-specific requirements (individual judges' standing orders) are not checked.

## Layout

- Court title on three centered lines: `IN THE UNITED STATES DISTRICT COURT` / `FOR THE NORTHERN DISTRICT OF TEXAS` / division.
- Caption: each party name is one row with a section mark (§) beside it, the case number (`CIVIL ACTION NO.`) and the jury legend on the right. This is the N.D. Tex. convention in the Legacy and Coney filings. Lilly's exemplar uses a `)` column and Burkes's uses none; both are seen in the court's filings.
- Title of the paper, centered, bold, caps.
- Body double-spaced (24 pt pitch), 12 pt EB Garamond, 1 inch margins, 0.5 inch first-line indent, numbered paragraphs.
- Headings: level 1 centered bold caps; level 2 bold, left, hanging indent; level 3 centered bold.
- Prayer items numbered `1.`, `2.`, ...; the jury demand is a heading and a paragraph.
- Signature block single-spaced at the right half: `Dated`, `Respectfully submitted`, firm, `/s/`, name, bar number, address, telephone, fax, email, role.
- Page numbers centered at the foot of every page; no header.

## Overlay (`samples/OVERLAY-lilly-complaint.pdf`)

Red is our render, blue is the filed exemplar, black is where they agree. The pages are paired by word overlap (`tools/overlay.sh`), so a partial transcription still lines up with the pages it came from. The overlay is a diagnostic, not a score: the sample is a portion of the filing, paragraph numbers are not transcribed, and our page breaks do not follow the filing's. The overlay pairs our pages 1 to 7 with filed pages 1, 3, 6, 8, 9, 10 and 11 (in that order), and our pages 8 to 10 with filed pages 25, 34 and 35. Read the page map in `samples/OVERLAY-lilly-complaint.txt`.

## Known gaps and open choices

1. **Rules not read from primary source.** See the table above. The FRCP and LR 10.1 text came from search excerpts, not the court's site. A reading of the full rules is needed.
2. **Typeface.** The filed exemplars use Times New Roman (system font, not vendored). `fonts/` vendors only EB Garamond, so EB Garamond is used. It has a smaller x-height than Times at 12 pt, so the text looks smaller than the exemplar. A vendored Times-metric font (in `fonts/`, a shared directory this task may not change) would remove the difference.
3. **Certificate of interested persons and cover sheet (LR 3.1).** Not produced by this template. A complaint filed without them is deficient under LR 3.1; they must be filed with the complaint.
4. **Jury demand is numbered.** In the filed exemplar the jury demand is an unnumbered paragraph under its heading. The template numbers every body paragraph, so the jury demand comes out as paragraph 44. Tier 2; open.
5. **Prayer items** are numbered `1.` to `7.`. The filed exemplar letters the sub-items of item 1 (i, ii, iii, ...); the sample omits them, and the template has no sub-item form. Tier 2; open.
6. **Headings.** Level 2 and level 3 headings are left-aligned in the template. The filed exemplar centers its sub-cause heading ("Unfair Competition in Violation of..."). Tier 2; open.
7. **Signature block alone on the last page.** The signature falls on page 10 with no body text. This matches the filed exemplar (its page 35 holds only the signature), so it is recorded as ACCEPTED.
8. **One sample only.** EVAL-LOOP asks for two or three filers in tier-2 comparison. The second filer (Burkes) is saved in `exemplars/` but not transcribed. Its caption and signature block were read and match the structure used here.
9. **Case-name italics.** The text layer carries no italic markup, so case names are not italicized in the sample. The template italicizes `*...*` markdown, so future samples can carry italics.
10. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run. The page review above is the Gate 2 equivalent.

## Review of the rendered pages (`samples/OUTPUT-lilly-complaint.pdf`, 10 pages)

Each page was rendered at 60 dpi and viewed after the last template change.

- Page 1: court title on three lines; caption with § column; `CIVIL ACTION NO. 3:26-cv-03514` and `JURY TRIAL DEMANDED` on the middle rows; `COMPLAINT` title; paragraphs 1 to 3. Pass.
- Page 2: paragraphs 4 to 7 (double-spaced; no overlap after the block-spacing fix). Pass.
- Page 3: paragraphs 8 to 12; `THE PARTIES` and `JURISDICTION AND VENUE` headings, each on its own line with space below. Pass.
- Page 4: paragraphs 13 to 19; `GENERAL ALLEGATIONS` and the level-2 heading "I. FDA'S RIGOROUS..." (two lines, hanging indent). Pass.
- Page 5: `II. LILLY DEVELOPS...` heading; paragraphs 20 to 24. Pass.
- Page 6: paragraphs 25 to 29; `III. BAD ACTORS...` heading and `A. The Black Market...` (level 3, left-aligned). Pass (see gap 6).
- Page 7: paragraphs 30 to 34; `B. FDA's and Lilly's Efforts...`. Pass.
- Page 8: paragraphs 35 to 41; `CAUSES OF ACTION`, `FIRST CAUSE OF ACTION` (level 2, left), its sub-heading (level 3). Pass (see gap 6).
- Page 9: paragraph 42; `PRAYER FOR RELIEF`; paragraph 43 `WHEREFORE`; prayer items 1 to 7; `JURY DEMAND` heading; paragraph 44 (see gap 4). Pass with gaps 4 and 5.
- Page 10: signature block (`Dated: October 8, 2026`; `Respectfully submitted,`; firm; `/s/`; name; bar number; address; telephone; fax; email; role). Pass (see gap 7).

Earlier review rounds found and fixed: court-title and caption lines overlapping (single-spaced stacks had zero gap); numbered paragraphs running together (paragraphs were inline, not blocks); a heading's second line colliding with the next paragraph (missing space below). The overlap bug is recorded as a template rule: a block whose content is a paragraph needs `below: body-leading`, or the next block starts one natural line height (about 0.65em) below it.
