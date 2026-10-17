# United States Bankruptcy Court, District of New Hampshire: rules

Alias `nhb`. Scope: papers filed by counsel through CM/ECF in the United States Bankruptcy Court for the District of New Hampshire; doc types `adversary-complaint` (the complaint commencing an adversary proceeding) and `motion-brief` (a motion, or a memorandum of law supporting one, in a contested matter). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (Bankruptcy Rules amendments) and whenever the court posts amended Local Bankruptcy Rules. **A revision is pending now**: Public Notice 26-3 (October 1, 2026) opened a comment period through October 31, 2026 on proposed revisions to the LBRs, LBFs, AOs and IBRs; re-verify this file when those take effect.

## Sources

| Tag | Source | URL |
|---|---|---|
| LBR | Local Bankruptcy Rules and Interim Bankruptcy Rules, "Effective February 1, 2026, As Amended Through May 1, 2026" (43-page PDF, created 2026-04-16; listed on the court's Rules and Forms page as "Local Bankruptcy Rules as of May 1, 2026"). Fetched 2026-10-17, sha256 dcab67be...1eb7. Page numbers are printed page numbers. | https://www.nhb.uscourts.gov/sites/nhb/files/NHBLocalRulesEffective05.01.2026.pdf |
| GO | General Order re: Local Bankruptcy Rules (December 30, 2025): new rules effective February 1, 2026; all prior LBRs, AOs and LBFs repealed. Public Notice 25-6 (same date). | https://www.nhb.uscourts.gov/sites/nhb/files/12-30-2025USBC-NHGeneralOrderLBRs.pdf, https://www.nhb.uscourts.gov/sites/nhb/files/USBC-NHPublicNotice25-06.pdf |
| PN26-3 | Public Notice 26-3 (October 1, 2026): comment period on proposed revisions | https://www.nhb.uscourts.gov/sites/nhb/files/USBC-NHPublicNotice26-3.pdf (rules page: https://www.nhb.uscourts.gov/rules-and-forms) |
| FRBP | Federal Rules of Bankruptcy Procedure 5005(a), 7005, 7007.1, 7008, 7010, 9004, 9011(a), 9013, 9037 (restyled, eff. Dec. 1, 2024; LII text) | https://www.law.cornell.edu/rules/frbp/rule_9004 (and .../rule_5005, rule_7005, rule_7007.1, rule_7008, rule_7010, rule_9011, rule_9013, rule_9037) |
| FRCP | Federal Rules of Civil Procedure 5(d)(1)(B), 8(a), 10(b) (applied by FRBP 7005, 7008, 7010) | https://www.law.cornell.edu/rules/frcp/rule_5, .../rule_8, .../rule_10 |
| F416 | Official Form 416A "Caption (Full)" and 416D "Caption for Use in Adversary Proceeding" (12/15) | https://www.uscourts.gov/sites/default/files/form_b416a_0.pdf, https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf |
| EX-A1 | Adversary complaint exemplar: Timothy P. Smith, Ch. 7 Trustee (Sheehan Phinney Bass & Green), Adv. No. 24-01019, Doc 1 | `adversary-complaint/exemplars/SOURCE.md` |
| EX-M1 | Motion memorandum exemplar: Mission Product Holdings, Inc. (Bernstein, Shur, Sawyer & Nelson), No. 15-11400, Doc 685 | `motion-brief/exemplars/SOURCE.md` |

Kinds: **M** = mandated by a court rule (FRBP, FRCP as applied, or LBR). **C** = convention (rules leave it open; exemplars named). **T** = project/tooling rule of this repo. **A** = author responsibility.

Findings:

1. **The February 1, 2026 rules replaced the 2024/2025 rules that the doc-type READMEs cite.** The GO repealed all prior LBRs. Gone from the current text: LBR 7101-7104 and 9004-1/9004-2 (now consolidated in LBR 9013-1), the BNH-number-after-signature requirement, and the 15/25-page memorandum limits of former LBR 7102(b)(2). The current text contains no page limit for motions or memoranda (searched "page", "memorand", "exceed"). README rows citing LBR 7101, 7102, 7103 or 9004-1 are superseded.
2. **No rule on typeface, type size, spacing, margins or paper size.** The current LBR contain no form-of-paper rule (searched font, point, spacing, margin, 8 1/2); FRBP 9004(a) requires only that a document "be clearly legible". All layout below is C or T. LBR 9029-1(a) says the district court's rules govern where they conflict with the LBR, but no district rule is incorporated for form of papers; that question is recorded as not verified, not as a requirement.
3. **Every motion carries three attachments**: a notice of hearing (LBF 7104-1), a certificate of service (LBF 7103-1) and a proposed order entitled "Order" (LBR 9013-1(f)).

## Court-wide requirements (all doc types)

### Page form

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHB-FORM-001 | "A petition, pleading, schedule, or other document must be clearly legible." No typeface, size, spacing or margin is prescribed. | FRBP 9004(a) | M |
| NHB-FORM-002 | US Letter pages, 1-inch margins, page number at the foot. No rule found; both exemplars. | EX-A1, EX-M1 | C |
| NHB-FORM-003 | Typeface Times New Roman, 12 point, body double-spaced. Seen in EX-A1 and EX-M1 (two filers, two firms). The rules are silent on font. | EX-A1, EX-M1 | C |
| NHB-FORM-004 | Every font used is embedded and is the template's declared family. | project | T |

### Caption

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHB-COVER-001 | Caption sets forth the court's name, the case's title, the case number and, if appropriate, the adversary-proceeding number, and a brief designation of the document's character. | FRBP 9004(b) | M |
| NHB-COVER-002 | Caption of motions, objections, responses and replies includes the debtor's name, the case number and the applicable chapter. | LBR 9013-1(a)(1), p. 28 | M |
| NHB-COVER-003 | The assigned judge's initials follow the case or adversary number, separated by a hyphen (e.g. "22-10577-MAF"). | LBR 9013-1(a)(2), p. 28 | M |
| NHB-COVER-004 | Adversary pleadings' caption substantially conforms to Official Form 416 (416D: In re debtor; plaintiff; defendant; Case No., Chapter, Adv. Proc. No.). | FRBP 7010; F416 | M (substantial conformity) |
| NHB-COVER-005 | Court name centered in capitals ("UNITED STATES BANKRUPTCY COURT / [FOR THE] DISTRICT OF NEW HAMPSHIRE"); party block on the left closed by a column of ")" marks; case number and chapter at the right. Seen in EX-A1 and EX-M1. | EX-A1, EX-M1 | C |

### Signature and electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHB-ELEC-001 | All papers are filed electronically through CM/ECF (exceptions: pro se parties; proofs of claim by non-users). | LBR 5005-4(b)-(c), p. 18; FRBP 5005(a)(3)(A) | M |
| NHB-ELEC-002 | Electronically filed documents include a signature block with name, address and telephone number; the Filing User's name is preceded by "/s/" and typed where the wet signature would appear. | LBR 5005-4(f)(1), p. 19; FRBP 9011(a) | M |
| NHB-ELEC-003 | Exhibits filed with a motion are attached as a single PDF, clearly labeled (Exhibit A, B, ...) and separated by a cover or divider page. | LBR 9013-1(j), p. 30 | M |
| NHB-ELEC-004 | Redact personal identifiers. | FRBP 9037(a); LBR 9037-1, p. 32 | A |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHB-CONT-001 | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances; separate counts where that promotes clarity. | FRBP 7010; FRCP 10(b) | M |
| NHB-CONT-002 | Jurisdiction allegation references the name, number and Code chapter of the main case and its district and division; the complaint states whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. | FRBP 7008 | M (content; A for wording) |
| NHB-CONT-003 | Short and plain statement of jurisdiction and claim; demand for relief. | FRBP 7008; FRCP 8(a) | A |
| NHB-CONT-004 | The adversary proceeding cover sheet is filed as an attachment to the complaint, with complete names and addresses of each plaintiff and defendant. Separate document. | LBR 7003-1, p. 23 | M (separate attachment) |
| NHB-CONT-005 | The clerk issues the summons; service under FRBP 7004. Not part of the complaint. | LBR 7004-2, p. 23 | M (separate) |
| NHB-CONT-006 | Corporate ownership statement for a nongovernmental corporate party (other than the debtor) with its first paper. | FRBP 7007.1 | M (separate filing) |
| NHB-CERT-001 | No certificate of service in the complaint itself (served with the summons under FRBP 7004; FRCP 5(d)(1)(B) via FRBP 7005 for later papers). | FRBP 7005; FRCP 5(d)(1)(B) | M (conditional) |
| NHB-CONT-007 | Title "COMPLAINT" centered; INTRODUCTION, JURISDICTION AND VENUE, PARTIES, FACTS and COUNT headings centered in capitals; count sub-titles in parentheses. One filer only (EX-A1); filer style until a second exemplar is collected. | EX-A1 | C (one filer) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NHB-CONT-101 | A request for an order is made by written motion that states its grounds with particularity and the relief requested. "Motion" includes applications and objections to claim. | FRBP 9013(a)-(b); LBR 9013-1 (preamble), p. 28 | M |
| NHB-CONT-102 | A motion to be heard on shortened notice says so in its body and title (e.g. "... on Shortened Notice") and states the cause. | LBR 9013-1(e), p. 29 | M (conditional) |
| NHB-CONT-103 | Filed with every motion: a notice of hearing in the form of LBF 7104-1, signed; a proposed order entitled "Order" (not "Proposed Order") in the form of the applicable LBF or LBF 9013-1 (except motions for relief and to modify a chapter 13 plan). Separate documents. | LBR 9013-1(f)(1), (f)(3), pp. 29-30 | M (separate documents) |
| NHB-CERT-101 | A certificate of service in the form of LBF 7103-1 is filed with every motion, stating for each CM/ECF recipient the date of filing and the recipient's name, and for each other recipient the date, manner of service, name and address. | LBR 9013-1(f)(2), p. 29 | M |
| NHB-CONT-104 | Objections and responses state in narrative form the factual or legal reasons the motion should be denied, not in the form of an answer to a complaint; a reply is optional. | LBR 9013-1(h), p. 30 | M (for responses) |
| NHB-CONT-105 | Summary judgment: a separate supporting memorandum of law and a separate statement of material facts in short numbered paragraphs with record references. | LBR 7056-1(a), p. 24 | M (conditional) |
| NHB-LEN-101 | No page limit for motions or memoranda in the current LBR (the former LBR 7102(b)(2) limits were repealed by GO). | LBR (whole text); GO | M (no limit) |
| NHB-CONT-106 | Title in bold capitals naming the movant; FACTUAL BACKGROUND and ARGUMENT headings centered; lettered and roman sub-headings; conclusion, signature, then certificate of service with service list. One filer only (EX-M1); filer style until a second exemplar is collected. | EX-M1 | C (one filer) |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| NHB-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| NHB-TOOL-002 | No case-specific text and no measured coordinates in the template. | T |
| NHB-REVIEW-001 | A recorded visual review of the current PDF covers every page (Gate 2). | T |

Not verified: whether D.N.H. LR 5.1 (district court form of papers) applies to bankruptcy filings through LBR 9029-1(a) or LR 77.4; the district rules were not read for this file. The LBF forms (7103-1, 7104-1, 9013-1) were not fetched.
