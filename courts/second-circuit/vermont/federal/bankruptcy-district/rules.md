# United States Bankruptcy Court, District of Vermont: rules

Alias `vtb`. Scope: papers filed through CM/ECF by counsel in the United States Bankruptcy Court for the District of Vermont, for the doc types in this folder: `adversary-complaint` (a complaint commencing an adversary proceeding, Fed. R. Bankr. P. 7001, 7003) and `motion-brief` (a motion under Fed. R. Bankr. P. 9013 with its memorandum of law in the same document). Verified against primary sources on 2026-10-17.

Re-check cadence: re-check annually each December 1 (the national rules' effective date and the date of the court's last local-rules revision, "Revised 12/1/24") and whenever the court posts amended Local Bankruptcy Rules or the District Court amends its Local Rule 10.

## Sources

| Tag | Source (rule / version / effective date) | URL |
|---|---|---|
| LBR | Vermont Local Bankruptcy Rules, "2024 Local Bankruptcy Rules", every page footed "Revised 12/1/24" (PDF created 2024-12-03; sha256 c02cd77a4a3a92fcc4ea31a51053b292aa051ba822716d6f42e14ad2aa4ee01c). Page numbers below are the footer's "Page N of 88". | https://www.vtb.uscourts.gov/sites/vtb/files/2024%20Local%20Rules%20Revised%2012.1.24.pdf |
| LBR-PAGE | Court's Local Rules page (lists the 2024 Local Bankruptcy Rules as current, with the District Court approval, the summary of revisions and the appendices) | https://www.vtb.uscourts.gov/local-rules |
| DVT | Local Rules of Procedure, U.S. District Court for the District of Vermont, edition dated "April 20, 2026" (60 pages; sha256 8048666fab25b6a7f9e35bd7fd8f486cca1041c9d5d047fd81c89338630300fa). Incorporated for format by LBR 5005-1(a). See "Not verified" note 1 on how this copy was obtained. | https://www.vtd.uscourts.gov/sites/vtd/files/LocalRules-20260420.pdf |
| ECF | "U.S. Bankruptcy Court, District of Vermont, Attorney Registration and Basic Instructions", "Updated 3/2025" (12 pages; sha256 007e2a1d21fb00c06481ed35676137ffae91c7db4e5c6fe5673ac06f5682746c) | https://www.vtb.uscourts.gov/sites/vtb/files/March%202025%20Attorney%20CMECF%20Instructions.pdf |
| FRBP | Federal Rules of Bankruptcy Procedure 7003, 7007.1, 7008, 7010, 9004, 9011, 9013 (each as amended Apr. 2, 2024, eff. Dec. 1, 2024) | https://www.law.cornell.edu/rules/frbp/rule_7003 , .../rule_7007.1 , .../rule_7008 , .../rule_7010 , .../rule_9004 , .../rule_9011 , .../rule_9013 |
| FRCP | Fed. R. Civ. P. 10 (applies through FRBP 7010) and Fed. R. Civ. P. 8(a) (applies through FRBP 7008). Rule 8 was read from the copy of the LII page cached the same day by the `vtd` agent (`/work/artifacts/rules-cache/vtd/frcp_8.html`). | https://www.law.cornell.edu/rules/frcp/rule_10 , https://www.law.cornell.edu/rules/frcp/rule_8 |
| EX-AC | Adversary-complaint exemplars (see `adversary-complaint/exemplars/SOURCE.md`): (1) Fouracre, by the Law Offices of Todd Taylor, Adv. 23-01001; (2) Official Committee of Unsecured Creditors, by Lemery Greisler and Pachulski Stang Ziehl & Jones, Adv. 26-01005; (3) Springfield Medical Care Systems, by Bernstein Shur, Adv. 20-01004. Visual reference only. | local |
| EX-MB | Motion-brief exemplars (see `motion-brief/exemplars/SOURCE.md`): (1) Roman Catholic Diocese of Burlington, by Fredrikson & Byron and Obuchowski Law Office, Adv. 26-01005 Doc. 11; (2) the Parish Defendants, by Gfeller Laurie LLP, Adv. 26-01005 Doc. 13. Visual reference only. | local |

Kinds: **M** = mandated by a court rule (FRBP, FRCP as incorporated, Vt. LBR, or D. Vt. L.R. as incorporated). **C** = convention (the rules leave it open; taken from exemplars of different filers). **T** = project/tooling rule of this repo. **A** = author responsibility, not machine-checkable (content the lawyer must supply).

## Findings

1. **The 2024 rules replaced the format list.** The doc-type READMEs were written against the 2021 edition (Vt. LBR 5005-1(a)(1)-(8): 3/4 inch margins, page numbers centered at the bottom, 1.5 or 2.0 spacing, 1.0 or 1.15 for quotations and footnotes). The current LBR 5005-1(a) (LBR p. 59) reads: "The District of Vermont Local Rule 10(a) applies to the format of filings and attachments. All electronically filed documents must be filed in portable document format (PDF)." D. Vt. L.R. 10(a) sets **1 inch** margins, **double spacing except quoted material**, and "consecutively numbered" pages with no position stated. The 2021 rows in the READMEs are superseded; the ones below govern.
2. **No typeface is named for filings.** D. Vt. L.R. 10(a)(4) says only "be no less than 12 point font". LBR 1007-3(c)(1) names "Arial, CG Times, Courier, or Times New Roman", but for **mailing lists only**. The face is therefore a convention (VTB-FORM-009), not a rule.
3. **Abrogated local rules.** LBR 7005-1 (certificate of service, adversary), LBR 7008-1 (core/non-core designation; "Abrogated. See Bankruptcy Rule 7008."), LBR 7056-2 (summary-judgment memoranda) and LBR 9004-2 (caption) are all "Abrogated" in the 2024 edition. The READMEs' LBR 7008-1 and 7005-1 rows are replaced by FRBP 7008 and LBR 9013-6.
4. **FRBP 7008 (eff. Dec. 1, 2024) no longer asks for a core/non-core statement**; it requires the jurisdiction allegation to name the bankruptcy case (name, number, Code chapter, district and division) and a statement whether the pleader does or does not consent to final orders or judgment by the bankruptcy court.
5. **LBR 5005-1 is phrased "should comply"** ("Documents and attachments filed in this Court ... should comply with the following presentation criteria"), but its sub-rules (b) and (c) use "must", and D. Vt. L.R. 10(a) uses "must". The rows are treated as M.

## Court-wide requirements

### Page form (LBR 5005-1(a), D. Vt. L.R. 10(a))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTB-FORM-001 | Every page is 8 1/2 x 11 inch (612 x 792 pt). D. Vt. L.R. 10(a)(1): "be of 8 ½ x 11 inch size". | D. Vt. L.R. 10(a)(1), DVT p. 7, via LBR 5005-1(a), LBR p. 59 | M |
| VTB-FORM-002 | Margins at least 1 inch. D. Vt. L.R. 10(a)(3): "have at least 1 inch margins". The rule states no exception for page numbers; the court's CM/ECF header stamp ("Case ... Doc ... Filed ... Entered ...") is applied in the top margin of every page (seen on all exemplars), so nothing of ours may sit there. | D. Vt. L.R. 10(a)(3), via LBR 5005-1(a); EX-AC, EX-MB for the stamp | M |
| VTB-FORM-003 | Type size: D. Vt. L.R. 10(a)(4): "be no less than 12 point font". No typeface is named. Applied to all text including footnotes (the rule states no footnote exemption). | D. Vt. L.R. 10(a)(4), via LBR 5005-1(a) | M |
| VTB-FORM-004 | Spacing: D. Vt. L.R. 10(a)(6): "be double-spaced, except for quoted material". Operational definition: baseline-to-baseline distance in body paragraphs at least twice the type size (24 pt at 12 pt). Quoted material may be single-spaced. The rule gives no exemption for footnotes, headings or the caption; see VTB-FORM-010 for the convention. | D. Vt. L.R. 10(a)(6), via LBR 5005-1(a) | M |
| VTB-FORM-005 | Pages consecutively numbered. D. Vt. L.R. 10(a)(5): "be consecutively numbered". Position is not stated (see VTB-FORM-011). | D. Vt. L.R. 10(a)(5), via LBR 5005-1(a) | M |
| VTB-FORM-006 | Plainly legible. D. Vt. L.R. 10(a)(2): "be plainly legible, whether keyed, typed, handwritten, or duplicated"; FRBP 9004(a): "must be clearly legible". | D. Vt. L.R. 10(a)(2); FRBP 9004(a) | M |
| VTB-FORM-007 | Footnotes used sparingly. D. Vt. L.R. 10(a)(7): "use footnotes sparingly". | D. Vt. L.R. 10(a)(7), via LBR 5005-1(a) | A |
| VTB-FORM-008 | Every font used is embedded and is the template's declared family (no silent fallback to a system font). | project; supports VTB-ELEC-001 | T |
| VTB-FORM-009 | Typeface: Times New Roman (a proportionally spaced serif) at 12 pt is the body face of four of the five filers (EX-AC 2, 3; EX-MB 1, 2); Fouracre (EX-AC 1) mixes Arial Narrow and Times New Roman. The rule names no face, so the template may use any legible proportional serif face at 12 pt or larger (the repo's vendored face). | EX-AC, EX-MB; Finding 2 | C |
| VTB-FORM-010 | Caption, headings, block quotations, footnotes and the signature block single-spaced; body double-spaced at 24 to 28 pt. Seen across filers: caption and signature block single-spaced in all five; footnotes single-spaced at the foot of the page (EX-MB 1, 2). | EX-AC, EX-MB | C |
| VTB-FORM-011 | Page number at the bottom of the page, centered (EX-AC 3; EX-MB 2; EX-AC 1 prints "-1-" centered). Arabic numerals from 1 on the first page. | EX-AC, EX-MB | C |

### Caption and identification (FRBP 9004(b), LBR 1005-1, LBR 5005-1(b), (c))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTB-COVER-001 | Caption sets forth: (1) the court's name; (2) the case's title; (3) the case number and, if appropriate, the adversary-proceeding number; (4) a brief designation of the document's character. | FRBP 9004(b) | M |
| VTB-COVER-002 | The caption includes the debtor's full name as stated on the petition and the chapter under which the case is currently pending; the case number; a title describing the filing's contents and/or the relief sought; and the name of the party on whose behalf it is filed. LBR 5005-1(c)(6) adds the title, role, or function in the case of all persons named in the document. | LBR 5005-1(c)(1)-(4), (6), LBR p. 59 | M |
| VTB-COVER-003 | "All documents filed in the case must contain a caption identical to that of the petition." Any SSN or other identifying number only in redacted form (last four digits). | LBR 1005-1, LBR p. 8 | M (A for identity with the petition) |
| VTB-COVER-004 | Caption layout seen across filers: "UNITED STATES BANKRUPTCY COURT" and "DISTRICT OF VERMONT" (EX-MB 1 and EX-AC 1 write "FOR THE DISTRICT OF VERMONT") centered at the top; an "In re" block with the debtor and "Debtor." on the left, case number and chapter on the right; below it the adversary block (plaintiff, "v.", defendants with their designations) on the left and the adversary number on the right; the document title below the caption, centered and in capitals (EX-AC 1, 3; EX-MB 1). The Committee (EX-AC 2) puts the title in the right column and a counsel block above the court name: that filer's style. | EX-AC, EX-MB | C |

### Signature and attorney identification

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTB-CERT-001 | The attorney's name, current office address, e-mail address, telephone number, and the name of the party the attorney is representing appear below the signature line of all filings. | LBR 5005-1(b), LBR p. 59 | M |
| VTB-CERT-002 | Signed by at least one attorney of record in the attorney's individual name; states the signer's address and telephone number. A CM/ECF electronic signature is the attorney's signature. Exemplars show "/s/ Name" on the signature line (all five filers). | FRBP 9011(a); LBR 9011-4(a), (b), LBR p. 74; EX-AC, EX-MB for "/s/" | M ("/s/" form C) |
| VTB-CERT-003 | Signatures of more than one party on one document follow one of the LBR 9011-4(d) procedures; consent filed within two business days. | LBR 9011-4(d), LBR pp. 74-75 | A |
| VTB-CERT-004 | Signature block in the right half of the page, with a date line before it (EX-AC 2, 3; EX-MB 2) or at its left on the signature line (EX-MB 1). | EX-AC, EX-MB | C |

### Electronic filing

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTB-ELEC-001 | "All electronically filed documents must be filed in portable document format (PDF)." Attachments in CM/ECF must be PDF. The rules state no searchable-text or size requirement; the template produces text-based PDF with embedded fonts (VTB-FORM-008). | LBR 5005-1(a), LBR p. 59; ECF p. 10 | M (PDF) |
| VTB-ELEC-002 | Supporting papers (notice of motion, proposed order, certificate of service) are uploaded as attachments to the main document in one docket entry (the court's "preferred method"). | ECF p. 10 ("Filing Documents with Additional Attachments") | C |

## Doc type: adversary-complaint

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTB-CONT-001 | Caption substantially conforms to the appropriate version of Official Form 416 (FRBP 7010); the title of the complaint names all the parties (FRCP 10(a)). | FRBP 7010; FRCP 10(a) | M |
| VTB-CONT-002 | Claims stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances; each claim founded on a separate transaction or occurrence in a separate count where that promotes clarity. All three exemplars number paragraphs consecutively from 1 and group counts under headings. | FRCP 10(b), via FRBP 7010; EX-AC 1-3 | M |
| VTB-CONT-003 | The jurisdiction allegation (FRCP 8, via FRBP 7008) includes the name, number, and Code chapter of the bankruptcy case the proceeding relates to and the district and division where it is pending. | FRBP 7008 | M (A for content) |
| VTB-CONT-004 | The complaint states whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. | FRBP 7008 | M (A for content) |
| VTB-CONT-005 | A demand for the relief sought (FRCP 8(a)(3), via FRBP 7008), placed after the counts and before the signature (a "WHEREFORE" or "Relief Requested" section in all three exemplars). | FRBP 7008 (FRCP 8 applies); EX-AC 1-3 | M (presence); C (placement, heading) |
| VTB-CONT-006 | Section headings for jurisdiction/venue, parties, facts and each count, centered, in capitals or bold, in all three filers (EX-AC 1 "A. The Parties"; EX-AC 2 "INTRODUCTION", "THE PARTIES"; EX-AC 3 "JURISDICTION AND VENUE"). | EX-AC 1-3 | C |
| VTB-CONT-007 | Separate papers, not part of the complaint: the summons (issued by the Clerk; served conventionally under FRBP 7004, not electronically) and the order on pre-trial deadlines served with it; a nongovernmental corporate party's FRBP 7007.1 corporate ownership statement. The template does not produce them. | LBR 7004-2, LBR p. 69; LBR 7016-1(a), LBR p. 70; FRBP 7007.1 | A |
| VTB-CONT-008 | No proposed order is required with a pleading initiating an adversary proceeding. | LBR 9072-1(a), LBR p. 87 | M (exemption) |
| VTB-CONT-009 | An amended complaint reproduces the entire pleading and is filed with a clean copy and a redlined version. | LBR 7007-1, LBR p. 69 | A |
| VTB-LEN-001 | No page or word limit for a complaint in the LBR or FRBP. | LBR (none found); FRBP | M (none) |

## Doc type: motion-brief

| ID | Requirement | Source | Kind |
|---|---|---|---|
| VTB-CONT-101 | A request for an order is made by written motion that states its grounds with particularity and sets forth the relief or order requested. | FRBP 9013(a), (b) | M (A for content) |
| VTB-CONT-102 | The motion (1) states with particularity the relevant law (by title and section) and/or procedure (by rule) relied on, (2) clearly describes all relief requested, and (3) includes a brief summary of the facts and circumstances supporting the relief. | LBR 9013-1(a), LBR p. 75 | M (A for content) |
| VTB-CONT-103 | The movant certifies they contacted opposing counsel (or the unrepresented opposing party) and made a good-faith attempt at resolution before filing, or acknowledges they did not, sets forth good cause, and requests a waiver. Neither exemplar shows this certification in its text layer (a finding against those filings, not a convention). | LBR 9013-1(b), LBR p. 75; EX-MB 1, 2 | M |
| VTB-CONT-104 | A motion and its supporting memorandum of law may be one document only if the movant includes both in the caption and the docket entry (e.g. "Motion to Dismiss and Supporting Memorandum of Law", EX-MB 2). EX-MB 1's title names only the motion. | LBR 9013-5(a), LBR p. 80; EX-MB 2 | M |
| VTB-CONT-105 | A stipulated motion includes the word "stipulated" in its title and a statement of consent in the body; consent is evidenced by signature or filed within two business days. | LBR 9013-1(f)(1), (2), LBR pp. 75-76 | M |
| VTB-CONT-106 | A motion seeking expedited relief or relief on shortened notice states why expedited relief is needed and why the movant did not seek relief earlier. | LBR 9013-1(g), LBR p. 76 | M (conditional) |
| VTB-CONT-107 | Each motion (except a stipulated motion) includes a proposed order, filed as an attachment to the motion and served with it. The template does not produce it. | LBR 9013-1(h), LBR p. 76; LBR 9072-1(a), (b), LBR p. 87 | M (separate paper) |
| VTB-CONT-108 | Affidavit filed in support when the relief requires a finding of fact or resolving a factual dispute; exhibits filed electronically, excerpts where lengthy. | LBR 9013-1(c), (d), LBR p. 75; LBR 5005-1(d) | A |
| VTB-CONT-109 | A notice of motion is filed and served before or with the motion, and a certificate of service covering both is filed, attached to the motion when filed at the same time. Service through CM/ECF may use the LBR 9013-6(e) form of certificate. The template does not produce these papers. | LBR 9013-6(a), (b), (e), LBR pp. 81-82 | M (separate papers) |
| VTB-CONT-110 | Summary-judgment motions: a separate short and concise statement of undisputed material facts and a memorandum of law; each pleading specifies whether oral argument is requested. | LBR 7056-1(a)(1), (b)(2), LBR p. 72 | M (conditional) |
| VTB-CONT-111 | Memorandum organized under headings with a concluding section stating the relief (both exemplars: introduction, jurisdiction or background, legal standard, argument headings, conclusion). EX-MB 1 numbers its paragraphs; EX-MB 2 does not (each filer's style). | EX-MB 1, 2 | C |
| VTB-LEN-101 | A memorandum of law is succinct and does not exceed 15 pages without prior leave of the Court; it includes a concise statement in support of each argument with relevant citations, and is part of, or an attachment to, a motion. The rule does not say which pages count; the template reports the page count of the whole combined document. | LBR 9013-5(b)(1)-(4), LBR pp. 80-81 | M |
| VTB-LEN-102 | A reply memorandum may not exceed 5 pages, and a sur-reply 3 pages, without prior leave. (Not the motion-brief doc type, recorded for reuse.) | LBR 9013-5(b), LBR p. 81 | M |
| VTB-LEN-103 | Citations not generally available on Westlaw or Lexis: a copy is provided to opposing parties and the Court. | LBR 9013-5(b), LBR p. 81 | A |

## Template-only requirements

| ID | Requirement | Kind |
|---|---|---|
| VTB-TOOL-001 | Every word of the markdown body appears in the PDF text, in order. | T |
| VTB-TOOL-002 | The template contains no case-specific text and no measured coordinates. | T |
| VTB-TOOL-003 | Each markdown italic span renders in an italic face. | T |
| VTB-REVIEW-001 | A recorded visual review of the current PDF covers every page and lists no open defect (docs/EVAL-LOOP.md, Gate 2). | T |

## Not verified

1. **D. Vt. Local Rules copy.** www.vtd.uscourts.gov returned "Request Rejected" (HTTP 404 from the site's firewall) to every request from this box on 2026-10-17, including the PDF URL above. The text of D. Vt. L.R. 10(a) was read from a copy of `LocalRules-20260420.pdf` fetched earlier the same day from that URL by the agent working the sibling court (`vtd`) and cached in `/work/artifacts/rules-cache/vtd/`; the sha256 above is of that file. The court's own landing page linking it was in that cache (`lr-page.html`). Re-fetch directly before release.
2. **District Court approval and summary of the 2024 LBR** (`USBC.LocalRules.Approval.2024.pdf`, `Summary of Local Rule Changes 1.1.24.pdf`, linked from LBR-PAGE) were rejected by the firewall; the effective date of the 2024 LBR is therefore taken only from the footer "Revised 12/1/24".
3. **Official Form 416** text was not read in this pass; VTB-CONT-001 relies on FRBP 7010's reference to it. The "Not verified" status does not change the M kind of FRBP 7010 itself.
4. No PDF size limit or text-searchability rule was found in the LBR or the ECF instructions; none is written as M.
