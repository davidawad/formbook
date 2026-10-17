# Exemplar source

| Field | Value |
|---|---|
| Court | United States Court of Appeals for the Second Circuit |
| Case | *Gideon Rapaport v. Abigail Finkelman* |
| Docket no. | 25-2247 |
| Document | BRIEF FOR APPELLEE ABIGAIL FINKELMAN (ECF No. 42, 60 pages, ECF stamp "Case: 25-2247, 02/26/2026, DktEntry: 42.1") |
| Filer | Abigail Finkelman, Defendant-Appellee (counsel: Max Rodriguez, Law Office of Max Rodriguez PLLC) |
| Date filed | 2026-02-26 (service via ACMS) |
| Date fetched | 2026-10-14 |
| URL fetched | https://storage.courtlistener.com/recap/gov.uscourts.ca2.351fab24-5314-4772-9606-5373f84843e7/gov.uscourts.ca2.351fab24-5314-4772-9606-5373f84843e7.42.0.pdf |
| Locator | CourtListener RECAP, found through the public search API (`type=rd`, `court=ca2`, query "Brief for Appellee"). |
| Text layer | Yes (`pdftotext` yields the text; fonts embedded). |

Why this one: a counsel-filed answering brief (appellee's brief) in the Second Circuit, text-based, from a private filer (not the government), so it shows the court's ordinary appellee-brief structure: caption cover, table of contents, table of authorities, jurisdictional statement, counterstatement of issues and of the case, summary, standard of review, argument, conclusion, signature, certificate of compliance, certificate of service.

Observations recorded for the README, from the filed copy itself:
- Typeface in the certificate of compliance: "14-point Times New Roman" (Form 6 wording).
- The brief runs 48 numbered pages of body (60 ECF pages) and certifies 11,818 words. That is above the 30-page principal-brief limit of FRAP 32(a)(7)(A) and within the word limit of FRAP 32(a)(7)(B)(i) (13,000 words); the court's own page says 14,000 words.
- The cover has no color in the ECF copy; the court requires a red cover for an appellee's paper copies (FRAP 32(a)(2)).
- The brief has no corporate disclosure statement (the filer is an individual) and no statement regarding oral argument.

## 2. Second filer: `FILED-EXAMPLE-hachette-23-1260-answering-brief.pdf`

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-hachette-23-1260-answering-brief.pdf` (75 pages, 612 x 792 pt, text-based: every page yields text with pdftotext; body in Times, fonts embedded) |
| Court | United States Court of Appeals for the Second Circuit |
| Case | *Hachette Book Group, Inc. v. Internet Archive* |
| Docket no. | 23-1260 (appeal from the S.D.N.Y.) |
| Document | Brief for Plaintiffs-Appellees [Redacted], Document 203 (CM/ECF stamp "Case 23-1260, Document 203, 03/15/2024, 3615317, Page1 of 75") |
| Filer | Plaintiffs-Appellees Hachette Book Group, Inc., HarperCollins Publishers LLC, John Wiley & Sons, Inc., Penguin Random House LLC (counsel: Elizabeth A. McNamara et al., Davis Wright Tremaine LLP; Scott A. Zebrak et al., Oppenheim + Zebrak, LLP). Different party and different counsel from entry 1 (Finkelman / Law Office of Max Rodriguez PLLC). |
| Date filed | March 15, 2024 (CM/ECF stamp) |
| Contents | Cover; corporate disclosure statement; table of contents; table of authorities; preliminary statement; counterstatement sections; summary of argument; standard of review; argument; conclusion; certificate of compliance ("contains 13,979 words", "typeface of 14 points or more", Microsoft Word count); certificate of service |
| URL fetched | https://www.eff.org/files/2024/05/29/hachette_v._internet_archive_-_hachettes_brief_redacted.pdf (linked from https://www.eff.org/document/hachette-v-internet-archive-hachettes-brief-redacted, on the EFF case page https://www.eff.org/cases/hachette-v-internet-archive) |
| Date retrieved | 2026-10-17 |
| sha256 | `a231960cee128c0e1ee3eb8212ecb19b90f8892ec9f8d8a6d9f47a60308e2480` |

Observations: the cover sets the docket number in a heavy condensed sans and the court name in blackletter ("United States Court of Appeals" in Linotext), as Finkelman's cover does in Old English: a printer's style shared by these two filers, not a rule. Corporate parties, so a FRAP 26.1 disclosure statement precedes the table of contents (FRAP 26.1(d)(2)); the Finkelman brief (individual party) has none. The CourtListener search API was rate-limited (HTTP 429) from this box on 2026-10-17, so this copy came from EFF's case page (EFF was co-counsel for the opposing party).
