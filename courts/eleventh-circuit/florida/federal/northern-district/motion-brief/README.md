# flnd: motion-brief

Doc type: **motion to dismiss with incorporated memorandum** in the United States District Court for the Northern District of Florida (`flnd`).
Folder: `courts/eleventh-circuit/florida/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: the whole 12-page motion and memorandum, transcribed (word-diff against the filing: body text identical; differences are caption, title, signature and running headers) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages, typst 0.15.0, pinned Times New Roman only (pdffonts), no warnings |
| overlay | ok: `usage/OVERLAY-kinsale-motion.pdf` and `OVERLAY-kinsale-motion.txt` (measured on the earlier EB Garamond render, before fb-595.68) |
| typeface | face required: **none named** (Loc. R. 5.1(C) says "at least 14-point font"; checked 2026-10-14 against the local rules PDF). Substitute: none; **Times New Roman**, the house standard (`docs/FONTS.md` rule 6; EB Garamond until fb-595.68), the exemplar's face too (known gap 2). |
| pages reviewed | 12 of 12 (every page rendered at 60 dpi and viewed after the last template change; re-checked 2026-10-14 after the fonts pass, same 12 pages, same overlay map; the earlier EB Garamond render, before fb-595.68) |
| BLOCKED | none (an exemplar was found) |

## Governing rules

Primary sources, verified 2026-10-14:

| Rule | Requirement | Where it is in the template |
|---|---|---|
| N.D. Fla. Loc. R. 5.1(B) | Case style on the first page (court, case number with judges' initials, a party on each side), then a heading identifying the document. Source: https://flnd.uscourts.gov/sites/flnd/files/local_rules/local_rules_0.pdf (see known gap 8). | `court-title`, `caption`, `brief_title`. |
| N.D. Fla. Loc. R. 5.1(C) | Double spaced; at least 14-point font; at least one-inch margins on all four sides; pages numbered. Same source. | `size: 14`, `pitch.body` (32.2 pt, measured on the filed exemplar), `margin` (base), centered page-number footer. |
| N.D. Fla. Loc. R. 5.1(D) | Attorney signature block: signature, typed name, bar number, street and email addresses, telephone; identifies the party. Same source. | `signature-block`: `firm`, `by`, `lines`. |
| N.D. Fla. Loc. R. 5.1(F) | Certificate of service with date and method, unless each party is served through the electronic system or by formal process. Same source. | The sample's "CERTIFICATE OF SERVICE" (a heading and a paragraph). The template sets the signature block before it. |
| N.D. Fla. Loc. R. 7.1(A) | A motion is in writing in the form required by Loc. R. 5.1 and 7.1. Same source. | The whole template. |
| N.D. Fla. Loc. R. 7.1(B)-(D) | Attorney conference and a certificate under a separate heading, unless the motion would determine the outcome of a claim (7.1(D)). Same source. | Content: the sample carries the 7.1(D) statement under its own heading ("LOCAL RULE 7.1(D) STATEMENT"), as the filing does. The template does not check which exception applies. |
| N.D. Fla. Loc. R. 7.1(E) | The supporting memorandum is in the same document as the motion. Same source. | `typst/layout.yaml`: the motion and memorandum are one document; unnumbered paragraphs, headings I., A., and so on. |
| N.D. Fla. Loc. R. 7.1(F) | A memorandum must not exceed 8,000 words and must include a certificate of the word count. Headings, footnotes and quotations count; the case style, signature block and certificate of service do not. Same source. | The sample's "CERTIFICATE OF COMPLIANCE WITH WORD LIMIT" (a heading and a sentence). The number is the sample's count (see below). |
| Fed. R. Civ. P. 12(b)(1), 12(b)(6), 12(f) | Lack of subject-matter jurisdiction; failure to state a claim; motion to strike. Fetched from https://www.law.cornell.edu/rules/frcp/rule_12 on 2026-10-14 (latest amendment listed: eff. Dec. 1, 2024). | Content (the sample's argument). The template does not check the defenses. |

## Word count (Loc. R. 7.1(F))

The sample's own count: **2,308 words**, from the lead-in paragraph through the word-count certificate, headings included, excluding the caption, the signature block and the certificate of service. Counted by whitespace-separated tokens on the transcribed text (`lead_in` 104 words; body from "I. INTRODUCTION" to the certificate of service, 2,204 words). The filing's own certificate says 2,286 words. The two counts differ because the filing's count is its author's, made on the original word-processor file; the transcription is the source here. The certificate in the sample states 2,308, the sample's count. Both are under the 8,000-word limit.

## Layout

- Letter paper, one-inch margins, 14-point Times New Roman, double spaced at a 32.2 pt baseline pitch.
- Court name and division centered bold; caption as in the complaint type (parties left, CASE NO. right); the title centered bold, two lines for the filing's title.
- Lead-in paragraph (frontmatter `lead_in`): unnumbered, first-line indent; states the relief and "In support, [party] states:".
- Level-1 headings (`#`): centered bold capitals (I. INTRODUCTION; III. ARGUMENT; IV. CONCLUSION; the Rule 7.1(D) statement; the certificates).
- Level-2 headings (`##`): bold, left, hanging indent (A., B.).
- Body paragraphs: unnumbered, first-line indent 0.5 in. Case names and signals in italic (`*...*`).
- Signature block, placed before the certificate of service (or at the end if there is none): "Dated:" on the left; "Respectfully submitted," then the firm lines, then "By: /s/" and the signer's lines on the right. Single spaced.

## Markdown contract (for samples)

See "Engines" below: the frontmatter fields are those the layout (`typst/layout.yaml`) reads. Body: markdown (headings `#` to `####`, paragraphs, lists, block quotations, footnotes, `*italics*`), set by the shared document model.

## What the overlay shows

`usage/OVERLAY-kinsale-motion.pdf` (measured on the earlier EB Garamond render, before fb-595.68; red = our render, blue = filed exemplar, black = both). Each page pairs with the same-numbered filed page:

    ours p.1-p.12 pair with filed p.1-p.12; word overlap 94.8, 86.8, 84.2, 78.1, 78.7, 75.6, 75.3, 70.6, 77.9, 79.8, 79.4, 86.2 %

The overlay is a diagnostic, not a score. The word-set overlap is a page-level measure; it is lowest on pp. 6 to 10 (70 to 80 %). A word-diff of the transcription against the filing's text layer (run outside the repo) found no differences in the body text, so the lower figures are the measure itself (the filing's text layer orders and hyphenates lines differently), not transcription errors.

## Gate 2 review (every page of the earlier EB Garamond PDF, before fb-595.68, at 60 dpi)

| Page | Review |
|---|---|
| 1 | Court title, caption, title (two lines), lead-in ending "In support, Militant states:". Pass. |
| 2 | I. INTRODUCTION heading; the three unnumbered paragraphs of the introduction. Pass. |
| 3 | II. RELEVANT BACKGROUND; italic case caption of the underlying action. Pass. |
| 4 | Background end; III. ARGUMENT heading; A. heading (two lines, bold, hanging); facial challenge paragraph with italic case name. Pass. |
| 5 | Italic case names and "Id." in the ripeness argument. Pass. |
| 6 | Continuation; the Northern District paragraph; *Colony* and *Northland* citations. Pass. |
| 7 | *Id.* and *See id.*; the "Dismissal without prejudice" paragraph. Pass. |
| 8 | B. heading (three lines, bold, hanging); Rule 12(b)(6) paragraph; *accord* signal. Pass. |
| 9 | *Wendy's* discussion; *Id.* at 522; the "falls on the Wendy's side" paragraph. Pass. |
| 10 | Declaratory Judgment paragraph; IV. CONCLUSION heading and conclusion. Pass. |
| 11 | LOCAL RULE 7.1(D) STATEMENT; CERTIFICATE OF COMPLIANCE WITH WORD LIMIT (2,308 words); "Dated" and signature block (firm, "By: /s/", signer, bar numbers, "Counsel for ..." italic). Pass. |
| 12 | CERTIFICATE OF SERVICE, its paragraph and the signer's name. Pass. (Tier-2 nit: the signer's name is set as a first-line-indented paragraph, not flush; the filing's layout is not reproduced here.) |

Fixed during review: (1) the signature block moved before the certificate of service, as in the filing; (2) the firm line "Attorneys for Defendant" added to the transcription (it is in the filing).

## Known gaps and open choices

1. **Only one exemplar.** Tier 2 asks for two or three filers. The CourtListener API search (`type=r`, `court=flnd`, "motion to dismiss", filed 2026-04 to 2026-10) found other N.D. Fla. motions: Howard v. Huhman, 4:26-cv-00161 (ECF 41, 17 pp.); Joshi v. OpenAI Foundation, 4:26-cv-00222 (ECF 33 and 42); Canup v. Aylstock, 3:26-cv-03359 (ECF 79, 37 pp.). Howard was downloaded and checked for text (Times New Roman 14 pt, 17 pp.) and not saved. Tier 2 is **not** judged against two filers yet.
2. **Font size and face.** The rule requires 14 point and names no face. The template uses Times New Roman 14 pt, the house standard (`docs/FONTS.md` rule 6), as the exemplar is set. Until fb-595.68 it used EB Garamond 14 pt, whose smaller x-height made the text look smaller (then ACCEPTED as a tier-2 difference). The point size meets the rule.
3. **Telephone number in the signature block.** Loc. R. 5.1(D) asks for a telephone number. The filed exemplar has none (its signature block gives the firm's PO box and email only). The sample transcribes the filing, so it has none; the template renders whatever the frontmatter gives and does not check for it. A filing built from this template should add one.
4. **Word count method.** See "Word count" above: the sample's count is 2,308; the filing's stated count is 2,286. The certificate states the sample's count.
5. **Double spacing read.** The body is double spaced at the exemplar's measured pitch. The caption, the court title, the signature block and the single-line party names are single spaced, as is customary. Recorded as an interpretation.
6. **Heading and signature wording.** "Respectfully submitted," is in title case in the template (the complaint's form); the filing uses capitals. A tier-2 choice, not asserted.
7. **Certificate-of-service signer line.** Set as a first-line-indented paragraph (see page 12). A flush or signature-column setting would match the filing more closely; not changed in this pass.
8. **Local rules version.** The local rules were read from the court's posted PDF (file metadata: created November 2015; the text is the 2015 revision that set the 14-point and 8,000-word rules). A Florida Bar News item reports "major revisions" planned for the N.D. Fla. rules; I did not confirm whether a later amendment changed Rules 5.1 or 7.1. David should check the court's current local rules before this is used as the reference.
9. **No gate scripts run.** `tools/check.sh` expects a court folder with `court.json` and `checks.yaml`; this doc-type folder is not that shape, and the brief forbids editing `tools/`. Render, overlay and the page review above are the checks run.

## Engines

On the generic federal district brief since fb-595.17.4: `typst/layout.yaml` is `base: /lib/layouts/frcp-motion-brief.yaml` plus this court's overlay, each value with its rule; the typst template only names the face; `latex/` (`template.tex`, `xdoc.lua`) and `docx/` (`reference.xml`, `xdoc.lua`) are generated from the merged layout by `fb engines gen` (do not edit them; change the layout and generate again). The old per-folder typst code and Word filter are removed. docs/EVAL-LOOP.md, "Generated engines", has the layout grammar.

| engine | output | check.sh | XENG-001..003 |
|---|---|---|---|
| typst (reference) | `usage/OUTPUT-motion-brief.typst.pdf`, 12 pages | 11 checks passed, 0 failed | reference |
| latex | `usage/OUTPUT-motion-brief.latex.pdf` | 14 checks passed, 0 failed | PASS (248/248 lines) |
| docx | `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` (LibreOffice) | 15 checks passed, 0 failed | PASS (248/248 lines) |

Frontmatter: `division`, `case_label` (default "CASE NO."), `case_number`, `caption.parties` (`names`, `designation`), `brief_title`, `signature` (`date`, `firm`, `by`, `lines`). The motion's opening paragraph moved from the frontmatter (`lead_in`) to the start of the body, so it is counted with the text. Loc. R. 7.1(F)'s 8,000 words are counted by the layout (`words.limit`, every engine: the body before the certificate of service; the render stops over it); the template asserts the certificate of the word count. The certificate of service is the body's tail, after the signature. The caption has no rule under the parties now (the exemplar has none; DEF-COVER-002 passes).

