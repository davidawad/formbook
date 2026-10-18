# United States Bankruptcy Court, District of Maine: rules

Alias `meb`. Scope: papers filed by counsel through CM/ECF in the United States Bankruptcy Court for the District of Maine; doc types `adversary-complaint` (the complaint commencing an adversary proceeding) and `motion-brief` (a contested-matter motion under Fed. R. Bankr. P. 9013 with its grounds and argument in the same paper). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (Bankruptcy Rules and Local Rules amendments take effect then; the current Local Rules are effective December 1, 2025) and whenever the court posts amended Local Rules or general orders.

## Sources

| Tag | Source | URL |
|---|---|---|
| LBR | United States Bankruptcy Court, District of Maine, Local Rules, "Effective December 1, 2025" (39-page PDF), with Appendix A "Administrative Procedures for Electronic Filing". Fetched 2026-10-17 (sha256 780ba20e...d3). Page numbers are the printed page numbers. | https://www.meb.uscourts.gov/sites/meb/files/202512_USBC_Local_Rules.pdf |
| FRBP | Federal Rules of Bankruptcy Procedure 5005(a), 7003, 7005, 7007.1, 7008, 7010, 9004, 9011(a), 9013, 9037 (restyled, as amended Apr. 2, 2024, eff. Dec. 1, 2024; LII text) | https://www.law.cornell.edu/rules/frbp/rule_9004 (and .../rule_5005, rule_7003, rule_7005, rule_7007.1, rule_7008, rule_7010, rule_9011, rule_9013, rule_9037) |
| FRCP | Federal Rules of Civil Procedure 5(d)(1)(B), 8(a), 10(a)-(b) (applied by FRBP 7005, 7008, 7010) | https://www.law.cornell.edu/rules/frcp/rule_5, .../rule_8, .../rule_10 |
| F416 | Official Form 416A "Caption (Full)" and 416D "Caption for Use in Adversary Proceeding" (12/15) | https://www.uscourts.gov/sites/default/files/form_b416a_0.pdf, https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf |
| EX-A1 | Adversary complaint exemplar: Manhart, Ch. 7 Trustee (Perkins Thompson), Adv. No. 26-01006, Doc 1 | `adversary-complaint/usage/SOURCE.md` |
| EX-M1 | Motion exemplar: Severin M. Beliveau (creditor, filing for himself), No. 24-20188, Doc 414 | `motion-brief/usage/SOURCE.md` |
| EX-M2 | Motion exemplar: Wheeling & Lake Erie Railway Company (Marcus, Clegg & Mistretta), No. 13-10670, Doc 1938 (filed 2016, under earlier Local Rules) | `motion-brief/usage/SOURCE.md` §2 |

Kinds: **M** = mandated by a court rule (FRBP, FRCP as applied, or D. Me. LBR). **C** = convention (rules leave it open; exemplars named). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings:

1. **No rule on typeface, type size, spacing, margins or paper size.** The December 2025 Local Rules contain no form-of-paper rule (searched for font, point, margin, spacing, 8 1/2), and FRBP 9004(a) requires only that a document "be clearly legible". All layout choices below are therefore C (from exemplars) or T. This differs from the district court (D. Me. Local R. 10 sets 12-point, double spacing and 1-inch margins). LBR 1001-1 makes the LBR the rules for cases in this court; LBR 9001-1(f) defines "D. Me. Local R." as the district court's rules, and the LBR incorporate district rules only for named subjects (summary judgment, LBR 7056-1 and D. Me. Local R. 56; attorney admission and conduct, LBR 9010-1 and D. Me. Local R. 83.x), none on form of papers. D. Me. Local R. 10 is therefore not treated as binding here.
2. **Proposed order with every motion** (LBR 9013-1(a)), a separate document.
3. **Caption must substantially conform to Official Form 416** (FRBP 7010), and every adversary paper carries the main-case caption plus the adversary caption (LBR 7003-1(a)).

## Court-wide requirements (all doc types)

### Page form

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MEB-FORM-001 | "A petition, pleading, schedule, or other document must be clearly legible." No typeface, size, spacing or margin is prescribed. | FRBP 9004(a) | M |
| MEB-FORM-002 | US Letter (8 1/2 x 11 in) pages. No rule found; all three exemplars are letter size. | EX-A1, EX-M1, EX-M2 | C |
| MEB-FORM-003 | Typeface: Times-style serif, 12 point, as in EX-A1 (Times New Roman), EX-M1 (Times Roman) and EX-M2 (Times New Roman). The rules are silent on font; three filers agree on the family. | EX-A1, EX-M1, EX-M2 | C |
| MEB-FORM-004 | Body double-spaced, 1-inch margins, page number at the foot. Seen in EX-A1, EX-M1 and EX-M2; no rule. | EX-A1, EX-M1, EX-M2 | C |
| MEB-FORM-005 | Every font used is embedded and is the template's declared family. | project | T |

### Caption (FRBP 9004(b), 7010; Official Form 416; LBR 7003-1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MEB-COVER-001 | Every document presented for filing has a caption setting forth (1) the court's name, (2) the case's title, (3) the case number and, if appropriate, adversary-proceeding number, and (4) a brief designation of the document's character. | FRBP 9004(b) | M |
| MEB-COVER-002 | Caption layout per Official Form 416: "United States Bankruptcy Court / ____ District Of ____"; "In re [debtor], Debtor" on the left; Case No. and Chapter on the right; the designation of the paper centered below. | F416 (416A, 416D) | M (substantial conformity) |
| MEB-COVER-003 | In an adversary proceeding, every paper contains the main case caption followed by the names of the parties to the adversary proceeding, the title of the paper, and the adversary proceeding number. Form 416D adds Plaintiff / Defendant and "Adv. Proc. No." | LBR 7003-1(a), p. 16; FRBP 7010; F416 (416D) | M |
| MEB-COVER-004 | Title-line legends when they apply: "Request for Emergency Determination" (court to act within 48 hours), "Request for Expedited Determination" (earlier than default deadlines), "Request for Limitation of Notice". | LBR 9013-4(a)(2)(A)-(B), (c)(1), p. 23 | M (conditional) |
| MEB-COVER-005 | A motion filed under LBR 9013-3 states "Relief Requested Without a Hearing" in the upper right corner of the first page. | LBR 9013-3, p. 22 | M (conditional) |

### Signature and electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MEB-ELEC-001 | All papers are filed electronically through ECF (exceptions: unrepresented parties; proofs of claim by non-users); highly sensitive documents are not filed electronically. | LBR 5005-1(a)-(c), p. 15; FRBP 5005(a)(3)(A) | M |
| MEB-ELEC-002 | ECF accepts only electronically converted PDF documents. | LBR App. A, introduction | M |
| MEB-ELEC-003 | Electronic signature is the signer's name typed in full, e.g. "/s/ Jane Doe"; the ECF password is the registered user's signature for FRBP 9011. | LBR App. A § II.A; FRBP 5005(a)(3)(C) | M |
| MEB-ELEC-004 | Every document is signed by at least one attorney of record in the attorney's individual name and states the signer's address and telephone number. | FRBP 9011(a) | M |
| MEB-ELEC-005 | Redact personal identifiers (last four digits of SSN/TIN and account numbers, year of birth, minors' initials). | FRBP 9037(a); LBR 9037-1, p. 27 | A |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MEB-CONT-001 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts where that promotes clarity. | FRBP 7010; FRCP 10(b) | M |
| MEB-CONT-002 | The jurisdiction allegation references the name, number and Code chapter of the main case and the district and division where it is pending; the complaint states whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | FRBP 7008 | M (content; A for wording) |
| MEB-CONT-003 | Short and plain statement of jurisdiction and of the claim, and a demand for the relief sought. | FRBP 7008; FRCP 8(a) | A |
| MEB-CONT-004 | Every unrepresented party files a completed cover sheet, Official Form B1040 (separate document). | LBR 7003-1(b), p. 16 | M (separate filing; pro se only) |
| MEB-CONT-005 | A nongovernmental corporate party (other than the debtor) files a corporate ownership statement with its first paper (separate document). | FRBP 7007.1 | M (separate filing) |
| MEB-CERT-001 | No certificate of service is required for papers served through ECF (FRCP 5 applies via FRBP 7005). The complaint itself is served with the summons under FRBP 7004, outside the template. | FRBP 7005; FRCP 5(d)(1)(B) | M (conditional) |
| MEB-CONT-006 | Section order (jurisdiction and venue, parties, facts, counts, prayer for relief, signature); headings centered in capitals. One filer only (EX-A1); filer style until a second exemplar is collected. | EX-A1 | C (one filer) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| MEB-CONT-101 | A request for an order is made by written motion that states its grounds with particularity and sets forth the relief or order requested. | FRBP 9013(a)-(b) | M |
| MEB-CONT-102 | Each written motion is accompanied by a proposed form of order (the court's posted form if there is one), which states that it issues after notice and hearing or opportunity for hearing, or identifies consenting parties. Separate document. | LBR 9013-1(a), p. 20 | M (separate filing) |
| MEB-CONT-103 | When a motion has a separately identified statement of facts under the header "Facts", every written response must admit or deny each factual allegation (FRCP 8(b)). | LBR 9013-1(c)(2), pp. 20-21 | M (effect of the header) |
| MEB-CONT-104 | A motion requesting emergency or expedited determination embeds that request (no separate motion), lists the facts justifying it, and identifies the day or range of days desired. | LBR 9013-4(a)(1), (a)(4), p. 23 | M (conditional) |
| MEB-LEN-101 | A reply is limited to five pages; memoranda in discovery disputes may not exceed five pages. No page limit applies to the motion itself. | LBR 9013-1(d)(1), p. 21; LBR 7026-1(b)(2), p. 16 | M (reply / discovery only) |
| MEB-CONT-105 | Motions in abandonment, lien-avoidance and free-and-clear sale matters state the property, its value, exemptions, and each lien (holder, type, priority, amount), unless all parties consent. | LBR 9014-1(b), p. 25 | M (conditional) |
| MEB-CERT-101 | The movant serves the motion as FRBP 7004 provides (no summons). When notice under FRBP 2002 is given by a party, that party files a certificate of service stating the mode and date of service, the names and addresses of the parties served and, when counsel is served, the party represented. For emergency or expedited motions a certificate states the time, date and manner of notice. | LBR 9014-1(a)(2), p. 25; LBR 2002-1(r), p. 5; LBR 9013-4(b), p. 23; FRBP 9013(b) | M (conditional) |
| MEB-CONT-106 | Seen in both motion filers (EX-M1, EX-M2), so convention: court name centered in capitals over a caption whose party block is closed by a ")" column, chapter and case number at the right; title centered in bold capitals; opening "Now comes [movant]" paragraph; numbered paragraphs; WHEREFORE prayer; "/s/" signature with counsel block; certificate of service starting on a new page, followed by the service list. Filer style (one filer each): EX-M1 uses roman-numeral section headings; EX-M2 a "JURISDICTIONAL STATEMENT" heading and "and Incorporated Memorandum of Law" in the title. | EX-M1, EX-M2 | C |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| MEB-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| MEB-TOOL-002 | No case-specific text and no measured coordinates in the template. | T |
| MEB-REVIEW-001 | A recorded visual review of the current PDF covers every page (Gate 2). | T |

Not verified: the court's "Adversary Complaint Template" (https://www.meb.uscourts.gov/sites/meb/files/Adversary_Complaint_Template.pdf), cited in `adversary-complaint/README.md`, could not be fetched on 2026-10-17 (the court site returned "Request Rejected"); it is a court guide, not a rule, and no requirement here rests on it.
