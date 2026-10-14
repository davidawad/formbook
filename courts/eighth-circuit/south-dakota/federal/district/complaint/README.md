# sdd: complaint

Doc type: **complaint** in the United States District Court for the District of South Dakota (`sdd`, ca8).
Folder: `courts/eighth-circuit/south-dakota/federal/district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-knosp-5-26-cv-05092-complaint.pdf` (1 filer, pro se; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-knosp-complaint.md` (the filed content of the exemplar; see below) |
| render | ok: `samples/OUTPUT-knosp-complaint.pdf`, 3 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-knosp-complaint.pdf` and `OVERLAY-knosp-complaint.txt` |
| pages reviewed | 3 of 3 (every page rendered at 60 dpi and viewed after the last template change) |
| tier 2 | not met to the eval-loop standard: one filer, and that filer is pro se (see Known gaps) |

File names follow the repo convention used by `tools/render.sh` and `tools/overlay.sh` (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `.txt`), not the `<id>.pdf` and `<id>-overlay.pdf` names in the brief, because the tools read and write the repo names by default.

## Governing rules

Primary source: D.S.D. Civil Local Rules, the official PDF on the court's site: https://www.sdd.uscourts.gov/sites/sdd/files/local_rules/12-1-15%20CIVIL%20LOCAL%20RULES%20OF%20PRACTICE.pdf . Fetched and read 2026-10-14. The printed page footers say "12/01/2015", which is the version date; no later version was found on the court site in this pass.

Federal rules: Fed. R. Civ. P. 8, 10 and 12, from https://www.law.cornell.edu/rules/frcp/rule_8 , `rule_10` and `rule_12`, fetched 2026-10-14. Rule 10 is "amended Apr. 30, 2007, eff. Dec. 1, 2007"; Rule 12 is "Apr. 2, 2024, eff. Dec. 1, 2024"; Rule 8 is "Apr. 28, 2010, eff. Dec. 1, 2010" (as the notes on the pages).

| Rule | Requirement (quoted or closely paraphrased from the source) | Where it is in the template |
|---|---|---|
| D.S.D. Civ. LR 83.4 | "All documents must be on 8 1/2 x 11 inch paper. The text must be double-spaced, but quotations more than two lines long must be indented and single-spaced. Headings and footnotes must be single-spaced. Margins must be at least one inch on all four sides. Fonts must be at least 12-point." | `margin = 1in`; `pitch = 24pt` (double spacing); `type-size = 12pt`; headings `single` leading; `paper: "us-letter"`. |
| D.S.D. Civ. LR 10.1(A) | "A pleading or other paper presented for filing must begin with the caption of the case, the title of the document, and the name of the party filing the document." | `cover(meta)`: court title, caption (parties), case number, title. |
| D.S.D. Civ. LR 10.1(B) | "All papers must be signed and include the typed or printed name, address, telephone number, and email address of the signer beneath the signature. This information must not appear as a header or footer on each page of the document, or as part of the caption of the case." | `signature-block(meta)` (the signature block is at the end of the body, not in the footer or the caption). |
| D.S.D. Civ. LR 5.1(A)(4) | The filing user's login serves as the signature; "Electronically filed documents must include a signature block" and the filing user's name "must be preceded by a '/ s /'". | `sig.pro_se` (a party without an attorney signs personally, with a line); otherwise "By: /s/" (attorney form). |
| Fed. R. Civ. P. 8(a) | "a short and plain statement of the grounds for the court's jurisdiction"; "a short and plain statement of the claim showing that the pleader is entitled to relief"; "a demand for the relief sought". | Sample sections: Basis for Jurisdiction, Statement of Claim, Relief (content supplied by the filer; the template does not check it). |
| Fed. R. Civ. P. 10(a) | "Every pleading must have a caption with the court's name, a title, a file number, and a Rule 7(a) designation." "The title of the complaint must name all the parties." | `court-title`, `caption` (names of all parties; case number; title). |
| Fed. R. Civ. P. 10(b) | "A party must state its claims or defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances." | `allegations()`: each paragraph is numbered 1, 2, ... ; a paragraph that starts with `~` is unnumbered (used for the certification, which is not an allegation). |

Jury demand: the template prints "JURY TRIAL DEMANDED" under the title when `jury_demand: true` (Fed. R. Civ. P. 38 requires a written demand; the rule is not quoted here because the template does not check it).

Not produced by this template: the civil cover sheet (JS 44), the summons, any Rule 7.1 disclosure, and any certificate of interested parties. These are separate filings; the exemplar's JS 44 is a separate page and is not transcribed.

No certificate of service is printed for the complaint: the complaint is served with a summons under Rule 4, not through CM/ECF. The motion brief template prints one (see `../motion-brief/README.md`).

## Layout

- Court title on top (three centered lines: "UNITED STATES DISTRICT COURT", "DISTRICT OF SOUTH DAKOTA", and the division, if given), then the caption: parties on the left (closed by a right and bottom rule), the case number, the title and "JURY TRIAL DEMANDED" on the right.
- No pleading paper and no line numbers: LR 83.4 does not require them, and the exemplar has none.
- Body double-spaced (24 pt pitch), first-line indent 0.5 in, numbered paragraphs. Headings are centered caps (level 1), bold (level 2), or bold italic (level 3), kept with the paragraph after them.
- Tables are single-spaced and not numbered (the exemplar's form uses party and defendant tables, and the sample keeps them as tables).
- Signature block at the end, kept on the same page as the last paragraph (so the signature is never alone on a page).
- Page number centered at the foot of every page.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`, `division` (optional), `caption.parties` (list of `{names, designation}`), `brief_title`, `jury_demand` (true or false), `date`, `signature` (`signer`, `pro_se` (true or false), `lines`, and `firm` for an attorney's firm block).
- Body chunks separated by blank lines: `#`, `##`, `###` headings; a markdown table; a list (lettered (a), (b), ...); or a paragraph (numbered). A paragraph starting with `~` is unnumbered.
- Not supported: footnotes (the complaint has none), raw typst. The sample must not put the paragraph numbers in the text; the template numbers the paragraphs.

## Overlay (red/blue test)

`samples/OVERLAY-knosp-complaint.pdf`: red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by shared words, not by index (see `samples/OVERLAY-knosp-complaint.txt`):

- our p.1 over filed p.1 (41.6% word overlap)
- our p.2 over filed p.4 (49.4%)
- our p.3 over filed p.5 (17.7%)

The pairing is partial: the exemplar is a 7-page form whose entries sit on pages 1 to 6 among pre-printed labels and instructions, so the word-overlap score is low even where the content matches. The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One filer, and it is pro se.** The brief asks for one exemplar per doc type, and EVAL-LOOP's tier 2 asks for two or three filers. The search (CourtListener RECAP, `court=sdd`, `type=r`, complaint queries; the API is limited to 5 requests a minute) found many complaints in this court, but only Knosp's has an available PDF. Tier 2 is therefore **not** judged against two or three filers. Whether a pro se AO form is a fair tier-2 reference for an attorney-drafted complaint is a question for David.
2. **Depth: 3 rendered pages, not 8 to 14.** The exemplar is 7 pages, but 6 of them are the AO form with its instructions and blanks; the filled content is about one and a half pages. The sample carries all of that filed content. No text was invented to reach a page count. A longer attorney-drafted complaint would be needed to test the body-text bar.
3. **Single spacing in the exemplar.** The AO form is single-spaced. LR 83.4 requires double spacing, so the template is double-spaced and the exemplar differs. The rule governs (the brief says the court's rules decide the layout; the exemplar settles only what the rules leave open).
4. **Sub-paragraph "A." became paragraph 2.** The form's "A. The federal statutes at issue..." is a separate paragraph in the sample and is numbered 2 by the template. This is the template's rule (each paragraph numbered), not a transcription error.
5. **Redactions.** Plaintiff's street address, telephone and e-mail are `[redacted]` in the sample, and the signature block shows the city only. Defendants' service addresses are kept (they are the registered-agent addresses). No SSN, birth date or financial-account number appears (LR 5.2).
6. **Jury demand.** The form's jury box is ambiguous in the text layer ("|^| Yes |_| No"). The docket text on CourtListener says "COMPLAINT with Jury Demand", so `jury_demand: true`.
7. **Signing date.** The text layer of the "Date of signing" line is illegible. The sample uses "July 21, 2026", the filing date stamped in the header, and says so in `exemplars/SOURCE.md`.
8. **Font.** EB Garamond is the only font vendored in `fonts/`. The exemplar is in a Times-metric face. EB Garamond's x-height is smaller, so the text looks smaller than the exemplar at the same 12 pt. The 12-point minimum is met. Vendoring a Times-metric font is a repo decision, not this box's.
9. **Caption.** The party column is closed by a right and bottom rule, not the ")" column of the form. Both are seen in filings; recorded as a tier-2 choice.
10. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` and are not run here; the brief says not to touch `tools/`. Render and overlay were run, and every page was reviewed.
11. **Page-number footer.** The number is centered at the foot of each page; the footer is not the case title (the complaint has no line-numbered pleading paper, so there is no required footer title).

## Review of the rendered pages (current PDF)

- Page 1: court title (three lines), caption with parties, case number, title and "JURY TRIAL DEMANDED", the "I. The Parties" heading, the plaintiff table, the defendants table, the "II. Basis for Jurisdiction" heading and paragraph 1. Pass (tables do not run into the caption; the heading is kept with its paragraph).
- Page 2: paragraph 2 (sub-paragraph A, jurisdiction), "III. Statement of Claim" with paragraph 3, "IV. Relief" with paragraph 4, "V. Certification and Closing" with its sub-heading. No overlap between paragraphs (after the paragraph-spacing fix described in `../motion-brief/README.md`). Pass.
- Page 3: the unnumbered certification paragraph and the signature block (line, name, pro se label, address, telephone, e-mail), kept together and not orphaned. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).
