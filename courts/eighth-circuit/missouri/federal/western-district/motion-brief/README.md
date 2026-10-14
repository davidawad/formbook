# W.D. Mo. (mowd): motion brief (suggestions in support of a motion to dismiss)

Doc type: **motion-brief** in the United States District Court for the Western District of Missouri (`mowd`). The local rules call a brief in support of a motion "suggestions" (L.R. 7.0(a)); this doc type produces the suggestions, which is the memorandum the brief calls for. The motion itself is a separate short filing (see Known gaps).
Folder: `courts/eighth-circuit/missouri/federal/western-district/motion-brief/` (self-contained; the court-root `typst/` and `samples/` are not touched).

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-mannon-6-26-cv-03197-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-mannon-suggestions.md` (an excerpt: cover, introduction, Sections I.A to I.C and VIII, certificate; see Known gaps) |
| typeface | face required by the rules: none (see Governing rules). Substitute: none; EB Garamond kept (`docs/FONTS.md`, "No face named"). Metric note: n/a. |
| render | ok: `samples/OUTPUT-mannon-suggestions.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`; re-rendered 2026-10-14, `pdffonts`: EB Garamond Regular, Bold and Italic embedded) |
| overlay | fail: `samples/OVERLAY-mannon-suggestions.pdf` not regenerated. `exemplars/` holds only `SOURCE.md` in this snapshot (no `FILED-EXAMPLE-*.pdf`), so `tools/overlay.sh` exits 1. The `.txt` page map is from an earlier run. |
| pages reviewed | 9 of 9 (re-rendered 2026-10-14 and every page viewed at 60 dpi; the template did not change) |

File names: the sample is `INPUT-<id>.md`, the render `OUTPUT-<id>.pdf` and the overlay `OVERLAY-<id>.{pdf,txt}`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default (the brief's `<id>.pdf` / `<id>-overlay.pdf` would not be found by the overlay tool).

## Governing rules

Primary source: W.D. Mo. Local Civil Rules, effective Dec. 1, 2022 (`https://www.mow.uscourts.gov/sites/mow/files/DC-Local_Rules-120122.pdf`, fetched 2026-10-14). The local rules set no typeface, font size, margin or spacing rule for filed papers. The typeface check was repeated on 2026-10-14 by extracting the text of that 76-page PDF and searching it for font, typeface, point size and paper-format terms: no match for filed papers.

| Rule | Requirement | Where it lives |
|---|---|---|
| L.R. 7.0(a) | A written motion must be supported with suggestions (a written brief with the relevant facts and applicable law). Suggestions must be concise and emphasize their primary authorities. | The document is titled "Suggestions in Support of ... Motion to Dismiss" (title from frontmatter). |
| L.R. 7.0(c)(1) | Moving party files supporting suggestions with the motion. | Filing practice (the motion is a separate document; see Known gaps). |
| L.R. 7.0(d)(1)(A) | Supporting suggestions may not exceed 15 pages unless the court orders otherwise. | Not counted by the template (author responsibility). The excerpt body is 5 pages. |
| L.R. 7.0(d)(2) | Exhibits, signature blocks, certificates of service and statements of fact do not count toward the page limit. | Signature block and certificate are generated outside the count (the template does not count pages). |
| L.R. 7.0(d)(3) | Suggestions over 10 pages must have a table of contents and a table of authorities (not counted). | `toc-page()` and `toa-page()` are always generated. |
| L.R. 7.0(e) | A request for oral argument is marked on the first page of the motion or the suggestions. | Not generated; the title line is frontmatter. Not shown in the exemplar. |
| L.R. 7.0(f) | Proposed orders are not filed on ECF. | Not generated (separate). |
| L.R. 3.2(a), (b) | Divisions of the District; divisional venue. | `division` in frontmatter, printed under the court title (the exemplar has "SOUTHERN DIVISION"). |
| L.R. 5.1 | Mandatory electronic filing. | The render is text searchable (vector text, fonts embedded); see the CM/ECF manual. |
| CM/ECF Civil and Criminal Administrative Procedures Manual (`https://www.mow.uscourts.gov/sites/mow/files/AdministrativeGuideandUserManual.pdf`, fetched 2026-10-14; revision date printed 8/27/2026) | Electronically converted PDFs are text searchable; scanned image PDFs are not. | As above. |
| Fed. R. Civ. P. 12(b)(6) | The motion to dismiss under the rule (the grounds are the author's text). | Not checked by the template. |
| Fed. R. Civ. P. 5(b) | Service on counsel through the court's electronic system and by other means as stated. | `service` in frontmatter; the certificate wording is the template's (the exemplar's wording: "via this Court's CM/ECF system and via electronic mail to Plaintiff"). |

## Layout (chosen, not mandated)

- Cover (unnumbered): court title, division, caption (parties left; "Case No." right), title of the paper centred and bold.
- Table of contents (roman i) and table of authorities (roman ii), both generated (see below).
- Body (arabic from 1): EB Garamond 13 pt, double spaced (`body-leading` = 1.35 em), first-line indent 0.5 inch, letter paper, 1 inch margins. Headings bold: level 1 "I.", level 2 "A.", level 3 "1.", level 4 "a." Headings are kept with the text after them.
- Signature block at the end of the body: "Respectfully submitted," and the `/s/` signer at the right half, with the firm, address and e-mail lines and "ATTORNEYS FOR DEFENDANTS".
- Certificate of service on its own page: the template's wording with the date and recipients from frontmatter.
- Table of authorities: cases alphabetized, then statutes (and other kinds if present), each with the pages where it is cited, "passim" at seven pages or more (`passim-at`).
- Table of contents: every heading, with its page.
- Page numbers centred at the foot.

Why EB Garamond: the same reason as the complaint folder. The local rules name no face, so the court-named-face rows of `docs/FONTS.md` do not apply and the template keeps EB Garamond. The exemplar is set in Times New Roman; the rules do not require Times, and a metric-compatible Times substitute ("Liberation Serif") is vendored but not used.

Why 13 pt: at 13 pt the EB Garamond x-height is close to the Mannon exemplar's Times New Roman at 12 to 14 pt (the exemplar's body measures about 14 pt Times by text-box height). Not a rule.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `division`; `caption` (`between`: "vs." or "v."; `parties`: list of `{names, designation}`); `title` (the brief's title, printed under the caption, centred and bold); `signature` (`signer`, `lines`: the lines under the name); `service` (`date`, `recipients`, `signer`); `authorities` (a registry: each key has `kind` (case, constitution, statute, regulation, rule, other), `name` (optional; italic for cases), `cite`).
- Body chunks, blank-line separated: a `#`/`##`/`###` heading; a `>` block quotation (single spaced); a list; any other chunk is a body paragraph (first-line indent, not numbered).
- Headings: the template numbers a heading only when its text does not already begin with its own number. An excerpt keeps the filing's numbers, so the sample types them ("I.", "A.", "VIII."). A heading beginning "Introduction" or "Certificate of Service" is unnumbered.
- Authorities: cite with a link whose target is `toa:KEY`, the full citation as the text: `[*Spokeo, Inc. v. Robins*, 136 S.Ct. 1540, 1547 (2016)](toa:spokeo)`. Every link is recorded with the page where it appears. A key that is not in `authorities:` stops the build. An authority cited on seven or more pages prints "passim".
- Italics (`*...*`) for case names and *Id.*; escaped asterisks for "at \*6" (Westlaw star pages).
- Not supported: footnotes (none in the exemplar's excerpt), tables, raw typst.

## Known gaps and open choices

1. **Local rules text is from December 2022.** The 2026 revision PDF (`DC-Local_Rules-072026.pdf`) returned HTTP 404 to WebFetch from this box, and courtrules.net returned 403. A later amendment would not be seen here (in particular any change to the 15-page limit in L.R. 7.0(d)). **Needs a check of the current local rules before this is treated as complete.**
2. **No typeface, size or spacing rule** in the local rules; the exemplar is Times New Roman at about 14 pt (text-box measure); this template is EB Garamond 13 pt, double spaced. If a judge's standing order requires Times New Roman, the face would change to "Liberation Serif" (`docs/FONTS.md`), and the page count and line breaks would need a re-render and check.
3. **Excerpt.** The sample transcribes the cover, the COME NOW paragraph, Section I (the typed heading and the first paragraph), I.A (standing), I.B (Folsom and Pope), I.C (Laclede County, through the failure-to-train paragraph), VIII (statute of limitations, in full) and the WHEREFORE paragraph, the signature and the certificate. Omitted: I.D, Sections II to VII. The 22-page exemplar is therefore not reproduced in full; the render is 9 pages (within the 8 to 14 target for an excerpt).
4. **The motion itself is not generated.** The exemplar's motion (Doc. 24, 3 pages) is a separate document, and L.R. 7.0(c)(1) requires it to accompany the suggestions. A motion-only template is not part of this doc type.
5. **Table of contents and authorities have no dot leaders and no hanging indent.** The exemplar's TOC and TOA use dot leaders. Typst's dot leaders did not lay out inside grid cells, so the rows use plain columns. Wrapped TOA entries start at the left margin (the Bartis entry in the sample shows this).
6. **Typed section numbers.** The template numbers headings only when the sample has no number of its own (see the markdown contract). The excerpt types its numbers, so an edit that adds or removes a section must renumber the typed headings by hand.
7. **Signature placement.** The exemplar puts its signature block on the cover page (Baty Otto Scheer PC's form). The template puts it at the end of the body, the conventional place. This is a tier-2/3 choice.
8. **Citations as printed.** The exemplar's citations are transcribed as printed: "*Bartis v. City of Bridgeton*, No. 406-CV-1574 JCH" (the case number looks like a typo for 4:06-cv-1574, not corrected here), "*Moffitt v. Town of Brookfield* ... (2nd Cir. 1991)" and "*Peck v. United States*, 470 F.Supp. 1003 (S.D.N.Y.1979)". The TOA prints the registry's form ("Cite" as set in the frontmatter), not the body's pinpoint form.
9. **Second exemplar not collected.** EVAL-LOOP's tier-2 rule asks for two or three filers. Ketcherside v. Foley, No. 5:26-cv-06042 (Doc. 18, a combined motion and memorandum) is not in public RECAP storage (HTTP 404 for the storage path). Vincenti v. USA Fencing Association, No. 4:25-cv-00850 (Doc. 14, motion and suggestions) was identified in the same CourtListener search but not downloaded. Tier 2 is not judged against two filers.
10. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape. The render and overlay were run; the page review below is the Gate 2 equivalent.
11. **Overlay pairing is coarse.** The overlay pairs pages by word overlap, so the excerpt's pages are matched to exemplar pages that share words, not to the pages they came from. The overlay is a diagnostic, not a score.

## Review of the rendered pages (current PDF, 60 dpi, every page viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 (unnumbered) | Cover: court title, division, caption, title | Pass. The caption's party column and the "Case No." line align; the title is centred and bold. |
| i | Table of contents | Pass. Entries show the level indentation and page numbers. The long I. entry wraps under its text (gap 5). |
| ii | Table of authorities (cases, statutes) | Pass. Cases alphabetized, statutes listed with their pages. The Bartis entry wraps to the left margin (gap 5). "passim" is not used (no authority reaches seven pages). |
| 1 | COME NOW paragraph; I (typed heading); first paragraph; A (standing) with the Spokeo quotation and *Id.* | Pass. Headings hang the numeral; body double spaced. |
| 2 | Plaintiff's fails to allege ...; B (Folsom and Pope); Wright, Moffitt, McKeon citations | Pass. |
| 3 | Folsom, Count VII (O'Neal); C (Laclede County), Gilmore, Monell, Id., Di Maggio | Pass. |
| 4 | Connick (failure to train); VIII heading (two lines); Count IV paragraph (Colombo, Bartis) | Pass. |
| 5 | Count VI (42 U.S.C. § 1986, Peck); the timing paragraph; WHEREFORE; signature block | Pass after fix: the signature block had been right-aligned text; it is now left-aligned in a right-hand column. |
| 6 | Certificate of service | Pass after fix: the signature line sits in the right-hand column. |

Page numbers: the cover is unnumbered, the contents and authorities are i and ii, and the body is 1 to 5, with the certificate on body page 6 (the TOC gives that page as 6).

## Overlay

`samples/OVERLAY-mannon-suggestions.pdf` (red = our render, blue = exemplar, black = both) and `samples/OVERLAY-mannon-suggestions.txt` (page map). Pages are paired by word overlap: ours p.1 to p.9 pair with filed p.1, 3, 4, 7, 8, 9, 20, 21, 22. The pairing is coarse because the sample is an excerpt and the exemplar's pleading-style caption and numbering are not reproduced; read the map with the caveat in gap 11.
