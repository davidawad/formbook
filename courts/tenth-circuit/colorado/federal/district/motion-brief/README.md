# cod: motion-brief (motion to dismiss with memorandum)

Doc type: **motion-brief** in the United States District Court for the District of Colorado (`cod`): a Fed. R. Civ. P. 12(b)(6) motion to dismiss whose argument is in the same document (the memorandum). Folder: `courts/tenth-circuit/colorado/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-sussman-1-26-cv-02065-motion-brief.pdf` (one filer: Sussman v. Miller, Defendants' motion; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-sussman-motion-to-dismiss.md` (a transcription of part of the 16-page filing; see Known gaps) |
| render | ok: `samples/OUTPUT-sussman-motion-to-dismiss.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-sussman-motion-to-dismiss.pdf` and `samples/OVERLAY-sussman-motion-to-dismiss.txt` |
| pages reviewed | 8 of 8 (every page rendered at 60 dpi and viewed after the last template change) |

File names: the sample is `INPUT-<id>.md`, the render is `OUTPUT-<id>.pdf` and the overlay is `OVERLAY-<id>.pdf/.txt`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default (the brief's `<id>.md` / `<id>-overlay.pdf` form was not used for this reason).

Commands (from the repo root, with `PATH="$HOME/tb/bin:$PATH"`):

```sh
sh tools/render.sh courts/tenth-circuit/colorado/federal/district/motion-brief samples/INPUT-sussman-motion-to-dismiss.md
sh tools/overlay.sh courts/tenth-circuit/colorado/federal/district/motion-brief sussman-motion-to-dismiss
```

## Governing rules

Primary source: **D.C.COLO.LCivR** (Local Rules of Practice, Civil, effective December 1, 2025), fetched 2026-10-14 from the court's own PDF, https://www.cod.uscourts.gov/Portals/0/Documents/LocalRules/2025_Final_Local_Rules.pdf. Rule text was read from that PDF's text layer.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| D.C.COLO.LCivR 10.1(b)–(g) | Letter paper; margins 1½ inches top, 1 inch left, right, bottom; black ink and not less than 12-point font; double spaced; one side; legible. | `page-w`, `margin-top`, `margin-side`, `margin-bottom`, `type-size = 12pt` (footnotes too), `body-leading`. |
| Typeface (no face named) | Black ink and not less than 12-point font (10.1(d)); no typeface named in LCivR. D.C.COLO.LPtR 17(a)–(b) names Arial 12-point, but only for briefs in patent cases (see Font note 6). | `font-family = "EB Garamond"`, kept because the civil rules name no face. |
| D.C.COLO.LCivR 7.1(a) | Duty to confer before a motion, with a certificate describing the efforts. | **Not required for this motion**: 7.1(b)(2) excepts "a motion under Fed. R. Civ. P. 12". The `conferral` frontmatter prints a certificate only when the author supplies one (the exemplar's certificate follows the assigned judge's civil practice standards, not the local rule). |
| D.C.COLO.LCivR 7.1(d) | The motion states the rule or statute it is filed under and is supported by legal authority; the motion is a separate document, not part of a response or reply. | The lead-in states "pursuant to Fed.R.Civ.P. 12(b)(6)" (author text). The template makes it a single document. |
| D.C.COLO.LCivR 7.1(e) | Every citation includes the specific page or statutory subsection. | Author content; not checked by the template. |
| D.C.COLO.LCivR 7.1(i) | Motions shall be concise. | Author content; not checked. |
| D.C.COLO.LCivR 5.1(a), (d) | CM/ECF formatting and filing. The NEF is the certificate of service for CM/ECF service; a separate certificate is needed for a party not served that way. | `service` frontmatter prints a certificate for the pro se party served by email. |
| Fed. R. Civ. P. 7(b)(1) | A motion must be in writing, state with particularity the grounds, and state the relief sought. Text checked at https://www.law.cornell.edu/rules/frcp/rule_7 on 2026-10-14. | Author content. The WHEREFORE paragraph (sample) states the relief. |
| Fed. R. Civ. P. 8(a)(2) | Short and plain statement of the claim (cited in the argument). | Author content. |
| Fed. R. Civ. P. 10(a) | Caption with court name, title, file number, Rule 7(a) designation. | `caption()`. |

Page limits: the 2025 local rules set none for district-court motions (the only page limit in the text is in the AP, Social Security appeal rules, D.C.COLO.LAPR). Individual judges' practice standards may set one. Those were not checked and are not asserted.

## Layout

- Letter size; top margin 1½ inches; left, right and bottom 1 inch; centered page number in the bottom margin.
- Caption as in the complaint: court name in two centered lines, `Civil Action No.`, party block (names, designation indented, `v.` between sides), title centered in bold capitals.
- Lead-in paragraph (the "Defendants ... hereby submit their Motion ... and state as follows:" paragraph), then the optional certificate (heading `CERTIFICATE OF COMPLIANCE` by default, centered and bold), then the body.
- Body double spaced, first-line indent 0.5 inch. Section numbers are typed by the template: level 1 "I." (centered bold capitals), level 2 "A." (bold, left), level 3 "1." (bold, indented), level 4 "a.". Block quotations single spaced and indented 1 inch each side. Footnotes 12 pt.
- Signature block after the body: "Respectfully submitted this ... day of ..." then each signer as `s/ Name`, name and contact lines, then the role line (for example "Attorneys for Defendants").
- Certificate of service (optional): centered bold heading, body text, the party block single spaced and indented, the signer's `/s/` line and title.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`, `caption` (list of `{names: [...], designation}`; "v." is inserted between sides), `title`, `lead_in` (markdown, optional), `conferral` (markdown, optional), `conferral_heading` (optional), `signature` (`intro`: list of lines; `signers`: list of `{name, lines, sig_line}`; `role`), `service` (optional: `heading`, `text` markdown, `party_lines`, `signer_lines`).
- Body: markdown. `#` is level 1, `##` level 2, `###` level 3, `####` level 4; the template numbers them. Case names and signals in italics (`*Kay v. Bemis*`, `*Id.*`). Footnotes `[^1]` with `[^1]: text` definitions anywhere in the file (supported; the motion template renders the whole body at once).
- Not supported: tables, raw typst, images.
- Escape markdown markers at the start of a paragraph and asterisks in citations (`at \*4`), as in any markdown.

## Known gaps and open choices

1. **One filer, not two or three.** EVAL-LOOP's tier-2 rule asks for exemplars from 2 or 3 different filers. CourtListener (RECAP, `court=cod`) also has these motions to dismiss, not saved: Ring v. Pinnacle Holdings, Ltd., 1:26-cv-01090 (Doc. 28, 16 pp, Word); Fish v. Entrata, Inc., 1:26-cv-02416 (Doc. 11, 18 pp, Acrobat Distiller); Brooks v. Nissan North America, Inc., 1:26-cv-01385 (Doc. 41, 22 pp); Teixeira v. Federal Bureau of Prisons, 1:26-cv-02158 (18 pp). Tier 2 is therefore **not** judged against 2 or 3 filers yet.
2. **Sample is a transcription of part of the filing.** Included: the lead-in, the certificate of compliance, Introduction, Standard of Review, Alleged Facts (with footnotes 1–4 and the paragraph in the filing that sits between the block of facts and footnote 1 omitted), Argument IV.A, IV.B (with B.1 and B.2, footnote 5), the Rule 8 argument, WHEREFORE, the signature block and the certificate of service. Omitted: Argument B.3 (self-defense), the Argument sections C, D and E of the filing, and the rest of the Alleged Facts.
3. **Section letters differ from the filing.** The Rule 8 argument is "F." in the filing and "C." in the sample, because the template numbers sections in order and the sample omits C–E. The filing also repeats the number "3." under B; that typo is not reproduced.
4. **Paragraph breaks.** The Alleged Facts paragraphs are split as the filing's paragraphs are (the transcription keeps the filing's first sentences, including the one about the deputies arriving at the house). The filing's paragraph breaks were read from the text layer, not from the layout, so a break may differ by a line.
5. **Italics.** Case names are italic in the sample by the template's convention (`*...*` is italic). The filing's italic runs were not checked one by one; the overlay does not check italics.
6. **Font.** EB Garamond (vendored) is used at 12 pt; the filing's body is Times New Roman (per `pdffonts`). The civil rules set no typeface (10.1(d) asks for 12-point or larger), so EB Garamond is kept under the fonts policy (`docs/FONTS.md`: a court that names no face keeps EB Garamond). The one face named in this court's rules is D.C.COLO.LPtR 17(a)–(b), Arial 12-point for claim-construction and dispositive-motion briefs in patent cases; it does not govern this civil rights motion. If this template is used for a brief in a patent case, the face must switch to `Liberation Sans` (metric-compatible Arial). EB Garamond's smaller x-height makes the text look smaller than the exemplar; that is the same choice as the complaint folder and is a question for David (a vendored Times-metric font would remove the difference).
7. **Certificate of compliance.** The sample keeps the filing's certificate, which is required by the judge's practice standards, not by LCivR 7.1(a) (excepted for Rule 12 motions by 7.1(b)(2)). The template prints it only when the frontmatter supplies `conferral`.
8. **Overlay is a diagnostic, not a score.** Page pairs from `samples/OVERLAY-sussman-motion-to-dismiss.txt`: ours p.1 with filed p.1 at 93%; p.2 with p.2 at 76%; p.3 with p.4 at 75%; p.4 with p.5 at 70%; p.5 with p.6 at 46%; p.6 with p.8 at 60%; p.7 with p.15 at 60%; p.8 with p.16 at 64%. The pairs shift because the sample omits parts of the filing; read the overlay for layout, not text.
9. **Not produced.** Proposed order (LCivR 7.1(g): a separate document with its own caption), any notice of hearing or related filing.
10. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the page review below is the Gate 2 equivalent.

## Review of the rendered pages (`OUTPUT-sussman-motion-to-dismiss.pdf`, 8 pages)

- Page 1: caption (plaintiff, `v.`, three defendants), title MOTION TO DISMISS, lead-in, CERTIFICATE OF COMPLIANCE, I. INTRODUCTION heading and first lines. Footer page number. Pass.
- Page 2: INTRODUCTION end; II. STANDARD OF REVIEW; III. ALLEGED FACTS; first paragraphs; footnote 1 at the foot of the page, 12 pt. Pass.
- Page 3: the "See also" paragraph with footnote 2 reference; the "Plaintiff attempts" paragraph with footnotes 3 and 4 at the foot; the Deputy paragraph and the claims paragraph. Pass.
- Page 4: IV. ARGUMENT heading; A. State and Federal Law is Similar.; B. Defendants possessed probable cause.; the probable-cause paragraph. Pass.
- Page 5: continued citations; the block quotation of C.R.S. § 18-3-206 single spaced and indented; B.1 heading (level 3 "1." indented); the next paragraph. Pass.
- Page 6: B.2 "The Body Worn Camera Footage." heading; the paragraph with footnote 5 at the foot. Pass.
- Page 7: C. The Complaint Violates Rule 8. (letter differs from the filing's F., see gap 3); WHEREFORE paragraph. Pass.
- Page 8: signature block (Respectfully submitted, both signers, Attorneys for Defendants); CERTIFICATE OF SERVICE with the pro se party block and the Legal Secretary's `/s/` line. Pass.

Gate 2 rows for these pages are recorded here, not in `reviews/` (this doc type has no `reviews/` folder).

## Engines

**docx** (`docx/`: `build-reference.sh` makes `reference.docx`; `cod.lua` sets the caption, section numbers, the certificates and the signature block). `sh tools/render.sh --engine docx courts/tenth-circuit/colorado/federal/district/motion-brief samples/INPUT-sussman-motion-to-dismiss.md` writes `OUTPUT-sussman-motion-to-dismiss.docx` and `OUTPUT-sussman-motion-to-dismiss.docx.pdf` (LibreOffice 26.8.1; `pdffonts`: EB Garamond only, embedded).

- Matches the typst output: 8 pages, the same as typst. Letter paper; margins as the complaint; 12 pt EB Garamond with 24 pt exact line pitch; caption and title as the complaint; section headings numbered by the template (I. centred caps; A., 1. with a hanging number, as typst); the conferral certificate and the certificate of service (centred bold headings, the party block indented and single spaced); footnotes at 12 pt, single spaced, with superscript references; the block quotation single spaced and indented one inch each side; centred page number in the footer.
- Differs: (a) pagination. Same cause as the complaint: about one line less per page in LibreOffice, so page breaks fall one or two lines earlier (for example page 4 starts with "Plaintiff brings various claims", page 7 starts with "Plaintiff asserts that the deputies"); the page count is the same. Word may break pages differently again. (b) Footnote separator and number spacing are LibreOffice's defaults, not typst's; they look the same at 60 dpi.
- BLOCKED: none. `sh tools/check.sh courts/tenth-circuit/colorado/federal/district --engine docx` cannot run for this court yet: no `checks.yaml` or `rules.md` in the court folder, so no check ID is assessed for the docx engine. This is a gap in the court folder, not a docx failure.
