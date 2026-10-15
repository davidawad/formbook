# M.D. Alabama Bankruptcy Court: adversary complaint (`almb`)

Doc-type folder for the adversary complaint in the United States Bankruptcy Court for the Middle District of Alabama. Engine: typst (`typst/`). Parent court: [`../README.md`](../README.md).

- Exemplar: `exemplars/FILED-EXAMPLE-southeastern-stud-adversary-complaint.pdf` (1 filer; see `exemplars/SOURCE.md`).
- Sample: `samples/INPUT-southeastern-stud.md` (transcribed from the exemplar), rendered to `samples/OUTPUT-southeastern-stud.pdf` (12 pages).
- Overlay: `samples/OVERLAY-southeastern-stud.pdf` and `samples/OVERLAY-southeastern-stud.txt`.
- Render: `sh tools/render.sh <this-dir> samples/INPUT-southeastern-stud.md`. Overlay: `sh tools/overlay.sh <this-dir> southeastern-stud`.

## Rules (requirement IDs)

Verified 2026-10-14 from the primary text. Kind: **M** mandated by a rule, **C** convention, **A** author responsibility.

| ID | Requirement | Kind | Source (verified) |
|---|---|---|---|
| ALMB-ADV-001 | A proceeding of the kinds listed in Rule 7001 (recovering money or property, determining the validity, priority or extent of liens, and similar) is commenced by an adversary complaint. | M | FRBP 7001, https://www.law.cornell.edu/rules/frbp/rule_7001 (cited by the court's attorney guide, `almb.uscourts.gov/sites/almb/files/Filing_an_Adversary_Proceeding_Attorneys.pdf`; the guide says no specific complaint form is required). Rule text not fetched this session. |
| ALMB-ADV-002 | The caption must substantially conform to Official Form 416 (Form 416D for an adversary proceeding). | M | FRBP 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 ("a pleading's caption must substantially conform to the appropriate version of Form 416"). Last amended 2024-04-02, eff. 2024-12-01. |
| ALMB-ADV-003 | The caption shows the court name, the case title, the case number and adversary-proceeding number, and a brief designation of the document. | M | FRBP 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 ("the court's name", "the case's title", "the case number and, if appropriate, adversary-proceeding number", "a brief designation of the document's character"). Last amended 2024-04-02, eff. 2024-12-01. |
| ALMB-ADV-004 | The document is legible. | M | FRBP 9004(a), same URL ("must be clearly legible"). |
| ALMB-ADV-005 | Jurisdiction is alleged by reference to the name, number and Code chapter of the case, and the district and division where it is pending. | M | FRBP 7008(a), https://www.law.cornell.edu/rules/frbp/rule_7008. Last amended 2024-04-02, eff. 2024-12-01. The template renders this sentence from frontmatter. |
| ALMB-ADV-006 | The complaint states whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. | M | FRBP 7008(a), same URL. The template renders the pleader's statement from `jurisdiction.consent`. The pleader must choose it; it is a bracketed placeholder in the sample. |
| ALMB-ADV-007 | Federal Rule of Civil Procedure 10 applies in an adversary proceeding (numbered paragraphs, each averment in its own paragraph). | M | FRBP 7010 (applies FRCP 10). The FRCP 10(b) text was not fetched this session. The template numbers allegations as written in the markdown. |
| ALMB-ADV-008 | Every signed paper has a signature block at the end of the text with the full name of each signer, at least one complete mailing address, at least one telephone number and an email address. `/s/` is an acceptable signature. | M | LBR 9011-1(a)-(b) (M.D. Ala. Local Rules, effective 2017-12-01, PDF `almb.uscourts.gov/sites/almb/files/Local_Rules_Dec_1_%202017.pdf`, p. 48). Not checked against the later 2024 local rule set (see Gaps). |
| ALMB-ADV-009 | A complaint is served with the summons (Official Form B 2500A). The clerk-issued summons cover sheet and the certificate of service are filed with the complaint to show service. | M | LBR 7005-1(c) (2017 local rules, p. 43); the attorney guide (`Filing_an_Adversary_Proceeding_Attorneys.pdf`) says attach Form B 2500A, both pages. This template does not produce the summons or the certificate; they are separate filings. |
| ALMB-ADV-010 | Filing fee for a complaint: $350 (CM/ECF "Open an AP Case"). | A | Attorney guide (`Filing_an_Adversary_Proceeding_Attorneys.pdf`), fee table. Not a formatting rule. |
| ALMB-ADV-011 | No typography, margin or spacing rule in the local rules. Font, size, margins and double spacing are the template's style choices, matched to the filed exemplar (tier 2). | C | 2017 local rules, full text searched for font, margin, point size, spacing: none. The template follows the exemplar's double spacing, one-inch margins and boxed caption. |

## What the overlay shows

`samples/OVERLAY-southeastern-stud.pdf`: red is our render, blue is the filed exemplar, black is both. Pages are paired by word overlap (`samples/OVERLAY-southeastern-stud.txt`):

| Ours | Filed | Word overlap |
|---|---|---|
| p.1 | p.1 | 56% |
| p.2 | p.2 | 47% |
| p.3 | p.3 | 54% |
| p.4 | p.4 | 60% |
| p.5 | p.6 | 56% |
| p.6 | p.7 | 78% |
| p.7 | p.8 | 50% |
| p.8 | p.10 | 56% |
| p.9 | p.11 | 80% |
| p.10 | p.12 | 60% |
| p.11 | p.12 | 37% |
| p.12 | p.13 | 65% |

The page pairing is a diagnostic. The offsets come from pagination: our rendering uses EB Garamond at 13 pt, the filed copy is a 12 pt Times-style serif on a 13-page scan, so the same text breaks onto different pages. Page 2 pairs with filed page 2 at 47% because our page 2 opens with the consent block, which the filed copy does not have. Visible differences, all tier 2 or 3:

- The filed caption has a boxed left column with the case number and adversary blank at the right; ours matches that structure. The filed copy prints the "v." between the sides; ours does too.
- Filed paragraphs are numbered 1 to 33 with a space after the number; ours matches.
- Our page 1 carries a "Jurisdiction and Consent" block not in the filed copy (FRBP 7008(a), ALMB-ADV-005 and -006). It is a rule-driven addition, not a transcription, so the overlay shows it as red only.
- The filed signature block sits on the last page with the prayer; ours puts the prayer on page 11 and the signature block on page 12. The signature block is about half a page and cannot be kept on the same page as the prayer under these margins; the filed copy also splits its signature across its last two pages. Accepted.

## Gate 2 review

Every page of `samples/OUTPUT-southeastern-stud.pdf` (12 pages) was rendered at 80 dpi and viewed in its final state, both singly and as contact sheets. Findings:

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 | exemplar p.1 | caption box with inset text and "v." between the sides; court title; title | FIXED (caption text was against the box edge; "v." was missing) |
| 2 | exemplar p.2 | consent block heading moved with its text; paragraph indents restored after block items | FIXED |
| 3-9 | exemplar pp.3-9 | numbered paragraphs 1-28, centred headings, Payoff Letter block quotation | PASS |
| 10 | exemplar p.12 | paragraphs 31-33, Count II heading | PASS |
| 11 | exemplar p.12 | prayer alone on the page, signature block on page 12 | ACCEPTED (reason: see "What the overlay shows") |
| 12 | exemplar p.13 | signature block, both signers, /s/ lines and emails | PASS |

## Gaps

- **Tier 2 is not met.** Only one public filer's almb adversary complaint was retrieved (see `exemplars/SOURCE.md`). The eval loop needs 2 or 3 filers. Search for a second one (CourtListener docket API, when its throttle lifts, or a RECAP docket page) is the next step.
- **Local rules currency.** The local rules fetched are the 2017 set (effective 2017-12-01). The court's own pages refer to new local rules effective 2024-04-01, and the draft 2023 redline lists LBR 7005-1, 9013-1 and 9013-3; the adopted 2024 text was not retrieved. Treat LBR 7005-1 and 9011-1 citations as the 2017 text until the 2024 text is checked.
- **Jurisdiction and consent.** The filed copy does not state consent. The sample's `jurisdiction.consent` is a bracketed placeholder the pleader must replace; the output carries the bracket.
- **Not produced:** the summons (Form B 2500A), the certificate of service, Exhibit A (Payoff Letter, not in the filed text), and the cover sheet. LBR 7005-1(c) requires the summons cover sheet and the certificate of service to be filed with the complaint; they are separate documents.
- **No gate run.** `tools/check.sh` and `tools/check-selftest.sh` were not run for this doc type; this change is render, overlay and visual review only.

## Run status (2026-10-15)

- Exemplar re-downloaded from the RECAP URL in `exemplars/SOURCE.md` (13 pages, 807645 bytes, sha256 `cf01ec6f27dff5ae480d5c5caa6a783dea011aa630b12fb3ea1003d284010366`) to `exemplars/FILED-EXAMPLE-southeastern-stud-adversary-complaint.pdf`.
- **render=ok**: `sh tools/render.sh <this-dir> samples/INPUT-southeastern-stud.md` wrote `samples/OUTPUT-southeastern-stud.pdf` (12 pages).
- **overlay=ok**: `sh tools/overlay.sh <this-dir> southeastern-stud` wrote `samples/OVERLAY-southeastern-stud.pdf` and `.txt`; page pairing matches the table above.
- **pages_reviewed=12**: every page of the render was rasterized and viewed in this run. No new issues; the Gate 2 table above stands.
- Tier 2 remains unmet: only one filer's almb adversary complaint is on record (see Gaps).
