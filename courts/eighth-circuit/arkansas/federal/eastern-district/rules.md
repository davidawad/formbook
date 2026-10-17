# Eastern District of Arkansas civil filings: rules

Alias `ared`. Scope: civil complaints and separate briefs in support of motions to dismiss. Verified against the court's current local-rules page and its linked complete rules text, and the U.S. Courts' current Federal Rules of Civil Procedure, on 2026-10-17. Re-check the court's local rules page and national rules before each template refresh and at least annually, including after a local-rule amendment or standing order.

## Primary sources

| Tag | Source | URL | Version checked |
|---|---|---|---|
| EDA-LR | Local Rules of the United States District Court for the Eastern and Western Districts of Arkansas | https://www.are.uscourts.gov/sites/are/files/local_rules/All_LR.pdf | Current complete copy linked from https://www.are.uscourts.gov/court-info/local-rules-and-orders/local-rules; rules 5.1 and 5.5 last amended Nov. 5, 2020 and Dec. 30, 2019, respectively; Rule 7.2 last amended Dec. 1, 2019. Verified current listing and text 2026-10-17. |
| FRCP | Federal Rules of Civil Procedure | https://www.uscourts.gov/forms-rules/current-rules-practice-procedure/federal-rules-civil-procedure | Current official publication checked 2026-10-17; relevant Rules 4, 5, 7, 8, 10, 11, 12, 38 |
| EXEMPLARS | Public filings in each doc-type folder's `exemplars/` directory | Source URL, filer, filing/retrieval date, and SHA-256 are recorded in each folder's `exemplars/SOURCE.md` | Public filings; visual convention only |

Kinds: **M** = mandatory; **C** = convention; **T** = repository contract; **A** = filer responsibility. Local rules supplement the FRCP.

## Common civil filing form

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ARED-FORM-001 | Pleadings, motions, and other papers are on letter-size paper, double-spaced, and printed on one side of the page. The rule says type must be "not less than elite"; it names no font family or point-size minimum. Papers are filed unfolded and without manuscript covers. | E.D. Ark. LR 5.5(a), EDA-LR pp. 5-6, verified 2026-10-17 | M |
| ARED-COVER-001 | A pleading or other paper states the case number assigned by the Clerk. A complaint caption identifies the court, case title, file number, and pleading designation; the complaint's title names all parties. | E.D. Ark. LR 5.5(a), EDA-LR p. 6; FRCP 10(a), official FRCP publication, verified 2026-10-17 | M |
| ARED-CERT-001 | Counsel signs in the attorney's individual name and states address, ZIP code, telephone number, and the Arkansas Supreme Court identification number (or another Supreme Court identification number, if applicable). FRCP additionally requires the signer's email address. | E.D. Ark. LR 5.5(c)(1), EDA-LR p. 6; FRCP 11(a), official FRCP publication, verified 2026-10-17 | M |
| ARED-ELEC-001 | A represented party files electronically unless the court permits nonelectronic filing for good cause. General exceptions include case-initiating documents; the Eastern District also excepts sealed records and documents that add a party. A person without counsel generally files on paper unless the court orders electronic filing. | E.D. Ark. LR 5.1, EDA-LR p. 4, verified 2026-10-17 | M |
| ARED-AUTH-001 | The filer redacts personal identifiers as required by FRCP 5.2(a). | FRCP 5.2(a), official FRCP publication, verified 2026-10-17 | A |

## Complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ARED-CONT-001 | A complaint contains a short and plain statement of the grounds for jurisdiction, a short and plain statement showing entitlement to relief, and a demand for the relief sought. | FRCP 8(a)(1)-(3), official FRCP publication, verified 2026-10-17 | M |
| ARED-CONT-002 | Claims are stated in numbered paragraphs, each limited as far as practicable to one set of circumstances; separate transactions or occurrences are placed in separate counts when clarity requires. | FRCP 10(b), official FRCP publication, verified 2026-10-17 | M |
| ARED-CERT-002 | A party demanding a jury must serve and file the demand no later than 14 days after the last pleading directed to the issue; it may be included in the complaint. | FRCP 38(b)(1)-(2), official FRCP publication, verified 2026-10-17 | M (if demanding a jury) |
| ARED-ELEC-002 | A represented party may file a case-initiating complaint on paper under the case-initiation exception; self-represented filers generally submit paper unless ordered to e-file. | E.D. Ark. LR 5.1, EDA-LR p. 4, verified 2026-10-17 | M |
| ARED-CONT-003 | Caption, heading, paragraph, and signature-block styling follow the complaint exemplars where the rules leave a choice. | `complaint/exemplars/SOURCE.md`, retrieved 2026-10-14 | C |

The original and two copies requirement in E.D. Ark. LR 5.5(a), and the JS-44 civil cover sheet under LR 5.5(d), concern paper filing and/or separate accompanying papers. The complaint template does not generate those extra copies or the separate cover sheet.

## Motion brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ARED-CONT-004 | Except for motions listed in LR 7.2(d), a motion raising an issue is accompanied by a brief with a concise statement of relevant facts and applicable law; the motion and brief are filed and served. | E.D. Ark. LR 7.2(a), EDA-LR p. 10, verified 2026-10-17 | M |
| ARED-CONT-005 | A motion to dismiss is filed as a separate pleading accompanied by a separate brief. | E.D. Ark. LR 7.2(e), EDA-LR p. 11, verified 2026-10-17 | M |
| ARED-CONT-006 | A written motion states with particularity the grounds for seeking the order. | FRCP 7(b)(1)(B), official FRCP publication, verified 2026-10-17 | M |
| ARED-CONT-007 | A motion to dismiss may assert the defenses listed in FRCP 12(b), including failure to state a claim under 12(b)(6). | FRCP 12(b)(6), official FRCP publication, verified 2026-10-17 | M |
| ARED-CONT-008 | Local Rule 7.2 sets no page or word limit for the supporting brief; an assigned judge may set additional requirements. | E.D. Ark. LR 7.2(a), EDA-LR pp. 10-11, verified 2026-10-17 | M |
| ARED-CONT-009 | Heading hierarchy, citation layout, and signature-block placement follow the motion-brief exemplar where the rules leave a choice. | `motion-brief/exemplars/SOURCE.md`, retrieved 2026-10-14 | C |
| ARED-CERT-003 | A separate certificate of service is not required when service is made through the court's electronic filing system. | FRCP 5(d)(1)(B), official FRCP publication, verified 2026-10-17 | M |

## Author responsibilities

| ID | Requirement | Source | Kind |
|---|---|---|---|
| ARED-AUTH-002 | An incarcerated plaintiff bringing an action under 42 U.S.C. § 1983 or 28 U.S.C. §§ 2241 or 2254 uses the court-approved complaint form unless a judge accepts another complaint under the conditions in the rule. | E.D. Ark. LR 9.1, EDA-LR p. 15, verified 2026-10-17 | A |
| ARED-AUTH-003 | A complaint is served with summons under FRCP 4; service on each defendant and filing of proof of service are the filer's responsibility. | FRCP 4(c), 4(l), official FRCP publication, verified 2026-10-17 | A |

## Template contract

| ID | Requirement | Kind |
|---|---|---|
| ARED-TOOL-001 | Every sample word appears in the rendered PDF in order; no case-specific text is embedded in the template. | T |
| ARED-TOOL-002 | Mechanical checks cover applicable mandatory requirements, and visual review covers every rendered page. | T |
