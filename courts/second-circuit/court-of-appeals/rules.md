# Second Circuit Court of Appeals briefs: rules

Alias `ca2`. Scope: the briefs of a counseled party in an appeal to the United States Court of Appeals for the Second Circuit, filed electronically through the court's CM/ECF system: the appellant's principal (opening) brief, the appellee's principal (answering) brief, and the appellant's reply brief (doc-type folders `opening-brief/`, `answering-brief/`, `reply-brief/`). Not in scope: pamphlet-format printed briefs (Local Rule 32.1(a)(2)), appendices, amicus briefs, motions, pro se filings.

Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (FRAP amendments take effect then, and the court's current local rules took effect December 2, 2024) and whenever the court posts amended local rules on its rules page.

## Sources

Every requirement below cites one of these tags. All were fetched on 2026-10-17; the sha256 is of the file as fetched.

| Tag | Source (rule, version, effective date) | URL |
|---|---|---|
| LR | Local Rules and Internal Operating Procedures of the Court of Appeals for the Second Circuit, "(Effective December 2, 2024)", 50 pages; the PDF linked from the court's rules page (rules page "Last modified on 12/13/2024"). sha256 `403c42363fc121db6354dd08c9f9b439926b741a2af351c76dffea6bb1569629` | https://www.ca2.uscourts.gov/clerk/case_filing/rules/pdf/LRs_IOCs_appendices_rev_2024.pdf |
| LR-WEB | The court's HTML page for Local Rule 32.1 ("Last modified at 11/16/2015"); its text of 32.1(a) to (c) is identical to LR. | https://www.ca2.uscourts.gov/clerk/case_filing/rules/title7/local_rule_32_1.html |
| RULES-PAGE | The court's rules landing page; names the LR PDF above and the FRAP PDF below as current. | https://www.ca2.uscourts.gov/clerk/case_filing/rules/rules_home.html |
| BRIEF-PAGE | Clerk's Office instructions "How To Appeal A Civil Case: Brief and appendix" ("Last modified at 1/31/2014"): word limits, typeface wording, cover colors, official caption. A clerk's instruction page, not a rule; where it conflicts with LR, LR governs. | https://www.ca2.uscourts.gov/clerk/case_filing/appealing_a_case/civil_case/brief_and_appendix.html |
| FRAP | Federal Rules of Appellate Procedure, Rules 25, 26.1, 28, 32 (Cornell LII copy) | https://www.law.cornell.edu/rules/frap/rule_32 , https://www.law.cornell.edu/rules/frap/rule_28 , https://www.law.cornell.edu/rules/frap/rule_25 , https://www.law.cornell.edu/rules/frap/rule_26.1 |
| FRAP-PDF | "Federal Rules of Appellate Procedure with Forms, December 1, 2024", as posted on the court's rules page; cross-checked against FRAP for Rules 26.1(d), 32(a)(4), 32(a)(5), 32(a)(7). sha256 `d61711eca8e1f65955d12f1b7d29d4cc453d9ee1e30c4fff6c54b23f113454f6` | https://www.ca2.uscourts.gov/clerk/case_filing/rules/pdf/Federal%20Rules%20of%20Appellate%20Procedure%20-%20December%201,%202024.pdf |
| EX-OB | Opening-brief exemplars, `opening-brief/exemplars/` (see its `SOURCE.md`) | local |
| EX-AB | Answering-brief exemplars, `answering-brief/exemplars/` | local |
| EX-RB | Reply-brief exemplars, `reply-brief/exemplars/` | local |

Kinds: **M** = mandated by a court rule (FRAP or a Second Circuit Local Rule; for BRIEF-PAGE, a clerk's instruction, marked as such). **C** = convention (the rules leave it open; taken from the exemplars of different filers). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Not verified (and therefore not used as an `M` source):

- **FRAP Form 6** (certificate of compliance) wording: the court's FRAP PDF renders the form as an image (pdftotext yields only its title), and the Cornell form page returned 404 on 2026-10-17. The certificate rows below rest on FRAP 32(g)(1)'s own text.
- **CM/ECF filing instructions** referred to by LR 25.1(c)(1) ("in accordance with the instructions posted on the court's website"): the court's e-filing overview and "How to use CM/ECF" pages were fetched but carry no PDF-format rule beyond LR 25.1; no separate PDF size or bookmark rule was found.

## Findings that differ from what many templates assume

1. **Word limits come from the local rule, not FRAP.** LR 32.1(a): "Briefs must conform to FRAP 32(a), except as set forth below"; (a)(4)(A) "A principal brief is acceptable if it contains no more than 14,000 words." (B) "A reply brief is acceptable if it contains no more than 7,000 words." FRAP 32(a)(7)(B) says 13,000 and 6,500. FRAP 32(e) lets a court accept longer documents by local rule.
2. **Docket number at least one inch high.** LR 32.1(a)(1): "The docket number of the case must appear in type at least one inch high." This is the single most visible Second Circuit rule; all exemplars of every filer do it.
3. **PDF page labels.** LR 32.1(a)(3): "The pages of a brief must contain sequential numbering. A Filing User must adjust the PDF of the brief to recognize the Filing User's sequential numbering scheme in the PDF's page search field." That is a tier-1 requirement on the PDF's page labels (roman front matter, arabic body), not only on the printed numbers.
4. **Paper copies are required for briefs.** LR 25.1(g) forbids paper copies "Unless the clerk requests or the relevant LR requires"; LR 31.1 requires them: "In all cases, a party must submit 6 paper copies of each brief." The FRAP 32(a)(2) cover colors (BRIEF-PAGE repeats them) therefore apply to the paper copies. The ECF PDF itself carries no cover color (no exemplar has one).
5. **Proof of service is not required for ECF service.** LR 25.1(h)(2): "A Filing User satisfies FRAP 25(d)'s proof of service requirements by completing the 'service' section when electronically filing a document." A certificate of service in the brief is a convention, not a rule.
6. **No typeface is named.** FRAP 32(a)(5)(A) requires "a proportionally spaced face" with serifs, "14-point or larger". LR 32.1(a) adds nothing for full-size briefs (its 12-point figure is for pamphlet briefs only, LR 32.1(a)(2)). BRIEF-PAGE gives Times New Roman only as an example: "Proportionally spaced typeface such as "Times New Roman" must be 14-point or larger." The exemplars use Times New Roman, Century Schoolbook and Palatino (different filers), so the face is a free choice.
7. **Double spacing is mandated.** FRAP 32(a)(4): "The text must be double-spaced, but quotations more than two lines long may be indented and single-spaced. Headings and footnotes may be single-spaced." (Earlier README notes in `reply-brief/` called double spacing a convention; that is wrong for full-size briefs.)

## Court-wide requirements

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (FRAP 32(a)(1) to (6); LR 32.1(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-FORM-001 | Every page is 8 1/2 by 11 inch (612 x 792 pt). | FRAP 32(a)(4) ("The brief must be on 8 1/2 by 11 inch paper"); LR 32.1(a) | M |
| CA2-FORM-002 | Margins at least one inch on all four sides. "Page numbers may be placed in the margins, but no text may appear there." | FRAP 32(a)(4) | M |
| CA2-FORM-003 | "The text must be double-spaced, but quotations more than two lines long may be indented and single-spaced. Headings and footnotes may be single-spaced." Check: baseline-to-baseline distance in body paragraphs at least twice the type size. | FRAP 32(a)(4) | M |
| CA2-FORM-004 | Typeface: "A proportionally spaced face must include serifs, but sans-serif type may be used in headings and captions. A proportionally spaced face must be 14-point or larger." (Monospaced alternative, "not more than 10 1/2 characters per inch", not used by the templates.) The rule states no footnote exemption; the checks apply 14 pt to all text including footnotes. BRIEF-PAGE repeats: "Proportionally spaced typeface such as "Times New Roman" must be 14-point or larger." | FRAP 32(a)(5)(A)-(B); BRIEF-PAGE | M |
| CA2-FORM-005 | Face: none named by any rule (Finding 6). Exemplars use Times New Roman (EX-AB Finkelman, EX-OB Internet Archive, EX-AB Hachette), Century Schoolbook (EX-OB Munafo, EX-RB MoneyLion) and Palatino (EX-RB Alisigwe). The face is the template's choice. | FRAP 32(a)(5)(A); EX-OB, EX-AB, EX-RB | C |
| CA2-FORM-006 | "A brief must be set in a plain, roman style, although italics or boldface may be used for emphasis. Case names must be italicized or underlined." | FRAP 32(a)(6) | M |
| CA2-FORM-007 | Reproduction: "clear black image on light paper"; one side of the paper only. In the PDF: text, not images of text (see CA2-ELEC-001). | FRAP 32(a)(1)(A)-(B) | M |
| CA2-FORM-008 | Every font used is embedded and is the template's declared family (no silent fallback). | project; supports FRAP 32(a)(5) and LR 25.1(e) | T |
| CA2-FORM-009 | "The pages of a brief must contain sequential numbering." | LR 32.1(a)(3) | M |
| CA2-FORM-010 | Page-number style: cover unnumbered; front matter (disclosure, contents, authorities) in lowercase roman numerals; body from arabic 1 at the first body section; certificates continue the arabic run. Seen in all six exemplar filers: Munafo (i, ii; body 1...), Internet Archive (disclosure page i), Finkelman ("-i-", "- ii -"), Hachette (ii), MoneyLion (i, ii), Alisigwe (i, ii). Number placement (centered foot) is the same across filers. | EX-OB, EX-AB, EX-RB | C |
| CA2-FORM-011 | Bound so it lies reasonably flat (paper copies only; no PDF effect). | FRAP 32(a)(3) | M (paper only) |

### Cover (FRAP 32(a)(2); LR 32.1(a)(1))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-COVER-001 | "the number of the case centered at the top" of the front cover. | FRAP 32(a)(2)(A) | M |
| CA2-COVER-002 | "The docket number of the case must appear in type at least one inch high." Template reading: type size at least 72 pt. (Open question recorded in `reply-brief/README.md`: whether the clerk reads "one inch" as type size or as digit height; the exemplars' docket lines measure about 73 to 115 pt bounding-box height, i.e. some filers set roughly 60 pt type, so the clerk evidently accepts the type-size reading or less.) | LR 32.1(a)(1) | M |
| CA2-COVER-003 | The name of the court ("United States Court of Appeals for the Second Circuit"). No district-court caption box. | FRAP 32(a)(2)(B) | M |
| CA2-COVER-004 | The title of the case (FRAP 12(a)): each party with its designation. The caption must conform to the court's "official caption": "The caption on the covers of the briefs and appendices must conform to this Court's "official caption."" | FRAP 32(a)(2)(C); BRIEF-PAGE (clerk's instruction) | M |
| CA2-COVER-005 | The nature of the proceeding (e.g. Appeal, Petition for Review) and the name of the court, agency or board below. | FRAP 32(a)(2)(D) | M |
| CA2-COVER-006 | The title of the brief, identifying the party or parties for whom it is filed. LR: "The title appearing on the front cover of a brief must include the name of the party or parties for whom the brief is filed." | FRAP 32(a)(2)(E); LR 32.1(a)(1) | M |
| CA2-COVER-007 | The name, office address and telephone number of counsel representing the party for whom the brief is filed. | FRAP 32(a)(2)(F) | M |
| CA2-COVER-008 | Cover color, paper copies only (Finding 4): appellant blue, appellee red, reply gray, intervenor or amicus green, supplemental tan; unrepresented parties exempt. The ECF PDF is white. | FRAP 32(a)(2); BRIEF-PAGE ("The following colors for brief covers must be used"); LR 31.1 | M (paper only) |
| CA2-COVER-009 | Cover layout seen across filers: the docket number is the first and largest element, bold or heavy; horizontal rules separate the blocks (court, caption, proceeding, title, counsel); the court name is centered under the docket number; the caption is centered with the designations set right or centered under each party and "v." / "-v-" / "-against-" between sides; "On Appeal from the United States District Court for the ... District of ..." centered; the brief title in bold capitals between rules; the counsel block in the lower half, indented or in two columns. Seen in all six filers (Munafo, Internet Archive, Finkelman, Hachette, MoneyLion, Alisigwe). The docket number is a bold serif in Munafo, MoneyLion and Alisigwe and a heavy condensed sans in Internet Archive and Hachette (sans is allowed in captions, FRAP 32(a)(5)(A)): either is acceptable. The court name in a blackletter face (Old English / Linotext) appears in Finkelman, MoneyLion and Hachette: a common New York appellate-printer style, optional (the other three filers use plain capitals). | EX-OB, EX-AB, EX-RB | C |
| CA2-COVER-010 | The cover is one page; the next page is the first front-matter page. | all exemplars | C |

### Electronic filing (LR 25.1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-ELEC-001 | Filed electronically in PDF; "A PDF must be text-searchable." Check: text extracts on every page; fonts embedded. | LR 25.1(c)(1), 25.1(e) | M |
| CA2-ELEC-002 | PDF page labels follow the brief's printed numbering ("A Filing User must adjust the PDF of the brief to recognize the Filing User's sequential numbering scheme in the PDF's page search field"). Check: the PDF `/PageLabels` give lowercase roman for the front matter and arabic from body page 1, matching the printed numbers. | LR 32.1(a)(3) | M |
| CA2-ELEC-003 | Size: a document over 10 megabytes that cannot be divided into 10 or fewer parts of at most 10 MB each is exempt from e-filing (filed on CD/DVD). Template target: one PDF of at most 10 MB. | LR 25.1(j)(3) | M |
| CA2-ELEC-004 | Signature: "A Filing User's personal log-in and password constitute the Filing User's signature"; "A PDF need not include a manual signature." Every brief must be signed by the party or one of its attorneys. Template: typed "/s/ Name" signature block after the conclusion and on each certificate (seen in all filers). | LR 25.1(e), (f); FRAP 32(d); EX-* | M (signature); C ("/s/" form) |
| CA2-ELEC-005 | Hyperlinks are permitted to other parts of the brief, to documents filed on appeal or below, and to statutes, rules, regulations and opinions; "A hyperlink to a cited authority does not replace standard citation format." | LR 25.1(i) | M (permission; author) |
| CA2-ELEC-006 | The top margin carries no text: the court stamps "Case: <no>, <date>, DktEntry: <n>, Page x of y" there (visible on every exemplar page). Covered by CA2-FORM-002. | EX-*; FRAP 32(a)(4) | C |
| CA2-ELEC-007 | Six paper copies of each brief are submitted (with colored covers, CA2-COVER-008). | LR 31.1; LR 25.1(g) | M (paper only; not a template property) |

### Length (FRAP 32(a)(7), 32(f); LR 32.1(a)(4); LR 28.1.1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-LEN-001 | Headings, footnotes and quotations count. Excluded: cover page; disclosure statement; table of contents; table of citations; statement regarding oral argument; addendum containing statutes, rules, or regulations; certificate of counsel; signature block; proof of service; any item excluded by local rule. | FRAP 32(f); BRIEF-PAGE repeats the list | M |
| CA2-LEN-002 | The local rule's word limits replace FRAP 32(a)(7)(B)'s (Finding 1). Per-doc-type limits: CA2-LEN-010, -020, -030. Page alternative: FRAP 32(a)(7)(A) (30 pages principal, 15 reply) remains; BRIEF-PAGE: "A principal brief must not exceed 30 pages or 14,000 words." The templates use the word limit and always print the certificate. | LR 32.1(a)(4); FRAP 32(a)(7)(A), 32(e); BRIEF-PAGE | M |
| CA2-LEN-003 | Cross-appeals: appellant's principal brief and response-and-reply brief 14,000 words each; appellee's principal-and-response brief 16,500; appellee's reply 7,000. Not implemented by the templates (no cross-appeal doc type); recorded so a cross-appeal brief is not checked against the wrong limit. | LR 28.1.1(a)-(c) | M |

### Contents common to all briefs

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-CONT-001 | "A brief must be concise, logically arranged with proper headings, and free of irrelevant matter. The court may disregard a brief that does not comply with this rule." | LR 28.1(a) | A |
| CA2-CONT-002 | Disclosure statement (FRAP 26.1(a): a nongovernmental corporate party identifies any parent corporation and any publicly held corporation owning 10% or more of its stock, or states there is none) "be included before the table of contents in the principal brief". Conditional on the party; the templates print it when the metadata supplies it. | FRAP 26.1(a), (d)(2); FRAP 28(a)(1) | M (conditional) |
| CA2-CONT-003 | Table of contents with page references; the page numbers equal the pages where the headings really are. | FRAP 28(a)(2), 28(c) | M |
| CA2-CONT-004 | Table of authorities: "cases (alphabetically arranged), statutes, and other authorities", with references to the pages of the brief where cited. BRIEF-PAGE: "An alphabetically arranged table of cases, statutes, and other authorities cited with references to pages in the brief". Group headings (Cases / Statutes / Rules / Other Authorities) are seen in every filer. | FRAP 28(a)(3), 28(c); BRIEF-PAGE; EX-* for grouping | M (content); C (grouping) |
| CA2-CONT-005 | Statutes, rules, regulations needed to decide the issues are set out in the brief or in an addendum at the end (or a pamphlet). If the appendix (exclusive of the orders appealed) exceeds 300 pages, a Special Appendix with the orders appealed and the text of any significant rule of law is required; it "may be an addendum at the end of a brief". | FRAP 28(f); LR 32.1(c) | M (conditional) |
| CA2-CONT-006 | References to the record cite the appendix pages (FRAP 28(e)); parties referred to by name, not "appellant"/"appellee" (FRAP 28(d)). | FRAP 28(d), (e) | A |
| CA2-CONT-007 | A pro se party's paper drafted by an attorney states at the beginning "This document was drafted in whole, or substantial part, by an attorney." Out of scope (counseled briefs); recorded for completeness. | LR 32.2 | M (pro se only) |

### Certificates

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-CERT-001 | Certificate of compliance by the attorney "that the document complies with the type-volume limitation"; it "must state the number of words". BRIEF-PAGE: "The filer must certify the number of words or lines in a certificate of compliance which is included in the brief." The filer "may rely on the word or line count of the word-processing system used". Form 6 is an acceptable form (its wording not verified, see Not verified). Every exemplar also states the typeface and size (FRAP 32(a)(5)-(6) compliance): a convention across all filers. | FRAP 32(g)(1)-(2); FRAP 28(a)(10); BRIEF-PAGE; EX-* for the typeface paragraph | M (word count); C (typeface paragraph) |
| CA2-CERT-002 | The word count stated in the certificate equals the actual count of counted words (CA2-LEN-001) and is within the doc type's limit. | FRAP 32(g)(1); LR 32.1(a)(4) | M |
| CA2-CERT-003 | Proof of service is required only for service "other than through the court's electronic-filing system"; for an ECF filer the ECF "service" section satisfies FRAP 25(d) (Finding 5). When required it states the date and manner of service, the names of the persons served, and their addresses. A certificate of service (after the certificate of compliance, or before it in Alisigwe) appears in all six exemplars even though they were served through ECF/ACMS, so the templates offer it and the samples include it. | FRAP 25(d)(1)-(3); LR 25.1(h)(2); EX-* | M (conditional); C (included by default) |
| CA2-CERT-004 | Certificates come last, after the conclusion and signature block, each headed in capitals and signed "/s/". Seen in all six filers. | EX-* | C |

## Doc type: opening-brief

The appellant's principal brief. Exemplars: `opening-brief/exemplars/SOURCE.md` (Munafo / Federal Public Defender, N.D.N.Y.; Internet Archive / Morrison & Foerster and EFF).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-LEN-010 | At most 14,000 words (CA2-LEN-001 exclusions), or 30 pages without a word count. | LR 32.1(a)(4)(A); FRAP 32(a)(7)(A); BRIEF-PAGE | M |
| CA2-CONT-010 | Contents, under appropriate headings and in this order: (1) disclosure statement if required (CA2-CONT-002); (2) table of contents; (3) table of authorities; (4) jurisdictional statement: basis of the district court's or agency's subject-matter jurisdiction, basis of this court's jurisdiction, filing dates establishing timeliness, and the final-judgment assertion (or other basis); (5) statement of the issues presented for review; (6) concise statement of the case (facts, procedural history, rulings presented, record references); (7) summary of the argument (not merely the headings); (8) argument, with a concise standard-of-review statement for each issue (in the discussion or under a separate heading before the issues); (9) short conclusion stating the precise relief sought; (10) certificate of compliance. | FRAP 28(a)(1)-(10) | M |
| CA2-CONT-011 | At the beginning of the statement of the case, the brief must (1) describe the nature of the case and the relevant procedural history; (2) identify the judge or agency official who rendered the decision appealed; (3) indicate the disposition below; (4) cite the decision or supporting opinion, if reported. | LR 28.1(b); BRIEF-PAGE | M (content: A) |
| CA2-CONT-012 | Statement of jurisdiction content (CA2-CONT-010 item 4). | FRAP 28(a)(4)(A)-(D) | A |
| CA2-COVER-011 | Cover color blue (paper copies). | FRAP 32(a)(2); BRIEF-PAGE | M (paper only) |
| CA2-CONV-010 | Heading labels: Argument points I., II. (centered, bold or capitals), then A., B., then 1., 2. Seen in both opening-brief filers (Munafo; Internet Archive: I., A., 1.). Internet Archive also divides the Statement of the Case with roman headings (I. Factual Background, II. ...); Munafo uses none there: author choice. | EX-OB | C |
| CA2-CONV-011 | Section titles used: "Jurisdictional Statement", "Statement of the Issues Presented", "Statement of the Case", "Summary of the Argument", "Argument", "Conclusion" (Munafo, title case); "JURISDICTIONAL STATEMENT", "INTRODUCTION", "STATEMENT OF ISSUES", "STATEMENT OF CASE", "SUMMARY OF ARGUMENT", "STANDARD OF REVIEW", "ARGUMENT", "CONCLUSION" (Internet Archive, capitals). An Introduction after the jurisdictional statement is one filer's choice. Standard of review as a separate section: Internet Archive (top level) and Munafo (sub-point A under Argument I). The FRAP 28(a) names are the rule; exact wording is the author's. | FRAP 28(a); EX-OB | C |

## Doc type: answering-brief

The appellee's principal brief. Exemplars: `answering-brief/exemplars/SOURCE.md` (Finkelman / Law Office of Max Rodriguez PLLC; Hachette et al. / Davis Wright Tremaine and Oppenheim + Zebrak).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-LEN-020 | At most 14,000 words (a principal brief), or 30 pages without a word count. Cross-appeal principal-and-response brief: 16,500 (CA2-LEN-003). | LR 32.1(a)(4)(A); LR 28.1.1(b); FRAP 32(a)(7)(A) | M |
| CA2-CONT-020 | Must conform to FRAP 28(a)(1)-(8) and (10) (disclosure if required, contents, authorities, ..., summary, argument, certificate of compliance), "except that none of the following need appear unless the appellee is dissatisfied with the appellant's statement: (1) the jurisdictional statement; (2) the statement of the issues; (3) the statement of the case; and (4) the statement of the standard of review." Required in every appellee brief therefore: table of contents, table of authorities, summary of the argument, argument, conclusion (FRAP 28(a)(9) is not in the 28(b) list, but every exemplar has one), certificate of compliance. | FRAP 28(b) | M |
| CA2-CONT-021 | A conclusion stating the relief sought (affirmance) followed by the signature block. Seen in both filers (Finkelman; Hachette). | EX-AB | C |
| CA2-CONT-022 | Optional sections, when included, are commonly titled "Counterstatement of ..." (Finkelman: "Counterstatement of Issues Presented for Review", "Counterstatement of the Case") and Hachette ("Counter Statement of Issues on Appeal", "Counter Statement of the Case"): a convention across both filers. Hachette opens with a "Preliminary Statement" and omits the jurisdictional statement (FRAP 28(b)(1) allows it); Finkelman includes one. Wording is the author's. | EX-AB | C |
| CA2-COVER-021 | Cover color red (paper copies). | FRAP 32(a)(2); BRIEF-PAGE | M (paper only) |
| CA2-CONV-020 | Standard of review as its own top-level section between the summary and the argument: seen in Finkelman and Hachette (two filers). | EX-AB | C |

## Doc type: reply-brief

The appellant's reply brief. Exemplars: `reply-brief/exemplars/SOURCE.md` (MoneyLion / McGuireWoods and Cooley; Alisigwe / Federal Defenders of New York).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA2-LEN-030 | At most 7,000 words, or 15 pages without a word count. (FRAP's half-of-13,000 = 6,500 is displaced by the local rule.) Appellee's cross-appeal reply: 7,000 (LR 28.1.1(c)). | LR 32.1(a)(4)(B); FRAP 32(a)(7)(A); BRIEF-PAGE ("A reply brief must not exceed 15 pages or half the type-volume") | M |
| CA2-CONT-030 | "A reply brief must contain a table of contents, with page references, and a table of authorities -- cases (alphabetically arranged), statutes, and other authorities -- with references to the pages of the reply brief where they are cited." No other section is mandated; FRAP 28(a) does not apply to a reply. | FRAP 28(c) | M |
| CA2-CONT-031 | Certificate of compliance with the word count (the 7,000-word limit is a type-volume limit). | FRAP 32(g)(1); BRIEF-PAGE | M |
| CA2-CONT-032 | No disclosure statement is required in a reply (FRAP 26.1(d)(2) places it in the principal brief). | FRAP 26.1(d) | M |
| CA2-CONT-033 | Filed within 21 days after the last appellee's brief (14 days on the Expedited Appeals Calendar). | LR 31.2(a)(2), (b)(3)(C) | A |
| CA2-COVER-031 | Cover color gray (paper copies). | FRAP 32(a)(2); BRIEF-PAGE | M (paper only) |
| CA2-CONV-030 | Body sections: an untitled or "Introduction"/"Preliminary Statement" opening (MoneyLion: "Introduction"), then "Argument" with roman points, then "Conclusion". Alisigwe goes straight to the argument points. Seen across both filers: Argument points I., II. with A., B. sub-points; Conclusion; certificates last. | EX-RB | C |
| CA2-CONV-031 | Certificate order differs between filers (MoneyLion: compliance then service; Alisigwe: service then compliance): order is a filer's choice. | EX-RB | C (either order) |
| CA2-CONV-032 | Alisigwe's cover carries "To be argued by: <name>" at the top right and "Of Counsel" under the counsel block: one filer's (Federal Defenders') style, not a convention. | EX-RB | tier 3 |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| CA2-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| CA2-TOOL-002 | The templates contain no case-specific text and no measured coordinates. | T |
| CA2-TOOL-003 | Each markdown italic span renders in an italic face. | T (supports CA2-FORM-006) |
| CA2-TOOL-004 | Each footnote appears on the page that carries its reference. | T |
| CA2-TOOL-005 | Every TOC page number equals the page on which the heading appears; every TOA page reference is a page that contains the citation. | T (supports CA2-CONT-003, -004) |
| CA2-REVIEW-001 | A recorded visual review of the current PDF covers every page with no open defect (docs/EVAL-LOOP.md, Gate 2). | T |
| CA2-GEN-001 | A second, structurally different sample passes gates 0 to 2. | T |
