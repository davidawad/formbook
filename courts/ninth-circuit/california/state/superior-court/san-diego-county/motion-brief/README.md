# calsuperct-sandiego: motion-brief

Doc type `motion-brief` for the Superior Court of California, County of San Diego (alias `calsuperct-sandiego`). A motion (notice and memorandum of points and authorities) on pleading paper. Template: `typst/calsuperct-sandiego-motion-brief.typ`, entry `typst/main.typ`.

**BLOCKED: no exemplar.** No filed San Diego Superior Court motion or memorandum was found, so there is no filed PDF to overlay and no real-world sample to transcribe. The template is built from the rules alone (below), and the sample is **synthetic**. `overlay=fail` is the expected result, not a bug: `tools/overlay.sh` has no exemplar to compare against.

## Searches tried (all before building the template)

1. `People v. Sun Healthcare complaint San Diego Superior Court filed pdf` (standard): no San Diego filing under that name. Sun Healthcare matters are in other venues (San Mateo, 2001 and 2005).
2. `San Diego Superior Court motion pleading paper pdf "Superior Court of California, County of San Diego" memorandum of points and authorities filed` (standard): only general guidance and other counties' materials. No filed San Diego pleading.
3. Extended search: `"County of San Diego" "Superior Court" memorandum of points and authorities in support of motion pdf Sweetwater OR "Attorney General" ... 25CU033612N`: returned San Diego demurrer, opposition and motion practice guides (smartrules.com, San Diego Law Library), not filings. Nothing under case 25CU033612N except the complaint already saved for the `complaint` doc type.
4. https://oag.ca.gov/node/30187 (the AG's page for a 2005 Sweetwater matter): a complaint and a superseding injunction only. Not a motion, and not in this court.

What would settle it: a motion from a San Diego civil case, from the case file of a filer who can share it, or from the court's own eFiling records if public. Any such filing goes in `exemplars/` as `FILED-EXAMPLE-<short-case>-<docket>-motion-brief.pdf`, with `exemplars/SOURCE.md` filled in; the overlay then runs.

## Governing rules

Verified 2026-10-15 unless the row says otherwise.

| Rule | Requirement | Used for | Source |
|---|---|---|---|
| CRC 2.104 | Font size not smaller than 12 points (amended 2017-01-01) | `type-size = 12pt` | https://www.courts.ca.gov/cms/rules/index/two/rule2_104 |
| CRC 2.105 | Font style essentially equivalent to Courier, Times New Roman, or Arial (amended 2017-01-01) | **Liberation Serif** (Times New Roman row of `docs/FONTS.md`) | https://www.courts.ca.gov/cms/rules/index/two/rule2_105 |
| CRC 2.107, 2.108, 2.109, 2.110 | Margins; double-spaced numbered lines; page numbers; footer title ≥10 pt (verified 2026-10-13 by the sibling complaint; not re-fetched today) | the same grid as `../complaint/` | https://www.courts.ca.gov/cms/rules/index/two/rule2_107 (and 2_108, 2_109, 2_110) |
| CRC 2.111(1)-(7) | First-page format: attorney block lines 1-7, court title on line 8, caption, case number, nature of the paper, judge and department (verified 2026-10-15, summarized) | first page | https://www.courts.ca.gov/cms/rules/index/two/rule2_111 |
| CRC 3.1110(b) | First page of each paper states the date, time and place of any scheduled hearing, the hearing judge if ascertainable, the title, the filing date of the action, and the trial date if set (verified 2026-10-15, summarized; amended 2017-01-01) | the caption's `hearing`, `action_filed`, `trial_date` fields | https://www.courts.ca.gov/cms/rules/index/three/rule3_1110 |
| CRC 3.1113(d) | Opening or responding memorandum: no more than 15 pages, except summary judgment and summary adjudication motions (verified 2026-10-15; amended 2017-01-01). The template does not count pages; the limit is a check for the filer. | not enforced by the template | https://www.courts.ca.gov/cms/rules/index/three/rule3_1113 |
| SD Local Rule 2.1.2(H) | Gov. Code § 6103 exempt filer: label top right, above the caption (Local Rules, Division II, effective 1/1/2026) | optional `fee_exempt` | https://www.sdcourt.ca.gov/sites/default/files/sdcourt/generalinformation/localrulesofcourt/division_ii_-_civil_2026.pdf |
| SD Local Rule 2.1.4.1(D) | E-filed documents: PDF, text-searchable | the sample render is text-searchable (verify with `pdftotext`) | same |
| SD Local Rule 2.1.19(A) | A motion must have a hearing date reserved (online system or the judge's calendar clerk) before filing; a motion without a reserved date will not be heard | the `hearing.date` field must be a reserved date | same |

The memorandum's substantive content (CCP, CRC 3.1113 contents) is not checked by this template.

## Layout

The same as `../complaint/`: a 28-line pleading grid, double-spaced, 12 pt Liberation Serif, footer title, attorney block in lines 1-7 (measured at the absolute text width, not 100%, which mis-measures inside `layout()`). The caption's right column prints the hearing block under the nature of the paper: `Date:`, `Time:`, `Dept.:`, `Judge:`, then `Action filed:` and `Trial date:`.

No case-specific text is in the template. No coordinate was measured off an exemplar (there is none).

## Markdown contract

As `../complaint/README.md`, plus:

| Field | Required | Feeds |
|---|---|---|
| `caption.hearing` | yes for a motion | map with `date`, `time`, `dept`, `judge` (CRC 3.1110(b)) |
| `caption.action_filed` | yes | `Action filed:` (CRC 3.1110(b)) |
| `caption.trial_date` | no | `Trial date:` (CRC 3.1110(b)) |

Quote any YAML value containing `: `.

## Sample (synthetic)

`samples/INPUT-synthetic-motion-brief.md`: **synthetic**. Fictional parties (JANE EXAMPLE v. EXAMPLE CORPORATION), fictional counsel (`counsel@example.invalid`), a fictional case number (`SYNTHETIC-0001`), a synthetic department and judge. Its text is placeholder argument. It exists only to exercise the template's first page, headings, body grid and signature. It is not a transcription and must not be read as a real filing.

## Commands

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/california/state/superior-court/san-diego-county/motion-brief samples/INPUT-synthetic-motion-brief.md
sh tools/overlay.sh courts/ninth-circuit/california/state/superior-court/san-diego-county/motion-brief synthetic-motion-brief   # fails: no exemplar (expected)
```

## Results

- **render=ok.** `samples/OUTPUT-synthetic-motion-brief.pdf`, 2 pages, US Letter. typst exit 0, no warnings.
- **overlay=fail (expected).** `tools/overlay.sh` exits 1: "no exemplar pdf in exemplars". Nothing was written.

### Gate 2 review: every page rendered at 60 dpi and looked at

| Page | Finding |
|---|---|
| 1 | Attorney block lines 1-6; court title lines 8-9; caption from line 11; hearing block (Date, Time, Dept., Judge, Action filed, Trial date) in the right column; footer clean. Pass. |
| 2 | Headings: "II. ARGUMENT" centered caps, "A." bold, "1." bold italic; body on the pleading numbers; signature block after the conclusion, "Dated" at left. Pass. |

Open tier-2 items: none can be judged without an exemplar. The template has not been compared against any filed San Diego motion.

## Known gaps

- **No exemplar.** Tier 2 (what a clerk expects) is unjudged. Until a filed San Diego motion is found, the layout rests on the rules and the complaint's grid.
- **Page limit.** CRC 3.1113(d) is a filer's check, not enforced.
- **Hearing reservation.** SD LR 2.1.19(A): the date must be reserved; the template cannot check that.
- **Notice vs memorandum.** A motion packet has a notice of motion, a memorandum, and often a separate statement and declarations. This template produces one paper; a notice of motion is not a separate template here.
- **Latex and docx.** Not built for this doc type.
