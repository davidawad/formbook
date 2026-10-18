# Board of Immigration Appeals: rules

Alias `bia`. Scope: a party's brief on appeal from an immigration judge's decision, filed with the Board (8 C.F.R. § 1003.3(c)(1)), as built by `brief-on-appeal/`. Verified against primary sources on 2026-10-17, with the limits stated under Sources.

Re-check cadence: the Practice Manual is updated chapter by chapter (each page footer carries "This chapter last updated: ..."); re-check chapters 3 and 4 and Appendices E and F every six months and whenever EOIR announces a Practice Manual update or amends 8 C.F.R. Part 1003. Re-check against the live justice.gov text as soon as it is reachable (see Sources).

## Sources

| Tag | Source | URL |
|---|---|---|
| CFR | 8 C.F.R. § 1003.3 (notice of appeal; briefs, (c)(1)), LII text read 2026-10-17 | https://www.law.cornell.edu/cfr/text/8/1003.3 |
| PM | Board of Immigration Appeals Practice Manual, edition assembled 2024-11-19 (164 pages; Chapter 3 "last updated June 1, 2023"; Chapter 4 "last updated August 12, 2024"). Cited by chapter and section. **Copy limits:** the official text is at https://www.justice.gov/eoir/reference-materials/bia, which returned HTTP 403 to this box on 2026-10-17 (also via the Wayback Machine). The copy read is the PDF of the Manual mirrored by Human Rights First (its footers name the justice.gov page as the source). Any later EOIR update is not reflected. | https://resources.humanrightsfirst.org/wp-content/uploads/2025/01/BIA-practice-manual-jan.-2025.pdf |
| EX-ab | `brief-on-appeal/usage/SAMPLE-bia-brief-on-appeal-abredacted.pdf` (Respondent A-B-, by Benjamin Winograd, Immigrant & Refugee Appellate Center, with CGRS) | local |

Kinds: **M** = mandated by regulation or by a "must" in the Practice Manual (the Board rejects or may reject non-conforming filings). **C** = convention or a Practice Manual preference ("should", "preferred"). **T** = project/tooling rule. **A** = author responsibility.

Findings that differ from what many templates assume:

1. **Font is a preference, not a rule.** PM 3.3(c)(7): "Font and type size must be easily readable. 'Times New Roman 12 point' font is preferred. Double-spaced text and single-spaced footnotes are also preferred. Both proportionally spaced and monospaced fonts are acceptable." Only "easily readable" is mandatory; Times New Roman 12 and double spacing are `C`.
2. **A hard 50-page body limit.** PM 3.3(c)(3) and 4.6(b): "Parties must limit the body of their briefs to 50 pages unless otherwise directed by the Board"; an oversized brief without a "MOTION TO EXTEND PAGE LIMIT" "will be rejected".
3. **The A-number goes on every page**: on the cover and "on the bottom right corner of each page thereafter" (PM 4.6(c)(2)).
4. **Proof of service is mandatory**; the Board rejects a submission without it (CFR 1003.3(c)(1); PM 3.2(d)).
5. **No reply brief** unless the Board invites or orders one (CFR 1003.3(c)(1)).

## Requirements

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (PM 3.3(c))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| BIA-FORM-001 | Standard 8 1/2 x 11 inch paper (legal size discouraged), white, opaque, unglazed; dark (preferably black) ink; one-sided. | PM 3.3(c)(4) ("should"); 8 C.F.R. § 1003.32(b) as cited there | C (M for size, through § 1003.32(b), not re-read here) |
| BIA-FORM-002 | Font and type size "must be easily readable". | PM 3.3(c)(7) | M |
| BIA-FORM-003 | "Times New Roman 12 point" font preferred; proportional and monospaced fonts both acceptable. | PM 3.3(c)(7) | C |
| BIA-FORM-004 | Double-spaced text and single-spaced footnotes preferred. | PM 3.3(c)(7) | C |
| BIA-FORM-005 | Briefs always paginated. | PM 3.3(c)(3); PM 4.6(b) ("should always be paginated") | C (strong) |
| BIA-FORM-006 | The A-number of each respondent appears on the cover page and in the bottom right corner of each page after it (consolidated appeals: every respondent's name and A-number on the first page, then the lead A-number followed by "et al." on each page). | PM 4.6(c)(2) | C (strong; "should") |
| BIA-FORM-007 | Margins: the Practice Manual sets none. The template's 1-inch margins are a project choice; tier 2 waits for a second filer. | PM 3.3(c) (silent) | C (open) |
| BIA-FORM-008 | Paper filings: two-hole punch at the top preferred (centered, 2 3/4 inches apart); staple top left; no side or commercial binding; no binder clips. Not applicable to the ECAS PDF. | PM 3.3(c)(8) | C (paper) |
| BIA-FORM-009 | Every font used is embedded and is the template's declared face; text extracts on every page. | project | T |

### Length (PM 3.3(c)(3), 4.6(b))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| BIA-LEN-001 | The body of the brief is at most 50 pages unless the Board directs otherwise. Headings, footnotes and quotations count; so do the statement of facts and procedural history, statement of issues, standard of review, summary of the argument, argument and conclusion, whatever their headings. | PM 3.3(c)(3); PM 4.6(b) | M |
| BIA-LEN-002 | Not counted: cover page, table of contents, table of citations, signature block, certificate/proof of service, addendum of statutes, rules, regulations or case law, supporting documentation. | PM 3.3(c)(3); PM 4.6(b) | M |
| BIA-LEN-003 | An oversized brief is accompanied by a written "MOTION TO EXTEND PAGE LIMIT" showing extraordinary and compelling reasons, filed with the brief; without it the brief is rejected. | PM 4.6(b) | M (conditional) |

### Cover and caption (PM 3.3(c)(6), 4.6(a), 4.6(c)(3))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| BIA-COVER-001 | Every brief has a cover page with a caption containing: the name and address of the filing party; the title of the filing (e.g. "DHS BRIEF ON APPEAL"); the full name of each respondent as on the charging document; each respondent's A-number; the type of proceeding (removal, deportation, exclusion, bond, visa petition). Special circumstances ("DETAINED", "EXPEDITE REQUEST", "JOINT MOTION") appear prominently, preferably top right and highlighted. | PM 3.3(c)(6); PM 4.6(a), (c)(3); PM Appendix E (cover-page examples; not extracted) | C (strong; "should") |
| BIA-COVER-002 | The Board's briefing notice is stapled on top of the cover page or attached as its instructions say. | PM 4.6(a) | A |

### Contents (PM 4.6(c)(4)-(8), 4.6(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| BIA-CONT-001 | Recommended contents: a concise statement of facts and procedural history; a statement of issues presented for review; the standard of review; a succinct summary of the argument; the argument; a short conclusion stating the precise relief or remedy sought. | PM 4.6(c)(4) | C (Board recommendation) |
| BIA-CONT-002 | Party designations: the noncitizen is "respondent" (removal, deportation, bond) or "applicant" (exclusion, asylum-only, withholding-only); "the immigration judge"; "DHS". Avoid "appellant"/"appellee". | PM 4.6(c)(5) | A |
| BIA-CONT-003 | Facts are cited to the record; undisputed facts may be adopted from the immigration judge's decision. | PM 4.6(c)(6) | A |
| BIA-CONT-004 | Substantive argument stays in the text; excessive footnotes discouraged. Headings and subheadings used for readability. | PM 4.6(c)(7), (8) | C |
| BIA-CONT-005 | Citations follow PM 4.6(d) and Appendix I (Board precedents by I&N Dec. volume and page; unpublished Board decisions with name, last three A-number digits and date). | PM 4.6(d) | A |
| BIA-CONT-006 | Sources of law not readily and freely available are reproduced in or attached to the brief. | PM 3.3(e)(1) | A |

### Signature and service (CFR 1003.3(c)(1), PM 3.2(d), 3.3(b), 4.6(c)(1))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| BIA-CERT-001 | Every brief filed in conjunction with an appeal includes proof of service on the opposing party; the Board rejects a submission without it. The proof states the name or title of the party served, the complete address, the date and the means of service, and is signed (by the filer or a designee). | CFR 1003.3(c)(1); PM 3.2(d); PM Appendix F | M |
| BIA-CERT-002 | Signed by the person who prepared it (only the practitioner of record, not a firm); handwritten signatures accompanied by a typed name; ECAS filers may use a conformed signature ("/S/ John Doe"). A registered attorney or accredited representative gives the EOIR ID number. | PM 3.3(b); PM 4.6(c)(1) | M (signature); C (EOIR ID, "should") |
| BIA-CERT-003 | Briefing schedule: simultaneous briefs within 20 days of the Board's order (and, without a transcript, no more than 35 days after the appeal was filed); extensions only in exceptional circumstances; no reply brief unless invited or ordered. | CFR 1003.3(c)(1) | A |
| BIA-ELEC-001 | The Board accepts electronic filing through ECAS; no electronic media (CDs, thumb drives) and no faxes without prior authorization. | PM 3.3(b)(2), 3.3(c) | M |

## Exemplar status (2026-10-17)

One filer only (EX-ab). The CLINIC "Sample BIA Appeal Brief" (Jezic & Moyse, bond appeal; https://www.cliniclegal.org/sites/default/files/2019-12/Sample%20BIA%20Appeal%20Brief-Himedes%20Chicas.pdf) was examined and not used: its names, A-number, amounts and dates are placeholders, so it cannot be shown to be a filed document. Tier 2 is therefore unsettled; see `docs/box-blocked.md`.
