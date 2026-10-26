# txdistrict-travis: notice-of-appearance

Doc type `notice-of-appearance` for the civil district courts of Travis County, Texas (alias `txdistrict-travis`): a notice of appearance of counsel, optionally with the designation of an attorney in charge (TRCP 8) and optionally with reservation language (a special appearance under TRCP 120a, a motion to transfer venue under TRCP 86). A notice asks the court for no ruling: no salutation, no certificate of conference (Local Rule 2.2 reaches motions), unnumbered paragraphs. Template: `typst/txdistrict-travis-notice-of-appearance.typ` over `/lib/typst/txdistrict-travis-common.typ` (caption, body, footer, `cert-heading`, `cert-sign` are imported; nothing in lib is edited); entry `typst/main.typ`. Engines: typst only. Exemplar provenance: `usage/SOURCE.md`. Court-wide sources and the date they were read: `../rules.md`.

## Governing rules

`../rules.md` now has TXTRAVIS-NOA-001 (TRCP 8) and NOA-002 (no LR 2.2 certification; signature and service); it has no row for TRCP 86 or 120a. The text below was read 2026-10-25 from the official TRCP PDF (https://www.txcourts.gov/media/1463426/texas-rules-of-civil-procedure.pdf, HTTP 200). Rows for 86 and 120a are candidates for rules.md.

| Rule | Requirement (short) | What the template does |
|---|---|---|
| TRCP 8 (rules.md NOA-001) | The attorney whose signature first appears on a party's initial pleadings is the attorney in charge "unless another attorney is specifically designated therein"; the designation is changed "by written notice to the court and all other parties in accordance with Rule 21a"; "All communications from the court or other counsel with respect to a suit shall be sent to the attorney in charge." | `attorney_in_charge` prints a designation paragraph (quoting the communications sentence), the label "Attorney-in-Charge" under that attorney in the signature block, and the title "Notice of Appearance and Designation of Attorney in Charge" |
| TRCP 57, 21(f)(2) (rules.md FORM-007, -008) | signature with State Bar number, address, telephone, email, fax if any | `signature` requires `signer`, `bar_no`, `phone`, `email`; every `others` attorney needs `name`, `bar_no` |
| TRCP 21(d), 21a(e) (rules.md MOT-006, ANS-005) | certificate of service over signature on the filed paper, stating date and manner | `service` requires `date`; prints the certificate over the signer's `/s/` |
| TRCP 21a(a) | service through the electronic filing manager when the recipient's email is on file | default `method`; `recipients` optional |
| TRCP 120a(1) | special appearance is by sworn motion "filed prior to motion to transfer venue or any other plea, pleading or motion"; "Every appearance, prior to judgment, not in compliance with this rule is a general appearance." | the template prints whatever `reservation` text the filer gives; it does not decide whether a notice is safe to file ahead of a special appearance (author responsibility) |
| TRCP 86(1) | a venue objection is waived if not made "prior to or concurrently with any other plea, pleading or motion except a special appearance motion" | same: `reservation` text only |
| Local Rule 2.2 (MOT-004, -005; NOA-002) | certificates of conference for motions | not printed: a notice is not a motion |
| Style (no rule) | 12 pt, 1 in margins, double-spaced text, single-spaced caption, signature block and list | shared named parameters in lib |

## Markdown contract

Frontmatter, then an optional markdown body (more paragraphs after the generated text, or the whole text with `generate: false`).

| Field | Required | Feeds |
|---|---|---|
| `cause_number`, `judicial_district`, `caption` | yes | the shared caption (`caption`: list of sides `{names, designation}` joined by "v."; put every party of a side in one `names` string, it wraps in the party column) |
| `appearing_for` | yes unless `generate: false` | "Notice is given that A and B appear in the above-captioned case as counsel for `<appearing_for>`." |
| `generate` | no (default `true`) | `false`: the body is the whole text |
| `attorney_in_charge` | no | `true` (the signer) or the name of the signer or one of `signature.others`; adds the TRCP 8 paragraph, the signature label and the longer title; omit for a plain notice |
| `serve_undersigned` | no | adds "All future notices and pleadings in this case should be served on the undersigned at the address in the signature block." |
| `reservation` | no | a string or list of strings, each its own paragraph after the generated ones: the filer's special-appearance / venue guard text |
| `title` | no | else generated from `attorney_in_charge` |
| `footer_title` | no | footer "TITLE - Page N" |
| `numbered_paragraphs` | no | default `false`; `true` numbers body paragraphs after the first heading |
| `signature` | yes | `signer`, `bar_no`, `phone`, `email`; optional `date` (a "Date:" line, left), `firm`, `title` (under the name), `lines` (address), `fax`, `role` (bold closing line), `others: [{name, bar_no, email, phone, title}]`, `officials: [{name, title}]` (a left column beside the block, as in exemplar 1) |
| `service` | yes | `date`; optional `method` (text after "by"), `recipients: [{name, lines, side}]` (`side`: lines in a right column beside the recipient; absent: "on all parties and counsel of record"), `columns: 1|2` (default 2 for two or more recipients), `own_page: true` (certificate starts a new page) |

Render: `tools/fb/target/release/fb render <dir> <INPUT>` (or `just render <dir>`, which builds fb with cargo).

## Samples

| INPUT | FILED-EXAMPLE | Pages | What it tests |
|---|---|---|---|
| `INPUT-notice-of-appearance.md` | Texas Attorney General for the defendants, 459th (2026) | 2 | `generate: false` body, attorney in charge = signer with title, `officials` column, one recipient with five lines, custom title |
| `INPUT-notice-of-appearance-2.md` | Dinsmore & Shohl for a defendant, 419th (2024) | 2 | generated plain notice (no designation), two lawyers, no recipients ("all parties and counsel of record"), certificate on its own page |
| `INPUT-notice-of-appearance-3.md` | none (fictional) | 2 | attorney in charge who is not the signer, two reservation paragraphs (TRCP 120a, 86), six defendants in one caption side, body paragraph, two recipients |

## Page review (rendered at 70 dpi, every page viewed; overlays `just overlay` / `fb overlay`, every page viewed)

Sample 1, 2 pp.: p.1 caption (parties wrap in the 47% column), title between rules, the filer's two paragraphs (body fills the page, as in exemplar 1); p.2 the officials column beside the signature block, the certificate with the two-column recipient list (lawyers left, firm right). Sample 2, 2 pp.: p.1 caption, plain title, generated paragraphs, two-attorney signature block; p.2 certificate alone. Sample 3, 2 pp.: p.1 six-party caption (nine lines, no overflow), long title, five paragraphs; p.2 date, signature block with "Attorney-in-Charge" under the second attorney, certificate with two recipients in two columns. Re-viewed all six pages at 70 dpi after the second revision. Overlay word overlap with the filed pages (first revision, diagnostic only): 1: 78% / 69%; 2: 63% / 70%. `fb check`: 24 passed, 0 failed (all three samples); `fb lint paths` passes.

## Tier 2 against the exemplars

| Item | Exemplar 1 (TX AG) | Exemplar 2 (Dinsmore) | Template | State |
|---|---|---|---|---|
| Salutation | none | none | none | matches (the motion-brief template's salutation is not used) |
| Service recipients | listed, two columns (names left, firm right) | none | optional; two columns by default for 2+ recipients (`service.columns: 1` stacks; a recipient `side` puts a firm column beside it); "all parties and counsel of record" when absent | matches |
| Caption | small capitals, plain "§" column, court column lines at top / bottom | small capitals, bold § | lib's bold capitals | ACCEPTED (lib; tier 3) |
| Title | small capitals between rules | bold caps between two rules | bold caps between two rules | matches 2 |
| Signature block | `/s/` underlined italic, officials left, firm bold small capitals | `/s/` over rule, firm in small capitals, "ATTORNEYS FOR ..." | `/s/` italic, firm bold capitals, attorney-in-charge label under the name | ACCEPTED (tier 3) |
| Date | "Date:" left of the block | none (date only in certificate) | optional "Date:" left | matches |
| Certificate | on page 2 of 2 under the signature | own page | below the signature; own page with `own_page` | matches both |
| Last body paragraph | on page 1; signature page alone | | body fills page 1; only the signature block is kept whole (not bound to the last paragraph), so it may stand alone on page 2 | matches 1 |
| Wording | filer's own (`generate: false`) | two sentences; generated text differs ("Notice is given that ... appear ... as counsel for ...", plus the service request) | | ACCEPTED (tier 3) |
| Clerk's e-file stamp | top right | top right | not printed; the page keeps a one-inch margin | ACCEPTED |
| Footer | "Page n of N" | page number only | "TITLE - Page n" (lib) | ACCEPTED |

## Known gaps

- Fonts are embedded; TS 3.1(E) says a PDF "may not contain embedded fonts" (rules.md TXTRAVIS-FORM-003); same for every formbook template.
- Typst only; no latex or docx.
- The generated sentences assert nothing the filer did not choose, but the template does not tell the filer whether filing a notice of appearance ahead of a special appearance or a venue motion is safe (TRCP 120a(1) last sentence, 86(1)); the `reservation` text and the order of filings are the filer's.
- Not generated: a statement that the attorney is in good standing with the State Bar (exemplar 1 says so; add it in the body), the Rule 21a recitation in the body.
- The signature block (date, closing, signature, firm, address, role: about 14 lines) is unbreakable and moves whole to the next page when it does not fit under the body; the certificate may start on the next page too, and its signature lines stay with its last recipient (checked on a real draft whose block was about 30 pt too tall for the space left on page 2).
- A very long single caption side must fit on one page; the caption grid does not split across pages (lib).
- Local-rule amendments due by 2026-10-31 and judge-specific procedures are not reflected (`../rules.md`).

## Candidates for lib

`title-rules` (title between two rules), `notice-signature` (attorney-in-charge label, `officials` column, per-attorney title and phone) and `notice-service` (optional recipients, own page) are defined in this folder's template; the proposed-order and notice-of-hearing papers may want the same. Also: a salutation-free `head` that takes a title between rules.

Option `title_underline: true` (added 2026-10-25): the title prints underlined, with no rules, so a set of papers in one case can match (the original-answer template has the same key).
