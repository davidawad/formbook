# cand: answer

Doc type: **answer** in the United States District Court for the Northern District of California (`cand`).
Folder: `courts/ninth-circuit/california/federal/northern-district/answer/`.

Built 2026-10-25 by filling a template gap (dotfiles `legal-writer-core`, "Missing template"): `brief-build
scaffold-template` copied the court's `complaint` template (same pleading paper, layout family `pleading`), then the
answer-specific changes below were made and calibrated against two filed answers from different filers.

| Item | Status |
|---|---|
| exemplars | 2 filers, in `usage/` (`SOURCE.md`): Gordon Rees for Rhombus Power (19 pages) and Wilkinson Stekloff / O'Melveny for Paramount Skydance and Warner Bros. Discovery (39 pages); found with `legal-writer exemplar-search` (free RECAP copies) |
| sample md | `usage/INPUT-answer.md`: a portion of exemplar 1 (pages 1 to 3, the jury demand response, the first five defenses, the prayer, the signature) |
| render | typst `usage/OUTPUT-answer.typst.pdf`, 5 pages; docx `usage/OUTPUT-answer.docx` (+ `.docx.pdf`), 5 pages |
| checks | typst `RESULT: 8 checks passed, 0 failed`; docx `RESULT: 12 checks passed, 0 failed` (2026-10-26, macOS LibreOffice, after the shared no-break hyphen fix); XENG-003 (every typst line breaks after the same word in docx) passes |
| pages reviewed | pages 1 and 4 of the typst render viewed against exemplar 1 pages 1 and 9 |

## What differs from the complaint template

| Change | Why (exemplars) |
|---|---|
| The body starts on page 1, on the numbered line after the one below the caption (no page break after the cover) | Both exemplars start the lead-in on page 1 under the caption |
| `caption_lines`: plain lines under the title in the caption's right column (e.g. `Complaint Filed: July 17, 2026`, the judge) | Exemplar 1 (Complaint Filed); common in N.D. Cal. answers |
| Numbered paragraphs (responses to the complaint's paragraphs, same numbers) stop at the first level-1 heading containing "affirmative defenses", "jury" or "prayer"; paragraphs after it are unnumbered with a first-line indent | Exemplar 1 numbers responses 1 to 108 and leaves the jury response, the defenses and the prayer unnumbered |
| Defense headings: level-2 headings (`## FIRST DEFENSE`, `## (Failure to State a Claim)`), centered bold | Exemplar 1 |
| Prayer items numbered `1.`, `2.` (the complaint letters them) | Exemplar 1 |
| docx: a list that ends the paper keeps every item with the signature block, as typst's sticky list block does | XENG-003 |

## Governing rules

Same paper and first-page rules as the complaint template (see `../complaint/README.md`, fetched 2026-10-14): Civil
L.R. 3-4(a)(1), (a)(3), (c)(1)-(3). For an answer also:

| Rule | Requirement | Where it is |
|---|---|---|
| Fed. R. Civ. P. 8(b) | Admit or deny each allegation; lack of knowledge has the effect of a denial; a partial denial admits the rest | Author content, one numbered response per complaint paragraph |
| Fed. R. Civ. P. 8(c) | Affirmative defenses must be stated | `# AFFIRMATIVE DEFENSES` section, unnumbered |
| Fed. R. Civ. P. 10(b) | Numbered paragraphs | `allegations()` numbers responses until the defenses |
| Fed. R. Civ. P. 12(a) | Time to answer (21 days after service; 60 if service was waived) | Not a template matter |
| Civil L.R. 3-6 | Jury demand in the caption after the title when a party demands one | `jury_demand: true`, as in the complaint template |

## Known gaps

1. **DEF-FONT-002 on docx (fixed 2026-10-26)**: LibreOffice embedded `LinuxLibertineG` on every page because
   `lib/docx/xengine.lua` held a hyphen before a digit with Word's `<w:noBreakHyphen/>`, which LibreOffice draws as
   U+2011, a glyph Times New Roman lacks. The filter now writes a hyphen and a word joiner (U+2060) instead.
2. **Lead-in line**: exemplar 1 starts the lead-in on line 18 after a taller caption; ours on line 16 because the
   sample caption is shorter. Tier 3.
3. **Defense sub-headings**: exemplar 1 sets the parenthetical sub-heading bold like the defense title; both are
   bold here. Exemplar 2 runs defenses as numbered paragraphs instead; one filer's style (tier 3).
4. **No certificate of service**: ECF filing serves registered users (Civil L.R. 5-1); add one in the body when a
   party must be served otherwise.
5. Tier 2 was judged against exemplar 1 page by page for pages 1 and 4 only; exemplar 2 was read for structure.
