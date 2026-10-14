# D. Kan. Bankr. (ksb): motion brief (memorandum in support of a motion)

- Court: `ksb`, United States Bankruptcy Court for the District of Kansas (`courts/tenth-circuit/kansas/federal/bankruptcy-district/`)
- Doc type: `motion-brief`. The memorandum that supports a motion, here a motion to dismiss an adversary complaint (LBR 7012.1(a) requires it). The motion itself is a separate filing and is not produced. One self-contained folder.
- Exemplar: `exemplars/FILED-EXAMPLE-williamson-social-networking-20-05036-motion-brief.pdf` (*Williamson v. Comcast Spotlight, LP*, Adv. No. 20-05036, memorandum filed 2020-04-06, 13 pages with table of contents and table of authorities). Provenance, search trail and caveats in `exemplars/SOURCE.md`. The file was re-downloaded from its URL on 2026-10-14.
- Sample: `samples/INPUT-williamson-comcast-memorandum.md`, a transcription of the filed memorandum: caption, counsel block, the table of contents and table of authorities (built by the template from links in the body), introduction, nature of proceedings, factual allegations, question presented, legal standard, Argument (two levels of headings), conclusion, signature block, and certificate of service.
- Status: template complete, rendered, overlaid, and every page reviewed (below). `court.json` untouched.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point. Reads `--input sample=...` and calls `ksb-motion-brief`. |
| `typst/ksb-motion-brief.typ` | Template. Parameter block at the top (type, spacing, margins, indents, the passim threshold). Metadata and section checks at the top of `ksb-motion-brief`. |
| `samples/INPUT-williamson-comcast-memorandum.md` | Markdown contract sample: YAML frontmatter, then the body. |
| `samples/OUTPUT-williamson-comcast-memorandum.pdf` | `sh tools/render.sh courts/tenth-circuit/kansas/federal/bankruptcy-district/motion-brief samples/INPUT-williamson-comcast-memorandum.md` (14 pages, no typst warnings). |
| `samples/OVERLAY-williamson-comcast-memorandum.pdf`, `.txt` | `sh tools/overlay.sh courts/tenth-circuit/kansas/federal/bankruptcy-district/motion-brief williamson-comcast-memorandum` (red = ours, blue = filed, black = agree; page map in the `.txt`). |
| `exemplars/` | The filed exemplar and `SOURCE.md`. |

### Frontmatter contract (sample metadata)

Required by the template (a missing key is a build failure): `court`, `debtor` (`names`, `designation`), `bankruptcy_case`, `chapter`, `caption` (list of `names` + `designation`), `title`, `counsel` (list of lines), `counsel_role`, `date`, `signature` (`preamble`, `signer`, `lines`, `role`), and `service` (`document`). Optional: `adversary_number` (printed as `Adv. No.`), `authorities` (a map from a key to `{kind, name | cite}`; every key used as `toa:<key>` in the body is listed in the TOA; a missing key fails the build). The body must contain `#` headings containing NATURE, FACT, QUESTION and ARGUMENT (LBR 9013.1(a)(1)-(4)); the template fails otherwise.

## Governing rules

Checked 2026-10-14.

| Source | Rule text used | URL |
|---|---|---|
| Fed. R. Bankr. P. 9004(a), (b) | Legible; caption with court name, case title, case number and adversary number, and a brief designation of the document. | <https://www.law.cornell.edu/rules/frbp/rule_9004> |
| Fed. R. Bankr. P. 9013 | A motion must state its grounds with particularity and the relief requested. The memorandum supports the motion (see LBR 7012.1(a)). | <https://www.law.cornell.edu/rules/frbp/rule_9013> |
| Fed. R. Bankr. P. 7012(b) | Fed. R. Civ. P. 12(b)–(i) applies in an adversary proceeding. The template cites Rule 12(b)(6) as the standard in the sample. | <https://www.law.cornell.edu/rules/frbp/rule_7012> |
| D. Kan. LBR 9004.1(a)(1) | 8½ × 11 paper; type no smaller than 12 points, set no more than an average of 12 characters per inch; double-spaced where practicable. | <https://www.ksb.uscourts.gov/sites/ksb/files/KS_LBRs_2024Dec.pdf> (p. 55; as amended 12/1/24) |
| D. Kan. LBR 9004.1(a)(2) | Pagination from the first page; numbered pages include the cover, the table of contents, the table of authorities, and every other part. | same (p. 56) |
| D. Kan. LBR 9004.1(a)(1), via LBR 9013.2(e) | Motions and orders follow LBR 9004.1. | same (p. 59) |
| D. Kan. LBR 9013.1(a)(1)–(4) | A brief or memorandum must state the nature of the matter, the facts (with record references), the question presented, and the argument with all authorities relied on. | same (p. 59) |
| D. Kan. LBR 9013.1(b) | The arguments and authorities section must not exceed 30 pages absent court order. Not checked by the template (the sample is 14 pages). | same (p. 59) |
| D. Kan. LBR 9013.1(c) | Exhibits attached to a brief must be separately labeled. | same (p. 59) |
| D. Kan. LBR 7012.1(a) | A motion to dismiss under FRBP 7012 must be filed with a supporting brief or memorandum. | same (p. 51) |
| D. Kan. LBR 7012.1(b)–(d) | Response within 21 days, reply within 14 days; one response and one reply without leave; oral argument may be requested in the motion or the memorandum. Timing is not in the template. | same (p. 51) |
| D. Kan. LBR 9013.2(d) | Briefs for non-dispositive motions are prohibited unless the court requires them. A motion to dismiss is dispositive, so this template does not apply to it. | same (p. 59) |
| D. Kan. LBR 9013.3(a), (a)(1) | Certificate of service: it must say that service was through the Notice of Electronic Filing for filing users, identify each document served, and show the manner of service on non-filing users. | same (p. 60) |

Requirement IDs used in `ksb-motion-brief.typ`:

| ID | Requirement | Where | Source | Kind |
|---|---|---|---|---|
| KSB-FORM-001 | 8½ × 11 paper, margins 1 inch on all sides | `set page` | LBR 9004.1(a)(1) (paper); margin is a style choice | M (paper), C (margin) |
| KSB-FORM-002 | Type ≥ 12 pt and ≤ 12 characters per inch on average | `type-size = 16pt` | LBR 9004.1(a)(1). At 14 pt EB Garamond measured 13.4 cpi | M |
| KSB-FORM-003 | Double-spaced where practicable | `line-pitch = 2 × type-size` | LBR 9004.1(a)(1) | M |
| KSB-FORM-004 | Pages numbered from the first page, the cover included | `numbering: "1"` | LBR 9004.1(a)(2) | M |
| KSB-MEM-001 | The four required sections (nature, facts, question presented, argument) | `ksb-motion-brief` panics on a missing heading | LBR 9013.1(a)(1)–(4) | M |
| KSB-MEM-002 | The arguments and authorities section is at most 30 pages | not checked | LBR 9013.1(b) | M, not yet enforced |
| KSB-CAP-001 | Caption: court name, case title, case number, adversary number, designation | `caption-block` | FRBP 9004(b) | M |
| KSB-CERT-001 | Certificate of service identifies the document and the manner of service (NEF) | `certificate-of-service` | LBR 9013.3(a), (a)(1) | M |

## Overlay

`samples/OVERLAY-williamson-comcast-memorandum.pdf` (14 pages, one per page of our render) puts our render (red) over the best-matching page of the filed memorandum (blue). Pages are paired by word overlap, not index.

- Pairings (word overlap, from the `.txt` map): ours p.1 ↔ filed p.1 (63%), p.2 ↔ p.2 (68%), p.3 ↔ p.4 (40%), p.4 (TOA continuation) ↔ no match, p.5 ↔ p.5 (86%), p.6 ↔ p.6 (34%), p.7 ↔ p.6 (44%), p.8 ↔ p.7 (37%), p.9 ↔ p.7 (62%), p.10 ↔ p.8 (54%), p.11 ↔ p.8 (58%), p.12 ↔ p.9 (45%), p.13 ↔ p.1 (34%), p.14 ↔ p.13 (84%). Pairing by word overlap is only a locator; it does not show that the layouts match.
- Visible differences: the filed memorandum uses Times, our render uses EB Garamond, so line breaks fall at different words. The blue layer carries the ECF header and footer (`Doc# 8`, `Filed 04/06/20`, per `SOURCE.md`) and the filer's own TOC and TOA page numbers. Our p.13 (signature block) pairs with filed p.1 by overlap, which is a weak match; our p.14 (certificate of service) pairs with filed p.13.
- The overlay is a diagnostic (tier 3), not a score.

## Page review (Gate 2)

Every page of `OUTPUT-williamson-comcast-memorandum.pdf` was rendered at 70 dpi and viewed (14 of 14). Typst printed no warnings. Fonts: EB Garamond only. The "Compared with" column gives the overlay pairing. Filed pages were viewed as images only for overlay p.8.

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | filed p.1 (overlay) | Counsel block, caption, title in capitals. Case and adversary numbers on the right. | PASS |
| 2 | filed p.2 (overlay) | Table of contents: headings, page column, dot leaders, two-level entries. | PASS |
| 3 | filed p.4 (overlay) | Table of authorities, Cases group, Federal Statutes. Page(s) column; passim threshold not reached. | PASS |
| 4 | none | Table of authorities continues (Federal Rules). Rest of page blank by design: the body starts on a new page. | ACCEPTED |
| 5 | filed p.5 (overlay) | Introduction and summary; section heading centered in capitals. | PASS |
| 6 | filed p.6 (overlay) | Introduction end; Nature and Stage of Proceedings. | PASS |
| 7 | filed p.6 (overlay) | Nature (end); Factual Allegations; Question Presented. | PASS |
| 8 | filed p.7 (overlay) | Legal Standard; citations in italics. Overlay p.8 was viewed as an image. | PASS |
| 9 | filed p.7 (overlay) | Argument heading A. with a hanging label; the first paragraph of Argument. | PASS |
| 10 | filed p.8 (overlay) | Argument A.1. heading (hanging label, bold); text. | PASS |
| 11 | filed p.8 (overlay) | Argument A.1. continues; citations in the body. | PASS |
| 12 | filed p.9 (overlay) | End of argument; Conclusion heading and WHEREFORE paragraph. | PASS |
| 13 | filed p.1 (overlay, by overlap) | Signature block alone: "Dated" line and the firm block. The WHEREFORE paragraph stays on p.12. A signature alone on a page is the layout the rules do not dictate, but a clerk would notice it. | OPEN |
| 14 | filed p.13 (overlay) | Certificate of service: wording, signature, role. | PASS |

**OPEN (p. 13):** the signature block is alone on its page. The fix is to keep the conclusion's last paragraph with the block; the template does not do that yet. It was not changed in this pass, because the existing template is not broken and the change touches the layout of every signature block. A follow-up should decide it.

## Known gaps

1. **One exemplar.** Tier 2 wants two or three filers. The second candidate in `exemplars/SOURCE.md` (*Taylor v. Community Loan Servicing*, 23-06024, doc 45) was not downloaded in this pass.
2. **The motion is not produced.** Only the memorandum; the motion it supports is a separate filing.
3. **Page 13 signature block** (OPEN above).
4. **Passim and TOA checks** are template behaviour (pages from `toa:` links, passim at 7 or more pages). The sample's authorities were added by hand and were not cross-checked against the PDF text here.
5. **The 30-page limit** (LBR 9013.1(b)) is not enforced. The sample is 14 pages.
6. **No consent statement or local-rule timing** is checked: LBR 7012.1(b)–(c) is procedure, not a layout requirement.
7. **Counsel block** is the filer's own; the template prints it as given.
8. **Character density** (LBR 9004.1(a)(1)) is not checked mechanically. 16 pt was chosen from a 14 pt measurement (13.4 cpi); the 16 pt figure was not re-measured.
