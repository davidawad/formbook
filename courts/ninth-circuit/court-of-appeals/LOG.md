# Loop log (ca9 principal brief)

One entry per iteration: what failed, what changed. Newest last. Gate numbers refer to `docs/EVAL-LOOP.md`.

**1. First render of the Sweet sample, viewed page by page (Gate 2, before any checker existed).**
Failed: the cover spilled onto a second page (counsel block and bottom rule); wrapped lines in the table of contents and in the certificate option rows started at the left margin; the TOC ran onto a second page for one entry; sub-heading labels sat at the margin instead of half an inch in; the signature block stood alone on a page, away from the conclusion; "60(b)" and "(5)" were split across lines.
Changed: found that `set par(hanging-indent: ...)` inside a block is ignored by typst 0.15, so hanging paragraphs are now explicit `par(hanging-indent: ...)` (`hang()` in the template); cover spacing tightened; label indent defined by heading level; the last paragraph of the brief is kept together with the signature block; unbreakable boxes around tokens containing ")(" and around "§ n" (done with boxes, not invisible characters, so the extracted text stays the author's characters).

**2. Generic sample added and viewed.**
Failed: with three plaintiffs, two defendants and two counsel groups the cover again spilled onto page 2; footnote text measured 15.5 pt tall against 18.3 pt for 14 pt text, i.e. typst's default footnote size (0.85 em) violated FRAP 32(a)(5); block quotation spacing was too large; headings used typst's built-in 1.4 em/1.2 em sizes.
Changed: the cover is now fitted by measuring (largest spacing at which it fits; type size never shrinks; build error if nothing fits); footnote entries explicitly 14 pt with a thin space after the marker; every heading set at body size or 1.15 em; quote spacing set explicitly.

**3. Gates 0 and 1 implemented (`tools/check.sh`) and run for the first time.**
Failed (real template defects, found by the checker): the certificate of compliance undercounted the words by about 190 (typst's `str.replace` has no `$1`, so link text was being deleted from the count); a citation that begins at the first line of a page was listed in the table of authorities on the previous page (typst files an invisible tag in front of a line-initial word under the previous line).
Changed: `count-words` uses capture functions; the TOA tag is placed after the first word of the citation (`tag-after-first-word`), with a selftest mutant that reintroduces the old behaviour.
Failed (checker defects): page-number footers leaked into the TOC/TOA parse; TOC page numbers live in their own text run; `-v` strips backslashes from regexes (`\(`); the content gate matched the addendum's own table of contents instead of the addendum headings; citations inside footnotes were not counted for the TOA; the PDF-derived word count included the addendum.
Changed: footers skipped by position, page number read from the next run on the same line, bracket classes instead of escapes, headings now placed just before the block that follows them, footnote links recorded with the footnote's page, addendum excluded from the count.

**4. Mutation test of the checker (`tools/check-selftest.sh`).**
Result: 18 mutants (dropped paragraph, dropped "- " paragraph, altered word, lost italics, altered footnote, lost footnote text, single spacing, 12 pt type, narrow margins, left-aligned headings, wrong font, small footnotes, no footnote size, wrong word count, wrong Argument numeral, case text in the template, TOA tag before the citation, TOA page off by one): all caught by the named check. One mutant first "changed nothing" (the expression no longer matched after a template edit); the selftest now fails in that case instead of passing silently.

**5. Visual review pass over every page of both PDFs (Gate 2).**
Failed: block quotation had no space above and below after the fix in 2 went too far the other way; the related-cases line printed "Dist.. arises" (double period) and, after a first change, "order))."; the cover of the generic sample is dense.
Changed: quotation spacing 1 em; related cases rendered as "No. N, *Name* (relationship)."; sample text adjusted; certificate number printed with a thousands separator ("11,622" style). The dense cover is recorded as an accepted limit (README, "Known limits").

**6. All gates green on both samples.** 94 checks pass; `reviews/2026-10-07.md` covers 23 + 19 pages with no open defect.
