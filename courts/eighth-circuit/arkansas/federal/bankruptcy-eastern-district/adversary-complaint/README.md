# Adversary complaint: U.S. Bankruptcy Court, E.D. Ark. (areb)

Exemplar: a real filed complaint, *Franks et al. v. Watkins*, Adv. No. 4:26-ap-01015 (E.D. Ark., filed 04/17/2026, counsel Lax, Vaughan, Fortson, Rowe & Threet, P.A.). See `exemplars/SOURCE.md`.

Status: exemplar saved; transcription rendered; overlay run; every page viewed (Gate 2 below). Open tier-2 items are listed under "Known gaps".

## What is here

| Path | What |
|---|---|
| `typst/areb-adversary-complaint.typ` | Template: `areb-complaint(meta, md)`. Every number is a named parameter at the top, and each traces to a rule ID or is marked as a convention. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits the frontmatter from the body, calls the template. |
| `exemplars/FILED-EXAMPLE-watkins-4-26-ap-01015-adversary-complaint.pdf` | The filed document (9 pp.): the B1040 cover sheet and the complaint through its signature. State-court exhibits A and B were removed. |
| `samples/INPUT-watkins-adversary-complaint.md` | Transcription of the complaint: caption, numbered paragraphs 1-29 under the filed headings, prayer, signature block. Names and text as filed. |
| `samples/OUTPUT-watkins-adversary-complaint.pdf` | Our render of the transcription (6 pp.). |
| `samples/OVERLAY-watkins-adversary-complaint.pdf` / `.txt` | Red (ours) over blue (filed) per page; `.txt` is the page map. |
| `exemplars/SOURCE.md` | Source, filer, dates and the search log. |

Build (from the repo root, with `PATH="$HOME/tb/bin:$PATH"` per the box setup):

```sh
D=courts/eighth-circuit/arkansas/federal/bankruptcy-eastern-district/adversary-complaint
sh tools/render.sh $D samples/INPUT-watkins-adversary-complaint.md     # -> samples/OUTPUT-watkins-adversary-complaint.pdf
sh tools/overlay.sh $D watkins-adversary-complaint                     # -> samples/OVERLAY-watkins-adversary-complaint.pdf/.txt
```

Fonts are the vendored EB Garamond only (`--ignore-system-fonts`); any typst warning fails the render.

## Governing rules

Verified 2026-10-14 against the sources below. Federal rule text came from the Legal Information Institute (law.cornell.edu), which mirrors the current restyled rules (effective Dec. 1, 2024). The local rules came from the court's own site.

| ID | Requirement | Source (URL) |
|---|---|---|
| AREB-CAP-001 | Caption: court name, case title, case number and adversary number, brief designation of the document | FRBP 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 |
| AREB-CAP-002 | Adversary caption: FRCP 10 applies, with the caption substantially conforming to Official Form 416 (the complaint caption; the letter suffix was not verified); title names all parties; the complaint has a Rule 7(a) designation | FRBP 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 ; FRCP 10(a), https://www.law.cornell.edu/rules/frcp/rule_10 |
| AREB-PAR-001 | Claims and defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances; later pleadings may refer to earlier paragraphs by number | FRCP 10(b), https://www.law.cornell.edu/rules/frcp/rule_10 |
| AREB-JUR-001 | Jurisdiction allegation names the case's name, number and chapter, and the district and division; the complaint states whether the pleader consents to entry of final orders (and core or non-core) | FRBP 7008(a), https://www.law.cornell.edu/rules/frbp/rule_7008 (text read; the 7008 page includes the 1987 committee note on core/non-core) |
| AREB-CLASS-001 | The proceeding is an adversary proceeding under the Part VII classes; the complaint cites them. Used here: (a) recover money or property (turnover, § 542), (f) determine whether a debt is dischargeable (§ 523) | FRBP 7001, https://www.law.cornell.edu/rules/frbp/rule_7001 |
| AREB-SIG-001 | Signed by at least one attorney of record in the attorney's individual name; each document states the signer's address and telephone | FRBP 9011(a), https://www.law.cornell.edu/rules/frbp/rule_9011 |
| AREB-ATTY-001 | Every filing: attorney's complete address, telephone number and state bar number; adversary cover sheet filled in completely | E.D./W.D. Ark. Local Rule 5005-4 (adopted 1/12/2006), https://www.areb.uscourts.gov/sites/arb/files/LocalRules.pdf (complete set; the court index lists it as revised 8/2/2018) |
| AREB-FORM-003 | Margins: one inch (convention; no rule sets margins for this court) | convention |
| AREB-FORM-004 | Type size 12 pt, body about double spaced (convention; no rule sets type size or spacing for this court) | convention |

Court-specific findings, to be read before editing the template:

- **No local rule covers form of papers.** The complete set (`LocalRules.pdf`, 17 pages) has rules 1001-1, 1020-1, 2015-1, 2072-1, 2090-1, 2090-2, 3015-1, 5001-2, 5005-4, 7033-1, 9015-1 and 9019-1. None sets font, size, margins, spacing or page limits for pleadings. It has no Rule 7001 local rule and no Rule 9013-1 local rule. The layout therefore comes from the federal rules plus conventions, and the tier-2 bar falls to the exemplar (`exemplars/FILED-EXAMPLE-watkins-4-26-ap-01015-adversary-complaint.pdf`).
- **Local Rule 5005-4 is the only court-specific format rule.** It applies to all filings, electronic or not.
- Proposed orders: Local Rule 9019-1 governs consent orders only. It is not used by this template.

## What the overlay shows

`tools/overlay.sh` run 2026-10-14 (`samples/OVERLAY-watkins-adversary-complaint.txt`). Pages are paired by word overlap, so the page numbers below are the filed document's, which includes the cover sheet on pages 1-2.

| Our page | Filed page | Word overlap |
|---|---|---|
| 1 | 3 (caption) | 96.0% |
| 2 | 4 | 78.8% |
| 3 | 5 | 55.5% |
| 4 | 7 | 66.1% |
| 5 | 8 | 86.1% |
| 6 | 9 (signature) | 78.3% |

The overlap is a pairing aid, not a score. The low pairs are pages where the filed text runs on at different line breaks, so the lines do not register. The render was checked against the filed pages by eye (below).

## Page review (Gate 2)

Rendered 2026-10-14 at 80 dpi, each page beside its filed page. Every page of `samples/OUTPUT-watkins-adversary-complaint.pdf` was viewed in its final state (6 of 6).

| Page | Result |
|---|---|
| 1 | Caption, title, preamble, paragraph 1. Pass after the caption fix (justified names had opened gaps). The adversary-number field prints blank as the filing does. |
| 2 | Parties (paragraphs 2-3), facts A (4-10). Pass. |
| 3 | Paragraphs 11-18. Pass. |
| 4 | Paragraphs 19-24, Part IV heading. Pass after the heading fix (`523(A)(6)` had been printed). |
| 5 | Paragraphs 25-29, Part V prayer, start of the WHEREFORE clause. Pass. |
| 6 | End of the prayer, `Respectfully submitted`, `s/ Branch T. Fields`, counsel block with phone. Pass after the signer fix (name had been printed in capitals). |

Defects found in review and fixed:

1. Caption names were justified, so lines like "BRUCE WATKINS, II and HEIDA FARQUE" had wide gaps. The caption is now ragged-right (template).
2. Level-1 headings went through `upper()`, which printed the statute cite as `523(A)(6)` (the same error as the title fix above). Headings print as written (template; the motion template has the same fix).
3. The `s/ NAME` line was printed in capitals. It is now printed as written, matching the filing (template).
4. The debtor names were one entry, which wrapped badly. The transcription now lists the two debtors on separate lines, as the filing does (transcription).

## Known gaps

- **Tier-2 items open, judged minor.**
  - Statute cites break at the parenthesis (`§ 523(a)` / `(6)`). A non-breaking join would fix it; not done.
  - The filing indents the first line of every paragraph, including the unnumbered preamble and WHEREFORE clause. The template indents only numbered paragraphs.
- **Accepted differences from the filing (template conventions).**
  - Caption label `Adv. Proc. No.` (the filing says `AP NO.`). The number is blank, as on the filing.
  - Debtor designation prints `Debtors.` where the filing prints `Debtor(s).`
  - Caption debtor names are centred; the filing left-aligns them under `IN RE:`.
  - Part headings are set on one line in title case, not as the filing's numeral over the title.
  - `Respectfully submitted,` and `s/ NAME` follow common practice; the filing reads `By: /s/ NAME`.
- **Length.** The filed complaint body is 7 pages (PDF pages 3-9); our render is 6 pages. The 8-14 page target was not applied because the filed complaint is shorter than 8 pages. The cover sheet (pages 1-2 of the exemplar) is not generated and is not counted.
- **Cover sheet not generated.** Official Form B104 (adversary proceeding cover sheet) must accompany the complaint; LR 5005-4 requires it to be complete. The template does not produce it. The exemplar includes the filed B1040 cover sheet, for reference.
- **Summons not generated.** The summons (the adversary summons form; the form number was not verified) is a separate document, not part of this template.
- **Privacy redactions not checked.** The filing states Debtors' names and a case number, and no SSN or account numbers appear in the transcription. Filers must redact under Fed. R. Bankr. P. 9037 (not fetched).
- **Electronic-filing and signature conventions** (`s/ NAME`, `Dated:` placement) follow common practice; they are not verified against the court's ECF procedures (not fetched). The filed complaint has no `Dated:` line, so the sample has none.
- **Attorney block placement.** LR 5005-4 requires the information on every filing; the template places it under the signature, and the filing does the same. Whether the court wants it at the top of page 1 is unverified.

## Known gaps

- **No exemplar.** Tier-2 conventions (spacing, caption proportions, cover-sheet placement, page furniture) are unchecked against a filed complaint. The 12 pt and double-spacing choices are conventions, not rule requirements.
- **Cover sheet not generated.** Official Form B104 (adversary proceeding cover sheet) must accompany the complaint; LR 5005-4 requires it to be complete. The template does not produce it.
- **Summons not generated.** The summons (the adversary summons form; the form number was not verified) is a separate document, not part of this template.
- **Privacy redactions not checked.** The sample uses no SSN or account numbers. Filers must redact under Fed. R. Bankr. P. 9037 (not fetched).
- **Length.** The sample is 5 pages. There is no exemplar length to target, so the 8-14 page target could not be applied.
- **Electronic-filing and signature conventions** (`s/ NAME`, `Dated:` placement) follow common practice; they are not verified against the court's ECF procedures (not fetched).
- **Attorney block placement.** LR 5005-4 requires the information on every filing; the template places it under the signature. Whether the court wants it at the top of page 1 is unverified.
