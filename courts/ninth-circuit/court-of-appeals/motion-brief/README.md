# Ninth Circuit (ca9): motion

Doc type: **motion-brief** (a motion, a response to a motion, or a reply; FRAP 27). Folder: `courts/ninth-circuit/court-of-appeals/motion-brief/`.

Status: filled 2026-10-26 by the template-gap procedure (`brief-build scaffold-template`, donor `../answering-brief`). Exemplars: 2 filed Ninth Circuit motions from different filers (`usage/SOURCE.md`). Engines: typst and docx (cross-engine gate on); the donor's latex engine was not carried over (its certificate and limits are a brief's). Gates on macOS, 2026-10-26: typst `RESULT: 16 checks passed, 0 failed`, docx `RESULT: 24 checks passed, 0 failed`. Pages reviewed: all 4 of the transcribed sample against exemplar 1; all 6 of the synthetic sample in both engines. Not a court-level `court.json` status.

## Governing rules (FRAP and Ninth Circuit Rules handbook effective June 1, 2026, https://cdn.ca9.uscourts.gov/datastore/uploads/frap-June%201%202026.pdf, pp. 93-95, 138-142)

| Rule | Requirement | Where it lives |
|---|---|---|
| FRAP 27(d)(1)(B) | A cover is not required, but the caption must give the case number, the court, the title of the case and a descriptive title naming the movant; a cover, if used, is white. | the shared ca9 cover (every filed example uses a caption page) |
| FRAP 27(d)(1)(D), (E); Circuit Rule 27-1(1)(c) | Letter paper, double spaced (quotations over two lines, headings and footnotes may be single), 1 in margins, FRAP 32(a)(5)-(6) typeface (14 pt serif). | the brief's page form, unchanged (`../../rules.md` CA9-FORM-*) |
| FRAP 27(d)(2)(A), (C) | A motion or response: 5,200 words; a reply: 2,600 words; FRAP 32(f) items excluded. | `motion-limits` by `motion_kind` (`motion`, `response`, `reply`); the render fails over the limit |
| Circuit Rule 27-1(1)(d); Circuit Rule 32-3 | 20 pages (reply 10), or words / 280. | not checked separately: 5,200 words is the binding limit for a computer-produced motion |
| Circuit Advisory Committee Note (1) to Rule 27-1 | Tables of contents and authorities are helpful over 10 pages or 2,500 words and are outside the count. | `tables: true/false`, else on over 2,500 words |
| FRAP 32(g)(1), (2) | A motion under 27(d)(2)(A) or (C) carries a certificate of compliance stating the word count; Form 6 suffices. | `certificate-of-compliance` (Form 6 wording; `word_processor` optional) |
| Circuit Rule 25-5(g)(1) | No certificate of service for a document served through ACMS. | `service.certificate` opt-in (Form 15 wording) |

## Frontmatter

The answering brief's (`case_number`, `caption`, `proceeding`, `brief_title`, `counsel`, `phone`, `signature`, `date`, optional `district_court_case`, `judge`, `authorities`, `service`, `related_cases`), plus `motion_kind` (default `motion`), `tables` and `word_processor`. `word_limit_basis` (Form 8) is not read.

## Known gaps

1. Circuit Rule 27-1(2)-(3) content (opposing counsel's position, a requested decision date in bold on the caption page) is the author's to write in the body; the template has no field for the bold date.
2. Emergency motions (Circuit Rule 27-3 certificate) are not modeled.
3. `fb lint` reports n-grams of the mandated form wording (FRAP Form 6, Ninth Circuit Form 15) and the donor's forced breaks in the signature block, as it does for the donor (63 findings there).
4. Exemplar 2 is not transcribed; the synthetic sample stands in for its tables.
