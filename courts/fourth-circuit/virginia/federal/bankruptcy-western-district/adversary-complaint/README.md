# United States Bankruptcy Court, W.D. Virginia: complaint commencing an adversary proceeding

- Court: `vawb`, United States Bankruptcy Court for the Western District of Virginia (`courts/fourth-circuit/virginia/federal/bankruptcy-western-district/`)
- Doc type: `adversary-complaint`. Complaint commencing an adversary proceeding (FRBP 7001); one self-contained folder, no shared files.
- Exemplar: `exemplars/FILED-EXAMPLE-rosen-24-06016-adversary-complaint.pdf` (*Rosen v. Texas Guaranteed Student Loan Corp. (n/k/a Trellis)*, Adv. No. 24-06016, filed 2024-05-31; provenance in `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-rosen-adversary-complaint.md`: the whole filed complaint, transcribed, with two changes marked in Known gaps.
- Status: template built; render, overlay and a page-by-page review done (below). Not reviewed by a human; `court.json` of the court folder untouched.
- Exemplar: yes (one filer, one exemplar; the brief asks for one per doc type).

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` and calls `vawb-adversary-complaint`. |
| `typst/vawb-adversary-complaint.typ` | Template. Parameter block at the top, each line tied to a rule or marked as a convention. |
| `samples/INPUT-rosen-adversary-complaint.md` | Sample: YAML frontmatter (caption, counsel, signature, service) and the body. |
| `samples/OUTPUT-rosen-adversary-complaint.pdf` | `sh tools/render.sh courts/fourth-circuit/virginia/federal/bankruptcy-western-district/adversary-complaint samples/INPUT-rosen-adversary-complaint.md` (3 pages, no typst warnings). |
| `samples/OVERLAY-rosen-adversary-complaint.pdf`, `.txt` | `sh tools/overlay.sh courts/fourth-circuit/virginia/federal/bankruptcy-western-district/adversary-complaint rosen-adversary-complaint` (red = ours, blue = filed, black = agree). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

File names follow the repo's tools (`INPUT-`/`OUTPUT-`/`OVERLAY-`) rather than the brief's `<id>.pdf` and `<id>-overlay.pdf`, because `tools/overlay.sh` reads `OUTPUT-<id>.pdf`.

## Governing rules

Primary sources, verified 2026-10-14. Local rules: W.D. Va. Local Rules, effective 3/14/25, <https://www.vawb.uscourts.gov/sites/default/files/local_rules/Local%20Rules%20-%202025.pdf> (read as text with pdftotext; LR 5005-3 at its p. 44, LR 7001-1 at p. 55).

| Rule | Requirement | Where the template uses it |
|---|---|---|
| LR 5005-3(C); LR 7001-1(C)(3) | Letter size, photo-reduced if needed; top margin of not less than 1 1/2 inches; multi-page papers fastened at the top | `top-margin = 1.5in`, `page-w`/`page-h` |
| LR 5005-3(A); LR 7001-1(C)(1) | Legibility: plainly and legibly typed, printed or reproduced, one side only | text output, one-sided pages |
| LR 7001-1(C)(2) | Caption and form per the Bankruptcy Rules and Official Forms; each paper bears the case number | `caption()` (case number in the right column) |
| LR 7001-1(C)(4) | Lower left-hand portion of the signature page: name, address, telephone and e-mail | `signature-block()`: counsel lower left |
| LR 7001-1(D)(1)-(2) | Filing fee and an originally signed Adversary Proceeding Cover Sheet (A.O. Form B-104) must accompany the complaint | not generated (see Known gaps) |
| LR 7001-1(A) | Venue: the complaint is filed in the divisional office where the bankruptcy case is pending | `division` frontmatter field (printed when given) |
| LR 9013-1(I) | Caption (example): court name, division, debtor, case number, the Movant/Respondent/Trustee designation, and a motion number | `caption()` uses the same left-column designations (complaint uses Plaintiff/Defendant) |
| FRBP 7010, <https://www.law.cornell.edu/rules/frbp/rule_7010> (as amended eff. 12/1/2024) | Caption substantially conforms to Official Form 416; Fed. R. Civ. P. 10 applies | `caption()`; numbered paragraphs (`set enum`) |
| FRBP 7008(a), <https://www.law.cornell.edu/rules/frbp/rule_7008> (as amended eff. 12/1/2024) | Jurisdiction allegation refers to the case's name, number and chapter and the district and division; the pleader must state whether it does or does not consent to entry of final orders or judgment by the bankruptcy court | the sample's paragraph 22 is a bracketed placeholder for this statement (see Known gaps); the template does not generate it |
| FRBP 9004(b), <https://www.law.cornell.edu/rules/frbp/rule_9004> (as amended eff. 12/1/2024) | Caption sets out the court's name, the case title, the case number and adversary number, and a designation of the document | `caption()` and the title line |
| FRBP 9004(a) | Legibility; abbreviations | text output |
| Fed. R. Civ. P. 10(b) (through FRBP 7010) | Numbered paragraphs, each limited to a single set of circumstances | markdown ordered lists render as `1.`, `2.` ... |

Conventions the template follows that no rule in the sources above fixes (tier 2): 12 pt EB Garamond (vendored), double spacing (24 pt pitch), one-inch side and bottom margins, page number centered in the footer, numbered paragraphs with the number at 0.5 in.

## Overlay

`samples/OVERLAY-rosen-adversary-complaint.pdf` puts our render (red) over the filed exemplar page with the most shared words (blue). Pairings from the last run (word overlap):

- Sample p.1 ↔ filed p.1 (78.5%): caption, salutation, first paragraphs. The filed caption is set as "IN THE UNITED STATES BANKRUPTCY COURT FOR THE WESTERN DISTRICT OF VIRGINIA" (no division line) with the parties in a different arrangement; expected.
- p.2 ↔ filed p.2 (64.7%): ours has paragraphs 7–18 and the heading "Facts and Request for Relief"; the filed page 2 carries paragraphs 4–14 and the same heading. The paragraph breaks fall on different lines, so the two pages do not align line for line.
- p.3 ↔ filed p.3 (48.4%): ours has paragraphs 19–22, the prayer, the counsel block and the service address; the filed page 3 has paragraphs 15–21 and the prayer. The filed signature block is on filed p.4, which the overlay does not pair with anything in our sample.

Diagnostic only, not a score.

## Page review (Gate 2)

Every page of `OUTPUT-rosen-adversary-complaint.pdf` was rendered at 60 dpi and viewed (3 of 3). The first pass showed two defects; both were fixed and the pages re-rendered and re-viewed.

| Page | Content | Result |
|---|---|---|
| 1 | Court title, caption, salutation, opening paragraph, paragraphs 1–6 | OK after fix: the party column is 4 in, so "(n/k/a Trellis)" no longer breaks at the slash. Before the fix it broke as "(n/" and "k/a". |
| 2 | Paragraphs 7–18; heading "Facts and Request for Relief" | OK after fix: the section heading was set at the heading size (larger than body) and is now body size, bold, centered. |
| 3 | Paragraphs 19–22; prayer; counsel block lower left; signature block; service address | OK. Paragraph 22 is the bracketed placeholder (see Known gaps). |

Typst printed no warnings. Fonts embedded: EB Garamond Regular and Bold only.

## Known gaps

1. **Consent statement (FRBP 7008(a)).** The filed complaint does not state whether the plaintiff consents to entry of final orders by the bankruptcy court. The template does not generate it. The sample's paragraph 22 is a bracketed placeholder, labelled as not in the filed complaint; it is not a choice made for the filer. Counsel must write the statement before filing.
2. **Cover sheet and fee (LR 7001-1(D)).** The Form B-104 cover sheet, the filing fee, and the summons (FRBP 7004) are not generated; they are separate papers.
3. **Exemplar depth.** The filed complaint is 4 pages, so the sample is 3 rendered pages, the full text transcribed. The brief's 8–14 page target does not apply to a 4-page exemplar.
4. **One filer.** The exemplar is one complaint by one counsel. Tier-2 conventions were judged against this one exemplar only; the brief's usual 2–3 exemplars from different filers were not found. A second W.D. Va. adversary complaint with a stored, text-based PDF was not located in the searches listed in `exemplars/SOURCE.md`.
5. **Caption layout.** The filed caption has no division line and uses "IN THE ... COURT / FOR THE ... DISTRICT" wording; the template uses the LR 9013-1(I) layout (court name on two lines, division when given). Tier-2 difference, accepted: the local rule's example caption is the template's reference.
6. **Electronic filing.** LR 5005-4 incorporates the court's Administrative Procedures for electronic filing (ECF, PDF requirements). Those procedures were not fetched in this box, so no PDF-format check is claimed.
7. **Rules not fetched.** The local rules and the FRBP texts above were read; FRBP 7001 (the categories of adversary proceedings) and 7004 (service and summons) were not, and the template does not depend on them.
8. **Typeface.** Face required: none. The W.D. Va. Local Rules (2025 text, read again 2026-10-14) name no typeface; the only font rule is LR 1007-2(F), a 12-point minimum for a pro se debtor's creditor list, which this template does not produce. FRBP 9004(a) requires only that a paper be "clearly legible". The filed complaint embeds Times New Roman, but a filer's choice is not a rule. Vendored substitute: none needed; `EB Garamond` stays (`docs/FONTS.md`: a court that names no face keeps EB Garamond), set at 12 pt, which meets the LR 1007-2(F) minimum. Fit: n/a. Fonts pass (fb-595.7.5): template unchanged, so the render is still 3 pages.
