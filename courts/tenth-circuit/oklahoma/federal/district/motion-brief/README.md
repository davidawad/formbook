# okd (District of Oklahoma): motion with brief in support

Doc type: **motion-brief**, a Rule 12(b)(6) motion to dismiss with its brief in support, in a United States District Court in Oklahoma (folder `district`, alias `okd`). The district is named by each sample's `court:` frontmatter, so the template carries no court name.
Folder: `courts/tenth-circuit/oklahoma/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-trupia-5-26-cv-02422-motion-to-dismiss.pdf` (one filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-trupia-motion-to-dismiss.md` (the whole 9-page filing, transcribed; see below) |
| render | ok: `samples/OUTPUT-trupia-motion-to-dismiss.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-trupia-motion-to-dismiss.pdf` and `OVERLAY-trupia-motion-to-dismiss.txt` (page map) |
| pages reviewed | 8 of 8 (every page of the final render rasterized at 60 dpi and viewed) |
| tools/check.sh, check-selftest.sh | not run: they expect a court folder with `court.json` and `rules.md`; this doc-type folder has neither shape (the brief forbids editing `tools/`) |

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Where it is in the template | Source |
|---|---|---|---|
| Fed. R. Civ. P. 7(b)(1) | A motion must be in writing, state with particularity the grounds for the order, and state the relief sought. | The title and the opening paragraph of the sample state the relief and the grounds; the template does not check the wording. | https://www.law.cornell.edu/rules/frcp/rule_7 |
| Fed. R. Civ. P. 12(b) and 12(b)(6) | Failure to state a claim is a defense that may be asserted by motion; the motion must be made before pleading. | Content of the sample; timing is not a template matter. | https://www.law.cornell.edu/rules/frcp/rule_12 |
| W.D. Okla. LCvR7.1(b) | Each motion and brief is clearly titled to identify on whose behalf it is presented. | `brief_title` (set in capitals, centered). | https://okwd.uscourts.gov/sites/okwd/files/LocalRules2026.pdf (local rules effective April 2026) |
| LCvR7.1(c) | Each motion is a separate document, except where the rules or a court order allow otherwise. | Not a template check; the sample is one motion. | same |
| LCvR7.1(d) | 13-point type or larger, footnotes included; margins at least one inch on the top, bottom and sides. | `type-size = 13pt`; `margin = 1in`; footnotes at 13 pt; footer page number at 13 pt. | same |
| LCvR7.1(e) | Opening briefs not over 25 pages (30 for summary judgment), without leave; cover, table of contents, table of authorities, signature block, certificate of service and exhibits are not counted; a brief longer than 15 pages must have an indexed table of contents and table of authorities. | The 15-page rule is enforced: the build fails above 15 pages (see gap 1). The 25-page limit is not enforced. | same |
| LCvR7.1(k) | A motion and brief in support may be one document if so identified in the title. | `brief_title` names both ("... MOTION TO DISMISS AND BRIEF IN SUPPORT"). | same |
| LCvR5.2(a) | 8 1/2 by 11 inch paper, double-spaced if typewritten, clearly legible. | `page-w`, `page-h`, `pitch` = 27.5 pt (see below). | same |

Not produced by this template: the certificate of service text beyond the sample's own certificate, the table of contents and table of authorities (gap 1), a proposed order (LCvR5.5), and the response or reply periods (LCvR7.1(g), (h)).

## Layout

- Court name in bold capitals, centered, on the first lines; caption with a ")" column; `Case No.` at the top right, and `JURY TRIAL DEMANDED` under it when `jury_demand` is true.
- Title in bold capitals, centered, below the caption (no separate cover page; the filing has none).
- Body: double spacing, first-line indent. Level 1 headings are centered bold capitals (STATEMENT OF THE CASE, ARGUMENT AND AUTHORITY, CONCLUSION); level 2 bold; level 3 bold italic. The section numbers and the statement paragraph numbers are typed in the sample.
- Quotations are indented and single-spaced; lists are rendered as markdown lists.
- Signature block: right half of the page, `closing` (for example "Respectfully submitted,") then each `groups` entry.
- Certificate: starts a new page; the title, the certificate text, the parties served (flush left), then the signer's lines in the right half.

### Measured line pitch

The filed exemplar's double-spaced baseline pitch is 27.5 pt (measured with `pdftotext -bbox` on the exemplar, the same pitch as the complaint folder's exemplar). The template uses it (`pitch = 27.5pt`, `body-leading = 1.465em`); the render measures 27.5 pt on every body line.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `court` (list of lines; uppercased by the template), `case_number`, `caption.parties` (list of `{names, designation}`; "v." is inserted between parties; each name line must fit the 3.6 in column, and the build fails if one does not), `brief_title`, `jury_demand`, `signature` (`closing` lines and `groups` with `lines`), and `certificate` (`title`, `text`, optional `served` lines, `groups` with `lines`).
- Body: blank-line-separated chunks. `# Heading` centered; `## Heading` bold; `### Heading` bold italic. Type the section numbers ("I.", "A.") in the heading text.
- Statement paragraphs are numbered by typing the number with the period escaped: `1\. City is ...`. An unescaped `1. ` would be a markdown list and render as one.
- Not supported: tables, raw typst.

## What the overlay shows

`tools/overlay.sh` pairs each rendered page with the filed page that shares the most words, and writes the red (ours), blue (filed) and black (both) overlay. The sample is the whole filing: our pages 1 to 5 pair with filed pages 1 to 5, and our pages 6 to 8 pair with filed pages 7 to 9 (filed page 6 is the one page of the filing that no page of ours pairs with). The page breaks fall differently from the filing's, and the text-based pairing follows the words. The page map is in `OVERLAY-trupia-motion-to-dismiss.txt`. The overlay is a diagnostic, not a score.

File names: `tools/overlay.sh` and `tools/render.sh` write `OVERLAY-<id>.pdf`/`.txt` and `OUTPUT-<id>.pdf`, the convention the other courts use, not the `<id>-overlay.pdf` form the brief mentions.

## Known gaps and open choices

1. **Table of contents and table of authorities are not produced.** LCvR7.1(e) requires both for a brief longer than 15 pages. The template fails the build when a render exceeds 15 pages, rather than delivering such a brief without them. A brief of 15 pages or less needs neither.
2. **The 25-page limit is not enforced.** The template does not subtract the pages that LCvR7.1(e) excludes (cover, table of contents and table of authorities, signature, certificate, exhibits). Counting that by hand: the body of the sample (up to the signature block) is 7 pages.
3. **Typed numbers.** Section numbers and statement paragraph numbers are typed in the sample, not generated; the template does not number argument headings. This follows the filing and the ca9 sample's convention for escaped markers.
4. **Font.** The rules do not name a face. This template uses EB Garamond (vendored in `fonts/`, the only face the build can use). EB Garamond at 13 pt has a smaller x-height than the exemplar's Times New Roman, so the text looks smaller on the page. The 13-point minimum is met; the Times-metric question is a repo decision.
5. **One exemplar.** EVAL-LOOP's tier-2 rule asks for 2 or 3 filers. The search (CourtListener RECAP, `okwd`, motions to dismiss filed 2026) found several other motions with stored PDFs (Benne, Loftis, Harris, Shugard); they were not saved because the brief asks for one exemplar per doc type. Tier 2 is therefore **not** judged against two filers yet.
6. **The "okd" folder.** CourtListener lists `okd` as not in use. The live Oklahoma federal courts are `okwd`, `oknd` and `oked`. The template follows the Western District's local rules, and the exemplar is from the Western District. If the folder should be a different district, the rules and the exemplar change; the template does not. This is a question for David.
7. **Certificate.** The sample uses a certificate of mailing (the exemplar's), since the filer served a pro se party by mail. A certificate of service through CM/ECF would use the same fields with different text; the template does not select between them.
8. **Headings wrap on the grid.** Each heading is set on whole double-spaced lines, so a two-line heading takes two lines of grid space, as the exemplar's does.
9. **Left-aligned body.** Body text is left-aligned, not justified; not asserted.

## Review of the rendered pages (final render, 8 pages)

- Page 1: court name, caption with ")" column, `Case No.` and `JURY TRIAL DEMANDED`, the title, the opening paragraph, the Statement of the Case heading, statement paragraphs 1 to 4. Pass.
- Page 2: statement paragraphs 5 to 8; ARGUMENT AND AUTHORITY heading with heading I and the start of its paragraph (the heading stays with its first lines). Pass.
- Page 3: the end of heading I's paragraph; heading II; heading III and its sub-heading A; the paragraphs of A; heading B. Pass.
- Page 4: the rest of B (Twombly, Ton Services, Ridge at Red Hawk, Wilson); the 42 U.S.C. § 1983 paragraphs. Pass.
- Page 5: the municipal liability paragraphs; the Iqbal and Twombly citations. Pass.
- Page 6: the end of III.B; sub-heading C; negligence and nuisance. Pass.
- Page 7: the end of III.C; CONCLUSION; the signature block (Respectfully submitted, the two counsel groups). Pass.
- Page 8: CERTIFICATE OF MAILING on its own page; the served party; the signer. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder). Layout defects found in earlier renders and fixed: paragraphs that could not break across pages (large gaps on pages 2 and 4 of the first render), paragraphs overlapping their neighbours (no trailing leading after a paragraph block), and the heading not kept with its paragraph.
