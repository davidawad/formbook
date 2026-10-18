# Patent Trial and Appeal Board (AIA trials): rules

Alias `ptab`. Scope: papers filed by a party in an AIA trial before the Patent Trial and Appeal Board, filed through P-TACTS: the petition for inter partes review (`petition/`, 37 C.F.R. §§ 42.104-42.105) and the patent owner response after institution (`patent-owner-response/`, 37 C.F.R. § 42.120). Post-grant review and derivation papers share the court-wide rules but are not in scope (their word limits differ, see PTAB-LEN-001 and PTAB-LEN-010). Verified against primary sources on 2026-10-17 (first partial pass 2026-10-14).

Re-check cadence: re-check annually each October 1 (37 C.F.R. part 42 is republished in the annual CFR edition) and whenever the eCFR "versions" list for part 42 shows a new amendment date, or the Trial Practice Guide web page posts a new "On <date>, sections ... were updated" note. At this pass the last amendments to the sections cited here were 85 FR 79128 (Dec. 9, 2020; §§ 42.23, 42.24, 42.108, 42.120) and 80 FR 28565 (May 19, 2015; § 42.6); later part-42 amendments (2024-2026) touch only §§ 42.10, 42.15, 42.75, 42.121, 42.221 (eCFR versions API, read 2026-10-17).

## Sources

| Tag | Source | URL |
|---|---|---|
| CFR-42 | 37 C.F.R. part 42 (Trial Practice before the PTAB), eCFR full text as of 2026-10-01 (point-in-time XML); sections read: 42.6, 42.8, 42.10, 42.22, 42.23, 42.24, 42.63, 42.104, 42.105, 42.106, 42.107, 42.108, 42.120. Section amendment dates from the eCFR versions API. | https://www.ecfr.gov/api/versioner/v1/full/2026-10-01/title-37.xml?part=42 ; https://www.ecfr.gov/api/versioner/v1/versions/title-37.json?part=42 |
| CFR-42.6 | 37 C.F.R. § 42.6 (format, filing, service; as amended 80 FR 28565, May 19, 2015). Cross-checked against Cornell LII. | https://www.law.cornell.edu/cfr/text/37/42.6 |
| CFR-42.24 | 37 C.F.R. § 42.24 (word counts; as amended 85 FR 79128, Dec. 9, 2020). Cross-checked against Cornell LII. | https://www.law.cornell.edu/cfr/text/37/42.24 |
| CFR-42.120 | 37 C.F.R. § 42.120 (patent owner response; as amended 85 FR 79129, Dec. 9, 2020) | https://www.law.cornell.edu/cfr/text/37/42.120 |
| CFR-1.4 | 37 C.F.R. § 1.4(d)(2) (S-signature), eCFR as of 2026-10-01 (incorporated by § 42.6(a)(4) through §§ 1.33 and 11.18(a)) | https://www.ecfr.gov/api/versioner/v1/full/2026-10-01/title-37.xml?section=1.4 |
| TPG | PTAB Consolidated Trial Practice Guide, web edition ("On December 12, 2025, sections II.B.4 and II.D.1.c were deleted and section II.M. and Appendix A-1 were updated"); sections I.C (Electronic Filing), I.D (Mandatory Notices), II.A.3 (Word Count and Page Limits), II.F (Patent Owner Response). The page's archive lists the November 2019 PDF (`tpgnov.pdf`) and a "November 2019, October 2025 webpage" PDF (`trial_practice_guide_nov2019_oct2025_web.pdf`); both were also fetched and the cited passages match. | https://www.uspto.gov/patents/ptab/trial-practice-guide |
| PTACTS-FAQ | "P-TACTS FAQs", USPTO, PDF created 2025-03-27 (file name dated 2025-03-20), Q. A8 (25 MB upload limit), A10 (document names), D8 (mandatory notices inside the petition), D10 (common petition errors) | https://www.uspto.gov/sites/default/files/documents/p_tacts_faqs_20250320.pdf |
| EX-SALESFORCE | Petition, *Salesforce.com, Inc. v. WSOU Investments*, IPR2022-00154 (Quinn Emanuel) | `petition/usage/` |
| EX-HUAWEI | Petition, Huawei Technologies v. WSOU Investments, IPR2021-00689 (Fish & Richardson) | `petition/usage/` |
| EX-SWARM | Patent owner response, *Juniper Networks v. Swarm Technology*, IPR2021-01445 (Jennings Strouss & Salmon) | `patent-owner-response/usage/` |
| EX-OMNI | Patent owner response, *Apple Inc. v. Omni MedSci, Inc.*, IPR2021-00453 (Brooks Kushman) | `patent-owner-response/usage/` |

Kinds: **M** = mandated by a rule (37 C.F.R. part 42 or a part-1 rule it incorporates). **C** = convention (the rules leave it open; the exemplars that show it are named). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable (content the filer must supply).

The Trial Practice Guide is guidance, not a codified rule; where it only restates a rule the row cites the rule, and where it adds something the row is C or A, never M.

Findings that differ from what many templates assume:

1. **The face is named, not described.** § 42.6(a)(2)(ii): "14-point, Times New Roman proportional font, with normal spacing, must be used". This is stricter than FRAP's "proportionally spaced face": the face itself is mandated. The rule has no footnote or heading exemption, so 14 pt applies to all text. (The repo's templates use a metric-compatible substitute; that is a known gap recorded in the doc-type READMEs, not a reading of the rule.)
2. **No table of contents or table of authorities is required.** No part-42 section requires either; § 42.24(a)(1) and (c) only exclude them from the word count when present. Every exemplar has a table of contents; both patent owner responses have a table of authorities and neither petition does (see PTAB-CONT-003).
3. **Word-count exclusions are written for petitions, motions, replies.** § 42.24(a)(1) excludes "a table of contents, a table of authorities, mandatory notices under § 42.8, a certificate of service or word count, or appendix of exhibits or claim listing" from petitions and motions; § 42.24(c) gives a similar list for replies. § 42.24(b) (patent owner responses) excludes only "a listing of facts which are admitted, denied, or cannot be admitted or denied". The Trial Practice Guide (II.A.3) states the (a)(1) exclusions generally ("Page and word count limits do not include ..."), and both PO-response exemplars certify their count "excluding the parts of the paper exempted by § 42.24(a)" (EX-OMNI) or without stating exclusions (EX-SWARM). The template applies the (a)(1) exclusions to the response too; this is a guide-based reading, recorded as such in PTAB-LEN-002.
4. **Grounds for standing count.** The TPG (II.A.3) says the exclusion "does not apply to grounds for standing", so the § 42.104(a) standing section is counted.
5. **No caption, page-number, header or cover rule.** § 42.6(a)(4) says only that documents "should be identified by the trial number (where known)". The caption, running header and page numbering are conventions (PTAB-COVER-*, PTAB-FORM-010, PTAB-FORM-011).
6. **Signatures are S-signatures with the registration number.** § 42.6(a)(4) requires signature under §§ 1.33 and 11.18(a); § 1.4(d)(2) defines the S-signature ("/Dr. James T. Jones, Jr./") and requires a practitioner's registration number with it.

## Requirements: court-wide (all papers)

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`. IDs from the 2026-10-14 partial pass (PTAB-FORM-001 to 005, PTAB-LEN-001, PTAB-LEN-002, PTAB-FILE-001, PTAB-FILE-002) keep their meaning. The doc-type READMEs use their own older labels (`PTAB-PET-*`, `PTAB-POR-*`); the IDs here are the canonical ones.

### Page form (37 C.F.R. § 42.6(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PTAB-FORM-001 | Page size 8 1/2 x 11 inch (612 x 792 pt), "except in the case of exhibits that require a larger size in order to preserve details of the original". | § 42.6(a)(1), CFR-42.6 | M |
| PTAB-FORM-002 | "Markings must be in black or must otherwise provide an equivalent dark, high-contrast image." | § 42.6(a)(2)(i), CFR-42.6 | M |
| PTAB-FORM-003 | Font: rule text "14-point, Times New Roman proportional font, with normal spacing, must be used". No exemption for footnotes, headings, tables or certificates; the checks apply 14 pt to all text. | § 42.6(a)(2)(ii), CFR-42.6 | M |
| PTAB-FORM-004 | "Double spacing must be used except in claim charts, headings, tables of contents, tables of authorities, indices, signature blocks, and certificates of service. Block quotations may be 1.5 spaced, but must be indented from both the left and the right margins." Operational definition for checks: body-paragraph baseline pitch at least 2 x type size (28 pt at 14 pt); block quotations at least 1.5 x and indented on both sides. The rule names no exception for footnotes or the certificate of word count; double-space them unless a check shows otherwise is needed. | § 42.6(a)(2)(iii), CFR-42.6; TPG II.A.3 (claim charts need not be double-spaced) | M |
| PTAB-FORM-005 | "Margins must be at least 2.5 centimeters (1 inch) on all sides." No exception for page numbers or headers is stated, so the checks keep running headers and page numbers inside the 1 in margins. (P-TACTS FAQ D10 lists "Margins less than 1 inch" among the most common petition errors.) | § 42.6(a)(2)(iv), CFR-42.6; PTACTS-FAQ D10 | M |
| PTAB-FORM-006 | Plain style is not regulated (no italics/bold rule). Convention: case names italicized; headings bold. Seen in all four exemplars. | EX-SALESFORCE, EX-HUAWEI, EX-SWARM, EX-OMNI | C |
| PTAB-FORM-007 | Every font used is embedded, and every embedded font is the template's declared family (no silent fallback). | project | T |
| PTAB-FORM-008 | No incorporation of arguments by reference from another document; no combined documents (e.g. a response combined with a motion). | § 42.6(a)(3), CFR-42.6 | A |
| PTAB-FORM-009 | The document "should be identified by the trial number (where known)". Template: the trial number appears on the caption page and in the running header (PTAB-FORM-010). Not applicable to a petition before a number is accorded. | § 42.6(a)(4), CFR-42.6 | M ("should") |
| PTAB-FORM-010 | Running header on every page after the caption page identifying the proceeding: all four filers carry one, with filer-specific content (EX-SALESFORCE "Petition for Inter Partes Review of / U.S. Patent No. ..."; EX-HUAWEI "Attorney Docket No. ... / IPR of U.S. Patent No. ..."; EX-SWARM "IPR2021-01445 ... Patent Owner's Response"; EX-OMNI "Case No.: ... Atty. Dkt. No.: ... / Patent No.: ..."). The convention is a header with the trial number (or patent number before one is accorded) and the paper's short title; the exact wording is each filer's style. | EX (four filers) | C |
| PTAB-FORM-011 | Page numbering: caption page unnumbered; front matter (contents, authorities, exhibit list) in lower-case roman; the body from Arabic 1; numbers centered at the foot. Seen in all four exemplars. Certificates continue the Arabic run (EX-SWARM, EX-OMNI, EX-SALESFORCE, EX-HUAWEI). | EX (four filers) | C |

### Length (37 C.F.R. § 42.24)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PTAB-LEN-001 | Word limit of a patent owner response to an IPR petition: "The word counts for a patent owner response to petition are the same as the word counts for the petition", which is 14,000 words for an inter partes review petition (18,700 for post-grant review; 18,700 for covered business method review, a program that expired Sept. 16, 2020 per the TPG; 14,000 for derivation). | § 42.24(b)(2) and (a)(1)(i)-(iv), CFR-42.24 | M |
| PTAB-LEN-002 | Word-count exclusions. Petition: "The word count or page limit does not include a table of contents, a table of authorities, mandatory notices under § 42.8, a certificate of service or word count, or appendix of exhibits or claim listing" (§ 42.24(a)(1)); any statement of material facts is included. Patent owner response: § 42.24(b) itself excludes only "a listing of facts which are admitted, denied, or cannot be admitted or denied"; the TPG II.A.3 states the (a)(1) exclusions for "Page and word count limits" generally, and the template applies them to the response (see Findings, 3). Grounds for standing are counted (TPG II.A.3). Claim charts in the paper count (TPG II.A.5). Headings, footnotes and quotations are not excluded by any rule, so they count. | § 42.24(a)(1), (b), CFR-42.24; TPG II.A.3, II.A.5 | M (petition exclusions; response's admitted/denied listing); C (applying the (a)(1) list to a response, per TPG) |
| PTAB-LEN-003 | "Any paper whose length is specified by type-volume limits must include a certification stating the number of words in the paper. A party may rely on the word count of the word-processing system used to prepare the paper." | § 42.24(d), CFR-42.24 | M |
| PTAB-LEN-004 | The count stated in the certification equals an independent count of the counted words (within a tolerance for automatic heading labels) and is at most the limit. | § 42.24(d); PTAB-LEN-001 | M |
| PTAB-LEN-005 | A petition over the word count may be filed only with a motion to waive (proposed petition appended); other waivers must be granted before filing. The template refuses to render over the limit. | § 42.24(a)(2), CFR-42.24 | M |

### Certificates and signature

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PTAB-CERT-001 | "Each document, other than an exhibit, must include a certificate of service at the end of that document." It must state "(A) The date and manner of service; and (B) The name and address of every person served." Service on counsel of record if represented; electronic service on agreement, otherwise Priority Mail Express or equivalent. | § 42.6(e)(1), (3), (4)(i), (iii), CFR-42.6 | M |
| PTAB-CERT-002 | Certificate of word count (PTAB-LEN-003). Convention for the title differs by doc type (see the doc-type sections). | § 42.24(d) | M (content); C (title) |
| PTAB-CERT-003 | Signature under §§ 1.33 and 11.18(a). An S-signature is "a signature inserted between forward slash marks" (e.g. "/Dr. James T. Jones, Jr./"); a practitioner "must supply their registration number either as part of the S-signature or immediately below or adjacent to the S-signature"; the signer's name is printed "preferably immediately below or adjacent the S-signature". All four exemplars sign with a slash signature and a registration number (EX-SALESFORCE uses "/s/ James Glass" with the number below; the others "/Name/"). | § 42.6(a)(4), CFR-42.6; § 1.4(d)(2)(i)-(iii), CFR-1.4 | M |
| PTAB-CERT-004 | Signature block: "Respectfully submitted," date, S-signature, typed name and Reg. No., firm, address, telephone, e-mail, and the role ("Lead Counsel for Patent Owner", "Counsel for Petitioner"). Seen in all four. | EX (four filers) | C |

### Exhibits

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PTAB-CONT-001 | Exhibits are numbered 1001-1999 (petitioner) and 2001-2999 (patent owner); citations to evidence use those numbers. | § 42.63(c), CFR-42 | M (A for the citations) |
| PTAB-CONT-002 | "Each party must maintain an exhibit list with the exhibit number and a brief description of each exhibit ... the current exhibit list must be filed when filing exhibits." All four exemplars place the list in the paper's front matter after the contents (and authorities): EX-HUAWEI "EXHIBITS", EX-SALESFORCE "LIST OF EXHIBITS", EX-SWARM "EXHIBIT LIST", EX-OMNI "UPDATED LIST OF EXHIBITS". | § 42.63(e), CFR-42; placement per EX (four filers) | M (list filed); C (in the front matter) |
| PTAB-CONT-003 | Table of contents: not required by any rule; present in all four exemplars, after the caption page, with dot leaders and right-aligned page numbers. | EX (four filers); § 42.24(a)(1) (excluded from count) | C |

### Electronic filing (P-TACTS)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PTAB-ELEC-001 | Filed electronically "via the Internet according to the parameters established by the Board"; other filing needs a motion. | § 42.6(b)(1), (2), CFR-42.6; TPG I.C | M |
| PTAB-ELEC-002 | "A single uploaded file may not exceed 25 megabytes in size." | PTACTS-FAQ A8 | M (system limit) |
| PTAB-ELEC-003 | Text PDF, not a scan: the FAQ advises "Converting Microsoft Word documents into searchable PDF files, rather than printing documents and scanning them in as flat PDF files". Guidance, not a rule; the template always produces a text PDF. Check: text extracts on every page; fonts embedded. | PTACTS-FAQ A8 | C |
| PTAB-ELEC-004 | Document name entered in P-TACTS: 75 characters or less, simple and descriptive. Filing metadata, not part of the PDF. | PTACTS-FAQ A10 | A |

### Author responsibilities

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PTAB-AUTH-001 | Each petition or motion (and, through § 42.23(a), each opposition such as a patent owner response) states the precise relief requested and a full statement of the reasons, "including a detailed explanation of the significance of the evidence". | § 42.22(a), § 42.23(a), CFR-42 | A |
| PTAB-AUTH-002 | A paper responding to one with a statement of material facts must list the facts admitted, denied, or that cannot be admitted or denied. | § 42.23(a), CFR-42 | A |

## Doc type: petition

Scope: petition requesting inter partes review (37 C.F.R. §§ 42.100-42.108).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PTAB-LEN-010 | Petition requesting inter partes review: 14,000 words (exclusions PTAB-LEN-002). PGR: 18,700; derivation: 14,000. | § 42.24(a)(1)(i), (ii), (iv), CFR-42.24 | M |
| PTAB-CONT-010 | Mandatory notices are part of the petition: real party-in-interest; related matters ("any other judicial or administrative matter that would affect, or be affected by, a decision"); lead and back-up counsel; service information (e-mail, postal address, hand-delivery address if different, telephone, facsimile). They "must be filed as part of the petition itself" (FAQ D8). Placement is open: EX-HUAWEI puts them first, before the body's other sections; EX-SALESFORCE after an Introduction (section II). | § 42.8(a)(1), (b)(1)-(4), CFR-42; PTACTS-FAQ D8; placement EX | M (content); C (placement split, no convention) |
| PTAB-CONT-011 | Lead counsel and at least one back-up counsel designated; lead counsel a registered practitioner; power of attorney filed with the designation. | § 42.10(a), (b), CFR-42 | M (A: filed as a separate paper) |
| PTAB-CONT-012 | Grounds for standing: certification "that the patent for which review is sought is available for inter partes review and that the petitioner is not barred or estopped". Counted toward the word limit. | § 42.104(a), CFR-42; TPG II.A.3 | M |
| PTAB-CONT-013 | Identification of challenge, for each challenged claim: the claim; statutory grounds (35 U.S.C. 102 or 103) and the patents or printed publications for each ground; how the claim is to be construed (with § 112(f) structure where applicable); how the construed claim is unpatentable, specifying "where each element of the claim is found in the prior art"; the exhibit numbers relied on and their relevance. | § 42.104(b)(1)-(5), CFR-42 | M (sections); A (content) |
| PTAB-CONT-014 | Statement of the precise relief requested and full statement of reasons (PTAB-AUTH-001). | § 42.22(a), CFR-42 | M |
| PTAB-CONT-015 | Fee: the petition is accompanied by the § 42.15(a) fee; no filing date without it. Both exemplars state a "Payment of Fees" section. | § 42.106(a)(3), CFR-42; EX-HUAWEI, EX-SALESFORCE | M (fee); C (section) |
| PTAB-CONT-016 | Order observed in both petitions: caption page; contents; exhibit list (and claim listing in EX-HUAWEI only, that filer's style); mandatory notices; payment of fees; requirements for IPR (standing, relief requested); the patent; level of ordinary skill; claim construction; grounds; conclusion; signature; certification of word count; certificate of service. | EX-HUAWEI, EX-SALESFORCE | C |
| PTAB-CONT-017 | No table of authorities in either petition (not required). The template emits one only if the input has authorities. | EX-HUAWEI, EX-SALESFORCE | C |
| PTAB-COVER-010 | Caption page: no rule. The two filers differ: EX-SALESFORCE uses the Board caption ("UNITED STATES PATENT AND TRADEMARK OFFICE / BEFORE THE PATENT TRIAL AND APPEAL BOARD / <petitioner> Petitioner v. <owner> Patent Owner / U.S. Patent No. / Inter Partes Review No. / title"), the same form both patent owner responses use; EX-HUAWEI uses an "In re Patent of" bibliographic block with the Mail Stop Patent Board address (that filer's style). Template follows the Board caption (three of four filers across both doc types). | EX (split for petitions) | C |
| PTAB-CERT-010 | Certification of word count titled "CERTIFICATION UNDER 37 C.F.R. § 42.24", stating the count and that it is under the limit, placed after the signature and before the certificate of service. Both petitions. | § 42.24(d); EX-HUAWEI, EX-SALESFORCE | M (content); C (title, placement) |
| PTAB-CERT-011 | Service of the petition on the patent owner "at the correspondence address of record for the subject patent" (electronic only on agreement; otherwise Priority Mail Express or equal); the certificate states it (EX-HUAWEI: Federal Express to the correspondence address). | § 42.105(a), (b), CFR-42; § 42.106(a)(2) | M |

## Doc type: patent-owner-response

Scope: the patent owner response after institution of an inter partes review (37 C.F.R. § 42.120).

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PTAB-FILE-001 | "A patent owner may file a single response to the petition and/or decision on institution. A patent owner response is filed as an opposition and is subject to the page limits provided in § 42.24." (The applicable limit is a word count, PTAB-LEN-001.) | § 42.120(a), CFR-42.120 | M |
| PTAB-FILE-002 | Due date: as set by Board order; if none, "three months from the date the inter partes review was instituted". | § 42.120(b), CFR-42.120 | M |
| PTAB-LEN-020 | Word limit 14,000 for an IPR response (same as the petition), with the exclusions in PTAB-LEN-002. Certification required (PTAB-LEN-003). | § 42.24(b)(2), (d), CFR-42.24 | M |
| PTAB-CONT-020 | As an opposition, the response complies with the content rules for motions (§ 42.22) and, if the petition has a statement of material facts, lists facts admitted/denied. | § 42.23(a), CFR-42 | M (A for content) |
| PTAB-CONT-021 | The patent owner's mandatory notices are a separate filing within 21 days of service of the petition (§ 42.8(a)(2)); they are not part of the response. Neither response exemplar includes them. | § 42.8(a)(2), CFR-42; EX-SWARM, EX-OMNI | M |
| PTAB-CONT-022 | Guide (not rule): "The response should identify all the involved claims that are believed to be patentable and state the basis for that belief", and "should include any affidavits or additional factual evidence sought to be relied upon and explain the relevance of such evidence". | TPG II.F | A |
| PTAB-CONT-023 | Table of authorities present in both responses, after the contents (cases, statutes, rules, other). | EX-SWARM, EX-OMNI | C |
| PTAB-CONT-024 | Front matter order in both responses: caption page; table of contents; table of authorities; exhibit list. The body opens with an Introduction (EX-SWARM "I. INTRODUCTION"; EX-OMNI "I. Introduction"), then the patent overview and claim construction, then the argument against each ground, then a conclusion. | EX-SWARM, EX-OMNI | C |
| PTAB-COVER-020 | Caption page (both responses): "UNITED STATES PATENT AND TRADEMARK OFFICE / BEFORE THE PATENT TRIAL AND APPEAL BOARD", petitioner "Petitioner," "v.", patent owner "Patent Owner.", the case number and patent number, then the title "PATENT OWNER('S) RESPONSE ..." citing the rule. Centered, single page. (EX-OMNI's title cites § 42.107, the preliminary-response rule, although the paper is the post-institution response; that is a filer slip, not a convention.) | EX-SWARM, EX-OMNI | C |
| PTAB-CERT-020 | Certificate of word count titled "CERTIFICATE OF COMPLIANCE" (EX-SWARM) or "Certificate of Compliance Pursuant to 37 C.F.R. § 42.24" (EX-OMNI), stating the word count and a typeface statement under § 42.6 (both filers). The typeface statement is a convention, not required text. | § 42.24(d); EX-SWARM, EX-OMNI | M (count); C (title, typeface statement) |
| PTAB-CERT-021 | Order of the closing certificates: split. EX-SWARM: signature, certificate of compliance, certificate of service. EX-OMNI: signature, certificate of service, certificate of compliance. § 42.6(e)(4)(i) puts the certificate of service "at the end of that document"; the template therefore places it last. | § 42.6(e)(4)(i); EX (split) | M (service at end); C |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| PTAB-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| PTAB-TOOL-002 | No case-specific text and no measured coordinates in the template. | T |
| PTAB-TOOL-003 | Every TOC entry's page number equals the page on which that heading appears; every TOA page reference contains the citation. | T (supports PTAB-CONT-003, PTAB-CONT-023) |
| PTAB-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |

## Exemplars

Two filers per doc type are now in hand (2026-10-17):

- petition: EX-SALESFORCE (Quinn Emanuel) and EX-HUAWEI (Fish & Richardson); same patent owner (WSOU), different petitioners and counsel. Both are district-court exhibit copies with an ECF header on each page.
- patent-owner-response: EX-SWARM (Jennings Strouss & Salmon, PTAB Litigation Blog copy) and EX-OMNI (Brooks Kushman; P-TACTS public download of the response as re-filed as Samsung Ex. 1012 in PGR2025-00064, exhibit label and "PGR2025-00064 Page 000nn" footer added by the re-filer). See `patent-owner-response/usage/SOURCE.md`.

Not verified: any PTAB standing order or Board notice beyond the Trial Practice Guide and the P-TACTS FAQ that adds to the paper format; the P-TACTS user guide's PDF requirements (the case-document listing API requires login; the FAQ is the public statement read).
