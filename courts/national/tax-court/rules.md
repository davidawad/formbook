# United States Tax Court: rules

Alias `tax`. Scope: papers filed by counsel or a self-represented petitioner in a deficiency case, as built by `petition/` (Rule 34(b), Form 1) and `pretrial-memorandum/` (Standing Pretrial Order under Rule 131(b)). Verified against primary sources on 2026-10-17.

Re-check cadence: when the Court posts a notice on its "Notices of Rule Amendments" page (https://www.ustaxcourt.gov/notices-of-rule-amendments/; latest on 2026-10-17: final amendments adopted August 8, 2024) and at least annually each October; re-check the Pretrial Memorandum form whenever a new Standing Pretrial Order is issued with a notice of trial.

## Sources

| Tag | Source | URL |
|---|---|---|
| TCR | Tax Court Rules of Practice and Procedure, "as amended through August 2024" (complete compilation, PDF created 2025-07-21). Page numbers are the compilation's printed pages. Rule 23 text is the March 20, 2023 amendment (160 T.C. 587-90), unchanged by the 2024 amendments. | https://ustaxcourt.gov/files/documents/Complete-Rules-of-Practice-and-Procedure.pdf |
| R23 | Rule 23 as amended effective March 20, 2023 (stand-alone copy; same text as TCR) | https://www.ustaxcourt.gov/resources/ropp/Rule-23_Amended_03202023.pdf |
| NOTICES | Notices of Rule Amendments page (lists the August 8, 2024 final amendments as the latest) | https://www.ustaxcourt.gov/notices-of-rule-amendments/ |
| PMF | Pretrial Memorandum form (2 pages; PDF dated 2026-09-04) | https://ustaxcourt.gov/files/documents/Pretrial_Memorandum_Form.pdf |
| SPTO | Standing Pretrial Order, regular case, sample (PDF dated 2021-12-27) | https://ustaxcourt.gov/files/documents/SPTO_regular_sample.pdf |
| DAWSON | DAWSON Practitioner Training Guide (the Court's eFiling instructions for counsel) | https://ustaxcourt.gov/files/documents/DAWSON_Practitioner_Training_Guide.pdf |
| EX-* | Filed exemplars in each doc type's `exemplars/` (see `SOURCE.md`). Visual reference only. | local |

Kinds: **M** = mandated by a Tax Court Rule, a form the Rules incorporate, or the Standing Pretrial Order. **C** = convention (rules leave it open). **T** = project/tooling rule. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **14-point for a proportional font, not 12.** Rule 23(d)(2): "14-point type produced by a proportional print font (e.g., Times New Roman or Century Schoolbook)"; 12-point is allowed only for a nonproportional font (e.g. Courier). The named faces are examples ("e.g."), not a requirement.
2. **Line density is capped, not just "double spacing".** Rule 23(d)(3): double-spaced lines no more than three to the vertical inch (pitch at least 24 pt); single-spaced lines no more than six (pitch at least 12 pt).
3. **Top and bottom margins are 3/4 inch, sides 1 inch** (Rule 23(d)(1)), and the rule applies to electronically filed papers too.
4. **No cover** on a paper filed in paper form (Rule 23(e)).
5. **The current Pretrial Memorandum form** (PMF, 2026) differs from the 2000-era form the template was built from: STATUS OF CASE offers only "Probable Trial" and "Definite Trial" (no "probable settlement"), and it adds "BRIEF SYNOPSIS OF LEGAL AUTHORITIES" and "EVIDENTIARY PROBLEMS" sections and a "Filed Electronically Yes/No" box.

## Requirements (court-wide: Rules 21, 23, 26, 27, 32)

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (Rule 23(c), (d), (e), (f))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TAX-FORM-001 | Page 8 1/2 inches wide by 11 inches long, including a paper filed electronically. | R 23(d)(1), TCR p. 20 | M |
| TAX-FORM-002 | Side margins no less than 1 inch; top and bottom margins no less than 3/4 inch, on each page. | R 23(d)(1), TCR p. 20 | M |
| TAX-FORM-003 | Text and footnotes in "consistent typeface no smaller than 12 characters per inch produced by a typewriting element, 12-point type produced by a nonproportional print font (e.g., Courier), or 14-point type produced by a proportional print font (e.g., Times New Roman or Century Schoolbook)". For a proportional face: 14 pt or larger, one face throughout, footnotes included. | R 23(d)(2), TCR pp. 20-21 | M |
| TAX-FORM-004 | "Double spacing between each line of text and single spacing between each line of indented quotations and footnotes." | R 23(d)(2), TCR p. 21 | M |
| TAX-FORM-005 | "Double-spaced lines must be no more than three lines to the vertical inch, and single-spaced lines must be no more than six lines to the vertical inch" (baseline pitch at least 24 pt double, at least 12 pt single). | R 23(d)(3), TCR p. 21 | M |
| TAX-FORM-006 | "Quotations in excess of five lines must be set off from the surrounding text and indented." | R 23(d)(2), TCR p. 21 | M |
| TAX-FORM-007 | Printed on one side only of opaque, unglazed paper (paper filings); clear and legible. | R 23(c), (d)(1), TCR p. 20 | M |
| TAX-FORM-008 | No back or cover on a paper filed in paper form; removable fastener only. The caption starts page 1. | R 23(e), TCR p. 21 | M |
| TAX-FORM-009 | "All citations of case names must be underscored or in italics." | R 23(f), TCR p. 21 | M |
| TAX-FORM-010 | Every font used is embedded and is the template's declared face (no silent fallback). | project; supports R 23(d)(2) | T |
| TAX-FORM-011 | The Clerk may not refuse a paper solely because of its form (but the Court may order otherwise). Form defects are still tier 1 for this project. | R 23(g), TCR p. 21 | M (note) |

### Caption, signature, contact information (Rules 23(a), 32(a), 33)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TAX-CONT-001 | Caption with the Court's name (United States Tax Court), the names of the parties (title of the case), the docket number once assigned, and the type of pleading. A petition's title names all parties and persons on whose behalf it is filed; later pleadings may name the first party on each side and refer generally to others. | R 32(a), TCR p. 30; R 23(a)(1), TCR p. 19 | M |
| TAX-CONT-002 | Full name and surname of each individual petitioner, without prefixes or titles ("Mr.", "Ms.", "Dr."); an estate or trust precedes the fiduciary's name and title ("Estate of Mary Doe, Deceased, Richard Roe, Executor"). | R 23(a)(1), TCR pp. 19-20 | M |
| TAX-CONT-003 | Date of signature on every paper. | R 23(a)(2), TCR p. 20 | M |
| TAX-CONT-004 | Signature of counsel (or the self-represented party); an individual, not a firm name; a corporate petitioner signs by an authorized officer ("Mary Doe, Inc., by Richard Roe, President"). For an electronically filed paper, the name on the signature block is the signature. Beneath the signature: name, mailing address, email address, telephone number, and counsel's Tax Court bar number (decision documents omit address, email and telephone). | R 23(a)(3), (4), TCR p. 20; R 33(a), TCR p. 31 | M |
| TAX-CONT-005 | After docketing, the docket number is on all papers. | R 35, TCR p. 34 | M |
| TAX-CONT-006 | Claims and defenses in numbered paragraphs, each limited as far as practicable to a single set of circumstances (pleadings). | R 32(b), TCR p. 31 | M |
| TAX-CONT-007 | Privacy: redact taxpayer identification numbers, dates of birth (year only), names of minor children (initials), financial account numbers (last four digits). | R 27(a), TCR p. 28 | A |

### Service and electronic filing (Rules 21, 26)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TAX-CERT-001 | A paper not served through the Court's electronic filing system (DAWSON) is filed with a certificate of service (Form 9). The Clerk serves petitions. | R 21(a), (b)(1), TCR p. 17 | M (conditional) |
| TAX-ELEC-001 | Electronic filing is required for all papers filed by a party represented by counsel (exceptions: papers not eligible, or an exemption for good cause); self-represented petitioners are not required to eFile. | R 26(b), TCR p. 27 | M |
| TAX-ELEC-002 | DAWSON uploads are PDF; each file at most 250 MB; not encrypted or password protected; PDF Portfolio files not supported. | DAWSON (eFiling: document requirements) | M |
| TAX-ELEC-003 | Text extracts on every page of the PDF; fonts embedded. Not required by a Tax Court Rule (the Rules require only "clear and legible", R 23(c)); a project check. | project | T |

## Doc type: `petition` (Rule 34(b), Form 1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TAX-CONT-010 | The petition contains the information required by the Rules and identifies the issues presented; otherwise the case may be dismissed. | R 34(a), TCR p. 32 | M |
| TAX-CONT-011 | A deficiency or liability petition is "substantially in accordance with Form 1 (Petition)" and contains: (A) individual: name and State of legal residence; (B) otherwise: name and principal place of business or office; (C) mailing address and the IRS office where the return was filed; (D) date of the notice and City and State of the issuing IRS office (or other jurisdictional allegations); (E) reasons for any name difference from the notice; (F) amount of deficiency or liability, nature of the tax, years or periods, and the approximate amount in dispute if only part is disputed; (G) in separately lettered paragraphs, clear and concise assignments of each and every error (issues not raised are deemed conceded); (H) in separately lettered paragraphs, the facts relied on to establish each error; (I) special matters required by Rule 39; (J) a request for relief; (K) signature, mailing address, email address and telephone number of each petitioner or counsel, and counsel's Tax Court bar number. | R 34(b)(1)(A)-(K), TCR pp. 32-33 | M |
| TAX-CONT-012 | A copy of the notice of deficiency or liability is attached to the petition. No other exhibit may be attached to a pleading. | R 34(b)(2), TCR p. 33; R 32(c), TCR p. 31 | M |
| TAX-CONT-013 | Ordinarily one petition per notice; joinder as Rule 34(b)(3)(B) allows. | R 34(b)(3), TCR p. 33 | A |
| TAX-CONT-014 | No claim for litigation or administrative costs in the petition (Rule 231 only). | R 34(f), TCR p. 34 | M |
| TAX-CONT-015 | A properly completed Form 2 (simplified petition) also satisfies Rule 34; the template models the Form 1 pleading. | R 34(d), TCR p. 34 | M (alternative) |
| TAX-CONT-016 | Petition structure in the one exemplar (Lawrence, pro se): caption, numbered paragraphs 1 to 6 following Form 1, lettered assignments of error and facts, prayer, signature. One filer only; tier 2 is not settled (see `petition/exemplars/SOURCE.md`). | EX-lawrence | C (one filer) |

## Doc type: `pretrial-memorandum` (Rule 131(b), Standing Pretrial Order)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TAX-CONT-020 | When a trial is necessary, each party files a Pretrial Memorandum no later than 21 days before the first day of the trial session, on the form attached to the Standing Pretrial Order; unexcused failure may bring sanctions. | R 131(b), TCR p. 103; SPTO ¶ 5.B | M |
| TAX-CONT-021 | Fields, in the form's order: Trial Calendar City; Date of Calendar; "Pretrial Memorandum for" (Petitioner/Respondent); Name of Case; Docket No(s).; Filed Electronically Yes/No; Attorneys (petitioner and respondent, each with telephone and email); Amounts in Dispute (Year(s)/Period(s), Deficiencies/Liabilities, Additions/Penalties); Status of Case (Probable Trial / Definite Trial); Current Estimate of Trial Time (hours); Motions You Expect to Make (title and brief description); Status of Stipulation of Facts (Completed, will be filed electronically / In progress); Issues; Witness(es) You Expect to Call (name and brief summary of expected testimony); Summary of Facts (chronological narrative; separate pages allowed); Brief Synopsis of Legal Authorities (separate pages allowed); Evidentiary Problems; date and signature (Petitioner/Respondent). "This form may be expanded as necessary." | PMF pp. 1-2 | M |
| TAX-CONT-022 | Rule 23 form and style (TAX-FORM-*) apply: the memorandum is a paper filed with the Court. Whether labeled form fields count as "text" for double spacing is not settled by the Rule; the Court's own form is single-spaced. | R 23(d)(2); PMF | C (open) |
| TAX-CERT-020 | Certificate of service if not served through DAWSON (TAX-CERT-001). The exemplar (respondent, DOJ Tax Division) carries one. | R 21(b)(1)(B); EX-duffy | M (conditional) |

## Exemplar status (2026-10-17)

Both doc types still have one filer each. No second public filing was found on 2026-10-17 (searches recorded in each `exemplars/SOURCE.md` and in `docs/box-blocked.md`). Tier 2 for this court is therefore not settled; the `C` rows above that cite one exemplar are that filer's style until a second filer is found.
