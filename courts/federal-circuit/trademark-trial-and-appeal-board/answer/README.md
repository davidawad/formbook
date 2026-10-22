# TTAB: answer and answer with counterclaim (typst + docx)

Doc type `answer` under the Trademark Trial and Appeal Board (`court` ttab): the Board's standard inter partes caption, the answer to a notice of opposition or petition to cancel, an optional counterclaim, the signature block and the certificate of service. Self-contained: the exemplars, the sample, the templates and this README live in this folder; the court root's `typst/` and `usage/` are not touched. Requirements and sources: [../rules.md](../rules.md), section "Doc type: answer". Filed exemplars: [usage/SOURCE.md](usage/SOURCE.md). Loop history: [../LOG.md](../LOG.md). Reviews: [../reviews/](../reviews/).

## Status

| Item | State |
|---|---|
| Exemplars | yes: two filers (Foley Hoag for RStudio, 2010, scanned; Dunlap Bennett & Ludwig for SageForth, 2022, text). See `usage/SOURCE.md` |
| Sample | `usage/INPUT-answer-3.md`: a fictional cancellation answer (every party and fact invented). No `FILED-EXAMPLE` has the same id, so `fb overlay` and `fb diff` have no pair |
| Render (typst) | `just render courts/federal-circuit/trademark-trial-and-appeal-board/answer` writes `usage/OUTPUT-answer-3.typst.pdf` (Times New Roman, or the vendored Liberation Serif with the same metrics) |
| Render (docx) | `sh tools/render.sh --engine docx <this dir> usage/INPUT-answer-3.md` writes `usage/OUTPUT-answer-3.docx` and `.docx.pdf` |
| Check gates (`tools/check.sh`) | typst and docx: 0 failed (`data/checks-default.yaml` with `eval.yaml`) |
| Cross-engine (Gate 4) | gated (`eval.yaml` `params.cross_engine: gate`): the docx breaks every line and page as typst does (XENG-001..003 PASS), on the shared layout model (`lib/typst/xengine.typ`, `lib/docx/xengine.lua`, `lib/docx/xengine-reference.sh`; fb-595.54.6) |
| LaTeX engine | not built |

Both engines name Times New Roman; typst falls back to the vendored Liberation Serif (the same metrics), LibreOffice uses Times New Roman where installed. Pitches: body 27.6 pt (Word double for Times New Roman at 12 pt), single 13.8 pt, exact line boxes in both engines.

`docx/reference.docx` is built by `docx/make-reference.sh` (the shared recipe `lib/docx/xengine-reference.sh`); `docx/ttab-answer.lua` builds the caption, title, signature block and certificate from the frontmatter and numbers the paragraphs.

## Markdown contract

A sample is one markdown file: a YAML frontmatter block, then the body.

```yaml
kind: opposition                  # or: cancellation (changes "Opposition No." to "Cancellation No.")
proceeding_number: "91123456"     # or a placeholder such as "[__________]"
matter:                           # lines above the parties in the caption block
  - "In the matter of Application Serial No. 00000000"
  - "For the mark: EXAMPLE"
  - "Filed: ..."
  - "Published: ..."
plaintiff: { name: "Opposer Name,", role: "Opposer," }
defendant: { name: "Applicant Name,", role: "Applicant." }
title: "APPLICANT’S ANSWER AND AFFIRMATIVE DEFENSES TO NOTICE OF OPPOSITION"
signature:
  date: "..."
  firm: "FIRM NAME"
  esign: "/Name/"                 # 37 CFR 2.193(c): the signer personally enters it
  name: "Attorney Name"
  title: "Attorney for Applicant"
  lines: ["bar number", "address", "telephone", "email"]
service:                          # omit the key to omit the certificate page
  date: "..."
  paper: "title of the paper served"
  method: "email"
  recipients:
    - { name: "Counsel Name", role: "counsel of record for Opposer", lines: ["Firm", "Address"], email: "..." }
  esign: "/Name/"
  name: "Attorney Name"
  title: "Attorney for Applicant"
```

Body: CommonMark.

- `# Heading` is a centered bold heading; `## Heading` bold, left; `### Heading` bold italic, left. No heading numbering.
- Numbered paragraphs are ordered lists with an explicit start (`16. ...`); the number is set at the first-line indent and wrapped lines return to the margin. A list item may continue with further indented paragraphs.
- `> quoted text` is a single-spaced block quotation indented one inch each side.
- `**[CONFORM: ...]**` on a line of its own (bold text beginning "[") is a drafting note: flush left, single-spaced, italic; delete before filing.
- Text that begins with a markdown marker is escaped: `90\. `, `\- `, `2\) `.
- Not supported: tables, images, footnotes, raw HTML. Smart punctuation is on; type the characters you want.

## Decisions

- **Layout follows the sibling doc types.** `typst/ttab-answer.typ`, `docx/ttab-answer.lua`, `docx/make-reference.sh`, `usage/` with `FILED-EXAMPLE-answer[-n].pdf`, `INPUT-answer-<n>.md`, `OUTPUT-answer-<n>.*`, as in `notice-of-opposition/` and `trial-brief/`.
- **Typeface.** Times New Roman (Liberation Serif in typst where it is not installed); the rule names no typeface (TTAB-FORM-006). The notice of opposition template uses EB Garamond; each doc type picks its own, as the exemplars do.
- **Caption.** Shaped on the *Sage* exemplar ("In the matter of Application Serial No. ...", mark, filing and publication dates, parties with roles, number at right), with a rule down the right edge and along the foot of the left block in place of the exemplar's column of parentheses; the proceeding number on the line of the "v." between the parties.
- **No page headers, no table of contents.** An answer needs neither; the Board states no length limit for a pleading.
- **Certificate of service on its own page** without a repeated caption: TBMP § 113.03's suggested form carries none; the *Sage* exemplar repeats the caption, which is optional.
- **Drafting notes in the body of a sample** make a held draft usable: the notes mark exactly what to conform and are deleted before filing.

## Known limits

- No `checks.yaml`: `tools/check.sh` judges the folder with `data/checks-default.yaml` and `eval.yaml` (pass stamps `usage/.check-typst.txt`, `.check-docx.txt`). Gate 2 (visual review of every page of both engines' PDFs) is recorded in `../reviews/`.
- No LaTeX engine. The entry is delivered typst plus docx.
- The typst engine does not render footnotes in this template (the Board's answer does not use them); cmarker would, but they are unreviewed here.
- The only committed sample is fictional and has no drafting notes or counterclaim; the drafting-note style (TTAB-TOOL-002) and the counterclaim part were reviewed on a held draft that is not in this repository.
