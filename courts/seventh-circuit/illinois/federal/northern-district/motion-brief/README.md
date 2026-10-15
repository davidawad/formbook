# ilnd: motion-brief

Doc type: **motion-brief**, the memorandum of law in support of a Fed. R. Civ. P. 12(b) motion to dismiss, in the United States District Court for the Northern District of Illinois (`ilnd`).
Folder: `courts/seventh-circuit/illinois/federal/northern-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-tahboub-1-25-cv-12614-motion-brief.pdf` (1 filer; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-tahboub-motion-brief.md`: cover, introduction, factual background, legal standard, Argument I.A and I.B (first part), conclusion, signature, certificate of service, footnotes 1 to 6. Arguments II to IV are omitted (see Known gaps). |
| render | ok: `samples/OUTPUT-tahboub-motion-brief.pdf`, 10 pages (cover plus 9), typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-tahboub-motion-brief.pdf` and `OVERLAY-tahboub-motion-brief.txt` (page map) |
| typeface | face required: none (N.D. Ill. LR 5.2(e) names no typeface; checked 2026-10-15). Vendored substitute: not needed; stays **EB Garamond**. Metric compatibility: n/a. |
| pages reviewed | 10 of 10 (re-rendered 2026-10-15 and every page rendered at 60 dpi and viewed) |

Build (from the repo root, with the toolchain on `PATH`):

```sh
D=courts/seventh-circuit/illinois/federal/northern-district/motion-brief
sh tools/render.sh $D samples/INPUT-tahboub-motion-brief.md         # -> samples/OUTPUT-tahboub-motion-brief.pdf
sh tools/overlay.sh $D tahboub-motion-brief                   # -> samples/OVERLAY-tahboub-motion-brief.{pdf,txt}
```

File names follow the tools (see the complaint README for the reason).

## Governing rules

Primary sources, fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| N.D. Ill. LR 7.1 (https://www.ilnd.uscourts.gov/_assets/_documents/_rules/lrrules.pdf) | A motion or a brief in support of a motion may not exceed 15 pages without prior approval. A brief over 15 pages needs a table of contents with page numbers and a table of cases. A non-compliant brief may be stricken. | Not enforced by the template. The template does **not** generate a table of contents or a table of authorities (see Known gaps). The sample is under 15 pages. |
| N.D. Ill. LR 5.2(e) | Same as the complaint: 8½ × 11 paper; line spacing at least 2.0 lines; 12-point body; footnotes at least 11 points; margins at least 1 inch. | `margin-*` (1 in), `type-size = 12pt`, `note-size = 11pt` (footnote entries), `body-leading = 1.65em` (27.6 pt pitch). |
| N.D. Ill. LR 5.3(b) | A judge may require a notice of presentment for a motion. | Not produced: the notice of motion is a separate document. |
| N.D. Ill. LR 5.5(a) to (c) | A certificate of service is required only when service on the filing system is made on a recipient who is not an E-Filer; it must identify the persons served, the date and the manner. | `certificate` frontmatter (optional). The exemplar includes one; the template prints it only when the sample gives one, on its own page. |
| Fed. R. Civ. P. 7(b)(1) (https://www.law.cornell.edu/rules/frcp/rule_7, fetched 2026-10-14) | A request for a court order must be made by a written motion that states the grounds with particularity and the relief sought. | Content of the notice of motion (not part of this doc type). The memorandum states the grounds in the introduction. |
| Fed. R. Civ. P. 12(b)(1) and 12(b)(6) (https://www.law.cornell.edu/rules/frcp/rule_12) | The defenses of lack of subject-matter jurisdiction and failure to state a claim may be raised by motion. | Content only. The sample's "Legal Standard" section states both standards. |
| Fed. R. Civ. P. 11(a) (https://www.law.cornell.edu/rules/frcp/rule_11) | Signed by an attorney of record; the signer's address, e-mail address and telephone number. | `signature-block` and the cover counsel block (from `counsel`). |

## Layout

- Cover page (no page number): court title (three centered lines, single-spaced), a caption with a column of ")" marks (the parties on the left, the case number and judge on the right, as in the exemplar), the title of the paper centered in bold, and the counsel block at lower right, single-spaced.
- Body from page 1 (the page numbers start after the cover): double-spaced (27.6 pt pitch), justified, first-line indent 0.5 in on every paragraph. Paragraphs are not numbered.
- Headings: level 1 is a centered bold capital section (INTRODUCTION, LEGAL STANDARD, ARGUMENT, CONCLUSION); level 2 a bold heading (the points, I., II.); level 3 bold, indented 0.5 in (the sub-points, A., B.); a level-4 heading (1., 2.) is set like level 3. A heading takes one pitch above and below and stays with the next block.
- Footnotes: 11 pt, single-spaced, with a 1.5 in rule. Definitions are written as `[^key]: ...` anywhere in the body; the template passes every definition to each chunk that refers to it (cmarker resolves a reference only against definitions in the same source).
- The last paragraph, its heading if any, and the signature block are kept together.
- Signature block: "Dated", "Respectfully submitted,", the party in capitals, "By: /s/" the signer, "One of Their Attorneys" (or the frontmatter role).
- Certificate of service (when given): its own page, a centered heading, double-spaced text, a right-column signature.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Blank-line-separated chunks: `#` (level 1), `##` (level 2), `###` and deeper (level 3 style), a list (`1.` items), a quotation (`>`), or a paragraph.
- Frontmatter: `case_number`, `judge` (optional), `division` (optional), `caption.parties` (list of `{names, designation}`; each name line is one row of the ")" column; "v." between parties), `brief_title` (list of lines), `counsel` (list of groups; each group is a list of lines, the last of which may be italic, e.g. `*Attorneys for Defendant*`), `date`, `signature` (`party` lines, `signer`, `role` lines), `certificate` (optional: `text`, `signer`, `role`).
- Heading numbers (I., A., 1.) are typed in the sample; the template does not number headings.
- Not supported: tables, raw typst. Quotations and lists are supported by the template but not exercised by the sample (see Known gaps).

## Known gaps and open choices

1. **No table of contents or table of authorities (LR 7.1).** A brief over 15 pages must carry both. The template does not generate them, and the sample is under 15 pages, so the rule does not bite here. A real brief over 15 pages needs a TOC and a table of cases added or the brief shortened: this is a tier-1 gap for the template. The exemplar itself (21 pages, no TOC or table of cases) is over the limit; whether the court granted leave was not checked.
2. **Notice of motion not produced.** The filed motion (ECF 24 in the exemplar's docket) is a separate document: the notice, the motion, and the judge's presentment requirements (LR 5.3(b)) are not in this template.
3. **Sample is a portion.** Transcribed from pages 1 to 9 and 19 to 21 of the 21-page filing, with Argument I.B cut after its first two paragraphs, and Arguments II to IV omitted (marked in the text). Typos in the source are carried over ("PURSANT", the certificate's "to be served to be filed"). Two extraction artifacts are corrected: the Iqbal pin cite reads "680–81" and the Lubavitch reporter cite reads "806 816" as printed.
4. **Exemplar is one filer.** Tier 2 is judged against this one filing only; see the complaint README for the other N.D. Ill. filings found.
5. **Font.** No font is mandated by LR 5.2(e) (verified 2026-10-15; see the complaint README). The template keeps EB Garamond, per `docs/FONTS.md`. The exemplar is Times New Roman; the difference in apparent size is the same as in the complaint, and is visual only.
6. **Caption style.** This template uses the ")" column (as in the exemplar). The complaint template uses a box; both are seen in N.D. Ill. filings. Recorded as ACCEPTED.
7. **Counsel block.** The exemplar places the counsel block on the cover and repeats it after the signature; the template prints it on the cover only.
8. **Untested template features.** Block quotations (`>`), bulleted lists and the level-4 heading are coded but not exercised by a sample; they are not verified.
9. **Certificate of service.** LR 5.5(a) requires a certificate only for service on a non-E-Filer. The exemplar has one anyway; the template prints one only when the sample gives one.
10. **Gates not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape and the brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent for this doc type.

## Search for further exemplars

CourtListener RECAP (`type=r`, `court=ilnd`, "memorandum in support of motion to dismiss"): the first page of results held no other motion memorandum with a downloadable PDF beyond the ones listed below. Other candidates seen but not saved: *45 Spirits LLC v. Sultan*, No. 1:26-cv-04902 (memorandum in support of a Rule 12(b)(2) motion, 18 pp, docket 73262099); *Anderson v. American Dental Associates*, No. 1:26-cv-01084 (opposition, not a motion, 24 pp). Only the Tahboub memorandum is saved.

## Review of the rendered pages (current PDF)

- Page 1 (cover, unnumbered): court title, caption with ")" column, case number and judge, title centered, counsel at lower right. No spill. Pass.
- Page 2 (page "1"): INTRODUCTION heading; body double-spaced with first-line indents; footnote marks. Pass.
- Page 3 (page "2"): paragraphs; footnotes 1 and 2 at the foot, 11 pt, single-spaced, with a rule. Pass.
- Page 4 (page "3"): "RELEVANT FACTUAL BACKGROUND" with footnote 3 mark in the heading; footnote 3 at the foot. Pass.
- Page 5 (page "4"): the end of the background; footnote 4 at the foot; LEGAL STANDARD moves to the next page with its paragraph, so no heading ends a page. Pass.
- Page 6 (page "5"): LEGAL STANDARD; ARGUMENT; the point heading I (two-line, no hyphenation); "A." heading with its first paragraph on the same page. Footnote 5 at the foot. Pass.
- Page 7 (page "6"): "B." heading with footnote 6 mark; footnote 6 at the foot. Pass.
- Page 8 (page "7"): sub-heading "1." (two lines, bold, indented); paragraphs; the page ends mid-paragraph. Pass.
- Page 9 (page "8"): the end of Argument I.B; the omission note (italic, indented); CONCLUSION; signature block (Dated, Respectfully submitted, party, "By: /s/", "One of Their Attorneys"). Pass.
- Page 10 (page "9"): CERTIFICATE OF SERVICE on its own page; text double-spaced; signature right column. Pass.
