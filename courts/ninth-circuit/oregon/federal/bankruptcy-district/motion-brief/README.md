# orb: motion-brief

Doc type: **motion with memorandum** (FRBP 9013; here, a motion in an adversary proceeding) in the United States Bankruptcy Court for the District of Oregon (`orb`).
Folder: `courts/ninth-circuit/oregon/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`). It is a motion with its argument in the body, not a separate memorandum. |
| sample md | `usage/INPUT-motion-brief.md` (transcription of the full 5-page filing, plus the rule-mandated notice; see Known gaps) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, 5 pages each, the same lines and pages (XENG gated), vendored Times New Roman only, no warnings (2026-10-22) |
| overlay | ok: `usage/OVERLAY-sheehy-motion.pdf` and `OVERLAY-sheehy-motion.txt` |
| pages reviewed | 5 of 5 on each engine (`reviews/2026-10-22.md`) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`INPUT-<id>.md`, `OUTPUT-<id>.pdf`, `OVERLAY-<id>.pdf/.txt`), not the `<id>.md` names in the brief.

## Governing rules

Primary source: Local Bankruptcy Rules of the District of Oregon, "LBR.120125 clean" (effective 2025-12-01), https://www.orb.uscourts.gov/sites/orb/files/documents/local_rules/LBR.120125%20clean.pdf, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| LBR 9004-1(a)(1)-(2) | Letter size; type at least 12 pt or 10 cpi; margins at least 1 inch top and bottom, 3/4 inch sides. | `page-w`, `page-h`, `type-size`, `margin-top`, `margin-bottom`, `margin-side`. |
| LBR 9004-1(a)(1)(B) (typeface) | Type size only; no typeface is named in the local rules (checked 2026-10-15 against the fetched LBR text). | Face required: none. Template face: Times New Roman (vendored, the house face), typst and docx alike. |
| LBR 9004-1(a)(4)(A) | Body double-spaced. | `pitch-body` (24 pt line boxes at 12 pt). |
| LBR 9004-1(a)(9)(A), (D) | Counsel block single-spaced upper left; title and page number in the lower-left margin. | `lines(meta.counsel)`; `page-footer()`. |
| LBR 9004-2(c) | Adversary caption (see the complaint README for the layout). | `court-title()`, `caption()`. |
| LBR 9013-1(b)(1) | The motion's title names the parties against whom relief is requested. | `brief_title` in the sample, which names ETC and the ECF 9 order. The template does not check it. |
| LBR 9013-1(b)(2) | A notice of motion precedes the substantive motion, in the form the rule sets (objection period; clerk's addresses). | `notice` frontmatter, rendered before the body. The sample's text follows the rule's form with the 14-day period from LBR 9013-1(c)(1)(A). |
| LBR 9013-1(c)(1)(A) | Objection period: 14 days after service, unless a rule sets another. | The notice text. |
| LBR 7007-1(a)(1) | The first paragraph of an adversary motion certifies a good-faith conferral (or another listed basis). | Not in the sample: the exemplar has none, and the wording depends on facts the exemplar does not state. The template does not check it (see Known gaps). |
| LBR 7007-1(b)(1)(C)-(D) | A brief (argument) not over 20 pages, exclusive of exhibits, unless leave is granted. | Not checked by the template; the sample is 5 pages. |
| LBR 9004-1(a)(9)(B) | The filer's OSB number. | `counsel` and `signature` in the sample. |

Not verified in this run: FRCP 60(b) and FRBP 9024, as cited by the exemplar (not fetched).

## Layout

- Page 1: counsel block, court title, the ruled caption (debtor block | case number; parties | adversary number, title, hearing lines if `hearing` is set), then the body after a blank double line, as in the filed motion.
- Notice (LBR 9013-1(b)(2)) before the body, from `notice`.
- The cross-engine layout model (`lib/typst/xengine.typ`, replacing `word-compat`): 24 pt body line boxes, 13.8 pt single lines, headings at the type size on the body pitch, explicit spaces between blocks.
- Body: headings (level 1 centered bold caps for BACKGROUND, LEGAL STANDARD, ARGUMENT, CONCLUSION; level 2 bold for argument headings); paragraphs are not numbered (a motion does not number its paragraphs); a chunk starting `- `, `* `, or `1. ` is a list lettered 1., 2., ...; a chunk starting `~ ` is a paragraph without the first-line indent (used for bullets in the Legal Standard).
- Signature block 3 in from the margin, after the date line; the last chunk is kept with it.
- Certificate of service on its own page, from `certificate` (its chunks are rendered like the body).

## Markdown contract (for samples)

- YAML frontmatter: `counsel`, `caption`, `case_number`, `adv_number`, `brief_title`, `footer_title`, optional `notice`, `date`, `signature`, optional `certificate`.
- Body: `#`, `##`, `###` headings; paragraphs (unnumbered); lists (numbered 1., 2., ...); `~ ` for an unindented paragraph.
- Not supported: tables, footnotes, raw typst.

## Overlay

`tools/overlay.sh` paired sample pages 1-5 with exemplar pages 1-5 in order (`OVERLAY-sheehy-motion.txt`). The overlay is a diagnostic, not a score.

## Known gaps and open choices

1. **One exemplar, not a memorandum.** The exemplar is a Rule 60(b) motion with its argument in the body; it has no separate memorandum, and it is the only filed motion of this kind that could be retrieved from CourtListener's RECAP for this court (search of `court=orb`, 2025-2026). Tier-2 judgment against two or three filers is not done.
2. **The sample adds the LBR 9013-1(b)(2) notice.** The exemplar has no notice paragraph. The notice text is the rule's form (no facts), so it is added and the overlay shows it red-only. The exemplar's omission is a deviation from the rule, recorded here, not a template choice.
3. **No LBR 7007-1(a)(1) prefiling certification.** The exemplar has none. The wording depends on facts (whether and how the parties conferred), so the sample does not add one. A real filing in an adversary proceeding needs it; the template renders it if it is written into the body's first paragraph, but does not check for it.
4. **Caption wording.** LBR 9004-2(c) uses "Case No."; the exemplar's caption reads "Originating Case No." The template uses the rule's wording.
5. **Font, footer size, caption form** as in the complaint README (Times New Roman, the house face, as the local rule names none; footer at 12 pt; the caption ruled as both filed examples, not LBR 9004-2(c)'s ")" column).
6. **Tool checks.** `tools/check.sh <this folder>` and `--engine docx` run every gate (0 failed; XENG-001..003 gated in `eval.yaml`). `tools/check-selftest.sh` takes a court root with `checks.yaml` and does not run here.
7. **Latex** is not built for this doc type.

## Review of the rendered pages

`reviews/2026-10-22.md` (5 of 5 pages, typst and docx).

## Engines

**docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt, Body Text in exact 24 pt lines, single lines 13.8 pt; "Body Flush" for the `~` paragraphs, "Body Numbered" with a tab to 1 in for list items) and `docx/orb-motion.lua` with `docx/lib/orb-common.lua` (the same file as the complaint's): the cover and the ruled caption, the notice, the body, the signature block, the certificate of service on its own page, the footer (the title in capitals and "Page N of M") and the section. No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh` and `render.sh`). Output: `usage/OUTPUT-motion-brief.docx` and `.docx.pdf`, 5 pages, every line and page as typst (XENG-001..003 gated).

- Not verified in Word (LibreOffice only); it opens and converts without a repair prompt.
