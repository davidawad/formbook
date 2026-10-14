# txsd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of Texas (`txsd`).
Folder: `courts/fifth-circuit/texas/federal/southern-district/complaint/` (new one-folder-per-doc-type layout; the court-root `typst/` and `samples/` are untouched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-schott-4-26-cv-08325-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-schott-complaint.md` (portions of the 14-page filing; see the sample's header) |
| typeface | face required by the retrieved rules: none named (LR10.2, Judge Hanks Procs. 7.A, Galveston f.). Substitute: none; **EB Garamond kept** (`docs/FONTS.md`, "No face named"). Embedded: EB Garamond only (`pdffonts`). |
| render | ok (re-run 2026-10-14): `samples/OUTPUT-schott-complaint.pdf`, 8 pages, typst 0.15.0, `tools/render.sh`, vendored fonts only, no warnings |
| overlay | ok (re-run 2026-10-14): `samples/OVERLAY-schott-complaint.pdf` and `samples/OVERLAY-schott-complaint.txt` |
| pages reviewed | 8 of 8 (re-rendered at 60 dpi and every page viewed on 2026-10-14; the layout is unchanged from the earlier review, which is listed below) |
| BLOCKED | none |

File names follow the repo's tools: `tools/render.sh` writes `OUTPUT-<id>.pdf` from `INPUT-<id>.md`, and `tools/overlay.sh` writes `OVERLAY-<id>.pdf` and `.txt`. The brief's `<id>-overlay.pdf` naming was not used so that the tools run unchanged.

## Governing rules

| Rule | Requirement | Where it is in the template | Verified |
|---|---|---|---|
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number, and the Rule 7(a) designation of the parties. | `court-title`, `caption-box` (the `C.A. No.` line and the party column). | Text fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_10 |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Body paragraphs are numbered 1, 2, ... by `body-content`; headings, lettered sub-items and prayer items are not. The paragraph under PRAYER FOR RELIEF and under JURY TRIAL DEMAND is not numbered (`unnumbered-headings`). | Same source as above |
| Fed. R. Civ. P. 11(a) | Signature of an attorney of record on the pleading; the signature block. | `signature-block`. | Not fetched; cited from the rule's known text. |
| Fed. R. Civ. P. 5(b)(2)(E) | Service on a registered user by the court's electronic-filing system (the complaint's service is the summons; this is for later filings). | Not used by the complaint template (see the motion-brief README). | Fetched 2026-10-14 from https://www.law.cornell.edu/rules/frcp/rule_5 |
| S.D. Tex. LR10.2 (Format, Local Rules, Sept. 2025 reprint) | "Papers ... must be on 8½" x 11" paper, stapled at the top only, punched at the top with two holes, double spaced, and paginated." Names **no typeface and no point size**. | Page size, margins, double spacing (`double`), page numbers. The 13 pt size comes from the judge rules below, not from LR10.2. | Text extracted 2026-10-14 from https://www.txs.uscourts.gov/sites/txs/files/LR%20September%202025%20Reprint.pdf (`pdftotext`; LR10.1 caption also cited) |
| Judge George C. Hanks, Jr. Court Procedures, 7.A (Houston Division) | "...limited to 25 pages, 13-point type-font, double-spaced, with 1" margins." Names no face. | Same as above. Applies to Judge Hanks's cases; the Schott complaint is not before him. | Fetched 2026-10-14 from https://www.txs.uscourts.gov/sites/txs/files/GCH_Court_Procedures.pdf (`pdftotext`) |
| Galveston Division Rules of Practice, f. | "Filings must be double-spaced and in 13-point or larger font." | `type-size = 13pt`, `double = 1.35em` (2.0 x type size). A Galveston Division judge's rule, not the Houston Division's; no face named. The template uses the 13 pt reading for all divisions; see Known gaps. | Fetched 2026-10-14 from https://www.txs.uscourts.gov/sites/txs/files/GalvestonDistrictCourtRulesofPractice.pdf |

Not produced by this template (separate filings that may be required with the first filing): the civil cover sheet (JS-44), the S.D. Tex. disclosure of interested parties (the Certificate of Interested Parties required by the division's orders), the Rule 7.1 disclosure statement, and the summons.

## Layout

- Page: US Letter, 1-inch margins on all sides, page numbers centered at the foot. No pleading line numbers: the Houston exemplar does not use them and no retrieved S.D. Tex. text requires them.
- Court title: "UNITED STATES DISTRICT COURT" / "FOR THE SOUTHERN DISTRICT OF TEXAS", and the division if the sample names one (`division`).
- Caption: `caption.style: box` (the Schott form: party column closed by a right rule and a bottom rule; `C.A. No.` and `JURY DEMANDED` at the right) or `section` (the Dangelas form, with a § column; used by the motion-brief template). Party names and designations come from `caption.parties`; "v." between parties.
- Title: bold, centered, capitals (`brief_title`).
- Lead-in: `lead_in`, unnumbered, before the first heading.
- Body: `#` headings are centered bold capitals; `##` headings are bold, left; paragraphs numbered with a 0.5-inch first-line indent; `- ` items are lettered (a), (b) with a hanging indent; `A. ` items (prayer) keep their letter.
- Signature: `signature` (`lead`, `party`, `by`, `signer_lines`) in a block indented 3.25 inches, single-spaced; `date` above it.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `division`, `judge`, `caption` (`style`, `parties`), `jury_demand`, `brief_title`, `lead_in`, `signature`, `date`.
- The body is blank-line-separated chunks: a `#`/`##` heading, a `- ` list, a `A. ` prayer item, or a paragraph (numbered).
- The sample must not put numbering in the text: the template numbers the allegations.
- Not supported: tables, footnotes, raw typst. Case names are italic with `*...*`.

## What the overlay shows

`tools/overlay.sh` pairs each rendered page with the exemplar page that shares the most words, then shows ours in red over the filed page in blue (black where they agree). Word-overlap per page (see `samples/OVERLAY-schott-complaint.txt`): ours 1 with filed 1 (80%), 2 with 2 (55%), 3 with 3 (46%), 4 with 5 (69%), 5 with 6 (64%), 6 with 8 (49%), 7 with 9 (54%), 8 with 14 (39%). The later pairings are low because the sample transcribes only portions of the filing (pages 1 to 7 and 12 to 14 of the exemplar, with most of filed paragraphs 1 to 48 transcribed and filed paragraphs 49 to 72 not). The overlay is a diagnostic, not a score; the layout comparison is the page review above.

## Known gaps and open choices

1. **One exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers; this pass collected one. Candidates seen in the same RECAP search and not saved: Muniz v. Mill Creek Residential Trust LLC, 4:26-cv-08861 (8 pages, SRIPLAW, copyright, checked for text), Ade Ojo v. YMCA of the Greater Houston Area, 4:26-cv-08791 (13 pages), Eli Lilly and Co. v. Cenexa Labs LLC, 4:26-cv-08806 (34 pages). Tier 2 is **not** judged against two filers yet.
2. **Font size (open question for David).** The template uses 13 pt, from the Galveston Division rule (f.) and Judge Hanks's procedures (7.A). Neither is the rule for this complaint's judge, and LR10.2 names no size. The Schott exemplar is 12 pt Times New Roman. If the presiding judge's procedures or the district's form rule allow 12 pt, change `type-size` in `typst/txsd-complaint.typ`. The procedures of the judge assigned to this case were not retrieved.
3. **Font face (decided 2026-10-14: EB Garamond kept).** No retrieved rule names a typeface (LR10.2, Hanks 7.A, Galveston f.), so `docs/FONTS.md` ("No face named") keeps EB Garamond. The Schott exemplar is Times New Roman, which is a filer's choice, not a rule. Liberation Serif is vendored and metric-compatible with Times New Roman if David wants Times; that would be a one-line change to `font-family`, and page count would then be checked against the filing. EB Garamond has a smaller x-height than Times at the same size, so the text looks smaller than the exemplar at 13 pt.
4. **Local-rule text.** LR10.1 and LR10.2 are now read from the Sept. 2025 reprint (see Governing rules). LR7.1 (conference averment) is a motion rule and does not apply to a complaint.
5. **Paragraph numbers and transcription.** The filed paragraph numbers are not transcribed; the template numbers from 1, so the sample numbers differ from the filing. Filed paragraphs 1 to 48 are transcribed in part (sections I to IV are abbreviated), the count (filed paragraph 73) and the prayer are kept, and filed paragraphs 49 to 72 are not transcribed. Footnote 1 on page 2 is not transcribed. Exhibit A (the Abner order) is referred to but not included.
6. **Count subtitle.** The filing centers "(Unpaid Overtime Under the FLSA)" under COUNT I; the template renders `##` headings left-aligned and bold. Logged as a tier-2 difference (OPEN).
7. **Caption number.** `C.A. No.` takes `case_number` when one is set; the filed form leaves it blank until assignment. This is a content choice, not a template defect.
8. **Clerk's header.** The ECF header line ("Case 4:26-cv-08325 Document 1 Filed 09/24/26") is added by the clerk and is not reproduced.
9. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids editing `tools/`. Render and overlay were run; this README's page review is the Gate 2 equivalent.

## Pages reviewed (Gate 2 rows, rendered at 60 dpi and viewed)

- Page 1: court title on two lines, box caption with C.A. No. and JURY DEMANDED, title "COMPLAINT", lead-in, PROCEDURAL BACKGROUND, paragraphs 1 and 2 numbered. No spill. Pass (re-viewed after the court-title change).
- Page 2: JURISDICTION AND VENUE, PARTIES, FACTS, heading I. Pass.
- Page 3: paragraphs 11 to 15, numbering and double spacing held. Pass.
- Page 4: paragraphs 15 to 20; heading II (bold, left, on two lines); lettered (a) to (c) start at the page foot. Pass.
- Page 5: lettered (d) to (f) carried over from page 4 with a hanging indent; paragraphs 21 to 26. Pass.
- Page 6: paragraphs 27 to 32; heading III. Pass.
- Page 7: paragraphs 33 to 38; heading IV; COUNT I and its subtitle; PRAYER FOR RELIEF heading with its WHEREFORE line kept with the prayer items (moved to page 8 with them). Pass.
- Page 8: prayer items A to D (indented letters), JURY TRIAL DEMAND (unnumbered), signature block single-spaced at the right. Pass.
