# FISC: motion (doc type `motion-brief`)

Typst template for a motion filed in the United States Foreign Intelligence Surveillance Court, built from the court's own Rules of Procedure. Scope: publicly released motions (for example, a motion to publish an opinion or to modify a reporting requirement). Other FISC doc types (applications, certifications, petitions, orders) are not covered here.

Status: exemplar=yes (two filed motions), render=ok, overlay=ok, both pages reviewed (9 of 9 rendered pages, all looked at). No `court.json` status change; the court's `court.json` and the court-root `typst/` and `usage/` are untouched.

## Governing rules

Source: FISC Rules of Procedure, effective November 1, 2010, <https://www.fisc.uscourts.gov/sites/default/files/FISC%20Rules%20of%20Procedure.pdf> (index page: <https://www.fisc.uscourts.gov/rules-procedure>, which states the Nov. 1, 2010 rules are current). Verified against the PDF on 2026-10-14. Rule 1 says issues the rules do not address may be resolved under the Federal Rules of Criminal or Civil Procedure; this template does not apply those.

| ID | Rule | Requirement | Where the template implements it |
|---|---|---|---|
| FISC-FILE-001 | R. 6(d) | A party seeking relief other than by application, certification or petition does so "by motion." | Doc type. The title is `brief_title` (frontmatter). |
| FISC-FORM-001 | R. 7(c)(1) | Submissions on 8½ × 11 inch opaque white paper. | `paper: "us-letter"` |
| FISC-FORM-002 | R. 7(c)(2) | "typed (double-spaced)" or reproduced so the image is clear black. | Body leading 1.35 em, giving a 24 pt baseline pitch at 12 pt. Single spacing elsewhere (blocks, headings, captions, signatures). |
| FISC-FILE-002 | R. 7(b) | A signed original and one copy are filed. | Not a document property. Recorded only; the template does not print a copy count. |
| FISC-FILE-003 | R. 7(f) | "Each submission must contain citations to pertinent provisions of the Act." | Not machine-checked (see gaps). |
| FISC-FILE-004 | R. 7(h)(1) | A non-government party's initial submission gives full name, address and telephone of the party or its counsel, and counsel's bar membership. | `counsel` block (names and lines). Bar membership is not a checked field (see gaps). |
| FISC-FILE-005 | R. 8(c) | A certificate of service that specifies the time and manner of service. | `service:` block: `date`, optional `time`, `manner`, `recipients`, `signature`. Printed on its own page. |
| FISC-FILE-006 | R. 7(h)(2) | In an adversarial proceeding, the government's initial submission gives the attorneys' names, mailing addresses, telephone and fax numbers. | `counsel` block; required when `adversarial: true` (the template stops the build otherwise). Not exercised by the government sample, which is non-adversarial. |
| FISC-FILE-007 | R. 7(h)(1) and R. 7(h)(2) | Counsel information is required in an adversarial submission. | Validated: `adversarial: true` without `counsel` stops the build. |
| FISC-FILE-008 | R. 7(i) | A non-government party, in an adversarial proceeding, states whether it and its counsel hold clearances, the circumstances, and the agencies and levels. | `clearance:` text; required when `adversarial: true` and `filer: other` (the template stops the build otherwise). The template prints the text it is given; it does not check that the text covers (1)-(3) (see gaps). |
| FISC-FORM-003 | R. 7(c) (margins) | No margin rule. | Convention: 1 in on all sides. |
| FISC-FORM-004 | R. 7(c) (font) | No typeface or size rule. R. 7(c) requires only 8½ × 11 opaque white paper and "typed (double-spaced)" or a clear black image; it names no face. Checked against the Rules PDF, 2026-10-14. | Typeface row: face required = none; per docs/FONTS.md ("No face named") the template uses Liberation Serif (Times metrics); EB Garamond was dropped because its glyph bounds put body text outside the 1 in margin (DEF-FORM-002). Size: convention 12 pt. Both exemplars are set in a 12 pt serif. |
| FISC-FORM-005 | R. 7 (caption) | No caption rule. | Government and private filers use different court headings in the exemplars. The template follows each (`filer:`). |
| FISC-FORM-006 | R. 7 (headings) | No heading rule. | Convention: level 1 I., II., ...; level 2 A., B., ...; level 3 1., 2., ...; bold, single-spaced. |
| FISC-FORM-007 | R. 7 (caption box) | No caption rule. | Two-column caption: `caption:` lines on the left with a right and bottom rule, `docket:` on the right. |
| FISC-FORM-008 | R. 7 (title) | No title rule. | `brief_title` in bold capitals, centered. |
| FISC-CONT-001 | R. 62(a) | A judge may publish an order or opinion on a party's motion; the Presiding Judge decides. | Relevant to what a motion asks for. No template element. |
| FISC-CONT-002 | R. 63 | Attorneys appearing before the court must hold clearances; the government's attorneys may appear regardless of bar membership. | Covered by the clearance statement in FISC-FILE-008. |
| FISC-CONT-003 | R. 25(b) | No supplements, replies or sur-replies without leave. | Applies to the filing's own practice; no template element. |

Rule 25(a)'s 20-page limit applies to petitions and responses, not motions, so the template sets no length limit.

## Template

- `typst/main.typ`: entry point. `sample=` names the markdown file to render.
- `typst/fisc-motion-brief.typ`: `fisc-motion-brief(meta, md)`. Content-agnostic. Parameters at the top. No case text, no forced line breaks, vendored fonts only. Every number traces to a rule (FISC-...) or a stated convention.

Frontmatter (`usage/*.md`):

| Field | Required | Meaning |
|---|---|---|
| `filer` | yes | `government` or `other`. Chooses the court heading. |
| `adversarial` | no (default `false`) | Enables FISC-FILE-006 to -008. |
| `caption` | yes | List of left-box caption lines. |
| `docket` | yes | Right-hand docket text, for example `Docket No. Misc. 19-02`. |
| `brief_title` | yes | Title, printed in bold capitals. |
| `dated` | no | `Dated: ...` before the signature block. |
| `clearance` | yes if adversarial and `filer: other` | Rule 7(i) statement. |
| `counsel` | yes if adversarial | List of `{names, lines}` groups (Rule 7(h)). |
| `signature` | yes | `lines`: signer lines after "Respectfully submitted,". |
| `verification` | no | `{date, statement, signature}`. Printed on its own page with the 28 U.S.C. § 1746 sentence. |
| `service` | no | `{date, time?, manner, recipients, signature}`. Certificate of service on its own page. |

Build:

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick
sh tools/render.sh courts/national/foreign-intelligence-surveillance-court/motion-brief usage/INPUT-motion-brief.md
sh tools/render.sh courts/national/foreign-intelligence-surveillance-court/motion-brief usage/INPUT-motion-brief-2.md
sh tools/overlay.sh courts/national/foreign-intelligence-surveillance-court/motion-brief accuracy-concerns-misc-19-02 courts/national/foreign-intelligence-surveillance-court/motion-brief/usage/FILED-EXAMPLE-motion-brief.pdf
sh tools/overlay.sh courts/national/foreign-intelligence-surveillance-court/motion-brief yahoo-directives-105b-07-01 courts/national/foreign-intelligence-surveillance-court/motion-brief/usage/FILED-EXAMPLE-motion-brief-2.pdf
```

Naming: the shared tools fix the output names, so outputs follow them rather than the `<id>.pdf` / `<id>-overlay.pdf` pattern in the brief. Render writes `usage/OUTPUT-<id>.pdf`; overlay reads that and writes `usage/OVERLAY-<id>.pdf` and `.txt`.

## Exemplars

| File | Case and filer | Date filed | Sample |
|---|---|---|---|
| `usage/FILED-EXAMPLE-motion-brief.pdf` | Misc. 19-02, Motion to Modify Reporting Period. Government (DOJ National Security Division, Office of Intelligence). | June 4, 2020 (received stamp) | `usage/INPUT-motion-brief.md` |
| `usage/FILED-EXAMPLE-motion-brief-2.pdf` | No. 105B(g) 07-01, Yahoo! Inc.'s Unclassified Motion under FISC Rule 62. Private party. | September 30, 2013 | `usage/INPUT-motion-brief-2.md` |

Sources and searches are recorded in `usage/SOURCE.md`. Both exemplars are scans with an OCR text layer, so `overlay.sh` can pair pages by text. Samples are transcriptions: OCR text, checked against the page images, with the handwritten verification date (June 3, 2020) read from the scan.

## Overlay (the red/blue test)

`usage/OVERLAY-<id>.pdf` is our render (red) over the filed page it pairs with (blue); black is where they agree. `usage/OVERLAY-<id>.txt` is the page map.

Page map (word-overlap by pairing):

- Government sample: ours p.1 ↔ filed p.1 (77%), p.2 ↔ p.2 (52%), p.3 ↔ p.3 (51%), p.4 ↔ p.5 (83%, the verification page).
- Yahoo sample: ours p.1 ↔ filed p.1 (76%), p.2 ↔ p.3 (72%), p.3 ↔ p.4 (89%), p.4 ↔ p.5 (37%: the date, counsel block and Rule 7(i) statement, which the filing does not carry in this form), p.5 ↔ p.6 (100%, the certificate of service).

Word overlap is a pairing aid, not a score. What the overlay shows: the text and page order match page for page. The two are not pixel-aligned: positions and line spacing differ slightly on the page. Those are tier-3 differences and are not chased.

## Page review (Gate 2)

Each rendered page was looked at at 60 dpi. Format: page, observation, status.

Government sample (4 pages):

- p.1: court heading (three centered lines: UNITED STATES, FOREIGN INTELLIGENCE SURVEILLANCE COURT, WASHINGTON, D.C.); caption box with right and bottom rules; docket on the right; title centered in bold capitals; heading I; double-spaced body; page number 1. ACCEPTED: the filed page carries a received stamp, which is not reproduced (see gaps).
- p.2: heading II wraps to two lines and stays bold; body double-spaced; page 2. OK.
- p.3: body ends; "Respectfully submitted," and the three-line signature block to the right. OK. The filed page has a handwritten signature above the name; the template leaves the space and prints no line.
- p.4: verification on its own page: heading, the 28 U.S.C. § 1746 sentence, the declarant block. OK. The filed verification is dated "June 3rd, 2020" in handwriting; the template prints "June 3, 2020".

Yahoo sample (5 pages):

- p.1: private-filer court heading (one line), caption box, title in three bold capitalized lines, heading I. OK.
- p.2: footnote 1 at the foot of the page; italicized case names and *Id.*; the bracketed quote "[FISCR]" is kept. OK.
- p.3: headings II and III; the conclusion ends the page with white space below. The signature block moved to p.4 with the counsel block, so a signature is never stranded from the counsel block it signs for (this was a defect in an earlier render; fixed). OK.
- p.4: "Dated:" line; "Respectfully submitted,"; the signature block; the counsel block (names, firm, address, e-mail); the Rule 7(i) statement. The page is mostly empty after the clearance statement, because nothing follows. OK.
- p.5: certificate of service: time and manner; recipient block; "pursuant to FISC Rule 8 and procedures...". The manner sentence is double-spaced while the recipient block is single-spaced. ACCEPTED: a sentence in double spacing, as in body text.

Fixes made during review (before the final render):

1. Court heading, signature and verification lines overlapped (stack spacing zero against a font natural line box of about 0.65 em). Fixed: stacks use the single-spacing gap.
2. Headings were larger than the body (typst's default heading size). Fixed: headings set to the body size.
3. The Yahoo sample failed to parse: an unquoted caption starting `In re:` read as a YAML mapping. Fixed in the sample by quoting it.
4. Yahoo p.3 stranded the signature from the counsel block (the signature ended one page and the counsel block began the next). Fixed by keeping the signature and counsel blocks in one unbreakable block.

Pages reviewed: 9 of 9 (government 4, Yahoo 5). The last layout change (keeping the signature with the counsel block) moved Yahoo pages 3-4 and changed nothing on the other pages; those pages were re-checked after the change (Yahoo 1, 3, 4, 5; government 3), and the rest were reviewed in the render before it.

## Known gaps and choices

- Classification markings are not reproduced. The exemplars carry "(U)" portion marks and declassification stamps (and a received stamp on the first page). The FISC rules do not mandate a banner (Rule 3 defers to Executive Order 13526). The template has no marking field, and the samples leave out the "(U)" marks.
- Rule 7(f) (citations to the Act): not machine-checked. The government exemplar cites no provision of the Act in its body, and the template does not check for one.
- Rule 7(h)(1) bar membership: not a checked field. The Yahoo exemplar gives counsel's names, firm, address and e-mail, but no bar membership and no telephone number; the sample carries what the filing gives. The template renders `counsel.lines` but does not require bar membership.
- Rule 7(i): the Yahoo exemplar says counsel "holds appropriate security clearance as required by FISC Rule 63" and "presently has access to classified information ... in accordance with applicable security requirements and regulations and applicable orders" of the FISC. It does not state the circumstances, agencies or levels that Rule 7(i)(2)-(3) asks for. The sample's `clearance` field paraphrases the filing's own sentences; it is not a verbatim quote and does not supply the missing details.
- Closing and sections: "Respectfully submitted," is the template's convention, not in the Yahoo exemplar. The template numbers all level-1 headings; the Yahoo exemplar's headings ("Facts", "Argument", "Conclusion") are unnumbered. Both are filed; the template follows the government exemplar.
- Verification wording: the template prints "I declare under penalty of perjury that the foregoing [title] [statement] Executed pursuant to 28 U.S.C. § 1746 on [date]." The statement is supplied in frontmatter, so the sample keeps the filing's own words.
- Font, size, margins and spacing are not set by the rules (FISC-FORM-002 to -004 are conventions). Chosen: Liberation Serif 12 pt, 1 in margins, double spacing.
- The Rules PDF's ModDate is 2014, but the court's own page says the Nov. 1, 2010 rules are current. No later amendment is listed there. If the court amends them, FISC-FILE and FISC-FORM citations need a re-check.
- Not run: `tools/check.sh`, `tools/check-selftest.sh` and `tools/tracker.sh`. This doc type has no `checks.yaml` or gate scripts, and the brief excludes the tracker. Validation here is the render (no typst warnings), the overlay, and the page review above.
- Samples are transcriptions of two filed motions, not generalized templates. A third, fictional sample for checking that the template is content-agnostic is not included.

## Engines

### typst (primary)

As above: `typst/fisc-motion-brief.typ`, rendered with `sh tools/render.sh`. Page counts: government sample 4, Yahoo sample 5.

### docx (checked with LibreOffice only)

Build and render:

```sh
sh tools/render.sh --engine docx courts/national/foreign-intelligence-surveillance-court/motion-brief usage/INPUT-<id>.md
```

fb render (behind `tools/render.sh --engine docx`) builds the reference document from `docx/reference.xml` (pandoc's default reference with the styles replaced: the typst face, Liberation Serif, at 12 pt, 24 pt body, 15.6 pt single blocks, footer PAGE field; `docx/build-reference.sh` did this until fb-595.68), then runs pandoc with the filter. Files: `docx/reference.xml`, `docx/fisc.lua` (the frontmatter becomes the court heading, caption table, title, signature, clearance, verification and certificate; the body keeps its markdown structure).

Matches the typst output (both samples, every page of both renders viewed at 60 dpi): Liberation Serif only (embedded, no system fonts); letter with 1 in margins; body double spaced (exact 24 pt pitch) with a 0.5 in first-line indent, and no indent on the paragraph after a heading or after a block; single blocks at 15.6 pt; caption box with right and bottom rules; bold capitals title; headings bold, numbered I., A., 1.; centered page number; verification and certificate of service each on its own page; 9 pt footnotes. Government sample 4 pages and Yahoo sample 5 pages, as in typst.

Differs:
- Line breaks and page breaks differ in places (LibreOffice vs typst). On the Yahoo sample, page 2 ends about three lines earlier than the typst page 2, so the text on pages 2-3 breaks at different lines. Not chased.
- Heading numbers are text written by the filter, not Word list numbering.
- The caption is a table; Word draws its borders slightly differently from LibreOffice.
- The signature block is kept together with keepNext chains; this was checked only where it fits one page (both samples).
- Word was not available: the .docx was converted and looked at with LibreOffice 26.8 only. It was not opened in Word.

BLOCKED (docx):
- All gates (`tools/check.sh <doc-type-dir> --engine docx`): the script cannot run on this doc-type folder. It reads `court.json` and `checks.yaml` from the folder it is given; this doc type has neither (nor does the court folder), so it exits 2 before any gate runs. Gate 0 (content), Gate 1 (the FISC-* rule checks above) and Gate 2 (review file) are therefore not run for docx. No stamp is written. The docx pages were reviewed by hand, as described above.
