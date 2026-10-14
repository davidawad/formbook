# N.D. W. Va. Bankruptcy Court (wvnb): motion with memorandum

Doc type: **motion with memorandum of law** in an adversary proceeding (FRBP 9013; LBR 9013-1(b)). Court: United States Bankruptcy Court for the Northern District of West Virginia. Folder: `courts/fourth-circuit/west-virginia/federal/bankruptcy-northern-district/motion-brief/`.

**BLOCKED: no exemplar.** No filed motion with memorandum from this court was found after the searches listed in `exemplars/SOURCE.md`. The template is built from the rules below, and the sample is fictional. The overlay cannot run without an exemplar PDF.

Status: exemplar=no, render=ok (typst, no warnings), overlay=fail (`tools/overlay.sh` exits 1: "no exemplar pdf"), pages reviewed 4 of 4 (rendered at 60 dpi and viewed). Nothing here sets `status` in `court.json`.

## Governing rules

Dates: rules text fetched and read 2026-10-14. "Local rules" means the N.D. W. Va. Local Bankruptcy Rules text, which is the November 21, 2003 version (the only copy the court publishes that could be retrieved). It may have been amended since, and no current text was found.

| ID | Rule | Requirement | Source (URL) | Where it lives in the template |
|---|---|---|---|---|
| WVNB-MOT-001 | FRBP 9013 | A request for an order is made by written motion. The motion states its grounds with particularity and sets forth the relief requested. | https://www.law.cornell.edu/rules/frbp/rule_9013 (fetched 2026-10-14; eff. Dec. 1, 2024) | Title; "Relief Requested" section (sample). The template does not check grounds. |
| WVNB-MOT-002 | LBR 9013-1(b) | Motions in adversary proceedings are governed principally by FRCP 5 and 7 and by FRBP 7005 and 7007. | local rules p. 59 (2003 text) | Whole template. FRBP 7005 and 7007 text not fetched. |
| WVNB-MOT-003 | LBR 9013-1(c)(2)(B) | Negative notice: "...an order may be entered granting the relief sought unless a specific written objection is filed within ____ days of the date of the mailing of this notice." | local rules pp. 59–60 (2003 text; Appendix G-2) | Boxed notice on page 1; days and date come from the sample. The 21-day figure in the sample is illustrative, not checked against the rules for this motion type. |
| WVNB-MOT-004 | LBR 9013-1(c)(2)(C) | Some motion types must carry a movant-prepared notice with a fixed negative-notice period (e.g. motion to avoid lien, 20 days, LBR 4003-2). | local rules pp. 59–60 (2003 text) | **Not generated.** The template prints whatever notice the sample gives. Known gap for those types. |
| WVNB-MOT-005 | LBR 9013-1(c)(1) | A proposed order accompanies a motion when appropriate, without the firm name. | local rules p. 59 (2003 text) | **Not generated.** Known gap. |
| WVNB-MOT-006 | LBR 9013-1(c)(3); LBR 5005-4.10 | A certificate of service is used when required; the notice rules do not replace service on interested parties; if the whole creditor body is served, the certificate may say so. | local rules pp. 60 (2003 text) | `certificate-of-service()` on its own page, from frontmatter `service`. The "mailing matrix" wording is not generated; the sample writes its own list. |
| WVNB-MOT-007 | FRCP 10(a) and FRBP 9004(b), FRBP 7010 | Caption, as for the complaint. | see `adversary-complaint/README.md` | `court-caption()`. |
| WVNB-FMT-001 | LBR 9004-1 (search-result excerpt only, not verified) | Font not less than 10 pt; spacing not more than double and not less than single; (excerpt also gives a 25-page limit for motions, briefs and memoranda). | https://www.courtrules.net/courts/federal/bankruptcy-northern-district-west-virginia/local-rules/7166 (HTTP 403; excerpt from a search result) | `type-size = 12pt`; `body-leading = 0.85em`; `page-limit = 25` documented but **not enforced** (no page counter). **Unverified; check the court's current text.** |
| WVNB-FMT-002 | Paper, margins, page numbers | Not stated in the LBR text read. | none | 8½ × 11 in, 1 in margins, page-number footer: convention, not a rule. |

## Table of contents and table of authorities (not generated)

The N.D. W. Va. text read does not require them for a bankruptcy motion. The template does not generate either. The `cand` template does, under its own rules; that is not carried over.

## Fonts and layout

- EB Garamond from `fonts/eb-garamond/` (vendored; the only font used).
- 12 pt body, 10 pt footnotes and footer. First-line indent 0.5 in; headings: centered capitals (sections) and bold centered (subsections). Headings are typed by the author; the template does not number them.
- Caption: same two-column table as the complaint. Motion docket number shown when given.
- Notice box: bordered block on page 1, before the body.
- Signature block; then a page break; then a certificate of service.

## What the sample shows

`samples/INPUT-example-motion-brief.md` is fictional: a motion by a transferee to dismiss Counts I and II of the sample complaint under FRCP 12(b)(6), made applicable by FRBP 7012(b). It has a relief section, background, standard of review, four argument headings, a conclusion, a signature, and a certificate of service listing three parties.

Render: `sh tools/render.sh <this-dir> samples/INPUT-example-motion-brief.md` produced `samples/OUTPUT-example-motion-brief.pdf`, 4 pages, embedded fonts EBGaramond-Regular, -Bold and -Italic only, no typst warnings.

The file names differ from the brief's naming on purpose. `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` reads that name and writes `OVERLAY-<id>.pdf` and `.txt`. The sample is `samples/<id>.md` as specified.

## Page review (Gate 2 record, 60 dpi, every page viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Counsel block, caption, title, notice box, first paragraph | OK. The notice box has a single border and sits between the caption and the body. |
| 2 | Relief requested, background, standard of review, argument headings | OK. Subsection headings are bold centered and sticky. |
| 3 | Argument (end), conclusion, signature | OK. |
| 4 | Certificate of service | OK. Parties listed one per block; signature block right. |

## Known gaps

- **Proposed order** (LBR 9013-1(c)(1)) and **movant-prepared notices** for the fixed-period motion types (LBR 9013-1(c)(2)(C)) are not generated.
- **Page limit** (25 pages, from the unverified 9004-1 excerpt) is documented but not counted.
- **Local rule text** is from 2003, and the 9004-1 excerpt is unverified.
- **Authorities** in the sample: *Iqbal* and *Twombly* are real cases, with reporter and pin cites from memory, not checked. Statute and rule cites in the sample (11 U.S.C. §§ 544, 548, 550; FRCP 15 and FRBP 7015) were not fetched.
- The 21-day negative-notice period in the sample is illustrative. Its correct period depends on the motion type, which the template does not decide.
- No exemplar, so no tier-2 comparison with a filed motion was possible.
