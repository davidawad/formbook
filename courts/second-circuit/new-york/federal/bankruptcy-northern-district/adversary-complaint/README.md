# nynb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Northern District of New York (`nynb`).
Folder: `courts/second-circuit/new-york/federal/bankruptcy-northern-district/adversary-complaint/`.

**BLOCKED: no exemplar.** No public filed N.D.N.Y. adversary complaint could be retrieved; the searches are recorded in
`exemplars/SOURCE.md`. The template is built from the rules. Tier 2 (professional convention, judged against 2 or 3
filed exemplars from different filers) therefore **cannot be judged** for this doc type. Tier 1 (the rules) is judged
below against the primary sources, not against a filing.

| Item | Status |
|---|---|
| exemplar | **no** (`exemplars/SOURCE.md` records the searches and the one docket that lists a complaint without a linked PDF) |
| sample md | `samples/INPUT-rule-derived-adversary-complaint.md`: **rule-derived and fictional**, not a transcription of any filing. Frontmatter contract below. |
| render | ok: `samples/OUTPUT-rule-derived-adversary-complaint.pdf`, 10 pages, letter, EB Garamond only (embedded, Regular and Bold), `tools/render.sh` exit 0, no typst warnings |
| overlay | **fail**: `tools/overlay.sh` exits 1 with "no exemplar pdf in exemplars" (there is no filed PDF to overlay). No `OVERLAY-` file was written. |
| pages reviewed | 10 of 10, each rendered at 60 dpi and viewed. Pages 1 to 3 were viewed before the last change, which only moves the prayer for relief and its lead-in (pages 9 and 10) and so cannot reach them. |

File names: the sample is `INPUT-rule-derived-adversary-complaint.md` (not `INPUT-<id>.md`) because it is not an input transcribed
from a filing. `tools/render.sh` and `tools/overlay.sh` use the repo's default `OUTPUT-<id>.pdf` name, so that is the name
used here, not the `<id>.pdf` the wave brief listed.

## Markdown contract (frontmatter)

The sample starts with a YAML block. The template reads these keys:

| Key | Meaning |
|---|---|
| `counsel` | list of lines, single-spaced, top left of page 1 (optional) |
| `debtor.names`, `debtor.tin` | the debtor under "In re:"; `tin` is printed as written (LBR 9004-1(c) allows only the last four digits, which the author must supply) |
| `case_number`, `chapter` | right column of the bankruptcy caption |
| `hearing` | not used by the complaint (the motion uses it) |
| `adversary.number`, `adversary.parties[]` | the adversary caption: `names` (list) and `designation` per party; `v.` is inserted between parties |
| `title` | centred bold title of the paper, here `ADVERSARY COMPLAINT` |
| `dated`, `signature.firm`, `signature.signer`, `signature.lines` | the date and signature block |

Body: blank-line-separated chunks. `#` is a centred bold heading, `##` a bold heading flush left. A chunk before the first
heading is an unnumbered preamble. Every other chunk is a numbered paragraph (FRCP 10(b) via FRBP 7010). A chunk starting
`(a) ` is an unnumbered prayer item. A numbered paragraph that leads into a `(a)` item sticks to it.

## Governing rules

Primary sources, fetched 2026-10-14 (the date verified for every row).

| Rule | Requirement | Kind | Where it is in the template |
|---|---|---|---|
| LBR 9004-1(a)(1)(A) (N.D.N.Y. Local Bankruptcy Rules, effective 12-01-2024, https://www.nynb.uscourts.gov/sites/nynb/files/LBR_GenOrders/Local%20Bankruptcy%20Rules_Effective%2012-01-2024%20Final.pdf; text extracted with pdftotext) | Text, in the body or a footnote, is a minimum of 12-point font | M | `type-size = 12pt`, set on the page for the whole document |
| LBR 9004-1(a)(1)(B) | Double-spaced, except block quotations and footnotes may be single-spaced | M | `pitch = 24pt`, `body-leading = 1.35em` (0.65em line box + 1.35em = 2.0em = 24 pt; the leading after each unit is added by hand) |
| LBR 9004-1(a)(1)(C)-(E) | Legible, single-sided, black ink | M | Output is a single-sided black-ink PDF; not a template choice |
| LBR 9004-1(a)(2)(A) | One-inch margin on all four sides | M | `margin = 1in` |
| LBR 9004-1(a)(2)(B) | Consecutively numbered pages | M | `numbering: "1"`, centred at the foot, on every page including page 1 |
| LBR 9004-1(a)(2)(C) | Letter size, 8½ × 11 | M | `paper: "us-letter"`; the PDF is 612 × 792 pt |
| LBR 9004-1(c) | Caption: court name, case title, case number and chapter, last four SSN/TIN digits only, the adversary name and number if pertinent, and a short title naming the document and the party filing it | M | `bankruptcy-caption`, `adversary-caption`; the SSN/TIN digits and the short title come from the sample |
| LBR 9004-1(d) | The court may decline a document that does not comply | M (consequence) | n/a |
| LBR 7003-1 | An Adversary Proceeding Cover Sheet is required for every adversary filed in CM/ECF or on paper | A (author) | not rendered: a separate form (the court's fillable cover sheet) |
| FRBP 9004(a) (Cornell LII, https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14) | A document must be clearly legible | M | as LBR 9004-1 |
| FRBP 9004(b) (same) | Caption: court's name, the case's title, the case number and adversary number, and a brief designation of the document | M | `title` line and both captions |
| FRBP 7001 (adversary proceeding; the sample cites 7001(1) and (6)) | Categories of adversary proceedings | content, A | in the sample text only |
| FRBP 7003 (Cornell, fetched 2026-10-14) | "Fed. R. Civ. P. 3 applies in an adversary proceeding" | content, A | sample's commencement by complaint |
| FRBP 7008(a) (Cornell, fetched 2026-10-14) | "Fed. R. Civ. P. 8 applies"; the jurisdiction allegation refers to the bankruptcy case by name, number and chapter; the complaint states whether the pleader consents to final orders by the bankruptcy court | M (content) | the sample pleads these in "Jurisdiction and venue" (the template does not check the wording) |
| FRBP 7010 (Cornell, fetched 2026-10-14) | "Fed. R. Civ. P. 10 applies"; the caption substantially conforms to Official Form 416A | M (caption) | caption layout follows Official Form 416A's structure as the rules describe it; Form 416A's text was not fetched (the uscourts.gov page returned 404) |
| FRCP 10(b) (via FRBP 7010) | Numbered paragraphs, each limited as far as practicable to a single set of circumstances | M (form) | numbering in `body-content` |

Rows marked M are the tier-1 requirements. Rows marked C would be convention and need an exemplar to judge; none is
claimed as convention here. Layout choices the rules leave open are: counsel block placement, the two-part caption
(bankruptcy caption above, adversary caption below, each with rules along the bottom and right edge of the party column), the centred `ADVERSARY COMPLAINT`
title, the heading styles, left-aligned text, and the page-number position. These are tier 2 by default and unjudged
until an exemplar exists.

## What the overlay shows

Nothing. There is no filed exemplar to overlay, so `tools/overlay.sh` cannot run (exit 1). The overlay is a tier-3
diagnostic in any case and is not a score.

## Known gaps

- **No exemplar, so tier 2 is unjudged.** The caption layout, heading hierarchy, counsel block and signature layout are our
  choices, not checked against a filed complaint from this court.
- **Judges' individual practices are not checked.** The LBR text found contains no page limit for a complaint; any judge's
  individual procedures are the author's responsibility.
- **Not rendered, author responsibility:** the Adversary Proceeding Cover Sheet (LBR 7003-1), the summons (LBR 7004-1),
  the redaction of personal identifiers beyond the caption (the rules on privacy protection are not in this template),
  and the signer's Bar Roll number (the sample has a placeholder).
- **No gate checks.** There is no `checks.yaml` for this doc type, so `tools/check.sh` is not wired here and no stamp exists.
  Gates 0 and 1 are not run; this is a rule-derived template, not a court under the eval loop.
- **Pleading paper is not used.** LBR 9004-1 does not require numbered lines, so the template has none (the cand complaint
  uses line numbers because N.D. Cal. requires them).
- **Footnotes are not exercised** by the sample. The rule (12-point, single-spaced allowed) is stated but no footnote is
  rendered, so the footnote style is untested.
- **Typeface.** LBR 9004-1 sets a minimum size, not a typeface. EB Garamond is our choice, vendored in `fonts/`.
