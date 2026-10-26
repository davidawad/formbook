# txdistrict-travis: rule-11-agreement

Doc type `rule-11-agreement` for the civil district courts of Travis County, Texas (alias `txdistrict-travis`): a Rule 11 agreement between counsel as the filed Travis exemplar sets it, a signed letter agreement (letterhead, date, addressees, "RE:" line naming the suit, numbered terms, "AGREED:" signature blocks) that the filer files with the clerk. Template: `typst/txdistrict-travis-rule-11-agreement.typ` over `/lib/typst/txdistrict-travis-common.typ`; entry `typst/main.typ`. Engines: typst only. Rules: `../rules.md` (TXTRAVIS-R11-001 to -004). Provenance of exemplars: `usage/SOURCE.md`.

**Not ready to e-file as rendered.** Technology Standards 3.1(E) says an e-filed PDF "may not contain embedded fonts"; every PDF this template renders embeds its fonts (rules.md TXTRAVIS-FORM-003, kind M, not met), and no un-embedding step ships with formbook. A green `fb check` does not test TS 3.1(E) and does not make the output filing-compliant. Before filing, check the PDF with `pdffonts`, and run it through a conforming PDF workflow or confirm with the e-filing service provider. Do not file the output directly.

**Exemplar caveat.** The one filed Travis example found (PFLAG v. Abbott, 459th, 2023) is a Rule 11 agreement on an informal stay, not a settlement; it is a format exemplar. No filed Travis Rule 11 settlement agreement was found (`usage/SOURCE.md`, "What the search found").

## Rules carried

| Rule | What the template does |
|---|---|
| TRCP 11 (R11-001) | the paper is a signed writing: the sender's signature block and an "AGREED:" block for each other signer, each with a date line; the filer files it with the clerk |
| Exemplar practice (R11-002) | letterhead, date, "Sent via" line, addressees, "RE:" line, salutation, numbered terms, the "If this letter accurately reflects ..." sentence stays with the closing and the sender's signature |
| *Vaishangi* (R11-003) | not applied: author's decision whether the agreement should be enforceable after plenary power ends |

## Markdown contract

Frontmatter (YAML), then the body. Required: `letterhead` (`firm`, optional `lines`), `date`, `addressees` (list of `{name, lines}`), `re` (the subject line, inline markdown for the case name), `salutation`, `signer` (`firm`, `name`, optional `bar_no`, `role`, `closing`), `agreed` (list of `{name, optional bar_no, firm, role}`, one "AGREED:" block each; `agreed_heading` changes the heading). Optional: `via` (bold line under the date), `footer: none`, `footer_title`. Body: paragraphs; a numbered list is one chunk with no blank line inside: `1. **Lead-in:** text`, nested by two spaces of indent (`a.` at two, `i.` at four); footnotes `[^k]`. The template prints the numbers, the letterhead rule, the closing and the signature blocks.

## Samples

| INPUT | Source | Pages | Shows |
|---|---|---|---|
| `INPUT-rule-11-agreement.md` | PFLAG v. Abbott letter agreement (459th, 2023) | 3 | numbered terms with bold lead-ins, a., b. and i., ii. sub-items, three footnotes, two signature blocks |

## Page review (done, every page of the OUTPUT viewed next to the FILED-EXAMPLE)

| Page | Result |
|---|---|
| OUTPUT p.1 | letterhead, date, "Sent via", addressee, RE line, salutation, opening paragraph, terms 1 and 2 begin, three footnotes: OK |
| OUTPUT p.2 | rest of term 2, terms 3-6 with the nested sub-items, the "If this letter accurately reflects ..." sentence stays with the signatures: OK |
| OUTPUT p.3 | closing, firm, signature, date line, "AGREED:" block, date line: OK |

## Known gaps (tier 2/3, ACCEPTED)

- The exemplar's logo, footer, clerk's stamp and handwritten signatures are not reproduced; its "Agreed: May 3, 2023" beside the sender's signature is a date line under the block here.
- The exemplar is single spaced with about 1.15 line pitch and the terms hang at about 1 inch; ours uses the shared lib's single-spaced pitch and 0.5-inch steps.
- A captioned Rule 11 agreement (a pleading with a caption and a "Rule 11 Agreement" title, as in the Solotki cover filing mentioned in `usage/SOURCE.md`) has no usable filed exemplar here and is not built.
- Not read: the standing orders and individual judges' procedures (rules.md gap).
