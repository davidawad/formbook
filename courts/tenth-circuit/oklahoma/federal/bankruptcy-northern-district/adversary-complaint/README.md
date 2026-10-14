# N.D. Okla. Bankruptcy Court (oknb): adversary complaint

Doc type: **adversary complaint** (complaint commencing an adversary proceeding, FRBP 7001). Court: United States Bankruptcy Court for the Northern District of Oklahoma. Folder: `courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/adversary-complaint/`.

Status: **exemplar=no**, render=ok, overlay=**fail** (not produced: there is no exemplar to overlay), pages reviewed 4 of 4. Nothing here sets a court-level `court.json` status.

BLOCKED: no exemplar. No filed adversary complaint from this court was found after the searches in `exemplars/SOURCE.md`. The template is built from the rules below; the sample is a synthetic transcription-free draft written to those rules.

## Governing rules

Dates: the local rules were read from the PDF on the court's site (version shown on its cover: "Updated March 21, 2025"); the FRBP and FRCP texts were read from Cornell LII on 2026-10-14. Statute and rule references not listed in the table below (11 U.S.C. §§ 101(36), 523(a)(2)(A)-(B), 28 U.S.C. §§ 157, 1334, 1408, 1409, FRBP 4007(c), 7004, 9015, Fed. R. Civ. P. 38-39) were **not re-fetched** this session; they are cited from the author's knowledge and must be checked before this folder is treated as complete.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| OKNB-ADV-001 | Fed. R. Bankr. P. 7001 (https://www.law.cornell.edu/rules/frbp/rule_7001), read 2026-10-14 | A proceeding to determine dischargeability of a debt (7001(6)) is an adversary proceeding, commenced by complaint. | the document type itself |
| OKNB-ADV-002 | Fed. R. Bankr. P. 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008), read 2026-10-14 | The allegation of jurisdiction names the case, its number, its Code chapter, and the district where it is pending. A complaint in an adversary proceeding states whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. | `jurisdiction-md` (generated from `jurisdiction`, `core`) |
| OKNB-ADV-003 | Fed. R. Bankr. P. 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010), read 2026-10-14, with Fed. R. Civ. P. 10(a)-(c) (https://www.law.cornell.edu/rules/frcp/rule_10), read 2026-10-14 | Caption with the court's name, a title, the file number; the title names all parties; claims in numbered paragraphs, each limited as far as practicable to one set of circumstances; a claim founded on a separate transaction goes in a separate count. | `caption`; `allegations` (numbered paragraphs; prayer unnumbered) |
| OKNB-ADV-004 | LBR 9004-1(A) (court's local rules PDF, Updated March 21, 2025) | 8 1/2 x 11 inches; no less than 12-point font including footnotes; margins no less than one inch; one side only; pleadings and briefs double spaced. | `type-size` 13pt; `margin` 1in; `body-leading` 1.35em (2.0em pitch); footnote size = `type-size` |
| OKNB-ADV-005 | LBR 9004-2(A) | Caption: name of the court, title of the case, the bankruptcy case number and adversary number, the chapter number directly under the case number, and a title that describes the nature of the document. | `court-title`, `caption` (Case No., Chapter, Adv. No.), `title-block` |
| OKNB-ADV-006 | LBR 9004-1(C), LBR 9011-1 | Attorney signature block shows full name, state bar number, address, email, telephone, fax if any, and the party represented. | `signature-block` (asserts `bar_number`, `telephone`, `email`) |
| OKNB-ADV-007 | LBR 7010-1 | "Form of pleadings in an adversary proceeding": see LBR 9004-1 and 9004-2. | OKNB-ADV-004, OKNB-ADV-005 |
| OKNB-ADV-008 | LBR 7003-1 | An adversary complaint not filed through ECF is accompanied by an Adversary Proceeding Cover Sheet (Official Form). | **not generated** (see gaps) |
| OKNB-ADV-009 | LBR 7004-2 | The clerk issues the summons after the complaint is filed; the summons is a separate document. | **not generated** (clerk-issued) |

Not used, and why: LBR 7007.1-1 (corporate ownership statement) applies to a corporate party and is a separate form, not part of this document. The prayer and the jury demand are conventions: a jury demand appears only when `jury_demand: true` (FRBP 9015).

## Exemplar

None. See `exemplars/SOURCE.md` for the sources searched (court how-to, govinfo orders, CourtListener blocked to this box, eight WebSearch queries). Tier-2 comparison against 2-3 filers is therefore not possible; tier 2 is judged against the rules only.

## Sample

- `samples/INPUT-adversary-complaint.md` is **synthetic**: fictional parties (Sample Lender, LLC v. John Quincy Example, chapter 7, a dischargeability claim under § 523(a)(2)(A)), fictional numbers (26-10000-R, 26-01000-R). It is not a transcription of any filing. Its frontmatter says so.
- The sample covers the caption, generated jurisdiction paragraphs, parties, facts, one claim, prayer, signature block, and two footnotes. The template generates the jurisdiction section from frontmatter (`jurisdiction`, `core`), so the sample does not repeat it.
- Length: 4 rendered pages. The 8-14 page target applies when an exemplar of that length exists; there is none to match, and a one-count complaint of this kind is short. Not padded.
- Naming: the tools read and write `INPUT-` / `OUTPUT-` / `OVERLAY-` names, so the sample is `INPUT-adversary-complaint.md` and the render is `OUTPUT-adversary-complaint.pdf`, not `<id>.pdf` as the brief's layout said. That follows CLAUDE.md's file-role naming and `tools/overlay.sh`.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/adversary-complaint samples/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district/adversary-complaint adversary-complaint
```

- render: **ok**. `samples/OUTPUT-adversary-complaint.pdf`, 4 pages, 612 x 792 pt. typst emitted no warnings (render.sh fails on any). Fonts: EBGaramond-Regular and -Bold only (`pdffonts`), embedded; nothing from the system.
- Measured: body line pitch 26.00 pt at 13 pt type on page 2 (= 2.0 em, double spacing per LBR 9004-1(A)). Margins 1 inch.
- overlay: **fail**. `tools/overlay.sh` exits 1 with "no exemplar pdf in .../exemplars"; no `OVERLAY-adversary-complaint.pdf` or `.txt` was produced. There is nothing for the red/blue test to compare against.

## Visual review (Gate 2, all 4 pages rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (In re block, party block, Case No./Chapter/Adv. No.), title, jurisdiction paragraphs 1-4, Parties heading | OK. Caption rules and column widths clean. Headings have a full double-spaced line above and below. |
| 2 | Parties paragraphs 5-6, Facts 7-10 with bullet list, footnote 1 | OK. Bullets, paragraph numbers and footnote separator correct. |
| 3 | Facts 11-13 with footnote 2, First Claim heading and subheading, Count paragraphs 14-16 | OK. Long subheading ("Nondischargeability of Debt Under 11 U.S.C. § 523(a)(2)(A)") is on one line. |
| 4 | Paragraph 17, Prayer for Relief (unnumbered), items (a)-(c), signature block | OK. Prayer paragraph is unnumbered; signature block carries bar number, phone, email and party. |

Defects found and fixed during the build (all in `typst/oknb-adversary-complaint.typ`, none in the sample):

1. Headings overlapped the paragraph after them. EB Garamond's line box is 0.65 em, shorter than its glyphs, so an auto-height heading block sat inside the next paragraph. Fixed by giving heading and title blocks a fixed height of one double-spaced line (`pitch`) and `above: body-leading`.
2. Numbered paragraphs ran together into one paragraph. Fixed by an explicit `parbreak()` after each chunk.
3. Footnote definitions were rendered per chunk and lost. Fixed by attaching each definition to the chunk that references it, and by skipping definition-only chunks so they take no paragraph number.
4. The title was uppercased, which turned `§ 523(a)(2)(A)` into `§ 523(A)(2)(A)`. Title now keeps its case; only level-1 headings are uppercased.
5. The prayer for relief was numbered as paragraph 18. Paragraphs under a "Prayer" heading are now unnumbered.
6. The court name lines overlapped (zero spacing in a stack). Fixed with single spacing.

## Known gaps and open choices

1. **No exemplar** (BLOCKED, above). Tier 2 has no filer to compare against. The layout is rule-driven only.
2. **Adversary cover sheet** (LBR 7003-1) is not generated; it is an Official Form filed with the complaint when the complaint is not filed through ECF.
3. **Summons** (LBR 7004-2) is issued by the clerk; not generated.
4. **Certificate of service:** none. A complaint is served with the summons under FRBP 7004; no certificate is in the rules this template reads.
5. **Font:** EB Garamond (vendored, OFL) at 13 pt, not Times New Roman. 13 pt because EB Garamond sets small at 12; both meet the LBR 9004-1(A) floor. This is a choice; no court-specified font was found.
6. **Caption layout:** the In re block and party block sit in one left column with a rule, and the case-number column on the right. LBR 9004-2(A) fixes what the caption contains, not its layout. A judge's standing order could differ.
7. **Electronic filing:** the court's May 2024 how-to says to print the finished complaint to PDF rather than save the Word file as a PDF, so the document is flattened. The typst output is a flattened PDF.
8. **Core / non-core and consent** (FRBP 7008(a)): generated from `core`. The sample says core under § 157(b)(2)(I) and consent. The author must choose these per complaint; the template does not decide them.
9. **Dischargeability deadline** (FRBP 4007(c)) is a footnote in the sample, not a rule the template enforces.
10. **Jurisdiction paragraphs** cite 28 U.S.C. §§ 1334(b), 157(a), (b)(1), and venue §§ 1408, 1409(a). These are not re-fetched this session (see the governing-rules note).
