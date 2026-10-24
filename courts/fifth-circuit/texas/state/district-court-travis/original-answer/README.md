# txdistrict-travis: original-answer

Doc type `original-answer` for the civil district courts of Travis County, Texas (alias `txdistrict-travis`): an original answer with any special exceptions, verified denials, affirmative defenses, counterclaim, jury demand and prayer, a signature block (TRCP 57), a certificate of service (TRCP 21a(e)) and, when the frontmatter has `verification:`, an unsworn-declaration verification (Tex. Civ. Prac. & Rem. Code 132.001). Template: `typst/txdistrict-travis-original-answer.typ` over `../typst/travis-common.typ`; entry `typst/main.typ`. Engines: typst only (no latex or docx).

## Governing rules

Full table with sources, URLs and the date read: `../rules.md`. The ones this template acts on:

| Rule | Requirement | Where the template uses it |
|---|---|---|
| TRCP 45 | Pleading is a petition and an answer; paper 8½ x 11 | page size (8.5 x 11 in) |
| TRCP 57, 21(f)(2) | Attorney signs with State Bar no., address, phone, email, fax if any | `signature-block` requires signer, bar_no, phone, email |
| TRCP 21(d), 21a(e) | Certificate of service over signature on the filed paper | `service-certificate` |
| TRCP 93; CPRC 132.001 | Verified pleas; unsworn declaration with jurat in place of an affidavit | `verification` page |
| TRCP 47, 92, 94, 97 | Counterclaim statements, general denial, affirmative defenses | author's body text (not generated) |
| TS 3.1 | Text-searchable PDF, 8.5x11, no encryption | Typst output; fonts are embedded (open question) |
| Style (no rule) | 12 pt, 1 in margins, double spacing, caption grid | named parameters at the top of `travis-common.typ` |

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

Answer-only: `verification`: `statement`, `declarant`, `birth_date`, `address`, `county`, `day`, `month`, `year` (optional `state`, `country`); prints on its own page after the certificate of service. The jurat's date of birth and address are required by statute; designate the filing as containing sensitive data when e-filing (TRCP 21c(d)).

Render: `just render-filing courts/fifth-circuit/texas/state/district-court-travis/original-answer <in.md> <out.pdf>`, or `just render <dir>` for the samples.

## Samples

| INPUT | FILED-EXAMPLE | Pages | What it tests |
|---|---|---|---|
| `INPUT-original-answer.md` | State Farm v. Catastrophic Solutions, 419th (answer and counterclaim) | 3 | every-paragraph numbering, short pleading, Rule 193.7 and designated-email parts |
| `INPUT-original-answer-2.md` | SCC Oaks v. TCAD, 200th (answer, counterclaim, disclosures; excerpt) | 4 | unnumbered paragraphs, two lawyers, caption without the cause number above the style |
| `INPUT-original-answer-3.md` | none (fictional) | 5 | special exceptions, verified denial, Rule 47 sub-headings, list, jury demand, verification page |

## Page-by-page review (rendered at 60 dpi and 80 dpi, every page viewed)

Sample 1, 3 pp.: p.1 caption grid, title, salutation, parts I-II; p.2 parts III-VII; p.3 prayer, signature, certificate of service. Sample 2, 4 pp.: p.1 caption and parts I-III; p.2 counterclaim and prayer; p.3 signature block with co-counsel; p.4 certificate. Sample 3, 5 pp.: p.1 parts I-II; p.2 parts III-V with list and sub-headings; p.3 jury demand, prayer, signature; p.4 certificate of service (kept whole on its own page by the template's no-split rule); p.5 verification. Overlay (`just overlay`, diagnostic only): the filed answers set their text on a tighter double-space (more lines per page) and print the clerk's e-file stamp in the top right; tier 3, not chased. `fb check` on the folder: 24 passed, 0 failed.

## Known gaps

- Fonts are embedded; TS 3.1(E) says a PDF "may not contain embedded fonts" (rules.md TXTRAVIS-FORM-003). Every formbook Typst template embeds; see Open questions.
- Typst only; no latex or docx engine.
- The last paragraph of the body travels with the signature block (never a signature alone on a page); a long last paragraph can leave white space at the foot of the previous page.
- Not generated: Rule 47(c) relief category, Rule 193.7 notice, jury fee note, designated e-service email, Rule 194 note, disclosures. Body text.
- The caption does not print "FILED" stamps, the court's name for a specific bench (e.g. the judge's name), or the "Page X of Y" form.
- Judge-specific rules and local-rule amendments due by 2026-10-31 are not reflected (rules.md).

## Open questions (conservative default taken)

1. Embedded fonts vs. TS 3.1(E): the e-filing manager accepts Typst PDFs in practice (not tested); default: keep the project's embedded vendored fonts.
2. Verification by unsworn declaration vs. notarized affidavit: default: CPRC 132.001 declaration (the secondary text of the statute was read; re-check on statutes.capitol.texas.gov).
