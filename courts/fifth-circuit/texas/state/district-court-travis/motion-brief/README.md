# txdistrict-travis: motion-brief

Doc type `motion-brief` for the civil district courts of Travis County, Texas (alias `txdistrict-travis`): a motion with its argument incorporated (for example a Rule 91a motion to dismiss), a signature block (TRCP 57), a certificate of conference (Travis Local Rule 2.2) and a certificate of service (TRCP 21a). With `document: proposed-order` the same template renders the proposed order as its own paper (Local Rules 11.4, 11.5). Template: `typst/txdistrict-travis-motion-brief.typ` over `/lib/typst/txdistrict-travis-common.typ`; entry `typst/main.typ`. Engines: typst only.

## Governing rules

Full table, sources, URLs and the date read: `../rules.md`.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| TRCP 21(a) | Motion states grounds and sets out the relief sought | author's body (Summary, Argument, Prayer) |
| TRCP 91a.2 | A 91a motion says it is made under the rule, identifies each cause of action, states the reasons | author's body |
| Local Rule 2.2 | Setting certification on every motion; conference certification on every motion except a dispositive one; the rule's words | `conference-certificate` |
| Local Rule 2.3 | No setting request without the certifications (or filing them within 24 hours) | author responsibility |
| TRCP 21(d), 21a(e) | Certificate of service over signature | `service-certificate` |
| TRCP 57, 21(f)(2) | Signature block contents | `signature-block` |
| Local Rule 11.4, 11.5 | Order on its own page with cause number, style and court; judge's signature line on a page with text; "SIGNED", never "entered" | `order-paper` |
| TS 3.1(E) | A proposed order is its own PDF | separate sample, `document: proposed-order` |

## Markdown contract

Frontmatter (YAML), then the body. Unknown keys are ignored.

| Field | Required | Feeds |
|---|---|---|
| `cause_number` | yes | "CAUSE NO. ..." above the caption |
| `judicial_district` | yes | "<n> JUDICIAL DISTRICT" in the right column |
| `caption` | yes | list of sides joined by "v.": `names` (bold capitals), `designation` (italic, optional) |
| `title` | yes | the paper's title, bold capitals |
| `footer_title` | no | footer "TITLE - Page N" (else "Page N") |
| `numbered_paragraphs` | no | default `true`: paragraphs after the first heading numbered 1., 2., ... continuously |
| `signature` | yes (answer, motion) | `signer`, `bar_no`, `phone`, `email` (TRCP 57, 21(f)(2)); optional `firm`, `lines` (address), `fax`, `date`, `role`, `others: [{name, bar_no, email}]` |
| `service` | yes (answer, motion) | `date`, optional `method` (text after "by"; default electronic service through the electronic filing manager), `recipients: [{name, lines}]` |

Body: paragraphs before the first heading are the unnumbered opening; `# Heading` is a part (the template prints the Roman numeral above the title); `## A. Heading` and `### 1. Heading` are sub-headings with the label you type; each other paragraph is numbered by the template (a heading that begins "Prayer", and a paragraph that begins "WHEREFORE", are not); `> quote`; `- list` (one chunk); footnotes `[^k]`. No tables, HTML or raw Typst. Never type the numerals, paragraph numbers, salutation, signature block or certificates: the template prints them.

Motion-only: `conference` (required): `dispositive: true` for a 91a, motion to dismiss or summary judgment (then only the setting certification prints); `setting: conferred|efforts`; for a motion that is not dispositive, `issues: conferred|efforts`; optional `detail` (who, when, how, result). `document`: `motion` (default), `notice` or `proposed-order`. A `notice` (notice of appearance or designation of attorney in charge, TRCP 8; notice of hearing or submission, TRCP 21(b)) needs `signature` and `service` but no `conference` (Local Rule 2.2 reaches motions only); its paragraphs are unnumbered unless `numbered_paragraphs: true`. A proposed order needs only `cause_number`, `judicial_district`, `caption`, `title` and the body (the order's text, no numbering); the template prints "SIGNED on ___, 20__." and the judge's line. A notice of hearing is a body part (TRCP 21(b), 91a.6 content) or its own paper.

Render: `just render-filing courts/fifth-circuit/texas/state/district-court-travis/motion-brief <in.md> <out.pdf>`.

## Samples

| INPUT | FILED-EXAMPLE | Pages | What it tests |
|---|---|---|---|
| `INPUT-motion-brief.md` | Rule 91a motion to dismiss, 201st (Chamberlain McHaney) | 5 | dispositive motion, footnotes, two lawyers, long closing paragraph with signature |
| `INPUT-motion-brief-2.md` | the order on that motion | 1 | proposed-order document |
| `INPUT-motion-brief-4.md` | fictional notice of appearance | 1 | notice document |
| `INPUT-motion-brief-3.md` | none (fictional) | 3 | non-dispositive motion, efforts certificates with detail, block quote, list, sub-headings, prayer, two recipients |

## Page-by-page review (every page viewed)

Sample 1: p.1 caption, opening, part I, footnote 1; p.2 part II, notes 2-4; p.3 paragraph 5 with notes 5-6 (white space below: the next block is the conclusion with its signature, kept together); p.4 conclusion, signature, two counsel; p.5 certificates of conference and service. Sample 2: 1 p., caption, order text, SIGNED line, JUDGE PRESIDING. Sample 3: p.1 caption, parts I-II, quotation, note; p.2 sub-headings A-B, list, prayer, signature; p.3 certificates. Overlay: the exemplar motion sets its text 1.5-1.8 lines tighter per page and puts the clerk's stamp top right; the exemplar order has a typed judge's name; tier 3. `fb check`: 24 passed, 0 failed.

## Known gaps

- The exemplar motion predates Local Rule 2.2 (effective 2024-11-15), so the certificate of conference is rule-derived; no public post-2024 Travis motion with the certificate was found.
- Local rules after 2024-11-15 (amended by 2026-10-31), the Master Calendar standing order (2026-07-01), the summary-judgment standing order (2026-06-29, not read) and individual judges' procedures are not reflected.
- No notice-of-hearing, table of contents or table of authorities (none is required in a Texas district court).
- Fonts are embedded (TS 3.1(E), see `../rules.md` TXTRAVIS-FORM-003); typst only; same signature-keeping behavior as the answer.
- 91a deadlines (60 days, 21 days, 14 days' notice, 45-day ruling) are not computed.

## Open questions (conservative default taken)

1. Whether to ship an engine-parity docx; default: typst only.
2. Whether a notice of hearing deserves its own doc type; default: body part.
