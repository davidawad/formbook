# U.S. Bankruptcy Court, Eastern District of Pennsylvania (adversary complaint, motion brief): rules

Alias `paeb`. Scope: a complaint commencing an adversary proceeding (`adversary-complaint/`) and a memorandum of law in support of a motion, typically a Rule 12(b)(6) motion to dismiss in an adversary proceeding (`motion-brief/`), filed by counsel through CM/ECF. Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (the FRBP amendment date, which this court also uses for its own amendments: Dec. 1, 2024 and Dec. 1, 2025) and whenever the court posts amended Local Bankruptcy Rules.

Access note: on 2026-10-17 `www.paeb.uscourts.gov` rejected direct requests from this box; the L.B.R. PDF was retrieved through the WebFetch tool from the court's URL (binary saved and read with `pdftotext`), and the court's announcement page from an Internet Archive capture.

## Sources

| Tag | Source | URL |
|---|---|---|
| LBR | Local Bankruptcy Rules, E.D. Pa., "(Effective December 1, 2025)", 93 pp. (PDF created 2025-11-20) | https://www.paeb.uscourts.gov/sites/paeb/files/PAEB%20Local%20Rules%20-2025-12-01%20Final.pdf |
| LBR-NEWS | Court announcement "Amendments to Local Bankruptcy Rules and Forms: Effective 12/01/2025" | https://web.archive.org/web/20251221020409/https://www.paeb.uscourts.gov/news/amendments-local-bankruptcy-rules-and-forms-effective-12012025 |
| FRBP | Federal Rules of Bankruptcy Procedure 7003, 7007.1, 7008, 7010, 9004, 9011, 9013 (LII text, restyled eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7008 (and rule_7003, rule_7007.1, rule_7010, rule_9004, rule_9011, rule_9013) |
| FRCP | Federal Rules of Civil Procedure 8, 10 (applied by FRBP 7008, 7010) | https://www.law.cornell.edu/rules/frcp/rule_8 , https://www.law.cornell.edu/rules/frcp/rule_10 |
| F416D | Official Form 416D, Caption for Use in Adversary Proceeding (12/15) | https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf |
| EX-KRUEGER | Adversary complaint, Adv. No. 26-00127 (Kang Haggerty LLC, for plaintiffs Krueger) | `adversary-complaint/exemplars/` |
| EX-TIG | Adversary complaint, Adv. No. 26-00204 (Salzmann Hughes PC, for plaintiffs) | `adversary-complaint/exemplars/` |
| EX-HENRY | Memorandum of law in support of motion to dismiss, *Henry v. US Bank Trust Co.*, Adv. No. 26-00106 (Eckert Seamans, for the defendant) | `motion-brief/exemplars/` |

Kinds: **M** = mandated by a rule (FRBP, FRCP as applied, L.B.R.). **C** = convention (from the exemplars). **T** = project/tooling rule. **A** = author responsibility.

Findings that differ from what many templates assume:

1. **No typeface, size, spacing, margin or brief-length rule.** The L.B.R. (Dec. 1, 2025) sets none of these; the only page-form rule is for papers filed in paper form (8 1/2 x 11, stapled at the top, L.B.R. 9004-1(b)). Every format choice is C. Unlike the Middle District bankruptcy court, the L.B.R. does not adopt the district court's motion or brief rules for adversary proceedings.
2. **Consent statement in every motion**, not only in pleadings: a motion "shall ... contain a statement that the movant does or does not consent to the entry of a final order or judgment by the court" (L.B.R. 9014-3(b)(2), applied to adversary proceedings by L.B.R. 7005-1(a)); an adversary complaint must carry the same statement under FRBP 7008.
3. **Certificate of service follows L.B.F. 9014-4** and is filed within 3 days or before the hearing (L.B.R. 9014-4), and applies to motions in adversary proceedings (L.B.R. 7005-1(a)).
4. **Dispositive motions in adversary proceedings** (Rule 12(b)(6), 12(c), 56): no hearing date is obtained, the response period is 21 days, and the L.B.F. 9014-3 notice is modified accordingly (L.B.R. 7005-1(b)).

## Requirements: all papers

### Page form

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PAEB-FORM-001 | A document "must be clearly legible". | FRBP 9004(a) | M |
| PAEB-FORM-002 | A document submitted in paper form "shall measure 8½ x 11 inches and shall be stapled or fastened at the top." (Applies only when paper filing is authorized; e-filed PDFs follow the same size by convention.) | L.B.R. 9004-1(a)-(b) | M (paper); C (PDF) |
| PAEB-FORM-003 | Times New Roman (or Times), 12 pt, double-spaced body (line pitch about 27-28 pt), 1 inch margins: EX-KRUEGER and EX-HENRY. EX-TIG also embeds Times New Roman. Common practice, not a rule. | EX-KRUEGER, EX-TIG, EX-HENRY | C |
| PAEB-FORM-004 | The bottom margin carries no text other than the page number: bankruptcy CM/ECF stamps "Case ... Doc ... Filed ... Entered ... Desc Main Document Page x of y" at the foot of every page. | exemplars | C |
| PAEB-FORM-005 | Every font embedded and of the template's declared family. | project | T |

### Caption, signature, filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PAEB-CAP-001 | Caption: the court's name; the case's title; the case number and, if appropriate, adversary-proceeding number; a brief designation of the document's character. | FRBP 9004(b) | M |
| PAEB-CAP-002 | In an adversary proceeding the pleading's caption "must substantially conform to the appropriate version of Form 416"; Official Form 416D lays out: court; "In re ____, Debtor" with Case No. and Chapter; "____, Plaintiff" v. "____, Defendant" with Adv. Proc. No.; document title. | FRBP 7010; F416D | M |
| PAEB-ELEC-001 | Documents are filed electronically through CM/ECF unless paper filing is authorized; the Notice of Electronic Filing is entry on the docket and service on those deemed to consent; filing must be completed before midnight Eastern time. | L.B.R. 5005-2(a), (d), (f) | M |
| PAEB-ELEC-002 | A document signed by a CM/ECF Filing User includes "a signature block that sets forth the name, address, telephone number, and e-mail address of the CM/ECF Filing User", and is either a scanned signed copy or carries "s/" next to the typed name. | L.B.R. 5005-7(a) | M |
| PAEB-ELEC-003 | The authorized use of the filer's login and password is the filer's signature for FRBP 9011. | L.B.R. 9011-1; FRBP 9011(a) | M |
| PAEB-ELEC-004 | Redaction of personal identifiers (FRBP 9037). | FRBP 9037 | A |
| PAEB-CERT-001 | Certificate of service, conforming to L.B.F. 9014-4, stating (1) the subject of the notice or title of the document served; (2) the names of all persons served and their physical or e-mail address; (3) whether service was through CM/ECF, mail, or another method; filed within 3 days after the document, or before a scheduled hearing if earlier. | L.B.R. 9014-4(a)-(b) | M |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PAEB-CONT-001 | FRCP 8 applies; the jurisdiction allegation "must include a reference to the name, number, and Code chapter of the case that the adversary proceeding relates to and the district and division where it is pending." | FRBP 7008; FRCP 8(a) | M |
| PAEB-CONT-002 | The complaint "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." | FRBP 7008 | M |
| PAEB-CONT-003 | Numbered paragraphs; separate counts where that promotes clarity; caption per Form 416D. | FRBP 7010; FRCP 10(b) | M |
| PAEB-CONT-004 | Only a *paper* complaint filed under L.B.R. 5005-2(c)(2) is filed with the Adversary Proceeding Cover Sheet provided by the Clerk. | L.B.R. 7003-1 | M (paper only) |
| PAEB-CONT-005 | Corporate ownership statement by a nongovernmental corporate party other than the debtor, with its first filing. Separate document. | FRBP 7007.1 | M (separate filing) |
| PAEB-CONT-006 | Structure seen in both filers: Form 416D-style caption with the main case and the adversary number; centered complaint title; sections for parties and "JURISDICTION AND VENUE"; numbered paragraphs; "COUNT I: <claim>" headings, each closed by a WHEREFORE paragraph; signature with "/s/". EX-TIG adds a final "PRAYER FOR RELIEF"; EX-KRUEGER adds argument-style roman-numbered sub-headings and a certificate of service. | EX-KRUEGER, EX-TIG | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| PAEB-LEN-001 | No page or word limit for a memorandum in support of a motion in the L.B.R. | LBR (no rule found) | M (none) |
| PAEB-CONT-010 | Motions in adversary proceedings are governed by L.B.R. 7005-1, which incorporates L.B.R. 9014-2, 9014-3(b)-(f), (h), (k) and 9014-4. | L.B.R. 9014-1(b); L.B.R. 7005-1(a) | M |
| PAEB-CONT-011 | The motion identifies the movant, the nature of the relief sought, and its basis, and contains the consent / no-consent statement on entry of a final order or judgment. | L.B.R. 9014-3(b)(1)-(2) | M (motion) |
| PAEB-CONT-012 | A proposed form of order is filed with the motion. | L.B.R. 9014-3(f) | M (motion) |
| PAEB-CONT-013 | For a Rule 12(b)(6), 12(c) or 56 motion in an adversary proceeding: no hearing date is obtained under L.B.R. 9014-3(c), the response period is 21 days, and the L.B.F. 9014-3 notice is modified to match. | L.B.R. 7005-1(b) | M |
| PAEB-CONT-014 | Structure seen in EX-HENRY: caption with ")" column; title "Memorandum of Law in Support of ... Motion to Dismiss"; roman-numbered sections I. Statement of the Case, II. Background, III. Legal Standard, IV. Legal Argument, V. Conclusion; no TOC or TOA (10 pages). One filer: that filer's style. | EX-HENRY | C (one filer) |

## Not verified

- L.B.F. 9014-3 (notice of motion) and L.B.F. 9014-4 (certificate of service) were not fetched; PAEB-CERT-001 states the rule's required content, not the form's layout.
- motion-brief has one filed exemplar. A second filer was searched for on 2026-10-17 (Internet Archive CDX index of CourtListener RECAP `gov.uscourts.paeb.*`: 83 archived files, page 1 of each read; they are petitions, notices, trustee motions and orders, none a memorandum of law in support of a motion); the CourtListener search API was throttled for the day. Recorded in `docs/box-blocked.md`.
