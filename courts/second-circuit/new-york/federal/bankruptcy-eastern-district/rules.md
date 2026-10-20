# U.S. Bankruptcy Court, E.D. New York: rules

Alias `nyeb`. Scope: papers filed through CM/ECF in a bankruptcy case or adversary proceeding in the United States Bankruptcy Court for the Eastern District of New York, by counsel. Court-wide rules first, then one section per doc-type folder (`adversary-complaint/`, `motion-brief/`). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (when amended Federal Rules of Bankruptcy Procedure take effect) and whenever the court posts amended Local Bankruptcy Rules, a new or amended General Order on electronic filing, or revised Judges' Procedures.

## Sources

Every requirement below cites one of these. LBR page numbers are the printed page numbers of the LBR PDF.

| Tag | Source | URL |
|---|---|---|
| LBR | "Local Bankruptcy Rules for the Eastern District of New York", effective December 13, 2019, "Amended September 17, 2026 (to update cover page only)" (cover text); 91 pages; PDF ModDate 2026-09-21; sha256 `fe410ff86562cb6fb4263b5973322733f33a4fcef28f695a1f9af951bfa87056`. Linked from the court's Local Bankruptcy Rules page (https://www.nyeb.uscourts.gov/local-bankruptcy-rules-united-states-bankruptcy-court-eastern-district-new-york). | https://www.nyeb.uscourts.gov/sites/nyeb/files/USBC-EDNY-Local-Bankruptcy-Rules.pdf |
| GO559 | General Order No. 559, "Electronic Means for Filing, Signing and Verification of Documents", Amended March 18, 2016 (Electronic Filing Procedures applicable to all bankruptcy cases and adversary proceedings), 10 pages; sha256 `4c9fbfef60f17f29b0c8424d9b2bbaf7b4b005c29d16b0e25f3771cf23005ed1`. Named as the court's electronic filing procedures on the Judges' Procedures page (section 4) and the Electronic Filing Procedures page (https://www.nyeb.uscourts.gov/electronic-filing-procedures). | https://www.nyeb.uscourts.gov/sites/nyeb/files/general-ordes/ord_559_0.pdf |
| JP | "Judges' Procedures" (court web page; printable PDF https://www.nyeb.uscourts.gov/sites/nyeb/files/Judges_Uniform_Procedures.pdf, 7 pages, PDF ModDate 2025-09-12, sha256 `2fbe3a98754dc18850d8743924086e88c450506c2736e7d9c33420566de5797c`). LBR 1001-1(b)(iii) makes individual chambers rules part of the court's procedures. | https://www.nyeb.uscourts.gov/judges-procedures |
| FRBP | Federal Rules of Bankruptcy Procedure, as restyled eff. Dec. 1, 2024: Rules 7001, 7003, 7007, 7007.1, 7008, 7010, 7012, 9004, 9011, 9013, 9037 (LII text) | https://www.law.cornell.edu/rules/frbp/rule_9004 (and `rule_7001`, `rule_7003`, `rule_7007`, `rule_7007.1`, `rule_7008`, `rule_7010`, `rule_7012`, `rule_9011`, `rule_9013`, `rule_9037`) |
| FRCP | Federal Rules of Civil Procedure 7, 8, 10, applied in adversary proceedings by FRBP 7007, 7008, 7010 (LII text) | https://www.law.cornell.edu/rules/frcp/rule_10 (and `rule_7`, `rule_8`) |
| F416D | Official Form 416D (12/15), "Caption for Use in Adversary Proceeding" | https://www.uscourts.gov/sites/default/files/form_b416d_0.pdf |
| EX-TOY | `adversary-complaint/usage/FILED-EXAMPLE-adversary-complaint.pdf` (Toyvation, LLC, by Solomon Rosengarten). Visual reference only. | local; see that folder's `SOURCE.md` |
| EX-WIL | `motion-brief/usage/FILED-EXAMPLE-motion-brief.pdf` (Brooklyn Masonic Temple LLC, by Williams LLP). Visual reference only. | local; see that folder's `SOURCE.md` |
| EX-SCH | `motion-brief/usage/FILED-EXAMPLE-motion-brief-2.pdf` (Israel Schaya, by Forchelli Deegan Terrana LLP; a reply in support of a Rule 2004 motion, In re Toyvation LLC, ECF Doc. 16). Visual reference only. | local; see that folder's `SOURCE.md` |
| EX-TVS | `adversary-complaint/usage/FILED-EXAMPLE-adversary-complaint-2.pdf` (Trump Village Section 4, Inc. and Igor Oberman, by Daniel S. Szalkiewicz / Veridian Legal P.C.; Adv. Pro. No. 1-26-01071-ess, ECF Doc. 1). Visual reference only. | local; see that folder's `SOURCE.md` |

Kinds: **M** = mandated by a court rule (FRBP, FRCP as incorporated, E.D.N.Y. LBR, General Order, Judges' Procedures). **C** = convention (the rules leave it open; taken from the exemplars). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable (content the lawyer must supply).

Findings that differ from what many templates assume:

1. **No font, type size, margin or line-spacing rule.** LBR 9004-1 ("Papers -- Requirements of Form") requires only that papers be "plainly typed, printed, or copied", without material erasures or interlineations, signed, and "on 8 1/2'' x 11'' paper". FRBP 9004(a) requires only that a document "must be clearly legible". GO559 and JP add nothing on typography. Every font, size, margin and spacing choice is therefore C.
2. **No page or word limit for a memorandum of law or a complaint.** The only length limits found are two-page letters: a letter requesting a conference (JP section 5(c)) and a letter requesting a summary-judgment pre-motion conference (LBR 7056-1(a)).
3. **The memorandum of law is a separate ECF filing.** LBR 5005-1(b)(iii) and GO559 II.A.5: everything that forms part of a motion may be filed under one docket number "except for a memorandum of law", which "shall be filed separately and shall indicate the motion or pleading to which it relates."
4. **Return date in the caption.** LBR 9004-2(c): "The return date and time of a motion shall be included in the upper right hand corner of the caption of the motion and all related papers." The memorandum is a related paper. Neither measured motion paper (EX-WIL, EX-SCH) shows one.
5. **Judge code.** LBR 9004-2(a): after the petition, all papers include "the case number and the Judge code" (e.g. the `-ess` / `-ESS` suffix, present in all four measured exemplars).
6. **Electronic signature form.** LBR 9011-1(b): "An electronic signature shall consist of "s/" followed by the first and last name of the person signing." All four measured exemplars sign "/s/ Name" (EX-TVS "/s/Daniel Szalkiewicz"), which contains the required "s/" form.

## Court-wide requirements

IDs are stable. `checks.yaml` references them. Never renumber; retire an ID by marking it `(withdrawn)`.

### Page form

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYEB-FORM-001 | Papers filed "shall be on 8 1/2'' x 11'' paper" (612 x 792 pt on every page). | LBR 9004-1(a)(ii), LBR p. 67 | M |
| NYEB-FORM-002 | Papers filed shall "be plainly typed, printed, or copied" and "have no erasures or interlineations which materially deface them". Check: text layer present on every page (see NYEB-ELEC-006). | LBR 9004-1(a)(i)(A)-(B), LBR p. 67 | M |
| NYEB-FORM-003 | A document "must be clearly legible. Commonly used English abbreviations are acceptable." | FRBP 9004(a) | M |
| NYEB-FORM-004 | Font and type size: **no rule.** LBR 9004-1, LBR 9004-2, GO559 and JP name no typeface or size. Convention seen in all four measured exemplars: 12 pt body text (EX-TOY Times-family 12 pt; EX-TVS and EX-SCH Times New Roman 12 pt; EX-WIL Arial Narrow at about 12.5 pt). A Times-family serif face is seen in three of the four filers (EX-TOY, EX-TVS, EX-SCH); EX-WIL is sans (that filer's style). | rules silent; EX-TOY, EX-TVS, EX-SCH, EX-WIL | C |
| NYEB-FORM-005 | Margins: **no rule.** All four measured exemplars use a 1 inch left margin (text from 72 pt); EX-SCH body lines end about 1 inch from the right edge. The template uses 1 inch on all sides. | rules silent; EX-TOY, EX-TVS, EX-SCH, EX-WIL | C |
| NYEB-FORM-006 | Line spacing: **no rule.** All four measured exemplars double-space the body (EX-TOY, EX-TVS and EX-SCH about 27.5 pt baseline pitch at 12 pt; EX-WIL about 30 pt) and single-space the caption, counsel block, block quotations and signature block. | rules silent; EX-TOY, EX-TVS, EX-SCH, EX-WIL | C |
| NYEB-FORM-007 | Paper copies "shall not be stapled or otherwise bound on the side". Paper only; not applicable to the electronic PDF. | LBR 9004-1(a)(ii), LBR p. 67 | M (paper only) |
| NYEB-FORM-008 | Page numbers: **no rule.** Three of the four measured exemplars (EX-TOY, EX-SCH, EX-WIL) number pages at the foot, centred, in Arabic numerals; EX-TVS has no page numbers. The template numbers pages (centred foot). | rules silent; EX-TOY, EX-SCH, EX-WIL; EX-TVS (none) | C |
| NYEB-FORM-009 | Every font used is embedded, and every embedded font is the template's declared family (no silent fallback to a system font). | project | T |
| NYEB-FORM-010 | An amendment filed as of right or by order "shall be filed in a form that is complete, including exhibits, and shall not incorporate by reference any prior paper." | LBR 9004-1(b), LBR p. 67 | A (M for the filer) |

### Caption

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYEB-COVER-001 | Every paper has a caption stating "United States Bankruptcy Court, Eastern District of New York" (the court's name). | LBR 9004-2(a), LBR p. 67; FRBP 9004(b)(1) | M |
| NYEB-COVER-002 | The caption includes the title and chapter of the case (the case's title). | LBR 9004-2(a); FRBP 9004(b)(2) | M |
| NYEB-COVER-003 | After the petition is filed, the caption includes the case number and the Judge code. | LBR 9004-2(a); FRBP 9004(b)(3) | M |
| NYEB-COVER-004 | In an adversary proceeding, every paper also contains the full title of the lawsuit and the adversary proceeding case number. | LBR 9004-2(a); FRBP 9004(b)(3) ("if appropriate, adversary-proceeding number") | M |
| NYEB-COVER-005 | The caption contains "a brief designation of the document's character" (the document title). | FRBP 9004(b)(4) | M |
| NYEB-COVER-006 | In consolidated cases, the lead case's docket number is listed first, followed by the docket numbers of all consolidated cases in ascending order. | LBR 9004-2(b), LBR p. 68 | M (conditional) |
| NYEB-COVER-007 | "The return date and time of a motion shall be included in the upper right hand corner of the caption of the motion and all related papers." | LBR 9004-2(c), LBR p. 68 | M (motion papers) |
| NYEB-COVER-008 | Caption layout: court name in capitals (centred in EX-TOY, EX-SCH, EX-WIL; left in EX-TVS) above a ruled caption block; the `In re` debtor block at left with case number and chapter at right; in an adversary proceeding, the parties block below it with the adversary number at right; the title below or at right. Seen in all four measured exemplars (EX-TOY and EX-SCH dashed rules ending in "X"; EX-WIL solid rules; EX-TVS a solid ruled box). | EX-TOY, EX-TVS, EX-SCH, EX-WIL; F416D layout | C |

### Signature

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYEB-CERT-001 | Every pleading, written motion and other document is signed by at least one attorney of record in the attorney's individual name (or by the unrepresented party), and states the signer's address and telephone number, if any. | FRBP 9011(a); LBR 9004-1(a)(i)(C) | M |
| NYEB-CERT-002 | "The name of the attorney or party pro se shall be printed or typed below the signature." | LBR 9011-1(a), LBR p. 69 | M |
| NYEB-CERT-003 | Signature block: "Dated:" with the date at left and the signer's "/s/" block at right, with name, address and telephone. Seen in all four measured exemplars (EX-TOY "Dated:" with no place; EX-WIL "Dated: New York, New York"; EX-SCH "Dated: Uniondale, New York"; EX-TVS "Dated: April 14, 2026 / New York, New York"). "Respectfully submitted," is EX-WIL only; a firm "By:" block is EX-WIL, EX-SCH and EX-TVS. | EX-TOY, EX-SCH, EX-WIL | C |

### Electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYEB-ELEC-001 | All motions, pleadings, memoranda of law, exhibits and other documents are filed by electronic means (except papers under seal under LBR 9018-1). | LBR 5005-1(b)(i), LBR p. 45; GO559 II.A.1 | M |
| NYEB-ELEC-002 | An electronically filed document that must be signed carries an electronic signature or a scanned original signature. "An electronic signature shall consist of "s/" followed by the first and last name of the person signing." The filer keeps the original for two years after the final order closing the case. | LBR 9011-1(b), LBR p. 69; GO559 II.C.1-2 | M |
| NYEB-ELEC-003 | Documents forming part of one motion or pleading, filed at the same time by the same party, may share one docket number, except a memorandum of law, which "shall be filed separately and shall indicate the motion or pleading to which it relates." | LBR 5005-1(b)(iii), LBR p. 46; GO559 II.A.5 | M |
| NYEB-ELEC-004 | Exhibits not in electronic form: relevant excerpts are scanned and filed, identified as excerpts, "shall not exceed 20 pages", and state that the entire document is in the filer's possession and available on request. | LBR 5005-1(b)(iv), LBR p. 46; GO559 II.A.6 | M (conditional) |
| NYEB-ELEC-005 | Filed documents comply with FRBP 9037 (redaction of personal identifiers); redaction is solely the filer's responsibility. | LBR 9037-1(a)-(b), LBR p. 83; GO559 II.D; FRBP 9037 | A (M for the filer) |
| NYEB-ELEC-006 | PDF produced from the source (typst / LaTeX / Word), not scanned: text extracts on every page and fonts are embedded. No E.D.N.Y. rule read requires a text-searchable PDF; this is a project rule supporting NYEB-FORM-002 and -003. | project | T |
| NYEB-ELEC-007 | Chambers copy: where the Judge's procedures require one, a paper copy of each document filed is marked "Chambers Copy" and delivered to the Clerk no later than the day after filing. JP section 6: Judge Stong requires chambers copies for motions and supporting documents in adversary proceedings; Judge Giugliano requires two sets for those and for all memoranda of law. Paper only; the template does not print the legend. | LBR 9004-1(c), LBR p. 67; JP section 6 | M (paper only, judge-specific) |
| NYEB-ELEC-008 | The ECF header stamped by the court ("Case ... Doc ... Filed ... Entered ...") sits in the top margin of every exemplar page; the template keeps the top margin free of text. | EX-TOY, EX-TVS, EX-SCH, EX-WIL | C |

Not verified (no rule found in LBR, GO559 or JP, so nothing is asserted as M): a maximum PDF file size, PDF/A, bookmarks, a font or size, margins, line spacing, page numbering, a table of contents or authorities.

## Doc type: adversary-complaint

The complaint that commences an adversary proceeding (FRBP 7001, 7003; FRCP 3). The summons, the adversary proceeding cover sheet, the filing fee and the corporate ownership statement are separate papers.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYEB-CONT-001 | The proceeding is one listed in FRBP 7001 (e.g. to recover money or property, to determine the validity, priority or extent of a lien). Scope only. | FRBP 7001 | A |
| NYEB-COVER-101 | The pleading's caption "must substantially conform to the appropriate version of Form 416" (for an adversary proceeding, Official Form 416D: court, `In re` debtor, Case No., Chapter, plaintiff, defendant, Adv. Proc. No., "COMPLAINT [or other designation]"). | FRBP 7010; F416D | M |
| NYEB-COVER-102 | Every pleading has a caption with the court's name, a title, a file number, and a Rule 7(a) designation ("Complaint"); the title of the complaint must name all the parties. | FRCP 10(a), applied by FRBP 7010 | M |
| NYEB-CONT-002 | Claims are stated "in numbered paragraphs, each limited as far as practicable to a single set of circumstances". | FRCP 10(b), applied by FRBP 7010 | M |
| NYEB-CONT-003 | If doing so would promote clarity, each claim founded on a separate transaction or occurrence is stated in a separate count. The template supports count headings ("FIRST CAUSE OF ACTION", ...), as EX-TOY uses; EX-TVS states one claim under one centred heading. | FRCP 10(b); EX-TOY, EX-TVS | M (conditional); C (heading form) |
| NYEB-CONT-004 | The complaint contains (1) a short and plain statement of the grounds for the court's jurisdiction, (2) a short and plain statement of the claim, (3) a demand for the relief sought. | FRCP 8(a), applied by FRBP 7008 | M (sections); A (content) |
| NYEB-CONT-005 | The jurisdiction allegation "must include a reference to the name, number, and Code chapter of the case that the adversary proceeding relates to and the district and division where it is pending." | FRBP 7008 | A (M for the filer) |
| NYEB-CONT-006 | The complaint "must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court." Neither measured complaint contains such a statement (EX-TOY and EX-TVS text searched for "consent" and "final order"); the template must not copy that omission. | FRBP 7008 | M |
| NYEB-CONT-007 | A demand for relief ("WHEREFORE ...") followed by the signature block. Seen in both measured complaints (EX-TOY lettered prayer items; EX-TVS a "PRAYER FOR RELIEF" heading and one WHEREFORE paragraph with numbered items run in). | FRCP 8(a)(3); EX-TOY, EX-TVS | M (demand); C (form) |
| NYEB-CERT-101 | A nongovernmental corporate party other than the debtor files a corporate ownership statement with its first appearance, pleading or motion; E.D.N.Y. extends this to a party that is a general or limited partnership or joint venture. Separate paper; not produced by the template. | FRBP 7007.1(a)-(b); LBR 7007.1-1, LBR p. 57 | M (separate paper) |
| NYEB-LEN-101 | Length: no page or word limit found for a complaint. | rules silent | M (none) |

Tier-2 notes: two filers measured (EX-TOY: Solomon Rosengarten; EX-TVS: Daniel S. Szalkiewicz / Veridian Legal P.C.). Common to both (convention): Times-family 12 pt, double-spaced body, numbered paragraphs, centred capital headings, "-against-" between the parties, "Dated:" at left with the "/s/" signer block at right. Seen in one filer only (that filer's style): no counsel block and centred court name (EX-TOY); counsel block at top left, ruled caption box, no page numbers, left-aligned court name, paragraph number indented 0.5 in with wrapped lines returning to the margin (EX-TVS); paragraph number at the margin with a hanging indent (EX-TOY). Neither filed copy shows an adversary number (EX-TVS leaves "Adversary Case No." blank); the template follows LBR 9004-2(a) (NYEB-COVER-004).

## Doc type: motion-brief

The memorandum of law in support of (or in opposition to) a motion, in an adversary proceeding or contested matter. The notice of motion, the motion itself, the proposed order and the proof of service are separate papers.

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYEB-CONT-201 | A motion is in writing (unless made at a hearing) and states its grounds with particularity and the relief or order requested. | FRBP 9013(a)-(b); FRCP 7(b)(1), applied by FRBP 7007 | M |
| NYEB-CONT-202 | A motion "shall specify the rules and statutory provisions upon which it is based and the legal authorities that support the requested relief, either in the motion or in a separate memorandum of law, and the factual grounds for relief." Failure may be grounds to strike or deny. | LBR 9013-1(a), LBR p. 69 | M (A for content) |
| NYEB-CONT-203 | A response states the factual grounds on which relief is opposed and the supporting legal authorities, in the response or in a separate memorandum of law. | LBR 9013-1(b), LBR p. 70 | M (A for content) |
| NYEB-COVER-201 | "The rules governing captions and other matters of form in pleadings apply to motions and other papers." The memorandum carries the full caption (NYEB-COVER-001 to -005), including the adversary title and number when filed in an adversary proceeding. | FRCP 7(b)(2), applied by FRBP 7007; LBR 9004-2(a) | M |
| NYEB-COVER-202 | Return date and time of the motion in the upper right corner of the caption (the memorandum is a related paper). See NYEB-COVER-007. | LBR 9004-2(c), LBR p. 68 | M |
| NYEB-COVER-203 | Counsel's name, address and telephone block at the top left of page 1, above the court name. Seen in both measured motion papers (EX-WIL, EX-SCH). | EX-WIL, EX-SCH | C |
| NYEB-ELEC-201 | The memorandum is filed as its own ECF entry and indicates the motion it relates to. See NYEB-ELEC-003. | LBR 5005-1(b)(iii); GO559 II.A.5 | M |
| NYEB-CERT-201 | A motion is accompanied by a proposed order; notice goes to every entity with or claiming an interest; motions are filed with proof of service (unless by order to show cause or LBR 9077-1 scheduling). Separate papers; not produced by the template. | LBR 9013-1(c)-(e), LBR p. 70 | M (separate papers) |
| NYEB-CONT-204 | A summary-judgment motion requires a prior pre-motion conference request by letter not exceeding two pages, and a separate statement of material facts. A discovery motion requires a good-faith-conference affidavit or affirmation and a prior conference request. Separate papers. | LBR 7056-1(a), (c), LBR p. 63; LBR 7007-1, LBR p. 57 | M (conditional, separate papers) |
| NYEB-CONT-205 | Timing: motion papers served at least 14 days before the hearing, answering papers received at least 7 days before, reply papers served and filed at least 3 days before; motions and answering papers filed no later than the day after service. | LBR 9006-1(a)-(b), LBR p. 68-69 | A |
| NYEB-LEN-201 | Length: no page or word limit for a memorandum of law found in LBR, GO559 or JP. | rules silent | M (none) |
| NYEB-CONT-206 | Table of contents / table of authorities: not required by any rule read. Neither measured motion paper has one (EX-WIL 13 pages, EX-SCH 6 pages). | rules silent; EX-WIL, EX-SCH | C |
| NYEB-CONT-207 | Top-level headings centred in bold capitals (ARGUMENT, CONCLUSION) in both measured motion papers; a CONCLUSION stating the relief before the signature in both. The section set "Preliminary Statement, Factual Background, Legal Standard, Argument" and lettered argument headings are EX-WIL only; numbered paragraphs, run-in argument subheadings and a "TO: THE HONORABLE ..." line are EX-SCH only (each filer's style). | EX-WIL, EX-SCH | C |

Tier-2 notes: two filers measured (EX-WIL: Williams LLP, Arial Narrow body, matter number "22376.3" at the foot; EX-SCH: Forchelli Deegan Terrana LLP, Times New Roman body). EX-SCH is a reply brief in a contested matter, not an opening memorandum in an adversary proceeding, so its caption has no adversary block; choices seen in only one of the two are that filer's style.

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| NYEB-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| NYEB-TOOL-002 | The template contains no case-specific text and no measured coordinates; the same template renders any conforming sample. | T |
| NYEB-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |
