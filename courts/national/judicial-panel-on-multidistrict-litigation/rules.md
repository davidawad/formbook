# Judicial Panel on Multidistrict Litigation: rules

Alias `jpml`. Scope: case documents filed with the Panel by CM/ECF users, as built by `motion-brief/` (a motion to transfer under 28 U.S.C. § 1407 with its brief). Verified against primary sources on 2026-10-17.

Re-check cadence: whenever the Panel posts revised Rules on its Rules and Procedures page (https://www.jpml.uscourts.gov/rules-procedures; current: Rules effective February 19, 2026, with the signed adopting order and a redline of the December 2025 revision), and at least annually each October.

## Sources

| Tag | Source | URL |
|---|---|---|
| JR | Rules of Procedure of the United States Judicial Panel on Multidistrict Litigation, effective February 19, 2026 (22 pages). Page numbers are the Rules' printed page numbers. Fetched with the Panel's site as referer (the site rejects bare requests). | https://www.jpml.uscourts.gov/sites/jpml/files/Panel%20Rules%20Effective%202-19-2026.pdf |
| RP | Rules and Procedures page (lists the 2026 Rules, the adopting order, the redline, 28 U.S.C. § 1407, the FAQ) | https://www.jpml.uscourts.gov/rules-procedures |
| FRCP | Fed. R. Civ. P. 5.2 (privacy), applied to Panel filings by JR 3.2(e) | https://www.law.cornell.edu/rules/frcp/rule_5.2 |
| EX-* | Filed exemplars in `motion-brief/exemplars/` (see `SOURCE.md`) | local |

Kinds: **M** = mandated by a Panel Rule. **C** = convention (rules leave it open). **T** = project/tooling rule. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **Page limit, not word limit.** A brief with a motion, and a response, may not exceed 20 pages; a reply 10 pages (a consolidated reply to several responses, 20). Exhibits, tables of contents or authorities, and signature blocks are excluded (JR 3.2(a)(iii), 6.1(d)).
2. **Font rule is size only.** JR 3.2(a)(iv): "typed in size 12-point font (for both text and footnotes), double spaced (text only)". No typeface, no margin rule.
3. **No margins in the Rules.** The Panel Rules set none; the template's 1-inch margins are a convention.
4. **Contact block on the final page** of every case document (JR 3.2(a)(ii)).
5. **Proposed orders are not submitted** (JR 3.2(a)(vi)).

## Requirements

IDs are stable. The IDs already used in `motion-brief/README.md` (`JPML-FIRST-001`, `JPML-FORM-001` to `-003`, `JPML-LIMIT-001`, `JPML-SIG-001`, `JPML-MOT-001`, `JPML-XFER-001`, `JPML-SERV-001`) are kept with the same meaning. Never renumber; retire an ID by marking it `(withdrawn)`.

### Form of case documents (JR 3.2(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| JPML-FIRST-001 | Each case document bears the heading "Before the United States Judicial Panel on Multidistrict Litigation," the identification "MDL No.___" and the descriptive title designated by the Panel (or, if none yet, an appropriate description). | JR 3.2(a)(i), p. 3 | M |
| JPML-FORM-001 | Letter size (8 1/2 x 11 inch) with sequentially numbered pages. | JR 3.2(a)(iv), p. 3 | M |
| JPML-FORM-002 | "size 12-point font (for both text and footnotes)". No typeface is named. | JR 3.2(a)(iv), p. 3 | M |
| JPML-FORM-003 | "double spaced (text only)": body text double spaced; footnotes, headings, block quotations, captions, tables and signature blocks are not "text" and may be single spaced. Operational check: body baseline pitch at least 24 pt at 12 pt. | JR 3.2(a)(iv), p. 3 | M |
| JPML-FORM-004 | Each exhibit separately numbered and clearly identified. | JR 3.2(a)(v), p. 3; JR 6.1(b)(v), p. 8 | M |
| JPML-FORM-005 | Proposed Panel orders shall not be submitted. | JR 3.2(a)(vi), p. 3 | M |
| JPML-FORM-006 | Side margins of about 1 inch (page-3 text extents, 2026-10-17: left 77 pt and 72 pt) and a Times / Times New Roman face (embedded fonts). Not in the Rules. Seen in both filers (Chimicles Schwartz et al. for the Torres plaintiffs; USPlabs's counsel): convention. | EX-chevrolet-bolt, EX-usplabs | C |
| JPML-FORM-007 | Every font used is embedded and is the template's declared face. | project | T |
| JPML-FORM-008 | Privacy protections of Fed. R. Civ. P. 5.2 apply to all Panel filings. | JR 3.2(e), p. 4; FRCP 5.2 | A |

### Length (JR 3.2(a)(iii), 6.1(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| JPML-LIMIT-001 | Each brief submitted with a motion, and any response, does not exceed 20 pages, exclusive of exhibits, tables of contents or authorities, and signature blocks. | JR 3.2(a)(iii), p. 3 | M |
| JPML-LIMIT-002 | A reply does not exceed 10 pages and addresses arguments raised in the response(s); a consolidated reply to more than one response may run 20 pages. | JR 3.2(a)(iii), p. 3; JR 6.1(d), p. 8 | M |
| JPML-LIMIT-003 | Only the Clerk of the Panel may enlarge page limits; motions to exceed them are not granted absent exceptional circumstances. | JR 3.2(a)(iii); JR 6.1(e), p. 8 | A |

### Contents of a motion (JR 6.1(b), 6.2)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| JPML-MOT-001 | Every motion briefly describes the action or relief sought and includes a brief that concisely states the background of the litigation and the movant's factual and legal contentions. | JR 6.1(b)(i), p. 7 | M |
| JPML-MOT-002 | Every motion includes a numbered schedule of actions giving, for each action: the complete name (every party as on the district court docket, no "et al."), the district court and division, the civil action number, and the assigned judge if known. | JR 6.1(b)(ii), p. 7 | M (separate attachment) |
| JPML-MOT-003 | Every motion includes copies of all complaints and docket sheets for the scheduled actions, and exhibits identified by number or letter with a descriptive title. | JR 6.1(b)(iv), (v), p. 8 | M (separate attachment) |
| JPML-XFER-001 | A party to an action initiates a § 1407 transfer by filing a motion under these Rules; a notice of filing and schedule of actions is served on each district court where an affected action is pending. | JR 6.2(a), p. 8 | M |
| JPML-MOT-004 | An amendment to a transfer motion is titled "Amendment to Motion for Transfer" and, if it adds actions, carries a "Schedule of Additional Actions" and a revised proof of service. | JR 6.2(f), p. 9 | M (conditional) |
| JPML-MOT-005 | A nongovernmental corporate party files a corporate disclosure statement (parents and any publicly held corporation owning 10% or more, or a statement that there is none) within 14 days of the Notice of Filing. Separate filing. | JR 5.1, p. 7 | M (separate filing) |
| JPML-MOT-006 | Brief structure: table of contents and table of authorities, then sections such as Introduction / Background / Argument / Conclusion, headings numbered I., A., 1. Seen in the Torres plaintiffs' brief (EX-chevrolet-bolt) only; the USPlabs exemplar is a 3-page motion without a separate brief. One filer: style, not yet a convention. | EX-chevrolet-bolt | C (one filer) |

### Signature, service (JR 3.2(a)(ii), 3.2(b), 4.1)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| JPML-SIG-001 | The final page of each case document contains the name, address, telephone number and email address of the attorney or party designated to receive service, and the name of each party represented. | JR 3.2(a)(ii), p. 3 | M |
| JPML-SIG-002 | Counsel sign and verify case documents electronically; the electronically filed document is the signed original. | JR 3.2(b), p. 3 | M |
| JPML-SERV-001 | All case documents contain a proof of service on all parties not served electronically through CM/ECF, stating the name and manner of service (for an unrepresented party, name and last known address), and why any party named in a constituent complaint was not served. A motion's proof of service includes a service list naming each party on the docket sheet and complaint (first plaintiff "et al." if 25 or more plaintiffs share counsel). | JR 4.1(a), p. 6; JR 6.1(b)(iii), p. 8 | M |
| JPML-SERV-002 | The proof of service for a § 1407 transfer motion certifies that counsel transmitted a notice of filing and a schedule of actions to the clerk of each district court where an affected action is pending. | JR 4.1(b), p. 6 | M |

### Electronic filing (JR 3.2(b)-(d))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| JPML-ELEC-001 | Only attorneys identified under Rule 4.1 file case documents, as registered Panel CM/ECF users; documents are not sent directly to any Panel member. | JR 3.2(b)(i), (c), p. 3 | M |
| JPML-ELEC-002 | A courtesy paper copy, marked "Courtesy Copy-Do Not File", goes to the Clerk within 1 business day for any motion, response, reply or supplemental information with more than 100 pages of exhibits. | JR 3.2(d), p. 4 | M (conditional) |
| JPML-ELEC-003 | Text extracts on every page; fonts embedded. Not a Panel Rule; a project check. | project | T |
