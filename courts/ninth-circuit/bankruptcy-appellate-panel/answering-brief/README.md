# Bankruptcy Appellate Panel of the Ninth Circuit: appellee's answering brief (bap9)

- Court: `bap9` (United States Bankruptcy Appellate Panel of the Ninth Circuit), folder `courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief/`
- Template: `typst/bap9-answering-brief.typ` (entry `typst/main.typ`)
- Exemplar: `usage/FILED-EXAMPLE-answering-brief.pdf` (see `usage/SOURCE.md`)
- Samples: `usage/INPUT-answering-brief.md`, a transcription of the exemplar, rendered to `usage/OUTPUT-answering-brief.typst.pdf`, overlay `.overlay/courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief/OVERLAY-answering-brief.pdf` and `.txt`; and `usage/INPUT-answering-brief-2.md` (fictional), rendered to `usage/OUTPUT-answering-brief-2.typst.pdf`
- Status of this doc type:
  - **Exemplar found (2026-10-16).** *Klein v. Sharp*, BAP No. CC-25-1042, Appellee's Answering Brief filed May 2, 2025 by Pachulski Stang Ziehl & Jones LLP for the chapter 11 trustee. Born-digital, complete. Alternate from a different filer: *Hujazi v. Wirum*, BAP No. NC-14-1030 (McKenna Long & Aldridge LLP), compared for tier 2, not saved.
  - The Klein sample transcribes the whole body (the brief is short: 1,598 words by the filer's count). The fictional sample is kept as it was.
  - Template built from the rules, then tested against the exemplar; see "Template changes from the overlay".

Summary line for the PM: `exemplar=yes render=ok overlay=ok pages_reviewed=12`

(pages_reviewed counts the transcription's current 12 pages, each viewed next to its exemplar page and its overlay page. The fictional sample's 11 pages were also viewed after the template changes.)

## Governing rules

Verified 2026-10-14. Primary source: BAP Litigants Manual (Rev'd 01/26), https://cdn.ca9.uscourts.gov/datastore/bap/2026/Litigants_Manual_2026_01_Final.pdf, read in full for the sections cited. FRBP text as quoted in the manual, with one secondary cross-check (see `../opening-brief/README.md`, "Governing rules").

| ID | Requirement | Source |
|---|---|---|
| BAP-CONTENT-001 | Responsive brief meets the opening brief's requirements, except that the statements of jurisdiction, of issues and standards of review, and of the case need not be included. The summary of argument, argument and conclusion remain (FRBP 8014(a)(6)-(7)). Table of contents and table of authorities remain (FRBP 8014(a)(2)). The template requires `Summary of Argument`, `Argument`, `Conclusion`, each under any accepted title. | FRBP 8014(b), Litigants Manual §VIII.5 |
| BAP-CERT-001 | Responsive brief includes a certification of interested parties. It does not include a certification of related cases. | BAP R. 8015(a)-1 as stated in Litigants Manual §VIII.6 |
| BAP-LENGTH-001 | Appellee's initial brief is held to the same limit as the appellant's: 30 pages, or 13,000 words under FRBP 8015(a)(7). Cover, tables, signature and certificates are excluded from the count. | Litigants Manual §VIII.8; FRBP 8015(a)(7) |
| BAP-FORM-001 to -003 | Same as the opening brief: 8½ × 11, one-inch margins, double spaced, 14 pt proportional type, plain roman with italics for emphasis. | FRBP 8015(a)(4)-(6), Litigants Manual §VIII.7 |
| BAP-COVER-001 | Same as the opening brief. The title identifies the appellee. | FRBP 8015(a)(2) (secondary summary) |
| BAP-SIG-001, BAP-SERVICE-001 | Same as the opening brief. | Administrative Order Regarding Electronic Filing, Rules 5(b) and 6 |

Note on FRBP 8014(b): the manual paraphrases this. The opening-brief README says the official text of 8014 and 8015 was not read directly; that applies here too.


BAP R. 8015(a)-1 itself was read on 2026-10-16 (https://cdn.ca9.uscourts.gov/datastore/bap/2015/06/18/baprules.pdf, rules as revised June 15, 2015): (a) every non-governmental party attaches the interested-parties certification to its initial brief; (b) the *appellant* attaches the related-cases statement to the opening brief. So the appellee's brief carries (a) and not (b), as the template does. FRBP 8015(a)(2) was read on 2026-10-16 at https://www.law.cornell.edu/rules/frbp/rule_8015 (cover items (A)-(F)).

## Template

`typst/bap9-answering-brief.typ` is the opening-brief template with its per-type settings block changed (`kind`, `title`, `required`, `certs`). It includes the two fixes made when the opening brief was checked against its exemplar (see `../opening-brief/README.md`, "Template changes from the overlay"). Since 2026-10-16 it also has the changes listed under "Template changes from the overlay" below, which the opening template does not yet have.

- Leading: 1.3em, which gives the 36.5 pt double-spaced line pitch measured on the render.
- Table of authorities, signature keep-with-last-paragraph, unbreakable certificates: as in the opening brief.


## Exemplar search (resolved 2026-10-16)

The earlier passes (2026-10-14 and 2026-10-15) searched CourtListener with `court=bap9` and found nothing. The reason: CourtListener files BAP9 dockets under the circuit's court id `ca9`, with the short number (ca9 docket "25-1042" is BAP No. CC-25-1042). The 2026-10-15 pass also wrongly ruled out *Hujazi v. Wirum* as a Ninth Circuit appeal; it is BAP No. NC-14-1030 (corrected in `usage/SOURCE.md`). Searching RECAP (`type=r`) under `ca9` for answering briefs with BAP captions found four candidates; three are from the same firm (Pachulski Stang Ziehl & Jones), so the primary is the shortest complete one (Klein, CC-25-1042) and the alternate is Hujazi (a different filer). Details, URLs and the rejected candidates are in `usage/SOURCE.md`.

## Template changes from the overlay

Each change is rule-driven or a tier-2 convention seen across filers; none copies the exemplar's text, coordinates or line breaks. The same changes are in `../reply-brief/typst/`. They are **not** made in `../opening-brief/typst/` (outside this item's scope); the opening template has none of them and should get the same changes. The docx filter (`docx/bap9.lua`) was not touched and does not read the two new frontmatter keys.

1. **Required-heading check rejected the filer's headings.** The filer numbers its sections ("II. SUMMARY OF ARGUMENT") and titles its argument "Discussion". FRBP 8014(a) fixes the content, not the wording or numbering, so a heading now matches with or without a roman enumerator and in any case, and `Discussion` is accepted for the argument. Nothing was renamed in the transcription.
2. **Brief title fixed to "Appellee's Answering Brief".** FRBP 8015(a)(2)(E) requires the title to identify the party or parties for whom the brief is filed; with several appellees, or a title naming the brief answered, the fixed title is wrong. New optional frontmatter key `brief_title` (default unchanged). Klein does not use it (its title is the default).
3. **No bankruptcy case title on the cover.** FRBP 8015(a)(2)(C) requires the title of the case as prescribed by Rule 8003(d)(2), and 8003(d)(2)(A) dockets the appeal "under the title of the bankruptcy case" ("In re ..., Debtor"). The Hujazi cover (and the reply exemplars) carry it; the template had no place for it. New optional key `bankruptcy_case` (`names`, `designation`), printed above the parties. Optional, not required, so the fictional samples still render unchanged; Klein's own cover omits it, so its transcription does not use it. Rule text read 2026-10-16 at https://www.law.cornell.edu/rules/frbp/rule_8015 and rule_8003.
4. **Table of contents did not indent sub-headings.** All three filers' tables (Klein, Hujazi, Beavor) indent second-level entries under their section; ours was flush left. Now indented by the paragraph indent.
5. **Headings sat closer to the preceding paragraph than to their own text** (space above a heading was smaller than the paragraph spacing). Space above is now the paragraph spacing plus a margin; space below is unchanged.
6. **Table of authorities sorted numbers digit by digit** ("28 U.S.C. § 1334" before "§ 157"). Digit runs now compare by value. Klein's own table has the digit-by-digit order; the Beavor reply table has numeric order; numeric is the professional choice.
7. **Certificate of service with unregistered parties** dropped the BAP sample certificate's middle sentence (registered parties served through CM/ECF). Both sentences are now printed (Litigants Manual Rev'd 01/26, sample certificate, manual p. 60). Klein has no unregistered parties, so it is not affected; shown on the Beavor reply sample.

Re-rendered after the changes: `OUTPUT-answering-brief.typst.pdf` (current render: 12 pages) and `OUTPUT-answering-brief-2.typst.pdf` (now 11 pages; was 10, from the heading spacing).

## Sample (`usage/INPUT-answering-brief.md`)

A transcription of the exemplar, not a fictional sample. The whole body is transcribed: the introductory paragraph, sections I-VI with the filer's numbering and upper-case titles, the five Statement-of-the-Case sub-headings, the signature, the compliance certificate and the interested-parties certification, all from the PDF's text layer. Case names and order titles in italics as filed. Omitted, as stated in the file's header comment: the bold-underlined defined terms (plain text here) and the filer's related-cases certification (BAP R. 8015(a)-1(b) asks it of the appellant's opening brief, so the template does not print one for an appellee). The filing has no certificate of service; the template prints its standard one. Authorities are linked with `toa:` keys, so the table of authorities is generated from the body. The compliance certificate states the template's count, 1,801 words; the filer's certificate states 1,598 (Word's count; ours is a whitespace-token count that includes citations and headings).

## Sample (`usage/INPUT-answering-brief-2.md`)

Fictional. About 950 words of body text. Sections: summary of argument; argument with sub-headings; conclusion. No statements of jurisdiction, issues or the case (correct under FRBP 8014(b)). Interested-parties certificate only. Written to the rules, not transcribed.

File naming follows the tools (`INPUT-` / `OUTPUT-` / `OVERLAY-`), as in the opening-brief folder.


## Overlay

`sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief klein-answering-brief` exits 0 (only one PDF in `usage/`) and writes `usage/OVERLAY-klein-answering-brief.pdf` (14 pages) and `.txt`.

Page map (ours → filed page, word overlap): 1→1 (94%), 2→2 (84%), 3→3 (86%), 4→4 (94%), 5→5 (96%), 6→6 (89%), 7→7 (78%), 8→8 (47%), 9→8 (40%), 10→9 (55%), 11→10 (61%), 12→11 (65%), 13→14 (33%), 14→14 (10%). Our body runs 9 pages against the filer's 8 (EB Garamond 14 pt sets wider than Times New Roman 14 pt), so from page 8 on the pairing is the nearest filed page, not a page-for-page claim. Page 14 (our certificate of service) has no counterpart in the filing.

The fictional sample has no overlay (it is not a filed document).

## Gate 2 review (2026-10-16; every page rendered at 60 dpi and viewed next to its paired exemplar page and its overlay page)

### sample klein-answering-brief (14 PDF pages: cover p1, TOC p2 (i), TOA p3 (ii), body p4-p12 (1-9), certificates p13-p14 (10-11))

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 cover | filed p1; Hujazi p1 | Case number at the top, court name, caption (appellants, v., appellee), proceeding with the BK case number and judge, title "APPELLEE'S ANSWERING BRIEF", counsel with bar numbers, address, phone, fax, e-mail, "Counsel for" line. All FRBP 8015(a)(2) items present. The court name wraps with "CIRCUIT" alone, as on the opening brief. | PASS |
| 1 cover | filed p1 | Counsel lines are italic and the telephone prints last (template order); the filer sets them upright with the phone before the fax and has rules between blocks. | ACCEPTED (tier 3: one filer's style) |
| 2 TOC | filed p2; Hujazi p4 | Sections I-VI with the filer's numbering; sub-headings 1-5 indented under III (FIXED: were flush left). Page numbers match our body: I 1, II 2, III 3, 1. 3, 2.-4. 4, 5. 5, IV 6, V 6, VI 9. | FIXED |
| 2 TOC | filed p2 | Filer's TOC is single spaced and bold; ours has wider spacing and regular weight. | ACCEPTED (tier 3) |
| 3 TOA | filed p3 | Cases, Statutes, Rules, each with its pages, checked against the body: Aalfs 6, Dela Rosa 7, Pinnacle 8, Syncom 7, Hinkson 6, 28 U.S.C. § 157 1, § 1334 1, the two rules 7. Statutes now in numeric order (FIXED; the filer's table has 1334 before 157). The filer's table has no "TABLE OF AUTHORITIES" title; ours has. | FIXED |
| 4 body 1 | filed p4 | Introductory paragraph, then "I. JURISDICTIONAL STATEMENT" centered bold; double spaced; italic order and motion titles. The filer puts the numeral on its own line and underlines the title. | ACCEPTED (tier 3) |
| 5 body 2 | filed p5 | Summary of Argument; defined terms plain (filer: bold underlined). | ACCEPTED (tier 3) |
| 6 body 3 | filed p6 | End of summary; III centered; "1. The Israeli Proceeding" bold left; space above headings now larger than paragraph spacing (FIXED). | FIXED |
| 7 body 4 | filed p7 | Sub-headings 2-4, each with its paragraph; filer underlines them. | PASS |
| 8 body 5 | filed p8 | Sub-heading 5 and its paragraph; text flows about half a page behind the filer. | PASS |
| 9 body 6 | filed p8 | IV Standard of Review (Aalfs, Hinkson italic), V Discussion begins. | PASS |
| 10 body 7 | filed p9 | Discussion; Dela Rosa, Syncom, rule citations. | PASS |
| 11 body 8 | filed p10 | Discussion; Pinnacle. | PASS |
| 12 body 9 | filed p11 | End of Discussion, VI Conclusion, and the signature kept with the last paragraph: /s/ John W. Lucas, firm, "Counsel to ..." and the date. The filer puts the date at left and "By" before the signature. | PASS (layout ACCEPTED, tier 3) |
| 13 certs 10 | filed p14 (and p12) | Certification of interested parties (two parties) and certificate of compliance (1,801 words, EB Garamond 14 pt) on one page, each unbreakable. Filer's title is the rule's form, "Certification Required by B.A.P. Rule 8015(a)-1(a)", and its text says "this appeal"; ours is titled "Certification of Interested Parties" and says "this case". | OPEN (see below) |
| 14 certs 11 | filed p14 | Certificate of service (all parties registered; BAP sample wording). The filing has none. The filer's related-cases certification (filed p15) is not printed: not required of an appellee. | ACCEPTED |

OPEN, for David: the interested-parties certification. BAP R. 8015(a)-1(a) (text read 2026-10-16, https://cdn.ca9.uscourts.gov/datastore/bap/2015/06/18/baprules.pdf, rules as revised June 15, 2015) gives a form "in substantially the following form": heading "Certification Required by BAP Rule 8015(a)-1(a)", a "[BAP NUMBER, DEBTOR'S NAME]" line, and "have an interest in the outcome of this appeal ... [list the names of all such parties and identify their connection and interest]". The template's certification is close in substance but uses its own heading and "this case", and has no BAP number/debtor line. Both answering exemplars (Klein; Hujazi under the old rule number 8010(a)-(1)(b)) use the rule's heading. The certification code is shared with the opening-brief template, so it was left for one change across all three doc types rather than changed here alone.

Tier-2 comparison with the alternate (Hujazi, viewed pages 1, 2, 4, 5, 6, 7): Hujazi's cover puts the court name first and a boxed caption with "In re ..., Debtor" and the numbers at the right; Klein puts the case number first. FRBP 8015(a)(2)(A) asks for the case number centered at the top, which the template does. Hujazi's section headings are left-aligned with the numeral; Klein and Beavor (reply) center them; the template centers level 1. Both filers indent TOC sub-entries (now done). Hujazi places its certifications before the TOC; Klein and Beavor after the body, like the template.

### sample fictional-answering-brief (11 PDF pages; re-rendered after the template changes)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 cover | rules | Case number, bankruptcy number, court, caption, proceeding, title, counsel. No `bankruptcy_case` key in this sample, so no "In re" line. | PASS |
| 2 TOC | body | Summary 1, Argument 2, I 2, II 4, III 5, Conclusion 6; level-2 entries indented; the wrapped entry I continues at the entry's indent. | PASS |
| 3 TOA | body | Law v. Siegel 5; § 544 1, 5; § 548 1, 3, 5; Rule 8014 2; checked against the body pages. | PASS |
| 4 body 1 | - | Summary of Argument, centered bold. | PASS |
| 5 body 2 | - | Argument, I, A; headings separated from the preceding text. | PASS |
| 6 body 3 | - | B and C. | PASS |
| 7 body 4 | - | II, A, B. | PASS |
| 8 body 5 | - | III, A, B. | PASS |
| 9 body 6 | - | Conclusion and signature together (the conclusion moved to its own page with the larger heading spacing; the keep-with-signature rule holds). | PASS |
| 10 certs 7 | - | Interested parties (four) and compliance (975 words). | PASS |
| 11 certs 8 | - | Certificate of service. | PASS |

## Known gaps

- One exemplar transcribed (Klein) and one alternate compared (Hujazi); a third filer was not compared for this doc type.
- The interested-parties certification wording (OPEN above).
- Official FRBP 8014(b) text not read directly.
- Excerpts of record appendix, corporate disclosure statement, paper rules: not generated (as in the opening brief).
- Word count and page count are not checked against the PDF (see the opening-brief README).
- `tools/check.sh` and `tools/check-selftest.sh` were not run for this doc type in this pass.

## Re-check 2026-10-15 (bead fb-595.20.9)

- Re-searched for an exemplar (CourtListener with `court=bap9`, paced; web search). None found. Searches are logged in `usage/SOURCE.md`.
- Re-rendered `usage/INPUT-answering-brief-2.md` with `sh tools/render.sh`: 10 pages, exit 0. Every page rendered at 60 dpi and viewed; layout unchanged from the review above. The PDF was moved to `/work/artifacts/bap9/` and is not committed.
- `sh tools/overlay.sh` exits 1 (`no exemplar pdf`). Overlay: not produced.
- Status unchanged: **BLOCKED: no public exemplar.**
## Engines

docx (`docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference; `docx/bap9.lua` builds the cover, front matter, signature and certificates from the frontmatter; output `usage/OUTPUT-<id>.docx`).

- Matches the typst form: US Letter with 1 in margins; EB Garamond 14 pt (font name declared; it must be installed where the file is opened); double spacing as exact 36.5 pt lines, the typst 1.3em gap between paragraphs, 0.5 in first-line indent; single-spaced headings, quotations, footnotes, table entries, signature and certificates; centered bold level-1 headings, bold left level-2 and level-3 headings with hanging indent. Three sections: cover with no footer, front matter in lower roman from i, body and certificates in arabic from 1. The filter applies the same word limit and required-heading checks as the typst template and passes the body word count to the compliance certificate (the opening and reply counts, 1,782 and 344, match the figures recorded in those READMEs).
- Differs from the typst form: (1) the table of contents is a TOC field whose cached result lists the headings without page numbers; Word or LibreOffice shows page numbers after a field update. (2) The table of authorities lists the cited authorities without page numbers in every viewer (LibreOffice does not honor TA/TOA fields), so it has no dot leaders. (3) Line breaks and page breaks follow Word or LibreOffice, not the typst render. (4) The last body paragraph is kept with the signature block (KeepWithNext); certificates are not forced onto one page.
- BLOCKED, docx.pdf gates (Gates 0 and 1 run on the LibreOffice PDF): no `soffice` on this box, so `tools/render-docx.sh` writes the .docx and fails at the conversion step. No `OUTPUT-<id>.docx.pdf` exists and no page of the .docx has been viewed; pages_reviewed is 0 for the docx engine.
- BLOCKED, page-number checks: the TOC and TOA page-number checks cannot pass by construction in this engine (no page numbers without a field update and a TOA field that LibreOffice does not honor), until the docx filter writes page numbers from a first pass.
- The .docx was validated for a valid zip, well-formed XML in every part, three sections with footer references, and every paragraph style defined in styles.xml. It has not been opened in Word or LibreOffice.
## Render check 2026-10-15

Re-rendered `usage/OUTPUT-fictional-*.pdf` with `sh tools/render.sh` (exit 0, no typst warnings). `sh tools/overlay.sh` exits 1 again: no exemplar pdf. Every page rendered at 60 dpi and viewed: answering-brief 10 of 10, reply-brief 6 of 6. No template changes in this pass. Still BLOCKED on the exemplar; search log appended to `usage/SOURCE.md`.

## Render and overlay review 2026-10-21

Re-rendered `usage/INPUT-answering-brief.md` with `sh tools/render.sh` (exit 0). `sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/answering-brief answering-brief` produced a 12-page overlay in `.overlay/`. Rendered all 12 output pages and all 12 overlay pages to PNG at 60 dpi and viewed each page. Current output SHA-256: `9bf86731123ad58c3be7f4987384d9ed2d5a8af188975ba1691969239e741bd0`.

| PDF page | Finding | Status |
|---|---|---|
| 1 | Cover fields and counsel block present; centered and legible. | PASS |
| 2 | TOC entries and page references align with body. | PASS |
| 3 | TOA groups and citations fit on page. | PASS |
| 4 | Jurisdiction heading and body begin cleanly. | PASS |
| 5 | Summary and next section heading flow correctly. | PASS |
| 6 | Statement of case begins after summary without collision. | PASS |
| 7 | Subheadings and body text remain distinct. | PASS |
| 8 | Statement of case continues into standard of review cleanly. | PASS |
| 9 | Discussion heading, paragraph flow and citations remain legible. | PASS |
| 10 | Discussion continues with consistent body spacing. | PASS |
| 11 | Conclusion and signature block fit without clipping. | PASS |
| 12 | Interested-parties, compliance and service certificates fit without clipping. | PASS |

Current status: `exemplar=yes render=ok overlay=ok pages_reviewed=12`.
