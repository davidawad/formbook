# txdistrict-travis: notice-of-hearing

Doc type `notice-of-hearing` for the civil district courts of Travis County, Texas (alias `txdistrict-travis`): a notice that a motion or application is set for hearing (or submission), with the Rule 57 signature block and a certificate of service. It asks the court for no ruling, so it has no salutation, no certificate of conference and no numbered paragraphs. Template: `typst/txdistrict-travis-notice-of-hearing.typ` over `/lib/typst/txdistrict-travis-common.typ` (read-only); entry `typst/main.typ`. Engines: typst only.

## Governing rules

Full table, sources and the date read: `../rules.md`.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| TRCP 21(b) (NOH-001) | Notice of a court proceeding is served not less than 3 days before it (unless the rules or the court say otherwise) and carries the information participants need: location or joining instructions, the court's contact | the `hearing:` keys and the body; the 3-day count is author responsibility (no dates are computed) |
| TRCP 21(d), 21a(e) | Certificate of service over signature, stating date and manner | `nh-service` |
| TRCP 57, 21(f)(2) | Attorney's name, State Bar number, address, telephone, email, fax if any | `nh-signature` |
| Local Rules 2.2, 2.3 | Certifications and the setting-request condition apply to motions | not printed: a notice is not a motion; the motion noticed carries them (author responsibility) |
| Local Rule 2.4 (NOH-002) | The party who obtains the setting gives notice of date, time and the total time needed, the same day | `hearing.date`, `.time`, `.length` all required; same-day sending is the author's |
| Local Rule 1.4 (NOH-003) | A notice must not direct the parties to the court in the case style | generated opening names "the Travis County Civil District Courts", never the numbered court; `hearing.court` overrides for a specially assigned court |
| Local Rule 9.1 (NOH-004) | Hearings are in person unless all parties agree and the setting is announced remote with the Court Administrator, or the judge finds good cause | `hearing.format`; whether a remote hearing is allowed is the author's; joining instructions in `joining` |
| Local Rule 7.1 (NOH-005) | Uncontested matters are submitted, not noticed for hearing | not a hearing notice; author responsibility |
| TS 3.1 | Text-searchable single PDF, 8.5x11 | page setup; embedded fonts are not met, see `../rules.md` TXTRAVIS-FORM-003 |

## Markdown contract

Frontmatter (YAML), then the body. Unknown keys are ignored. The paper needs `hearing:` or a non-empty body (or both).

| Field | Required | Feeds |
|---|---|---|
| `cause_number` | yes | "CAUSE NO. ..." above the caption |
| `judicial_district` | yes | "<n> JUDICIAL DISTRICT" in the court column and the generated opening |
| `caption` | yes | list of sides joined by "v.": `names` (bold capitals under `caption_style: lib`, as typed under `plain`), `designation` (italic, optional) |
| `title` | yes | bold underlined capitals |
| `caption_style` | no | `lib` (default, as the shared caption of motion-brief, original-answer, proposed-order: party names and the court column in bold capitals) or `plain` (names as typed, court column in plain weight). Papers in one case must match; INPUT 1-3 use `plain` because the three filed notices print their captions in plain weight |
| `court_column_order` | no | `district-middle` (default, the order of the shared caption in motion-brief, original-answer and proposed-order: "IN THE DISTRICT COURT OF", the district, the county) or `county-middle` ("IN THE DISTRICT COURT OF", the county, the district). Papers in one case must match, so use the order the case already uses |
| `footer_title` | no | footer "TITLE - Page N" |
| `hearing` | no | generates the opening paragraph (below) |
| `signature` | yes | `signer`, `bar_no`, `phone`, `email`; optional `firm`, `lines`, `fax`, `date` (printed "Date:" at the left), `role`, `others: [{name, bar_no, email}]` |
| `service` | yes | `date`; optional `method` (text after "by"; default electronic service through the electronic filing manager); optional `recipients: [{name, lines}]` |
| `numbered_paragraphs` | no | default `false` |

`hearing` keys: `motion` (inline markdown, e.g. `"*Defendant's Motion for Sanctions*"`), `date`, `time`, `length` (all required; Local Rule 2.4 total time needed); optional `court` (replaces the court phrase for a specially assigned court), `kind` (noun, default "hearing"; "emergency oral hearing"), `central_docket: true` (prints "on the Central Docket in the Travis County Civil District Courts" instead of the generic court phrase), `format: in-person|remote`, `location` (with `in-person`), `remote` (required with `remote`; the words after "will take place", e.g. "via Zoom videoconference"), `joining` (a sentence of joining instructions or of the court's contact, TRCP 21(b)). The opening reads "PLEASE TAKE NOTICE that <motion> has been set for <kind> on **<date>, at <time>** <where> and is estimated to take <length>." then one paragraph for `format`. Body markdown (paragraphs, `*emphasis*`, `**bold**`) follows. With no `hearing:` the body is the whole notice (INPUT 1-3 are body-only transcriptions).

Service: with no `recipients`, or recipients with no address lines, the certificate says "on all counsel of record" (a name-only recipient is printed as given); recipients with `lines` print the list under "on the following counsel of record or parties:".

Render: `just render-filing courts/fifth-circuit/texas/state/district-court-travis/notice-of-hearing <in.md> <out.pdf>`.

## Samples

| INPUT | FILED-EXAMPLE | Pages (filed) | What it tests |
|---|---|---|---|
| `INPUT-notice-of-hearing.md` | Pillsbury, 459th, 2026-02-05, TRO application | 2 (2) | body-only, emergency Zoom notice, three lawyers, "all counsel of record" |
| `INPUT-notice-of-hearing-2.md` | Ferguson Braswell, 459th, 2026-03-03, motion for sanctions | 2 (3) | 17-name caption (column widened, no overflow), Central Docket paragraphs, one lawyer with fax |
| `INPUT-notice-of-hearing-3.md` | Holland & Knight, 53rd, 2020-07-16, motion to compel (pre-2024 rules) | 2 (2) | four lawyers breaking across pages, a listed pro se recipient, mailed and emailed service |
| `INPUT-notice-of-hearing-4.md` | none (fictional) | 2 | generated opening from `hearing:` (in person, length), a Rule 91a motion noticed, body paragraph, listed recipient |

## Tier 2 against the exemplars

- Court column: the filed exemplars in this folder (all three) put the county in the middle and the district at the bottom, so INPUT 1-3 set `court_column_order: county-middle`; the shared lib caption puts the district in the middle, which is this template's default so a notice matches the motion and answer of the same case. Other filed papers in the court folders use both orders.
- No salutation (none of the three filed notices has one). Service recipients optional. Signature block with "Date:" at the left beside "Respectfully submitted," as in exemplar 1. Caption style: the filed notices print plain-weight, as-typed names, so INPUT 1-3 set `caption_style: plain`; the default `lib` matches the shared caption of the motion, answer and order of the same case.
- A long party list: the shared caption fixed the party column at 47% and its fixed-height grid cannot break. This template measures the party column; if taller than 5.6 in it widens the column to 57%; if still taller it stacks the parties full width with the court lines below (breakable across pages). Exemplar 2's 17 names now fit page 1 with the title and the opening of the notice; the court lines are not drawn over the footer.
- Each signature: the last paragraph is glued to the signing lawyer's block; further lawyers and the role break between lawyers, never inside one.

## Page-by-page review (every page viewed)

Rendered at 60 dpi beside the filed pages, and `fb overlay` (word-overlap is not a score): Sample 1 p.1 caption, title, both opening paragraphs, signature date and first two lawyers (filed: the whole signature block fits page 1 of 2; ours wraps the third lawyer to p.2 because our text is double-spaced at 27.6 pt against the filed 24 pt); p.2 last lawyer and role, certificate. Sample 2 p.1 17-name caption in a grid (filed: 25 lines in a 55% column; ours 27 lines at 57%), title, first paragraphs; p.2 the rest, signature, certificate on the same page (filed 3 pages: certificate alone on p.3). Sample 3 p.1 caption, opening, four lawyers' block (breaks after the third lawyer onto p.2; filed breaks after "Respectfully submitted"), p.2 role, certificate with the recipient. Sample 4 p.1 generated opening, body, signature, first of two lawyers; p.2 second lawyer and role, certificate with a listed recipient. `fb lint paths` PASS; `fb check`: 32 checks passed, 0 failed.

## Known gaps

- Tier 3, accepted: the clerk's e-filing stamp (top right) is not drawn; the filed notices set a 24 pt line, we set 27.6 pt (house style, `../rules.md` TXTRAVIS-FORM-001), so the page breaks differ; exemplar 2 starts the certificate on its own page and prints "NOTICE OF HEARING   Page n" bold left and right; exemplar 3 sets its title between two rules and has a footer rule; exemplar 1 underlines "/s/" on the signature line and puts address after the firm; ours prints name, bar number, address, telephone, email in one order.
- Exemplar 1 and the generated opening of an older template named the numbered court (459th) in the text; Local Rule 1.4 forbids it, so this template prints "the Travis County Civil District Courts". Exemplar 1's header has the court column as "IN THE DISTRICT COURT / TRAVIS COUNTY, TEXAS / 459th JUDICIAL DISTRICT"; ours prints "IN THE DISTRICT COURT OF" (the order of exemplar 2); ours upper-cases the district ("459TH").
- Exemplar 1's certificate says "I hereby certify" and "this instrument"; ours says "I certify" and "the foregoing document". Tier 3.
- Anything after 2024-11-15 (local rules amended by 2026-10-31, the Master Calendar standing order effective 2026-07-01, individual judges' notice procedures) are not in `../rules.md` as read; the template makes no claim about them. The TRCP 21(b) 3-day count, a Rule 91a hearing's 21-day and 14-day notice (`../rules.md` TXTRAVIS-MOT-003) and the court contact and evidence-submission instructions are the author's, in `hearing:` or the body.
- Fonts are embedded (TS 3.1(E)); typst only.
- Candidates for `lib/typst/txdistrict-travis-common.typ` (defined locally here with the `nh-` prefix): a caption that measures the party column and widens or stacks instead of overflowing; a signature block with "Date:" beside it and a break between lawyers; a certificate of service with optional recipients ("all counsel of record"); `head` with `salute: false` already exists but its caption forces bold capitals.
