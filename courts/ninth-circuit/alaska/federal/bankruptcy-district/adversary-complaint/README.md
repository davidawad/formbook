# United States Bankruptcy Court, D. Alaska (akb): adversary complaint

Doc type: **adversary-complaint** (complaint commencing an adversary proceeding, FRBP 7001). Court: United States Bankruptcy Court for the District of Alaska. Folder: `courts/ninth-circuit/alaska/federal/bankruptcy-district/adversary-complaint/`.

Status: exemplar=yes, render=ok, overlay=ok, pages reviewed 3 of 3. Nothing here sets `status` in `court.json`.

## Governing rules

Sources: the District of Alaska Local Bankruptcy Rules, "LOCAL BANKRUPTCY RULES, DISTRICT OF ALASKA (12/2024)", https://www.akb.uscourts.gov/sites/akb/files/2024%20-%20Local%20Bankruptcy%20Rules.pdf (text extracted with `pdftotext -layout`; fetched 2026-10-14; the court's website says its PDF is the official text). Federal rules: Fed. R. Bankr. P. 7008, 7010, 9004 as restyled (2024 amendment, effective Dec. 1, 2024), from the Legal Information Institute (https://www.law.cornell.edu/rules/frbp/rule_7008, `rule_7010`, `rule_9004`; fetched 2026-10-14). Fed. R. Civ. P. 10(b) is applied through FRBP 7010 (its text is not re-fetched here). Official Form 416D is named in LBR 9004-1(c)(1); its layout is approximated, not reproduced.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| AKB-ADV-001 | FRBP 7010 | Fed. R. Civ. P. 10 applies; the caption must substantially conform to Official Form 416 (here 416D, LBR 9004-1(c)(1)). | caption (`caption()`), court title |
| AKB-ADV-002 | FRBP 9004(a) | Legible. | whole document (Typst text, Times New Roman) |
| AKB-ADV-003 | FRBP 9004(b); LBR 9004-1(c)(1) | Caption sets out the court's name, the case title, the case number and the adversary number, and the document's title. | `court-title()`, `caption()` (case numbers beside the parties), `title-block()` |
| AKB-ADV-004 | LBR 9004-1(c)(2)(A)-(B) | Attorney name, address, telephone and e-mail, at the top left, starting at least 1 inch from the top edge, then the party represented. | `counsel-block()`; top margin 1 in |
| AKB-ADV-005 | LBR 9004-1(a)(1) | Letter size, white paper. | `page-w`, `page-h` |
| AKB-ADV-006 | LBR 9004-1(a)(2) | Margin of at least 1 inch on all four sides. | `margin = 1in` |
| AKB-ADV-007 | LBR 9004-1(a)(4) | Double-spaced or 1.5-spaced; quotations over 50 words single-spaced and indented. | `body-leading` (24 pt pitch); quote `show` rule |
| AKB-ADV-008 | LBR 9004-1(a)(5) | Each page numbered at the bottom. | `footer-page` |
| AKB-ADV-009 | LBR 9004-1(a)(7) | 12-point or 10-pitch type. No typeface is named. | `type-size = 12pt`; `font-family = ("Times New Roman", "Liberation Serif")` |
| AKB-ADV-010 | LBR 9004-1(a)(9) | Names typed beneath signatures. | `signature-block()` (`/s/` line, then the name typed beneath) |
| AKB-ADV-011 | FRBP 7008(a) (as restyled 2024) | The allegation of jurisdiction names the case, its number and Code chapter, and the district and division. | sample content (Background and jurisdiction paragraphs); not enforced by the template |
| AKB-ADV-012 | FRBP 7008(a); LBR 7012-1 | The complaint states whether the pleader does or does not consent to entry of final orders or judgment by the Bankruptcy Court. | `consent-block()`: an assertion fails the render when `consent` is missing from the frontmatter |
| AKB-ADV-013 | LBR 7003-1(a)-(b) | Filed with a completed summons for each defendant, the filing fee if required, and (if filed conventionally) Form 1040. | not part of this document; not generated (see gaps) |

Not used, and why: LBR 7001-1 (applies D. Alaska Civil L.R. 7.1 etc. in adversary proceedings; no content rule for a complaint's form); LBR 7004-1 (service on debtor's attorney, a service matter); the pleading-paper line numbers of N.D. Cal. (LBR 9004-1 does not require them). No certificate of service or proposed order is generated: neither is required for an adversary complaint by the rules cited here.

## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: Complaint for Avoidance and Recovery of Payments, Adv. Proc. No. 18-90016, filed May 14, 2018 by the Chapter 7 Trustee's counsel. 3 pages, text layer present. Only one exemplar (see gaps).
- Provenance, searches and caveats: `usage/SOURCE.md`.

## Sample

- `usage/INPUT-adversary-complaint.md`: transcription of the whole filing: attorney block, caption (debtor, plaintiff, defendants; case numbers), title and subtitle, lead-in, all 11 allegations under 3 headings (I, II, III.A), the table (Table 3.2), the request for relief (A.-D.), the signature block.
- Frontmatter follows the field contract of the cand samples (`counsel`, `caption.parties`, `brief_title`, `lead_in`, `signature`). New fields for this court: `brief_subtitle`, `consent`, `date` (optional).
- Two things are not transcription: (1) the `consent` value, a placeholder `Plaintiff [does / does not] consent ...` added because the filing has no consent statement and the template requires one; (2) the Typst output prints the placeholder text, so the sample PDF is not a finished filing. An author must replace it.
- The template numbers the allegations itself (1, 2, 3 ...). The filing numbers them by section (1, 1.2, 2.1, 3.2); the sample does not reproduce those numbers.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env "tb")
sh tools/render.sh courts/ninth-circuit/alaska/federal/bankruptcy-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/ninth-circuit/alaska/federal/bankruptcy-district/adversary-complaint battley-furie-complaint
```

- `usage/OUTPUT-adversary-complaint.typst.pdf`: 3 pages. typst compiled with no warnings. Fonts: EBGaramond-Regular and EBGaramond-Bold, embedded (vendored only). (The earlier EB Garamond render, before fb-595.68; the committed Times New Roman render is 4 pages.)
- `usage/OVERLAY-battley-furie-complaint.pdf` and `.txt`: red = our render, blue = filed exemplar, black = both. The page pairing is by word overlap: ours p.1 ↔ filed p.1 (77%), p.2 ↔ p.2 (61%), p.3 ↔ p.3 (53%).
- File-name note: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` writes `OVERLAY-<id>.pdf`/`.txt` (repo convention). The brief's `<id>.pdf` and `<id>-overlay.pdf` names are not used, because the shared tools fix these names.
- Line pitch measured with `pdftotext -bbox` on page 2: baselines 90.6, 114.6, 138.6 pt, a 24 pt pitch (double spacing).

## Visual review (rendered at 60 dpi, all 3 pages looked at, on the earlier EB Garamond render)

| Page | What it is | Finding |
|---|---|---|
| 1 | Attorney block, court title, caption (debtor, plaintiff, defendants; Case No. and Adv. Proc. No.), title and subtitle, lead-in, heading I and paragraphs 1-3 | OK after a fix: headings were printing over the preceding lines (heading show rules returned inline content with no block spacing); each heading is now a block with a double line above it. Caption rules and "v." placement OK. |
| 2 | Headings II, III, III.A; paragraphs 4-11; Table 3.2; heading IV; paragraph 12 | OK after the same fix. Table rules thin, header row bold. Paragraph 12 ends the page, the relief items follow on page 3 (a page break inside the relief list, acceptable). |
| 3 | Relief items A.-D., STATEMENT REGARDING CONSENT (placeholder text), signature block | OK. Signature block right of centre, names typed beneath "/s/". Page number at foot. |

Quotation rule tested on a scratch sample (removed afterwards): a block quote renders single-spaced and indented, and unnumbered after a fix (a quote chunk was numbered at first).

Reviewed pages: 3 of 3.

## Known gaps and open choices

1. **Consent statement (AKB-ADV-012).** The filed exemplar has none. The sample's `consent` value is a placeholder that prints `[does / does not]` and a note. A real filing needs the author's choice. **Needs the filing attorney's decision** before the template is used for a real filing.
2. **Counsel e-mail (AKB-ADV-004).** LBR 9004-1(c)(2)(A) (12/2024) lists an e-mail address. The 2018 exemplar has none, so the sample has none. The template does not assert it; add an `e-mail` line to `counsel` for a real filing.
3. **Jurisdiction content (AKB-ADV-011).** FRBP 7008(a) asks the jurisdiction allegation to name the case, its number and Code chapter, and the district and division. The filing states the chapter and number in its Background paragraphs, not in the jurisdiction paragraph, and gives no division. The template cannot check this; it is author content.
4. **Summons and cover sheet (AKB-ADV-013).** LBR 7003-1 requires a summons for each defendant, the fee, and, for a conventional filing, Form 1040. These are separate documents and are not generated.
5. **Caption layout.** An approximation of Official Form 416D (party groups ruled below, "v." between them, numbers beside the parties). Not a reproduction of the form. FRBP 7010 requires "substantially conform".
6. **Font.** Times New Roman at 12 pt, as in the exemplar (`docs/FONTS.md` rule 6, the house standard; the pinned install, Liberation Serif as fallback). The LBR floor is 12 pt or 10 pitch and names no face. Until fb-595.68 the template used EB Garamond (vendored, OFL).

## Typeface (fonts pass, fb-595.7.5)

| Doc type | Face required by the rules | Vendored substitute (typst family) | Fit | Status |
|---|---|---|---|---|
| adversary-complaint | none: LBR 9004-1(a)(7) says "twelve (12) point or ten (10) pitch type" and names no face (text checked 2026-10-14 from the 12/2024 LBR PDF, `pdftotext`) | none; Times New Roman, the house standard (`docs/FONTS.md` rule 6; Liberation Serif fallback). EB Garamond until fb-595.68 | n/a | the exemplar's Times New Roman is the filer's choice, not a rule |

The filed exemplar is set in Times New Roman, but no rule requires it, so the court-named-face substitution (`docs/FONTS.md`) does not apply here. Render check (fb-595.7.5, on the earlier EB Garamond render): `pdffonts` on `usage/OUTPUT-adversary-complaint.typst.pdf` showed `EBGaramond-Regular` and `EBGaramond-Bold`, embedded, and no other face. The committed render embeds `TimesNewRomanPSMT` and `TimesNewRomanPS-BoldMT`.
7. **Paragraph numbering.** The template numbers paragraphs continuously (Fed. R. Civ. P. 10(b)); the filed exemplar numbers by section. The sample's numbers differ from the filing's.
8. **Length.** The exemplar is 3 pages, so the sample is 3 pages; the 8-14 page target applies to longer exemplars and does not apply here.
9. **One exemplar.** The eval-loop tier 2 rule asks for 2 or 3 filings from different filers. Only one adversary complaint from this court was fetched; the other complaints found (Gebhardt v. Aegis 16-90020; Cook Inlet 17-90028, 17-90059) were not reachable in this run (HTTP 202 throttling). Tier 2 is therefore not judged against a second filer.
10. **ECF header** (court-generated) is not reproduced.

## Engines

**docx** (`docx/reference.xml`, from which fb render builds the reference document on the shared cross-engine recipe in the typst face, `base="xengine"`; cover, caption, consent and signature built in `docx/akb.lua`; rendered with `tools/render.sh --engine docx`; checked with LibreOffice 26.8 only, Word not available).

- Matches the typst output: letter size, 1 in margins, Times New Roman 12 pt (`pdffonts` on the committed `.docx.pdf`: TimesNewRomanPSMT and -BoldMT), exact 24 pt double spacing for the body and the relief items, single-spaced counsel block, caption, consent and signature block, a centered page number, numbered allegations 1-12 and lettered relief items A.-D. The LibreOffice PDF was 3 pages, as the typst output was, and all 3 pages of both were viewed at 60 dpi (on the earlier EB Garamond build; the committed renders are 4 pages each).
- Differs (recorded on the earlier build by `docx/build-reference.sh`, before the fb-595.68 cross-engine port; `eval.yaml` now gates the docx on typst's line and page breaks, and the typst headings are now 12 pt too): (1) headings are 12 pt bold in docx; the typst headings render larger (typst's default heading size is kept by its show rules), the LBR asks for 12 pt type, so the docx follows the rule. (2) The Table 3.2 grid is about 5.5 in wide (pandoc's default column grid); the typst table is content-width. (3) Caption spacing is within a few points of typst, not identical. (4) Word may paginate differently; the page count is measured on the LibreOffice PDF only.
- `sh tools/check.sh <doc-dir> --engine docx` does not run on this folder: it needs `court.json`, `checks.yaml` and `reviews/` at the court level, and this folder has none of them (the script exits with errors on `court.json` and `checks.yaml`). No stamp was written. Gates 0-3 are therefore NOT run for docx. BLOCKED: check.sh (all gates, docx): missing court-level `checks.yaml`, `reviews/` and `court.json` in this folder's court.
- No docx BLOCKED item is known from the render itself; the docx opens in LibreOffice without a repair prompt (the conversion succeeded), Word was not tested.
