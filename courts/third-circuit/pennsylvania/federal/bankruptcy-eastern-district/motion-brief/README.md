# paeb: motion brief (motion with memorandum of law)

Doc type: **motion with memorandum of law** in the United States Bankruptcy Court for the Eastern District of Pennsylvania (`paeb`), in an adversary proceeding.
Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `exemplars/FILED-EXAMPLE-henry-26-00106-motion-brief.pdf` (Eckert Seamans Cherin & Mellott, LLC for U.S. Bank Trust Co., N.A.; filed 2026-03-16). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-henry-memorandum.md`: the full memorandum (caption, lead-in, Sections I to V, signature) |
| render | ok: `samples/OUTPUT-henry-memorandum.pdf`, 8 pages; typst 0.15.0, vendored EB Garamond only, `--ignore-system-fonts`, no warnings |
| overlay | ok: `samples/OVERLAY-henry-memorandum.pdf` and `.txt` |
| pages reviewed | 8 of 8. Every page was rasterized at 60 dpi and viewed after the last template change. |

Build (from the repo root, PATH per the box setup):

```sh
D=courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/motion-brief
sh tools/render.sh $D samples/INPUT-henry-memorandum.md
sh tools/overlay.sh $D henry-memorandum $D/exemplars/FILED-EXAMPLE-henry-26-00106-motion-brief.pdf
```

File names follow the tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), as in `adversary-complaint/README.md`.

## Governing rules

Each rule was fetched on 2026-10-14. The PAEB rules are the "PAEB Local Rules" PDF dated 2025-12-01, from https://www.paeb.uscourts.gov/sites/paeb/files/PAEB%20Local%20Rules%20-2025-12-01%20Final.pdf (its page numbers are those printed on it).

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| Fed. R. Bankr. P. 9013 (current text eff. 2024-12-01) | "A motion must state its grounds with particularity and set forth the relief or order requested." | https://www.law.cornell.edu/rules/frbp/rule_9013 | the motion's text; the memorandum follows the motion's title and lead-in |
| Fed. R. Bankr. P. 9004(a), (b) (eff. 2024-12-01) | Legible; caption with the court's name, the case title, the case and adversary numbers, and a designation of the document. | https://www.law.cornell.edu/rules/frbp/rule_9004 | `court-title()`, `caption-rows()`, `title` |
| L.B.R. 9014-1(b) | A motion filed in an adversary proceeding is governed by L.B.R. 7005-1. | PAEB Local Rules PDF, p. 70 | the caption and the adversary number |
| L.B.R. 7005-1(b) | For a 12(b)(6) or Rule 56 motion: no hearing date under L.B.R. 9014-3(c); response period 21 days under 9014-3(h); the movant modifies the notice (L.B.F. 9014-3). | same, p. 56 | not generated (see Known gaps, 2) |
| L.B.R. 9014-3(b)(1), (2) | A motion identifies the movant, the relief and its basis, and states whether the movant does or does not consent to final orders or judgment by the court. | same, p. 72 | `consent:` frontmatter, printed only when given (see Known gaps, 1) |
| L.B.R. 9014-3(e), (f), (g) | A notice of the motion, a proposed order, and service on the Clerk's service list. | same, p. 72–73 | not generated (see Known gaps, 2) |
| L.B.R. 9014-3(h) | Response within 14 days of service (general deadline), subject to subdivision (i). | same, p. 73 | not generated |
| L.B.R. 9014-4(a), (b) | A certificate of service is filed promptly, and conforms to L.B.F. 9014-4. | same, pp. 73–74 | optional `certificate:` block (see Known gaps, 3) |
| L.B.R. 9004-1(b) | Paper filings measure 8½ × 11 inches, stapled or fastened at the top. | same, p. 67 | `page(paper: "us-letter")` |

No E.D. Pa. rule on typeface, type size, margins, line spacing or page limit was found in the local rules PDF (93 pages; searched for font, point, margin, spacing and page limit) or in FRBP 9004. These are conventions, judged against the exemplar. The PAEB rules also set no page limit for a memorandum.

## Layout (conventions, judged against the exemplar)

- Letter paper, 1 inch margins, page number centered at the foot.
- Court name in bold capitals, two lines, centered; a three-column caption with the debtor and parties on the left, colons, and `Chapter`, `Case No.` and `Adv. No.` at right (the exemplar uses the same structure).
- Title in bold, centered. The lead-in ("AND NOW comes …") is flush with a first-line indent.
- Double spacing (24 pt baseline pitch at 12 pt). Memorandum paragraphs are not numbered, as in the exemplar.
- Headings: Roman-numeral sections (`I.`, `II.`) bold capitals, left; sub-headings (`i.`, `ii.`, `iii.`) bold, left; both kept with the text after them.
- Signature block at the foot: "Dated" at left, the firm, `By: /s/` and the lines at right. The last paragraph stays on the page with the signature block.

## What the overlay shows

`OVERLAY-henry-memorandum.pdf` puts our render in red over the filed memorandum in blue. The page map (`.txt`) pairs our pages with the exemplar pages that share the most words: p. 1 with p. 1 (71%), p. 2 with p. 2 (80%), p. 3 with p. 4 (52%), p. 4 with p. 5 (47%), p. 5 with p. 6 (67%), p. 6 with p. 7 (60%), p. 7 with p. 9 (69%), p. 8 with p. 10 (82%). Page pairings drift where our pages hold more text per page than the filing; the overlay is a diagnostic only.

## Gate 2 review (final render, every page viewed)

- p. 1: court title, caption (defendant's name split into rows so the colons align), title, lead-in, Section I heading and the first paragraph. Pass.
- p. 2 and p. 3: Section I (remaining paragraphs) and Section II, Background. Pass.
- p. 4: Section III, Legal Standard, and the start of Section IV. The Section IV heading keeps with its first paragraph and does not end the page alone. Pass.
- p. 5: sub-heading `i.` with its paragraphs, sub-heading `ii.` begins. Pass.
- p. 6: remaining paragraphs of `ii.`. Pass.
- p. 7: sub-heading `iii.` with its paragraphs. Pass.
- p. 8: final paragraph of Section IV, Section V Conclusion, signature block. Pass.

## Known gaps and open choices

1. **Consent statement.** L.B.R. 9014-3(b)(2) requires the motion to state whether the movant consents to final orders. That sentence belongs to the motion, which is not in the exemplar; the exemplar is the memorandum only. The template prints a `consent:` paragraph only when the sample gives one. The Henry sample does not, so the sample matches the exemplar. A real filing needs the statement in the motion.
2. **Notice, proposed order and response period.** L.B.R. 9014-3(e) (notice in the form of L.B.F. 9014-3), (f) (proposed order) and (g) (service) are not generated. For a 12(b)(6) motion like this one, L.B.R. 7005-1(b) sets a 21-day response period and says the movant modifies the notice; the template does not state the period.
3. **Certificate of service.** Optional `certificate:` block, worded as in the complaint exemplar. The L.B.F. 9014-4 form was not fetched, so the wording is not checked against it.
4. **Typeface (fonts pass, 2026-10-15).** Face required by the rules: none (L.B.R. 9004-1(b) and FRBP 9004, as in `adversary-complaint/README.md`, known gap 1). Substitute: none; EB Garamond stays. The exemplar body is Times-Roman (base-14, not embedded, per `pdffonts`), an exemplar convention, not a rule, and not chased.
5. **Length.** The filed memorandum runs 10 pages; our render is 8 pages from the same text, because of the line length and spacing of EB Garamond. The 8-page render is within the 8-to-14 target. No PAEB page limit was found.
6. **One filer.** Only the Eckert Seamans memorandum was usable. Searched RECAP for paeb memoranda: Johnson v. Wells Fargo (26-00133, Doc 7) is not available; Sheila Henry Doc 12-1 is a reply memorandum from the same filer, a different document type, and was not used.
7. **Alignment.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer.
8. **Tool gate not run.** As in the complaint, `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids editing `tools/`. The page review above stands in for Gate 2.

## Search log (exemplar)

- CourtListener search API, `court=paeb`, `type=r`, `q="motion to dismiss" memorandum`, `filed_after=2026-01-01`. Memoranda found: Henry (26-00106, Doc 10, available: chosen), Johnson (26-00133, Doc 7, not available), Johnson (26-10372, main case, not an adversary), Sheila Henry Doc 12-1 (reply, same filer).
