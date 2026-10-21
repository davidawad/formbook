# Trademark Trial and Appeal Board

- Alias: `ttab`
- CourtListener: [ttab](https://www.courtlistener.com/?court=ttab)
- Level: agency
- Circuit: `cafc`
- Status: **in progress** (50%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [x] `exemplars/` has at least 2 filed PDFs (different filers)
- [x] `samples/` has at least 2 .md samples
- [ ] typst engine passes (`samples/.check-typst.txt` valid)
- [ ] latex engine passes (`samples/.check-latex.txt` valid)
- [ ] docx engine passes (`samples/.check-docx.txt` valid)
- [ ] overlay PDF present (`samples/*-overlay.pdf`)
- [x] a review file in `reviews/`

Engines: typst `built`, latex `—`, docx `built`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and the typst engine passes `tools/check.sh` (valid stamp).

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `exemplars/` real filed examples from different filers (PDF) and `SOURCE.md`
- `samples/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

# Trademark Trial and Appeal Board: how this entry works

Template for the Board's standard inter partes caption, answer, optional counterclaim, signature block and certificate of service. Requirements and sources: [rules.md](rules.md). Filed exemplars: [exemplars/SOURCE.md](exemplars/SOURCE.md). Loop history: [LOG.md](LOG.md). Reviews: [reviews/](reviews/).

## Render

```sh
sh tools/render.sh courts/federal-circuit/trademark-trial-and-appeal-board samples/sircharge-answer-reserve.md             # typst: samples/sircharge-answer-reserve.pdf
sh tools/render.sh --engine docx courts/federal-circuit/trademark-trial-and-appeal-board samples/sircharge-answer-reserve.md  # docx + LibreOffice PDF
```

The typst PDF embeds Liberation Serif, the vendored face metrically identical to Times New Roman. To render the typst PDF in Times New Roman itself (a system font, so outside `tools/render.sh`, which forbids system fonts), run typst by hand with the font named:

```sh
typst compile --root <court-dir> --font-path /System/Library/Fonts/Supplemental --input font="Times New Roman" \
  --package-cache-path vendor/typst-packages --input sample=samples/NAME.md <court-dir>/typst/main.typ out.pdf
```

The docx names Times New Roman; Word uses it. LibreOffice, which makes the checked PDF, substitutes Liberation Serif when it cannot see Times New Roman.

`docx/reference.docx` is built by `docx/build-reference.sh` (styles only, no body); `docx/ttab.lua` builds the caption, title, signature block and certificate from the frontmatter and numbers the paragraphs.

## Markdown contract

A sample is one markdown file: a YAML frontmatter block, then the body.

```yaml
kind: opposition                  # or: cancellation (changes "Opposition No." to "Cancellation No.")
proceeding_number: "91123456"     # or a placeholder such as "[__________]"
matter:                           # lines above the parties in the caption box
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

- **Caption.** Shaped on the *Sage* exemplar and the instruction for this matter ("In the matter of Application Serial No. ...", mark, filing and publication dates, parties with roles, number at right), with a rule down the right edge and along the foot of the left box in place of the exemplar's column of parentheses.
- **No page headers, no table of contents.** An answer needs neither; the Board states no length limit for a pleading.
- **Certificate of service on its own page** without a repeated caption: TBMP § 113.03's suggested form carries none; the *Sage* exemplar repeats the caption, which is optional.
- **Drafting notes are in the body of the sample.** That is what makes a reserve draft usable: the notes mark exactly what to conform; they are deleted before filing.

## Known limits

- Mechanical gates (content, rules, generalization) are not implemented for this court yet; there is no `checks.yaml`, so `tools/check.sh` does not run here and no pass stamp exists. Gate 2 (visual review of every page of both engines' PDFs) is recorded in `reviews/`. See `LOG.md`.
- No LaTeX engine. The entry is delivered typst plus docx.
- Page-break choices differ between the typst PDF and the docx PDF (12 and 13 pages for sample 1). Neither rule nor exemplar fixes them.
- The typst engine does not render footnotes in this template (the Board's answer does not use them); cmarker would, but they are unreviewed here.

[Formbook index](../../../README.md) | [Status table](../../../STATUS.md)
