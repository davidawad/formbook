# Trademark Trial and Appeal Board: inter partes papers (answer, answer and counterclaim)

Alias `ttab`. Scope: a paper filed by counsel in an opposition or cancellation proceeding, with the Board's standard caption: chiefly the **Answer** (and **Answer and Counterclaim**) to a notice of opposition or petition to cancel. Other papers that carry the same caption and signature and service blocks (motions, stipulations) use the same template; their own content rules are not covered here. Verified against primary sources on 2026-10-21.

## Sources

Every requirement below cites one of these. TBMP page numbers are the printed page numbers of the June 2026 edition.

| Tag | Source | Where |
|---|---|---|
| CFR | 37 C.F.R. Part 2, eCFR as of 2026-10-19 (sections 2.6, 2.101 to 2.107, 2.111 to 2.114, 2.116, 2.119, 2.126, 2.127, 2.133, 2.135, 2.193, 2.195, 2.196) | KB: `~/Knowledge/Stacks/K Law/KF United States/KF2971-3193 Intellectual property/KF3091-3193 Patent law and trademarks/KF3176-3180 General. Common-law trademarks (Table KF4)/KF3180/37 CFR Part 2 - Rules of Practice in Trademark Cases (eCFR 2026-10-19).md`; public: https://www.ecfr.gov/current/title-37/chapter-I/subchapter-A/part-2 |
| TBMP | Trademark Trial and Appeal Board Manual of Procedure, June 2026 (§§ 110.01, 110.02, 113, 309.02, 309.03, 310.03, 311, 313, 514) | KB: same folder, `TTAB Manual of Procedure (TBMP) - June 2026.pdf`; public: https://www.uspto.gov/trademarks/trademark-trial-and-appeal-board/tbmp |
| STAT | 15 U.S.C. §§ 1063, 1064, 1068, 1141f | https://www.law.cornell.edu/uscode/text/15/1068 ; matter copy `response-plan/sources/statutes/` |
| TTC | USPTO "TTAB Center" page (what can be filed there), last updated 2026-09-08, read 2026-10-21 | https://www.uspto.gov/systems-information/trademark-trial-and-appeal-board-ttab-center |
| FRCP | Fed. R. Civ. P. 8(b), 9, 11, 12(b), 15 (the Board follows them unless Part 2 differs, 37 C.F.R. § 2.116(a)) | https://www.law.cornell.edu/rules/frcp |
| EX | The filed exemplars in `exemplars/` (see `exemplars/SOURCE.md`). Visual reference for open choices only. | local |

Kinds: **M** = mandated by a statute or rule. **C** = convention (the rules leave it open; taken from TBMP guidance worded "should", or seen across the exemplars). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable (content the lawyer must supply).

Findings that differ from what many templates assume:

1. **Filing system.** The rule text still says ESTTA (37 C.F.R. §§ 2.106(b)(1), 2.114(b)(1), 2.126(a)). TBMP § 110.01 (June 2026) says TTAB Center is public for notices of opposition, petitions to cancel, trial testimony, evidence and briefs, and that ESTTA redirects to it as capability arrives. The TTAB Center page (updated 2026-09-08) lists motions, attorney appearances and correspondence updates as available and says the next release will let customers "File answers, counterclaims, amended pleadings and related motions." No date is given. Until that release, an answer and a counterclaim go through ESTTA; check the page on the day of filing.
2. **Answer time.** The Board's notice of institution sets it, "not less than thirty days" from the mailing date (§ 2.105(a)). TBMP § 310.03(a) says the long-standing 40 days "is changing" to 60 days. Calendar from the order, never from the manual.
3. **A restriction of a plaintiff's pleaded registration needs a counterclaim** (§ 2.133(d)), but a Section 18 restriction claim is not an attack on validity, so the five-year limit of Section 14 does not bar it (TBMP § 309.03(d), notes 10 and 11).
4. **The Board will not restrict a registration the counterclaim does not name**, and a main claim can be sustained on a pleaded registration the counterclaim did not reach (TBMP § 309.03(d) n.7; the *Sage* exemplar). A counterclaim must name every pleaded registration the opposition could be sustained on.
5. **No reply to an affirmative defense** (§ 2.106(b)(2)). An attack on a pleaded registration's validity, including abandonment, is not an affirmative defense and is heard only as a counterclaim or separate petition (§ 2.106(b)(3)(ii); TBMP § 311.02(d)).

## Requirements

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Form (tier 1 for the Board's own requirements)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TTAB-FORM-001 | Text of an electronically filed submission is at least 11-point and double-spaced. Operational definition used here: 12-point type with a baseline-to-baseline distance in body paragraphs of at least 24 pt (the template sets 27.6 pt, the same as Word's "double" for Times New Roman at 12 pt). The caption, block quotations, signature block, certificate of service and drafting notes may be single-spaced (the rule states no exemption; the exemplars single-space them). | CFR § 2.126(a)(1); TBMP § 311.01 | M |
| TTAB-FORM-002 | Page size Letter, 8.5 by 11 inch (the rule states this for paper; it is also the electronic default). Margins 1 inch; the Board states no margin. | CFR § 2.126(b)(2); EX | C |
| TTAB-FORM-003 | Exhibits, if any, are attached to the electronic submission, clear and legible. The template produces none (an answer attaches none by default; evidence is offered by notice of reliance at trial). | CFR § 2.126(a)(2) | M |
| TTAB-FORM-004 | A serif face is used throughout, in Times New Roman or a metrically identical face. The typst PDF embeds Liberation Serif (SIL OFL, vendored in `fonts/liberation-serif/`; the repo allows no system fonts); the docx names Times New Roman. | project; supports TTAB-FORM-001 | T |
| TTAB-FORM-005 | Page numbers centered at the foot, Arabic, starting at 1 on the first page. | EX | C |
| TTAB-FORM-006 | A paper that is confidential in whole or part is marked and filed under the Board's confidential selection with a redacted public copy. Not generated; author responsibility. | CFR § 2.126(c) | A |

### Caption and title

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TTAB-HEAD-001 | The paper bears at its top the heading "IN THE UNITED STATES PATENT AND TRADEMARK OFFICE BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD". | TBMP § 311.01(a); EX | C |
| TTAB-HEAD-002 | The caption names the proceeding (parties and their roles) and the proceeding number ("Opposition No." or "Cancellation No."). | TBMP § 311.01(a), § 309.02(a); EX | C |
| TTAB-HEAD-003 | The caption identifies the application (serial number, mark, filing date, publication date) in an opposition, or the registration (number, mark, registration date) in a cancellation. | EX (*Sage*) | C |
| TTAB-HEAD-004 | The paper carries a title that states its nature ("ANSWER", "ANSWER AND COUNTERCLAIM", and so on), centered. | TBMP § 311.01(a) | C |

### The answer (37 C.F.R. § 2.106(b); FRCP 8(b))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TTAB-ANS-001 | The answer admits or denies each averment of the notice on which the opposer relies, in short and plain terms. | CFR § 2.106(b)(2); TBMP § 311.02(a) | M |
| TTAB-ANS-002 | Lack of knowledge or information sufficient to form a belief is stated as such and has the effect of a denial. | CFR § 2.106(b)(2); FRCP 8(b)(5) | M |
| TTAB-ANS-003 | A denial fairly meets the substance of the averment; if only part is denied, the true and material part is admitted and the remainder denied. A general denial is allowed only if the applicant in good faith controverts every averment. | CFR § 2.106(b)(2); FRCP 8(b)(2) to (4); TBMP § 311.02(a) | M |
| TTAB-ANS-004 | Responses are in numbered paragraphs that correspond to the numbered paragraphs of the notice. | TBMP § 311.02(a) | C |
| TTAB-ANS-005 | The answer does not argue the merits in the responses; argument goes in amplifications and defenses. | TBMP § 311.02(a) and n.1 | C |
| TTAB-ANS-006 | Anything not expressly admitted is denied (a closing or opening statement to that effect is customary). | FRCP 8(b)(3); EX | C |
| TTAB-ANS-007 | The paper follows the Federal Rules of Civil Procedure when it pleads a special matter (fraud: FRCP 9(b)). | CFR § 2.106(b)(2) | M |
| TTAB-ANS-008 | The answer is filed within the time the notice of institution sets, or as the Board resets it; otherwise the opposition may be decided as in case of default and all deadlines are tolled until that is resolved. | CFR §§ 2.105(a), 2.106(a); TBMP § 310.03 | M |

### Defenses and amplifications

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TTAB-DEF-001 | Affirmative defenses are stated simply and directly, with enough detail to give fair notice of the basis; an unpleaded defense cannot be relied on. | CFR § 2.106(b)(2); TBMP §§ 311.02(b)(1), 311.02(c) | M |
| TTAB-DEF-002 | Assertions that amplify a denial (for example, that the opposer's mark is weak) may be pleaded and are not affirmative defenses; they are not an attack on the pleaded registration. | TBMP § 311.02(d) and n.1 | C |
| TTAB-DEF-003 | A defense that the applicant is at least entitled to registration with a restriction is pleaded with the proposed restriction in detail, the allegation that it avoids a likelihood of confusion, and that the plaintiff does not use its mark on what the restriction excludes; the restriction itself is entered on motion under § 2.133 (or on the Board's finding under § 2.133(b)). | TBMP §§ 311.02(b)(1), 514.01; CFR § 2.133(a), (b); STAT § 1068 | M |
| TTAB-DEF-004 | Failure to state a claim may be pleaded in the answer. | TBMP § 311.02(b)(1) n.1; FRCP 12(b), (h)(2) | M |
| TTAB-DEF-005 | Evidentiary matter (lists of third-party registrations, quoted file histories) is a matter for proof, not for pleading; the template's samples plead only what gives fair notice. | TBMP § 311.02(b)(1) | C |
| TTAB-DEF-006 | A reply to an affirmative defense is not filed. | CFR § 2.106(b)(2); TBMP § 311.03 | M |
| TTAB-DEF-007 | Laches and acquiescence run in an opposition from publication and are severely limited; do not plead them without facts. | TBMP § 311.02(b)(1) | A |

### Counterclaim (37 C.F.R. §§ 2.106(b)(3), 2.111 to 2.115, 2.133(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TTAB-CC-001 | A defense attacking the validity of a registration pleaded in the opposition is a compulsory counterclaim if grounds exist when the answer is filed, and is pleaded with or as part of the answer; grounds learned later are pleaded promptly. | CFR § 2.106(b)(3)(i); TBMP § 313.04 | M |
| TTAB-CC-002 | An attack on a pleaded registration, including a request to restrict it, is not heard without a counterclaim or separate petition. | CFR §§ 2.106(b)(3)(ii), 2.133(d); TBMP § 309.03(d) | M |
| TTAB-CC-003 | The counterclaim is in form generally like a petition to cancel and identifies each registration it seeks to cancel or restrict; the counterclaimant need not plead entitlement to a statutory cause of action. | CFR § 2.112(a); TBMP § 313.03 | M |
| TTAB-CC-004 | The fee is the petition-to-cancel fee, per class and per counterclaimant, paid when the counterclaim is filed: $600 per class electronically ($700 on paper). Without the fee the counterclaim is not instituted. | CFR §§ 2.6(a)(16), 2.111(d); TBMP § 313.02 | M |
| TTAB-CC-005 | The counterclaim is filed electronically and served on every party, with proof of service. | CFR §§ 2.111(c), 2.114(b)(1), 2.119(a); TBMP §§ 313.03, 313.05 | M |
| TTAB-CC-006 | A restriction claim under Section 18 may be brought against a registration more than five years old because it is an equitable remedy and not an attack on validity; the claim must plead the specific restriction sought and that it avoids a likelihood of confusion. Grounds other than a restriction are limited by Section 14 after five years (nonuse under Section 14(6) after three years). Section 14's five-year period is tolled for a counterclaim only if the opposition was filed before the registration's fifth anniversary. | STAT §§ 1064, 1068; CFR § 2.111(b); TBMP §§ 309.03(d), 313.03 | M |
| TTAB-CC-007 | The Board sets at least 30 days to answer a counterclaim and resets the schedule as needed. | CFR § 2.106(b)(3)(iii), (iv); TBMP § 313.06 | M |

### Signature and service

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TTAB-SIG-001 | Every submission is signed by the party or its attorney or other authorized representative; an unsigned submission is not refused if a signed copy is supplied within the time the Board sets. An answer need not be verified. | CFR § 2.119(e); TBMP § 311.01(b) | M |
| TTAB-SIG-002 | An electronic signature is a combination of letters, numbers, spaces or punctuation the signer adopts, placed between two forward slashes and **personally entered by the signer**. | CFR § 2.193(a)(2), (c)(1) | M |
| TTAB-SIG-003 | The signer's first and last name and title or position are set out immediately below or adjacent to the signature, and the capacity in which the signer signs (attorney for applicant) is stated. | CFR § 2.193(d); TBMP § 311.01(a), (b) | M |
| TTAB-SIG-004 | Signing certifies the submission under 37 C.F.R. § 11.18(b); the signer is an "attorney" under § 11.1 or § 11.14. | CFR § 2.193(f) | M |
| TTAB-SERV-001 | The answer and the counterclaim are served on the opposer's attorney of record (or on the opposer if it has none), and proof of service appears on or is securely attached to the paper. | CFR § 2.119(a), (b); TBMP § 311.01(c) | M |
| TTAB-SERV-002 | Service is by email unless otherwise stipulated; another method only if email was attempted and could not be made, explained in the paper or an amended certificate. The Board's filing notice is not service. | CFR § 2.119(b); TBMP §§ 113.04, 311.01(c) | M |
| TTAB-SERV-003 | The certificate states the date and manner of service and, as TBMP asks, the name of each person served, with address and email address, and identifies the submission and proceeding if it is on a separate sheet. | CFR § 2.119(a); TBMP § 113.03 | M |
| TTAB-SERV-004 | The certificate is signed by the filing party or its attorney. | CFR § 2.119(a); TBMP § 113.03 | M |

### Filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| TTAB-FILE-001 | An answer (and a counterclaim) must be filed through the Board's electronic system; paper only if the system is unavailable or in extraordinary circumstances, with a petition to the Director and the fee. | CFR §§ 2.106(b)(1), 2.114(b)(1), 2.126; TBMP §§ 110.01, 311.01(c) | M |
| TTAB-FILE-002 | The filing date is the date of electronic receipt, Eastern Time. | CFR § 2.195(a); TBMP § 110.02 | M |
| TTAB-FILE-003 | A period that ends on a Saturday, Sunday or federal holiday in the District of Columbia ends on the next day that is not one. | CFR § 2.196 | M |
| TTAB-FILE-004 | Check which system takes the answer and the counterclaim on the day of filing (finding 1 above). | TBMP § 110.01; TTC | A |

### Tooling (project rules)

| ID | Requirement | Kind |
|---|---|---|
| TTAB-TOOL-001 | The template is content-agnostic: no case-specific text; the caption, signature block and certificate of service come only from the frontmatter. | T |
| TTAB-TOOL-002 | A paragraph that is entirely bold text beginning with "[" is a drafting note (for example "[CONFORM: ...]"). The typst and docx engines set it flush left, single-spaced and in italics so it can be found and deleted before filing. | T |
| TTAB-TOOL-003 | Numbered paragraphs are written as markdown ordered lists with an explicit starting number so that the numbers can match the notice. Text that begins with a markdown marker is escaped (`90\. `). | T |
| TTAB-TOOL-004 | Mechanical gates (content, rules, generalization) are not implemented for this court yet; only the review gate (`reviews/`) is. See `LOG.md`. | T |
