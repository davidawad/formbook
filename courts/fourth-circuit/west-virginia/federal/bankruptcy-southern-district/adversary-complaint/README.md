# S.D. W. Va. Bankruptcy Court (wvsb): adversary complaint

Doc type: **adversary complaint** (FRBP 7001 adversary proceeding; FRBP 7010 applies FRCP 10 and requires the caption to conform to Official Form 416). Court: United States Bankruptcy Court for the Southern District of West Virginia. Folder: `courts/fourth-circuit/west-virginia/federal/bankruptcy-southern-district/adversary-complaint/`.

Status: exemplar=yes (one, with caveats below), render=ok, overlay=ok, pages reviewed 12 of 12. Nothing here sets `court.json` status.

## Governing rules

Dates are the date each text was read (2026-10-14). Federal rule text comes from Cornell LII (current text, "eff. Dec. 1, 2024" restyling). The local rules are the court's 2012 edition (`wvsb.uscourts.gov/sites/wvsb/files/localrules.pdf`, 138 pp.). I could not confirm that it is the current edition; see gap 5.

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| WVSB-FORM-001 | FRBP 9004(a) (eff. 12/1/2024, verified) | "A petition, pleading, schedule, or other document must be clearly legible." No paper-size rule found. | `typst` page `us-letter` (convention) |
| WVSB-FORM-002 | None found (FRBP 9004; S.D. W. Va. local rules 2012 ed., full text searched 2026-10-14 for typeface, font and point size: none) | No typeface or point size is set by rule, so the template keeps EB Garamond, 13 pt (`docs/FONTS.md`: "No face named"). A style choice. Vendored in `fonts/eb-garamond/`. | `font-family`, `type-size` |
| WVSB-FORM-003 | None found | Double spacing, as in the exemplar. Convention. | `line-pitch` = 24 pt |
| WVSB-FORM-004 | None found | 1-inch margins, as in the exemplar. Convention. | `margins` |
| WVSB-CAP-001 | FRBP 9004(b)(1)-(4) (verified) | Caption states the court's name, the case title, the case number and adversary-proceeding number, and a brief designation of the document. | `court`, `caption`, `case_info`, `title` |
| WVSB-CAP-002 | FRCP 10(a), via FRBP 7010 (verified) | Caption has the court's name, a title, a file number, and a Rule 7(a) designation. The title names all parties. | `caption` sides; `title` |
| WVSB-CAP-003 | FRBP 7010 (verified: caption "must substantially conform to the appropriate version of Form 416") | Form 416 text not fetched. The template follows the exemplar's full caption (debtor, plaintiffs, defendants; adversary number on the right). | `caption`, `case_info` |
| WVSB-CMP-001 | FRCP 10(b), via FRBP 7010 (verified) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Sample numbers typed and escaped (`1\.`) |
| WVSB-CMP-002 | FRCP 10(b) (verified) | Each claim founded on a separate transaction or occurrence is stated in a separate count (where it promotes clarity). | Count headings in sample (level 2) |
| WVSB-CMP-003 | FRBP 7008(a) (verified: the allegation of jurisdiction "must include a reference to the name, number, and Code chapter of the case ... and the district and division where it is pending") | Jurisdiction allegation names the case. **The exemplar does not meet this** (¶¶ 12–13 cite statutes only; the case appears in ¶ 11 and the caption). Not enforced by the template. | Sample as filed; gap 2 |
| WVSB-CMP-004 | FRBP 7008(a) (verified: "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court") | Required consent statement. **The exemplar does not state it.** The template requires a `consent:` key and fails without it. The sample carries a bracketed placeholder for counsel. | `consent` (template, before the signature) |
| WVSB-CMP-005 | FRBP 9011(a) (verified, eff. 12/1/2024): signed by an attorney of record; "must state the signer's address and telephone number" | Signature block with each signer's address and telephone. | `signature.blocks` |
| WVSB-CMP-006 | LR 9011-4 (2012 ed.; cites the ECF procedures) | Electronic signature: a scanned image, or `/s/` followed by the typed name. | `signature.blocks` (`/s/` lines in sample) |
| WVSB-CMP-007 | LR 7003-1 (2012 ed.) | A complaint filed on paper needs the Adversary Proceeding Cover Sheet (Form B104). Electronic filings do not. | Not generated (separate form). Gap 4. |
| WVSB-CMP-008 | LR 7004-2 (2012 ed.) | The Clerk issues the summons; the plaintiff does not draft it. | Not generated. |
| WVSB-CMP-009 | FRCP 10(c), via FRBP 7010 (verified) | An exhibit to a pleading is part of the pleading. | Not used in this sample. |
| — | FRBP 7001 (verified, eff. 12/1/2024) | Lists which proceedings are adversary proceedings, items (a)–(j). Classification only; the template does not check it. | — |
| — | FRBP 7003 (verified, eff. 12/1/2024) | "Fed. R. Civ. P. 3 applies in an adversary proceeding" (commencement). | — |

Not used, and why: the Blackjewel Procedures Order (Bankr. S.D. W. Va., 2020, in the main case) requires a Notice of Hearing as the first page of every motion. It is a case order, not a court rule, and it does not apply to complaints. It is not applied to any doc type here (gap 6).

## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: 23 pages, Doc. 334 in *In re Blackjewel, L.L.C., et al.*, Case No. 3:19-bk-30289 (Bankr. S.D. W. Va.), filed July 25, 2019 by plaintiffs' counsel (Petsonk PLLC; Mountain State Justice, Inc.). Text layer present (`pdftotext` reads it).
- Provenance, caveats and the searches tried are in `usage/SOURCE.md`. The caveat that matters: the complaint is captioned as an adversary complaint but is docketed in the main case, and it is the only adversary-style complaint from this court found.

## Sample

- `usage/INPUT-adversary-complaint.md`: transcribed from the exemplar. Caption, counsel block, opening paragraph, ¶¶ 1–43 (parties, jurisdiction, facts), Counts I and II, the prayer (¶ 112), and the signature blocks. Footnote 1 (the debtors) is the caption footnote. Counts III–VI (¶¶ 68–111) are not transcribed, so the prayer's numbering jumps from 67 to 112 and its item e refers to Count VIII, which is not in the sample. This is deliberate, to stay in the 8–14 page target.
- The `consent:` line is a placeholder (gap 1). The exemplar has no consent statement.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/fourth-circuit/west-virginia/federal/bankruptcy-southern-district/adversary-complaint
sh tools/render.sh $D usage/INPUT-adversary-complaint.md   # -> usage/OUTPUT-adversary-complaint.typst.pdf
sh tools/overlay.sh $D blackjewel-doc334                    # -> usage/OVERLAY-blackjewel-doc334.pdf and .txt
```

- `usage/OUTPUT-adversary-complaint.typst.pdf`: 12 pages. Typst compiled with no warnings (`render.sh` fails on any). Fonts: EBGaramond-Regular, -Bold, -Italic only (embedded).
- File names follow the tools (`OUTPUT-`, `OVERLAY-`), which the brief's `<id>.pdf` and `<id>-overlay.pdf` names differ from. The page map is in `usage/OVERLAY-blackjewel-doc334.txt`.
- Overlay pairing (ours → filed): p.1–2 ↔ 1–2; p.3 ↔ 3; p.4 ↔ 5; p.5 ↔ 6; p.6–7 ↔ 7–8; p.8 ↔ 10; p.9 ↔ 11; p.10 ↔ 12; p.11 ↔ 13; p.12 ↔ 22 (the prayer and signature page of the exemplar). The pairing is by word overlap, so it is coarse. The exemplar's pleading layout is not reproduced, so the two layers do not coincide on text lines. It is a diagnostic, not a score.

## Visual review (Gate 2 record: all 12 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtors, plaintiffs, v., defendants), adversary number, title, opening paragraph, debtors footnote | OK. The caption table draws a rule on the right and bottom of the left column. |
| 2 | Opening paragraph (cont.), ¶¶ 1–3, PARTIES | OK. |
| 3 | ¶¶ 3–9 | OK. |
| 4 | ¶¶ 10–19, JURISDICTION AND VENUE, FACTS (level-3 fact sub-heading) | OK. |
| 5 | ¶¶ 20–29, level-3 sub-heading | OK. The page ends with white space because the next heading moves with its text. |
| 6 | ¶¶ 30–35, two bold sub-headings | OK. |
| 7 | ¶¶ 36–43, lettered sub-paragraphs a–c | OK. |
| 8 | ¶ 43 (sub-paragraphs b–f), ¶¶ 44–48, Count I heading | OK. Count heading centred; statute line in italic. |
| 9 | ¶¶ 49–56, Count II heading | OK. |
| 10 | ¶¶ 56–61, sub-paragraphs a–b | OK. |
| 11 | ¶¶ 62–67, DAMAGES AND RELIEF REQUESTED, ¶ 112 begins | OK. The jump 67 → 112 is the omitted counts, as in the exemplar's numbering. |
| 12 | Prayer a–f, consent placeholder, both counsel blocks | OK. The signature stays with the prayer (two counsel blocks side by side). |

Pages reviewed: 12 of 12. The first version had the signature block alone on page 13; the two counsel blocks were laid side by side to bring it under the prayer. Heading sizes were pinned to body size (Typst's defaults made them larger than the exemplar's).

## Known gaps and open choices

1. **Consent to final orders (WVSB-CMP-004).** The exemplar does not state it, and FRBP 7008(a) requires it. The template refuses to render without a `consent:` value. The sample shows a bracketed placeholder for counsel. **Needs a decision**: whether the plaintiffs consent or not is counsel's, not the template's.
2. **Jurisdiction allegation (WVSB-CMP-003).** The exemplar's jurisdiction paragraph does not name the case number, Code chapter, district and division together, as FRBP 7008(a) requires. The sample keeps the exemplar as filed. The template cannot check the content.
3. **Caption Form 416 text (WVSB-CAP-003).** Form 416 was not fetched (the uscourts.gov URL returned 404). The caption follows the exemplar.
4. **Paper cover sheet (WVSB-CMP-007).** Form B104 is cited by the local rule; I did not check its current official number or text. The template does not generate it, and a paper filing needs it.
5. **Local rules currency.** The 2012 edition is the latest version I could read; the court's current site was not reachable in full. The 1994 "Complete Package" has no format or caption rule either. A newer edition could exist and was not seen.
6. **Notice of Hearing.** The 2020 Blackjewel Procedures Order requires a notice of hearing on the first page of motions. It is case-specific and not applied. Whether a court-wide form requires one was not verified.
7. **Typeface and spacing.** No rule sets a typeface or spacing for this court (FRBP 9004(a) requires only legibility; the local rules say nothing). EB Garamond 13 pt double-spaced is a style choice. The exemplar's filers used Times New Roman and Calibri (`pdffonts`). Judge-specific standing orders were not checked.
8. **Partial transcription.** Counts III–VI and the class allegations (¶¶ 68–111) are omitted for the 8–14 page target. The prayer refers to Count VIII, which is not in the sample.
9. **Single exemplar.** One filed adversary complaint, captioned as an adversary, filed in the main case. The eval-loop rule asks for two or three from different filers before tier 2 is judged; none was found in the searches listed in `usage/SOURCE.md`. Tier 2 is therefore judged against this one exemplar only.
10. **No certificate of service or summons.** A complaint is served with a summons issued by the Clerk (LR 7004-2), which the template does not generate.

## Engines

**docx** (`docx/`): declarative `reference.xml` uses shared xengine styles and inherits `{font}` from Typst; `wvsb-adversary-complaint.lua` builds the caption, numbered sections and signature. `fb render --engine docx` creates the DOCX and LibreOffice PDF; tier-1 and cross-engine checks pass.

- Uses the same Times New Roman face as Typst, with matching page and line breaks; tier-1 and cross-engine checks pass.
- Differs: (a) the caption rules are paragraph borders (a right rule on the left-column paragraphs and a bottom rule on an empty paragraph), not a cell border; LibreOffice leaves a small break in the right rule at the "v." line. (b) Between paragraphs the typst output has a single-line pitch (about 17 pt), because `par(spacing: 0pt)` removes the leading there; the docx keeps 24 pt. The docx is therefore longer (14 pages against typst's 12). The typst template was not changed; this is for review. (c) The consent statement and the signature are kept together (keep-with-next), so they move to a new page as one block.
- Reviewed: all 14 docx pages and all 12 typst pages rendered at 60 dpi and looked at.
- BLOCKED: `sh tools/check.sh <folder> --engine docx` cannot run: this folder has no `checks.yaml` (exit 2, `Error: open .../checks.yaml: no such file or directory`), and `court.json` is also not found in the doc-type folder (jq error). No check ID was evaluated, so the gates are unverified for docx.
