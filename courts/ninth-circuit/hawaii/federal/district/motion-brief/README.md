# hid: motion-brief

Doc type: **motion with memorandum in support** (FRCP 12 motion) in the United States District Court for the District of Hawaii (`hid`).
Folder: `courts/ninth-circuit/hawaii/federal/district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `usage/FILED-EXAMPLE-motion-brief.pdf` (1 filer, the State of Hawai‘i defendants; a Rule 12(c) motion, not 12(b); see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-motion-brief.md`: an excerpt of the memorandum (Background, Legal Standard, the first part of Argument A, Conclusion) and the motion paragraphs, caption and signature |
| typeface | Times New Roman required (LR 10.2(a)(2)) → **Times New Roman** 14 pt (vendored), footnotes included, in typst and docx alike (fb-595.68.22; was Liberation Serif). |
| render | ok: `usage/OUTPUT-motion-brief.typst.pdf`, 14 pages, Times New Roman, typst 0.15.0, vendored fonts only, no typst warnings. Body pitch `pitch-double = 32.2pt` (fb-595.68.22). |
| overlay | **fail**: `tools/overlay.sh` needs `usage/SAMPLE-*.pdf`, which is not in this snapshot (`usage/` holds `SOURCE.md` only). `usage/OVERLAY-*` is stale (from EB Garamond) and must be regenerated once the exemplar PDF is restored. |
| pages reviewed | 14 of 14 of the Liberation Serif render, at 50 dpi as a contact sheet; body text not read at full resolution. The Times New Roman render is not re-reviewed page by page (fb-595.68.22). |

File names follow the tools' convention, not the brief's `<id>.md` shorthand: `tools/render.sh` writes `OUTPUT-<id>.pdf` and `tools/overlay.sh` reads it and writes `OVERLAY-<id>.pdf` / `.txt`.

## Typeface

LR 10.2(a)(2): "All memoranda, including footnotes, shall utilize 14-point Times New Roman plain style, except that italics, underlining, or boldface may be used for emphasis." The court names a face, and the template sets it: vendored **Times New Roman** 14 pt (`font-family` in `typst/hid-motion-brief.typ`), footnotes included, in typst and docx alike (fb-595.68.22; was Liberation Serif, the metric substitute). The double-spaced pitch is `pitch-double = 32.2pt` (2.3 x 14 pt; the exemplar's 32.3 pt, LR 10.2(a)(4)); single lines are 16.1 pt, the counsel block 12 pt in 13.8 pt lines. The render is 14 pages.

## Governing rules

Primary sources. Each rule text was read from the source named; the local rules are from the copy the court posted, which is the 2019 amended text (effective 2019-09-01), read 2026-10-14. Later amendments, if any, are not checked here.

| Rule | Requirement | Where it is in the template | Kind |
|---|---|---|---|
| Fed. R. Civ. P. 12(b)(6) and 12(c) (https://www.law.cornell.edu/rules/frcp/rule_12, read 2026-10-14) | Defenses by motion; judgment on the pleadings. The motion form is the same for either. | `motion` paragraphs (frontmatter); the Rule number is text in the sample. | — (content) |
| D. Haw. LR 10.1 and 10.2(a)(1) (court's posted Local Rules, https://www.hid.uscourts.gov/files/order532/2019_08_26_administrative_Order%20Amending%20the%20Local%20Rules%20eff%202019_09_01(1).pdf, read 2026-10-14) | White opaque 8½ × 11 paper, one-inch margins, one side of each sheet. | `page-margin = 1in`, US-letter, one-sided PDF. | M |
| LR 10.2(a)(2) (same) | 14-point Times New Roman plain style for all memoranda, footnotes included (italics, underlining and boldface allowed for emphasis). | `type-size = 14pt` everywhere (body, headings, footnotes, quotations); typeface Times New Roman (see "Typeface"; fb-595.68.22). | M |
| LR 10.2(a)(4) (same) | Double-spaced, except counsel identification, title of the case, footnotes, quotations and exhibits. | `pitch-double = 32.2pt` (2.3 x 14 pt; fb-595.68.22), the exemplar's 32.3-pt pitch (`pdftotext -bbox`). Footnotes, block quotations, caption and counsel are single-spaced. | M |
| LR 10.2(b) (same) | Counsel's name, Hawaii bar number, address, telephone and email, and the party each represents, upper left of the first page. | `caption()`: `counsel.columns` (two columns for the AG counsel), `counsel_for`. | M |
| LR 10.2(c)(1)–(4) (same) | After counsel: title of the court; title of the action; case number followed by the judge's initials; title of the document. | `court-title`, `parties`, `case_number` (carries the judge initials, e.g. `-HG-WRP`), `title`. | M |
| LR 7.3 (same) | Below the title of a motion or related document: (a) date and time of the hearing when known, (b) the presiding judge, (c) the trial date when known, (d) the docket number of a document to which the filing relates. | `caption()`: `Judge:` (required), `hearing` and `trial_date` (printed when given). (d) applies to responses and replies, not the motion; not in the sample. | M |
| LR 7.4(a) (same) | A memorandum shall not exceed 25 pages unless it complies with LR 7.4(b) and (e). | The memorandum's pages are counted by `context` at the end of the body; over 25 pages, the build requires the word alternative (below). | M |
| LR 7.4(b) (same) | A memorandum may exceed 25 pages if it contains no more than 6,250 words. | `word-limit = 6250`; over 6,250 words with more than 25 pages, the build **panics** (it does not produce a PDF). | M |
| LR 7.4(d) (same) | Headings, footnotes and quotations count toward the word limit; caption, TOC, TOA, exhibits, declarations, certificates of counsel and certificates of service do not. | `count-words()` over the markdown body: headings, text, footnotes and quotations are counted; the caption, TOC, TOA, signature block and certificates are not. | M |
| LR 7.4(e) (same) | A memorandum submitted under LR 7.4(b) must include a certificate by the attorney stating its word count. | `certificate-of-compliance()`, printed automatically when the memorandum runs past 25 pages (the word alternative is then in use). | M (when 7.4(b) is used) |
| LR 7.4(f) (same) | Briefs and memoranda exceeding ten pages shall have a table of contents and a table of authorities. | `toc-section()` (outline of the level 1–3 headings with their page numbers) and `toa-section()` (built from the `toa:` links; page numbers by query; "passim" at 7 or more pages). Both are printed for every motion in this template; the TOC and TOA are present whatever the length. | M (over 10 pages) |
| LR 7.8 (same) | Before a motion, counsel must confer; the motion shall state: "This motion is made following the conference of counsel pursuant to LR7.8 which took place on [date]." | The motion paragraphs (frontmatter `motion`); the sample carries the statement. | M (statement) |
| LR 5.3 (same) | Electronic filing under Fed. R. Civ. P. 5(d)(3) and the local rules. | The PDF is the filing form; no certificate is required by the rule. | — |
| LR 12.1 and 10.3 (same) | Mandatory chambers copies of a Rule 12 motion include two copies of the related complaint; chambers copies are tabbed and in the form LR 10.3 requires. | Not produced (separate chambers copies). | M, separate |

Convention (tier 2; from the exemplar): the certificate of service in the caption (the exemplar's copy has none, so the template's certificate follows the CM/ECF wording in `certificate-of-service()`; that wording is the template's convention, not copied from the exemplar); the TOC, TOA and body numbering (roman for the front matter, arabic from 1 for the memorandum), with the motion's first page unnumbered; "Page(s)" heading in the TOA; `passim`; footers with a centered page number.

## Layout

- Page 1: counsel block (two columns, 12 pt in 13.8 pt lines; fb-595.68.22) and "Attorneys for Defendants" under it; court title; caption box (parties at left, a rule at right and bottom; at right, the case number, the document title in bold capitals, and "Judge:"). The caption stays on page 1 only if it fits; the template keeps the caption block unbreakable.
- Pages 1–2: the motion, its dated line and signature block; page 1 prints no number, a continuation page prints its own ("2"), so the caption page is the only unnumbered page (DEF-COVER-001).
- Pages i–ii: TABLE OF CONTENTS (outline, dotted leaders), TABLE OF AUTHORITIES (cases, statutes, rules; "Page(s)" at right; hanging indents).
- Pages 1–9 (arabic): MEMORANDUM IN SUPPORT OF MOTION, then the body. Level 1 headings: bold, left, roman (I., II.), capitals written in the markdown. Level 2: bold, letter (A., B.), sentence case. Level 3: bold, arabic. Each label in a half-inch box with the text hanging after it (fb-595.68.22). Body: 14 pt, double-spaced, first-line indent 0.5 in on every paragraph (including the first after a heading). Footnotes: 14 pt, single-spaced, at the foot of the page.
- The last paragraph of the memorandum is kept on the same page as the signature block, so a signature does not stand alone on a page (as ca9 does; when the last block is a heading, no paragraph is moved). Footnote definitions stay with the body part that holds their references.
- Certificate of compliance (only over 25 pages); certificate of service (when `service.certificate: true`), on a new page.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number` (with the judge's initials in it, as LR 10.2(c)(3) requires); `judge` (LR 7.3(b)); `counsel.columns` (1 to 3 columns, each a list of lines; `""` is a blank line); `counsel_for`; `parties` (list of `{names: [...], designation: "..."}`); `title` (the document title; printed in bold capitals); `hearing` and `trial_date` (optional, LR 7.3); `motion` (list of paragraphs, unnumbered, double-spaced); `date` (the dated line); `signature.blocks` (list of `{lines: [...]}`); `service` (`certificate: true`, `date`, `signature` lines); `authorities` (the table of authorities registry).
- Authorities registry: `key: {kind: case|statute|rule|constitution|regulation|other, name: "...", cite: "..."}`. `name` is optional; for a case it prints in italics. A key used in the body but not in the registry stops the build.
- Citations: a link whose target is `toa:KEY` with the citation as its text: `[*Gregg v. Haw. Dep’t of Pub. Safety*, 870 F.3d 883, 887 (9th Cir. 2017)](toa:gregg)`. Short forms and *Id.* link to the same key. Every link is recorded with the page on which it starts.
- Body headings: `# TITLE` (level 1, numbered I., II., ...), `## Title` (level 2, A., B., ...), `### Title` (level 3, 1., 2., ...). Numbers are never typed.
- Footnotes: `text[^key]`, with `[^key]: text` anywhere in the body (kept in the body part that holds the references).
- Block quotations: `> text`.
- Escape markers that start a paragraph: `1\. `, `2\) ` (as in ca9's contract).
- Not supported: tables, images, raw typst.

## Known gaps and open choices

1. **Overlay not regenerated.** The exemplar PDF is missing from this snapshot, so the overlay cannot run (see the overlay row). Tier-2 review of the new face against the exemplar is therefore not done.
2. **Rule 12(c), not 12(b).** The brief asked for a Rule 12(b) motion to dismiss. The only full-text D. Haw. motion reached is a Rule 12(c) motion (see Searches). The template is the same for either rule; the sample's motion text says 12(c).
3. **Excerpt.** The sample is the Background, the Legal Standard, the first part of Argument A and the Conclusion of the 25-page memorandum. Argument A continues and Arguments B and C are not transcribed. Footnotes 5 and 6 of the exemplar are omitted: their text is not legible in the text layer's reading order. The overlay pairs the sample's pages with the filing's pages by word overlap (see `OVERLAY-us-v-hawaii-motion-brief.txt`).
4. **Appendices A–B** are named in the title (as in the exemplar) but not attached; the sample has no appendices.
5. **Certificate of service.** The exemplar's copy has none, so the template's CM/ECF wording is the template's convention. The sample carries it.
6. **Word count.** The count is computed from the markdown (LR 7.4(d)), not from a word processor (LR 7.4(e) lets the preparer rely on the word processor's count; this template has none). Signature blocks are not counted. The count of the sample's memorandum is not printed (no certificate: under 25 pages).
7. **LR 7.4(b) path.** The certificate is printed only when the memorandum runs past 25 pages. The body of the sample is 9 pages, so the sample does not print one. The path was exercised with a temporary sample of short paragraphs (35 pages, certificate stating 1,688 words; the sample file was deleted afterwards), and the guard was exercised with a longer one (32 pages and 7,508 words: the build stopped with the LR 7.4 message). Both checks ran; neither output is in the repository.
8. **Hearing date and trial date** (LR 7.3(a), (c)) are printed only when the frontmatter gives them; the sample gives neither. The exemplar gives neither.
9. **Counsel block.** Counsel is 12 pt in two columns so the caption fits on page 1 (the exemplar's counsel block is also single-spaced and set smaller than the body). This is a layout choice (tier 2), not a rule.
10. **Italics in the exemplar.** Case names and signals are transcribed from the text layer's visible italic words, not from style data. The overlay compares words, not style.
11. **Level-3 headings** (`###`, numbered 1., 2.) are styled by the template but are not in the sample, so that style is untested.

## Searches for the exemplar (for the record)

- CourtListener RECAP (`type=rd`, `type=r`, `court=hid`): D. Haw. motions and memoranda are docketed, but almost none with a downloadable PDF; the anonymous API allows 5 requests per minute, and the documents endpoint needs an account.
- The Democracy Docket copy of *United States v. Nago*, 1:25-cv-00522 (Document 53, Rule 12(b)(6), filed 2026-02-18): only the first two pages are in the PDF; not usable as a full exemplar.
- Justia dockets and cases (`dockets.justia.com`, `cases.justia.com`): HTTP 403 to this box.
- Clearinghouse (`clearinghouse.net`): HTTP 403 to this box.
- stateimpactcenter.org PDFs (the Hawai‘i motion in the *Cruise Lines v. Suganuma* case): HTTP 403.
- Found and used: *United States v. State of Hawai‘i*, 1:25-cv-00179 (Document 22 and 22-1), the State's Rule 12(c) motion and memorandum, from the Climate Litigation Database's copy (`cdn.climatepolicyradar.org`).

## Engines

### docx (`docx/`)

- Built from `docx/reference.xml` (the cross-engine style recipe, `base="xengine"`, in the typst face; built by `fb render`) and `docx/hid.lua` (pandoc filter). `docx/make-reference.sh` and `docx/reference.docx` are gone (fb-595.68.22). `sh tools/render.sh --engine docx <this folder> usage/INPUT-motion-brief.md` writes `usage/OUTPUT-motion-brief.docx` and `usage/OUTPUT-motion-brief.docx.pdf` (14 pages, as typst).
- Both engines on the shared cross-engine layout model (fb-595.68.22): Times New Roman 14 pt, footnotes included (LR 10.2(a)(2)); 32.2 pt double pitch (LR 10.2(a)(4)), 16.1 pt single lines, the counsel block 12 pt in 13.8 pt lines; headings with the label in a half-inch box and the text hanging after it; footnotes at 14 pt in 16.1 pt lines, 7 pt apart; the last paragraph kept with the signature; centered "- n -" footer.
- Written by the filter: counsel block and caption box as tables (rule at the right and bottom of the parties box), with "No.", the upper-case title and "Judge:" at the right; the motion paragraphs (unnumbered) and their dated line and signature; the table of contents and the table of authorities (LR 7.4(f)) as listing rows with page columns, their pages through `fb render`'s needles; three sections (the motion with page 1 unnumbered, the tables roman from i, the memorandum arabic from 1); "MEMORANDUM IN SUPPORT OF MOTION" and the memorandum headings numbered I., A., 1.; the signature at the end of the memorandum; the LR 7.4(b)/(e) certificate of compliance past 25 pages, from the memorandum's last page and the markdown word count as typst counts it (both 1922 words in a test at a 5-page limit); the certificate of service on its own page (when `service.certificate` is true) (fb-595.68.22).
- Checks: `sh tools/check.sh <this folder> --engine docx`: `RESULT: 13 checks passed, 0 failed`; Gate 4 XENG-001..003 pass (14 pages, 257/257 lines break after the same word as typst; `eval.yaml` `params.cross_engine: gate`); DEF-TOC-001 and DEF-COVER-001 pass on both. typst: `RESULT: 9 checks passed, 0 failed`. The earlier docx BLOCKED items (no LibreOffice; TOC and TOA, LR 7.4(f); LR 7.4(b) and (e)) and the Liberation Serif typeface question are resolved by this port (fb-595.68.22).

## FRCP base port assessment (fb-595.17.12)

Skipped: a shared change is needed. D. Haw. LR 7.4(a), (b) and (e) (HID-LEN-001, tier 1) let a memorandum run past 25 pages only if it holds no more than 6,250 words and carries the attorney's word-count certificate; the template counts the memorandum's own pages (from its first body page, after the motion, the contents and the authorities), prints the certificate of compliance only when they pass 25, and stops the render when they pass 25 and the words pass 6,250. The shared document model can stop on a word count (`words.limit`) and print a block on a frontmatter field (`when`), but it has no condition on the rendered page count of a part of the document: a hard 6,250-word limit would refuse a memorandum of 25 pages or fewer that the rule allows, and a frontmatter switch would let a longer memorandum go out without the certificate the rule requires. Missing base feature: a limit or a block conditioned on the number of pages a part of the document takes (here the memorandum body: "over 25 pages, the word limit and the certificate apply"), in all three engines (typst `counter(page)` at the body's end, LaTeX the `.aux`, Word the page passes of docxpages.rs). The rest is expressible as an overlay: 14-point Times New Roman at 32.2 and 16.1 pt (LR 10.2(a)), the counsel block at 12 pt, the court title, the ruled caption with the judge (LR 10.2(b)-(c), 7.3), the motion paragraphs and its signature as the cover (unnumbered on both of its pages, `params.cover_pages: 2`), the tables in roman (LR 7.4(f)) with the titles centred (`contents.style`), the memorandum from 1 under its centred title, headings I./A./1. in half-inch label boxes, the certificate of service. This folder does not use pleading paper.
