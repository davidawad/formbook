# nebraskab: motion-brief

Doc type: **motion-brief** (a motion or a brief in support of, or in opposition to, a motion, with its memorandum) in the United States Bankruptcy Court for the District of Nebraska (`nebraskab`).
Folder: `courts/eighth-circuit/nebraska/federal/bankruptcy-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, 9 pages; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md` (the whole brief: caption, intro, sections I to IV with subsections A to F, signature, and the certificate's wording in frontmatter) |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 14 pages (11 on the earlier EB Garamond render: the exemplar's 9, plus the certificate on its own page), typst 0.15.0, vendored TeX Gyre Bonum only, no warnings |
| overlay | ok: `usage/OVERLAY-zuhlke-motion-brief.pdf` and `OVERLAY-zuhlke-motion-brief.txt` (page map) |
| typeface | no face required by the rules (checked 2026-10-14, see Decisions); TeX Gyre Bonum 12 pt, the face the font audit matched to the exemplar's Bookman Old Style (`data/exemplar-fonts.json`, `docs/FONTS.md`); EB Garamond 13 pt until then |
| pages reviewed | 11 of 11, on the earlier EB Garamond render (every page rendered at 60 dpi and viewed after the last change; see the review section) |

## Governing rules

Primary sources. Each text was fetched on 2026-10-14. Federal rules: Cornell LII copies of the Federal Rules of Bankruptcy Procedure (restyled text effective 2024-12-01). Local rules: the District of Nebraska Bankruptcy Court Local Rules as posted on `neb.uscourts.gov` ("2026 FINAL AMENDED", 35 pages). District rules: NECivR 7.1 as posted on `ned.uscourts.gov` (the PDF's header reads "Effective December 1, 2021"; the URL is the 2022-12 folder).

| Rule | Requirement | Where in the template / sample |
|---|---|---|
| FRBP 9013(b) | A motion must state its grounds with particularity and set forth the relief or order requested. (Fetched text.) | The sample's grounds and relief sections (the brief states the grounds in Sections II to IV and asks for relief in Section IV). |
| FRBP 9004(a)-(b) | Legible; caption with the court, the title, the case and adversary numbers, and the document's designation. | `caption()`: court name, *In re* block, parties, case and adversary numbers, title in the right column. |
| FRBP 9011(a) | Signed by at least one attorney of record in the attorney's own name, with the signer's address and telephone number. | `signature-block()`: "By: /s/" line, printed name, bar number, firm, address, telephone, email. |
| LR 9011-1(B) | A CM/ECF filing may be signed "/s/" followed by the printed name. | "By: /s/ Richard P. Garden, Jr." |
| LR 7007-1(A) | In an adversary proceeding, a motion states its basis and the specific relief requested. LR 9013-1 does not apply to adversary motions, except as stated in LR 7041-1. | Section IV (CONCLUSION) requests specific relief. The template does not check the wording. Conflict: General Order 22-08 (2022) replaced LR 9013-1 and says its procedure applies to "bankruptcy cases and adversary proceedings"; the 2026 text is later and excludes adversary motions. The court has not reconciled them in the posted text; which one governs is not settled here. |
| LR 7007-1(B) | If a motion raises a substantial issue of law, the movant files a supporting brief at the same time. Without a brief, the motion may be deemed abandoned. | The template produces the brief; the filing sequence is not checked. |
| LR 7007-1(C) | An opposing brief is due 14 days after the motion, or 21 days when the motion is for summary judgment, to dismiss, or for judgment on the pleadings. A failure to file an opposing brief is not a confession, but it precludes contesting the movant's statement of facts. | Not in the template. The sample is an opposing brief to a summary-judgment motion. |
| LR 7007-1(E) | A brief concisely states the factual and legal basis and cites authority. A factual assertion cites the evidentiary item by docket number and page number. | Citations are typed by the author (the template does not check them). The exemplar cites declarations by docket number and paragraph (e.g. "Popwell Declaration, Doc. 120 at ¶3"), not by page; see Decisions. |
| LR 7007-1(F) | Evidence not in the pleadings must be filed with a separate index of evidence before the brief. Items already on the docket (including proofs of claim) are not re-filed. | Not in the template (a separate filing). |
| LR 7007-1(G) | No oral argument unless a separate motion, filed no later than the brief, asks for it and states the time needed. | Not in the template. |
| LR 5005-1(C) and Appendix E | A party files a certificate of service stating how service on non-CM/ECF participants was made. | `certificate()`: CM/ECF wording (the exemplar's wording). The Appendix E forms for mail service are not implemented (see Known gaps). |
| LR 1015-1(A)-(B) | Joint administration is sought by motion, except that spouses' estates are jointly administered unless an objection is filed; after joint administration is ordered, captions state that the cases are jointly administered. | Not applied. The Zuhlke debtors are spouses, so LR 1015-1(A) may apply automatically; the exemplar's caption does not say "jointly administered", and whether joint administration was "ordered" is not checked. Not asserted in the sample. |
| NECivR 7.1(d) (district civil rules) | A supporting or opposing brief may not exceed 13,000 words, and a brief includes a certificate of compliance stating the word count. | **Not applied.** Whether the district's civil rules reach an adversary proceeding is not confirmed (LR 1001-1(B) makes the district's "General Rules" applicable; NECivR is the civil rules). The exemplar has no word certificate. See Known gaps. |

Not checked: the brief cites Neb. R. Bankr. P. 7056-1(B) for the statement of facts. The 2026 local rules text posted by the court has no Rule 7056-1 (a search of the text for "7056" finds nothing). The rule may be in an earlier local rules version, or the citation may be wrong; this is an open question for the court's current rules, not settled here.

## Layout

- Court name, centered and bold, two lines (constant for this court).
- Caption in two columns: the *In re* block with a rule under it; the parties with "v." between them; intervenors after the parties (no "v."). The right column holds the case number, the adversary line and the title in bold capitals (as in the exemplar).
- Body: double spaced (28.8 pt pitch at 12 pt, typst `pitch-double`), 1-inch margins, letter paper, left-aligned.
- `##` headings are sections: centered, bold, capitals, with roman numerals I., II., ... generated by the template. `###` headings are subsections: bold, left, with A., B., ... generated by the template and restarting under each section. The sample types no numbers.
- Paragraphs are not numbered by the template. The exemplar's responses to the statement of facts are numbered 1 to 8 by the author, so the sample types them with an escaped period (`1\.`), which the markdown renders as text.
- Signature block after the conclusion, in the right-hand column, kept together (non-breakable).
- Certificate of service on its own page, generated from frontmatter (`certificate.date`, `certificate.signer`), with the CM/ECF wording.
- Section symbols: non-breaking space after "§" (and before it), as in the complaint template.

## Markdown contract (for samples)

Frontmatter:

| Field | Type | Feeds |
|---|---|---|
| `in_re` | list of strings | the *In re* block |
| `case_lines` | list of strings | the case number lines, e.g. `Case No. BK 24-40267-BSK`, `(Chapter 7)` |
| `adversary_line` | string | e.g. `Ad. Proc. 24-4011-BSK` |
| `parties` | list of `{names: [...], designation: "Plaintiff,"}` | the party block, "v." between parties |
| `intervenors` | optional list of `{names, designation}` | blocks after the parties, no "v." |
| `title` | string | the document title, in bold capitals in the right column |
| `signature` | `{party: "...", lines: [...]}` | the party line and the signer's lines (first line `By: /s/ Name`) |
| `certificate` | `{date: "...", signer: "..."}` | the certificate of service (required; the template fails without it) |

Body: `## SECTION` (roman), `### Subsection` (letter), blank-line-separated paragraphs. Do not type numbers or letters for sections and subsections. Case names: `*Name*` (italic, as the exemplar's italic case names). Footnotes: `text[^key]` with a definition line (rendered at 11 pt; the sample has none).

## Engines

Three engines, one markdown sample (`usage/INPUT-motion-brief.md`). The typst template is the reference for the layout.

| Engine | Files | Status |
|---|---|---|
| typst (primary) | `typst/`, `usage/OUTPUT-motion-brief.typst.pdf` | rendered (see above) |
| latex | none in this folder | not built |
| docx | `docx/` (`reference.xml`, from which `fb render` builds the reference document on the shared cross-engine recipe, and `nebraskab-motion-brief.lua`; until fb-595.68 `build-reference.sh` and `render.sh` with a committed `reference.docx`), `usage/OUTPUT-motion-brief.docx`, `.docx.pdf` | `usage/.check-docx.txt`: PASS (the BLOCKED notes below are from before LibreOffice) |

**docx, what matches the typst template** (the same values, set as Word styles in `docx/reference.xml` and by the filter): US Letter, 1 in margins; TeX Gyre Bonum 12 pt; body double spaced (28.8 pt exact) with a 0.5 in first-line indent; caption, signature and certificate single spaced (14.4 pt exact); footnotes 11 pt in 13.2 pt lines; page number centered in the footer. Caption: the court name; the *In re* block with a rule under it; the parties with "v."; intervenors after them, with no "v."; the case lines and the adversary line on the right, then the title in bold capitals, in a borderless three-column table (3.4 in, 0.25 in gutter, 2.85 in). `##` headings are centered bold, numbered I., II., ... by the filter; `###` headings are bold with a hanging A., B., ... that restart under each section. The signature block is kept on one page. The certificate of service starts on its own page, with the CM/ECF wording of the typst template.

**docx, what differs** (written for the earlier build, before fb-595.68):
- Section numerals and subsection letters are typed text (a tab after the letter), not Word list numbering. They read the same; they do not renumber when a heading is added in Word.
- The caption rule is a paragraph border under the *In re* block, not a drawn line.
- `render.sh` (since retired into fb render) widened the caption and signature tables to the 6.5 in text width after pandoc (pandoc writes a 5.5 in grid). Word may still paginate differently from the LibreOffice PDF.
- The font is named as TeX Gyre Bonum. A reader without it installed sees a substitute.

**docx BLOCKED** (then; the committed `usage/.check-docx.txt` now reads PASS):
- Every `.docx.pdf` check (Gates 0 to 3, measured on the LibreOffice PDF from `soffice --headless --convert-to pdf`): BLOCKED. LibreOffice is not on conda-forge and could not be installed on the build box (no root). No page of the `.docx` has been rendered or viewed, so no visual claim is made for the docx.
- The `.docx` is a valid zip (`unzip -t`) and its `word/document.xml` is well-formed (`xmllint`, in `render.sh`). Other parts are not schema-checked, and a Word or LibreOffice open without a repair prompt is not checked.
- `tools/check.sh` needs a court root (`court.json`, `rules.md`, `checks.yaml`); this doc-type folder has none, so the repo gates do not run on it.

## Decisions

- **Exemplar is a brief in opposition, not the original motion.** The brief type covers the memorandum that accompanies a motion; LR 7007-1(B) requires such a brief to be filed alongside a motion raising a substantial issue of law. The template takes any body, so the same template serves a motion's supporting brief or a brief in opposition; the caption title carries the difference.
- **The filer's typo is kept.** The caption reads "TRUSTEEE" (the exemplar's own spelling). The sample transcribes the filing as it was filed.
- **Declarations cited by paragraph.** The exemplar cites declarations with "Doc. 120 at ¶3". LR 7007-1(E) asks for a page number; the paragraph form is what the exemplar uses. The sample keeps the exemplar's citations. A clerk may ask for page numbers; this is a tier-2 point, not a template rule.
- **Certificate on its own page.** The exemplar puts its certificate on page 9 after the signature. The template starts the certificate on a new page; the rules do not fix the position.
- **Font, margins, spacing:** TeX Gyre Bonum 12 pt, the font audit's match for this exemplar's Bookman Old Style (`data/exemplar-fonts.json`); 1 inch margins and double spacing as in the adversary-complaint template (which is Times New Roman), see `../adversary-complaint/README.md`. Both were EB Garamond 13 pt before. The typeface check (2026-10-14) covered the same texts: the local rules and NECivR 7.1 name no face or size, so no court-named substitute applies.

## Known gaps and open questions

1. **One exemplar, one filer.** Tier-2 review is against one filer (Cline Williams, for the trustee). Doc 81 of the same adversary (a 12-page brief in support of an objection, same filer) was read for conventions and not saved. A brief from a second filer was not found in this court in the searches run (CourtListener, `type=r`, `court=nebraskab`, "brief in support motion", "memorandum in support motion to dismiss", "brief in opposition motion").
2. **Word limit (NECivR 7.1(d)) not applied.** See the rules table. If the district's civil rules apply to adversary proceedings, the template needs a word-count certificate with the software and version, and a limit check.
3. **Mailed service not implemented.** A motion that must go to the mailing matrix needs the Appendix B forms of General Order 22-08 (the matrix attached to the certificate, with unserved parties crossed out for limited notice). The template produces only the CM/ECF certificate. The template cannot yet produce a motion's mailed-service certificate.
4. **Firm document number omitted.** The exemplar's last line ("4927-3540-1811, v. 1") is the firm's document ID, printed by the filer's word processor. It is not a court requirement and is not transcribed.
5. **Evidence index (LR 7007-1(F)) and oral argument (LR 7007-1(G))** are separate filings; the template does not produce them.
6. **Rule 7056-1(B) citation.** See the note under the rules table: the 2026 local rules text posted by the court does not contain it.
7. **Check scripts not run.** `tools/check.sh` expects a court root with `court.json` and `rules.md`, and this folder is not that shape. The brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent for this doc type.
8. **No `reviews/` folder** for this doc type; the review is recorded here.

## Review of the rendered pages (final EB Garamond build, 11 pages)

Each page was rendered at 60 dpi and viewed after the last change. Paragraphs were read from the PDF text layer.

- Page 1: court name; *In re* block with the rule under it; the trustee party, "Plaintiff,"; "v."; the defendants; the intervenor; the intro paragraph; the title in the right column; section I heading; the typed responses 1 to 3. Pass.
- Page 2: responses 4 to 8; section II heading; the first two evidence paragraphs. Pass.
- Page 3: the rest of the evidence paragraphs (the state-court actions, the unsecured claims, the stay). Pass.
- Page 4: section III heading; subsection A heading (sticky with its paragraphs); the first two paragraphs of subsection A (the § 544(b) quotation and the *Stalnaker* paragraph). Pass.
- Page 5: subsection B heading (sticky with its first paragraph); the paragraphs of B and the § 36-805 paragraph. Page 5 ends with some blank space because the subsection C heading and its paragraph moved to page 6 as a unit. Page 4 also ends with blank space, for the same reason (the subsection B heading moved to page 5). Pass.
- Page 6: subsection C heading; the first paragraphs of C (the *McElwee* distinction and the § 544(b)(1) text). Pass.
- Page 7: the rest of subsection C; subsection D heading (sticky) and its first paragraph. Pass.
- Page 8: the rest of subsection D; subsection E heading and its paragraphs (Rule 3001(f) and § 506(a)); the *Heritage Highgate* sentence. Pass.
- Page 9: the rest of the *Heritage Highgate* paragraph and the Morales and related citations; the *Bassett* paragraph; subsection F heading and its first paragraph. Pass.
- Page 10: the rest of subsection F; section IV heading; the conclusion; the signature block (party line, "By: /s/", the signer, the firm and the contact lines), kept together. Pass.
- Page 11: certificate of service (CM/ECF wording, the date, "/s/" and the printed name). Pass.

No heading at the foot of a page without its text; no section number or subsection letter missing or repeated; italic case names as the exemplar shows them; the signature block is not separated from the conclusion; the caption block does not overlap the title.
