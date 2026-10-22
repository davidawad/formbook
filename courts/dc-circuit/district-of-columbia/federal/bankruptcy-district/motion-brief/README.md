# dcb: motion with memorandum

Doc type: **motion with memorandum** (a written motion under Fed. R. Bankr. P. 9013, with the supporting memorandum of facts and law in the same filing, Local Bankruptcy Rule 9013-1(b)(2)) in the United States Bankruptcy Court for the District of Columbia (`dcb`). Filed here as a motion to dismiss an adversary complaint.
Folder: `courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole 7-page motion and memorandum transcribed, plus the notice of motion and fill-in lines the rule requires and the exemplar lacks (gap 1) |
| typeface | face required: none (LBR and FRBP checked, see gap 2). Font: Times New Roman (the house standard, fb-9fyu; the exemplar's face) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 8 pages, typst 0.15.0, vendored Times New Roman only, no warnings; re-rendered 2026-10-22 (fb-595.68.6) |
| overlay | ok: `usage/OVERLAY-swain-landing.pdf` and `OVERLAY-swain-landing.txt` (re-run 2026-10-15 against `usage/FILED-EXAMPLE-motion-brief.pdf`) |
| pages reviewed | 8 of 8 on typst and docx (every page viewed side by side, 2026-10-22) |
| check gates | not run: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this is a doc-type folder, and `tools/` is out of scope for this box |

File names: as in `adversary-complaint/README.md`, the tools' default names are used (`OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), and the sample is `INPUT-<id>.md`.

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/dc-circuit/district-of-columbia/federal/bankruptcy-district/motion-brief swain-landing
```

## Governing rules

Verified 2026-10-14. Local rules: the court's Local Bankruptcy Rules as attached to General Order 2025-01 (signed March 3, 2025; revisions effective April 1, 2025), https://www.dcb.uscourts.gov/sites/dcb/files/2025-03-03%20GO%202025-01%20signed%20w%20LBR.pdf (text read from the PDF's text layer). Federal rules: Cornell LII.

| Rule | Requirement | Where the template does it |
|---|---|---|
| Fed. R. Bankr. P. 9013(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9013) | A request for an order is made by written motion; a motion must state its grounds with particularity and set forth the relief requested. | the motion's lead-in and body (author text); `title` |
| Fed. R. Bankr. P. 9004(a)-(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | Legible; caption with the court's name, the case title, the case and adversary-proceeding numbers, and a designation of the document. | `court-title()`, `caption()`, `title` |
| LBR 9013-1(b)(1)-(2) | Grounds and relief stated with particularity; a memorandum of facts and law may be filed with or combined with the motion. | the body; the memorandum is combined with the motion (no separate memorandum is required) |
| LBR 9013-1(c) | A motion in an adversary proceeding includes or is accompanied by a conspicuous notice of the motion, objection deadline and hearing, conforming substantially to Official Form B 420A (exception: a contemporaneous motion under LBR 9013-2). | `notice-box()`: a bordered notice with fill-in lines for the response deadline and the hearing (blank in the sample) |
| LBR 9013-1(d)(1)-(3) | No hearing set: the moving party serves a notice of opportunity to object and request a hearing, and the opponent may respond within 14 days. Hearing set on 21 days' notice: response due 7 days before the hearing. | `notice-box()` text; the day counts are not printed (the template does not compute dates) |
| LBR 9013-1(e)(2)-(3) | A response may include a memorandum; if no response is timely filed, the Court may treat the motion as conceded and grant it without a hearing. | `notice-box()` (the "no response" sentence) |
| LBR 9013-1(f) | Certificate of service for each motion: the date, the manner of service, and the names and addresses of each recipient not served through CM/ECF. | `certificate-of-service()`: date, manner, recipients, signer |
| LBR 5005-1(c) | First page: the attorney's name, bar number, office address, email, telephone and whom the attorney represents (footer or header permitted). | `counsel-block()` (upper left; asserts email and "represents") |

Verified in this pass: FRBP 9013 and 9004 (LII, quoted); LBR 9013-1(b)-(f) and 5005-1(c) (the court's attached LBR PDF). Not verified: Official Form B 420A (the notice form's own wording and fields, which LBR 9013-1(c) requires the notice to follow substantially), any page limit for a memorandum (none found in the rule text read; the judges' standing orders were not read), and any proposed-order requirement (not produced).

Not produced: a proposed order, the Exhibit A referred to in the motion (the Final Order), and any declaration.

## Layout

- Letter paper, one-inch margins on all sides; page number centred at the foot.
- Counsel block single-spaced in the upper left; court name in bold capitals; caption as a three-column grid with a column of ")" marks; the adversary number on the plaintiff line; the title in bold capitals centred.
- Notice of motion in a bordered box under the title (LBR 9013-1(c)), single-spaced.
- Body double-spaced: 27.6 pt between body lines at 12 pt (measured on the exemplar, pages 2 to 4). Every line is a box of its pitch (27.6 pt body, 13.8 pt single lines: the cross-engine layout model, `lib/typst/xengine.typ`). Block quotations are indented 0.5 inch on each side and single-spaced, a single line above and below; headings single-spaced, a single line above and below.
- Headings: level 1 centred bold; level 2 bold; level 3 bold italic and indented. Headings are single-spaced and kept with the text after them. The filer's own numbering (I., A., 1.) is typed in the sample and printed as written.
- Signature block after the body: "Date", "Respectfully submitted", the firm, "/s/", the signer and contact lines. The certificate of service follows on the same page where it fits.
- The template contains no case-specific text. Every name, number, date and paragraph comes from the sample.

## Known gaps and open choices

1. **Notice of motion (LBR 9013-1(c)).** The filed exemplar has no notice of motion, no objection deadline and no hearing, although the rule requires one for a motion in an adversary proceeding unless it is filed with a contemporaneous motion under LBR 9013-2. The template generates the notice; the sample leaves the response deadline and the hearing blank (the fill-in lines print as underscores), because the exemplar gives no date and the sample must not invent one. The notice's wording is not Official Form B 420A: it has not been checked against that form. A filer should use the form itself.
2. **Typeface and size.** As in the complaint README (gap 2), checked 2026-10-15 against the court's LBR PDF: no rule names a typeface or point size, so the template sets Times New Roman 12 pt, the house standard (fb-9fyu) and the exemplar's face, on typst and docx alike.
3. **One exemplar only.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The CourtListener API search (`type=r&court=dcb`, query "motion to dismiss" adversary) turned up Engelhorn (25-10044), Developer RE1 (25-10037), JPK NewCo (25-10015, entry 20, not checked) and Anglin Consulting (25-10032, entry 43, no PDF). None of those was checked for text and none was saved. The web search for a D.C. Bankruptcy motion found the court's local rules and general orders, not a filing. A second filer is needed for tier 2.
4. **Caption number.** The exemplar's caption says "Adversary No. 18-00173 MMH" but the ECF header says "Case 25-10013-ELG". The sample keeps the caption number as printed, and records the ECF number in `usage/SOURCE.md`.
5. **Certificate of service wording.** The exemplar's certificate says "Motion and Memorandum in Support of Debtor's Motion to Dismiss", which does not match the filer's own motion. The template's certificate says "the foregoing", so the sample's certificate differs from the exemplar's words on purpose.
6. **Typed numbering and typos.** The exemplar types its own heading numbers (I., A., 1.), so the template does not number headings. The transcription keeps the filer's wording and typos ("recission", "Similarly state law rescission", "§548(a)(B)(i)", "failure to state a Claim"). Italics for case names are not in the text layer, so the sample is roman (the template italicises `*...*` markup where the sample uses it).
7. **Overlay.** The sample is the whole motion, so the overlay pairs pages one-to-one (ours p.1 to p.7 with filed p.1 to p.7). The overlay is a diagnostic, not a score.

## Review of the rendered pages (fb-595.68.6, 8 pages per engine)

Rendered with `pdftoppm -r 50`; every page of the typst render and of the docx render viewed side by side after the
last template change. Gate 2 rows for these pages are recorded here: this doc type has no `reviews/` folder.

| Page | Content | Result |
|---|---|---|
| 1 | counsel block, court name, ")" caption (one row per line), title, the ruled notice box (LBR 9013-1(c)), the lead-in | Pass on both engines. ACCEPTED: the page ends about four lines short, because "I. INTRODUCTION" stays with its first paragraph on page 2 (a heading never ends a page). |
| 2 | I. INTRODUCTION and its paragraphs | Pass on both. |
| 3 | II. LEGAL STANDARD; heading A (two single-spaced lines); three block quotations | Pass on both. |
| 4 | heading B and its paragraphs | Pass on both. |
| 5 | III. ARGUMENT; heading A (four lines); level-3 headings 1 to 3, bold italic, a step in | Pass on both. |
| 6 | heading 4; heading B (three lines) and its text | Pass on both. |
| 7 | IV. CONCLUSION, the signature block ("Date", "Respectfully submitted,", the firm, the signer's lines) | Pass on both. |
| 8 | CERTIFICATE OF SERVICE (LBR 9013-1(f)): date and manner, the recipient's block, the signature column; on one page | Pass on both. |

## Engines

Typst is the primary engine (`typst/`); the docx engine is `docx/`: `reference.xml` (the cross-engine style recipe,
`base="xengine"`, in the typst face) and `dcb-motion-brief.lua`; `fb render` builds the reference document and runs
pandoc (no shell script, fb-595.68). There is no latex engine for this doc type. Both engines sit on the
cross-engine layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`): every line in a box of its pitch,
first-fit ragged-right line breaking, no kerning, ligatures or hyphenation; the caption is a table of one row per
line and the notice a one-cell ruled table with a 10 pt inset in Word, as the typst grid and box; the docx filter adds
typst's break rules that LibreOffice lacks (a word joiner in ")(", a zero-width space after a slash before a letter).

- **Gate 4:** `params.cross_engine: gate` (`eval.yaml`): XENG-001..003 pass, the docx breaks every line and page as the typst render (8 pages).
- **docx BLOCKED items:** none.
- **Not verified:** the `.docx` has not been opened in Microsoft Word (none here); it converts without error in LibreOffice (DEF-DOCX-OPEN).
