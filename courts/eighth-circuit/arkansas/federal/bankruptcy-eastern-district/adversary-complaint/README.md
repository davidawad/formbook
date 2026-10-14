# Adversary complaint: U.S. Bankruptcy Court, E.D. Ark. (areb)

**BLOCKED: no exemplar.** No filed adversary complaint from this court was found. The searches tried are recorded in `exemplars/SOURCE.md`. The sample is synthetic and labelled as such. The overlay cannot run without an exemplar PDF.

Status: template built from the rules; render and page review done (below); overlay not run (no exemplar).

## What is here

| Path | What |
|---|---|
| `typst/areb-adversary-complaint.typ` | Template: `areb-complaint(meta, md)`. Every number is a named parameter at the top, and each traces to a rule ID or is marked as a convention. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits the frontmatter from the body, calls the template. |
| `samples/INPUT-generic-adversary-complaint.md` | Synthetic sample (invented names, numbers and dates). Exercises the caption, numbered paragraphs, count headings, prayer and counsel block. |
| `samples/OUTPUT-generic-adversary-complaint.pdf` | Render of the sample (5 pages). |
| `exemplars/SOURCE.md` | The exemplar search log. No PDF saved. |

Build (from the repo root, with `PATH="$HOME/tb/bin:$PATH"` per the box setup):

```sh
D=courts/eighth-circuit/arkansas/federal/bankruptcy-eastern-district/adversary-complaint
sh tools/render.sh $D samples/INPUT-generic-adversary-complaint.md   # -> samples/OUTPUT-generic-adversary-complaint.pdf
sh tools/overlay.sh $D generic-adversary-complaint             # fails: no exemplar PDF in exemplars/
```

Fonts are the vendored EB Garamond only (`--ignore-system-fonts`); any typst warning fails the render. The overlay tool writes `samples/OVERLAY-<id>.pdf` and `.txt` by its own naming, not `<id>-overlay.pdf`.

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

- **No local rule covers form of papers.** The complete set (`LocalRules.pdf`, 17 pages) has rules 1001-1, 1020-1, 2015-1, 2072-1, 2090-1, 2090-2, 3015-1, 5001-2, 5005-4, 7033-1, 9015-1 and 9019-1. None sets font, size, margins, spacing or page limits for pleadings. It has no Rule 7001 local rule and no Rule 9013-1 local rule. The layout therefore comes from the federal rules plus conventions, and the tier-2 bar falls to the exemplar, which is missing.
- **Local Rule 5005-4 is the only court-specific format rule.** It applies to all filings, electronic or not.
- Proposed orders: Local Rule 9019-1 governs consent orders only. It is not used by this template.

## What the overlay shows

Not run. The overlay compares our render against a filed exemplar. With no exemplar the page-pairing has nothing to pair against, so the red/blue test cannot show anything yet. Once a filed complaint is saved in `exemplars/`, run the overlay and record the page map in this README.

## Page review (Gate 2)

Rendered 2026-10-14 at 60 dpi. Every page of `samples/OUTPUT-generic-adversary-complaint.pdf` was viewed.

| Page | Result |
|---|---|
| 1 | Caption, title, first numbered paragraphs. Pass. |
| 2 | Parties and facts. Pass. |
| 3 | Facts continued, sub-headings. Pass. |
| 4 | Counts I to III headings and paragraphs. Pass. |
| 5 | Prayer, date, signature line (`s/ COUNSEL EXAMPLE`), counsel block. Pass after the signer line was added (it was missing in the first render). |

Defects found and fixed during review:

1. The title was passed through `upper()`, so the statute cite `523(a)(2)(A)` printed as `523(A)(2)(A)`. The title is now printed as written.
2. The paragraph number ran into its text. Numbered paragraphs now use a first-line indent with the number and text on one line.
3. The signature block lacked the `s/ NAME` line required for the signer. Added.
4. Level-1 headings printed larger than the body. Headings now use the body size.

## Known gaps

- **No exemplar.** Tier-2 conventions (spacing, caption proportions, cover-sheet placement, page furniture) are unchecked against a filed complaint. The 12 pt and double-spacing choices are conventions, not rule requirements.
- **Cover sheet not generated.** Official Form B104 (adversary proceeding cover sheet) must accompany the complaint; LR 5005-4 requires it to be complete. The template does not produce it.
- **Summons not generated.** The summons (the adversary summons form; the form number was not verified) is a separate document, not part of this template.
- **Privacy redactions not checked.** The sample uses no SSN or account numbers. Filers must redact under Fed. R. Bankr. P. 9037 (not fetched).
- **Length.** The sample is 5 pages. There is no exemplar length to target, so the 8-14 page target could not be applied.
- **Electronic-filing and signature conventions** (`s/ NAME`, `Dated:` placement) follow common practice; they are not verified against the court's ECF procedures (not fetched).
- **Attorney block placement.** LR 5005-4 requires the information on every filing; the template places it under the signature. Whether the court wants it at the top of page 1 is unverified.
