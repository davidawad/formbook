# ksd: motion brief (memorandum in support of a motion to dismiss)

Doc type: **motion-brief**, the memorandum in support of a Rule 12(b) motion, in the United States District Court for the District of Kansas (`ksd`).
Folder: `courts/tenth-circuit/kansas/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer: Morris Laing Law Firm for Laird Noller Automotive, Inc.; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole memorandum, 11 pages, transcribed (case names and signals italic as the filed copy sets them) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 12 pages each, vendored Times New Roman only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with D. Kan.'s local rules overlaid in `typst/layout.yaml` (fb-595.17.19) |
| overlay | `just overlay courts/tenth-circuit/kansas/federal/district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 12 of 12 on typst, latex and docx (every page of the three renders viewed side by side at 40 dpi after the move onto the FRCP base, 2026-10-29) |

## Governing rules

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D. Kan. R. 5.1(a) | Papers are letter-size, double-spaced, in no less than 12-point (10-point for footnotes), "Times New Roman or similar," uncompressed font. Source: https://www.ksd.uscourts.gov/sites/ksd/files/MASTER%20COPY%20updated%204%2027%2026.pdf (Rules of Practice, "As amended 4/1/26"; text checked 2026-10-14). | The base: letter, 12 pt (footnotes too); `typst/layout.yaml` `pitch: {body: 27.6}` (twice the 13.8 pt single line, the exemplar's text pitch); `font-family` ("Times New Roman", "Liberation Serif") in `typst/ksd-motion-brief.typ`. |
| D. Kan. R. 5.1(b) | Signature block: names, addresses, telephone, facsimile and email; attorneys' registration numbers. | The base's `closing` prints the lines the sample gives (`signature.blocks`). Facsimile and registration numbers are author content (not asserted; see Known gaps). |
| D. Kan. R. 5.1(f) | Certificate of service states the name and address of each person served, the capacity in which served, the manner of service, and the date. | `after_tail` (`when: service`): each recipient's name, address, "Capacity:" and "Manner of service:"; `typst/ksd-motion-brief.typ` stops the render if a recipient lacks one of them or the date is missing. |
| D. Kan. R. 7.1(a) | The brief must contain (1) a statement of the specific relief sought, (2) a statement of the nature of the matter, (3) a concise statement of the facts with record references, and (4) the argument, referring to all authorities relied on. Same source. | `checks: {sections: ["CONCLUSION"]}` stops the render in every engine without a CONCLUSION (the relief); the typst template also asserts a level-1 heading naming the facts or background. Items (2) and (4) are author content. |
| D. Kan. R. 7.1(d)(3) | Principal brief in support of a motion other than discovery, summary judgment or class certification: 15 pages at most. Same source. | `eval.yaml` `params.page_limit: 15` (DEF-LEN-001, every engine), counted with the certificate of service (the conservative reading). |
| Fed. R. Civ. P. 5(d)(1)(B) | No certificate of service is required when a paper is served by filing it with the court's electronic-filing system; other service needs one. Source: https://www.law.cornell.edu/rules/frcp/rule_5 (text checked 2026-10-14). | The certificate is optional (`service` in the frontmatter). The sample has one because the recipient (the plaintiff) is served by email. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number. | `front` in `typst/layout.yaml`, the D. Kan. form (below). |

Not produced by this template: a motion (a separate filing; this template is the memorandum), a proposed order, a certificate of compliance (D. Kan. has no word limit for this motion), a table of contents or table of authorities (no D. Kan. rule requires them for a memorandum of 15 pages or fewer), and the exhibit index required by D. Kan. R. 7.1(e) when exhibits are attached (the sample attaches none).

## Layout

The generic FRCP brief with D. Kan.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there):

- Letter paper, 1-inch margins on all sides, no pleading paper (D. Kan. does not require it). Page number centered at the foot of every page.
- Caption in the exemplar's form: the court's name (two centered bold lines); the parties at the left (designation an inch in, "v." between them), a column of ")" as tall as theirs, "Case No." at the right centered on their height, a rule under the parties and their ")"; then the title in centered bold capitals, underlined.
- Body double-spaced at 27.6 pt, with a 0.5-inch first-line indent on every paragraph.
- Headings: level 1 centered bold capitals, unnumbered; level 2 bold "A.", level 3 bold "1." half an inch in, level 4 italic "a." an inch in, each label in a half-inch box with the title hanging after it. The template numbers them; the author types no letters.
- Block quotations: single-spaced, indented 0.5 inch on both sides, a double line after. Footnotes 12 pt, single-spaced, under a 30 % rule.
- Signature (the base's closing): "Respectfully submitted," at the body pitch, then at the right the firm, a signature line, the signer's block and the role lines; kept with the body's last paragraph.
- Certificate of service (optional): centered bold heading; the author's text; each recipient's name, address, capacity and manner half an inch in; the signer's "/s/" line and name at the right. Kept whole.

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `case_number` | yes | "Case No." in the caption (`case_label` changes the label) |
| `caption.parties` | yes | list of `{names, designation}`; `names` one string, a newline between lines; "v." is inserted between parties |
| `brief_title` | yes | the centered title (printed in capitals) |
| `signature.date_line` | yes | the line before the signature ("Respectfully submitted,") |
| `signature.firm` | no | the firm, above the signature line |
| `signature.blocks` | yes | a list of signer blocks, each a list of lines (the "/s/" line first) |
| `signature.counsel_for` | no | the role lines; a newline starts a line; `*...*` is italic |
| `service` | no | certificate of service: `date`, `text` (the author's paragraph), `signer`, `signer_name`, `recipients` (each `name`, `address` (list), `capacity`, `manner`) |

**Body**: the text before the first heading is an unnumbered opening paragraph. `# HEADING` (level 1), `## Heading` (level 2), `### Heading` (level 3), `#### Heading` (level 4). Footnotes as `[^key]` with `[^key]: text`. Case names and signals in `*...*`, as the filed copy sets them. Not supported: raw typst.

## Known gaps and open choices

1. **One filer.** Tier 2 asks for 2 or 3 filers; one exemplar is saved.
2. **Margins.** The D. Kan. rules set no margin. One inch (the base) was chosen; the exemplar's margins were not measured.
3. **Page limit.** DEF-LEN-001 counts every page, the certificate of service included; if D. Kan. does not count it, the check is stricter than the rule. The rule does not say which pages count.
4. **Additions to the certificate.** The filed certificate gives the recipient's name, address and email, and says the copy was "sent via email," but states no capacity. D. Kan. R. 5.1(f)(2) requires the capacity, so the sample adds "Capacity: Plaintiff" (from the caption) and "Manner of service: email" (from the certificate's text). These two lines are the only text not in the filed copy.
5. **Facsimile and registration numbers.** D. Kan. R. 5.1(b)(1)(D) lists facsimile numbers, and R. 5.1(b)(2) lists attorneys' registration numbers. The filed copy has them, so the sample carries them; the template does not check that they are present.
6. **Signature column.** The exemplar sets "Respectfully submitted," and the firm in the signature column; the base sets the closing line at the left margin's indent and the firm above a signature line at the right. Tier 3 (one filer's style).
7. **Combined motion.** The memorandum is a separate filing from the motion (Doc. 6 and Doc. 7). A combined motion and brief would need the motion's own relief statement, which this template does not produce.
8. **Self-test.** There is no `check-selftest.sh` run: the doc-type folder has no `court.json`.

## Gate 2 review (2026-10-29, the three renders after the move onto the FRCP base, every page)

| Page | Content | Finding | Status |
|---|---|---|---|
| 1 | Court name, caption with ")" column and the rule under the parties, "Case No.", title in two lines, opening paragraph, INTRODUCTION | none | PASS |
| 2 | Introduction (end); STATEMENT OF FACTS | none | PASS |
| 3 | Facts (end); ARGUMENTS AND AUTHORITIES; A. STANDARD OF REVIEW | none | PASS |
| 4 | Standard of review (end); B. | none | PASS |
| 5 | C. (two-line heading, hanging); italic case names | none | PASS |
| 6 | C. (end); D. (two-line heading) | none | PASS |
| 7 | D. (end) | none | PASS |
| 8 | E. (two-line heading) | none | PASS |
| 9 | E. (end); F. (two-line heading) | none | PASS |
| 10 | G.; the injunction paragraphs | none | PASS |
| 11 | G. (end); CONCLUSION; signature (Respectfully submitted, firm, signature line, "/s/" block, italic role lines) | Closing line at the left, not in the signature column (Known gaps 6) | ACCEPTED |
| 12 | CERTIFICATE OF SERVICE: the text, the recipient's name, address, capacity and manner, the "/s/" line | none | PASS |

## Engines

typst (`typst/ksd-motion-brief.typ` names the face and asserts the rules; `typst/layout.yaml` the D. Kan. overlay); latex (`latex/template.tex`, `latex/xdoc.lua`) and docx (`docx/reference.xml`, `docx/xdoc.lua`) generated by `fb engines gen` from the merged layout. `params.cross_engine: gate` in `eval.yaml`.

- typst: `RESULT: 12 checks passed, 0 failed`.
- latex: `RESULT: 15 checks passed, 0 failed`; XENG-001..003 PASS (12 pages, 282/282 typst lines break after the same word).
- docx: `RESULT: 16 checks passed, 0 failed`; XENG-001..003 PASS (12 pages, 282/282).
- The facts-heading and certificate assertions run in typst only; the CONCLUSION section check and the page limit run in every engine.
- BLOCKED: none.
