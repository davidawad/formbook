# flsb: motion brief (typst)

Court: United States Bankruptcy Court, Southern District of Florida (`flsb`). Doc type: motion brief under Fed. R. Bankr. P. 9013 with its memorandum (filed in an adversary proceeding).

**exemplar=yes, with a scope limit.** Filed exemplar: `exemplars/FILED-EXAMPLE-laspro-alinia-16-01315-motion-brief.pdf`. It is the **memorandum in support of a motion to dismiss** (ECF 49, 2017), not the motion itself (ECF 29). See `exemplars/SOURCE.md`.

## Governing rules

Verified 2026-10-14.

| Rule | What it requires | Source | Where the template uses it |
|---|---|---|---|
| Fed. R. Bankr. P. 9013 | A request for an order must be made by written motion; a motion must state its grounds with particularity and set forth the relief requested | https://www.law.cornell.edu/rules/frbp/rule_9013 (Dec. 1, 2024 text) | Body and the relief stated in the Conclusion (no code check) |
| Fed. R. Bankr. P. 9004(b) | Caption: court name, case title, case number and adversary number, and a designation of the document | https://www.law.cornell.edu/rules/frbp/rule_9004 | Caption |
| Fed. R. Bankr. P. 7010 | Adversary pleadings follow Civil Rule 10 and the Form 416 caption | https://www.law.cornell.edu/rules/frbp/rule_7010 | Adversary caption |
| S.D. Fla. Bankr. L.R. 9004-1(a)(2)–(4) | 1-inch margins; 12-point font (footnotes 10-point); double spacing except captions, titles, headings, quotations over 50 words, footnotes, signature blocks and certificates | 2026 Local Rules, https://www.flsb.uscourts.gov/sites/flsb/files/local_rules/2026_Local_Rules.pdf, Rule 9004-1, pp. 39–40 | Margins, type size, `body-leading` (24 pt), single-spaced block quotations, signature, certificate |
| L.R. 9004-1(d) | No incorporation by reference of facts or arguments made in another filed document | same | Not enforced by the template; the sample incorporates nothing (checked by reading) |
| L.R. 9004-1(e)(2) | Adversary caption: "In re:" block, division line, plaintiff v. defendant, Adv. No. | same | Caption |
| L.R. 9013-1(a) | A motion seeking relief against an entity that has appeared through counsel must include a certification that the movant's counsel conferred (or tried to) in good faith | same, Rule 9013-1, p. 45 | `conferral:` frontmatter renders a "Certificate of Conferral" when given; see known gaps |

PDF text layer: L.R. 9004-1(a)(1) requires text-searchable PDF; the output has one (`pdftotext`).

## Layout

| Path | What |
|---|---|
| `typst/flsb-motion-brief.typ` | Template: `flsb-motion-brief(meta, body)`. Content-agnostic; case words come from the sample's frontmatter. |
| `typst/main.typ` | Entry point. |
| `samples/INPUT-alinia-memorandum.md` | Transcription of the exemplar: caption, title, body (pages 1–12), footnotes 1–2, conclusion, signature block, certificate of service with service list. |
| `samples/OUTPUT-alinia-memorandum.pdf` | Our render. |
| `samples/OVERLAY-alinia-memorandum.pdf`, `.txt` | Red/blue overlay and page map. |
| `exemplars/` | The filed PDF and `SOURCE.md`. |

Commands, from the repo root with the toolchain on `PATH`:

```sh
sh tools/render.sh courts/eleventh-circuit/florida/federal/bankruptcy-southern-district/motion-brief samples/INPUT-alinia-memorandum.md
sh tools/overlay.sh courts/eleventh-circuit/florida/federal/bankruptcy-southern-district/motion-brief alinia-memorandum
```

File-name note: as in the complaint README, the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf`/`.txt`, not the `<id>.pdf` and `<id>-overlay.pdf` the brief named.

## Overlay (red/blue test)

Pairings from `samples/OVERLAY-alinia-memorandum.txt` (word overlap, a diagnostic, not a score): ours p.1 → filed p.1 (76.0%), p.2 → p.2 (63.6%), p.3 → p.4 (55.7%), p.4 → p.5 (83.1%), p.5 → p.6 (77.2%), p.6 → p.8 (53.5%), p.7 → p.9 (62.9%), p.8 → p.10 (82.3%), p.9 → p.11 (76.8%), p.10 → p.12 (77.8%). From page 3 on our page numbers differ from the exemplar's, so compare the overlay by content, not by page number. The filed pages 14 and 15 have no text layer, so the overlay cannot pair against them.

## Page review (Gate 2)

Every page of `OUTPUT-alinia-memorandum.pdf` (10 pages) was rendered at 60 dpi and looked at. `pages_reviewed=10`.

| Page | Result |
|---|---|
| 1 | Caption (two-column, "In re:" block and case numbers), centered title, opening paragraph, start of I. INTRODUCTION with footnote 1. |
| 2 | Introduction continues; II. DISCUSSION and A. The Amended Complaint. |
| 3 | Section A continues. |
| 4 | Section A ends; B. Choice of Law Analysis begins. |
| 5 | Section B; the Section 145 and Section 6 block quotations are single-spaced and indented; C. heading. |
| 6 | Section C(i); footnote 2 at the foot of the page. |
| 7 | C(i) ends; C(ii) (Section 6 factors). |
| 8 | C ends; D. heading (two-line heading, kept with its first paragraph). |
| 9 | Section D ends; page has white space at the foot because the Conclusion is kept with its signature block. |
| 10 | CONCLUSION, signature block, CERTIFICATE OF SERVICE, SERVICE LIST, all on one page. |

Defects found and fixed while reviewing:

- Paragraphs overlapped (block height did not include trailing leading). Fixed with `below: body-leading` on each body block.
- The first paragraph after a heading was pushed off page 1, leaving it mostly empty. Fixed by letting the heading wrapper break (the heading itself is `sticky`).
- The signature block landed alone on page 10 with no text above it. Fixed: the final body paragraph and its heading are `sticky`, so the Conclusion moves with the signature.

## Known gaps

- **Conferral certificate (L.R. 9013-1(a)).** The 2017 exemplar has none, so the sample has none, and the template prints the certificate only when `conferral:` is given. A motion against a represented entity filed today needs one; it must be written for each filing. Not a template default, because the text is case-specific.
- **Motion form.** The exemplar is the memorandum (ECF 49), not the motion (ECF 29). The single-document "motion with incorporated memorandum" form is covered by the template but not exemplified by a filed copy in this folder.
- **Headings are typed by hand** (I., A., (i)). The ca9 template numbers them automatically; this one does not.
- **Exhibit 1 (affidavit, exemplar pp. 13–15) and Exhibit A (CV and bibliography, pp. 16–23)** are not transcribed. The body refers to Exhibit 1, which is not in this folder.
- **Exemplar errors kept as filed.** For example: "Alina" in the defined term; "he issue" in C(i); "Complaint ¶¶28-10"; "(Laspro" with no closing parenthesis; the unbalanced quotation at the end of footnote 2. The transcription keeps them, so the overlay shows them as text differences.
- **Running-header case number.** The exemplar's running header reads "Case No. 14-29974-BKC-LMI", while its cover reads 14-22974-BKC-LMI. The template uses the cover number.
- **L.R. 9004-1(d)** (no incorporation by reference) is not enforced by the template.
- **Page 9 white space** is the cost of keeping the Conclusion with its signature.

## Status

`court.json` is not touched; status is not set. Shared tools, the root README, `STATUS.md` and `data/` are not edited.
