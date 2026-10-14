# nynb: motion-brief

Doc type: **memorandum of law in support of a motion** (FRBP 9013 motion with its memorandum) in the United States
Bankruptcy Court for the Northern District of New York (`nynb`). The sample is a Rule 12(b)(6) motion to dismiss in an
adversary proceeding (FRBP 7012(b)).
Folder: `courts/second-circuit/new-york/federal/bankruptcy-northern-district/motion-brief/`.

**BLOCKED: no exemplar.** No public filed N.D.N.Y. bankruptcy memorandum of law could be retrieved; the searches are
recorded in `exemplars/SOURCE.md`. The template is built from the rules. Tier 2 cannot be judged against filings for this
doc type. Tier 1 is judged below against the primary sources.

| Item | Status |
|---|---|
| exemplar | **no** (`exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-rule-derived-motion-brief.md`: **rule-derived and fictional**, not a transcription of any filing. Frontmatter contract below. |
| render | ok: `samples/OUTPUT-rule-derived-motion-brief.pdf`, 7 pages, letter, EB Garamond only (embedded: Regular, Italic, Bold, BoldItalic), `tools/render.sh` exit 0, no typst warnings |
| overlay | **fail**: `tools/overlay.sh` exits 1 with "no exemplar pdf in exemplars". No `OVERLAY-` file was written. |
| pages reviewed | 7 of 7, each rendered at 60 dpi and viewed. The last change moved only the certificate's signature line (page 7). |

The sample is 7 pages. The wave brief's 8 to 14 page target was written for a transcribed exemplar of that length; with no
exemplar it is not a requirement here, and the sample is not padded to reach it.

File names: `INPUT-rule-derived-motion-brief.md` and `OUTPUT-rule-derived-motion-brief.pdf` (the repo's default names; see the
note in `../adversary-complaint/README.md`).

## Markdown contract (frontmatter)

| Key | Meaning |
|---|---|
| `chambers_copy` | `true` prints `ECF CASE – CHAMBERS COPY` at the top right of page 1 (LBR 9013-1(h)) |
| `counsel` | list of lines, single-spaced, top left of page 1 (optional) |
| `debtor.names`, `debtor.tin` | the debtor under "In re:" |
| `case_number`, `chapter` | right column of the bankruptcy caption |
| `hearing.date`, `hearing.time`, `hearing.location` | printed above the case number (LBR 9013-1(g)(1); see the first gap below) |
| `adversary` | optional. When present, an adversary caption is printed below the bankruptcy caption |
| `title` | centred bold title of the memorandum |
| `dated`, `signature.firm`, `signature.signer`, `signature.lines` | the date and signature block |
| `certificate.paragraphs`, `certificate.dated`, `certificate.signer` | the certificate of service, printed after the signature block |

Body: blank-line-separated chunks. `#` is a centred bold heading (PRELIMINARY STATEMENT, ARGUMENT), `##` a bold heading
flush left (a POINT), `###` a bold italic heading flush left. A chunk starting `>` is a block quotation, single-spaced and
indented on both sides. Every other chunk is an unnumbered, double-spaced paragraph with a first-line indent.

## Governing rules

Primary sources, fetched 2026-10-14 (the date verified for every row).

| Rule | Requirement | Kind | Where it is in the template |
|---|---|---|---|
| LBR 9004-1(a)(1)(A)-(E), (a)(2)(A)-(C) (N.D.N.Y. Local Bankruptcy Rules, effective 12-01-2024; the PDF used is https://www.nynb.uscourts.gov/sites/nynb/files/LBR_GenOrders/Local%20Bankruptcy%20Rules_Effective%2012-01-2024%20Final.pdf) | 12-point minimum (text and footnotes); double-spaced except block quotations and footnotes; legible, single-sided, black; one-inch margins on all four sides; consecutively numbered pages; letter size | M | `type-size`, `pitch`, `body-leading`, `margin`, page numbering, `paper: "us-letter"` |
| LBR 9004-1(c) | Caption: court name, case title, case number and chapter, last four SSN/TIN digits, adversary name and number if pertinent, short title naming the document and the party | M | `bankruptcy-caption`, `adversary-caption`, `title` |
| LBR 9013-1(a)(1) | The notice of motion sets out the specific relief, the party against whom it is sought, and the rule or statute relied on | M (for the notice of motion; the memorandum states the same) | the sample's first paragraph and Points I to III state the relief, the party and the rules (Rules 12(b)(6), 9(b), 7012(b); 11 U.S.C. §§ 544(b), 548(a)(1)(A)) |
| LBR 9013-1(c) | A certificate of service on registered and non-registered users, stating the manner of service on each party | M | `certificate` (the sample states CM/ECF and first-class mail) |
| LBR 9013-1(e) | A motion is filed and served at least 21 days before the return date | A (timing) | not checked; the return date in the sample is 2026-11-19 and its service date is the author's |
| LBR 9013-1(g)(1) | "The date, time, and location of the hearing shall be included above the case number in the caption." This sentence is in the answering-papers paragraph of the rule. | M for answering papers; applied here to the moving memorandum by convention | `hearing` lines printed above `Case No.` |
| LBR 9013-1(h)(1)(F) (Albany) and (h)(2)(D) (Syracuse and Utica) | Chambers copy, marked "ECF CASE – CHAMBERS COPY", for memoranda of law | M (marking); delivery is an author duty | `chambers_copy` legend |
| LBR 7056-1(b) | Summary-judgment memorandum: cites all authorities and discloses controlling contrary authority | A (not this template's doc type) | none; the sample is a 12(b)(6) memorandum |
| FRBP 9013 (Cornell LII, fetched 2026-10-14) | "A request for an order must be made by written motion unless…" | M (the motion, not the memorandum) | content |
| FRBP 7012(b) and Fed. R. Civ. P. 12(b)(6), 9(b) (via FRBP 7009) | Motion to dismiss in an adversary proceeding; fraud pleaded with particularity | content | sample Points I and II |

Rows marked M are the tier-1 requirements. Layout choices the rules leave open: the centred bold title, the heading
hierarchy, the placement of the hearing block in the caption (see gap 1), the block quotation style, and the signature
and certificate layout. These are tier 2 by default and unjudged until an exemplar exists.

The LBR text found contains no page limit for memoranda of law. The only "page limit" text in it is a copy-fee item.
Individual judges may set page limits or other requirements; the author checks those, and the template does not.

## What the overlay shows

Nothing. There is no filed exemplar to overlay, so `tools/overlay.sh` cannot run (exit 1). The overlay is a tier-3
diagnostic in any case.

## Known gaps

1. **Hearing block above the case number on a memorandum.** LBR 9013-1(g)(1) puts the hearing above the case number for
   answering papers. The template applies it to the moving memorandum too, by convention, because the NDNY text found does
   not say where the hearing goes on a moving memorandum. Confirm against the court's own practice or an exemplar.
2. **No exemplar, so tier 2 is unjudged.** Heading styles, the title block, signature placement and the certificate layout
   are our choices.
3. **No table of contents or table of authorities.** The rules found do not require either for this memorandum, and the
   sample is short. Judges may require them for longer briefs; that would need a TOC and TOA template added.
4. **Footnotes are not exercised** by the sample. The 12-point rule for footnotes is stated but no footnote is rendered.
5. **Not rendered, author responsibility:** the notice of motion itself (LBR 9013-1(a)(1) requires the notice to state the
   relief, the party and the rule), the proposed order, the Statement of Material Facts for a summary-judgment motion (LBR
   7056-1(a)), the chambers copy's delivery (LBR 9013-1(h)), the 21-day service (LBR 9013-1(e)), and the adjournment and
   withdrawal forms (LBR 9013-1(i) to (n)).
6. **No gate checks.** There is no `checks.yaml` for this doc type, so `tools/check.sh` is not wired here and no stamp
   exists. Gates 0 and 1 are not run.
7. **Typeface.** LBR 9004-1 sets a minimum size, not a typeface. EB Garamond is our choice, vendored in `fonts/`.
