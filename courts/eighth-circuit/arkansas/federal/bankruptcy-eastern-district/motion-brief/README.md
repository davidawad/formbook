# Motion with memorandum (brief) in support: U.S. Bankruptcy Court, E.D. Ark. (areb)

Exemplar: a real filed motion to dismiss an adversary proceeding, with its memorandum (argument and authorities) in the same document. *Stewart v. Navient Solutions, LLC*, Adv. No. 3:23-ap-01057 (E.D. Ark., Northern Division, filed 11/13/2023, counsel Wetzel and Moore, P.A.). See `exemplars/SOURCE.md`.

Status: exemplar saved; transcription rendered; overlay run; every page viewed (Gate 2 below). Open tier-2 items are listed under "Known gaps".

## What is here

| Path | What |
|---|---|
| `typst/areb-motion-brief.typ` | Template: `areb-motion-brief(meta, md)`. Every number is a named parameter at the top, and each traces to a rule ID or is marked as a convention. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits the frontmatter from the body, calls the template. |
| `exemplars/FILED-EXAMPLE-stewart-3-23-ap-01057-motion-brief.pdf` | The filed document (8 pp., RECAP doc 5 copied as filed). |
| `samples/INPUT-stewart-navient-motion-brief.md` | Transcription of the motion and its memorandum: caption (adversary), motion paragraphs 1-8, argument and authorities, ineffective-service argument, WHEREFORE clause, signature block, service list. Names and text as filed. |
| `samples/OUTPUT-stewart-navient-motion-brief.pdf` | Our render of the transcription (7 pp.). |
| `samples/OVERLAY-stewart-navient-motion-brief.pdf` / `.txt` | Red (ours) over blue (filed) per page; `.txt` is the page map. |
| `exemplars/SOURCE.md` | Source, filer, dates and the search log. |

Build (from the repo root, with `PATH="$HOME/tb/bin:$PATH"` per the box setup):

```sh
D=courts/eighth-circuit/arkansas/federal/bankruptcy-eastern-district/motion-brief
sh tools/render.sh $D samples/INPUT-stewart-navient-motion-brief.md   # -> samples/OUTPUT-stewart-navient-motion-brief.pdf
sh tools/overlay.sh $D stewart-navient-motion-brief                   # -> samples/OVERLAY-stewart-navient-motion-brief.pdf/.txt
```

Fonts are the vendored EB Garamond only (`--ignore-system-fonts`); any typst warning fails the render.

## Governing rules

Verified 2026-10-14. Federal rule text came from the Legal Information Institute (law.cornell.edu), which mirrors the current restyled rules (effective Dec. 1, 2024). The local rules came from the court's own site.

| ID | Requirement | Source (URL) |
|---|---|---|
| AREB-MOT-001 | A written motion (FRBP 9013(a)) must state its grounds with particularity and set forth the relief or order requested. The template gives numbered motion paragraphs for grounds and relief. | FRBP 9013(a)-(b), https://www.law.cornell.edu/rules/frbp/rule_9013 |
| AREB-MOT-002 | The movant serves the motion on the trustee or debtor in possession and the entities the rules or the court designate, within the time under Rule 9006(d). The certificate of service states the method and the parties. | FRBP 9013(b), https://www.law.cornell.edu/rules/frbp/rule_9013 (9006(d) not fetched) |
| AREB-CAP-001 | Caption: court name, case title, case number and adversary number (if any), brief designation of the document | FRBP 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 |
| AREB-SIG-001 | Signed by at least one attorney of record in the attorney's individual name; each document states the signer's address and telephone | FRBP 9011(a), https://www.law.cornell.edu/rules/frbp/rule_9011 |
| AREB-ATTY-001 | Every filing: attorney's complete address, telephone number and state bar number | E.D./W.D. Ark. Local Rule 5005-4 (adopted 1/12/2006), https://www.areb.uscourts.gov/sites/arb/files/LocalRules.pdf (complete set; the court index lists it as revised 8/2/2018) |
| AREB-MEM-001 | No rule requires a memorandum or brief with a bankruptcy motion in this court. The memorandum is a convention, and the sample's structure (introduction, facts, argument, conclusion) is the usual shape. | convention; no E.D. Ark. Local Rule 9013-1 exists (see findings) |
| AREB-FORM-003 | Margins: one inch (convention; no rule sets margins for this court) | convention |
| AREB-FORM-004 | Type size 12 pt, body about double spaced (convention; no rule sets type size or spacing for this court) | convention |

Court-specific findings, to be read before editing the template:

- **No Local Rule 9013-1.** The complete local rules set (`LocalRules.pdf`, 17 pages) lists rules 1001-1, 1020-1, 2015-1, 2072-1, 2090-1, 2090-2, 3015-1, 5001-2, 5005-4, 7033-1, 9015-1 and 9019-1. It has no motion rule, and no rule on the form of papers (font, size, margins, spacing, page limits). The brief requested "per this court's local bankruptcy rules", but the court's local rules do not supply one. The template therefore takes its layout from FRBP 9013 and conventions.
- **Local Rule 9019-1** governs consent orders and routine orders. It does not govern motions and is not used here. Under it a proposed order is submitted only if it is a consent or routine order.
- **Local Rule 5005-4** applies to all filings, electronic or not, and requires the attorney's address, phone and bar number.

## What the overlay shows

`tools/overlay.sh` run 2026-10-14 (`samples/OVERLAY-stewart-navient-motion-brief.txt`). Pages are paired by word overlap; the filed page numbers are those of the 8-page filing.

| Our page | Filed page | Word overlap |
|---|---|---|
| 1 | 1 (caption) | 95.0% |
| 2 | 2 | 88.7% |
| 3 | 3 | 60.2% |
| 4 | 5 | 62.9% |
| 5 | 6 | 74.1% |
| 6 | 7 (signature) | 55.7% |
| 7 | 8 (certificate of service) | 31.2% |

The overlap is a pairing aid, not a score. The low pairs are the argument pages, where the filed text runs on at different line breaks, and the certificate, whose wording is the template's boilerplate and differs from the filing's.

## Page review (Gate 2)

Rendered 2026-10-14 at 80 dpi, each page beside its filed page where it matters. Every page of `samples/OUTPUT-stewart-navient-motion-brief.pdf` was viewed in its final state (7 of 7).

| Page | Result |
|---|---|
| 1 | Caption with the adversary block, title, introduction. Pass after the debtor-name fix (the template already prints `In re:` and `Debtor.`). |
| 2 | Procedural facts 1-8, footnote 1, `Argument and Authorities` heading. Pass. |
| 3 | Argument: Bender, Article III ripeness, prudential ripeness. Pass. |
| 4 | Argument: Chapter 13 authorities. The filing's own typo, "as to a whether", is kept as filed. Pass. |
| 5 | Argument: application to the Chapter 11 plan; dismissal request. Pass. |
| 6 | `Ineffective Service` heading and argument, WHEREFORE clause, `Respectfully submitted,` with the signer and the two-line attorney description. Pass after the signer-line fix (the long line had wrapped out of the block). |
| 7 | Counsel block, certificate of service with the served party, signature. Pass, except that the counsel block falls on page 7, apart from the signature on page 6 (open; see below). |

Defects found in review and fixed:

1. Caption names were justified (template; the same fix is in the adversary template).
2. Level-1 headings went through `upper()` (template; `523(A)` would have been the same error on other motions).
3. The `s/ NAME` line was printed in capitals (template).
4. The debtor entry repeated `In re:` and `Debtor.` (transcription).
5. The attorney description was a single long italic line that wrapped to the left margin, out of the right-aligned block (transcription: split into two lines). The template does not limit long signature lines; a longer line would hit the same problem.

## Known gaps

- **Accepted differences from the filing (template conventions).**
  - The certificate of service is the template's boilerplate (CM/ECF and first-class mail), with the service list taken from the metadata. The filing's wording is different.
  - The filing has no separate `Memorandum in Support` heading; its argument follows the motion under `Argument and Authorities`. The transcription keeps the filed headings.
  - Captions and titles are set in title case; the filing sets the title in capitals.
- **Open tier-2 items, judged minor.**
  - The filing indents the first line of every paragraph, including the argument paragraphs. The template indents only numbered paragraphs.
  - Statute and rule cites break at the parenthesis (`Fed.R.Civ.P. 12(b)` / `(5)`). A non-breaking join would fix it; not done.
  - The counsel block is not kept with the signature. The signature sits at the foot of page 6 and the counsel block starts page 7. Each block is `breakable: false` on its own; a keep-together across both is the likely fix, not tested.
  - The filing's footnote 1 is transcribed as a paragraph, because the template has no footnote support. The footnote is marked `[1]` in the text.
- **Length.** The filing is 8 pages; our render is 7 pages. The filed document is 8 pages, so the 8-14 page target is not applied.
- **Brief.** The filing is a motion with its memorandum in one document. A separately filed brief in support was not found as an available PDF in this court's RECAP results, so the template's two-part shape (motion, then memorandum) is exercised here as one document.
- **Sale-motion authorities not fetched.** The sample cites 11 U.S.C. §§ 363(b), 363(f), 1107, 1108, 157 and 1408 and Fed. R. Bankr. P. 6004. These are the sample's content, not the template's, and the text of the statutes and Rule 6004 was not read. Check them before any use of the sample as a model.
- **Page limits and standing orders not checked.** No local rule limits motion or brief length. Chief Judge or judge-specific standing orders were not searched, and they may impose limits or proposed-order requirements.
- **Proposed order not generated.** Many courts want a proposed order with a motion. This court's rules were not found to require one for a motion. The template does not produce one.
- **Electronic-filing and signature conventions** (`s/ NAME`, `Dated:` placement) follow common practice; they are not verified against the court's ECF procedures (not fetched). The filing has no `Dated:` line, so the sample has none.
