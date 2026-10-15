# utd: complaint

Doc type: **complaint** (complaint and jury demand, FRCP 8 and 10) in the United States District Court for the District of Utah (`utd`).
Folder: `courts/tenth-circuit/utah/federal/district/complaint/`. Self-contained: exemplar, sample, template and review are in this folder.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-fastre-1-26-cv-00060-complaint.pdf` (15 pages, text layer; `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-fastre-complaint.md` (abridged transcription of the exemplar, see Known gaps) |
| render | ok: `samples/OUTPUT-fastre-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`) |
| typeface | face required: **none** (DUCivR 10-1(3) names no typeface; checked against the December 2023 text, 2026-10-15). Substitute: none needed. Font: **EB Garamond** kept (`docs/FONTS.md`: a court naming no face keeps EB Garamond). Not metric-compatible with any Times; not applicable here. |
| overlay | ok: `samples/OVERLAY-fastre-complaint.pdf` and `samples/OVERLAY-fastre-complaint.txt` (`tools/overlay.sh`, exemplar passed as the third argument: see Render and overlay) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last template change; re-rendered and re-viewed 2026-10-15 in the fonts pass, no change to the template) |

File names. The brief names outputs `<id>.pdf` and `<id>-overlay.pdf`. `tools/render.sh`, `tools/overlay.sh` and the court-folder convention (`CLAUDE.md`) name them `INPUT-<id>.md` → `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`. The tools were used as they are; `<id>` is `fastre-complaint`.

## Governing rules

Primary source: D. Utah Local Civil Rules, December 2023 edition, https://www.utd.uscourts.gov/sites/utd/files/Civil%20Rules%20Final%202023.pdf, fetched and read 2026-10-14. That PDF is the newest civil-rules edition I found (a December 2021 edition also exists, superseded). The rule text quoted below is from that PDF. Federal rules: Fed. R. Civ. P. 5(d)(1)(B), 8(a), 10(a)–(b), 38(b), from https://www.law.cornell.edu/rules/frcp/rule_8 (and rule_5, rule_10, rule_38), fetched 2026-10-14.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| DUCivR 10-1(1) | Paper and margins | 8½ × 11 inch; top margin at least 1½ inches; remaining margins at least 1 inch. | `margins` (top 1.5 in, others 1 in) in `typst/utd-complaint.typ` |
| DUCivR 10-1(3) | Font and size | Clearly legible; minimum 12 point, including footnotes. No typeface named in the text. | `type-size = 13pt`, `font-family = EB Garamond` |
| DUCivR 10-1(4) | Spacing | Text double-spaced, except block quotes and footnotes. | `line-pitch = 26pt` (measured baseline pitch 25.94 pt), `body-leading` |
| DUCivR 10-1(5) | Pagination | Document pages numbered consecutively. | `numbering: "1"` on every page, cover included |
| DUCivR 10-1(6)(A) | Contact information | Upper left, above the caption: counsel's name and bar number, firm, address, telephone, email, party represented. | `counsel` and `counsel_role` frontmatter, `counsel-block()` |
| DUCivR 10-1(6)(B) | Caption table | Names of parties, title of the document, case number, assigned judge and referred magistrate judge if applicable. | `caption`, `brief_title`, `case_number`, `judge`, `magistrate` in `caption-table()` |
| DUCivR 10-1(7) | Jury demand | "JURY DEMANDED" in capitals in the caption of the initial pleading, immediately below the title. | `jury_demand: true` → "JURY DEMANDED" under the title in the caption |
| DUCivR 10-1(8) | Signatures | Every document signed by counsel; electronic signature allowed. | `signature-block()`: "DATED this …", "By: /s/", name, "Attorneys for …" |
| Fed. R. Civ. P. 10(a) | Caption | Court name, title, file number, Rule 7(a) designation. | Court title, title, case number, "Plaintiffs," / "Defendants." designations |
| Fed. R. Civ. P. 10(b) | Numbered paragraphs | Each claim or defense in numbered paragraphs. | `allegations()`: each allegation is numbered by the template (1, 2, …) |
| Fed. R. Civ. P. 8(a) | Short plain statement | Grounds for jurisdiction; a short and plain statement of the claim; a demand for relief. | Content of the sample (the template does not check content) |
| Fed. R. Civ. P. 38(b) | Jury demand | Written demand, served and filed. | "Jury Demand" section at the end of the body (not numbered) |

Not produced by this template (separate filings or documents, not part of the complaint): civil cover sheet (JS-44), summons, the Rule 7.1 disclosure statement, and any proposed order. FRCP 5(d)(1)(B) excuses a certificate of service for a paper filed through the court's electronic-filing system, so none is generated.

## Layout

- Page 1 (cover): counsel block single-spaced at the upper left; court title centred; caption table (party column with a right and bottom rule; right column with title, "JURY DEMANDED", case number, judge). The caption fits on page 1 for the sample's counsel and defendant list (checked on the render).
- Body: double-spaced, first-line indent 0.5 in. Numbered paragraphs (1, 2, …) with the number at the indent. Headings: level 1 centred bold capitals (PARTIES, JURISDICTION AND VENUE, GENERAL ALLEGATIONS, PRAYER FOR RELIEF, JURY DEMAND); level 2 centred bold (cause-of-action headings); level 3 bold, left (sub-headings under GENERAL ALLEGATIONS). A heading keeps a full line of space above and below and stays with the paragraph after it.
- Prayer: the lead-in ("Plaintiffs pray …") is unnumbered; items are numbered 1., 2., …
- Signature: "DATED this …" at left; "Respectfully submitted," firm name and the signing block at right; kept on the page with the last paragraph (see Known gaps for the rule that forces this).
- No pleading paper (no line numbers, no rules down the margin). DUCivR 10-1 does not require numbered lines; the exemplar has none.

## Markdown contract (for samples)

- YAML frontmatter. Fields: `case_number`, `court` (lines), `division` (optional), `counsel` (lines), `counsel_role`, `caption` (list of `{names, designation}`; "v." is inserted between sides), `brief_title`, `jury_demand` (true/false), `judge` (optional), `magistrate` (optional), `lead_in` (optional, unnumbered lead-in paragraph), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. `#` = level 1, `##` = level 2, `###` = level 3 headings. A list (`1.`, `-`) is not numbered. A paragraph is numbered unless it is under a heading whose text contains "Prayer" or "Jury Demand", or it introduces a list (the next chunk is a list).
- The sample does not type numbers: the template numbers the allegations. Cross-references to paragraph numbers must not be typed in the text.
- Not supported: tables, footnotes, raw typst.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/tenth-circuit/utah/federal/district/complaint samples/INPUT-fastre-complaint.md
sh tools/overlay.sh courts/tenth-circuit/utah/federal/district/complaint fastre-complaint /path/to/exemplar.pdf
```

The exemplar PDF is not in the checkout (only `exemplars/SOURCE.md` is). On 2026-10-15 the overlay ran against the RECAP copy at the SOURCE.md URL, fetched to a temp directory and passed as the third argument; its page count (15) matches the SOURCE.md. Without the argument, `overlay.sh` looks for `exemplars/*.pdf`.

`OVERLAY-fastre-complaint.pdf` is the red/blue test: red = our render, blue = the filed exemplar, black = both. `OVERLAY-fastre-complaint.txt` is the page map. `overlay.sh` pairs each render page with the exemplar page that shares the most words (its page map is coarse, see below). The overlay is a diagnostic, not a score.

Overlay map: ours pp. 1–7 ↔ filed pp. 1–7 (word overlap 70–95%); ours p. 8 ↔ filed p. 15 (58%); ours p. 9 ↔ filed p. 15 (20%). Pages 8–9 pair with the exemplar's last page because the sample skips exemplar pp. 8–14 (see Known gaps), so the low overlap there is expected.

## Visual review (Gate 2 record, all 9 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Cover: counsel block, court title, caption (whole party list), JURY DEMANDED, case no., judge | OK. Caption fits on the page (a previous build spilled "Defendants." to page 2; fixed by widening the party column and tightening single spacing). |
| 2 | Lead-in, PARTIES, ¶¶ 1–6 | OK. Numbers at indent, text double-spaced. |
| 3 | ¶¶ 7–14, JURISDICTION AND VENUE, GENERAL ALLEGATIONS, first sub-heading | OK. Heading has space above and below. |
| 4 | ¶¶ 15–25 | OK. |
| 5 | ¶¶ 26–38, sub-heading "Hans Exhibits Obvious Symptoms …" | OK. |
| 6 | ¶¶ 39–45, sub-heading "The Jail's Delayed Response and Lifesaving Efforts" | OK. |
| 7 | ¶¶ 46–52, FIRST CAUSE OF ACTION (three heading lines) | OK. |
| 8 | ¶ 53, PRAYER FOR RELIEF with items 1–8, JURY DEMAND heading | OK. Prayer items numbered, lead-in unnumbered. |
| 9 | JURY DEMAND paragraph (unnumbered), DATED, signature block | OK. Signature stays with the jury-demand paragraph (was orphaned on its own page before the keep-with-signature rule). |

Pages reviewed: 9 of 9.

## Known gaps and open choices

1. **Abridged sample.** The sample transcribes exemplar ¶¶ 1–53, the first cause of action's heading and ¶¶ 52–53, the prayer and the jury demand. Omitted: exemplar ¶¶ 54–105 (the rest of the Monell count, the individual-liability count against the jail staff, and the detail of ¶¶ 54–85). The render is 9 pages against the exemplar's 15, within the 8–14 target.
2. **One exemplar.** Tier 2 asks for two or three filers. Alternates were found and recorded in `exemplars/SOURCE.md` (Keller v. Danford, The Preserve v. Kamas City, Owen v. State of Utah Legislative Services). Not run as a second-filer comparison.
3. **Typeface.** DUCivR 10-1(3) names no typeface (checked 2026-10-15), so `docs/FONTS.md` keeps the template on EB Garamond, at 13 pt so that the visible size is close to Times 12 pt. The filed exemplar embeds TimesNewRoman (and Arial); that is one filer's choice that the rule leaves open, not a requirement. Whether the clerk convention is Times (which would mean Liberation Serif, the metric-compatible substitute in `fonts/`) is a question for David.
4. **Type size.** 13 pt is a style choice above the 12-point minimum. The complaint template has no footnote styling and the sample has no footnotes, so the footnote minimum (DUCivR 10-1(3)) is not tested. If a footnote is added, check that it renders at 12 pt or larger.
5. **Caption separator.** The template inserts "v." between sides; the exemplar uses "vs.". Utah filings use both; the template keeps one form.
6. **Title.** The exemplar title is "COMPLAINT AND DEMAND FOR JURY TRIAL". The template prints "COMPLAINT" with "JURY DEMANDED" under it, as DUCivR 10-1(7) asks. The sample therefore carries the rule's form, not the exemplar's title line. A filer who keeps the long title should also keep the jury demand line.
7. **Judge and case number.** Blank in the sample, as filed (the case was not yet assigned a judge's initials at the time of filing). The template prints "Judge ____" only when `judge` is given.
8. **Keep-with-signature.** The template keeps the last plain paragraph with the signature block, so a signature never stands alone. A last list (the prayer) is not kept with the signature; in that case the signature may stand alone. Not seen in this sample.
9. **Sub-heading styling.** The exemplar's sub-headings are bold at the left margin (template: level 3). Its cause-of-action title lines are centred (template: level 2). Both are conventions, not rule text.
10. **Not checked by the template.** Content requirements of FRCP 8(a) (jurisdiction, claim, demand) and the accuracy of cited statutes. Local-rule compliance of exhibits (DUCivR 10-1 exhibits paragraph) is not generated.
11. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, which this doc-type folder does not have; the brief forbids editing `tools/`. Render and overlay were run; the review above is the Gate 2 record for this doc type.
