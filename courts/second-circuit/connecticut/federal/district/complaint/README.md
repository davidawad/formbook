# ctd: complaint

Doc type: **complaint** (Complaint and Demand for Jury Trial) in the United States District Court for the District of Connecticut (`ctd`). Folder: `courts/second-circuit/connecticut/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `usage/FILED-EXAMPLE-complaint.pdf` (see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-complaint.md`, the whole filing: caption, lead-in, all 66 paragraphs, five causes of action, prayer, jury demand, signature block |
| render | ok: `usage/OUTPUT-complaint.typst.pdf`, 12 pages, typst 0.15.0, vendored Times New Roman only (embedded), no typst warnings; docx: `usage/OUTPUT-complaint.docx` and `.docx.pdf`, 12 pages, every line as typst |
| typeface | no face named by the rules; Times New Roman, the house face (vendored, embedded). See Known gaps 2 |
| overlay | ok: `usage/OVERLAY-forzano-complaint.pdf` and `OVERLAY-forzano-complaint.txt` (pairs by text; exemplar PDF `usage/FILED-EXAMPLE-complaint.pdf` fetched from the SOURCE.md URL on 2026-10-15) |
| pages reviewed | 12 of 12 on both engines (rendered to PNG and viewed on 2026-10-22) |

Commands (run with `export PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/second-circuit/connecticut/federal/district/complaint usage/INPUT-complaint.md
sh tools/overlay.sh courts/second-circuit/connecticut/federal/district/complaint forzano-complaint
```

File names follow the repo tools rather than the brief's `<id>.pdf` and `<id>-overlay.pdf`: `render.sh` writes `OUTPUT-<id>.pdf` and `overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt` by default, and the tools are not to be edited here. The sample is `INPUT-<id>.md`, as in the other courts.

## Governing rules

Primary sources, fetched 2026-10-14:
- D. Conn. Local Rules of Civil Procedure (as amended; the rules PDF "Current-Revised-Local-Rules-9.4.26"), https://www.ctd.uscourts.gov/sites/default/files/Current-Revised-Local-Rules-9.4.26.pdf (linked from https://www.ctd.uscourts.gov/court-info/local-rules-and-orders). Rule 10 and Rule 7(a)(5) quoted below.
- Electronic Filing Policies and Procedures, rev. Oct. 3, 2025, https://www.ctd.uscourts.gov/sites/default/files/Electronic-Filing-Policies-and-Procedures-10.3.25.pdf (sections I.F, II and XI).
- Fed. R. Civ. P. 8, 10, retrieved from https://www.law.cornell.edu/rules/frcp/rule_8 and rule_10.

| ID | Rule | Requirement | Where it is in the template |
|---|---|---|---|
| CTD-FORM-001 | D. Conn. L. Civ. R. 10 | "Pleadings shall be double-spaced, on 8-1/2" by 11" pages." | `pitch-body = 27.6pt` (lib/typst/xengine.typ line boxes). 27.6 pt is 2 x 13.8 pt, the single line of 12 pt Times in Word; the exemplar measures 27.6 pt pitch. Checked on the render with `pdftotext -bbox`: every body line 27.6 pt apart. |
| CTD-FORM-002 | L. Civ. R. 7(a)(5) (memoranda); L. Civ. R. 10 (pleadings, silent on size) | Text at least 12 point "unless otherwise ordered". | `type-size = 12pt`. The 12 pt size is taken from L. Civ. R. 7(a)(5), which sets it for memoranda; for pleadings it is a convention that matches the exemplar. |
| CTD-FORM-003 | EFPP I.F.2 (fonts) | PDF records must embed every font; base-14 fonts (Times New Roman among them) need no embedding, others must be embedded and legally embeddable. | Times New Roman (vendored) is embedded as subsets on both engines (`pdffonts`). |
| CTD-FORM-004 | L. Civ. R. 10 | "margins of at least 1"" (left and right); the template uses 1 inch on all sides. | `margin = 1in`. |
| CTD-FORM-005 | L. Civ. R. 10 | "page numbers in the bottom margin of each page after page 1." | `footer`: centred number, suppressed on page 1 (`counter(page).get().first() > 1`). |
| CTD-FIRST-001 | Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation; the complaint's title names all parties. | `court` (two lines, from the sample), `caption.parties` (every party named, with designation), `brief_title`, `case_number`. |
| CTD-FIRST-002 | L. Civ. R. 10 | "The complete docket number, including the initials of the Judge to whom the case has been assigned, shall be typed on each pleading. The date of each pleading shall be included in the case caption." | `case_number` must include the judge's initials (the template prints it as given); `date` printed in the caption right column (`Date:`). |
| CTD-PARA-001 | Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()` numbers each body paragraph 1, 2, ... from the Markdown, the number in a half-inch box after the half-inch indent. Headings and lists are not numbered. `<!-- unnumbered -->` marks the wherefore clause and the jury demand. |
| CTD-SIG-001 | L. Civ. R. 10; EFPP XI.B | Signature block: "/s/" name of the password registrant, typewritten name, office address, telephone, fax (if available), e-mail, federal bar number. | `signature` (`signer`, `bar`, `lines`); `signature-block()` prints "/s/ name", "name, Fed. Bar No. bar", then the lines. |
| CTD-SIG-002 | L. Civ. R. 10 | "The date of each pleading shall be included in the case caption." | `date`, printed as "Dated:" in the signature block and in the caption. |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS-44), the summons, a Rule 7.1 disclosure statement, and any certification of interested parties the judge requires. Not checked: a jury demand under Fed. R. Civ. P. 38 (the demand is written as in the exemplar; the rule text was not fetched in this pass).

## Layout

- US Letter, 1 inch on every side. No pleading paper: D. Conn. has no numbered-line rule (L. Civ. R. 10 requires double spacing and nothing more). The exemplar has none.
- Caption on page 1 with the court title, a left party column (rule on the right and bottom), and the right column with case number, date and title. Page 1 starts the body under the caption (no separate cover page), as in the exemplar.
- Numbered paragraphs: first line indented 0.5 in, number, then text. Continuation lines return to the margin, as in the exemplar.
- Every line is a box of its pitch (27.6 pt body, 13.8 pt single) on the shared layout model (lib/typst/xengine.typ); blocks carry explicit spaces (one blank body line around the caption and above the signature), so the docx (exact line spacing in the same twips) breaks every line and page as typst.
- Headings: level 1 is a centred bold caps heading, level 2 a centred bold sub-heading (the cause-of-action title), level 3 bold italic, all on the body pitch. A heading is sticky: it never ends a page.
- Bullets stay bullets; ordered lists are lettered (a), (b), ... (the prayer, and any quoted statute).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `case_number` (with judge initials), `court` (list of lines), `caption.parties` (list of `{names, designation}`; "v." is inserted between parties), `brief_title`, `lead_in` (unnumbered lead-in paragraph, optional), `jury_demand` (true puts "DEMAND FOR JURY TRIAL" in the caption), `date`, `signature` (`signer`, `bar` (optional), `lines`).
- Body: blank-line-separated chunks. `#` = level 1 heading, `##` = level 2, `###` = level 3. A chunk starting `1. `, `- ` or `* ` is a list. Any other chunk is a numbered paragraph. A chunk beginning with `<!-- unnumbered -->` (an HTML comment, which the template strips) is an unnumbered paragraph. This replaces a bare `[unnumbered]` prefix, which printed as text the filing does not show.
- Do not put paragraph numbers in the text: a chunk that starts `12. ` is read as a list and lettered. The sample's paragraph numbers were stripped for this reason.

## Known gaps and open choices

1. **One exemplar.** The eval-loop tier-2 rule asks for two or three filers, each a different filer, before tier 2 is judged. The brief asks for one exemplar per doc type. Other D. Conn. complaints checked for a second reference are listed in `usage/SOURCE.md` and were not saved. Tier 2 is therefore judged against the rules and this one filing, and that is not the full bar.
2. **Font.** No rule text read for this doc type names a face. EFPP I.F.2 (fetched 2026-10-15) lists Times New Roman among the base-14 fonts only as fonts that need not be embedded; it sets no typeface. Local Rule 10 names none in the text checked (the 9.4.26 rules PDF cited above returned 404 on 2026-10-15; a 2016 copy of Rule 10 on courtrules.net names none; re-verify against the live rules). The exemplar is set in Times New Roman, which is a convention, not a rule. The template sets Times New Roman, the house standard and the face of every exemplar (vendored, embedded, legally embeddable), on both engines. Judge-specific orders are a separate matter: see the note in `motion-brief/README.md` Known gaps 4 (Judge Bryant's 2018 Electronic Filing Order names Arial 12 pt for documents in that judge's cases; that is one judge's order, not a court rule, and the template does not switch per judge).
3. **Pleading size.** L. Civ. R. 10 is silent on type size for pleadings. 12 pt is used, matching the exemplar and L. Civ. R. 7(a)(5).
4. **Judge initials.** The template prints `case_number` as given; the template does not check that it has the judge's initials. The sample's number carries them.
5. **Date in the caption.** The exemplar's caption has no date; L. Civ. R. 10 requires one. The template follows the rule, so the render has a date line that the exemplar lacks. The sample's date is the ECF filing date from the page header.
6. **Overlay pairing.** `overlay.sh` pairs pages by word overlap. The render has 12 pages and the exemplar 11; the lines differ (the date line in the caption, a different caption and line breaks). The overlay is a diagnostic, not a score.
7. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at its root; this doc-type folder has neither, and the brief forbids touching `tools/`. The gates were not run. Render, overlay and the page review are the Gate 2 equivalent for this doc type.
8. **Bullets versus numbers.** The exemplar's paragraph 19 is a bulleted list; the render keeps bullets. Its prayer and the quoted statute in paragraph 34 are lettered, as in the cand template. The exemplar letters its prayer as (a) to (h); the sample reproduces the split between "d." and "e." as filed.
9. **Typographical errors kept.** "Plaintiffs drives" (paragraph 9), "Plaintiffs incorporates" (paragraph 39), "reliablity" (paragraph 23) and similar are in the sample as filed. They are the exemplar's text, not the template's.
10. **Signature block.** "Fed. Bar No." is the template's label for the bar number (the exemplar prints "ct28597" alone); the exemplar has no fax number, and the template prints a fax line only if the sample supplies one.

## Review of the rendered pages (11 of 11, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (parties with indented designations; right column case number, date, title), lead-in, INTRODUCTION, paragraphs 1 to 7 | OK. Caption rule right and bottom. No overlap after the grid fix. |
| 2 | JURISDICTION AND VENUE, PARTIES, FACTUAL ALLEGATIONS, paragraphs 8 to 16 | OK. Numbers at 0.5 in, text on the 27.6 pt grid. |
| 3 | Paragraphs 17 to 19 and the first three repair bullets | OK. Bullets keep their indent. |
| 4 | Remaining repair bullets, paragraphs 20 to 22 | OK. |
| 5 | Paragraph 23; FIRST CAUSE OF ACTION (level 1 and level 2 sub-heading), paragraphs 24 to 32 | OK. The two-line sub-heading is on the grid. |
| 6 | Paragraphs 33 to 38; the quoted statute as list item (a) | OK. The list is a block of single-line-leading items closed on the grid. |
| 7 | SECOND CAUSE OF ACTION, paragraphs 39 to 46 | OK. |
| 8 | THIRD CAUSE OF ACTION, paragraphs 47 to 54 | OK. Heading at the top of the page is kept with its paragraph. |
| 9 | Paragraph 54 end; FOURTH and FIFTH CAUSES OF ACTION; paragraphs 55 to 61 | OK. |
| 10 | Paragraphs 62 to 66; PRAYER FOR RELIEF with the wherefore clause (unnumbered) and items (a) to (f) | OK. Item (d) ends "by the" and (e) begins "Court", as filed. |
| 11 | Items (g) and (h); DEMAND FOR JURY TRIAL; "Dated" and signature block (/s/, name with bar number, firm, address, phone, e-mail) | OK. Page number shown. |

## Engines

Both engines run on the shared cross-engine layout model (fb-595.68.25; docs/EVAL-LOOP.md, "Cross-engine gate"): `typst/ctd-complaint.typ` on `lib/typst/xengine.typ`, `docx/complaint.lua` on `lib/docx/xengine.lua`, with the same numbers in twips. Times New Roman 12 pt on both (the docx had named EB Garamond); body lines in 27.6 pt boxes (L. Civ. R. 10, double-spaced), single lines (court title, caption, signature, page number) in 13.8 pt boxes; a blank body line between the court title, the caption, the text and the signature; the paragraph number in a half-inch box after the half-inch indent (docx: a tab at 1 in); list labels half an inch in, the text hanging at 1 in; the last paragraph kept with the signature block; no page number on page 1 (docx: `titlePg`, fb render's empty first footer), then the number centred 0.5 in above the bottom edge.

**docx** (`docx/`): `docx/reference.xml` (`base="xengine"`, `{font}`) holds the styles; fb render builds the reference document from it. `docx/complaint.lua` writes the court title, the caption table (party column ruled right and bottom), the lead-in, the headings, the numbered paragraphs (a `<!-- unnumbered -->` comment, which pandoc reads as a raw HTML block, makes the next paragraph unnumbered, as in typst), the lists and the signature block, and the last section and its page-number footer (`$FORMBOOK_FINAL`, `$FORMBOOK_FOOTERS`). No shell script.

`fb diff --engines`: 12 pages each, 0 page ends differ, 269/269 typst lines identical. `eval.yaml` sets `params.cross_engine: gate`.

Gate 2 review of the typst and docx PDFs (12 of 12 pages each, rendered at 50 dpi, pages 1 and 12 at 80 dpi, viewed on 2026-10-22, against `usage/FILED-EXAMPLE-complaint.pdf`):

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (parties with "v." between blank lines, Case No., Date, title), lead-in, INTRODUCTION, JURISDICTION AND VENUE, paragraphs 1 to 4 | OK. Caption ruled right and bottom, as the exemplar. |
| 2 | Paragraphs 5 to 15; PARTIES, FACTUAL ALLEGATIONS | OK |
| 3 | Paragraphs 15 to 19 and the first two repair bullets | OK |
| 4 | Repair bullets continue | OK |
| 5 | Last bullet, paragraphs 20 to 28; FIRST CAUSE OF ACTION and its two-line sub-heading | OK |
| 6 | Paragraphs 29 to 34; the quoted statute as item (a) | OK |
| 7 | Paragraphs 35 to 41; SECOND CAUSE OF ACTION | OK |
| 8 | Paragraphs 42 to 49; THIRD CAUSE OF ACTION | OK |
| 9 | Paragraphs 50 to 55; FOURTH CAUSE OF ACTION with two sub-headings | OK |
| 10 | Paragraphs 56 to 63; FIFTH CAUSE OF ACTION | OK |
| 11 | Paragraphs 64 to 66; PRAYER FOR RELIEF, the unnumbered wherefore clause, items (a) to (e) | OK |
| 12 | Items (f) to (h); DEMAND FOR JURY TRIAL; "Dated" and "Respectfully submitted," on one line; the /s/ block | OK. Page number shown. |

ACCEPTED (tier 3): the exemplar underlines its headings and sets the court title in three lines ("FOR THE"); the template's headings are bold, not underlined, and the court title is the two lines of the sample.
