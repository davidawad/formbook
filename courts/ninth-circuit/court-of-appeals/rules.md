# Ninth Circuit principal (opening) brief: rules

Alias `ca9`. Scope: appellate briefs filed by counsel through the Appellate Electronic Filing System (ACMS). Principal-brief requirements below describe an opening brief. Verified against primary sources on 2026-10-17. Re-check at each annual FRAP/local-rule update and at least annually.

## Sources

Every requirement below cites one of these. Page numbers are the printed page numbers of the Rules Handbook.

| Tag | Source | URL |
|---|---|---|
| HB | Ninth Circuit "FRAP, Ninth Circuit Rules, Circuit Advisory Committee Notes", effective June 1, 2026 (the court's current rules handbook) | https://cdn.ca9.uscourts.gov/datastore/uploads/frap-June%201%202026.pdf |
| RULES-PAGE | Court's rules landing page (names the handbook above as current; lists the 2024, 2025 and June 2026 rule changes) | https://www.ca9.uscourts.gov/rules/ |
| FRAP | Federal Rules of Appellate Procedure, official U.S. Courts publication (effective Dec. 1, 2025); relevant provisions cross-checked against HB | https://www.uscourts.gov/sites/default/files/document/federal-rules-of-appellate-procedure.pdf |
| F8 | Form 8, Certificate of Compliance for Briefs (Rev. 12/01/22) | https://cdn.ca9.uscourts.gov/datastore/uploads/forms/form08.pdf |
| F15 | Form 15, Certificate of Service for Electronic Filing (Rev. 12/01/2018) | https://cdn.ca9.uscourts.gov/datastore/uploads/forms/form15.pdf |
| F17 | Form 17, Statement of Related Cases Pursuant to Circuit Rule 28-2.6 (New 12/01/2018) | https://cdn.ca9.uscourts.gov/datastore/uploads/forms/form17.pdf |
| F34 | Form 34, Disclosure Statement under FRAP 26.1 and Circuit Rule 26.1-1 | https://cdn.ca9.uscourts.gov/datastore/uploads/forms/form34.pdf |
| EX | The filed exemplar in `usage/` (Sweet v. McMahon, No. 26-1136, DktEntry 23.1). Visual reference only. | local |

Kinds: **M** = mandated by a court rule (FRAP or Ninth Circuit Rule). **C** = convention (taken from the exemplar or common practice; the rules leave it open). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable (content the lawyer must supply).

Findings that differ from what many templates assume:

1. **No disclosure statement in the brief.** Circuit Rule 28-1(c) (HB p. 112) says the brief "should not include a disclosure statement pursuant to FRAP 26.1" unless Circuit Rule 26.1-1 says otherwise. Rule 26.1-1 (HB p. 91) requires Form 34 to be filed separately, as its own ACMS filing type "Disclosure Statement (CR 26.1-1)". The template therefore generates none. (FRAP 28(a)(1) still lists a disclosure statement first; the circuit rule overrides it for this court.)
2. **Cover color is a paper-copy rule only.** FRAP 32(a)(2) requires a blue cover for the appellant's brief. Circuit Rule 25-5(c) (HB p. 84): "No paper copies of electronically filed documents may be submitted unless specifically directed by the Court." The court's order requesting paper copies states the cover color. The electronic PDF therefore has a white cover (as the exemplar does). Not implemented.
3. **Length limit is 14,000 words**, not FRAP's 13,000 (Circuit Rule 32-1(a), HB p. 141).
4. **Certificate of service is not required** for a brief served through ACMS (Circuit Rule 25-5(g)(1), HB p. 85). The template makes it opt-in.
5. **Form 8 must accompany the brief** (Circuit Rule 32-1(e)). The exemplar uses a FRAP-style paragraph instead; this template reproduces Form 8.

## Requirements

IDs are stable. `checks.yaml` references them. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form (FRAP 32(a)(1) to (6), Circuit Rule 32-1(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-FORM-001 | Every page is 8 1/2 by 11 inch (612 x 792 pt). | FRAP 32(a)(4), HB p. 138 | M |
| CA9-FORM-002 | Margins at least one inch on all four sides. Page numbers may sit in the margins; no other text may. | FRAP 32(a)(4), HB p. 138 | M |
| CA9-FORM-003 | Body text is double-spaced. Quotations of more than two lines may be indented and single-spaced; headings and footnotes may be single-spaced. Operational definition used by the checks: baseline-to-baseline distance in body paragraphs is at least twice the type size (28 pt at 14 pt). | FRAP 32(a)(4), HB p. 138 | M |
| CA9-FORM-004 | Proportionally spaced face with serifs (sans-serif only in headings and captions), 14-point or larger. The checks apply 14 pt to all text including footnotes and headings (the conservative reading; the rule states no footnote exemption). | FRAP 32(a)(5)(A), HB p. 139 | M |
| CA9-FORM-005 | Plain roman type; italics or boldface only for emphasis. Case names italicized or underlined. | FRAP 32(a)(6), HB p. 139 | M |
| CA9-FORM-006 | Reproduced clearly, one side of the page; text, not images of text. Covered by CA9-ELEC-001. | FRAP 32(a)(1), HB p. 138 | M |
| CA9-FORM-007 | Every font used is embedded, and every embedded font is the template's declared family (no silent fallback to a system font). | project; supports FRAP 32(a)(5) and Circuit Rule 25-5(e) | T |
| CA9-FORM-008 | Page numbering: front matter after the cover in lowercase roman numerals (cover unnumbered); the body starts at Arabic 1 on the first page of the first body section; numbers centered at the foot, inside the bottom margin. Numbers are consecutive within each run. | EX; FRAP says only that numbers may sit in the margin | C |
| CA9-FORM-009 | Exemplar-derived open choices: top-level section headings and Argument point headings are centered (checked mechanically on every line); the rest is checked by visual review (Gate 2) only: point headings bold (Times New Roman has no small capitals), sub-point headings bold with a hanging label, first-line indent on body paragraphs, cover layout with rules, TOC and TOA styling. | EX | C |

### Length (FRAP 32(a)(7), Circuit Rule 32-1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-LEN-001 | A principal brief may not exceed 14,000 words. Headings, footnotes and quotations count. | Circuit Rule 32-1(a), HB p. 141; FRAP 32(f), HB p. 140 | M |
| CA9-LEN-002 | Excluded from the count: cover page, disclosure statement, table of contents, table of authorities, statement regarding oral argument, addendum of statutes/rules/regulations, certificates of counsel (including the Form 17 statement and the Form 8 certificate), signature block, proof of service. | FRAP 32(f), HB p. 140; Circuit Rule 32-1(c); Circuit Rule 28-2.6 (related-cases statement is a certificate of counsel) | M |
| CA9-LEN-003 | Words in visual images that the court is meant to read are counted manually and added to the certificate. (The template reports "0" manually counted unless the metadata field `manual_image_words` says otherwise.) | Circuit Rule 32-1(f), HB p. 141; F8 | M |

### Contents and order (FRAP 28(a), Circuit Rule 28-2)

Required order of the appellant's brief, with this court's overrides applied:

1. Cover (CA9-COVER-*)
2. Table of contents, with page references (CA9-CONT-001)
3. Table of authorities: cases alphabetized, statutes, other authorities, with the pages where cited (CA9-CONT-002)
4. Jurisdictional statement (CA9-CONT-003)
5. Statement of the issues presented for review (CA9-CONT-004). Pertinent statutes/rules are set out here or in an addendum (CA9-ADD-001).
6. Statement of the case (CA9-CONT-005)
7. Summary of the argument (CA9-CONT-006)
8. Argument, including the standard of review for each issue (CA9-CONT-007, CA9-CONT-008)
9. Conclusion stating the precise relief sought, then signature (CA9-CONT-009)
10. Statement of related cases (CA9-CERT-003)
11. Certificate of compliance (CA9-CERT-001)
12. Certificate of service, only if service was not through ACMS (CA9-CERT-004)
13. Addendum, if used (CA9-ADD-001)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-CONT-001 | Table of contents with page references. Required in every counseled brief. Entries are the brief's headings (and the trailing certificates by convention), page numbers right-aligned on the last line of a wrapped entry, with dot leaders. | FRAP 28(a)(2), HB p. 110; Circuit Rule 28-1(a), HB p. 112 (Rev. 12/1/24, 6/1/26); leaders and alignment per EX | M (existence, page references); C (leaders) |
| CA9-CONT-002 | Table of authorities: cases (alphabetically arranged), statutes, other authorities, with references to the pages of the brief where each is cited. Every authority cited in the body appears; every TOA page reference is a page on which the authority is actually cited. Grouping into Cases / Constitutional Provisions / Statutes / Regulations / Rules / Other Authorities follows EX. | FRAP 28(a)(3), HB p. 110; Circuit Rule 28-1(a); grouping per EX | M (content); C (grouping) |
| CA9-CONT-003 | Statement of jurisdiction, preceding the statement of the case, stating in order: (a) statutory basis of the district court's or agency's subject-matter jurisdiction; (b) basis for claiming the order is final or appealable and the statutory basis of this Court's jurisdiction; (c) date of entry of the order, date of the notice of appeal, and the statute or rule making the appeal timely. FRAP 28(a)(4) adds the final-judgment assertion. The template checks the section exists in order; the content is CA9-AUTH-001. | FRAP 28(a)(4), HB p. 110; Circuit Rule 28-2.2, HB p. 114 | M |
| CA9-CONT-004 | Statement of the issues presented for review. | FRAP 28(a)(5) | M |
| CA9-CONT-005 | Statement of the case: facts relevant to the issues, procedural history, rulings presented for review, with record references. | FRAP 28(a)(6) | M |
| CA9-CONT-006 | Summary of the argument (must not merely repeat the headings). | FRAP 28(a)(7) | M |
| CA9-CONT-007 | Argument section. | FRAP 28(a)(8)(A) | M |
| CA9-CONT-008 | A standard-of-review statement for each issue, in the argument or under its own heading before it. Circuit Rule 28-2.5 adds: state where in the record the issue was raised and ruled on. The template checks that a heading containing "standard of review" exists (at any level). | FRAP 28(a)(8)(B); Circuit Rule 28-2.5, HB p. 114 | M |
| CA9-CONT-009 | Short conclusion stating the precise relief sought; followed by the signature block (CA9-ELEC-003). | FRAP 28(a)(9) | M |
| CA9-CONT-010 | Required top-level sections appear in this order: Statement of Jurisdiction, Statement of the Issue(s), Statement of the Case, Summary of the Argument, Argument, Conclusion. An Introduction (convention in the exemplar) comes before Statement of Jurisdiction. Standard of Review may be its own top-level section between Summary and Argument. | FRAP 28(a)(4) to (9); EX | M (order); C (Introduction) |
| CA9-CONT-011 | No disclosure statement in the brief (see Findings, 1). | Circuit Rule 28-1(c), HB p. 112; Circuit Rule 26.1-1, HB p. 91; F34 | M |
| CA9-CONT-012 | Headings are numbered correctly: within Statement of the Case and Summary, A./B./C. then 1./2.; within Argument, I./II./III., then A./B., then 1./2., then a./b. Numbers are automatic and consecutive. | EX; common appellate style | C |
| CA9-CONT-013 | Bail/detention status statement in criminal appeals; custody/reopening statement in BIA petitions for review. Author supplies it (template has no special section; place it under the jurisdictional statement or its own heading). | Circuit Rule 28-2.4, HB p. 114 | A (M for the filer) |

### Cover (FRAP 32(a)(2))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-COVER-001 | The case number is centered at the top of the front cover (the first line of text on page 1). | FRAP 32(a)(2)(A), HB p. 138 | M |
| CA9-COVER-002 | The name of the court: "United States Court of Appeals for the Ninth Circuit". The cover must not carry a district-court caption box. | FRAP 32(a)(2)(B) | M |
| CA9-COVER-003 | The title of the case: each party with its designation on appeal. | FRAP 32(a)(2)(C); FRAP 12(a) | M |
| CA9-COVER-004 | The nature of the proceeding (e.g. Appeal, Petition for Review) and the name of the court, agency or board below. | FRAP 32(a)(2)(D) | M |
| CA9-COVER-005 | The title of the brief, identifying the party or parties for whom it is filed. | FRAP 32(a)(2)(E) | M |
| CA9-COVER-006 | Name, office address and telephone number of counsel for the filing party. | FRAP 32(a)(2)(F) | M |
| CA9-COVER-007 | Convention: district court docket number and judge below ("D.C. No. ...; Hon. ..."), shown only when supplied. Not required by rule. | common 9th Cir. practice | C |
| CA9-COVER-008 | Cover color: blue for the appellant's brief, only on paper copies requested by the Court. Not applicable to the electronic PDF (white). | FRAP 32(a)(2); Circuit Rule 25-5(c), HB p. 84 | M (paper only) |
| CA9-COVER-009 | The cover occupies exactly one page; the table of contents starts on page 2. | EX | C |

### Certificates, signature, related cases

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-CERT-001 | A brief that uses a word count must be accompanied by Form 8, which states: the case number; that the filer is the attorney or self-represented party; the number of words (and the number manually counted in images) excluding FRAP 32(f) items; that type size and typeface comply with FRAP 32(a)(5) and (6); exactly one basis for the length limit (for a principal brief: "complies with the word limit of Cir. R. 32-1"); signature "s/[typed name]" and date. | FRAP 32(g); Circuit Rule 32-1(e), HB p. 141; F8 | M |
| CA9-CERT-002 | The word count stated in the certificate equals the actual count of counted words, and is at most 14,000. The checks compare it with an independent count taken from the PDF and allow a tolerance for automatic heading labels. | FRAP 32(g)(1) ("must state the number of words"); Circuit Rule 32-1(a) | M |
| CA9-CERT-003 | Each party identifies in a statement on the last page of its initial brief any known related case pending in this Court (case name, docket number, relationship); Form 17 wording. If none, no statement is required, but Form 17 offers the "I am unaware of any related cases currently pending in this court" statement; the template always emits it. The statement is a certificate of counsel and is excluded from the length limits. The exemplar places it immediately before the certificate of compliance; the template follows the exemplar, so the certificates share the final pages. | Circuit Rule 28-2.6, HB p. 115; F17; EX for placement | M (content); C (placement before Form 8) |
| CA9-CERT-004 | Certificate of service: required only when the brief is not served through ACMS (e.g. an unregistered party, sealed filing). The template emits it when the metadata sets `service.certificate: true`, using Form 15 wording. | Circuit Rule 25-5(g), HB p. 85; F15 | M (conditional) |

### Electronic filing (Circuit Rule 25-5)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-ELEC-001 | PDF generated from the original word-processing (here: typst) source so it can be searched and copied. Scanned PDFs are prohibited. Check: text extracts on every page; fonts are embedded. | Circuit Rule 25-5(e), HB p. 85 | M |
| CA9-ELEC-002 | No single attachment exceeds 100 MB. | Circuit Rule 25-5(e) | M |
| CA9-ELEC-003 | Signatures are `s/` followed by the typed name, in the signature block after the conclusion, the related-cases statement and the certificate. | Circuit Rule 25-5(f), HB p. 85; FRAP 32(d) | M |
| CA9-ELEC-004 | The top margin carries no text (the court stamps its own "Case: ..., DktEntry: ..." banner there). Covered by the margin check CA9-FORM-002. | EX (stamp visible on every exemplar page); FRAP 32(a)(4) | C |
| CA9-ELEC-005 | PDF carries document bookmarks for the major headings. | convenience; not in the rules | C |

### Addendum (Circuit Rule 28-2.7, FRAP 28(f))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-ADD-001 | Pertinent constitutional provisions, treaties, statutes, ordinances, regulations or rules are set out verbatim with citation either (1) following the statement of issues or (2) in an addendum introduced by its own table of contents; in the latter case a statement referencing the addendum must appear after the statement of issues (author text). A bound addendum is separated from the brief by a distinctively colored page (paper copies only, see CA9-COVER-008). The addendum is excluded from the length limit. The template builds the addendum from the `Addendum` section of the markdown, on its own pages with its own table of contents and page numbers "Add-1", "Add-2", ... | Circuit Rule 28-2.7, HB p. 115; FRAP 28(f); FRAP 32(f) | M |
| CA9-ADD-002 | In a counseled immigration petition for review the opening brief must include an addendum of the orders challenged (IJ and BIA orders), bound with the brief. Author supplies the orders; the template's addendum section can carry them. | Circuit Rule 28-2.7, HB p. 115 | M (for immigration filers) |

### Author responsibilities (not machine-checkable)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-AUTH-001 | Jurisdictional statement contains the items in CA9-CONT-003. | FRAP 28(a)(4); Circuit Rule 28-2.2 | A |
| CA9-AUTH-002 | Every assertion about the record cites the Excerpts of Record (ER), except undisputed background; no citations directly to the underlying record. | Circuit Rule 28-2.8, HB p. 115 | A |
| CA9-AUTH-003 | Use parties' names or lower-court designations, not "appellant/appellee". | FRAP 28(d) | A |
| CA9-AUTH-004 | Do not append or incorporate briefs from the district court or a prior appeal. | Circuit Rule 28-1(b), HB p. 112 | A |
| CA9-AUTH-005 | Redact personal identifiers. | FRAP 25(a)(5); Circuit Advisory Note to Rule 25-5 | A |
| CA9-AUTH-006 | The signature is an attestation that the signer reviewed the filing and is responsible for its accuracy (including any generative-AI assistance). | Circuit Advisory Committee Note to Rule 32-1 (New 12/1/25), HB p. 141 | A |

## Template-only requirements (the template's own contract)

| ID | Requirement | Kind |
|---|---|---|
| CA9-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. Nothing is silently dropped (list markers, leading numerals, dashes). | T |
| CA9-TOOL-002 | The template contains no case-specific text and no measured coordinates; the same template renders any conforming sample. | T |
| CA9-TOOL-003 | Each markdown span in italics renders in an italic face. | T (supports CA9-FORM-005) |
| CA9-TOOL-004 | Each footnote in the markdown appears in the PDF on the page that carries its reference. | T |
| CA9-TOOL-005 | Every TOC entry's page number equals the page on which that heading really appears. | T (supports CA9-CONT-001) |
| CA9-TOOL-006 | Every TOA page reference is a page that really contains the citation, and every cited authority is listed. | T (supports CA9-CONT-002) |
| CA9-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |
| CA9-GEN-001 | The second sample exercises every feature listed in `checks.yaml: generalization.require_features`. | T |
| CA9-GEN-002 | Both samples pass gates 0 to 2. | T |

## Document-type differences

The requirements above apply to principal (opening) briefs unless stated otherwise. Answering and reply briefs use the same page form, electronic filing, cover, and certificate rules, with the length and required-content differences below. The Ninth Circuit Handbook's Circuit Rule 32-1 is controlling; FRAP 28(b) and (c) set the responding brief's required content.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| CA9-LEN-004 | An answering brief may not exceed 14,000 words or 35 pages. | Circuit Rule 32-1(a), HB p. 141 | M |
| CA9-LEN-005 | A reply brief may not exceed 7,000 words or 15 pages. | Circuit Rule 32-1(b), HB p. 141 | M |
| CA9-CONT-014 | An answering brief must include the appellee's argument, and may omit the jurisdictional statement, issues, and case statement if the appellee is satisfied with the appellant's presentation; any omitted section should be identified as adopted. | FRAP 28(b), official FRAP PDF; HB | M |
| CA9-CONT-015 | A reply brief must contain a table of contents and table of authorities, and may address only the arguments presented in the appellee's brief. It need not repeat the statement of the case or issues. | FRAP 28(c), official FRAP PDF; HB | M |
