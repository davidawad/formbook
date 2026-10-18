# Eighth Circuit BAP (bap8): answering brief (appellee's brief)

- Court: `bap8`, United States Bankruptcy Appellate Panel for the Eighth Circuit (`courts/eighth-circuit/bankruptcy-appellate-panel/`). Court-root `typst/` and `usage/` are untouched.
- Doc type: `answering-brief`. Appellee's brief, FRBP 8014(b).
- **Exemplar: yes.** `usage/SAMPLE-bap8-answering-brief-swackhammer226006.pdf`: Appellees' Brief, *Farm Credit Services of America, PCA v. Swackhammer*, BAP No. 22-6006, filed 2022-12-23 by Robert C. Gainer (Cutler Law Firm, P.C.) for the debtor-appellees (22 pages, text PDF, Word 2021). Found 2026-10-16 in CourtListener RECAP, where BAP dockets sit under court id `ca8` (not `bap8`). Source details in `usage/SOURCE.md`.
- **Sample: transcription.** `usage/INPUT-bap8-answering-brief-swackhammer226006.md` transcribes the whole filing: cover, summary of the case, oral-argument statement, both certifications, the full body (filing pp. 1-13, all six footnotes and the four block quotations), signature, certificates. The tables are rebuilt by the template from the headings and `toa:` links.
- Render: ok, `usage/OUTPUT-bap8-answering-brief-swackhammer226006.typst.pdf`, 22 pages (the filing is also 22), typst with no warnings (2026-10-16). `pdffonts`: EB Garamond only.
- Overlay: ok, `usage/OVERLAY-swackhammer-22-6006.pdf` and `.txt` (2026-10-16). Diagnostic only, see below.
- Pages reviewed: 22 of 22 as PNG at 60 dpi (2026-10-16), compared with filing pages 1, 2, 5, 8 and 13 rendered at 50 dpi.
- Superseded: the synthetic sample (`INPUT-synthetic-answering-brief.md`) and its `OUTPUT-` `.pdf`, `.docx`, `.docx.pdf` were removed. The docx outputs for the new sample were **not** made: LibreOffice (`soffice`) is not installed on this box, so `docx/render.sh` cannot run. See Engines.
- Status: `court.json` untouched; `status` not set.

## Files

| Path | What |
|---|---|
| `typst/main.typ` | Entry point; reads `--input sample=...` (default now `usage/INPUT-bap8-answering-brief-swackhammer226006.md`) and calls `bap8-brief`. |
| `typst/bap8-answering-brief.typ` | Template. Parameter block at the top: `doc-kind`, `word-limit` (13,000), `required-sections` (FRBP 8014(b): summary, argument), `needs-standard-of-review = false`. |
| `usage/INPUT-bap8-answering-brief-swackhammer226006.md` | Transcription of the filed brief (contract below). |
| `usage/OUTPUT-bap8-answering-brief-swackhammer226006.typst.pdf` | Render (`sh tools/render.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief usage/INPUT-bap8-answering-brief-swackhammer226006.md`). |
| `usage/OVERLAY-swackhammer-22-6006.pdf`, `.txt` | Overlay (`sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief swackhammer-22-6006`). |
| `usage/SAMPLE-bap8-answering-brief-swackhammer226006.pdf`, `usage/SOURCE.md` | The filed exemplar and its source and search log. |

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

Transcription notes for `INPUT-bap8-answering-brief-swackhammer226006.md`:
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

Render of 2026-10-16, every page rasterized at 60 dpi (`pdftoppm -r 60`) and viewed. Typst printed no warnings. Fonts embedded: EB Garamond only. Exemplar pages compared: 1 (cover), 2 (summary of the case), 5 (contents), 8 (body page 1), 13 (body page 6, Argument heading).

| Page | Content | Result |
|---|---|---|
| 1 | Cover: BAP No., court (two lines, break before "for the Eighth Circuit"), In re line, appellant, v., appellees, trustee, proceeding, title, counsel | OK after fixes 1 and 2. Same parts in the same order as filing p. 1. |
| 2 | Summary of the Case; Oral Argument Unnecessary (i) | OK. Double-spaced, as filing p. 2. |
| 3 | Certification of Interested Parties (ii) | OK after fix 3: number and title, then the rule's lead sentence; 11 parties; signature. |
| 4 | Certification of Related Cases (iii) | OK. |
| 5 | Table of Contents (iv) | OK after fix 5. Lists the two preliminary statements at "i", like the filing. The filing also lists the certifications and the tables; ours does not (tier 3). |
| 6 | Table of Authorities (v): cases, statutes, rules, other | OK after fix 5 (*Jellings* entry wraps with its pages on the last line). |
| 7 | Jurisdictional Statement; Issues; Statement of the Case, A. Background, B. Procedural History (1) | OK. |
| 8 | Statement of the Case (2); footnote 1 | OK. |
| 9 | Statement of the Case (3); footnote 2 (single-spaced) | OK. |
| 10 | Statement of the Case end; Summary of the Argument (4); footnote 3 | OK. |
| 11 | Summary of the Argument with the bulleted list (5); footnote 4 | OK. |
| 12 | Summary end; Argument; point heading I; A. Legal Standards (6) | OK. Point heading is centered bold small caps; the filing's is left, bold, with a hanging "I." (tier 3, not chased). |
| 13 | § 1229 block quotation (7) | OK. Single-spaced, indented both sides. |
| 14 | Quotation end; Jellings, Dittmer; legislative-history quotation (8) | OK. |
| 15 | Jellings quotation; Wruck; Cockhren (9) | OK. |
| 16 | Acceptance; sub-heading B; Jellings quotation (10) | OK. |
| 17 | Argument I.B continued; Schnakenberg quotation begins (11) | OK. |
| 18 | Quotation end; point heading II; footnote 5 (12) | OK. |
| 19 | Argument II end; footnote 6 (13) | ACCEPTED: bottom half of the page is blank because the Conclusion heading and paragraph are kept with the signature block on the next page (template rule: the signature never stands alone). |
| 20 | Conclusion; signature block (14) | OK. |
| 21 | Certificate of Compliance (15): 3,228 words (the filing states 3,326) | OK. The count is the template's count of the transcription. |
| 22 | Certificate of Service (16) | OK. |

Pages reviewed: 22 of 22.

## Overlay

`sh tools/overlay.sh courts/eighth-circuit/bankruptcy-appellate-panel/answering-brief swackhammer-22-6006`, exit 0, 2026-10-16. Page pairing by shared words: ours 1-6 pair with filed 1-6 at 49-90%; body pages 7-18 pair with filed 8-19 at 52-88% (one page behind, because the filing has a sixth front page, vi, for statutes); ours 19-21 with filed 19-21 at 42-69%; ours 22 (service) pairs with filed 4 at 24% (no real match: the filing's service certificate lists counsel, ours uses the CM/ECF sentence). The lines do not coincide: the filing is Times New Roman with full justification; ours is EB Garamond 14 pt ragged right. Tier 3, not chased.

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
