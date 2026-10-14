# W.D. Mo. Bankruptcy: motion brief (mowb)

Doc type: **motion-brief**, the memorandum of law that supports a motion in an adversary proceeding in the United States Bankruptcy Court for the Western District of Missouri (Kansas City). Folder: `courts/eighth-circuit/missouri/federal/bankruptcy-western-district/motion-brief/`.

The exemplars are *separate* memoranda filed with a motion to dismiss (the motion itself, the grounds in short form, is a different filing). The template therefore produces the memorandum: caption, title, argument with headings, signature and certificate of service. The motion, its proposed order and any supporting summary are not generated (see "Not produced" below).

| Item | Status |
|---|---|
| exemplar | yes, 2 filers: `exemplars/FILED-EXAMPLE-barnhart-13-04184-motion-brief.pdf` (4 pp, MOHELA, 2014) and `exemplars/FILED-EXAMPLE-lewallen-05-05013-motion-brief.pdf` (5 pp, Green Tree Servicing and U.S. Bank, 2005). See `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-barnhart-mohela-memorandum.md` (the whole memorandum, 4 pages) |
| render | ok: `samples/OUTPUT-barnhart-mohela-memorandum.pdf`, 4 pages, typst 0.15.0, EB Garamond only (vendored), no warnings |
| typeface | no face named by the court's rules (checked 2026-10-14); EB Garamond kept, per `docs/FONTS.md` rule 3 |
| overlay | fail (2026-10-14): `tools/overlay.sh` cannot run, because `exemplars/` holds only `SOURCE.md` and the filed PDF is not in this snapshot. The `OVERLAY-barnhart-mohela-memorandum.txt` shown is from the earlier run; no `.pdf` overlay exists. |
| pages reviewed | 4 of 4 (every page of the 2026-10-14 render rasterized at 60 dpi and viewed) |

File names follow `tools/render.sh` and `tools/overlay.sh` (`INPUT-`, `OUTPUT-`, `OVERLAY-`). The overlay tool writes `OVERLAY-<id>.pdf`; it does not write `<id>-overlay.pdf`.

## Governing rules

Primary sources. Fetched 2026-10-14.

| ID | Rule | Requirement | Where it lives in the template |
|---|---|---|---|
| MOWB-MB-001 | W.D. Mo. Bankr. L.R. 9013-1(A) (2012 text, see gap 1) | "Motions shall be in writing unless made in open court and shall state with particularity grounds for the relief requested." The motion is the separate filing; the memorandum must be consistent with it. | Not checked by the template (the motion is not generated). |
| MOWB-MB-002 | W.D. Mo. Bankr. L.R. 9013-1(B) (2012 text) | Affidavits and other pertinent documents relied on for facts outside the record: no more than 5 pages may be filed with the motion; longer material is summarized on the Local Form MOW 9040-1.1 summary, and copies go to opposing counsel. | Not generated. The exemplars cite the complaint paragraphs, not affidavits. |
| MOWB-MB-003 | W.D. Mo. Bankr. L.R. 9013-1(C) (2012 text) | A response, and any memorandum of authority, is due within 21 days after service of the motion. | Not generated (a timing rule, not a layout rule). |
| MOWB-MB-004 | W.D. Mo. Bankr. L.R. 9013-1(E) (2012 text) | Failure of the movant to file a supporting memorandum waives the right to file one. | Why the memorandum is filed with the motion; not a layout rule. |
| MOWB-MB-005 | Fed. R. Bankr. P. 9004(a)-(b) (Cornell LII) | Papers must be "clearly legible"; a caption with the name of the court, the title of the case, the bankruptcy docket number, and a brief designation of the paper. | `court`, `title`, `adv_number`. |
| MOWB-MB-006 | W.D. Mo. Bankr. L.R. 17004-1(A) (2012 text) | Adversary captions carry the debtor's name, case number, chapter and judge assignment, plus the plaintiff, the defendant, the adversary case number, and the judge. | `debtor`, `case_number`, `chapter`, `judge`, `plaintiffs`, `defendants`, `adv_number`. |
| MOWB-MB-007 | W.D. Mo. Bankr. L.R. 9011-4 (2012 text) | Attorney signature in the attorney's individual name with: name, bar number, firm name, address, telephone, fax, and e-mail. | `signature` (all fields required). |
| MOWB-MB-008 | W.D. Mo. Bankr. L.R. 9013-3 (2012 text) | "Each pleading shall have a signed certificate of service at the end of the pleading or on a separate, captioned certificate, stating: the manner and date of service, and each person served." A pleading without a proper certificate may be stricken or denied. | `certificate` (date and manner required). Each person served is given by the manner text (CM/ECF notice to registered parties). |

Not produced by this template (separate filings, not part of the memorandum): the motion (L.R. 9013-1(A)); the summary of affidavits or other documents (L.R. 9013-1(B), Local Form MOW 9040-1.1, not checked as to form); a proposed order; the notice of hearing (L.R. 9013-1(G): at least 7 days, 2012 text). None of the exemplars has a table of contents or a table of authorities, and no page limit for a memorandum appears in the W.D. Mo. bankruptcy local rules text I could read (gap 1).

## Layout

- Letter paper, 1 inch margins on all sides, no line numbers (neither exemplar has them).
- Court title (two lines), centered, capitals, then the division in parentheses.
- Caption as one row per line: party column, closing ")" column, right column for the case number, chapter, judge and adversary number. Each row has a fixed height, so the ")" marks line up.
- Document title, bold and centered, under the caption.
- Body single-spaced within a paragraph (line pitch about 15.5 pt), one blank line between paragraphs, first-line indent of 0.5 in, flush left (not justified), as in both exemplars.
- Level-1 headings: roman numerals (I., II., ...), bold capitals, left, with the text after a 0.4 in gap. Level-2 headings: capital letters (A., B., ...), bold, left. No level-2 heading is used in the sample (the exemplar has none).
- Body paragraphs are not numbered (a memorandum of law, not an allegation).
- Lists are numbered 1., 2., ... with the paragraph spacing.
- Page number centered at the foot.
- Signature block on the right half of the page: firm, "/s/" line with signer and bar number, address, telephone, fax, e-mail, and the role of the signer. The date is printed on the left when the frontmatter has one.
- Certificate of service after the signature, heading in bold capitals (not a numbered heading, so it takes no roman numeral).

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `court` (list of lines), `division` (optional), `debtor`, `case_number`, `chapter`, `judge` (optional), `plaintiffs`, `defendants` (lists), `adv_number`, `title`, `signature` (`firm` list, `signer`, `bar`, `lines` list, `role`), `date` (optional), `certificate` (`date`, `manner`).
- YAML pitfall: a value containing ` #` (for example `# 40448MO`) must be quoted, or YAML reads the `#` as a comment. The sample quotes it.
- Body: `# Heading` is a level-1 heading (roman numbered by the template); `## Heading` is level 2 (capital letters). Blank-line-separated paragraphs. Case names in `*italics*`.
- Not supported: tables, footnotes, raw typst.

## Overlay

`sh tools/overlay.sh courts/eighth-circuit/missouri/federal/bankruptcy-western-district/motion-brief barnhart-mohela-memorandum`. The first exemplar in `exemplars/` is Barnhart. The page map from the final run (`samples/OVERLAY-barnhart-mohela-memorandum.txt`): ours p.1 to p.4 pair with filed pp. 1 to 4 (word overlap 64.4%, 70.1%, 60.4%, 28.4%). Page 4 is low (28%) because our page 4 holds the certificate of service, which the filed memorandum does not have, and the filed page 4 is short. The overlay is a diagnostic, not a score. The visible differences are tier-3: the filed document is in Calibri/Arial and has a different caption spacing.

## Gate 2 review (current PDF, every page rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, division, caption (seven defendants), title, lead-in ("COMES NOW"), heading I and the first paragraph | OK. The caption rows stay aligned with the seven defendant lines; "METROPOLITAN COMMUNITY COLLEGE" stays on one line (party column 3.8 in). |
| 2 | Background end, heading II (Motion to Dismiss Standard), paragraphs on the Rule 12(b)(6) standard | OK. Case names in italics. |
| 3 | Heading II end, heading III (Undue Hardship), heading IV (Argument), heading V (Conclusion) | OK. The Conclusion runs over to page 4. |
| 4 | Conclusion end, signature block, heading VI (Certificate of Service) | OK. The certificate is on the same page as the signature. |

## Known gaps and open choices

1. **Rule text is not the current one.** The W.D. Mo. bankruptcy local rules I could read are the 2012 text ("Adopted November 30, 2012, effective January 1, 2013", `mow.uscourts.gov/sites/mow/files/BK_Archive_bk_rules.pdf`). The 2003 text (`BK_Archive_local_rules_of_practice.pdf`) has the same 9011-4, 9013-1 and 9013-3 wording, but 9013-1(C) gives 20 days there and 21 days in 2012. The 2019 proposed amendments (`2019-BK-Proposed-LR-Amendments.pdf`) redirect and were not read. Whether the rules were amended after 2013 is **not verified**. The court's current local rules page could not be fetched (403/404 to the fetch tool). **David or the PM should check the current W.D. Mo. bankruptcy local rules before this template is treated as final**, especially any page limit or format rule added after 2013.
2. **Type face and size.** No W.D. Mo. or FRBP rule sets a font or type size for a memorandum that I could read. The exemplars use Times New Roman (Lewallen) or Calibri/Arial (Barnhart; the text layer shows embedded Calibri). The only vendored face is EB Garamond, so the template uses it at 13 pt, which is about Times 12 pt by apparent size. Re-checked 2026-10-14: the W.D. Mo. bankruptcy rules page on courtrules.net returned 403 and a web search did not reach the court's own text, so no typeface rule was found for this court. Under `docs/FONTS.md` rule 3 a court that names no face keeps EB Garamond, so the template stays on it. Liberation Serif (metric-compatible with Times) is vendored, but it is not required here, so it is not used. This is a tier-2 choice.
3. **Single spacing and the blank line between paragraphs** follow both exemplars (tier 2). Carlson, the complaint, is double-spaced; memoranda in W.D. Mo. are not, in the two exemplars shown.
4. **Certificate of service.** L.R. 9013-3 requires one. Lewallen has one (ECF notice and first-class mail to the persons listed). Barnhart has none in its text layer; its CM/ECF notice is not printed. The sample's certificate is therefore an addition, with the date taken from the ECF stamp ("Filed 03/10/14"). The template makes it mandatory because the rule does.
5. **Judge.** The sample's judge, Honorable Cynthia A. Norton, is printed on the Barnhart caption. Case number 13-04184 carries the "-can" suffix.
6. **Sample length.** The Barnhart memorandum is 4 pages, so the render is 4 pages. The brief's target of 8-14 pages applies to exemplars of that length; this one is shorter. Lewallen (5 pages) was not transcribed; it is kept as the second filer and was checked for layout (its caption, heading, signature and certificate).
7. **Transcription.** Barnhart's text is transcribed as printed, with two normalizations: the court designation of *In re Ross* is written "(Bankr. W.D. Mo. 1999)" (the filing has "(Bankr.W.D.Mo.1999)"). The filing's own errors are kept ("this is does not apply", "de[s]igned", "Plaintiffs'" for the single plaintiff). Italics for case names are our markup; the text layer does not show italic runs, so the exact italic choices in the filing are not verified.
8. **Not checked by the template.** Whether the motion itself states the grounds with particularity (L.R. 9013-1(A)), whether a summary of affidavits is attached (9013-1(B)), and the response deadline (9013-1(C)) are for the motion and the notice, not this memorandum.
9. **Recent exemplar not found.** The searches (CourtListener RECAP, `court=mowb`, "memorandum in support" and "motion to dismiss") turned up Krigel v. McCray (16-04019, doc 7, a motion with no separate memorandum), Strauss v. Isaacks (08-04238, suggestions in support of summary judgment, not a motion to dismiss), and Jackson (25-04023, docs 58 and 92, 2025 motions to dismiss, which could not be downloaded: the RECAP storage path needs the PACER case id, and the API returned 401/403). A 2025-2026 memorandum with a text layer was not retrieved. Both saved exemplars are from 2005 and 2014. This is a tier-2 risk: the layout conventions may have moved since.
10. **Checks not run.** `tools/check.sh` and `tools/check-selftest.sh` expect `court.json` and `rules.md`, which a doc-type folder does not have. The brief forbids `tools/tracker.sh`. Render, overlay and the page review are the checks run here.
