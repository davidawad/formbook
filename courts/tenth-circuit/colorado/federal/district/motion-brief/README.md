# cod: motion-brief (motion to dismiss with memorandum)

Doc type: **motion-brief** in the United States District Court for the District of Colorado (`cod`): a Fed. R. Civ. P. 12(b)(6) motion to dismiss whose argument is in the same document (the memorandum). Folder: `courts/tenth-circuit/colorado/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (one filer: Sussman v. Miller, Defendants' motion by SGR, LLC; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (a transcription of part of the 16-page filing; see Known gaps) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, `.latex.pdf`, `.docx` and `.docx.pdf`, 10 pages each, vendored Liberation Sans only, no warnings, on the shared document model: the generic FRCP brief `lib/layouts/frcp-motion-brief.yaml` with D. Colo.'s local rules overlaid in `typst/layout.yaml` (fb-595.17.19) |
| overlay | `just overlay courts/tenth-circuit/colorado/federal/district/motion-brief` writes `.overlay/.../OVERLAY-motion-brief.pdf` (not committed) |
| pages reviewed | 10 of 10 on typst, latex and docx (every page of the three renders viewed side by side at 40 dpi after the move onto the FRCP base, 2026-10-29) |

Commands (from the repo root):

```sh
sh tools/check.sh courts/tenth-circuit/colorado/federal/district/motion-brief                 # typst
sh tools/check.sh courts/tenth-circuit/colorado/federal/district/motion-brief --engine latex
sh tools/check.sh courts/tenth-circuit/colorado/federal/district/motion-brief --engine docx
fb engines gen courts/tenth-circuit/colorado/federal/district/motion-brief                    # after a layout change
```

## Governing rules

Primary source: **D.C.COLO.LCivR** (Local Rules of Practice, Civil, effective December 1, 2025), fetched 2026-10-14 from the court's own PDF, https://www.cod.uscourts.gov/Portals/0/Documents/LocalRules/2025_Final_Local_Rules.pdf. Rule text was read from that PDF's text layer.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.C.COLO.LCivR 10.1(b)–(g) | Letter paper; margins 1½ inches top, 1 inch left, right, bottom; black ink and not less than 12-point font; double spaced; one side; legible. | The base (`lib/layouts/frcp-motion-brief.yaml`): letter, 1 inch margins, 12 pt (footnotes too), 24 pt double pitch, 13.8 pt single lines for the caption, headings, quotations, footnotes and signature; `typst/layout.yaml` `margin: {top: 108}` (1½ in). |
| Typeface (no face named) | Black ink and not less than 12-point font (10.1(d)); no typeface named in LCivR. D.C.COLO.LPtR 17(a)–(b) names Arial 12-point, but only for briefs in patent cases (see Known gaps 6). | `font-family = "Liberation Sans"` in `typst/cod-motion-brief.typ` (Arial's metrics, the audited exemplar's face, `data/exemplar-fonts.json`); the generated latex and docx engines name it from there. |
| D.C.COLO.LCivR 7.1(a) | Duty to confer before a motion, with a certificate describing the efforts. | **Not required for this motion**: 7.1(b)(2) excepts "a motion under Fed. R. Civ. P. 12". The `conferral` frontmatter prints a certificate under the opening paragraph only when the author supplies one (`front`, `when: conferral`; the exemplar's certificate follows the assigned judge's civil practice standards, not the local rule). |
| D.C.COLO.LCivR 7.1(d) | The motion states the rule or statute it is filed under and is supported by legal authority; the motion is a separate document, not part of a response or reply. | The `lead_in` paragraph states "pursuant to Fed.R.Civ.P. 12(b)(6)" (author text), set under the title (`front`). The template makes a single document. |
| D.C.COLO.LCivR 7.1(e) | Every citation includes the specific page or statutory subsection. | Author content; not checked by the template. |
| D.C.COLO.LCivR 7.1(i) | Motions shall be concise. | Author content; not checked. |
| D.C.COLO.LCivR 5.1(a), (d) | CM/ECF formatting and filing. The NEF is the certificate of service for CM/ECF service; a separate certificate is needed for a party not served that way. | `after_tail` (`when: service`): the certificate, the party served half an inch in, the signer at the right; kept whole. |
| Fed. R. Civ. P. 7(b)(1) | A motion must be in writing, state with particularity the grounds, and state the relief sought. Text checked at https://www.law.cornell.edu/rules/frcp/rule_7 on 2026-10-14. | Author content. The WHEREFORE paragraph (sample) states the relief. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number, Rule 7(a) designation. | `front` in `typst/layout.yaml`, the D. Colo. form: the court's name (`constants`), `Civil Action No.`, the parties, the title between two rules. |
| Fed. R. Civ. P. 11(a) | Signed by an attorney of record, with address, e-mail and telephone. | The base's `closing`: the date line, a signature line and each signer's block at the right, kept with the body's last paragraph. |

Page limits: the 2025 local rules set none for district-court motions (the only page limit in the text is in the AP, Social Security appeal rules, D.C.COLO.LAPR). Individual judges' practice standards may set one. Those were not checked and are not asserted.

## Layout

The generic FRCP brief with D. Colo.'s overlay (`typst/layout.yaml`; every value has its rule in a comment there):

- Letter size; top margin 1½ inches; left, right and bottom 1 inch; centered page number in the bottom margin, in a single-spaced line.
- Caption in the D. Colo. form: the court's name in two centered bold lines; a double line below, `Civil Action No.`; a double line below, the parties (each party's names, its designation half an inch in a single line below, `v.` between them a single line from each); then the title centered in bold between two rules across the page. Single lines (13.8 pt).
- The opening paragraph (`lead_in`, "Defendants ... hereby submit their Motion ... and state as follows:") under the title, then the optional certificate of conferral (`conferral`, heading `conferral_heading`, centered bold), then the body.
- Body double spaced (24 pt lines), first-line indent 0.5 inch. Sections numbered by the template: level 1 "I." (centered bold capitals with its number); level 2 "A." (bold, the label in a half-inch box at the margin, the title hanging after it); level 3 "1." the same, half an inch in. Headings single-spaced, a single line above and below, kept with the next block. Block quotations single spaced and indented 1 inch each side. Footnotes 12 pt, single-spaced, 7 pt apart under a 30 % rule. The last paragraph of the body is kept with the signature block.
- Signature (the base's closing): the date line ("Respectfully submitted this ...") at the body pitch, then at the right a signature line and each signer's block (an `s/` line, the name and contact lines), then the role line; kept on one page.
- Certificate of service (optional, `service`), after the signature and kept whole: centered bold heading, the certificate at the body pitch, the party served single spaced half an inch in, the signer's lines at the right.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter (the base's): `case_number`, `case_label` (optional, default `Civil Action No.`), `caption.parties` (list of `{names, designation}`; `names` one string, a newline between lines; "v." is inserted between parties), `brief_title`, `signature` (`date_line`; `firm` optional; `blocks`: a list of signer blocks, each a list of lines, the first the `s/` line; `counsel_for` optional). D. Colo.'s: `lead_in` (optional), `conferral` and `conferral_heading` (optional, default `CERTIFICATE OF CONFERRAL`), `service` (optional: `text`, `served`: a list of entries, each lines joined by newlines, `signed`: the signer's lines).
- Body: markdown. `#` is level 1, `##` level 2, `###` level 3; the template numbers them. `>` starts a block quotation. Case names and signals in italics (`*Kay v. Bemis*`). Footnotes `[^1]` with `[^1]: text` definitions.
- Escape markdown markers at the start of a paragraph and asterisks in citations (`at \*4`), as in any markdown.

## Known gaps and open choices

1. **One filer, not two or three.** EVAL-LOOP's tier-2 rule asks for exemplars from 2 or 3 different filers. CourtListener (RECAP, `court=cod`) also has these motions to dismiss, not saved: Ring v. Pinnacle Holdings, Ltd., 1:26-cv-01090 (Doc. 28, 16 pp, Word); Fish v. Entrata, Inc., 1:26-cv-02416 (Doc. 11, 18 pp, Acrobat Distiller); Brooks v. Nissan North America, Inc., 1:26-cv-01385 (Doc. 41, 22 pp); Teixeira v. Federal Bureau of Prisons, 1:26-cv-02158 (18 pp). Tier 2 is therefore **not** judged against 2 or 3 filers yet.
2. **Sample is a transcription of part of the filing.** Included: the lead-in, the certificate of compliance, Introduction, Standard of Review, Alleged Facts (with footnotes 1–4 and the paragraph in the filing that sits between the block of facts and footnote 1 omitted), Argument IV.A, IV.B (with B.1 and B.2, footnote 5), the Rule 8 argument, WHEREFORE, the signature block and the certificate of service. Omitted: Argument B.3 (self-defense), the Argument sections C, D and E of the filing, and the rest of the Alleged Facts.
3. **Section letters differ from the filing.** The Rule 8 argument is "F." in the filing and "C." in the sample, because the template numbers sections in order and the sample omits C–E. The filing also repeats the number "3." under B; that typo is not reproduced.
4. **Paragraph breaks.** The filing's paragraph breaks were read from the text layer, not from the layout, so a break may differ by a line.
5. **Italics.** Case names are italic in the sample by convention (`*...*`). The filing's italic runs were not checked one by one.
6. **Font.** Liberation Sans (vendored, Arial's metrics) at 12 pt, the face of the audited exemplar (Arial; `data/exemplar-fonts.json`, which `fb lint fonts` checks the template against). `docs/FONTS.md` rule 6 (Times New Roman where the rules name no face) would move this template to Times New Roman; that needs a `template_face` entry for this exemplar in `data/exemplar-fonts.json` (a shared file) and is left for that decision. Liberation Sans has its own superscript digits for some numbers; the template synthesizes footnote marks (`set super(typographic: false)`), as LaTeX and Word set them.
7. **Certificate of compliance.** The sample keeps the filing's certificate, which is required by the judge's practice standards, not by LCivR 7.1(a) (excepted for Rule 12 motions by 7.1(b)(2)). The template prints it only when the frontmatter supplies `conferral`.
8. **Signature line.** The base sets one signature line above the signers' blocks; the exemplar rules each signer's `s/` line. Tier 3 (one filer's style).
9. **Not produced.** Proposed order (LCivR 7.1(g): a separate document with its own caption), any notice of hearing or related filing.
10. **Self-test.** There is no `check-selftest.sh` run: the doc-type folder has no `court.json`.

## Gate 2 review (2026-10-29, the three renders after the move onto the FRCP base, every page)

| Page | What is on it | Finding | Status |
|---|---|---|---|
| 1 | Court name, Civil Action No., parties, title between rules, lead-in, CERTIFICATE OF COMPLIANCE, I. INTRODUCTION and its first lines | The exemplar sets "I." a tab before its centered title; ours centers number and title together (`eval.yaml` `cover_structure_accepted`, tier 3) | ACCEPTED |
| 2 | Introduction end; II. STANDARD OF REVIEW; III. ALLEGED FACTS | none | PASS |
| 3 | Facts with footnotes 1–4 at the foot, 12 pt | none | PASS |
| 4 | IV. ARGUMENT; A. State and Federal Law is Similar | none | PASS |
| 5 | B. Defendants possessed probable cause; the C.R.S. § 18-3-206 block quotation, single spaced, an inch in on each side | none | PASS |
| 6 | B.1 heading, half an inch in; argument | none | PASS |
| 7 | B.2 heading; footnote 5 at the foot | none | PASS |
| 8 | C. The Complaint Violates Rule 8; the page ends after it | The WHEREFORE paragraph is kept with the signature block on page 9, which leaves the lower half of page 8 empty (as before the move) | OPEN |
| 9 | WHEREFORE paragraph; signature (date line, signature line, both signers, Attorneys for Defendants) | none | PASS |
| 10 | CERTIFICATE OF SERVICE, the pro se party served, the Legal Secretary's `/s/` line | Kept whole, so it takes its own page | PASS |

## Engines

typst (`typst/cod-motion-brief.typ` names the face; `typst/layout.yaml` the D. Colo. overlay); latex (`latex/template.tex`, `latex/xdoc.lua`) and docx (`docx/reference.xml`, `docx/xdoc.lua`) generated by `fb engines gen` from the merged layout. `params.cross_engine: gate` in `eval.yaml`.

- typst: `RESULT: 10 checks passed, 0 failed`.
- latex: `RESULT: 13 checks passed, 0 failed`; XENG-001..003 PASS (10 pages, 220/220 typst lines break after the same word).
- docx: `RESULT: 14 checks passed, 0 failed`; XENG-001..003 PASS (10 pages, 220/220).
- BLOCKED: none.
