# wvnd: complaint

Doc type: **complaint** in the United States District Court for the Northern District of West Virginia (`wvnd`).
Folder: `courts/fourth-circuit/west-virginia/federal/northern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-heston-1-26-cv-00092-complaint.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-heston-complaint.md` (a portion of the 36-page filing; see below) |
| render | ok: `samples/OUTPUT-heston-complaint.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-heston-complaint.pdf` and `samples/OVERLAY-heston-complaint.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |
| tier-1 gate | none asserted by a local rule for this paper; see "Governing rules" and the open question below |

File names follow the repo's file-role convention, which `tools/render.sh` and `tools/overlay.sh` require: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf`, the comparison `OVERLAY-<id>.pdf` and `.txt`. The brief's `<id>.md` and `<id>-overlay.pdf` names would have needed changes to the tools, which are out of scope for this box.

## Governing rules

Primary sources: the Federal Rules of Civil Procedure (Cornell LII text, fetched 2026-10-14) and the Local Rules of the Northern District of West Virginia (the 2018 compilation, the PDF the court's own site links as its current local rules, `https://www.wvnd.uscourts.gov/sites/wvnd/files/NDWV%20Local%20Rules%202018%20MASTER.pdf%20with%20appendix.pdf`, fetched and text-extracted 2026-10-14). The court's site lists one later civil amendment (LR Gen P 2.01 and LR Civ P 7.10 and 7.20, effective December 1, 2022); it does not touch the rules cited here.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 8(a)(1)–(3) (`https://www.law.cornell.edu/rules/frcp/rule_8`, verified 2026-10-14) | A short and plain statement of the grounds for jurisdiction, of the claim, and a demand for relief. | Content of the sample (the template does not check the wording). |
| Fed. R. Civ. P. 10(a) (`https://www.law.cornell.edu/rules/frcp/rule_10`, verified 2026-10-14) | A caption with the court's name, a title, a file number, and the Rule 7(a) designation; the title names all parties. | `caption()`: court title, parties, "Civil Action No." from `case_number`, the title from `title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Every chunk that is not a heading, a lettered list or a `~` paragraph is numbered by `allegation` through the whole complaint. |
| Fed. R. Civ. P. 10(c) | Adoption by reference. | Not enforced; the sample's "incorporates paragraphs 1 through 182" is content. |
| Fed. R. Civ. P. 11(a) (`https://www.law.cornell.edu/rules/frcp/rule_11`, verified 2026-10-14) | Signed by an attorney of record in the attorney's name; the paper states the signer's address, e-mail and telephone. | `signature-block()` asserts an e-mail address and a telephone number in the signature lines. |
| Fed. R. Civ. P. 38(b) | A jury demand. | Body text (the sample's last paragraph). The template does not add it. |
| LR Gen P 5.03(c) (2018 compilation) | Attorney signature in the form "s/ (attorney name)"; "s/" alone is insufficient. | `signature-block()` prints "s/ " followed by `signature.signer`. The exemplar prints "/s/"; the rule's text governs. |
| LR Civ P 7.02(a) (2018 compilation) | Memoranda only: 8½ × 11 paper, one-inch margins, Times New Roman, Courier New or Arial at 12 point proportional, double spaced. | Not required of a complaint. The page follows it as the court's standard for papers: one-inch margins, 12 point, double spaced, page number centered in the bottom margin. Font: see known gaps. |
| LR Gen P 5.06(e) (2018 compilation) | A certificate of service "is required for all filings." | Not produced for the complaint: the initial pleading is served with the summons (Fed. R. Civ. P. 4), and the exemplar has none. See the open question below. |

Not produced by this template (separate papers, not part of the complaint): the civil cover sheet (JS-44); the corporate-disclosure statement under LR Gen P 2.01 and LR Civ P 7.10 (the court's form, filed through CM/ECF); the summons (LR Gen P 5.06(c): prepared in paper by the plaintiff).

## Layout

- Court title centered on the first lines (the exemplar's lines 1–2), then the caption: the parties in a single-spaced left column, "v." between the sides, a rule under the caption, and "Civil Action No." with the judge on the right.
- Title "COMPLAINT" centered and bold, then the unnumbered lead-in paragraph.
- Body double spaced (24 pt pitch at 12 pt), first-line indent 0.5 inch on numbered paragraphs, one-inch margins on all four sides, page number centered in the bottom margin.
- Headings: level 1 is centered bold caps; level 2 is centered bold; level 3 is bold italic at the left. A heading never stands at the foot of a page (`sticky`).
- Prayer items are a markdown list and are lettered (a), (b), ... with a hanging indent.
- Signature block after the last paragraph: "Dated:" at the left; the party, "By Counsel," the "s/" line and the counsel lines at the middle of the page, single spaced.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Body chunks are separated by blank lines.
- `# Heading` (level 1), `## Heading` (level 2) and `### Heading` (level 3) are headings.
- A paragraph is numbered by the template. Do not type a number at its start: a line starting `1. ` is a lettered-list item, not a paragraph.
- A paragraph starting `~ ` (tilde and a space) is unnumbered, for the introduction and for notes outside the allegations. The `~` is removed before it is rendered.
- A list of lines each starting `N. ` in one chunk (no blank lines between items) is a lettered list: (a), (b), ...
- Inline markdown: `*italic*` for case names and signals, `[text](url)`, smart punctuation. Not supported: tables, footnotes (none are needed here), raw typst.
- Frontmatter: `case_number` (required), `judge` (optional), `caption` (list of `{names, designation}`, required), `title` (required), `lead_in` (optional), `signature` (required: `date`, `party`, `signer`, `lines`; the lines must include an e-mail address and a telephone number, or the build fails).

## What the sample is (and is not)

`samples/INPUT-heston-complaint.md` transcribes the caption, the lead-in, the introduction, the jurisdiction and venue paragraphs, the parties, the first part of the facts (the interrogation, the North Marion meeting), Count I's first five paragraphs, the prayer, the jury demand and the signature block. The filing's paragraphs 25–40 and 68–182 are not transcribed; the sample says so in brackets. Paragraph numbers in the sample are assigned by the template and do not match the filing, so the sample's "paragraphs 1 through 182" in Count I refers to the filing's numbering, as the exemplar's own text does.

## Known gaps and open choices

1. **Typeface.** No local rule names a typeface for a complaint. The page uses EB Garamond (vendored in `fonts/`), the only serif font in the repo. LR Civ P 7.02(a) names Times New Roman, Courier New or Arial for memoranda, and the exemplar is set in Times New Roman. Neither is vendored here, and `fonts/` is outside this task. OPEN, a question for David: vendor a Times-metric face (for example Liberation Serif, SIL OFL) or accept EB Garamond. EB Garamond at 12 point has a smaller x-height than Times at 12 point, so the text looks smaller than the exemplar.
2. **Certificate of service for an initial complaint (LR Gen P 5.06(e)).** The rule says "required for all filings." The exemplar has none, and an initial complaint is served with the summons. The template does not produce one. OPEN, a question for David: does the court require one on the complaint itself? If it does, `certificate()` in the motion-brief template can be copied in.
3. **One exemplar only.** The brief asks for one filing per doc type. Other N.D. W. Va. complaints with text layers were found and not saved: Organon LLC v. Mylan Pharmaceuticals Inc., 1:26-cv-00112 (35 pages, patent complaint); The Cincinnati Insurance Company v. Classic Antiques & Primitives, 1:26-cv-00111 (15 pages); Novo Nordisk Inc. v. Viatris Inc., 1:26-cv-00100 (36 pages). Tier-2 conventions are therefore judged against one filer, not two or three.
4. **Caption.** The caption is a plain left column with a rule beneath, as in the exemplar. The "Judge:" line is printed when `judge` is given.
5. **Sample is a portion.** The 8-page output covers the transcribed portion of the 36-page filing.
6. **Italics are inferred.** The exemplar's text layer carries no italics; case names in the sample are italicized by convention, not by the filing.

## Review of the rendered pages (current PDF, all 8 pages viewed)

- Page 1: court title, caption (plaintiff, "v.", defendants, Civil Action No. and Judge on the right), rule, "COMPLAINT", lead-in, introduction starts. No overlap; the two-line caption entries do not collide. Pass.
- Page 2: introduction ends, "JURISDICTION AND VENUE", paragraphs 1–6 numbered on the grid. Pass.
- Page 3: "PARTIES" centered bold, paragraphs 7–19. Pass.
- Page 4: paragraphs 20–30; "INTERROGATIONS OF THE SUPERINTENDENT" centered; the bracketed note on the filing's omitted paragraphs. Pass.
- Page 5: paragraphs 31–39; the two-line centered heading "THE CONCEALED NORTH MARION MEETING…"; no heading at the foot of the page. Pass.
- Page 6: paragraphs 40–50. Pass.
- Page 7: "COUNT I…" heading (three lines, centered), "(Against the Marion County Board of Education)", paragraphs 51–55, "PRAYER FOR RELIEF", items (a) and (b). Pass.
- Page 8: items (c)–(h), "DEMAND FOR JURY TRIAL", the jury demand, the date and the signature block (party, "By Counsel,", "s/ Ryan J. Umina", counsel lines with e-mail and telephone). Pass.

Overlay (`samples/OVERLAY-heston-complaint.txt`): page pairing by shared words. Pages 1–2 pair with the same filed pages (72.9% and 63.3% word overlap). Pages 3–8 pair with later filed pages because the sample skips filed paragraphs; the pairing is a diagnostic, not a score.
