# Delaware Court of Chancery: filings

Alias `delch`. Scope: papers filed in the Court of Chancery of the State of Delaware (motions, briefs, letters, pleadings and orders). No court-root FILED-EXAMPLE exists and no public filed brief was found (see `usage/SOURCE.md`, if present; none was collected for this court), so this file is rules only.

## Sources

| Tag | Source | URL |
|---|---|---|
| CH-RULES | Rules of the Court of Chancery, full set (PDF titled "Full Set of Chancery Rules (6.1.2026)"; amendments effective June 1, 2026 shown in the index) | https://courts.delaware.gov/forms/download.aspx?id=160908 |
| CH-INDEX | Rules of the Delaware State Courts, Court of Chancery section (index of current rules and amendments) | https://courts.delaware.gov/rules/?ct=chan |

Verified against the Court of Chancery Rules, "Full Set of Chancery Rules (6.1.2026)" (Rule 10 history line: effective Sept. 25, 2023), on 2026-10-21. Rule 171 (Briefs) is repealed and its content moved to Rules 7 and 10.

## Form of filings (Rule 10)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DELCH-FORM-001 | Font: one of three conventions. (A) Times New Roman 14-point, with 13-point footnotes; (B) Century 12-point, with 11-point footnotes; (C) Century Schoolbook 12-point, with 11-point footnotes. A filing uses one convention throughout. | CH-RULES, Rule 10(b)(1). | M |
| DELCH-FORM-002 | Line spacing of text is at least twice the point size of the typeface (for example at least 28 points for 14-point Times New Roman). Headings, footnotes and block quotations may use exact point-size spacing. | CH-RULES, Rule 10(b)(2). | M |
| DELCH-FORM-003 | Margins are at least one inch on all sides. | CH-RULES, Rule 10(b)(3). | M |
| DELCH-FORM-004 | Paper is opaque and unglazed, measures 8 1/2 by 11 inches for briefs, motions, letters, compendia and appendices, and reproduces as a clear black image on white paper. Copies may be printed double-sided. | CH-RULES, Rule 10(e)(2)(A). | M |
| DELCH-FORM-005 | Briefs, compendia and appendices are bound securely so the text is not obscured and the document lies flat when open. Other filings may be bound or stapled. | CH-RULES, Rule 10(e)(3). | M |
| DELCH-CAP-001 | Every filing has a caption with the Court's name, the names of the parties, and the civil action number, and a title. A complaint names all parties in its caption; other papers name the first party on each side and may refer generally to others. | CH-RULES, Rule 10(a). | M |
| DELCH-CERT-001 | By signing, the signatory certifies compliance with Rule 10. The signature block of any motion, brief or letter states the applicable word limit and the number of words in the filing subject to that limit. | CH-RULES, Rule 10(d). | M |
| DELCH-CITE-001 | Citations and quotations follow the Uniform System of Citation (Bluebook) as modified by the Delaware Uniform Citation (Yellow Book). | CH-RULES, Rule 10(c). | M |
| DELCH-COPY-001 | A party may deliver two copies of a motion, brief or letter to the judicial officer, in addition to electronic filing. | CH-RULES, Rule 10(e)(1). | A |

## Pleadings, motions and letters (Rule 7)

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DELCH-CONT-001 | A written motion, opposition or reply contains numbered paragraphs. A brief may not contain numbered paragraphs. | CH-RULES, Rule 7(b)(2)(B), 7(c)(2)(C). | M |
| DELCH-CONT-002 | A written motion should attach a form of order providing the relief sought. | CH-RULES, Rule 7(b)(2)(C). | A |
| DELCH-LEN-001 | Word limits for written motions: a motion supported by an opening brief may not exceed 500 words; a motion not so supported may not exceed 3,000 words; an opposition may not exceed 3,000 words; a reply may not exceed 2,000 words. Other submissions containing argument need leave of Court. The caption, title, signature block and Rule 5.1(c) footer do not count. | CH-RULES, Rule 7(b)(3). | M |
| DELCH-LEN-002 | Word limits for briefs: an opening or answering brief may not exceed 14,000 words; a reply brief may not exceed 8,000 words. The front cover, table of contents, table of citations, signature block and Rule 5.1(c) footer do not count. | CH-RULES, Rule 7(c)(3). | M |
| DELCH-LEN-003 | A letter to the Court may not exceed 1,000 words. The letterhead, header, address and delivery information, caption, date, salutation, close, signature, enclosure and copy lines, and Rule 5.1(c) footer do not count. | CH-RULES, Rule 7(d)(3). | M |
| DELCH-CONT-003 | Only the following briefs may be filed unless the Court orders otherwise: opening, answering and reply briefs on a Rule 12, 23, 23.1, 41(b), 56 or 65 motion; briefs on settlement or fee applications under Rules 23, 23.1 or 23.2; pre-trial briefs; post-trial briefs. | CH-RULES, Rule 7(c)(1). | M |
| DELCH-CONT-004 | Letters: a letter from a lawyer is signed by a Delaware lawyer; a Delaware lawyer's letter may not merely transmit a non-Delaware lawyer's letter; a letter may not request relief other than by authorization of the Court. | CH-RULES, Rule 7(d)(1)-(2). | M |

## Briefs (Rule 7(c)(2))

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DELCH-COVER-001 | A brief cover page identifies the caption (as Rule 10 requires), the title of the brief, and the name, office address and telephone of the filing party or counsel. | CH-RULES, Rule 7(c)(2)(A). | M |
| DELCH-ORDER-001 | A brief contains, in this order and under headings: a table of contents with page references; a table of authorities with page references (cases alphabetically, then statutes, then other authorities); an introduction; in an opening or answering brief, a statement of facts with record references; an argument (divided into sections and subsections as needed); and a conclusion stating the relief sought. | CH-RULES, Rule 7(c)(2)(B). | M |

## Confidential information

| ID | Requirement | Source | Kind |
|---|---|---|---|
| DELCH-PUB-001 | Personal identifiers (social security numbers, complete financial account numbers, dates of birth, names of minor children) are omitted or redacted under Rule 5(k); filings with confidential information follow Rule 5.1(c). | CH-RULES, Rule 5.1(b)(3)(C), 5.1(c). | M |

## Template-only requirement

| ID | Requirement | Kind |
|---|---|---|
| DELCH-TOOL-001 | A reusable template contains no case-specific text, measured coordinates, or forced line breaks. | T |

## Notes for the template (not checked mechanically)

- Rule 10(b)(1) allows a 14-point Times New Roman convention, which is larger than the 12-point default. Any template using it needs an `eval.yaml` stating the size with a citation to Rule 10(b)(1) when a doc folder is built. A 12-point Century or Century Schoolbook convention is equally permitted; pick one per template and do not mix.
- Rule 7(b)(2)(C) (form of order) is advisory; a template need not add one.
