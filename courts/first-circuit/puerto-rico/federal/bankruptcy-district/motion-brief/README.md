# Motion brief (memorandum of law): United States Bankruptcy Court, D. Puerto Rico (`prb`)

Doc type: memorandum of law supporting a motion, combined in one paper with the motion (LBR 9013-2(a) allows the memorandum and the motion to be a single document). The sample is an amended motion for summary judgment in an adversary proceeding. Templated: the caption, the title, the lead-in, unnumbered body paragraphs with footnotes, headings, block quotations, the response-time notice, the certificate of service, and the signature block.

## Rules

Local rules text: the court's "Local Bankruptcy Rules" compilation (PRLBRs-2013, https://www.prb.uscourts.gov/sites/default/files/local_rules/PRLBRs-2013_Complete_0.pdf, fetched 2026-10-14; 2013 compilation as posted, so later amendments may not be reflected). LBR 9013-1 is taken from General Order 18-02 (June 19, 2018, https://www.prb.uscourts.gov/sites/default/files/general-ordes/GO_18-02_9013-1.pdf, fetched 2026-10-14), which supersedes the 2013 text of LBR 9013-1. Federal rule text: Cornell LII (fetched 2026-10-14).

| Rule | Requirement | Where in the template |
|---|---|---|
| LBR 9013-2(a) | Any motion must be accompanied by a supporting memorandum with the points and authorities, and must refer to the specific provisions of the Code, the Rules, the LBRs and/or other controlling authority. The memorandum may be combined with the motion. | The body: headings, citations, footnotes (the sample's citations are the exemplar's). Content is not checked. |
| LBR 9013-2(b) | Listed motions (extension, hearing request, adding creditors, amending schedules, stipulated motions, definite statement, informative motions) need no memorandum. | Not applicable: the template is for a motion that needs one. |
| LBR 9013-1(c)(1) (GO 18-02) | An initial motion carries the response-time notice, in single or double space, in at least 11 point type, with language substantially similar to the rule's text. | `response-notice()`: the rule's text, with the period from `response_days`; 12 pt body type, single spaced. |
| LBR 9013-1(c)(2) (GO 18-02) | Periods: 14 days by default; 21 days for a motion to compromise, a notice of intended sale, or a motion to modify a plan after confirmation; 30 days for a motion to dismiss a chapter 7, 12 or 13 case. | `response-periods`: the template accepts 14, 21 or 30 and asserts the value. See gap 1. |
| LBR 9013-1(a), (b) | Urgent and ex parte motions have their own certification and notice requirements. | Not templated (a different document: the urgent-motion certification). |
| LBR 1005-1(a) | Case name, number, judge's initials and chapter on every paper. | `caption()`: `bankruptcy_case` ("11-03499 (MCF)", with the judge's initials) and `chapter` are asserted present. |
| LBR 1005-1(b) | Every document is a pdf measuring 8 1/2 x 11 inches. | `page-w`, `page-h`: US Letter. |
| LBR 1005-1(c) | Signature block: name, mailing address, email, telephone and facsimile numbers; for an attorney, the firm, the client and the bar admission number. | `signature-block()`: `signer`, `lines`; asserted present. See gap 3. |
| LBR 1005-1(d) | An amendment states in bold print that it is an amendment. | The title is bold; the sample's title begins "AMENDED". |
| LBR 5005-4(b)(2)(C)(ii) | The electronic signature is the filer's name preceded by "/s/". | `signature-block()`: prints "/s/ " before the signer. |
| LBR 9013-3(a) (2013 compilation) | The certificate of service states how and when service was made, names and addresses of all persons served, and the name and address of the person certifying. | `certificate-of-service()`: the frontmatter `certificate` text. Not generated from a list of parties. See gap 4. |
| FRBP 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004, fetched 2026-10-14) | A document's caption sets out the court, the case title, the case and adversary numbers, and a designation of the document. | `caption()` and `cover()`. |
| Typeface (fonts pass, 2026-10-14) | Face required: **none named** in the PR bankruptcy LBRs (2013 compilation and GO 18-02; no typeface or size clause found). LBR 1001-1(b) falls back to the District Court's local civil rules for matters not covered; their Local Rule 10 text was not retrieved, so this is OPEN. L.Cv.R. 7(e) (via LBR 1001-1(b), `../rules.md` Finding 2) asks no less than 12 points. The template sets **Times New Roman** 12 pt (Liberation Serif its metric twin), the house standard and the face of the Oriental Bank exemplar (`data/exemplar-fonts.json`), on typst and docx alike (fb-595.68.17). | `font-family` in `prb-motion-brief.typ`. |

## What the overlay shows

`usage/OVERLAY-perez-cruz-msj.pdf` (red: our render; blue: the filed exemplar; black: both agree) and `.txt` (page map). Pages pair by text: ours p.1-8 -> filed p.1, 2, 4, 5, 6, 7, 8, 9. Filed p.3 is not the best match for any of our pages, so it is unpaired in the map. The exemplar is 10 pages and the render is 8. The sample transcribes the whole memorandum and notice, so the difference is in face and spacing, not omitted text. Layout is not a line-for-line match, so the overlay is a text-content comparison.

## Known gaps

1. **Response period (LBR 9013-1(c)).** The exemplar's notice says 30 days ("If within thirty (30) days ..."). LBR 9013-1(c)(2) gives 30 days only for a motion to dismiss a chapter 7, 12 or 13 case; a motion for summary judgment is not on the list, so the default 14 days applies. The sample's frontmatter sets `response_days: 14`, which departs from the exemplar on purpose. The exemplar's notice also says "stipulation" where the rule text says "paper"; the template uses the rule's wording. This departure is for David to confirm.
2. **Block quotations.** The 11 U.S.C. § 524(a) quotation's clauses (1) and (2) are on separate lines in the exemplar; the render runs them together because markdown line breaks inside a blockquote are soft breaks. Readable, but not the filed layout.
3. **Signature block (LBR 1005-1(c)).** The rule asks for the facsimile number and the client's name. The sample has neither a fax number nor the client's name (the exemplar's block has neither). Reproduced as filed; for David to decide.
4. **Certificate of service (LBR 9013-3(a)).** The certificate is the exemplar's text. It names counsel for plaintiff, the chapter 13 trustee and the U.S. Trustee's office, and gives the first-class mail address for plaintiff's counsel; it does not list every party served. Not checked against the case's docket of parties.
5. **Not templated (separate papers, or not in the exemplar):** the notice of motion and hearing date, any certification or declaration (the exemplar relies on a separate statement of uncontested facts at Dk. No. 28), the proposed order, and the urgent-motion certification (LBR 9013-1(a)(1)).
6. **Table of contents and table of authorities.** None is generated and the LBR 9013-2 text checked does not require one. Judges' preferences are not checked.
7. **Typeface.** No PR bankruptcy rule names a typeface. The template uses Times New Roman 12 pt on both engines, the face of the Oriental Bank exemplar (`FILED-EXAMPLE-motion-brief-3.pdf`, per the font audit).
8. **Second exemplar not collected.** `usage/SOURCE.md` records that the only other PR bankruptcy motion-with-memorandum found was a PROMESA district-court filing, which does not match this folder. Tier 2 is judged against one filer. This is OPEN.
9. **Footnote numbering.** Footnotes are written as `[^n]` markers with `[^n]:` definitions in the sample; typst numbers them in order of appearance, so the sample's numbers must run in order. A footnote marker inside bold or italic text would split the formatting; none is in the sample.

## Gate 2 review

Re-done 2026-10-22 on the cross-engine renders (fb-595.68.17), typst and docx, every page of both samples (9 and 9) rasterized and viewed:

- Page 1: court lines, the caption (parties ruled at the right and below, a rule under the debtor; case, chapter and adversary numbers at the right), the bold title, "TO THE HONORABLE COURT:", the lead-in, section I with footnote 1 at the foot. Pass.
- Pages 2-7 (msj) / 2-8 (osj): body paragraphs, footnotes 2-5 at the foot of the pages that mark them (footnote 4 runs over from page 6 to 7 in the msj, on both engines), headings at the margin (sub-point "a. V. Conclusion" in bold italic), the § 524(a) and *Morales* quotations single-spaced half an inch in on both sides. Pass as layout; the 524(a) line breaks are gap 2.
- Pages 8-9: the WHEREFORE paragraph, the NOTICE (rule text, 14 days), the certificate of service, "Respectfully submitted," the date and the `/s/` block at 3 in. Pass as layout; the period and signature lines are gaps 1 and 3.
- OPEN (sample, for David): the osj body carries its own "NOTICE OF RESPONSE TIME" and "(single) " paragraphs, printed as written, so the osj shows two notices on both engines.

## Engines

Both engines are on the shared cross-engine layout model (lib/typst/xengine.typ, lib/docx/xengine.lua; docs/EVAL-LOOP.md): Times New Roman 12 pt, exact 24 pt double pitch for the body and headings, 13.8 pt single lines for the court lines, caption, title, notice, quotations, footnotes and signature, ragged right, no hyphenation; `eval.yaml` sets `params.cross_engine: gate`, and the docx breaks every line and page as typst on both samples (XENG-001..003).

docx: `docx/reference.xml` (base="xengine", the face only as `{font}`; Footnote Text without keepLines so a note splits across a page as in typst; Body Text Note without widow control for a paragraph that marks a footnote) replaces `build-reference.sh` and the committed EB Garamond `reference.docx`; `docx/prb-motion-brief.lua` writes the court lines, the caption table, the title, the lead-in, the headings, the NOTICE, the certificate of service (when the frontmatter has one) and the signature block; body paragraphs, quotations (Block Text) and footnotes are pandoc's, numbered through the document (the old reference restarted them, DEF-CONT-001). The typst `note-clearance` (7.5 pt) makes the space above the footnote rule LibreOffice's. Checked on `usage/OUTPUT-motion-brief.docx.pdf` and `usage/OUTPUT-motion-brief-2.docx.pdf` (LibreOffice); Word was not checked.

BLOCKED: none.
