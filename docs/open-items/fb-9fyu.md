# fb-9fyu: exemplars no vendored or pinned face can match

The corrected exemplar-font audit (`fb fonts audit`, tools/fb/src/fontaudit.rs, written to `data/exemplar-fonts.json`)
classifies every FILED-EXAMPLE PDF on the branch (2,250; four entries of the earlier audit named files no longer in
the tree and were dropped): 1,525 metric-exact, 413 approximate, **312 impossible** (was 849 of 2,254 at 5f89efb5a).
This file lists the 312 by circuit for the per-circuit replacement-search beads (fb-9fyu step 3; no search was done
here). Each row is one exemplar; 125 of the 312 are court-root copies (`<court>/usage/`) of a doc folder's exemplar, so
a replacement found for one usually serves both.

## Reasons

| reason | count | meaning |
|---|---|---|
| `scanned-ocr` | 160 | a scan: most pages are one page-size image, or the visible text is no more than a filing stamp, and an invisible OCR layer carries the words (pdftotext reads it, pdftohtml drops it). The OCR font is the OCR engine's choice, not the filer's. |
| `scanned-no-text` | 8 | a scan with no text layer beyond the stamp. |
| `commercial-face` | 133 | the body is set in a face with no vendored or pinned metric-compatible substitute: Garamond 57, Equity 24, Century (Monotype) 23, Calisto MT 8, Constantia 6, Century Expanded 3, Baskerville / Baskerville Old Face 4, Goudy Old Style 2, Plantagenet Cherokee 2, Segoe UI 1, Proxima Nova 1, Leelawadee UI 1, Charter 1. |
| `unnamed-font` | 11 | the body font's name was stripped (`CIDFont+F1`, `WRD_EMBED_SUB`, `Z_C00000.tmp`) and its FontDescriptor (Ascent, Descent, CapHeight) matches none of the measured signatures (Times New Roman, Arial, Courier New, Georgia, Garamond, Century Schoolbook). |

## What changed in the classifier

- **Name variants.** One family key per face: the subset tag, Acrobat's `*` mark, `,Bold`/`-BoldMT` style tails,
  `PS`/`MT`/`PSMT`, `Identity-H` and trailing digits are removed (`TimesNewRomanPS-BoldMT`, `TimesNewRoman,Bold`,
  `*TimesNewRoman-4801-Identity-H` and `TimesNewRomanPSMT2` are all Times New Roman). Bold, italic and regular of a
  face now count as one body face.
- **Face table.** The earlier generator knew only Times New Roman, Times and Liberation Sans, so Arial, Helvetica,
  Courier New, Courier, Georgia, Cambria, Calibri, Century Schoolbook, Palatino / Book Antiqua and Bookman were all
  "impossible". They now map to their docs/FONTS.md substitutes (metric-exact: Times New Roman, TeX Gyre Termes,
  Liberation Sans, Liberation Mono, TeX Gyre Cursor, Gelasio, Caladea, Carlito, TeX Gyre Schola for Adobe New Century
  Schoolbook; approximate: TeX Gyre Schola for Monotype Century Schoolbook, Pagella, Bonum, Gelasio for Georgia Pro).
- **Unnamed fonts.** Microsoft Print to PDF strips names (`CIDFont+F1`); the FontDescriptor metrics, also read from
  compressed object streams, identify the face (97 exemplars).
- **Scans.** A page-size image on at least 80 % of pages, or visible text below 300 characters a page, with an
  invisible OCR layer is `scanned-ocr`. The earlier generator took the OCR or stamp font for the body (a Helvetica
  filing stamp on a scan read as a metric-exact Arial body) or called an OCR layer "no text layer".
- **Copy-protected PDFs.** pdftohtml refuses a file whose permissions forbid copying (`copy:no`); 23 such
  born-digital exemplars were "no text layer". Their body face is now the embedded family with the most styles,
  noted in `why`.


## `just lint` (54 font-policy findings at 5f89efb5a, 0 now)

The corrected audit first raised the findings to 379; the court's rules decide the face, so they were resolved in the
audit and in the lint's use of it, and in templates only where the rules are silent and the exemplar is metric-exact:

- **Lint scope** (tools/fb/src/lint/fonts.rs). An exemplar settles a face only when it is metric-exact or carries a
  ruling (`template_face`); approximate and impossible exemplars leave the face to the rules and docs/FONTS.md.
  Typst Times New Roman without the Liberation Serif fallback is Times New Roman. LaTeX `\usepackage{tgbonum}`,
  `tgpagella`, `tgtermes`, `tgcursor`, `tgheros` (Arial's advances) and `newtxtext` (for Liberation Serif) count as
  declarations. Typst imports are now followed (the parser never read an import, so `/lib/typst/<court>-common.typ`
  faces, e.g. Travis County's, were missed), and a file that declares no face is not checked.
- **TNR gate** (tools/fb/src/fonts.rs `wants_tnr`): a `template_face` decides, so a rule-named face over a Times New
  Roman exemplar (Florida's Arial) no longer demands an embedded TimesNewRomanPSMT. 506 doc folders newly fall under
  the TNR-EMBEDDED gate; every committed OUTPUT in them already embeds TimesNewRomanPSMT (latex: newtx).
- **Rulings** (`template_face` and `note` on 77 exemplar entries, one per doc folder): Times New Roman where the rules
  name no face or allow it (docs/FONTS.md rule 6) or require it (Missouri 84.03, NMCCA 17(c), Idaho I.A.R. 36,
  Connecticut's serif rule against Arial/Calibri exemplars); the rule's own face where it names one (Florida 9.045(b)
  Arial/Bookman, Alabama 32(a)(7) and Georgia R. 16 Century Schoolbook, Tennessee R. 46 Century, California 8.74(b)(1)
  Century Schoolbook preferred, D.C. Circuit Handbook Century); Liberation Serif for Wisconsin Court of Appeals
  answering and reply briefs (no face named; docs/FONTS.md rule 3 default).
- **Templates changed** (rules silent on a mandated face, exemplar metric-exact Times New Roman, template in another
  face), re-rendered and checked on every engine they ship (all green): California Courts of Appeal, Fifth District
  amicus, answering, motion and writ petition; Fourth District amicus; Sixth District answering, motion and writ
  petition (EB Garamond -> Times New Roman; CRC 8.204(b)(2) allows any conventional font); Mississippi Supreme Court
  amicus and BAP 1st Cir. reply (Liberation Serif -> Times New Roman, its metric twin; docs/FONTS.md rule 3).

## Follow-ups (not done here)

- Still EB Garamond, with an approximate (Century Schoolbook) exemplar, so not changed: California Fifth District
  opening and reply briefs, Fourth District motion and writ petition, Sixth District amicus brief. docs/FONTS.md
  reserves EB Garamond for a rule that names Garamond; CRC 8.74(b)(1) prefers Century Schoolbook.
- BAP 1st Cir. answering brief's `docx/bap1.lua` still names Liberation Serif in its certificate (`FONT_NAME`).
- Wisconsin Court of Appeals templates are Liberation Serif (rule 3 default), not the rule-6 Times New Roman.


## eighth-circuit (28)

| folder | exemplar | face | reason |
|---|---|---|---|
| arkansas/federal/eastern-district/complaint | FILED-EXAMPLE-complaint.pdf | — | scanned-ocr |
| arkansas/state/court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | Garamond | commercial-face |
| arkansas/state/court-of-appeals | FILED-EXAMPLE-answering-brief.pdf | Garamond | commercial-face |
| arkansas/state/supreme-court/petition-for-discretionary-review | FILED-EXAMPLE-petition-for-discretionary-review.pdf | Garamond | commercial-face |
| arkansas/state/supreme-court/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | Calisto MT | commercial-face |
| arkansas/state/supreme-court | FILED-EXAMPLE-petition-for-discretionary-review.pdf | Garamond | commercial-face |
| arkansas/state/supreme-court | FILED-EXAMPLE-petition-for-writ.pdf | Calisto MT | commercial-face |
| court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief-2.pdf | Garamond | commercial-face |
| court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | Calisto MT | commercial-face |
| court-of-appeals/opening-brief | FILED-EXAMPLE-opening-brief.pdf | Garamond | commercial-face |
| court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief-2.pdf | Garamond | commercial-face |
| iowa/federal/bankruptcy-northern-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-2.pdf | Calisto MT | commercial-face |
| iowa/federal/bankruptcy-northern-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint.pdf | Calisto MT | commercial-face |
| iowa/federal/northern-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Segoe UI | commercial-face |
| minnesota/state/court-of-appeals/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | Garamond | commercial-face |
| minnesota/state/court-of-appeals | FILED-EXAMPLE-amicus-brief.pdf | Garamond | commercial-face |
| missouri/federal/bankruptcy-western-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-2.pdf | Garamond | commercial-face |
| missouri/state/supreme-court/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Plantagenet Cherokee | commercial-face |
| missouri/state/supreme-court | FILED-EXAMPLE-reply-brief.pdf | Plantagenet Cherokee | commercial-face |
| nebraska/state/court-of-appeals/opening-brief | FILED-EXAMPLE-opening-brief.pdf | Century (Monotype) | commercial-face |
| nebraska/state/court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Century (Monotype) | commercial-face |
| nebraska/state/court-of-appeals | FILED-EXAMPLE-opening-brief.pdf | Century (Monotype) | commercial-face |
| nebraska/state/court-of-appeals | FILED-EXAMPLE-reply-brief.pdf | Century (Monotype) | commercial-face |
| north-dakota/state/court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Goudy Old Style | commercial-face |
| north-dakota/state/court-of-appeals | FILED-EXAMPLE-reply-brief.pdf | Goudy Old Style | commercial-face |
| south-dakota/federal/district/complaint | FILED-EXAMPLE-complaint.pdf | — | scanned-ocr |
| south-dakota/state/supreme-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| south-dakota/state/supreme-court | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |

## eleventh-circuit (11)

| folder | exemplar | face | reason |
|---|---|---|---|
| alabama/federal/bankruptcy-middle-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-3.pdf | — | scanned-ocr |
| alabama/federal/bankruptcy-middle-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint.pdf | — | scanned-ocr |
| florida/federal/bankruptcy-middle-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-2.pdf | Calisto MT | commercial-face |
| florida/federal/bankruptcy-middle-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-3.pdf | — | scanned-no-text |
| florida/state/fifth-district-court-of-appeal/opening-brief | FILED-EXAMPLE-opening-brief.pdf | unnamed `cidfont+f4` | unnamed-font |
| florida/state/fifth-district-court-of-appeal | FILED-EXAMPLE-opening-brief.pdf | unnamed `cidfont+f4` | unnamed-font |
| florida/state/second-district-court-of-appeal/answering-brief | FILED-EXAMPLE-answering-brief.pdf | unnamed `cidfont+f1` | unnamed-font |
| florida/state/second-district-court-of-appeal | FILED-EXAMPLE-answering-brief.pdf | unnamed `cidfont+f1` | unnamed-font |
| florida/state/supreme-court/petition-for-review | FILED-EXAMPLE-petition-for-review.pdf | unnamed `cidfont+f4` | unnamed-font |
| florida/state/supreme-court | FILED-EXAMPLE-petition-for-review.pdf | unnamed `cidfont+f4` | unnamed-font |
| georgia/state/supreme-court | FILED-EXAMPLE-petition-for-writ.pdf | — | scanned-ocr |

## federal-circuit (3)

| folder | exemplar | face | reason |
|---|---|---|---|
| court-of-appeals/opening-brief | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| court-of-federal-claims/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-no-text |
| court-of-veteran-appeals/opening-brief | FILED-EXAMPLE-opening-brief.pdf | Garamond | commercial-face |

## fifth-circuit (34)

| folder | exemplar | face | reason |
|---|---|---|---|
| louisiana/federal/bankruptcy-eastern-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint.pdf | Garamond | commercial-face |
| louisiana/state/court-of-appeal/petition-for-discretionary-review | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| louisiana/state/court-of-appeal | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| mississippi/state/court-of-appeals/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| mississippi/state/court-of-appeals | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| mississippi/state/supreme-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| mississippi/state/supreme-court | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| texas/state/court-of-civil-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Equity | commercial-face |
| texas/state/court-of-civil-appeals | FILED-EXAMPLE-motion-brief.pdf | Equity | commercial-face |
| texas/state/court-of-criminal-appeals/petition-for-rehearing | FILED-EXAMPLE-petition-for-rehearing.pdf | Equity | commercial-face |
| texas/state/court-of-criminal-appeals/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| texas/state/court-of-criminal-appeals | FILED-EXAMPLE-brief-on-the-merits.pdf | Garamond | commercial-face |
| texas/state/court-of-criminal-appeals | FILED-EXAMPLE-petition-for-rehearing.pdf | Equity | commercial-face |
| texas/state/court-of-criminal-appeals | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| texas/state/district-court-travis/motion-brief | FILED-EXAMPLE-motion-brief-2.pdf | — | scanned-ocr |
| texas/state/district-court-travis/motion-brief | FILED-EXAMPLE-motion-brief-5.pdf | Equity | commercial-face |
| texas/state/district-court-travis/notice-of-appearance | FILED-EXAMPLE-notice-of-appearance-2.pdf | — | scanned-ocr |
| texas/state/district-court-travis/notice-of-appearance | FILED-EXAMPLE-notice-of-appearance.pdf | Equity | commercial-face |
| texas/state/district-court-travis/original-answer | FILED-EXAMPLE-original-answer.pdf | — | scanned-ocr |
| texas/state/district-court-travis/proposed-order | FILED-EXAMPLE-proposed-order-2.pdf | Equity | commercial-face |
| texas/state/district-court-travis/proposed-order | FILED-EXAMPLE-proposed-order-5.pdf | — | scanned-no-text |
| texas/state/district-court-travis/proposed-order | FILED-EXAMPLE-proposed-order.pdf | — | scanned-ocr |
| texas/state/district-court-travis/rule-11-agreement | FILED-EXAMPLE-rule-11-agreement.pdf | — | scanned-ocr |
| texas/state/judicial-panel-on-multidistrict-litigation/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | Equity | commercial-face |
| texas/state/judicial-panel-on-multidistrict-litigation/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| texas/state/judicial-panel-on-multidistrict-litigation | FILED-EXAMPLE-amicus-brief.pdf | Equity | commercial-face |
| texas/state/judicial-panel-on-multidistrict-litigation | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| texas/state/special-court-of-review/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| texas/state/special-court-of-review/reply-brief | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| texas/state/special-court-of-review | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| texas/state/special-court-of-review | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| texas/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | Equity | commercial-face |
| texas/state/supreme-court | FILED-EXAMPLE-petition-for-writ.pdf | Equity | commercial-face |
| texas/state/supreme-court | FILED-EXAMPLE-reply-brief.pdf | Equity | commercial-face |

## first-circuit (18)

| folder | exemplar | face | reason |
|---|---|---|---|
| bankruptcy-appellate-panel/answering-brief | FILED-EXAMPLE-answering-brief.pdf | Garamond | commercial-face |
| maine/state/supreme-judicial-court/petition-for-review | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| maine/state/supreme-judicial-court | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| massachusetts/state/supreme-judicial-court/petition-for-rehearing | FILED-EXAMPLE-petition-for-rehearing.pdf | Baskerville | commercial-face |
| massachusetts/state/supreme-judicial-court/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | Baskerville Old Face | commercial-face |
| massachusetts/state/supreme-judicial-court | FILED-EXAMPLE-petition-for-rehearing.pdf | Baskerville | commercial-face |
| massachusetts/state/supreme-judicial-court | FILED-EXAMPLE-petition-for-writ.pdf | Baskerville Old Face | commercial-face |
| new-hampshire/state/supreme-court/petition-for-rehearing | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| new-hampshire/state/supreme-court | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| puerto-rico/federal/bankruptcy-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-2.pdf | Leelawadee UI | commercial-face |
| puerto-rico/federal/bankruptcy-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| puerto-rico/state/court-of-appeals/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| puerto-rico/state/court-of-appeals | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| puerto-rico/state/supreme-court/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| puerto-rico/state/supreme-court/brief-on-the-merits | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| puerto-rico/state/supreme-court | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| puerto-rico/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| puerto-rico/state/supreme-court | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |

## fourth-circuit (33)

| folder | exemplar | face | reason |
|---|---|---|---|
| court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief-2.pdf | Garamond | commercial-face |
| north-carolina/state/court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | Constantia | commercial-face |
| north-carolina/state/court-of-appeals/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | Equity | commercial-face |
| north-carolina/state/court-of-appeals | FILED-EXAMPLE-answering-brief.pdf | Constantia | commercial-face |
| north-carolina/state/court-of-appeals | FILED-EXAMPLE-petition-for-writ.pdf | Equity | commercial-face |
| north-carolina/state/superior-court/opening-brief | FILED-EXAMPLE-opening-brief.pdf | Equity | commercial-face |
| north-carolina/state/superior-court/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | — | scanned-ocr |
| north-carolina/state/superior-court | FILED-EXAMPLE-opening-brief.pdf | Equity | commercial-face |
| north-carolina/state/superior-court | FILED-EXAMPLE-petition-for-writ.pdf | — | scanned-ocr |
| north-carolina/state/supreme-court/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | Century (Monotype) | commercial-face |
| north-carolina/state/supreme-court/petition-for-review | FILED-EXAMPLE-petition-for-review.pdf | Constantia | commercial-face |
| north-carolina/state/supreme-court/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | Equity | commercial-face |
| north-carolina/state/supreme-court | FILED-EXAMPLE-amicus-brief.pdf | Century (Monotype) | commercial-face |
| north-carolina/state/supreme-court | FILED-EXAMPLE-petition-for-review.pdf | Constantia | commercial-face |
| north-carolina/state/supreme-court | FILED-EXAMPLE-petition-for-writ.pdf | Equity | commercial-face |
| south-carolina/state/court-of-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| south-carolina/state/court-of-appeals | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| south-carolina/state/supreme-court/brief-on-the-merits | FILED-EXAMPLE-brief-on-the-merits.pdf | unnamed `cidfont+f1` | unnamed-font |
| south-carolina/state/supreme-court/petition-for-rehearing | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| south-carolina/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | unnamed `cidfont+f1` | unnamed-font |
| south-carolina/state/supreme-court | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| virginia/federal/eastern-district/complaint | FILED-EXAMPLE-complaint.pdf | — | scanned-ocr |
| virginia/state/court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | Century (Monotype) | commercial-face |
| virginia/state/court-of-appeals | FILED-EXAMPLE-answering-brief.pdf | Century (Monotype) | commercial-face |
| virginia/state/supreme-court/answering-brief | FILED-EXAMPLE-answering-brief.pdf | Century (Monotype) | commercial-face |
| virginia/state/supreme-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Century (Monotype) | commercial-face |
| virginia/state/supreme-court | FILED-EXAMPLE-answering-brief.pdf | Century (Monotype) | commercial-face |
| virginia/state/supreme-court | FILED-EXAMPLE-motion-brief.pdf | Century (Monotype) | commercial-face |
| west-virginia/federal/southern-district/complaint | FILED-EXAMPLE-complaint.pdf | — | scanned-no-text |
| west-virginia/state/intermediate-court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| west-virginia/state/intermediate-court-of-appeals | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| west-virginia/state/supreme-court/petition-for-rehearing | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| west-virginia/state/supreme-court | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |

## military (5)

| folder | exemplar | face | reason |
|---|---|---|---|
| army-court-of-criminal-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| army-court-of-criminal-appeals/opening-brief | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| court-of-military-commission-review/answering-brief | FILED-EXAMPLE-answering-brief-2.pdf | — | scanned-ocr |
| court-of-military-commission-review/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| court-of-military-commission-review/opening-brief | FILED-EXAMPLE-opening-brief-3.pdf | — | scanned-ocr |

## national (5)

| folder | exemplar | face | reason |
|---|---|---|---|
| foreign-intelligence-surveillance-court-of-review/amicus-brief | FILED-EXAMPLE-amicus-brief-2.pdf | — | scanned-ocr |
| foreign-intelligence-surveillance-court/motion-brief | FILED-EXAMPLE-motion-brief-2.pdf | — | scanned-ocr |
| foreign-intelligence-surveillance-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| tax-court/petition | FILED-EXAMPLE-petition.pdf | — | scanned-ocr |
| tax-court/pretrial-memorandum | FILED-EXAMPLE-pretrial-memorandum.pdf | — | scanned-ocr |

## ninth-circuit (51)

| folder | exemplar | face | reason |
|---|---|---|---|
| alaska/state/supreme-court/petition-for-review | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| alaska/state/supreme-court | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| arizona/state/supreme-court/petition-for-review | FILED-EXAMPLE-petition-for-review.pdf | Garamond | commercial-face |
| arizona/state/supreme-court | FILED-EXAMPLE-petition-for-review.pdf | Garamond | commercial-face |
| bankruptcy-appellate-panel/opening-brief | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| california/federal/bankruptcy-northern-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-2.pdf | — | scanned-no-text |
| california/federal/bankruptcy-southern-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-2.pdf | — | scanned-no-text |
| california/federal/central-district/complaint | FILED-EXAMPLE-complaint-2.pdf | Garamond | commercial-face |
| california/federal/southern-district/complaint | FILED-EXAMPLE-complaint-2.pdf | — | scanned-no-text |
| california/state/court-of-appeal-fourth-district/opening-brief | FILED-EXAMPLE-opening-brief.pdf | Garamond | commercial-face |
| california/state/court-of-appeal-fourth-district/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| california/state/court-of-appeal-fourth-district | FILED-EXAMPLE-opening-brief.pdf | Garamond | commercial-face |
| california/state/court-of-appeal-fourth-district | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| california/state/court-of-appeal-sixth-district/opening-brief | FILED-EXAMPLE-opening-brief.pdf | Garamond | commercial-face |
| california/state/court-of-appeal-sixth-district/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| california/state/court-of-appeal-sixth-district | FILED-EXAMPLE-opening-brief.pdf | Garamond | commercial-face |
| california/state/court-of-appeal-sixth-district | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| california/state/court-of-appeal-third-district | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| california/state/courts-of-appeal/opening-brief | FILED-EXAMPLE-opening-brief.pdf | Garamond | commercial-face |
| california/state/courts-of-appeal/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| california/state/courts-of-appeal | FILED-EXAMPLE-amicus-brief.pdf | Century (Monotype) | commercial-face |
| california/state/courts-of-appeal | FILED-EXAMPLE-opening-brief.pdf | Century (Monotype) | commercial-face |
| court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Garamond | commercial-face |
| court-of-appeals | FILED-EXAMPLE-opening-brief.pdf | Garamond | commercial-face |
| guam/federal/district/complaint | FILED-EXAMPLE-complaint.pdf | — | scanned-ocr |
| hawaii/state/intermediate-court-of-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| hawaii/state/intermediate-court-of-appeals | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| hawaii/state/supreme-court/petition-for-rehearing | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| hawaii/state/supreme-court | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| idaho/state/supreme-court/brief-on-the-merits | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| idaho/state/supreme-court/petition-for-discretionary-review | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| idaho/state/supreme-court/petition-for-review | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| idaho/state/supreme-court/reply-brief | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| idaho/state/supreme-court | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| idaho/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| idaho/state/supreme-court | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| idaho/state/supreme-court | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| idaho/state/supreme-court | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| montana/state/supreme-court/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | — | scanned-ocr |
| montana/state/supreme-court/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Equity | commercial-face |
| montana/state/supreme-court | FILED-EXAMPLE-petition-for-writ.pdf | — | scanned-ocr |
| montana/state/supreme-court | FILED-EXAMPLE-reply-brief.pdf | Equity | commercial-face |
| northern-mariana-islands/state/supreme-court/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| northern-mariana-islands/state/supreme-court | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| oregon/state/court-of-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| oregon/state/court-of-appeals | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| oregon/state/supreme-court/brief-on-the-merits | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| oregon/state/supreme-court/petition-for-review | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| oregon/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| oregon/state/supreme-court | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| washington/federal/bankruptcy-western-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | unnamed `wrdembedsub` | unnamed-font |

## second-circuit (7)

| folder | exemplar | face | reason |
|---|---|---|---|
| new-york/federal/bankruptcy-northern-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint.pdf | — | scanned-ocr |
| new-york/federal/southern-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| new-york/federal/western-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Calisto MT | commercial-face |
| new-york/state/court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief-2.pdf | Garamond | commercial-face |
| new-york/state/court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | Garamond | commercial-face |
| new-york/state/court-of-appeals/petition-for-discretionary-review | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| new-york/state/court-of-appeals | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |

## seventh-circuit (16)

| folder | exemplar | face | reason |
|---|---|---|---|
| illinois/state/appellate-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| illinois/state/appellate-court | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| illinois/state/supreme-court/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Century (Monotype) | commercial-face |
| illinois/state/supreme-court | FILED-EXAMPLE-reply-brief.pdf | Century (Monotype) | commercial-face |
| indiana/federal/southern-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| indiana/state/court-of-appeals/opening-brief | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| indiana/state/court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| indiana/state/court-of-appeals | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| indiana/state/court-of-appeals | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| indiana/state/supreme-court | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| indiana/state/supreme-court | FILED-EXAMPLE-petition-for-rehearing.pdf | Calisto MT | commercial-face |
| wisconsin/federal/bankruptcy-eastern-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| wisconsin/state/court-of-appeals/opening-brief | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| wisconsin/state/court-of-appeals | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| wisconsin/state/supreme-court/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | Century (Monotype) | commercial-face |
| wisconsin/state/supreme-court | FILED-EXAMPLE-amicus-brief.pdf | Century (Monotype) | commercial-face |

## sixth-circuit (25)

| folder | exemplar | face | reason |
|---|---|---|---|
| court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| kentucky/federal/bankruptcy-eastern-district/motion-brief | FILED-EXAMPLE-motion-brief-3.pdf | — | scanned-ocr |
| kentucky/state/court-of-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| kentucky/state/court-of-appeals/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | Garamond | commercial-face |
| kentucky/state/court-of-appeals | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| kentucky/state/court-of-appeals | FILED-EXAMPLE-petition-for-writ.pdf | Garamond | commercial-face |
| kentucky/state/supreme-court/petition-for-discretionary-review | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| kentucky/state/supreme-court/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | Garamond | commercial-face |
| kentucky/state/supreme-court | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| kentucky/state/supreme-court | FILED-EXAMPLE-petition-for-writ.pdf | Garamond | commercial-face |
| ohio/federal/bankruptcy-northern-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint.pdf | unnamed `cidfont+f1` | unnamed-font |
| ohio/federal/southern-district/complaint | FILED-EXAMPLE-complaint.pdf | Garamond | commercial-face |
| ohio/state/court-of-appeals/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| ohio/state/court-of-appeals | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| tennessee/state/court-of-criminal-appeals/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | Century (Monotype) | commercial-face |
| tennessee/state/court-of-criminal-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| tennessee/state/court-of-criminal-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Century (Monotype) | commercial-face |
| tennessee/state/court-of-criminal-appeals | FILED-EXAMPLE-amicus-brief.pdf | Century (Monotype) | commercial-face |
| tennessee/state/court-of-criminal-appeals | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| tennessee/state/court-of-criminal-appeals | FILED-EXAMPLE-motion-brief.pdf | Century (Monotype) | commercial-face |
| tennessee/state/supreme-court/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| tennessee/state/supreme-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| tennessee/state/supreme-court | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| tennessee/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | Century (Monotype) | commercial-face |
| tennessee/state/supreme-court | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |

## supreme-court-of-the-united-states (3)

| folder | exemplar | face | reason |
|---|---|---|---|
| amicus-brief | FILED-EXAMPLE-amicus-brief-3.pdf | Century Expanded | commercial-face |
| cert-petition | FILED-EXAMPLE-cert-petition.pdf | Century Expanded | commercial-face |
| merits-brief | FILED-EXAMPLE-merits-brief-3.pdf | Century Expanded | commercial-face |

## tenth-circuit (58)

| folder | exemplar | face | reason |
|---|---|---|---|
| colorado/federal/bankruptcy-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint-2.pdf | — | scanned-no-text |
| colorado/state/court-of-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| colorado/state/court-of-appeals | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| colorado/state/supreme-court/answering-brief | FILED-EXAMPLE-answering-brief.pdf | Equity | commercial-face |
| colorado/state/supreme-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| colorado/state/supreme-court | FILED-EXAMPLE-answering-brief.pdf | Equity | commercial-face |
| colorado/state/supreme-court | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief-2.pdf | Equity | commercial-face |
| kansas/state/court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| kansas/state/court-of-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| kansas/state/court-of-appeals/opening-brief | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| kansas/state/court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| kansas/state/court-of-appeals | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| kansas/state/court-of-appeals | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| kansas/state/court-of-appeals | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| kansas/state/court-of-appeals | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| kansas/state/supreme-court/brief-on-the-merits | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| kansas/state/supreme-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| kansas/state/supreme-court/petition-for-review | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| kansas/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| kansas/state/supreme-court | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| kansas/state/supreme-court | FILED-EXAMPLE-petition-for-review.pdf | — | scanned-ocr |
| new-mexico/federal/bankruptcy-district/adversary-complaint | FILED-EXAMPLE-adversary-complaint.pdf | Equity | commercial-face |
| new-mexico/state/court-of-appeals/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | — | scanned-ocr |
| new-mexico/state/court-of-appeals/reply-brief | FILED-EXAMPLE-reply-brief.pdf | Constantia | commercial-face |
| new-mexico/state/court-of-appeals | FILED-EXAMPLE-petition-for-writ.pdf | — | scanned-ocr |
| new-mexico/state/court-of-appeals | FILED-EXAMPLE-reply-brief.pdf | Constantia | commercial-face |
| new-mexico/state/supreme-court/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| new-mexico/state/supreme-court/brief-on-the-merits | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| new-mexico/state/supreme-court/reply-brief | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| new-mexico/state/supreme-court | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| new-mexico/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| new-mexico/state/supreme-court | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| oklahoma/federal/bankruptcy-northern-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| oklahoma/state/court-of-civil-appeals/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| oklahoma/state/court-of-civil-appeals | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| oklahoma/state/court-of-criminal-appeals/brief-on-the-merits | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| oklahoma/state/court-of-criminal-appeals/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| oklahoma/state/court-of-criminal-appeals/petition-for-rehearing | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| oklahoma/state/court-of-criminal-appeals | FILED-EXAMPLE-brief-on-the-merits.pdf | — | scanned-ocr |
| oklahoma/state/court-of-criminal-appeals | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| oklahoma/state/court-of-criminal-appeals | FILED-EXAMPLE-petition-for-rehearing.pdf | — | scanned-ocr |
| oklahoma/state/supreme-court/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| oklahoma/state/supreme-court/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| oklahoma/state/supreme-court/brief-on-the-merits | FILED-EXAMPLE-brief-on-the-merits.pdf | Garamond | commercial-face |
| oklahoma/state/supreme-court/reply-brief | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| oklahoma/state/supreme-court | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| oklahoma/state/supreme-court | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| oklahoma/state/supreme-court | FILED-EXAMPLE-brief-on-the-merits.pdf | Garamond | commercial-face |
| oklahoma/state/supreme-court | FILED-EXAMPLE-reply-brief.pdf | — | scanned-ocr |
| utah/federal/district/motion-brief | FILED-EXAMPLE-motion-brief-3.pdf | Proxima Nova | commercial-face |
| utah/federal/district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Charter | commercial-face |
| utah/state/supreme-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| utah/state/supreme-court/petition-for-writ | FILED-EXAMPLE-petition-for-writ.pdf | Garamond | commercial-face |
| utah/state/supreme-court | FILED-EXAMPLE-motion-brief.pdf | Garamond | commercial-face |
| utah/state/supreme-court | FILED-EXAMPLE-petition-for-writ.pdf | Garamond | commercial-face |
| wyoming/state/supreme-court/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| wyoming/state/supreme-court | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |

## third-circuit (15)

| folder | exemplar | face | reason |
|---|---|---|---|
| court-of-appeals/answering-brief | FILED-EXAMPLE-answering-brief-2.pdf | Garamond | commercial-face |
| new-jersey/federal/district/complaint | FILED-EXAMPLE-complaint.pdf | unnamed `zc00000.tmp` | unnamed-font |
| pennsylvania/federal/bankruptcy-middle-district/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| pennsylvania/state/commonwealth-court/answering-brief | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| pennsylvania/state/commonwealth-court | FILED-EXAMPLE-answering-brief.pdf | — | scanned-ocr |
| pennsylvania/state/court-of-judicial-discipline/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| pennsylvania/state/court-of-judicial-discipline | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| pennsylvania/state/superior-court/motion-brief | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| pennsylvania/state/superior-court/opening-brief | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| pennsylvania/state/superior-court | FILED-EXAMPLE-motion-brief.pdf | — | scanned-ocr |
| pennsylvania/state/superior-court | FILED-EXAMPLE-opening-brief.pdf | — | scanned-ocr |
| pennsylvania/state/supreme-court/amicus-brief | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| pennsylvania/state/supreme-court/petition-for-discretionary-review | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
| pennsylvania/state/supreme-court | FILED-EXAMPLE-amicus-brief.pdf | — | scanned-ocr |
| pennsylvania/state/supreme-court | FILED-EXAMPLE-petition-for-discretionary-review.pdf | — | scanned-ocr |
