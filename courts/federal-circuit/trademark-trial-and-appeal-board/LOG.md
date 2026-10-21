# Loop log (TTAB inter partes papers)

One entry per iteration. Newest last. Gate numbers refer to `docs/EVAL-LOOP.md`.

**1. Rules and exemplars first.** Read 37 C.F.R. Part 2 (eCFR 2026-10-19) and TBMP June 2026 from the KB for every cite in `rules.md`; read the TTAB Center page live (it lists answers and counterclaims as a future release). Found two filed answers on TTABVUE. First attempt to download them with curl returned HTTP 502 on every document: the server serves a document PDF only when the request's Referer is the proceeding-entry page. Retrieved through the browser with that Referer; recorded in `exemplars/SOURCE.md`.

**2. First typst render of sample 1 (viewed).** Failed: numbered paragraphs hung their wrapped lines under the text (typst's enum layout) instead of returning to the margin; top-level headings were left-aligned because a block without a width shrinks to its content, so `align(center)` had nothing to center in; drafting notes were set as double-spaced bold body paragraphs; the caption's matter line wrapped. Changed: numbers rendered by hand from the enum's children, headings and notes given `width: 100%`, notes set flush left, single-spaced, italic, caption columns 64/36.

**3. Spacing.** Failed: baseline pitch measured 24.1 pt (exactly 2 x 12 pt) while Word's "double" for Times New Roman at 12 pt is 27.6 pt, so the two engines paginated differently. Changed: `body-leading` 1.39em gives 27.6 pt, matching the docx.

**4. docx engine built and viewed.** `docx/build-reference.sh` makes the reference document (styles, footer page field); `docx/ttab.lua` builds caption, title, signature block and certificate from the frontmatter as raw OpenXML and numbers the paragraphs. Failed on first view: the signature block stood alone on a page, away from the prayer; the "[OPTIONAL Class 9 ...]" note was joined to the paragraph after it in the sample and rendered inline in docx but as a block in typst. Changed: the last paragraph before the signature block is set in a keep-with-next style; the sample puts the note on its own line.

**5. Second sample.** A fictional cancellation answer exercises what sample 1 does not: the cancellation caption, three recipients in the certificate of service, a block quotation, a level-3 heading, a bullet list inside a numbered item, escaped markers, and no drafting notes. Viewed in both engines; no defect found.

**6. Not done.** `checks.yaml` and the mechanical gates (content, rules, generalization), the selftest, and the LaTeX engine. They are recorded in `rules.md` as TTAB-TOOL-004 and in `README.extra.md`. The court is not "up for review" until they exist; `court.json` status is unchanged.
