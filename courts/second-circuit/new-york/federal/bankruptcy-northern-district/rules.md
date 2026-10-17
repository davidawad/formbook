# U.S. Bankruptcy Court, N.D. New York: rules

Alias `nynb`. Scope: papers filed by counsel through CM/ECF in the United States Bankruptcy Court for the Northern District
of New York, for the doc types in this folder: `adversary-complaint` (the complaint commencing an adversary proceeding)
and `motion-brief` (a memorandum of law in support of a motion, in a case or an adversary proceeding). Verified against
primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (the court's local rules take effect on December 1) and whenever the
court posts amended local rules or revised Administrative Procedures. **Pending:** the court has published proposed
amendments effective December 1, 2026 (NOTICE below), which rewrite LBR 9013-1 and drop the chambers-copy paragraph;
re-verify NYNB-ELEC-006 and the 9013-1 rows on or after 2026-12-01.

## Sources

| Tag | Source (rule / version / effective date) | URL |
|---|---|---|
| LBR | Local Bankruptcy Rules, N.D.N.Y., effective December 1, 2024 (listed as "Current Local Rules" on the court's Local Rules page, fetched 2026-10-17; sha256 `42cf58029ce1b15f5df588fae5dd701a51993b9d43c151cdfaaa041b5ccdd4e4`). Page numbers below are the printed page numbers. | https://www.nynb.uscourts.gov/sites/nynb/files/LBR_GenOrders/Local%20Bankruptcy%20Rules_Effective%2012-01-2024%20Final.pdf |
| LR-PAGE | Court's "Local Rules & General Orders" page (names the December 1, 2024 rules as current) | https://www.nynb.uscourts.gov/local-rules-general-orders |
| NOTICE | Public Notice, "Opportunity for Public Comment on Proposed Amendments to Local Bankruptcy Rules Effective December 01, 2026", dated October 01, 2026, with the proposed text (sha256 `84a55f0e3a72249eba05c14d55e5e654e2f2030835648591a1c64adb7e46cbc9`). Proposed, not in force. | https://www.nynb.uscourts.gov/sites/nynb/files/News/LR%20Publication%20Notice%202026.pdf |
| AP | Administrative Procedures for Filing, Signing & Verifying Pleadings & Papers by Electronic Means, revised January 1, 2012 (the current version on the court's Administrative Procedures page; sha256 `87019341dd574461be7c0866fafb44bee9decf08a31ec66abc3d482e67ad9766`) | https://www.nynb.uscourts.gov/sites/nynb/files/CMECF/AdminProc010112.pdf (page: https://www.nynb.uscourts.gov/administrative-procedures) |
| FRBP | Federal Rules of Bankruptcy Procedure 7003, 7007.1, 7008, 7010, 7012, 9004, 9011, 9013, 9037 (as amended Apr. 2, 2024, eff. Dec. 1, 2024; Cornell LII text) | https://www.law.cornell.edu/rules/frbp/rule_9004 (and `rule_7003`, `rule_7007.1`, `rule_7008`, `rule_7010`, `rule_7012`, `rule_9011`, `rule_9013`, `rule_9037`) |
| FRCP | Federal Rules of Civil Procedure 8 and 10 (applied by FRBP 7008 and 7010; Cornell LII text) | https://www.law.cornell.edu/rules/frcp/rule_8, https://www.law.cornell.edu/rules/frcp/rule_10 |
| F416D | Official Form 416D, Caption for Use in Adversary Proceeding (12/15) (sha256 `a2ed5c2eeba7f1a78c4ae18fb9d9ee97d9586b67bf0e92766c35e85470082834`) | https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf |
| F416A | Official Form 416A, Caption (Full) (12/15) (sha256 `ad62c9ed2c031075ddc77f073d52fb12e70f40c42a1922efe72e1a9f50f1a2ac`) | https://www.uscourts.gov/sites/default/files/form_b416a_0.pdf |
| EX-FANGIO | Exemplar: Fangio (Ch. 11 trustee) v. Vehifax Corp., Adv. No. 15-50001, Dkt 1, complaint, by The Crossmore Law Office | `adversary-complaint/exemplars/` |
| EX-STEVENS | Exemplar: Stevens (Plan Administrator) v. Evepark London LP, Adv. No. 26-90046, Dkt 1, complaint, by Klestadt Winters Jureller Southard & Stevens, LLP | `adversary-complaint/exemplars/` |
| EX-GECC | Exemplar: EF Consulting LLC v. General Electric Capital Corp., Adv. No. 10-90175, Dkt 6, GECC's memorandum of law in support of its motion to dismiss, by Moritt Hock & Hamroff LLP | `motion-brief/exemplars/` |
| EX-EFC | Exemplar: same adversary, Dkt 13, plaintiffs' (EF Consulting LLC and Oasis HC LLC) memorandum of law in opposition to the motion to dismiss and in support of their cross-motion for partial summary judgment, by Backenroth Frankel & Krinsky LLP | `motion-brief/exemplars/` |

Kinds: **M** = mandated by a court rule (LBR, AP, FRBP, or FRCP as applied by the FRBP). **C** = convention (the rules
leave it open; taken from exemplars, with the filers named). **T** = project/tooling rule of this repo. **A** = author
responsibility, not machine-checkable (content the lawyer must supply).

Findings that differ from what many templates assume:

1. **No typeface rule, and no page or word limit.** LBR 9004-1(a)(1)(A) sets only "A minimum of 12-point font". No LBR,
   AP section or FRBP rule read for this file sets a page or word limit for a complaint or a memorandum of law (LBR
   9004-1(b) refers to "page limitations" but none is set in the LBR text). Length limits, if any, come from a judge's
   order.
2. **The 12-point minimum applies to footnotes too** ("Text, whether in the body of a document or in a footnote, must
   be: (A) A minimum of 12-point font").
3. **Caption must carry the last four SSN/TIN digits** (LBR 9004-1(c)), which none of the four exemplars do.
4. **File-size conflict.** AP V.B (2012): "The size of the electronic file shall be no larger than 2 megabytes." LBR
   9013-2 (2024), for motion exhibits: "no larger than 5 Megabytes (MB)." AP II.A.1 says the AP governs on conflict
   "as it relates to the electronic filing". The checks use the stricter 2 MB.
5. **Chambers copy marking** "ECF CASE – CHAMBERS COPY" (LBR 9013-1(h)) is required in force today, but the proposed
   December 1, 2026 text of LBR 9013-1 (NOTICE) no longer contains paragraph (h).

## Court-wide requirements

### Page form (LBR 9004-1(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYNB-FORM-001 | Every page "Letter-size, 8 ½ x 11 inch layout" (612 x 792 pt). | LBR 9004-1(a)(2)(C), LBR p. 113 | M |
| NYNB-FORM-002 | "Formatted with a one-inch margin on all four sides." Check: no text outside a 1 in inset on any page (the court's ECF header stamp is added after filing and is not part of our output). | LBR 9004-1(a)(2)(A), LBR p. 113 | M |
| NYNB-FORM-003 | Font size: text "whether in the body of a document or in a footnote, must be ... A minimum of 12-point font." Applies to footnotes and headings alike. The rule names no typeface. | LBR 9004-1(a)(1)(A), LBR p. 113 | M |
| NYNB-FORM-004 | "Double-spaced, except that text in a block quotation or footnote may be single-spaced." Operational definition for the checks: body baseline-to-baseline distance at least 2 x type size (24 pt at 12 pt). Captions, headings and signature blocks are not body text (the rule is silent; treated as convention). | LBR 9004-1(a)(1)(B), LBR p. 113 | M |
| NYNB-FORM-005 | "Plainly and legibly written, typewritten, printed or reproduced without defacing erasures or interlineations"; a document "must be clearly legible". | LBR 9004-1(a)(1)(C); FRBP 9004(a) | M |
| NYNB-FORM-006 | "Printed on only a single-side of a page" and "Printed in black ink." Check: all text is black (no coloured text). | LBR 9004-1(a)(1)(D), (E) | M |
| NYNB-FORM-007 | Pages "Consecutively numbered." The rule does not fix the position or the numeral style. | LBR 9004-1(a)(2)(B), LBR p. 113 | M |
| NYNB-FORM-008 | Page-number style: arabic numerals centred at the foot. Where a cover page and a table of contents precede the body, the cover is unnumbered, the front matter is in lower-case roman numerals and the body starts at 1: seen in EX-STEVENS, EX-GECC and EX-EFC (3 filers). EX-FANGIO (no front matter) prints arabic numbers centred at the foot from page 2, page 1 unnumbered. A single arabic run from page 1 also satisfies NYNB-FORM-007 and is the template default for short papers. | EX-STEVENS, EX-GECC, EX-EFC, EX-FANGIO | C |
| NYNB-FORM-009 | Typeface: Times / Times New Roman in all four exemplars (EX-FANGIO Times-Roman, EX-STEVENS TimesNewRomanPSMT, EX-GECC Times-Roman, EX-EFC TimesNewRomanPSMT), so a serif text face is the convention. The rule is silent on face (NYNB-FORM-003); the template's vendored serif face is a project choice. | EX-FANGIO, EX-STEVENS, EX-GECC, EX-EFC | C |
| NYNB-FORM-010 | Every font used is embedded, and every embedded font is the template's declared family (vendored fonts only). | project | T |
| NYNB-FORM-011 | "Extensive footnotes must not be used to circumvent page limitations." | LBR 9004-1(b), LBR p. 113 | A |
| NYNB-FORM-012 | "The Court reserves the right to not consider a document that fails to comply with this Rule." (Consequence of NYNB-FORM-001 to -007 and NYNB-CAP-001.) | LBR 9004-1(d), LBR p. 114 | M (consequence) |

### Caption (LBR 9004-1(c), FRBP 9004(b))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYNB-CAP-001 | The caption contains: the name of the Court; the title of the case; the case number and chapter number; "only the last four digits of the debtor's social security number and/or taxpayer identification number"; and, "if pertinent to an adversary proceeding, the adversary proceeding name and assigned number". | LBR 9004-1(c), LBR p. 113; FRBP 9004(b)(1)-(3) | M |
| NYNB-CAP-002 | "The caption shall also contain a short title that identifies the document and the name of the party on whose behalf it is filed." (FRBP 9004(b)(4): "a brief designation of the document's character".) | LBR 9004-1(c); FRBP 9004(b)(4) | M |
| NYNB-CAP-003 | Court name as two lines, "UNITED STATES BANKRUPTCY COURT" / "NORTHERN DISTRICT OF NEW YORK", in capitals at the head of the caption. The LBR sample caption prints it centred-left in that form; all four exemplars print it flush left (EX-STEVENS and EX-EFC below a counsel block). | LBR 9004-1(c) sample caption; EX-FANGIO, EX-STEVENS, EX-GECC, EX-EFC | C |
| NYNB-CAP-004 | Case number and chapter in a right-hand column ("Case No. XX-XXXXX" / "Chapter 13" in the LBR sample); the SSN/TIN line directly under the debtor's name, before "Debtors." | LBR 9004-1(c) sample caption | C (layout of an M requirement) |
| NYNB-CAP-005 | Short title centred below the caption: LBR sample caption, EX-STEVENS, EX-GECC, EX-EFC (3 filers). EX-FANGIO puts "ADVERSARY COMPLAINT" in the caption's right column (filer style). | LBR 9004-1(c) sample; EX-STEVENS, EX-GECC, EX-EFC | C |
| NYNB-CAP-006 | Personal identifiers: only the last four digits of an SSN, TIN or financial-account number, the year of birth, and a minor's initials. "Responsibility for redacting ... rests solely with counsel." | LBR 9037-1(a), (b), LBR p. 140; FRBP 9037(a) | A (M for the filer) |

### Signature (LBR 9011-3, LBR 5005-1(b), FRBP 9011(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYNB-SIG-001 | Signed by at least one attorney of record in the attorney's individual name; "Each document must state the signer's address and telephone number". | FRBP 9011(a) | M |
| NYNB-SIG-002 | "the attorney's signature block shall include the signer's e-mail address and Northern District of New York attorney bar roll identification number." | LBR 9011-3(b), LBR p. 119 | M |
| NYNB-SIG-003 | Electronic signature "in the format “/s/name” unless the document has been scanned and shows the actual signature." AP III.C: "shall indicate a signature in the format, “/s/ name,” unless the document has been scanned and shows the original signature." | LBR 9011-3(c), LBR p. 119; LBR 5005-1(b), LBR p. 81; AP III.C | M |
| NYNB-SIG-004 | The filer's name on the docket must match the attorney name signed on the document. | LBR 9011-3(d) | A |
| NYNB-SIG-005 | Signature block layout: "Dated:" line with place and date at left, firm name and "By: /s/ ..." block at right: EX-STEVENS, EX-GECC and EX-EFC (3 filers). | EX-STEVENS, EX-GECC, EX-EFC | C |

### Electronic filing (LBR 5005-1, AP)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYNB-ELEC-001 | An entity represented by an attorney "must file documents electronically in accordance with the Administrative Procedures". | LBR 5005-1(a)(1), LBR p. 81 | M |
| NYNB-ELEC-002 | Pleadings, briefs and memoranda of law are filed "in Portable Document Format (PDF) or PDF/A." (PDF/A is announced as a future requirement; no date set.) Check: the output is a valid PDF with a text layer on every page and embedded fonts. | AP II.A.2 (p. 4) | M (PDF); C (text layer, PDF/A-readiness) |
| NYNB-ELEC-003 | File size: "The size of the electronic file shall be no larger than 2 megabytes." (AP V.B; LBR 9013-2 says 5 MB for motion exhibits; AP II.A.1 says the AP governs on conflict. The checks use 2 MB.) | AP V.B; AP II.A.1; LBR 9013-2, LBR p. 124 | M |
| NYNB-ELEC-004 | Documents are not accepted by email or fax. | LBR 5005-1(c) | A |
| NYNB-ELEC-005 | A proposed order is not placed in the body of a pleading ("DO NOT ELECTRONICALLY FILE A PLEADING THAT CONTAINS A PROPOSED ORDER IN THE BODY OF THE PLEADING"). | LBR 9011-3(h)(2), LBR p. 120 | M |
| NYNB-ELEC-006 | Chambers copy, for the matters listed (Albany: (h)(1)(A)-(G), including "Memoranda of law ... filed in regard to a submitted matter"; Syracuse and Utica: (h)(2)(A)-(H), including "Any pleading filed in an adversary proceeding" and memoranda of law), "must be clearly marked as “ECF CASE – CHAMBERS COPY.”" Delivery is the author's duty. Proposed for deletion effective 2026-12-01 (NOTICE). | LBR 9013-1(h), LBR pp. 121-122 | M (marking, when a chambers copy is made); A (delivery) |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYNB-CONT-001 | Caption substantially conforms to Official Form 416D: court and district; "In re [debtor], Debtor"; plaintiff; defendant; Case No., Chapter, Adv. Proc. No. in the right column; "COMPLAINT [or other designation]" below. Plus the N.D.N.Y. additions of NYNB-CAP-001 (last four SSN/TIN digits). | FRBP 7010; F416D; LBR 9004-1(c) | M |
| NYNB-CONT-002 | "The title of the complaint must name all the parties." | FRCP 10(a) via FRBP 7010 | M |
| NYNB-CONT-003 | Claims stated "in numbered paragraphs, each limited as far as practicable to a single set of circumstances"; each claim founded on a separate transaction, where clarity is served, in a separate count. Check: body paragraphs carry consecutive numbers. | FRCP 10(b) via FRBP 7010 | M (numbering); A (content) |
| NYNB-CONT-004 | A short and plain statement of jurisdiction; it "must include a reference to the name, number, and Code chapter of the case that the adversary proceeding relates to and the district and division where it is pending." | FRBP 7008; FRCP 8(a)(1) | A (M for the filer) |
| NYNB-CONT-005 | The complaint "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." (EX-STEVENS ¶ 3 does; EX-FANGIO, 2015, does not.) | FRBP 7008 | A (M for the filer) |
| NYNB-CONT-006 | A short and plain statement of the claim, and "a demand for the relief sought" (the prayer / WHEREFORE clause). | FRCP 8(a)(2), (3) via FRBP 7008 | M (a prayer is present); A (content) |
| NYNB-CONT-007 | Adversary Proceeding Cover Sheet required "for all proceedings filed online via CM/ECF and in paper format" (a separate form, not part of the complaint PDF). | LBR 7003-1, LBR p. 94 | A |
| NYNB-CONT-008 | Summons is generated by CM/ECF on filing; the plaintiff prints and serves it (FRBP 7004). Not part of the complaint. | LBR 7004-1(a), LBR p. 95 | A |
| NYNB-CONT-009 | Corporate ownership statement for a nongovernmental corporate party (other than the debtor), filed with its first appearance or pleading. Separate paper. | FRBP 7007.1 | A |
| NYNB-CONT-010 | Prayer items set as a lettered or numbered list after "WHEREFORE": EX-FANGIO numbers them "1." to "5.", EX-STEVENS letters them "A." to "C."; the labelled list is the convention, the label style is filer style. | EX-FANGIO, EX-STEVENS | C |
| NYNB-CONT-011 | Counsel block at the top left of page 1 (EX-STEVENS only) and a separate cover page with a table of contents (EX-STEVENS only): filer style, not required. | EX-STEVENS | C (optional; one filer) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYNB-LEN-001 | No page or word limit for a memorandum of law is set in the LBR, the AP, or FRBP 9013. A judge's order may set one. | LBR (whole text searched), AP, FRBP 9013 | A |
| NYNB-CONT-020 | Caption per NYNB-CAP-001/-002; in an adversary proceeding the adversary name and number are included (Form 416D layout, NYNB-CONT-001). The short title names the document and the party (e.g. "Memorandum of Law in Support of Defendant ...'s Motion to Dismiss"). | LBR 9004-1(c); FRBP 9004(b); FRBP 7010 (adversary pleadings) | M |
| NYNB-CONT-021 | For answering papers: "The date, time, and location of the hearing shall be included above the case number in the caption." (The rule's text is in the answering-papers paragraph; for a moving memorandum it is a convention, not a mandate.) | LBR 9013-1(g)(1), LBR p. 121 | M (answering papers); C (moving papers) |
| NYNB-CONT-022 | The notice of motion sets out "the specific relief sought, the party or parties against whom such relief is sought, and the rule or statute upon which the motion or application is predicated." A motion "must state its grounds with particularity and set forth the relief or order requested." (The notice and the motion are separate papers; the memorandum supports them.) | LBR 9013-1(a)(1), LBR p. 120; FRBP 9013(b) | A (M for the notice/motion) |
| NYNB-CERT-001 | Certificate of service "upon both registered and non-registered users of the CM/ECF system is required. The certificate must state the manner in which service or notice was accomplished on each party." Filed not later than 7 days before the return date. Sample language: AP Form D. EX-GECC uses a sworn affidavit of service. | LBR 9013-1(c), LBR p. 120; AP Form D | M (presence and manner of service); A (timing) |
| NYNB-CONT-023 | Timing: motion filed and served at least 21 days before the return date; answering papers received at least 7 days before it. | LBR 9013-1(e), (g)(1) | A |
| NYNB-CONT-024 | Summary-judgment memorandum (LBR 7056-1(b), (d)): "cites all authorities upon which the party relies" and "must disclose all controlling authorities, including those contrary to" the party's position; the motion also needs a separate statement of material facts in numbered paragraphs (LBR 7056-1(a)). | LBR 7056-1, LBR p. 104 | A (M for summary-judgment papers) |
| NYNB-CONT-025 | Exhibits to a motion: filed electronically; may be summarized with only relevant excerpts filed; a proposed order submitted as an exhibit "shall prominently bear on its face the word “EXHIBIT.”" | LBR 9013-2, LBR p. 124 | A |
| NYNB-CONT-026 | Front matter for a long memorandum: separate cover page (caption, title, firm block), table of contents and table of authorities numbered in lower-case roman, body from arabic 1. Seen in EX-GECC (42 pp, Moritt Hock) and EX-EFC (66 pp, Backenroth Frankel), 2 filers, so a convention for long memoranda; the rules do not require it. Counsel block at the top left of page 1 is in EX-EFC only (filer style). | EX-GECC, EX-EFC | C |
| NYNB-CONT-027 | Top-level headings ("PRELIMINARY STATEMENT", "STATEMENT OF FACTS", "CONCLUSION") centred in capitals: EX-GECC and EX-EFC (2 filers). Bold weight and point-heading style were not compared from the text layer (Gate 2 visual check). | EX-GECC, EX-EFC | C |

## Not verified

- **Judges' individual practices.** The two judges' pages on the court site (Chief Judge Kinsella's "Procedures for
  Appearances/Hearings", fetched 2026-10-17) cover remote appearances only; no format or length rule was found. No other
  chambers rules were found.
- **Current CM/ECF PDF rules beyond AP 2012.** The AP page lists the 2012 revision as current and a "Changes to ECF
  Administrative Procedures" PDF (not read). Any later change to the 2 MB limit or a PDF/A mandate is not verified.
- **Official Form 416A/416D text** was read from uscourts.gov (12/15 versions); whether a later revision exists was not
  checked.
- The README claim that FRBP 7010 requires conformity to "Official Form 416A" is corrected here: FRBP 7010 says "the
  appropriate version of Form 416", which for an adversary proceeding is Form 416D.
