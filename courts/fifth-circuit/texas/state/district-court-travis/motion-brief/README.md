# txdistrict-travis: motion-brief

Doc type `motion-brief` for the civil district courts of Travis County, Texas (alias `txdistrict-travis`): a motion with its argument incorporated (for example a Rule 91a motion to dismiss), a signature block (TRCP 57), a certificate of conference (Travis Local Rule 2.2) and a certificate of service (TRCP 21a). With `document: proposed-order` the same template renders the proposed order as its own paper (Local Rules 11.4, 11.5). Template: `typst/txdistrict-travis-motion-brief.typ` over `/lib/typst/txdistrict-travis-common.typ`; entry `typst/main.typ`. Engines: typst only.

**Not ready to e-file as rendered.** Technology Standards 3.1(E) says an e-filed PDF "may not contain embedded fonts"; every PDF this template renders embeds its fonts (rules.md TXTRAVIS-FORM-003, kind M, not met), and no un-embedding step ships with formbook. A green `fb check` does not test TS 3.1(E) and does not make the output filing-compliant. Before filing, check the PDF with `pdffonts`, and run it through a conforming PDF workflow or confirm with the e-filing service provider. Do not file the output directly.

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
| Local Rule 11.1; TS 3.1(E) | A proposed order is its own PDF but is never filed as a stand-alone document: attach it to the motion (or other pleading) | separate sample, `document: proposed-order`; filed as an attachment to the motion |

## Markdown contract

Frontmatter (YAML), then the body. Unknown keys are ignored.

| Field | Required | Feeds |
|---|---|---|
| `cause_number` | yes | "CAUSE NO. ..." above the caption |
| `judicial_district` | yes | "<n> JUDICIAL DISTRICT" in the right column |
| `caption` | yes | list of sides joined by "v.": `names` (bold capitals), `designation` (italic, optional) |
| `title` | yes | the paper's title, bold capitals |
| `footer_title` | no | footer "TITLE - Page N" (else "Page N") |
| `footer` | no | `none` drops the footer (no rule requires one); default prints it |
| `title_underline` | no | `true` underlines the title (original-answer exemplar 2); default off |
| `numbered_paragraphs` | no | default `true`: paragraphs after the first heading numbered 1., 2., ... continuously |
| `signature` | yes (answer, motion) | `signer`, `bar_no`, `phone`, `email` (TRCP 57, 21(f)(2)); optional `firm`, `lines` (address), `fax`, `date`, `role`, `others: [{name, bar_no, email}]` |
| `service` | yes (answer, motion) | `date`, optional `method` (text after "by"; default electronic service through the electronic filing manager), `recipients: [{name, lines}]` |

Body: paragraphs before the first heading are the unnumbered opening; `# Heading` is a part (the template prints the Roman numeral above the title); `## A. Heading` and `### 1. Heading` are sub-headings with the label you type; each other paragraph is numbered by the template (a heading that begins "Prayer", and a paragraph that begins "WHEREFORE", are not); `> quote`; `- list` (one chunk); footnotes `[^k]`. No tables, HTML or raw Typst. Never type the numerals, paragraph numbers, salutation, signature block or certificates: the template prints them.

Joint motion (added 2026-10-26): `signatures` (a list of signature blocks, each with the keys of `signature`) in place of `signature`; the first block prints "Respectfully submitted,", each other block follows it, and the certificates use the first signer. A line `---` between paragraphs starts a part with its Roman numeral and no heading text (the Seattle Children's exemplar: "I.", "II.").

Motion-only: `conference` (required): `dispositive: true` for a 91a, motion to dismiss or summary judgment (then only the setting certification prints); `setting: conferred|efforts`; for a motion that is not dispositive, `issues: conferred|efforts`; optional `detail` (who, when, how, result). `document`: `motion` (default), `notice` or `proposed-order`. A `notice` (notice of appearance or designation of attorney in charge, TRCP 8; notice of hearing or submission, TRCP 21(b)) needs `signature` and `service` but no `conference` (Local Rule 2.2 reaches motions only); its paragraphs are unnumbered unless `numbered_paragraphs: true`. A proposed order needs only `cause_number`, `judicial_district`, `caption`, `title` and the body (the order's text, no numbering); the template prints "SIGNED on ___, 20__." and the judge's line. Local Rule 11.1: a proposed order must not be filed as a stand-alone document; file its PDF only as an attachment to the motion or another pleading. A notice of hearing is a body part (TRCP 21(b), 91a.6 content) or its own paper.

Render: `just render-filing courts/fifth-circuit/texas/state/district-court-travis/motion-brief <in.md> <out.pdf>`.

## Samples

| INPUT | FILED-EXAMPLE | Pages | What it tests |
|---|---|---|---|
| `INPUT-motion-brief.md` | Rule 91a motion to dismiss, 201st (Chamberlain McHaney) | 5 | dispositive motion, footnotes, two lawyers, long closing paragraph with signature |
| `INPUT-motion-brief-2.md` | the order on that motion | 1 | proposed-order document |
| `INPUT-motion-brief-4.md` | fictional notice of appearance | 1 | notice document |
| `INPUT-motion-brief-5.md` | opposed motion to quash and for protective order, Texas Attorney General, 459th (2026-02-12; post Local Rule 2.2) | 8 (exemplar 7) | non-dispositive motion with certificate of conference, four signers, headings |
| `INPUT-motion-brief-6.md` | Joint Motion to Dismiss, Seattle Children's v. OAG, 98th (2024) | 3 (exemplar 3) | joint motion, two firms' signature blocks (`signatures`), parts with no heading text (`---`), unnumbered paragraphs, WHEREFORE prayer; the template adds the certificate of conference and of service the exemplar lacks |
| `INPUT-motion-brief-3.md` | none (fictional) | 3 | non-dispositive motion, efforts certificates with detail, block quote, list, sub-headings, prayer, two recipients |

## Page-by-page review (every page viewed)

Exemplar 6 (added 2026-10-26): the 3 filed pages and the 3 rendered pages viewed side by side at 60-70 dpi: p.1 caption, title, salutation, opening, part I and the first two paragraphs (ours is double spaced at a tighter pitch than the scan, so p.1 holds part of the third paragraph that the filed p.1 leaves for p.2); p.2 the last paragraph, part II, prayer, "Respectfully submitted," and the first firm's block; p.3 the second firm's block, then the two certificates the exemplar does not have. `fb check`: pass.

Exemplar 5 (added 2026-10-25): 7 filed pages and 8 rendered pages viewed side by side at 70 dpi; differences in Known gaps. Sample 1: p.1 caption, opening, part I, footnote 1; p.2 part II, notes 2-4; p.3 paragraph 5 with notes 5-6 (white space below: the next block is the conclusion with its signature, kept together); p.4 conclusion, signature, two counsel; p.5 certificates of conference and service. Sample 2: 1 p., caption, order text, SIGNED line, JUDGE PRESIDING. Sample 3: p.1 caption, parts I-II, quotation, note; p.2 sub-headings A-B, list, prayer, signature; p.3 certificates. Overlay: the exemplar motion sets its text 1.5-1.8 lines tighter per page and puts the clerk's stamp top right; the exemplar order has a typed judge's name; tier 3. `fb check` (all five samples): 40 passed, 0 failed.

## Known gaps

- Joint motion (exemplar 6, added 2026-10-26): the exemplar has no certificate of conference or of service, the template prints both (rules.md TXTRAVIS-MOT-007); the exemplar's text is justified, ours is ragged right; its firm names are in small capitals; its Corr Cronin block has no State Bar line (here "State Bar of Texas No. pro hac vice pending"); the exemplar fits 3 pages, ours 3 with certificates.

- Exemplar 1 predates Local Rule 2.2 (effective 2024-11-15), so its certificate of conference is rule-derived. Exemplar 5 (2026) has a certificate of conference, but not in the Local Rule 2.2 words (one paragraph: conferred on 2026-02-12 in a good-faith effort to resolve or narrow the issues; opposed). It has no separate certification about the date, time and format of the setting. The template prints both Local Rule 2.2 certifications and cannot print only the filer's one paragraph, so its output differs from the exemplar there. No exemplar carries the Local Rule 2.2 wording.
- Exemplar 5 against the template: the template prints Roman numerals above the headings ("I. INTRODUCTION"); the filed motion has underlined small-capital headings without numerals. The signature certificates in the exemplar are signed by a different lawyer than the motion's signer; the template prints one signer.
- Local rules after 2024-11-15 (amended by 2026-10-31), the Master Calendar standing order (2026-07-01), the summary-judgment standing order (2026-06-29, not read) and individual judges' procedures are not reflected.
- No table of contents or table of authorities (none is required in a Texas district court). Standalone templates for notices of hearing and of appearance and for proposed orders now exist (`../notice-of-hearing`, `../notice-of-appearance`, `../proposed-order`); use them. This template's `document: notice` and `proposed-order` modes remain for compatibility only.
- Fonts are embedded (TS 3.1(E), see `../rules.md` TXTRAVIS-FORM-003); typst only; same signature-keeping behavior as the answer.
- 91a deadlines (60 days, 21 days, 14 days' notice, 45-day ruling) are not computed.

## Open questions (conservative default taken)

1. Whether to ship an engine-parity docx; default: typst only.
2. Whether notices of hearing and of appearance and proposed orders deserve their own doc type: decided by David (2026-10-25), each has its own folder with exemplars and a template (now written); the `document:` modes here remain for compatibility only.
