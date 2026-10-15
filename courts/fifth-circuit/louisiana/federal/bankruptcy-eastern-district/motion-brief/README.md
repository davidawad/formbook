# laeb: motion brief (memorandum in support of a motion)

Doc type: **motion brief**: a memorandum in support of a motion (here, a motion for summary judgment in an adversary proceeding) filed in the United States Bankruptcy Court for the Eastern District of Louisiana (`laeb`).
Folder: `courts/fifth-circuit/louisiana/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-crosby-marine-26-1018-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-crosby-msj-memo.md` (the memorandum's caption, title, background, argument, conclusion, signature and certificate; the 28-page exemplar is abridged in its argument, see gap 8) |
| render | ok: `samples/OUTPUT-crosby-msj-memo.pdf`, 8 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-crosby-msj-memo.pdf` and `samples/OVERLAY-crosby-msj-memo.txt` |
| typeface | EB Garamond, 12 pt. No rule names a face, so `docs/FONTS.md` "No face named" applies and the template keeps EB Garamond (gap 2) |
| pages reviewed | 8 of 8 (re-rendered and every page viewed at 60 dpi on 2026-10-14, fonts pass; output unchanged) |
| BLOCKED | none |

File names: the brief's `samples/<id>.md` and `samples/<id>-overlay.pdf` are written as `INPUT-<id>.md` and `OVERLAY-<id>.pdf/.txt`, because `tools/render.sh` and `tools/overlay.sh` read and write those names by default (CLAUDE.md, "File roles are in the name").

## Governing rules

Primary sources, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 9013(a), (b) | A request for an order is made by written motion; a motion "must state its grounds with particularity and set forth the relief or order requested." https://www.law.cornell.edu/rules/frbp/rule_9013 (as amended Dec. 1, 2024). The memorandum states the grounds; the motion states the relief. | Not template text. The sample's frontmatter `title` names the motion; the body argues the grounds. |
| E.D. La. Local Rule 9013-2 | "Motions, objections, and responses must include authorities in support of the motion, which may be either incorporated in the pleading or set forth in a separate memorandum served on all interested parties and filed contemporaneously with the pleading." https://www.laeb.uscourts.gov/sites/laeb/files/local_rules/LocalRules050113.pdf (2013 version, effective May 1, 2013) | The memorandum is the separate document; `title` names it ("MEMORANDUM IN SUPPORT OF ..."). |
| E.D. La. Local Rule 9013-1 | Motions in writing; 21-day notice for hearing; objections and responses 7 days before hearing; ex parte list (D). Not a format rule. | Not template text. |
| Fed. R. Bankr. P. 9004(a) | "A petition, pleading, schedule, or other document must be clearly legible." https://www.law.cornell.edu/rules/frbp/rule_9004 (as amended Dec. 1, 2024) | Vendored EB Garamond at 12 pt, black on white. |
| Fed. R. Bankr. P. 9004(b) | A filed document must include a caption covering the court's name, the case's title, the case number (and adversary-proceeding number, if applicable), and a brief designation of the document's character. | `caption()`: court title, parties with designations (DEBTORS, PLAINTIFFS, DEFENDANTS), case information (case number, chapter, complex-case and section lines, adversary number); `title`. |
| Fed. R. Bankr. P. 7056 | Summary judgment in adversary proceedings: Fed. R. Civ. P. 56 applies. Cited in the exemplar's text; not separately fetched for this pass. | Not template text (the sample quotes the exemplar's text; the rule itself is not reproduced). |
| E.D. La. Local Rules, general | No rule on paper size, typeface, margins, line spacing, page limits or cover pages was found in the 2013 Local Rules (text searched for "font", "point", "margin", "spac", "page limit", "paper", "pleading"). | Typography is a convention, see gap 2. |
| E.D. La. Clerk's Notes, "Font Size" (copy retrieved 2026-10-14: https://www.laeb.uscourts.gov/sites/laeb/files/ClerksNotes704.pdf; undated), citing LBR 5005-3 | Motions, applications, memoranda and judgments/orders "must be typed or written in a size format that is sufficient to read without difficulty." Names no face. LBR 5005-3 is not in the 2013 Local Rules copy, so its current text was not read. | Vendored EB Garamond at 12 pt (gap 2). |

Not produced by this template: the ECF header line ("Case 26-10678 Doc 414-1 Filed 05/15/26 ..."), which the court's system adds on filing; the motion itself (the notice of motion and the Rule 9013 motion are separate documents with their own captions); the proposed order (Local Rule 9013-3 governs its contents); the statement of uncontested material facts and exhibits (Exs. 1-7 in the exemplar).

## Layout

- Letter paper; 1-inch margins; body double-spaced (24 pt line pitch at 12 pt, from `body-leading`); caption, block quotations, counsel and signature single-spaced.
- Caption: court title centered and bold on two lines; a left party column closed by a rule at its right edge; case information at right. Parties are separated by a blank line; the sample's own words are used between parties ("VS." in the exemplar, given as `sep: "VS."`), and the debtor's line has no separator (`sep: ""`). The exemplar uses a section sign (§) column; the rule is a convention (gap 3).
- Title centered and bold under the caption. The body starts with an unnumbered lead-in paragraph (first-line indent).
- Headings numbered by the template: level 1 "I.", level 2 "A.", level 3 "1.", with a hanging indent. A heading keeps the paragraph after it (sticky) and has one blank line above it.
- Paragraphs: first-line indent 0.5 inch, not numbered (memorandum convention; the exemplar's body paragraphs are not numbered).
- Block quotations: single-spaced, indented 0.5 inch on both sides.
- Lists: items numbered (1), (2), ... (the eight recharacterization factors in the exemplar).
- Footnotes: `text[^key]` with a `[^key]: ...` definition anywhere in the body; typst's default footnote size.
- Signature block: "Dated:" line at left; "Respectfully submitted," and the firm name, "By: /s/" and the counsel lines single-spaced on the right half. The block does not break across pages.
- Certificate of service (optional, `certificate` frontmatter): centered bold heading, the certificate text, and the signer's "/s/" line.
- Footer: "Page X of Y" centered, 11 pt.

## Overlay (`samples/OVERLAY-crosby-msj-memo.pdf`)

`tools/overlay.sh` pairs our pages with the best-matching exemplar pages by shared words (`OVERLAY-crosby-msj-memo.txt`):

| ours | filed | word overlap |
|---|---|---|
| p.1 | p.1 | 52.0% |
| p.2 | p.2 | 37.1% |
| p.3 | p.4 | 62.9% |
| p.4 | p.5 | 69.1% |
| p.5 | p.6 | 40.6% |
| p.6 | p.8 | 58.8% |
| p.7 | p.9 | 54.6% |
| p.8 | p.28 | 91.9% |

What the overlay shows, as a diagnostic (not a score): the sample's pages 1-2 pair with the exemplar's caption pages, where the exemplar has its long party list in a § column and ours has the party list in a rule-closed column; pages 3-7 pair with the exemplar's background and argument pages (the sample skips some paragraphs, so later exemplar pages can pair); page 8 (signature and certificate) pairs with the exemplar's last page. The exemplar's ECF header is not generated. Typeface differs (EB Garamond vs Times New Roman).

## Gate 2 review (pages rendered at 60 dpi and viewed)

- Page 1: court title, caption (the debtor line, the plaintiffs, the defendants list beginning with "MEGED FUNDING GROUP A/K/A ..."), case information at right. Pass. (The caption runs onto page 2 as in the exemplar.)
- Page 2: remainder of the defendants list, "DEFENDANTS", the title "MEMORANDUM IN SUPPORT OF MOTION FOR SUMMARY JUDGMENT", the lead-in paragraph starting on page 2. Pass.
- Page 3: lead-in end, "I. FACTUAL AND PROCEDURAL BACKGROUND" (bold, numbered by the template), paragraphs, "A." heading, footnote 1. Pass.
- Page 4: "A." paragraphs, "B." heading, footnote 2 (the UCC footnote). Pass.
- Page 5: "C." heading, "II. ARGUMENT AND AUTHORITIES", "A. Summary Judgment Standard" and its paragraphs. Pass.
- Page 6: "B." heading, paragraphs citing *Butner*, *R&J Pizza*, *Dryden*; "C." and "1." headings; footnote 3 (the Exs. 1-3 reference). Pass.
- Page 7: block quotation (indented, single-spaced), the factor list (1)-(8), closing paragraph, "III. CONCLUSION". Pass.
- Page 8: "Dated:" line, the signature block (firm name, "By: /s/", counsel lines, attorneys' italic line), "CERTIFICATE OF SERVICE" and the certificate with "/s/". Pass.

## Known gaps and open choices

1. **One exemplar; tier 2 needs 2 or 3 filers.** The brief asks for one exemplar per doc type. CourtListener lists other E.D. La. motions with memorandum attachments (*Rivera-Fulton, Trustee v. Patriot Marine Services*, Adv. 24-01075, motion for partial summary judgment; Markel's motion to dismiss in *Babin v. Crescent*, Adv. 24-01028), but their attachments have no RECAP file, so they could not be downloaded. The exemplar used here is the Meged/Dependance/Reliance memorandum; no other filer's memorandum is saved. Tier 2 is therefore **not** judged against 2 or 3 filers yet.
2. **Font: no face required; EB Garamond kept.** The 2013 Local Rules and the Clerk's Notes (LBR 5005-3, a size-and-legibility rule) name no typeface, so `docs/FONTS.md` "No face named" applies and the template keeps EB Garamond. The filed exemplar is Times New Roman, but the exemplar only settles what the rules leave open. EB Garamond at 12 pt reads smaller than Times at 12 pt, so the overlay text looks smaller. Whether tier 2 wants a Times-metric face (`Liberation Serif`, metric-compatible) is a question for David. If the current LBR 5005-3 text names a face, switch the font list to the `docs/FONTS.md` substitute.
3. **Caption column.** The exemplar uses a § column; the template uses a rule at the column's right edge (the form used in cand). Both are seen in practice; recorded as a convention.
4. **Caption footnote.** The exemplar's caption carries footnote 1 (the joint-administration order for lead case 25-10678 and the three related cases). Footnotes are supported in body text only, so the sample omits it. The caption text is otherwise complete, including the full defendants list.
5. **Not generated:** ECF header, the motion and notice, the proposed order, statement of uncontested facts, exhibits (see Governing rules).
6. **Local Rules currency.** The only E.D. La. Local Rules copy retrieved is the 2013 version (`LocalRules050113.pdf`). The court's current rules and its Administrative Procedures Manual could not be retrieved; they may set formatting that the 2013 rules do not. Check before this doc type is marked done.
7. **Rule 7056** is cited from the exemplar's text and was not separately fetched.
8. **Sample is abridged.** The sample transcribes the caption, lead-in, background (A-C), the argument's standard and first subsections, the eight-factor section's opening and the conclusion, the signature and the certificate, from the exemplar's text. It omits the rest of the argument (the exemplar runs to page 27); the omitted text is not needed to test the form. The sample's 8 pages are at the low end of the 8-14 target for an exemplar of this length.
9. **Signature block on the last page alone** (page 8 of the sample): the conclusion ends on page 7 and the block moves whole to page 8, as in the exemplar's last page. Not a defect; recorded so the next pass knows.
10. **Check scripts not run.** `tools/check.sh` expects a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and the brief forbids touching `tools/`. Render and overlay were run; the review above is the Gate 2 equivalent for this doc type.

## Engines

docx: `docx/build-reference.sh` writes `docx/reference.docx`; `docx/laeb-motion-brief.lua` builds the caption, court title, title, signature block, certificate of service, the heading numbers (I., A., 1.) and the (1), (2) lists. Rendered with `tools/render.sh --engine docx`.

- Matches the typst form: EB Garamond 12 pt (vendored, embedded), 24 pt exact double spacing with no extra space between paragraphs, first-line indent 0.5 in, 1 in margins on letter paper, caption with a rule at the party column's right edge, level-1 headings in bold capitals with a hanging number, level-2 bold, level-3 bold italic (hanging indents as in typst), block quotations single spaced and indented 0.5 in on both sides, signature block at 3 in with "And" between counsel blocks, certificate of service with its own heading and an /s/ line, footnotes 10 pt, footer "Page X of Y" at 11 pt (PAGE and NUMPAGES fields).
- Differs: 8 pages in both, but the breaks differ. In the .docx the heading "III. CONCLUSION" starts page 8 (typst starts page 8 with the signature block). The cause is the same as in the complaint: LibreOffice places exact-spaced lines about 11 pt lower than typst. A level-2 heading ("B. Accounts Receivable Sold by a Debtor Prepetition Are Not Estate Property") runs on one line in the .docx and wraps in typst. The numbers are literal text written by the filter.
- Checked in LibreOffice only: the .docx converted without error. Word was not available and was not checked.

BLOCKED: none
