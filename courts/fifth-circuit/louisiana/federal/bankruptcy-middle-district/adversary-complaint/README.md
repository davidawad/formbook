# lamb (Bankruptcy Court, M.D. La.): adversary complaint

Doc type: **adversary complaint** (FRBP 7001 et seq.) in the United States Bankruptcy Court for the Middle District of Louisiana (`lamb`).
Folder: `courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | **no**: `BLOCKED: no exemplar`. No filed M.D. La. adversary complaint found. Searches are in `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-adversary-complaint-sample.md`: **fictitious**, built from the rules, not transcribed from a filing. |
| render | ok: `samples/OUTPUT-adversary-complaint-sample.pdf`, 6 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | **fail**: `sh tools/overlay.sh` exits 1 with "no exemplar pdf in exemplars" (no filed exemplar exists). No `OVERLAY-*` file is written. |
| pages reviewed | 6 of 6 (every page rendered at 60 dpi and viewed after the last template change) |

File names. The brief asks for `samples/<id>.md`, `samples/<id>.pdf` and `<id>-overlay.pdf`. The repo tools read and write `samples/OUTPUT-<id>.pdf` and `samples/OVERLAY-<id>.pdf/.txt`, and `tools/` is not to be edited, so the tool names are used.

## Governing rules

Primary sources, verified 2026-10-14. Text was read from the court's own PDF or the official rule page (fetched through WebFetch; see caveat on FRBP 9013 in the motion README).

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| LAMB-FORM-001 | LR 5005-2(a) (2022 Local Rules, amended Jan. 1, 2022: https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf) | Documents are sized 8½ × 11 inches for filing. | `page` in `typst/lamb-adversary-complaint.typ`. |
| LAMB-FORM-002 | LR 5005-2(b) | 12-point font, double-spaced, for all documents except pro se parties. | `type-size = 12pt`; all text, headings, caption and footer at 12 pt. |
| LAMB-FORM-003 | LR 5005-2(b) | Double-spaced. | `body-leading = 0.7em`, calibrated so the baseline pitch is 24.06 pt on body pages (checked with `pdftotext -bbox-layout`). |
| LAMB-FORM-004 | Fed. R. Bankr. P. 9004(a) (legibility; https://www.law.cornell.edu/rules/frbp/rule_9004) | Clearly legible. | Vendored EB Garamond, 12 pt; no font fallback (`fallback: false`). |
| LAMB-CAP-001 | Fed. R. Bankr. P. 7010 (applies Fed. R. Civ. P. 10; caption must substantially conform to Official Form 416) (https://www.law.cornell.edu/rules/frbp/rule_7010) | Caption with court, title, parties, case and adversary numbers. | `caption(meta)`: court name, debtor "In re:", plaintiff and defendants, case no., chapter, adversary no. |
| LAMB-CONT-001 | Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | The jurisdiction allegation names the case, its number and Code chapter, and the district and division; the complaint states whether the pleader does or does not consent to final orders by the bankruptcy court. | The template panics unless the body contains the word "consent". Author writes the statement (see sample ¶¶ 3-5). |
| LAMB-CONT-002 | Fed. R. Civ. P. 10(b), applied by FRBP 7010 | Claims in numbered paragraphs, each limited as far as practicable to one set of circumstances. | Every body paragraph is numbered by the template (`numbered()`); headings and the `WHEREFORE` lead-in are not. |
| LAMB-CONT-003 | FRBP 7001(1) | Recovery of money or property is an adversary proceeding. | Cited in the sample; not checked by the template. |
| LAMB-FILE-001 | Standing Order 2026-1 (signed Feb. 24, 2026, effective Mar. 1, 2026: https://www.lamb.uscourts.gov/sites/lamb/files/Standing%20Order%202026-1%20adversary%20cover%20sheet.pdf) | Every original complaint in an adversary proceeding is accompanied by Official Form B1040, "Adversary Proceeding Cover Sheet". | **Not generated**: it is a separate form filed with the complaint. Listed here so it is not forgotten. |
| LAMB-FILE-002 | LR 7004-1(a)-(b) | Plaintiff requests issuance of summons on filing; serves summons, notice of pretrial conference and complaint within the FRBP 7004(e) time; files proof of service seven days before the scheduling conference. | **Not generated**: separate filings. |
| LAMB-FILE-003 | LR 9013-4(b) | A filing is served on the trustee, the debtor, debtor's counsel and the U.S. Trustee. | Not generated; the complaint carries no certificate. Separate certificate of service per LR 9013-4(a) if a notice filing is made. |

Not checked by the template, and listed as author responsibilities: the wording of the jurisdiction paragraph, the core and non-core designation, and the factual allegations.

## Layout and template

- Caption: court name centred, then a two-column Form 416 style caption. The left column is closed by a rule at the right and bottom; the right column has the case, chapter and adversary numbers. Every string comes from frontmatter.
- Title: centred, bold capitals, from `title`.
- Body: markdown chunks separated by a blank line. `# TEXT` is a centred bold capitals section heading; `## TEXT` is a bold left sub-heading; `### TEXT` is bold italic. A `1. ...` list is a lettered list `(a)`, `(b)` ... (prayer). A chunk starting `WHEREFORE` is an unnumbered lead-in. Any other chunk is a numbered allegation.
- Signature: `Dated:` on the left; `Respectfully submitted,`, the signer as `/s/`, and the counsel lines in italic on the right.
- No counsel block at the top left of page 1, no certificate, no proposed order (none is required for a complaint under these rules).

## Frontmatter (schema)

| Field | Required | Feeds |
|---|---|---|
| `title` | yes | Title under the caption; PDF title. |
| `debtor` | yes | "In re:" line. |
| `case_no` | yes | "Case No." |
| `chapter` | yes | Chapter line (e.g. "Chapter 7"). |
| `adv_no` | yes | "Adversary Proceeding No." |
| `plaintiff` | yes | List of lines for the plaintiff (e.g. the trustee's name and capacity). |
| `defendants` | yes | List of lines for the defendants. |
| `date` | yes | "Dated:" line. |
| `signature` | yes | `signer` and `lines` (counsel block). |

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/adversary-complaint
sh tools/render.sh $D samples/INPUT-adversary-complaint-sample.md        # -> samples/OUTPUT-adversary-complaint-sample.pdf
sh tools/overlay.sh $D adversary-complaint-sample                  # fails: no exemplar pdf
```

Render: `pdfinfo` reports 6 pages, us-letter. `pdffonts` lists EBGaramond-Regular, -Bold and -Italic only, all embedded. `render.sh` exits 0 with no typst output.

Body-line pitch on page 2 (the calibration): 24.06 pt between every pair of body lines.

## Visual review (Gate 2 record, 6 pages, 60 dpi, every page viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, first allegations | OK. Double comma after the debtor name was fixed (the template no longer adds a comma; the frontmatter carries it). |
| 2 | Allegations 4-11, Parties, "The Debtor and Its Business" sub-heading | OK. |
| 3 | Allegations 12-20, "The Transfers" and "The Debtor's Financial Condition" | OK. |
| 4 | "Badges of Fraud", "The Trustee's Demand", "Conditions Precedent", First Claim heading and allegations 29-30 | OK. The claim heading is kept with its first allegation. |
| 5 | First and Second and Third Claims, Reservation of Rights | OK. Claim headings centred, sub-heading bold, numbering continues across claims. |
| 6 | Prayer for relief (a)-(e), signature block | OK. Lettered list hangs correctly; `Dated:` and signature block aligned. |

## Known gaps and open choices

1. **No exemplar** (`BLOCKED: no exemplar`). Every choice that a real filing would settle is a choice made from the rules, not from a filed pleading: the Form 416 caption layout, the paragraph numbering style, and the signature block.
2. **Length.** 6 pages. The brief's 8-14 page target is set by an exemplar's length, and there is none. The sample is as long as it needs to be to exercise each rule-driven part (caption, jurisdiction and consent, parties, facts, badges of fraud, three claims, reservation, prayer). It is not padded.
3. **Lead-in paragraph is numbered.** The first chunk ("Plaintiff Jane Sample... files this Adversary Complaint...") takes paragraph number 1. Many practitioners leave that lead-in unnumbered. The template has no marker that leaves it unnumbered. Logged as a convention choice, not a rule point.
4. **Font.** EB Garamond at 12 pt (vendored, OFL), not Times New Roman. The rules name no typeface. The 12-point size is met; the x-height is smaller than Times at 12 pt, so the text looks smaller than a Times filing.
5. **Consent and jurisdiction wording.** The template only checks the word "consent". The wording of the FRBP 7008(a) statement and the core/non-core designation are not verified against any filing and are the author's responsibility.
6. **Standing Order 2026-1 cover sheet (B1040)** is not generated; see LAMB-FILE-001. It is needed with every original complaint on or after March 1, 2026.
7. **Caveat on the source.** The local rules were read from the court's 2022 PDF (amended January 1, 2022). A search result mentions Standing Order 2024-2, which amends LR 4001-1(f) and points to LR 9013-5 for proposed orders. Other amendments after 2022 were not checked against the court's current posting, because the court site is blocked from this box. Check the current rules before relying on this template.
8. **Overlay.** Cannot run without an exemplar. `OVERLAY-*` is not produced.
