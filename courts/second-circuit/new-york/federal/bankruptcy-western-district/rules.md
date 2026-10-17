# U.S. Bankruptcy Court, W.D. New York: rules

Alias `nywb`. Scope: papers filed through CM/ECF by counsel in the United States Bankruptcy Court for the Western District of New York; doc types `adversary-complaint` (complaint commencing an adversary proceeding) and `motion-brief` (motion with memorandum of law, and briefs on a motion). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (the usual effective date of Federal Rules of Bankruptcy Procedure amendments) and whenever the court posts amended Local Rules or Administrative Procedures on https://www.nywb.uscourts.gov/court-info/local-rules-and-orders.

## Sources

| Tag | Source (rule / version / effective date) | URL |
|---|---|---|
| LBR | W.D.N.Y. Local Rules of Bankruptcy Procedure, adopted effective May 13, 1997 (one-PDF version linked from the court's "Local Rules and Orders" page as current; PDF created 2013-08-14; 33 pages; sha256 4fee661037c8b2c546e6943dbd2ebdb5aff2f6a7c007b916d51b1cf1d33b5bcf). Rules 9004-1, 9004-2, 9004-3 at printed p. 19; 9013-1 at p. 21. | https://www.nywb.uscourts.gov/sites/nywb/files/Local%20Rules.pdf |
| LR-PAGE | Court page "Local Rules and Orders" (links LBR as "Local Rules as one PDF" and as individual rules) | https://www.nywb.uscourts.gov/court-info/local-rules-and-orders |
| ECF | "Amended Administrative Procedures for Filing, Signing and Verifying Pleadings and Papers Electronically", dated October 1, 2010 (Chief Judge Carl L. Bucki; PDF created 2011-10-28; 34 pages; sha256 6f48213babe094c29388f1042b3d4751234d02ffe7194dcb32f99b066634e2c9), linked from the court's "Administrative Procedures/Orders" page | https://www.nywb.uscourts.gov/sites/nywb/files/ECF_Administrative_Procedures_Oct_2010_update.pdf (page: https://www.nywb.uscourts.gov/administrative-procedures-and-orders) |
| FRBP-9004 | Fed. R. Bankr. P. 9004 (as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_9004 |
| FRBP-9011 | Fed. R. Bankr. P. 9011(a) (as amended, current text) | https://www.law.cornell.edu/rules/frbp/rule_9011 |
| FRBP-9013 | Fed. R. Bankr. P. 9013 (as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_9013 |
| FRBP-7008 | Fed. R. Bankr. P. 7008 (as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7008 |
| FRBP-7010 | Fed. R. Bankr. P. 7010 (as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7010 |
| FRBP-7007.1 | Fed. R. Bankr. P. 7007.1 (as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7007.1 |
| FRBP-7012 | Fed. R. Bankr. P. 7012(b) (as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7012 |
| FRBP-5005 | Fed. R. Bankr. P. 5005(a)(1) (as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_5005 |
| FRCP-10 | Fed. R. Civ. P. 10 (as amended Apr. 30, 2007, eff. Dec. 1, 2007), applied by FRBP 7010 | https://www.law.cornell.edu/rules/frcp/rule_10 |
| JUDGE | Chambers pages of Judge Timothy P. Lyster and Chief Judge Carl L. Bucki and the documents linked there that were fetched ("TPL Motion Scheduling aug 2026.pdf", "Negative Notice Procedures.pdf", "Calendar Practice Mayville NF Olean.pdf"); read for format rules, none found | https://www.nywb.uscourts.gov/content/judge-timothy-p-lyster, https://www.nywb.uscourts.gov/content/chief-judge-carl-l-bucki |
| EX-AC | Adversary-complaint exemplars, 3 filers (see `adversary-complaint/exemplars/SOURCE.md`): Wallach (Harter Secrest & Emery), Advisory Trust Group (Pachulski Stang Ziehl & Jones), Diocese of Rochester (Bond, Schoeneck & King; Blank Rome) | local |
| EX-MB | Motion-brief exemplars, 3 filers (see `motion-brief/exemplars/SOURCE.md`): Diocese of Rochester (Bond, Schoeneck & King), Official Committee of Unsecured Creditors (Pachulski Stang Ziehl & Jones), Continental Insurance (Barclay Damon; Crowell & Moring) | local |

Kinds: **M** = mandated by a court rule (Local Rule, the court's ECF Administrative Procedures, FRBP or an FRCP rule the FRBP applies). **C** = convention (the rules leave it open; taken from exemplars of different filers). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable.

Findings that differ from what many templates assume:

1. **No rule sets a typeface, type size, line spacing, margins or a page/word limit.** LBR 9004-1 requires only that papers be "plainly and legibly written, preferably typewritten, printed or reproduced" on "letter size paper". The FRBP has no counterpart of FRAP 32 or a district-court font rule. Font, size, spacing and margins are therefore conventions (C), from the exemplars.
2. **Judge's initial in the docket number.** LBR 9004-2 requires "the proper docket number or numbers, including the initial at the end of the number indicating the Judge to whom the matter has been assigned". Only two of the six exemplars do this on page 1 (Wallach `09-13438K`; Advisory Trust `20-20230 (PRW)`); the clerk still received the others (LBR 9004-3). The template must supply it.
3. **Consent statement in a complaint.** FRBP 7008 requires every complaint in a bankruptcy-court adversary proceeding to state whether the pleader does or does not consent to entry of final orders or judgment by the bankruptcy court. The 2011 Wallach complaint predates the 2016 amendment and lacks it; Advisory Trust (2022) has it (¶ 8); the 2019 Diocese complaint does not (no "consent" in its text layer).
4. **ECF file-size cap is 4 MB** per document (ECF § 6.B); there is no text-searchable-PDF requirement in the court's procedures.
5. **The local rules are old.** The current one-PDF LBR is the May 13, 1997 set (PDF created 2013). The individual-rules HTML pages on the court site returned "Request Rejected" (site firewall) for every page past the first when fetched on 2026-10-17; only the first page (rules 1001-1 to 2002-1) loaded, so the PDF is the text relied on here.

## Court-wide requirements

IDs are stable. Never renumber; retire an ID by marking it `(withdrawn)`.

### Form of papers

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWB-FORM-001 | Letter-size paper (8 1/2 x 11 in, 612 x 792 pt), exhibits excepted. LBR text: "except for exhibits, shall be on letter size paper, and fastened in durable covers". | LBR 9004-1 | M |
| NYWB-FORM-002 | Papers "shall be plainly and legibly written, preferably typewritten, printed or reproduced; shall be without erasures or interlineations materially defacing them; shall be in ink or its equivalent on durable, white paper of good quality". FRBP: a document "must be clearly legible". | LBR 9004-1; FRBP-9004 (a) | M |
| NYWB-FORM-003 | Font: **no rule names a typeface or size.** LBR 9004-1 says only "plainly and legibly written". Exemplars: body text about 12 pt by word-box height in five of six exemplars (all except the Committee's motion, whose word boxes are larger in its sans-serif face; size not determined). Faces split: Times family (Diocese memo, Diocese complaint, Continental reply) and Helvetica (Wallach, Advisory Trust, Committee). 12 pt is a convention; the face is each filer's style. | LBR 9004-1 (silent on font); EX-AC; EX-MB | C |
| NYWB-FORM-004 | Line spacing: no rule. All six exemplars set body text double-spaced (baseline pitch 27.5 to 27.6 pt at 12 pt type); block quotations, headings, caption, tables and signature blocks single-spaced. | EX-AC (3 filers); EX-MB (3 filers) | C |
| NYWB-FORM-005 | Margins: no rule. All six exemplars keep text within one inch left and right (text x from 72 pt to about 540 pt); ECF headers stamped by the court sit in the top margin. | EX-AC; EX-MB | C |
| NYWB-FORM-006 | Page numbers: no rule. All six exemplars number pages at the foot, centered, in arabic; the two memoranda with front matter (Diocese memo, Committee motion) number the TOC/TOA pages in lower-case roman. | EX-AC; EX-MB | C |
| NYWB-FORM-007 | Every font used is embedded and is the template's declared family (no fallback to a system font). | project rule (docs/EVAL-LOOP.md R3) | T |
| NYWB-FORM-008 | Papers not conforming to LBR 9004 are generally received by the clerk, but their effectiveness is subject to the court's determination; the clerk must not refuse a paper solely for form. | LBR 9004-3; FRBP-5005 (a)(1) | A |

### Caption and signature (the caption is this court's "cover"; IDs use COVER)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWB-COVER-001 | Caption with (1) the court's name, (2) the case's title, (3) the case number and, if appropriate, the adversary-proceeding number, (4) a brief designation of the document's character. | FRBP-9004 (b); LBR 9004-2 ("the name of the Court, the title of the case, the proper docket number or numbers ... and a description of their nature") | M |
| NYWB-COVER-002 | The docket number includes "the initial at the end of the number indicating the Judge to whom the matter has been assigned" (e.g. `09-13438K`, `20-20230 (PRW)`). | LBR 9004-2 | M |
| NYWB-COVER-003 | Caption layout: court name centered at the top in capitals; the bankruptcy case (`In re:` / debtor / `Debtor.`) above the adversary parties (`Plaintiff,` `v.` `Defendant.`) in a left column; `Chapter`, `Case No.` and `Adv. Proc. No.` in a right column; the document title centered in capitals below the caption. Seen in all six exemplars (rules, boxes and spacing of the caption vary by filer: tier 3). | EX-AC; EX-MB | C |
| NYWB-COVER-004 | Every paper (unless excepted under FRBP 9011) is dated, signed, and shows the name, address and telephone number of each attorney (or of the litigant if there is no attorney). FRBP: signed by at least one attorney of record in the attorney's individual name; states the signer's address and telephone number. | LBR 9004-2; FRBP-9011 (a) | M |
| NYWB-COVER-005 | An electronically filed paper indicates the original signature with an "/s/" signature and the date on which the signature was made (unless a scanned document shows the handwritten signature and date). | ECF § 4.C (pp. 10-11) | M |
| NYWB-COVER-006 | Signature block convention: `Dated:` (or `Date:`) line at the left, firm name, `/s/` signer, attorney names, address, telephone (e-mail where given), and "Counsel to/for <party>" in a right-hand block. Seen in all six exemplars. | EX-AC; EX-MB | C |

### Electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWB-ELEC-001 | Registered participants must file electronically through ECF, and "electronically filed documents must be in Portable Document Format ('PDF')". | ECF § 3.A.1 (p. 5) | M |
| NYWB-ELEC-002 | The ECF system "will not allow the filing of documents larger than four megabytes (4mb)"; larger attachments must be split into separate PDF files. | ECF § 6.B (p. 12) | M |
| NYWB-ELEC-003 | Personal identifiers protected by FRBP 9037 and the Judicial Conference privacy guidelines must be redacted before filing. | ECF § 3.A.2 (pp. 5-6) | A |
| NYWB-ELEC-004 | A proposed order is never placed in the body of a pleading; it is a separate document ("DO NOT ELECTRONICALLY FILE A PLEADING THAT CONTAINS A PROPOSED ORDER IN THE BODY OF THE PLEADING"). The template generates no proposed order. | ECF § 8.B (p. 13) | M |
| NYWB-ELEC-005 | Text layer: no court rule requires a text-searchable PDF (the ECF procedures recommend 300 ppi when scanning paper, § 6.C). The template emits text, not images (project rule). | ECF § 6.C; project | T |

Not verified (not written as M): judge-specific briefing or page-limit rules (none found in the JUDGE pages and documents fetched; other chambers documents were not read); Official Form 416 caption versions (FRBP 7010 refers to them; the form itself was not fetched); the adversary proceeding cover sheet (Form B1040) requirement (ECF § 6.A says only that "Cover sheets are considered attachments"; the uscourts.gov form URL tried returned 404).

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWB-CONT-001 | Caption substantially conforms to the appropriate version of Official Form 416 (FRBP 7010); FRCP 10(a) through FRBP 7010: the title of the complaint names all the parties. | FRBP-7010; FRCP-10 (a) | M |
| NYWB-CONT-002 | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim on a separate transaction or occurrence in a separate count when that promotes clarity. | FRCP-10 (b), via FRBP-7010 | M |
| NYWB-CONT-003 | The allegation of jurisdiction includes a reference to the name, number and Code chapter of the case the adversary proceeding relates to and the district and division where it is pending. | FRBP-7008 | M (content: A) |
| NYWB-CONT-004 | The complaint states whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. | FRBP-7008 | M (content: A) |
| NYWB-CONT-005 | A nongovernmental corporate party (other than the debtor) files a corporate ownership statement with its first pleading. A separate filing; not part of the template. | FRBP-7007.1 (a), (b) | A |
| NYWB-CONT-006 | Structure convention: unnumbered lead-in ("... alleges as follows:"); centered section headings (nature of the action / jurisdiction and venue / parties / background or facts); counts headed as counts or claims for relief; a `WHEREFORE` prayer for relief with lettered or numbered items; signature block. Seen in all three complaint exemplars (Wallach, Advisory Trust, Diocese). | EX-AC | C |
| NYWB-CONT-007 | No table of contents or certificate of service inside the complaint (none of the three exemplars has either; service of the summons and complaint is proved separately). | EX-AC | C |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| NYWB-CONT-101 | A request for an order is made by written motion (unless an application is authorized or the request is made at a hearing); the motion states its grounds with particularity and sets forth the relief or order requested. | FRBP-9013 (a), (b) | M (content: A) |
| NYWB-CONT-102 | Notices of motion with supporting affidavits and memoranda are served and filed at least five days before the return date (eight if served by mail), unless a rule or order provides otherwise. Timing, not layout. | LBR 9013-1(B) (p. 21) | A |
| NYWB-LEN-101 | Length: **no page or word limit** for motions or memoranda was found in the LBR, the ECF procedures or the JUDGE documents fetched. No length check is mandated. | LBR; ECF; JUDGE (silent) | C |
| NYWB-CONT-103 | Front matter: a table of contents (with page references and dot leaders) and a table of authorities precede the body in the two longer briefs (Diocese memo, 32 pp.; Committee motion, 24 pp.); the 17-page Continental reply has neither. A convention for longer briefs, not a rule. | EX-MB | C |
| NYWB-CONT-104 | Body convention: an introduction or preliminary statement, background, argument with roman-numeral point headings and lettered sub-points, a conclusion stating the relief requested (Continental: a `WHEREFORE` paragraph), then the signature block. Seen across the three motion-brief filers. | EX-MB | C |
| NYWB-CONT-105 | In an adversary proceeding, a responsive pleading must state whether the party consents to entry of final orders or judgment (applies to answers, not to the motion brief itself). | FRBP-7012 (b) | A |
