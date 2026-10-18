# laed: complaint

Doc type: **complaint** in the United States District Court for the Eastern District of Louisiana (`laed`).
Folder: `courts/fifth-circuit/louisiana/federal/eastern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/SAMPLE-laed-complaint-buckles226cv01954.pdf` (one filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-laed-complaint-buckles.md` (a portion of the 21-page filing; see known gap 7) |
| render | ok: `usage/OUTPUT-laed-complaint-buckles.typst.pdf`, 10 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `usage/OVERLAY-buckles-complaint.pdf` and `OVERLAY-buckles-complaint.txt` (page map; re-run 2026-10-14 against a copy of the exemplar fetched from the URL in `usage/SOURCE.md`, not committed) |
| typeface | Rule names no face (LR 10.1 "standard font"). EB Garamond kept, per `docs/FONTS.md` ("No face named"). Not metric-compatible with the exemplar's Times New Roman; see known gap 1. |
| pages reviewed | 10 of 10 (every page rendered at 60 dpi and viewed in its final state; re-checked 2026-10-14 after the fonts pass, no change to the template) |

## Governing rules

Primary sources, fetched 2026-10-14:

- E.D. La. Local Civil Rules, text from https://www.laed.uscourts.gov/sites/default/files/local_rules/2022%20CIVIL%20RULES%20LAED%20w%20Amendment%202%204%2025.pdf (linked from https://www.laed.uscourts.gov/attorney-information/rules-and-orders/local-rules). LR 10.1 and LR 9.2 read in full; LR 7 read in full (see the motion-brief README).
- Federal Rules of Civil Procedure, from the Cornell LII pages (https://www.law.cornell.edu/rules/frcp/rule_10, `rule_8`, `rule_5`, `rule_7`, `rule_12`). Rule 10(a) and (b) read from their opening sentences; Rule 8(a) read as its lead-in; Rule 5(b)(2)(E) read as an excerpt.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LR 10.1 (form) | 8-1/2 x 11 inch; double spaced, except quotations and footnotes; "standard font"; sequential page numbers beginning with "2" on the second page; no print in the margins except page numbers; page numbers at least 1/2 inch from the bottom; margins at least 1 inch. | `margin`, `footer-descent`, `body-leading` (24 pt pitch at 12 pt), the `footer` (number from page 2), `font-family`. |
| LR 10.1 (caption) | The caption shows the Division and Section (as applicable), and the judge and magistrate judge to whom the case is assigned. | `caption()`: `civil_action_no`, `section`, `judge`, `magistrate` in the frontmatter; a blank line for each field the sample leaves empty (an unassigned complaint). |
| FRCP 10(a) | Caption: court name, title, file number, and the Rule 7(a) designation; the complaint's title names all the parties. | `court-title()` (court name is the court's own), `caption()`, `title` and `caption` frontmatter. The template does not check that the title names all parties. |
| FRCP 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Body paragraphs are numbered by the template (`numbered-para`). A paragraph marked `!` is not numbered (lead-in, prayer lead-in, jury demand). |
| FRCP 8(a) | A short and plain statement of the grounds for jurisdiction, of the claim, and of the relief sought. | Content, not template. The template does not check it. |
| LR 9.2 (last paragraph) | "Complaints submitted for filing must be on forms furnished by the clerk or substantially similar to those forms." | **Not applied.** The sentence sits under LR 9.2 (Social Security complaints). See known gap 5. |

Not produced by this template (separate filings that may be required with a first complaint): the civil cover sheet (LR 10.1, last paragraph), the summons, and any Rule 7.1 disclosure statement.

## Layout

- Court title centered and bold on the first page; caption in a grid (party column with a right and bottom rule, case fields on the right); title centered and bold; `JURY TRIAL DEMANDED` under the title when `jury_demand: true`.
- Body double spaced (24 pt pitch), first-line indent 0.5 in, headings centered bold (level 1), bold (level 2) and bold italic (level 3), no paragraph spacing beyond one line.
- Numbered paragraphs: the number, a tab, then the text at the first-line indent. Lettered prayer items (`A.`, `B.`, ...) hang from the indent; the author types the letter.
- Class definitions, and any other single-spaced indented quotation, are block quotations (`>`), unnumbered.
- Signature block on the right half of the page (`sig-indent`), "Dated" on the left; each counsel group is single spaced.
- Page numbers from page 2 (LR 10.1).

## Markdown contract (for samples)

A sample is one `.md` file: a YAML frontmatter block, then the body.

Frontmatter:

| Field | Type | Meaning |
|---|---|---|
| `civil_action_no`, `section`, `judge`, `magistrate` | string, optional | Caption fields. Leave `""` for an unassigned complaint; the template draws a blank. |
| `caption` | list of `{names, designation}` | Party sides. `names` are printed one per line (inline markdown allowed, e.g. `*et al.*`); `designation` (for example `Plaintiff,`) is printed under them; "v." is inserted between sides. |
| `title` | string | The title of the paper (printed bold and centered; write it in capitals). |
| `jury_demand` | boolean, optional | Prints `JURY TRIAL DEMANDED` under the title. |
| `date` | string, optional | Printed as `Dated: ...` on the left of the signature block. |
| `signature` | list of `{names, lines}` | Counsel groups. The first group sits under "Respectfully submitted,". Put the `/s/` line first in `names`. |

Body:

- `# Heading` is level 1 (centered bold). `## Heading` is level 2 (bold). `### Heading` is level 3 (bold italic). Type the heading as the filing does, including any "A." label; the template does not number headings.
- A paragraph is numbered by the template. Do not type the number.
- A paragraph starting with `! ` is not numbered (`! Pursuant to Federal Rule ...`).
- A paragraph starting `A. ` or `(a) ` is a lettered item (hanging indent); the author types the label.
- A paragraph starting `> ` is an unnumbered, single-spaced, indented block quotation.
- Case names and other emphasis: `*Horne v. Flores*`. Lists (`-`, `1.`) are not used by this template.
- No tables, footnotes, or raw typst. No forced line breaks: each line of a stack is its own block.

## Overlay (`usage/OVERLAY-buckles-complaint.pdf`)

Red is our render, blue is the filed exemplar, black is where they agree. Pages are paired by word overlap, not by index (`tools/overlay.sh`). The page map in `OVERLAY-buckles-complaint.txt`:

```
ours p.1  filed p.1   ours p.6  filed p.10
ours p.2  filed p.2   ours p.7  filed p.12
ours p.3  filed p.4   ours p.8  filed p.13
ours p.4  filed p.6   ours p.9  filed p.14
ours p.5  filed p.9   ours p.10 filed p.21
```

The pairing is loose after page 3 because the sample skips filed pages (the breach-notification and data-security sections, and the third to fifth claims). The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **Font.** LR 10.1 requires a "standard font" and names no face. Under `docs/FONTS.md` ("No face named"), the template keeps EB Garamond. The filed exemplar is Times New Roman 12 pt, a filer's choice the rule does not require. Liberation Serif (metric-compatible with Times New Roman) is vendored, so the switch is available. EB Garamond at 12 pt has a smaller x-height than Times, so the text looks smaller than the exemplar. The 12 pt size satisfies the rules' "standard font" requirement as far as the rule goes. **Question for David:** keep EB Garamond (current), or switch this doc type to Liberation Serif to match the exemplar's look? Until then this is a tier-2 difference.
2. **Point size.** LR 10.1 sets no point size. 12 pt is used, as in the exemplar.
3. **One exemplar.** The brief asks for one exemplar per doc type. A second E.D. La. complaint, *Rivers-Roberts v. Hurricane Message, LLC*, No. 2:26-cv-01259 (Doc. 1, filed 2026-06-11, 26 pages, text layer present), was checked and not saved: the file is 67 MB, over the snapshot size limit. Tier 2 is therefore judged against one filer. The Rivers-Roberts caption has no Section or magistrate line, which is one more data point on the caption (gap 4).
4. **Caption fields.** LR 10.1 requires the Section and the judge and magistrate. The exemplar shows neither a Section line nor a magistrate line. The template draws labelled blanks for an unassigned case, as LR 10.1 asks, so the tier-2 difference from the exemplar is a deliberate choice.
5. **LR 9.2, last paragraph** (complaints "must be on forms furnished by the clerk or substantially similar to those forms"). The sentence sits under the Social Security rule. It is read here as not applying to a general civil complaint, which is how the exemplar was filed. **Question for David:** confirm that reading. If it applies, the template needs the clerk's form.
6. **Not produced:** the civil cover sheet (JS-44 / LR 10.1), the summons, and any Rule 7.1 disclosure. These are separate filings.
7. **Sample is a portion.** `INPUT-laed-complaint-buckles.md` transcribes the cover and caption, the introduction, parties, jurisdiction, factual background (parts A and B only), class allegations, tolling, the first and second claims, the prayer, the jury demand and the signature. It omits the breach-notification and data-security parts of the facts (filed ¶¶ 31 to 37) and the third to fifth claims. The template numbers from 1, so the numbers do not match the filed ones: our ¶ 23 is the start of filed ¶ 38, and our ¶¶ 24 to 29 are filed ¶¶ 39 to 44.
8. **Output and overlay names.** `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf` and `OVERLAY-<id>.txt`. The brief named them `<id>.pdf` and `<id>-overlay.pdf`; the tools were not edited, so the tool names are used.
9. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`. This doc-type folder has neither, and the brief forbids editing `tools/`. Render and overlay ran; the Gate 2 review is the page review below, not a check stamp.
10. **Caption rule box.** The party column is closed by a right and a bottom rule, not by a column of ")" marks as in some filings. This is a convention (both forms are seen), recorded as accepted.
11. **Headings are typed by the author** (no automatic "A.", "B."). This keeps the sample faithful to the filing; it means a sample must type its own letters.

## Review of the rendered pages (final state)

| Page | What was checked | Result |
|---|---|---|
| 1 | Court title, caption (blank case fields), title, jury demand legend, the unnumbered lead-in, numbered paragraphs 1 to 4. No page number. | Pass. |
| 2 | Numbered paragraphs 5 to 9, PARTIES and JURISDICTION AND VENUE headings, page number "2". | Pass. |
| 3 | Numbered paragraphs 10 to 18, FACTUAL BACKGROUND, the level-2 "A." heading. | Pass. |
| 4 | Paragraphs 19 to 24, level-2 "B." heading, CLASS ALLEGATIONS, the two class-definition quotations (single spaced, indented). | Pass. |
| 5 | Paragraphs 24 (continued) to 27 (numerosity, commonality, typicality, adequacy). | Pass. |
| 6 | Paragraphs 28 to 31 (predominance, superiority), TOLLING heading and the tolling paragraphs. | Pass. |
| 7 | Paragraphs 32 to 37, CLAIMS FOR RELIEF, FIRST CLAIM FOR RELIEF (bold), "Negligence" (bold italic). | Pass. |
| 8 | Paragraphs 38 to 44; SECOND CLAIM FOR RELIEF and its heading, "Negligence Per Se". No heading at the foot of a page. | Pass. |
| 9 | Paragraphs 45 to 49; PRAYER FOR RELIEF heading; unnumbered "WHEREFORE" lead-in; prayer items A to C. | Pass. |
| 10 | Prayer items D to I; DEMAND FOR JURY TRIAL (unnumbered); "Dated" on the left and "Respectfully submitted," on the right; signature groups single spaced; firm name on one line. | Pass. |

## Engines

Typst is the primary engine. The DOCX engine is `docx/`: `build-reference.sh` makes `reference.docx` from pandoc's default, `laed-complaint.lua` is the filter, and `render.sh` runs pandoc (`tools/render-docx.sh` calls it). Output: `usage/OUTPUT-laed-complaint-buckles.docx`. The LibreOffice PDF, `usage/OUTPUT-buckles-complaint.docx.pdf`, was not produced (see BLOCKED).

| Engine | Status |
|---|---|
| typst | the render above; tier-1 form per LR 10.1 |
| latex | not built |
| docx | `.docx` built; read back with pandoc and every XML part well-formed. `.docx.pdf` BLOCKED. Not viewed. |

**What the DOCX form sets** (from the reference and the filter; no page has been looked at): letter page, 1 in margins; EB Garamond 12 pt, the same vendored face as typst; 24 pt exact line pitch (double spacing); 0.5 in first-line indent; page number centered 0.6 in from the bottom edge, none on page 1; the caption as a borderless table, the party column closed by a right and a bottom rule, the case fields on the right; title bold and centered; headings centered bold, bold and bold italic; numbered paragraphs, with the number typed as text as typst does; unnumbered `!` paragraphs; lettered items with a hanging indent; single-spaced block quotations indented 0.5 in on each side; the signature block with "Dated" on the left and "Respectfully submitted," at 3 in.

**Differences and open checks**

- No page of the `.docx` has been rendered or compared with the typst pages (0 of 10 reviewed). The spacing around the caption, the quotations and the signature block is set from the typst values and not tuned against a render.
- A paragraph number is followed by a tab to the next default tab stop (1.0 in). Typst puts the text 0.25 in after the number, so the text can start a few points to the right of the typst position.
- Word and LibreOffice may paginate differently (DOCX.md, "Known limits"). The page count and the page numbers must be checked in the LibreOffice PDF.

**docx BLOCKED items**

- `docx.pdf`, Gates 0 and 1 and the page review: BLOCKED. The LibreOffice 25.2 build unpacked from Debian trixie debs (no root here) aborts at startup with `com::sun::star::uno::DeploymentException`: the extracted packages have no `libdeploymentlo.so`. No PDF was produced, so no check ran. Unblock: install LibreOffice so it runs on this box, then `sh tools/render.sh --engine docx <this folder> usage/INPUT-laed-complaint-buckles.md`.
- `tools/check.sh --engine docx`: not run. It needs `court.json` and `rules.md` in the folder (known gap 9). The check stamp `usage/.check-docx.txt` was not written.
- The LibreOffice conversion needs EB Garamond visible to fontconfig. `fonts/eb-garamond/` is vendored for typst; install it for the user running the check (DOCX.md, "Fonts").

[Formbook index](../../../../../README.md) | [Status table](../../../../../STATUS.md)
