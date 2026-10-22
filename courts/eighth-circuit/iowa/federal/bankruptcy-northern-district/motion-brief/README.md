# ianb: motion with memorandum (brief)

Doc type: **motion with memorandum** (a motion under FRBP 9013, with the grounds and the argument in support, in one document) in the United States Bankruptcy Court for the Northern District of Iowa (`ianb`). Folder: `courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes, 2 filers, each partial: `usage/FILED-EXAMPLE-motion-brief.pdf` (3 pp.: the brief in support of a motion to dismiss; the motion itself is not in RECAP) and `usage/FILED-EXAMPLE-motion-brief-2.pdf` (6 pp.: a motion to strike with its grounds and facts; no separate brief). See `usage/SOURCE.md`. |
| sample md | `usage/INPUT-motion-brief.md` (3 rendered pages; the whole brief) and `usage/INPUT-motion-brief-2.md` (6 rendered pages, 5 in EB Garamond; the whole motion) |
| typeface | face required: none (no N.D. Iowa or FRBP rule names one; checked 2026-10-14 against the 2024 Local Rules PDF, Rules 5005-1 and 9004-1 and a full-text search for font, typeface and point size). Substitute: none needed. Font: **Times New Roman** 12 pt, the house standard (`docs/FONTS.md`, rule 6; EB Garamond 13 pt until then). Not metric-compatible with any court-named face, because none is named. |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf` (3 pp.) and `usage/OUTPUT-motion-brief-2.typst.pdf` (5 pp. then), re-rendered 2026-10-14 with `tools/render.sh` (typst 0.15.0, no system fonts, exit 0, no warnings; `pdffonts` then showed EB Garamond only); the committed renders embed Times New Roman only and are 3 and 6 pages |
| overlay | **not regenerated 2026-10-14: fail.** `tools/overlay.sh` needs the filed exemplar PDFs, and `usage/` holds only `SOURCE.md` in this snapshot (no PDF on the box, none in git history). The `OVERLAY-*.txt` maps are from an earlier run and were not rebuilt. |
| pages reviewed | 8 of 8 rendered sample pages (3 + 5), each rendered at 60 dpi and viewed on 2026-10-14 after the font pass (the font did not change then; this is the re-check of the EB Garamond render) |
| check.sh | not run: same reason as `../adversary-complaint/README.md` (no `court.json` or `rules.md` in a doc-type folder). Not a stamp. |

## Governing rules

No N.D. Iowa rule found in the current local rules sets the form of a motion or a brief: there is no L.R. 9013-1 or 9013-2 in Parts 1-9 (the only "9013" entry is 9013-3). No page limit, font, size, spacing or margin is set anywhere in the parts read. The form below comes from the federal rules and from the local rules on signature, service and proposed orders.

| Rule | Requirement | Where it is in the template | Date verified and source |
|---|---|---|---|
| Fed. R. Bankr. P. 9013(a), (b) | A request for an order is made by written motion. A motion must state its grounds with particularity and set forth the relief or order requested. | `motion-brief()`: the numbered grounds and the "relief" wording. The check is a keyword test only (gap 3). | 2026-10-14, https://www.law.cornell.edu/rules/frbp/rule_9013 |
| Fed. R. Bankr. P. 9004(a), (b) | Legible; caption with court name, case title, case number and adversary number, and a designation of the document. | `caption()`: the court name, debtor and parties on the left, chapter and numbers and the title on the right. | 2026-10-14, https://www.law.cornell.edu/rules/frbp/rule_9004 (eff. Dec. 1, 2024) |
| Fed. R. Bankr. P. 7010 | Adversary-proceeding caption must substantially conform to Form 416. | `caption()` when `adversary_no` is given. The adversary caption is the form the exemplars use (see `../adversary-complaint/README.md`, gap 2). | 2026-10-14, https://www.law.cornell.edu/rules/frbp/rule_7010 |
| N.D. Iowa L.R. 9013-3 | Proof of service of every paper that must be served must be filed promptly, before action is taken, and must show the **date and manner** of service. | `certificate-of-service()` from the `service` frontmatter (`date`, `manner`, `by`). | Local Rules, Part 9, https://www.ianb.uscourts.gov/local-rules2 (PDF "Part9_0", fetched 2026-10-14) |
| N.D. Iowa L.R. 9010-1(a), (b) | Bar number on the first signed paper; below the signature: business address, telephone, e-mail and **business FAX number**. | `signature()`: `bar`, `address`, `phone`, `fax`, `email`. | Local Rules, Part 9, fetched 2026-10-14 (the 2022 compilation has no FAX; gap 6) |
| N.D. Iowa L.R. 9072-1(a)(3) | A proposed order is a separate document, with the preparing attorney's name in the lower left of the signature page. | Not generated (gap 8). | Local Rules, Part 9, fetched 2026-10-14 |
| N.D. Iowa L.R. 7037-1(a) | A motion relating to discovery is not considered unless counsel files an affidavit that counsel conferred in good faith (or certifies the efforts made). | Not generated or checked (gap 9). The Gray brief argues its absence. | Local Rules, Part 7, PDF "Part7_0", fetched 2026-10-14 |
| N.D. Iowa L.R. 9004-1(b) | Unpublished decisions of this court may be cited in briefs or memoranda. | Not checked; the author cites. | Local Rules, Part 9, fetched 2026-10-14 |
| Fed. R. Bankr. P. 9011 | Signature of the attorney. | `signature()`: "/s/" line and signer. | Cited for the signature line only; not separately fetched. |

Rule text for N.D. Iowa is taken from the current PDF parts linked on https://www.ianb.uscourts.gov/local-rules2 (Part 7 and Part 9). The PDFs carry no effective date. The 2022 compilation was also read.

## Frontmatter and body contract (for samples)

- YAML frontmatter, then the body. Required: `debtor`, `chapter`, `case_no`, `title`, `signature` (`signer`, `bar`, `firm`, `address` (list), `phone`, `fax`, `email`, `role`; `date` optional, and when absent the "Dated" line is left out), and `service` (`date`, `manner`, `by`). The fields `plaintiff`, `defendant` and `adversary_no` are required together for an adversary; omit all three for a contested matter in the main case. A missing field fails the render with a message naming it.
- Body: blank-line-separated chunks.
  - `# ...`: centered bold heading (the motion's title lines, "FACTS UPON WHICH ...", "Legal Argument"). Resets the numbering.
  - `## ...`: bold, left-aligned argument heading (for example "I. PLAINTIFF HAS FAILED ..."). Resets the numbering.
  - A chunk of `1. ...` lines: numbered by the template (1, 2, ...), continuing across chunks and restarting after each heading. Use this for the numbered grounds and facts.
  - Any other chunk: an unnumbered paragraph with a 0.5 in first-line indent.
- Footnotes: a `[^N]` reference in a paragraph and a separate `[^N]: text` chunk. cmarker drops footnote definitions, so the template places each reference as a typst footnote.
- Case names are plain roman in the transcription, matching the text layers (which have no italic markup). `*...*` italics render if a sample uses them.
- The "relief" check: the body must contain "relief", "request" or "requests" (FRBP 9013(b)).

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/motion-brief usage/INPUT-motion-brief.md
sh tools/overlay.sh courts/eighth-circuit/iowa/federal/bankruptcy-northern-district/motion-brief mcquillen-gray-brief usage/FILED-EXAMPLE-motion-brief.pdf
# same for veroblue-motion with its exemplar
```

- File names follow the tools (see `../adversary-complaint/README.md`, gap 10): `usage/OUTPUT-<id>.pdf`, `usage/OVERLAY-<id>.pdf` and `.txt`.
- Overlay pairing (word overlap, from the `.txt` maps):
  - mcquillen-gray-brief: ours p.1-p.2 ↔ filed p.1-p.2 (97%, 95%); ours p.3 ↔ filed p.3 (36%: the certificate page has no counterpart in the filed brief).
  - veroblue-motion: ours p.1 ↔ filed p.1 (81%); p.2 ↔ p.2 (85%); p.3 ↔ p.4 (58%); p.4 ↔ p.5 (59%); p.5 ↔ p.6 (80%). Our render runs one page shorter than the filing, so the page offset is about one page in the middle.
  - The overlay is a diagnostic, not a score.

## Visual review (Gate 2 record)

Every sample page was rendered at 60 dpi and looked at, after the last template change.

| Sample | Page | What it is | Finding |
|---|---|---|---|
| mcquillen-gray-brief | 1 | Caption (adversary: plaintiff and defendant on the left), COMES NOW paragraph, "Legal Argument" heading, argument heading I., first paragraph with footnote 1 reference. | OK. |
| mcquillen-gray-brief | 2 | Paragraph of I., argument headings II. and III., III. text, footnote 1 at the foot of the page. | OK. Footnote text sits below the rule on the page. |
| mcquillen-gray-brief | 3 | End of the text, signature block (no "Dated" line: the filing is undated), CERTIFICATE OF SERVICE with the date and manner placeholders. | OK as rendered. The placeholders show that L.R. 9013-3's date and manner are not on the filed copy (gap 4). |
| veroblue-motion | 1 | Caption (contested-matter form with the adversary numbers), PLEASE TAKE NOTICE paragraph with footnote 1, numbered grounds 1-3. | OK. |
| veroblue-motion | 2 | Grounds 4, FACTS UPON WHICH THE MOTIONS ARE BASED heading, numbered facts 1-6 (numbering restarts at 1). | OK. |
| veroblue-motion | 3 | Facts 7-16. | OK. |
| veroblue-motion | 4 | Facts 17-23. | OK. |
| veroblue-motion | 5 | Fact 24, the "Based on the foregoing" paragraph, signature block (one signer; the second attorney in the filing is not transcribed, gap 5), CERTIFICATE OF SERVICE with the date placeholder. | OK. |

## Engines

| Engine | Folder | Output in `usage/` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `OUTPUT-<id>.pdf` | unchanged |
| docx | `docx/` | `OUTPUT-<id>.docx` and `OUTPUT-<id>.docx.pdf` (both samples) | `usage/.check-docx.txt`: PASS (the BLOCKED notes below are from before LibreOffice) |
| latex | `latex/` | none | not built |

**docx build.** `fb render` builds the reference document from `docx/reference.xml` (`base="xengine"`, the shared cross-engine recipe in the typst face; `docx/make-reference.sh` built a committed `reference.docx` until fb-595.68). `docx/ianb-motion-brief.lua` builds the caption, the signature block and the certificate of service from the frontmatter (no case text in the filter); it numbers each item of an ordered list (the grounds and facts), restarting the count after every heading, and leaves other paragraphs unnumbered. `#` headings are centered and bold; `##` argument headings are bold and left. Footnotes are pandoc's own. Command: `sh tools/render.sh --engine docx <this-dir> usage/INPUT-<id>.md`. The command writes the `.docx` and the `.docx.pdf` (the committed `usage/.check-docx.txt` reads PASS); the notes below, through BLOCKED, were written when `soffice` was not installed and it stopped after the `.docx`.

**What matches the typst template** (set from the template's values, and the line pitch and footnote size measured on the typst PDF, not from a filed copy): Times New Roman 12 pt; 24 pt exact line pitch for body and numbered items (24.05 pt at EB Garamond 13 pt before); footnotes 11 pt at 12.7 pt single spacing; half-inch first-line indent; 1-inch margins on letter paper; the caption (3.3 in party box with a right rule and a bottom rule; the adversary lines only when `adversary_no` is given); the signature block, with "Dated" only when a date is in the frontmatter; the certificate of service (centered heading, date and manner, italic "/s/" line); a centered "Page X of Y" footer at 10 pt (PAGE and NUMPAGES fields).

**What differs or is not checked.** No docx page has been rendered or looked at, so no visual claim is made for the `.docx`. Word and LibreOffice may paginate differently (line breaks, the caption table's row height, footnote placement). The caption rules are table borders, not the typst stroke. The Times New Roman font must be installed on the machine that opens the file; it is not embedded. The paragraph spacing after each unnumbered paragraph is the typst value (0.6 em), set in the Body Text style.

**docx BLOCKED.** No `checks.yaml` exists for this court, so there are no check IDs. The blocks are these:
- `OUTPUT-<id>.docx.pdf` (Gates 0 to 3 on the LibreOffice PDF): BLOCKED. LibreOffice cannot be installed on this box: conda-forge has no `libreoffice` package and `soffice` is absent (`tools/bootstrap.sh` reports it MISSING). Neither sample's `.docx.pdf` was produced, so no gate has run on it.
- Gate 2 for the docx: 0 pages reviewed (no PDF to render; the typst renders are 3 pages for mcquillen-gray-brief and 5 for veroblue-motion).
- Opening the `.docx` in LibreOffice and Word without a repair prompt: not done (no LibreOffice; no Word).

## Known gaps and open choices

1. **No complete exemplar.** Neither filing is a motion and its brief in one PDF. The Gray filing is the brief only (its motion is not in RECAP storage). The VeroBlue filing is a motion with its own facts section and no brief. The template covers both shapes: grounds and facts as numbered items, argument under `##` headings. Whether David wants the two shapes merged, or one document per filing, is a question for him; the template produces one document.
2. **No N.D. Iowa format rule found.** No font, size, spacing, margin or page limit in the current local rules (checked 2026-10-14 against the 2024 Local Rules PDF: no face or point size anywhere, including Rules 5005-1 and 9004-1); no L.R. 9013-1 or 9013-2 exists in Parts 1-9. So the template uses Times New Roman, the house standard (`docs/FONTS.md`, rule 6; EB Garamond at 13 pt before). The form is a convention: Times New Roman at 12 pt, double spaced, one-inch margins, page numbers at the foot. Recorded as ACCEPTED.
3. **FRBP 9013(b) is checked by keyword.** The template asserts that the body contains "relief", "request" or "requests". It does not check that the grounds are stated with particularity, which is a reading question for the author.
4. **Certificate of service placeholders.** L.R. 9013-3 requires the date and manner of service. Gray has no certificate; the template renders one with placeholders, so the missing date and manner are visible. VeroBlue's certificate has no date. Both are gaps in the filed copies, flagged for David rather than filled in.
5. **Second attorney not transcribed.** VeroBlue's signature block lists two attorneys (Michael D. Schwartz, AT0013972, and Brandon M. Schwartz, AT0011248). The sample keeps the first; the template has one `signer` field.
6. **FAX line.** The current L.R. 9010-1(b) requires a business FAX number under the signature. VeroBlue's filed copy has none, so the sample shows "[not on the filed copy]". Gray's filed copy has one. Same discrepancy as `../adversary-complaint/README.md`, gap 3.
7. **Footnotes.** Handled by the template (see Body contract) in paragraphs and in numbered items. Each exemplar has one footnote. The adversary-complaint template has no footnote support and fails the render if a sample contains `[^`, so a footnote cannot be dropped silently there.
8. **Proposed order not produced.** L.R. 9072-1(a)(3) makes the proposed order a separate document. Out of scope for this folder.
9. **Discovery motions.** L.R. 7037-1(a) requires the conferral affidavit for discovery motions. The template does not generate or check it. The Gray brief argues the absence of the affidavit in the complaint's motions; that argument is the author's.
10. **Summary judgment not covered.** FRCP 56 / L.R. 7056-1 motions have their own statement-of-facts form; a Viner Law Firm brief (13 pages, RECAP entry 16 on docket 111821) was found but not downloaded.
11. **Depth.** Exemplars are 3 and 6 pages; samples render to 3 and 6 pages (3 and 5 on the earlier EB Garamond render). The brief's 8-14 page target is not reachable from these filings. Each filing is transcribed in full.
12. **Transcription faithfulness.** Typos in the filings are kept (for example "pled", "adequate", "DEFENDNAT", "indicted"). The Gray footnote's "[Doc 1]" is kept.
13. **Gates not run.** As in the adversary-complaint folder.

[Formbook index](../../../../../../README.md) | [Iowa](../../../README.md) | [adversary-complaint](../adversary-complaint/README.md)

## Current shared-model adoption status (2026-10-22)

The DOCX engine uses `docx/reference.xml` and Lua filters with the shared cross-engine layout model. The Word face is resolved from this folder's typst template. The folder has no docx shell builder/render script or binary `reference.docx`; its entry is absent from `.shell-safety-baseline.json`. The current `sh tools/check.sh` runs for typst and docx both report zero failed checks. `DEF-COVER-001` and `DEF-TOC-001` pass; the sample has no contents or authorities table. No LaTeX engine is present in this folder.

The docx check passes XENG-001..003 on every input. Older DOCX notes in this README describe the pre-adoption shell-built engine and are superseded by this status.
