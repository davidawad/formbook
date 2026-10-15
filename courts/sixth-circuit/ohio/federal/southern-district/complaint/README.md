# ohsd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Ohio (`ohsd`).
Folder: `courts/sixth-circuit/ohio/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-doe-v-columbus-2-26-cv-00684-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-doe-complaint.md` (partial transcription, see Known gaps) |
| render | ok: `samples/OUTPUT-doe-complaint.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings, exit 0 |
| overlay | ok: `samples/OVERLAY-doe-complaint.pdf` and `OVERLAY-doe-complaint.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed in the final layout) |

File names follow `tools/overlay.sh` and CLAUDE.md, not the brief's shorter names: the sample is `samples/INPUT-<id>.md`, the render `samples/OUTPUT-<id>.pdf`, the overlay `samples/OVERLAY-<id>.pdf` and `.txt`. The tool reads and writes those names by default.

## Governing rules

Primary source for the local rules: S.D. Ohio Local Rules as amended 2024-10-21, `https://www.ohsd.uscourts.gov/sites/ohsd/files/2024-10-21%20Local%20Rules.pdf`, read 2026-10-14 (the PDF was read through WebFetch; its text was extracted from the saved copy). Federal rules: `https://www.law.cornell.edu/rules/frcp/rule_10` and `.../rule_12`, read 2026-10-14.

| Rule | Requirement (verified text unless noted) | Where it is in the template |
|---|---|---|
| S.D. Ohio Civ. R. 5.1(a) | 8½ × 11 paper; double-spaced except block quotations; each page numbered consecutively; side margins and top margin not less than one inch; electronic filings one-inch margins on all sides. The rule sets **no typeface and no point size**. | `page-w`, `page-h`, `margin = 1in`, `body-leading` (double spacing), page number in the footer. |
| S.D. Ohio Civ. R. 5.2(a) | Proof of service on the pleading or on the document served (not used by the complaint; the complaint is served with the summons). | Not produced for a complaint. The certificate branch exists for filings that need one (see the motion-brief README). |
| S.D. Ohio Civ. R. 7.2(a)(3) | Memoranda over 20 pages need a combined table of contents and summary. | Not applicable to a complaint. |
| S.D. Ohio Civ. R. 10.1 | A pleading that challenges the constitutionality of a statute must say "Claim of Unconstitutionality" immediately after the title, and the civil cover sheet must be checked. | Not rendered. Add the words to `brief_title` when it applies. |
| Fed. R. Civ. P. 10(a) | A caption with the court's name, a title, a file number and a Rule 7(a) designation; the title names all parties. | `court-title` (court and division), `caption` (parties, case number, title). Verified 2026-10-14. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts. | `body-chunks` numbers each body paragraph (`numbered: true`); headings are not numbered; `unnumbered` lists the sections (prayer for relief, jury demand) whose paragraphs are not numbered. Verified 2026-10-14. |
| Fed. R. Civ. P. 10(c) | Written instruments attached as exhibits are part of the pleading. | Exhibits are not part of the render. |
| Fed. R. Civ. P. 8(a) | Short and plain statement of jurisdiction, claim and relief demanded. | Author content. **Not re-fetched in this pass** (from memory). |
| Fed. R. Civ. P. 38(b) | Jury demand endorsed on the pleading or served within 14 days. | `legend` prints "JURY DEMAND ENDORSED HEREIN" under the title. **Not re-fetched** (from memory). |
| Fed. R. Civ. P. 5(d)(1)(B) | Certificate of service for papers after the complaint. | Not applicable to the complaint. **Not re-fetched** (from memory). |

Not produced by this template (separate filings, not part of the complaint): the civil cover sheet (JS 44), the summons, and any Rule 7.1 disclosure statement.

## Layout

- Letter paper, one-inch margins on all sides, EB Garamond 12 pt, double-spaced (baseline pitch 24 pt).
- Page number centred at the foot of every page. No pleading line numbers (S.D. Ohio does not require pleading paper; the CAND template does, and is not this one).
- Court title: three centred bold lines (United States District Court; Southern District of Ohio; the division from the sample).
- Caption: the parties in a left column with a right rule and a bottom rule; the case number, optional judge line, title and optional legend on the right.
- Body: numbered paragraphs with a 0.5 inch first-line indent; centred bold headings; count headings as level 1 (title) and level 2 (sub-title) lines.
- Prayer for relief: lettered items (A., B., …) indented and unnumbered.
- Closing: the last paragraph and the signature block are set in one unbreakable block, so the signature never stands alone on a page.
- Typeface and size: EB Garamond is the only serif vendored in `fonts/`. The filed exemplar uses Garamond, so the face matches the filing; the size is 12 pt, a working standard (see Known gaps).

## Overlay

`samples/OVERLAY-doe-complaint.pdf`: red is our render, blue is the filed exemplar, black where both agree. Pages are paired by word overlap (`OVERLAY-doe-complaint.txt`): our pages 1 to 8 pair with filed pages 1, 3, 9, 9, 14, 16, 19, 20. Page 1 pairs at 76% word overlap (the caption and parties match the filed caption). The later pages match less because the sample is a partial transcription, so most filed words are absent by design. The overlay is a diagnostic, not a score.

## Review findings (rendered pages, 60 dpi)

Findings from the first renders, all fixed in the template:
- Court title lines overlapped (lines built as separate blocks with no leading). Fixed: one single-spaced stack.
- Body single-spaced: one-line paragraph blocks had no spacing after them, so the 24 pt pitch collapsed to 7.8 pt. Fixed: every body block and heading carries `below: body-leading`.
- Section headings rendered at the default heading size (larger than body). Fixed: `size: type-size` on the heading show rules.
- The signature block stood alone on the last page. Fixed: the last paragraph and the signature are one unbreakable block.

Pages reviewed in the final layout: 1 (caption, parties), 2 (numbered parties and jurisdiction), 3 (the bracketed factual note, Count I), 4 (Count I to II), 5 (Count II to IV), 6 (Count IV to V), 7 (Count VII, prayer), 8 (jury demand and signature). No cover spill, no broken heading, no widow headings.

## Known gaps

- **Tier 2 is not met: one filer.** A second S.D. Ohio complaint from a different filer was not found. RECAP entries for *Xiao v. General Electric*, 1:26-cv-01033, and other October 2026 complaints have no available document. EVAL-LOOP asks for 2 or 3 filers.
- **The sample is a partial transcription.** It keeps the caption, parties, jurisdiction, Counts I–V and VII (count paragraphs that are procedural or legal theory), the prayer, the jury demand and the signature. Filed ¶¶ 31–64 (the factual narrative of a sexual-assault survivor's case) are replaced by a bracketed note, a deliberate choice recorded in `exemplars/SOURCE.md`. Counts VI and VIII and the state-court exhibits (filed pp. 21–53) are not transcribed. The render is 8 pages against a 20-page pleading (the brief's 8–14 target is for an exemplar of that length; this one is long, but the sample is short by design).
- **Typeface and size are not set by the local rules.** S.D. Ohio Civ. R. 5.1 is silent on the face and the point size; the template uses EB Garamond 12 pt as a working standard, which matches the Garamond filing. Judges' standing orders may set something different. This needs a decision from David if a different face is wanted, since only EB Garamond is vendored.
- **Division assignment is not checked.** `division` is written by the author; Civ. R. 82.1 (venue by county) is not implemented.
- **Claim of unconstitutionality (Civ. R. 10.1)** is not rendered; the author adds it to the title when it applies.
- **Paragraph numbers in the transcription are the template's, not the filing's.** Filed paragraph numbers are noted in brackets only where a note replaces text.
- **The exemplar PDF is 12 MB.** It is committed because the brief asks for it; it may be large for the repository.
- **CourtListener** blocks HTML docket pages from this box (CloudFront 403) and rate-limits the anonymous search API (5 per minute); the RECAP storage paths came from the search API's `filepath_local` field.

## Engines

**docx** (`docx/`): `build-reference.sh` builds `docx/reference.docx` from pandoc's default (EB Garamond 12 pt, exact 24 pt double spacing, one-inch margins, centred PAGE footer, heading and paragraph styles). `ohsd.lua` sets the court title, the caption table, the numbered allegations, the prayer, the signature block and the certificate (none here). Render: `samples/OUTPUT-doe-complaint.docx` and `.docx.pdf` (LibreOffice 26.8.1, EB Garamond embedded), 8 pages. Reviewed: all 8 pages of the `.docx.pdf` and all 8 pages of the typst render, at 60 dpi, in the final state.

- Matches typst: letter paper, margins, EB Garamond 12 pt, 24 pt body pitch, the page count (8), the court title and caption (page 1 caption lines within 0.1 pt of the typst baselines), the PARTIES heading and first allegation (within about 1 pt), numbered allegations with a 0.5 in first-line indent and text at 1 in, count headings, the prayer, the signature block, the centred page number.
- Differs (tier 2, not chased): line breaks differ on most pages (LibreOffice shaping: for example allegation 2 breaks after "sexual-"). Page breaks differ: the docx ends page 2 after allegation 14, and the prayer for relief moves to page 8 whole (kept with its items), where typst keeps it on page 7. Pages 3 and 5 end short because of widow control. The caption spacing constants differ between the complaint and motion-brief `ohsd.lua` (the left column is taller here, the right column in the motion); both are measured against the typst output.
- Word: not available here. The file converts in LibreOffice with no error; Word may paginate slightly differently (docs/DOCX.md).
- BLOCKED: none. No table of contents, table of authorities, line numbering or bookmarks are required for this document.
- Gates: `sh tools/check.sh courts/sixth-circuit/ohio/federal/southern-district --engine docx` exits 2 before any gate runs: `checks.yaml` (and `rules.md`) do not exist yet for this court, so Gates 0 to 3 are not run for docx. Not changed here.
