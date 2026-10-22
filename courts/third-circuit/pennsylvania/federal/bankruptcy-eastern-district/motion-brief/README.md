# paeb: motion brief (motion with memorandum of law)

Doc type: **motion with memorandum of law** in the United States Bankruptcy Court for the Eastern District of Pennsylvania (`paeb`), in an adversary proceeding.
Folder: `courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, one filer: `usage/FILED-EXAMPLE-motion-brief.pdf` (Eckert Seamans Cherin & Mellott, LLC for U.S. Bank Trust Co., N.A.; filed 2026-03-16). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md`: the full memorandum (caption, lead-in, Sections I to V, signature) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` and `.docx.pdf`, 9 pages each; vendored Times New Roman only, `--ignore-system-fonts`, no warnings; the docx breaks every line and page as typst (XENG-001..003 gated, `eval.yaml`) |
| overlay | ok: `usage/OVERLAY-henry-memorandum.pdf` and `.txt` |
| pages reviewed | 9 of 9 on both engines, 2026-10-22 (see "Gate 2 review"). |

Build (from the repo root, PATH per the box setup):

```sh
D=courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district/motion-brief
sh tools/render.sh $D usage/INPUT-motion-brief.md
sh tools/overlay.sh $D henry-memorandum $D/usage/SAMPLE-henry-26-00106-motion-brief.pdf
```

File names follow the tools (`INPUT-`, `OUTPUT-`, `OVERLAY-`), as in `adversary-complaint/README.md`.

## Engines

Engine status: typst and docx (`OUTPUT-motion-brief.docx` and its LibreOffice `.docx.pdf`), every line and page alike (XENG-001..003 gated: 228/228 lines); latex not built (`latex/` is empty).

- **typst** (primary, `typst/`): on the shared cross-engine layout model (`lib/typst/xengine.typ`, fb-595.68.34): a 24 pt body pitch (double spaced; the title too), 14 pt single lines (court title, caption rows, signature, certificate lists, footer), explicit block spaces (12 pt around a heading, 14 pt between cover parts, 24 pt above the signature and the certificate).
- **docx** (`docx/`): `docx/reference.xml` (the cross-engine recipe, `base="xengine"`, in the typst face `{font}`: Times New Roman 12 pt; it named EB Garamond until fb-595.68.34) and `docx/paeb-motion-brief.lua` (on `lib/docx/xengine.lua`), which writes every paragraph: the court title, the caption (a borderless three-column table, one row per single line), the title, the lead-in and the optional consent statement, the memorandum paragraphs, the "> " lead-ins (flush, kept with the next block), the headings, the lists (label at 0.5 in, text hanging at 1 in, labelled by `list_numbering`), the signature block, the optional certificate of service, the footer (a centred PAGE field, ``) and the section (letter, 1 in margins, ``). No shell: `fb render` builds the reference document and packs the archive (were `docx/build-reference.sh`, `docx/paeb.lua` and a committed `reference.docx`). Not verified in Word (LibreOffice only); it opens and converts without a repair prompt (DEF-DOCX-OPEN).
- **docx BLOCKED items:** none. `sh tools/check.sh <this folder> --engine docx`: every gate green.

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
- Double spacing (24 pt line pitch at 12 pt), no extra space between paragraphs. Memorandum paragraphs are not numbered, as in the exemplar.
- Headings: Roman-numeral sections (`I.`, `II.`) bold capitals, left; sub-headings (`i.`, `ii.`, `iii.`) bold, left; both on the body pitch with 12 pt above and below, kept with the text after them.
- Signature block at the foot: "Dated" at left, the firm, `By: /s/` and the lines at right. The last paragraph stays on the page with the signature block; the block is single lines from 3 in with "Dated:" beside the first.

## What the overlay shows

`OVERLAY-henry-memorandum.pdf` puts our render in red over the filed memorandum in blue. The page map (`.txt`) pairs our pages with the exemplar pages that share the most words: p. 1 with p. 1 (71%), p. 2 with p. 2 (80%), p. 3 with p. 4 (52%), p. 4 with p. 5 (47%), p. 5 with p. 6 (67%), p. 6 with p. 7 (60%), p. 7 with p. 9 (69%), p. 8 with p. 10 (82%). Page pairings drift where our pages hold more text per page than the filing; the overlay is a diagnostic only.

## Gate 2 review (2026-10-22, every page of both engines rendered at 45 dpi and viewed side by side)

Both engines carry the same lines on every page (XENG-003).

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (the defendant's name one row per line, a colon on every row), title (three double-spaced lines), lead-in, I. Statement of the Case | OK. |
| 2 | Section I continued | OK. |
| 3 | Section I end; II. Background | OK. |
| 4 | Section II end; III. Legal Standard | OK. |
| 5 | Section III end; IV. Legal Argument; sub-heading i. | OK: the two-line sub-heading kept with its paragraph. |
| 6 | Sub-heading i. end; sub-heading ii. | OK. |
| 7 | Sub-heading ii. end; sub-heading iii. ("¶¶ 15, 20" kept together) | OK. |
| 8 | Sub-heading iii. end | OK: the page ends early because V. Conclusion stays with its paragraph, which stays with the signature block. |
| 9 | V. Conclusion and the signature block | OK. |

No open tier-2 finding.

## Known gaps and open choices

1. **Consent statement.** L.B.R. 9014-3(b)(2) requires the motion to state whether the movant consents to final orders. That sentence belongs to the motion, which is not in the exemplar; the exemplar is the memorandum only. The template prints a `consent:` paragraph only when the sample gives one. The Henry sample does not, so the sample matches the exemplar. A real filing needs the statement in the motion.
2. **Notice, proposed order and response period.** L.B.R. 9014-3(e) (notice in the form of L.B.F. 9014-3), (f) (proposed order) and (g) (service) are not generated. For a 12(b)(6) motion like this one, L.B.R. 7005-1(b) sets a 21-day response period and says the movant modifies the notice; the template does not state the period.
3. **Certificate of service.** Optional `certificate:` block, worded as in the complaint exemplar. The L.B.F. 9014-4 form was not fetched, so the wording is not checked against it.
4. **Typeface (fonts pass, 2026-10-15).** Face required by the rules: none (L.B.R. 9004-1(b) and FRBP 9004, as in `adversary-complaint/README.md`, known gap 1). The house face, Times New Roman (vendored), is used in typst and docx alike (the docx named EB Garamond until fb-595.68.34); the exemplar body is Times-Roman too (base-14, not embedded, per `pdffonts`).
5. **Length.** The filed memorandum runs 10 pages; our render is 9 pages from the same text (Times New Roman 12 pt, double spaced, 1 in margins). No PAEB page limit was found.
6. **One filer.** Only the Eckert Seamans memorandum was usable. Searched RECAP for paeb memoranda: Johnson v. Wells Fargo (26-00133, Doc 7) is not available; Sheila Henry Doc 12-1 is a reply memorandum from the same filer, a different document type, and was not used.
7. **Alignment.** Body text is left-aligned, not justified. The exemplar's justification could not be read from the text layer.
8. **Tool checks.** `sh tools/check.sh <this folder>` and `--engine docx`: `RESULT: 9 checks passed, 0 failed` (typst) and `RESULT: 13 checks passed, 0 failed` (docx, XENG-001..003 gated).

## Search log (exemplar)

- CourtListener search API, `court=paeb`, `type=r`, `q="motion to dismiss" memorandum`, `filed_after=2026-01-01`. Memoranda found: Henry (26-00106, Doc 10, available: chosen), Johnson (26-00133, Doc 7, not available), Johnson (26-10372, main case, not an adversary), Sheila Henry Doc 12-1 (reply, same filer).
