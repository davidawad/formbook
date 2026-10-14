# txnb: motion-brief

Doc type: **motion with brief in support** in the United States Bankruptcy Court for the Northern District of Texas (`txnb`), filed in an adversary proceeding (for example, a motion to dismiss).
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-northern-district/motion-brief/`.

BLOCKED: no exemplar. No filed motion or brief from this court could be found or downloaded (searches listed in `exemplars/SOURCE.md`). The template is built from the rules below; the layout choices the rules leave open are conventions, not checked against a filing.

| Item | Status |
|---|---|
| exemplar | no (`BLOCKED: no exemplar`; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-synthetic-motion-brief.md`: a SYNTHETIC test fixture, not a transcription of a filing. It exists only to exercise the template. |
| render | ok on the synthetic fixture: `tools/render.sh` ran with typst 0.15.0, vendored EB Garamond only, no warnings. The PDF is `samples/OUTPUT-synthetic-motion-brief.pdf` (kept out of git, see Known gaps). |
| overlay | fail: `tools/overlay.sh` exits 1 with "no exemplar pdf in exemplars". There is nothing to overlay against. |
| pages reviewed | 4 of 4 (synthetic render, every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary sources, fetched 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013 | A motion must state its grounds with particularity and set forth the relief or order requested; a request for an order is made by written motion, with the exceptions in the rule. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9013 on 2026-10-14 (paraphrased; the page's quote limit prevented verbatim quoting). | Title (`title` frontmatter) and the body; the template does not check that grounds are stated. |
| Fed. R. Bankr. P. 9004(a)-(b) | Legible papers; caption with (1) court name, (2) case title, (3) case number and adversary number, (4) designation of the document. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14. | `court-title()`, `caption()` (case and adversary numbers), `cover()` title line. |
| L.B.R. 9013-1(a) | Applies L.B.R. 7007-1(a)-(c) and 7007-3 to motion practice in the bankruptcy court. Local rules revised 12/1/16, fetched from https://www.txnb.uscourts.gov/sites/txnb/files/local_rules/TXNB_Local_Rules_Revised_12.1.16_0.pdf on 2026-10-14. | The three items below. |
| L.B.R. 7007-1(a) | Conference before filing, except for motions to dismiss, motions for judgment on the pleadings, motions for summary judgment, motions for new trial, or when a conference is not possible or practicable. | No element; a motion to dismiss does not need the conference. |
| L.B.R. 7007-1(b) and (f) | Certificate of conference (unopposed or opposed, date, attorneys conferring, reasons); a certificate of conference is required for a motion that needs a conference. | `certificate_conference` frontmatter; the certificate is written only when the frontmatter gives it. |
| L.B.R. 7007-1(c) | Proposed order, set forth separately as an exhibit to the motion. | Not generated (see Known gaps). |
| L.B.R. 7007-1(e) and 9014-1(b) | Certificate of service (date, mode of service, names and addresses of parties served) filed with the clerk, attached to the motion. | `certificate_service` frontmatter. |
| L.B.R. 7007-2(a) | A brief shall be printed, typewritten, or presented in some other legible form. | Typeset in the template. |
| L.B.R. 7007-2(c) | A brief shall not exceed 25 pages, excluding the table of contents and table of authorities. A reply brief shall not exceed 10 pages. | Not enforced by the template (see Known gaps). |
| L.B.R. 7007-2(d) | A brief over 10 pages shall contain (1) a table of contents with page references and (2) an alphabetically arranged table of authorities with page references. | Table of contents: generated from the headings when `toc: true`. Table of authorities: not generated (see Known gaps). |
| L.B.R. 9013-1(b)(5) | A complete paper copy of a motion to dismiss under Fed. R. Bankr. P. 7012 is to be delivered within 24 hours of electronic filing, unless the Presiding Judge orders otherwise. | Not a template element; a filing step to note. |

No font, margin or line-spacing rule for motions was found in the N.D. Tex. bankruptcy local rules (the copy above). The mailing-matrix type rule (10 to 14 pt, Courier, Times Roman, Helvetica or Orator) is for the matrix in a complex Chapter 11 case and is not applied here.

The local rules copy is dated "Revised 12/1/16". A later revision may exist on the court's site; this run did not find one. Recheck before filing.

## Layout

- Letter size, 1-inch margins, page number centered in the footer.
- Counsel block single-spaced at the top left (the N.D. Tex. bankruptcy local rules do not say where counsel goes; this is a convention).
- Court title centered and bold: UNITED STATES BANKRUPTCY COURT / NORTHERN DISTRICT OF TEXAS / DIVISION.
- Form 416 caption (same as the adversary-complaint folder): debtor above the adversary parties on the left; chapter, case number and adversary number on the right.
- Title centered and bold, then the body.
- Body double-spaced (about 24 pt pitch at 12 pt, a convention), paragraphs unnumbered and first-line indented 0.5 in. Headings: level 1 centered bold caps; level 2 bold; level 3 bold italic.
- Lists numbered 1., 2., ... as written (relief items).
- Table of contents on its own page, after the cover, when `toc: true`.
- Signature block, then the certificate of conference and the certificate of service when given. Each certificate is kept on one page with its heading.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `caption` (`debtor` optional; `parties` list of `{names, designation}`), `chapter`, `case_number`, `adversary_number`, `division`, `title`, `toc` (true to generate the table of contents), `counsel`, `date`, `signature` (`firm`, `signer`, `lines`), `certificate_conference` and `certificate_service` (optional markdown; a leading `[noindent]` is removed).
- Body: blank-line-separated chunks. A `#` heading (the table of contents picks up levels 1 and 2); a list; or a paragraph. A paragraph starting with `[noindent]` is not first-line indented.
- Not supported: tables, footnotes, raw typst.

## Known gaps and open choices

1. **No exemplar (blocking for tier 2).** The brief asks for a filed exemplar; none was found (see `exemplars/SOURCE.md`). Spacing, caption detail, counsel placement and the certificate wording are unchecked against a filing. Tier 2 cannot be judged. The overlay cannot run.
2. **Synthetic fixture.** `samples/INPUT-synthetic-motion-brief.md` is a placeholder test document, not an exemplar. Its render is for template testing only.
3. **Table of authorities not generated.** L.B.R. 7007-2(d)(2) requires one for a brief over 10 pages. Generating page references needs a citation-tagging step in the sample, which is not built. A brief over 10 pages cannot be filed from this template without it.
4. **Page limit not enforced.** L.B.R. 7007-2(c) allows 25 pages, excluding the table of contents and authorities. The template does not count body pages or fail the build past 25.
5. **Proposed order not generated.** L.B.R. 7007-1(c) requires it as a separate exhibit. It is a separate document, to be drafted separately.
6. **Certificate of conference.** L.B.R. 7007-1(a) exempts motions to dismiss from the conference requirement. The template writes a certificate only when the frontmatter gives one, so a motion to dismiss can omit it.
7. **Font.** No font rule was found for motions, so EB Garamond at 12 pt (the only vendored font) is used. It is smaller in apparent size than Times New Roman at 12 pt.
8. **Output PDFs are not committed.** Following the snapshot's rule against PDFs in the repo, `OUTPUT-synthetic-motion-brief.pdf` was moved to `/work/artifacts/` after review. Rerun `sh tools/render.sh <this-folder> samples/INPUT-synthetic-motion-brief.md` to regenerate it.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and `tools/` is out of scope for this box. The gates were not run.

## Review of the rendered pages (synthetic fixture, final template)

- Page 1: counsel block; court title; Form 416 caption; the title "DEFENDANT'S MOTION TO DISMISS AND BRIEF IN SUPPORT" centered. No overlap. Pass.
- Page 2: table of contents from the headings (the first heading is the fixture's own title, "Synthetic fixture", which the fixture adds; a real brief would not carry it). Page numbers are shown; all the headings fall on page 3 in this fixture. Pass.
- Page 3: body paragraphs indented and double-spaced; headings centered bold caps and bold sub-headings; relief list numbered; the signature block; the certificate of conference with the signer's "/s/" line. Pass.
- Page 4: the certificate of service, kept together on its own page because it did not fit on page 3. Pass.

[Formbook index](../../../../../../README.md) | [Court README](../README.md)
