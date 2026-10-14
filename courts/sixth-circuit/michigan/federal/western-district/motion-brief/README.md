# miwd: motion-brief

Doc type: **motion-brief** (brief in support of a Rule 12(b)(6) motion to dismiss, with its memorandum) in the United States District Court for the Western District of Michigan (`miwd`).
Folder: `courts/sixth-circuit/michigan/federal/western-district/motion-brief/`. Self-contained: it does not touch the court root (`court.json`, `typst/`, `samples/`, `exemplars/`). The motion itself (the notice of motion, a separate filing that states the relief sought, FRCP 7(b)(1)) is not produced here.

| Item | Status |
|---|---|
| exemplar | yes: 2 filers, `exemplars/FILED-EXAMPLE-valenzuela-alliance-1-26-cv-1694-motion-brief.pdf` (primary, Barnes & Thornburg for Alliance Cloud) and `exemplars/FILED-EXAMPLE-coddington-skopos-1-25-cv-100-motion-brief.pdf` (second filer, Biles Wilson for Skopos). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-valenzuela-brief.md`: the full 11-page filing's body (concise statement through conclusion, footnote, signature); TOC generated; TOA not transcribed |
| render | ok: `samples/OUTPUT-valenzuela-brief.pdf`, 8 pages (cover, contents, 6 body pages), typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-valenzuela-brief.pdf` and `samples/OVERLAY-valenzuela-brief.txt` (against the primary exemplar) |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed; see the review below) |

Build, from the repo root (`PATH` must include the toolchain):

```sh
sh tools/render.sh courts/sixth-circuit/michigan/federal/western-district/motion-brief samples/INPUT-valenzuela-brief.md
sh tools/overlay.sh courts/sixth-circuit/michigan/federal/western-district/motion-brief valenzuela-brief exemplars/FILED-EXAMPLE-valenzuela-alliance-1-26-cv-1694-motion-brief.pdf
```

The tools write `samples/OUTPUT-<id>.pdf` and `samples/OVERLAY-<id>.pdf`/`.txt`. The brief names these `<id>.pdf` and `<id>-overlay.pdf`; the tools (which this box must not edit) use the `OUTPUT-`/`OVERLAY-` names, so those are what is delivered.

## Governing rules

Verified 2026-10-14.

| Rule | Requirement | Source | Where in the template |
|---|---|---|---|
| LCivR 7.2(a) | A motion to dismiss for failure to state a claim is a dispositive motion. | Local Civil Rules, as posted: https://www.miwd.uscourts.gov/sites/miwd/files/Local%20Civil%20Rules.pdf (text dated "Updated February 1, 2018"; the court's rules page shows last modified January 1, 2019) | Scope of this doc type. |
| LCivR 7.2(b) | A brief in support of a dispositive motion is at most 25 pages, exclusive of cover sheet, tables and indices. | same | `max-body-pages = 25`. The template measures the pages from the first page of the brief to the last and fails the build over 25 (`assert` in `typst/miwd-motion-brief.typ`). |
| LCivR 7.2(c) | Reply brief may be filed within 14 days, not more than 10 pages. | same | Not produced (a separate filing). |
| LCivR 7.2(d) | A request for oral argument goes in the caption and in the heading of the brief. | same | `oral_argument_requested` frontmatter, printed under the case number. |
| LCivR 7.1(a) | A brief states the concise reasons in support of the party's position and cites the rules and authorities relied on. | same | Author content. |
| LCivR 7.1(d) | Concurrence certificate is required for non-dispositive motions only. | same | Not required here (not produced). |
| LCivR 10.1 | Double spaced, 8 1/2 x 11, one side; type no smaller than 12 point; margins at least one inch. | same | `type-size`, `pitch`, `margin`, `body-leading`. Footnotes are 12 point too. |
| LCivR 10.3 | Date of signing and the address and telephone number of the signing attorney. | same | `signature` frontmatter. |
| LCivR 5.7(d)(i) | Electronically filed documents must be in PDF digital format. | same | Render is PDF (`typst compile`). |
| Fed. R. Civ. P. 7(b)(1) | A motion must state with particularity the grounds and the relief sought. | https://www.law.cornell.edu/rules/frcp/rule_7 (verified 2026-10-14) | Author content; the brief's concise statement (section I) states the grounds. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. The title of other papers may name the first party on each side. | https://www.law.cornell.edu/rules/frcp/rule_10 (verified 2026-10-14) | `court-title`, `caption`. |
| Fed. R. Civ. P. 11(a) | Paper signed by an attorney of record, stating the signer's address, e-mail address and telephone number. | https://www.law.cornell.edu/rules/frcp/rule_11 (verified 2026-10-14, lead-in text) | `signature-block`. |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim may be raised by motion made before pleading. | https://www.law.cornell.edu/rules/frcp/rule_12 (verified 2026-10-14, lead-in text) | Author content. |

Not produced: the notice of motion and its order, the certificate of service, the Rule 7.1 disclosure statement (for a nongovernmental corporate party), the civil cover sheet, and the Rule 5.2 redactions (author responsibility).

## Layout (as built)

- Cover (page 1, no number): court title centered (three lines), the caption (parties in the left column closed by a rule; case number, judge and "ORAL ARGUMENT REQUESTED" in the right column), then the title of the brief, bold and centered, below the caption.
- Contents (page i): "TABLE OF CONTENTS" centered, "Page" at the right, then the generated outline of the level 1 and level 2 headings with dot leaders and page numbers.
- Body (pages 1 to 6): double spaced, first-line indent 0.5 in. Headings: level 1 bold capitals with a hanging number (I., II., ...), level 2 bold with its number indented (A., B., ...), level 3 (1., 2., ...) and level 4 (a., b., ...). The numbers come from the template, never the sample.
- Signature: "Dated" on the left; the firm, "/s/" and the signer and remaining lines on the right, kept unbreakable with the final paragraph.
- Page numbers: none on the cover, roman on the contents, arabic from the first page of the brief (restarting at 1), centered at the foot.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Fields: `case_number`, `judge` (both print a blank line when empty), `division`, `caption.parties` (list of `{names, designation}`; "v." between parties), `title`, `oral_argument_requested` (true or absent), `date`, `signature` (`firm` list, `signer` string, `lines` list).
- Body: blank-line-separated chunks. `#` level 1 heading, `##` level 2, `###` level 3, `####` level 4; body paragraphs; block quotations (`>`, single spaced, indented); footnotes (`text[^key]` with `[^key]: text` anywhere in the body; the template attaches each definition to the chunk that references it).
- Do not type heading numbers or the TOC. Escape pin cites that start with an asterisk (`at \*5`), or markdown reads them as emphasis.
- Not supported: tables, images, raw typst.

## Review (Gate 2 equivalent, current PDF)

Each page was rendered at 60 dpi and viewed. Compared with the primary exemplar (Valenzuela, filed 07/24/26); the page pairing follows the overlay map.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 (cover) | Valenzuela p.1 | Court title, caption with rule, case number and judge, "ORAL ARGUMENT REQUESTED", title below the caption. The filed cover carries the page number "1"; ours has none. | ACCEPTED (cover unnumbered, a common convention; no rule either way) |
| 2 (contents) | Valenzuela p.2 (TOC), p.3 to 4 (TOA) | The entries and headings match the filed contents. Page numbers match for I to IV and for A and B (1, 1, 2, 2, 3, 5); V is on our page 6 and the filing's page 7, because the body text is laid out differently (tier 2/3). The filed table of authorities is absent: see Gap 1. | OPEN (TOA not generated) |
| 3 (body 1) | Valenzuela p.5 | Concise statement and background; footnote 1 on the page that carries its reference; italic case names. | PASS |
| 4 (body 2) | Valenzuela p.6 | Background end, legal standard, argument introduction. | PASS |
| 5 (body 3) | Valenzuela p.7 | Heading A (two lines, bold, hanging number), its text. | PASS |
| 6 (body 4) | Valenzuela p.9 | Argument A continued; citations with *id.* and signals in italics. | PASS |
| 7 (body 5) | Valenzuela p.10 | Heading B (two lines), its text. | PASS |
| 8 (body 6) | Valenzuela p.11 | Heading V (CONCLUSION), the conclusion, the date and signature block kept together. | PASS |

Tier-2 items recorded as accepted or open:

- **Table of authorities (OPEN).** The filed brief has one; the template does not generate one. A TOA needs a citation registry (as in the ca9 template: each citation is linked with its authority key and its page recorded), which this doc type does not have. LCivR 7.2(b) excludes tables from the page limit and no local rule requires one, so the brief is complete without it, but the clerk's expectation for an 11-page brief is that it has one. The exemplar's TOA is the target.
- **Caption (ACCEPTED).** The second filer (Coddington) uses a section-mark (§) column between the parties and the case number; the template uses a party column closed by a rule, as in the complaint. Both forms appear in this district's filings (tier-2 choice).
- **Font (ACCEPTED).** The filed brief is in a Times-style face; the template uses EB Garamond, the only vendored font. LCivR 10.1 sets 12 point, which is met. See the complaint README for the same question.

## Overlay (`samples/OVERLAY-valenzuela-brief.pdf`)

Red is our render, blue is the filed exemplar, black is where both agree. Pages are paired by shared words: ours p.1 with filed p.1 (91.8%), p.2 with p.2 (89.4%), p.3 with p.5 (91.6%), p.4 with p.6 (76.8%), p.5 with p.7 (60.1%), p.6 with p.9 (52.5%), p.7 with p.10 (55.7%), p.8 with p.11 (67.4%). The page map is in `samples/OVERLAY-valenzuela-brief.txt`. The contents page overlays the filed contents and, in blue only, the filed table of authorities that we do not produce. The overlay is a diagnostic, not a score.

## Known gaps

1. **No table of authorities** (OPEN, above). The exemplar's TOA is the target. The sample does not transcribe it.
2. **Proposed local rule: 10,800 words, not pages.** Administrative Order 26-RL-054 (June 26, 2026; comment period closed July 27, 2026; https://www.miwd.uscourts.gov/sites/miwd/files/Admin%20Order%2026-RL-054.pdf) proposes replacing the 25-page limit of LCivR 7.2(b) with a 10,800-word limit (headings, footnotes and citations counted; the caption, tables, signature block and exhibits excluded) and a certificate of compliance stating the word count and software. I did not find a final adopted version. The template enforces the in-effect 25-page limit only. If the word limit is adopted, the template must count words and print the certificate before landing.
3. **Italics are our marking.** Case names and signals are italic by citation convention. The filed text layer has no italic markup and I did not check the typeface span by span, so the italics are not a transcription of the filing.
4. **Font** (above).
5. **Not produced:** the notice of motion, the certificate of service, the Rule 7.1 disclosure statement, the certificate of concurrence (not required for a dispositive motion, LCivR 7.1(d)), the proposed order.
6. **Checker not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`, and this doc-type folder has neither. The brief forbids editing `tools/`, so the gates were not run; the review above stands in for Gate 2.
7. **Cover numbering.** The filed cover shows "1", and the body restarts at 1 after the contents. Ours leaves the cover unnumbered and starts the body at 1. Both appear in W.D. Mich. filings; this is tier-2.

## Searches (exemplar)

CourtListener search for W.D. Mich. motions and briefs in support of a motion to dismiss (`court=miwd`, RECAP `type=r`, filed 2024 to 2026). Downloaded and checked for a text layer: Valenzuela (11 pp., text), Coddington (26 pp., text), and Moser (64 pp., Attorney General, set aside because it runs well past the 25-page limit of a single brief). The other search hits were not downloaded. Chosen: Valenzuela (primary) and Coddington (second filer).
