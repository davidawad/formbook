# Eighth Circuit BAP (bap8): answering brief (appellee's brief)

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `usage/` are untouched.
- Doc type: `answering-brief`. Appellee's brief, FRBP 8014(b).
- **Exemplar: yes.** `usage/FILED-EXAMPLE-answering-brief.pdf`: Appellees' Brief, *Farm Credit Services of America, PCA v. Swackhammer*, BAP No. 22-6006, filed 2022-12-23 by Robert C. Gainer (Cutler Law Firm, P.C.) for the debtor-appellees (22 pages, text PDF, Word 2021). Found 2026-10-16 in CourtListener RECAP, where BAP dockets sit under court id `ca8` (not `bap8`). Source details in `usage/SOURCE.md`.
- **Sample: transcription.** `usage/INPUT-answering-brief.md` transcribes the whole filing: cover, summary of the case, oral-argument statement, both certifications, the full body (filing pp. 1-13, all six footnotes and the four block quotations), signature, certificates. The tables are rebuilt by the template from the headings and `toa:` links.
- Render: ok, `usage/OUTPUT-answering-brief.typst.pdf`, 20 pages, Typst 0.15.1 with no warnings (2026-10-21). `pdffonts`: Times New Roman (regular, bold, and italic; embedded).
- Overlay: ok, `sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief answering-brief` (2026-10-21); writes `.overlay/courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief/OVERLAY-answering-brief.pdf` and `.txt` (gitignored).
- Pages reviewed: all 22 filed pages and all 20 rendered pages rasterized at 60 dpi and inspected (2026-10-21). The output is two pages shorter because its authorities table and body pagination are more compact; no content or layout defect was visible. See Gate 2 below.
- Superseded: the synthetic sample (`INPUT-synthetic-answering-brief.md`) and its `OUTPUT-` `.pdf`, `.docx`, `.docx.pdf` were removed. The docx outputs for the new sample were **not** made: LibreOffice (`soffice`) is not installed on this box, so `docx/render.sh` cannot run. See Engines.
- Status: `court.json` untouched; `status` not set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` (default now `usage/INPUT-answering-brief.md`) and calls `bap8-brief`. |
| `typst/bap8-answering-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections` (FRBP 8014(b): summary, argument), `needs-standard-of-review = false`. |
| `usage/INPUT-answering-brief.md` | Transcription of the filed brief (contract below). |
| `usage/OUTPUT-answering-brief.typst.pdf` | Render (`sh tools/render.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-answering-brief.md`). |
| `usage/OVERLAY-swackhammer-22-6006.pdf`, `.txt` | Overlay (`sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief swackhammer-22-6006`). |
| `usage/FILED-EXAMPLE-answering-brief.pdf`, `usage/SOURCE.md` | The filed exemplar and its source and search log. |

## Template changes this run (2026-10-16)

The same changes were made in `../reply-brief/typst/bap8-reply-brief.typ` (the two files differ only in the parameter block). `../opening-brief/typst/` is untouched; it still has the caption and table issues below.

1. **Caption "v."** The cover printed "v." between every pair of caption parts, so an "In re" line and a trailing non-party (here the Chapter 12 trustee) got a "v." too. A caption side may now set `v: false` to suppress the "v." after it; an empty `designation` prints nothing.
2. **Court name line break.** The name wrapped as "...FOR THE EIGHTH / CIRCUIT". The closing "for the ... Circuit" phrase is now held together with no-break spaces, so the name wraps before it, as both filed exemplars do. No line break is forced.
3. **Certification of Interested Parties wording (L.R. BAP 8th Cir. 8014A(b)(1)).** The rule's form opens with "NUMBER AND TITLE OF THE APPEAL" and "Certification Required By L.R. BAP 8th Cir. 8014A(b)(1): The undersigned...". The template printed only "BAP No. ..." and dropped the "Certification Required..." lead. It now prints the lead, and an optional `appeal_title` after the number. The filing does both.
4. **Optional `preliminary` front matter.** Markdown with level-1 headings, printed after the cover and before the certifications, listed in the table of contents with roman page numbers. No BAP rule fixes the place of a summary of the case or an oral-argument statement (FRBP 8019(a) allows the statement and puts no place on it); the filing puts both there. An oral-argument section is excluded from the word count (8015(g)); anything else in `preliminary` is counted.
5. **Table leaders.** A long heading or authority could push its page number onto a line of its own, with a stray leader dot (seen in the contents for Argument I and in the authorities for *Jellings*). Page references now sit in their own right-hand column, level with the entry's last line.

## Markdown contract (frontmatter)

Same as `opening-brief/README.md` (`case_number`, `caption`, `proceeding`, `brief_title`, `counsel`, `phone`, `email`, `signature`, `date`, `word_processor`, `typeface`, `interested_parties`, `related_cases`, `disclosure` optional, `service`, `authorities`; body citations `[text](toa:key)`), plus, in this template:
- `appeal_title` (optional): the title printed after the number in the interested-parties certification.
- `caption[].v` (optional, default true): `false` drops the "v." after that side.
- `preliminary` (optional): markdown with `#` headings for statements placed before the certifications.

Transcription notes for `INPUT-answering-brief.md`:
- The filing gives no counsel email. The `email` field says "Not stated in the filed brief", as in the opening-brief sample.
- "Attorneys for Appellees" is printed under counsel's name on the cover, as the second `names` line.
- The filing's spellings are kept: "§ 1129" in point heading I (the TOC says § 1229), "Schnackenberg"/"Schnakenberg", "Jelling", "let along". The TOC's "JURIDICTIONAL" and "ARGUEMENT" are not reproduced: the template builds the TOC from the body headings, which are spelled correctly in the filing.
- The related-cases certification is the filer's own sentence, including its "Certification Required by L.R. BAP 8th Cir. 8014A(b)(2)" lead.
- The filing's "Certificate of Virus-Free Document" cites 8th Cir. R. 28A(h)(2), a Court of Appeals rule, not a BAP rule. It is not reproduced.
- The certificate of service uses the template's CM/ECF wording (L.R. BAP 8014A(c)), not the filer's list of served counsel.

## Governing rules

Primary sources, read on 2026-10-14:
- FRBP 8014 and 8015 (restyled, as amended Apr. 2, 2024, eff. Dec. 1, 2024), text from <https://www.law.cornell.edu/rules/frbp/rule_8014> and <https://www.law.cornell.edu/rules/frbp/rule_8015>. This is a mirror of the official text; the official text was not fetched.
- Committee Notes to FRBP 8015 (2014, 2018, 2020, 2024), same page.
- Local Rules of the United States Bankruptcy Appellate Panel for the Eighth Circuit, December 2023 version, <https://ecf.ca8.uscourts.gov/newbap/rules/localrules_bapDec2023.pdf>, read with `pdftotext` on 2026-10-14 and again on 2026-10-16 (8014A(b)(1) form text: "NUMBER AND TITLE OF THE APPEAL", "Certification Required By L.R. BAP 8th Cir. 8014A(b)(1): ..."): L.R. BAP 8th Cir. 8014A(a)-(c), 8015A (the Panel "may accept briefs that do not meet all the requirements of" FRBP 8015).
- Not fetched: Official Form 417C; FRBP 8012; the BAP Internal Operating Procedures.

| Rule | Requirement | Where the template uses it |
|---|---|---|
| FRBP 8014(b) | Appellee's brief conforms to 8014(a)(1)-(8) and (10). Jurisdiction, issues and case (8014(a)(4)-(6)) need appear only if the appellee is dissatisfied with the appellant's statement. The list has no conclusion item (8014(a)(9)). | `required-sections` = summary of argument, argument; `needs-standard-of-review = false` |
| FRBP 8014(a)(7)-(8), (10) | Summary of argument; argument; certificate of compliance if required | section check; `certificate-of-compliance` |
| FRBP 8015(a)(7)(B)(i) | Principal-brief type-volume limit: 13,000 words, read as applying to the appellee's principal brief (see Known gaps) | `word-limit = 13000` |
| FRBP 8015(a)(2), (a)(4), (a)(5)(A), (a)(6), (g), (h) | Cover contents; layout and margins; 14 pt serif; plain roman; exclusions from length; certificate | as in `opening-brief/README.md` (same template body) |
| L.R. BAP 8th Cir. 8014A(b)(1)-(2) | Certification of Interested Parties; Certification of Related Cases | `certifications` |
| L.R. BAP 8th Cir. 8014A(c) | Service certificate for a paper copy to a non-participant | `certificate-of-service` |
| FRBP 8014(d) | No addendum section; a `# Addendum` heading is refused | as in `opening-brief/README.md` |

## Gate 2: page review

Render rechecked 2026-10-21 with Typst 0.15.1. Every page of the 22-page filing and 20-page output was rasterized at 60 dpi (`pdftoppm -r 60`) and inspected. Typst printed no warnings. The embedded font is Times New Roman (regular, bold, and italic). The output's more compact pagination is consistent throughout; its cover, certifications, tables, body headings and quotations, signature, and certificates are legible and orderly. The output differs from the filing in line justification, which is not fixed by the rules.

| Page | Content | Result |
|---|---|---|
| 1 | Cover | PASS: case number, court, caption, proceeding, title, and counsel appear in a clear hierarchy. The display type differs from the filed cover. |
| 2 | Summary of the Case and oral-argument statement | PASS: both preliminary sections are easy to distinguish. |
| 3 | Interested-parties certification | PASS: required lead, party list, and signature fit cleanly. |
| 4 | Related-cases certification | PASS: text and signature are legible. |
| 5 | Table of Contents | PASS: hierarchy and page references are clear. |
| 6 | Table of Authorities | PASS: groups and page references are aligned and readable. |
| 7 | Jurisdiction, issues, Statement of the Case | PASS: headings and body text are distinct. |
| 8 | Procedural history | PASS: paragraphs and footnote are legible. |
| 9 | Procedural history; Summary of the Argument begins | PASS: section transition is clear. |
| 10 | Summary of the Argument; Argument begins | PASS: list and heading hierarchy are clear. |
| 11 | Argument I; Legal Standards; statutory quotation | PASS: heading and quotation are distinguishable. |
| 12 | Statutory quotation and argument | PASS: quotation indentation and body text are readable. |
| 13 | Argument I; legal authorities and quotation | PASS: paragraphs and citation links are legible. |
| 14 | Argument I.B; block quotation | PASS: subsection heading and quotation are readable. |
| 15 | Argument I.B continuation | PASS: paragraphs and quotations remain distinct. |
| 16 | Argument I.B continuation | PASS: text is legible and consistently spaced. |
| 17 | Argument II | PASS: point heading and footnotes are legible. |
| 18 | Argument II; conclusion and signature | PASS: conclusion stays with the signature block. |
| 19 | Certificate of Compliance | PASS: numbered statements and certification signature are clear. |
| 20 | Certificate of Service | PASS: service statement and signature are clear. |

Pages reviewed: 20 of 20 output pages and 22 of 22 filed pages.

## Overlay

`sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief answering-brief`, exit 0, 2026-10-21. The output has 20 pages and the filed PDF has 22, so the overlay pairs by shared text rather than page number. Their typography and line justification differ; those choices are not fixed by the rules. The filed certificate of service lists counsel, while the template uses the local-rule CM/ECF wording. These open-choice differences are accepted.

## Known gaps

- **Word limit for an appellee's brief.** FRBP 8015(a)(7)(B)(i) speaks of a "principal brief"; the template applies 13,000 words to the appellee's brief, by analogy to FRAP 32(a)(7). Not confirmed against the BAP.
- **Conclusion not required.** 8014(b) does not list it; the template does not require it.
- **Word count** comes from the markdown, not the PDF text (3,228 here; the filer's Word count was 3,326).
- **Standard-of-review check** is off for this type (8014(b)(2)).
- **Certificate wording** is not verified against Official Form 417C.
- **Certifications placement:** after the cover (and any preliminary statements), before the TOC. The filing does the same.
- **TOC does not list the certifications, tables or certificates** (they are `outlined: false`). The filing lists them. Tier 3.
- **Point headings** are centered small caps; the filing's are left-aligned with a hanging numeral. Fisette's TOC also hangs the numeral. Not changed: neither rule nor a second appellee exemplar settles it.
- **Cover color:** none (FRBP 8015 has no cover-color rule).
- **One exemplar only.** Tier 2 is judged against this filing and the opening-brief exemplar (Fisette, a different filer).

## Engines

**docx** (`docx/`). Not re-run: `soffice` (LibreOffice) is not on this box, and `docx/render.sh` needs it. The old synthetic `.docx`/`.docx.pdf` outputs were removed with their sample. The docx build (`front.jq`, `brief.lua`) does not know this run's new fields (`appeal_title`, `caption[].v`, `preliminary`), so a docx of this sample would omit the summary of the case and the oral-argument statement, print "v." after the In re line, and lack the 8014A(b)(1) lead sentence. BLOCKED: docx render (no LibreOffice on this box); the docx front matter must be brought up to the typst template (fields above).

**latex**: none in this folder.
