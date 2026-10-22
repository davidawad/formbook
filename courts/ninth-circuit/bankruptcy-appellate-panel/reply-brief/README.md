# Bankruptcy Appellate Panel of the Ninth Circuit: appellant's reply brief (bap9)

- Court: `bap9` (United States Bankruptcy Appellate Panel of the Ninth Circuit), folder `courts/ninth-circuit/bankruptcy-appellate-panel/reply-brief/`
- Template: `typst/bap9-reply-brief.typ` (entry `typst/main.typ`)
- Exemplar: `usage/FILED-EXAMPLE-reply-brief.pdf` (see `usage/SOURCE.md`)
- Samples: `usage/INPUT-reply-brief.md`, a transcription of the exemplar (abridged), rendered to `usage/OUTPUT-reply-brief.typst.pdf`, overlay `.overlay/courts/ninth-circuit/bankruptcy-appellate-panel/reply-brief/OVERLAY-reply-brief.pdf` and `.txt`; and `usage/INPUT-reply-brief-2.md` (fictional), rendered to `usage/OUTPUT-reply-brief-2.typst.pdf`
- Status of this doc type:
  - **Exemplar found (2026-10-16).** *Beavor v. Reno City Center Owner, LLC*, BAP case 25-1050, "Appellants' Reply to Brief of Appellee Reno City Center Owner, LLC", filed August 29, 2025 by Greenberg Glusker Fields Claman & Machtinger LLP for the appellants. Born-digital, complete. Alternates from different filers: *Moehling v. Select Portfolio Servicing* (BAP No. SC-26-1081, pro se) and, for the cover caption, the answering-brief alternate *Hujazi v. Wirum* (BAP No. NC-14-1030); compared, not saved.
  - The Beavor sample is abridged: the current render has 14 pages against the filer's 23 (see the sample's header comment). The fictional sample is kept as it was.
  - The former "no reply content rules" gap is closed: FRBP 8014(c) was read (see "Gap" below).

Summary line for the PM: `exemplar=yes render=ok overlay=ok pages_reviewed=14`

(pages_reviewed counts the transcription's current 14 pages, each viewed next to its exemplar page and its overlay page. The fictional sample's 6 pages were also viewed after the template changes.)

## Governing rules

Verified 2026-10-14. Primary source: BAP Litigants Manual (Rev'd 01/26), https://cdn.ca9.uscourts.gov/datastore/bap/2026/Litigants_Manual_2026_01_Final.pdf. FRBP text as quoted in the manual, with one secondary cross-check (see `../opening-brief/README.md`, "Governing rules").

| ID | Requirement | Source |
|---|---|---|
| BAP-LENGTH-001 | Reply brief: 15 pages, or half the type-volume limit of the principal brief (13,000 words / 2 = 6,500 words). Cover, tables, signature and certificates are excluded. | Litigants Manual §VIII.8; FRBP 8015(a)(7) (secondary summary for the "half" rule) |
| BAP-CERT-004 | Certificate of compliance for the type-volume limit, stating the word count. | FRBP 8015(h) (secondary summary) |
| BAP-CERT-005 | No certification of interested parties or of related cases is listed for a reply. The template prints only the compliance certificate and the service certificate. | Litigants Manual §VIII.6 lists the certifications for the opening and responsive briefs only |
| BAP-FORM-001 to -003 | Same as the opening brief. | FRBP 8015(a)(4)-(6), Litigants Manual §VIII.7 |
| BAP-COVER-001 | Same as the opening brief. The title identifies the appellant. | FRBP 8015(a)(2) (secondary summary) |
| BAP-SIG-001, BAP-SERVICE-001 | Same as the opening brief. | Administrative Order Regarding Electronic Filing, Rules 5(b) and 6 |


## Gap: no reply content rules (closed 2026-10-16)

FRBP 8014(c), read 2026-10-16 at https://www.law.cornell.edu/rules/frbp/rule_8014: "The appellant may file a brief in reply to the appellee's brief. A reply brief must comply with (a)(2)–(3)." So a reply needs a table of contents and a table of authorities and no named sections. The template requires no headings (`doc.required: ()`) and now requires the `authorities` registry, so the table of authorities is always printed (before 2026-10-16 it was printed only when the frontmatter happened to give one). FRBP 8015(a)(7)(B)(ii) was read the same day: a reply "contains no more than half the type volume specified in item (i)" (13,000 words), i.e. 6,500, as the template enforces.

History (2026-10-14): FRBP 8014(a) and (b) and the manual's §VIII.5 set out contents for the opening and responsive briefs. The manual gives no section list for a reply, and the official FRBP 8014(c) text was not read then; the question to David ("does the Panel require any reply heading?") is answered by the rule text above: no.

## Template

`typst/bap9-reply-brief.typ` is the opening-brief template with its per-type settings block changed (`kind`, `title`, `required`, `word-limit`, `certs`). It includes the two fixes made when the opening brief was checked against its exemplar (see `../opening-brief/README.md`, "Template changes from the overlay"). Since 2026-10-16 it also has the changes listed under "Template changes from the overlay" below, which the opening template does not yet have.

- Line pitch: 31 pt body lines (double spacing, BAP-FORM-003) and 17 pt single-spaced elements, as exact line boxes (the cross-engine layout model, see "Engines"; until 2026-10-22: 1.3em leading, about 31 pt with Times New Roman, plus a 1.3em paragraph gap).
- Table of contents: printed for the reply. Table of authorities: always printed; the `authorities` registry is required (FRBP 8014(c)).

## Exemplar search (resolved 2026-10-16)

The earlier passes searched CourtListener with `court=bap9` and found nothing. CourtListener files BAP9 dockets under the circuit's court id `ca9` with the short number (ca9 "25-1050" here; ca9 "25-1042" = BAP No. CC-25-1042). The earlier note ruling out *Hujazi v. Wirum* as a Ninth Circuit appeal was wrong (it is BAP No. NC-14-1030; corrected in `usage/SOURCE.md`). Searching RECAP (`type=r`) under `ca9` found three reply candidates: Beavor (counsel, born-digital, chosen), Moehling (pro se) and Reznick (pro per, a scan). Details in `usage/SOURCE.md`.

## Template changes from the overlay

The same seven changes as in `../answering-brief/README.md` ("Template changes from the overlay"), made in `typst/bap9-reply-brief.typ`, plus one reply-only change. None copies the exemplar's text, coordinates or line breaks. The opening-brief template has none of them yet; the docx filter was not touched and does not read the new keys.

1. Required-heading check: tolerant of enumerators and case (the reply requires no headings, so this has no effect here; kept for identical code).
2. **`brief_title`** (FRBP 8015(a)(2)(E)): the fixed "Appellant's Reply Brief" did not identify the filing parties of the Beavor brief (several appellants) or the brief it answers. The Beavor sample sets `brief_title: "Appellants' Reply to Brief of Appellee Reno City Center Owner, LLC"`.
3. **`bankruptcy_case`** (FRBP 8015(a)(2)(C), 8003(d)(2)(A)): the cover now prints the bankruptcy case title ("In Re: RENO CITY CENTER OWNER, LLC / Debtor (Chapter 11)") above the parties. Beavor, Moehling and Hujazi all carry it.
4. TOC sub-headings indented (all three filers do).
5. Headings spaced away from the preceding paragraph (they sat closer to it than to their own text; visible before the fix at the "b)" sub-headings on our pages 6 and 8).
6. TOA numbers sorted by value: our statutes printed "§ 1112(b), § 1141(b), § 349(b)(3), § 742"; now "§ 349(b)(3), § 742, § 1112(b), § 1141(b)", the filer's order.
7. Certificate of service with unregistered parties: the BAP sample certificate's sentence on CM/ECF service of registered parties was missing; now printed before the mailing sentence (Beavor has one non-CM/ECF participant).
8. Reply only: `authorities` is required (FRBP 8014(c), see "Gap").

Re-rendered after the changes: `OUTPUT-reply-brief.typst.pdf` (current render: 14 pages) and `OUTPUT-reply-brief-2.typst.pdf` (6 pages, unchanged page count).

## Sample (`usage/INPUT-reply-brief.md`)

A transcription of the exemplar, abridged, from the PDF's text layer: the cover; I. Standard of Review; II. Argument part A in full (a) and (b), with footnotes 1-3 and the block quotation; part B, the first two paragraphs of B(a) with footnote 4, and B(b) in full with its block quotation; III. Conclusion; signature; compliance certificate and certificate of service (the one non-CM/ECF participant is in `service.unregistered`). Omitted, as the header comment says: the rest of B(a) (filed pages 7-13), footnotes 5-6, the CM/ECF service list and the server's declaration. The table of authorities is generated from the excerpt, so it lists only the authorities cited in it (17 of the filer's 27). Three heading levels: level 1 "I." sections, level 2 "A."/"B.", level 3 "a)"/"b)". The compliance certificate states the template's count for the excerpt, 2,324 words; the filer's states 3,542 for the whole brief.

## Sample (`usage/INPUT-reply-brief-2.md`)

Fictional. About 350 words of body text (478 words including frontmatter). Two argument headings and a conclusion. Compliance and service certificates only. Written to the rules, not transcribed.

File naming follows the tools (`INPUT-` / `OUTPUT-` / `OVERLAY-`), as in the opening-brief folder.


## Overlay

`sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/reply-brief beavor-reply-brief` exits 0 (one PDF in `usage/`) and writes `usage/OVERLAY-beavor-reply-brief.pdf` (15 pages) and `.txt`.

Page map (ours → filed page, word overlap): 1→1 (100%), 2→2 (42%), 3→4 (40%), 4→5 (96%), 5→6 (69%), 6→7 (58%), 7→8 (54%), 8→8 (48%), 9→9 (64%), 10→10 (69%), 11→11 (66%), 12→18 (56%), 13→19 (45%), 14→19 (49%), 15→22 (20%). Our 11 body pages hold the excerpt; from page 12 on the pairing is the nearest filed page (the omitted filed pages 12-17 have no counterpart). Low overlap on the TOC and TOA is expected (the excerpt has fewer entries).

The fictional sample has no overlay (not a filed document).

## Gate 2 review (2026-10-16; every page rendered at 60 dpi and viewed next to its paired exemplar page and its overlay page)

### sample beavor-reply-brief (15 PDF pages: cover p1, TOC p2 (i), TOA p3 (ii), body p4-p14 (1-11), certificates p15 (12))

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 cover | filed p1; Moehling p1; Hujazi p1 | Case number at top, court, "In Re: RENO CITY CENTER OWNER, LLC / Debtor (Chapter 11)" (FIXED: no place for it before), parties, proceeding, the filer's title (FIXED: was the fixed "APPELLANT'S REPLY BRIEF"), counsel with e-mail, phone. All FRBP 8015(a)(2) items present. | FIXED |
| 1 cover | filed p1; Moehling p1; Hujazi p1 | The filer and both alternates put the court name above the case number; the template follows FRBP 8015(a)(2)(A) (case number centered at the top), as Klein does. Filer sets the designations in italics, small caps for the court, and rules around the title; ours italicises the counsel lines. | ACCEPTED (tier 3; order is rule-driven) |
| 2 TOC | filed p2 | I, II, A, B, III with page numbers matching our body (1, 2, 2, 7, 11); A and B indented (FIXED). The filer lists the a)/b) level and the two certificates; the template's TOC has depth 2 and lists no certificates. | FIXED / ACCEPTED (depth: tier 3) |
| 3 TOA | filed p3-p4 | Cases, Statutes, Other Authorities; every entry checked against our body pages (e.g. Jevic 1, 4, 5, 10; Lujan 2, 6; § 1112(b) 1; Bank of America 10). Statutes in numeric order (FIXED). Fits one page (the excerpt cites 17 authorities). | FIXED |
| 4 body 1 | filed p5 | "I. STANDARD OF REVIEW" centered bold; double spaced; case names italic. Filer underlines the title and justifies the text. | PASS (style ACCEPTED, tier 3) |
| 5 body 2 | filed p6 | II centered; "A." level 2 and "a)" level 3, bold, left, with space above (FIXED). | FIXED |
| 6 body 3 | filed p7 | Footnotes 1-2 at the foot of the page that carries their references, under a short rule. | PASS |
| 7 body 4 | filed p8 | Footnote 3 on its reference page; the Jevic block quotation single spaced and indented both sides, as filed. | PASS |
| 8 body 5 | filed p8 | Argument continues; italic "Id." and case names. | PASS |
| 9 body 6 | filed p9 | "b)" sub-heading now set off from the preceding paragraph (FIXED; it sat tight against it before). | FIXED |
| 10 body 7 | filed p10 | "B. The Dismissal Order Violates Jevic." and "a)". The filer italicises "Jevic" in the heading; the transcription has it roman. | ACCEPTED (transcription detail, not a template issue) |
| 11 body 8 | filed p11 | Footnote 4 on its page; "b) The Dismissal Order Favored Equity" (excerpt resumes at B(b)). | PASS |
| 12 body 9 | filed p18 | B(b); the § 349(b) block quotation. | PASS |
| 13 body 10 | filed p19 | B(b) continues; Bank of America, Norwest italic. | PASS |
| 14 body 11 | filed p19 | III Conclusion and the signature kept together: /s/ Brian L. Davidoff, names, firm, "Attorneys for Appellants", date. The filer has date and firm at left and "By:". | PASS (layout ACCEPTED, tier 3) |
| 15 certs 12 | filed p22 (p17-p18) | Compliance (2,324 words, Times New Roman 14 pt) and service on one page. Service has both BAP sample sentences and the mailed party (FIXED). No interested-parties or related-cases certification: not required in a reply; the filer has none either. The filer's server declaration and full CM/ECF list are its own form. | FIXED / ACCEPTED |

Tier-2 comparison with the alternates: Moehling (pro se; pages 1-2 viewed) and Hujazi (counsel; page 1 viewed) both carry "In re ..., Debtor" on the cover, with the BAP and bankruptcy numbers at the right of a caption box; with Beavor that is three filers, so the bankruptcy case title is a convention, and FRBP 8015(a)(2)(C) requires it. Moehling's TOC numbers its level-1 entries with roman numerals, like Beavor's, and its title is the plain "Appellant's Reply Brief" (the template default).

### sample fictional-reply-brief (6 PDF pages; re-rendered after the template changes)

| Page | Compared with | Finding | Status |
|---|---|---|---|
| 1 cover | rules | Title "APPELLANT'S REPLY BRIEF" (default); no `bankruptcy_case` key, so no "In re" line. | PASS |
| 2 TOC | body | Argument 1; I-III indented, 1, 1, 2; Conclusion 2. | PASS |
| 3 TOA | body | Law v. Siegel 2; § 548 1. | PASS |
| 4 body 1 | - | Argument, I, II; headings set off from preceding text. | PASS |
| 5 body 2 | - | III, Conclusion, signature together. | PASS |
| 6 certs 3 | - | Compliance (344 words) and service. | PASS |

## Known gaps

- One exemplar transcribed (Beavor, abridged) and two alternates compared (Moehling, Hujazi).
- Reply content rules: closed (see the gap section).
- FRBP 8014(c) and 8015(a)(7)(B)(ii) read 2026-10-16 on law.cornell.edu (not the uscourts.gov PDF).
- Word count and page count are not checked against the PDF (see the opening-brief README).

## Re-check 2026-10-15 (bead fb-595.20.9)

- Re-searched for an exemplar (CourtListener with `court=bap9`, paced; web search). None found. Searches are logged in `usage/SOURCE.md`.
- Re-rendered `usage/INPUT-reply-brief-2.md` with `sh tools/render.sh`: 6 pages, exit 0. Every page rendered at 60 dpi and viewed; layout unchanged from the review above. The PDF was moved to `/work/artifacts/bap9/` and is not committed.
- `sh tools/overlay.sh` exits 1 (`no exemplar pdf`). Overlay: not produced.
- Status unchanged: **BLOCKED: no public exemplar.**
## Engines

typst (the reference) and docx, both on the shared cross-engine layout model (docs/EVAL-LOOP.md, "Cross-engine gate"; fb-595.54.4): `typst/bap9-*.typ` applies `lib/typst/xengine.typ`; `docx/reference.xml` holds the styles of `lib/docx/xengine-reference.sh`, from which fb render builds `docx/reference.docx` (`tools/fb/src/docxref.rs`), and `docx/bap9.lua` (on `lib/docx/xengine.lua`) writes the cover, the tables with their page numbers, the headings, lists, signature and certificates with the typst template's pitches, spaces, indents and columns. The three BAP9 templates (opening, answering, reply) are one text in each engine; only the per-type block (`doc` in typst, `CFG` in the filter) differs. Output `usage/OUTPUT-<id>.docx` and its LibreOffice PDF `usage/OUTPUT-<id>.docx.pdf`.

- One face: Times New Roman 14 pt in both engines (typst falls back to Liberation Serif, its metric twin; the docx names Times New Roman). The opening brief was EB Garamond until fb-595.54.4: LibreOffice sets EB Garamond's f-ligatures, which Word and typst do not, so its lines drifted up to 1.96 pt from typst's; the answering and reply templates were already Times New Roman (their docx still named EB Garamond, a DEF-FONT-002 mismatch, now fixed).
- Line boxes: body 31 pt (double spacing, BAP-FORM-003), everything single-spaced 17 pt (headings, cover, tables, quotations, footnotes, signature, certificates); no space between body paragraphs (the 0.5 in first-line indent marks them); spaces between blocks in whole points, the same in twips in the filter.
- Tables: each row wraps before its page column (36 pt contents, 56 pt or the page list's width for authorities) and a dot leader runs to the page. The docx filter writes the page numbers from a first LibreOffice pass (fb render, docxpass.rs: a heading is found by its title, a citation by its text and the words after it, or by its first word when it runs over a page end; typst files a citation under the page of its first word too).
- Footnotes: 14 pt in 17 pt lines, 7 pt apart, a 2 in rule; between the body and the first note the height of Word's separator paragraph (16.1 pt, measured on LibreOffice: typst `clearance` + `gap`), so both engines end a page above the same note.
- Break rules both engines share: no break inside "362(a)(4)" (typst boxes it; the filter puts a word joiner between ")" and "("), none after a slash inside a word ("CM/ECF"), none after a section sign; footnote marks are the digit at 58 % (typst `super(typographic: false)`).
- Gate 4 CROSS-ENGINE gates (`params.cross_engine: gate` in `eval.yaml`): XENG-001..003 PASS on every INPUT (pages, page ends and every line break as typst's; width drift of an identical line at most 0.43 pt).

## Render check 2026-10-15

Re-rendered `usage/OUTPUT-fictional-*.pdf` with `sh tools/render.sh` (exit 0, no typst warnings). `sh tools/overlay.sh` exits 1 again: no exemplar pdf. Every page rendered at 60 dpi and viewed: answering-brief 10 of 10, reply-brief 6 of 6. No template changes in this pass. Still BLOCKED on the exemplar; search log appended to `usage/SOURCE.md`.

## Render and overlay review 2026-10-21

Re-rendered `usage/INPUT-reply-brief.md` with `sh tools/render.sh` (exit 0). `sh tools/overlay.sh courts/ninth-circuit/bankruptcy-appellate-panel/reply-brief reply-brief` produced a 14-page overlay in `.overlay/`. Rendered all 14 output pages and all 14 overlay pages to PNG at 60 dpi and viewed each page. Current output SHA-256: `686868a9d6f5822cd145083c4afd874f4a45622406fbe619fd5e2d558f3089ca`.

| PDF page | Finding | Status |
|---|---|---|
| 1 | Cover fields and brief title present; centered and legible. | PASS |
| 2 | TOC entries and page references align with body. | PASS |
| 3 | TOA groups and citations fit on page. | PASS |
| 4 | Standard of review heading and body render cleanly. | PASS |
| 5 | Argument headings, indentation and body are distinct. | PASS |
| 6 | Body text and footnotes remain legible. | PASS |
| 7 | Argument continues; footnote remains on reference page. | PASS |
| 8 | Subheadings and body text remain distinct. | PASS |
| 9 | Block quotation and surrounding argument fit cleanly. | PASS |
| 10 | Argument continues with consistent spacing. | PASS |
| 11 | Argument continues with citations and headings legible. | PASS |
| 12 | Conclusion begins and continues without clipping. | PASS |
| 13 | Conclusion and signature block fit cleanly. | PASS |
| 14 | Compliance and service certificates fit without clipping. | PASS |

Current status: `exemplar=yes render=ok overlay=ok pages_reviewed=14`.

## Cross-engine port and review 2026-10-22 (fb-595.54.4)

The template moved onto the shared layout model (see "Engines"): 31 pt body lines with no paragraph gap, single-spaced 17 pt elements, the tables as rows with a page column (`lib/typst/tables.typ` no longer used), the footnote area as Word's, citations filed under the page of their first word, counsel and signature lines printed as given. In `INPUT-reply-brief.md` the Kaiser Gypsum quotation, which nests an opening quote inside an opening quote as filed, is typed with curly quotes: the two smart-quote readers paired the straight ones differently (typst "proceeding.“", pandoc "any”party"). Every page of both typst renders rendered at 45 dpi and viewed; the docx PDFs viewed beside them (XENG-001..003 PASS on both).

| Sample, PDF page | Finding | Status |
|---|---|---|
| reply-brief p1 cover | Bankruptcy case title, parties, proceeding, the filer's title (`brief_title`, two lines), counsel; one page. | PASS |
| reply-brief p2-p3 (i-ii) | Contents with the argument sub-headings indented; authorities (11 cases, 4 statutes, 2 other) with wrapped entries hanging and page lists matching the body. | PASS |
| reply-brief p4-p14 (1-11) | Body double-spaced; footnotes 1-4 under the 2 in rule on pages 3, 4 and 7; the Jevic and § 349(b) block quotations single-spaced; the conclusion and signature on page 11. | PASS |
| reply-brief p15 (12) | Compliance (2,324 words) and service with the mailed party. | PASS |
| reply-brief-2 p1-p3 | Cover; contents; authorities (1 case, 1 statute). | PASS |
| reply-brief-2 p4-p5 (1-2) | Argument with three sub-headings, Conclusion and signature on page 2. | PASS |
| reply-brief-2 p6 (3) | Compliance (344 words) and service. | PASS |
