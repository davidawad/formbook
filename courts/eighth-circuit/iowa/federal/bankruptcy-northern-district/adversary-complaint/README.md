# ianb: adversary complaint

Doc type: **adversary complaint** (a complaint in an adversary proceeding, FRBP Part VII) in the United States Bankruptcy Court for the Northern District of Iowa (`ianb`). Folder: `courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, 2 filers: `exemplars/FILED-EXAMPLE-hanrahan-comstar-25-09028-adversary-complaint.pdf` (6 pp.) and `exemplars/FILED-EXAMPLE-childers-roche-25-09079-adversary-complaint.pdf` (4 pp.). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-hanrahan-comstar.md` (5 rendered pages; transcribes the whole filing) and `samples/INPUT-childers-roche.md` (4 rendered pages; transcribes the whole filing) |
| render | ok: `samples/OUTPUT-hanrahan-comstar.pdf` (5 pp.) and `samples/OUTPUT-childers-roche.pdf` (4 pp.), typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-hanrahan-comstar.pdf` and `.txt`; `samples/OVERLAY-childers-roche.pdf` and `.txt` |
| pages reviewed | 9 of 9 rendered sample pages (5 + 4), each rendered at 60 dpi and viewed after the last template change |
| check.sh | not run: `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this doc-type folder has neither (see gap 9). Not a stamp. |

## Governing rules

No N.D. Iowa rule sets a font, size, margin, spacing or paper for this document, so the form is set by the federal rules that govern the caption, the body and the signature, and by the local rules on signatures and cover sheets.

| Rule | Requirement | Where it is in the template | Date verified and source |
|---|---|---|---|
| Fed. R. Bankr. P. 7010 | Adversary pleading: Fed. R. Civ. P. 10 applies, and the caption must substantially conform to the appropriate Official Form 416. | `caption()` | 2026-10-14, https://www.law.cornell.edu/rules/frbp/rule_7010 (restyled text, eff. Dec. 1, 2024). The Official Form 416 variants were not fetched (gap 2). |
| Fed. R. Bankr. P. 9004(a), (b) | Legible; caption with the court's name, the case title, the case number and adversary number, and a brief designation of the document. | `caption()`: court name; debtor and parties on the left; chapter, case number, adversary number and title on the right. | 2026-10-14, https://www.law.cornell.edu/rules/frbp/rule_9004 (eff. Dec. 1, 2024) |
| Fed. R. Bankr. P. 7008(a) | Jurisdiction must include the name, number and Code chapter of the case, and the district and division; the complaint must state whether the pleader consents to final orders or judgment by the bankruptcy court. | `complaint()` asserts that the body contains "consent" (a keyword check, gap 4). The jurisdiction paragraph is author text. | 2026-10-14, https://www.law.cornell.edu/rules/frbp/rule_7008 (eff. Dec. 1, 2024) |
| Fed. R. Civ. P. 10(a), (b) (via FRBP 7010) | Numbered paragraphs, each limited as far as practicable to a single set of circumstances; caption with court, title, file number and Rule 7(a) designation. | `numbered-para()`: every body paragraph after the first heading and not beginning COMES NOW or WHEREFORE is numbered by the template (gap 5). | 2026-10-14, https://www.law.cornell.edu/rules/frcp/rule_10 |
| N.D. Iowa L.R. 7003-1 | Every adversary complaint includes an Adversary Cover Sheet (Director's Form 1040). | Not generated (gap 6). | Local Rules, Part 7, https://www.ianb.uscourts.gov/local-rules2 (PDF "Part7_0", fetched 2026-10-14) |
| N.D. Iowa L.R. 9010-1(a) | The first paper filed that an attorney signs carries the attorney's bar number (an Iowa Bar number, SSN, or clerk-assigned number). | `signature()`: `bar`. | Local Rules, Part 9, PDF "Part9_0", fetched 2026-10-14 |
| N.D. Iowa L.R. 9010-1(b) | Below the attorney's signature: business address, telephone, e-mail and **business FAX number**. | `signature()`: address, phone, fax, email. The FAX line is required. | Local Rules, Part 9, PDF "Part9_0", fetched 2026-10-14. The 2022 compilation omitted FAX (gap 3). |
| Fed. R. Bankr. P. 9011 | Signature of the attorney (FRBP 9011(a)). | `signature()`: "/s/" line and signer. | 2026-10-14, not separately fetched; the rule is cited for the signature line only. |

Rule text for N.D. Iowa is taken from the current PDF parts linked on https://www.ianb.uscourts.gov/local-rules2 (Part 7 and Part 9). The PDFs carry no effective date. The 2022 compilation ("2022 Local Rules FINAL.pdf") and the 2020 combined version were also read; they differ on 9010-1(b) (no FAX), and the current parts control here.

## Frontmatter and body contract (for samples)

- YAML frontmatter, then the body. Required fields: `debtor`, `chapter`, `case_no`, `plaintiff`, `defendant`, `title`, and `signature` (`signer`, `bar`, `firm`, `address` (list), `phone`, `fax`, `email`, `role`, `date`). A missing field fails the render with a message naming it. `adversary_no` is optional (default: a blank "Adversary Case No. ____").
- Body: blank-line-separated chunks. `# ...` is a centered bold section heading; `## ...` is a centered bold heading (count headings). A chunk of `1. ...` lines is lettered (a), (b), ... by the template (prayer items). Any other chunk is a paragraph: numbered by the template (1, 2, ...), except paragraphs before the first heading and paragraphs beginning COMES NOW or WHEREFORE, which are unnumbered.
- The sample types no paragraph numbers. Tables, footnotes and raw typst are not supported (the adversary exemplars have neither).
- No case text is in the template. The court's name in the caption is fixed text (the court, not a case).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, micromamba env (see brief)
sh tools/render.sh courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/adversary-complaint samples/INPUT-hanrahan-comstar.md
sh tools/overlay.sh courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/adversary-complaint hanrahan-comstar exemplars/FILED-EXAMPLE-hanrahan-comstar-25-09028-adversary-complaint.pdf
# same for childers-roche with its exemplar
```

- File names follow the tools, not the brief's `<id>.pdf` / `<id>-overlay.pdf`: `render.sh` writes `samples/OUTPUT-<id>.pdf` and `overlay.sh` writes `samples/OVERLAY-<id>.pdf` and `.txt`. The overlay is passed the exemplar explicitly, because its default is the first PDF in `exemplars/`, which would pair Hanrahan with Childers.
- Overlay pairing (word overlap, from the `.txt` maps):
  - hanrahan-comstar: ours p.1-p.4 ↔ filed p.1-p.3, p.5 (75%, 60%, 59%, 54%); ours p.5 ↔ filed p.5 (41%). The filed signature page (p.6) has no pair; the filing's signature block is on that page.
  - childers-roche: ours p.1-p.4 ↔ filed p.1-p.4 (83%, 81%, 71%, 57%).
  - The overlay is a diagnostic, not a score. Our render has no pleading paper and the exemplars use Times or Helvetica, so the text lines do not coincide.

## Visual review (Gate 2 record)

Every sample page was rendered at 60 dpi and looked at, after the last template change.

| Sample | Page | What it is | Finding |
|---|---|---|---|
| hanrahan-comstar | 1 | Caption, court title, Chapter 7 and case number, adversary number, title; paragraphs 1-4 under I. | OK. Caption closed by a rule on the left column's right and bottom edges. |
| hanrahan-comstar | 2 | II. Background and parties, paragraphs 5-15. | OK. Double spaced; paragraph numbers at 0.5 in. |
| hanrahan-comstar | 3 | Count I (heading wraps to two lines, centered), paragraphs 16-24, Count II heading. | OK. No heading at the foot of the page. |
| hanrahan-comstar | 4 | Count II, count III, PRAYER FOR RELIEF, WHEREFORE, items (a)-(d). | OK. |
| hanrahan-comstar | 5 | Items (e)-(h), date, signature block with FAX placeholder. | OK. The FAX line reads "[not on the filed copy]", which is the placeholder for the missing line that 9010-1(b) now requires (gap 3). |
| childers-roche | 1 | Caption (the debtor is a multi-entity name), COMES NOW, I., paragraphs 1-4. | OK. |
| childers-roche | 2 | Paragraphs 5-12, II. Facts heading. | OK. |
| childers-roche | 3 | Paragraphs 12-14, III. Prayer, WHEREFORE, items (a)-(b). | OK. |
| childers-roche | 4 | Items (c)-(e), signature block with the date placeholder. | OK. The filed copy has no date line; the placeholder shows that. |

## Known gaps and open choices

1. **No font or size rule.** Nothing in the N.D. Iowa or FRBP text names a font or type size. The template uses EB Garamond (the only vendored family) at 13 pt, because EB Garamond at 12 pt sets visibly smaller than the exemplars' Times. Choice, not a rule. Recorded as ACCEPTED.
2. **Official Form 416 not fetched.** FRBP 7010 requires a caption that "substantially conform[s] to the appropriate version of Form 416". The template follows the caption the two exemplars use (court name on two lines, party block on the left, chapter, case number, adversary number and title on the right). The Official Form 416A text itself was not fetched, so this is a conformance by comparison with the exemplars, not against the form.
3. **FAX line.** The current N.D. Iowa L.R. 9010-1(b) (Part 9) requires a business FAX number under the signature. Hanrahan's filed copy (May 2025) has none, and the 2022 compilation did not require one. The template requires the `fax` field; the Hanrahan sample shows the placeholder "[not on the filed copy]" rather than a made-up number. This is a discrepancy between the exemplar and the current rule that David should know about: either the rule changed after the filing or the filer did not comply.
4. **Consent statement is a keyword check.** FRBP 7008(a) requires a statement of consent to final orders. The template asserts that the body contains the word "consent". That catches an omission, but not a wrong statement (for example, "does not consent" with a core-proceeding claim). The sample text is the filer's own.
5. **Paragraph numbering rule.** The template numbers every body paragraph after the first heading, except those beginning COMES NOW or WHEREFORE. The exemplars do the same (the Childers exemplar's WHEREFORE paragraph is also unnumbered). A paragraph that should be unnumbered (for example, a block quotation) needs a different form, which the template does not provide.
6. **No Adversary Cover Sheet.** N.D. Iowa L.R. 7003-1 requires Director's Form 1040 with every complaint. The template does not produce it, and the exemplars' cover sheets are separate attachments. Filed with the complaint, not part of this template.
7. **Length.** The two exemplars are 6 and 4 pages, so the samples render to 5 and 4 pages. The brief's 8-14 page target is not reachable from these filings; the samples transcribe each filing completely instead.
8. **Exemplar provenance.** Both are RECAP copies. The Hanrahan signature block is visible only in the page image, so it was transcribed from the picture. See `exemplars/SOURCE.md`.
9. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court directory with `court.json` and `rules.md`, and this doc-type folder has neither. The brief forbids touching `tools/` and `court.json`. The gate checks above (the FRBP 7008 keyword, the signature fields) are the only automated checks in this folder.
10. **Overlay file names.** The brief names `samples/<id>-overlay.pdf`; the tool writes `samples/OVERLAY-<id>.pdf`. The tool's names are used (see Render and overlay).
11. **Not produced:** the summons and the civil cover sheet. The rules read here do not require either to be part of the complaint document; the summons is a separate issuance by the clerk.

[Formbook index](../../../../../../README.md) | [Iowa](../../../README.md) | [motion-brief](../motion-brief/README.md)
